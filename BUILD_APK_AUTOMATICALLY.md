# WCK Vault — Automatic APK Build

This project is prepared so the Android platform files can be generated automatically during a cloud build. The repository workflow is:

1. Upload the contents of this `WCK_Vault_App` folder to a GitHub repository.
2. Make sure the repository's default branch is `main` or `master`.
3. On push, GitHub Actions runs the workflow in `.github/workflows/build-apk.yml`.
4. The workflow installs Flutter, generates the Android platform files, gets dependencies, and builds a release APK.
5. Open the repository's **Actions** tab, select **WCK Vault - Build Android APK**, open the successful run, and download the artifact named **WCK-Vault-Android-APK**.

You can also start the workflow manually from **Actions → WCK Vault - Build Android APK → Run workflow**.

## Important
- The current WCK Vault app contains a local/demo login + OTP dialog. Real SMS OTP, secure backend authentication, user approval, and server-side Super Admin controls require production backend deployment and credentials.
- The 133 source PDFs are bundled as app assets.
- Original source files/revisions remain separate; no silent merge is performed.
