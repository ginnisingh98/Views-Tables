--------------------------------------------------------
--  DDL for Package Body PO_RFQ_VENDORS_PKG_S4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RFQ_VENDORS_PKG_S4" as
/* $Header: POXPIR5B.pls 115.0 99/07/17 01:50:10 porting ship $ */
/*========================================================================
** PROCEDURE NAME : check_unique_supplier_site
** DESCRIPTION    :
**
**
**
**
** ======================================================================*/

PROCEDURE check_unique_supplier_site
			(X_rowid		VARCHAR2,
			 X_vendor_id		NUMBER,
                         X_vendor_site_id	NUMBER,
			 X_po_header_id		NUMBER) IS

  X_progress VARCHAR2(3) := NULL;
  dummy	   NUMBER;

 BEGIN

  X_progress := '010';

  SELECT  1
  INTO    dummy
  FROM    sys.DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_rfq_vendors
		     WHERE  po_header_id   = X_po_header_id
                     AND    vendor_id      = X_vendor_id
		     AND    vendor_site_id = X_vendor_site_id
		     AND    ((X_rowid is null) or
                             (X_rowid != rowid)));

  X_progress := '020';

 exception

  when no_data_found then
      po_message_s.app_error('PO_RFQ_VENDOR_ALREADY_EXISTS');
      raise;

  when others then
--      po_message_s.sql_error('check_unique',X_progress,sqlcode);
      po_message_s.app_error('PO_RFQ_VENDOR_ALREADY_EXISTS');
      raise;

 end check_unique_supplier_site;

END PO_RFQ_VENDORS_PKG_S4;

/
