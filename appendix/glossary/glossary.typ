#import "../../config/constants.typ" : glossary
#import "terms.typ": glossary-terms
#import "../../config/thesis-config.typ": print-glossary

#pagebreak(to:"odd")
#heading(numbering: none, glossary) <glossary>

#print-glossary(
  glossary-terms,
  deduplicate-back-references: true,
  user-print-title: (entry) => {
    let short = entry.at("short")
    let capitalized = upper(short.clusters().first()) + short.clusters().slice(1).join("")
    if "long" in entry and entry.at("long") != none {
      [*#capitalized* -- #entry.at("long")]
    } else {
      [*#capitalized*]
    }
  }
)