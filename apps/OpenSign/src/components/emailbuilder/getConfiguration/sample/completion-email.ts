import { TEditorConfiguration } from "../../documents/editor/core";
import { logoUrl } from "../../../../constant/Utils";

const getCompletionEmail = (
): TEditorConfiguration => {
  const appName =
    "InLibro - Signatures";

  const logoBlock =
        {
          "block-1709571212684": {
            type: "Image",
            data: {
              style: {
                padding: { top: 24, bottom: 24, right: 24, left: 24 }
              },
              props: {
                width: null,
                height: 50,
                url: logoUrl,
                alt: "logo",
                linkHref: null,
                contentAlignment: "middle"
              }
            }
          }
        };
  const logoBlockId =
        ["block-1709571212684"];

  return {
    root: {
      type: "EmailLayout",
      data: {
        backdropColor: "#f5f5f5",
        canvasColor: "#FFFFFF",
        canvasWidth: 600,
        textColor: "#242424",
        fontFamily: "MODERN_SANS",
        childrenIds: [
          ...logoBlockId,
          "block-1770633502472",
          "block-1770795667636",
          "block-1770795483071"
        ]
      }
    },
    ...logoBlock,
    "block-1770633502472": {
      type: "Text",
      data: {
        style: {
          color: "#FFFFFF",
          backgroundColor: "#29A9D8",
          fontSize: 20,
          fontWeight: "bold",
          padding: {
            top: 16,
            bottom: 16,
            right: 24,
            left: 24
          }
        },
        props: {
          markdown: false,
          text: "Document signé avec succès\n\n"
        }
      }
    },
    "block-1770633797211": {
      type: "Text",
      data: {
        style: {
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 24
          }
        },
        props: {
          text: "Sender"
        }
      }
    },
    "block-1770633813576": {
      type: "Text",
      data: {
        style: {
          color: "#626363",
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 0
          }
        },
        props: {
          text: "{{receiver_email}}"
        }
      }
    },
    "block-1770633912944": {
      type: "Text",
      data: {
        style: {
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 24
          }
        },
        props: {
          text: "Organization"
        }
      }
    },
    "block-1770633915601": {
      type: "Text",
      data: {
        style: {
          color: "#626363",
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 0
          }
        },
        props: {
          text: "{{company_name}}"
        }
      }
    },
    "block-1770633918679": {
      type: "Text",
      data: {
        style: {
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 24
          }
        },
        props: {
          text: "Expires on"
        }
      }
    },
    "block-1770633921948": {
      type: "Text",
      data: {
        style: {
          color: "#626363",
          backgroundColor: null,
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 0
          }
        },
        props: {
          text: "{{expiry_date}}"
        }
      }
    },
    "block-1770633961786": {
      type: "Text",
      data: {
        style: {
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 24
          }
        },
        props: {
          text: "Note"
        }
      }
    },
    "block-1770633964531": {
      type: "Text",
      data: {
        style: {
          color: "#626363",
          fontSize: 15,
          fontWeight: "bold",
          padding: {
            top: 0,
            bottom: 0,
            right: 24,
            left: 0
          }
        },
        props: {
          text: "{{note}}"
        }
      }
    },
    "block-1770795483071": {
      type: "Html",
      data: {
        style: {
          backgroundColor: "#f5f5f5",
          fontSize: 14,
          textAlign: null,
          padding: {
            top: 16,
            bottom: 16,
            right: 24,
            left: 24
          }
        },
        props: {
          contents: `Ceci est un courriel automatique de ${appName}. Pour toute question concernant cet courriel, veuillez contacter directement l'expéditeur à l'adresse <a href="mailto:{{sender_mail}}" target="_blank">{{sender_mail}}</a>.`
        }
      }
    },
    "block-1770795667636": {
      type: "Html",
      data: {
        style: {
          fontSize: 14,
          textAlign: null,
          padding: {
            top: 32,
            bottom: 20,
            right: 20,
            left: 20
          }
        },
        props: {
          contents:
            'Toutes les parties ont signé le document avec succès. "<b>{{document_title}}</b>". Veuillez télécharger le document joint.'
        }
      }
    }
  };
};

export default getCompletionEmail;
