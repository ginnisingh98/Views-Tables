--------------------------------------------------------
--  DDL for Package RLM_SETUP_TERMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_SETUP_TERMS_SV" AUTHID CURRENT_USER AS
/* $Header: RLMSETTS.pls 120.0 2005/05/26 17:16:25 appldev noship $ */

--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>

/*============================================================================
  PACKAGE NAME:		rlm_setup_terms_sv

  DESCRIPTION:  	Contains procedures that populate RLM setup terms
			record at three levels: customer, address and
			customer item.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		JAUTOMO

  PROCEDURE/FUNCTIONS:	get_setup_terms()
			populate_record_cust()
			populate_record_add()
			populate_record_item()

  ===========================================================================*/
  C_SDEBUG		NUMBER := rlm_core_sv.C_LEVEL6;
  C_DEBUG		NUMBER := rlm_core_sv.C_LEVEL7;


  /* Global type setup_terms_rec_typ is defined as a record here,
     for other programs to use */

  TYPE setup_terms_rec_typ is RECORD (

 cust_shipto_terms_id     RLM_CUST_SHIPTO_TERMS.CUST_SHIPTO_TERMS_ID%TYPE,
 customer_id		  RLM_CUST_SHIPTO_TERMS.CUSTOMER_ID%TYPE,
 cum_control_code	  RLM_CUST_SHIPTO_TERMS.CUM_CONTROL_CODE%TYPE,
 cum_org_level_code	  RLM_CUST_SHIPTO_TERMS.CUM_ORG_LEVEL_CODE%TYPE,
 cum_shipment_rule_code	  RLM_CUST_SHIPTO_TERMS.CUM_SHIPMENT_RULE_CODE%TYPE,
 cum_yesterd_time_cutoff  RLM_CUST_SHIPTO_TERMS.CUM_YESTERD_TIME_CUTOFF%TYPE,
 cust_assign_supplier_cd  RLM_CUST_SHIPTO_TERMS.CUST_ASSIGN_SUPPLIER_CD%TYPE,
 customer_rcv_calendar_cd RLM_CUST_SHIPTO_TERMS.CUSTOMER_RCV_CALENDAR_CD%TYPE,
 supplier_shp_calendar_cd RLM_CUST_SHIPTO_TERMS.SUPPLIER_SHP_CALENDAR_CD%TYPE,
 unship_firm_cutoff_days  RLM_CUST_SHIPTO_TERMS.UNSHIP_FIRM_CUTOFF_DAYS%TYPE,
 unshipped_firm_disp_cd	  RLM_CUST_SHIPTO_TERMS.UNSHIPPED_FIRM_DISP_CD%TYPE,
 inactive_date	  	  RLM_CUST_SHIPTO_TERMS.INACTIVE_DATE%TYPE,
 critical_attribute_key	  RLM_CUST_SHIPTO_TERMS.CRITICAL_ATTRIBUTE_KEY%TYPE,
 schedule_hierarchy_code  RLM_CUST_SHIPTO_TERMS.SCHEDULE_HIERARCHY_CODE%TYPE,
 comments		RLM_CUST_SHIPTO_TERMS.COMMENTS%TYPE,
 intransit_time		RLM_CUST_SHIPTO_TERMS.INTRANSIT_TIME%TYPE,
 time_uom_code		RLM_CUST_SHIPTO_TERMS.TIME_UOM_CODE%TYPE,
 ship_from_org_id	RLM_CUST_SHIPTO_TERMS.SHIP_FROM_ORG_ID%TYPE,
 address_id		RLM_CUST_ITEM_TERMS.ADDRESS_ID%TYPE,
 header_id		RLM_CUST_ITEM_TERMS.HEADER_ID%TYPE,
 agreement_id           RLM_CUST_ITEM_TERMS.AGREEMENT_ID%TYPE,
 agreement_name		RLM_CUST_ITEM_TERMS.AGREEMENT_NAME%TYPE,
 future_agreement_id	RLM_CUST_ITEM_TERMS.FUTURE_AGREEMENT_ID%TYPE,
 future_agreement_name	RLM_CUST_ITEM_TERMS.FUTURE_AGREEMENT_NAME%TYPE,
 round_to_std_pack_flag	RLM_CUST_ITEM_TERMS.ROUND_TO_STD_PACK_FLAG%TYPE,
 ship_delivery_rule_name RLM_CUST_ITEM_TERMS.SHIP_DELIVERY_RULE_NAME%TYPE,
 ship_method		RLM_CUST_ITEM_TERMS.SHIP_METHOD%TYPE,
 std_pack_qty		RLM_CUST_ITEM_TERMS.STD_PACK_QTY%TYPE,
 price_list_id		RLM_CUST_ITEM_TERMS.PRICE_LIST_ID%TYPE,
 use_edi_sdp_code_flag	RLM_CUST_ITEM_TERMS.USE_EDI_SDP_CODE_FLAG%TYPE,
 match_across_key	RLM_CUST_SHIPTO_TERMS.MATCH_ACROSS_KEY%TYPE,
 match_within_key	RLM_CUST_SHIPTO_TERMS.MATCH_WITHIN_KEY%TYPE,
 pln_firm_day_to	RLM_CUST_ITEM_TERMS.PLN_FIRM_DAY_TO%TYPE,
 pln_firm_day_from	RLM_CUST_ITEM_TERMS.PLN_FIRM_DAY_FROM%TYPE,
 pln_forecast_day_from	RLM_CUST_ITEM_TERMS.PLN_FORECAST_DAY_FROM%TYPE,
 pln_forecast_day_to	RLM_CUST_ITEM_TERMS.PLN_FORECAST_DAY_TO%TYPE,
 pln_frozen_day_to	RLM_CUST_ITEM_TERMS.PLN_FROZEN_DAY_TO%TYPE,
 pln_frozen_day_from	RLM_CUST_ITEM_TERMS.PLN_FROZEN_DAY_FROM%TYPE,
 seq_firm_day_from	RLM_CUST_ITEM_TERMS.SEQ_FIRM_DAY_FROM%TYPE,
 seq_firm_day_to	RLM_CUST_ITEM_TERMS.SEQ_FIRM_DAY_TO%TYPE,
 seq_forecast_day_to	RLM_CUST_ITEM_TERMS.SEQ_FORECAST_DAY_TO%TYPE,
 seq_forecast_day_from	RLM_CUST_ITEM_TERMS.SEQ_FORECAST_DAY_FROM%TYPE,
 seq_frozen_day_from	RLM_CUST_ITEM_TERMS.SEQ_FROZEN_DAY_FROM%TYPE,
 seq_frozen_day_to	RLM_CUST_ITEM_TERMS.SEQ_FROZEN_DAY_TO%TYPE,
 shp_firm_day_from	RLM_CUST_ITEM_TERMS.SHP_FIRM_DAY_FROM%TYPE,
 shp_firm_day_to	RLM_CUST_ITEM_TERMS.SHP_FIRM_DAY_TO%TYPE,
 shp_frozen_day_from	RLM_CUST_ITEM_TERMS.SHP_FROZEN_DAY_FROM%TYPE,
 shp_frozen_day_to	RLM_CUST_ITEM_TERMS.SHP_FROZEN_DAY_TO%TYPE,
 shp_forecast_day_from	RLM_CUST_ITEM_TERMS.SHP_FORECAST_DAY_FROM%TYPE,
 shp_forecast_day_to	RLM_CUST_ITEM_TERMS.SHP_FORECAST_DAY_TO%TYPE,
 demand_tolerance_above	RLM_CUST_ITEM_TERMS.DEMAND_TOLERANCE_ABOVE%TYPE,
 demand_tolerance_below	RLM_CUST_ITEM_TERMS.DEMAND_TOLERANCE_BELOW%TYPE,
 customer_contact_id	RLM_CUST_ITEM_TERMS.CUSTOMER_CONTACT_ID%TYPE,
 freight_code		RLM_CUST_ITEM_TERMS.FREIGHT_CODE%TYPE,
 supplier_contact_id	RLM_CUST_ITEM_TERMS.SUPPLIER_CONTACT_ID%TYPE,
 attribute_category	RLM_CUST_ITEM_TERMS.ATTRIBUTE_CATEGORY%TYPE,
 tp_attribute_category	RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE_CATEGORY%TYPE,
 attribute1		RLM_CUST_ITEM_TERMS.ATTRIBUTE1%TYPE,
 attribute2		RLM_CUST_ITEM_TERMS.ATTRIBUTE2%TYPE,
 attribute3		RLM_CUST_ITEM_TERMS.ATTRIBUTE3%TYPE,
 attribute4		RLM_CUST_ITEM_TERMS.ATTRIBUTE4%TYPE,
 attribute5		RLM_CUST_ITEM_TERMS.ATTRIBUTE5%TYPE,
 attribute6		RLM_CUST_ITEM_TERMS.ATTRIBUTE6%TYPE,
 attribute7		RLM_CUST_ITEM_TERMS.ATTRIBUTE7%TYPE,
 attribute8		RLM_CUST_ITEM_TERMS.ATTRIBUTE8%TYPE,
 attribute9		RLM_CUST_ITEM_TERMS.ATTRIBUTE9%TYPE,
 attribute10		RLM_CUST_ITEM_TERMS.ATTRIBUTE10%TYPE,
 attribute11		RLM_CUST_ITEM_TERMS.ATTRIBUTE11%TYPE,
 attribute12		RLM_CUST_ITEM_TERMS.ATTRIBUTE12%TYPE,
 attribute13		RLM_CUST_ITEM_TERMS.ATTRIBUTE13%TYPE,
 attribute14		RLM_CUST_ITEM_TERMS.ATTRIBUTE14%TYPE,
 attribute15		RLM_CUST_ITEM_TERMS.ATTRIBUTE15%TYPE,
 tp_attribute1		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE1%TYPE,
 tp_attribute2		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE2%TYPE,
 tp_attribute3		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE3%TYPE,
 tp_attribute4		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE4%TYPE,
 tp_attribute5		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE5%TYPE,
 tp_attribute6		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE6%TYPE,
 tp_attribute7		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE7%TYPE,
 tp_attribute8		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE8%TYPE,
 tp_attribute9		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE9%TYPE,
 tp_attribute10		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE10%TYPE,
 tp_attribute11		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE11%TYPE,
 tp_attribute12		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE12%TYPE,
 tp_attribute13		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE13%TYPE,
 tp_attribute14		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE14%TYPE,
 tp_attribute15		RLM_CUST_ITEM_TERMS.TP_ATTRIBUTE15%TYPE,
 cust_item_terms_id	RLM_CUST_ITEM_TERMS.CUST_ITEM_TERMS_ID%TYPE,
 customer_item_id	RLM_CUST_ITEM_TERMS.CUSTOMER_ITEM_ID%TYPE,
 calc_cum_flag		RLM_CUST_ITEM_TERMS.CALC_CUM_FLAG%TYPE,
 cust_item_status_code	RLM_CUST_ITEM_TERMS.CUST_ITEM_STATUS_CODE%TYPE,
 pln_mrp_forecast_day_from   RLM_CUST_ITEM_TERMS.PLN_MRP_FORECAST_DAY_FROM%TYPE,
 pln_mrp_forecast_day_to     RLM_CUST_ITEM_TERMS.PLN_MRP_FORECAST_DAY_TO%TYPE,
 shp_mrp_forecast_day_from   RLM_CUST_ITEM_TERMS.SHP_MRP_FORECAST_DAY_FROM%TYPE,
 shp_mrp_forecast_day_to     RLM_CUST_ITEM_TERMS.SHP_MRP_FORECAST_DAY_TO%TYPE,
 seq_mrp_forecast_day_from   RLM_CUST_ITEM_TERMS.SEQ_MRP_FORECAST_DAY_FROM%TYPE,
 seq_mrp_forecast_day_to     RLM_CUST_ITEM_TERMS.SEQ_MRP_FORECAST_DAY_TO%TYPE,
 -- Bug# 1426313
 msg_name                    VARCHAR2(30),
 intransit_calc_basis	     RLM_CUST_SHIPTO_TERMS.INTRANSIT_CALC_BASIS%TYPE,
 pln_frozen_flag                 RLM_CUST_ITEM_TERMS.PLN_FROZEN_FLAG%TYPE,
 shp_frozen_flag                 RLM_CUST_ITEM_TERMS.SHP_FROZEN_FLAG%TYPE,
 seq_frozen_flag                 RLM_CUST_ITEM_TERMS.SEQ_FROZEN_FLAG%TYPE,
 issue_warning_drop_parts_flag   RLM_CUST_ITEM_TERMS.ISSUE_WARNING_DROP_PARTS_FLAG%TYPE,
 --
 -- for blankets
 blanket_number		     RLM_CUST_SHIPTO_TERMS.BLANKET_NUMBER%TYPE,
 release_rule	     	     RLM_CUST_SHIPTO_TERMS.RELEASE_RULE%TYPE,
 release_time_frame	     RLM_CUST_SHIPTO_TERMS.RELEASE_TIME_FRAME%TYPE,
 release_time_frame_uom      RLM_CUST_SHIPTO_TERMS.RELEASE_TIME_FRAME_UOM%TYPE,
 exclude_non_workdays_flag   RLM_CUST_SHIPTO_TERMS.EXCLUDE_NON_WORKDAYS_FLAG%TYPE,
 disable_create_cum_key_flag  RLM_CUST_ITEM_TERMS.disable_create_cum_key_flag%TYPE );


/*=============================================================================
  PROCEDURE NAME:	get_setup_terms

  DESCRIPTION:		This serves as a top level routine from which all
			other procedures in the package will be called. It
			will be called to retrieve all setup terms at the
			specified terms definition level or at the lowest
			terms definition level if not specified. It sorts
			out exceptions and branches different cases based
			on the input parameters to determine which other
			procedures within the package to call

  PARAMETERS:		x_ship_from_org_id 		IN NUMBER
			x_customer_id 			IN NUMBER
			x_ship_to_address_id 		IN NUMBER
			x_customer_item_id 		IN NUMBER
			x_terms_definition_level 	IN OUT NOCOPY VARCHAR2
			x_terms_rec 			OUT NOCOPY setup_terms_rec_typ
			x_return_message                OUT NOCOPY VARCHAR2
			x_return_status 		OUT NOCOPY BOOLEAN

  Valid input values for x_terms_definition_level: 	'CUSTOMER',
							'ADDRESS',
							'CUSTOMER_ITEM'
 ============================================================================*/

  PROCEDURE get_setup_terms (
		x_ship_from_org_id	 	IN NUMBER,
		x_customer_id	 		IN NUMBER,
		x_ship_to_address_id 		IN NUMBER,
		x_customer_item_id	 	IN NUMBER,
		x_terms_definition_level	IN OUT NOCOPY VARCHAR2,
		x_terms_rec			OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message                OUT NOCOPY VARCHAR2,
		x_return_status 		OUT NOCOPY BOOLEAN);

--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:	populate_record_cust

  DESCRIPTION:		This procedure is called by get_setup_terms
			cover procedure or possibly populate_record_add
			procedure to populate the x_rla_setup_terms_rec
			record with the CUSTOMER level terms.
			Ship_to_address_id and customer_item_id information
			are  not needed by this procedure.

  PARAMETERS:		x_ship_from_org_id 		IN NUMBER
			x_customer_id 			IN NUMBER
			x_terms_definition_level 	IN OUT NOCOPY NUMBER
			x_terms_rec 			OUT NOCOPY setup_terms_rec_typ
                        x_return_message                IN OUT NOCOPY VARCHAR2,
			x_return_status 		OUT NOCOPY BOOLEAN
 ============================================================================*/

 PROCEDURE populate_record_cust (
		x_ship_from_org_id 		IN NUMBER,
		x_customer_id 			IN NUMBER,
		x_terms_definition_level 	IN OUT NOCOPY VARCHAR2,
		x_terms_rec 			OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message                IN OUT NOCOPY VARCHAR2,
		x_return_status 		OUT NOCOPY BOOLEAN);

--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:	populate_record_add

  DESCRIPTION:		This procedure is called by get_setup_terms
			cover procedure and possibly populate_record_item
			procedure to populate the x_rla_setup_terms_rec
			record with the ADDRESS level terms.
			Customer_item_id information is not needed by this
			procedure.

  PARAMETERS:		x_ship_from_org_id 		IN NUMBER
			x_customer_id 			IN NUMBER
			x_ship_to_address_id		IN NUMBER
			x_terms_definition_level 	IN OUT NOCOPY NUMBER
			x_terms_rec 			OUT NOCOPY setup_terms_rec_typ
                        x_return_message                IN OUT NOCOPY VARCHAR2,
			x_return_status 		OUT NOCOPY BOOLEAN
 ============================================================================*/

  PROCEDURE populate_record_add (
		x_ship_from_org_id 			IN NUMBER,
		x_customer_id 				IN NUMBER,
		x_ship_to_address_id 			IN NUMBER,
		x_customer_item_id			IN NUMBER,
		x_terms_definition_level 		IN OUT NOCOPY VARCHAR2,
		x_terms_rec 				OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message                        IN OUT NOCOPY VARCHAR2,
		x_return_status 			OUT NOCOPY BOOLEAN);

--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:	populate_record_item

  DESCRIPTION:		This procedure is called by get_setup_terms
			cover procedure to populate the x_rla_setup_terms_rec
			record with the ADDRESS ITEM level terms.

  PARAMETERS:		x_ship_from_org_id 		IN NUMBER
			x_customer_id 			IN NUMBER
			x_ship_to_address_id		IN NUMBER
			x_customer_item_id		IN NUMBER
			x_terms_definition_level 	IN OUT NOCOPY NUMBER
			x_terms_rec 			OUT NOCOPY setup_terms_rec_typ
                        x_return_message                IN OUT NOCOPY VARCHAR2,
			x_return_status 		OUT NOCOPY BOOLEAN
 ============================================================================*/

  PROCEDURE populate_record_item (
		x_ship_from_org_id 		IN NUMBER,
		x_customer_id 			IN NUMBER,
		x_ship_to_address_id 		IN NUMBER,
		x_customer_item_id 		IN NUMBER,
		x_terms_definition_level 	IN OUT NOCOPY VARCHAR2,
		x_terms_rec 			OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message                IN OUT NOCOPY VARCHAR2,
		x_return_status 		OUT NOCOPY BOOLEAN);


--<TPA_PUBLIC_NAME>

/*=============================================================================
  PROCEDURE NAME:	populate_record_cust_item

  DESCRIPTION:		This procedure is called by get_setup_terms
			cover procedure to populate the x_rla_setup_terms_rec
			record with the CUSTOMER ITEM level terms.

  PARAMETERS:		x_ship_from_org_id 		IN NUMBER
			x_customer_id 			IN NUMBER
			x_ship_to_address_id		IN NUMBER
			x_customer_item_id		IN NUMBER
			x_terms_definition_level 	IN OUT NOCOPY NUMBER
			x_terms_rec 			OUT NOCOPY setup_terms_rec_typ
                        x_return_message                IN OUT NOCOPY VARCHAR2,
			x_return_status 		OUT NOCOPY BOOLEAN
 ============================================================================*/

  PROCEDURE populate_record_cust_item (
		x_ship_from_org_id 		IN NUMBER,
		x_customer_id 			IN NUMBER,
		x_ship_to_address_id 		IN NUMBER,
		x_customer_item_id 		IN NUMBER,
		x_terms_definition_level 	IN OUT NOCOPY VARCHAR2,
		x_terms_rec 			OUT NOCOPY rlm_setup_terms_sv.setup_terms_rec_typ,
                x_return_message                IN OUT NOCOPY VARCHAR2,
		x_return_status 		OUT NOCOPY BOOLEAN);

--<TPA_PUBLIC_NAME>


/*=============================================================================
  PROCEDURE NAME:	GetTPContext

  DESCRIPTION:		This procedure returns the tpcontext

  PARAMETERS:		x_customer_id	 		IN NUMBER DEFAULT NULL
		        x_ship_to_address_id 		IN NUMBER DEFAULT NULL
                       	x_customer_number 		OUT NOCOPY VARCHAR2
                       	x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2
                       	x_tp_group_code 		OUT NOCOPY VARCHAR2

 ============================================================================*/
  PROCEDURE GetTPContext(x_customer_id	 		IN NUMBER DEFAULT NULL,
		         x_ship_to_address_id 		IN NUMBER DEFAULT NULL,
                       	 x_customer_number 		OUT NOCOPY VARCHAR2,
                       	 x_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	 x_bill_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	 x_inter_ship_to_ece_locn_code 	OUT NOCOPY VARCHAR2,
                       	 x_tp_group_code 		OUT NOCOPY VARCHAR2);
--<TPA_TPS>


END RLM_SETUP_TERMS_SV;
 

/
