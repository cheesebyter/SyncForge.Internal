# SyncForge Release Template

> Copy this file to `RELEASE_NOTES_vX.Y.Z.md` and replace placeholders.

---

# SyncForge vX.Y.Z

Release Date: YYYY-MM-DD  
Git Tag: vX.Y.Z  
Commit: <short-sha>  

---

## 1. Release Summary

Short description of this release.

Example:
SyncForge v0.2.0 introduces the Excel Connector and improves atomic Replace handling while maintaining backward compatibility within the 0.1.x contract.

---

## 2. Version Classification

- [ ] PATCH (Bugfix only, no behavior change)
- [ ] MINOR (Backward compatible feature additions)
- [ ] MAJOR (Breaking changes introduced)

SemVer Justification:

Explain why this version number was chosen.

---

## 3. Added

List new features introduced in this release.

- 
- 
- 

---

## 4. Changed

List behavior changes that are backward compatible.

- 
- 
- 

---

## 5. Fixed

List bug fixes.

- 
- 
- 

---

## 6. Deprecated

List features marked as deprecated (still functional).

- 
- 

Removal planned for version: X.Y.Z

---

## 7. Breaking Changes

If none, explicitly state:

> None.

Otherwise:

### BC-1 – Title

Description of change.

Impact:
- What breaks?
- Who is affected?

Migration Guide:
- Step 1
- Step 2
- Example before/after

---

## 8. Performance Notes

If applicable, include benchmark data.

Example:

- 500MB CSV → ~9.4s
- 2GB CSV → ~23.4s
- Peak Memory ~150MB

Changes affecting performance:
- 
- 

---

## 9. Exit Code Contract

Status:

- [ ] No changes to existing exit codes
- [ ] New exit codes added (non-breaking)
- [ ] Exit code changes (Breaking Change documented above)

Verification:

`check-exit-codes.ps1` result:
- [ ] Verified

---

## 10. Job Configuration Schema

Status:

- [ ] No breaking changes
- [ ] New optional fields added
- [ ] Breaking schema change (documented above)

JSON Schema updated:
- [ ] Yes
- [ ] Not applicable

---

## 11. Connector Changes

CSV:
- 

Excel:
- 

MS-SQL:
- 

REST:
- 

---

## 12. Compatibility Matrix

.NET Version:
- 

Linux (tested):
- 

Windows (tested):
- 

SQL Server (tested):
- 

Docker Version (if applicable):
- 

---

## 13. Security Notes

- Any security-related changes?
- Dependency updates?
- Secret-handling changes?

If none:

> No security-impacting changes in this release.

---

## 14. Known Limitations

Explicitly list current limitations.

- 
- 
- 

---

## 15. Upgrade Instructions

If none:

> No special upgrade steps required.

Otherwise:

1. 
2. 
3. 

---

## 16. Artifacts

Release binaries:

- syncforge-linux-x64
- syncforge-win-x64

Checksums:

- SHA256 (Linux):
- SHA256 (Windows):

---

## 17. CI Status

- [ ] Linux build successful
- [ ] Windows build successful
- [ ] Smoke tests passed
- [ ] Integration tests passed
- [ ] Performance benchmarks verified (if applicable)

---

## 18. Maintainer Sign-off

Release prepared by:
Reviewed by:
Approved on:

---

End of Release Notes.