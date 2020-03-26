# Releasing Facebook ObjC SDK

This document will guide you through the process of issuing a new version of the Facebook SDK.

## Release Steps

### Bump Version

Run the bump version script:

```sh
# Call `bump-version` and pass in the desired semantic version, e.g. 4.40.0
sh scripts/run.sh bump-version 4.40.0
```

This script will modify the relevant version references and will edit the Changelog.

Ensure that the version changes and Changelog updates are correct, then commit these changes with the title: "Bump
Version: 4.40.0" and submit a Pull Request.

### Tag Version

Once the bump version diff has successfully landed on the branch you wish to release, and all CI builds have passed, run
the tag current version script:

```sh
# Ensure you're on the correct commit, e.g. latest master
git checkout master && git pull

# Tag the currently set version and, optionally, push to origin
sh scripts/run.sh tag-current-version --push
```

### Release Version

Head over to the [GitHub Releases](https://github.com/facebook/facebook-objc-sdk/releases), select the pushed tag, and
add the copy for the new release from the Changelog to the release body. Give it the title of "Facebook SDK: X.Y.Z" and
click "Publish Release".

**Note:** Automation of this step is a WIP.

### Release FBSDKMarketingKit

On your machine, run:

```sh
cd internal/FBSDKMarketingKit/
carthage build --archive
zip \
  -x "*.DS_Store" \
  -r Carthage/Build/iOS/Static/FBSDKMarketingKit.zip \
  Carthage/Build/iOS/Static/FBSDKMarketingKit.framework
```

Take this file and upload it to the latest GitHub releases.

Once done, run:

```sh
pod trunk push FBSDKMarketingKit.podspec --allow-warnings
```

**Note:** You'll need edit access for GitHub releases. Automation of this step is a WIP.

### Update Reference Documentation

On your machine, run:

```sh
sh scripts/run.sh release docs --publish
```

This will construct the documentation via. Jazzy and, optionally, upload them to developers.facebook.com.

**Note:** You'll need access to the internal repository scripts.

### Update Guides Documentation

On your machine, run:

```sh
sh scripts/run.sh release changelog
```

This will upload the Changelog and new version to developers.facebook.com.

**Note:** You'll need access to the internal repository scripts.

## Advanced Steps

All the steps below will normally be handled by Travis CI. In case Travis CI automation fails, here are the remaining
steps necessary for a release.

### Upload Frameworks for Carthage

On your machine, run:

```sh
sh scripts/run.sh build carthage --archive
```

This will place all the SDK kits into the `Carthage/Release/` directory. Upload all the zip files to the GitHub Release.

### Release to Cocoapods

On your machine, run:

```sh
sh scripts/run.sh release cocoapods --allow-warnings
```

This will publish all the podspecs.
