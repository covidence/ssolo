## [Unreleased]

## [0.1.1] - 2025-05-15

- Switched the puma process in the `ssolo` executable to use single-threaded mode. This avoids different ephemeral certificates in each thread/worker.
- Improved the detection of certificate prefix/suffix lines when outputting the IdP metadata.

## [0.1.0] - 2025-05-15

- Initial release
