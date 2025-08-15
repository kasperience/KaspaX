# August Session Roadmap: Integrating kdapp-wallet

I'm taking a short holiday break, but development doesn't have to stop! This is an open invitation for any community members who want to jump in and help build the future of decentralized identity on Kaspa.

The next major milestone is to make our vision of "Authentication as a Service" a reality by integrating the `kdapp-wallet` with our new `kaspa-auth-daemon`.

## The Vision: The "ssh-agent" for Kaspa

The goal is to stop applications from handling private keys directly. Instead, they will ask the secure, background daemon to perform signing operations for them.

| Feature          | `ssh-agent` (The Analogy)                                   | `kaspa-auth-daemon` (Our Goal)                                 |
| ---------------- | ----------------------------------------------------------- | -------------------------------------------------------------- |
| **Purpose**      | Manages SSH private keys.                                   | Manages **Kaspa** private keys.                                |
| **Runs as**      | A background process (daemon).                              | A background process (daemon).                                 |
| **Unlock**       | Unlock key with passphrase **once** per session.            | Unlock wallet with password **once** per session.              |
| **Client**       | `ssh`, `git`, `scp` commands.                               | `kdapp-wallet-cli`, other apps.                                |
| **Request**      | "Authenticate me for this server."                          | "Sign this Kaspa transaction for me."                          |
| **Benefit**      | No repeated passphrase entry. Apps don't need key access.   | No repeated wallet password entry. Apps don't need key access. |

## Implementation Plan

Here is a concrete, 3-step plan to achieve this. A focused developer could likely create a proof-of-concept in just a few days.

### Step 1: Teach the Daemon to Sign Transactions

The `kaspa-auth-daemon` needs a new command to sign arbitrary transaction data.

1.  **Modify `src/daemon/protocol.rs`**:
    *   Add a `DaemonRequest::SignTransaction { username: String, transaction_data: Vec<u8> }` variant.
    *   Add a `DaemonResponse::TransactionSigned { signed_transaction: Vec<u8> }` variant.
2.  **Modify `src/daemon/service.rs`**:
    *   Implement the logic for the `SignTransaction` request. This involves finding the user's unlocked wallet and using the private key to sign the provided data.

### Step 2: Modify the `kdapp-wallet` Client

The `kdapp-wallet` needs to be updated to use the daemon instead of handling keys itself.

1.  **Add a new command** like `send-via-daemon`.
2.  This command will **not** ask for a private key. Instead, it will connect to the daemon's socket.
3.  It will construct the raw transaction, send it to the daemon via the new `SignTransaction` request, and wait for the signed response.
4.  Finally, it will broadcast the signed transaction received from the daemon.

### Step 3: End-to-End Testing

1.  Run `kaspa-auth-daemon start`.
2.  Unlock an identity using `kaspa-auth-daemon send unlock ...`.
3.  Use the new `kdapp-wallet send-via-daemon` command to send a transaction.
4.  Verify the transaction on a block explorer.

---

This is a fantastic opportunity to contribute to a real, cutting-edge decentralized project. All the foundational work is done. Now it's time to connect the pieces!

Happy coding!