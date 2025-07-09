# Automated Slicer Build with GitHub Actions

This repository contains GitHub Actions workflows to automatically build 3D Slicer on multiple platforms. This approach is much more reliable than manual builds and handles all dependencies automatically.

## 🚀 Quick Start

### Option 1: Use the Workflows in This Repository

1. **Fork this repository** or copy the workflow files to your own repository
2. **Push to main branch** or **manually trigger** the workflow
3. **Download the built Slicer** from the Actions artifacts

### Option 2: Manual Trigger

1. Go to the **Actions** tab in your GitHub repository
2. Select **"Build Slicer (Simplified)"** workflow
3. Click **"Run workflow"**
4. Choose **Release** or **Debug** build type
5. Click **"Run workflow"** button

## 📁 Workflow Files

### 1. `build-slicer.yml` (Full Multi-Platform)
- **Platforms**: Windows, Linux, macOS
- **Features**: Full build with caching, testing support
- **Duration**: 4-6 hours per platform
- **Use case**: Complete CI/CD pipeline

### 2. `build-slicer-simple.yml` (Windows Only)
- **Platform**: Windows only
- **Features**: Simplified, faster build
- **Duration**: 3-4 hours
- **Use case**: Quick Windows builds

## ⚙️ Workflow Features

### ✅ Automatic Dependency Management
- **CMake** (compatible version 3.28.3)
- **Qt 5.15.2** with MSVC2019 components
- **Visual Studio 2022** build tools
- **Python 3.9** environment

### 🔄 Smart Caching
- **Qt installation** cached between runs
- **Slicer dependencies** cached for faster rebuilds
- **Build artifacts** preserved for 30 days

### 📦 Build Outputs
- **Windows**: `.exe` installer and portable `.zip`
- **Linux**: `.tar.gz` and `.deb` packages  
- **macOS**: `.dmg` installer and `.app` bundle

## 🛠️ Customization

### Build Configuration Options

Edit the workflow files to customize:

```yaml
env:
  QT_VERSION: '5.15.2'        # Qt version
  CMAKE_VERSION: '3.28.3'     # CMake version
  BUILD_TYPE: Release          # Release or Debug
```

### Slicer Build Options

Modify CMake configuration:

```yaml
- name: Configure Slicer
  run: |
    cmake \
      -DSlicer_BUILD_TESTING:BOOL=OFF \          # Disable tests
      -DSlicer_BUILD_DOCUMENTATION:BOOL=OFF \    # Disable docs  
      -DSlicer_USE_PYTHONQT_WITH_TCL:BOOL=OFF \  # Disable TCL
      # Add more options as needed
```

### Platform-Specific Settings

#### Windows
```yaml
runs-on: windows-2022
generator: "Visual Studio 17 2022"
architecture: x64
```

#### Linux
```yaml
runs-on: ubuntu-22.04
generator: "Unix Makefiles"
packages: build-essential cmake git libgl1-mesa-dev
```

#### macOS
```yaml
runs-on: macos-12
generator: "Unix Makefiles"
deployment_target: "10.15"
```

## 📊 Build Status & Monitoring

### Check Build Status
1. Go to **Actions** tab in your repository
2. Click on the running workflow
3. Monitor progress in real-time

### Download Artifacts
1. Wait for build completion (✅ green checkmark)
2. Scroll down to **"Artifacts"** section
3. Download the platform-specific package

### Troubleshooting Failed Builds
1. Check the **build logs** in the failed job
2. Download **error logs** from artifacts (if available)
3. Common issues:
   - **Disk space**: Ensure runner has enough space (60GB for Debug)
   - **Timeout**: Build took longer than 6 hours
   - **Dependencies**: Missing or incompatible versions

## 🔧 Local Development Integration

### Use with Your Slicer Fork

1. **Fork Slicer repository**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Slicer.git
   cd Slicer
   ```

2. **Copy workflow files**:
   ```bash
   mkdir -p .github/workflows
   # Copy the .yml files from this repository
   ```

3. **Customize for your needs**:
   - Edit branch triggers
   - Modify build options
   - Add custom build steps

### Environment Variables

Set these in your repository settings → Secrets:

```yaml
# Optional: for private Qt license
QT_ACCOUNT: ${{ secrets.QT_ACCOUNT }}
QT_PASSWORD: ${{ secrets.QT_PASSWORD }}

# Optional: for code signing
WINDOWS_CERTIFICATE: ${{ secrets.WINDOWS_CERTIFICATE }}
MACOS_CERTIFICATE: ${{ secrets.MACOS_CERTIFICATE }}
```

## 📝 Manual Build Comparison

| Method | Time | Reliability | Setup Effort | Maintenance |
|--------|------|-------------|--------------|-------------|
| **Manual Local** | 3-12 hours | ⚠️ Medium | 🔴 High | 🔴 High |
| **GitHub Actions** | 3-6 hours | ✅ High | 🟢 Low | 🟢 Low |

### Advantages of GitHub Actions:
- ✅ **Clean environment** every time
- ✅ **Automatic dependency management**
- ✅ **Multi-platform builds** simultaneously  
- ✅ **No local resource usage**
- ✅ **Reproducible builds**
- ✅ **Built-in artifact storage**

## 🔍 Advanced Usage

### Matrix Builds
Build multiple configurations simultaneously:

```yaml
strategy:
  matrix:
    build_type: [Release, Debug]
    platform: [windows-2022, ubuntu-22.04, macos-12]
    qt_version: ['5.15.2']
```

### Conditional Builds
Only build on specific conditions:

```yaml
# Only build on releases
on:
  release:
    types: [published]

# Only build specific file changes
on:
  push:
    paths:
      - 'src/**'
      - 'CMakeLists.txt'
```

### Notification Integration
Add Slack/Discord notifications:

```yaml
- name: Notify on completion
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🆘 Support & Troubleshooting

### Common Issues

**1. Build Timeout**
```yaml
timeout-minutes: 360  # Increase to 6+ hours
```

**2. Disk Space**
```yaml
- name: Free disk space
  run: |
    docker system prune -af
    rm -rf /usr/local/lib/android
```

**3. Memory Issues**
```yaml
cmake --build . --parallel 1  # Reduce parallelism
```

### Getting Help

1. **Check Slicer documentation**: https://slicer.readthedocs.io/
2. **Slicer Discourse forum**: https://discourse.slicer.org/
3. **GitHub Issues**: Create an issue in this repository
4. **Build logs**: Always attach full build logs when asking for help

## 📄 License

This workflow configuration is provided under the same license as 3D Slicer. 
See the [Slicer License](https://github.com/Slicer/Slicer/blob/main/License.txt) for details.

---

**Happy Building! 🚀**
