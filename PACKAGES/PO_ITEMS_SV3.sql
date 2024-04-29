--------------------------------------------------------
--  DDL for Package PO_ITEMS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ITEMS_SV3" AUTHID CURRENT_USER as
/* $Header: POXCOI3S.pls 115.2 2002/11/23 03:31:15 sbull ship $ */

/*===========================================================================
  PROCEDURE NAME:	get_taxable_flag

  DESCRIPTION:		Obtain the item taxable flag based on the following
                        priority:

                        1. User_preference
                        2. Ship_to organization
                        3. Item organization
                        4. Purchasing option


  PARAMETERS:

  DESIGN REFERENCES:	x_item_id   			IN  NUMBER,
		        x_item_org_id			IN  NUMBER,
                        x_ship_to_org_id	  	IN  NUMBER,
                        x_user_pref_taxable_flag        IN  VARCHAR2,
                        x_item_org_taxable_flag     	IN  VARCHAR2,
                        x_po_default_taxable_flag	IN  VARCHAR2,
                        x_return_taxable_flag           OUT VARCHAR2

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Wlau 		09/26	Created
===========================================================================*/

PROCEDURE get_taxable_flag(x_item_id   			IN     NUMBER,
		           x_item_org_id		IN     NUMBER,
                           x_ship_to_org_id	  	IN     NUMBER,
                           x_user_pref_taxable_flag     IN     VARCHAR2,
                           x_ship_to_org_taxable_flag   IN OUT NOCOPY VARCHAR2,
                           x_item_org_taxable_flag     	IN OUT NOCOPY VARCHAR2,
                           x_po_default_taxable_flag	IN     VARCHAR2,
                           x_return_taxable_flag        IN OUT NOCOPY VARCHAR2);

END PO_ITEMS_SV3;

 

/
