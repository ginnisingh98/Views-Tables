--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV4" AUTHID CURRENT_USER AS
/* $Header: POXPOS4S.pls 120.1 2005/08/17 02:04:09 arudas noship $*/

/*===========================================================================
  PROCEDURE NAME:	delete_all_shipments

  DESCRIPTION:		Deletes all the shipments associated with
			a particular entity level.

  PARAMETERS:		X_delete_id            IN     NUMBER,
		        X_entity_level         IN     VARCHAR2

  DESIGN REFERENCES:


  ALGORITHM:		If this is a line, delete all shipments that
			  are associated with the Line and
			  are of type PLANNED, STANDARD, PRICE BREAK
		        If this is a header, delete all shipments
			  that are associated with the Header and
			  are of type PLANNED, STANDARD, PRICE BREAK
			If this is a release, delete all shipments
		          that are associated with the release header
			  and are of type SCHEDULED, BLANKET.

			For Lines you should pass:
				entity_level = LINE
			For Headers you should pass:
				entity_level = HEADER
			For Releases you should pass:
				entity_level = RELEASE
  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/2	Created

===========================================================================*/
  PROCEDURE delete_all_shipments
		      (X_delete_id        IN     NUMBER,
		       X_entity_level     IN     VARCHAR2,
		       X_type_lookup_code IN	 VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	delete_shipments

  DESCRIPTION:		Deletes the current shipment and calls the
			routine to delete all of it's children.

  PARAMETERS:		X_line_location_id     IN     NUMBER,
		        X_row_id               IN     VARCHAR2,
                        X_doc_header_id    IN NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/3	Created
                        SIYER           6/6     Added parameter X_doc_header_id

===========================================================================*/
  PROCEDURE delete_shipment
		      (X_line_location_id        IN     NUMBER,
		       X_row_id                  IN     VARCHAR2,
                       X_doc_header_id           IN     NUMBER,
                       X_shipment_type           IN     VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	delete_children

  DESCRIPTION:		Deletes all of the children associated with
			a purchase order shipment including:
				Requisition Line Link
				Purchase Order Distributions.

  PARAMETERS:		X_line_location_id     IN     NUMBER
                        X_doc_header_id        IN     NUMBER
                        X_shipment_type        IN     VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:		Need to fill in the calls to the routines
			in the other packages.  DEBUG.
			(5/3 - KP)

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/3	Created
                        SIYER           6/6     Added parameter X_doc_header_id

===========================================================================*/
  PROCEDURE delete_children
		      (X_line_location_id IN NUMBER,
                       X_doc_header_id    IN NUMBER,
                       X_shipment_type    IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	update_shipment

  DESCRIPTION:		Cover routine to update the shipment and
			to update all of the distributions.


  PARAMETERS:		See Below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:		Need to fill in the calls to the routines
			in the other packages.  DEBUG.
			(5/3 - KP)

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/3	Created
                        SIYER                   Changed
			ECSO		2/27/97 Add Global Flex

===========================================================================*/
   PROCEDURE update_shipment
		      (X_Rowid                          VARCHAR2,
                       X_Line_Location_Id               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Quantity                       NUMBER,
                       X_Quantity_Received              NUMBER,
                       X_Quantity_Accepted              NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Billed                NUMBER,
                       X_Quantity_Cancelled             NUMBER,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Need_By_Date                   DATE,
                       X_Promised_Date                  DATE,
                       X_Last_Accept_Date               DATE,
                       X_Price_Override                 NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Encumbered_Date                DATE,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
		       X_Tax_User_Override_Flag		VARCHAR2,
		       X_Calculate_Tax_Flag		VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       X_From_Line_Location_Id          NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Lead_Time                      NUMBER,
                       X_Lead_Time_Unit                 VARCHAR2,
                       X_Price_Discount                 NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Approved_Flag         IN OUT NOCOPY   VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Closed_Flag                    VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Inspection_Required_Flag       VARCHAR2,
                       X_Receipt_Required_Flag          VARCHAR2,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Qty_Rcv_Exception_Code         VARCHAR2,
                       X_Enforce_Ship_To_Location       VARCHAR2,
                       X_Allow_Substitute_Receipts      VARCHAR2,
                       X_Days_Early_Receipt_Allowed     NUMBER,
                       X_Days_Late_Receipt_Allowed      NUMBER,
                       X_Receipt_Days_Exception_Code    VARCHAR2,
                       X_Invoice_Close_Tolerance        NUMBER,
                       X_Receive_Close_Tolerance        NUMBER,
                       X_Ship_To_Organization_Id        NUMBER,
                       X_Shipment_Num                   NUMBER,
                       X_Source_Shipment_Id             NUMBER,
                       X_Shipment_Type                  VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Receiving_Routing_Id           NUMBER,
                       X_Accrue_On_Receipt_Flag         VARCHAR2,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Closed_By                      NUMBER,
                       X_need_to_approve         IN OUT NOCOPY NUMBER,
                       X_increment_revision             BOOLEAN,
                       X_new_rev_num                    NUMBER,
                       X_po_rel_Rowid                   VARCHAR2,
		       X_dist_window_open               VARCHAR2,
                       X_Global_Attribute_Category          VARCHAR2,
                       X_Global_Attribute1                  VARCHAR2,
                       X_Global_Attribute2                  VARCHAR2,
                       X_Global_Attribute3                  VARCHAR2,
                       X_Global_Attribute4                  VARCHAR2,
                       X_Global_Attribute5                  VARCHAR2,
                       X_Global_Attribute6                  VARCHAR2,
                       X_Global_Attribute7                  VARCHAR2,
                       X_Global_Attribute8                  VARCHAR2,
                       X_Global_Attribute9                  VARCHAR2,
                       X_Global_Attribute10                 VARCHAR2,
                       X_Global_Attribute11                 VARCHAR2,
                       X_Global_Attribute12                 VARCHAR2,
                       X_Global_Attribute13                 VARCHAR2,
                       X_Global_Attribute14                 VARCHAR2,
                       X_Global_Attribute15                 VARCHAR2,
                       X_Global_Attribute16                 VARCHAR2,
                       X_Global_Attribute17                 VARCHAR2,
                       X_Global_Attribute18                 VARCHAR2,
                       X_Global_Attribute19                 VARCHAR2,
                       X_Global_Attribute20                 VARCHAR2,
		       X_Country_of_Origin_Code		    VARCHAR2,
		       X_Invoice_Match_Option		    VARCHAR2, --bgu, Dec. 7, 98
		       --togeorge 10/03/2000
		       --added note to receiver
		       X_note_to_receiver		    VARCHAR2 default null,
-- Mahesh Chandak(GML) Add 7 process related fields.
-- start of Bug# 1548597
                       X_Secondary_Unit_Of_Measure        VARCHAR2 default null,
                       X_Secondary_Quantity               NUMBER default null ,
                       X_Preferred_Grade                  VARCHAR2 default null,
                       X_Secondary_Quantity_Received      NUMBER default null,
                       X_Secondary_Quantity_Accepted      NUMBER default null,
                       X_Secondary_Quantity_Rejected      NUMBER default null,
                       X_Secondary_Quantity_Cancelled     NUMBER default null,
-- end of Bug# 1548597
                       X_Consigned_Flag                   VARCHAR2 default null,  /* CONSIGNED FPI */
                       X_amount                           NUMBER default null,  -- <SERVICES FPJ>
                       p_transaction_flow_header_id       NUMBER default null, --< Shared Proc FPJ >
                       p_manual_price_change_flag         VARCHAR2 default null  --< Manual Price Override FPJ >
		       );
--<HTML Agreements R12 Start>
PROCEDURE validate_delete_line_loc( p_line_loc_id     IN NUMBER
                                   ,p_po_line_id      IN NUMBER
                                   ,p_doc_type        IN VARCHAR2
                                   ,p_style_disp_name IN VARCHAR2
                                   ,x_message_text    OUT NOCOPY VARCHAR2);

PROCEDURE process_delete_line_loc(p_line_loc_id     IN NUMBER
                                 ,p_line_loc_row_id IN ROWID
                                 ,p_po_header_id    IN NUMBER
                                 ,p_po_line_id      IN NUMBER
                                 ,p_doc_subtype     IN VARCHAR2);
--<HTML Agreements R12 End>
END PO_SHIPMENTS_SV4;

 

/