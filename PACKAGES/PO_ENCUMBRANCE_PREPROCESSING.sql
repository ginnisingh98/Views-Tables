--------------------------------------------------------
--  DDL for Package PO_ENCUMBRANCE_PREPROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ENCUMBRANCE_PREPROCESSING" AUTHID CURRENT_USER AS
-- $Header: POXENC1S.pls 120.0.12010000.2 2014/02/04 04:35:53 gjyothi ship $



-- Procedures used by PO_DOCUMENT_FUNDS_PVT.do_action:

PROCEDURE get_all_distributions(
   p_action                         IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_get_backing_docs_flag          IN             VARCHAR2
,  p_ap_budget_account_id           IN             NUMBER
,  p_possibility_check_flag         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
,  x_count                          OUT NOCOPY     NUMBER
);


PROCEDURE do_encumbrance_validations(
   p_action                         IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_validate_document              IN             VARCHAR2
,  p_do_state_check_flag            IN             VARCHAR2   -- Bug 3280496
,  x_validation_successful_flag     OUT NOCOPY     VARCHAR2
,  x_sub_check_report_id            OUT NOCOPY     NUMBER
);


PROCEDURE derive_packet_values(
   p_action                    IN   VARCHAR2
,  p_cbc_flag                  IN   VARCHAR2
,  p_doc_type                  IN   VARCHAR2
,  p_doc_subtype               IN   VARCHAR2
,  p_use_gl_date               IN   VARCHAR2
,  p_override_date             IN   DATE
,  p_partial_flag              IN   VARCHAR2
,  p_set_of_books_id           IN   NUMBER
,  p_currency_code_func        IN   VARCHAR2
,  p_req_encumb_type_id        IN   NUMBER
,  p_po_encumb_type_id         IN   NUMBER
,  p_ap_reinstated_enc_amt     IN   NUMBER
,  p_ap_cancelled_qty          IN   NUMBER
,  p_invoice_id                IN   NUMBER
);

PROCEDURE derive_dist_from_doc_types(
   p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  x_distribution_type              OUT NOCOPY     VARCHAR2
);

PROCEDURE derive_doc_types_from_dist(
   p_distribution_type              IN             VARCHAR2
,  x_doc_type                       OUT NOCOPY     VARCHAR2
,  x_doc_subtype                    OUT NOCOPY     VARCHAR2
);

PROCEDURE check_enc_action_possible(
   p_action            IN VARCHAR2
,  p_doc_type          IN  VARCHAR2
,  p_doc_subtype       IN  VARCHAR2
,  p_doc_level         IN  VARCHAR2
,  p_doc_level_id      IN  NUMBER
,  x_action_possible_flag OUT NOCOPY VARCHAR2
);


PROCEDURE delete_encumbrance_gt;

-- Bug 15987200
PROCEDURE get_reversal_amounts(
  p_doc_type          IN VARCHAR2
,  p_doc_subtype      IN VARCHAR2
,  p_currency_code_func  IN  VARCHAR2
,  p_min_acct_unit_func  IN  NUMBER
,  p_cur_precision_func  IN  NUMBER
);

END PO_ENCUMBRANCE_PREPROCESSING;

/
