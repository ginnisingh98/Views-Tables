--------------------------------------------------------
--  DDL for Package PO_UOM_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UOM_S" AUTHID CURRENT_USER as
/* $Header: RCVTXU1S.pls 120.1.12010000.2 2012/06/20 02:59:16 liayang ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_UOM_S

  DESCRIPTION:

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:

  PROCEDURE NAMES:	uom_convert()
			val_uom_conversion()
			val_unit_of_measure()
===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	val_unit_of_measure()

  DESCRIPTION:		This function checks whether a given Unit of Measure
			is still valid.


  PARAMETERS:		X_unit_of_measure IN VARCHAR2

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Changed to	14-AUG-1995	LBROADBE
			Function
===========================================================================*/
FUNCTION  val_unit_of_measure(X_unit_of_measure IN VARCHAR2) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME: uom_convert()

  DESCRIPTION:
	This is the PO wrapper procedure to the Inventory uom procedure.
   	It calls the stored function po_uom_convert for now. It needs to be
 	changed to call the Inventory stored procedure once Inventory is done
	creating it.

  USAGE:
	po_uom_s.uom_convert(from_quantity, from_uom, item_id, to_uom,
			     to_quantity)

  PARAMETERS:
	from_quantity	IN  number   - source quantity
	from_uom	IN  varchar2 - source unit of measure
	item_id		IN  number   - item id (null for one time items)
	to_uom		IN  varchar2 - destination unit of measure
	to_quantity	OUT number   - destination quantity

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	17-MAR-95	Sanjay Kothary	Created
===========================================================================*/

PROCEDURE uom_convert(	from_quantity	in	number,
			from_uom	in	varchar2,
			item_id		in	number,
			to_uom		in	varchar2,
			to_quantity	out	NOCOPY number);

/*===========================================================================
  PROCEDURE NAME:	val_uom_conversion()

  DESCRIPTION:
	o PRO - For each match record, we check if there is a uom conversion
		defined between purchasing order and receipt. if not defined,
		the match will be rejected.
  PARAMETERS:

  DESIGN REFERENCES:	RCVRCMUR.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE val_uom_conversion;

/*===========================================================================
  PROCEDURE NAME:  po_uom_conversion()

  DESCRIPTION:
	This is the PO uom conversion procedure
   	It needs to be
 	changed to call the Inventory stored procedure once Inventory is done
	creating it.

  USAGE:
	po_uom_s.po_uom_conversion ( from_unit  varchar2, to_unit 	varchar2, item_id number, uom_rate    	out 	number )

  PARAMETERS:
	from_unit	IN  varchar2 - source unit of measure
	to_unit		IN  varchar2 - destination unit of measure
	item_id		IN  number   - item id (null for one time items)
	uom_rate	OUT number   - conversion rate between the two units

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	17-MAR-95	Sanjay Kothary	Created
===========================================================================*/

procedure po_uom_conversion ( from_unit  in varchar2,
                              to_unit    in varchar2,
                              item_id    in number,
                              uom_rate   out NOCOPY number );
/*===========================================================================
  PROCEDURE NAME:  po_uom_convert ()

  DESCRIPTION:
	This is the PO uom conversion procedure that returns a the conversion
        rate from the function
   	It needs to be
 	changed to call the Inventory stored procedure once Inventory is done
	creating it.

  USAGE:
	conv_rate := po_uom_s.po_uom_convert ( from_unit   varchar2,
                          to_unit  varchar2,
			  item_id  number );

  PARAMETERS:
	from_unit	IN  varchar2 - source unit of measure
	to_unit		IN  varchar2 - destination unit of measure
	item_id		IN  number   - item id (null for one time items)

  RETURNS:

	conversion_rate NUMBER - conversion rate between the two units

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	17-MAR-95	Sanjay Kothary	Created
===========================================================================*/
function po_uom_convert ( from_unit   in varchar2,
                          to_unit     in varchar2,
			  item_id     in number ) return number;


/*===========================================================================
  PROCEDURE NAME:  get_primary_uom()

  DESCRIPTION:
        This function returns the primary UOM based on item_id/organization
        for both pre-defined and one-time items

  USAGE:
	uom := po_uom_s.get_primary_uom ( item_id  number,   org_id   number,
current_unit_of_measure   varchar2 )

  PARAMETERS:
	item_id		IN  number   - item id (null for one time items)
        org_id          IN  number   - org id
        current_unit_of_measure IN VARCHAR2 - currently defined uom on trx.

  RETURNS:

	primary_uom - VARCHAR2 - Primary UOM for given item and org

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	17-MAR-95	Sanjay Kothary	Created
===========================================================================*/
function get_primary_uom ( item_id  in number,
                           org_id   in number,
                           current_unit_of_measure   in varchar2 )
return varchar2;

/*========================================================================

  FUNCTION  :   po_uom_convert_p()

   Created a function po_uom_convert_p which is pure function to be used in
   the where and select clauses of a SQL stmt.bug 1365577
   ******************************************************
   So, any change in the po_uom_convertion proc in rvpo02
   should be implemented in this new function.
   ******************************************************
========================================================================*/
function po_uom_convert_p ( from_unit  in  varchar2,
                            to_unit    in  varchar2,
                            item_id    in  number ) return number;


/*===========================================================================
  PROCEDURE NAME:  get_secondary_uom()

  DESCRIPTION:
        This function returns the primary UOM based on item_id/organization
        for both pre-defined and one-time items

  USAGE:
	uom := po_uom_s.get_secondary_uom(p_item_id  in number,
                             p_org_id   in number,
                             x_secondary_uom_code out varchar2,
                             x_secondary_unit_of_measure out varchar2);

  PARAMETERS:
	item_id		IN  number   - item id (null for one time items)
        org_id          IN  number   - org id
        x_secondary_uom_code OUT VARCHAR2 - items secondary uom code.
        x_secondary_unit_of_measure OUT VARCHAR2 - items secondary unit of meas

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	09-SEP-05	Preetam Bamb	Created
===========================================================================*/
procedure get_secondary_uom (p_item_id  in number,
                             p_org_id   in number,
                             x_secondary_uom_code out NOCOPY varchar2,
                             x_secondary_unit_of_measure out NOCOPY varchar2);

/*===========================================================================
  PROCEDURE NAME:  get_unit_of_measure()

  DESCRIPTION:
        This function returns the unit of measure for the passed uom code

  USAGE:
        uom := po_uom_s.get_unit_of_measure(
                             p_uom_code in varchar2,
                             x_unit_of_measure out NOCOPY varchar2);

  PARAMETERS:
        x_uom_code IN VARCHAR2 - items secondary uom code.
        x_unit_of_measure OUT VARCHAR2 - items secondary unit of meas

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
        09-SEP-05       Preetam Bamb    Created
===========================================================================*/
procedure get_unit_of_measure(
                             p_uom_code in varchar2,
                             x_unit_of_measure out NOCOPY varchar2);

/*========================================================================

  FUNCTION  :   rti_trx_qty_to_soc_qty()

   Created a function rti_trx_qty_to_soc_qty which is pure function to be used in
   the where and select clauses of rvtvq.lpc the lot specific UOM convertion for rti
   source_doc_quantity
========================================================================*/

FUNCTION rti_trx_qty_to_soc_qty(P_INTERFACE_TRANSACTION_ID IN NUMBER,
                                                  P_TO_ORG_ID                IN NUMBER,
                                                  P_ITEM_ID                  IN NUMBER,
                                                  P_FROM_QTY                 IN NUMBER,
                                                  P_FROM_UOM                 IN VARCHAR2,
                                                  P_TO_UOM                   IN VARCHAR2)  RETURN NUMBER;

END PO_UOM_S;



/
