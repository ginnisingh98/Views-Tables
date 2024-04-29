--------------------------------------------------------
--  DDL for Package Body OKE_ACTION_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_ACTION_VALIDATIONS_PKG" AS
/* $Header: OKEVDATB.pls 120.0.12010000.2 2009/04/21 13:04:43 serukull ship $ */

G_Yes 			CONSTANT VARCHAR2(1) := 'Y';
G_No			CONSTANT VARCHAR2(1) := 'N';

  L_req_list	VARCHAR2(2000);
  PROCEDURE Add_Attr_To_Required_List( name VARCHAR2 ) IS
    l_msg VARCHAR2(2000) := NULL;
   BEGIN
    IF name LIKE 'OKE%' THEN
      FND_MESSAGE.Set_Name ( 'OKE', name );
      l_msg := FND_MESSAGE.Get;
     ELSE
      l_msg := name;
    END IF;
    IF L_req_list IS NOT NULL THEN
      FND_MESSAGE.Set_Name ( 'OKE', 'OKE_LIST' ); -- 'START, END' for left2right and reverse for right2left
      FND_MESSAGE.Set_Token ( 'START', L_req_list );
      FND_MESSAGE.Set_Token ( 'END', L_msg );
      L_req_list := FND_MESSAGE.Get;
     ELSE
      L_req_list := l_msg ;
    END IF;
  END Add_Attr_To_Required_List;


FUNCTION Check_Pjm ( P_Action_ID NUMBER
		, P_Organization_ID NUMBER
		, P_Project_ID NUMBER )
RETURN BOOLEAN IS

  L_Value VARCHAR2(25);
  L_ID NUMBER;
  L_Prj_ID NUMBER;
  L_Result BOOLEAN;
  L_Msg VARCHAR2(2000);

  CURSOR Org_C IS
  SELECT 'X' FROM pjm_org_parameters
  WHERE Organization_ID = L_ID
  AND PROJECT_REFERENCE_ENABLED = 'Y';

  CURSOR Prj_C IS
  SELECT 'X' FROM pjm_project_parameters
  WHERE Organization_ID = L_ID
  AND Project_ID = L_Prj_ID;


BEGIN

  -- Validate inventory org against pjm
  L_ID := P_Organization_ID;
  OPEN Org_C;
  FETCH Org_C INTO L_Value;
  CLOSE Org_C;

  IF L_Value IS NULL THEN

    L_Result := TRUE;
  ELSE

    L_Value := NULL;
    -- Validate project with pjm
    IF P_Project_ID IS NOT NULL THEN
      L_Prj_ID := P_Project_ID;

      OPEN Prj_C;
      FETCH Prj_C INTO L_Value;
      CLOSE Prj_C;

      IF L_Value IS NULL THEN
        --FND_MESSAGE.Set_Name('OKE', 'OKE_PROJECT_NOT_SETUP');
        --L_Msg := FND_MESSAGE.Get;
--        l_msg := 'Project is not set up in project manufacturing';
--        Add_Msg ( P_Action_ID, L_Msg );
        L_Result := FALSE;
      ELSE
        L_Result := TRUE;
      END IF;
    END IF;
  END IF;


  RETURN L_Result;

END Check_Pjm;

PROCEDURE Add_Msg ( P_Action_ID				NUMBER
		, P_Msg					VARCHAR2 ) IS

  L_ID 		NUMBER;
  L_Name 	VARCHAR2(120);
  L_Number	VARCHAR2(120);

  CURSOR c IS
  SELECT pa_action_id
  FROM oke_deliverable_actions
  WHERE action_id = p_action_id;

BEGIN
  OPEN c;
  FETCH c INTO L_ID;
  CLOSE c;

  PA_DELIVERABLE_UTILS.Get_Action_Detail ( p_dlvr_action_ver_id => L_ID
				, x_name =>  L_Name
				, x_number => L_Number );
  FND_MESSAGE.Set_Name ( 'PA', 'PA_ACTION_NAME_ERR');
  FND_MESSAGE.Set_Token ( 'ACTION_NAME', L_Name );
  FND_MESSAGE.Set_Token ( 'MESSAGE', P_Msg );
  FND_MSG_PUB.Add;

END Add_Msg;


FUNCTION Validate_Mds ( P_Action_ID 			NUMBER
			, P_Deliverable_ID 		NUMBER
			, P_Task_ID			NUMBER
			, P_Ship_From_Org_ID		NUMBER
			, P_Ship_From_Location_ID	NUMBER
			, P_Ship_To_Org_ID		NUMBER
			, P_Ship_To_Location_ID		NUMBER
			, P_Schedule_Designator		VARCHAR2
			, P_Expected_Date		DATE
			, P_Quantity			NUMBER
			, P_Uom_Code			VARCHAR2 ) RETURN VARCHAR2 IS

  l_ret VARCHAR2(1) := G_YES;
  L_Item_ID 	NUMBER;
  L_Org_ID 	NUMBER;
  L_Qty 	NUMBER;
  L_Project_ID  NUMBER;
  l_dummy       VARCHAR2(1);
  L_Uom_Code 	VARCHAR2(30);
  L_Msg		VARCHAR2(2000);

  CURSOR c1 IS
  SELECT b.item_id
  , b.inventory_org_id
  , b.quantity
  , b.uom_code
  , b.project_id
  FROM oke_deliverables_b b
  WHERE b.deliverable_id = p_deliverable_id;

  CURSOR c2 IS
  SELECT '!'
  FROM oke_system_items_v
  WHERE id1 = l_item_id
  AND organization_id = l_org_id
  AND NVL(shippable_item_flag, 'N') = 'Y';

  CURSOR c3 IS
  SELECT '!'
  FROM oke_deliverable_actions b
  WHERE b.Action_ID = p_Action_ID
    AND (b.deliverable_id = p_deliverable_id or b.deliverable_id is null and p_deliverable_id is null)
    AND (b.Task_ID = p_Task_ID or b.Task_ID is null and p_Task_ID is null)
    AND (b.Ship_From_Org_ID = p_Ship_From_Org_ID or b.Ship_From_Org_ID is null and p_Ship_From_Org_ID is null)
    AND (b.Ship_From_Location_ID = p_Ship_From_Location_ID or b.Ship_From_Location_ID is null and p_Ship_From_Location_ID is null)
    AND (b.Ship_To_Org_ID = p_Ship_To_Org_ID or b.Ship_To_Org_ID is null and p_Ship_To_Org_ID is null)
    AND (b.Ship_To_Location_ID = p_Ship_To_Location_ID or b.Ship_To_Location_ID is null and p_Ship_To_Location_ID is null)
    AND (b.Expected_Date = p_Expected_Date or b.Expected_Date is null and p_Expected_Date is null)
    AND (b.Schedule_Designator = p_Schedule_Designator or b.Schedule_Designator is null and p_Schedule_Designator is null)
    AND (b.Quantity = p_Quantity or b.Quantity is null and p_Quantity is null)
    AND (b.Uom_Code = p_Uom_Code or b.Uom_Code is null and p_Uom_Code is null)
  ;

 BEGIN

  FND_MSG_PUB.Initialize;
  L_req_list := NULL;

  l_dummy := NULL;
  OPEN c3;
  FETCH c3 INTO l_dummy;
  CLOSE c3;

  IF l_dummy IS NULL THEN
    FND_MESSAGE.Set_Name ( 'OKE', 'OKE_SAVE_BEFORE_PROCEED' );
    FND_MSG_PUB.Add;
    RETURN G_NO;
  END IF;

  OPEN c1;
  FETCH c1 INTO L_Item_ID, L_Org_ID, L_Qty, L_Uom_Code, L_Project_ID;
  CLOSE c1;

  IF P_Task_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_TASK');
  END IF;

  IF L_Item_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_ITEM');
  END IF;

  IF NVL ( L_Org_ID, P_Ship_From_Org_ID ) IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_ORG');
  END IF;

  IF L_Qty IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_QTY');
  END IF;

  IF L_Uom_Code IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_UOM');
  END IF;

  IF NOT Check_Pjm ( P_Action_ID, L_Org_ID, L_Project_ID ) THEN
--      l_msg := 'PJM setup is required';
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_NO_PJM_SETUP');
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  IF P_Expected_Date IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_DATE');
   ELSIF P_Expected_Date < Trunc( SYSDATE ) THEN
--    l_msg := 'The date is past due';
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_EXP_DATE_PAST' );
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  IF P_Schedule_Designator IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_DATA_PLAN');
  END IF;

  IF L_req_list IS NOT NULL THEN
--    l_msg := 'The following data are required: ' || L_req_list;
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_MISS_REQ_DATA');
    FND_MESSAGE.Set_Token ( 'DATA', L_req_list );
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  RETURN l_ret;

 EXCEPTION
   WHEN OTHERS THEN
     Add_Msg ( P_Action_ID, sqlerrm );
     RETURN G_NO;

END Validate_MDS;

FUNCTION Validate_WSH ( P_Action_ID			NUMBER
			, P_Deliverable_ID 		NUMBER
			, P_Task_ID			NUMBER
			, P_Ship_From_Org_ID		NUMBER
			, P_Ship_From_Location_ID	NUMBER
			, P_Ship_To_Org_ID		NUMBER
			, P_Ship_To_Location_ID		NUMBER
			, P_Expected_Date		DATE
			, P_Volume			NUMBER
			, P_Volume_Uom			VARCHAR2
			, P_Weight			NUMBER
			, P_Weight_Uom			VARCHAR2
			, P_Quantity			NUMBER
			, P_Uom_Code			VARCHAR2 )
RETURN VARCHAR2 IS

  L_Item_ID 	NUMBER;
  L_Org_ID 	NUMBER;
  L_Qty 	NUMBER;
  l_Dummy VARCHAR2(1);
  l_ret VARCHAR2(1) := G_YES;
  L_Uom_Code    VARCHAR2(30);
  L_Msg		VARCHAR2(2000);
  L_Desc	VARCHAR2(2000);
  Item_Based BOOLEAN := TRUE;
  L_ID 		NUMBER;
  L_Project_ID 	NUMBER;

  CURSOR c1 IS
  SELECT b.item_id
  , b.inventory_org_id
  , b.source_deliverable_id
  , b.project_id, 'x'
  FROM oke_deliverables_b b
  WHERE b.deliverable_id = p_deliverable_id
  AND b.source_code = 'PA';

  CURSOR c2 IS
  SELECT 'x'
  FROM oke_system_items_v
  WHERE id1 = l_item_id
  AND organization_id = l_org_id
  AND NVL(shippable_item_flag, 'N') = 'Y';

BEGIN

  FND_MSG_PUB.Initialize;
  L_req_list := NULL;

  l_dummy := NULL;
  OPEN c1;
  FETCH c1 INTO L_Item_ID, L_Org_ID, L_ID, L_Project_ID, l_dummy;
  CLOSE c1;

  IF l_dummy IS NULL THEN
    FND_MESSAGE.Set_Name ( 'OKE', 'OKE_SAVE_BEFORE_PROCEED' );
    FND_MSG_PUB.Add;
    RETURN G_NO;
  END IF;

  IF P_Quantity IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_QTY');
  END IF;

  IF P_Uom_Code IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_UOM');
  END IF;

  IF P_Task_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_TASK');
  END IF;

  IF PA_DELIVERABLE_UTILS.Is_Dlvr_Item_Based ( p_deliverable_id => L_ID ) = 'Y' THEN

    IF L_Item_ID IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_ITEM');
    END IF;

    IF NVL ( L_Org_ID, P_Ship_From_Org_ID ) IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_ORG');
    ELSE
      l_dummy := NULL;
      OPEN c2;
      FETCH c2 INTO l_dummy;
      CLOSE c2;

      IF l_Dummy IS NULL THEN
--       l_msg := 'Item is not shippable';
       FND_MESSAGE.Set_Name ( 'OKE', 'OKE_DTS_ITEM_NOSHIP');
       L_Msg := FND_MESSAGE.Get;
       Add_Msg ( P_Action_ID, L_Msg );
       l_ret := G_NO;
      END IF;
    END IF;

  ELSE
    IF P_Volume IS NULL OR P_Volume_UOM IS NULL OR P_Weight IS NULL OR P_Weight_UOM IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_VOLUME');
    END IF;

    L_Desc := PA_DELIVERABLE_UTILS.Get_Deliverable_Description ( P_Deliverable_ID => L_ID );
    IF L_Desc IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_DESC');
    END IF;
  END IF;


  IF P_Ship_To_Location_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_SHIPTO');
  END IF;

  IF P_Ship_From_Location_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_SHIPFROM');
  END IF;

  IF P_Expected_Date IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_DATE');
   ELSIF P_Expected_Date < Trunc( SYSDATE ) THEN
--    l_msg := 'The date is past due';
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_EXP_DATE_PAST_WSH' );
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  IF NOT Check_Pjm ( P_Action_ID, L_Org_ID, L_Project_ID ) THEN
--      l_msg := 'PJM setup is required';
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_NO_PJM_SETUP');
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  IF L_req_list IS NOT NULL THEN
--    l_msg := 'The following data are required: ' || L_req_list;
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_MISS_REQ_DATA');
    FND_MESSAGE.Set_Token ( 'DATA', L_req_list );
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  RETURN l_ret;

 EXCEPTION
   WHEN OTHERS THEN
     Add_Msg ( P_Action_ID, sqlerrm );
     RETURN G_NO;

END Validate_Wsh;

FUNCTION Validate_Req ( P_Action_ID			NUMBER
			, P_Deliverable_ID		NUMBER
			, P_Task_ID			NUMBER
			, P_Ship_From_Org_ID		NUMBER
			, P_Ship_From_Location_ID	NUMBER
			, P_Ship_To_Org_ID		NUMBER
			, P_Ship_To_Location_ID		NUMBER
			, P_Expected_Date		DATE
			, P_Destination_Type_Code	VARCHAR2
			, P_Requisition_Line_Type_ID	NUMBER
			, P_Category_ID			NUMBER
			, P_Currency_Code		VARCHAR2
			, P_Quantity			NUMBER
			, P_UOM_Code			VARCHAR2
			, P_Unit_Price			NUMBER
			, P_Rate_Type			VARCHAR2
			, P_Rate_Date			DATE
			, P_Exchange_Rate		NUMBER
			, P_Expenditure_Type_Code	VARCHAR2
			, P_Expenditure_Organization_Id	NUMBER
			, P_Expenditure_Item_Date	DATE )
  RETURN VARCHAR2 IS

  L_Item_ID 	NUMBER;
  L_Org_ID 	NUMBER;
  L_Qty 	NUMBER;
  l_Dummy VARCHAR2(1);
  l_ret VARCHAR2(1) := G_YES;
  L_Uom_Code    VARCHAR2(30);
  L_Msg		VARCHAR2(2000);
  L_Desc	VARCHAR2(2000);
  Item_Based BOOLEAN := TRUE;
  L_ID 		NUMBER;
  L_Error_Code 	VARCHAR2(2000);
  L_Currency_Code VARCHAR2(30);
  L_Project_ID NUMBER;
  L_Task_ID NUMBER;

  -- PATC variables
  l_msg_application      VARCHAR2(5);
  l_msg_type             VARCHAR2(1);
  l_msg_token1           VARCHAR2(200);
  l_msg_token2           VARCHAR2(200);
  l_msg_token3           VARCHAR2(200);
  l_msg_count            NUMBER;
  l_billable_flag        VARCHAR2(1);

  CURSOR c1 IS
  SELECT b.item_id ,
         nvl(b.inventory_org_id,act.ship_to_org_id) org_id ,
         b.project_id ,
         b.source_deliverable_id, 'x'
   FROM oke_deliverables_b b , oke_deliverable_actions act
  WHERE b.deliverable_id = P_Deliverable_ID
  and   b.deliverable_id = act.Deliverable_ID
  and   act.action_id = p_action_id
  AND   b.source_code = 'PA' ;

CURSOR c2 IS
  SELECT 'x'
  FROM oke_system_items_v
  WHERE id1 = l_item_id
  AND organization_id = l_org_id
  AND NVL(purchasing_enabled_flag, 'N') = 'Y';

  cursor pi is
  select 'OKE_DTS_EXP_PROJECT_INVALID'
  from   dual
  where not exists (
    select 'Project is valid'
    from   pa_projects_expend_v
    where  project_id = l_project_id )
  union all
  select 'OKE_PROJECT_NOT_SETUP'
  from   dual
  where not exists (
    select 'Project valid for PJM'
    from   pjm_project_parameters
    where  organization_id = l_org_id
    and    project_id = l_project_id )
/*  union all
  select 'OKE_DTS_EXP_TASK_INVALID'
  from   dual
  where not exists (
    select 'Task valid and chargeable'
    from   pa_tasks_expend_v t
    where  project_id = l_project_id
    and    task_id = l_task_id
    and    chargeable_flag = 'Y' ) */
  union all
  select 'OKE_TASK_REQUIRED'
  from   dual
  where not exists (
    select 'Task Reference OK'
    from   pjm_org_parameters
    where  organization_id = l_org_id
    and not (   project_control_level = 2
            and l_task_id is null )
    );

  cursor pe is
  select 'OKE_DTS_EXP_PROJECT_INVALID'
  from   dual
  where not exists (
    select 'Project is valid'
    from   pa_projects_expend_v
    where  project_id = l_project_id )
  union all
  select 'OKE_DTS_EXP_TASK_INVALID'
  from   dual
  where not exists (
    select 'Task is valid and chargeable'
    from   pa_tasks_expend_v
    where  project_id = l_project_id
    and    task_id = l_task_id
    and    chargeable_flag = 'Y' )
  union all
  select 'OKE_DTS_EXP_DATE_INVALID'
  from   dual
  where not exists (
    select 'Date is valid for task'
    from   pa_tasks t
    ,      pa_projects_all p
    where  t.project_id = l_project_id
    and    t.task_id = l_task_id
    and    p.project_id = t.project_id
    and    p_expenditure_item_date
           between nvl(t.start_date , nvl(p.start_date , p_expenditure_item_date - 1))
               and nvl(t.completion_date , nvl(p.completion_date , p_expenditure_item_date + 1)) )
  union all
  select 'OKE_DTS_EXP_TYPE_INVALID'
  from   dual
  where not exists (
    select 'Expenditure Type exists and is valid'
    from   pa_expenditure_types_expend_v
    where  expenditure_type = p_expenditure_type_code
    and    system_linkage_function = 'VI' )
  union all
  select 'OKE_DTS_EXP_ORG_INVALID'
  from   dual
  where not exists (
    select 'Expenditure Org exists and is valid'
    from   pa_organizations_expend_v
    where  organization_id = p_expenditure_organization_id );

    CURSOR c3 ( P_ID NUMBER ) IS
    SELECT 'x'
    FROM gl_sets_of_books gl, org_organization_definitions org
    WHERE org.organization_id = P_ID
    AND gl.Set_Of_Books_ID = org.Set_Of_Books_ID
    AND gl.currency_code = p_currency_code;

BEGIN

  FND_MSG_PUB.Initialize;
  L_req_list := NULL;

  l_dummy := NULL;
  OPEN c1;
  FETCH c1 INTO L_Item_ID, L_Org_ID, L_Project_ID, L_ID, l_dummy;
  CLOSE c1;

  IF l_dummy IS NULL THEN
    FND_MESSAGE.Set_Name ( 'OKE', 'OKE_SAVE_BEFORE_PROCEED' );
    FND_MSG_PUB.Add;
    RETURN G_NO;
  END IF;

  IF P_Destination_Type_Code IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_DEST_TYPE');
  END IF;

  IF P_Task_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_TASK');
  END IF;

  IF P_Uom_Code IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_UOM');
  END IF;

  Item_Based := PA_DELIVERABLE_UTILS.Is_Dlvr_Item_Based ( p_deliverable_id => L_ID ) = 'Y';
  IF Item_Based THEN

    IF L_Item_ID IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_ITEM');
     ELSE
      l_dummy := NULL;
      OPEN c2;
      FETCH c2 INTO l_dummy;
      CLOSE c2;
      IF l_dummy IS NULL THEN
--        l_msg := 'Item not purchasable';
        FND_MESSAGE.Set_Name ( 'OKE', 'OKE_DTS_ITEM_NOPO');
        L_Msg := FND_MESSAGE.Get;
        Add_Msg ( P_Action_ID, L_Msg );
        l_ret := G_NO;
      END IF;

    END IF;

    IF NVL ( L_Org_ID, P_Ship_From_Org_ID ) IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_ORG');
    END IF;

  ELSE -- if Non Item Based

    IF P_Requisition_Line_Type_ID IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_LINE_TYPE');
    END IF;

    IF P_Category_ID IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_CATEGORY');
    END IF;

    L_Desc := PA_DELIVERABLE_UTILS.Get_Deliverable_Description ( p_deliverable_id => L_ID );
    IF L_Desc IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_DESC');
    END IF;

  END IF;

  IF P_Quantity IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_QTY');
  END IF;

  IF P_Ship_To_Location_ID IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_RECLOC');
  END IF;

  IF P_Expected_Date IS NULL THEN
    Add_Attr_To_Required_List('OKE_DTS_REQ_DATE');
   ELSIF P_Expected_Date < Trunc( SYSDATE ) THEN
--    l_msg := 'The date is past due';
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_EXP_DATE_PAST_REQ' );
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  IF P_Destination_Type_Code = 'EXPENSE' AND L_Item_ID > 0 THEN
    IF P_Expenditure_Organization_ID IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_EXP_ORG');
    END IF;
    IF P_Expenditure_Item_Date IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_EXP_DATE');
    END IF;
    IF P_Expenditure_Type_Code IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_EXP_TYPE');
    END IF;
  END IF;

  l_dummy := null;
  OPEN c3 ( L_Org_ID );
  FETCH c3 INTO l_dummy;
  CLOSE c3;

  IF l_dummy IS NULL THEN
    IF P_Exchange_Rate IS NULL THEN
      Add_Attr_To_Required_List('OKE_DTS_REQ_RATE');
    END IF;
  END IF;

  IF L_req_list IS NOT NULL THEN
--    l_msg := 'The following data are required: ' || L_req_list;
    FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_MISS_REQ_DATA');
    FND_MESSAGE.Set_Token ( 'DATA', L_req_list );
    L_Msg := FND_MESSAGE.Get;
    Add_Msg ( P_Action_ID, L_Msg );
    l_ret := G_NO;
  END IF;

  L_Task_ID := P_Task_ID;
  IF ( P_Destination_Type_Code = 'INVENTORY' ) then

    l_error_code := NULL;
    open pi;
    loop
      fetch pi into l_error_code;
      exit when pi%notfound;
      FND_MESSAGE.Set_Name('OKE' , l_error_code);
      FND_MSG_PUB.Add;
    end loop;
    close pi;
    if ( l_error_code is not null ) then
      l_ret := G_NO;
    end if;

    IF NOT Check_Pjm ( P_Action_ID, L_Org_ID, L_Project_ID ) THEN
--      l_msg := 'PJM setup is required';
      FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_NO_PJM_SETUP');
      L_Msg := FND_MESSAGE.Get;
      Add_Msg ( P_Action_ID, L_Msg );
      l_ret := G_NO;
    END IF;

  ELSE -- Destination_Type_Code = 'EXPENSE'

    l_error_code := NULL;
    open pe;
    loop
      fetch pe into l_error_code;
      exit when pe%notfound;
      FND_MESSAGE.Set_Name('OKE' , l_error_code);
      L_Msg := FND_MESSAGE.Get;
      Add_Msg ( P_Action_ID, L_Msg );
    end loop;
    close pe;
    if ( l_error_code is not null ) then
      l_ret := G_NO;
    end if;

  END IF;

  IF l_ret = G_YES AND P_Destination_Type_Code = 'EXPENSE' THEN
    PATC.get_status(
        X_project_id 			=> L_Project_ID
      , X_task_id 			=> P_Task_ID
      , X_ei_date 			=> p_expenditure_item_date
      , X_expenditure_type 		=> P_Expenditure_Type_Code
      , X_non_labor_resource 		=> NULL --X_non_labor_resource --?
      , X_person_id 			=> NULL --X_person_id --?
      , X_quantity 			=> P_Quantity
      , X_denom_currency_code 	=> P_Currency_Code
  --    , X_acct_currency_code 		=> X_acct_currency_code --?
      , X_denom_raw_cost 		=> P_Unit_Price
  --    , X_acct_raw_cost 		=> X_acct_raw_cost --?
      , X_acct_rate_type 		=> P_Rate_Type
      , X_acct_rate_date 		=> P_RATE_DATE
      , X_acct_exchange_rate 		=>P_EXCHANGE_RATE
  --    , X_transfer_ei 		=> X_transfer_ei
      , X_incurred_by_org_id 		=> P_Expenditure_Organization_ID
      , X_msg_application 		=> l_msg_application
      , X_msg_type 			=> l_msg_type
      , X_msg_token1 			=> l_msg_token1
      , X_msg_token2 			=> l_msg_token2
      , X_msg_token3 			=> l_msg_token3
      , X_msg_count 			=> l_msg_count
      , X_status 			=> l_msg
      , X_billable_flag 		=> l_billable_flag
    );

    IF l_msg IS NOT NULL THEN
      FND_MESSAGE.SET_NAME(l_Msg_Application, l_msg);
      IF l_Msg_Token1 IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN('patc_msg_token1', l_Msg_Token1);
      END IF;
      IF l_Msg_Token2 IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN('patc_msg_token2', l_Msg_Token2);
      END IF;
      IF l_Msg_Token3 IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN('patc_msg_token3', l_Msg_Token3);
      END IF;
      FND_MSG_PUB.Add;
      l_ret := G_NO;
    END IF;
  END IF;

  RETURN l_ret;

 EXCEPTION
   WHEN OTHERS THEN
     Add_Msg ( P_Action_ID, sqlerrm );
     RETURN G_NO;

END Validate_Req;

FUNCTION Exchange_Rate ( P_Orig_Code VARCHAR2
			, P_Target_Code VARCHAR2
			, P_Rate_Type VARCHAR2
			, P_Date DATE ) RETURN NUMBER IS
  ConvAmt      number;
  Numerator    number;
  Denom        number;
  Rate         number;
  Func_Code    varchar2(30);
  Unit_Price   number := 0;

BEGIN
  IF P_Orig_Code <> P_Target_Code THEN
     GL_CURRENCY_API.Convert_Amount
      	( X_From_Currency    => P_Orig_Code
      	, X_To_Currency      => P_Target_Code
      	, X_Conversion_Date  => P_Date
      	, X_Conversion_Type  => P_Rate_Type
      	, X_Amount           => Unit_Price
      	, X_Converted_Amount => ConvAmt
      	, X_Denominator      => Denom
      	, X_Numerator        => Numerator
      	, X_Rate             => Rate
      	);
    RETURN Rate;
  ELSE
    RETURN NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Exchange_Rate;

FUNCTION Functional_Currency ( P_Org_ID NUMBER ) RETURN VARCHAR2 IS

  L_Currency_Code VARCHAR2(30);
  CURSOR c IS
  SELECT gl.Currency_Code
  FROM gl_sets_of_books gl, org_organization_definitions org
  WHERE org.ORGANIZATION_ID = P_Org_ID
  AND gl.Set_Of_Books_ID = org.Set_Of_Books_ID;

BEGIN

  OPEN c;
  FETCH c INTO L_Currency_Code;
  CLOSE c;

  RETURN L_Currency_Code;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Functional_Currency;

FUNCTION Get_Location_Description ( P_ID NUMBER ) RETURN VARCHAR2 IS
l_return_val VARCHAR2(240);

CURSOR c_hr IS
SELECT nvl(description,'')
FROM hr_locations_all
WHERE location_id=p_id;

CURSOR c_hz IS
SELECT substr(address1,1,240)
FROM hz_locations
WHERE location_id=p_id;

CURSOR c_both IS
SELECT description
FROM hr_locations
WHERE location_id=p_id;

BEGIN

OPEN c_hr;
FETCH c_hr INTO l_return_val;
IF c_hr%NOTFOUND THEN
 OPEN c_hz;
 FETCH c_hz INTO l_return_val;
 IF c_hz%NOTFOUND THEN
  l_return_val:='ERROR-NO SUCH LOCATION_ID';
 END IF;
 CLOSE c_hz;
END IF;
CLOSE c_hr;
RETURN l_return_val;

END;

END;


/
