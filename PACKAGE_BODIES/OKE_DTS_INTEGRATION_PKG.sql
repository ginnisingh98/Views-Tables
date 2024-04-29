--------------------------------------------------------
--  DDL for Package Body OKE_DTS_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DTS_INTEGRATION_PKG" AS
/* $Header: OKEINTGB.pls 120.8.12010000.6 2009/04/21 13:02:31 serukull ship $ */

 g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_dts.integaration_pkg.';
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

END;

PROCEDURE Create_Mrp_Item(p_item_id NUMBER, p_inventory_org_id NUMBER, p_plan VARCHAR2)
 IS
  L_Level NUMBER;
  l_rowid VARCHAR2(100);
  dummy VARCHAR2(1);
  CURSOR Level_C(P_ID NUMBER) IS
    SELECT Maximum_BOM_Level
    FROM bom_parameters
    WHERE Organization_ID = P_ID;

  CURSOR v IS
   SELECT '!' INTO Dummy
     FROM mrp_schedule_items
    WHERE Inventory_Item_Id = p_Item_Id
      AND Schedule_designator = p_Plan
      AND Organization_Id = p_Inventory_Org_Id;
  BEGIN

   OPEN v;
   FETCH v INTO dummy;
   CLOSE v;

   IF dummy IS NULL THEN
     OPEN Level_C ( p_Inventory_Org_ID );
     FETCH Level_C INTO L_Level;
     CLOSE Level_C;
     IF L_Level IS NULL THEN
       L_Level := 5;
     END IF;

     MRP_SCHEDULE_ITEMS_PKG.Insert_Row(
        X_Rowid                 => l_rowid,
        X_Inventory_Item_Id     => p_Item_Id,
        X_Organization_Id       => p_inventory_org_id,
        X_Schedule_Designator   => p_plan,
        X_Last_Update_Date      => sysdate,
        X_Last_Updated_By       => fnd_global.user_id,
        X_Creation_Date         => sysdate,
        X_Created_By            => fnd_global.user_id,
        X_Last_Update_Login     => fnd_global.login_id,
        X_MPS_Explosion_Level   => L_Level
     );
   END IF;

END Create_Mrp_Item;

PROCEDURE INSERT_ROW (
  p_Item_ID NUMBER,
  p_Inv_Org_ID NUMBER,
  p_Designator VARCHAR2,
  p_Demand_Date DATE,
  p_workdate DATE,
  p_Primary_Qty NUMBER,
  p_Project_ID NUMBER,
  p_Task_ID NUMBER,
  p_Unit_Number VARCHAR2,
  p_deliverable_id NUMBER,
  x_mps_transaction_id OUT NOCOPY NUMBER
 ) IS

  l_id NUMBER;
  l_schedule_level   CONSTANT NUMBER := 2;
  l_supply_demand_type   CONSTANT NUMBER := 1;
  l_schedule_origination_type CONSTANT NUMBER := 1;

  CURSOR l_csr(p_id NUMBER) IS
  SELECT MPS_TRANSACTION_ID FROM MRP_SCHEDULE_DATES
  WHERE MPS_TRANSACTION_ID = l_id
  AND SCHEDULE_LEVEL = L_Schedule_Level
  AND SUPPLY_DEMAND_TYPE = L_Supply_Demand_Type;

  CURSOR l_id_csr IS
  SELECT mrp_schedule_dates_s.NEXTVAL FROM dual;

BEGIN

  --
  -- Get id
  --
  OPEN l_id_csr;
  FETCH l_id_csr INTO l_id;
  CLOSE l_id_csr;

  -- Insert twice to create both original and current record
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
    L_Id      ,
    lu.lookup_code    ,
    L_Supply_Demand_Type  ,
    Sysdate      ,
    Fnd_Global.User_Id  ,
    Sysdate      ,
    Fnd_Global.User_Id  ,
    Fnd_Global.Login_Id  ,
    p_Item_Id    ,
    p_Inv_Org_ID  ,
    p_Designator  ,
    p_Demand_Date  ,
    p_workdate    ,
    p_Primary_Qty    ,
    p_Primary_Qty    ,
    l_schedule_origination_type,
    p_Project_Id  ,
    p_Task_Id    ,
    p_Unit_Number     ,
    'OKE'      ,
    P_Deliverable_ID
    FROM  mfg_lookups lu
    WHERE lookup_type = 'MRP_SCHEDULE_LEVEL'
    AND   lookup_code IN ( 1 , 2)
    AND NOT EXISTS (
      SELECT NULL
      FROM   mrp_schedule_dates
      WHERE  mps_transaction_id = L_Id
      AND    schedule_level = lu.lookup_code );

  OPEN l_csr(l_id);
  FETCH l_csr INTO l_id;
  IF (l_csr%NOTFOUND) THEN

    CLOSE l_csr;
    RAISE NO_DATA_FOUND;

  END IF;

  CLOSE l_csr;

  x_mps_transaction_id := l_id;

END insert_row;

PROCEDURE update_row (
  p_Item_ID NUMBER,
  p_Inv_Org_ID NUMBER,
  p_Designator VARCHAR2,
  p_Demand_Date DATE,
  p_workdate DATE,
  p_Primary_Qty NUMBER,
  p_Project_ID NUMBER,
  p_Task_ID NUMBER,
  p_Unit_Number VARCHAR2,
  p_deliverable_id NUMBER,
  p_row_id ROWID
) IS

BEGIN

  UPDATE MRP_SCHEDULE_DATES d
  SET
  LAST_UPDATE_DATE = Sysdate,
  LAST_UPDATED_BY = Fnd_Global.User_Id,
  LAST_UPDATE_LOGIN = Fnd_Global.Login_Id,
  INVENTORY_ITEM_ID = p_Item_Id,
  ORGANIZATION_ID = p_Inv_Org_Id,
  SCHEDULE_DESIGNATOR = p_Designator,
  SCHEDULE_DATE = p_Demand_Date,
  SCHEDULE_WORKDATE = p_workdate,
  ORIGINAL_SCHEDULE_QUANTITY = p_Primary_Qty,
  SCHEDULE_QUANTITY = ( SELECT greatest(p_Primary_Qty - nvl(sum(R.relief_quantity) , 0) , 0)
                              FROM mrp_schedule_consumptions R
                              WHERE R.transaction_id = d.mps_transaction_id ),
  PROJECT_ID = p_Project_Id,
  TASK_ID = p_Task_Id,
  END_ITEM_UNIT_NUMBER = p_Unit_Number
  WHERE ROWID = p_row_id;

END update_row;
/*
PROCEDURE lock_row (P_MPS_TRANSACTION_ID IN NUMBER, P_Deliverable_Id In Number) IS


  CURSOR l_csr IS
  SELECT
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
	RATE_END_DATE,
	SCHEDULE_QUANTITY,
	ORIGINAL_SCHEDULE_QUANTITY,
	REPETITIVE_DAILY_RATE,
	SCHEDULE_ORIGINATION_TYPE,
	SOURCE_FORECAST_DESIGNATOR,
	REFERENCE_SCHEDULE_ID,
	SCHEDULE_COMMENTS,
	SOURCE_ORGANIZATION_ID,
	SOURCE_SCHEDULE_DESIGNATOR,
	SOURCE_SALES_ORDER_ID,
	SOURCE_CODE,
	SOURCE_LINE_ID,
	RESERVATION_ID,
	FORECAST_ID,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	DDF_CONTEXT,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	PROJECT_ID,
	TASK_ID,
	LINE_ID,
	END_ITEM_UNIT_NUMBER
  FROM MRP_SCHEDULE_DATES
  WHERE MPS_TRANSACTION_ID = P_MPS_TRANSACTION_ID
  AND SCHEDULE_LEVEL = 2
  AND SUPPLY_DEMAND_TYPE = 1
  FOR UPDATE OF MPS_TRANSACTION_ID NOWAIT;

  Cursor C Is
  Select Mps_Transaction_Id
	, Item_Id
	, Inventory_Org_Id
	, Ndb_Schedule_Designator
	, Expected_Shipment_Date
	, Quantity
	, Project_Id
	, Task_Id
	, Unit_Number
  From oke_k_deliverables_b
  Where Deliverable_Id = P_Deliverable_Id;

  recinfo l_csr%ROWTYPE;
  cinfo C%ROWTYPE;
  l_schedule_level 	constant number := 2;
  l_supply_demand_type 	constant number := 1;
  l_schedule_origination_type constant number := 1;

BEGIN


      Open C;
      Fetch C Into Cinfo;
      Close C;

      OPEN l_csr;
      FETCH l_csr INTO recinfo;

      IF(l_csr%NOTFOUND) THEN
	CLOSE l_csr;
	FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
	APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      CLOSE l_csr;

      IF(
	(recinfo.mps_transaction_id = cinfo.mps_transaction_id)
	and (recinfo.schedule_level = l_schedule_level)
	and (recinfo.supply_demand_type = l_supply_demand_type)
	and (recinfo.inventory_item_id = cinfo.item_id)
	and (recinfo.organization_id = cinfo.inventory_org_id)
	and (recinfo.schedule_designator = cinfo.ndb_schedule_designator)
	and (recinfo.schedule_date = cinfo.expected_shipment_date)

	and (recinfo.schedule_origination_type = l_schedule_origination_type)
	and ((recinfo.project_id = cinfo.project_id)
	   or ((recinfo.project_id is null)
		and (cinfo.project_id is null)))
	and ((recinfo.task_id = cinfo.task_id)
	   or ((recinfo.task_id is null)
		and (cinfo.task_id is null)))
	and ((recinfo.end_item_unit_number = cinfo.unit_number)
	   or ((recinfo.end_item_unit_number is null)
		and (cinfo.unit_number is null)))) THEN

    NULL;

  ELSE
	FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
	APP_EXCEPTION.RAISE_EXCEPTION;

     END IF;

     RETURN;

END lock_row;
*/
PROCEDURE create_mds_entry(
  P_DELIVERABLE_ID   IN      NUMBER,
  X_OUT_ID           OUT NOCOPY  NUMBER,
  X_RETURN_STATUS    OUT NOCOPY  VARCHAR2)
 IS
  l_return_status VARCHAR2(1) := oke_api.g_ret_sts_success;
  l_api_version    CONSTANT NUMBER :=1;
  l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_MDS_ENTRY';
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);

  l_current_id NUMBER;
  l_func VARCHAR2(1);
  l_workdate Date;
  L_Primary_Qty NUMBER;
  L_To_Uom  VARCHAR2(3);
  l_cr_item BOOLEAN := TRUE;

  CURSOR mds_c IS
    Select rowid
    , item_id
  	, inventory_org_id
  	, ndb_schedule_designator
  	, nvl(expected_shipment_date , need_by_date) demand_date
  	, quantity
  	, project_id
  	, task_id
  	, unit_number
  	, uom_code
  	, mps_transaction_id
    From oke_k_deliverables_b
    Where deliverable_id = p_deliverable_id
    FOR UPDATE NOWAIT;
  L_DRow_ID ROWID;
  L_Item_ID NUMBER;
  L_Inv_Org_ID NUMBER;
  L_Designator VARCHAR2(80);
  L_Demand_Date DATE;
  L_Quantity NUMBER;
  L_Project_ID NUMBER;
  L_Task_ID NUMBER;
  L_Unit_Number VARCHAR2(80);
  L_UOM_Code VARCHAR2(80);
  l_mps_transaction_id NUMBER;

  CURSOR Uom_C ( P_Item_ID NUMBER , P_Org_ID NUMBER ) IS
   SELECT Primary_Uom_Code
     FROM mtl_system_items
    WHERE inventory_item_id = P_Item_ID
      AND organization_id = P_Org_ID;

  CURSOR sdates_c IS
    SELECT  rowid,
          	INVENTORY_ITEM_ID,
          	ORGANIZATION_ID,
          	SCHEDULE_DESIGNATOR
    FROM mrp_schedule_dates
    WHERE MPS_TRANSACTION_ID = l_MPS_TRANSACTION_ID
      AND SCHEDULE_LEVEL = 2
      AND SUPPLY_DEMAND_TYPE = 1
    FOR UPDATE NOWAIT;
  L_SRow_ID ROWID;
  L_Item_ID_Old NUMBER;
  L_Inv_Org_ID_Old NUMBER;
  L_Designator_Old VARCHAR2(80);

BEGIN
  l_return_status := OKE_API.START_ACTIVITY(
      l_api_name,
      OKE_API.G_FALSE,
      '_PVT',
      x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
    RAISE OKE_API.G_EXCEPTION_ERROR;
  END IF;

  Open Mds_C;
  Fetch Mds_C Into L_DRow_ID, L_Item_ID, L_Inv_Org_ID, L_Designator,
                   L_Demand_Date, L_Quantity, L_Project_ID, L_Task_ID,
                   L_Unit_Number, L_Uom_Code, l_mps_transaction_id;
  Close Mds_C;

  IF l_mps_transaction_id IS NOT NULL THEN
    OPEN sdates_c;
    FETCH sdates_c INTO L_SRow_ID, L_Item_ID_Old, L_Inv_Org_ID_Old, L_Designator_Old;
    CLOSE sdates_c;
  END IF;

  --
  -- Get workdate
  --
  l_workdate := mrp_calendar.prev_work_day(l_Inv_Org_Id , 1 , l_Demand_Date);

  --
  -- Get Primary Uom
  --
  OPEN Uom_C(l_Item_ID , l_Inv_Org_Id);
  FETCH Uom_C INTO L_To_Uom;
  CLOSE Uom_C;

  L_Primary_Qty := Uom_Conversion( l_Item_ID , l_Uom_Code , L_To_Uom , l_Quantity);

  IF L_SRow_ID IS NOT NULL THEN -- update if MDS record exists
    update_row(
      p_Item_ID => l_Item_ID,
      p_Inv_Org_ID => l_Inv_Org_ID,
      p_Designator => l_Designator,
      p_Demand_Date => l_Demand_Date,
      p_workdate => l_workdate,
      p_Primary_Qty => l_Primary_Qty ,
      p_Project_ID => l_Project_ID,
      p_Task_ID => l_Task_ID,
      p_Unit_Number => l_Unit_Number,
      P_Deliverable_Id  => p_deliverable_id,
      P_ROW_ID  => L_SRow_ID
    );

    -- delete empty mrp_schedule_items, if item, org, or plan changed
    IF L_Item_ID_Old = L_Item_ID
      AND L_Inv_Org_ID_Old = L_Inv_Org_ID
      AND L_Designator_Old = L_Designator
    THEN
      l_cr_item := FALSE;
-- Do not remove extra records from mrp_schedule_items
--     ELSE
--      DELETE mrp_schedule_items
--      WHERE Inventory_Item_Id = L_Item_ID_Old
--        AND Schedule_designator = L_Designator_Old
--        AND Organization_Id = L_Inv_Org_ID_Old
--        AND NOT EXISTS(
--          SELECT NULL FROM mrp_schedule_dates
--          WHERE Inventory_Item_Id = L_Item_ID_Old
--            AND Schedule_designator = L_Designator_Old
--            AND Organization_Id = L_Inv_Org_ID_Old
--        );
    END IF;

    UPDATE oke_k_deliverables_b
     SET po_ref_2 = 1
     WHERE ROWID = L_DRow_ID;

  ELSE -- if record wasn't updated - insert it

    INSERT_ROW(
      p_Item_ID => l_Item_ID,
      p_Inv_Org_ID => l_Inv_Org_ID,
      p_Designator => l_Designator,
      p_Demand_Date => l_Demand_Date,
      p_workdate => l_workdate,
      p_Primary_Qty => l_Primary_Qty ,
      p_Project_ID => l_Project_ID,
      p_Task_ID => l_Task_ID,
      p_Unit_Number => l_Unit_Number,
      P_Deliverable_Id  => P_Deliverable_Id,
      X_Mps_Transaction_Id  => L_mps_transaction_id
    );
    IF l_mps_transaction_id IS NOT NULL THEN
      x_out_id := l_mps_transaction_id;
      -- update mps_transaction_id in deliverable table
      UPDATE oke_k_deliverables_b
       SET mps_transaction_id = l_mps_transaction_id
       WHERE ROWID = L_DRow_ID;
    END IF;
  END IF;

  -- Create Mrp Schedule Item if not Exists
  IF l_cr_item THEN
    Create_Mrp_Item( l_Item_Id, l_Inv_Org_Id, l_Designator );
  END IF;

  x_return_status := l_return_status;
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
  '_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
  l_api_name,
  G_PKG_NAME,
  'OKE_API.G_RET_STS_UNEXP_ERROR',
  x_msg_count,
  x_msg_data,
  '_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
  l_api_name,
  G_PKG_NAME,
  'OTHERS',
  x_msg_count,
  x_msg_data,
  '_PVT');


END create_mds_entry;

PROCEDURE create_ship_line(
P_DELIVERABLE_ID		IN	NUMBER,
X_DELVIERY_DETAIL_ID		OUT NOCOPY	NUMBER,
X_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS

  l_ship_rec wsh_delivery_details_pkg.delivery_details_rec_type;
  l_return_status       varchar2(1);
  l_api_version		CONSTANT NUMBER :=1;
  l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_SHIP_LINE';

  x_msg_count number;
  x_msg_data varchar2(2000);
  l_id number;
  l_customer_id Number;
  l_fob_term VARCHAR2(30);
  l_ship_method VARCHAR2(30);
  l_ship_priority VARCHAR2(30);
  l_freight_term VARCHAR2(30);
  l_org_id NUMBER;

  -- dumb addition for bug 3405926
  l_header_id number;
  l_cust_po_number varchar2(150);
  l_contract_number varchar2(150);
  l_authoring_org_id number;
  l_deliverable_num varchar2(150);
  l_project_id number;
  l_task_id number;
  l_quantity number;
  l_item_id number;
  l_ship_to_location_id number;
  l_uom_code varchar2(80);
  l_expected_date date;
  l_promised_date date;
  l_ship_from_location_id number;
  l_inv_org_id number;
  l_description varchar2(250);
  l_country_of_origin_code varchar2(80);
  l_inspection_req_flag varchar2(1);
  l_unit_number varchar2(80);
  l_currency_code varchar2(80);
  l_weight number;
  l_weight_uom_code varchar2(80);
  l_volume number;
  l_volume_uom_code varchar2(80);

 l_customer_item_id  number := null;

  cursor term
  ( C_deliverable_id  number
  , C_term_code       varchar2
  ) is
  select kt1.term_value_pk1 term_value
  from   oke_k_deliverables_b d
  ,      oke_k_terms kt1
  ,    ( select cle_id , cle_id_ascendant , level_sequence from okc_ancestrys
         union all
         select id , id , 99999 from okc_k_lines_b ) a
  where  d.deliverable_id = C_deliverable_id
  and    kt1.term_code = C_term_code
  and    kt1.k_header_id = d.k_header_id
  and    a.cle_id = d.k_line_id
  and  ( ( kt1.k_line_id is null and a.cle_id = a.cle_id_ascendant )
       or kt1.k_line_id = a.cle_id_ascendant )
  order by decode(kt1.k_line_id , null , 0 , a.level_sequence) desc;

  CURSOR csr_dts_ship(p_id number) IS
  SELECT shipping_request_id, in_process_flag, initiate_shipment_date
    FROM oke_k_deliverables_b
   WHERE deliverable_id = p_id
  FOR UPDATE OF shipping_request_id, in_process_flag, initiate_shipment_date NOWAIT;

  CURSOR l_line_csr(p_id number) IS
  SELECT B.K_HEADER_ID
  ,      H.CUST_PO_NUMBER
  ,      H.CONTRACT_NUMBER
  ,      H.AUTHORING_ORG_ID
  ,      B.DELIVERABLE_NUM
  ,      B.PROJECT_ID
  ,      B.TASK_ID
  ,      B.QUANTITY
  ,      B.ITEM_ID
  ,      B.SHIP_TO_LOCATION_ID
  ,      B.UOM_CODE
  ,      B.EXPECTED_SHIPMENT_DATE
  ,      B.PROMISED_SHIPMENT_DATE
  ,      B.SHIP_FROM_LOCATION_ID
  ,      B.INVENTORY_ORG_ID
  ,      T.DESCRIPTION
  ,      B.COUNTRY_OF_ORIGIN_CODE
  ,      DECODE(B.INSPECTION_REQ_FLAG , 'Y' , 'R' , 'N') INSPECTION_REQ_FLAG
  ,      B.UNIT_NUMBER
  ,      B.CURRENCY_CODE
  ,      B.WEIGHT
  ,      B.WEIGHT_UOM_CODE
  ,      B.VOLUME
  ,      B.VOLUME_UOM_CODE
  FROM   OKC_K_HEADERS_B H
  ,      OKE_K_DELIVERABLES_B B
  ,      OKE_K_DELIVERABLES_TL T
  WHERE  B.DELIVERABLE_ID = p_id
  AND    B.DELIVERABLE_ID = T.DELIVERABLE_ID
  AND    T.LANGUAGE = USERENV('LANG')
  AND    H.ID = B.K_HEADER_ID;

  CURSOR Item_C ( P_ID NUMBER ) IS
  SELECT Decode(MTL_Transactions_Enabled_Flag, 'Y', 'Y', 'N')
  FROM mtl_system_items
  WHERE Inventory_Item_ID = P_ID;

  CURSOR OU_C ( P_Organization_ID NUMBER ) IS
  SELECT OPERATING_UNIT
  FROM ORG_ORGANIZATION_DEFINITIONS
  WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;

  -- linfo l_line_csr%rowtype;
  L_Flag VARCHAR2(1);
  l_cust_item_flag varchar2(1) := 'Y';

   CURSOR csr_cust_item (p_deliverable_id NUMBER )
	IS
   SELECT  l.customer_item_id, d.item_id, d.INVENTORY_ORG_ID
   FROM    oke_k_lines l,
                 oke_k_deliverables_b d
    WHERE   d.deliverable_id    =   p_deliverable_id
         AND     d.k_line_id         =   l.k_line_id
         AND     l.inventory_item_id =   d.item_id;

    CURSOR csr_validate_cust_item
      IS
     SELECT 'X'
     FROM    mtl_parameters m,
                   MTL_CUSTOMER_ITEM_XREFS x,
                   mtl_customer_items m
       where    m.ORGANIZATION_ID  =   l_INV_ORG_ID
      AND     x. MASTER_ORGANIZATION_ID= m.MASTER_ORGANIZATION_ID
      AND     X.INVENTORY_ITEM_ID =   l_item_id
      AND     x.CUSTOMER_ITEM_ID  =  l_customer_item_id
      AND     m.customer_item_id = x.CUSTOMER_ITEM_ID
      AND     m.customer_id =  l_customer_id;

BEGIN
  l_return_status := OKE_API.START_ACTIVITY(
			l_api_name,
			OKE_API.G_FALSE,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  OPEN l_line_csr(P_DELIVERABLE_ID);
  FETCH l_line_csr INTO l_header_id, l_cust_po_number, l_contract_number, l_authoring_org_id, l_deliverable_num, l_project_id, l_task_id, l_quantity
	, l_item_id, l_ship_to_location_id, l_uom_code, l_expected_date, l_promised_date, l_ship_from_location_id, l_inv_org_id, l_description
	, l_country_of_origin_code, l_inspection_req_flag, l_unit_number, l_currency_code, l_weight, l_weight_uom_code, l_volume, l_volume_uom_code;
  CLOSE l_line_csr;

  -- get the right ship_to_location_id
  select location_id into l_ship_rec.ship_to_location_id
  from oke_cust_site_uses_v
  where id1 = l_ship_to_location_id;

  -- get the customer_id from contract header party
  -- currently use ship_to_location derive party_id from oke_cust_site_uses_v

  select cust_account_id into l_customer_id
  from oke_cust_site_uses_v
  where id1 = l_ship_to_location_id;

  -- Populate shipping terms for report purpose

  FOR Item_Info IN Term(P_Deliverable_ID, 'OB_FOB') LOOP
    L_Fob_Term := Item_Info.Term_Value;
    EXIT WHEN L_Fob_Term IS NOT NULL;
  END LOOP;

  FOR Item_Info IN Term(P_Deliverable_ID, 'OB_SHIPMENT_PRIORITY') LOOP
    L_Ship_Priority := Item_Info.Term_Value;
    EXIT WHEN L_Ship_Priority IS NOT NULL;
  END LOOP;

  FOR Item_Info IN Term(P_Deliverable_ID, 'OB_SHIPPING_METHOD') LOOP
    L_Ship_Method := Item_Info.Term_Value;
    EXIT WHEN L_Ship_Method IS NOT NULL;
  END LOOP;

  FOR Item_Info IN Term(P_Deliverable_ID, 'OB_FREIGHT_TERMS') LOOP
    L_Freight_Term := Item_Info.Term_Value;
    EXIT WHEN L_Freight_Term IS NOT NULL;
  END LOOP;

  -- Check item specific info
  OPEN Item_C ( L_Item_ID );
  FETCH Item_C INTO L_Flag;
  CLOSE Item_C;

  -- Retrieve Operating Unit info
  OPEN OU_C(l_INV_ORG_ID);
  FETCH OU_C INTO L_Org_ID;
  CLOSE OU_C;

  -- Retrieve Customer item info
  OPEN  csr_cust_item(P_Deliverable_ID);
  FETCH   csr_cust_item INTO l_customer_item_id,l_item_id, l_INV_ORG_ID;
  CLOSE csr_cust_item;

  IF ( l_customer_item_id IS NOT NULL ) THEN
  OPEN csr_validate_cust_item;
  FETCH  csr_validate_cust_item INTO l_cust_item_flag;
  CLOSE csr_validate_cust_item;
      IF (l_cust_item_flag  <> 'X' ) THEN
        l_customer_item_id :=NULL;
      END IF;
  END IF;


  -- set record
  l_ship_rec.delivery_detail_id  	:= null;
  l_ship_rec.source_code		:= G_WSH_SOURCE_CODE;
  l_ship_rec.source_header_id		:= L_HEADER_ID;
  l_ship_rec.source_line_id		:= P_DELIVERABLE_ID;
  l_ship_rec.customer_id		:= l_customer_id;
  l_ship_rec.sold_to_contact_id		:= null;
  l_ship_rec.inventory_item_id		:= l_ITEM_ID;
  l_ship_rec.item_description		:= L_DESCRIPTION;
  l_ship_rec.hazard_class_id		:= null;
  l_ship_rec.country_of_origin		:= l_COUNTRY_OF_ORIGIN_CODE;
  l_ship_rec.classification		:= null;
  l_ship_rec.ship_from_location_id	:= l_SHIP_FROM_LOCATION_ID;
  l_ship_rec.ship_to_site_use_id	:= l_ship_to_location_id;
  l_ship_rec.ship_to_contact_id		:= null;
  l_ship_rec.deliver_to_location_id	:= null;
  l_ship_rec.deliver_to_contact_id	:= null;
  l_ship_rec.intmed_ship_to_location_id	:= null;
  l_ship_rec.intmed_ship_to_contact_id	:= null;
  l_ship_rec.hold_code			:= null;
  l_ship_rec.ship_tolerance_above	:= null;
  l_ship_rec.ship_tolerance_below	:= null;
 -- l_ship_rec.requested_quantity		:= l_QUANTITY;
  l_ship_rec.shipped_quantity		:= null;
  l_ship_rec.delivered_quantity		:= null;
  -- l_ship_rec.requested_quantity_uom	:= l_UOM_CODE;
  l_ship_rec.subinventory		:= null;
  l_ship_rec.revision			:= null;
  l_ship_rec.lot_number			:= null;
  l_ship_rec.customer_requested_lot_flag:= null;
  l_ship_rec.serial_number		:= null;
  l_ship_rec.locator_id			:= null;
  l_ship_rec.date_requested		:= l_promised_date;
  l_ship_rec.date_scheduled		:= l_expected_date;
  l_ship_rec.master_container_item_id	:= null;
  l_ship_rec.detail_container_item_id	:= null;
  l_ship_rec.load_seq_number		:= null;
  l_ship_rec.ship_method_code		:= l_ship_method;
  l_ship_rec.carrier_id			:= null;
  l_ship_rec.freight_terms_code		:= l_freight_term;
  l_ship_rec.shipment_priority_code	:= l_ship_priority;
  l_ship_rec.fob_code			:= l_fob_term;
  l_ship_rec.customer_item_id		:= l_customer_item_id;
  l_ship_rec.dep_plan_required_flag	:= null;
  l_ship_rec.customer_prod_seq		:= null;
  l_ship_rec.customer_dock_code		:= null;
  l_ship_rec.net_weight			:= l_weight;
  l_ship_rec.weight_uom_code		:= l_weight_uom_code;
  l_ship_rec.volume			:= l_volume;
  l_ship_rec.volume_uom_code		:= l_volume_uom_code;
  l_ship_rec.tp_attribute_category	:= null;
  l_ship_rec.tp_attribute1		:= null;
  l_ship_rec.tp_attribute2		:= null;
  l_ship_rec.tp_attribute3		:= null;
  l_ship_rec.tp_attribute4		:= null;
  l_ship_rec.tp_attribute5		:= null;
  l_ship_rec.tp_attribute6		:= null;
  l_ship_rec.tp_attribute7		:= null;
  l_ship_rec.tp_attribute8		:= null;
  l_ship_rec.tp_attribute9		:= null;
  l_ship_rec.tp_attribute10		:= null;
  l_ship_rec.tp_attribute11		:= null;
  l_ship_rec.tp_attribute12		:= null;
  l_ship_rec.tp_attribute13		:= null;
  l_ship_rec.tp_attribute14		:= null;
  l_ship_rec.tp_attribute15		:= null;
  l_ship_rec.attribute_category		:= null;
  l_ship_rec.attribute1			:= null;
  l_ship_rec.attribute2			:= null;
  l_ship_rec.attribute3			:= null;
  l_ship_rec.attribute4			:= null;
  l_ship_rec.attribute5			:= null;
  l_ship_rec.attribute6			:= null;
  l_ship_rec.attribute7			:= null;
  l_ship_rec.attribute8			:= null;
  l_ship_rec.attribute9			:= null;
  l_ship_rec.attribute10		:= null;
  l_ship_rec.attribute11		:= null;
  l_ship_rec.attribute12		:= null;
  l_ship_rec.attribute13		:= null;
  l_ship_rec.attribute14		:= null;
  l_ship_rec.attribute15		:= null;
  l_ship_rec.created_by			:= fnd_global.user_id;
  l_ship_rec.creation_date		:= sysdate;
  l_ship_rec.last_update_date		:= sysdate;
  l_ship_rec.last_update_login		:= fnd_global.login_id;
  l_ship_rec.last_updated_by		:= fnd_global.user_id;
  l_ship_rec.program_application_id	:= null;
  l_ship_rec.program_id			:= null;
  l_ship_rec.program_update_date	:= null;
  l_ship_rec.request_id			:= null;
  l_ship_rec.mvt_stat_status		:= null;
  l_ship_rec.released_flag		:= null;
  l_ship_rec.organization_id		:= l_INV_ORG_ID;
  l_ship_rec.transaction_temp_id	:= null;
  l_ship_rec.ship_set_id		:= null;
  l_ship_rec.arrival_set_id		:= null;
  l_ship_rec.ship_model_complete_flag 	:= null;
  l_ship_rec.top_model_line_id		:= null;
  l_ship_rec.source_header_number	:= l_CONTRACT_NUMBER;
  l_ship_rec.source_header_type_id	:= null;
  l_ship_rec.source_header_type_name	:= null;
  l_ship_rec.cust_po_number		:= l_CUST_PO_NUMBER;
  l_ship_rec.ato_line_id		:= null;
  l_ship_rec.src_requested_quantity	:= l_QUANTITY;
  l_ship_rec.src_requested_quantity_uom	:= l_UOM_CODE;
  l_ship_rec.move_order_line_id		:= null;
  l_ship_rec.cancelled_quantity		:= null;
  l_ship_rec.quality_control_quantity	:= null;
  l_ship_rec.cycle_count_quantity	:= null;
  l_ship_rec.tracking_number		:= null;
  l_ship_rec.movement_id		:= null;
  l_ship_rec.shipping_instructions	:= null;
  l_ship_rec.packing_instructions	:= null;
  l_ship_rec.project_id			:= l_PROJECT_ID;
  l_ship_rec.task_id			:= l_TASK_ID;
  l_ship_rec.org_id			:= l_org_id;
  l_ship_rec.oe_interfaced_flag		:= null;
  l_ship_rec.split_from_detail_id	:= null;
  l_ship_rec.inv_interfaced_flag	:= null;
  l_ship_rec.source_line_number		:= l_DELIVERABLE_NUM;
  l_ship_rec.inspection_flag		:= l_INSPECTION_REQ_FLAG;
  l_ship_rec.container_flag		:= null;
  l_ship_rec.container_type_code	:= null;
  l_ship_rec.container_name		:= null;
  l_ship_rec.fill_percent		:= null;
  l_ship_rec.gross_weight		:= null;
  l_ship_rec.master_serial_number	:= null;
  l_ship_rec.maximum_load_weight	:= null;
  l_ship_rec.maximum_volume		:= null;
  l_ship_rec.minimum_fill_percent	:= null;
  l_ship_rec.seal_code			:= null;
  l_ship_rec.unit_number		:= l_unit_number;
  l_ship_rec.currency_code		:= l_currency_code;
  l_ship_rec.freight_class_cat_id	:= null;
  l_ship_rec.commodity_code_cat_id	:= null;
  l_ship_rec.preferred_grade		:= null;
  l_ship_rec.src_requested_quantity2 	:= null;
  l_ship_rec.src_requested_quantity_uom2  := null;
  l_ship_rec.requested_quantity2	:= null;
  l_ship_rec.shipped_quantity2		:= null;
  l_ship_rec.delivered_quantity2	:= null;
  l_ship_rec.cancelled_quantity2	:= null;
  l_ship_rec.quality_control_quantity2	:= null;
  l_ship_rec.cycle_count_quantity2	:= null;
  l_ship_rec.requested_quantity_uom2	:= null;
--  l_ship_rec.sublot_number		:= null;
  l_ship_rec.lpn_id			:= null;

  -- bug 2424468, populate pickable_flag
  l_ship_rec.pickable_flag 		:= l_flag;

  -- bug 3597451
  -- Try to lock record and update data

     FOR rec_dts_ship IN csr_dts_ship(p_deliverable_id) LOOP
/*Bug 6011322 start */
        IF rec_dts_ship.shipping_request_id IS NOT NULL THEN
            FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_SHIP_EXISTS');
            FND_MESSAGE.set_token('SHIPPING_DETAIL',rec_dts_ship.shipping_request_id);
            FND_MSG_PUB.Add;
            RAISE OKE_API.G_EXCEPTION_ERROR;
          END IF;
/* Bug 6011322 end */

        -- call api
        WSH_interface_pub.create_shipment_lines(l_ship_rec, l_id, l_return_status);

        if l_return_status = oke_api.g_ret_sts_success then
          -- update deliverable table
          update oke_k_deliverables_b
          set shipping_request_id = l_id,
	      in_process_flag = 'Y',
	      initiate_shipment_date = sysdate
          where CURRENT OF csr_dts_ship;

          x_return_status := l_return_status;

        else

          IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

          ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

            RAISE OKE_API.G_EXCEPTION_ERROR;

          END IF;

        end if;

     END LOOP;
     OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
     COMMIT;



  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END;

PROCEDURE create_req_line
( p_requestor       in varchar2
, p_deliverable_id  in number
, p_charge_account  in number
, x_batch_id        out nocopy number
, x_return_status   out nocopy varchar2
) IS

  l_return_status   VARCHAR2(1);
  l_api_version     CONSTANT NUMBER :=1;
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_REQ_LINE';
  l_mps_id          NUMBER;

  x_msg_count number;
  x_msg_data varchar2(2000);
  l_id number;
  l_requestor varchar2(150);
  l_found boolean;
  l_employee_id number;
  l_project_id NUMBER;
  l_task_id NUMBER;
  l_inv_org_id NUMBER;
  l_dest_type VARCHAR2(30);
  l_exp_type VARCHAR2(30);
  l_exp_org_id NUMBER;
  l_exp_item_date DATE;
  l_need_by_date DATE;
  l_error_code VARCHAR2(80);
  l_context VARCHAR2(1);
  l_mds_id Number;
  l_sched_date DATE;
  L_Item_Id NUMBER;
  L_Plan Varchar2(80);
  L_Currency_Code VARCHAR2(80);
  L_Exchange_Rate NUMBER;
  L_Unit_Price NUMBER;
  L_Currency_Price NUMBER;
  l_ship_from_org_id NUMBER;
  l_vendor_id NUMBER;
  l_vendor_site_id NUMBER;
  l_ship_from_location_id NUMBER;
  L_Buy_Or_Sell VARCHAR2(1);
  L_Func_Currency_Code VARCHAR2(30);
  L_Req_Line_Type_ID NUMBER;
  L_Category_ID NUMBER;
  l_quantity NUMBER;
  l_description VARCHAR2(240);
  l_item_description VARCHAR2(240);
  l_uom_code VARCHAR2(30);



  cursor c is
  select employee_id
  from fnd_user
  where user_name = l_requestor;

  cursor c1 is
  select project_id
  ,      task_id
  ,      destination_type_code
  ,      expenditure_type
  ,      expenditure_organization_id
  ,      expenditure_item_date
  ,      inventory_org_id
  ,      trunc(need_by_date)
  ,      mps_transaction_id
  ,      ndb_schedule_designator
  ,      expected_shipment_date
  ,      item_id
  ,      unit_price
  ,      exchange_rate
  ,      ship_from_org_id
  ,      currency_code
  ,      ship_from_location_id
  , 	 requisition_line_type_id
  , 	 po_category_id
  , 	 quantity
  ,      description
  ,      uom_code
  from   oke_k_deliverables_vl
  where  deliverable_id = p_deliverable_id;

  CURSOR csr_dts_req(p_id number) IS
  SELECT po_ref_1, in_process_flag
    FROM oke_k_deliverables_b
   WHERE deliverable_id = p_id
  FOR UPDATE OF po_ref_1, in_process_flag NOWAIT;
/* Bug Number: 6011322 start */
  cursor req_c(p_id number, p_batch_id number) is
      select 'S'
       from po_requisitions_interface_all
       where oke_contract_deliverable_id = p_id
       and nvl(process_flag, 'S') = 'ERROR'
       and batch_id = p_batch_id;
/* Bug Number: 6011322 end */

  --
  -- Cursor to validate PA information for Inventory
  --
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
    where  organization_id = l_inv_org_id
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
    where  organization_id = l_inv_org_id
    and not (   project_control_level = 2
            and l_task_id is null )
    );

  --
  -- Cursor to validate PA information for Expense
  --
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
    and    l_exp_item_date
           between nvl(t.start_date , nvl(p.start_date , l_exp_item_date - 1))
               and nvl(t.completion_date , nvl(p.completion_date , l_exp_item_date + 1)) )
  union all
  select 'OKE_DTS_EXP_TYPE_INVALID'
  from   dual
  where not exists (
    select 'Expenditure Type exists and is valid'
    from   pa_expenditure_types_expend_v
    where  expenditure_type = l_exp_type
    and    system_linkage_function = 'VI' )
  union all
  select 'OKE_DTS_EXP_ORG_INVALID'
  from   dual
  where not exists (
    select 'Expenditure Org exists and is valid'
    from   pa_organizations_expend_v
    where  organization_id = l_exp_org_id );

    CURSOR Curr_C ( P_ID NUMBER ) IS
    SELECT gl.Currency_Code
    FROM gl_sets_of_books gl, org_organization_definitions org
    WHERE org.organization_id = P_ID
    AND gl.Set_Of_Books_ID = org.Set_Of_Books_ID;

    CURSOR Header_C IS
    SELECT Buy_Or_Sell
    FROM okc_k_headers_b
    WHERE ID = (SELECT K_Header_ID FROM oke_k_deliverables_b WHERE Deliverable_ID = P_Deliverable_ID);

BEGIN
  l_return_status := OKE_API.START_ACTIVITY(
			l_api_name,
			OKE_API.G_FALSE,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;


IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start centrol logging debug session for okeintgb.pls');
EnD IF;

  -- populate preparer_id, requestor_id based on wf requestor
  l_requestor := p_requestor;

  OPEN c;
  fetch c into l_employee_id;
  l_found := c%found;
  close c;

  if l_found then
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'preparer populated');
END IF;
    --
    -- verify if the project and task supplied for projects
    --
    open c1;

    fetch c1 into l_project_id , l_task_id , l_dest_type
                , l_exp_type , l_exp_org_id , l_exp_item_date
                , l_inv_org_id , l_need_by_date
                , l_mds_id , l_plan , l_sched_date , l_item_id
		, l_unit_price, l_exchange_rate, l_ship_from_org_id
	        , l_currency_code, l_ship_from_location_id, l_req_line_type_id
		, l_category_id, l_quantity, l_description, l_uom_code;

    close c1;
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'line type is : ' || l_req_line_type_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'category is :' || l_category_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'description is : ' || l_description);

      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'before validate project');
END IF;

    if ( l_project_id is not null ) then

      l_context := 'Y';

      --
      -- Validate PA information
      --
      if ( l_dest_type = 'INVENTORY' ) then

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
          RAISE OKE_API.G_EXCEPTION_ERROR;
        end if;

        l_exp_type      := NULL;
        l_exp_org_id    := NULL;
        l_exp_item_date := NULL;

      else /* destination type is EXPENSE */

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'called validate expense type');
END IF;
        l_error_code := NULL;
        open pe;
        loop
          fetch pe into l_error_code;
          exit when pe%notfound;
          FND_MESSAGE.Set_Name('OKE' , l_error_code);
          FND_MSG_PUB.Add;
        end loop;
        close pe;
        if ( l_error_code is not null ) then
          RAISE OKE_API.G_EXCEPTION_ERROR;
        end if;

      end if;

    else /* project_id is null */

        l_context := 'N';

    end if;


  -- Get converted price based on the functional currency and contract currency

  OPEN Curr_C(L_Inv_Org_ID);
  FETCH Curr_C INTO L_Func_Currency_Code;
  CLOSE Curr_C;

  IF L_Func_Currency_Code <> L_Currency_Code THEN

    if l_unit_price > 0 and l_exchange_rate > 0 then

      l_currency_price := L_Unit_Price;
      l_unit_price := l_unit_price * l_exchange_rate;

    end if;

  END IF;

  -- Get vendor info if buy contract

  OPEN Header_C;
  FETCH Header_C INTO L_Buy_Or_Sell;
  CLOSE Header_C;

  IF L_Buy_Or_Sell = 'B' THEN

    L_Vendor_ID := L_Ship_From_Org_ID;
    L_Vendor_Site_ID := L_Ship_From_Location_ID;

  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'call before amount based');
END IF;
  -- Amount based requisition logics

  if l_dest_type = 'EXPENSE' then

    if l_item_id is null and l_req_line_type_id > 0 then
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'called amount based');
      END IF;

      l_quantity := l_unit_price * l_quantity;
      l_unit_price := 1;
      l_item_description := l_description;
      l_uom_code := null;

    end if;

 -- bug 7651409
    IF l_item_id is null and  l_req_line_type_id IS NULL THEN
     l_item_description := l_description;
    END IF;

  end if;

  -- bug 3597451
  -- Try to lock record and update data

     FOR rec_dts_req IN csr_dts_req(p_deliverable_id) LOOP
/*Bug Bumber: 6011322 */
           if rec_dts_req.po_ref_1 > 0 then

         l_return_status := OKE_API.G_RET_STS_ERROR;
               open req_c(p_deliverable_id, rec_dts_req.po_ref_1);
               fetch req_c into l_return_status;
               close req_c;
               IF l_return_status = OKE_API.G_RET_STS_ERROR THEN
           FND_MESSAGE.Set_Name('OKE', 'OKE_DTS_REQ_EXISTS');
           FND_MSG_PUB.Add;
           RAISE OKE_API.G_EXCEPTION_ERROR;
               END IF;

       end if;

     -- unique group id to be associate with all rows in the table
     select oke_interface_s.nextval
     into l_id
     from dual;
/* Bug Number: 6011322 end */

  insert into po_requisitions_interface_all(
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
    d.item_id,
    l_quantity,
    l_unit_price,
    l_need_by_date,
    'OKE',  -- hard code for OKE
    d.ship_to_location_id,
    l_employee_id,
    l_employee_id,
    'VENDOR',
    decode(d.destination_type_code, 'INVENTORY', 'APPROVED','INCOMPLETE'),
    l_uom_code,
    l_id,
    decode(d.destination_type_code, 'INVENTORY',mp.material_account, p_charge_account),
    null, -- to be added later if required
    d.inventory_org_id,
    'N', -- hard coded
    ood.operating_unit,
    l_project_id,
    l_task_id,
    l_context,
    d.k_header_id,
    ver.major_version,
    d.k_line_id,
    d.deliverable_id,
    d.unit_number,
    l_exp_org_id,
    l_exp_type,
    l_exp_item_date,
    l_dest_type,
    nvl(d.currency_code,l_func_currency_code),
    d.exchange_rate,
    d.rate_date,
    d.rate_type,
    l_currency_price,
    l_vendor_id,
    l_vendor_site_id,
    l_req_line_type_id,
    l_category_id,
    l_item_description
  from oke_k_deliverables_b d
  ,    okc_k_headers_b h
  ,    mtl_parameters mp
  ,    org_organization_definitions ood
  ,    oke_k_vers_numbers_v ver
  where d.deliverable_id = p_deliverable_id
  and h.id = d.k_header_id
  and ver.chr_id = d.k_header_id
  and ood.organization_id = d.inventory_org_id
  and mp.organization_id = d.inventory_org_id;



  if l_return_status = oke_api.g_ret_sts_success then
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Req created successfully, update deliverable table');
END IF;

    -- update deliverable table
    update oke_k_deliverables_b
    set po_ref_1 = l_id
    ,   in_process_flag = 'Y'
    where CURRENT OF csr_dts_req;

    --
    -- Work around for Planning not recognize OKE records when link PO to the MDS entries
    -- created from DTS
    --

    IF (   l_plan IS NOT NULL
       AND nvl(l_sched_date , l_need_by_date) IS NOT NULL
       AND l_item_id IS NOT NULL
       AND l_inv_org_id IS NOT NULL ) THEN
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Update MDS');
END IF;

      create_mds_entry(
	P_DELIVERABLE_ID		=> P_DELIVERABLE_ID,
	X_OUT_ID			=> L_MPS_ID,
	X_RETURN_STATUS			=> L_RETURN_STATUS);

        IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

        ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

          RAISE OKE_API.G_EXCEPTION_ERROR;

        END IF;

    END IF;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Create Req process completed normally');
END IF;

    x_batch_id := l_id;
    x_return_status := l_return_status;



  else

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;

    END IF;

  end if;


     END LOOP;
     COMMIT;


  end if;

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
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

  END;

PROCEDURE create_actions
( P_API_VERSION          IN         NUMBER
, P_REQUESTOR            IN         VARCHAR2
, P_INIT_MSG_LIST        IN         VARCHAR2
, X_MSG_COUNT            OUT NOCOPY NUMBER
, X_MSG_DATA             OUT NOCOPY VARCHAR2
, P_ACTION               IN         VARCHAR2
, P_DELIVERABLE_ID       IN         NUMBER
, P_CHARGE_ACCOUNT       IN  	    NUMBER
, X_RESULT               OUT NOCOPY        NUMBER
, X_RETURN_STATUS        OUT NOCOPY        VARCHAR2
) IS

  l_api_name             varchar2(30);
  l_return_status        varchar2(1) ;

BEGIN

  l_api_name      := 'CREATE_ACTIONS';
  l_return_status := OKE_API.G_RET_STS_SUCCESS;

  l_return_status := OKE_API.START_ACTIVITY(
			l_api_name,
			OKE_API.G_FALSE,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;



  IF P_ACTION = 'PLAN' THEN

    create_mds_entry(
	P_DELIVERABLE_ID	=> P_DELIVERABLE_ID,
	X_OUT_ID		=> X_RESULT,
	X_RETURN_STATUS		=> L_RETURN_STATUS);

  ELSIF P_ACTION = 'SHIP' THEN

    create_ship_line(
	P_DELIVERABLE_ID	=> P_DELIVERABLE_ID,
	X_DELVIERY_DETAIL_ID	=> X_RESULT,
	X_RETURN_STATUS		=> L_RETURN_STATUS);

  ELSIF P_ACTION = 'REQ' THEN

    create_req_line(
	p_requestor		=> P_REQUESTOR,
    	p_deliverable_id 	=> P_DELIVERABLE_ID,
        p_charge_account	=> P_CHARGE_ACCOUNT,
    	x_batch_id 		=> X_RESULT,
    	x_return_status 	=> L_RETURN_STATUS);

  END IF;


  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  x_return_status := l_return_status;

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
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

  END;

--
-- Public Procedures
--
PROCEDURE Set_WF_Attributes
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

  l_k_number varchar2(120);
  l_doc_type varchar2(80);
  l_line_number varchar2(120);
  l_deliverable_num varchar2(120);
--bug 7390122 added parameter l_description to display deliverable description
  l_description varchar2(240);
--bug 7390122 end
  l_destination_type varchar2(80);
  l_expenditure_type varchar2(80);
  l_expenditure_item_date date;
  l_expenditure_org varchar2(240);
  l_need_by_date date;

  l_ship_from_location_id number;
  l_org_id                number;
  l_ship_from_location varchar2(80);

  CURSOR c_common (p_id number) IS
  SELECT H.k_number_disp     k_number
  ,      T.k_type_name       doc_type
  ,      L.line_number       line_number
  ,      D.deliverable_num   deliverable_num
  ,	 D.description	     description
  ,      h.authoring_org_id  org_id
--bug 7390122 changed oke_k_deliverables_b to oke_k_deliverables_vl as it has description
  FROM   oke_k_deliverables_vl D
  ,      okc_k_lines_b L
  ,      oke_k_headers_v H
  ,      oke_k_types_vl T
  WHERE  D.deliverable_id = p_id
  AND    L.id = D.k_line_id
  AND    H.k_header_id = L.dnz_chr_id
  AND    T.k_type_code = H.k_type_code;
  -- crec   c_common%rowtype;

  CURSOR c_req (p_id number) IS
  SELECT D.destination_type_code  destination_type
  ,      D.expenditure_type
  ,      D.expenditure_item_date
  ,      O.name                   expenditure_org
  ,      D.need_by_date
  FROM   oke_k_deliverables_b D
  ,      hr_all_organization_units_tl O
  WHERE  D.deliverable_id = p_id
  AND    O.organization_id (+) = D.expenditure_organization_id
  AND    O.language (+) = userenv('LANG');
  -- rrec   c_req%rowtype;

  CURSOR c_ship (p_id number) IS
  SELECT D.ship_from_location_id
  ,      L.location_code          ship_from_location
  FROM   oke_k_deliverables_b D
  ,      hr_locations_all_tl  L
  WHERE  D.deliverable_id = p_id
  AND    L.location_id = D.ship_from_location_id
  AND    L.language = userenv('LANG');
  -- srec   c_ship%rowtype;

  l_deliverable_id        NUMBER;
  l_action                VARCHAR2(30);

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    l_deliverable_id := WF_ENGINE.GetItemAttrNumber
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'DELIVERABLE_ID' );

    l_action := WF_ENGINE.GetItemAttrText
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ACTION' );

    --
    -- Initializing common attributes
    --


    OPEN c_common(l_deliverable_id);
--bug 7390122 added l_description for fetching description
    FETCH c_common INTO l_k_number, l_doc_type, l_line_number, l_deliverable_num,l_description,l_org_id;
    CLOSE c_common;

    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'DOC_TYPE'
    , AValue   => l_doc_type );

    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'K_NUMBER'
    , AValue   => l_k_number );

    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'DELIVERABLE_NUM'
    , AValue   => l_deliverable_num );

 --bug 7390122 added function for setting description
    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'DESCRIPTION'
    , AValue   => l_description );

    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'LINE_NUMBER'
    , AValue   => l_line_number );

    WF_ENGINE.SetItemAttrNUMBER
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'ORG_ID'
    , AValue   =>  l_org_id );

    IF ( l_action = 'REQ' ) THEN
      --
      -- Initializing Requisition specific attributes
      --


      OPEN c_req(l_deliverable_id);
      FETCH c_req INTO l_destination_type, l_expenditure_type, l_expenditure_item_date, l_expenditure_org, l_need_by_date;
      CLOSE c_req;

      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'DESTINATION_TYPE'
      , AValue   => l_destination_type );

      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'EXPENDITURE_TYPE'
      , AValue   => l_expenditure_type );

      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'EXPENDITURE_ORG'
      , AValue   => l_expenditure_org );

      WF_ENGINE.SetItemAttrDate
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'EXPENDITURE_ITEM_DATE'
      , AValue   => l_expenditure_item_date );

      WF_ENGINE.SetItemAttrDate
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'SCHEDULE_DATE'
      , AValue   => l_need_by_date );

    ELSIF ( l_action = 'SHIP' ) THEN
      --
      -- Initializing Shipping specific attributes
      --


      OPEN c_ship(l_deliverable_id);
      FETCH c_ship INTO l_ship_from_location_id, l_ship_from_location;
      CLOSE c_ship;

      WF_ENGINE.SetItemAttrText
      ( ItemType => ItemType
      , ItemKey  => ItemKey
      , AName    => 'SHIP_FROM_LOCATION'
      , AValue   => l_ship_from_location );

    END IF;

    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ResultOut := 'ERROR:';
    WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
    WF_Core.Context
            ( 'OKE_DTS_INTEGRATION_PKG'
            , 'SET_WF_ATTRIBUTES'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
    RAISE;

END Set_WF_Attributes;


PROCEDURE Create_Event
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

  l_api_version           NUMBER;
  l_init_msg_list         VARCHAR2(240);
  l_action                VARCHAR2(30);
  l_requestor             VARCHAR2(30);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  l_deliverable_id        NUMBER;
  l_result                NUMBER;
  l_return_status         VARCHAR2(240);
  l_error_text            VARCHAR2(4000);
  l_charge_account	  NUMBER;

  i                       NUMBER;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    l_api_version := WF_ENGINE.GetItemAttrNumber
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'API_VERSION' );

    l_init_msg_list := WF_ENGINE.GetItemAttrText
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'INIT_MSG_LIST' );

    l_deliverable_id := WF_ENGINE.GetItemAttrNumber
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'DELIVERABLE_ID' );

    l_action := WF_ENGINE.GetItemAttrText
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ACTION' );

    l_requestor := WF_ENGINE.GetItemAttrText
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'REQUESTOR' );

    l_charge_account := WF_ENGINE.GetItemAttrNumber
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'CHARGE_ACCOUNT' );
    FND_MSG_PUB.initialize;



    OKE_DTS_INTEGRATION_PKG.CREATE_ACTIONS
    ( l_api_version
    , l_requestor
    , l_init_msg_list
    , l_msg_count
    , l_msg_data
    , l_action
    , l_deliverable_id
    , l_charge_account
    , l_result
    , l_return_status);

    WF_ENGINE.SetItemAttrNumber
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'MSG_COUNT'
            , AValue   => l_msg_count );

    WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'MSG_DATA'
            , AValue   => l_msg_data );

    IF ( l_action = 'PLAN' ) THEN
      WF_ENGINE.SetItemAttrNumber
              ( ItemType => ItemType
              , ItemKey  => ItemKey
              , AName    => 'MPS_ID'
              , AValue   => l_result );
    ELSIF ( l_action = 'SHIP' ) THEN
      WF_ENGINE.SetItemAttrNumber
              ( ItemType => ItemType
              , ItemKey  => ItemKey
              , AName    => 'DELIVERY_DETAIL_ID'
              , AValue   => l_result );
    ELSIF ( l_action = 'REQ' ) THEN
      WF_ENGINE.SetItemAttrNumber
              ( ItemType => ItemType
              , ItemKey  => ItemKey
              , AName    => 'BATCH_ID'
              , AValue   => l_result );
    END IF;

    WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'RETURN_STATUS'
            , AValue   => l_return_status );

    IF ( l_return_status <> OKE_API.G_RET_STS_SUCCESS ) THEN

      if ( l_msg_count = 1 ) then
        l_error_text := FND_MSG_PUB.Get( p_msg_index => 1 , p_encoded => 'F' );
      elsif ( l_msg_count > 1 ) then
        for i in 1..l_msg_count loop
          if ( l_error_text is null ) then
            l_error_text := i || '. ' ||
                            fnd_msg_pub.get( p_msg_index => i , p_encoded => 'F' );
          else
            l_error_text := l_error_text || fnd_global.newline || fnd_global.newline ||
                            i || '. ' ||
                            fnd_msg_pub.get( p_msg_index => i , p_encoded => 'F' );
          end if;
        end loop;
      end if;

      WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => l_error_text );

      ResultOut := 'COMPLETE:E';
    ELSE
      ResultOut := 'COMPLETE:S';
    END IF;

    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ResultOut := 'ERROR:';
    WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
    WF_Core.Context
            ( 'OKE_DTS_INTEGRATION_PKG'
            , 'CREATE_EVENT'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
    RAISE;
END CREATE_EVENT;

PROCEDURE Get_Charge_Account
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS

  l_item_id	          NUMBER;
  l_org_id      	  NUMBER;
  l_charge_account	  NUMBER;


  i                       NUMBER;

BEGIN

  IF ( FuncMode = 'RUN' ) THEN

    l_item_id := WF_ENGINE.GetItemAttrNumber
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ITEM_ID' );

    l_Org_id := WF_ENGINE.GetItemAttrNumber
            ( itemtype => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ORGANIZATION_ID' );




    l_charge_account := OKE_DTS_INTEGRATION_PKG.CHARGE_ACCOUNT(L_Item_ID, L_Org_ID);

    WF_ENGINE.SetItemAttrNumber
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'CHARGE_ACCOUNT'
            , AValue   => l_charge_account);

     ResultOut := 'COMPLETE:S';

     RETURN;

  END IF;


  IF ( FuncMode = 'CANCEL' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ResultOut := 'ERROR:';
    WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
    WF_Core.Context
            ( 'OKE_DTS_INTEGRATION_PKG'
            , 'CREATE_EVENT'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
    RAISE;
END Get_Charge_Account;

PROCEDURE Launch_Process
( P_ACTION		       IN      VARCHAR2
, P_API_VERSION                IN      NUMBER
, P_COUNTRY_OF_ORIGIN_CODE     IN      VARCHAR2
, P_CURRENCY_CODE              IN      VARCHAR2
, P_DELIVERABLE_ID             IN      NUMBER
, P_DELIVERABLE_NUM            IN      VARCHAR2
, P_INIT_MSG_LIST	       IN      VARCHAR2
, P_INSPECTION_REQED	       IN      VARCHAR2
, P_ITEM_DESCRIPTION           IN      VARCHAR2
, P_ITEM_ID		       IN      NUMBER
, P_ITEM_NUM		       IN      VARCHAR2
, P_K_HEADER_ID  	       IN      NUMBER
, P_K_NUMBER		       IN      VARCHAR2
, P_LINE_NUMBER		       IN      VARCHAR2
, P_MPS_TRANSACTION_ID	       IN      NUMBER
, P_ORGANIZATION	       IN      VARCHAR2
, P_ORGANIZATION_ID	       IN      NUMBER
, P_PROJECT_ID		       IN      NUMBER
, P_PROJECT_NUM                IN      VARCHAR2
, P_QUANTITY    	       IN      NUMBER
, P_SCHEDULE_DATE              IN      DATE
, P_SCHEDULE_DESIGNATOR        IN      VARCHAR2
, P_SHIP_TO_LOCATION           IN      VARCHAR2
, P_TASK_ID      	       IN      NUMBER
, P_TASK_NUM                   IN      VARCHAR2
, P_UNIT_NUMBER                IN      VARCHAR2
, P_UOM_CODE                   IN      VARCHAR2
, P_WORK_DATE		       IN      DATE
, P_REQUESTOR                  IN      VARCHAR2 := NULL
)IS
   L_WF_Item_Type VARCHAR2(8)   ;
   L_WF_Process   VARCHAR2(240) ;
   L_WF_Item_Key  VARCHAR2(240) ;
   L_WF_User_Key  VARCHAR2(240) ;
   L_REQUESTOR   VARCHAR2(240) := NVL(P_REQUESTOR,FND_GLOBAL.User_Name);
BEGIN
   L_WF_Item_Type :='OKEDTS';

   IF P_ACTION = 'PLAN' THEN
      L_WF_Process := 'OKEDTSPLAN';
   ELSIF P_ACTION = 'SHIP' THEN
      L_WF_Process := 'OKEDTSSHIP';
   ELSIF P_ACTION = 'REQ' THEN
      L_WF_Process := 'OKEDTSREQ';
   END IF;

   L_WF_Item_Key := P_Deliverable_ID || ':' ||
                    to_char(sysdate , 'DDMONRRHH24MISS');

   L_WF_User_Key := P_K_NUMBER        || ':' ||
                    P_LINE_NUMBER     || ':' ||
                    P_Deliverable_Num || ':' ||
                    L_WF_Process      || ':' ||
                    P_Deliverable_ID  || ':' ||
                    to_char(sysdate , 'DDMONRRHH24MISS');


   WF_Engine.CreateProcess
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , Process  => L_WF_Process);

   WF_Engine.SetItemOwner
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , Owner    => L_REQUESTOR);

   WF_Engine.SetItemUserKey
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , UserKey  => L_WF_User_Key);

    --
    -- Setting various Workflow Item Attributes
    --

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'ACTION'
      , AValue   => P_ACTION );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'API_VERSION'
      , AValue   => P_API_VERSION );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'COUNTRY_OF_ORIGIN_CODE'
      , AValue   => P_COUNTRY_OF_ORIGIN_CODE );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'CURRENCY_CODE'
      , AValue   => P_CURRENCY_CODE );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'DELIVERABLE_ID'
      , AValue   => P_DELIVERABLE_ID );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'DELIVERABLE_NUM'
      , AValue   => P_DELIVERABLE_NUM );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'INIT_MSG_LIST'
      , AValue   => P_INIT_MSG_LIST );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'INSPECTION_REQED'
      , AValue   => P_INSPECTION_REQED );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'ITEM_DESCRIPTION'
      , AValue   => P_ITEM_DESCRIPTION );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'ITEM_ID'
      , AValue   => P_ITEM_ID );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'ITEM_NUM'
      , AValue   => P_ITEM_NUM );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'K_HEADER_ID'
      , AValue   => P_K_HEADER_ID );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'K_NUMBER'
      , AValue   => P_K_NUMBER );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'LINE_NUMBER'
      , AValue   => P_LINE_NUMBER );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'MPS_TRANSACTION_ID'
      , AValue   => P_MPS_TRANSACTION_ID );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'ORGANIZATION'
      , AValue   => P_ORGANIZATION );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'ORGANIZATION_ID'
      , AValue   => P_ORGANIZATION_ID );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'PROJECT_ID'
      , AValue   => P_PROJECT_ID );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'PROJECT_NUM'
      , AValue   => P_PROJECT_NUM );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'QUANTITY'
      , AValue   => P_QUANTITY );

   WF_ENGINE.SetItemAttrDate
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'SCHEDULE_DATE'
      , AValue   => P_SCHEDULE_DATE );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'SCHEDULE_DESIGNATOR'
      , AValue   => P_SCHEDULE_DESIGNATOR );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'SHIP_TO_LOCATION'
      , AValue   => P_SHIP_TO_LOCATION );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'TASK_ID'
      , AValue   => P_TASK_ID );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'TASK_NUM'
      , AValue   => P_TASK_NUM );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'UNIT_NUMBER'
      , AValue   => P_UNIT_NUMBER );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'UOM_CODE'
      , AValue   => P_UOM_CODE );

   WF_ENGINE.SetItemAttrDate
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'WORK_DATE'
      , AValue   => P_WORK_DATE );

   WF_ENGINE.SetItemAttrText
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'REQUESTOR'
      , AValue   => l_requestor );

   WF_ENGINE.SetItemAttrNumber
      ( ItemType => L_WF_Item_Type
      , ItemKey  => L_WF_Item_Key
      , AName    => 'CHARGE_ACCOUNT'
      , AValue   => NULL );
  --
  -- Start the Workflow Process
  --
  WF_ENGINE.StartProcess( ItemType => L_WF_Item_Type
                        , ItemKey  => L_WF_Item_Key );


END Launch_Process;

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

   FUNCTION Get_WSH_Allowed_Cancel_Qty (
      P_DELIVERABLE_ID   IN NUMBER
     ) RETURN NUMBER IS
     l_cancel_qty NUMBER := -1;
     l_return_status         VARCHAR2(1) := 'S';
     l_msg_count             NUMBER := 0;
     l_msg_data              VARCHAR2(2000);
    BEGIN
     WSH_INTEGRATION.Get_Cancel_Qty_Allowed
                    ( p_source_code         => 'OKE',
                      p_source_line_id      => P_DELIVERABLE_ID,
                      x_cancel_qty_allowed  => l_cancel_qty,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data
                     );
     IF l_return_status <> 'S' THEN
       l_cancel_qty := 0;
     END IF;
    RETURN l_cancel_qty;

   END Get_WSH_Allowed_Cancel_Qty;

   PROCEDURE Cancel_Shipping(
     P_DELIVERABLE_ID            IN      NUMBER,
     X_CANCELLED_QTY                     OUT NOCOPY        NUMBER,
     X_RETURN_STATUS                     OUT NOCOPY        VARCHAR2
   ) IS
     l_header_id NUMBER;
     l_shipping_request_id NUMBER;
     l_uom_code VARCHAR2(3);
     l_changed_attributes WSH_INTERFACE.ChangedAttributeTabType;

     CURSOR dlvbl_c IS
        SELECT k_header_id, uom_code, shipping_request_id
         FROM oke_k_deliverables_b
         where deliverable_id = p_deliverable_id;

    CURSOR cancel_qty_c IS
        SELECT Nvl(Sum(CANCELLED_QUANTITY),0)
         FROM wsh_delivery_details
         where source_code = 'OKE'
         AND SOURCE_line_ID = p_deliverable_id
         START WITH DELIVERY_DETAIL_ID=l_shipping_request_id
         CONNECT BY PRIOR DELIVERY_DETAIL_ID = SPLIT_FROM_DELIVERY_DETAIL_ID;
    BEGIN
     OPEN dlvbl_c;
     FETCH dlvbl_c INTO l_header_id, l_uom_code, l_shipping_request_id;
     CLOSE dlvbl_c;
     l_changed_attributes(1).source_header_id := l_header_id;
     l_changed_attributes(1).original_source_line_id := p_deliverable_id;
     l_changed_attributes(1).shipped_flag := 'N';
     l_changed_attributes(1).source_line_id := P_DELIVERABLE_ID;
    l_changed_attributes(1).order_quantity_uom := l_uom_code;
     l_changed_attributes(1).source_code := 'OKE';
     l_changed_attributes(1).action_flag := 'U';
     l_changed_attributes(1).ordered_quantity := 0;
     WSH_INTERFACE.Update_Shipping_Attributes (
       p_source_code         => 'OKE',
       p_changed_attributes  => l_changed_attributes,
      x_return_status       => X_RETURN_STATUS
     );
     IF x_return_status = 'S' THEN
       OPEN cancel_qty_c;
       FETCH cancel_qty_c INTO x_cancelled_qty;
       CLOSE cancel_qty_c;
--bug 8320909 start
  UPDATE oke_k_deliverables_b
 	       SET quantity=quantity-x_cancelled_qty
 	       WHERE deliverable_id = p_deliverable_id;
--bug 8320909 end
      ELSE
       x_cancelled_qty := 0;
     END IF;
   END Cancel_Shipping;




END;

/
