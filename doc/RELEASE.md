# Release

ℹ️ **For now the most of the release process is pretty manual, but the plan is to
make it as automatic as possible in a near future.** ℹ️

## Tagging

Any release should start with a tag. Tags should be named using [Semantic
versioning](https://semver.org/) and be annotated, where the tag message should
be the release notes for this tag.

To tag a version use:

```sh
git tag -a v0.3.1
```

This will open an editor to write the tag message.  The `RELEASE-NOTES.md` can
be used as a starting point for the tag message as normally this file should be
updated on every user-facing change with a description of that change.

## Platforms

### Web

The web release process is already automated. For now all changes in master are
automatically deployed to the website. In the future we should only deploy
releases and provide a *beta* or *next* website where the latest master is
deployed (and possibly automatically deploy pull requests too to a test
website).

### Android

These are very simplified instructions on how to make a release build that can
be uploaded to the Google Play Store.

For now the process is pretty manual, but the plan is to make it as automatic as
possible.

These instructions are mainly based in [Flutter's Build and release an Android
app document](https://flutter.dev/docs/deployment/android).

#### Signing keys

To make a release we need to sign the distribution files (apk or appbundle) with
a release key. The key is stored in a keystore and the same key should be always
used to upload the same app. So this key should be already created and stored
safely somewhere, but if this is the first time doing the process, a new key and
keystore can be created like this (in the project's root):

```console
$ keytool -genkey -v -keystore .java-keystore.jks -keyalg RSA -keysize 2048 \
    -validity 10000 -alias me.noclick.app
```

This will prompt for a password. A very secure password should be used. The same
password will be used for both the new key and the key store if it didn't exist
before.

The key alias is `me.noclick.app` and `.java-keystore.jks` is where the keystore
file is saved. These are important because they are specified in the
`android/key.properties` file (so if a different key alias or key store location
is used, this file should be updated too).

⚠️ **The key store file should NOT be saved in the repository, is a private
key.** ⚠️

### Building the release version

The tagged version should be built as an appbundle. For now the `--build-name`
(`versionName` in Android lingo) and `--build-number` (`versionCode`) are
passed explicitly until we automate the release an have these in sync with the
`pubspec.yaml` file.

The `--build-number` should be calculated based on the version like this:

`vX.Y.Z` → `XXXYYYZZZZ`

Where for each component should be padded with zero to reach the require width
and then leading zeros should be removed from the final number. This leaves us
without `--build-number` for pre-releases, but that should be fine as
pre-releases can be done as regular releases using different distribution
channels (like development, beta and final).

Example:

```text
v0.3.5 → 0000030005 → 30005
         XXXYYYZZZZ
```

Please note that the [maximum `--build-number` is
2100000000](https://developer.android.com/studio/publish/versioning.html#appversioning),
this means in our case `X` can't be bigger than 210.

Then to do the release build, you can use this command:

```console
$ flutter build appbundle --release --build-name v0.3.5 --build-number 30005

Building without sound null safety
For more information see https://dart.dev/null-safety/unsound-null-safety

Running Gradle task 'bundleRelease'...
Running Gradle task 'bundleRelease'... Done                        12.2s
✓ Built build/app/outputs/bundle/release/app-release.aab (17.9MB).
```

The appbundle in `build/app/outputs/bundle/release/app-release.aab` is ready
for upload to the Google Play Store.
