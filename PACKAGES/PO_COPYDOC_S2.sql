--------------------------------------------------------
--  DDL for Package PO_COPYDOC_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_S2" AUTHID CURRENT_USER AS
/* $Header: POXCPO2S.pls 115.2 2002/11/25 23:36:08 sbull ship $*/

PROCEDURE validate_header(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype          IN      po_headers.type_lookup_code%TYPE,
  x_to_global_flag	    IN	    po_headers_all.global_agreement_flag%TYPE,	-- GA
  x_po_header_record        IN OUT NOCOPY  PO_HEADERS%ROWTYPE,
  x_to_segment1             IN      po_headers.segment1%TYPE,
  x_agent_id                IN      po_headers.agent_id%TYPE,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
-- xkan  x_currency_code           IN      po_headers.currency_code%TYPE,
-- xkan  x_rate_type               IN      po_headers.rate_type%TYPE,
-- xkan  x_rate_date               IN      po_headers.rate_date%TYPE,
-- xkan  x_rate                    IN      po_headers.rate%TYPE,
-- xkan  x_vendor_id               IN      po_headers.vendor_id%TYPE,
-- xkan  x_vendor_site_id          IN      po_headers.vendor_site_id%TYPE,
-- xkan  x_vendor_contact_id       IN      po_headers.vendor_contact_id%TYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
);

END po_copydoc_s2;

 

/
