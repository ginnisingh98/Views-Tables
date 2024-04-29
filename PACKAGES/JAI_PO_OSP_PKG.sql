--------------------------------------------------------
--  DDL for Package JAI_PO_OSP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PO_OSP_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_po_osp.pls 120.2 2007/05/16 06:17:33 csahoo ship $ */

  PROCEDURE ja_in_57F4_process_header
  (p_po_header_id    po_headers_all.po_header_id%type ,
   p_po_release_id   po_releases_all.po_release_id%type,
   p_vendor_id       po_vendors.vendor_id%type ,
   p_vendor_site_id  po_vendor_sites_all.vendor_site_id%type,
   p_called_from     varchar2
   );

  PROCEDURE ja_in_57f4_lines_insert
  (p_po_header_id    po_headers_all.po_header_id%type ,
   p_po_line_id      po_lines_all.po_line_id%type ,
   p_po_release_id   po_releases_all.po_release_id%type,
   p_vendor_id       po_vendors.vendor_id%type ,
   p_vendor_site_id  po_vendor_sites_all.vendor_site_id%type,
   p_called_from     varchar2
  );

  /* Start - Added by csahoo bug#5699863*/
	procedure cancel_osp
	(p_form_id         JAI_PO_OSP_HDRS.form_id%type
	);
	/* End - Added by csahoo for bug#5699863*/

  PROCEDURE create_rcv_57f4(
    p_transaction_id                NUMBER,
    p_process_status    OUT NOCOPY  VARCHAR2,
    p_process_message   OUT NOCOPY  VARCHAR2
  );

  PROCEDURE update_57f4_on_receiving
  (
    p_shipment_header_id	NUMBER,
    p_shipment_line_id		NUMBER,
    p_to_organization_id	NUMBER,
    p_ship_to_location_id	NUMBER,
    p_item_id				NUMBER,
    p_tran_type						RCV_TRANSACTIONS.transaction_type%TYPE,
    p_rcv_tran_qty					RCV_TRANSACTIONS.quantity%TYPE,
    p_new_primary_unit_of_measure	RCV_SHIPMENT_LINES.primary_unit_of_measure%TYPE,
    p_old_primary_unit_of_measure	RCV_SHIPMENT_LINES.primary_unit_of_measure%TYPE,
    p_unit_of_measure				RCV_SHIPMENT_LINES.unit_of_measure%TYPE,
    p_po_header_id			NUMBER,
    p_po_release_id			NUMBER,
    p_po_line_id			NUMBER,
    p_po_line_location_id		NUMBER,
    p_last_updated_by		NUMBER,
    p_last_update_login		NUMBER,
    p_creation_date			DATE
  );
END jai_po_osp_pkg;

/
