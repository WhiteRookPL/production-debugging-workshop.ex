# Debugging Elixir in Production - *Workshop*

## **Join the Elixir Fire Brigade - Level-up Your Elixir Debugging Skills**

Both *Erlang* and *Elixir* are praised for their "debuggability". It's true - there's a lot of tools and techniques that can be used, even on live, production systems. Not only that - they are easily accessible and freely usable. Together we're going to explore them in depth.

We're going to learn what exactly happens when you call a GenServer, how to "spy" on processes and introspect the *VM* internals. We're going to work with an example application - a basic key-value store built on top of plug, prepare a release for it and deploy it to production. Unfortunately, after the deployment we're going to discover some errors, we didn't anticipate. Fortunately, with the knowledge we gained earlier, we'll be able to diagnose and fix them - live in production!

Attendees should be familiar with syntax and basic features of either *Elixir* or *Erlang*. It is advised that all attendees complete the *"Mix and OTP tutorial"* before the workshop. Link is here: http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html

Participants should have `Elixir >= 1.3` and `Erlang >= 18` locally installed, together with their favorite editor.

## Editions

- [**ElixirConf EU** (*Barcelona*, 2017)](http://www.elixirconf.eu/events/elixirconf2017/tutorials#tutorial-join-the-elixir-fire-brigade-level-up-your-elixir-debugging-skills)

## Prerequisites

- *Erlang* - verified with *18.3* and above.
- *Elixir* - verified with *1.3* and above.
- *Phoenix* - verified with *1.3* and above.

For managing multiple *Erlang* and *Elixir* versions we recommend [asdf](https://github.com/asdf-vm/asdf).

## How to using this workshop?

### Moving through bugs

If you want to tackle particular bug just move to a specific tag:

```bash
production-debugging-workshop.ex $ git checkout BUG_1
```

If you want to check how it was fixed, move to the corresponding tag with a *fix*:

```bash
production-debugging-workshop.ex $ git checkout FIX_1
```

In order to see how it was solved just do a `git diff`:

```bash
production-debugging-workshop.ex $ git diff BUG_1..FIX_1
```

Explanation why and how to debug and narrow it down is inside [materials](#materials).

### Helpers

Feel free to use prepared helpers and scripts that will ease your pain when using this repository (please keep in mind that scripts requires `curl`). You will find them in the `helpers` directory which contains:

- Markdown *cheat-sheet* with helpful tools and commands used during workshop (`helpers/commands.md`).
- Scripts for executing `curl` commands (using _REST API_).
  - If you do not like command line - do not worry, we have prepared exported version of those *API* calls compatible with [*Advanced REST Client*](https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo/related).
    - Unfortunately it is *Google Chrome* / *Chromium* only add-on - *PR* for other browsers are welcomed! :smile:

## Materials

If you were on one of editions mentioned [above](#editions) you should receive materials after the workshop in a dedicated email from us.
Unfortunately rest of people will have to wait - *stay tuned*. :wink:

## Authors

- [@afronski](https://github.com/afronski)
- [@mentero](https://github.com/mentero)
- [@michalmuskala](https://github.com/michalmuskala)
