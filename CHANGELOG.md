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

[Unreleased]: https://github.com/blinkdog/telnet-stream/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/blinkdog/telnet-stream/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/blinkdog/telnet-stream/compare/v1.0.0...v1.0.1
