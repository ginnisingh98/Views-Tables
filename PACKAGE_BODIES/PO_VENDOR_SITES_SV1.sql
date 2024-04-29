--------------------------------------------------------
--  DDL for Package Body PO_VENDOR_SITES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDOR_SITES_SV1" AS
/* $Header: POXPIVSB.pls 115.0 99/07/17 01:52:02 porting ship $ */

/*==============================================================

  FUNCTION NAME : derive_vendor_site_id

===============================================================*/
FUNCTION  derive_vendor_site_id(X_vendor_id        IN NUMBER,
                                X_vendor_site_code IN VARCHAR2)
return NUMBER IS

X_progress         varchar2(3)     := NULL;
X_vendor_site_id_v number          := NULL;

BEGIN

 X_progress := '010';
/*
   Get the vendor site id from po_supplier_sites_val_v based on
   the parameters supplied from the input.                     */

 SELECT		 vendor_site_id
 INTO		 X_vendor_site_id_v
 FROM		 po_supplier_sites_val_v
 WHERE		 vendor_id = X_vendor_id
 AND		 vendor_site_code = X_vendor_site_code;

RETURN X_vendor_site_id_v;

EXCEPTION

   WHEN no_data_found THEN
        RETURN NULL;
   WHEN others THEN
        po_message_s.sql_error('derive_vendor_site_id',X_progress, sqlcode);
        raise;

END derive_vendor_site_id;

END PO_VENDOR_SITES_SV1;

/
