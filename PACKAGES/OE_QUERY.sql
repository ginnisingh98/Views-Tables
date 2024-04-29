--------------------------------------------------------
--  DDL for Package OE_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_QUERY" AUTHID CURRENT_USER as
/* $Header: OEXQRYSS.pls 120.1 2006/11/19 18:00:32 ssurapan noship $ */

function LINE_TOTAL(
   ORDER_ROWID           IN VARCHAR2
 , ORDER_LINE_ID         IN NUMBER DEFAULT NULL
 , LINE_TYPE_CODE        IN VARCHAR2
 , ITEM_TYPE_CODE        IN VARCHAR2
 , SERVICE_DURATION      IN NUMBER
 , SERVICEABLE_FLAG      IN VARCHAR2
 , ORDERED_QTY           IN NUMBER
 , CANCELLED_QTY         IN NUMBER
 , SELLING_PRICE         IN NUMBER
                      )
  return NUMBER;

function SERVICE_TOTAL(
   P_ROWID               IN VARCHAR2
 , P_LINE_ID             IN NUMBER
 , P_LINES_LINE_ID       IN NUMBER
 , P_ITEM_TYPE_CODE      IN VARCHAR2
 , P_SERVICEABLE_FLAG    IN VARCHAR2
                      )
  return NUMBER;


 function SCHEDULE_STATUS(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2;

 pragma restrict_references( SCHEDULE_STATUS, WNDS);  -- ,WNPS);


 function SCHEDULE_STATUS(
   SCHEDULE_STATUS_CODE    IN VARCHAR2
                              )
   return VARCHAR2;

 pragma restrict_references( SCHEDULE_STATUS, WNDS);  -- ,WNPS);


  function ATO_Indicator( P_Line_Id IN NUMBER,
			  P_Item_Type_Code IN VARCHAR2 )
   return VARCHAR2;

  function Get_ATO_Indicator( P_Line_Id IN NUMBER,
			  P_Item_Type_Code IN VARCHAR2 )
   return VARCHAR2;


 function RELEASED_QUANTITY(
   P_LINE_ID           IN NUMBER
                              )
   return NUMBER;

  pragma restrict_references (RELEASED_QUANTITY, WNDS, WNPS);

 function p_line_released_quantity (
   P_LINE_ID           IN NUMBER
                              )
   return NUMBER;

  pragma restrict_references (p_line_released_quantity, WNDS, WNPS);


 function II_RESERVED_QUANTITY(
   P_LINE_ID             IN NUMBER,
   P_COMPONENT_CODE	 IN VARCHAR2
                              )
   return NUMBER;


  pragma restrict_references (II_RESERVED_QUANTITY, WNDS, WNPS);


 function II_RELEASED_QUANTITY(
   P_LINE_ID             IN NUMBER,
   P_COMPONENT_CODE	 IN VARCHAR2
                              )
   return NUMBER;

  pragma restrict_references (II_RELEASED_QUANTITY, WNDS, WNPS);

 function II_SCHEDULE_STATUS_CODE(
   P_LINE_ID             IN NUMBER,
   P_COMPONENT_CODE	 IN VARCHAR2
                              )
   return VARCHAR2;

  pragma restrict_references (II_SCHEDULE_STATUS_CODE, WNDS, WNPS);

 function RESERVED_QUANTITY(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
                              )
   return NUMBER;


 function HOLD(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
,  ORDER_HEADER_ID         IN NUMBER DEFAULT NULL
                              )
   return varchar2;

----------------------------------------------------------------------
-- SHIPMENT_SCHEDULE_NUMBER is a better function to figure out
-- shipment_number because it takes service lines into consideration.
-- Should use SHIPMENT_SCHEDULE_NUMBER whenever possible.
----------------------------------------------------------------------
 function SHIPMENT_NUMBER(
   ORDER_LINE_ID                       IN NUMBER DEFAULT NULL
,  ORDER_PARENT_LINE_ID                IN NUMBER DEFAULT NULL
,  ORDER_SHIP_SCHEDULE_LINE_ID         IN NUMBER DEFAULT NULL
,  ORDER_LINE_NUMBER                   IN NUMBER DEFAULT NULL
                          )
   return NUMBER;

----------------------------------------------------------------------
-- BASE_LINE_NUMBER is a better function to figure out line_number
-- because it takes service lines into consideration.
-- Should use BASE_LINE_NUMBER whenever possible.
----------------------------------------------------------------------
 function LINE_NUMBER(
   ORDER_LINE_ID                       IN NUMBER DEFAULT NULL
,  ORDER_SHIP_SCHEDULE_LINE_ID         IN NUMBER DEFAULT NULL
,  ORDER_PARENT_LINE_ID                IN NUMBER DEFAULT NULL
,  ORDER_LINE_NUMBER                   IN NUMBER DEFAULT NULL
                          )
   return NUMBER;


 function ITEM_CONC_SEG(
   ITEM_ID                            IN NUMBER DEFAULT NULL
,  ORG_ID                             IN NUMBER DEFAULT NULL
                          )
   return VARCHAR2;

 function ORDER_TYPE(
   ID                                 IN NUMBER DEFAULT NULL
                          )
   return VARCHAR2;

  FUNCTION  Configuration_Total
	(
        Config_Parent_Line_Id               IN NUMBER
	) RETURN NUMBER;

   Function Source_Order_number
       ( P_ORIGINAL_SYSTEM_SOURCE_CODE VARCHAR2,
         P_ORIGINAL_SYSTEM_REFERENCE VARCHAR2
       ) return VARCHAR2;

   Function Source_Order_Type
       ( P_ORIGINAL_SYSTEM_SOURCE_CODE VARCHAR2,
         P_ORIGINAL_SYSTEM_REFERENCE VARCHAR2
       ) return VARCHAR2;
 --Added missing default value Bug#5660501
 function Supply_Res_Details(
   P_Line_Id  IN NUMBER DEFAULT NULL)
    return VARCHAR2;
-- Added missing default value Bug#5660501
 function Schedule_Status_Code(
   Order_Line_Id  IN NUMBER DEFAULT NULL)
    return VARCHAR2;

 function picking_line_schedule_status(
   P_LINE_ID           IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2;

 function p_line_schedule_status_code(
   P_LINE_ID		IN NUMBER DEFAULT NULL
				)
   return VARCHAR2;


 pragma restrict_references(Schedule_Status_Code, WNDS, WNPS);
 pragma restrict_references(Supply_Res_Details, WNDS, WNPS);
 pragma restrict_references(LINE_TOTAL, WNDS, WNPS);
 pragma restrict_references(SERVICE_TOTAL, WNDS, WNPS);
 pragma restrict_references( ATO_INDICATOR, WNDS,WNPS);
 pragma restrict_references( GET_ATO_INDICATOR, WNDS,WNPS);
 pragma restrict_references( RESERVED_QUANTITY, WNDS, WNPS);
 pragma restrict_references( HOLD, WNDS, WNPS);
 pragma restrict_references( SHIPMENT_NUMBER, WNDS, WNPS);
 pragma restrict_references( LINE_NUMBER, WNDS, WNPS);
 pragma restrict_references( ITEM_CONC_SEG, WNDS, WNPS);
 pragma restrict_references( ORDER_TYPE, WNDS, WNPS);
 pragma restrict_references( CONFIGURATION_TOTAL, WNDS,RNPS, WNPS);
 pragma restrict_references( source_order_number, WNDS,RNPS, WNPS);
 pragma restrict_references( source_order_type, WNDS,RNPS, WNPS);
 pragma restrict_references( picking_line_schedule_status, WNDS);  -- ,WNPS);
 pragma restrict_references( p_line_schedule_status_code, WNDS,WNPS);

  --
  -- NAME
  --   Order_Total
  --
  -- ARGUMENT
  --   Header_Id  	Header_Id of the order
  --
  -- DESCRIPTION
  --   Returns the pre-tax order total for the order identified
  --   by Header_Id
  --
  FUNCTION Order_Total(Header_Id IN NUMBER) Return NUMBER;

    PRAGMA Restrict_References(Order_Total, WNDS, WNPS);

  FUNCTION Shipment_Total(P_Line_Id IN NUMBER) return NUMBER;

    PRAGMA Restrict_References(Shipment_Total, WNDS, RNPS, WNPS);


  --
  -- Receipt and Accepted Quantity and Dates
  --
  -- Give the line ID, these functions will return
  -- received ( accepted ) quantity or dates from
  -- MTL_SO_RMA_INTERFACE table.
  --
  FUNCTION  Received_qty( P_Line_Id NUMBER)
			 RETURN NUMBER;
  pragma restrict_references (Received_qty, WNDS, WNPS);
  FUNCTION  Accepted_qty( P_Line_Id NUMBER)
			 RETURN NUMBER;
  pragma restrict_references (Accepted_qty, WNDS, WNPS);
  FUNCTION  Received_Date( P_Line_Id NUMBER,
			   P_S29_DATE DATE)
			 RETURN DATE;
  pragma restrict_references (Received_Date, WNDS, WNPS);
  FUNCTION  Accepted_Date( P_Line_Id NUMBER,
			   P_S29_DATE DATE)
			 RETURN DATE;
  pragma restrict_references (Accepted_Date, WNDS, WNPS);
  FUNCTION  GET_TAX_EXEMPT_FLAG(
				P_Reference_Code VARCHAR2,
				P_Invoice_Flag VARCHAR2,
				P_Order_Flag VARCHAR2,
				P_No_Ref_Flag VARCHAR2,
				P_Open_Flag VARCHAR2
				)
    RETURN VARCHAR2;
  pragma restrict_references (GET_TAX_EXEMPT_FLAG, WNDS);  -- , WNPS);
  FUNCTION  GET_TAX_EXEMPT_REASON(  P_Reference_Code VARCHAR2,
				    P_Invoice_reason VARCHAR2,
				    P_Order_reason VARCHAR2,
				    P_No_Ref_reason VARCHAR2,
				    P_Open_Flag VARCHAR2)
    RETURN VARCHAR2;
  pragma restrict_references (GET_TAX_EXEMPT_REASON, WNDS);  -- , WNPS);
  FUNCTION  GET_PRICE_ADJ_TOTAL(
				P_Header_Id NUMBER,
				P_Line_Id NUMBER
				)
    RETURN NUMBER;
  pragma restrict_references (GET_PRICE_ADJ_TOTAL, WNDS, WNPS);


  --
  -- NAME
  --   Get_Std_Tax_Exemption
  --
  PROCEDURE Get_Std_Tax_Exemption(Ship_To_Site_Use_Id    IN NUMBER,
				  Invoice_To_customer_id IN NUMBER,
				  Date_Ordered		 IN DATE,
				  Tax_Exempt_Number	 OUT NOCOPY VARCHAR2,
				  Tax_Exempt_Reason	 OUT NOCOPY VARCHAR2);
  pragma restrict_references (Get_Std_Tax_Exemption, WNDS);  -- , WNPS);

  --
  -- Std_Tax_Exempt_Number
  --
  FUNCTION Std_Tax_Exempt_Number(Ship_To_Site_Use_Id    IN NUMBER,
				 Invoice_To_customer_id IN NUMBER,
				 Date_Ordered	        IN DATE)
    Return VARCHAR2;

  pragma restrict_references (Std_Tax_Exempt_Number, WNDS);  -- , WNPS);

  --
  -- Std_Tax_Exempt_Reason
  --
  FUNCTION Std_Tax_Exempt_Reason(Ship_To_Site_Use_Id    IN NUMBER,
				 Invoice_To_customer_id IN NUMBER,
				 Date_Ordered	        IN DATE)
    Return VARCHAR2;

  pragma restrict_references (Std_Tax_Exempt_Reason, WNDS);  -- , WNPS);


  FUNCTION line_config_item_exists(X_line_id IN NUMBER) RETURN VARCHAR2;

  PRAGMA restrict_references(line_config_item_exists, WNDS,RNPS,WNPS);


  FUNCTION line_released_qty(X_line_id IN NUMBER) RETURN NUMBER;

 PRAGMA restrict_references (line_released_qty, WNDS, RNPS, WNPS);


  FUNCTION lot_expiration(X_inventory_item_id IN NUMBER,
                            X_organization_id IN NUMBER,
                            X_lot_number IN VARCHAR2) RETURN DATE;

 PRAGMA restrict_references (lot_expiration, WNDS, RNPS, WNPS);


 FUNCTION picking_line_reserved_qty(X_picking_line_id IN NUMBER)
	RETURN NUMBER;

 PRAGMA restrict_references(picking_line_reserved_qty, WNDS, WNPS, WNPS);

 FUNCTION Open_Backordered_Quantity(X_line_id NUMBER)
	RETURN NUMBER;

 PRAGMA restrict_references(Open_Backordered_Quantity, WNDS, WNPS);

  FUNCTION picking_line_item_id(X_picking_line_id IN NUMBER) return NUMBER;

  PRAGMA restrict_references(picking_line_item_id, WNDS, WNPS);

 function ATP_Date_Line_Id(
   P_Session_id In Number,
   P_Line_Id    In Varchar2,
   P_Inventory_Item_Id In Number)
    return Date;

 function Available_Quantity_Line_Id(
   P_Session_id In Number,
   P_Line_Id    In Varchar2,
   P_Inventory_Item_Id In Number)
    return Number;

 function Demand_Interface_RowId_Line_Id(
   P_Session_id In Number,
   P_Line_Id    In Varchar2)
    return Varchar2;

 pragma restrict_references(ATP_DATE_LINE_ID, WNDS, WNPS);
 pragma restrict_references(AVAILABLE_QUANTITY_LINE_ID, WNDS, WNPS);
 pragma restrict_references(DEMAND_INTERFACE_ROWID_LINE_ID, WNDS, WNPS);

 function ATP_Date_Delivery(
   P_Session_id In Number,
   P_Delivery    In Varchar2)
     return Date;

 function Available_Quantity_Delivery(
   P_Session_id In Number,
   P_Delivery    In Varchar2)
    return Number;

 function Demand_Interface_RowId_Del(
   P_Session_id In Number,
   P_Delivery    In Varchar2)
    return Varchar2;

 pragma restrict_references(ATP_DATE_DELIVERY, WNDS, WNPS);
 pragma restrict_references(AVAILABLE_QUANTITY_DELIVERY, WNDS, WNPS);
 pragma restrict_references(DEMAND_INTERFACE_ROWID_DEL, WNDS, WNPS);

function get_organization_name
  return VARCHAR2;

 pragma restrict_references(GET_ORGANIZATION_NAME, WNDS, WNPS);

    /* The order status is displayed as cancelled or Closed if the order
       is in the state of Cancelld or Closed and the entry status field
       will be set to non updatable. For other headers the entry status
       will display the result for the value in the column s1
    */

function get_entry_status_name(p_open_flag in varchar2,
                               p_cancelled_flag in varchar2,
                               p_s1_id        in number)
  return VARCHAR2;

 pragma restrict_references(GET_ENTRY_STATUS_NAME, WNDS, WNPS);

 function OPTION_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER;
 pragma restrict_references( OPTION_LINE_NUMBER, WNDS, WNPS);

function INVOICE_BALANCE(
P_CUSTOMER_TRX_ID         IN NUMBER
                )
  return NUMBER;

 pragma restrict_references( INVOICE_BALANCE, WNDS,WNPS);

function INVOICE_AMOUNT(
P_CUSTOMER_TRX_ID         IN NUMBER
                )
  return NUMBER;

 pragma restrict_references( INVOICE_AMOUNT, WNDS,WNPS);

function CYCLE_REQUEST
  return NUMBER;

function BASE_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                            )
     return NUMBER;

 pragma restrict_references( BASE_LINE_NUMBER, WNDS, WNPS);

function SHIPMENT_SCHEDULE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                            )
     return NUMBER;

 pragma restrict_references( SHIPMENT_SCHEDULE_NUMBER, WNDS, WNPS);

END OE_QUERY;

 

/
