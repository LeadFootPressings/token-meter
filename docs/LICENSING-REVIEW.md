# License decision and comparison

**Approved: MIT.** The owner accepted the recommendation and supplied **LeadFoot** as the copyright holder. The project [LICENSE](../LICENSE) uses 2026, the project development year, as its copyright year; this is not a public release date. Apache 2.0 is a strong alternative if an explicit contributor patent grant and patent-litigation provisions are priorities. GPLv3 fits a deliberate goal of keeping distributed derivatives open, but is less aligned with unrestricted proprietary derivatives. The comparison below records the basis for the decision. The project LICENSE contains the governing text; this memo adds no terms.

All three allow public use, modification, redistribution, and commercial use. None reserves commercial use exclusively to the original author.

| Topic | MIT | Apache 2.0 | GPLv3 |
| --- | --- | --- | --- |
| Redistribution | Retain copyright/license notice | Retain license/notices, mark changes; preserve applicable NOTICE content | Preserve notices and satisfy source/conveyance conditions |
| Closed derivatives | Permitted | Permitted with conditions | Distributed covered derivatives generally must be GPL with corresponding source |
| Patents | No express patent grant in the text | Express, scoped contributor patent grant; patent-litigation termination | Express patent provisions and contributor patent grants |
| Contributor ownership | Contributors retain ownership unless separately agreed | Same; default contribution licensing is addressed in section 5 | Contributors retain ownership; contributions must be compatible with GPL distribution |
| Future commercial work | Proprietary versions/other projects possible if rights allow | Same, subject to retained notices and license obligations | Separate projects possible; proprietary relicensing of covered third-party contributions requires additional permission |

A source-code license is distinct from the price of an app, trademark ownership, platform terms, and rights to a hosted service. Prior compliant recipients keep the rights already granted; a later commercial edition cannot retroactively withdraw those permissions. Contributors do not automatically assign their copyright to the maintainer. Collect permission or obtain appropriate contribution terms before promising future dual licensing of their work.

For inventions with potentially patentable subject matter, review patent strategy with qualified counsel before public disclosure. The recommendation here does not assess patentability or promise patent protection. Apache's express grant is a substantive decision, not merely a longer MIT notice.

## Material reviewed

The original Swift UI, AppKit icon generator, Python icon packer, and shell scripts contained no license file, copyright notices, package dependencies, or attributed third-party source. That inspection cannot establish authorship or chain of title. The owner identified LeadFoot for the copyright notice. This code review does not independently establish legal ownership of the original material.

No Codex executable is bundled; users install it independently. Apple frameworks and system symbols remain subject to Apple's terms. The CI workflow references GitHub's checkout action at an exact commit; it is not embedded in the app. The exhibition uses original local HTML/CSS and the actual demo images, with system fonts and no third-party images or remote font services.

The approved MIT text is applied to Token Meter and its associated documentation. The separate exhibition website has not been assigned a license by this decision. Before publication, confirm rights to distribute the original material and establish the public contribution/reporting routes. No CLA, DCO, assignment, or legal ownership statement has been adopted by this preparation.

A paid or hosted Token Meter also needs a new service-integration review. The current OpenAI app-server authentication restrictions are independent of all three source licenses.

## Primary/reference texts

- [MIT text, GitHub's Choose a License](https://choosealicense.com/licenses/mit/)
- [Apache License 2.0, Apache Software Foundation](https://www.apache.org/licenses/LICENSE-2.0)
- [GPLv3 text, GitHub's Choose a License](https://choosealicense.com/licenses/gpl-3.0/)
- [OpenAI app-server authentication guidance](https://learn.chatgpt.com/docs/app-server)

Sources reviewed November 5, 2026. The GNU-hosted GPL page could not be fetched during this review; the complete text was consulted through GitHub's license reference instead.
