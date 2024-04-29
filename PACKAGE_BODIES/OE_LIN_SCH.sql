--------------------------------------------------------
--  DDL for Package Body OE_LIN_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LIN_SCH" AS
/* $Header: OEXLNSHB.pls 115.2 99/07/16 08:13:17 porting shi $ */

OE_SUCCESS  CONSTANT VARCHAR2(1) := 'Y';
OE_FAILURE  CONSTANT VARCHAR2(1) := 'N';


PROCEDURE Get_Reserved_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Reserved_Quantity         OUT NUMBER,
	P_Return_Status	            OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;


        SELECT  SUM( QUANTITY )
        INTO    P_Reserved_Quantity
        FROM    SO_LINE_DETAILS
        WHERE   SCHEDULE_STATUS_CODE = 'RESERVED'
        AND     LINE_ID = P_Line_Id
        AND     NVL ( INCLUDED_ITEM_FLAG , 'N' ) = 'N';


exception

  when no_data_found then
       P_Reserved_Quantity := 0;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Get_Reserved_Quantity',
                                Operation=>'Scheduling',
				Object=>'LINE',
                                Message=>' When Others');


end Get_Reserved_Quantity;

PROCEDURE Get_Released_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Config_Item_Exists IN VARCHAR2,
        P_Line_Released_Quantity      OUT NUMBER,
	P_Return_Status			  OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;


SELECT  NVL ( SUM ( QUANTITY ) , 0 )
INTO    P_Line_released_Quantity
FROM    SO_LINE_DETAILS
WHERE   LINE_ID = P_Line_Id
AND     NVL ( INCLUDED_ITEM_FLAG , 'N' ) = 'N'
AND     NVL ( RELEASED_FLAG , 'Y' ) = 'Y'
AND     NVL ( CONFIGURATION_ITEM_FLAG , 'N' ) =
        DECODE ( P_Config_Item_Exists , 'Y' , 'Y' , 'N' );



exception

  when no_data_found then
       P_Line_released_Quantity:=0;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Get_Released_Quantity',
                                Operation=>'Scheduling',
				Object=>'LINE',
                                Message=>' When Others');


end Get_Released_Quantity;


PROCEDURE Check_Details_Complexity
(
        P_Line_Id                   IN NUMBER,
        Details_Complexity_Count          OUT NUMBER,
	P_Return_Status			  OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;


SELECT COUNT(*)
INTO   Details_Complexity_Count
FROM   SO_LINE_DETAILS
WHERE  LINE_ID = P_Line_Id
AND     NVL ( RELEASED_FLAG , 'N' ) = 'N'
GROUP BY COMPONENT_CODE
HAVING COUNT ( DisTINCT WAREHOUSE_ID ) > 1
OR     COUNT ( DisTINCT SCHEDULE_DATE ) > 1
OR     COUNT ( DisTINCT REVISION ) > 1
OR     COUNT ( DisTINCT LOT_NUMBER ) > 1
OR     COUNT ( DisTINCT SUBINVENTORY ) > 1
OR     COUNT ( DisTINCT DEMAND_CLASS_CODE ) > 1
OR   ( COUNT ( SUBINVENTORY ) > 0
AND    COUNT ( SUBINVENTORY ) <> COUNT ( * ) )
OR   ( COUNT ( WAREHOUSE_ID ) > 0
AND    COUNT ( WAREHOUSE_ID ) <> COUNT ( * ) )
OR   ( COUNT ( SCHEDULE_DATE ) > 0
AND    COUNT ( SCHEDULE_DATE ) <> COUNT ( * ) )
OR   ( COUNT ( LOT_NUMBER ) > 0
AND    COUNT ( LOT_NUMBER ) <> COUNT ( * ) )
OR   ( COUNT ( REVisION ) > 0
AND    COUNT ( REVisION ) <> COUNT ( * ) )
OR   ( COUNT ( DEMAND_CLASS_CODE ) > 0
AND    COUNT ( DEMAND_CLASS_CODE ) <> COUNT ( * ) );


exception
   when no_data_found then
        Details_Complexity_Count:=0;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Check_Details_Complexity',
                                Operation=>'Scheduling',
				Object=>'LINE',
                                Message=>' When Others');


end Check_Details_Complexity;

PROCEDURE Get_Scheduling_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Config_Item_Exists IN VARCHAR2,
        P_Reserved_Quantity         OUT NUMBER,
        P_Line_Released_Quantity      OUT NUMBER,
        Details_Complexity_Count          OUT NUMBER,
	P_Return_Status			  IN OUT VARCHAR2
)

is

begin

	P_Return_Status:=OE_SUCCESS;


        OE_LIN_SCH.Get_Reserved_Quantity(
                P_Line_Id=>P_Line_Id,
                P_Reserved_Quantity=>P_Reserved_Quantity,
		P_Return_Status=>P_Return_Status
                 );

	if ( P_Return_Status = OE_FAILURE ) then
	   return;
	end if;


        OE_LIN_SCH.Get_Released_Quantity(
                P_Line_Id=>P_Line_Id,
                P_Config_Item_Exists=>
                P_Config_Item_Exists,
                P_Line_Released_Quantity=>
                P_Line_Released_Quantity,
		P_Return_Status=>P_Return_Status);

	if ( P_Return_Status = OE_FAILURE ) then
	   return;
	end if;


       OE_LIN_SCH.Check_Details_Complexity(
                P_Line_Id=>P_Line_Id,
                Details_Complexity_Count=>Details_Complexity_Count,
		P_Return_Status=>P_Return_Status
                );

end;

PROCEDURE Check_Scheduling_Quantity
(
        P_Line_Id                   IN NUMBER,
        P_Config_Item_Exists        IN VARCHAR2,
        P_Ordered_Quantity          IN NUMBER,
        P_Cancelled_Quantity        IN NUMBER,
        P_Reserved_Quantity         IN OUT NUMBER,
        Return_Status                     IN OUT VARCHAR2
)

is

  L_Details_Complexity_Count          NUMBER;
  L_Released_Quantity                 NUMBER;
  L_Reserved_Quantity                 NUMBER;

begin
        Return_Status:=OE_SUCCESS;

        OE_LIN_SCH.Get_Scheduling_Quantity(
			P_Line_Id,
        		P_Config_Item_Exists,
        		L_Reserved_Quantity,
        		L_Released_Quantity,
        		L_Details_Complexity_Count,
			Return_Status
			);

	if ( Return_Status = OE_FAILURE ) then
	   return;
	end if;

        if (nvl(P_Reserved_Quantity,0) > (nvl(P_Ordered_Quantity,0) -
                                         nvl(P_Cancelled_Quantity,0) )) then
            OE_MSG.Set_Buffer_Message('OE_SCH_RES_MORE_ORD_QTY','','');
            Return_Status:=OE_FAILURE;
            Return;
	elsif (nvl(P_Reserved_Quantity,0) < nvl(L_Released_Quantity,0)) then
    OE_MSG.Set_Buffer_Message('OE_SCH_RES_LESS_REL_QTY','RELEASED_QUANTITY',to_char(L_Released_Quantity));
            Return_Status:=OE_FAILURE;
            Return;
        else
            if L_Details_Complexity_Count > 0 then
            	OE_MSG.Set_Buffer_Message('OE_SCH_COMPLEX_DETAILS','','');
            	Return_Status:=OE_FAILURE;
            	Return;
            end if;
        end if;


end;

PROCEDURE Get_Schedule_Status
(

        P_Line_Id                         IN NUMBER,
        P_Schedule_Status_Code            IN OUT VARCHAR2,
        P_Schedule_Status_Name            OUT VARCHAR2,
        P_Schedule_Action_Code            OUT VARCHAR2,
        P_Return_Status                   OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;


P_Schedule_Action_Code := null;
P_Schedule_Status_Code := null;
P_Schedule_Status_Name := null;

SELECT DECODE( NVL( SUM( DECODE( SCHEDULE_STATUS_CODE,
           'RESERVED', QUANTITY, 0 ) ), 0 ),
       0,
       DECODE( NVL( SUM( DECODE( SCHEDULE_STATUS_CODE,
           'SUPPLY RESERVED', QUANTITY, 0 ) ), 0 ),
       0,
       DECODE( NVL( SUM( DECODE( SCHEDULE_STATUS_CODE,
           'DEMANDED', QUANTITY, 0 ) ), 0 ),
       0, NULL,
       'DEMANDED' ),
       'SUPPLY RESERVED' ),
       'RESERVED' )
	INTO   P_Schedule_Status_Code
	FROM   SO_LINE_DETAILS
	WHERE  LINE_ID = P_Line_Id;

SELECT MEANING
	INTO   P_Schedule_Status_Name
	FROM   SO_LOOKUPS
	WHERE  LOOKUP_TYPE = 'SCHEDULE STATUS'
	AND  LOOKUP_CODE = P_Schedule_Status_Code;

exception

  when no_data_found then
       null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Get_Schedule_Status',
                                Operation=>'Scheduling',
				Object=>'LINE',
                                Message=>' When Others');

end;


PROCEDURE Get_Schedule_DB_Values
(
        P_Row_Id                          IN VARCHAR2,
        P_Line_Id                         IN NUMBER,
        P_schedule_date                   OUT VARCHAR2,
        P_demand_Class_Code               OUT VARCHAR2,
        P_Ship_To_Site_Use_Id             OUT NUMBER,
        P_Warehouse_id                    OUT Number,
        P_Ship_To_Contact_Id              OUT NUMBER,
        P_Shipment_Priority_Code          OUT VARCHAR2,
        P_Ship_Method_Code                OUT VARCHAR2,
        P_Schedule_Date_Svrid             OUT NUMBER,
        P_Demand_Class_Svrid              OUT NUMBER,
        P_Ship_To_Svrid                   OUT NUMBER,
        P_Warehouse_Svrid                 OUT NUMBER,
        P_Ordered_Quantity                OUT NUMBER,
        P_Unit_Code                       OUT VARCHAR2,
        P_Reserved_Quantity               OUT NUMBER,
        P_Return_Status                   OUT VARCHAR2

) is


begin

      P_Return_Status:=OE_SUCCESS;

        SELECT      SCHEDULE_DATE
                ,   DEMAND_CLASS_CODE
                ,   SHIP_TO_SITE_USE_ID
                ,   WAREHOUSE_ID
                ,   SHIP_TO_CONTACT_ID
                ,   SHIPMENT_PRIORITY_CODE
                ,   SHIP_METHOD_CODE
                ,   SCHEDULE_DATE_SVRID
                ,   DEMAND_CLASS_SVRID
                ,   SHIP_TO_SVRID
                ,   WAREHOUSE_SVRID
                ,   ORDERED_QUANTITY
                ,   UNIT_CODE
        INTO        P_SCHEDULE_DATE
                ,   P_DEMAND_CLASS_CODE
                ,   P_SHIP_TO_SITE_USE_ID
                ,   P_WAREHOUSE_ID
                ,   P_SHIP_TO_CONTACT_ID
                ,   P_SHIPMENT_PRIORITY_CODE
                ,   P_SHIP_METHOD_CODE
                ,   P_SCHEDULE_DATE_SVRID
                ,   P_DEMAND_CLASS_SVRID
                ,   P_SHIP_TO_SVRID
                ,   P_WAREHOUSE_SVRID
                ,   P_ORDERED_QUANTITY
                ,   P_UNIT_CODE
        FROM    SO_LINES
        WHERE   ROWID = P_Row_id;


        SELECT  SUM ( NVL ( QUANTITY , 0 ) )
        INTO    P_RESERVED_QUANTITY
        FROM    SO_LINE_DETAILS
        WHERE   SCHEDULE_STATUS_CODE = 'RESERVED'
        AND     LINE_ID = P_Line_Id
        AND     NVL ( INCLUDED_ITEM_FLAG , 'N' ) = 'N';

        P_Return_Status:=OE_SUCCESS;


exception

 when no_data_found then
      P_Reserved_Quantity:=NULL;
      P_Return_Status:=OE_SUCCESS;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Get_Schedule_DB_Values',
                                Operation=>'Scheduling',
				Object=>'LINE',
                                Message=>' When Others');

end;


PROCEDURE Validate_Scheduling_Attributes
(
        P_DB_Record_Flag                  IN VARCHAR2,
        P_Lin_Obj_Schedule_Action_Code    IN VARCHAR2,
        P_Lin_Obj_Reserved_Quantity       IN NUMBER,
        P_Lin_Obj_Ordered_Quantity        IN NUMBER,
        P_Lin_Obj_Ship_To_Site_Use_Id     IN NUMBER,
        P_Lin_Obj_Warehouse_Id            IN Number,
        P_Lin_Obj_Schedule_Date           IN DATE,
        P_Lin_Obj_Demand_Class_Code       IN VARCHAR2,
        P_Row_Id                          IN VARCHAR2,
        P_Line_Id                         IN NUMBER,
        P_World_DB_schedule_date          IN OUT VARCHAR2,
        P_World_DB_demand_Class_Code      IN OUT VARCHAR2,
        P_World_DB_Ship_To_Site_Use_Id    IN OUT NUMBER,
        P_World_DB_Warehouse_id           IN OUT Number,
        P_World_DB_Ship_To_Contact_Id     IN OUT NUMBER,
        P_World_DB_Ship_Priority_Code     IN OUT VARCHAR2,
        P_World_DB_Ship_Method_Code       IN OUT VARCHAR2,
        P_World_DB_Schedule_Date_Svrid    IN OUT NUMBER,
        P_World_DB_Demand_Class_Svrid     IN OUT NUMBER,
        P_World_DB_Ship_To_Svrid          IN OUT NUMBER,
        P_World_DB_Warehouse_Svrid        IN OUT NUMBER,
        P_World_DB_Ordered_Quantity       IN OUT NUMBER,
        P_World_DB_Unit_Code              IN OUT VARCHAR2,
        P_World_DB_Reserved_Quantity      IN OUT NUMBER,
        P_Return_Status                   IN OUT VARCHAR2

)
is


begin

P_Return_Status:=OE_SUCCESS;

if ( P_DB_Record_Flag = 'N' ) then
   if ( P_Lin_Obj_Schedule_Action_Code is NULL
        or P_Lin_Obj_Schedule_Action_Code =  'RESERVE' ) then
      return;
   elsif ( P_Lin_Obj_Schedule_Action_Code not in ( 'DEMAND', 'ATP CHECK')) then
        if ( P_Lin_Obj_Reserved_Quantity is null
             or P_Lin_Obj_Reserved_Quantity = 0   ) then
           return;
        else
           OE_MSG.Set_Buffer_Message('OE_SCH_NO_RES_QTY_REQUIRED','','');
           P_Return_Status:=OE_FAILURE;
           return;
        end if;
   end if;
end if;

OE_LIN_SCH.Get_Schedule_DB_Values(
        P_Row_Id=>P_Row_Id,
        P_Line_Id=>P_Line_Id,
        P_schedule_date=>P_World_DB_schedule_date,
        P_demand_Class_Code=>P_World_DB_demand_Class_Code,
        P_Ship_To_Site_Use_Id=>P_World_DB_Ship_To_Site_Use_Id,
        P_Warehouse_id=>P_World_DB_Warehouse_id,
        P_Ship_To_Contact_Id=>P_World_DB_Ship_To_Contact_Id,
        P_Shipment_Priority_Code=>P_World_DB_Ship_Priority_Code,
        P_Ship_Method_Code=>P_World_DB_Ship_Method_Code,
        P_Schedule_Date_Svrid=>P_World_DB_Schedule_Date_Svrid,
        P_Demand_Class_Svrid=>P_World_DB_Demand_Class_Svrid,
        P_Ship_To_Svrid=>P_World_DB_Ship_To_Svrid,
        P_Warehouse_Svrid=>P_World_DB_Warehouse_Svrid,
        P_Ordered_Quantity=>P_World_DB_Ordered_Quantity,
        P_Unit_Code=>P_World_DB_Unit_Code,
        P_Reserved_Quantity=>P_World_DB_Reserved_Quantity,
        P_Return_Status=>P_Return_Status);

if ( P_return_Status = OE_FAILURE ) then
   return;
end if;

if ( P_Lin_Obj_Schedule_Action_Code is null ) then
   if ( P_Lin_Obj_Reserved_quantity <> P_World_DB_Reserved_Quantity ) then
     if ( P_Lin_Obj_Ordered_Quantity <> P_world_DB_Ordered_Quantity ) then
           OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED','','');
           P_Return_Status:=OE_FAILURE;
           return;
    end if;
  end if;
else
     if ( P_Lin_Obj_Ordered_Quantity <> P_world_DB_Ordered_Quantity ) then
           OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED','','');
           P_Return_Status:=OE_FAILURE;
           return;
    end if;
end if;

if ( P_Lin_Obj_Schedule_Action_Code is null ) then
   return;
elsif ( P_Lin_Obj_Schedule_Action_Code in ( 'UNRESERVE', 'UNDEMAND',
                                            'UNSCHEDULE') ) then
      if ( P_Lin_Obj_Reserved_quantity <> P_World_DB_Reserved_Quantity )
         then
           OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED','','');
           P_Return_Status:=OE_FAILURE;
           return;
      elsif ( P_Lin_Obj_Warehouse_Id <> P_world_DB_Warehouse_Id )
         then
           OE_MSG.Set_Buffer_Message('OE_SCH_WH_CHG_NOT_ALLOWED','','');
           P_Return_Status:=-1;
           return;
      elsif ( P_Lin_Obj_Schedule_Date <> P_World_DB_Schedule_Date )
         then
            OE_MSG.Set_Buffer_Message('OE_SCH_DATE_CHG_NOT_ALLOWED','','');
           P_Return_Status:=OE_FAILURE;
            return;
     elsif ( P_Lin_Obj_Demand_Class_Code <> P_World_DB_Demand_Class_Code) then
            OE_MSG.Set_Buffer_Message('OE_SCH_DEM_CL_CHG_NOT_ALLOWED','','');
           P_Return_Status:=OE_FAILURE;
            return;
     end if;
elsif ( P_Lin_Obj_Schedule_Action_Code in ( 'ATP CHECK', 'DEMAND')) then
   if ( P_Lin_Obj_Schedule_Action_Code = 'ATP CHECK' ) then
     if ( P_Lin_Obj_Ship_To_Site_Use_Id <> P_World_DB_Ship_To_Site_Use_Id ) then
          OE_MSG.Set_Buffer_Message('OE_SCH_SHIP_TO_CHG_NOT_ALLOWED','','');
           P_Return_Status:=OE_FAILURE;
          return;
     end if;
   end if;
   if ( P_Lin_Obj_Reserved_quantity <> P_World_DB_Reserved_Quantity )
      then
        OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED','','');
        P_Return_Status:=OE_FAILURE;
        return;
   end if;
elsif ( P_Lin_Obj_Schedule_Action_Code in ( 'RESERVE') ) then
   if ( P_Lin_Obj_Reserved_quantity <> P_World_DB_Reserved_Quantity )
      then
        OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED','','');
        P_Return_Status:=OE_FAILURE;
        return;
   end if;
end if;

exception

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Validate_Scheduling_Attributes',
                                Operation=>'',
                                Object=>'LINE',
                                Message=>' When Others');


end;


PROCEDURE Scheduling_Security
(
        Attribute                           IN VARCHAR2,
        ATO_Model_Flag                      IN VARCHAR2,
        ATO_Line_Id                         IN NUMBER,
        Supply_Reservation_Exists           IN VARCHAR2,
        DB_Record_Flag                      IN VARCHAR2,
        Source_Object                       IN VARCHAR2,
        Order_Category                      IN VARCHAR2,
        Row_Id                              IN VARCHAR2,
        Return_Status                       OUT VARCHAR2
)

is

        L_Count NUMBER;
        L_Return_Status VARCHAR2(1);

begin

        OE_LIN.Fully_Released(
                    Row_Id,
                    L_Return_Status);
        if ( L_Return_Status = 'N' ) then
             Return_Status:='N';
             return;
        end if;

        OE_LIN.Fully_Cancelled(
                    Row_Id,
                    L_Return_Status);
        if ( L_Return_Status = 'N' ) then
             Return_Status:='N';
             return;
        end if;

        Return_Status:='Y';

exception

 when others then
      Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN_SCH.Scheduling_Security',
                                Operation=>'',
				Object=>'LINE',
                                Message=>' When Others');

end Scheduling_Security;

-- The following package need to be removed
-- after the c code is checked in. - Rajan

PROCEDURE Query_Reserved_Quantity
(

        P_Line_Id                         IN NUMBER,
        P_Reservations                    IN VARCHAR2,
        P_Reserved_Quantity               OUT NUMBER,
        P_Return_Status                   OUT VARCHAR2
)
is

begin

P_Return_Status:=OE_SUCCESS;


if ( P_Reservations <> 'Y' ) then
   P_Reserved_Quantity := NULL;
   return;
end if;

SELECT  SUM( QUANTITY )
   INTO    P_Reserved_Quantity
   FROM    SO_LINE_DETAILS
   WHERE   SCHEDULE_STATUS_CODE = 'RESERVED'
   AND     LINE_ID = P_Line_Id
   AND     NVL ( INCLUDED_ITEM_FLAG , 'N' ) = 'N';

exception

  when no_data_found then
       null;

 when others then
      P_Return_Status:=OE_FAILURE;
      OE_MSG.Internal_Exception(Routine=>
                                'OE_LIN.Query_Reserved_Quantity',
                                Operation=>'Scheduling',
                                Object=>'LINE',
                                Message=>' When Others');

end;

end OE_LIN_SCH;

/
