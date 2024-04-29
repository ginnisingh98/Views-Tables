--------------------------------------------------------
--  DDL for Package Body WSH_PICKING_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PICKING_BATCHES_PKG" as
/* $Header: WSHPRBTB.pls 120.3.12010000.2 2009/12/03 13:36:16 anvarshn ship $ */


  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PICKING_BATCHES_PKG';
  --
  -- Bug 3266659: Added P_Ship_Set_Smc_Flag for the pick release public API

  PROCEDURE Insert_Row(X_Rowid           IN OUT NOCOPY  VARCHAR2,
             X_Batch_Id       IN OUT NOCOPY  NUMBER,
             P_Creation_Date          DATE,
             P_Created_By          NUMBER,
             P_Last_Update_Date        DATE,
             P_Last_Updated_By        NUMBER,
             P_Last_Update_Login        NUMBER,
 	     -- Bug 3266659 : Batch name prefix
	     p_batch_name_prefix	VARCHAR2 DEFAULT NULL,
             X_Name         IN OUT NOCOPY  VARCHAR2,
             P_Backorders_Only_Flag      VARCHAR2,
             P_Document_Set_Id        NUMBER,
             P_Existing_Rsvs_Only_Flag    VARCHAR2,
             P_Shipment_Priority_Code    VARCHAR2,
             P_Ship_Method_Code        VARCHAR2,
             P_Customer_Id          NUMBER,
             P_Order_Header_Id        NUMBER,
             P_Ship_Set_Number        NUMBER,
             P_Inventory_Item_Id        NUMBER,
             P_Order_Type_Id          NUMBER,
             P_From_Requested_Date      DATE,
             P_To_Requested_Date        DATE,
             P_From_Scheduled_Ship_Date    DATE,
             P_To_Scheduled_Ship_Date    DATE,
             P_Ship_To_Location_Id      NUMBER,
             P_Ship_From_Location_Id      NUMBER,
             P_Trip_Id      NUMBER,
             P_Delivery_Id      NUMBER,
             P_Include_Planned_Lines    VARCHAR2,
             P_Pick_Grouping_Rule_Id    NUMBER,
             P_Pick_Sequence_Rule_Id    NUMBER,
             P_Autocreate_Delivery_Flag VARCHAR2,
             P_Attribute_Category      VARCHAR2,
             P_Attribute1          VARCHAR2,
             P_Attribute2          VARCHAR2,
             P_Attribute3          VARCHAR2,
             P_Attribute4          VARCHAR2,
             P_Attribute5          VARCHAR2,
             P_Attribute6          VARCHAR2,
             P_Attribute7          VARCHAR2,
             P_Attribute8          VARCHAR2,
             P_Attribute9          VARCHAR2,
             P_Attribute10          VARCHAR2,
             P_Attribute11          VARCHAR2,
             P_Attribute12          VARCHAR2,
             P_Attribute13          VARCHAR2,
             P_Attribute14          VARCHAR2,
             P_Attribute15          VARCHAR2,
             P_Autodetail_Pr_Flag      VARCHAR2,
             P_Carrier_Id          NUMBER,
             P_Trip_Stop_Id          NUMBER,
             P_Default_Stage_Subinventory  VARCHAR2,
             P_Default_Stage_Locator_Id    NUMBER,
             P_Pick_From_Subinventory    VARCHAR2,
             P_Pick_From_locator_Id      NUMBER,
             P_Auto_Pick_Confirm_Flag    VARCHAR2,
             P_Delivery_Detail_Id     NUMBER,
             P_Project_Id          NUMBER,
             P_Task_Id            NUMBER,
             P_Organization_Id    NUMBER,
             P_Ship_Confirm_Rule_Id      NUMBER,
             P_Autopack_Flag          VARCHAR2,
             P_Autopack_Level        NUMBER,
             P_Task_Planning_Flag      VARCHAR2,
             P_Dynamic_replenishment_Flag      VARCHAR2 DEFAULT NULL, --bug# 6689448 (replenishment project)
             P_Non_Picking_Flag      VARCHAR2 DEFAULT NULL,
             p_regionID		     NUMBER,
             p_zoneId		     NUMBER,
             p_categoryID	     NUMBER,
             p_categorySetID	     NUMBER,
             p_acDelivCriteria	     VARCHAR2,
	     p_RelSubinventory	     VARCHAR2,
	     p_append_flag           VARCHAR2,
             p_task_priority         NUMBER,
	     P_Ship_Set_Smc_Flag     VARCHAR2  DEFAULT NULL, --- Added for pick release Public API
             p_actual_departure_date DATE,
             p_allocation_method     VARCHAR2 , -- X-dock
             p_crossdock_criteria_id NUMBER,    -- X-dock
             -- but 5117876, following 14 attributes are added
             p_Delivery_Name_Lo      VARCHAR2        DEFAULT NULL,
             p_Delivery_Name_Hi      VARCHAR2        DEFAULT NULL,
             p_Bol_Number_Lo         VARCHAR2        DEFAULT NULL,
             p_Bol_Number_Hi         VARCHAR2        DEFAULT NULL,
             p_Intmed_Ship_To_Loc_Id NUMBER        DEFAULT NULL,
             p_Pooled_Ship_To_Loc_Id NUMBER        DEFAULT NULL,
             p_Fob_Code              VARCHAR2        DEFAULT NULL,
             p_Freight_Terms_Code    VARCHAR2        DEFAULT NULL,
             p_Pickup_Date_Lo        DATE        DEFAULT NULL,
             p_Pickup_Date_Hi        DATE        DEFAULT NULL,
             p_Dropoff_Date_Lo       DATE        DEFAULT NULL,
             p_Dropoff_Date_Hi       DATE        DEFAULT NULL,
             p_Planned_Flag          VARCHAR2        DEFAULT NULL,
             p_Selected_Batch_Id     NUMBER        DEFAULT NULL,
             p_client_Id             NUMBER      DEFAULT NULL --Modified R12.1.1 LSP PROJECT
  ) IS
  --
  CURSOR C IS SELECT rowid FROM WSH_PICKING_BATCHES
         WHERE batch_id = X_Batch_Id;

  -- bug 5117876, use sequence mtl_txn_request_headers_s
  -- CURSOR NEXTID IS SELECT wsh_picking_batches_s.nextval FROM sys.dual;
  CURSOR NEXTID IS SELECT mtl_txn_request_headers_s.nextval FROM sys.dual;

  -- bug 5117876, add one more parameter batchid
/*
  CURSOR Batch (batch_name VARCHAR2) IS
         Select batch_id From WSH_PICKING_BATCHES
         Where NAME = batch_name;
*/
  CURSOR Batch (batch_name VARCHAR2, batchid NUMBER) IS
         Select batch_id From WSH_PICKING_BATCHES
         Where NAME = batch_name OR batch_id = batchid;

  --
  CURSOR Move_Order (batch_name VARCHAR2) IS
        SELECT header_id FROM MTL_TXN_REQUEST_HEADERS
        WHERE request_number =  batch_name;
  --
  userid  NUMBER;
  loginid NUMBER;
  temp  NUMBER;
  temp2   NUMBER;
--Added for Bugfix#1724744.
  P_Trip_For_Stop_Id NUMBER;
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
  --
  -- Added for Bug#: 3266659
   l_batch_name_prefix VARCHAR2(30);

   BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       --
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
       WSH_DEBUG_SV.log(l_module_name,'X_BATCH_ID',X_BATCH_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
       WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
       WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
       WSH_DEBUG_SV.log(l_module_name,'X_NAME',X_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_BACKORDERS_ONLY_FLAG',P_BACKORDERS_ONLY_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SET_ID',P_DOCUMENT_SET_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_EXISTING_RSVS_ONLY_FLAG',P_EXISTING_RSVS_ONLY_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_PRIORITY_CODE',P_SHIPMENT_PRIORITY_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_NUMBER',P_SHIP_SET_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE_ID',P_ORDER_TYPE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_REQUESTED_DATE',P_FROM_REQUESTED_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_TO_REQUESTED_DATE',P_TO_REQUESTED_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_FROM_SCHEDULED_SHIP_DATE',P_FROM_SCHEDULED_SHIP_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_TO_SCHEDULED_SHIP_DATE',P_TO_SCHEDULED_SHIP_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_SHIP_TO_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOCATION_ID',P_SHIP_FROM_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INCLUDE_PLANNED_LINES',P_INCLUDE_PLANNED_LINES);
       WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_ID',P_PICK_GROUPING_RULE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQUENCE_RULE_ID',P_PICK_SEQUENCE_RULE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_AUTOCREATE_DELIVERY_FLAG',P_AUTOCREATE_DELIVERY_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
       WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
       WSH_DEBUG_SV.log(l_module_name,'P_AUTODETAIL_PR_FLAG',P_AUTODETAIL_PR_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_SUBINVENTORY',P_DEFAULT_STAGE_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_LOCATOR_ID',P_DEFAULT_STAGE_LOCATOR_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_SUBINVENTORY',P_PICK_FROM_SUBINVENTORY);
       WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_LOCATOR_ID',P_PICK_FROM_LOCATOR_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_AUTO_PICK_CONFIRM_FLAG',P_AUTO_PICK_CONFIRM_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_PROJECT_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_TASK_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_CONFIRM_RULE_ID',P_SHIP_CONFIRM_RULE_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_AUTOPACK_FLAG',P_AUTOPACK_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_AUTOPACK_LEVEL',P_AUTOPACK_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'P_TASK_PLANNING_FLAG',P_TASK_PLANNING_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_dynamic_replenishment_flag',P_dynamic_replenishment_flag); --bug# 6689448 (replenishment project)
       WSH_DEBUG_SV.log(l_module_name,'P_Non_Picking_Flag',P_Non_Picking_Flag);
       -- rlanka : Pack J Enhancement
       wsh_debug_Sv.log(l_module_name,'p_RegionID', p_regionID);
       wsh_debug_sv.log(l_module_name,'p_zoneID',p_zoneID);
       wsh_debug_sv.log(l_module_name,'p_categoryID',p_categoryID);
       wsh_debug_sv.log(l_module_name,'p_categorySetID',p_categorySetID);
       wsh_debug_sv.log(l_module_name,'p_acDelivCriteria',p_acDelivCriteria);
       wsh_debug_sv.log(l_module_name,'p_RelSubinventory', p_RelSubinventory);
       wsh_debug_sv.log(l_module_name,'p_append_flag', p_append_flag);
       -- Bug#: 3266659 : Pick Release API
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_SMC_FLAG',P_SHIP_SET_SMC_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'p_batch_name_prefix',p_batch_name_prefix);
       WSH_DEBUG_SV.log(l_module_name,'p_task_priority',p_task_priority);
       WSH_DEBUG_SV.log(l_module_name,'p_actual_departure_date',p_actual_departure_date);
       -- X-dock
       WSH_DEBUG_SV.log(l_module_name,'p_allocation_method',p_allocation_method);
       WSH_DEBUG_SV.log(l_module_name,'p_crossdock_criteria_id',p_crossdock_criteria_id);
       -- bug 5117876, 14 more attributes
       WSH_DEBUG_SV.log(l_module_name,'p_Delivery_Name_Lo', p_Delivery_Name_Lo);
       WSH_DEBUG_SV.log(l_module_name,'p_Delivery_Name_Hi', p_Delivery_Name_Hi);
       WSH_DEBUG_SV.log(l_module_name,'p_Bol_Number_Lo',p_Bol_Number_Lo);
       WSH_DEBUG_SV.log(l_module_name,'p_Bol_Number_Hi',p_Bol_Number_Hi);
       WSH_DEBUG_SV.log(l_module_name,'p_Intmed_Ship_To_Loc_Id', p_Intmed_Ship_To_Loc_Id);
       WSH_DEBUG_SV.log(l_module_name,'p_Pooled_Ship_To_Loc_Id', p_Pooled_Ship_To_Loc_Id);
       WSH_DEBUG_SV.log(l_module_name,'p_Fob_Code', p_Fob_Code);
       WSH_DEBUG_SV.log(l_module_name,'p_Freight_Terms_Code', p_Freight_Terms_Code);
       WSH_DEBUG_SV.log(l_module_name,'p_Pickup_Date_Lo', p_Pickup_Date_Lo);
       WSH_DEBUG_SV.log(l_module_name,'p_Pickup_Date_Hi', p_Pickup_Date_Hi);
       WSH_DEBUG_SV.log(l_module_name,'p_Dropoff_Date_Lo', p_Dropoff_Date_Lo);
       WSH_DEBUG_SV.log(l_module_name,'p_Dropoff_Date_Hi', p_Dropoff_Date_Hi);
       WSH_DEBUG_SV.log(l_module_name,'p_Planned_Flag', p_Planned_Flag);
       WSH_DEBUG_SV.log(l_module_name,'p_Selected_Batch_Id', p_Selected_Batch_Id);
	 WSH_DEBUG_SV.log(l_module_name,'p_Client_Id', p_client_Id);               --Modified R12.1.1 LSP PROJECT

       --
     END IF;
     --
     userid  := FND_GLOBAL.USER_ID;
     loginid := FND_GLOBAL.LOGIN_ID;

     -- Added for Bug#: 3266659
     l_batch_name_prefix := p_batch_name_prefix;


     IF (X_Batch_Id is NULL) THEN
     OPEN NEXTID;
     FETCH NEXTID INTO X_Batch_Id;
     CLOSE NEXTID;
     END IF;

       --Bug#: 3266659: Added code to look for
       -- Default Batch Name
       IF ( X_Name is NULL) Then
          IF ( l_batch_name_prefix is NOT NULL ) THEN
   	     X_Name := l_batch_name_prefix ||'-'|| TO_CHAR(X_Batch_Id);
  	  ELSE
	     X_Name := TO_CHAR(X_Batch_Id);
	  END IF;
       ELSE
          l_batch_name_prefix := NULL;   ---later we will check this value
       END IF;


     Loop
       OPEN  Move_Order( X_Name);
       FETCH Move_Order INTO temp;
       IF Move_Order%NOTFOUND THEN
        CLOSE Move_Order;
        -- bug 5117876, X_Batch_Id is added
        OPEN  Batch( X_Name, X_Batch_Id);
        FETCH Batch INTO temp;
        IF Batch%NOTFOUND THEN
         CLOSE Batch;
        EXIT;
        END IF;
       END IF;

       OPEN NEXTID;
       FETCH NEXTID INTO X_Batch_Id;
       CLOSE NEXTID;

       -- Added for Bug#: 3266659
       IF ( l_batch_name_prefix is NOT NULL ) THEN
    	      X_Name := l_batch_name_prefix ||'-'|| TO_CHAR(X_Batch_Id);
       ELSE
	      X_Name := TO_CHAR(X_Batch_Id);
       END IF;

     IF Move_Order%ISOPEN THEN
        CLOSE Move_Order;
       END IF;
       IF Batch%ISOPEN THEN
        CLOSE Batch;
       END IF;
     End Loop;

--Start Bugfix#1724744.
     IF ( p_trip_stop_id IS NOT NULL ) then
      IF ( p_trip_id IS NULL) then
       SELECT trip_id
       INTO P_Trip_For_Stop_id
       FROM wsh_trip_stops
       WHERE stop_id = p_trip_stop_id;
      END IF;
     END IF;
--End Bugfix#1724744.

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Inserting into WSH_PICKING_BATCHES');
     END IF;

     INSERT INTO WSH_PICKING_BATCHES(
        batch_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        name,
        backorders_only_flag,
        document_set_id,
        existing_rsvs_only_flag,
        shipment_priority_code,
        ship_method_code,
        customer_id,
        Order_Header_Id,
        ship_set_number,
        inventory_item_id,
        order_type_id,
        from_requested_date,
        to_requested_date,
        from_scheduled_ship_date,
        to_scheduled_ship_date,
        ship_to_location_id,
        ship_from_location_id,
        trip_id,
        delivery_id,
        include_planned_lines,
        pick_grouping_rule_id,
        pick_sequence_rule_id,
        autocreate_delivery_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        autodetail_pr_flag,
        Carrier_Id,
        Trip_Stop_Id,
        Default_Stage_Subinventory,
        Default_Stage_Locator_Id,
        Pick_From_Subinventory,
        Pick_From_locator_Id,
        Auto_Pick_Confirm_Flag,
        Delivery_Detail_Id,
        Project_Id,
        Task_Id,
        organization_id,
        Ship_Confirm_Rule_Id,
        Autopack_Flag,
        Autopack_Level,
        Task_Planning_Flag,
        Dynamic_Replenishment_flag, --bug# 6689448 (replenishment project)
        non_picking_flag,
	/* rlanka : Pack J Enhancement */
        region_ID,
        zone_ID,
        category_ID,
        category_Set_ID,
        ac_Delivery_Criteria,
	rel_subinventory,
	append_flag,
        task_priority,
	ship_set_smc_flag, -- Bug#: 3266659
        actual_departure_date,
        allocation_method,     -- X-dock
        crossdock_criteria_id, -- X-dock
        Delivery_Name_Lo,      -- bug 5117876, 14 attriubtes are added
        Delivery_Name_Hi,
        Bol_Number_Lo,
        Bol_Number_Hi,
        Intmed_Ship_To_Loc_Id,
        Pooled_Ship_To_Loc_Id,
        Fob_Code,
        Freight_Terms_Code,
        Pickup_Date_Lo,
        Pickup_Date_Hi,
        Dropoff_Date_Lo,
        Dropoff_Date_Hi,
        Planned_Flag,
        Selected_Batch_Id,
	  Client_ID                     --Modified R12.1.1 LSP PROJECT
       ) VALUES (
        X_Batch_Id,
        SYSDATE,
        userid,
        SYSDATE,
        userid,
        loginid,
        X_Name,
        P_Backorders_Only_Flag,
        P_Document_Set_Id,
        P_Existing_Rsvs_Only_Flag,
        P_Shipment_Priority_Code,
        P_Ship_Method_Code,
        P_Customer_Id,
        P_Order_Header_Id,
        P_Ship_Set_Number,
        P_Inventory_Item_Id,
        P_Order_Type_Id,
        P_From_Requested_Date,
        P_To_Requested_Date,
        P_From_Scheduled_Ship_Date,
        P_To_Scheduled_Ship_Date,
        P_Ship_To_Location_Id,
        P_Ship_From_Location_Id,
	--Introduced NVL for Bugfix#1724744.
      	NVL(P_Trip_Id,P_Trip_For_Stop_Id),
      	P_Delivery_Id,
      	P_Include_Planned_Lines,
      	P_Pick_Grouping_Rule_Id,
      	P_Pick_Sequence_Rule_Id,
      	P_Autocreate_Delivery_Flag,
        P_Attribute_Category,
        P_Attribute1,
        P_Attribute2,
        P_Attribute3,
        P_Attribute4,
        P_Attribute5,
        P_Attribute6,
        P_Attribute7,
        P_Attribute8,
        P_Attribute9,
        P_Attribute10,
        P_Attribute11,
        P_Attribute12,
        P_Attribute13,
        P_Attribute14,
        P_Attribute15,
        P_Autodetail_Pr_Flag,
        P_Carrier_Id,
        P_Trip_Stop_Id,
        P_Default_Stage_Subinventory,
        P_Default_Stage_Locator_Id,
        P_Pick_From_Subinventory,
        P_Pick_From_locator_Id,
        P_Auto_Pick_Confirm_Flag,
        P_Delivery_Detail_Id,
        P_Project_id,
        P_Task_Id,
      	P_Organization_Id,
        P_Ship_Confirm_Rule_Id,
        P_Autopack_Flag,
        P_Autopack_Level,
        P_Task_Planning_Flag,
        P_Dynamic_Replenishment_flag, --bug# 6689448 (replenishment project)
        P_Non_Picking_Flag,
        p_regionID,
        p_zoneId,
        p_categoryID,
        p_categorySetID,
        p_acDelivCriteria,
	p_RelSubinventory,
	p_append_flag,
        p_task_priority,
	p_Ship_Set_Smc_Flag, -- Bug#: 3266659
        p_actual_departure_date,
        nvl(p_allocation_method,'I'),    -- X-dock
        p_crossdock_criteria_id, -- X-dock
        p_Delivery_Name_Lo,      -- bug 5117876, 14 attributes are added
        p_Delivery_Name_Hi,
        p_Bol_Number_Lo,
        p_Bol_Number_Hi,
        p_Intmed_Ship_To_Loc_Id,
        p_Pooled_Ship_To_Loc_Id,
        p_Fob_Code,
        p_Freight_Terms_Code,
        p_Pickup_Date_Lo,
        p_Pickup_Date_Hi,
        p_Dropoff_Date_Lo,
        p_Dropoff_Date_Hi,
        p_Planned_Flag,
        p_Selected_Batch_Id,
	  p_client_Id                   --Modified R12.1.1 LSP PROJECT
       );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    Raise NO_DATA_FOUND;
  end if;
  IF C%ISOPEN THEN
    CLOSE C;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

  EXCEPTION
    WHEN OTHERS THEN
      IF C%ISOPEN THEN
         CLOSE C;
      END IF;
      IF NEXTID%ISOPEN THEN
         CLOSE NEXTID;
      END IF;
      IF Batch%ISOPEN THEN
         CLOSE Batch;
      END IF;
      IF Move_Order%ISOPEN THEN
         CLOSE Move_Order;
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid              IN OUT NOCOPY  VARCHAR2,
           P_Batch_Id            NUMBER,
           P_Name              VARCHAR2,
           P_Backorders_Only_Flag      VARCHAR2,
           P_Document_Set_Id          NUMBER,
           P_Existing_Rsvs_Only_Flag      VARCHAR2,
           P_Shipment_Priority_Code      VARCHAR2,
           P_Ship_Method_Code        VARCHAR2,
           P_Customer_Id            NUMBER,
           P_Order_Header_Id            NUMBER,
           P_Ship_Set_Number          NUMBER,
           P_Inventory_Item_Id        NUMBER,
           P_Order_Type_Id          NUMBER,
           P_From_Requested_Date        DATE,
           P_To_Requested_Date        DATE,
           P_From_Scheduled_Ship_Date DATE,
           P_To_Scheduled_Ship_Date    DATE,
           P_Ship_To_Location_Id            NUMBER,
           P_Ship_From_Location_Id           NUMBER,
           P_Trip_Id         NUMBER,
           P_Delivery_Id         NUMBER,
           P_Include_Planned_Lines     VARCHAR2,
           P_Pick_Grouping_Rule_Id      NUMBER,
           P_Pick_Sequence_Rule_Id      NUMBER,
       	   P_Autocreate_Delivery_Flag   VARCHAR2,
           P_Attribute_Category             VARCHAR2,
           P_Attribute1            VARCHAR2,
           P_Attribute2            VARCHAR2,
           P_Attribute3            VARCHAR2,
           P_Attribute4            VARCHAR2,
           P_Attribute5            VARCHAR2,
           P_Attribute6            VARCHAR2,
           P_Attribute7            VARCHAR2,
           P_Attribute8            VARCHAR2,
           P_Attribute9            VARCHAR2,
           P_Attribute10            VARCHAR2,
           P_Attribute11            VARCHAR2,
           P_Attribute12            VARCHAR2,
           P_Attribute13            VARCHAR2,
           P_Attribute14            VARCHAR2,
           P_Attribute15            VARCHAR2,
           P_Autodetail_Pr_Flag        VARCHAR2,
           P_Carrier_Id            NUMBER,
           P_Trip_Stop_Id          NUMBER,
           P_Default_Stage_Subinventory    VARCHAR2,
           P_Default_Stage_Locator_Id    NUMBER,
           P_Pick_From_Subinventory      VARCHAR2,
           P_Pick_From_locator_Id      NUMBER,
           P_Auto_Pick_Confirm_Flag      VARCHAR2,
           P_Delivery_Detail_Id     NUMBER,
           P_Project_Id            NUMBER,
           P_Task_Id              NUMBER,
           P_Organization_Id        NUMBER,
           P_Ship_Confirm_Rule_Id     NUMBER,
           P_Autopack_Flag           VARCHAR2,
           P_Autopack_Level          NUMBER,
           P_Task_Planning_Flag        VARCHAR2,
           P_Dynamic_replenishment_Flag      VARCHAR2, --bug# 6689448 (replenishment project)
           P_Non_Picking_Flag        VARCHAR2,
           p_regionID		     NUMBER,
           p_zoneId		     NUMBER,
           p_categoryID	     	     NUMBER,
           p_categorySetID	     NUMBER,
           p_acDelivCriteria	     VARCHAR2,
	   p_RelSubinventory	     VARCHAR2,
	   p_append_flag             VARCHAR2,
           p_task_priority           NUMBER,
           p_actual_departure_date   DATE,
           p_allocation_method     VARCHAR2 , -- X-dock
           p_crossdock_criteria_id NUMBER,  --  X-dock
	     p_client_Id             NUMBER   --Modified R12.1.1 LSP PROJECT
  ) IS
  --
  CURSOR C IS
    SELECT *
    FROM   WSH_PICKING_BATCHES
    WHERE  rowid = X_Rowid
    FOR UPDATE of Batch_Id NOWAIT;
  --
  Recinfo C%ROWTYPE;
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
    WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_NAME',P_NAME);
    WSH_DEBUG_SV.log(l_module_name,'P_BACKORDERS_ONLY_FLAG',P_BACKORDERS_ONLY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SET_ID',P_DOCUMENT_SET_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_EXISTING_RSVS_ONLY_FLAG',P_EXISTING_RSVS_ONLY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_PRIORITY_CODE',P_SHIPMENT_PRIORITY_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_NUMBER',P_SHIP_SET_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE_ID',P_ORDER_TYPE_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_FROM_REQUESTED_DATE',P_FROM_REQUESTED_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_TO_REQUESTED_DATE',P_TO_REQUESTED_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_FROM_SCHEDULED_SHIP_DATE',P_FROM_SCHEDULED_SHIP_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_TO_SCHEDULED_SHIP_DATE',P_TO_SCHEDULED_SHIP_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_SHIP_TO_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOCATION_ID',P_SHIP_FROM_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_INCLUDE_PLANNED_LINES',P_INCLUDE_PLANNED_LINES);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_ID',P_PICK_GROUPING_RULE_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQUENCE_RULE_ID',P_PICK_SEQUENCE_RULE_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_AUTOCREATE_DELIVERY_FLAG',P_AUTOCREATE_DELIVERY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
    WSH_DEBUG_SV.log(l_module_name,'P_AUTODETAIL_PR_FLAG',P_AUTODETAIL_PR_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_SUBINVENTORY',P_DEFAULT_STAGE_SUBINVENTORY);
    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_LOCATOR_ID',P_DEFAULT_STAGE_LOCATOR_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_SUBINVENTORY',P_PICK_FROM_SUBINVENTORY);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_LOCATOR_ID',P_PICK_FROM_LOCATOR_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_AUTO_PICK_CONFIRM_FLAG',P_AUTO_PICK_CONFIRM_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_PROJECT_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_TASK_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TASK_PLANNING_FLAG',P_TASK_PLANNING_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_dynamic_replenishment_flag',P_dynamic_replenishment_flag);  --bug# 6689448 (replenishment project)
    WSH_DEBUG_SV.log(l_module_name,'P_Non_Picking_FLAG',P_Non_Picking_FLAG);
    --
    -- rlanka : Pack J Enhancement
    --
    wsh_debug_Sv.log(l_module_name,'p_RegionID', p_regionID);
    wsh_debug_sv.log(l_module_name,'p_zoneID',p_zoneID);
    wsh_debug_sv.log(l_module_name,'p_categoryID',p_categoryID);
    wsh_debug_sv.log(l_module_name,'p_categorySetID',p_categorySetID);
    wsh_debug_sv.log(l_module_name,'p_acDelivCriteria',p_acDelivCriteria);
    wsh_debug_sv.log(l_module_name,'p_RelSubinventory', p_RelSubinventory);
    wsh_debug_sv.log(l_module_name,'p_append_flag', p_append_flag);
    wsh_debug_sv.log(l_module_name,'p_task_priority', p_task_priority);
    wsh_debug_sv.log(l_module_name,'p_actual_departure_date',
                     p_actual_departure_date);
    -- X-dock
    WSH_DEBUG_SV.log(l_module_name,'p_allocation_method',p_allocation_method);
    WSH_DEBUG_SV.log(l_module_name,'p_crossdock_criteria_id',p_crossdock_criteria_id);
    WSH_DEBUG_SV.log(l_module_name,'p_client_Id',p_client_Id);    --Modified R12.1.1 LSP PROJECT
  END IF;
  --
  OPEN C;
  FETCH C INTO Recinfo;
  --
  if (C%NOTFOUND) then
    --
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
    --
  end if;
  --
  IF C%ISOPEN THEN
    CLOSE C;
  END IF;
  --
  if (

         (Recinfo.batch_id =  P_Batch_Id)
       AND (Recinfo.name =  P_Name)
       AND (Recinfo.backorders_only_flag =  P_Backorders_Only_Flag)
       AND (   (Recinfo.Document_Set_Id =  P_Document_Set_Id)
        OR (  (Recinfo.Document_Set_Id IS NULL)
          AND (P_Document_Set_Id IS NULL)))
       AND (   (Recinfo.existing_rsvs_only_flag =  P_Existing_Rsvs_Only_Flag)
        OR (  (Recinfo.existing_rsvs_only_flag IS NULL)
          AND (P_Existing_Rsvs_Only_Flag IS NULL)))
       AND (   (Recinfo.shipment_priority_code =  P_Shipment_Priority_Code)
        OR (  (Recinfo.shipment_priority_code IS NULL)
          AND (P_Shipment_Priority_Code IS NULL)))
       AND (   (Recinfo.ship_method_code =  P_Ship_Method_Code)
        OR (  (Recinfo.ship_method_code IS NULL)
          AND (P_Ship_Method_Code IS NULL)))
       AND (   (Recinfo.customer_id =  P_Customer_Id)
        OR (  (Recinfo.customer_id IS NULL)
          AND (P_Customer_Id IS NULL)))
	AND (   (Recinfo.client_id =  P_Client_Id) --Modified R12.1.1 LSP PROJECT
        OR (  (Recinfo.client_id IS NULL)
          AND (P_client_id IS NULL)))                --Modified R12.1.1 LSP PROJECT
       AND (   (Recinfo.Order_Header_Id =  P_Order_Header_Id)
        OR (  (Recinfo.Order_Header_Id IS NULL)
          AND (P_Order_Header_Id IS NULL)))
       AND (   (Recinfo.ship_set_number =  P_Ship_Set_Number)
        OR (  (Recinfo.ship_set_number IS NULL)
          AND (P_Ship_Set_Number IS NULL)))
       AND (   (Recinfo.inventory_item_id =  P_Inventory_Item_Id)
        OR (  (Recinfo.inventory_item_id IS NULL)
          AND (P_Inventory_Item_Id IS NULL)))
       AND (   (Recinfo.order_type_id =  P_Order_Type_Id)
        OR (  (Recinfo.order_type_id IS NULL)
          AND (P_Order_Type_Id IS NULL)))
       /* rlanka : Pack J Enhancement */
       AND ((to_date(Recinfo.from_requested_date, 'DD/MM/YYYY HH24:MI:SS') = to_date(P_From_Requested_Date, 'DD/MM/YYYY HH24:MI:SS'))
        OR (Recinfo.from_requested_date IS NULL AND P_From_Requested_Date IS NULL))
       AND ((to_date(Recinfo.to_requested_date, 'DD/MM/YYYY HH24:MI:SS') =  to_date(P_To_Requested_Date, 'DD/MM/YYYY HH24:MI:SS'))
        OR (Recinfo.to_requested_date IS NULL AND P_To_Requested_Date IS NULL))
       AND ((to_date(Recinfo.from_scheduled_ship_date, 'DD/MM/YYYY HH24:MI:SS') =  to_date(P_From_Scheduled_Ship_Date, 'DD/MM/YYYY HH24:MI:SS'))
        OR (Recinfo.from_scheduled_ship_date IS NULL AND P_From_Scheduled_Ship_Date IS NULL))
       AND ((to_date(Recinfo.to_scheduled_ship_date, 'DD/MM/YYYY HH24:MI:SS') =  to_date(P_To_Scheduled_Ship_Date, 'DD/MM/YYYY HH24:MI:SS'))
        OR (Recinfo.to_scheduled_ship_date IS NULL AND P_To_Scheduled_Ship_Date IS NULL))
       AND (   (Recinfo.ship_to_location_id =  P_Ship_To_Location_Id)
        OR (  (Recinfo.ship_to_location_id IS NULL)
          AND (P_Ship_To_Location_Id IS NULL)))
       AND (   (Recinfo.ship_from_location_id =  P_Ship_From_Location_Id)
        OR (  (Recinfo.ship_from_location_id IS NULL)
          AND (P_Ship_From_Location_Id IS NULL)))
       AND (   (Recinfo.trip_id =  P_Trip_Id)
        OR (  (Recinfo.trip_id IS NULL)
          AND (P_Trip_Id IS NULL)))
       AND (   (Recinfo.delivery_id =  P_Delivery_Id)
        OR (  (Recinfo.delivery_id IS NULL)
          AND (P_Delivery_Id IS NULL)))
       AND (   (Recinfo.include_planned_lines =  P_Include_Planned_Lines)
        OR (  (Recinfo.include_planned_lines IS NULL)
          AND (P_Include_Planned_Lines IS NULL)))
       AND (   (Recinfo.pick_grouping_rule_id =  P_Pick_Grouping_Rule_Id)
        OR (  (Recinfo.pick_grouping_rule_id IS NULL)
          AND (P_Pick_Grouping_Rule_Id IS NULL)))
       AND (   (Recinfo.pick_sequence_rule_id =  P_Pick_Sequence_Rule_Id)
        OR (  (Recinfo.pick_sequence_rule_id IS NULL)
          AND (P_Pick_Sequence_Rule_Id IS NULL)))
       /* rlanka : incorrect comparison was here */
       AND (   (Recinfo.autocreate_delivery_flag =  P_Autocreate_Delivery_Flag)
        OR (Recinfo.autocreate_delivery_flag IS NULL AND P_Autocreate_Delivery_Flag IS NULL))
       AND (   (Recinfo.attribute_category =  P_Attribute_Category)
        OR (  (Recinfo.attribute_category IS NULL)
          AND (P_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 =  P_Attribute1)
        OR (  (Recinfo.attribute1 IS NULL)
          AND (P_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 =  P_Attribute2)
        OR (  (Recinfo.attribute2 IS NULL)
          AND (P_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 =  P_Attribute3)
        OR (  (Recinfo.attribute3 IS NULL)
          AND (P_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 =  P_Attribute4)
        OR (  (Recinfo.attribute4 IS NULL)
          AND (P_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 =  P_Attribute5)
        OR (  (Recinfo.attribute5 IS NULL)
          AND (P_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 =  P_Attribute6)
        OR (  (Recinfo.attribute6 IS NULL)
          AND (P_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 =  P_Attribute7)
        OR (  (Recinfo.attribute7 IS NULL)
          AND (P_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 =  P_Attribute8)
        OR (  (Recinfo.attribute8 IS NULL)
          AND (P_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 =  P_Attribute9)
        OR (  (Recinfo.attribute9 IS NULL)
          AND (P_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 =  P_Attribute10)
        OR (  (Recinfo.attribute10 IS NULL)
          AND (P_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 =  P_Attribute11)
        OR (  (Recinfo.attribute11 IS NULL)
          AND (P_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 =  P_Attribute12)
        OR (  (Recinfo.attribute12 IS NULL)
          AND (P_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 =  P_Attribute13)
        OR (  (Recinfo.attribute13 IS NULL)
          AND (P_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 =  P_Attribute14)
        OR (  (Recinfo.attribute14 IS NULL)
          AND (P_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 =  P_Attribute15)
        OR (  (Recinfo.attribute15 IS NULL)
          AND (P_Attribute15 IS NULL)))
       AND (   (Recinfo.autodetail_pr_flag =  P_Autodetail_Pr_Flag)
        OR (  (Recinfo.autodetail_pr_flag IS NULL)
          AND (P_Autodetail_Pr_Flag IS NULL)))
       AND (   (Recinfo.carrier_id =  P_Carrier_Id)
        OR (  (Recinfo.carrier_id IS NULL)
          AND (P_Carrier_Id IS NULL)))
       AND (   (Recinfo.trip_stop_id =  P_Trip_Stop_Id)
        OR (  (Recinfo.trip_stop_id IS NULL)
          AND (P_Trip_Stop_Id IS NULL)))
       AND (   (Recinfo.default_stage_subinventory =  P_Default_Stage_Subinventory)
        OR (  (Recinfo.default_stage_subinventory IS NULL)
          AND (P_Default_Stage_Subinventory IS NULL)))
       AND (   (Recinfo.default_stage_locator_id =  P_Default_Stage_Locator_Id)
        OR (  (Recinfo.default_stage_locator_id IS NULL)
          AND (P_Default_Stage_Locator_Id IS NULL)))
       AND (   (Recinfo.pick_from_subinventory =  P_Pick_From_Subinventory)
        OR (  (Recinfo.pick_from_subinventory IS NULL)
          AND (P_Pick_From_Subinventory IS NULL)))
       AND (   (Recinfo.pick_from_locator_id =  P_Pick_From_Locator_Id)
        OR (  (Recinfo.pick_from_locator_id IS NULL)
          AND (P_Pick_From_Locator_Id IS NULL)))
       AND (   (Recinfo.auto_pick_confirm_flag =  P_Auto_Pick_Confirm_Flag)
        OR (  (Recinfo.auto_pick_confirm_flag IS NULL)
          AND (P_Auto_Pick_Confirm_Flag IS NULL)))
       AND (   (Recinfo.delivery_detail_id =  P_delivery_detail_id)
        OR (  (Recinfo.delivery_detail_id IS NULL)
          AND (P_delivery_detail_id IS NULL)))
       AND (   (Recinfo.project_id =  P_project_id)
        OR (  (Recinfo.project_id IS NULL)
          AND (P_project_id IS NULL)))
       AND (   (Recinfo.task_id =  P_task_id)
        OR (  (Recinfo.task_id IS NULL)
          AND (P_task_id IS NULL)))
       AND (   (Recinfo.ship_confirm_rule_id =  P_ship_confirm_rule_id)
        OR (  (Recinfo.ship_confirm_rule_id IS NULL)
          AND (P_ship_confirm_rule_id IS NULL)))
       AND (   (Recinfo.autopack_flag =  P_autopack_flag)
        OR (  (Recinfo.autopack_flag IS NULL)
          AND (P_autopack_flag IS NULL)))
       AND (   (Recinfo.autopack_level =  P_autopack_level)
        OR (  (Recinfo.autopack_level IS NULL)
          AND (P_autopack_level IS NULL)))
       AND (   (Recinfo.task_planning_flag =  P_task_planning_flag)
        OR (  (Recinfo.task_planning_flag IS NULL)
          AND (P_task_planning_flag IS NULL)))
          --bug# 6689448 (replenishment project)
      AND (   (Recinfo.dynamic_replenishment_flag =  P_dynamic_replenishment_flag)
        OR (  (Recinfo.dynamic_replenishment_flag IS NULL)
          AND (P_dynamic_replenishment_flag IS NULL)))
      /* rlanka : Pack J Enhancement */
      AND ((Recinfo.zone_id = p_zoneID)
          OR (Recinfo.zone_id IS NULL AND p_ZoneID is NULL))
      AND ((Recinfo.region_id = p_regionID)
          OR (Recinfo.region_id IS NULL AND p_regionID is NULL))
      AND ((Recinfo.category_id = p_categoryID)
          OR (Recinfo.category_id IS NULL AND p_categoryID is NULL))
      AND ((Recinfo.category_set_id = p_categorySetID)
          OR (Recinfo.category_set_id IS NULL AND p_categorySetID is NULL))
      AND ((Recinfo.rel_subinventory = p_relsubinventory)
          OR (Recinfo.rel_subinventory IS NULL AND p_relsubinventory is NULL))
      AND ((Recinfo.ac_delivery_criteria = p_acDelivcriteria)
          OR (Recinfo.ac_delivery_criteria IS NULL AND p_acDelivcriteria is NULL))
      AND ((Recinfo.append_flag = p_append_flag)
          OR (Recinfo.append_flag IS NULL AND p_append_flag is NULL))
      -- X-dock - allocation_method and crossdock_criteria_id
      AND ((Recinfo.allocation_method = p_allocation_method)
          OR (Recinfo.allocation_method IS NULL AND p_allocation_method is NULL))
      AND ((Recinfo.crossdock_criteria_id = p_crossdock_criteria_id)
          OR (Recinfo.crossdock_criteria_id IS NULL AND p_crossdock_criteria_id is NULL))
      -- end of X-dock change
      AND ((Recinfo.task_priority = p_task_priority)
          OR (Recinfo.task_priority IS NULL AND p_task_priority is NULL))             AND ((to_date(Recinfo.actual_departure_date, 'DD/MM/YYYY HH24:MI:SS') =
            to_date(p_actual_departure_date, 'DD/MM/YYYY HH24:MI:SS'))
          OR (Recinfo.actual_departure_date IS NULL AND
              p_actual_departure_date IS NULL)))
 then
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'RETURN');
    END IF;
    --
    return;
  else
    --
    IF l_debug_on THEN
     wsh_debug_sv.pop(l_module_name, 'FORM_RECORD_CHANGED');
    END IF;
    --
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
    --
  end if;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid              IN OUT NOCOPY  VARCHAR2,
             P_Batch_Id            NUMBER,
             P_Last_Update_Date        DATE,
             P_Last_Updated_By        NUMBER,
             P_Last_Update_Login        NUMBER,
             P_Name              VARCHAR2,
             P_Backorders_Only_Flag      VARCHAR2,
             P_Document_Set_Id        NUMBER,
             P_Existing_Rsvs_Only_Flag    VARCHAR2,
             P_Shipment_Priority_Code    VARCHAR2,
             P_Ship_Method_Code        VARCHAR2,
             P_Customer_Id          NUMBER,
             P_Order_Header_Id        NUMBER,
             P_Ship_Set_Number        NUMBER,
             P_Inventory_Item_Id        NUMBER,
             P_Order_Type_Id          NUMBER,
             P_From_Requested_Date      DATE,
             P_To_Requested_Date        DATE,
             P_From_Scheduled_Ship_Date    DATE,
             P_To_Scheduled_Ship_Date    DATE,
             P_Ship_To_Location_Id      NUMBER,
             P_Ship_From_Location_Id      NUMBER,
             P_Attribute_Category      VARCHAR2,
             P_Attribute1          VARCHAR2,
             P_Attribute2          VARCHAR2,
             P_Attribute3          VARCHAR2,
             P_Attribute4          VARCHAR2,
             P_Attribute5          VARCHAR2,
             P_Attribute6          VARCHAR2,
             P_Attribute7          VARCHAR2,
             P_Attribute8          VARCHAR2,
             P_Attribute9          VARCHAR2,
             P_Attribute10          VARCHAR2,
             P_Attribute11          VARCHAR2,
             P_Attribute12          VARCHAR2,
             P_Attribute13          VARCHAR2,
             P_Attribute14          VARCHAR2,
             P_Attribute15          VARCHAR2,
             P_Autodetail_Pr_Flag      VARCHAR2,
             P_Carrier_Id          NUMBER,
             P_Trip_Stop_Id          NUMBER,
             P_Default_Stage_Subinventory  VARCHAR2,
             P_Default_Stage_Locator_Id    NUMBER,
             P_Pick_From_Subinventory    VARCHAR2,
             P_Pick_From_locator_Id      NUMBER,
             P_Auto_Pick_Confirm_Flag    VARCHAR2,
             P_Delivery_Detail_Id     NUMBER,
             P_Project_Id          NUMBER,
             P_Task_Id            NUMBER,
             P_Organization_Id    NUMBER,
             P_Ship_Confirm_Rule_Id      NUMBER,
             P_Autopack_Flag          VARCHAR2,
             P_Autopack_Level        NUMBER,
             P_Task_Planning_Flag      VARCHAR2,
             P_Dynamic_replenishment_Flag      VARCHAR2 DEFAULT NULL, --bug# 6689448 (replenishment project)
             P_non_picking_flag      VARCHAR2,
             p_regionID		     NUMBER,
             p_zoneId		     NUMBER,
             p_categoryID	     NUMBER,
             p_categorySetID	     NUMBER,
             p_acDelivCriteria	     VARCHAR2,
	     p_RelSubinventory	     VARCHAR2,
	     p_append_flag           VARCHAR2,
             p_task_priority         NUMBER,
             p_actual_departure_date DATE,
             p_allocation_method     VARCHAR2 , -- X-dock
             p_crossdock_criteria_id NUMBER,  --  X-dock
		p_client_Id             NUMBER DEFAULT NULL --Modified R12.1.1 LSP PROJECT
  ) IS
  --
  userid  NUMBER;
  loginid NUMBER;
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
    WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
    WSH_DEBUG_SV.log(l_module_name,'P_NAME',P_NAME);
    WSH_DEBUG_SV.log(l_module_name,'P_BACKORDERS_ONLY_FLAG',P_BACKORDERS_ONLY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SET_ID',P_DOCUMENT_SET_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_EXISTING_RSVS_ONLY_FLAG',P_EXISTING_RSVS_ONLY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_PRIORITY_CODE',P_SHIPMENT_PRIORITY_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_NUMBER',P_SHIP_SET_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE_ID',P_ORDER_TYPE_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_FROM_REQUESTED_DATE',P_FROM_REQUESTED_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_TO_REQUESTED_DATE',P_TO_REQUESTED_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_FROM_SCHEDULED_SHIP_DATE',P_FROM_SCHEDULED_SHIP_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_TO_SCHEDULED_SHIP_DATE',P_TO_SCHEDULED_SHIP_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_SHIP_TO_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOCATION_ID',P_SHIP_FROM_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
    WSH_DEBUG_SV.log(l_module_name,'P_AUTODETAIL_PR_FLAG',P_AUTODETAIL_PR_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_CARRIER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_SUBINVENTORY',P_DEFAULT_STAGE_SUBINVENTORY);
    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_LOCATOR_ID',P_DEFAULT_STAGE_LOCATOR_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_SUBINVENTORY',P_PICK_FROM_SUBINVENTORY);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_LOCATOR_ID',P_PICK_FROM_LOCATOR_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_AUTO_PICK_CONFIRM_FLAG',P_AUTO_PICK_CONFIRM_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_PROJECT_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_TASK_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_TASK_PLANNING_FLAG',P_TASK_PLANNING_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_dynamic_replenishment_flag',P_dynamic_replenishment_flag); --bug# 6689448 (replenishment project)
    WSH_DEBUG_SV.log(l_module_name,'P_non_picking_flag',P_non_picking_flag);
    -- rlanka : Pack J Enhancement
    wsh_debug_Sv.log(l_module_name,'p_RegionID', p_regionID);
    wsh_debug_sv.log(l_module_name,'p_zoneID',p_zoneID);
    wsh_debug_sv.log(l_module_name,'p_categoryID',p_categoryID);
    wsh_debug_sv.log(l_module_name,'p_categorySetID',p_categorySetID);
    wsh_debug_sv.log(l_module_name,'p_acDelivCriteria',p_acDelivCriteria);
    wsh_debug_sv.log(l_module_name,'p_RelSubinventory', p_RelSubinventory);
    wsh_debug_sv.log(l_module_name,'p_append_flag', p_append_flag);
    wsh_debug_sv.log(l_module_name,'p_task_priority', p_task_priority);
    wsh_debug_sv.log(l_module_name,'p_actual_departure_date',
                     p_actual_departure_date);
    -- X-dock
    WSH_DEBUG_SV.log(l_module_name,'p_allocation_method',p_allocation_method);
    WSH_DEBUG_SV.log(l_module_name,'p_crossdock_criteria_id',p_crossdock_criteria_id);
    WSH_DEBUG_SV.log(l_module_name,'p_client_Id',p_client_Id);    --Modified R12.1.1 LSP PROJECT
    --
  END IF;
  --
  userid  := FND_GLOBAL.USER_ID;
  loginid := FND_GLOBAL.LOGIN_ID;
  --
  UPDATE WSH_PICKING_BATCHES
  SET
     batch_id           	=  P_Batch_Id,
     last_update_date       	=  SYSDATE,
     last_updated_by         	=  userid,
     last_update_login         	=  loginid,
     name             		=  P_Name,
     backorders_only_flag     	=  P_Backorders_Only_Flag,
     Document_Set_Id         	=  P_Document_Set_Id,
     existing_rsvs_only_flag    =  P_Existing_Rsvs_Only_Flag,
     shipment_priority_code     =  P_Shipment_Priority_Code,
     ship_method_code       	=  P_Ship_Method_Code,
     customer_id           	=  P_Customer_Id,
     order_Header_Id         	=  P_Order_Header_Id,
     ship_set_number         	=  P_Ship_Set_Number,
     inventory_item_id         	=  P_Inventory_Item_Id,
     order_type_id           	=  P_Order_Type_Id,
     from_requested_date       	=  P_From_Requested_Date,
     to_requested_date         	=  P_To_Requested_Date,
     from_scheduled_ship_date   =  P_From_Scheduled_Ship_Date,
     to_scheduled_ship_date     =  P_To_Scheduled_Ship_Date,
     ship_to_location_id       	=  P_Ship_To_Location_Id,
     ship_from_location_id      =  P_Ship_From_Location_Id,
     attribute_category       	=  P_Attribute_Category,
     attribute1           	=  P_Attribute1,
     attribute2           	=  P_Attribute2,
     attribute3           	=  P_Attribute3,
     attribute4           	=  P_Attribute4,
     attribute5           	=  P_Attribute5,
     attribute6           	=  P_Attribute6,
     attribute7           	=  P_Attribute7,
     attribute8           	=  P_Attribute8,
     attribute9           	=  P_Attribute9,
     attribute10           	=  P_Attribute10,
     attribute11           	=  P_Attribute11,
     attribute12           	=  P_Attribute12,
     attribute13           	=  P_Attribute13,
     attribute14           	=  P_Attribute14,
     attribute15           	=  P_Attribute15,
     autodetail_pr_flag       	=  P_Autodetail_Pr_Flag,
     carrier_id           	=  P_Carrier_Id,
     trip_stop_id         	=  P_Trip_Stop_Id,
     default_stage_subinventory =  P_Default_Stage_Subinventory,
     default_stage_locator_id   =  P_Default_Stage_Locator_Id,
     pick_from_subinventory     =  P_Pick_From_Subinventory,
     pick_from_locator_id     	=  P_Pick_From_locator_Id,
     auto_pick_confirm_flag     =  P_Auto_Pick_Confirm_Flag,
     project_id           	=  P_Project_Id,
     task_id             	=  P_Task_Id,
     delivery_detail_id       	=  P_Delivery_Detail_Id,
     ship_confirm_rule_id     	=  P_Ship_Confirm_Rule_Id,
     Autopack_Flag           	=  P_Autopack_Flag,
     autopack_level         	=  P_Autopack_Level,
     task_planning_flag       	=  P_Task_Planning_Flag,
     dynamic_replenishment_flag =  P_dynamic_replenishment_flag, --bug# 6689448 (replenishment project)
     non_picking_flag       	=  P_non_picking_flag,
     region_id			=  p_regionID,
     zone_id                    =  p_zoneID,
     category_id                =  p_categoryID,
     category_set_id            =  p_categorySetID,
     ac_Delivery_criteria       =  p_acDelivcriteria,
     rel_subinventory           =  p_relsubinventory,
     append_flag                =  p_append_flag,
     task_priority              =  p_task_priority,
     actual_departure_date      =  p_actual_departure_date,
     allocation_method          =  nvl(p_allocation_method,'I'), -- X-dock
     crossdock_criteria_id      =  p_crossdock_criteria_id, --  X-dock
     client_id                  =  p_client_Id    --Modified R12.1.1 LSP PROJECT
  WHERE rowid = X_Rowid;
  --
  if (SQL%NOTFOUND) then
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'NO_DATA_FOUND');
    END IF;
    --
    Raise NO_DATA_FOUND;
    --
  end if;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  END Update_Row;



  PROCEDURE Delete_Row(X_Rowid IN OUT NOCOPY  VARCHAR2) IS
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
  END IF;
  --
  DELETE FROM WSH_PICKING_BATCHES
  WHERE rowid = X_Rowid;
  --
  if (SQL%NOTFOUND) then
    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'NO_DATA_FOUND');
    END IF;
    Raise NO_DATA_FOUND;
  end if;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  END Delete_Row;


  FUNCTION Submit_Release_Request(P_Batch_Id NUMBER,
                                  P_Log_Level NUMBER ,
                                  P_Num_Workers NUMBER ,
                                  P_Commit    VARCHAR2 ) RETURN NUMBER IS -- log level fix

 -- Bug # 2231365 : Defaulted the parameter p_log_level to 0

  request_id NUMBER;
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SUBMIT_RELEASE_REQUEST';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
    WSH_DEBUG_SV.log(l_module_name,'P_NUM_WORKERS',P_NUM_WORKERS);
    WSH_DEBUG_SV.log(l_module_name,'P_Commit',P_Commit);
    --
  END IF;
  --
  request_id := FND_REQUEST.Submit_Request('WSH', 'WSHPSGL','','',FALSE,
          P_Batch_Id, P_Log_Level, P_Num_Workers);  -- log level fix

  IF NVL(P_Commit, 'Y') <> 'N' THEN -- we commit by default
    --
    if (request_id > 0) then
      COMMIT WORK;
    end if;
    --
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  return request_id;
  --
  END Submit_Release_Request;



  PROCEDURE Delete_And_Commit(X_Rowid IN OUT NOCOPY  VARCHAR2) IS
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_AND_COMMIT';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
  END IF;
  --
  Delete_Row(X_Rowid);
  COMMIT WORK;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  END Delete_And_Commit;


  PROCEDURE Commit_Work IS
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COMMIT_WORK';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  COMMIT WORK;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  END Commit_Work;



  PROCEDURE Get_Printer ( p_report IN VARCHAR2,
              x_report_printer OUT NOCOPY  VARCHAR2,
              p_default_report IN VARCHAR2 default 'OEXSHPIK' ) IS
  --
  level_type_id NUMBER;
  app_id    NUMBER;
  respid    NUMBER;
  userid    NUMBER;
  printer    varchar2(32);
  --
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PRINTER';
  --
  BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_REPORT',P_REPORT);
    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_REPORT',P_DEFAULT_REPORT);
    --
  END IF;
  --
  -- get the applications, responsibility, and user ID
  app_id := FND_GLOBAL.RESP_APPL_ID;
  respid := FND_GLOBAL.RESP_ID;
  userid := FND_GLOBAL.USER_ID;

  -- get pick slip printer
/*  SELECT MAX(P.LEVEL_TYPE_ID)
  INTO level_type_id
  FROM WSH_REPORT_PRINTERS P,
     SO_REPORTS R
  WHERE P.REPORT_SET_ID = R.REPORT_ID
  AND   R.NAME =
      NVL(report, default_report)
  AND P.LEVEL_VALUE_ID = DECODE(P.LEVEL_TYPE_ID,
                   10001,0,
                   10002,app_id,
                   10003,respid,
                   10004,userid)
  AND ENABLE_FLAG = 'Y';

  SELECT P.PRINTER_NAME
  INTO printer
  FROM WSH_REPORT_PRINTERS P,
     SO_REPORTS R
  WHERE P.REPORT_ID = R.REPORT_ID
  AND   R.NAME =
      NVL(report, default_report)
  AND P.LEVEL_TYPE_ID = level_type_id
  AND P.LEVEL_VALUE_ID = DECODE(level_type_id,
                   10001,0,
                   10002,app_id,
                   10003,respid,
                   10004,userid);
*/
  x_report_printer := printer;

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    WHEN OTHERS THEN
     x_report_printer := NULL;
     --
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
  END get_printer;

END WSH_PICKING_BATCHES_PKG;

/
