--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_S6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_S6" AS
/* $Header: POXCPO6B.pls 120.1 2005/06/03 05:07:18 appldev  $*/


PROCEDURE validate_ussgl_trx_code(
  x_ussgl_transaction_code  IN OUT NOCOPY  VARCHAR2,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                IN      po_online_report_text.line_num%TYPE,
  x_shipment_num            IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num        IN      po_online_report_text.distribution_num%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
) IS

  x_progress    VARCHAR2(4);
  x_valid_flag  VARCHAR2(2);

BEGIN
  /* R12 SLA : Will always return true. This function should not be used */
  x_progress := '001';
  x_return_code := 0;
  RETURN;

END validate_ussgl_trx_code;

/*************************************************************************
 PROCEDURE insert_rfq_vendors()
       used in blanket to RFQ copy  - dreddy 1388111
**************************************************************************/

PROCEDURE insert_rfq_vendors(x_po_header_id          IN  NUMBER,
                             x_po_vendor_id          IN  NUMBER,
                             x_po_vendor_site_id     IN  NUMBER,
                             x_po_vendor_contact_Id  IN  NUMBER
                             ) IS

BEGIN
    INSERT INTO PO_RFQ_VENDORS(
                   po_header_id,
                   sequence_num,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   creation_date,
                   created_by,
                   vendor_id,
                   vendor_site_id,
                   vendor_contact_id,
                   print_flag,
                   print_count,
                   printed_date,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15
                   ) VALUES  (   x_po_header_id,
				 1,
                               	 sysdate,
                             	 fnd_global.user_id,
                              	 fnd_global.login_id,
                               	 sysdate,
                               	 fnd_global.user_id,
                                 x_po_vendor_id,
                               	 x_po_vendor_site_id,
                               	 x_po_vendor_contact_Id,
				 'Y',
				 null,
                               	 null,
                              	 null,
                               	 null,
                                 null,
                               	 null,
                                 null,
                               	 null,
                                 null,
                               	 null,
                               	 null,
                                 null,
                               	 null,
                                 null,
                               	 null,
                                 null,
                               	 null,
                                 null);
EXCEPTION
 WHEN OTHERS THEN
   null;
END insert_rfq_vendors;

END po_copydoc_s6;


/
