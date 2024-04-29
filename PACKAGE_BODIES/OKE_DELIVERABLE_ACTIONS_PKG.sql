--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_ACTIONS_PKG" AS
/* $Header: OKEVDACB.pls 120.2 2005/06/27 14:40:33 ausmani noship $ */

G_Pkg_Name CONSTANT VARCHAR2(30) := 'OKE_DTS_INTERGRATION';

FUNCTION Charge_Account ( P_Item_ID NUMBER, P_Org_ID NUMBER) RETURN NUMBER;
FUNCTION Uom_Conversion
( P_Item_Id   NUMBER
, P_From_Uom  VARCHAR2
, P_To_Uom    VARCHAR2
, P_Quantity  NUMBER
) RETURN NUMBER;


FUNCTION Uom_Conversion
( P_Item_Id   NUMBER
, P_From_Uom  VARCHAR2
, P_To_Uom    VARCHAR2
, P_Quantity  NUMBER
) RETURN NUMBER IS

  L_Quantity NUMBER;

BEGIN

  IF P_From_UOM = P_To_UOM THEN
    L_Quantity := P_Quantity;
  ELSIF P_From_Uom IS NULL OR P_To_Uom IS NULL THEN
    L_Quantity := 0;
  ELSIF P_From_Uom IS NULL AND P_To_Uom IS NULL THEN
    L_Quantity := P_Quantity;
  ELSE
    L_Quantity := INV_CONVERT.Inv_Um_Convert
                             ( P_Item_ID
                             , 5 -- precision, can be changed later
                             , P_Quantity
                             , P_From_Uom
                             , P_To_Uom
                             , Null
                             , Null);
  END IF;


  IF L_Quantity = -9999 THEN
    L_Quantity := 0;
  END IF;

  RETURN L_Quantity;

END UOM_Conversion;

FUNCTION Check_Item_Unique ( P_Action_ID NUMBER )
RETURN BOOLEAN IS

  Dummy NUMBER;
  L_Item_ID NUMBER;
  L_Org_ID NUMBER;
  L_Designator VARCHAR2(30);

BEGIN

  SELECT 1
  INTO Dummy
  FROM dual
  WHERE NOT EXISTS (
	SELECT 1
   	FROM mrp_schedule_items mrp
        , oke_deliverables_b oke
	, oke_deliverable_actions oka
	WHERE oka.action_id = p_action_id
	AND oke.deliverable_id = oka.deliverable_id
 	AND mrp.inventory_item_id = oke.item_id
	AND mrp.schedule_designator = oka.schedule_designator
	AND mrp.organization_id = oka.ship_from_org_id);

   RETURN ( TRUE );
   RETURN NULL;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ( FALSE );
END Check_Item_Unique;

PROCEDURE Delete_Row ( P_Action_ID NUMBER ) IS
  L_ID NUMBER;

  CURSOR c IS
  SELECT reference2
  FROM oke_deliverable_actions
  WHERE action_id = p_action_id;

BEGIN
  OPEN c;
  FETCH c INTO l_id;
  CLOSE c;

  IF l_id IS NOT NULL THEN
    DELETE FROM mrp_schedule_dates
      WHERE mps_transaction_id = l_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Delete_Row;

PROCEDURE Insert_Row ( P_Action_ID NUMBER
		, X_Mps_Transaction_ID OUT NOCOPY NUMBER ) IS

  L_ID 			NUMBER;
  L_Workdate 		DATE;
  L_Schedule_Level		CONSTANT NUMBER := 2;
  L_Supply_Demand_Type		CONSTANT NUMBER := 1;
  L_Schedule_Origination_Type 	CONSTANT NUMBER := 1;
  L_Level			NUMBER;
  L_To_UOM			VARCHAR2(3);
  L_Primary_Qty			NUMBER;

  CURSOR c1 ( P_Transaction_ID NUMBER ) IS
  SELECT rowid
  FROM mrp_schedule_dates
  WHERE mps_transaction_id = p_transaction_id
  AND schedule_level = l_schedule_level
  AND supply_demand_type = l_supply_demand_type;

  c1info c1%rowtype;

  CURSOR c2 ( P_Organization_ID NUMBER ) IS
  SELECT Maximum_BOM_Level
  FROM bom_parameters
  WHERE organization_id = p_organization_id;

  CURSOR C3 IS
  SELECT b.item_id
  , c.ship_from_org_id
  , c.schedule_designator
  , c.expected_date
  , b.uom_code
  , b.quantity
  , b.project_id
  , c.task_id
  , b.unit_number
  , c.deliverable_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions c
  WHERE c.action_id = p_action_id
  AND b.deliverable_id = c.deliverable_id;

  c3info c3%rowtype;

  CURSOR c4 ( P_Item_ID NUMBER, P_Org_ID NUMBER ) IS
  SELECT primary_uom_code
  FROM mtl_system_items
  WHERE inventory_item_id = p_item_id
  AND organization_id = p_org_id;

BEGIN

  -- Get ID
  SELECT mrp_schedule_dates_s.nextval
  INTO l_id
  FROM dual;

  IF Check_Item_Unique ( P_Action_ID ) THEN
    INSERT INTO mrp_schedule_items (
	inventory_item_id
	, organization_id
	, schedule_designator
	, last_update_date
	, last_updated_by
	, creation_date
	, created_by
	, last_update_login
	, mps_explosion_level )
     SELECT b.item_id
	, c.ship_from_org_id
	, c.schedule_designator
	, sysdate
	, fnd_global.user_id
	, sysdate
	, fnd_global.user_id
	, fnd_global.login_id
	, d.maximum_bom_level
      FROM oke_deliverables_b b
	, oke_deliverable_actions c
	, bom_parameters d
      WHERE c.action_id = p_action_id
      AND c.deliverable_id = b.deliverable_id
      AND c.ship_from_org_id = d.organization_id;
  END IF;


  OPEN c3;
  FETCH c3 INTO c3info;
  CLOSE c3;

  L_Workdate := MRP_CALENDAR.Prev_Work_Day ( c3info.ship_from_org_id
					, 1
					, c3info.expected_date );
  OPEN c4 ( c3info.item_id, c3info.ship_from_org_id);
  FETCH c4 INTO L_To_Uom;
  CLOSE c4;

  L_Primary_Qty := Uom_Conversion ( c3info.item_id
				, c3info.uom_code
				, l_to_uom
				, c3info.quantity );

  INSERT INTO MRP_SCHEDULE_DATES(
	MPS_TRANSACTION_ID,
	SCHEDULE_LEVEL,
	SUPPLY_DEMAND_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	SCHEDULE_DESIGNATOR,
	SCHEDULE_DATE,
	SCHEDULE_WORKDATE,
	SCHEDULE_QUANTITY,
        ORIGINAL_SCHEDULE_QUANTITY,
	SCHEDULE_ORIGINATION_TYPE,
	PROJECT_ID,
	TASK_ID,
	END_ITEM_UNIT_NUMBER,
	SOURCE_CODE,
	SOURCE_LINE_ID)
  SELECT
	L_Id			,
	lu.lookup_code		,
	L_Supply_Demand_Type	,
	Sysdate			,
	Fnd_Global.User_Id	,
	Sysdate			,
	Fnd_Global.User_Id	,
	Fnd_Global.Login_Id	,
	c3info.Item_Id		,
	c3info.Ship_From_Org_Id	,
	c3info.Schedule_Designator	,
	c3info.Expected_Date	,
	l_workdate		,
	L_Primary_Qty		,
	L_Primary_Qty		,
	l_schedule_origination_type,
	c3info.Project_Id	,
	c3info.Task_Id		,
	c3info.Unit_Number     ,
        'OKE'			,
	c3info.deliverable_id
  FROM  mfg_lookups lu
  WHERE lookup_type = 'MRP_SCHEDULE_LEVEL'
  AND   lookup_code in ( 1 , 2)
  AND NOT EXISTS (
    SELECT NULL
    FROM   mrp_schedule_dates
    WHERE  mps_transaction_id = L_Id
    AND    schedule_level = lu.lookup_code );

  OPEN c1 (l_id);
  FETCH c1 INTO c1info;
  IF (c1%NOTFOUND) THEN

    CLOSE c1;
    RAISE NO_DATA_FOUND;

  END IF;

  CLOSE c1;
  x_mps_transaction_id := l_id;

END insert_row;

PROCEDURE update_row ( X_Mps_Transaction_Id IN OUT NOCOPY NUMBER
		, P_Action_Id IN NUMBER
) IS

  CURSOR c IS
  SELECT b.item_id
  , c.ship_from_org_id
  , c.schedule_designator
  , c.expected_date
  , b.quantity
  , b.project_id
  , c.task_id
  , b.unit_number
  , b.uom_code
  , mrp_calendar.prev_work_day(c.ship_from_org_id
			 , 1
			 , c.expected_date) workdate
  , d.primary_uom_code
  FROM oke_deliverables_b b
  , oke_deliverable_actions c
  , mtl_system_items d
  WHERE c.action_id = p_action_id
  AND b.deliverable_id = c.deliverable_id
  AND d.inventory_item_id = b.item_id
  AND d.organization_id = c.ship_from_org_id;

  cinfo c%rowtype;
  L_Primary_Qty NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO cinfo;
  CLOSE c;

  L_Primary_Qty := uom_conversion( cinfo.item_id
		, cinfo.uom_code
  		, cinfo.primary_uom_code
		, cinfo.quantity );

  UPDATE MRP_SCHEDULE_DATES
  SET
	LAST_UPDATE_DATE = Sysdate,
	LAST_UPDATED_BY = Fnd_Global.User_Id,
	LAST_UPDATE_LOGIN = Fnd_Global.Login_Id,
	INVENTORY_ITEM_ID = cinfo.Item_Id,
	ORGANIZATION_ID = cinfo.Ship_From_Org_Id,
	SCHEDULE_DESIGNATOR = cinfo.Schedule_Designator,
	SCHEDULE_DATE = cinfo.Expected_Date,
	SCHEDULE_WORKDATE = cinfo.Workdate,
	SCHEDULE_QUANTITY = ( select greatest(L_Primary_Qty - nvl(sum(ref.relief_quantity) , 0) , 0)
                              from mrp_schedule_consumptions ref
                              where ref.transaction_id = x_mps_transaction_id ),
	PROJECT_ID = cinfo.Project_Id,
	TASK_ID = cinfo.Task_Id,
	END_ITEM_UNIT_NUMBER = cinfo.Unit_Number
  WHERE MPS_TRANSACTION_ID = X_MPS_TRANSACTION_ID
  AND SCHEDULE_LEVEL = 2
  AND SUPPLY_DEMAND_TYPE = 1;

  IF ( sql%notfound ) THEN

    insert_row( P_Action_ID     => p_action_id
              , X_MPS_Transaction_ID => x_mps_transaction_id );

  END IF;

END update_row;

PROCEDURE Create_Demand ( P_Action_ID 	NUMBER
		, P_Init_Msg_List	VARCHAR2
		, X_ID			OUT NOCOPY NUMBER
		, X_Return_Status 	OUT NOCOPY VARCHAR2
		, X_Msg_Count		OUT NOCOPY NUMBER
		, X_Msg_Data		OUT NOCOPY VARCHAR2 ) IS

  L_Return_Status 		VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
  L_API_Version			CONSTANT NUMBER := 1;
  L_API_Name			CONSTANT VARCHAR2(30) := 'CREATE_DEMAND';
  L_Quantity			NUMBER;
  L_ID 				NUMBER;

  CURSOR c1 IS
  SELECT reference2
  FROM oke_deliverable_actions
  WHERE action_id = p_action_id
  FOR UPDATE NOWAIT;

  CURSOR c2 IS
  SELECT schedule_quantity
  FROM mrp_schedule_dates
  WHERE mps_transaction_id = l_id;

BEGIN

  L_Return_Status := OKE_API.Start_Activity (
				L_API_Name
				, P_Init_Msg_List
				, '_PKG'
				, X_Return_Status );
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c1;
  FETCH c1 INTO L_ID;
  CLOSE c1;

  IF L_ID IS NULL THEN
    Insert_Row ( P_Action_ID => P_Action_ID
	, X_Mps_Transaction_ID => L_ID );
  ELSE
    OPEN c2;
    FETCH c2 INTO L_Quantity;
    CLOSE c2;

    IF L_Quantity <> 0 OR L_Quantity IS NULL THEN
      Update_Row ( P_Action_ID => P_Action_ID
	, X_Mps_Transaction_ID => L_ID );
    END IF;

  END IF;

  IF L_ID IS NOT NULL THEN
    X_ID := L_ID;

    UPDATE oke_deliverable_actions
    SET reference2 = L_ID
    WHERE action_id = p_action_id
    AND action_type = 'WSH';
  END IF;

  X_Return_Status := L_Return_Status;
--  Commit;
  OKE_API.End_Activity ( X_Msg_Count, X_Msg_Data );

EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PKG');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PKG');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PKG');


END Create_Demand;

PROCEDURE Create_Shipment ( P_Action_ID 	NUMBER
			, P_Init_Msg_List       VARCHAR2
			, X_ID			OUT NOCOPY NUMBER
			, X_Return_Status 	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 ) IS
  L_Return_Status 		VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
  L_API_Version			CONSTANT NUMBER := 1;
  L_API_Name			CONSTANT VARCHAR2(30) := 'CREATE_SHIPMENT';
  L_Quantity			NUMBER;
  L_ID 				NUMBER;
  L_OU_ID 			NUMBER;
  L_Ship_Rec 			wsh_delivery_details_pkg.delivery_details_rec_type;
  L_Flag 			VARCHAR2(1);
  L_Description			VARCHAR2(250);
  L_Header_Number		VARCHAR2(150);
  L_Action_Name			VARCHAR2(240);
  L_Action_Number 		VARCHAR2(150);
  L_Deliverable_Name		VARCHAR2(150);
  L_Deliverable_Number		VARCHAR2(150);
  L_Project_ID 			NUMBER;

  CURSOR c1 IS
  SELECT b.source_header_id
  	, b.source_deliverable_id
	, b.deliverable_id
	, b.project_id
	, b.item_id
	, nvl(b.quantity, c.quantity) quantity
	, nvl(b.uom_code, c.uom_code) uom_code
	, b.inventory_org_id
	, c.pa_action_id
	, c.ship_from_org_id
	, c.ship_to_org_id
	, c.ship_to_location_id
	, c.ship_from_location_id
	, c.expected_date
	, c.promised_date
	, b.unit_number
	, decode ( c.inspection_req_flag, 'Y', 'R', 'N') inspection_req_flag
	, c.volume
	, c.volume_uom_code
	, c.weight
	, c.weight_uom_code
	, nvl(b.currency_code, c.currency_code) currency_code
	, c.task_id
  FROM oke_deliverables_b b
	, oke_deliverable_actions c
  WHERE c.action_id = p_action_id
  AND b.deliverable_id = c.deliverable_id;

  c1info c1%rowtype;

  CURSOR c2 ( p_org_id NUMBER ) IS
  SELECT operating_unit
  FROM org_organization_definitions
  WHERE organization_id = p_org_id;

  CURSOR c3 ( p_location_id NUMBER ) IS
  SELECT id1, cust_account_id
  FROM oke_cust_site_uses_v
  WHERE location_id = p_location_id
  AND site_use_code = 'SHIP_TO';

  c3info c3%rowtype;

  CURSOR c4 ( p_org_id number,P_item_ID NUMBER ) IS
  SELECT MTL_Transactions_Enabled_Flag
  FROM mtl_system_items
  where organization_id = p_org_id
  and  inventory_item_id = p_item_id;

BEGIN

  L_Return_Status := OKE_API.Start_Activity (
				L_API_Name
				, P_Init_Msg_List
				, '_PKG'
				, X_Return_Status );
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c1;
  FETCH c1 INTO c1info;
  CLOSE c1;

  OPEN c2(c1info.ship_from_org_id);
  FETCH c2 INTO L_OU_ID;
  CLOSE c2;

  OPEN c3 ( c1info.ship_to_location_id );
  FETCH c3 INTO c3info;
  CLOSE c3;

  OPEN c4 ( c1info.ship_from_org_id ,c1info.item_id);
  FETCH c4 INTO L_Flag;
  CLOSE c4;

  -- Get deliverable description from PA
  L_Description := substr(PA_DELIVERABLE_UTILS.Get_Dlv_Description ( p_action_ver_id => c1info.pa_action_id ), 1, 250);
  PA_DELIVERABLE_UTILS.Get_Action_Project_Detail ( p_dlvr_action_ver_id => c1info.pa_action_id
							, x_project_id => l_project_id
							, x_project_name => l_header_number );
  PA_DELIVERABLE_UTILS.Get_Action_Detail ( p_dlvr_action_ver_id => c1info.pa_action_id
					, x_name => l_action_name
					, x_number => l_action_number );
  PA_DELIVERABLE_UTILS.Get_Dlvr_Detail ( p_dlvr_ver_id => c1info.source_deliverable_id
					, x_name => l_deliverable_name
					, x_number => l_deliverable_number );
  --
  -- Leave 25 for deliverable short name if over 150 after concat
  --
  IF Length ( L_Deliverable_Name || ' : ' || L_Action_Name ) > 150 THEN
    IF Length ( L_Deliverable_Name ) > 25 THEN
      L_Action_Name := SUBSTR ( L_Deliverable_Name, 1, 25 ) || ' : ' || SUBSTR( L_Action_Name, 1, 122 );
    ELSE
      L_Action_Name := L_Deliverable_Name || ' : ' || SUBSTR ( L_Action_Name, 1, 147 - Length ( L_Deliverable_Name ) );
    END IF;

  ELSE
    L_Action_Name := L_Deliverable_Name || ' : ' || L_Action_Name ;
  END IF;



  l_ship_rec.source_code		:= 'OKE';
-- l_ship_rec.source_header_id		:= c1info.SOURCE_HEADER_ID; --Bug3863976
  l_ship_rec.source_header_id		:= -99; -- Bug 3863976
  l_ship_rec.source_line_id		:= p_action_id;
  l_ship_rec.customer_id		:= c3info.cust_account_id;
  l_ship_rec.inventory_item_id		:= c1info.item_id;
  l_ship_rec.item_description		:= l_description;
  l_ship_rec.ship_from_location_id	:= c1info.ship_from_location_id;
  l_ship_rec.ship_to_location_id	:= c1info.ship_to_location_id;
  l_ship_rec.ship_to_site_use_id	:= c3info.id1;
  -- l_ship_rec.requested_quantity	:= nvl(c1info.quantity, 1);
  -- l_ship_rec.requested_quantity_uom	:= nvl(c1info.uom_code, 'EA');
  l_ship_rec.date_requested		:= c1info.promised_date;
  l_ship_rec.date_scheduled		:= c1info.expected_date;
  l_ship_rec.net_weight			:= c1info.weight;
  l_ship_rec.weight_uom_code		:= c1info.weight_uom_code;
  l_ship_rec.volume			:= c1info.volume;
  l_ship_rec.volume_uom_code		:= c1info.volume_uom_code;
  l_ship_rec.created_by			:= fnd_global.user_id;
  l_ship_rec.creation_date		:= sysdate;
  l_ship_rec.last_update_date		:= sysdate;
  l_ship_rec.last_update_login		:= fnd_global.login_id;
  l_ship_rec.last_updated_by		:= fnd_global.user_id;
  l_ship_rec.organization_id		:= c1info.ship_from_org_id;
  l_ship_rec.source_header_number	:= l_header_number;
  l_ship_rec.src_requested_quantity	:= nvl(c1info.quantity, 1);
  l_ship_rec.src_requested_quantity_uom	:= nvl(c1info.uom_code, 'EA');
  l_ship_rec.project_id			:= c1info.source_header_id;
  l_ship_rec.task_id			:= c1info.task_id;
  l_ship_rec.org_id			:= l_ou_id;
  l_ship_rec.source_line_number		:= l_action_name;
  l_ship_rec.inspection_flag		:= c1info.inspection_req_flag;
  l_ship_rec.unit_number		:= c1info.unit_number;
  l_ship_rec.currency_code		:= c1info.currency_code;
  l_ship_rec.pickable_flag 		:= l_flag;

  WSH_INTERFACE_PUB.Create_Shipment_Lines ( L_Ship_Rec
					, L_ID
					, L_Return_Status );


  IF L_Return_Status = OKE_API.G_Ret_Sts_Success THEN
    UPDATE oke_deliverable_actions
    SET reference1 = l_id
    , in_process_flag = 'Y'
    , initiate_date = sysdate
    WHERE action_id = p_action_id;

    X_Return_Status := L_Return_Status;
--    Commit;
  ELSE
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PKG');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PKG');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PKG');

END Create_Shipment;

PROCEDURE Create_Requisition ( P_Action_ID 	NUMBER
			, P_Init_Msg_List       VARCHAR2
			, X_ID			OUT NOCOPY NUMBER
			, X_Return_Status 	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 ) IS

  L_Return_Status 		VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
  L_API_Version			CONSTANT NUMBER := 1;
  L_API_Name			CONSTANT VARCHAR2(30) := 'CREATE_REQUISITION';
  L_Quantity			NUMBER;
  L_ID 				NUMBER;
  L_Description			VARCHAR2(150);
  L_ID 				NUMBER;
  L_Requestor			NUMBER;
  L_Employee			NUMBER;
  L_Context 			VARCHAR2(1);
  L_Charge_Account		NUMBER;

  CURSOR c1 IS
  SELECT employee_id
  FROM fnd_user
  WHERE user_id = l_requestor;

  CURSOR c2 IS
  SELECT b.source_header_id
  , c.task_id
  , c.destination_type_code
  , c.expenditure_type
  , c.expenditure_organization_id
  , c.expenditure_item_date
  , nvl(b.inventory_org_id,c.ship_to_org_id) inventory_org_id
  , trunc ( c.expected_date ) expected_date
  , c.reference1
  , c.reference2
  , c.schedule_designator
  , b.item_id
  , nvl(b.unit_price, c.unit_price) unit_price
  , c.exchange_rate
  , c.ship_from_org_id
  , nvl(b.currency_code, c.currency_code) currency_code
  , c.ship_from_location_id
  , c.requisition_line_type_id
  , c.po_category_id
  , nvl(b.quantity, c.quantity) quantity
  , nvl(b.uom_code, c.uom_code) uom_code
  , c.pa_action_id
  , c.ship_to_location_id
  , c.deliverable_id
  , c.action_id
  , b.unit_number
  , c.rate_date
  , c.rate_type
  FROM oke_deliverables_b b
  , oke_deliverable_actions c
  WHERE c.action_id = p_action_id
  AND b.deliverable_id = c.deliverable_id;

  c2info c2%rowtype;


BEGIN
  L_Return_Status := OKE_API.Start_Activity (
				L_API_Name
				, P_Init_Msg_List
				, '_PKG'
				, X_Return_Status );
  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c2;
  FETCH c2 INTO c2info;
  CLOSE c2;

  L_Charge_Account := Charge_Account ( p_item_id => c2info.item_id
				, p_org_id => c2info.inventory_org_id );

  L_Requestor := FND_GLOBAL.User_ID;

  OPEN c1;
  FETCH c1 INTO L_Employee;
  CLOSE c1;

  L_Context := 'Y';
  L_Description := substr(PA_DELIVERABLE_UTILS.Get_Dlv_Description ( p_action_ver_id => c2info.pa_action_id ), 1, 240);

  IF c2info.reference1>0 THEN
    DELETE FROM po_requisitions_interface_all
      WHERE oke_contract_deliverable_id = c2info.action_id
        AND batch_id = c2info.reference1;
  END IF;

  INSERT INTO po_requisitions_interface_all(
    last_updated_by,
    last_update_login,
    last_update_date,
    creation_date,
    created_by,
    item_id,
    quantity,
    unit_price,
    need_by_date,
    interface_source_code,
    deliver_to_location_id,
    deliver_to_requestor_id,
    preparer_id,
    source_type_code,
    authorization_status,
    uom_code,
    batch_id,
    charge_account_id,
    group_code,
    destination_organization_id,
    autosource_flag,
    org_id,
    project_id,
    task_id,
    project_accounting_context,
    oke_contract_header_id,
    oke_contract_version_id,
    oke_contract_line_id,
    oke_contract_deliverable_id,
    end_item_unit_number,
    expenditure_organization_id,
    expenditure_type,
    expenditure_item_date,
    destination_type_code,
    currency_code,
    rate,
    rate_date,
    rate_type,
    currency_unit_price,
    suggested_vendor_id,
    suggested_vendor_site_id,
    line_type_id,
    category_id,
    item_description)
  select fnd_global.user_id,
    fnd_global.login_id,
    sysdate,
    sysdate,
    fnd_global.user_id,
    c2info.item_id,
    c2info.quantity,
    c2info.unit_price * Nvl(c2info.exchange_rate,1), -- bug#4189882
    c2info.expected_date,
    'OKE',  -- hard code for OKE
    c2info.ship_to_location_id,
    l_employee,
    l_employee,
    'VENDOR',
    decode(c2info.destination_type_code, 'INVENTORY', 'APPROVED','INCOMPLETE'),
    c2info.uom_code,
    p_action_id,
    decode(c2info.destination_type_code, 'INVENTORY',mp.material_account, l_charge_account),
    null, -- to be added later if required
    c2info.inventory_org_id,
    'N', -- hard coded
    ood.operating_unit,
    c2info.source_header_id,
    c2info.task_id,
    l_context,
    c2info.source_header_id,
    null,
    c2info.deliverable_id,
    c2info.action_id,
    c2info.unit_number,
    c2info.expenditure_organization_id,
    c2info.expenditure_type,
    c2info.expenditure_item_date,
    c2info.destination_type_code,
    c2info.currency_code,
    c2info.exchange_rate,
    c2info.rate_date,
    c2info.rate_type,
    c2info.unit_price,
    c2info.ship_from_org_id,
    c2info.ship_from_location_id,
    c2info.requisition_line_type_id,
    c2info.po_category_id,
    l_description
  from mtl_parameters mp
  ,    org_organization_definitions ood
  where ood.organization_id = c2info.inventory_org_id
  and mp.organization_id = c2info.inventory_org_id;

  UPDATE oke_deliverable_actions
  SET reference1 = p_action_id
  , in_process_flag = 'Y'
  WHERE action_id = p_action_id;
--  COMMIT;

  X_ID := P_Action_ID;
  X_Return_Status := L_Return_Status;
  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PKG');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PKG');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PKG');

END Create_Requisition;

FUNCTION Charge_Account ( P_Item_ID NUMBER, P_Org_ID NUMBER) RETURN NUMBER IS

  CURSOR Item_C IS
  SELECT Expense_Account
  FROM mtl_system_items
  WHERE Inventory_Item_ID = P_Item_ID
  AND Organization_ID = P_Org_ID;

  CURSOR Org_C IS
  SELECT Expense_Account
  FROM mtl_parameters
  WHERE ORGANIZATION_ID = P_Org_ID;

  L_Account NUMBER;


BEGIN



  IF P_Item_ID > 0 THEN

    OPEN Item_C;
    FETCH Item_C INTO L_Account;
    CLOSE Item_C;

    IF L_Account IS NULL THEN



      OPEN Org_C;
      FETCH Org_C INTO L_Account;
      CLOSE Org_C;

    END IF;

  ELSE

    OPEN Org_C;
    FETCH Org_C INTO L_Account;
    CLOSE Org_C;

  END IF;



  IF L_Account > 0 THEN


    RETURN L_Account;

  ELSE


    RETURN NULL;

  END IF;



END Charge_Account;

PROCEDURE Delete_Action ( P_Action_ID NUMBER ) IS

  L_Action_ID NUMBER;
  L_Ref_2 NUMBER;

  CURSOR c IS
  SELECT action_id
  , reference2
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_action_id;

BEGIN
  OPEN c;
  FETCH c INTO L_Action_ID, L_Ref_2;
  CLOSE c;

  IF L_Ref_2 > 0 THEN
    Delete_Row ( L_Action_ID );
  END IF;

  DELETE FROM oke_deliverable_actions
  WHERE action_id = l_action_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Delete_Action;

PROCEDURE Delete_Deliverable ( P_Deliverable_ID NUMBER ) IS

  L_Deliverable_ID NUMBER;
  L_Action_ID NUMBER;

  CURSOR c IS
  SELECT deliverable_id
  FROM oke_deliverables_b
  WHERE source_deliverable_id = p_deliverable_id;

  CURSOR c_act IS
  SELECT pa_action_id
  FROM oke_deliverable_actions
  WHERE deliverable_id = l_deliverable_id;

BEGIN
  OPEN c;
  FETCH c INTO L_Deliverable_ID;
  CLOSE c;

  IF L_Deliverable_ID > 0 THEN

    For c_rec IN c_act LOOP
      Delete_Action ( c_rec.pa_action_id );
    END LOOP;

    DELETE FROM oke_deliverables_tl
    WHERE deliverable_id = l_deliverable_id;

    DELETE FROM oke_deliverables_b
    WHERE deliverable_id = l_deliverable_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Delete_Deliverable;

END;


/
