--------------------------------------------------------
--  DDL for Package Body OE_SHP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHP_PROCESS" AS
/* $Header: OEXSHPRB.pls 115.3 99/07/16 08:15:54 porting shi $ */

OE_SUCCESS  CONSTANT VARCHAR2(1) := 'Y';
OE_FAILURE  CONSTANT VARCHAR2(1) := 'N';
OE_SHIPMENT_MISMATCH CONSTANT VARCHAR2(30) :=
           'SHIPMENT_SCHEDULE_QTY_MISMATCH';

PROCEDURE Apply_Ordered_Quantity_Change
(
        P_Lines_Item_Type_Code          IN  VARCHAR2,
        P_Lines_Ser_Flag                IN  VARCHAR2,
        P_Ord_Enforce_List_Prices_Flag  IN VARCHAR2,
        P_Shp_Config_Flag               OUT VARCHAR2,
        P_Shp_Sch_Flag                  OUT VARCHAR2,
        P_Shp_Adj_Flag                  OUT VARCHAR2,
        P_Shp_Apply_Ord_Adj_Flag        OUT VARCHAR2,
        P_Shp_Credit_Flag               OUT VARCHAR2,
        P_Shp_Ser_Flag                  IN OUT VARCHAR2,
        P_Shp_Schedule_Quantity_Tot   IN OUT NUMBER,
        P_Line_Details_S_Qty_Total   OUT NUMBER,
        P_Shp_Installation_Quantity   OUT NUMBER,
        P_Shp_Ordered_Quantity        IN  NUMBER,
        P_Shp_Open_Quantity           IN OUT NUMBER,
        P_Shp_Cancelled_Quantity      IN  NUMBER,
        P_return_Status                 IN OUT VARCHAR2
)
is

begin

   P_Return_Status:=OE_SUCCESS;

   OE_SHP_PROCESS.Get_Shipment_Detail_Controls(
        P_Lines_Item_Type_Code=>P_Lines_Item_Type_Code,
        P_Lines_Ser_Flag=>P_Lines_Ser_Flag,
        P_Ord_Enforce_List_Prices_Flag=>P_Ord_Enforce_List_Prices_Flag,
        P_Shp_Config_Flag=>P_Shp_Config_Flag,
        P_Shp_Sch_Flag=>P_Shp_Sch_Flag,
        P_Shp_Adj_Flag=>P_Shp_Adj_Flag,
        P_Shp_Apply_Ord_Adj_Flag=>P_Shp_Apply_Ord_Adj_Flag,
        P_Shp_Credit_Flag=>P_Shp_Credit_Flag,
        P_Shp_Ser_Flag=>P_Shp_Ser_Flag,
        P_return_Status=>P_return_Status);

   if ( P_Return_Status = OE_FAILURE ) then
      return;
   end if;

   if (P_Shp_Schedule_Quantity_Tot   is not null ) then
   	OE_LIN.Calc_Lin_Obj_Open_Quantity(
        	Lin_Obj_Ordered_Quantity=>P_Shp_Ordered_Quantity,
        	Lin_Obj_Open_Quantity=>P_Shp_Open_Quantity,
        	Lin_Obj_Cancelled_Quantity=>P_Shp_Cancelled_Quantity,
		P_Return_Status=>P_return_Status
		);
        if ( P_Return_Status = OE_FAILURE ) then
	   return;
	end if;
	P_Shp_Schedule_Quantity_Tot:=P_Shp_Open_Quantity;
	P_Line_Details_S_Qty_Total:=P_Shp_Open_Quantity;
   end if;

   if (P_Shp_Ser_Flag='Y') then
	P_Shp_Installation_Quantity:=null;
   end if;

exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_OPT_SER_LINES.Apply_Ordered_Quantity_Change',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');


end Apply_Ordered_Quantity_Change;

PROCEDURE Get_Shipment_Detail_Controls
(
        P_Lines_Item_Type_Code          IN  VARCHAR2,
        P_Lines_Ser_Flag                IN  VARCHAR2,
        P_Ord_Enforce_List_Prices_Flag  IN VARCHAR2,
        P_Shp_Config_Flag         	OUT VARCHAR2,
        P_Shp_Sch_Flag            	OUT VARCHAR2,
        P_Shp_Adj_Flag            	OUT VARCHAR2,
        P_Shp_Apply_Ord_Adj_Flag        OUT VARCHAR2,
        P_Shp_Credit_Flag               OUT VARCHAR2,
        P_Shp_Ser_Flag                  OUT VARCHAR2,
        P_return_Status                 OUT VARCHAR2
)
is

begin

 if ( P_Lines_Item_Type_Code = 'MODEL') then
    P_Shp_Config_Flag:='Y';
 else
    P_Shp_Config_Flag:='N';
 end if;

 if ( P_Ord_Enforce_List_Prices_Flag = 'Y' ) then
    P_Shp_Adj_Flag:='N';
 else
    P_Shp_Adj_Flag:='Y';
 end if;

 P_Shp_Apply_Ord_Adj_Flag:='Y';
 P_Shp_Credit_Flag:='Y';
 P_Shp_Ser_Flag:=P_Lines_Ser_Flag;

exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Get_Shipment_Detail_Controls',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');


end Get_Shipment_Detail_Controls;

PROCEDURE Query_Shipment_Total
(
        P_Shp_Row_Id            IN VARCHAR2,
        P_Shp_Line_Id           IN NUMBER,
        P_Lines_Line_Id             IN NUMBER,
        P_Shp_Line_Type_Code    IN VARCHAR2,
        P_Shp_serviceable_Flag  IN VARCHAR2,
        P_Order_Currency_Precision  IN NUMBER,
        P_Shp_Selling_Price     IN NUMBER,
        P_Shp_Line_Total  	  IN OUT NUMBER,
        P_Shp_Total             IN OUT NUMBER,
        P_Shp_Ordered_Quantity  IN NUMBER,
        P_Shp_Open_Quantity     IN OUT NUMBER,
        P_Shp_Cancelled_Quantity IN NUMBER,
        P_Shp_Service_Total     OUT NUMBER,
        P_Shp_Query_Total       OUT VARCHAR2,
	P_Return_Status	          IN OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;

if P_Shp_Line_id is not null then
   if P_Shp_Total is not null then
       P_Shp_Query_Total:='N';
   else
       P_Shp_Total:=0;
       P_Shp_Line_Total:=0;
       P_Shp_Service_Total:=0;
       OE_SHP_PROCESS.Calc_Shipment_Total(
             P_Shp_Line_Total=>P_Shp_Line_Total,
             P_Shp_Ordered_Quantity=>P_Shp_Ordered_Quantity,
             P_Shp_Open_Quantity=>P_Shp_Open_Quantity,
             P_Shp_Cancelled_Quantity=>P_Shp_Cancelled_Quantity,
             P_Shp_Selling_Price=>P_Shp_Selling_Price,
             P_Shp_Line_Type_Code=>P_Shp_Line_Type_Code,
	     P_Return_Status=>P_Return_Status );
        if ( P_return_Status = OE_FAILURE ) then
            return;
        end if;
        if ( P_Shp_Line_Type_Code = 'MODEL' ) then
		SELECT NVL(SUM(  ROUND( (NVL( ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 )) *
                         NVL(SELLING_PRICE, 0 ),
                 P_Order_Currency_Precision))
                 , 0)
		,NVL( SUM( DECODE( SERVICE_PARENT_LINE_ID, P_Lines_LINE_ID,
                 ROUND( (NVL( ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 ) ) *
                         NVL( SELLING_PRICE, 0 ),
                  P_Order_Currency_Precision), 0 ) ), 0 )
		INTO   P_Shp_Total
		,P_Shp_Service_Total
		FROM   SO_LINES
		WHERE (ROWID = P_Shp_Row_Id
		OR  PARENT_LINE_ID = P_Shp_Line_Id
		OR SERVICE_PARENT_LINE_ID = P_Shp_Line_Id );
         elsif ( P_Shp_Serviceable_Flag = 'Y')  then
                SELECT NVL(SUM(  ROUND( (NVL( ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 )) *
                         NVL(SELLING_PRICE, 0 ),
                 P_Order_Currency_Precision))
                 , 0)
                ,NVL( SUM( DECODE( SERVICE_PARENT_LINE_ID, P_Lines_LINE_ID,
                 ROUND( (NVL( ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 ) ) *
                         NVL( SELLING_PRICE, 0 ),
                  P_Order_Currency_Precision), 0 ) ), 0 )
                INTO   P_Shp_Total
                ,P_Shp_Service_Total
                FROM   SO_LINES
                WHERE (ROWID = P_Shp_Row_Id
                OR  SERVICE_PARENT_LINE_ID = P_Shp_Line_Id );
          else
                P_Shp_Total:=P_Shp_Line_Total;
          end if;
  end if;
end if;

exception

 when no_data_found then
            null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Query_Shipment_Total',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');

end Query_Shipment_Total;

PROCEDURE Calc_Shipment_Total
(
        P_Shp_Line_Total  	        OUT  NUMBER,
        P_Shp_Ordered_Quantity        IN   NUMBER,
        P_Shp_Open_Quantity           IN OUT  NUMBER,
        P_Shp_Cancelled_Quantity      IN   NUMBER,
        P_Shp_Selling_Price           IN   NUMBER,
        P_Shp_Line_Type_Code          IN   VARCHAR2,
	P_Return_Status			IN OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;

   OE_LIN.Calc_Lin_Obj_Open_Quantity(
        Lin_Obj_Ordered_Quantity=>P_Shp_Ordered_Quantity,
        Lin_Obj_Open_Quantity=>P_Shp_Open_Quantity,
        Lin_Obj_Cancelled_Quantity=>P_Shp_Cancelled_Quantity,
	P_Return_Status=>P_Return_Status);

   if ( P_Return_Status = OE_FAILURE ) then
	return;
   end if;

   if P_Shp_Open_Quantity is null and
      P_Shp_Selling_Price is null then
      P_Shp_Line_Total:=0;
   else
      P_Shp_Line_Total:=P_Shp_Open_Quantity * P_Shp_Selling_Price;
   end if;

exception

 when no_data_found then
            null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Calc_Shipment_Total',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');

end Calc_Shipment_Total;


PROCEDURE Total_Shipment
(
        P_Shp_Total          		IN OUT  NUMBER,
        P_Shp_Line_Total      		IN OUT  NUMBER,
        P_Shp_Ordered_Quantity  	IN NUMBER,
        P_Shp_Open_Quantity   		IN OUT NUMBER,
        P_Shp_Cancelled_Quantity 	IN NUMBER,
        P_Shp_Selling_Price   		IN NUMBER,
        P_Shp_Line_Type_Code  		IN VARCHAR2,
	P_return_Status			IN OUT VARCHAR2
)
is

L_Total NUMBER;

begin

P_Return_Status:=OE_SUCCESS;

if P_Shp_Line_Total is null then
   L_Total:=0;
else
   L_Total:=P_Shp_Line_Total;
end if;

OE_SHP_PROCESS.Calc_Shipment_Total(
             P_Shp_Line_Total=>P_Shp_Line_Total,
             P_Shp_Ordered_Quantity=>P_Shp_Ordered_Quantity,
             P_Shp_Open_Quantity=>P_Shp_Open_Quantity,
             P_Shp_Cancelled_Quantity=>P_Shp_Cancelled_Quantity,
             P_Shp_Selling_Price=>P_Shp_Selling_Price,
             P_Shp_Line_Type_Code=>P_Shp_Line_Type_Code,
             P_Return_Status=>P_Return_Status );
if ( P_return_Status = OE_FAILURE ) then
    return;
end if;

P_Shp_Total := P_Shp_Total + P_Shp_Line_Total - L_Total;

exception

 when no_data_found then
        null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Total_Shipment',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');


end Total_Shipment;

PROCEDURE Calc_Line_Total
(
        P_Lines_Line_Total  	        OUT  NUMBER,
        P_Lines_Ordered_Quantity        IN   NUMBER,
        P_Lines_Open_Quantity           IN OUT  NUMBER,
        P_Lines_Cancelled_Quantity      IN   NUMBER,
        P_Lines_Selling_Price           IN   NUMBER,
        P_Lines_Line_Type_Code          IN   VARCHAR2,
        P_Lines_Item_Type_Code          IN   VARCHAR2,
        P_Lines_Service_Duration        IN   NUMBER,
	P_Return_Status			IN OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;


if P_Lines_Line_Type_Code = 'PARENT' then
   P_Lines_Line_Total:=0;
else
   OE_LIN.Calc_Lin_Obj_Open_Quantity(
        Lin_Obj_Ordered_Quantity=>P_Lines_Ordered_Quantity,
        Lin_Obj_Open_Quantity=>P_Lines_Open_Quantity,
        Lin_Obj_Cancelled_Quantity=>P_Lines_Cancelled_Quantity,
	P_Return_Status=>P_Return_Status);

   if ( P_Return_Status = OE_FAILURE ) then
	return;
   end if;

   if P_Lines_Open_Quantity is null and
      P_Lines_Selling_Price is null then
      P_Lines_Line_Total:=0;
   elsif ( P_Lines_Item_Type_Code = 'SERVICE' ) then
      if ( P_Lines_Service_Duration is null ) then
         P_Lines_Line_Total:=0;
      else
         P_Lines_Line_Total:=P_Lines_Open_Quantity * P_lines_Selling_Price;
      end if;
   else
      P_Lines_Line_Total:=P_Lines_Open_Quantity * P_lines_Selling_Price;
   end if;
end if;

exception

 when no_data_found then
            null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Calc_Line_Total',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');

end Calc_Line_Total;

PROCEDURE Total_Line
(
        P_Lines_Total          		IN OUT  NUMBER,
        P_Lines_Line_Total      	IN OUT  NUMBER,
        P_Lines_Ordered_Quantity  	IN NUMBER,
        P_Lines_Open_Quantity   	IN OUT NUMBER,
        P_Lines_Cancelled_Quantity 	IN NUMBER,
        P_Lines_Selling_Price   	IN NUMBER,
        P_Lines_Line_Type_Code  	IN VARCHAR2,
        P_Lines_Item_Type_Code	 	IN VARCHAR2,
        P_Lines_Service_Duration	IN NUMBER,
	P_return_Status			IN OUT VARCHAR2
)
is

L_Total NUMBER;

begin

P_Return_Status:=OE_SUCCESS;

if P_Lines_Line_Total is null then
   L_Total:=0;
else
   L_Total:=P_Lines_Line_Total;
end if;

OE_SHP_PROCESS.Calc_Line_Total(
             P_Lines_Line_Total=>P_Lines_Line_Total,
             P_Lines_Ordered_Quantity=>P_Lines_Ordered_Quantity,
             P_Lines_Open_Quantity=>P_Lines_Open_Quantity,
             P_Lines_Cancelled_Quantity=>P_Lines_Cancelled_Quantity,
             P_Lines_Selling_Price=>P_Lines_Selling_Price,
             P_Lines_Line_Type_Code=>P_Lines_Line_Type_Code,
             P_Lines_Item_Type_Code=>P_Lines_Item_Type_Code,
             P_Lines_Service_Duration=>P_Lines_Service_Duration,
             P_Return_Status=>P_Return_Status );
if ( P_return_Status = OE_FAILURE ) then
    return;
end if;

P_Lines_Total := P_Lines_Total + P_Lines_Line_Total - L_Total;

exception

 when no_data_found then
        null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Total_Line',
                                Operation=>'',
				Object=>'SHIPMENT',
                                Message=>' When Others');


end Total_Line;

PROCEDURE  Shipment_Total
(
	P_Line_Id 		IN NUMBER,
        P_Line_Total		OUT NUMBER,
	P_Return_Status 	OUT VARCHAR2
)
is

begin

      SELECT NVL(SUM( (NVL( ORDERED_QUANTITY, 0 ) -
                       NVL( CANCELLED_QUANTITY, 0 )) *
                      NVL(SELLING_PRICE, 0 ))
                    , 0)
      INTO   P_Line_Total
      FROM   SO_LINES
         WHERE ( SHIPMENT_SCHEDULE_LINE_ID = P_line_Id
                 OR SERVICE_PARENT_LINE_ID = P_Line_Id );

/*LINE_ID = P_Line_Id
       OR     PARENT_LINE_ID = P_Line_Id
       OR     SERVICE_PARENT_LINE_ID =
              P_Line_Id ); */


Exception

 when no_data_found then
       P_Line_Total:=0;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Shipment_Total',
                                Operation=>'',
                                Object=>'SHIPMENT',
                                Message=>' When Others');


end Shipment_Total;

PROCEDURE Shipment_Quantity_Total
(
        P_Lines_Line_Id                 IN NUMBER,
        P_Lines_Shipment_Qty_Total      OUT NUMBER,
        P_Lines_Shipment_Lines_Count    OUT NUMBER,
        P_return_Status                 OUT VARCHAR2
)
is

begin

SELECT NVL( SUM( NVL( ORDERED_QUANTITY, 0 ) -
                      NVL( CANCELLED_QUANTITY, 0 ) ), 0 ),
            COUNT(*)
     INTO   P_Lines_Shipment_Qty_Total,
            P_Lines_Shipment_Lines_Count
     FROM   SO_LINES
     WHERE  SHIPMENT_SCHEDULE_LINE_ID = P_Lines_Line_Id
     AND    PARENT_LINE_ID IS NULL
     AND    SERVICE_PARENT_LINE_ID IS NULL;

Exception

 when no_data_found then
       P_Lines_Shipment_Qty_Total:=0;
       P_Lines_Shipment_Lines_Count:=0;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Shipment_Quantity_Total',
                                Operation=>'',
                                Object=>'SHIPMENT',
                                Message=>' When Others');


end Shipment_Quantity_Total;

PROCEDURE  Update_Line_Type_Code
(
        P_Line_Id               IN NUMBER,
        P_Line_Type_Code        IN VARCHAR2,
        P_Return_Status         OUT VARCHAR2
)
is

begin

  if ( P_Line_Type_Code <> 'REGULAR') then
     UPDATE SO_LINES
     SET LINE_TYPE_CODE = 'REGULAR'
     WHERE  LINE_ID = P_Line_Id;
  elsif ( P_Line_Type_Code <> 'PARENT') then
     UPDATE SO_LINES
     SET LINE_TYPE_CODE = 'PARENT'
     WHERE  LINE_ID = P_Line_Id;
  end if;


Exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Update_Line_Type_Code',
                                Operation=>'',
                                Object=>'SHIPMENT',
                                Message=>' When Others');

end Update_Line_Type_Code;


PROCEDURE  Match_Shipment_Quantity
(
        P_Ship_Sched_Line_Id       IN OUT NUMBER,
        P_Line_RowId               IN VARCHAR2,
        P_Open_Line_Quantity       IN OUT NUMBER,
        P_Total_Shipment_Quantity  IN OUT NUMBER,
        P_Return_Status            OUT VARCHAR2
)
is

begin

 SELECT SUM(NVL(ORDERED_QUANTITY,0) - NVL(CANCELLED_QUANTITY,0))
     INTO P_Total_Shipment_Quantity
     FROM SO_LINES
     WHERE SHIPMENT_SCHEDULE_LINE_ID = P_Ship_Sched_Line_Id
     AND PARENT_LINE_ID IS NULL
     AND SERVICE_PARENT_LINE_ID IS NULL;

 SELECT SUM(NVL(ORDERED_QUANTITY,0) - NVL(CANCELLED_QUANTITY,0))
     INTO P_Open_Line_Quantity
     FROM SO_LINES
     WHERE LINE_ID = P_Ship_Sched_Line_Id;
 if (Nvl(P_Open_Line_Quantity,0) <> Nvl(P_Total_Shipment_Quantity,0)) ANd
      nvl(P_Total_Shipment_Quantity,0) <> 0 then
    P_Return_Status := OE_SHIPMENT_MISMATCH;
    return;
 else
    P_Ship_Sched_Line_Id := null;
 end if;

 P_Return_Status:=OE_SUCCESS;

Exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Match_Shipment_Quantity',
                                Operation=>'',
                                Object=>'SHIPMENT',
                                Message=>' When Others');

end Match_Shipment_Quantity;


PROCEDURE  Update_Line_Quantity
(
        P_Ship_Sched_Line_Id       IN OUT NUMBER,
        P_Total_Shipment_Quantity  IN OUT NUMBER,
        P_Open_Line_Quantity       IN OUT NUMBER,
        P_Line_Quantity            IN OUT NUMBER,
        P_Return_Status            OUT VARCHAR2
)
is

begin

 SELECT SUM(NVL(ORDERED_QUANTITY,0) - NVL(CANCELLED_QUANTITY,0))
     INTO P_Open_Line_Quantity
     FROM SO_LINES
     WHERE LINE_ID = P_Ship_Sched_Line_Id;

 UPDATE SO_LINES
     SET    ORDERED_QUANTITY = NVL(CANCELLED_QUANTITY,0)
                        + P_Total_Shipment_Quantity
     WHERE  LINE_ID = P_Ship_Sched_Line_Id;

 P_Return_Status:=OE_SUCCESS;

Exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_SHP_PROCESS.Update_Line_Quantity',
                                Operation=>'',
                                Object=>'SHIPMENT',
                                Message=>' When Others');

end Update_Line_Quantity;

PROCEDURE  Update_Parent_Option_Quantity
(
		P_Line_Id                  IN NUMBER,
		P_Total_Shipment_Quantity  IN NUMBER,
		P_Ordered_Quantity         IN NUMBER,
		P_Cancelled_Quantity       IN NUMBER,
		P_Return_Status            OUT VARCHAR2
)
is

x boolean;

begin

 UPDATE SO_LINES
 SET    ORDERED_QUANTITY = NVL(CANCELLED_QUANTITY,0) +
			 (((ORDERED_QUANTITY-NVL(CANCELLED_QUANTITY,0))/
		    (P_Ordered_Quantity-NVL(P_Cancelled_Quantity, 0)))
		 * P_Total_Shipment_Quantity)
	 WHERE  PARENT_LINE_ID  = P_Line_Id;

 P_Return_Status:=OE_SUCCESS;

Exception

  when others then
	   P_Return_Status:=OE_FAILURE;
		OE_MSG.Internal_Exception(Routine=>
				'OE_SHP_PROCESS.Update_Parent_Option_Quantity',
				Operation=>'',
				Object=>'SHIPMENT',
				Message=>' When Others');

end Update_Parent_Option_Quantity;


END OE_SHP_PROCESS;

/
