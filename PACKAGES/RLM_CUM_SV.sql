--------------------------------------------------------
--  DDL for Package RLM_CUM_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_CUM_SV" AUTHID CURRENT_USER AS
/* $Header: RLMCUMMS.pls 120.2.12010000.1 2008/07/21 09:43:48 appldev ship $ */
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>


/*============================================================================
  PACKAGE NAME:		rlm_cum_sv

  DESCRIPTION:  	Contains procedures that perform the following task:

			1) calculate the cum key id based on the input
			parameters. If the cum key id is not found, a new cum
			key id will be inserted into cum key table. It also
			returns cum related quantity for the cum key id.

			2) calculate the supplier's CUM associated with a CUM
			Key Identifier, using CUM Rules established for the
			CUSTOMER or ADDRESS, or for the CUSTOMER_ITEM eligible
			for CUM Calculation.

			3) update cum key after shipment. Updates occur in cum
			key table and OE Order Lines.

			4) adjust cum key every time cum start date is altered

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		JAUTOMO

  PROCEDURE/FUNCTIONS:	CalculateCumKey
				CalculateSupplierCum
  				UpdateCumKey
  				ResetCum
				GetCumControlCode
  ===========================================================================*/
  -- Global Variables

  C_SDEBUG		NUMBER := rlm_core_sv.C_LEVEL6;
  C_DEBUG		NUMBER := rlm_core_sv.C_LEVEL7;

TYPE cum_key_attrib_rec_type IS RECORD (
-- Parameter definition is changed as per TCA obsolescence project.
  customer_id			HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE,
  customer_item_id		RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE,
  inventory_item_id             OE_ORDER_LINES.INVENTORY_ITEM_ID%TYPE,
  ship_from_org_id		RLM_CUST_ITEM_CUM_KEYS.SHIP_FROM_ORG_ID%TYPE,
  intrmd_ship_to_address_id 	RLM_CUST_ITEM_CUM_KEYS.INTRMD_SHIP_TO_ID%TYPE,
  ship_to_address_id		RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE,
  bill_to_address_id		RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE,
  purchase_order_number		RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE,
  cust_record_year		RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE,
  cum_start_date		DATE,
  called_by_reset_cum		VARCHAR2(1) NOT NULL DEFAULT 'N',
  create_cum_key_flag		VARCHAR2(1) NOT NULL DEFAULT 'Y'
  --update_old_cum_key_id         VARCHAR2(1) DEFAULT 'N',
  --old_cum_key_id	        NUMBER DEFAULT 0
  );

TYPE cum_rec_type is RECORD (
  msg_data			VARCHAR2(2500),
  -- Bug# 1426313
  msg_name                      VARCHAR2(30) DEFAULT NULL,
  record_return_status		BOOLEAN DEFAULT FALSE,
  cum_key_id			RLM_CUST_ITEM_CUM_KEYS.CUM_KEY_ID%TYPE,
  cum_start_date		RLM_CUST_ITEM_CUM_KEYS.CUM_START_DATE%TYPE,
  shipped_quantity		OE_ORDER_LINES.SHIPPED_QUANTITY%TYPE DEFAULT 0,
  actual_shipment_date		OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE DEFAULT SYSDATE,
  cum_key_created_flag		BOOLEAN DEFAULT FALSE,
  cum_qty			RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE DEFAULT 0,
  as_of_date_cum_qty		RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE DEFAULT 0,
  cum_qty_to_be_accumulated	RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_TO_BE_ACCUMULATED%TYPE DEFAULT 0,
  cum_qty_after_cutoff		RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_AFTER_CUTOFF%TYPE DEFAULT 0,
  last_cum_qty_update_date	RLM_CUST_ITEM_CUM_KEYS.LAST_CUM_QTY_UPDATE_DATE%TYPE,
  cust_uom_code			RLM_CUST_ITEM_CUM_KEYS.CUST_UOM_CODE%TYPE,
  use_ship_incl_rule_flag	VARCHAR2(1) DEFAULT 'Y',
  shipment_rule_code		RLM_CUST_SHIPTO_TERMS.CUM_SHIPMENT_RULE_CODE%TYPE DEFAULT 'AS_OF_CURRENT',
  yesterday_time_cutoff		RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  last_update_date		RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  as_of_date_time		OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE,
  customer_item_id		RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE,
  inventory_item_id             OE_ORDER_LINES.INVENTORY_ITEM_ID%TYPE);

TYPE cum_oe_lines_type IS RECORD (
  line_id                       oe_order_lines.line_id%TYPE,
  header_id                     oe_order_lines.header_id%TYPE,
  --industry_attribute7           oe_order_lines.industry_attribute7%TYPE,
  --industry_attribute8           oe_order_lines.industry_attribute8%TYPE,
  shipped_quantity              oe_order_lines.shipped_quantity%TYPE,
  actual_shipment_date          oe_order_lines.actual_shipment_date%TYPE,
  order_quantity_uom            oe_order_lines.order_quantity_uom%TYPE,
  org_id                        oe_order_lines_all.org_id%TYPE);


TYPE t_oe_header_rec IS RECORD (
   header_id  NUMBER,
   org_id     NUMBER );
TYPE t_cum_oe_lines IS TABLE OF cum_oe_lines_type INDEX BY BINARY_INTEGER;
TYPE t_new_ship_count IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_oe_header IS TABLE OF t_oe_header_rec INDEX BY BINARY_INTEGER;
TYPE t_old_cum IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_cums  IS TABLE OF cum_rec_type INDEX BY BINARY_INTEGER;

  C_cum_oe_lines                        NUMBER := 1;
  C_line_table_type                     NUMBER := 2;
  g_cum_oe_lines                        t_cum_oe_lines;
  g_miss_new_ship_count			t_new_ship_count;
  g_oe_header_rec 			oe_order_pub.header_rec_type;
  g_oe_header_val_rec             	oe_order_pub.header_val_rec_type;
  g_oe_header_adj_tbl            	oe_order_pub.header_adj_tbl_type;
  g_oe_header_adj_val_tbl        	oe_order_pub.header_adj_val_tbl_type;
  g_oe_header_scredit_tbl         	oe_order_pub.header_scredit_tbl_type;
  g_oe_header_scredit_val_tbl     	oe_order_pub.header_scredit_val_tbl_type;
  g_oe_line_tbl                   	oe_order_pub.line_tbl_type := oe_order_pub.g_miss_line_tbl;
  g_oe_tmp_line_tbl                   	oe_order_pub.line_tbl_type := oe_order_pub.g_miss_line_tbl;
  g_oe_line_val_tbl               	oe_order_pub.line_val_tbl_type;
  g_oe_header_out_rec             	oe_order_pub.header_rec_type;
  g_oe_header_val_out_rec         	oe_order_pub.header_val_rec_type;
  g_oe_header_adj_out_tbl         	oe_order_pub.header_adj_tbl_type;
  g_oe_header_adj_val_out_tbl     	oe_order_pub.header_adj_val_tbl_type;
  g_oe_header_scredit_out_tbl     	oe_order_pub.header_scredit_tbl_type;
  g_oe_hdr_scdt_val_out_tbl      	oe_order_pub.header_scredit_val_tbl_type;
  g_oe_line_out_tbl               	oe_order_pub.line_tbl_type;
  g_oe_line_val_out_tbl           	oe_order_pub.line_val_tbl_type;
  g_oe_line_adj_out_tbl           	oe_order_pub.line_adj_tbl_type;
  g_oe_line_adj_val_out_tbl      	oe_order_pub.line_adj_val_tbl_type;
  g_oe_line_scredit_out_tbl       	oe_order_pub.line_scredit_tbl_type;
  g_oe_line_scredit_val_out_tbl   	oe_order_pub.line_scredit_val_tbl_type;
  g_oe_lot_serial_out_tbl         	oe_order_pub.Lot_Serial_Tbl_Type;
  g_oe_lot_serial_val_out_tbl     	oe_order_pub.Lot_Serial_Val_Tbl_Type;
  g_oe_action_request_out_tbl     	oe_order_pub.request_tbl_type;
  g_Header_price_Att_out_tbl		oe_order_pub.Header_Price_Att_Tbl_Type;
  g_Header_Adj_Att_out_tbl		oe_order_pub.Header_Adj_Att_Tbl_Type;
  g_Header_Adj_Assoc_out_tbl		oe_order_pub.Header_Adj_Assoc_Tbl_Type;
  g_Line_price_Att_out_tbl		oe_order_pub.Line_Price_Att_Tbl_Type;
  g_Line_Adj_Att_out_tbl		oe_order_pub.Line_Adj_Att_Tbl_Type;
  g_Line_Adj_Assoc_out_tbl		oe_order_pub.Line_Adj_Assoc_Tbl_Type;

  --g_NameForIdRec                        name_for_id_type;
  k_CalledByVD                          CONSTANT NUMBER := 1;
  g_manual_cum                          BOOLEAN := FALSE; -- BugFix #4147544

/*=============================================================================
  FUNCTION NAME:	get_cum_control

  DESCRIPTION:		This procedure will be called by Demand Status
                        Inquiry Report, to get the CUM Control Code
			based on the setup made in the RLM Setup Terms Form.

  PARAMETERS:		i_ship_from_org_id	 IN NUMBER
                        i_customer_id            IN NUMBER,
                        i_ship_to_address_id     IN NUMBER,
                        i_customer_item_id       IN NUMBER

 ============================================================================*/
  FUNCTION get_cum_control(
               i_ship_from_org_id          IN NUMBER,
               i_customer_id               IN NUMBER,
               i_ship_to_address_id        IN NUMBER,
               i_customer_item_id          IN NUMBER
                            )
  RETURN VARCHAR2;

/*=============================================================================
  PROCEDURE NAME:	CalculateCumKey

  DESCRIPTION:	This procedure will be called to calculate
			cum key id based on the input parameters: cum_key_record,
			and cum_record. If the cum key id is not found, a new cum key
			id will be inserted into cum key table. It also return cum
			related quantity for the cum key id.

  PARAMETERS:	x_cum_key_record IN cum_key_attrib_rec_type
		x_cum_record     IN OUT NOCOPY cum_rec_type

 ============================================================================*/

 PROCEDURE CalculateCumKey (
	x_cum_key_record IN     RLM_CUM_SV.cum_key_attrib_rec_type,
	x_cum_record     IN OUT NOCOPY RLM_CUM_SV.cum_rec_type);
--<TPA_PUBLIC_NAME>
/*=============================================================================
  PROCEDURE NAME:	CalculateCumKeyClient

  DESCRIPTION:	This procedure will be called to calculate
			cum key id based on the input parameters:
                  not in records data structure, but regular
                  variables. It is to be called from forms 6
                  application.
			If the cum key id is not found, a new cum key id
			will be inserted into cum key table. It also
			return cum related quantity for the cum key id.

  PARAMETERS:	look at the code below

 ============================================================================*/

PROCEDURE CalculateCumKeyClient (
-- Parameter definition is changed as per TCA obsolescence project.
  x_customer_id			IN	HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE,
  x_customer_item_id		IN	RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE,
  x_ship_from_org_id		IN	RLM_CUST_ITEM_CUM_KEYS.SHIP_FROM_ORG_ID%TYPE,
  x_intrmd_ship_to_address_id IN	RLM_CUST_ITEM_CUM_KEYS.INTRMD_SHIP_TO_ID%TYPE,
  x_ship_to_address_id		IN	RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE,
  x_bill_to_address_id		IN	RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE,
  x_purchase_order_number	IN	RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE,
  x_cust_record_year		IN	RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE,
  x_create_cum_key_flag		IN	VARCHAR2,
  x_msg_data			IN OUT NOCOPY VARCHAR2,
  x_record_return_status	IN OUT NOCOPY BOOLEAN,
  x_cum_key_id			IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_KEY_ID%TYPE,
  x_cum_start_date		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_START_DATE%TYPE,
  x_shipped_quantity		IN OUT NOCOPY OE_ORDER_LINES.SHIPPED_QUANTITY%TYPE,
  x_actual_shipment_date	IN OUT NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE,
  x_cum_key_created_flag	IN OUT NOCOPY BOOLEAN,
  x_cum_qty			IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_as_of_date_cum_qty		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_cum_qty_to_be_accumulated	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_TO_BE_ACCUMULATED%TYPE,
  x_cum_qty_after_cutoff	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_AFTER_CUTOFF%TYPE,
  x_last_cum_qty_update_date	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_CUM_QTY_UPDATE_DATE%TYPE,
  x_cust_uom_code		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUST_UOM_CODE%TYPE,
  x_use_ship_incl_rule_flag	IN OUT NOCOPY VARCHAR2,
  x_shipment_rule_code		IN OUT NOCOPY RLM_CUST_SHIPTO_TERMS.CUM_SHIPMENT_RULE_CODE%TYPE,
  x_yesterday_time_cutoff	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_last_update_date		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_as_of_date_time		IN OUT NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE);

/*=============================================================================
  PROCEDURE NAME:	CalculateSupplierCum

  DESCRIPTION:		This procedure will be called to calculate the
                        supplier's CUM associated with a CUM Key Identifier,
                        using CUM Rules established for the CUSTOMER or
                        ADDRESS, or for the CUSTOMER_ITEM eligible for CUM
                        Calculation.

  PARAMETERS:		x_new_ship_count IN     t_new_ship_count
			x_cum_key_record IN     cum_key_attrib_rec_type%TYPE
			x_cum_record     IN OUT NOCOPY cum_rec_type%TYPE

 ============================================================================*/

 PROCEDURE CalculateSupplierCum (
     x_new_ship_count        IN     RLM_CUM_SV.t_new_ship_count := RLM_CUM_SV.g_miss_new_ship_count,
     x_cum_key_record        IN     RLM_CUM_SV.cum_key_attrib_rec_type,
     x_cum_record            IN OUT NOCOPY RLM_CUM_SV.cum_rec_type);
--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:	CalculateSupplierCumClient

  DESCRIPTION:	This procedure will be called to calculate
			cum key id based on the input parameters:
                  not in records data structure, but regular
                  variables. It is to be called from forms 6
                  application.
			If the cum key id is not found, a new cum key id
			will be inserted into cum key table. It also
			return cum related quantity for the cum key id.

  PARAMETERS:	look at the code below

 ============================================================================*/

PROCEDURE CalculateSupplierCumClient (
-- Parameter definition is changed as per TCA obsolescence project.
  x_customer_id			IN	HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE,
  x_customer_item_id		IN	RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE,
  x_inventory_item_id           IN      OE_ORDER_LINES.INVENTORY_ITEM_ID%TYPE,
  x_ship_from_org_id		IN	RLM_CUST_ITEM_CUM_KEYS.SHIP_FROM_ORG_ID%TYPE,
  x_intrmd_ship_to_address_id IN	RLM_CUST_ITEM_CUM_KEYS.INTRMD_SHIP_TO_ID%TYPE,
  x_ship_to_address_id		IN	RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE,
  x_bill_to_address_id		IN	RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE,
  x_purchase_order_number	IN	RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE,
  x_cust_record_year		IN	RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE,
  x_create_cum_key_flag		IN	VARCHAR2,
  x_msg_data			IN OUT NOCOPY VARCHAR2,
  x_record_return_status	IN OUT NOCOPY BOOLEAN,
  x_cum_key_id			IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_KEY_ID%TYPE,
  x_cum_start_date		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_START_DATE%TYPE,
  x_shipped_quantity		IN OUT NOCOPY OE_ORDER_LINES.SHIPPED_QUANTITY%TYPE,
  x_actual_shipment_date	IN OUT NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE,
  x_cum_key_created_flag	IN OUT NOCOPY BOOLEAN,
  x_cum_qty				IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_as_of_date_cum_qty		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY%TYPE,
  x_cum_qty_to_be_accumulated	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_TO_BE_ACCUMULATED%TYPE,
  x_cum_qty_after_cutoff	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUM_QTY_AFTER_CUTOFF%TYPE,
  x_last_cum_qty_update_date	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_CUM_QTY_UPDATE_DATE%TYPE,
  x_cust_uom_code			IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.CUST_UOM_CODE%TYPE,
  x_use_ship_incl_rule_flag	IN OUT NOCOPY VARCHAR2,
  x_shipment_rule_code		IN OUT NOCOPY RLM_CUST_SHIPTO_TERMS.CUM_SHIPMENT_RULE_CODE%TYPE,
  x_yesterday_time_cutoff	IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_last_update_date		IN OUT NOCOPY RLM_CUST_ITEM_CUM_KEYS.LAST_UPDATE_DATE%TYPE,
  x_as_of_date_time		IN OUT NOCOPY OE_ORDER_LINES.ACTUAL_SHIPMENT_DATE%TYPE);

/*=============================================================================
  PROCEDURE NAME:	UpdateCumKey

  DESCRIPTION:	This procedure will be called to calculate
			the cum key id and attach it to the OE Order Lines
			after shipment has been confirmed.
			It is also called to calculate the total cum
			quantities including the shipment quantities that
			are just confirmed.

  PARAMETERS:	x_trip_stop_id   IN  NUMBER
		x_return_status  OUT NOCOPY BOOLEAN

 ============================================================================*/

 PROCEDURE UpdateCumKey (
	x_trip_stop_id   	IN  NUMBER,
	x_return_status 	OUT NOCOPY BOOLEAN);
--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:	UpdateCumKeyClient

  DESCRIPTION:	This procedure will be called to calculate
		the cum key id and attach it to the OE Order Lines
		after shipment has been confirmed.
		It is also called to calculate the total cum
		quantities including the shipment quantities that
		are just confirmed.

  PARAMETERS:	errbuf			OUT VARCHAR2
		retcode			OUT NUMBER
		x_trip_stop_id   	IN  NUMBER

 ============================================================================*/

 PROCEDURE UpdateCumKeyClient (
	errbuf			OUT NOCOPY VARCHAR2,
	retcode			OUT NOCOPY NUMBER,
	x_trip_stop_id   	IN  NUMBER);

/*=============================================================================
  PROCEDURE NAME:	ResetCum

  DESCRIPTION:	This procedure will be called to alter
			the cum key id stored in cum key table
			and oe order line table, to adjust changes
			made to the cum keys.

  PARAMETERS:	x_ship_from_org_id	 IN NUMBER
			x_customer_id		 IN NUMBER
			x_ship_to_org_id		 IN NUMBER
			x_intrmd_ship_to_org_id	 IN NUMBER
			x_bill_to_org_id	 	 IN NUMBER
			x_customer_item_id	 IN NUMBER
			x_transaction_start_date IN DATE
			x_transaction_end_date	 IN DATE
			x_return_status		 OUT NOCOPY BOOLEAN

 ============================================================================*/

 PROCEDURE ResetCum (
                p_org_id                 IN NUMBER,
		x_ship_from_org_id	 IN NUMBER,
		x_customer_id		 IN NUMBER,
		x_ship_to_org_id	 	 IN NUMBER,
		x_intrmd_ship_to_org_id	 IN NUMBER,
		x_bill_to_org_id	 	 IN NUMBER,
		x_customer_item_id       IN NUMBER,
		x_transaction_start_date IN DATE,
		x_transaction_end_date	 IN DATE DEFAULT SYSDATE,
		x_return_status		 OUT NOCOPY BOOLEAN);

-- This is called by Cum Key Adjustment concurrent program executable

 PROCEDURE ResetCumClient (
		errbuf			 OUT NOCOPY VARCHAR2,
		retcode			 OUT NOCOPY NUMBER,
                p_org_id                 IN NUMBER,
		x_ship_from_org_id	 IN NUMBER,
		x_customer_id		 IN NUMBER,
		x_ship_to_org_id	 IN NUMBER,
		x_intrmd_ship_to_org_id	 IN NUMBER,
		x_bill_to_org_id	 IN NUMBER,
		x_customer_item_id       IN NUMBER,
		x_transaction_start_date IN VARCHAR2,
		x_transaction_end_date   IN VARCHAR2);

/*=============================================================================
  FUNCTION NAME:	GetCumControl

  DESCRIPTION:		This procedure will be called by Demand Status
                        Inquiry Report, to get the CUM Control Code
			based on the setup made in the RLM Setup Terms Form.

  PARAMETERS:		i_ship_from_org_id	 IN NUMBER
                        i_customer_id            IN NUMBER,
                        i_ship_to_address_id     IN NUMBER,
                        i_customer_item_id       IN NUMBER


 ============================================================================*/
  FUNCTION GetCumControl(
               i_ship_from_org_id          IN NUMBER,
               i_customer_id               IN NUMBER,
               i_ship_to_address_id        IN NUMBER,
               i_customer_item_id          IN NUMBER
                            )
  RETURN VARCHAR2;

/*=============================================================================
  FUNCTION NAME:	GetCumManagement

  DESCRIPTION:		This procedure will be called by Release Workbench
                        to get the cum control code and cum organization
			level code

  PARAMETERS:		i_ship_from_org_id	 IN NUMBER
                        i_customer_id            IN NUMBER,
                        i_ship_to_address_id     IN NUMBER,
                        i_customer_item_id       IN NUMBER,
			o_cum_control_code	 IN VARCHAR2,
			o_cum_org_level_code	 IN VARCHAR2

 ============================================================================*/
  PROCEDURE GetCumManagement(
               i_ship_from_org_id          IN NUMBER,
               i_ship_to_address_id        IN NUMBER,
               i_customer_item_id          IN NUMBER,
	       o_cum_control_code	   OUT NOCOPY VARCHAR2,
	       o_cum_org_level_code	   OUT NOCOPY VARCHAR2
                            );

/*=============================================================================
  PROCEDURE NAME:	GetCumStartDate

  DESCRIPTION:		This procedure is called by CalculateCumKey to
			get the cum current start date and cum current record
			year

  PARAMETERS:	i_schedule_header_id	IN NUMBER
                i_schedule_line_id	IN NUMBER
		o_cum_start_date	OUT DATE
		o_cust_record_year	OUT VARCHAR2
		o_return_message	OUT VARCHAR2
		o_return_status		OUT BOOLEAN

 ============================================================================*/
  PROCEDURE GetCumStartDate(
			i_schedule_header_id	IN NUMBER,
			i_schedule_line_id	IN NUMBER,
			o_cum_start_date	OUT NOCOPY DATE,
			o_cust_record_year	OUT NOCOPY VARCHAR2,
			o_return_message	OUT NOCOPY VARCHAR2,
			o_return_status		OUT NOCOPY BOOLEAN);

/*=============================================================================
  PROCEDURE NAME:	GetTPContext

  DESCRIPTION:		This procedure returns the tpcontext using CUM Key
			Record

  PARAMETERS:		x_cum_key_record		IN  RLM_CUM_SV.cum_key_attrib_rec_type
                       	x_customer_number 		OUT NOCOPY VARCHAR2
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2

 ============================================================================*/
  PROCEDURE GetTPContext(
			x_cum_key_record		IN  RLM_CUM_SV.cum_key_attrib_rec_type,
                       	x_customer_number 		OUT NOCOPY VARCHAR2,
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2);
--<TPA_TPS>

/*=============================================================================
  PROCEDURE NAME:	GetTPContext2

  DESCRIPTION:		This procedure returns the tpcontext using Trip Stop ID

  PARAMETERS:		x_trip_stop_id			IN  NUMBER
                       	x_customer_number 		OUT NOCOPY VARCHAR2
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2

 ============================================================================*/
 PROCEDURE GetTPContext2(
			x_trip_stop_id			IN  NUMBER,
                       	x_customer_number 		OUT NOCOPY VARCHAR2,
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2);
--<TPA_TPS>

/*============================================================================

  PROCEDURE NAME:       GetCums


  This procedure is called by reset cum.  According to the parameters and
  the setup terms for the cum, it gets all the cum records from
  rlm_cust_item_cum_keys.  From the records returned, the program filters
  out NOCOPY those recors which do not have any manual adjustments within the period
  nor any shipments(if there is any shipment the field last_cum_qty_update_date
  would be within the time frame).  These records would be sorted, so that all
  corresponding Cums are in sorted together(for example same customer items
  may be sorted together).  The program recognizes the first record of each
  group as the newly created CUM and the reset of the group as the CUMs which
  are being adjusted.  It then puts all the new cums in one table and all the
  old one in a different table.


  PARAMETERS:

   **  x_rlm_setup_terms_record      IN
       This is setupterms generated from the resetCums parameters
   **  x_terms_level                 IN
       This is the same as parameter x_terms_definition_level of
       rlm_setup_terms_sv.get_setup_terms
   **  x_cum_key_record              IN
       This records would containe the followings if it could be derived in
       resetcum
       bill_to_address_id, ship_to_address_id, intrmd_ship_to_address_id,
       ship_from_org_id,customer_item_id,customer_id
   **  x_transaction_start_date      IN
       same as parameter in resetcum
   **  x_transaction_end_date        IN
       same as parameter in resetcum would be defaulted to sysdate
   **  x_cum_records                 OUT
       These are records of all new cum_keys created
   **  x_old_cum_records             OUT
       These are all old_cums which either have shipment or manual adjustments
   **  x_counter                     OUT
       This is a table that indicates the relation ship between x_cum_records
       and x_old_cum_records.  For example, if x_cum_records(3) has
       2 records in the old cums table x_old_cum_records, then
       x_counter(3) would have the value 2
   **  x_return_status               OUT
       1 if any cums found to be adjusted, 0 if no cum

=============================================================================*/
 PROCEDURE GetCums (
        x_rlm_setup_terms_record  IN  rlm_setup_terms_sv.setup_terms_rec_typ,
        x_terms_level             IN  VARCHAR2 DEFAULT NULL,
        x_cum_key_record          IN  OUT NOCOPY rlm_cum_sv.cum_key_attrib_rec_type,
        x_transaction_start_date  IN  DATE,
        x_transaction_end_date    IN  DATE DEFAULT NULL,
        x_ship_from_org_id        IN  NUMBER DEFAULT NULL,
        x_ship_to_org_id          IN  NUMBER DEFAULT NULL,
        x_intmed_ship_to_org_id   IN  NUMBER DEFAULT NULL,
        x_bill_to_org_id          IN  NUMBER DEFAULT NULL,
        x_cum_records             OUT NOCOPY RLM_CUM_SV.t_cums,
        x_old_cum_records         OUT NOCOPY RLM_CUM_SV.t_cums,
        x_counter                 OUT NOCOPY RLM_CUM_SV.t_new_ship_count,
        x_return_status           OUT NOCOPY NUMBER);

/*============================================================================

  PROCEDURE NAME:       SetSupplierCum

    This procedure calls the CalculateSupplierCum for all the shipments
    for the given Cum Key.  It populates oe global tables and it calculates
    the cum qty

  PARAMETERS:

     ** x_index                   IN              NUMBER
        This is the index for table x_cum_records
     ** x_cum_key_record          IN              cum_key_attrib_rec_type
        contains information adbout address ids
     ** x_transaction_start_date  IN              DATE
     ** x_cum_records             IN OUT NOCOPY          RLM_CUM_SV.t_cums
        Using the x_index we get the new cum record which needs to be rest
     ** x_return_status           OUT NOCOPY          BOOLEAN
        This will return FALSE if unexpected error happens
     ** x_counter                 IN OUT NOCOPY          NUMBER
        Shows the number of order lines modified

=============================================================================*/

 PROCEDURE SetSupplierCum (
        x_index                   IN              NUMBER,
        x_cum_key_record          IN              cum_key_attrib_rec_type,
        x_transaction_start_date  IN              DATE,
        x_cum_records             IN OUT NOCOPY          RLM_CUM_SV.t_cums,
        x_return_status           OUT NOCOPY             BOOLEAN,
        x_counter                 IN OUT NOCOPY          NUMBER,
        x_adjustment_date         IN OUT NOCOPY          DATE );

/*===========================================================================

PROCEDURE NAME:    QuickSort

===========================================================================*/

PROCEDURE QuickSort(first    IN NUMBER,
                    last     IN NUMBER,
                    sortType IN NUMBER);

/*===========================================================================

PROCEDURE NAME:    Swap

===========================================================================*/
PROCEDURE Swap( i       IN NUMBER,
                j       IN NUMBER,
               sortType IN NUMBER);


PROCEDURE GetShippLines (
        x_cum_key_id              IN              NUMBER,
        x_ship_from_org_id        IN              NUMBER DEFAULT NULL,
        x_ship_to_org_id          IN              NUMBER DEFAULT NULL,
        x_intmed_ship_to_org_id   IN              NUMBER DEFAULT NULL,
        x_bill_to_org_id          IN              NUMBER DEFAULT NULL,
        x_customer_item_id        IN              NUMBER DEFAULT NULL,
        x_inventory_item_id       IN              NUMBER,
        x_transaction_start_date  IN              DATE,
        x_transaction_end_date    IN              DATE ,
        x_index                   IN  OUT NOCOPY         NUMBER );


PROCEDURE UpdateOldKey(x_old_cum_records        IN OUT NOCOPY RLM_CUM_SV.t_cums,
                         x_shipment_rule_code     IN VARCHAR2 DEFAULT
                                                          'AS_OF_CURRENT',
                         x_cutoff_time            IN DATE     DEFAULT NULL,
                         x_cum_key_record         IN OUT NOCOPY cum_key_attrib_rec_type,
                         x_ship_from_org_id       IN NUMBER DEFAULT NULL,
                         x_ship_to_org_id         IN NUMBER DEFAULT NULL,
                         x_intmed_ship_to_org_id  IN NUMBER DEFAULT NULL,
                         x_bill_to_org_id         IN NUMBER DEFAULT NULL,
                         x_customer_item_id       IN NUMBER DEFAULT NULL,
                         x_return_status          OUT NOCOPY BOOLEAN);

FUNCTION GetInventoryItemId(x_customer_item_id IN NUMBER)
return NUMBER;



/*=======================================================================

 PROCEDURE GetLatestCum (
        x_cum_key_record IN     RLM_CUM_SV.cum_key_attrib_rec_type,
        x_rlm_setup_terms_record IN rlm_setup_terms_sv.setup_terms_rec_typ,
        x_cum_record     IN OUT NOCOPY RLM_CUM_SV.cum_rec_type);

=========================================================================*/


 PROCEDURE GetLatestCum (
        x_cum_key_record IN     RLM_CUM_SV.cum_key_attrib_rec_type,
        x_rlm_setup_terms_record IN rlm_setup_terms_sv.setup_terms_rec_typ,
        x_cum_record     IN OUT NOCOPY RLM_CUM_SV.cum_rec_type,
        x_called_from_vd IN NUMBER DEFAULT 0);


/*=========================================================================

PROCEDURE NAME:       LockCumKey

Parameter: x_CumKeyId  IN NUMBER

Created by: jckwok

Creation Date: June 15, 2004

History: Created due to Bug 3688778

===========================================================================*/

FUNCTION LockCumKey (x_CumKeyId  IN NUMBER)
RETURN BOOLEAN;


END RLM_CUM_SV;

/
