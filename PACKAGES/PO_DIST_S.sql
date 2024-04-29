--------------------------------------------------------
--  DDL for Package PO_DIST_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DIST_S" AUTHID CURRENT_USER as
/* $Header: POXPOPDS.pls 120.1.12000000.2 2007/10/17 11:55:13 ppadilam ship $ */
/*===========================================================================
  PACKAGE NAME:		PO_DIST_S
  DESCRIPTION:		Contains the server side Distribution APIS
  CLIENT/SERVER:	Server
  LIBRARY NAME:
  OWNER:		KPOWELL
  PROCEDURE NAMES:	get_total_dist_qty()
			val_distribution_exists()
===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	get_total_dist_qty()
  DESCRIPTION:		Gets the remaining distribution quantity so
			it can be defaulted on to the distribution.
  PARAMETERS:		X_po_line_location_id	IN	NUMBER
			X_total_quantity	IN OUT NOCOPY NUMBER
  DESIGN REFERENCES:
  ALGORITHM:		Get the total quantity for all distributions
			against the shipment.
  NOTES:
  OPEN ISSUES:
  CLOSED ISSUES:
  CHANGE HISTORY:	KPOWELL		4/20	Created
===========================================================================*/
  PROCEDURE test_get_total_dist_qty
		      (X_po_line_location_id	IN	NUMBER);
  PROCEDURE get_total_dist_qty
		      (X_po_line_location_id	IN	NUMBER,
		       X_total_quantity		IN OUT NOCOPY  NUMBER);
/*===========================================================================
  PROCEDURE NAME:	val_distribution_exists()
  DESCRIPTION:		Validates if a distribution exists for a
			shipment
  PARAMETERS:		X_po_line_location_id	IN	NUMBER
			RETURN BOOLEAN
  DESIGN REFERENCES:
  ALGORITHM:		Validate if a distribution exists for a
			shipment
  NOTES:
  OPEN ISSUES:
  CLOSED ISSUES:
  CHANGE HISTORY:	KPOWELL		4/20	Created
===========================================================================*/
  FUNCTION val_distribution_exists
		      (X_po_line_location_id    IN      NUMBER) RETURN BOOLEAN;
  PROCEDURE test_val_distribution_exists
		      (X_po_line_location_id    IN      NUMBER);

   /* passed two extra parameters into this function
       Distribution_Num         - bug 1046786
       Destination_Subinventory - bug 1001768 */

  FUNCTION val_approval_status
		      (X_distribution_id          IN NUMBER,
                       X_distribution_num         IN NUMBER,
		       X_deliver_to_person_id     IN NUMBER,
		       X_quantity_ordered         IN NUMBER,
		       X_amount_ordered           IN NUMBER, -- Bug 5409088
		       X_rate			  IN NUMBER,
		       X_rate_date                IN DATE,
		       X_gl_encumbered_date       IN DATE,
		       X_charge_account_id        IN NUMBER,
                       X_project_id IN NUMBER,      -- Bug # 6408034
         --< Shared Proc FPJ Start >
         p_dest_charge_account_id   IN NUMBER,
         --< Shared Proc FPJ End >

		       X_recovery_rate		          IN NUMBER,
         X_destination_subinventory IN VARCHAR2 ) RETURN NUMBER;

END PO_DIST_S;

 

/
