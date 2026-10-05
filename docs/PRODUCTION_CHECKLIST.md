# WCK Vault Production Checklist

1. Deploy authentication + OTP backend.
2. Create Noyon as the sole Super Admin in the server database.
3. Enforce server-side RBAC.
4. Store original PDFs in protected object storage.
5. Generate short-lived authenticated PDF access URLs.
6. Add audit events for login, search, document open, import, revision, user changes and security events.
7. Add Android FLAG_SECURE / platform screenshot controls.
8. Add Windows session/device policy.
9. Add server-side document revision history.
10. Import and index the complete 134+ PDF inventory.
11. Extract/verify product visuals from each source PDF; never substitute unrelated images.
12. Run Android and Windows release builds and QA.
