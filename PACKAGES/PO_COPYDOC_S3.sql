--------------------------------------------------------
--  DDL for Package PO_COPYDOC_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_S3" AUTHID CURRENT_USER AS
/* $Header: POXCPO3S.pls 120.1 2005/09/13 17:57:16 spangulu noship $*/
/*  Functionality for PA->RFQ Copy : dreddy
    new parameter copy_price is passed */
PROCEDURE validate_line(
  x_action_code         IN      VARCHAR2,
  x_to_doc_subtype      IN      po_headers.type_lookup_code%TYPE,
  x_po_line_record      IN OUT NOCOPY  po_lines%ROWTYPE,
  x_orig_po_line_id     IN      po_lines.po_line_id%TYPE,
  x_wip_install_status  IN      VARCHAR2,
  x_sob_id              IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_po_header_id        IN      po_lines.po_header_id%TYPE,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_copy_price          IN      BOOLEAN,
  x_return_code         OUT NOCOPY     NUMBER,
  p_is_complex_work_po  IN      BOOLEAN    -- <Complex Work R12>
);

END po_copydoc_s3;

 

/
