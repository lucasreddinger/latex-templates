Attached: a LaTeX template and a document. Drop the document into the template to produce the finished file.

The template has two kinds of content, treated oppositely:

- **Scaffolding** = the template's infrastructure (sectioning machinery, float renumbering, page styles, geometry/font switches, title-page layout, boilerplate and common packages/config). Keep it verbatim — but only the scaffolding the document's structure calls for (see "Match the scaffolding" below).
- **Custom slots** = the per-document sections (custom packages, custom config) and fill-in values (header comment, paths, bib resource, metadata). Specific to this document: discard whatever the template seeds them with and include only what the document needs.

Match the scaffolding to what the document actually is:

- If it's a paper only (no supplement) → strip all the supplement scaffolding from the document area of the file.
- If it's a supplement only → skip straight to the start of the supplement; drop the main-text scaffolding (its title page, main-text branch, etc.).
- If it's both → keep both.

Then:

- Cut the template's example/placeholder content; replace it with the document.
- Header comment → replace the template's title/description lines with a few terse title lines for the document (not a description); leave the rest of the header (compile block, font note) as-is.
- Custom packages / custom config → minimal: only what actually appears in the resultant document. No extra packages or config the document doesn't use.
- Paths, bib resource, metadata → the document's values, verbatim where it specifies them.

Don't add anything the document doesn't use, don't pad or drop blank lines the template didn't have, and don't compile, test, or otherwise verify the result — just deliver the file. Verification is my job.
