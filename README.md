# alexmoss.co.uk

[alexmoss.co.uk](https://alexmoss.co.uk) is - on the surface at least - an online CV describing the career of me, Alex Moss.

It also serves as a way for me to experiment with some cloud-native technologies using a very simple application.

---

## Cloud Run Experiment

- [ ] Check other features
  - [ ] auto-build just via `gcloud run`?
  - [ ] If not, try `kaniko`

---

## Tech

- [ ] Dashboard
- [ ] Alerts
- [ ] Availability checks

---

## Theme Edits

The sections I wanted are different from what the theme ships with. You can control this by editing `themes/somrat/layouts/index.html` to control the filenames used etc.

These were the sections I ended up with:

0. Banner
1. About, Experience + Skills
2. Services --> Tech Skills, extend with words
   - Ditch the call to action
3. Platform Engineering like About
4. Cloud Architecture like About but reversed
   - [removed] Portfolio - keep, link to other sites
5. Education
6. Testimonials --> Interests
7. Fun Facts
8. Contact

### Other Adjustments

1. There's some custom CSS added in `custom.css`.
2. I disabled the tags + related posts functionality in `themes/somrat/layouts/_default/single.html`, as I didn't want to use them and they looked odd with blank info.
3. I edited the "Read More" links to have a forward arrow instead of down, and therefore a different animation too. This is in `index.html`.
4. I edited the portrait photo in the About section to not be width: 100% and to align it to the center of the div by setting `mx-auto` in `index.html`.
5. Added `contact.js` (my own code) and linked to it in `script.html`. For this to work I also added `jqBootstrapValidation.js` (you can find this easily enough on t'interwebz).
6. Disabled the Portfolio section in `index.html`. Didn't need it for this content.
7. Created a 404 page - it was blank. See `404.html`.
8. Replaced remote sourcing of fontawesome and rubik fonts with local copies. I like to minimise my external dependencies!
9. I also deleted several assets that weren't used - such as screenshots and example site for the theme.

## Local Development

`./go run`. You need to have Hugo installed (tested with `hugo v0.90.1+extended`).

## Other Themes

As an aside, I considered the following other Hugo themes before settling the `somrat` one:

- [port-hugo](https://github.com/tylerjlawson/port-hugo) - pretty similar to this one
- [timer-hugo](https://github.com/themefisher/timer-hugo)
