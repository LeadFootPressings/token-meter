# Digital exhibition foundation

Collection name: **LeadFoot Pressings**, selected by the owner. This is the public-facing collection name; it does not assert a company or separate legal entity.

The prototype is a separate, self-contained local scaffold, excluded from the application repository under `.local-preparation/invention-exhibition/`. It can be moved intact to its own repository when approved. No hosting registration, remote repository, analytics, external assets, or deployment has been created.

The revised design uses cool slate/blue tones, blue-violet gradients, translucent glass surfaces, and direct product language. Its buildless HTML/CSS/JavaScript introduces Token Meter as exhibit 001, explains the two windows, shows actual synthetic-data app previews, records the design history, and offers an explicitly labeled interactive explanation. The browser demo cannot read an account or execute the native app. Download/source availability is stated honestly until real approved URLs exist.

## Reusable project model

Each invention uses a catalog entry with: stable slug, exhibit number, name, subtitle/problem, platform, version, release status, license status, screenshots and alt text, features, development notes, contribution information, and optional try/download/source URLs. `templates/project.json` and `templates/project.html` are starting points. Copy the template and populate verified content; leave unavailable actions absent with a plain-language status. Do not insert fake links or generic success claims.

The shell supplies common typography, colors, navigation, responsive layout, focus states, project facts, image treatment, and a journal section. Apps remain independent repositories; the exhibition only carries descriptive metadata, approved images, and links. Future web-native projects can link to a real Try It page; native apps should offer a download or clearly labeled demonstration.

## GitHub Pages assessment

GitHub Pages is suitable for the initial static exhibition: HTML/CSS/JS, images, project indexes, and browser-local demos. It does not run the native macOS app, a Python/Swift backend, private database logic, or secret-bearing API calls. Keep binaries as GitHub Release assets rather than repeatedly committing them into website history. Pages logs visitor IP addresses for security, so a later privacy statement must not claim the host collects nothing. See [GitHub Pages overview](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages).

Choose a dedicated `<owner>.github.io` repository once the owner exists. Relative asset paths in the prototype also support project subpaths. Keep deployment disabled until approved. A first deployment can be a deliberate manual Pages setup; later automation should require owner approval of the exact version.

GitHub Pages is not intended for sites primarily facilitating commercial transactions or providing commercial SaaS. If the collection evolves into a storefront or paid service, re-evaluate hosting and use an appropriate commercial platform/backend. Secrets, authentication, purchases, and licensing servers do not belong in client-side JavaScript. See [GitHub Pages limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits).
