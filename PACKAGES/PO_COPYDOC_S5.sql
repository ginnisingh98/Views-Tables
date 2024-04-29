--------------------------------------------------------
--  DDL for Package PO_COPYDOC_S5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_S5" AUTHID CURRENT_USER AS
/* $Header: POXCPO5S.pls 115.3 2003/10/08 03:01:57 arusingh ship $*/

--<Encumbrance FPJ: add sob_id to param list>
PROCEDURE validate_distribution(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype	    IN      po_headers.type_lookup_code%TYPE,
  x_po_distribution_record  IN OUT NOCOPY  po_distributions%ROWTYPE,
  x_po_header_id            IN      po_distributions.po_header_id%TYPE,
  x_po_line_id              IN      po_distributions.po_line_id%TYPE,
  x_line_location_id        IN      po_distributions.line_location_id%TYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                IN      po_online_report_text.line_num%TYPE,
  x_shipment_num            IN      po_online_report_text.shipment_num%TYPE,
  x_sob_id                  IN      FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
);

--< Shared Proc Start >
PROCEDURE generate_accounts
(
    x_return_status       OUT    NOCOPY VARCHAR2,
    p_online_report_id    IN     NUMBER,
    p_po_header_rec       IN     PO_HEADERS%ROWTYPE,
    p_po_line_rec         IN     PO_LINES%ROWTYPE,
    p_po_shipment_rec     IN     PO_LINE_LOCATIONS%ROWTYPE,
    x_po_distribution_rec IN OUT NOCOPY PO_DISTRIBUTIONS%ROWTYPE,
    x_sequence            IN OUT NOCOPY NUMBER
);
--< Shared Proc End >

END po_copydoc_s5;

 

/
