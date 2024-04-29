--------------------------------------------------------
--  DDL for Package PO_LINE_TYPES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_TYPES_SV" AUTHID CURRENT_USER as
/* $Header: POXSTLTS.pls 115.7 2003/10/03 22:14:31 jmcfadde ship $ */
/*===========================================================================
  PACKAGE NAME:		PO_LINE_TYPES_SV

  DESCRIPTION:		This package contains the Line Type server side
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  PROCEDURE NAMES:	test_get_line_type_def()
			get_line_type_def()
			get_line_type()
			val_line_type()
			is_outside_processing
===========================================================================*/


/*===========================================================================
  FUNCTION NAME:	val_line_type()

  DESCRIPTION:		This function checks whether a given Line Type is
			still active.


  PARAMETERS:		X_line_type_id IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Changed to 	14-AUG-1995	LBROADBE
			Function
===========================================================================*/
FUNCTION val_line_type(X_line_type_id IN NUMBER) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	get_line_type_def()

  DESCRIPTION:		Gets the following  line type dependant defaults:
	                  o order_type_lookup_code (Amount, Quantity)
	                  o category_id
	                  o unit_of_measure
	                  o unit_price
			  o outside operation flag
	                  o receiving_flag			(PO)
                          o receive close tolerance             (PO)

  PARAMETERS:		X_Line_Type_Id			IN	NUMBER
			X_Order_Type_Lookup_Code	IN OUT	VARCHAR2
			X_Category_Id			IN OUT	NUMBER
			X_Unit_Meas_Lookup_Code		IN OUT	VARCHAR2
			X_Unit_Price			IN OUT  NUMBER
			X_Outside_Operations_Flag	IN OUT  VARCHAR2
			X_Receiving_Flag		IN OUT  VARCHAR2
   -- Bug: 1157232 Added receive close tolerance to the list of parameters
			X_Receive_close_tolerance	IN OUT  NUMBER

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXRQERQ.doc
			../POXSCERQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		03-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE test_get_line_type_def
		(X_Line_Type_Id		IN	NUMBER);

PROCEDURE get_line_type_def                                   -- <SERVICES FPJ>
(    p_line_type_id              IN           NUMBER
,    x_order_type_lookup_code    OUT NOCOPY   VARCHAR2
,    x_purchase_basis            OUT NOCOPY   VARCHAR2
,    x_matching_basis            OUT NOCOPY   VARCHAR2
,    x_category_id               OUT NOCOPY   NUMBER
,    x_unit_meas_lookup_code     OUT NOCOPY   VARCHAR2
,    x_unit_price                OUT NOCOPY   NUMBER
,    x_outside_operations_flag   OUT NOCOPY   VARCHAR2
,    x_receiving_flag            OUT NOCOPY   VARCHAR2
,    x_receive_close_tolerance   OUT NOCOPY   NUMBER
);

PROCEDURE get_line_type_def                                   -- <SERVICES FPJ>
(    p_line_type_id              IN           NUMBER
,    x_order_type_lookup_code    OUT NOCOPY   VARCHAR2
,    x_purchase_basis            OUT NOCOPY   VARCHAR2
,    x_category_id               OUT NOCOPY   NUMBER
,    x_unit_meas_lookup_code     OUT NOCOPY   VARCHAR2
,    x_unit_price                OUT NOCOPY   NUMBER
,    x_outside_operations_flag   OUT NOCOPY   VARCHAR2
,    x_receiving_flag            OUT NOCOPY   VARCHAR2
,    x_receive_close_tolerance   OUT NOCOPY   NUMBER
);

PROCEDURE get_line_type_def                                   -- <SERVICES FPJ>
(    p_line_type_id              IN           NUMBER
,    x_order_type_lookup_code    OUT NOCOPY   VARCHAR2
,    x_purchase_basis            OUT NOCOPY   VARCHAR2
,    x_matching_basis            OUT NOCOPY   VARCHAR2
,    x_outside_operation_flag    OUT NOCOPY   VARCHAR2
);

PROCEDURE get_line_type_def
		(X_Line_Type_Id		IN 	NUMBER,
		 X_Order_Type_Lookup_Code	IN OUT	NOCOPY VARCHAR2,
		 X_Category_Id			IN OUT	NOCOPY NUMBER,
		 X_Unit_Meas_Lookup_Code	IN OUT	NOCOPY VARCHAR2,
		 X_Unit_Price			IN OUT NOCOPY  NUMBER,
		 X_Outside_Operations_Flag	IN OUT NOCOPY  VARCHAR2,
		 X_Receiving_Flag		IN OUT NOCOPY  VARCHAR2 ,
                 X_Receive_close_tolerance	IN OUT NOCOPY  NUMBER);


/*===========================================================================
  FUNCTION NAME:	get_line_type

  DESCRIPTION:		This function returns the line type for
			a specific line type id.

  PARAMETERS:		X_Line_Type_Id			IN	NUMBER


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		18-MAY-95	RMULPURY
===========================================================================*/

FUNCTION get_line_type (x_line_type_id IN NUMBER)
	 return varchar2;



FUNCTION outside_processing_items_exist ( p_po_header_id NUMBER )   -- <GA FPI>
  RETURN BOOLEAN;

FUNCTION is_outside_processing_item ( p_item_id     NUMBER          -- <GA FPI>
                                    , p_org_id      NUMBER )
  RETURN BOOLEAN;

FUNCTION is_outside_processing ( p_line_type_id NUMBER )            -- <GA FPI>
  RETURN BOOLEAN;

FUNCTION transactions_exist ( p_line_type_id NUMBER )         -- <SERVICES FPJ>
  RETURN VARCHAR2;


END PO_LINE_TYPES_SV;

 

/
