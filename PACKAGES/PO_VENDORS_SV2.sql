--------------------------------------------------------
--  DDL for Package PO_VENDORS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORS_SV2" AUTHID CURRENT_USER as
/* $Header: POXVDV2S.pls 115.1 99/10/11 17:18:06 porting shi $*/

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

    FUNCTION get_vendor_name_func(X_vendor_id  IN NUMBER) RETURN VARCHAR2;

--    PRAGMA RESTRICT_REFERENCES(get_vendor_name_func, WNDS);


END PO_VENDORS_SV2;

 

/
