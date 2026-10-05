# WCK Vault — Final Build Package

**Waterproofing & Construction Knowledge Vault**  
**Created by Noyon**

## Included
- Flutter Android + Windows/PC application source
- 133 currently accessible source PDFs bundled under `assets/source_pdfs/`
- Original PDF filenames preserved
- Searchable indexed source text for all 133 accessible PDFs
- Product/TDS/application/technical/methodology/precaution record structure
- Original PDF viewer using `pdfx`
- Separate revision/source files preserved
- Super Admin dashboard and control structure
- Inventory manifest for the final 133-PDF source set

## Inventory status
- Final WCK Vault source set: **133 PDFs**
- All 133 source PDFs are bundled in this package.
- No missing PDF is required for this final baseline.

## Important production requirement
This package is the **final build-ready source/data package**, not a falsely claimed signed APK/EXE. The current execution environment does not contain Flutter/Android SDK/Windows build tooling, and no production OTP/backend credentials are available here.

Before public deployment, connect:
1. Secure authentication + password hashing
2. Real OTP provider
3. Server-side user approval/roles/suspension/revocation
4. Protected PDF storage/access rules
5. Server-side audit logging
6. Production signing keys for Android and Windows

The bundled app intentionally labels these as production integration requirements rather than pretending the local demo login is a real OTP service.

## Automatic APK build
The project now includes `.github/workflows/build-apk.yml`. Upload/commit this project to a GitHub repository and the workflow will automatically generate the Android release APK as a downloadable Actions artifact. A Windows `build_apk.bat` is also included for local builds when Flutter/Android tooling is installed.
