--------------------------------------------------------
--  DDL for Package PO_COPYDOC_S6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_S6" AUTHID CURRENT_USER AS
/* $Header: POXCPO6S.pls 115.3 2002/11/25 23:34:16 sbull ship $*/

PROCEDURE validate_ussgl_trx_code(
  x_ussgl_transaction_code  IN OUT NOCOPY  VARCHAR2,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                IN      po_online_report_text.line_num%TYPE,
  x_shipment_num            IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num        IN      po_online_report_text.distribution_num%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
);

PROCEDURE insert_rfq_vendors(
  x_po_header_id          IN  NUMBER,
  x_po_vendor_id          IN  NUMBER,
  x_po_vendor_site_id     IN  NUMBER,
  x_po_vendor_contact_Id  IN  NUMBER
);

END po_copydoc_s6;

 

/
