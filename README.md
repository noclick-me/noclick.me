# noclick.me App [![Sponsor](https://img.shields.io/badge/-Sponsor-555555?style=flat-square)](https://github.com/llucax/llucax/blob/main/sponsoring-platforms.md)[![GitHub Sponsors](https://img.shields.io/badge/--ea4aaa?logo=github&style=flat-square)](https://github.com/sponsors/llucax)[![Liberapay](https://img.shields.io/badge/--f6c915?logo=liberapay&logoColor=black&style=flat-square)](https://liberapay.com/llucax/donate)[![Paypal](https://img.shields.io/badge/--0070ba?logo=paypal&style=flat-square)](https://www.paypal.com/donate?hosted_button_id=UZRR3REUC4SY2)[![Buy Me A Coffee](https://img.shields.io/badge/--ff813f?logo=buy-me-a-coffee&logoColor=white&style=flat-square)](https://www.buymeacoffee.com/llucax)[![Patreon](https://img.shields.io/badge/--f96854?logo=patreon&logoColor=white&style=flat-square)](https://www.patreon.com/llucax)[![Flattr](https://img.shields.io/badge/--6bc76b?logo=flattr&logoColor=white&style=flat-square)](https://flattr.com/@llucax)

[![CI](https://github.com/noclick-me/noclick.me/workflows/CI/badge.svg)](https://github.com/noclick-me/noclick.me/actions?query=branch%3Amain+workflow%3ACI+)
[![Coverage](https://codecov.io/gh/noclick-me/noclick.me/branch/main/graph/badge.svg?token=UW4J79EE4T)](https://codecov.io/gh/noclick-me/noclick.me)

Share links with more descriptive URLs!

This repository is the home of the mobile and web app to create new links in
a noclick.me server.

## License

The project is published under APGL (see [LICENSE.md](LICENSE.md)).

The main goal of choosing this license is to protect user's right. There is
a second goal, for which there are not very good known licenses, which is to
protect my ability (as developer behind the project) to sustain myself by
finding ways to make a living with my work.

Because of this I decided to use a standard open source license and wirte
a (non-legally binding) [declaration of
intent](https://github.com/llucax/llucax/blob/main/license-declaration-of-intent-v1.md).
Please read it if you want to make sure this software can stay alive and
healthy (specially if you plan to offer this software as a service).

## Contributing

This project is written in [Flutter](https://flutter.dev/). Once you have
a working Flutter SDK installed, you can build it with `flutter build` and try
it out with `flutter run`.

### Git Hooks

This repository provides some useful Git hooks to make sure new commits have
some basic health.

The hooks are provided in the `.githooks/` directory and can be easily used by
configuring git to use this directory for hooks instead of the default
`.git/hooks/`:

```sh
git config core.hooksPath .githooks
```

So far there is a hook to prevent commits with the `WIP` word in the message to
be pushed, and one hook to run `flutter analyze` and `flutter test` before
a new commit is created. The later can take some time, but it can be easily
disabled temporarily by using `git commit --no-verify` if you are, for example,
just changing the README file or amending a commit message.

### Releasing

Please have a look at the [release document](doc/RELEASE.md).
