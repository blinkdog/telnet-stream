# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- for new features
### Changed
- for changes in existing functionality
### Deprecated
- for soon-to-be removed features
### Removed
- for now removed features
### Fixed
- for any bug fixes
### Security
- in case of vulnerabilities

## [1.0.5] - 2021-01-17
### Added
- Contributor Voakie provided TypeScript definitions for telnet-stream
### Changed
- Modified check task to use Promises for dependency version checks
- Modified coverage task to use nyc library instead of istanbul
- Modified deprecated Buffer allocations in two test classes
- Updated dev dependencies to latest versions in package.json

## [1.0.4] - 2017-11-25
### Added
- Example source code to ensure examples function properly
### Changed
- Examples in README.md to make them functional

## [1.0.3] - 2017-11-25
### Changed
- Minor clean up of package.json

## [1.0.2] - 2017-11-25
### Added
- CHANGELOG.md added to npm published files in package.json

## [1.0.1] - 2017-11-25
### Changed
- Minor clean up of TelnetOutput

## 1.0.0 - 2017-11-25
### Added
- TelnetSocket to decorate a net.Socket
- Options object to specify subnegotiation buffer size and error policy
- Emit error events on subnegotiation errors
- Test coverage reporting with istanbul
- LICENSE and README.md files to npm published archive
- CHANGELOG.md to track project changes

### Changed
- Default behavior for subnegotiation errors; bytes are kept not discarded
- Location of test sources

[Unreleased]: https://github.com/blinkdog/telnet-stream/compare/v1.0.5...HEAD
[1.0.5]: https://github.com/blinkdog/telnet-stream/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/blinkdog/telnet-stream/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/blinkdog/telnet-stream/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/blinkdog/telnet-stream/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/blinkdog/telnet-stream/compare/v1.0.0...v1.0.1
