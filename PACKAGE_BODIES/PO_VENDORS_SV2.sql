--------------------------------------------------------
--  DDL for Package Body PO_VENDORS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORS_SV2" as
/* $Header: POXVDV2B.pls 115.0 99/07/17 02:05:27 porting ship $*/

/*===========================================================================
  Bug #508009
  FUNCTION NAME : get_vendor_name_func()

  DESCRIPTION    :  For a given Vendor Id, this returns  the Vendor Name.

  PARAMETERS:   NUMBER - Vendor ID

  RETURN VALUE: VARCHAR2 - Vendor Name

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

========================================================================*/

    FUNCTION get_vendor_name_func(X_vendor_id  IN NUMBER) RETURN VARCHAR2
    IS
    BEGIN
       return(po_vendors_sv.get_vendor_name_func(X_vendor_id));
    END;

END PO_VENDORS_SV2;

/
