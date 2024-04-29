--------------------------------------------------------
--  DDL for Package PO_APPROVED_SUPPLIER_LIST_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVED_SUPPLIER_LIST_S1" AUTHID CURRENT_USER as
/*$Header: POXSCASS.pls 115.1 2002/11/27 00:01:51 sbull noship $*/
/*===========================================================================
  PACKAGE NAME:  PO_APPROVED_SUPPLIER_LIST_S1
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to select the ASL information.

  CLIENT/SERVER: Server

  OWNER:         Shawna Liu

  FUNCTION/
		 get_asl_info()

============================================================================*/

/*===========================================================================
  PROCEDURE NAME      :  get_asl_info

  DESCRIPTION         :  GET_ASL_INFO is a procedure that selects the ASL
                         information for the Organization, Supplier, Supplier
                         Site and Item combination from PO_APPROVED_SUPPLIER_LIST
                         and pass the enable authorizations flag to the calling
                         procedure.

  PARAMETERS          :  x_organization_id                 IN      NUMBER,
			 x_vendor_id                       IN      NUMBER,
			 x_vendor_site_id                  IN      NUMBER,
			 x_item_id                         IN      NUMBER,
                         x_asl_id                          OUT     NUMBER,
                         x_enable_authorizations_flag      OUT     VARCHAR2

  DESIGN REFERENCES   :

  ALGORITHM           :  Select ASL_ID, enable_authorizations_flag based on
                         the organization_id, vendor_id, vendor_site_id and
                         return ASL_ID and enable_authorization_flag.

  NOTES               :  1. An explicit cursor is used even though the select
                         should only return one row, in compliance with
                         the coding standard.
                         2. For now, po_message.show is used to handle errors.

  OPEN ISSUES         :

  CLOSED ISSUES       :  1. Approval_status should be 'APPROVED'.
                         2. Need to handle NO_DATA_FOUND, but not TOO_MANY_ROWS
                            (confirmed with Sri).

  CHANGE HISTORY      :  Created            29-MAR-1995     SXLIU
==========================================================================*/
PROCEDURE get_asl_info(x_organization_id                 in      NUMBER,
		       x_vendor_id                       in      NUMBER,
		       x_vendor_site_id                  in      NUMBER,
		       x_item_id                         in      NUMBER,
                       x_asl_id                          out NOCOPY     NUMBER,
                       x_enable_authorizations_flag      out NOCOPY     VARCHAR2);

END PO_APPROVED_SUPPLIER_LIST_S1;

 

/
