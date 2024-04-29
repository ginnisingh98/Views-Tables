--------------------------------------------------------
--  DDL for Package PO_CUSTOMERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CUSTOMERS_SV" AUTHID CURRENT_USER as
/* $Header: POXRQCUS.pls 120.1 2006/02/14 12:24:59 dreddy noship $ */
/*===========================================================================
  PACKAGE NAME:		po_customers_sv

  DESCRIPTION:		Contains all server side procedures that
			access po_location_associations entity.

  CLIENT/SERVER:	Server

  OWNER:		RMULPURTY

  PROCEDURE NAMES:	get_cust_details()
			val_cust_details()
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_cust_details

  DESCRIPTION:		Obtain the customer details associated with
			a destination location
                        Bug 5028505: Added source org parameter

  PARAMETERS:		x_deliver_to_location_id	IN 	NUMBER
			x_customer_id			IN OUT  NUMBER
			x_address_id			IN OUT  NUMBER
			x_site_use_id			IN OUT  NUMBER
                        x_source_org_id                 IN OUT  NUMBER

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_cust_details(x_deliver_to_location_id	IN     NUMBER,
			   x_customer_id		IN OUT NOCOPY NUMBER,
			   x_address_id			IN OUT NOCOPY NUMBER,
			   x_site_use_id		IN OUT NOCOPY NUMBER,
                           x_source_org_id              IN NUMBER DEFAULT NULL);


END po_customers_sv;
 

/
