# https://moss.work

moss.work is - on the surface at least - an online CV describing the career of Alex Moss.

In truth, it serves as a way to experiment with cloud automation technologies by using a very simple application.

The technology stack is basically GitbookIO (although this is not out of active development, so probably ought to replace it!).

It was my first foray into Docker/Kubernetes, so probably not of the highest standard :) I'll try to remember to retro some of the other things I learn as I go back into the build.

---

## To Do

- [ ] Add an Interests section - technology & extra-curricular
- [ ] Live/Ready Probes
- [ ] Trigger it from a CI/CD tool
- [ ] Automated testing, inc security scanning
- [ ] Availability checking

---

## How To

Install gitbook locally - on my mac, `brew install gitbook` does the trick

You can then use the `./go` bash script wrapper - run it without arguments to see the options. This can be used to build locally as well as part of CI.

---

## Running locally

```
cd content/ && gitbook serve
```

---

## Known Issues

1. You need to pre-install the additional plugins locally first (they appear in the content/node_modules/ directory). In theory the gitbook entrypoint script should be able to sort these out, but it doesn't seem to be working correctly for me.
2. To get the Google Analytics plugin working, I had to manually edit the package.json to remove a dependency on gitbook >= v4.0.0-alpha.0. I manually edited it to require 3.2.3. I couldn't get v4.0.0 to install properly.
