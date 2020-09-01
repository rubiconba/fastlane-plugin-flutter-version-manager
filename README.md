# flutter_version_manager plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-flutter_version_manager)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-flutter_version_manager`, add it to your project by running:

```bash
fastlane add_plugin flutter_version_manager
```

Inside project root, create new `version.yml` file and add the following:
```
---
major: 0
minor: 0
patch: 1

```
## About flutter_version_manager

Manages app versioning of a Flutter project. This plugin heavily resides on having a git repository and at least one commit as version code is applied through timestamp of HEAD commit. As for app version, `version.yml` should be used as a single source of truth. In order to apply changes to pubspec, use `-apply` as an argument of a plugin.

This plugin accepts 4 arguments:
`yml` - Path to version.yml file
`pubspec` - Path to pubspec.yaml file
`git_repo` - Path to git repository (optional)
`arguments` - Additional arguments (optional)
```
-h: Access this menu
-version: Reads current version name
-code: Reads current version code
-major: Bumps major version
-minor: Bumps minor version
-patch: Bumps patch version
-apply: Applies version specified from version.yml to pubspec
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
