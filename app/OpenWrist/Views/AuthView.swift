import SwiftUI

struct AuthView: View {
    @ObservedObject var store: AuthStore
    @State private var adding = false

    var body: some View {
        NavigationStack {
            List {
                if store.accounts.isEmpty {
                    ContentUnavailableView("No accounts",
                        systemImage: "lock.shield",
                        description: Text("Add a 2FA account to see its codes here."))
                }
                ForEach(store.accounts) { account in
                    // TimelineView refreshes the code + countdown every second.
                    TimelineView(.periodic(from: .now, by: 1)) { ctx in
                        AccountRow(account: account, now: ctx.date)
                    }
                }
                .onDelete { store.remove(at: $0) }
            }
            .navigationTitle("Authenticator")
            .toolbar {
                Button { adding = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $adding) {
                AddAccountView { store.add($0) }
            }
        }
    }
}

private struct AccountRow: View {
    let account: TOTPAccount
    let now: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.issuer).font(.headline)
                Text(account.label).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(account.code(at: now))
                    .font(.title2.monospacedDigit().bold())
                    .foregroundStyle(.tint)
                Text("\(OWTOTP.secondsRemaining(at: now, period: account.period))s")
                    .font(.caption).monospacedDigit().foregroundStyle(.secondary)
            }
        }
    }
}

struct AddAccountView: View {
    var onAdd: (TOTPAccount) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var issuer = ""
    @State private var label = ""
    @State private var secret = ""
    @State private var uri = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Paste setup link") {
                    TextField("otpauth://totp/…", text: $uri).autocorrectionDisabled()
                }
                Section("…or enter manually") {
                    TextField("Issuer (e.g. Microsoft)", text: $issuer)
                    TextField("Account (e.g. you@work.com)", text: $label)
                    TextField("Secret key (base32)", text: $secret).autocorrectionDisabled()
                }
                if let e = error { Text(e).foregroundStyle(.red) }
            }
            .navigationTitle("Add account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { add() }
                }
            }
        }
    }

    private func add() {
        if !uri.trimmingCharacters(in: .whitespaces).isEmpty {
            guard let acc = TOTPAccount.parse(otpauth: uri) else {
                error = "Invalid otpauth link"; return
            }
            onAdd(acc); dismiss(); return
        }
        guard OWTOTP.base32Decode(secret) != nil, !secret.isEmpty else {
            error = "Invalid base32 secret"; return
        }
        onAdd(TOTPAccount(issuer: issuer.isEmpty ? label : issuer,
                          label: label, secretBase32: secret))
        dismiss()
    }
}
