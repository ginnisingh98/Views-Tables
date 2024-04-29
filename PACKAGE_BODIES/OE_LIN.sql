--------------------------------------------------------
--  DDL for Package Body OE_LIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LIN" AS
/* $Header: OEXLINSB.pls 115.2 99/07/16 08:13:11 porting shi $ */

OE_SUCCESS  CONSTANT VARCHAR2(1) := 'Y';
OE_FAILURE  CONSTANT VARCHAR2(1) := 'N';
OE_BOOKED      CONSTANT INTEGER:= 1;


PROCEDURE  Check_Allow_Manual_Discount
(
        P_Price_List_Id           	     IN    NUMBER,
        P_Order_Price_List_Id		     IN    NUMBER,
        P_Order_Order_Type_Id     	     IN    NUMBER,
        P_Header_Id            		     IN    NUMBER,
        P_Line_Id               	     IN    NUMBER,
        P_List_Price             	     IN    NUMBER,
        P_Discounting_Privilage   	     IN    VARCHAR2,
        P_Global_Result           	     OUT   VARCHAR2,
        P_Check_Multiple_Adj_Flag            IN    VARCHAR2 DEFAULT 'Y'

)
is
P_REASON    varchar2(100);
begin
    OE_LIN.Check_Manual_Discount_Priv(
        X_Price_List_Id=>P_Price_List_Id,
        X_Order_Price_List_Id=>P_Order_Price_List_Id,
        X_Order_Order_Type_Id=>P_Order_Order_Type_Id,
        X_Header_Id=>P_Header_Id,
        X_Line_Id=>P_Line_Id,
        X_List_Price=>P_List_Price,
        X_Discounting_Privilage=>P_Discounting_Privilage,
        X_Global_Result=>P_Global_Result,
        X_Reason=>P_Reason,
        X_Check_Multiple_Adj_Flag=>P_Check_Multiple_Adj_Flag
        );
end;

PROCEDURE Check_Manual_Discount_Priv
(
        X_Price_List_Id                      IN    NUMBER,
        X_Order_Price_List_Id                IN    NUMBER,
        X_Order_Order_Type_Id                IN    NUMBER,
        X_Header_Id                          IN    NUMBER,
        X_Line_Id                            IN    NUMBER,
        X_List_Price                         IN    NUMBER,
        X_Discounting_Privilage              IN    VARCHAR2,
        X_Global_Result                      OUT   VARCHAR2,
        X_Reason                             OUT   VARCHAR2,
        X_Check_Multiple_Adj_Flag            IN    VARCHAR2 DEFAULT 'Y'
)
is
L_Dummy NUMBER;
begin

  X_Global_Result:=OE_SUCCESS;

  if (X_Discounting_Privilage='NONE') then
        OE_MSG.Set_Buffer_Message('OE_MANDIS_DISALLOWED',
           'REASON','OE_MANDIS_NO_PRIVILEGE');
        X_Global_Result:=OE_FAILURE;
        X_Reason := 'OE_MANDIS_NO_PRIVILEGE';
        Return;
  ELSif ( X_List_Price > 0 ) then
     begin
       SELECT NULL INTO L_Dummy
       FROM SO_DisCOUNTS
       WHERE PRICE_LisT_ID = NVL(X_PRICE_LIST_ID,X_Order_PRICE_LIST_ID)
/* Bug 524620 - do not check manual discount condition unless seling price
                is being changed, in which case X_Check_Multiple_Adj_Flag is
                passed as 'Y'.   */
/*     AND NVL(AUTOMATIC_DisCOUNT_FLAG,'N') = 'N' AND ROWNUM = 1;     */
       AND (NVL(AUTOMATIC_DisCOUNT_FLAG,'N') = 'N'
            OR X_Check_Multiple_Adj_Flag = 'N')
       AND ROWNUM = 1;
       begin
         SELECT NULL INTO L_Dummy
                FROM SO_ORDER_TYPES
                WHERE ORDER_TYPE_ID = X_Order_ORDER_TYPE_ID
                AND ((ENFORCE_LINE_PRICES_FLAG = 'Y'
                AND X_Discounting_Privilage = 'UNLIMITED')
                OR ENFORCE_LINE_PRICES_FLAG = 'N') AND ROWNUM = 1;
         if (X_Check_Multiple_Adj_Flag = 'Y') then
           begin
              SELECT NULL INTO L_Dummy
                FROM   SO_PRICE_ADJUSTMENTS
                WHERE  HEADER_ID = X_HEADER_ID
                AND    LINE_ID   = X_LINE_ID
                AND    NVL( AUTOMATIC_FLAG, 'N' ) = 'N'
                HAVING COUNT(*) > 1;
        	OE_MSG.Set_Buffer_Message('OE_MANDIS_DISALLOWED',
           	'REASON','OE_MANDIS_TOO_MANY');
        	X_Global_Result:=OE_FAILURE;
                X_Reason := 'OE_MANDIS_TOO_MANY';
        	Return;
           exception
                when no_data_found then
                X_Global_Result:=OE_SUCCESS;
                return;
           end;
         end if;
       exception
                when no_data_found then
        	OE_MSG.Set_Buffer_Message('OE_MANDIS_DISALLOWED',
           	'REASON','OE_MANDIS_PRICES_ENFORCED');
        	X_Global_Result:=OE_FAILURE;
                X_Reason := 'OE_MANDIS_PRICES_ENFORCED';
        	Return;
       end;

     exception
                when no_data_found then
        	OE_MSG.Set_Buffer_Message('OE_MANDIS_DISALLOWED',
           	'REASON','OE_MANDIS_NO_DISCOUNT');
        	X_Global_Result:=OE_FAILURE;
                X_Reason := 'OE_MANDIS_NO_DISCOUNT';
        	Return;
     end;
  /*else no else is required as this condition is tetsted at the time of
     selling_price validation too
      441551
       	OE_MSG.Set_Buffer_Message('OE_MANDIS_DISALLOWED',
       	'REASON','OE_MANDIS_NO_LIST_PRICE');
       	X_Global_Result:=OE_FAILURE;
        X_Reason := 'OE_MANDIS_NO_LIST_PRICE';
       	Return;
     */
  end if;

exception

 when others then
      X_Global_Result:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Check_Allow_Manual_Discount',
                                Operation=>'Pricing',
				Object=>'LINE',
                                Message=>' When Others');


end Check_Manual_Discount_Priv;

PROCEDURE Apply_Manual_Discount
(
        P_Manual_Discount_Id                IN NUMBER,
        P_List_Price                        IN NUMBER,
        P_List_Percent                      IN NUMBER,
        P_Selling_Price                     IN NUMBER,
        P_Manual_Discount_Percent           IN NUMBER,
        P_Pricing_Method_Code               IN VARCHAR2,
        P_Selling_Percent                   OUT NUMBER,
        P_Header_Id                         IN NUMBER,
        P_Line_Id                           IN NUMBER,
        P_User_Id                           IN NUMBER,
        P_Login_Id                          IN NUMBER,
        P_Manual_Discount_Line_Id           IN NUMBER,
        P_Price_List_Id             IN NUMBER,
        P_Order_Price_List_Id               IN NUMBER,
        P_Order_Order_Type_Id               IN NUMBER,
        P_Discounting_Privilage             IN VARCHAR2,
        P_Adjustment_Total          OUT NUMBER,
        P_Global_Result                     OUT VARCHAR2
)

is

L_Global_Result VARCHAR2(1);
dummy           NUMBER;

begin

    P_Global_Result:=OE_SUCCESS;

    OE_LIN.Check_Allow_Manual_Discount(
                P_Price_List_Id=>P_Price_List_Id,
                P_Order_Price_List_Id=>P_Order_Price_List_Id,
                P_Order_Order_Type_Id=>P_Order_Order_Type_Id,
                P_Header_Id=>P_Header_Id   ,
                P_Line_Id=>P_Line_Id    ,
                P_List_Price=>P_List_Price       ,
                P_Discounting_Privilage=>P_Discounting_Privilage,
                P_Global_Result=>L_Global_Result
                );
    P_Global_Result:=L_Global_Result;


    if ( L_Global_Result <> 'Y' ) then
       return;
    elsif (NVL(P_LisT_PRICE,0) = 0 ) then
       return;
    end if;

    if (P_MANUAL_DisCOUNT_PERCENT is null ) then
       return;
    end if;


     if P_MANUAL_DisCOUNT_PERCENT <> 0 then
         if P_PRICING_METHOD_CODE = 'PERC' then
              P_SELLING_PERCENT := P_LisT_PERCENT * P_SELLING_PRICE
                                                  / P_LisT_PRICE;
         end if;
         begin

             SELECT NULL INTO dummy FROM
	            	SO_PRICE_ADJUSTMENTS
                        WHERE   HEADER_ID = P_HEADER_ID
                        AND     LINE_ID = P_LINE_ID
                        AND     AUTOMATIC_FLAG = 'N';

             UPDATE  SO_PRICE_ADJUSTMENTS
                     SET     PERCENT =
                                        P_MANUAL_DisCOUNT_PERCENT
                                ,       DisCOUNT_ID =
                                        P_MANUAL_DisCOUNT_ID
                                ,       LAST_UPDATE_DATE =
                                        SYSDATE
                                ,       LAST_UPDATED_BY =
                                        P_USER_ID
                                ,       LAST_UPDATE_LOGIN =
                                        P_LOGIN_ID
                                WHERE   HEADER_ID = P_HEADER_ID
                                AND     LINE_ID = P_LINE_ID
                                AND     AUTOMATIC_FLAG = 'N';
             P_Adjustment_Total := null;
             return;
	   exception

               when no_data_found then

               INSERT INTO SO_PRICE_ADJUSTMENTS
                                (      PRICE_ADJUSTMENT_ID
                                ,      CREATION_DATE
                                ,      CREATED_BY
                                ,      LAST_UPDATE_DATE
                                ,      LAST_UPDATED_BY
                                ,      LAST_UPDATE_LOGIN
                                ,      HEADER_ID
                                ,      LINE_ID
                                ,      DisCOUNT_ID
                                ,      DisCOUNT_LINE_ID
                                ,      AUTOMATIC_FLAG
                                ,      PERCENT)
                                VALUES
                                (      SO_PRICE_ADJUSTMENTS_S.NEXTVAL
                                ,      SYSDATE
                                ,      P_USER_ID
                                ,      SYSDATE
                                ,      P_USER_ID
                                ,      P_LOGIN_ID
                                ,      P_HEADER_ID
                                ,      P_LINE_ID
                                ,      P_MANUAL_DisCOUNT_ID
                                ,      P_MANUAL_DisCOUNT_LINE_ID
                                ,      'N'
                                ,      P_MANUAL_DisCOUNT_PERCENT);

             P_Adjustment_Total := null;
         end;

     else
                        DELETE FROM SO_PRICE_ADJUSTMENTS
                                     WHERE  HEADER_ID = P_HEADER_ID
                                     AND    LINE_ID = P_LINE_ID
                                     AND    AUTOMATIC_FLAG = 'N';

     end if;

exception
 when no_data_found then
        P_Global_Result:=L_Global_Result;

 when others then
      P_Global_Result:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Apply_Manual_Discount',
                                Operation=>'Pricing',
				Object=>'LINE',
                                Message=>' When Others');



end Apply_Manual_Discount;


PROCEDURE Get_Line_Object_Adj_Total
(
        Order_Header_Id               IN    NUMBER,
        Lin_Obj_Line_Id               IN    NUMBER,
        Lin_Obj_Apply_Order_Adjs_Flag IN    VARCHAR2,
        P_Automatic_Flag              IN    VARCHAR2,
        Lin_Obj_Adjustment_Total      OUT   NUMBER,
        P_Return_Status               OUT   VARCHAR2
)
is

begin

        P_Return_Status:=OE_SUCCESS;

        SELECT NVL( SUM( NVL( PERCENT, 0 ) ), 0 )
        INTO   Lin_Obj_Adjustment_Total
        FROM   SO_PRICE_ADJUSTMENTS
        WHERE  HEADER_ID = Order_Header_Id
        AND (( Lin_Obj_Apply_Order_Adjs_Flag = 'Y'
        AND    LINE_ID is NULL )
        OR   ( LINE_ID = Lin_Obj_Line_Id
        AND    AUTOMATIC_FLAG = NVL(P_Automatic_Flag,AUTOMATIC_FLAG)));



exception

       when no_data_found then
            null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Get_Line_Object_Adj_Total',
                                Operation=>'Pricing',
				Object=>'LINE',
                                Message=>' When Others');



end;


PROCEDURE ATO_Model
(
        ATO_Model_Flag                      IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
)
is


begin

        if (ATO_Model_Flag = 'Y') then
           OE_MSG.Set_Buffer_Message('OE_SCH_ATO_MODEL','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_Validate.ATO_Model',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');

end ATO_Model;

PROCEDURE ATO_Configuration
(
        ATO_Line_Id                         IN NUMBER,
        Return_Status                       OUT VARCHAR2
)
is


begin

        if (ATO_Line_Id is not null) then
           OE_MSG.Set_Buffer_Message('OE_SCH_LINE_PART_OF_ATO_CONFIG','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_Validate.ATO_Configuration',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');

end ATO_Configuration;

PROCEDURE Supply_Reserved
(
        Supply_Reservation_Exists           IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
)
is


begin

        if (Supply_Reservation_Exists='Y') then
           OE_MSG.Set_Buffer_Message('OE_SCH_LINE_HAS_SUPP_RES','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Supply_Reserved',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');

end Supply_Reserved;


PROCEDURE Check_Schedule_Group
(
        DB_Record_Flag                      IN VARCHAR2,
        Source_Object                       IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
)
is


begin

        if (DB_Record_Flag='Y' and Source_Object is not null) then
           OE_MSG.Set_Buffer_Message('OE_SCH_LINE_GROUP_MEMBER','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;
exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Check_Schedule_Group',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');


end Check_Schedule_Group;


PROCEDURE Internal_Order
(
        Order_Category                      IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
)
is


begin

        if (Order_Category='P') then
           OE_MSG.Set_Buffer_Message('OE_SCH_INT_ORDER_UPD','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Internal_Order',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');


end Internal_Order;


PROCEDURE Fully_Released
(
        Row_Id                            IN VARCHAR2,
        Return_Status                     OUT VARCHAR2
)

is

        L_Count NUMBER;

begin

        SELECT COUNT(*)
        INTO   L_Count
        FROM   SO_LINES
        WHERE  ROWID = Row_Id
        AND    S2 = 4;

        if L_Count = 1 then
           OE_MSG.Set_Buffer_Message('OE_SCH_LINE_FULLY_RELEASED','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Fully_Released',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');

end Fully_Released;



PROCEDURE Fully_Cancelled
(
        Row_Id                            IN VARCHAR2,
        Return_Status                     OUT VARCHAR2
)

is

        L_Count NUMBER;

begin


        SELECT COUNT(*)
        INTO   L_Count
        FROM   SO_LINES
        WHERE  ROWID = Row_Id
        AND    ORDERED_QUANTITY = NVL(CANCELLED_QUANTITY,0);

        if L_Count = 1 then
           OE_MSG.Set_Buffer_Message('OE_SCH_LINE_FULLY_CANCELLED','','');
           Return_Status:='N';
        else
           Return_Status:='Y';
        end if;

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Fully_Cancelled',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');

end Fully_Cancelled;

PROCEDURE Calc_Lin_Obj_Open_Quantity
(
        Lin_Obj_Ordered_Quantity        IN  NUMBER,
        Lin_Obj_Open_Quantity           OUT NUMBER,
        Lin_Obj_Cancelled_Quantity      IN  NUMBER,
        P_return_Status                 OUT VARCHAR2

)
is

begin

P_Return_Status:=OE_SUCCESS;

if Lin_Obj_Ordered_Quantity is null then
   Lin_Obj_Open_Quantity:=0;
ELSif Lin_Obj_Cancelled_Quantity is null then
   Lin_Obj_Open_Quantity:=Lin_Obj_Ordered_Quantity;
else
   Lin_Obj_Open_Quantity:=Lin_Obj_Ordered_Quantity -
                          Lin_Obj_Cancelled_Quantity;
end if;

exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Calc_Lin_Obj_Open_Quantity',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');


end Calc_Lin_Obj_Open_Quantity;


PROCEDURE Load_ATO_Flag
(
        P_Lin_Obj_Line_Id                   IN  NUMBER,
        P_Lin_Obj_Item_Type_Code            IN  VARCHAR2,
        P_Lin_Obj_ATO_Line_Id               IN  NUMBER,
        P_Lin_Obj_ATO_Flag                  IN  VARCHAR2,
        P_Lin_Obj_ATO_Model_Flag            IN OUT  VARCHAR2,
        P_Lin_Obj_Supply_Reserv_Exists     OUT VARCHAR2,
        P_Lin_Obj_Config_Item_Exists        OUT VARCHAR2,
        P_Return_Status                     OUT VARCHAR2
)

is

L_Dummy NUMBER;

begin

P_Lin_Obj_ATO_Model_Flag:='N';
P_Lin_Obj_Supply_Reserv_Exists:='N';
P_Lin_Obj_Config_Item_Exists :='N';


if (P_Lin_Obj_ATO_Flag = 'Y') then
    if (P_Lin_Obj_ATO_Line_Id is NULL ) then
        if (P_Lin_Obj_Item_Type_Code IN
                   ( 'MODEL', 'KIT' ) ) then
               P_Lin_Obj_ATO_Model_Flag:='Y';
         end if;
     else
         return;
     end if;
else
     return;
end if;

SELECT  NULL INTO L_Dummy
FROM    SO_LINE_DETAILS
WHERE   LINE_ID = P_Lin_Obj_Line_Id
AND     SCHEDULE_STATUS_CODE = 'SUPPLY RESERVED';

P_Lin_Obj_Supply_Reserv_Exists:='Y';

exception

when no_data_found then

  if (P_Lin_Obj_ATO_Model_Flag='Y') then

     begin

        SELECT  NULL INTO L_Dummy
        FROM    SO_LINE_DETAILS
        WHERE   NVL ( CONFIGURATION_ITEM_FLAG , 'N' ) = 'Y'
        AND     LINE_ID = P_Lin_Obj_Line_Id;

        P_Lin_Obj_Config_Item_Exists:='Y';

    exception

        when no_data_found then
             null;
    end;

  end if;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Load_ATO_Flag',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');


end Load_ATO_Flag;

PROCEDURE Check_Navigate_Shipments
(
        P_Header_Id                         IN  NUMBER,
        P_Line_Id                           IN  NUMBER,
        P_Order_S1                          IN  NUMBER,
        P_Config_Item_Exists                IN  VARCHAR2,
        P_Return_Status                     OUT VARCHAR2,
        P_ITEM_TYPE_CODE                    IN VARCHAR2 default null,
        P_SERVICE_INSTALLED                 IN VARCHAR2 default 'N'
)

is

L_Dummy NUMBER;

begin

 P_Return_Status:=OE_SUCCESS;

 if p_service_installed = 'Y' then
    l_dummy := null;
    if p_item_type_code = 'MODEL' then
       declare cursor service_exists(x_line_id number) is
               select line_id
               from so_lines
               where service_parent_line_id = x_line_id
               and nvl(ordered_quantity,0) - nvl(cancelled_quantity,0) > 0
                           union
               select lin.line_id
               from so_lines serv, so_lines lin
               where serv.service_parent_line_id = lin.line_id
               and nvl(serv.ordered_quantity,0) -
                         nvl(serv.cancelled_quantity,0) > 0
               and lin.parent_line_id = x_line_id;
         cursor installation_exists(x_line_id number) is
               select line_id
               from SO_LINE_SERVICE_DETAILS
               where line_id = x_line_id
                           union
               select lin.line_id
               from SO_LINE_SERVICE_DETAILS isd, so_lines lin
               where isd.line_id = lin.line_id
               and lin.parent_line_id = x_line_id;
       begin
          open service_exists(p_line_id);
          fetch service_exists into l_dummy;
          close service_exists;
          if l_dummy is not null then
             P_Return_Status:=OE_FAILURE;
             OE_MSG.Set_Buffer_Message('OE_LIN_SERVICES_EXISTS','','');
             return;
          end if;
          open installation_exists(p_line_id);
          fetch installation_exists into l_dummy;
          close installation_exists;
          if l_dummy is not null then
             P_Return_Status:=OE_FAILURE;
             OE_MSG.Set_Buffer_Message('OE_LIN_ISD_EXISTS','','');
             return;
          end if;
       end;
    else -- not a model
       declare cursor service_exists(x_line_id number) is
               select line_id
               from so_lines
               where service_parent_line_id = x_line_id
               and nvl(ordered_quantity,0) - nvl(cancelled_quantity,0) > 0;

         cursor installation_exists(x_line_id number) is
               select line_id
               from SO_LINE_SERVICE_DETAILS
               where line_id = x_line_id;
       begin
          open service_exists(p_line_id);
          fetch service_exists into l_dummy;
          close service_exists;
          if l_dummy is not null then
             P_Return_Status:=OE_FAILURE;
             OE_MSG.Set_Buffer_Message('OE_LIN_SERVICES_EXISTS','','');
             return;
          end if;
          open installation_exists(p_line_id);
          fetch installation_exists into l_dummy;
          close installation_exists;
          if l_dummy is not null then
             P_Return_Status:=OE_FAILURE;
             OE_MSG.Set_Buffer_Message('OE_LIN_ISD_EXISTS','','');
             return;
          end if;
       end;
    end if; -- item_type = MODEL
 end if; -- service installed

 SELECT NULL into L_Dummy
 FROM   SO_LINE_DETAILS
 WHERE  SCHEDULE_STATUS_CODE IS NOT NULL
 AND    LINE_ID IN
      (SELECT LINE_ID
       FROM   SO_LINES
       WHERE  HEADER_ID = P_Header_Id
       AND   (LINE_ID = P_Line_Id
              OR PARENT_LINE_ID = P_Line_Id))
       AND ROWNUM = 1;

 OE_MSG.Set_Buffer_Message('OE_OE_SCHEDULING_EXISTS','','');

 P_Return_Status:=OE_FAILURE;

 exception

 when no_data_found then

    if (P_Order_S1 =  OE_BOOKED) then
      begin
	SELECT NULL into L_Dummy
	FROM   SO_LINES
	WHERE  HEADER_ID = P_Header_Id
	AND   (LINE_ID = P_Line_Id
        OR PARENT_LINE_ID = P_Line_Id)
	AND   (S2 NOT IN (8,18)
        OR S5 NOT IN (8,18)
        OR S8 NOT IN (8,18)
        OR S25 NOT IN (8,18)
        OR P_Config_Item_Exists = 'Y'
        OR OPEN_FLAG IS NULL)
	AND ROWNUM = 1;

 	P_Return_Status:=OE_FAILURE;
        OE_MSG.Set_Buffer_Message('OE_OE_LINE_CONFIG_PROCESSED','','');
      exception
        when no_data_found then
	    null;
      end;
    end if;


 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Check_Navigate_Shipments',
                                Operation=>'',
                                Object=>'LINE',
                                Message=>' When Others');


end Check_Navigate_Shipments;

PROCEDURE Update_Shippable_Flag
(
        P_ATO_Option_Parent_Line            IN  NUMBER,
        P_Return_Status                     OUT VARCHAR2
)

is

L_Dummy NUMBER;

begin

 P_Return_Status:=OE_SUCCESS;

 UPDATE SO_LINE_DETAILS
 SET SHIPPABLE_FLAG = 'N'
 WHERE LINE_ID IN (  SELECT  L.LINE_ID
                    FROM    SO_LINES L
                    WHERE  ( PARENT_LINE_ID = P_ATO_Option_Parent_Line
                            AND ATO_LINE_ID IS NOT NULL)
                    OR     ( PARENT_LINE_ID = P_ATO_Option_Parent_Line
                            AND ATO_LINE_ID IS NULL
                            AND ATO_FLAG = 'Y'
                            AND ITEM_TYPE_CODE = 'MODEL')
                 );

 exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Update_Shippable_Flag',
                                Operation=>'',
                                Object=>'LINE',
                                Message=>' When Others');


end Update_Shippable_Flag;

end OE_LIN;

/
