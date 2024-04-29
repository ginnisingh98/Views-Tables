--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_UTILS_PUB" AS
/* $Header: OKEPDUTB.pls 120.1 2006/09/08 23:00:09 sasethi noship $ */

--
-- Private Global Variables
--
G_Yes          CONSTANT VARCHAR2(80)                    := 'Y';
G_No           CONSTANT VARCHAR2(80)                    := 'N';
G_PKG_Name	CONSTANT VARCHAR2(30)			:= 'OKE_DELIVERABLE_UTILS_PUB';
G_API_Type 	CONSTANT VARCHAR2(30)			:= 'PROCEDURE';


--
--  Name          : MDS_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether certain
--   		    Action has been executed
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION MDS_Initiated_Yn ( P_Action_ID 	NUMBER)
RETURN VARCHAR2 IS

  CURSOR c IS
  SELECT reference2
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_action_id
  AND action_type = 'WSH';

  L_Ref_2 NUMBER;

BEGIN

  IF P_Action_ID > 0 THEN
    OPEN c;
    FETCH c INTO L_Ref_2;
    CLOSE c;

    IF L_Ref_2 > 0 THEN
      RETURN G_Yes;
    ELSE
      RETURN G_No;
    END IF;
  ELSE
    RETURN ( NULL ) ;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END MDS_Initiated_Yn;

--
--  Name          : WSH_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether shipping
--   		    Action has been executed
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION WSH_Initiated_Yn ( P_Action_ID 	NUMBER)
RETURN VARCHAR2 IS

  CURSOR c IS
  SELECT reference1
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_action_id
  AND action_type = 'WSH';

  L_Ref_1 NUMBER;

BEGIN

  IF P_Action_ID > 0 THEN
    OPEN c;
    FETCH c INTO L_Ref_1;
    CLOSE c;

    IF L_Ref_1 > 0 THEN
      RETURN G_Yes;
    ELSE
      RETURN G_No;
    END IF;
  ELSE
    RETURN ( NULL ) ;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Wsh_Initiated_Yn;

--
--  Name          : REQ_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether procure
--   		    Action has been executed
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION REQ_Initiated_Yn ( P_Action_ID 	NUMBER)
RETURN VARCHAR2 IS

  L_Ref_1 NUMBER;
  L_Action_ID NUMBER;
  L_Project_ID NUMBER;
  L_Flag VARCHAR2(1) := G_NO;

  CURSOR c IS
  SELECT a.reference1, a.action_id, d.project_id
    FROM oke_deliverable_actions a, oke_deliverables_b d
    WHERE a.pa_action_id = p_action_id  AND action_type = 'REQ'
      AND d.deliverable_id = a.deliverable_id
  ;

  CURSOR d IS
   SELECT Decode(process_flag, 'ERROR', G_NO, G_YES)
     FROM po_requisitions_interface_all
     WHERE oke_contract_deliverable_id = l_action_id AND batch_id = l_ref_1
  ;

  CURSOR r IS
   SELECT G_YES
     FROM oke_deliverable_requisitions_v
     WHERE ACTION_ID = l_action_id and project_id = l_project_id
  ;

BEGIN

  IF P_Action_ID > 0 THEN
    OPEN c;
    FETCH c INTO L_Ref_1, L_Action_ID, l_project_id;
    CLOSE c;

    IF L_Ref_1 > 0 THEN
      OPEN d;
      FETCH d INTO L_Flag;
      IF d%NOTFOUND THEN
        OPEN r;
        FETCH r INTO L_Flag;
        CLOSE r;
      END IF;
      CLOSE d;
    END IF;
    RETURN l_flag;
  ELSE
    RETURN ( NULL ) ;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Req_Initiated_Yn;

--
--  Name          : Item_Defined_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    has been defined for the action
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Defined_Yn ( P_Deliverable_ID 	NUMBER)
RETURN VARCHAR2 IS

    L_Dummy NUMBER;

    CURSOR c IS
    SELECT 1
    FROM oke_deliverables_b
    WHERE source_code = 'PA'
    AND source_deliverable_id = p_deliverable_id
    AND item_id > 0;

  BEGIN
    OPEN c;
    FETCH c INTO L_Dummy;
    IF c%NOTFOUND THEN
      CLOSE c;
      RETURN 'N';
    END IF;

    CLOSE c;
    RETURN 'Y';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';

END Item_Defined_Yn;


--
--  Name          : Ready_To_Ship_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether ready_to_ship
--   		    has been checked for the action
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Ready_To_Ship_Yn ( P_Action_ID 	NUMBER)
RETURN VARCHAR2 IS

  CURSOR c IS
  SELECT NVL(ready_flag, 'N')
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_action_id
  AND action_type = 'WSH';

  L_Value VARCHAR2(1);

BEGIN

  IF P_Action_ID > 0 THEN
    OPEN C;
    FETCH C INTO L_Value;
    CLOSE C;

    RETURN L_Value;
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Ready_To_Ship_Yn;

--
--  Name          : Ready_To_Procure_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether ready_to_procure
--   		    has been checked for the action
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Ready_To_Procure_Yn ( P_Action_ID 	NUMBER)
RETURN VARCHAR2 IS
  CURSOR c IS
  SELECT NVL(ready_flag, 'N'), reference1
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_action_id
  AND action_type = 'REQ';

  CURSOR d IS
  SELECT 1
  FROM dual
  WHERE EXISTS ( SELECT 1
		 FROM po_requisitions_interface_all
		 WHERE oke_contract_deliverable_id = p_action_id
		 AND process_flag = 'ERROR');

  L_Value VARCHAR2(1);
  L_Flag NUMBER;
  L_Ref NUMBER;

BEGIN

  IF P_Action_ID > 0 THEN
    OPEN C;
    FETCH C INTO L_Value, L_Ref;
    CLOSE C;

    IF L_Value = 'Y' AND L_Ref > 0 THEN
      OPEN d;
      FETCH d INTO L_Flag;
      CLOSE d;

      IF L_Flag <> 1 THEN
        L_Value := 'N';
      END IF;
    END IF;

    RETURN L_Value;
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Ready_To_Procure_Yn;


--
--  Name          : Item_Shippable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    is shippable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	Deliverable ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Shippable_Yn ( P_Deliverable_ID 	NUMBER)
RETURN VARCHAR2 IS

  CURSOR c IS
  SELECT NVL(shippable_item_flag, 'N')
  FROM oke_system_items_v
  WHERE id1 = (
	SELECT item_id
	FROM oke_deliverables_b
        WHERE source_code = 'PA'
	AND source_deliverable_id = p_deliverable_id );

  L_Value VARCHAR2(1);

BEGIN

  IF P_Deliverable_ID > 0 THEN
    OPEN C;
    FETCH C INTO L_Value;
    CLOSE C;

    RETURN L_Value;
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Item_Shippable_Yn;


--
--  Name          : Item_Billable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    is billable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	Deliverable ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Billable_Yn ( P_Deliverable_ID 	NUMBER)
RETURN VARCHAR2 IS

  CURSOR c IS
  SELECT NVL(invoiceable_item_flag, 'N')
  FROM oke_system_items_v
  WHERE id1 = (
	SELECT item_id
	FROM oke_deliverables_b
        WHERE source_code = 'PA'
	AND source_deliverable_id = p_deliverable_id );

  L_Value VARCHAR2(1);

BEGIN

  IF P_Deliverable_ID > 0 THEN
    OPEN C;
    FETCH C INTO L_Value;
    CLOSE C;

    RETURN L_Value;
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Item_Billable_Yn;

--
--  Name          : Item_Purchasable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    is purchasable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	Deliverable ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Purchasable_Yn ( P_Deliverable_ID 	NUMBER)
RETURN VARCHAR2 IS

  CURSOR c IS
  SELECT NVL(purchasing_enabled_flag, 'N')
  FROM oke_system_items_v
  WHERE id1 = (
	SELECT item_id
	FROM oke_deliverables_b
        WHERE source_code = 'PA'
    	AND source_deliverable_id = p_deliverable_id );

  L_Value VARCHAR2(1);

BEGIN

  IF P_Deliverable_ID > 0 THEN
    OPEN C;
    FETCH C INTO L_Value;
    CLOSE C;

    RETURN L_Value;
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_No;
  WHEN OTHERS THEN
    RETURN ( NULL );

END Item_purchasable_Yn;

FUNCTION Action_Deletable_Yn ( P_Action_ID NUMBER )
RETURN VARCHAR2 IS

Dummy NUMBER;

BEGIN

  SELECT 1
  INTO dummy
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_action_id
  AND reference1 > 0
  AND NOT EXISTS ( SELECT 1
	FROM po_requisitions_interface_all
 	WHERE oke_contract_deliverable_id = p_action_id
	AND process_flag = 'ERROR' );

  RETURN G_No;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN G_Yes;
  WHEN OTHERS THEN
    RETURN G_No;
END Action_Deletable_Yn;

PROCEDURE Copy_Item ( P_Source_Project_ID 	NUMBER
		, P_Target_Project_ID		NUMBER
		, P_Source_Deliverable_ID	NUMBER
		, P_Target_Deliverable_ID	NUMBER
		, P_Target_Deliverable_Number	VARCHAR2
		, P_Copy_Item_Details_Flag 	VARCHAR2
		, X_Return_Status	    OUT NOCOPY VARCHAR2
		, X_Msg_Count		    OUT NOCOPY NUMBER
		, X_Msg_Data		    OUT NOCOPY VARCHAR2 ) IS

  L_API_Name		CONSTANT VARCHAR2(30) := 'COPY_ITEM';
  L_Init_Msg_List       CONSTANT VARCHAR2(1) := 'T';
  L_Return_Status 	VARCHAR2(1);
  L_ID			NUMBER;
  L_Name		VARCHAR2(120);
  L_Number		VARCHAR2(120);
  L_Deliverable_ID	NUMBER;
  L_Deliverable_Description oke_deliverables_tl.description%TYPE;
  L_Deliverable_Comments oke_deliverables_tl.comments%TYPE;

  CURSOR c IS
  SELECT deliverable_id, description, comments
  FROM oke_deliverables_vl
  WHERE source_code = 'PA'
  AND source_header_id = p_source_project_id
  AND source_deliverable_id = p_source_deliverable_id;


BEGIN

  L_Return_Status := OKE_API.Start_Activity (
		P_Api_Name	=> L_Api_Name,
		P_Init_Msg_List => L_Init_Msg_List,
		P_API_Type	=> G_API_Type,
		X_Return_Status => X_Return_Status );
  IF ( L_Return_Status = OKE_API.G_RET_STS_ERROR ) THEN
    RAISE OKE_API.G_Exception_Error;
  ELSIF ( L_Return_Status = OKE_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  IF P_Source_Project_ID IS NULL
    OR P_Target_Project_ID IS NULL
    OR P_Source_Deliverable_ID IS NULL
    OR P_Target_Deliverable_ID IS NULL THEN

    FND_MESSAGE.Set_Name ( 'OKE', 'OKE_REQ_PARAMETER');
    FND_MSG_PUB.Add;
    RAISE OKE_API.G_Exception_Error;

  END IF;

  SELECT oke_k_deliverables_s.nextval
  INTO l_id
  FROM DUAL;

  OPEN c;
  FETCH c INTO L_Deliverable_ID, L_Deliverable_Description, L_Deliverable_Comments;
  CLOSE c;

  IF NVL( P_Copy_Item_Details_Flag, 'N' ) =  'Y' THEN

    INSERT INTO oke_deliverables_b (
	deliverable_id
	, creation_date
	, created_by
	, last_updated_by
	, last_update_date
 	, last_update_login
	, deliverable_number
	, source_code
	, source_header_id
	, source_line_id
	, source_deliverable_id
	, project_id
	, delivery_date
	, item_id
	, currency_code
	, inventory_org_id
	, unit_price
	, uom_code
	, quantity
	, unit_number )
    SELECT l_id
	, sysdate
	, fnd_global.user_id
	, fnd_global.user_id
	, sysdate
	, fnd_global.login_id
	, p_target_deliverable_number
	, 'PA'
	, p_target_project_id
	, null
	, p_target_deliverable_id
	, p_target_project_id
	, delivery_date
	, item_id
	, currency_code
	, inventory_org_id
	, unit_price
	, uom_code
	, quantity
	, unit_number
    FROM oke_deliverables_b
    WHERE source_code = 'PA'
    AND source_header_id = p_source_project_id
    AND source_deliverable_id = p_source_deliverable_id;

  ELSE

   INSERT INTO oke_deliverables_b (
	deliverable_id
	, creation_date
	, created_by
	, last_updated_by
	, last_update_date
 	, last_update_login
	, deliverable_number
	, source_code
	, source_header_id
	, source_line_id
	, source_deliverable_id
	, project_id
	, delivery_date)
    SELECT l_id
	, sysdate
	, fnd_global.user_id
	, fnd_global.user_id
	, sysdate
	, fnd_global.login_id
	, p_target_deliverable_number
	, 'PA'
	, p_target_project_id
	, null
	, p_target_deliverable_id
	, p_target_project_id
	, delivery_date
    FROM oke_deliverables_b
    WHERE source_code = 'PA'
    AND source_header_id = p_source_project_id
    AND source_deliverable_id = p_source_deliverable_id;
  END IF;

  INSERT INTO oke_deliverables_tl (
  	deliverable_id
	, language
	, creation_date
	, created_by
	, last_update_date
	, last_updated_by
	, last_update_login
	, source_lang
	, description
	, comments )
  SELECT l_id
	, l.language_code
	, sysdate
	, fnd_global.user_id
	, sysdate
	, fnd_global.user_id
	, fnd_global.login_id
	, oke_utils.get_userenv_lang
	, L_Deliverable_Description
	, L_Deliverable_Comments
  FROM fnd_languages l
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND  not exists
      (select NULL
      from OKE_DELIVERABLES_TL T
      where T.DELIVERABLE_ID = l_id
      and T.LANGUAGE = L.LANGUAGE_CODE);


  OKE_API.End_Activity ( X_Msg_Count => X_Msg_Count
			, X_Msg_Data => X_Msg_Data );

  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Copy_Item;

PROCEDURE Copy_Action ( P_Source_Project_ID 	NUMBER
		, P_Target_Project_ID		NUMBER
		, P_Source_Deliverable_ID	NUMBER
		, P_Target_Deliverable_ID	NUMBER
		, P_Source_Action_ID		NUMBER
		, P_Target_Action_ID		NUMBER
		, P_Target_Action_Name		VARCHAR2
		, P_Target_Action_Date		DATE
		, X_Return_Status	    OUT NOCOPY VARCHAR2
		, X_Msg_Count		    OUT NOCOPY NUMBER
		, X_Msg_Data		    OUT NOCOPY VARCHAR2 ) IS

  L_API_Name		CONSTANT VARCHAR2(30) := 'COPY_ACTION';
  L_Init_Msg_List       CONSTANT VARCHAR2(1) := 'T';
  L_Return_Status 	VARCHAR2(1);
  L_Deliverable_ID	NUMBER;
  l_currency_code VARCHAR2(30);
  l_inventory_org_id	NUMBER;
  l_unit_price	NUMBER;
  l_uom_code VARCHAR2(30);
  l_quantity	NUMBER;
  l_Item_Based_YN VARCHAR2(1);

  CURSOR c IS
  SELECT deliverable_id, currency_code, inventory_org_id,
         unit_price, uom_code, quantity,
         PA_DELIVERABLE_UTILS.IS_DLVR_ITEM_BASED(p_target_deliverable_id) Item_Based_YN
  FROM oke_deliverables_b
  WHERE source_code = 'PA'
  AND source_header_id = p_target_project_id
  AND source_deliverable_id = p_target_deliverable_id;

BEGIN

  L_Return_Status := OKE_API.Start_Activity (
		P_Api_Name	=> L_Api_Name,
		P_Init_Msg_List => L_Init_Msg_List,
		P_API_Type	=> G_API_Type,
		X_Return_Status => X_Return_Status );
  IF ( L_Return_Status = OKE_API.G_RET_STS_ERROR ) THEN
    RAISE OKE_API.G_Exception_Error;
  ELSIF ( L_Return_Status = OKE_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  IF P_Source_Project_ID IS NULL
    OR P_Target_Project_ID IS NULL
    OR P_Source_Deliverable_ID IS NULL
    OR P_Target_Deliverable_ID IS NULL
    OR P_Source_Action_ID IS NULL
    OR P_Target_Action_ID IS NULL THEN

    FND_MESSAGE.Set_Name ( 'OKE', 'OKE_REQ_PARAMETER');
    FND_MSG_PUB.Add;
    RAISE OKE_API.G_Exception_Error;

  END IF;

  OPEN c;
  FETCH c INTO L_Deliverable_ID, l_currency_code, l_inventory_org_id,
         l_unit_price, l_uom_code, l_quantity, l_Item_Based_YN;
  CLOSE C;

  INSERT INTO oke_deliverable_actions (
    action_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , action_type
    , action_name
    , pa_action_id
    , deliverable_id
    , ship_to_org_id
    , ship_to_location_id
    , ship_from_org_id
    , ship_from_location_id
    , inspection_req_flag
    , expected_date
    , schedule_designator
    , volume
    , volume_uom_code
    , weight
    , weight_uom_code
    , expenditure_organization_id
    , expenditure_type
    , expenditure_item_date
    , destination_type_code
    , rate_type
    , rate_date
    , exchange_rate
    , requisition_line_type_id
    , po_category_id
    , unit_price
    , currency_code
    , quantity
    , uom_code)
  SELECT oke_k_deliverables_s.nextval
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , fnd_global.login_id
    , action_type
    , p_target_action_name
    , p_target_action_id
    , l_deliverable_id

    , Decode( action_type||','||l_Item_Based_YN,
            'REQ,Y', l_inventory_org_id, ship_to_org_id ) ship_to_org_id
    , Decode( action_type||','||l_Item_Based_YN||','||Nvl(l_inventory_org_id,''),
            'REQ,Y,', NULL, ship_to_location_id ) ship_to_location_id

    , Decode( action_type||','||l_Item_Based_YN,
            'WSH,Y', l_inventory_org_id, ship_from_org_id ) ship_from_org_id
    , Decode( action_type||','||l_Item_Based_YN||','||Nvl(l_inventory_org_id,''),
            'WSH,Y,', NULL, ship_from_location_id ) ship_from_location_id

    , inspection_req_flag
    , p_target_action_date
    , Decode( l_inventory_org_id, NULL, NULL, schedule_designator) schedule_designator
    , volume
    , volume_uom_code
    , weight
    , weight_uom_code
    , expenditure_organization_id
    , expenditure_type
    , expenditure_item_date
    , destination_type_code
    , rate_type
    , rate_date
    , exchange_rate
    , requisition_line_type_id
    , po_category_id
    , Decode( l_Item_Based_YN, 'Y', l_unit_price, unit_price)
    , Decode( l_Item_Based_YN, 'Y', l_currency_code, currency_code)
    , Decode( l_Item_Based_YN, 'Y', l_quantity, quantity)
    , Decode( l_Item_Based_YN, 'Y', l_uom_code, uom_code)
  FROM oke_deliverable_actions
  WHERE pa_action_id = p_source_action_id;

  OKE_API.End_Activity ( X_Msg_Count => X_Msg_Count
			, X_Msg_Data => X_Msg_Data );

  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Copy_Action;

PROCEDURE Delete_Action ( P_Action_ID 		NUMBER -- PA_ACTION_ID
			, X_Return_Status	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 ) IS

  L_API_Name		CONSTANT VARCHAR2(30) := 'DELETE_ACTION';
  L_Init_Msg_List       CONSTANT VARCHAR2(1) := 'T';
  L_Return_Status 	VARCHAR2(1);

BEGIN

  L_Return_Status := OKE_API.Start_Activity (
		P_Api_Name	=> L_Api_Name,
		P_Init_Msg_List => L_Init_Msg_List,
		P_API_Type	=> G_API_Type,
		X_Return_Status => X_Return_Status );
  IF ( L_Return_Status = OKE_API.G_RET_STS_ERROR ) THEN
    RAISE OKE_API.G_Exception_Error;
  ELSIF ( L_Return_Status = OKE_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  OKE_DELIVERABLE_ACTIONS_PKG.Delete_Action ( P_Action_ID );

  X_Return_Status := L_Return_Status;
  OKE_API.End_Activity ( X_Msg_Count => X_Msg_Count
			, X_Msg_Data => X_Msg_Data );
EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Delete_Action;

PROCEDURE Delete_Demand ( P_Action_ID 		NUMBER -- OKE_ACTION_ID
			, X_Return_Status	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 ) IS

  L_API_Name		CONSTANT VARCHAR2(30) := 'DELETE_DEMAND';
  L_Init_Msg_List       CONSTANT VARCHAR2(1) := 'T';
  L_Return_Status 	VARCHAR2(1);

BEGIN

  L_Return_Status := OKE_API.Start_Activity (
		P_Api_Name	=> L_Api_Name,
		P_Init_Msg_List => L_Init_Msg_List,
		P_API_Type	=> G_API_Type,
		X_Return_Status => X_Return_Status );
  IF ( L_Return_Status = OKE_API.G_RET_STS_ERROR ) THEN
    RAISE OKE_API.G_Exception_Error;
  ELSIF ( L_Return_Status = OKE_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  OKE_DELIVERABLE_ACTIONS_PKG.Delete_Row ( P_Action_ID );

  X_Return_Status := L_Return_Status;
  OKE_API.End_Activity ( X_Msg_Count => X_Msg_Count
			, X_Msg_Data => X_Msg_Data );
EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Delete_Demand;

PROCEDURE Delete_Deliverable ( P_Deliverable_ID	NUMBER
			, X_Return_Status	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 ) IS

  L_API_Name		CONSTANT VARCHAR2(30) := 'DELETE_DELIVERABLE';
  L_Init_Msg_List       CONSTANT VARCHAR2(1) := 'T';
  L_Return_Status 	VARCHAR2(1);

BEGIN

  L_Return_Status := OKE_API.Start_Activity (
		P_Api_Name	=> L_Api_Name,
		P_Init_Msg_List => L_Init_Msg_List,
		P_API_Type	=> G_API_Type,
		X_Return_Status => X_Return_Status );
  IF ( L_Return_Status = OKE_API.G_RET_STS_ERROR ) THEN
    RAISE OKE_API.G_Exception_Error;
  ELSIF ( L_Return_Status = OKE_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  OKE_DELIVERABLE_ACTIONS_PKG.Delete_Deliverable ( P_Deliverable_ID );

  X_Return_Status := L_Return_Status;
  OKE_API.End_Activity ( X_Msg_Count => X_Msg_Count
			, X_Msg_Data => X_Msg_Data );
EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Delete_Deliverable;

FUNCTION Unit_Price ( P_Item_ID NUMBER
		, P_Org_ID NUMBER ) RETURN NUMBER IS

  L_Return_Status VARCHAR2(1);
  L_Msg_Count NUMBER;
  L_Msg_Data VARCHAR2(2000);
  L_Unit_Price NUMBER;

  cursor c is
  select list_price_per_unit
  from mtl_system_items_b
  where organization_id = p_org_id
  and inventory_item_id = p_item_id;


BEGIN

/*  CST_ItemResourceCosts_GRP.Get_ItemCost (
       p_api_version           => 1,
       p_init_msg_list         => FND_API.G_FALSE,
       p_commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       x_return_status         => L_Return_Status,
       x_msg_count             => L_Msg_Count,
       x_msg_data              => L_Msg_Data,
       p_item_id               => P_Item_ID,
       p_organization_id       => P_Org_ID,
       p_cost_source           => 3,
       p_cost_type_id          => 0,
       x_item_cost             => L_Unit_Price ); */

  open c;
  fetch c into l_unit_price;
  close c;

  RETURN L_Unit_Price;

END;

FUNCTION Currency_Code ( P_Item_ID NUMBER, P_Org_ID NUMBER )
RETURN VARCHAR2 IS

BEGIN
  RETURN 'USD';

END;

PROCEDURE Batch_MDS ( P_Project_ID NUMBER
		, P_Task_ID NUMBER
		, P_Init_Msg_List VARCHAR2
		, X_Return_Status OUT NOCOPY VARCHAR2
		, X_Msg_Count OUT NOCOPY NUMBER
		, X_Msg_Data OUT NOCOPY VARCHAR2 ) IS

  CURSOR c1 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND a.reference2 is null
  AND b.item_id > 0
  AND b.quantity > 0
  AND b.inventory_org_id > 0
  AND b.uom_code IS NOT NULL
  AND a.schedule_designator IS NOT NULL
  AND a.action_type = 'WSH'
  AND a.expected_date >= sysdate;

  c1rec c1%ROWTYPE;

  CURSOR c2 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND a.reference2 is null
  AND b.project_id = p_project_id
  AND b.item_id > 0
  AND b.quantity > 0
  AND b.inventory_org_id > 0
  AND b.uom_code IS NOT NULL
  AND a.schedule_designator IS NOT NULL
  AND a.action_type = 'WSH'
  AND a.expected_date >= sysdate;

  c2rec c1%ROWTYPE;

  CURSOR c3 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND a.reference2 is null
  AND a.task_id = p_task_id
  AND b.item_id > 0
  AND b.quantity > 0
  AND b.inventory_org_id > 0
  AND b.uom_code IS NOT NULL
  AND a.schedule_designator IS NOT NULL
  AND a.action_type = 'WSH'
  AND a.expected_date >= sysdate;

  c3rec c1%ROWTYPE;

  L_Return_Status 		VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
  L_API_Version			CONSTANT NUMBER := 1;
  L_API_Name			CONSTANT VARCHAR2(30) := 'BATCH_DEMAND';
  L_ID 				NUMBER;
  L_Msg_Count			NUMBER;
  L_Msg_Data			VARCHAR2(2000);


BEGIN

  L_Return_Status := OKE_API.Start_Activity ( L_Api_Name
					, P_Init_Msg_List
					, '_PKG'
					, X_Return_Status );

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  IF P_Project_ID IS NULL THEN
    FOR c1rec IN c1 LOOP

      OKE_DELIVERABLE_ACTIONS_PKG.Create_Demand ( c1rec.action_id
				, 'F'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  ELSIF P_Project_ID > 0 AND P_Task_ID IS NULL THEN
    FOR c2rec IN c2 LOOP
      OKE_DELIVERABLE_ACTIONS_PKG.Create_Demand ( c2rec.action_id
				, 'F'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  ELSIF P_Task_ID > 0 THEN
    FOR c3rec IN c3 LOOP
      OKE_DELIVERABLE_ACTIONS_PKG.Create_Demand ( c3rec.action_id
				, 'F'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  END IF;

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
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
  END Batch_MDS;

  PROCEDURE Batch_Req ( P_Project_ID NUMBER
		, P_Task_ID NUMBER
		, P_Init_Msg_List VARCHAR2
		, X_Return_Status OUT NOCOPY VARCHAR2
		, X_Msg_Count OUT NOCOPY NUMBER
		, X_Msg_Data OUT NOCOPY VARCHAR2 ) IS

  CURSOR c1 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND b.source_code = 'PA'
  AND ( a.reference1 is null OR EXISTS (
		SELECT 1
 		FROM po_requisitions_interface_all
 		WHERE oke_contract_deliverable_id > 0
		AND process_flag = 'ERROR'
		AND batch_id = a.reference1 ))
  AND NVL ( a.ready_flag, 'N' ) = 'Y'
  AND a.action_type = 'REQ'
  AND a.expected_date >= sysdate;

  c1rec c1%ROWTYPE;

  CURSOR c2 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND b.source_code = 'PA'
  AND b.source_header_id = p_project_id
  AND ( a.reference1 is null OR EXISTS (
		SELECT 1
 		FROM po_requisitions_interface_all
 		WHERE oke_contract_deliverable_id > 0
		AND process_flag = 'ERROR'
		AND batch_id = a.reference1 ))
  AND NVL ( a.ready_flag, 'N' ) = 'Y'
  AND a.action_type = 'REQ'
  AND a.expected_date >= sysdate;

  c2rec c1%ROWTYPE;

  CURSOR c3 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND b.source_code = 'PA'
  AND b.source_header_id = p_project_id
  AND ( a.reference1 is null OR EXISTS (
		SELECT 1
 		FROM po_requisitions_interface_all
 		WHERE oke_contract_deliverable_id > 0
		AND process_flag = 'ERROR'
		AND batch_id = a.reference1 ))
  AND NVL ( a.ready_flag, 'N' ) = 'Y'
  AND a.action_type = 'REQ'
  AND a.task_id = p_task_id
  AND a.expected_date >= sysdate;

  c3rec c1%ROWTYPE;

  L_Return_Status 		VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
  L_API_Version			CONSTANT NUMBER := 1;
  L_API_Name			CONSTANT VARCHAR2(30) := 'BATCH_REQ';
  L_ID 				NUMBER;
  L_Msg_Count			NUMBER;
  L_Msg_Data			VARCHAR2(2000);


BEGIN

  L_Return_Status := OKE_API.Start_Activity ( L_Api_Name
					, P_Init_Msg_List
					, '_PKG'
					, X_Return_Status );

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  IF P_Project_ID IS NULL THEN
    FOR c1rec IN c1 LOOP

      OKE_DELIVERABLE_ACTIONS_PKG.Create_Requisition ( c1rec.action_id
				, 'T'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  ELSIF P_Project_ID > 0 AND P_Task_ID IS NULL THEN
    FOR c2rec IN c2 LOOP
      OKE_DELIVERABLE_ACTIONS_PKG.Create_Requisition ( c2rec.action_id
				, 'T'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  ELSIF P_Task_ID > 0 THEN
    FOR c3rec IN c3 LOOP
      OKE_DELIVERABLE_ACTIONS_PKG.Create_Requisition ( c3rec.action_id
				, 'T'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  END IF;

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
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

  END Batch_REQ;

  PROCEDURE Batch_Wsh ( P_Project_ID NUMBER
		, P_Task_ID NUMBER
		, P_Init_Msg_List VARCHAR2
		, X_Return_Status OUT NOCOPY VARCHAR2
		, X_Msg_Count OUT NOCOPY NUMBER
		, X_Msg_Data OUT NOCOPY VARCHAR2 ) IS


  CURSOR c1 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND b.source_code = 'PA'
  AND a.reference1 is null
  AND NVL ( a.ready_flag, 'N' ) = 'Y'
  AND a.action_type = 'WSH'
  AND a.expected_date >= sysdate;

  c1rec c1%ROWTYPE;

  CURSOR c2 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND b.source_code = 'PA'
  AND b.source_header_id = p_project_id
  AND a.reference1 is null
  AND NVL ( a.ready_flag, 'N' ) = 'Y'
  AND a.action_type = 'WSH'
  AND a.expected_date >= sysdate;

  c2rec c1%ROWTYPE;

  CURSOR c3 IS
  SELECT a.action_id
  FROM oke_deliverables_b b
  , oke_deliverable_actions a
  WHERE b.deliverable_id = a.deliverable_id
  AND b.source_code = 'PA'
  AND b.source_header_id = p_project_id
  AND a.reference1 is null
  AND NVL ( a.ready_flag, 'N' ) = 'Y'
  AND a.action_type = 'WSH'
  AND a.task_id = p_task_id
  AND a.expected_date >= sysdate;

  c3rec c1%ROWTYPE;

  L_Return_Status 		VARCHAR2(1) := OKE_API.G_Ret_Sts_Success;
  L_API_Version			CONSTANT NUMBER := 1;
  L_API_Name			CONSTANT VARCHAR2(30) := 'BATCH_WSH';
  L_ID 				NUMBER;
  L_Msg_Count			NUMBER;
  L_Msg_Data			VARCHAR2(2000);


BEGIN

  L_Return_Status := OKE_API.Start_Activity ( L_Api_Name
					, P_Init_Msg_List
					, '_PKG'
					, X_Return_Status );

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  IF P_Project_ID IS NULL THEN
    FOR c1rec IN c1 LOOP

      OKE_DELIVERABLE_ACTIONS_PKG.Create_Shipment ( c1rec.action_id
				, 'F'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  ELSIF P_Project_ID > 0 AND P_Task_ID IS NULL THEN
    FOR c2rec IN c2 LOOP
      OKE_DELIVERABLE_ACTIONS_PKG.Create_Shipment ( c2rec.action_id
				, 'F'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  ELSIF P_Task_ID > 0 THEN
    FOR c3rec IN c3 LOOP
      OKE_DELIVERABLE_ACTIONS_PKG.Create_Shipment ( c3rec.action_id
				, 'F'
				, L_ID
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data );
      IF L_Return_Status <> 'S' THEN
        OKE_ACTION_VALIDATIONS_PKG.Add_Msg ( L_ID, L_Msg_Data );
      END IF;
    END LOOP;
  END IF;

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
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

  END Batch_WSH;

  FUNCTION Item_Exist_Yn ( P_Deliverable_ID 	NUMBER ) RETURN VARCHAR2 IS

    L_Dummy NUMBER;

    CURSOR c IS
    SELECT 1
    FROM oke_deliverables_b
    WHERE source_code = 'PA'
    AND source_deliverable_id = p_deliverable_id
    AND item_id > 0;

  BEGIN
    OPEN c;
    FETCH c INTO L_Dummy;
    IF c%NOTFOUND THEN
      CLOSE c;
      RETURN 'N';
    END IF;

    CLOSE c;
    RETURN 'Y';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END Item_Exist_Yn;

  PROCEDURE Default_Action ( P_Source_Code VARCHAR2
		, P_Action_Type VARCHAR2
		, P_Source_Action_Name VARCHAR2
		, P_Source_Deliverable_ID NUMBER
		, P_Source_Action_ID NUMBER
		, P_Action_Date DATE ) IS

    L_ID NUMBER;
    L_Deliverable_ID NUMBER;

    CURSOR c IS
    SELECT DELIVERABLE_ID
    FROM oke_deliverables_b
    WHERE SOURCE_CODE = P_SOURCE_CODE
    AND SOURCE_DELIVERABLE_ID = P_SOURCE_DELIVERABLE_ID;

  BEGIN

    SELECT oke_k_deliverables_s.NEXTVAL INTO L_ID FROM DUAL;

    OPEN c;
    FETCH c INTO L_Deliverable_ID;
    CLOSE c;

    INSERT INTO oke_deliverable_actions (
      ACTION_ID
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , ACTION_TYPE
    , ACTION_NAME
    , DELIVERABLE_ID
    , PA_ACTION_ID
    , EXPECTED_DATE
    , destination_type_code
    ) VALUES ( L_ID
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , FND_GLOBAL.LOGIN_ID
    , P_ACTION_TYPE
    , P_SOURCE_ACTION_NAME
    , L_DELIVERABLE_ID
    , P_SOURCE_ACTION_ID
    , P_ACTION_DATE
    , Decode( P_ACTION_TYPE, 'REQ', 'EXPENSE', NULL)
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION Task_Used_In_Wsh ( P_Task_ID NUMBER ) RETURN VARCHAR2 IS

    CURSOR C IS
    SELECT G_Yes
    FROM oke_deliverable_actions
    WHERE task_id = p_task_id
    AND action_type = 'WSH'
--    AND reference1 > 0 -- bug# 4007769  commented out
;

    L_Dummy VARCHAR2(1);

  BEGIN

    IF P_Task_ID > 0 THEN
      OPEN C;
      FETCH C INTO L_Dummy;
      CLOSE C;
      RETURN Nvl(L_Dummy,G_No);
    ELSE
      RETURN null;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Task_Used_In_Wsh;

  FUNCTION Task_Used_In_Req ( P_Task_ID NUMBER ) RETURN VARCHAR2 IS

    CURSOR c IS
    SELECT G_Yes
    FROM oke_deliverable_actions
    WHERE task_id = p_task_id
    AND action_type = 'REQ'
--    AND reference1 > 0 -- bug# 4007769  commented out
;

    L_Dummy VARCHAR2(1);

  BEGIN

    IF P_Task_ID > 0 THEN
      OPEN C;
      FETCH C INTO L_Dummy;
      CLOSE C;
      RETURN Nvl(L_Dummy,G_No);
    ELSE
      RETURN null;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

END;


/
