--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV7" AUTHID CURRENT_USER AS
/* $Header: POXPOS7S.pls 115.2 2002/11/26 19:42:51 sbull ship $*/

/*===========================================================================
  FUNCTION NAME:	get_dest_type_dist

  DESCRIPTION:		Checks if there is any distribution
                        that has the destination type as SHOP FLOOR
                        or INVENTORY for a given line_location_id.

  PARAMETERS:		See Below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SIYER		6/15	Created

===========================================================================*/
function get_dest_type_dist(X_po_header_id IN number,
                            X_po_line_id   IN number,
                            X_line_location_id  IN number)
         return boolean;

/*===========================================================================
  PROCEDURE NAME:	get_original_date

  DESCRIPTION:		Gets the Original Commitment Date that was
                        provided on the shipment. It is the promised date
                        from the archive table.

  PARAMETERS:		See Below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SIYER		6/15	Created

===========================================================================*/

 procedure get_original_date(X_line_location_id IN number,
                             X_Promised_Date    IN OUT NOCOPY DATE);

/*===========================================================================
  PROCEDURE NAME:	get_dist_num

  DESCRIPTION:		Gets the total number of distributions

  PARAMETERS:		See Below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SIYER		6/15	Created

===========================================================================*/
procedure get_dist_num(X_line_location_id  IN number,
                       X_dist_num IN OUT NOCOPY number,
                       X_code_combination_id IN OUT NOCOPY number);


 /*===========================================================================
  PROCEDURE NAME:	check_available_quantity

  DESCRIPTION:		Checks if there is qty available to be released
                        for a line/shipment combination.

  PARAMETERS:		See Below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SIYER		6/30	Created

===========================================================================*/
procedure check_available_quantity(X_source_shipment_id IN NUMBER,
                                   X_orig_quantity      IN NUMBER,
                                   X_quantity           IN NUMBER );

END PO_SHIPMENTS_SV7;

 

/
