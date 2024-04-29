--------------------------------------------------------
--  DDL for Package PO_INTG_DOCUMENT_FUNDS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTG_DOCUMENT_FUNDS_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGFCKS.pls 115.6 2004/06/10 18:25:26 arusingh noship $*/


-------------------------------------------------------------------------------
--Package global constants

g_doc_type_REQUISITION CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE := 'REQUISITION';

g_doc_type_PO CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE := 'PO';

g_doc_type_PA CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE := 'PA';

g_doc_type_RELEASE CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE := 'RELEASE';


-------------------------------------------------------------------------------
-- Public APIs

PROCEDURE reinstate_po_encumbrance(
   p_api_version       IN         NUMBER,
   p_commit            IN         VARCHAR2 default FND_API.G_FALSE,
   p_init_msg_list     IN         VARCHAR2 default FND_API.G_FALSE,
   p_validation_level  IN         NUMBER default FND_API.G_VALID_LEVEL_FULL,
   p_distribution_id   IN         NUMBER,
   p_invoice_id        IN         NUMBER,
   p_encumbrance_amt   IN         NUMBER,
   p_qty_cancelled     IN         NUMBER,
   p_budget_account_id IN         NUMBER,
   p_gl_date           IN         DATE,
   p_period_name       IN         VARCHAR2,
   p_period_year       IN         VARCHAR2,
   p_period_num        IN         VARCHAR2,
   p_quarter_num       IN         VARCHAR2,
   p_tax_line_flag     IN         VARCHAR2 default NULL,  -- Bug 3480949
   x_packet_id         OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
);

PROCEDURE get_active_encumbrance_amount(
   p_api_version       IN  NUMBER
,  p_init_msg_list     IN  VARCHAR2 default FND_API.G_FALSE
,  p_validation_level  IN  NUMBER default FND_API.G_VALID_LEVEL_FULL
,  x_return_status     OUT NOCOPY VARCHAR2
,  p_doc_type          IN  VARCHAR2
,  p_distribution_id   IN  NUMBER
,  x_active_enc_amount OUT NOCOPY NUMBER
);

FUNCTION get_active_encumbrance_func(
   p_doc_type          IN  VARCHAR2
,  p_distribution_id  IN  NUMBER
)
RETURN NUMBER;
-- bug 3669608: removed pragma WNDS restriction from this API

END PO_INTG_DOCUMENT_FUNDS_GRP;

 

/
