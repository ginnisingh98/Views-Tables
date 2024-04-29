--------------------------------------------------------
--  DDL for Package PO_LOCATIONS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LOCATIONS_S" AUTHID CURRENT_USER AS
/* $Header: POXCOL2S.pls 115.4 2002/12/27 20:55:30 anhuang ship $*/

/* create client package */
/*
PACKAGE PO_LOCATIONS_S IS
*/

/*===========================================================================
  PACKAGE NAME:		PO_LOCATIONS_S

  DESCRIPTION:

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:		Thomas Cai

  PROCEDURE/FUNCTION NAMES:
			val_location()
                        get_loc_attributes();
                        get_tax_name();
			val_if_inventory_destination()
                        val_ship_to_site_in_org()
                        val_receipt_site_in_org ()
			get_ship_to_location()
                        derive_location_info()
                        validate_location_info()
                        validate_tax_info()
                        po_predel_validation()

  HISTORY:
        3/22/95 tc all algorithms are added.
        5/4/95  si added get_loc_attributes procedure.
        5/4/95  si added the show errors part of the spec.
        10/25/96 rb added derive_location_info and validate_location_info
        3/3/99  ayeung added po_predel_validation()
===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	get_ship_to_location()

  DESCRIPTION:		This procedure returns a ship-to location ID for
			a given deliver-to location ID.  It also verifies
			whether this ship-to is still active, and returns
			TRUE or FALSE accordingly.


  PARAMETERS:		X_deliver_to_loc_id 	IN 	NUMBER,
			X_ship_to_loc_id 	IN OUT	NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	10-JUL-1995	LBROADBE
===========================================================================*/
FUNCTION get_ship_to_location(X_deliver_to_loc_id 	IN 	NUMBER,
			      X_ship_to_loc_id 	        IN OUT	NOCOPY NUMBER) return BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_location()

  DESCRIPTION:
	Validate necessary fields are filled in, based on destination type.
		Expense and Shopfloor
		- Require deliver-to location
		  message RCV_ALL_MISSING_DELIVER_TO
		Receiving
		- Require transfer to another receiving location
		  message RCV_ALL_MISSING_RECEIVE_TO

	Return 0 for failure, 1 for success.

  PARAMETERS:
        x_location_id           IN NUMBER,
        x_destination_type      IN VARCHAR2,
        x_organization_id       IN NUMBER,


  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:
	if location_id is null then
	   case x_destination_type
	      :if = receiving then
	         return fail1
	      :if = expense or shopfloor or inventory then
	         return fail2
           end case

        return ok.

  NOTES:

  OPEN ISSUES:
        1. When Oracle Inventory creates a receipt header for an in-transit
        shipment, get destincation type from receiving shipment line which
        is pre-populated. Check with Oracle Inventory.

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_location
(
        x_location_id           IN NUMBER,
        x_destination_type      IN VARCHAR2,
        x_organization_id       IN NUMBER
)
RETURN	NUMBER;

/*===========================================================================
 PROCEDURE NAME:	get_location_attributes()

  DESCRIPTION:  Given a location id, get the location_code and
                inventory_org_id.


  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         05/95

===============================================================================*/

 procedure get_loc_attributes ( X_temp_loc_id IN number, X_loc_dsp IN OUT NOCOPY varchar2,
                                        X_org_id IN OUT NOCOPY  number);

/*===========================================================================
 PROCEDURE NAME:	get_tax_name()

  DESCRIPTION:  Given a location id, get the tax_name associated with it.


  PARAMETERS:

  DESIGN REFERENCES:	POXPOREL.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         06/95

===============================================================================*/


 procedure get_tax_name ( X_location_id IN NUMBER,
                          X_org_id      IN NUMBER,
                          X_tax_name    IN OUT NOCOPY VARCHAR2);



/*===========================================================================
 PROCEDURE NAME:	get_loc_org ()

  DESCRIPTION:  	Given a location and the set of books, this
	  		procedure provides the organization.

  PARAMETERS:		x_location_id	IN 	NUMBER
			x_sob_id	IN 	NUMBER
			x_org_id	IN OUT	NUMBER
			x_org_name	IN OUT  VARCHAR2

  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: 	Ramana Y. Mulpury        06/95

===============================================================================*/


 procedure get_loc_org  ( X_location_id IN NUMBER,
			  X_sob_id 	IN NUMBER,
                          X_org_id      IN OUT NOCOPY NUMBER,
                          X_org_code    IN OUT NOCOPY VARCHAR2,
                          X_org_name    IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	val_if_inventory_destination

  DESCRIPTION:		Check if there are any inventory final destinations
                        either on the po or in-transit shipment.  If there
                        are then you need to get the latest implemented
                        item rev if it is under item rev control

  PARAMETERS:		X_item_id			IN	NUMBER,
                        X_organization_id               IN      NUMBER
                        X_item_revision			IN OUT	VARCHAR2,
			X_rev_exists		        OUT	BOOLEAN

  DESIGN REFERENCES:	../RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		27-JUN-95         GKELLNER
===========================================================================*/

FUNCTION val_if_inventory_destination (
X_line_location_id  IN NUMBER,
X_shipment_line_id  IN NUMBER)
RETURN BOOLEAN;




/*===========================================================================
 PROCEDURE NAME:	get_location_code()

  DESCRIPTION:  	This procedure provides the location_code
			based on the location id.


  PARAMETERS:		x_location_id	IN 	NUMBER
			x_location_code IN OUT	VARCHAR2

  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: 	Ramana Y. Mulpury	06/23

===============================================================================*/

 procedure get_location_code ( x_location_id 	IN	 NUMBER,
                               x_location_code 	IN OUT	NOCOPY  VARCHAR2);


FUNCTION get_location_code                                      -- <2699404>
(    p_location_id        IN       HR_LOCATIONS.location_id%TYPE
) RETURN HR_LOCATIONS.location_code%TYPE;


/*===========================================================================
 PROCEDURE NAME:	val_ship_to_site_in_org()

  DESCRIPTION:  Validates if the given location is an active ship_to_site
                in the given org.
                This procedure is currently being called during autocreate of
                a PO shipment.


  PARAMETERS:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         07/95

===============================================================================*/


 FUNCTION val_ship_to_site_in_org
          ( x_location_id           IN NUMBER,
            x_organization_id       IN NUMBER
          )
          RETURN BOOLEAN;


/*===========================================================================
 PROCEDURE NAME:	val_receipt_site_in_org

  DESCRIPTION:  Validates if the given location is an active receiving site
                in the given org.
                This procedure is currently being called for receiving
                validation


  PARAMETERS:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY: Sudha Iyer         07/95

===============================================================================*/


 FUNCTION val_receipt_site_in_org
          ( x_location_id           IN NUMBER,
            x_organization_id       IN NUMBER
          )
          RETURN BOOLEAN;



/*===========================================================================
 PROCEDURE NAME:    derive_location_info()

  DESCRIPTION:      Derives information about the missing components of
                    location record based on the components that have values.


  PARAMETERS:       p_loc_record IN OUT RCV_SHIPMENT_HEADER_SV.LocRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:            uses dbms_sql to create the WHERE clause based on the
                    components of p_loc_record that have values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  10/25/96        Raj Bhakta

===============================================================================*/

PROCEDURE derive_location_info(p_loc_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Location_id_record_type);


/*===========================================================================
 PROCEDURE NAME:    validate_location_info()

  DESCRIPTION:      Validate the components of location record based on the
                    components that have values. Returns error status and
                    error messages based on diff tests.


  PARAMETERS:       p_loc_record IN OUT RCV_SHIPMENT_HEADER_SV.LocRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:            uses dbms_sql to create the WHERE clause based on the
                    components of p_loc_record that have values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  10/25/96        Raj Bhakta

===============================================================================*/

PROCEDURE validate_location_info(p_loc_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Location_id_record_type);

/*===========================================================================
 PROCEDURE NAME:    validate_tax_info()

  DESCRIPTION:      Validate the components of tax record based on the
                    components that have values. Returns error status and
                    error messages based on diff tests.


  PARAMETERS:       p_tax_rec IN OUT RCV_SHIPMENT_HEADER_SV.TaxRecType

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  10/29/96        Raj Bhakta  Created

===============================================================================*/

PROCEDURE validate_tax_info(p_tax_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.TaxRecType);


/*===========================================================================
 PROCEDURE NAME:    po_predel_validation()

  DESCRIPTION:      This procedure is used primarily by the HR Location form
                    (PERWSLOC) to validate any locations that can be deleted
                    from the database.  It checks for any location that is
                    currently in use in the PO, RCV, CHV base tables


  PARAMETERS:       p_location_id IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:  03/03/99        Andrew Yeung  Created

=============================================================================*/

PROCEDURE PO_PREDEL_VALIDATION(p_location_id IN NUMBER);


END PO_LOCATIONS_S;


 

/
