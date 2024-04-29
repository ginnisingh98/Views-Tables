--------------------------------------------------------
--  DDL for Package OE_INBOUND_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INBOUND_INT" AUTHID CURRENT_USER AS
/* $Header: OEXOEINS.pls 120.1.12010000.5 2009/08/10 07:31:54 snimmaga ship $ */
/*#
* This API allows clients to perform various operations on sales orders.
* @rep:product ONT
* @rep:scope public
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY ONT_SALES_ORDER
* @rep:displayname Sales Order Services
*/
  --
  -- Global check
  --
  G_check_action_ret_status VARCHAR2(10) := 'S';

  --
  --  Functions that convert traditional PL/SQL complex types
  --  (Record, Table, etc.,) to PL/SQL object types (these are the ones
  --   understood by the web service adapter); and vice-versa.
  --
	FUNCTION PL_TO_SQL1(aPlsqlItem OE_ORDER_PUB.HEADER_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_REC_TYPE;

	FUNCTION SQL_TO_PL1(aSqlItem OE_ORDER_PUB_HEADER_REC_TYPE)
	RETURN OE_ORDER_PUB.HEADER_REC_TYPE;

	FUNCTION PL_TO_SQL2(aPlsqlItem OE_ORDER_PUB.HEADER_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_VAL_REC_T;

	FUNCTION SQL_TO_PL2(aSqlItem OE_ORDER_PUB_HEADER_VAL_REC_T)
	RETURN OE_ORDER_PUB.HEADER_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL26(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_REC_T;

	FUNCTION SQL_TO_PL26(aSqlItem OE_ORDER_PUB_HEADER_ADJ_REC_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_REC_TYPE;

	FUNCTION PL_TO_SQL3(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_TBL_T;

	FUNCTION SQL_TO_PL3(aSqlItem OE_ORDER_PUB_HEADER_ADJ_TBL_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE;

	FUNCTION PL_TO_SQL27(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_VAL_R;

	FUNCTION SQL_TO_PL27(aSqlItem OE_ORDER_PUB_HEADER_ADJ_VAL_R)
	RETURN OE_ORDER_PUB.HEADER_ADJ_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL4(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_VAL_T;

	FUNCTION SQL_TO_PL4(aSqlItem OE_ORDER_PUB_HEADER_ADJ_VAL_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL28(aPlsqlItem OE_ORDER_PUB.HEADER_PRICE_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PRICE_AT6;

	FUNCTION SQL_TO_PL28(aSqlItem OE_ORDER_PUB_HEADER_PRICE_AT6)
	RETURN OE_ORDER_PUB.HEADER_PRICE_ATT_REC_TYPE;

	FUNCTION PL_TO_SQL5(aPlsqlItem OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PRICE_ATT;

	FUNCTION SQL_TO_PL5(aSqlItem OE_ORDER_PUB_HEADER_PRICE_ATT)
	RETURN OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE;

	FUNCTION PL_TO_SQL29(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ATT_R;

	FUNCTION SQL_TO_PL29(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ATT_R)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ATT_REC_TYPE;

	FUNCTION PL_TO_SQL6(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ATT_T;

	FUNCTION SQL_TO_PL6(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ATT_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE;

	FUNCTION PL_TO_SQL30(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ASSOC_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ASSO6;

	FUNCTION SQL_TO_PL30(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ASSO6)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ASSOC_REC_TYPE;

	FUNCTION PL_TO_SQL7(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ASSOC;

	FUNCTION SQL_TO_PL7(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ASSOC)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE;

	FUNCTION PL_TO_SQL31(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT_R;

	FUNCTION SQL_TO_PL31(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_R)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE;

	FUNCTION PL_TO_SQL8(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT_T;

	FUNCTION SQL_TO_PL8(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_T)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE;

	FUNCTION PL_TO_SQL32(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT11;

	FUNCTION SQL_TO_PL32(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT11)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL9(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT_V;

	FUNCTION SQL_TO_PL9(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_V)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL33(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_R;

	FUNCTION SQL_TO_PL33(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_R)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_REC_TYPE;

	FUNCTION PL_TO_SQL10(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_T;

	FUNCTION SQL_TO_PL10(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_T)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE;

	FUNCTION PL_TO_SQL34(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_5;

	FUNCTION SQL_TO_PL34(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_5)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL11(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_V;

	FUNCTION SQL_TO_PL11(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_V)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL35(aPlsqlItem OE_ORDER_PUB.LINE_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_REC_TYPE;

	FUNCTION SQL_TO_PL35(aSqlItem OE_ORDER_PUB_LINE_REC_TYPE)
	RETURN OE_ORDER_PUB.LINE_REC_TYPE;

	FUNCTION PL_TO_SQL12(aPlsqlItem OE_ORDER_PUB.LINE_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_TBL_TYPE;

	FUNCTION SQL_TO_PL12(aSqlItem OE_ORDER_PUB_LINE_TBL_TYPE)
	RETURN OE_ORDER_PUB.LINE_TBL_TYPE;

	FUNCTION PL_TO_SQL36(aPlsqlItem OE_ORDER_PUB.LINE_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_VAL_REC_TYP;

	FUNCTION SQL_TO_PL36(aSqlItem OE_ORDER_PUB_LINE_VAL_REC_TYP)
	RETURN OE_ORDER_PUB.LINE_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL13(aPlsqlItem OE_ORDER_PUB.LINE_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_VAL_TBL_TYP;

	FUNCTION SQL_TO_PL13(aSqlItem OE_ORDER_PUB_LINE_VAL_TBL_TYP)
	RETURN OE_ORDER_PUB.LINE_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL37(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_REC_TYP;

	FUNCTION SQL_TO_PL37(aSqlItem OE_ORDER_PUB_LINE_ADJ_REC_TYP)
	RETURN OE_ORDER_PUB.LINE_ADJ_REC_TYPE;

	FUNCTION PL_TO_SQL14(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_TBL_TYP;

	FUNCTION SQL_TO_PL14(aSqlItem OE_ORDER_PUB_LINE_ADJ_TBL_TYP)
	RETURN OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;

	FUNCTION PL_TO_SQL38(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_VAL_REC;

	FUNCTION SQL_TO_PL38(aSqlItem OE_ORDER_PUB_LINE_ADJ_VAL_REC)
	RETURN OE_ORDER_PUB.LINE_ADJ_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL15(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_VAL_TBL;

	FUNCTION SQL_TO_PL15(aSqlItem OE_ORDER_PUB_LINE_ADJ_VAL_TBL)
	RETURN OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL39(aPlsqlItem OE_ORDER_PUB.LINE_PRICE_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PRICE_ATT_R;

	FUNCTION SQL_TO_PL39(aSqlItem OE_ORDER_PUB_LINE_PRICE_ATT_R)
	RETURN OE_ORDER_PUB.LINE_PRICE_ATT_REC_TYPE;

	FUNCTION PL_TO_SQL16(aPlsqlItem OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PRICE_ATT_T;

	FUNCTION SQL_TO_PL16(aSqlItem OE_ORDER_PUB_LINE_PRICE_ATT_T)
	RETURN OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE;

	FUNCTION PL_TO_SQL40(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ATT_REC;

	FUNCTION SQL_TO_PL40(aSqlItem OE_ORDER_PUB_LINE_ADJ_ATT_REC)
	RETURN OE_ORDER_PUB.LINE_ADJ_ATT_REC_TYPE;

	FUNCTION PL_TO_SQL17(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ATT_TBL;

	FUNCTION SQL_TO_PL17(aSqlItem OE_ORDER_PUB_LINE_ADJ_ATT_TBL)
	RETURN OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE;

	FUNCTION PL_TO_SQL41(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ASSOC_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ASSOC_R;

	FUNCTION SQL_TO_PL41(aSqlItem OE_ORDER_PUB_LINE_ADJ_ASSOC_R)
	RETURN OE_ORDER_PUB.LINE_ADJ_ASSOC_REC_TYPE;

	FUNCTION PL_TO_SQL18(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ASSOC_T;

	FUNCTION SQL_TO_PL18(aSqlItem OE_ORDER_PUB_LINE_ADJ_ASSOC_T)
	RETURN OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE;

	FUNCTION PL_TO_SQL42(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_REC;

	FUNCTION SQL_TO_PL42(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_REC)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE;

	FUNCTION PL_TO_SQL19(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_TBL;

	FUNCTION SQL_TO_PL19(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_TBL)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE;

	FUNCTION PL_TO_SQL43(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_VA6;

	FUNCTION SQL_TO_PL43(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_VA6)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL20(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_VAL;

	FUNCTION SQL_TO_PL20(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_VAL)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL44(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_REC;

	FUNCTION SQL_TO_PL44(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_REC)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_REC_TYPE;

	FUNCTION PL_TO_SQL21(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_TBL;

	FUNCTION SQL_TO_PL21(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_TBL)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE;

	FUNCTION PL_TO_SQL45(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_VA3;

	FUNCTION SQL_TO_PL45(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_VA3)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL22(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_VAL;

	FUNCTION SQL_TO_PL22(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_VAL)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL46(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_REC_T;

	FUNCTION SQL_TO_PL46(aSqlItem OE_ORDER_PUB_LOT_SERIAL_REC_T)
	RETURN OE_ORDER_PUB.LOT_SERIAL_REC_TYPE;

	FUNCTION PL_TO_SQL23(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_TBL_T;

	FUNCTION SQL_TO_PL23(aSqlItem OE_ORDER_PUB_LOT_SERIAL_TBL_T)
	RETURN OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;

	FUNCTION PL_TO_SQL47(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_VAL_R;

	FUNCTION SQL_TO_PL47(aSqlItem OE_ORDER_PUB_LOT_SERIAL_VAL_R)
	RETURN OE_ORDER_PUB.LOT_SERIAL_VAL_REC_TYPE;

	FUNCTION PL_TO_SQL24(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_VAL_T;

	FUNCTION SQL_TO_PL24(aSqlItem OE_ORDER_PUB_LOT_SERIAL_VAL_T)
	RETURN OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE;

	FUNCTION PL_TO_SQL48(aPlsqlItem OE_ORDER_PUB.REQUEST_REC_TYPE)
 	RETURN OE_ORDER_PUB_REQUEST_REC_TYPE;

	FUNCTION SQL_TO_PL48(aSqlItem OE_ORDER_PUB_REQUEST_REC_TYPE)
	RETURN OE_ORDER_PUB.REQUEST_REC_TYPE;

	FUNCTION PL_TO_SQL25(aPlsqlItem OE_ORDER_PUB.REQUEST_TBL_TYPE)
 	RETURN OE_ORDER_PUB_REQUEST_TBL_TYPE;

	FUNCTION SQL_TO_PL25(aSqlItem OE_ORDER_PUB_REQUEST_TBL_TYPE)
	RETURN OE_ORDER_PUB.REQUEST_TBL_TYPE;

  --
  --  Utility procedures
  --
  PROCEDURE Convert_Line_null_to_miss(p_x_line_rec   IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type);
  PROCEDURE Convert_hdr_null_to_miss (p_x_header_rec IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type);

  --
  --  Webservice Adapter wrapper for Oe_Order_Pub.Process_Order(...) API
  --  with the newer signature.
  --
/*#
* Use this procedure to build Oracle Applications Adapter based web services that
* create, update or delete Sales Orders in the Order Management system.  In addition to
* allowing direct changes to the sales order, this API supports the application of header
* and line level price adjustments, pricing attributes, sales credits, and payments.
* Lot and Serial number information are supported for return lines.  This API also
* supports action requests that allow users to execute a variety of actions such as
* booking, hold application and removal, automatic attachments, fullfillment set
* application and removal, match and reserve for Configured items, get ship method
* and freight rates (both individually and together), and the linking and delinking
* of Configured items.
*   @param P_API_VERSION_NUMBER API version used to check call compatibility
*   @param P_INIT_MSG_LIST Parameter that determines whether internal message tables should be initialized
*   @param P_RETURN_VALUES Parameter determines whether ids should be converted to values for population in the output value parameters
*   @param P_ACTION_COMMIT Not used
*   @param X_RETURN_STATUS Return status of API call
*   @param X_MESSAGES Output table containing processing messages generated in the current call of API
*   @param P_HEADER_REC Input record structure containing current header-level ID information for an order
*   @param P_OLD_HEADER_REC Input record structure containing old header-level ID information for an order
*   @param P_HEADER_VAL_REC Input record structure containing current header-level value information for an order
*   @param P_OLD_HEADER_VAL_REC Input record structure containing old header-level value information for an order
*   @param P_HEADER_ADJ_TBL Input table containing current header-level ID information for price adjustments
*   @param P_OLD_HEADER_ADJ_TBL Input table containing old header-level ID information for price adjustments
*   @param P_HEADER_ADJ_VAL_TBL Input table containing current header-level value information for price adjustments
*   @param P_OLD_HEADER_ADJ_VAL_TBL Input table containing old header-level value information for price adjustments
*   @param P_HEADER_PRICE_ATT_TBL Input table containing current header-level information for pricing attributes
*   @param p_old_Header_Price_Att_tbl Input table containing old header-level information for pricing attributes
*   @param p_Header_Adj_Att_tbl Input table containing current header-level adjustment attributes
*   @param p_old_Header_Adj_Att_tbl Input table containing old header-level adjustment attributes
*   @param p_Header_Adj_Assoc_tbl Input table containing current information about relationships between header-level adjustments
*   @param p_old_Header_Adj_Assoc_tbl Input table containing old information about relationships between header-level adjustments
*   @param p_Header_Scredit_tbl Input table containing current header-level ID information for sales credits
*   @param p_old_Header_Scredit_tbl Input table containing old header-level ID information for sales credits
*   @param p_Header_Scredit_val_tbl Input table containing current header-level value information for sales credits
*   @param p_old_Header_Scredit_val_tbl Input table containing old header-level value information for sales credits
*   @param p_Header_Payment_tbl Input table containing current header-level ID information for payments
*   @param p_old_Header_Payment_tbl Input table containing old header-level ID information for payments
*   @param p_Header_Payment_val_tbl Input table containing current header-level value information for payments
*   @param p_old_Header_Payment_val_tbl Input table containing old header-level value information for payments
*   @param p_line_tbl Input table containing current line-level ID information for an order
*   @param p_old_line_tbl Input table containing old line-level ID information for an order
*   @param p_line_val_tbl Input table containing current line-level value information for an order
*   @param p_old_line_val_tbl Input table containing old line-level value information for an order
*   @param p_Line_Adj_tbl Input table containing current line-level ID information for price adjustments
*   @param p_old_Line_Adj_tbl Input table containing old line-level ID information for price adjustments
*   @param p_Line_Adj_val_tbl Input table containing current line-level value information for price adjustments
*   @param p_old_Line_Adj_val_tbl Input table containing old line-level value information for price adjustments
*   @param p_Line_price_Att_tbl Input table containing current line-level information for pricing attributes
*   @param p_old_Line_Price_Att_tbl Input table containing old line-level information for pricing attributes
*   @param p_Line_Adj_Att_tbl Input table containing current line-level adjustment attributes
*   @param p_old_Line_Adj_Att_tbl Input table containing old line-level adjustment attributes
*   @param p_Line_Adj_Assoc_tbl Input table containing current information about relationships between line-level adjustments
*   @param p_old_Line_Adj_Assoc_tbl Input table containing old information about relationships between line-level adjustments
*   @param p_Line_Scredit_tbl Input table containing current line-level ID information for sales credits
*   @param p_old_Line_Scredit_tbl Input table containing old line-level ID information for sales credits
*   @param p_Line_Scredit_val_tbl Input table containing current line-level value information for sales credits
*   @param p_old_Line_Scredit_val_tbl Input table containing old line-level value information for sales credits
*   @param p_Line_Payment_tbl Input table containing current line-level ID information for payments
*   @param p_old_Line_Payment_tbl Input table containing old line-level ID information for payments
*   @param p_Line_Payment_val_tbl Input table containing current line-level value information for payments
*   @param p_old_Line_Payment_val_tbl Input table containing current line-level value information for payments
*   @param p_Lot_Serial_tbl Input table containing current ID information for lot and serial numbers
*   @param p_old_Lot_Serial_tbl Input table containing old ID information for lot and serial numbers
*   @param p_Lot_Serial_val_tbl Input table containing current value information for lot and serial numbers
*   @param p_old_Lot_Serial_val_tbl Input table containing old value information for lot and serial numbers
*   @param p_action_request_tbl Input table containing delayed requests
*   @param x_header_rec Output record structure containing current header-level ID information for an order
*   @param x_header_val_rec Output record structure containing current header-level value information for an order (if p_return_values was passed as true)
*   @param x_Header_Adj_tbl Output table containing current header-level ID information for price adjustments
*   @param x_Header_Adj_val_tbl Output table containing current header-level value information for price adjustments (if p_return_values was passed as true)
*   @param x_Header_price_Att_tbl Output table containing current header-level information for pricing attributes
*   @param x_Header_Adj_Att_tbl Output table containing current header-level adjustment attributes
*   @param x_Header_Adj_Assoc_tbl Output table containing current information about relationships between header-level adjustments
*   @param x_Header_Scredit_tbl Output table containing current header-level ID information for sales credits
*   @param x_Header_Scredit_val_tbl Output table containing current header-level value information for sales credits (if p_return_values was passed as true)
*   @param x_Header_Payment_tbl Output table containing current header-level ID information for payments
*   @param x_Header_Payment_val_tbl Output table containing current header-level value information for payments (if p_return_values was passed as true)
*   @param x_line_tbl Output table containing current line-level ID information for an order
*   @param x_line_val_tbl Output table containing current line-level value information for an order (if p_return_values was passed as true)
*   @param x_Line_Adj_tbl Output table containing current line-level ID information for price adjustments
*   @param x_Line_Adj_val_tbl Output table containing current line-level value information for price adjustments (if p_return_values was passed as true)
*   @param x_Line_price_Att_tbl Output table containing current line-level information for pricing attributes
*   @param x_Line_Adj_Att_tbl Output table containing current line-level adjustment attributes
*   @param x_Line_Adj_Assoc_tbl Output table containing current information about relationships between line-level adjustments
*   @param x_Line_Scredit_tbl Output table containing current line-level ID information for sales credits
*   @param x_Line_Scredit_val_tbl Output table containing current line-level value information for sales credits (if p_return_values was passed as true)
*   @param x_Line_Payment_tbl Output table containing current line-level ID information for payments
*   @param x_Line_Payment_val_tbl Output table containing current line-level value information for payments (if p_return_values was passed as true)
*   @param x_Lot_Serial_tbl Output table containing current ID information for lot and serial numbers
*   @param x_Lot_Serial_val_tbl Output table containing current value information for lot and serial numbers (if p_return_values was passed as true)
*   @param x_action_request_tbl Output table containing delayed requests
*   @param p_rtrim_data Parameter specifying whether to right-trim the input data
*   @rep:scope      public
*   @rep:lifecycle  active
*   @rep:category   BUSINESS_ENTITY ONT_SALES_ORDER
*   @rep:displayname    Sales Order Service
*/
  PROCEDURE Process_Order (
        P_API_VERSION_NUMBER  NUMBER,
        P_INIT_MSG_LIST       VARCHAR2,
        P_RETURN_VALUES       VARCHAR2,
        P_ACTION_COMMIT       VARCHAR2,
        X_RETURN_STATUS   OUT NOCOPY VARCHAR2 ,
        X_MESSAGES        OUT NOCOPY OE_MESSAGE_OBJ_T,
        P_HEADER_REC                OE_ORDER_PUB_HEADER_REC_TYPE,
        P_OLD_HEADER_REC            OE_ORDER_PUB_HEADER_REC_TYPE,
        P_HEADER_VAL_REC            OE_ORDER_PUB_HEADER_VAL_REC_T,
        P_OLD_HEADER_VAL_REC        OE_ORDER_PUB_HEADER_VAL_REC_T,
        P_HEADER_ADJ_TBL            OE_ORDER_PUB_HEADER_ADJ_TBL_T,
        P_OLD_HEADER_ADJ_TBL        OE_ORDER_PUB_HEADER_ADJ_TBL_T,
        P_HEADER_ADJ_VAL_TBL        OE_ORDER_PUB_HEADER_ADJ_VAL_T,
        P_OLD_HEADER_ADJ_VAL_TBL    OE_ORDER_PUB_HEADER_ADJ_VAL_T,
        P_HEADER_PRICE_ATT_TBL      OE_ORDER_PUB_HEADER_PRICE_ATT,
        P_OLD_HEADER_PRICE_ATT_TBL  OE_ORDER_PUB_HEADER_PRICE_ATT,
        P_HEADER_ADJ_ATT_TBL        OE_ORDER_PUB_HEADER_ADJ_ATT_T,
        P_OLD_HEADER_ADJ_ATT_TBL    OE_ORDER_PUB_HEADER_ADJ_ATT_T,
        P_HEADER_ADJ_ASSOC_TBL      OE_ORDER_PUB_HEADER_ADJ_ASSOC,
        P_OLD_HEADER_ADJ_ASSOC_TBL  OE_ORDER_PUB_HEADER_ADJ_ASSOC,
        P_HEADER_SCREDIT_TBL        OE_ORDER_PUB_HEADER_SCREDIT_T,
        P_OLD_HEADER_SCREDIT_TBL    OE_ORDER_PUB_HEADER_SCREDIT_T,
        P_HEADER_SCREDIT_VAL_TBL      OE_ORDER_PUB_HEADER_SCREDIT_V,
        P_OLD_HEADER_SCREDIT_VAL_TBL  OE_ORDER_PUB_HEADER_SCREDIT_V,
        P_HEADER_PAYMENT_TBL          OE_ORDER_PUB_HEADER_PAYMENT_T,
        P_OLD_HEADER_PAYMENT_TBL      OE_ORDER_PUB_HEADER_PAYMENT_T,
        P_HEADER_PAYMENT_VAL_TBL      OE_ORDER_PUB_HEADER_PAYMENT_V,
        P_OLD_HEADER_PAYMENT_VAL_TBL  OE_ORDER_PUB_HEADER_PAYMENT_V,
        P_LINE_TBL                    OE_ORDER_PUB_LINE_TBL_TYPE,
        P_OLD_LINE_TBL                OE_ORDER_PUB_LINE_TBL_TYPE,
        P_LINE_VAL_TBL                OE_ORDER_PUB_LINE_VAL_TBL_TYP,
        P_OLD_LINE_VAL_TBL            OE_ORDER_PUB_LINE_VAL_TBL_TYP,
        P_LINE_ADJ_TBL                OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
        P_OLD_LINE_ADJ_TBL            OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
        P_LINE_ADJ_VAL_TBL            OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
        P_OLD_LINE_ADJ_VAL_TBL        OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
        P_LINE_PRICE_ATT_TBL          OE_ORDER_PUB_LINE_PRICE_ATT_T,
        P_OLD_LINE_PRICE_ATT_TBL      OE_ORDER_PUB_LINE_PRICE_ATT_T,
        P_LINE_ADJ_ATT_TBL            OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
        P_OLD_LINE_ADJ_ATT_TBL        OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
        P_LINE_ADJ_ASSOC_TBL          OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
        P_OLD_LINE_ADJ_ASSOC_TBL      OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
        P_LINE_SCREDIT_TBL            OE_ORDER_PUB_LINE_SCREDIT_TBL,
        P_OLD_LINE_SCREDIT_TBL        OE_ORDER_PUB_LINE_SCREDIT_TBL,
        P_LINE_SCREDIT_VAL_TBL        OE_ORDER_PUB_LINE_SCREDIT_VAL,
        P_OLD_LINE_SCREDIT_VAL_TBL    OE_ORDER_PUB_LINE_SCREDIT_VAL,
        P_LINE_PAYMENT_TBL            OE_ORDER_PUB_LINE_PAYMENT_TBL,
        P_OLD_LINE_PAYMENT_TBL        OE_ORDER_PUB_LINE_PAYMENT_TBL,
        P_LINE_PAYMENT_VAL_TBL        OE_ORDER_PUB_LINE_PAYMENT_VAL,
        P_OLD_LINE_PAYMENT_VAL_TBL    OE_ORDER_PUB_LINE_PAYMENT_VAL,
        P_LOT_SERIAL_TBL              OE_ORDER_PUB_LOT_SERIAL_TBL_T,
        P_OLD_LOT_SERIAL_TBL          OE_ORDER_PUB_LOT_SERIAL_TBL_T,
        P_LOT_SERIAL_VAL_TBL          OE_ORDER_PUB_LOT_SERIAL_VAL_T,
        P_OLD_LOT_SERIAL_VAL_TBL      OE_ORDER_PUB_LOT_SERIAL_VAL_T,
        P_ACTION_REQUEST_TBL          OE_ORDER_PUB_REQUEST_TBL_TYPE,
        X_HEADER_REC              OUT NOCOPY     OE_ORDER_PUB_HEADER_REC_TYPE  ,
        X_HEADER_VAL_REC          OUT NOCOPY     OE_ORDER_PUB_HEADER_VAL_REC_T ,
        X_HEADER_ADJ_TBL          OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_TBL_T ,
        X_HEADER_ADJ_VAL_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_VAL_T ,
        X_HEADER_PRICE_ATT_TBL    OUT NOCOPY     OE_ORDER_PUB_HEADER_PRICE_ATT ,
        X_HEADER_ADJ_ATT_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_ATT_T ,
        X_HEADER_ADJ_ASSOC_TBL    OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_ASSOC ,
        X_HEADER_SCREDIT_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_SCREDIT_T ,
        X_HEADER_SCREDIT_VAL_TBL  OUT NOCOPY     OE_ORDER_PUB_HEADER_SCREDIT_V ,
        X_HEADER_PAYMENT_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_PAYMENT_T ,
        X_HEADER_PAYMENT_VAL_TBL  OUT NOCOPY     OE_ORDER_PUB_HEADER_PAYMENT_V ,
        X_LINE_TBL                OUT NOCOPY     OE_ORDER_PUB_LINE_TBL_TYPE    ,
        X_LINE_VAL_TBL            OUT NOCOPY     OE_ORDER_PUB_LINE_VAL_TBL_TYP ,
        X_LINE_ADJ_TBL            OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_TBL_TYP ,
        X_LINE_ADJ_VAL_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_VAL_TBL ,
        X_LINE_PRICE_ATT_TBL      OUT NOCOPY     OE_ORDER_PUB_LINE_PRICE_ATT_T ,
        X_LINE_ADJ_ATT_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_ATT_TBL ,
        X_LINE_ADJ_ASSOC_TBL      OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_ASSOC_T ,
        X_LINE_SCREDIT_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_SCREDIT_TBL ,
        X_LINE_SCREDIT_VAL_TBL    OUT NOCOPY     OE_ORDER_PUB_LINE_SCREDIT_VAL ,
        X_LINE_PAYMENT_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_PAYMENT_TBL ,
        X_LINE_PAYMENT_VAL_TBL    OUT NOCOPY     OE_ORDER_PUB_LINE_PAYMENT_VAL ,
        X_LOT_SERIAL_TBL          OUT NOCOPY     OE_ORDER_PUB_LOT_SERIAL_TBL_T ,
        X_LOT_SERIAL_VAL_TBL      OUT NOCOPY     OE_ORDER_PUB_LOT_SERIAL_VAL_T ,
        X_ACTION_REQUEST_TBL      OUT NOCOPY     OE_ORDER_PUB_REQUEST_TBL_TYPE ,
        P_RTRIM_DATA                    VARCHAR2
  );

  --
  --  Webservice Adapter wrapper for Oe_Order_Pub.Process_Order(...) API
  --  This is a deprecated signature, and retained only for backward
  --  compatibility reasons.
  --
  --  Clients should use the equivalent OE_INBOUND_INT.Process_Order(...)
  --  with the newer signature (for all practical purposes).
  --
  PROCEDURE Process_Order (
        P_API_VERSION_NUMBER  NUMBER,
        P_INIT_MSG_LIST       VARCHAR2,
        P_RETURN_VALUES       VARCHAR2,
        P_ACTION_COMMIT       VARCHAR2,
        X_RETURN_STATUS   OUT NOCOPY VARCHAR2 ,
        X_MSG_COUNT       OUT NOCOPY NUMBER,
        X_MSG_DATA        OUT NOCOPY VARCHAR2,
        P_HEADER_REC                OE_ORDER_PUB_HEADER_REC_TYPE,
        P_OLD_HEADER_REC            OE_ORDER_PUB_HEADER_REC_TYPE,
        P_HEADER_VAL_REC            OE_ORDER_PUB_HEADER_VAL_REC_T,
        P_OLD_HEADER_VAL_REC        OE_ORDER_PUB_HEADER_VAL_REC_T,
        P_HEADER_ADJ_TBL            OE_ORDER_PUB_HEADER_ADJ_TBL_T,
        P_OLD_HEADER_ADJ_TBL        OE_ORDER_PUB_HEADER_ADJ_TBL_T,
        P_HEADER_ADJ_VAL_TBL        OE_ORDER_PUB_HEADER_ADJ_VAL_T,
        P_OLD_HEADER_ADJ_VAL_TBL    OE_ORDER_PUB_HEADER_ADJ_VAL_T,
        P_HEADER_PRICE_ATT_TBL      OE_ORDER_PUB_HEADER_PRICE_ATT,
        P_OLD_HEADER_PRICE_ATT_TBL  OE_ORDER_PUB_HEADER_PRICE_ATT,
        P_HEADER_ADJ_ATT_TBL        OE_ORDER_PUB_HEADER_ADJ_ATT_T,
        P_OLD_HEADER_ADJ_ATT_TBL    OE_ORDER_PUB_HEADER_ADJ_ATT_T,
        P_HEADER_ADJ_ASSOC_TBL      OE_ORDER_PUB_HEADER_ADJ_ASSOC,
        P_OLD_HEADER_ADJ_ASSOC_TBL  OE_ORDER_PUB_HEADER_ADJ_ASSOC,
        P_HEADER_SCREDIT_TBL        OE_ORDER_PUB_HEADER_SCREDIT_T,
        P_OLD_HEADER_SCREDIT_TBL    OE_ORDER_PUB_HEADER_SCREDIT_T,
        P_HEADER_SCREDIT_VAL_TBL      OE_ORDER_PUB_HEADER_SCREDIT_V,
        P_OLD_HEADER_SCREDIT_VAL_TBL  OE_ORDER_PUB_HEADER_SCREDIT_V,
        P_HEADER_PAYMENT_TBL          OE_ORDER_PUB_HEADER_PAYMENT_T,
        P_OLD_HEADER_PAYMENT_TBL      OE_ORDER_PUB_HEADER_PAYMENT_T,
        P_HEADER_PAYMENT_VAL_TBL      OE_ORDER_PUB_HEADER_PAYMENT_V,
        P_OLD_HEADER_PAYMENT_VAL_TBL  OE_ORDER_PUB_HEADER_PAYMENT_V,
        P_LINE_TBL                    OE_ORDER_PUB_LINE_TBL_TYPE,
        P_OLD_LINE_TBL                OE_ORDER_PUB_LINE_TBL_TYPE,
        P_LINE_VAL_TBL                OE_ORDER_PUB_LINE_VAL_TBL_TYP,
        P_OLD_LINE_VAL_TBL            OE_ORDER_PUB_LINE_VAL_TBL_TYP,
        P_LINE_ADJ_TBL                OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
        P_OLD_LINE_ADJ_TBL            OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
        P_LINE_ADJ_VAL_TBL            OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
        P_OLD_LINE_ADJ_VAL_TBL        OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
        P_LINE_PRICE_ATT_TBL          OE_ORDER_PUB_LINE_PRICE_ATT_T,
        P_OLD_LINE_PRICE_ATT_TBL      OE_ORDER_PUB_LINE_PRICE_ATT_T,
        P_LINE_ADJ_ATT_TBL            OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
        P_OLD_LINE_ADJ_ATT_TBL        OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
        P_LINE_ADJ_ASSOC_TBL          OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
        P_OLD_LINE_ADJ_ASSOC_TBL      OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
        P_LINE_SCREDIT_TBL            OE_ORDER_PUB_LINE_SCREDIT_TBL,
        P_OLD_LINE_SCREDIT_TBL        OE_ORDER_PUB_LINE_SCREDIT_TBL,
        P_LINE_SCREDIT_VAL_TBL        OE_ORDER_PUB_LINE_SCREDIT_VAL,
        P_OLD_LINE_SCREDIT_VAL_TBL    OE_ORDER_PUB_LINE_SCREDIT_VAL,
        P_LINE_PAYMENT_TBL            OE_ORDER_PUB_LINE_PAYMENT_TBL,
        P_OLD_LINE_PAYMENT_TBL        OE_ORDER_PUB_LINE_PAYMENT_TBL,
        P_LINE_PAYMENT_VAL_TBL        OE_ORDER_PUB_LINE_PAYMENT_VAL,
        P_OLD_LINE_PAYMENT_VAL_TBL    OE_ORDER_PUB_LINE_PAYMENT_VAL,
        P_LOT_SERIAL_TBL              OE_ORDER_PUB_LOT_SERIAL_TBL_T,
        P_OLD_LOT_SERIAL_TBL          OE_ORDER_PUB_LOT_SERIAL_TBL_T,
        P_LOT_SERIAL_VAL_TBL          OE_ORDER_PUB_LOT_SERIAL_VAL_T,
        P_OLD_LOT_SERIAL_VAL_TBL      OE_ORDER_PUB_LOT_SERIAL_VAL_T,
        P_ACTION_REQUEST_TBL          OE_ORDER_PUB_REQUEST_TBL_TYPE,
        X_HEADER_REC              OUT NOCOPY     OE_ORDER_PUB_HEADER_REC_TYPE  ,
        X_HEADER_VAL_REC          OUT NOCOPY     OE_ORDER_PUB_HEADER_VAL_REC_T ,
        X_HEADER_ADJ_TBL          OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_TBL_T ,
        X_HEADER_ADJ_VAL_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_VAL_T ,
        X_HEADER_PRICE_ATT_TBL    OUT NOCOPY     OE_ORDER_PUB_HEADER_PRICE_ATT ,
        X_HEADER_ADJ_ATT_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_ATT_T ,
        X_HEADER_ADJ_ASSOC_TBL    OUT NOCOPY     OE_ORDER_PUB_HEADER_ADJ_ASSOC ,
        X_HEADER_SCREDIT_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_SCREDIT_T ,
        X_HEADER_SCREDIT_VAL_TBL  OUT NOCOPY     OE_ORDER_PUB_HEADER_SCREDIT_V ,
        X_HEADER_PAYMENT_TBL      OUT NOCOPY     OE_ORDER_PUB_HEADER_PAYMENT_T ,
        X_HEADER_PAYMENT_VAL_TBL  OUT NOCOPY     OE_ORDER_PUB_HEADER_PAYMENT_V ,
        X_LINE_TBL                OUT NOCOPY     OE_ORDER_PUB_LINE_TBL_TYPE    ,
        X_LINE_VAL_TBL            OUT NOCOPY     OE_ORDER_PUB_LINE_VAL_TBL_TYP ,
        X_LINE_ADJ_TBL            OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_TBL_TYP ,
        X_LINE_ADJ_VAL_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_VAL_TBL ,
        X_LINE_PRICE_ATT_TBL      OUT NOCOPY     OE_ORDER_PUB_LINE_PRICE_ATT_T ,
        X_LINE_ADJ_ATT_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_ATT_TBL ,
        X_LINE_ADJ_ASSOC_TBL      OUT NOCOPY     OE_ORDER_PUB_LINE_ADJ_ASSOC_T ,
        X_LINE_SCREDIT_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_SCREDIT_TBL ,
        X_LINE_SCREDIT_VAL_TBL    OUT NOCOPY     OE_ORDER_PUB_LINE_SCREDIT_VAL ,
        X_LINE_PAYMENT_TBL        OUT NOCOPY     OE_ORDER_PUB_LINE_PAYMENT_TBL ,
        X_LINE_PAYMENT_VAL_TBL    OUT NOCOPY     OE_ORDER_PUB_LINE_PAYMENT_VAL ,
        X_LOT_SERIAL_TBL          OUT NOCOPY     OE_ORDER_PUB_LOT_SERIAL_TBL_T ,
        X_LOT_SERIAL_VAL_TBL      OUT NOCOPY     OE_ORDER_PUB_LOT_SERIAL_VAL_T ,
        X_ACTION_REQUEST_TBL      OUT NOCOPY     OE_ORDER_PUB_REQUEST_TBL_TYPE ,
        P_RTRIM_DATA                    VARCHAR2
  );

  --
  -- O2C25
  --
  --  Process_Order_25(...) specifically created to perform Process Order
  --  operations in O2C25 code line.
  --
  ----------
    PROCEDURE Process_Order_25 (
          P_API_VERSION_NUMBER          NUMBER,
          P_INIT_MSG_LIST               VARCHAR2,
          P_RETURN_VALUES               VARCHAR2,
          P_ACTION_COMMIT               VARCHAR2,
          X_RETURN_STATUS           OUT NOCOPY VARCHAR2 ,
          X_MESSAGES                OUT NOCOPY OE_MESSAGE_OBJ_T,
          P_HEADER_REC                  OE_ORDER_PUB_HEADER_REC_TYPE,
          P_OLD_HEADER_REC              OE_ORDER_PUB_HEADER_REC_TYPE,
          P_HEADER_VAL_REC              OE_ORDER_PUB_HEADER_VAL_REC_T,
          P_OLD_HEADER_VAL_REC          OE_ORDER_PUB_HEADER_VAL_REC_T,
          P_HEADER_ADJ_TBL              OE_ORDER_PUB_HEADER_ADJ_TBL_T,
          P_OLD_HEADER_ADJ_TBL          OE_ORDER_PUB_HEADER_ADJ_TBL_T,
          P_HEADER_ADJ_VAL_TBL          OE_ORDER_PUB_HEADER_ADJ_VAL_T,
          P_OLD_HEADER_ADJ_VAL_TBL      OE_ORDER_PUB_HEADER_ADJ_VAL_T,
          P_HEADER_PRICE_ATT_TBL        OE_ORDER_PUB_HEADER_PRICE_ATT,
          P_OLD_HEADER_PRICE_ATT_TBL    OE_ORDER_PUB_HEADER_PRICE_ATT,
          P_HEADER_ADJ_ATT_TBL          OE_ORDER_PUB_HEADER_ADJ_ATT_T,
          P_OLD_HEADER_ADJ_ATT_TBL      OE_ORDER_PUB_HEADER_ADJ_ATT_T,
          P_HEADER_ADJ_ASSOC_TBL        OE_ORDER_PUB_HEADER_ADJ_ASSOC,
          P_OLD_HEADER_ADJ_ASSOC_TBL    OE_ORDER_PUB_HEADER_ADJ_ASSOC,
          P_HEADER_SCREDIT_TBL          OE_ORDER_PUB_HEADER_SCREDIT_T,
          P_OLD_HEADER_SCREDIT_TBL      OE_ORDER_PUB_HEADER_SCREDIT_T,
          P_HEADER_SCREDIT_VAL_TBL      OE_ORDER_PUB_HEADER_SCREDIT_V,
          P_OLD_HEADER_SCREDIT_VAL_TBL  OE_ORDER_PUB_HEADER_SCREDIT_V,
          P_HEADER_PAYMENT_TBL          OE_ORDER_PUB_HEADER_PAYMENT_T,
          P_OLD_HEADER_PAYMENT_TBL      OE_ORDER_PUB_HEADER_PAYMENT_T,
          P_HEADER_PAYMENT_VAL_TBL      OE_ORDER_PUB_HEADER_PAYMENT_V,
          P_OLD_HEADER_PAYMENT_VAL_TBL  OE_ORDER_PUB_HEADER_PAYMENT_V,
          P_LINE_TBL                    OE_ORDER_PUB_LINE_TBL_TYPE,
          P_OLD_LINE_TBL                OE_ORDER_PUB_LINE_TBL_TYPE,
          P_LINE_VAL_TBL                OE_ORDER_PUB_LINE_VAL_TBL_TYP,
          P_OLD_LINE_VAL_TBL            OE_ORDER_PUB_LINE_VAL_TBL_TYP,
          P_LINE_ADJ_TBL                OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
          P_OLD_LINE_ADJ_TBL            OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
          P_LINE_ADJ_VAL_TBL            OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
          P_OLD_LINE_ADJ_VAL_TBL        OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
          P_LINE_PRICE_ATT_TBL          OE_ORDER_PUB_LINE_PRICE_ATT_T,
          P_OLD_LINE_PRICE_ATT_TBL      OE_ORDER_PUB_LINE_PRICE_ATT_T,
          P_LINE_ADJ_ATT_TBL            OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
          P_OLD_LINE_ADJ_ATT_TBL        OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
          P_LINE_ADJ_ASSOC_TBL          OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
          P_OLD_LINE_ADJ_ASSOC_TBL      OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
          P_LINE_SCREDIT_TBL            OE_ORDER_PUB_LINE_SCREDIT_TBL,
          P_OLD_LINE_SCREDIT_TBL        OE_ORDER_PUB_LINE_SCREDIT_TBL,
          P_LINE_SCREDIT_VAL_TBL        OE_ORDER_PUB_LINE_SCREDIT_VAL,
          P_OLD_LINE_SCREDIT_VAL_TBL    OE_ORDER_PUB_LINE_SCREDIT_VAL,
          P_LINE_PAYMENT_TBL            OE_ORDER_PUB_LINE_PAYMENT_TBL,
          P_OLD_LINE_PAYMENT_TBL        OE_ORDER_PUB_LINE_PAYMENT_TBL,
          P_LINE_PAYMENT_VAL_TBL        OE_ORDER_PUB_LINE_PAYMENT_VAL,
          P_OLD_LINE_PAYMENT_VAL_TBL    OE_ORDER_PUB_LINE_PAYMENT_VAL,
          P_LOT_SERIAL_TBL              OE_ORDER_PUB_LOT_SERIAL_TBL_T,
          P_OLD_LOT_SERIAL_TBL          OE_ORDER_PUB_LOT_SERIAL_TBL_T,
          P_LOT_SERIAL_VAL_TBL          OE_ORDER_PUB_LOT_SERIAL_VAL_T,
          P_OLD_LOT_SERIAL_VAL_TBL      OE_ORDER_PUB_LOT_SERIAL_VAL_T,
          P_ACTION_REQUEST_TBL          OE_ORDER_PUB_REQUEST_TBL_TYPE,
          X_HEADER_REC              OUT NOCOPY    OE_ORDER_PUB_HDR_REC25,
          X_HEADER_VAL_REC          OUT NOCOPY    OE_ORDER_PUB_HEADER_VAL_REC_T,
          X_HEADER_ADJ_TBL          OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_TBL_T,
          X_HEADER_ADJ_VAL_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_VAL_T,
          X_HEADER_PRICE_ATT_TBL    OUT NOCOPY    OE_ORDER_PUB_HEADER_PRICE_ATT,
          X_HEADER_ADJ_ATT_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_ATT_T,
          X_HEADER_ADJ_ASSOC_TBL    OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_ASSOC,
          X_HEADER_SCREDIT_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_SCREDIT_T,
          X_HEADER_SCREDIT_VAL_TBL  OUT NOCOPY    OE_ORDER_PUB_HEADER_SCREDIT_V,
          X_HEADER_PAYMENT_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_PAYMENT_T,
          X_HEADER_PAYMENT_VAL_TBL  OUT NOCOPY    OE_ORDER_PUB_HEADER_PAYMENT_V,
          X_LINE_TBL                OUT NOCOPY    OE_ORDER_PUB_LINE_TAB25,
          X_LINE_VAL_TBL            OUT NOCOPY    OE_ORDER_PUB_LINE_VAL_TBL_TYP,
          X_LINE_ADJ_TBL            OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_TBL_TYP ,
          X_LINE_ADJ_VAL_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
          X_LINE_PRICE_ATT_TBL      OUT NOCOPY    OE_ORDER_PUB_LINE_PRICE_ATT_T,
          X_LINE_ADJ_ATT_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
          X_LINE_ADJ_ASSOC_TBL      OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
          X_LINE_SCREDIT_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_SCREDIT_TBL,
          X_LINE_SCREDIT_VAL_TBL    OUT NOCOPY    OE_ORDER_PUB_LINE_SCREDIT_VAL,
          X_LINE_PAYMENT_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_PAYMENT_TBL,
          X_LINE_PAYMENT_VAL_TBL    OUT NOCOPY    OE_ORDER_PUB_LINE_PAYMENT_VAL,
          X_LOT_SERIAL_TBL          OUT NOCOPY    OE_ORDER_PUB_LOT_SERIAL_TBL_T,
          X_LOT_SERIAL_VAL_TBL      OUT NOCOPY    OE_ORDER_PUB_LOT_SERIAL_VAL_T ,
          X_ACTION_REQUEST_TBL      OUT NOCOPY    OE_ORDER_PUB_REQUEST_TBL_TYPE,
          P_RTRIM_DATA                            VARCHAR2
        );
  ---------- O2C25


END Oe_Inbound_Int;

/
