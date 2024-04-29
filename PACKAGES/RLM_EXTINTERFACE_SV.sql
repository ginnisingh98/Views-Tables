--------------------------------------------------------
--  DDL for Package RLM_EXTINTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_EXTINTERFACE_SV" AUTHID CURRENT_USER as
/*$Header: RLMEINTS.pls 120.2.12010000.1 2008/07/21 09:44:39 appldev ship $*/
--<TPA_PUBLIC_NAME=RLM_TPA_SV>
--<TPA_PUBLIC_FILE_NAME=RLMTPDP>
/*==========================================================================*/

  k_TDEBUG              NUMBER := rlm_core_sv.C_LEVEL10;
  k_SDEBUG              NUMBER := rlm_core_sv.C_LEVEL11;
  k_DEBUG               NUMBER := rlm_core_sv.C_LEVEL12;
  --
  k_PLANNING            CONSTANT VARCHAR2(30) := 'PLANNING_RELEASE';
  k_SHIPPING            CONSTANT VARCHAR2(30) := 'SHIPPING';
  k_SEQUENCED           CONSTANT VARCHAR2(30) := 'SEQUENCED';
  --
  -- Currently OE requires us to provide 5 in the automotive orders for doc type
  --
  k_OE_DOCUMENT_TYPE    NUMBER := 5;
  k_VNULL	  CONSTANT VARCHAR2(25) := 'THIS_IS_A_NULL_VALUE';
  k_NNULL     CONSTANT NUMBER       := -19999999999;--Bugfix 5911991
  --

  g_oe_header_rec                 oe_order_pub.header_rec_type;
  g_oe_header_val_rec             oe_order_pub.header_val_rec_type;
  g_oe_header_adj_tbl             oe_order_pub.header_adj_tbl_type;
  g_oe_header_adj_val_tbl         oe_order_pub.header_adj_val_tbl_type;
  g_oe_header_scredit_tbl         oe_order_pub.header_scredit_tbl_type;
  g_oe_header_scredit_val_tbl     oe_order_pub.header_scredit_val_tbl_type;
  -- Remove initialization of g_oe_line_tbl (bug# 1298267)
  g_oe_line_tbl                   oe_order_pub.line_tbl_type;
  g_oe_line_val_tbl               oe_order_pub.line_val_tbl_type;
  g_oe_header_out_rec             oe_order_pub.header_rec_type;
  g_oe_header_val_out_rec         oe_order_pub.header_val_rec_type;
  g_oe_header_adj_out_tbl         oe_order_pub.header_adj_tbl_type;
  g_oe_header_adj_val_out_tbl     oe_order_pub.header_adj_val_tbl_type;
  g_oe_Header_price_Att_out_tbl   oe_order_pub.Header_Price_Att_Tbl_Type;
  g_oe_Header_Adj_Att_out_tbl     oe_order_pub.Header_Adj_Att_Tbl_Type;
  g_oe_Header_Adj_Assoc_out_tbl   oe_order_pub.Header_Adj_Assoc_Tbl_Type;
  g_oe_header_scredit_out_tbl     oe_order_pub.header_scredit_tbl_type;
  g_oe_hdr_scdt_val_out_tbl       oe_order_pub.header_scredit_val_tbl_type;
  g_oe_line_out_tbl               oe_order_pub.line_tbl_type;
  g_oe_line_val_out_tbl           oe_order_pub.line_val_tbl_type;
  g_oe_line_adj_out_tbl           oe_order_pub.line_adj_tbl_type;
  g_oe_line_adj_val_out_tbl       oe_order_pub.line_adj_val_tbl_type;
  g_oe_Line_price_Att_out_tbl     OE_Order_PUB.Line_Price_Att_Tbl_Type;
  g_oe_Line_Adj_Att_out_tbl       OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  g_oe_Line_Adj_Assoc_out_tbl     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  g_oe_line_scredit_out_tbl       oe_order_pub.line_scredit_tbl_type;
  g_oe_line_scredit_val_out_tbl   oe_order_pub.line_scredit_val_tbl_type;
  g_oe_lot_serial_out_tbl         oe_order_pub.Lot_Serial_Tbl_Type;
  g_oe_lot_serial_val_out_tbl     oe_order_pub.Lot_Serial_Val_Tbl_Type;
  g_oe_action_request_out_tbl     oe_order_pub.request_tbl_type;
  g_total_time                    NUMBER:=0;
  g_total_lines                   NUMBER:=0;

/*===========================================================================
  FUNCTION/PROCEDURE NAME:BuildOELineTab

  DESCRIPTION: Builds the line_tab.

  PARAMETERS: x_req_tab IN OUT NOCOPY T_INT_TAB

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created Mnandell 05/27/99
/*==========================================================================*/

PROCEDURE BuildOELineTab(x_Op_tab IN rlm_rd_sv.t_generic_tab, x_return_status OUT NOCOPY VARCHAR2);

/*===========================================================================
  FUNCTION/PROCEDURE NAME:ProcessOperation

  DESCRIPTION: Builds the line_tab and Calls processorder api.

  PARAMETERS: x_return_status IN OUT NOCOPY T_INT_TAB

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created Mnandell 05/27/99
===========================================================================*/

PROCEDURE ProcessOperation(x_Op_tab IN rlm_rd_sv.t_generic_tab,x_header_id IN NUMBER, x_return_status IN OUT NOCOPY VARCHAR2);

/*===========================================================================

  FUNCTION/PROCEDURE NAME:  InsertOMMessages

  DESCRIPTION: Inserts the OM mesages into the exceptions table.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created Mnandell 05/08/02

===========================================================================*/

PROCEDURE InsertOMMessages(x_header_id IN NUMBER,
                           x_customer_item_id IN NUMBER,
                           x_msg_count  IN NUMBER,
                           x_msg_level  IN VARCHAR2,
                           x_token IN VARCHAR2,
                           x_msg_name IN VARCHAR2);

/*===========================================================================
  FUNCTION/PROCEDURE NAME:BuildOELine

  DESCRIPTION: Builds the oe_line_rec.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created Mnandell 05/27/99
                                tp-enabling jckwok 12/11/03
===========================================================================*/
PROCEDURE BuildOELine(x_oe_line_rec IN OUT NOCOPY oe_order_pub.line_rec_type,
                      x_Op_rec IN rlm_rd_sv.t_generic_rec);
--<TPA_PUBLIC_NAME>
/*===========================================================================
  FUNCTION/PROCEDURE NAME:CallProcessConstraintAPI

  DESCRIPTION: Calls processConstraints api.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created Mnandell 05/27/99
===========================================================================*/
FUNCTION CallProcessConstraintAPI(x_Key_rec IN rlm_rd_sv.t_Key_rec,
                           x_Qty_rec OUT NOCOPY rlm_rd_sv.t_Qty_rec,
                           x_Operation IN VARCHAR2,
                           x_OperationQty IN NUMBER := 0)
RETURN BOOLEAN;

FUNCTION SubmitDemandProcessor(p_schedule_purpose_code VARCHAR2 DEFAULT NULL,
                            p_from_date   DATE DEFAULT NULL,
                            p_to_date   DATE DEFAULT NULL,
                            p_from_customer_ext   VARCHAR2 DEFAULT NULL,
                            p_to_customer_ext   VARCHAR2 DEFAULT NULL,
                            p_from_ship_to_ext   VARCHAR2 DEFAULT NULL,
                            p_to_ship_to_ext   VARCHAR2 DEFAULT NULL,
			    p_run_edi_loader   BOOLEAN DEFAULT FALSE)
return NUMBER;

PROCEDURE GetIntransitQty (x_CustomerId 	In NUMBER,
                           x_ShipToId   	In NUMBER,
                           x_intmed_ship_to_org_id In NUMBER,--Bugfix 5911991
                           x_ShipFromOrgId   	In NUMBER,
                           x_InventoryItemId   	In NUMBER,
			   x_CustomerItemId     In NUMBER,
                           x_OrderHeaderId    	In NUMBER,
			   x_BlanketNumber	In NUMBER,
                           x_OrgId              In NUMBER,
			   x_SchedType	      	In VARCHAR2,
                           x_ShipperRecs    	In WSH_RLM_INTERFACE.t_shipper_rec,
		           x_ShipmentDate   	In DATE,
  			   x_MatchWithin        In RLM_CORE_SV.T_MATCH_REC,
		           x_MatchAcross	In RLM_CORE_SV.T_MATCH_REC,
			   x_Match_Rec      	IN WSH_RLM_INTERFACE.t_optional_match_rec,
                           x_header_id       	IN NUMBER,
                           x_InTransitQty    	OUT NOCOPY NUMBER,
                           x_return_status 	OUT NOCOPY VARCHAR2);

/*===========================================================================
  FUNCTION/PROCEDURE NAME: CheckShippingConstraints

  DESCRIPTION: Call Shipping API to check if a particular order line
               can be cancelled

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created JAUTOMO 11/08/01
===========================================================================*/

PROCEDURE CheckShippingConstraints (
                   x_source_code            IN     VARCHAR2,
                   x_changed_attributes     IN     WSH_SHIPPING_CONSTRAINTS_PKG.ChangedAttributeRecType,
                   x_return_status          OUT NOCOPY    VARCHAR2,
                   x_action_allowed         OUT NOCOPY    VARCHAR2,
                   x_action_message         OUT NOCOPY    VARCHAR2,
                   x_ord_qty_allowed        OUT NOCOPY    NUMBER,
                   x_log_level              IN     NUMBER  DEFAULT 0,
                   x_header_id              IN     NUMBER,
                   x_order_header_id        IN     NUMBER);

/*===========================================================================
  FUNCTION/PROCEDURE NAME: GetLineStatus

  DESCRIPTION: Return the status of an Order Line.

  PARAMETERS: x_ScheduleLineId, x_OrderLineId

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created Mnandell 05/27/99
===========================================================================*/
FUNCTION GetLineStatus(x_ScheduleLineId  In NUMBER, x_OrderLineId  In NUMBER)
RETURN VARCHAR2;

/*===========================================================================
  FUNCTION/PROCEDURE NAME: GetLocation

  DESCRIPTION: Return the Location of an Org Id.

  PARAMETERS: x_OrgId

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES: The x_OrgId value can be Ship_To_Org_Id / Intrmd_Ship_To_Org_Id.
         The Location is column from HZ_CUST_SITE_USES.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created ppeddama 10/12/99
===========================================================================*/
FUNCTION GetLocation(x_OrgId  In NUMBER)
RETURN VARCHAR2;

/*===========================================================================
  FUNCTION/PROCEDURE NAME: GetAddress1

  DESCRIPTION: Return the Address1 Line for an Org Id.

  PARAMETERS: x_OrgId

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES: The x_OrgId value can be Ship_To_Org_Id / Intrmd_Ship_To_Org_Id.
         The Address1 is column from HZ_LOCATIONS.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created ppeddama 10/12/99
===========================================================================*/
FUNCTION GetAddress1(x_OrgId  In NUMBER)
RETURN VARCHAR2;

/*===========================================================================
  FUNCTION/PROCEDURE NAME: BuildTPOELine

  DESCRIPTION:      Copies Tp_attributes from x_op_rec into x_oe_line_rec.

  PARAMETERS:       x_oe_line_rec  IN OUT NOCOPY oe_order_pub.line_rec_type
                    x_Op_rec      IN rlm_rd_sv.t_generic_rec

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created mnandell 01/20/2000
===========================================================================*/
PROCEDURE BuildTPOELine(x_oe_line_rec IN OUT NOCOPY oe_order_pub.line_rec_type,
                        x_Op_rec      IN rlm_rd_sv.t_generic_rec);
--<TPA_PUBLIC_NAME>

/*===========================================================================
  FUNCTION/PROCEDURE NAME: BuildTPOELine

  DESCRIPTION:      Copies Tp_attributes from x_op_rec into x_oe_line_rec.

  PARAMETERS:       x_oe_line_rec  IN OUT oe_order_pub.line_rec_type
                    x_Op_rec      IN rlm_rd_sv.t_generic_rec

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created mnandell 01/20/2000
===========================================================================*/
PROCEDURE GetTpContext(x_Op_rec          IN rlm_rd_sv.t_generic_rec,
                       x_customer_number OUT NOCOPY VARCHAR2,
                       x_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_bill_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_inter_ship_to_ece_locn_code OUT NOCOPY VARCHAR2,
                       x_tp_group_code OUT NOCOPY VARCHAR2);
--<TPA_TPS>

/*===========================================================================
  PROCEDURE NAME: GetIntransitShippedLines

  DESCRIPTION:      Calculates Intransit Qty based on Shipped Lines

  PARAMETERS:       x_Sched_rec          IN     RLM_INTERFACE_HEADERS%ROWTYPE,
                    x_Group_rec          IN     rlm_dp_sv.t_Group_rec,
                    x_optional_match_rec IN  WSH_RLM_INTERFACE.t_optional_match_rec,
                    x_min_horizon_date   IN VARCHAR2,
                    x_intransit_qty      IN OUT NOCOPY NUMBERx_

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:               created asutar 07/10/2000
===========================================================================*/

PROCEDURE GetIntransitShippedLines (x_Sched_rec          IN     RLM_INTERFACE_HEADERS%ROWTYPE,
                                    x_Group_rec          IN     rlm_dp_sv.t_Group_rec,
				    x_optional_match_rec IN      RLM_RD_SV.t_generic_rec,
                                    x_min_horizon_date   IN VARCHAR2,
                                    x_intransit_qty      IN OUT NOCOPY NUMBER);


END RLM_EXTINTERFACE_SV;

/
