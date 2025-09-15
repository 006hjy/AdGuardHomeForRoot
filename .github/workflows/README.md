# GitHub Workflow Documentation

## Build Workflow

The `build.yml` workflow automatically builds AdGuardHome for Root packages with the latest AdGuardHome releases.

### Triggers

- **Manual**: Can be triggered manually via GitHub Actions UI
- **Push**: Triggered on pushes to main branch
- **Pull Request**: Triggered on PRs to main branch  
- **Schedule**: Runs daily at 2 AM UTC to check for new AdGuardHome releases

### Architecture Support

The workflow builds packages for both supported architectures:
- **ARM64**: For modern 64-bit Android devices
- **ARMv7**: For older 32-bit Android devices

### Process

1. **Release Detection**: 
   - Fetches latest AdGuardHome release from GitHub API
   - Falls back to web scraping if API fails
   - Uses known working release as final fallback

2. **Download & Extract**:
   - Downloads `AdGuardHome_linux_arm64.tar.gz` or `AdGuardHome_linux_armv7.tar.gz`
   - Extracts the AdGuardHome binary from the archive
   - Validates the extraction was successful

3. **Package Creation**:
   - Copies AdGuardHome binary to `src/bin/` directory
   - Creates zip archive with all files from `src/` directory
   - Uploads artifacts for download

4. **Release Creation** (scheduled runs only):
   - Creates a new GitHub release
   - Uploads both ARM64 and ARMv7 packages
   - Includes installation instructions in release notes

### Output

- **Artifacts**: Available for 30 days after build
- **Releases**: Created automatically for scheduled builds
- **Naming**: `AdGuardHomeForRoot_[arch].zip`

### Manual Execution

To manually trigger the workflow:
1. Go to Actions tab in GitHub
2. Select "Build AdGuardHome for Root" workflow
3. Click "Run workflow"
4. Choose the branch (usually main)
5. Click "Run workflow"

The workflow will create both ARM64 and ARMv7 packages and optionally create a release if triggered manually.