--------------------------------------------------------
--  DDL for Package RLM_XML_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_XML_API" AUTHID CURRENT_USER AS
/* $Header: RLMXMLPS.pls 120.6 2005/08/16 13:06:34 mnandell noship $*/

k_DELIVER  CONSTANT VARCHAR2(10) := 'DELIVER';
k_RECEIPT  CONSTANT VARCHAR2(10) := 'RECEIPT';
k_SHIPMENT CONSTANT VARCHAR2(10) := 'SHIPMENT';
k_RECEIVED CONSTANT VARCHAR2(10) := 'RECEIVED';
k_SHIPPED  CONSTANT VARCHAR2(10) := 'SHIPPED';
k_DEMAND   CONSTANT VARCHAR2(10) := 'DEMAND';
k_ASOF     CONSTANT VARCHAR2(10) := 'AS_OF';
k_AHDBHND  CONSTANT VARCHAR2(12) := 'AHEAD_BEHIND';
k_FINISHED CONSTANT VARCHAR2(10) := 'FINISHED';
k_FROMTO   CONSTANT VARCHAR2(10) := 'FROM_TO';

k_ERROR    CONSTANT NUMBER       := 1;
k_SUCCESS  CONSTANT NUMBER       := 0;

k_VNULL    CONSTANT VARCHAR2(25) := 'THIS_IS_A_NULL_VALUE';
k_DNULL    CONSTANT DATE         := to_date('01/01/1930','dd/mm/yyyy');
k_NNULL    CONSTANT NUMBER       := -19999999999;

C_SDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL7;
C_DEBUG               CONSTANT   NUMBER := rlm_core_sv.C_LEVEL8;

TYPE t_Cursor_ref IS REF CURSOR;

TYPE t_ItemAttribsRec IS RECORD (
	ship_from_ext		RLM_INTERFACE_LINES.cust_ship_from_org_ext%TYPE,
	ship_to_ext   		RLM_INTERFACE_LINES.cust_ship_to_ext%TYPE,
	bill_to_ext		RLM_INTERFACE_LINES.cust_bill_to_ext%TYPE,
        cust_item_ext 		RLM_INTERFACE_LINES.customer_item_ext%TYPE,
	item_desc_ext		RLM_INTERFACE_LINES.item_description_ext%TYPE,
	cust_dock_code		RLM_INTERFACE_LINES.customer_dock_code%TYPE,
	hazrd_code_ext		RLM_INTERFACE_LINES.hazard_code_ext%TYPE,
	cust_item_rev		RLM_INTERFACE_LINES.customer_item_revision%TYPE,
	item_note_text		RLM_INTERFACE_LINES.item_note_text%TYPE,
	cust_po_num		RLM_INTERFACE_LINES.cust_po_number%TYPE,
	cust_po_linnum		RLM_INTERFACE_LINES.cust_po_line_num%TYPE,
	cust_po_relnum		RLM_INTERFACE_LINES.cust_po_release_num%TYPE,
	cust_po_date		RLM_INTERFACE_LINES.cust_po_date%TYPE,
	commodity_ext		RLM_INTERFACE_LINES.commodity_ext%TYPE,
	sup_item_ext		RLM_INTERFACE_LINES.supplier_item_ext%TYPE);


TYPE t_SchdItemAttribs IS TABLE OF t_ItemAttribsRec
  INDEX BY BINARY_INTEGER;

g_SchedItemTab	t_SchdItemAttribs;


/*==========================================================================
  PROCEDURE NAME	ValidateScheduleType

  DESCRIPTION		This procedure is used to validate the value of the
			<SCHDULETYP> element.  If this is anything other than
			DEMAND, the XML message is rejected.

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		02/22/02	Created
============================================================================*/
PROCEDURE ValidateScheduleType(x_SchedType IN VARCHAR2, x_RetCode OUT NOCOPY NUMBER);


/*==========================================================================
  PROCEDURE NAME	SetSSSILineDetails

  DESCRIPTION		This procedure is used to set the external values of
  			item_detail_type, item_detail_subtype, date_type_code, and
  			item_detail_quantity for a SSSI schedule

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		02/22/02	Created
============================================================================*/
PROCEDURE SetSSSILineDetails(x_LineType IN  VARCHAR2,
		        x_ReqdDt   IN  DATE,
		        x_RecdDt   IN  DATE,
		        x_ShipDt   IN  DATE,
                        x_ItemQty  IN  NUMBER,
		        x_RecdQty  IN  NUMBER,
		        x_ShipQty  IN  NUMBER,
			x_DateType IN  VARCHAR2,
			x_ItemUOM  IN  VARCHAR2,
			x_RecdUOM  IN  VARCHAR2,
			x_ShipUOM  IN  VARCHAR2,
		        x_StartDt  OUT NOCOPY DATE,
		        x_Qty      OUT NOCOPY NUMBER,
			x_Subtype  OUT NOCOPY VARCHAR2,
			x_DateCode OUT NOCOPY VARCHAR2,
			x_QtyUOM   OUT NOCOPY VARCHAR2,
			x_ErrCode  IN OUT NOCOPY NUMBER,
			x_ErrMsg   IN OUT NOCOPY VARCHAR2);



/*==========================================================================
  PROCEDURE NAME	SetSPSILineDetails

  DESCRIPTION		This procedure is used to set the external values of
  			item_detail_type, item_detail_subtype, date_type_code, and
  			item_detail_quantity for a SPSI schedule

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		02/22/02	Created
============================================================================*/
PROCEDURE SetSPSILineDetails(x_LineType IN  VARCHAR2,
			 x_FromDt    IN  DATE,
			 x_ToDt      IN  DATE,
		         x_RecdDt    IN  DATE,
		         x_ShipDt    IN  DATE,
                         x_ItemQty   IN  NUMBER,
		         x_RecdQty   IN  NUMBER,
		         x_ShipQty   IN  NUMBER,
			 x_DateType  IN  VARCHAR2,
			 x_ItemUOM   IN  VARCHAR2,
			 x_RecdUOM   IN  VARCHAR2,
			 x_ShipUOM   IN  VARCHAR2,
			 x_BktType   IN  VARCHAR2,
		         x_StartDt   OUT NOCOPY DATE,
			 x_EndDt     OUT NOCOPY DATE,
			 x_Subtype   OUT NOCOPY VARCHAR2,
		         x_Qty       OUT NOCOPY NUMBER,
			 x_DateCode  OUT NOCOPY VARCHAR2,
			 x_QtyUOM    OUT NOCOPY VARCHAR2,
			 x_ErrCode   IN OUT NOCOPY NUMBER,
			 x_ErrMsg    IN OUT NOCOPY VARCHAR2);



/*==========================================================================
  PROCEDURE NAME	SetScheduleItemNum

  DESCRIPTION		This procedure is used to derive the schedule_item_num
			for each line inserted.  Makes use of the following
			procedures/functions:
			(1) Procedure InitializeSchedItemTab
			(2) Function IsDuplicate
			(3) Procedure InsertItemAttribsRec
			(4) Procedure PrintSchedItemTab

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		02/22/02	Created
============================================================================*/
PROCEDURE SetScheduleItemNum(x_HeaderID IN NUMBER,
			     x_ErrCode  IN OUT NOCOPY NUMBER,
			     x_ErrMsg   IN OUT NOCOPY VARCHAR2);



/*==========================================================================
  PROCEDURE NAME	PrintSchedItemTab

  DESCRIPTION		This procedure is used only for debugging purposes
  			and prints the values stored in the g_SchedItemTab
  			table.

  DESIGN REFERENCES

  CHANGE HISTORY	rlanka		04/10/02	Created
============================================================================*/
PROCEDURE PrintSchedItemTab;


/*==========================================================================
  PROCEDURE NAME	InitializeSchedItemTab

  DESCRIPTION		This procedure is used to initialize the
  			g_SchedItemTab table which has a row for every
  			unique combination of SF/ST/BT/CI and other attribs.

  DESIGN REFERENCES

  CHANGE HISTORY	rlanka		04/10/02	Created
============================================================================*/
PROCEDURE InitializeSchedItemTab (x_HeaderID IN NUMBER);


/*==========================================================================
  FUNCTION NAME		IsDuplicate

  DESCRIPTION		This function checks whether the item attribs record
  			currently exists in the g_SchedItemTab table.  Return
  			TRUE if present, FALSE otherwise.

  DESIGN REFERENCES

  CHANGE HISTORY	rlanka		04/10/02	Created
============================================================================*/
FUNCTION IsDuplicate(x_ItemAttribsRec IN t_ItemAttribsRec) RETURN BOOLEAN;



/*==========================================================================
  PROCEDURE NAME	InsertItemAttribsRec

  DESCRIPTION		This procedure inserts an item attributes record
  			into g_SchedItemTab.

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		04/10/02	Created
============================================================================*/
PROCEDURE InsertItemAttribRec(x_ItemAttribsRec IN t_ItemAttribsRec);



/*==========================================================================
  PROCEDURE NAME	UpdateLineNumbers

  DESCRIPTION		This procedure is used to assign values to column
			line_number.

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		02/22/02	Created
============================================================================*/
PROCEDURE UpdateLineNumbers(x_HeaderID IN     NUMBER,
			    x_ErrCode  IN OUT NOCOPY NUMBER,
			    x_ErrMsg   IN OUT NOCOPY VARCHAR2);



/*==========================================================================
  PROCEDURE NAME	FlexBktAssignment

  DESCRIPTION		Updates the start/end date times on a line using the
			details from the PSFLEXBKT segment on an SPSI schedule
			if the BKTYPE matches any FLEXBKTID entry.

  DESIGN REFERENCES	rlmxmldld.rtf

  CHANGE HISTORY	rlanka		02/22/02	Created
============================================================================*/
PROCEDURE FlexBktAssignment(x_header_id IN     NUMBER,
			    x_ErrCode   IN OUT NOCOPY NUMBER,
			    x_ErrMsg    IN OUT NOCOPY VARCHAR2);

--MOAC: Added the following new procedure
/*==========================================================================
  PROCEDURE NAME        GetDefaultOU

  DESCRIPTION           This procedure is used to get the valu of
                        MO:Default Operating Unit which will be inserted
                        into the rlm tables once the XML transactions are
                        interfaced to RLM.

  DESIGN REFERENCES     MultiOrg_TDD.rtf

  CHANGE HISTORY        anviswan          03/21/05        Created
============================================================================*/


PROCEDURE GetDefaultOU(x_default_ou IN OUT NOCOPY NUMBER,
                       x_ErrCode  IN OUT NOCOPY NUMBER,
                       x_ErrMsg   IN OUT NOCOPY VARCHAR2);

--CR: Added the following new procedure
/*==========================================================================
  PROCEDURE NAME        DeriveCustomerId

  DESCRIPTION           This procedure is used to Derive the Customer id from the
                        SourceTPLocationCode sent in the envelope and
                        assign to the ece_tp_location_code_ext

  DESIGN REFERENCES     TCACustomerRelationships_TDD.rtf

  CHANGE HISTORY        mnandell          06/21/05        Created
============================================================================*/


PROCEDURE DeriveCustomerId(x_internalcontrolNum IN NUMBER,
                           x_SourceTPLocCode OUT NOCOPY VARCHAR2,
                           x_CustomerId OUT NOCOPY NUMBER,
                           x_ErrCode  IN OUT NOCOPY NUMBER,
                           x_ErrMsg   IN OUT NOCOPY VARCHAR2);

END RLM_XML_API;
 

/
