--------------------------------------------------------
--  DDL for Package Body OE_SO_LIN_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SO_LIN_VALIDATE" AS
/* $Header: oesolinb.pls 115.3 99/07/16 08:28:20 porting ship $ */

FUNCTION DB_Reserved_Quantity (X_Line_Id IN NUMBER) return NUMBER is
  DB_Res_Qty NUMBER := NULL;
begin

  SELECT  SUM ( NVL ( QUANTITY , 0 ) )
  INTO    DB_Res_Qty
  FROM    SO_LINE_DETAILS
  WHERE   SCHEDULE_STATUS_CODE = 'RESERVED'
  AND     LINE_ID = X_Line_Id
  AND     NVL ( INCLUDED_ITEM_FLAG , 'N' ) = 'N';

  Return (DB_Res_Qty);

exception

  when NO_DATA_FOUND then return(DB_Res_Qty);
  when OTHERS then RAISE;

end DB_Reserved_Quantity;

PROCEDURE Validate_Reserved_Qty (
                P_Line_Id             IN NUMBER,
		P_Lines_Reserved_Qty  IN NUMBER,
		P_Lines_Ordered_Qty  IN NUMBER,
		P_Lines_Cancelled_Qty  IN NUMBER,
		P_Lines_Released_Qty  IN NUMBER,
		P_Result		OUT VARCHAR2
		) is
begin

  P_Result := 'Y';

  if (P_Lines_Reserved_Qty = OE_SO_LIN_VALIDATE.DB_Reserved_Quantity(P_Line_Id)) then
    Return;
  end if;

  if (P_Lines_Reserved_Qty > (NVL(P_Lines_Ordered_Qty,   0)
			    - NVL(P_Lines_Cancelled_Qty, 0) )) then
    OE_MSG.Set_Buffer_Message('OE_SCH_RES_MORE_ORD_QTY');
    P_Result := 'N';
    Return;
  elsif (P_Lines_Reserved_Qty < NVL(P_Lines_Released_Qty, 0) ) then
    OE_MSG.Set_Buffer_Message('OE_SCH_RES_LESS_REL_QTY','RELEASED_QUANTITY',to_char(P_Lines_Released_Qty));
    P_Result := 'N';
    Return;
  else
    if (OE_SO_LIN_VALIDATE.Complex_Details(P_Line_Id)) then
      OE_MSG.Set_Buffer_Message('OE_SCH_COMPLEX_DETAILS');
      P_Result := 'N';
      Return;
    end if;
  end if;

  Return;

end Validate_Reserved_Qty;



PROCEDURE Load_Item_Warehouse_Attributes(
		P_Inventory_Item_Id	IN	NUMBER,
		P_Organization_id	IN	NUMBER,
		P_Item_Desc		OUT	VARCHAR2,
		P_SO_Xactions_Flag	OUT	VARCHAR2,
		P_Reservable_Type	OUT	NUMBER,
		P_ATP_Flag		OUT	VARCHAR2,
		P_Result		OUT	VARCHAR2
		)
is
begin

    P_Result := 'Y';

    SELECT msi.description,
           msi.so_transactions_flag,
           msi.reservable_type,
           msi.atp_flag
    INTO   P_Item_Desc,
           P_SO_Xactions_Flag,
           P_Reservable_Type,
           P_ATP_Flag
    FROM   mtl_system_items msi
    WHERE  msi.inventory_item_id = P_Inventory_Item_Id
    AND    msi.organization_id   = P_Organization_Id;

exception
    when NO_DATA_FOUND then NULL;
    when OTHERS then P_Result := 'N';
end Load_Item_Warehouse_Attributes;




FUNCTION complex_details (x_line_id IN NUMBER) RETURN BOOLEAN IS
  complexDetails NUMBER := 0;
BEGIN

  SELECT min(1)
  INTO   complexDetails
  FROM   so_line_details
  WHERE  line_id = x_line_id
  AND    NVL( released_flag, 'N') = 'N'
  GROUP BY component_code
  HAVING   COUNT( DISTINCT warehouse_id)      >  1
  OR       COUNT( DISTINCT schedule_date)     >  1
  OR       COUNT( DISTINCT revision)          >  1
  OR       COUNT( DISTINCT lot_number)        >  1
  OR       COUNT( DISTINCT subinventory)      >  1
  OR       COUNT( DISTINCT demand_class_code) >  1
  OR       ( COUNT( subinventory)             >  0
      AND    COUNT( subinventory)             <> COUNT(1))
  OR       ( COUNT( warehouse_id)             >  0
      AND    COUNT( warehouse_id)             <> COUNT(1))
  OR       ( COUNT( schedule_date)            >  0
      AND    COUNT( schedule_date)            <> COUNT(1))
  OR       ( COUNT( lot_number)               >  0
      AND    COUNT( lot_number)               <> COUNT(1))
  OR       ( COUNT( revision)                 >  0
      AND    COUNT( revision)                 <> COUNT(1))
  OR       ( COUNT( demand_class_code)        >  0
      AND    COUNT( demand_class_code)        <> COUNT(1));

IF complexDetails = 1 THEN
  RETURN TRUE;
ELSE
  RETURN FALSE;
END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN RETURN FALSE;

END complex_details;


PROCEDURE Get_Schedule_DB_Values(
		    X_Row_Id			  IN  VARCHAR2
		,   X_Line_Id			  IN  NUMBER
		,   P_Db_Schedule_Date		  OUT DATE
	        ,   P_Db_Demand_Class_Code	  OUT VARCHAR2
	        ,   P_Db_Ship_To_Site_Use_Id	  OUT NUMBER
	        ,   P_Db_Warehouse_Id		  OUT NUMBER
	        ,   P_Db_Ship_To_Contact_Id  	  OUT NUMBER
	        ,   P_Db_Shipment_Priority_Code	  OUT VARCHAR2
	        ,   P_Db_Ship_Method_Code	  OUT VARCHAR2
	        ,   P_Db_Schedule_Date_Svrid 	  OUT NUMBER
	        ,   P_Db_Demand_Class_Svrid	  OUT NUMBER
	        ,   P_Db_Ship_To_Svrid  	  OUT NUMBER
	        ,   P_Db_Warehouse_Svrid  	  OUT NUMBER
	        ,   P_Db_Ship_Set_Number  	  OUT NUMBER
	        ,   P_Db_Ship_Set_Number_Svrid    OUT NUMBER
		,   P_Db_Reserved_Quantity  	  OUT NUMBER
		,   Result			  OUT VARCHAR2
		) is
begin

	Result := 'Y';

	SELECT      schedule_date
	        ,   demand_class_code
	        ,   ship_to_site_use_id
	        ,   warehouse_id
	        ,   ship_to_contact_id
	        ,   shipment_priority_code
	        ,   ship_method_code
	        ,   schedule_date_svrid
	        ,   demand_class_svrid
	        ,   ship_to_svrid
	        ,   warehouse_svrid
	        ,   ship_set_number
	        ,   ship_set_number_svrid
	INTO        P_Db_Schedule_Date
	        ,   P_Db_Demand_Class_Code
	        ,   P_Db_Ship_To_Site_Use_Id
	        ,   P_Db_Warehouse_Id
	        ,   P_Db_Ship_To_Contact_Id
	        ,   P_Db_Shipment_Priority_Code
	        ,   P_Db_Ship_Method_Code
	        ,   P_Db_Schedule_Date_Svrid
	        ,   P_Db_Demand_Class_Svrid
	        ,   P_Db_Ship_To_Svrid
	        ,   P_Db_Warehouse_Svrid
	        ,   P_Db_Ship_Set_Number
	        ,   P_Db_Ship_Set_Number_Svrid
	FROM    SO_LINES
	WHERE   rowid = X_Row_Id;

	P_Db_Reserved_Quantity :=
		OE_SO_LIN_VALIDATE.DB_Reserved_Quantity(X_Line_Id);

exception
  when OTHERS then
    OE_MSG.Internal_Exception('OE_SO_LIN_VALIDATE.Get_Schedule_DB_Values',
				'Get_DB_Values', 'LINE');
    Result := 'N';
end Get_Schedule_DB_Values;



PROCEDURE Query_Time_Stamps(
		X_Row_Id			IN VARCHAR2,
		X_Creation_Date			OUT DATE,
		X_Creation_Date_Time		OUT DATE,
		X_Std_Component_Freeze_Date	OUT DATE,
		X_Tax_Code			OUT VARCHAR2,
		X_Tax_Code_SVRID		OUT NUMBER,
		Result				OUT VARCHAR2
		) is
begin

  Result := 'Y';

--  if (P_Override_Tax_Code_Flag IS NOT NULL) then

	SELECT creation_date
	,      To_Date(To_Char( creation_date, 'YYYY/MM/DD HH24:MI' ),
		       'YYYY/MM/DD HH24:MI')
	,      To_Date(To_Char( standard_component_freeze_date,
			       'YYYY/MM/DD HH24:MI' ),'YYYY/MM/DD HH24:MI')
	,      tax_code
	,      tax_code_svrid
	INTO   X_Creation_Date
	,      X_Creation_Date_Time
	,      X_Std_Component_Freeze_Date
	,      X_Tax_Code
	,      X_Tax_Code_Svrid
	FROM   so_lines
	WHERE  rowid = X_Row_id;

--  else

--	SELECT creation_date
--	,      To_Date(To_Char( creation_date, 'YYYY/MM/DD HH24:MI' ),
--		       'YYYY/MM/DD HH24:MI')
--	,      To_Date(To_Char( standard_component_freeze_date,
--		       'YYYY/MM/DD HH24:MI' ),'YYYY/MM/DD HH24:MI')
--	INTO   X_Creation_Date
--	,      X_Creation_Date_Time
--	,      X_Standard_Component_Freeze_Date
--	FROM   so_lines
--	WHERE  rowid = X_Row_id;

--  end if;

exception

  when OTHERS then
    OE_MSG.Internal_Exception('OE_SO_LIN_VALIDATE.Query_Time_Stamps',
			      'Query Time Stamps' , 'LINE');
    Result := 'N';
end Query_Time_Stamps;


PROCEDURE Load_ATO_Model(
			X_Line_Id		IN     	NUMBER,
			X_ATO_Model		OUT    	VARCHAR2,
			X_ATO_Flag		IN     	VARCHAR2,
			X_ATO_Line_Id		IN     	NUMBER,
			X_Item_Type_Code	IN     	VARCHAR2,
			X_Configuration_Item_Exists OUT VARCHAR2,
			Result			OUT	VARCHAR2
		)
is
begin

  Result := 'Y';

  if ((X_AtO_Flag = 'Y') and
      (X_ATO_Line_Id is NULL) and
      (X_Item_Type_Code in ('MODEL', 'KIT'))) then
    X_ATO_Model := 'Y';

    X_Configuration_Item_Exists := 'N';

    SELECT 'Y'
    INTO   X_Configuration_Item_Exists
    FROM   dual
    WHERE  exists
	(SELECT 'CONFIG_ITEM'
  	 FROM   so_line_details
	 WHERE  line_id = X_Line_Id
	 AND    NVl(configuration_item_flag, 'N') = 'Y');

  else
    X_ATO_Model := 'N';
  end if;


exception

  when NO_DATA_FOUND then
	NULL;

  when OTHERS then
    OE_MSG.Internal_Exception('OE_SO_LIN_VALIDATE.Load_ATO_Model',
			      'Load_ATO_Model' , 'LINE');
    Result := 'N';
end Load_ATO_Model;


PROCEDURE  Load_Supply_Reserved(
			X_Line_Id		IN     	NUMBER,
			X_Supply_Res_Details    OUT 	VARCHAR2,
			Result			OUT	VARCHAR2
		)
is
begin

  Result := 'Y';
  X_Supply_Res_Details := 'N';

  SELECT 'Y'
  INTO   X_Supply_Res_Details
  FROM   dual
  WHERE  exists
	(SELECT 'SUPPLY_RESERVED'
	 FROM   so_line_details
	 WHERE  line_id = X_Line_id
	 AND    schedule_status_code = 'SUPPLY RESERVED');


exception

  when NO_DATA_FOUND then
	NULL;

  when OTHERS then
    OE_MSG.Internal_Exception('OE_SO_LIN_VALIDATE.Load_Supply_Reserved',
			      'Load Supply Reserved' , 'LINE');
    Result := 'N';
end Load_Supply_Reserved;



PROCEDURE Validate_Scheduling_Attributes

	(
		P_Row_Id			VARCHAR2,
		P_Line_Id			NUMBER,
		P_Ship_Set_Number		NUMBER,
		P_Reserved_Quantity		NUMBER,
		P_Warehouse_Id			NUMBER,
		P_Ship_To_Site_Use_Id		NUMBER,
		P_Schedule_Date			DATE,
		P_Demand_Class_Code		VARCHAR2,
		P_Ship_Method_Code		VARCHAR2,
		P_Shipment_Priority_Code	VARCHAR2,
		P_Schedule_Action_Code		VARCHAR2,
		P_Navigation_Context		VARCHAR2,
		P_Result		IN OUT	VARCHAR2
	) IS


  DB_Reserved_Quantity		NUMBER := NULL;
  DB_Warehouse_Id		NUMBER := NULL;
  DB_Ship_To_Site_Use_Id	NUMBER := NULL;
  DB_Ship_Set_Number		NUMBER := NULL;
  DB_Schedule_Date		DATE   := NULL;
  DB_Demand_Class_Code		VARCHAR2(30) := NULL;
  DB_Shipment_Priority_Code	VARCHAR2(30) := NULL;
  DB_Ship_Method_Code		VARCHAR2(30) := NULL;

  Dummy_Svrid			NUMBER := NULL;

  Result	                VARCHAR2(30) := 'N';


  FUNCTION Warehouse_Changed RETURN BOOLEAN is
  begin

    if ((P_Warehouse_Id = DB_Warehouse_Id) or
	 (P_Warehouse_Id  is NULL and
	  DB_Warehouse_Id is NULL)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Warehouse_Changed;

  FUNCTION Demand_Class_Code_Changed RETURN BOOLEAN is
  begin

    if ((P_Demand_Class_Code = DB_Demand_Class_Code) or
	 (P_Demand_Class_Code  is NULL and
	  DB_Demand_Class_Code is NULL)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Demand_Class_Code_Changed;

  FUNCTION Ship_Method_Code_Changed RETURN BOOLEAN is
  begin

    if ((P_Ship_Method_Code = DB_Ship_Method_Code) or
	 (P_Ship_Method_Code  is NULL and
	  DB_Ship_Method_Code is NULL)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Ship_Method_Code_Changed;

  FUNCTION Shipment_Priority_Code_Changed RETURN BOOLEAN is
  begin

    if ((P_Shipment_Priority_Code = DB_Shipment_Priority_Code) or
	 (P_Shipment_Priority_Code  is NULL and
	  DB_Shipment_Priority_Code is NULL)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Shipment_Priority_Code_Changed;


  FUNCTION Schedule_Date_Changed RETURN BOOLEAN is
  begin

    if ((P_Schedule_Date = DB_Schedule_Date) or
	 (P_Schedule_Date  is NULL and
	  DB_Schedule_Date is NULL)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Schedule_Date_Changed;

  FUNCTION Reserved_Quantity_Changed RETURN BOOLEAN is
  begin

    if (nvl(P_Reserved_Quantity, 0) = nvl(DB_Reserved_Quantity,0)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Reserved_Quantity_Changed;

  FUNCTION Ship_To_Site_Use_Changed RETURN BOOLEAN is
  begin

    if ((P_Ship_To_Site_Use_Id = DB_Ship_To_Site_Use_Id) or
	 (P_Ship_To_Site_Use_Id  is NULL and
	  DB_Ship_To_Site_Use_Id is NULL)) then
	Return(FALSE);
    end if;

    return (TRUE);

  end Ship_To_Site_Use_Changed;


  FUNCTION Any_Group_Attribute_Changed RETURN BOOLEAN is
  begin

    if (Warehouse_Changed   or
	Ship_To_Site_Use_Changed or
	Schedule_Date_Changed or
	Demand_Class_Code_Changed or
	Shipment_Priority_Code_Changed or
	Ship_Method_Code_Changed) then

      return TRUE;

    end if;

    return (FALSE);

  end Any_Group_Attribute_Changed;


begin

  P_Result := 'Y';

  Get_Schedule_DB_Values(P_Row_Id,
			 P_Line_Id,
			 DB_Schedule_Date,
			 DB_Demand_Class_Code,
			 DB_Ship_To_Site_Use_Id,
			 DB_Warehouse_Id,
			 Dummy_Svrid,
			 DB_Shipment_Priority_Code,
			 DB_Ship_Method_Code,
			 Dummy_Svrid,
			 Dummy_Svrid,
			 Dummy_Svrid,
			 Dummy_Svrid,
			 DB_Ship_Set_Number,
			 Dummy_Svrid,
			 DB_Reserved_Quantity,
			 Result);

  if (Result = 'N') then
	P_Result := 'N';
        Return;
  end if;

  if (P_Navigation_Context = 'ORDER') then

    if (nvl(P_Ship_Set_Number, -1) <> nvl(DB_Ship_Set_Number, -1)) then
      if (Any_Group_Attribute_Changed) then
	OE_MSG.Set_Buffer_Message('OE_SCH_SHIPSET_CHG_NOT_ALLOWED');
	P_Result := 'N';
        Return;
      end if;
    end if;

  end if;

  if (P_Schedule_Action_Code in ('ATP CHECK')) then

	if (Ship_To_Site_Use_Changed) then
          OE_MSG.Set_Buffer_Message('OE_SCH_SHIP_TO_CHG_NOT_ALLOWED');
	  P_Result := 'N';
          Return;
	end if;

  end if;

  if (P_Schedule_Action_Code in ('ATP CHECK', 'DEMAND')) then

	if (Reserved_Quantity_Changed) then
          OE_MSG.Set_Buffer_Message('OE_SCH_NO_RES_QTY_REQUIRED');
	  P_Result := 'N';
          Return;
	end if;
  end if;

  if (P_Schedule_Action_Code in ('UNRESERVE', 'UNDEMAND', 'UNSCHEDULE')) then

	if (Reserved_Quantity_Changed) then
          OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
	  P_Result := 'N';
          Return;
	end if;

	if (P_Navigation_Context = 'ORDER') then

	  if (Warehouse_Changed) then
            OE_MSG.Set_Buffer_Message('OE_SCH_WH_CHG_NOT_ALLOWED');
	    P_Result := 'N';
            Return;
	  end if;

	end if;

	if (Schedule_Date_Changed) then
          OE_MSG.Set_Buffer_Message('OE_SCH_DATE_CHG_NOT_ALLOWED');
	  P_Result := 'N';
          Return;
	end if;

	if (Demand_Class_Code_Changed) then
          OE_MSG.Set_Buffer_Message('OE_SCH_DEM_CL_CHG_NOT_ALLOWED');
	  P_Result := 'N';
          Return;
	end if;
  end if;

  if (P_Schedule_Action_Code in ('RESERVE') ) then
        if (Reserved_Quantity_Changed) then
          OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
          P_Result := 'N';
          Return;
        end if;
  end if;

  Return;

EXCEPTION

  when OTHERS then
    OE_MSG.Internal_Exception('OE_SO_LIN_VALIDATE.Validate_Scheduling_Attributes',
			      'Validating Scheduling Attributes' , 'LINE');

end Validate_Scheduling_Attributes;

END OE_SO_LIN_VALIDATE;

/
