# Remove the file from git history
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch firebase-tools-instant-win.exe" --prune-empty --tag-name-filter cat -- --all

# Clean up refs
git for-each-ref --format="delete %(refname)" refs/original/ | git update-ref --stdin

# Clean up loose objects
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Remove the file locally if it exists
if (Test-Path "firebase-tools-instant-win.exe") {
    Remove-Item "firebase-tools-instant-win.exe"
}

# Clean git repository
git rm -r --cached .
git add .
git commit -m "Clean repository and remove large files"
