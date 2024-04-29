--------------------------------------------------------
--  DDL for Package Body WSH_PICKING_BATCHES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PICKING_BATCHES_GRP" AS
/* $Header: WSHPRGPB.pls 120.6.12010000.6 2009/12/03 14:28:41 gbhargav ship $ */

-- Package Variables
--
--===================
-- CONSTANTS
--===================
--
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PICKING_BATCHES_GRP';
-- add your constants here if any

--===================
-- PROCEDURES
--===================
--
--=============================================================================================
-- Start of comments
--
-- API Name          : Create_Batch
-- Type              : Group
-- Pre-reqs          : None.
-- Function          : This API is called  from WSH_PICKING_BATCHES_PUB
--                     to validate all the parameters and create the Picking Batch
--
-- PARAMETERS        : p_api_version_number    known api versionerror buffer
--                     p_init_msg_list         FND_API.G_TRUE to reset list
--                     x_return_status         return status
--                     x_msg_count             number of messages in the list
--                     x_msg_data              text of messages
--                     p_commit                FND_API.G_TRUE to perform a commit
--                     p_rule_id               Picking Rule Id used for defaulting purpose
--	               p_rule_name             Picking Rule name used for defaulting purpose, Ignore it when p_rule_id
--                                             contains value
--                     p_batch_rec             Contains the all the parameters for the batch
--                     p_batch_prefix          Batch prefix to be prefixed to the batch name
--                     x_batch_id              Out parameter contains the batch id created
-- VERSION           : current version         1.0
--                     initial version         1.0
--============================================================================================

PROCEDURE Create_Batch(
	    p_api_version_number     IN	  NUMBER,
	    p_init_msg_list	     IN	  VARCHAR2  DEFAULT NULL,
	    p_commit		     IN	  VARCHAR2  DEFAULT NULL,
	    x_return_status	     OUT  NOCOPY    VARCHAR2,
	    x_msg_count		     OUT  NOCOPY    NUMBER,
	    x_msg_data		     OUT  NOCOPY    VARCHAR2,
	    p_rule_id		     IN	  NUMBER    DEFAULT NULL,
	    p_rule_name		     IN	  VARCHAR2  DEFAULT NULL,
	    p_batch_rec		     IN	  WSH_PICKING_BATCHES_PUB.Batch_Info_Rec,
	    p_batch_prefix	     IN	  VARCHAR2  DEFAULT NULL,
	    x_batch_id		     OUT  NOCOPY    NUMBER) IS



---- cursor to get Picking Rule information for the Given Picking Rule Id
CURSOR	Get_Picking_Rule_Info(v_rule_id IN NUMBER,v_rule_name IN VARCHAR2) IS
SELECT	-- name,
	backorders_only_flag,
	autodetail_pr_flag,
	auto_pick_confirm_flag,
	pick_sequence_rule_id,
	pick_grouping_rule_id,
	include_planned_lines,
	organization_id,
	customer_id,
	from_requested_date,
	to_requested_date,
	existing_rsvs_only_flag,
	order_header_id,
	inventory_item_id,
	order_type_id,
	from_scheduled_ship_date,
	to_scheduled_ship_date,
	shipment_priority_code,
	ship_method_code,
	ship_set_number,
	ship_to_location_id,
	default_stage_subinventory,
	default_stage_locator_id,
	pick_from_subinventory,
	pick_from_locator_id,
	task_id,
	project_id,
	ship_from_location_id,
	autocreate_delivery_flag,
	ship_confirm_rule_id,
	autopack_flag,
	autopack_level,
	document_set_id,
	task_planning_flag,
        ac_delivery_criteria,
        append_flag,
        task_priority,
        nvl(allocation_method,'I'), -- X-dock
        crossdock_criteria_id, -- X-dock
        dynamic_replenishment_flag, --bug# 6689448 (replenishment project)
        rel_subinventory, --Bug8221008
        client_id -- LSP PROJECT
FROM	wsh_picking_rules
WHERE	picking_rule_id	= nvl(v_rule_id,picking_rule_id)
AND     name = nvl(v_rule_name,name)
AND trunc(sysdate) BETWEEN nvl(start_date_active,trunc(sysdate)) AND nvl(end_date_active,trunc(sysdate) + 1);


CURSOR Get_Order_Type_id(p_type_id IN NUMBER ,p_type_name IN VARCHAR2) IS
SELECT transaction_type_id
FROM   oe_transaction_types_tl
WHERE  p_type_id IS NOT NULL
AND    transaction_type_id = p_type_id
UNION All
SELECT transaction_type_id
FROM   oe_transaction_types_tl
WHERE  p_type_id IS NULL
AND    name = p_type_name;


CURSOR Get_order_header_id(p_order_number IN NUMBER ,p_order_type_id IN	NUMBER,p_header_id IN NUMBER) IS
SELECT	 header_id
FROM	oe_order_headers_all
WHERE  p_header_id IS NOT NULL
AND    header_id = p_header_id
UNION ALL
SELECT	 header_id
FROM	oe_order_headers_all
WHERE  p_header_id IS NULL
AND     order_number = p_order_number
AND     order_type_id = p_order_type_id;

CURSOR  Get_Ship_Set_Id(p_ship_set_id IN NUMBER, p_ship_set_number IN VARCHAR2, p_header_id IN NUMBER) IS
SELECT  set_id
FROM    OE_SETS
WHERE   p_ship_set_id IS NOT NULL
AND     set_id =  p_ship_set_id
UNION ALL
SELECT  set_id
FROM    OE_SETS
WHERE   p_ship_set_id IS NULL
AND     header_id = p_header_id
AND     set_name =  p_ship_set_number
AND     set_type =  'SHIP_SET';

CURSOR Check_Delivery_Detail_Id(p_delivery_detail_id IN NUMBER) IS
SELECT delivery_detail_id
FROM   wsh_delivery_details
WHERE  delivery_detail_id = p_delivery_detail_id
AND container_flag IN ('N','Y'); -- R12 MDC

CURSOR  Check_Item_Id( p_item_id IN NUMBER,p_organization_id IN NUMBER) IS
SELECT  inventory_item_id
FROM    mtl_system_items
WHERE   inventory_item_id = p_item_id
AND     organization_id = nvl(p_organization_id,organization_id)
AND     rownum = 1;

CURSOR  Check_Subinventory( p_subinventory_name IN VARCHAR2,p_organization_id IN NUMBER) IS
SELECT  secondary_inventory_name
FROM    mtl_subinventories_trk_val_v
WHERE   secondary_inventory_name = p_subinventory_name
AND     organization_id = p_organization_id;

CURSOR  Check_Locator_Id ( p_Locator_Id IN VARCHAR2, p_subinventory IN VARCHAR2, p_organization_id IN NUMBER) IS
SELECT  Inventory_location_id
FROM    mtl_item_locations
WHERE   Inventory_location_id = p_Locator_Id
AND     subinventory_code = p_subinventory
AND     organization_id   = p_organization_id;

CURSOR  Check_Category_Set_Id( p_category_set_id  IN NUMBER) IS
SELECT  category_set_id
FROM    mtl_category_sets
WHERE   category_set_id = p_category_set_id
AND     rownum = 1;

CURSOR  Check_Category_Id( p_category_id IN NUMBER ) IS
SELECT  category_id
FROM    mtl_item_categories
WHERE   category_id = p_category_id
AND     rownum = 1;

-- Bug 3438300 - Start
cursor c_location_id (p_org_id VARCHAR2) IS
select location_id from wsh_ship_from_orgs_v
where organization_id = p_org_id;

cursor c_org_id (p_location_id NUMBER) IS
select organization_id from wsh_ship_from_orgs_v
where location_id = p_location_id;

-- Bug# 3438300 - End

   --R12 MDC
  CURSOR c_check_consol_dlvy(p_delivery_id IN NUMBER) IS
  SELECT delivery_id
  FROM   wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id
  AND    delivery_type = 'STANDARD';


-- Standard call to check for call compatibility
l_api_version	     CONSTANT NUMBER :=	1.0;
l_api_name	     CONSTANT VARCHAR2(30) := 'WSH_PICKING_BATCHES_GRP';
l_return_status		      VARCHAR2(30) := NULL;
l_msg_count		      NUMBER;
l_msg_data		      VARCHAR2(32767);
l_number_of_errors	      NUMBER :=	0;
l_number_of_warnings	      NUMBER :=	0;
l_debug_on BOOLEAN;

-- Record Variable which holds the input Batch Record
l_batch_in_rec         WSH_PICKING_BATCHES_PUB.Batch_Info_rec;
-- Record Variable which holds final data to be sent to the private API
l_batch_grp_rec        WSH_PICKING_BATCHES_GRP.Batch_Info_rec;

l_rule_id         NUMBER;
l_rule_name       VARCHAR2(60);
l_batch_name_prefix  VARCHAR2(60);
-- bug 3463315 add validation when append_flag = 'Y'
l_param_info              WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

-- Bug 3438300 - Start
l_ship_from_loc_id NUMBER;
l_org_id NUMBER;
-- Bug# 3438300 - End

l_is_WMS_org  VARCHAR2(1); -- Bug# 3480908
--
l_client_name  VARCHAR2(200); -- LSP PROJECT
--
l_module_name CONSTANT VARCHAR2(100) :=	'wsh.plsql.' ||	G_PKG_NAME || '.' || 'CREATE_BATCH';
--

WSH_INVALID_CONSOL_DEL	EXCEPTION;

BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on :=	WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on	IS NULL	 THEN
  --{
     l_debug_on	:= WSH_DEBUG_SV.is_debug_enabled;
  --}
  END IF;
  --
  SAVEPOINT PICKING_BATCH_GRP;

  -- Standard begin of API savepoint
  --
  -- Debug Statements
  --
  IF l_debug_on	THEN
  --{
     wsh_debug_sv.push(l_module_name);
     --
     wsh_debug_sv.LOG(l_module_name, 'P_API_VERSION_NUMBER', p_api_version_number);
     wsh_debug_sv.LOG(l_module_name, 'P_INIT_MSG_LIST',	p_init_msg_list);
     wsh_debug_sv.LOG(l_module_name, 'P_COMMIT', p_commit);
  --}
  END IF;

  IF NOT fnd_api.compatible_api_call(
		 l_api_version,
		 p_api_version_number,
		 l_api_name,
		 g_pkg_name)   THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  -- Check p_init_msg_list
  IF fnd_api.to_boolean(p_init_msg_list) THEN
  --{
      fnd_msg_pub.initialize;
  --}
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_batch_in_rec  := p_batch_rec;
  l_rule_id       := p_rule_id;
  l_rule_name     := p_rule_name;
  l_batch_name_prefix := p_batch_prefix;


  --
  -- Debug Statements
  --
  IF l_debug_on	THEN
  --{
     wsh_debug_sv.log(l_module_name,'PROCESSING THE RULE INFORMATION'|| '    P_RULE_ID : ' || TO_CHAR( l_rule_id ) || '  P_RULE_NAME:  '|| l_rule_name);
  --}
  END IF;
  --
  IF ( l_rule_id is NOT NULL AND l_rule_id <> FND_API.G_MISS_NUM ) OR ( l_rule_name is NOT NULL AND l_rule_name <> FND_API.G_MISS_CHAR ) THEN
  --{ Passed the Values or Not
     IF ( l_rule_id  = FND_API.G_MISS_NUM ) THEN
     --{
          l_rule_id := NULL;
     --}
     END IF;
     IF ( l_rule_name  = FND_API.G_MISS_CHAR ) OR  ( l_rule_id  IS NOT NULL) THEN
     --{
         l_rule_name := NULL;
     --}
     END IF;
     --
     --
     -- Debug	Statements
     --
     IF l_debug_on THEN
     --{
	WSH_DEBUG_SV.logmsg(l_module_name,  'FETCHING PICKING RULE INFO FOR THE GIVEN RULE ID AND RULE NAME'  );
     --}
     END IF;
     --
     -- fetch Picking Rule Information for the given picking Rule Id
     OPEN	Get_Picking_Rule_Info(l_rule_id,l_rule_name);
     FETCH      Get_Picking_Rule_Info
     INTO	l_batch_grp_rec.backorders_only_flag,
	        l_batch_grp_rec.autodetail_pr_flag,
		l_batch_grp_rec.auto_pick_confirm_flag,
		l_batch_grp_rec.pick_sequence_rule_id,
		l_batch_grp_rec.pick_grouping_rule_id,
		l_batch_grp_rec.include_planned_lines,
		l_batch_grp_rec.organization_id,
		l_batch_grp_rec.customer_id,
		l_batch_grp_rec.from_requested_date,
		l_batch_grp_rec.to_requested_date,
		l_batch_grp_rec.existing_rsvs_only_flag,
		l_batch_grp_rec.order_header_id,
		l_batch_grp_rec.inventory_item_id,
		l_batch_grp_rec.order_type_id,
		l_batch_grp_rec.from_scheduled_ship_date,
		l_batch_grp_rec.to_scheduled_ship_date,
		l_batch_grp_rec.shipment_priority_code,
		l_batch_grp_rec.ship_method_code,
		l_batch_grp_rec.ship_set_id,
		l_batch_grp_rec.ship_to_location_id,
		l_batch_grp_rec.Default_Stage_subinventory,
		l_batch_grp_rec.Default_Stage_locator_id,
		l_batch_grp_rec.pick_from_subinventory,
		l_batch_grp_rec.pick_from_locator_id,
		l_batch_grp_rec.task_id,
		l_batch_grp_rec.project_id,
		l_batch_grp_rec.ship_from_location_id,
		l_batch_grp_rec.autocreate_delivery_flag,
		l_batch_grp_rec.ship_confirm_rule_id,
		l_batch_grp_rec.autopack_flag,
		l_batch_grp_rec.autopack_level,
		l_batch_grp_rec.document_set_id,
		l_batch_grp_rec.task_planning_flag,
		l_batch_grp_rec.ac_delivery_criteria,
		l_batch_grp_rec.append_flag,
                l_batch_grp_rec.task_priority,
                l_batch_grp_rec.allocation_method,  --X-dock
                l_batch_grp_rec.crossdock_criteria_id,  --X-dock
                l_batch_grp_rec.dynamic_replenishment_flag, --bug# 6689448 (replenishment project)
                l_batch_grp_rec.rel_subinventory, --Bug8221008
                l_batch_grp_rec.client_id; -- LSP PROJECT
     -- If rule info provided is not exist raise error
     IF Get_Picking_Rule_Info%NOTFOUND THEN
     --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
	--{
	   WSH_DEBUG_SV.logmsg(l_module_name,  'P_RULE_ID : ' || TO_CHAR( p_rule_id ) || 'P_RULE_NAME:  '|| p_rule_name || '	DOES NOT EXIST.');
        --}
	END IF;
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PICKING_RULE');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	CLOSE Get_Picking_Rule_Info;
	IF l_debug_on THEN
	--{
  	   WSH_DEBUG_SV.pop(l_module_name);
	--}
	END IF;
	--
	return;
     --}
     END IF;
     CLOSE Get_Picking_Rule_Info;
   --} End of Pick Rule Checking
  END IF;


------------------------------------------------------------------------------------------------------------
-- VALIDATE ALL	THE INPUT PARAMETER VALUES
-- LOGIC followed
--   If Parameter value is NULL then treat it as NOT PASSED to the API
--    (*** In this case consider the value from the picking rule info if picking rule info provided)
--   If the parameter value is FND_API.G_MISS.xxx then treat it as NULL
--   Otherwise Validate the parameter value.
------------------------------------------------------------------------------------------------------------

-- Validating the Back Order Only Flag
  IF ( l_batch_in_rec.Backorders_Only_Flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Backorders_Only_Flag <> FND_API.G_MISS_CHAR ) THEN
     --{ Checking value is null or not
         -- BUG # 6719369 (Rplenishment project); Need to consider the
         --          'replenishment completed' status.
         IF ( l_batch_in_rec.Backorders_Only_Flag  NOT IN ('I','E','O','M') ) THEN
	 --{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','BACKORDERS_ONLY_FLAG ');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
         --}
	 END IF;
	 l_batch_grp_rec.Backorders_Only_Flag := l_batch_in_rec.Backorders_Only_Flag ;
     ELSE
        l_batch_grp_rec.Backorders_Only_Flag := NULL;
     --}
     END IF;
  --}
  END IF;

-- End of Validating the Back Order Only Flag
--
-- LSP PROJECT : begin
---  Cleint Validations

  IF (WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L') THEN
  --{
      IF ( ( l_batch_in_rec.client_Id IS NOT NULL ) OR ( l_batch_in_rec.client_code IS NOT NULL )) THEN
      --{ Passed the Values or Not
          IF  l_batch_in_rec.client_Id = FND_API.G_MISS_NUM  THEN
          --{
              l_batch_in_rec.client_Id := NULL;
          --}
          END IF;
          IF  l_batch_in_rec.client_code =  FND_API.G_MISS_CHAR  THEN
          --{
              l_batch_in_rec.client_code := NULL;
          --}
          END IF;
          IF ( ( l_batch_in_rec.client_Id IS NOT NULL) OR ( l_batch_in_rec.client_code IS NOT NULL) ) THEN
          --{
	          IF l_debug_on THEN
	              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_DEPLOY.GET_CLIENT_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              wms_deploy.get_client_details(
                  x_client_id	   => l_batch_in_rec.client_Id,
                  x_client_code	   => l_batch_in_rec.client_code,
                  x_client_name    => l_client_name,
                  x_return_status  => l_return_status);
              IF l_debug_on THEN
	              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              wsh_util_core.api_post_call(
                  p_return_status => l_return_status,
                  x_num_warnings  => l_number_of_warnings,
                  x_num_errors    => l_number_of_errors,
                  p_msg_data      => l_msg_data);
              l_batch_grp_rec.client_Id :=  l_batch_in_rec.client_Id;
          ELSE
              l_batch_grp_rec.client_Id := NULL;
          --}
          END IF;
      --} Passed the Values or Not
      END IF;
  ELSE
      l_batch_grp_rec.client_Id := NULL;
  --}
  END IF;
-- End of Client Validations
-- LSP PROJECT : end
--
--- Organization Validations
  IF ( ( l_batch_in_rec.Organization_Id IS NOT NULL ) OR ( l_batch_in_rec.Organization_Code IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Organization_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Organization_Id := NULL;
     --}
     END IF;

     IF ( l_batch_in_rec.Organization_Code =  FND_API.G_MISS_CHAR ) THEN
     --{
         l_batch_in_rec.Organization_Code := NULL;
     --}
     END IF;

     IF ( ( l_batch_in_rec.Organization_Id IS NOT NULL ) OR ( l_batch_in_rec.Organization_Code IS NOT NULL ) ) THEN
     --{

	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_ORG',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        WSH_UTIL_VALIDATE.Validate_Org(
	      p_Org_id	       => l_batch_in_rec.Organization_Id,
	      p_Org_Code       => l_batch_in_rec.Organization_Code,
	      x_return_status  => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	l_batch_grp_rec.Organization_Id :=l_batch_in_rec.Organization_Id;

	-- Bug# 3480908 - start - Checking whether the org is a WMS org
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.Check_Wms_Org',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        l_is_WMS_org := WSH_UTIL_VALIDATE.Check_Wms_Org(
	      p_organization_id	       => l_batch_grp_rec.Organization_Id);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	-- Bug# 3480908 - End

     ELSE
        l_batch_grp_rec.Organization_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

--  End of Organization Validations

--- Document Set Validations

  IF ( ( l_batch_in_rec.Document_Set_Id IS NOT NULL ) OR ( l_batch_in_rec.Document_Set_Name IS NOT NULL )) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Document_Set_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Document_Set_id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Document_Set_Name  =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.Document_Set_name := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Document_Set_Id IS NOT NULL) OR ( l_batch_in_rec.Document_Set_name IS NOT NULL) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_REPORT_SET',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        WSH_UTIL_VALIDATE.Validate_Report_Set(
	     p_report_set_id	=> l_batch_in_rec.Document_Set_Id,
	     p_report_set_name	=> l_batch_in_rec.Document_Set_name,
	     x_return_status	=> l_return_status);

	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
            l_batch_grp_rec.Document_Set_Id := l_batch_in_rec.Document_Set_Id;
     ELSE
        l_batch_grp_rec.Document_Set_Id := NULL;
     --}
     END IF;
   --} Passed the Values or Not
  END IF;

-- End of Document Set Validations

-- Ship Method  Validations

  IF ( ( l_batch_in_rec.Ship_Method_Code IS NOT NULL ) OR ( l_batch_in_rec.Ship_Method_Name IS NOT NULL )) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Ship_Method_Code = FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_in_rec.Ship_Method_Code := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Ship_Method_Name =  FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_in_rec.Ship_Method_Name := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Ship_Method_Code IS NOT NULL) OR ( l_batch_in_rec.Ship_Method_Name IS NOT NULL) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_SHIP_METHOD',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
         WSH_UTIL_VALIDATE.Validate_Ship_Method(
	      p_ship_method_code   => l_batch_in_rec.Ship_Method_Code,
	      p_ship_method_name   => l_batch_in_rec.Ship_Method_Name,
	      x_return_status	   => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        l_batch_grp_rec.ship_Method_Code := l_batch_in_rec.Ship_Method_Code;
     ELSE
        l_batch_grp_rec.ship_Method_Code := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

---  End of Ship Method Validations

---  Customer Validations

  IF ( ( l_batch_in_rec.Customer_Id IS NOT NULL ) OR ( l_batch_in_rec.Customer_Number IS NOT NULL )) THEN
  --{ Passed the Values or Not
     IF  l_batch_in_rec.Customer_Id = FND_API.G_MISS_NUM  THEN
     --{
        l_batch_in_rec.Customer_Id := NULL;
     --}
     END IF;
     IF  l_batch_in_rec.Customer_Number =  FND_API.G_MISS_CHAR  THEN
     --{
        l_batch_in_rec.Customer_Number := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Customer_Id IS NOT NULL) OR ( l_batch_in_rec.Customer_Number IS NOT NULL) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CUSTOMER',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        WSH_UTIL_VALIDATE.Validate_Customer(
	    p_Customer_id	   => l_batch_in_rec.Customer_Id,
	    p_Customer_Number	   => l_batch_in_rec.Customer_Number,
	    x_return_status	   => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        l_batch_grp_rec.Customer_Id :=  l_batch_in_rec.Customer_Id;
     ELSE
        l_batch_grp_rec.Customer_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Customer Validations

-- Order Type Validations

  IF ( ( l_batch_in_rec.Order_Type_Id IS NOT NULL ) OR ( l_batch_in_rec.Order_Type_Name IS NOT NULL )) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Order_Type_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Order_Type_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Order_Type_Name =  FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_in_rec.Order_Type_Name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Order_Type_Id IS NOT NULL ) OR ( l_batch_in_rec.Order_Type_Name IS NOT NULL) )THEN
     --{
        OPEN Get_Order_Type_id(l_batch_in_rec.Order_Type_Id,l_batch_in_rec.Order_Type_Name);
        FETCH Get_Order_Type_id INTO l_batch_in_rec.Order_Type_Id;
        IF ( Get_Order_Type_id%NOTFOUND ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORDER_TYPE');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    CLOSE Get_Order_Type_id;
	    return;
        --}
	END IF;
	CLOSE Get_Order_Type_id;
	l_batch_grp_rec.Order_Type_Id := l_batch_in_rec.Order_Type_Id;
     ELSE
        l_batch_grp_rec.Order_Type_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Order	Type Validations


-- Order Number	Validations

  IF ( ( l_batch_in_rec.order_header_id IS NOT NULL ) OR ( l_batch_in_rec.order_number IS NOT NULL )) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.order_header_id = FND_API.G_MISS_NUM ) THEN
     --{
     	l_batch_in_rec.order_header_id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.order_number =  FND_API.G_MISS_NUM ) OR ( l_batch_in_rec.order_header_id IS NOT NULL ) THEN
     --{
        l_batch_in_rec.order_number := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.order_number IS NOT NULL AND l_batch_grp_rec.order_type_id IS NULL ) THEN
     --{
	 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORDER_NUMBER AND ORDER_TYPE_ID combination');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 return;
     --}
     END IF;
     IF ( ( l_batch_in_rec.order_header_id  IS NOT NULL ) OR  ( l_batch_in_rec.order_number IS NOT NULL AND l_batch_grp_rec.order_type_id IS NOT NULL ) ) THEN
     --{
         OPEN Get_Order_Header_id(l_batch_in_rec.Order_Number,l_batch_grp_rec.Order_Type_id,l_batch_in_rec.order_header_id);
         FETCH Get_Order_Header_id INTO l_batch_in_rec.order_header_id;
         IF ( Get_Order_Header_id%NOTFOUND ) THEN
	 --{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORDER_NUMBER OR ORDER_HEADER_ID');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    CLOSE Get_Order_Header_id;
	    return;
         --}
	 END IF;
	 CLOSE Get_Order_Header_id;
	 l_batch_grp_rec.order_header_id := l_batch_in_rec.order_header_id;
     ELSE
        l_batch_grp_rec.order_header_id := NULL;
     --}
     END IF;
  --}Passed the Values or Not
  END IF;

-- End of Order	Number Validations

-- Ship	Set Number Validations

  IF ( ( l_batch_in_rec.ship_set_id IS NOT NULL ) OR ( l_batch_in_rec.ship_set_number IS NOT NULL )) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.ship_set_id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.ship_set_id := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.ship_set_number =  FND_API.G_MISS_CHAR ) OR ( l_batch_in_rec.ship_set_id IS NOT NULL ) ) THEN
     --{
        l_batch_in_rec.ship_set_number := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.ship_set_number IS NOT NULL AND l_batch_grp_rec.order_header_id IS NULL ) THEN
     --{
	 FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SHIP_SET_NUMBER AND ORDER_HEADER_ID combination');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 wsh_util_core.add_message(x_return_status);
	 return;
     --}
     END IF;
     IF ( ( l_batch_in_rec.ship_set_id  IS NOT NULL ) OR  ( l_batch_in_rec.ship_set_number IS NOT NULL AND l_batch_grp_rec.order_header_id IS NOT NULL ) ) THEN
     --{
         OPEN Get_Ship_Set_Id(l_batch_in_rec.ship_set_id,l_batch_in_rec.ship_set_number,l_batch_grp_rec.order_header_id);
         FETCH Get_Ship_Set_Id INTO l_batch_in_rec.ship_set_id;
         IF ( Get_Ship_Set_Id%NOTFOUND ) THEN
	 --{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SHIP_SET_NUMBER OR SHIP_SET_ID');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    CLOSE  Get_Ship_Set_Id;
	    return;
         --}
	 END IF;
	 CLOSE Get_Ship_Set_Id;
	 l_batch_grp_rec.ship_set_id := l_batch_in_rec.ship_set_id;
     ELSE
        l_batch_grp_rec.ship_set_id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Ship Set Number  Validations

--- Ship To Location  Validations
IF l_batch_grp_rec.Customer_Id IS NOT NULL THEN --Bug# 3480908 - Ignore Ship_To if customer not provided
  IF ( ( l_batch_in_rec.Ship_To_Location_Id IS NOT NULL ) OR ( l_batch_in_rec.Ship_To_Location_code IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Ship_To_Location_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Ship_To_Location_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Ship_To_Location_code =  FND_API.G_MISS_CHAR) THEN
     --{
	l_batch_in_rec.Ship_To_Location_code := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Ship_To_Location_Id IS NOT NULL) OR ( l_batch_in_rec.Ship_To_Location_code IS NOT NULL ) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        WSH_UTIL_VALIDATE.Validate_Location(
	      p_location_id	   => l_batch_in_rec.Ship_To_Location_Id,
	      p_location_code	   => l_batch_in_rec.Ship_To_Location_Code,
	      x_return_status	   => l_return_status,
	      p_isWshLocation	   => TRUE);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	l_batch_grp_rec.Ship_To_Location_Id := l_batch_in_rec.Ship_To_Location_Id;
     ELSE
        l_batch_grp_rec.Ship_To_Location_Id:= NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
ELSE  -- Bug# 3480908
  l_batch_grp_rec.Ship_To_Location_Id:= NULL;
END IF;
-- End of Ship to Location Validations

--- Ship From Location Validations

  IF ( ( l_batch_in_rec.Ship_From_Location_Id IS NOT NULL ) OR ( l_batch_in_rec.Ship_From_Location_code IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Ship_From_Location_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Ship_From_Location_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Ship_From_Location_code =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.Ship_From_Location_code := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Ship_From_Location_Id IS NOT NULL) OR ( l_batch_in_rec.Ship_From_Location_code IS NOT NULL ) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
 	WSH_UTIL_VALIDATE.Validate_Location(
	     p_location_id	   => l_batch_in_rec.Ship_From_Location_Id,
	     p_location_code	   => l_batch_in_rec.Ship_From_Location_Code,
	     x_return_status	   => l_return_status,
	     p_isWshLocation	   => TRUE);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
        l_batch_grp_rec.Ship_From_Location_Id := l_batch_in_rec.Ship_From_Location_Id;
     ELSE
        l_batch_grp_rec.Ship_From_Location_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  -- Bug 5373798
  ELSE -- (l_batch_in_rec.Ship_From_Location_Id IS  NULL) AND ( l_batch_in_rec.Ship_From_Location_code IS NULL)
      l_batch_grp_rec.Ship_From_Location_Id := NULL;
  END IF;


-- End of Ship From Location Validations


--- Trip Validations

  IF ( ( l_batch_in_rec.Trip_Id IS NOT NULL ) OR ( l_batch_in_rec.Trip_Name IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Trip_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Trip_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Trip_name =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.Trip_name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Trip_Id IS NOT NULL ) OR ( l_batch_in_rec.Trip_Name IS NOT NULL ) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_TRIP_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
 	WSH_UTIL_VALIDATE.Validate_Trip_Name(
	      p_trip_id	       => l_batch_in_rec.Trip_Id,
	      p_trip_name      => l_batch_in_rec.Trip_Name,
	      x_return_status  => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        l_batch_grp_rec.Trip_Id :=l_batch_in_rec.Trip_Id;
     ELSE
        l_batch_grp_rec.Trip_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Trip Validations

-- Delivery   Validations

  IF ( ( l_batch_in_rec.Delivery_Id IS NOT NULL ) OR ( l_batch_in_rec.Delivery_Name IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Delivery_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Delivery_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Delivery_Name =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.Delivery_name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Delivery_Id IS NOT NULL) OR ( l_batch_in_rec.Delivery_Name IS NOT NULL ) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_DELIVERY_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
 	WSH_UTIL_VALIDATE.Validate_Delivery_Name(
	      p_delivery_id	   => l_batch_in_rec.Delivery_Id,
	      p_delivery_name	   => l_batch_in_rec.Delivery_Name,
	      x_return_status  => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        --R12 MDC
        --Delivery must be a standard delivery
        OPEN c_check_consol_dlvy(l_batch_in_rec.Delivery_Id);
        FETCH c_check_consol_dlvy INTO l_batch_in_rec.Delivery_Id;
        IF c_check_consol_dlvy%NOTFOUND THEN
           CLOSE c_check_consol_dlvy;
           RAISE WSH_INVALID_CONSOL_DEL;
        END IF;
        CLOSE c_check_consol_dlvy;

	l_batch_grp_rec.Delivery_Id := l_batch_in_rec.Delivery_Id;
     ELSE
        l_batch_grp_rec.Delivery_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Delivery Validations

--- Trip Stop Validations
--- Consider the trip stops only when the trip information is provided
--- same thing is being followed in pick release form also
  IF ( l_batch_grp_rec.trip_id IS NOT NULL ) THEN
  --{
     IF ( ( l_batch_in_rec.Trip_Stop_Id IS NOT NULL ) OR ( l_batch_in_rec.trip_stop_location_id IS NOT NULL ) ) THEN
     --{ Passed the Values or Not
        IF ( l_batch_in_rec.Trip_Stop_Id = FND_API.G_MISS_NUM ) THEN
	--{
            l_batch_in_rec.Trip_Stop_Id := NULL;
        --}
	END IF;
        IF ( l_batch_in_rec.trip_stop_location_id =  FND_API.G_MISS_NUM ) THEN
	--{
             l_batch_in_rec.trip_stop_location_id := NULL;
        --}
	END IF;
        IF ( ( l_batch_in_rec.Trip_Stop_Id IS NOT NULL )  OR ( l_batch_in_rec.trip_stop_location_id IS NOT NULL ) ) THEN
	--{
  	   IF l_debug_on THEN
	   --{
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_STOP_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
           --}
	   END IF;
           WSH_UTIL_VALIDATE.Validate_Stop_Name(
	      p_stop_id		  => l_batch_in_rec.Trip_Stop_Id,
	      p_trip_id		  => l_batch_grp_rec.Trip_id,
	      p_stop_location_id  => l_batch_in_rec.trip_stop_location_id,
	      p_planned_dep_date  => NULL,
	      x_return_status	  => l_return_status);

           IF l_debug_on THEN
	   --{
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
           --}
	   END IF;
           --
           wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

           l_batch_grp_rec.Trip_Stop_Id := l_batch_in_rec.Trip_Stop_Id ;
        ELSE
           l_batch_grp_rec.Trip_Stop_Id := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
  --}
  END IF;

-- End of Trip Stop  Validations


-- Pick_Grouping_Rule_Id  Validations

  IF ( ( l_batch_in_rec.pick_grouping_rule_Id IS NOT NULL ) OR ( l_batch_in_rec.pick_grouping_rule_Name IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.pick_grouping_rule_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.pick_grouping_rule_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.pick_grouping_rule_Name =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.pick_grouping_rule_name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.pick_grouping_rule_Id IS NOT	NULL) OR ( l_batch_in_rec.pick_grouping_rule_Name IS NOT NULL ) ) THEN
     --{
 	 IF l_debug_on THEN
	 --{
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_PICK_GROUP_RULE_NAMe',WSH_DEBUG_SV.C_PROC_LEVEL);
         --}
	 END IF;
         WSH_UTIL_VALIDATE.Validate_Pick_Group_Rule_Name(
	      p_pick_grouping_rule_id	       => l_batch_in_rec.pick_grouping_rule_Id,
	      p_pick_grouping_rule_name        => l_batch_in_rec.pick_grouping_rule_Name,
	      x_return_status  => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	l_batch_grp_rec.pick_grouping_rule_Id :=l_batch_in_rec.pick_grouping_rule_Id;
     ELSE
        l_batch_grp_rec.pick_grouping_rule_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Pick_Grouping_Rule_Id	 Validations

-- Pick_Sequence_Rule_Id  Validations

  IF ( ( l_batch_in_rec.pick_sequence_rule_Id IS NOT NULL ) OR ( l_batch_in_rec.pick_sequence_rule_Name IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.pick_sequence_rule_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.pick_sequence_rule_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.pick_sequence_rule_name =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.pick_sequence_rule_name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.pick_sequence_rule_Id IS NOT	NULL) OR ( l_batch_in_rec.pick_sequence_rule_Name IS NOT NULL ) ) THEN
     --{
 	IF l_debug_on THEN
	--{
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_PICK_SEQ_RULE_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
 	END IF;
        WSH_UTIL_VALIDATE.Validate_Pick_Seq_Rule_Name(
	      p_pick_sequence_rule_id	       => l_batch_in_rec.pick_sequence_rule_Id,
	      p_pick_sequence_rule_name        => l_batch_in_rec.pick_sequence_rule_Name,
	      x_return_status                  => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

        l_batch_grp_rec.pick_sequence_rule_Id :=l_batch_in_rec.pick_sequence_rule_Id;
     ELSE
        l_batch_grp_rec.pick_sequence_rule_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Pick_Sequence_Rule_Id Validations

-- Bug 3463315 Append_Flag validation

  IF ( l_batch_in_rec.autocreate_delivery_flag IS NOT NULL ) THEN
     IF ( l_batch_in_rec.autocreate_delivery_flag = FND_API.G_MISS_CHAR ) THEN
        l_batch_in_rec.autocreate_delivery_flag := NULL;
     END IF;

     IF (l_batch_in_rec.autocreate_delivery_flag IS NOT NULL) THEN
	l_batch_grp_rec.autocreate_delivery_flag := l_batch_in_rec.autocreate_delivery_flag;
     ELSE
        l_batch_grp_rec.autocreate_delivery_flag := NULL;
     END IF;

  END IF;

  -- Bug# 3480908 - Start
  IF l_batch_grp_rec.autocreate_delivery_flag <> 'Y' THEN
      l_batch_grp_rec.Autopack_Flag := 'N';
      l_batch_grp_rec.Ship_Confirm_Rule_Id := NULL;
      l_batch_grp_rec.ac_Delivery_Criteria := NULL;
  END IF;
  -- Bug# 3480908 - End

  IF ( l_batch_in_rec.ac_delivery_criteria IS NOT NULL ) THEN
     IF ( l_batch_in_rec.ac_delivery_criteria = FND_API.G_MISS_CHAR ) THEN
        l_batch_in_rec.ac_delivery_criteria := NULL;
     END IF;

     IF (l_batch_in_rec.ac_delivery_criteria IS NOT NULL) THEN
	l_batch_grp_rec.ac_delivery_criteria := l_batch_in_rec.ac_delivery_criteria;
     ELSE
        l_batch_grp_rec.ac_delivery_criteria := NULL;
     END IF;
  END IF;

-- End of Bug 3463315 Append_Flag validation

-- Ship_Confirm_Rule_Id	 Validations

  IF ( ( l_batch_in_rec.ship_confirm_rule_Id IS NOT NULL ) OR ( l_batch_in_rec.ship_confirm_rule_Name IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.ship_confirm_rule_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.ship_confirm_rule_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.ship_confirm_rule_name =  FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.ship_confirm_rule_name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.ship_confirm_rule_Id IS NOT	NULL) OR ( l_batch_in_rec.ship_confirm_rule_Name IS NOT NULL ) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_SHIP_CON_RULE_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        WSH_UTIL_VALIDATE.Validate_Ship_Con_Rule_Name(
	      p_ship_confirm_rule_id	       => l_batch_in_rec.ship_confirm_rule_Id,
	      p_ship_confirm_rule_name        => l_batch_in_rec.ship_confirm_rule_Name,
	      x_return_status                  => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	l_batch_grp_rec.ship_confirm_rule_Id :=l_batch_in_rec.ship_confirm_rule_Id;
     ELSE
        l_batch_grp_rec.ship_confirm_rule_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of ship_confirm_Rule_Id Validations
  --{
  --
  -- Posco ER : By now, we know for sure whether a Ship Confirm Rule
  -- has to be used with this batch or NOT
  --
  -- So, proceed to validate the Actual Departure date
  --
  IF l_batch_grp_rec.ship_confirm_rule_id IS NULL THEN
   --{
   IF l_batch_in_rec.actual_departure_date IS NOT NULL THEN
    --
    FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_ACTUAL_DEP_DATE');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    --
    IF l_debug_on THEN
     wsh_debug_sv.logmsg(l_module_name, 'Error - WSH_NO_ACTUAL_DEP_DATE');
     wsh_debug_sv.pop(l_module_name);
    END IF;
    --
    RETURN;
    --
   END IF;
   --}
  ELSE
   --{
   IF l_batch_in_rec.actual_departure_date IS NOT NULL THEN
    --{
    WSH_UTIL_VALIDATE.ValidateActualDepartureDate(
            p_ship_confirm_rule_id  => l_batch_grp_rec.ship_confirm_rule_id,
            p_actual_departure_date => l_batch_in_rec.actual_departure_date,
            x_return_status         => l_return_status);
    --
    wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
    --
    l_batch_grp_rec.actual_departure_date := l_batch_in_rec.actual_departure_date;
    --}
   ELSE
    l_batch_grp_rec.actual_departure_date := NULL;
   END IF;
   --}
  END IF;
  --
  --}
  --
--- Carrier  Validations
-- Bug#: 3266659 - Removing carrier validations
/*
  IF ( ( l_batch_in_rec.Carrier_Id IS NOT NULL ) OR ( l_batch_in_rec.Carrier_Name IS NOT NULL ) ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Carrier_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_in_rec.Carrier_Id := NULL;
     --}
     END IF;
     IF ( l_batch_in_rec.Carrier_name =  FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_in_rec.Carrier_Name := NULL;
     --}
     END IF;
     IF ( ( l_batch_in_rec.Carrier_Id IS NOT NULL ) OR ( l_batch_in_rec.Carrier_Name IS NOT NULL ) ) THEN
     --{
	IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_CARRIER',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        WSH_UTIL_VALIDATE.Validate_Carrier(
	      x_Carrier_id	  => l_batch_in_rec.Carrier_Id,
	      p_Carrier_name	  => l_batch_in_rec.Carrier_Name,
	      x_return_status     => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );

	l_batch_grp_rec.Carrier_Id := l_batch_in_rec.Carrier_Id;
     ELSE
        l_batch_grp_rec.Carrier_Id  := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
*/
-- End of Carrier Validations

-- Inventory Item Id Validations

  IF ( l_batch_in_rec.Inventory_Item_Id IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Inventory_Item_Id <> FND_API.G_MISS_NUM ) THEN
     --{
        OPEN Check_Item_id(l_batch_in_rec.Inventory_Item_Id,l_batch_grp_rec.organization_id);
        FETCH Check_Item_id INTO l_batch_in_rec.Inventory_Item_Id;
        IF ( Check_Item_id%NOTFOUND ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INVENTORY_ITEM_ID');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    CLOSE Check_Item_id;
	    return;
        --}
	END IF;
	CLOSE Check_Item_id;
        l_batch_grp_rec.Inventory_Item_Id := l_batch_in_rec.Inventory_Item_Id;
     ELSE
        l_batch_grp_rec.Inventory_Item_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Inventory Item Id  Validations


--  Subinventory and locators are considered only when the organization is mentioned

  IF ( l_batch_grp_rec.organization_id IS NOT NULL ) THEN
  --{ Check subinventories and locators only when Org is specified
     -- Default_Stage_Subinventory  Validations
     IF ( l_batch_in_rec.Default_Stage_Subinventory  IS NOT NULL ) THEN
     --{ Passed the Values or Not
        IF ( l_batch_in_rec.Default_Stage_Subinventory <> FND_API.G_MISS_CHAR) THEN
	--{
           OPEN Check_Subinventory( l_batch_in_rec.Default_Stage_Subinventory,l_batch_grp_rec.organization_id);
           FETCH Check_Subinventory INTO l_batch_in_rec.Default_Stage_Subinventory;
           IF ( Check_Subinventory%NOTFOUND ) THEN
	   --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','DEFAULT_STAGE_SUBINVENTORY');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      CLOSE Check_Subinventory;
	      return;
           --}
	   END IF;
	   CLOSE Check_Subinventory;
	   l_batch_grp_rec.Default_Stage_Subinventory := l_batch_in_rec.Default_Stage_Subinventory;
        ELSE
           l_batch_grp_rec.Default_Stage_Subinventory := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
     -- End of Default_Stage_Subinventory  Validations
--Bug8221008 Validations for rel_subinventory
     IF ( l_batch_in_rec.rel_subinventory  IS NOT NULL ) THEN
     --{ Passed the Values or Not
        IF ( l_batch_in_rec.rel_subinventory <> FND_API.G_MISS_CHAR) THEN
	--{
           OPEN Check_Subinventory( l_batch_in_rec.rel_subinventory,l_batch_grp_rec.organization_id);
           FETCH Check_Subinventory INTO l_batch_in_rec.rel_subinventory;
           IF ( Check_Subinventory%NOTFOUND ) THEN
	   --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','REL_SUBINVENTORY');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      CLOSE Check_Subinventory;
	      return;
           --}
	   END IF;
	   CLOSE Check_Subinventory;
	   l_batch_grp_rec.rel_subinventory := l_batch_in_rec.rel_subinventory;
        ELSE
           l_batch_grp_rec.rel_subinventory := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
--Bug8221008 End of validations for rel_subinventory

     -- Default_Stage_Locator_Id  Validations
     IF ( l_batch_in_rec.Default_Stage_Locator_Id IS NOT NULL ) THEN
     --{ Passed the Values or Not
        IF (l_batch_in_rec.Default_Stage_Locator_Id <> FND_API.G_MISS_NUM ) THEN
	--{
           OPEN Check_Locator_Id( l_batch_in_rec.Default_Stage_Locator_Id,l_batch_grp_rec.Default_Stage_Subinventory,l_batch_grp_rec.organization_id);
           FETCH Check_Locator_Id INTO l_batch_in_rec.Default_Stage_Locator_Id;
           IF ( Check_Locator_Id%NOTFOUND ) THEN
	   --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','DEFAULT_STAGE_LOCATOR_ID');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      CLOSE Check_Locator_Id;
	      return;
           --}
	   END IF;
	   CLOSE Check_Locator_Id;
           l_batch_grp_rec.Default_Stage_Locator_Id := l_batch_in_rec.Default_Stage_Locator_Id;
        ELSE
           l_batch_grp_rec.Default_Stage_Locator_Id := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
     -- End of Default_Stage_Locator_Id  Validations


     -- Pick_From_Subinventory  Validations
     IF ( l_batch_in_rec.Pick_From_Subinventory  IS NOT NULL ) THEN
     --{ Passed the Values or Not
        IF ( l_batch_in_rec.Pick_From_Subinventory <> FND_API.G_MISS_CHAR) THEN
	--{
           OPEN Check_Subinventory( l_batch_in_rec.Pick_From_Subinventory,l_batch_grp_rec.organization_id);
           FETCH Check_Subinventory INTO l_batch_in_rec.Pick_From_Subinventory;
           IF ( Check_Subinventory%NOTFOUND ) THEN
	   --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PICK_FROM_SUBINVENTORY');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      CLOSE Check_Subinventory;
	      return;
           --}
	   END IF;
	   CLOSE Check_Subinventory;
	   l_batch_grp_rec.Pick_From_Subinventory := l_batch_in_rec.Pick_From_Subinventory;
        ELSE
           l_batch_grp_rec.Pick_From_Subinventory := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
     -- End of Pick_From_Subinventory  Validations

     -- Pick_From_locator_Id Validations
     IF ( l_batch_in_rec.Pick_From_locator_Id IS NOT NULL ) THEN
     --{ Passed the Values or Not
        IF (l_batch_in_rec.Pick_From_locator_Id <> FND_API.G_MISS_NUM ) THEN
	--{
           OPEN Check_Locator_Id( l_batch_in_rec.Pick_From_locator_Id,l_batch_grp_rec.Pick_From_Subinventory,l_batch_grp_rec.organization_id );
           FETCH Check_Locator_Id INTO l_batch_in_rec.Pick_From_locator_Id;
           IF ( Check_Locator_Id%NOTFOUND ) THEN
	   --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PICK_FROM_LOCATOR_ID');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      CLOSE  Check_Locator_Id;
	      return;
	   --}
	   END IF;
	   CLOSE Check_Locator_Id;
           l_batch_grp_rec.Pick_From_locator_Id := l_batch_in_rec.Pick_From_locator_Id;
        ELSE
           l_batch_grp_rec.Pick_From_locator_Id := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
     -- End of Pick_From_locator_Id Validations
  -- } Check subinventories and locators only when Org is specified
  END IF;

-- End of subinventory and locator validations

-- Delivery_Detail_Id  Validations

  IF ( l_batch_in_rec.Delivery_Detail_Id IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Delivery_Detail_Id <> FND_API.G_MISS_NUM ) THEN
     --{
         IF (l_batch_in_rec.Delivery_Detail_Id = -1 ) THEN
         --{ Bug# 7505524, in wave pick release case, wms is passing dd as -1.
             l_batch_grp_rec.Delivery_Detail_Id := l_batch_in_rec.Delivery_Detail_Id;
         ELSE
             l_batch_grp_rec.Delivery_Detail_Id := l_batch_in_rec.Delivery_Detail_Id;
             OPEN Check_Delivery_Detail_Id(l_batch_in_rec.Delivery_Detail_Id);
             FETCH Check_Delivery_Detail_Id INTO l_batch_in_rec.Delivery_Detail_Id;
             IF ( Check_Delivery_Detail_Id%NOTFOUND ) THEN
	         --{
	             FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','DELIVERY_DETAIL_ID');
	             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	             wsh_util_core.add_message(x_return_status);
	             CLOSE Check_Delivery_Detail_Id;
	             return;
             --}
	         END IF;
	         CLOSE Check_Delivery_Detail_Id;
             l_batch_grp_rec.Delivery_Detail_Id := l_batch_in_rec.Delivery_Detail_Id;
         --}
         END IF;
     ELSE
        l_batch_grp_rec.Delivery_Detail_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Delivery_Detail_Id  Validations

-- Category_Set_ID  Validations
  IF ( l_batch_in_rec.Category_Set_Id IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Category_Set_Id <> FND_API.G_MISS_NUM ) THEN
     --{
        OPEN Check_Category_Set_Id(l_batch_in_rec.Category_Set_Id);
        FETCH Check_Category_Set_Id INTO l_batch_in_rec.Category_Set_Id;
        IF ( Check_Category_Set_Id%NOTFOUND ) THEN
	--{
	   FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CATEGORY_SET_ID');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   wsh_util_core.add_message(x_return_status);
	   CLOSE Check_Category_Set_Id;
	   return;
        --}
	END IF;
	CLOSE Check_Category_Set_Id;
        l_batch_grp_rec.Category_Set_Id := l_batch_in_rec.Category_Set_Id;
     ELSE
        l_batch_grp_rec.Category_Set_Id := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
-- End of Category_Set_ID  Validations


-- Category_ID Validations
  IF ( l_batch_grp_rec.Category_Set_Id IS NOT NULL ) THEN
  --{ Set_Id
     IF ( l_batch_in_rec.Category_Id IS NOT NULL ) THEN
     --{ Passed the Values or Not
        IF ( l_batch_in_rec.Category_Id <> FND_API.G_MISS_NUM ) THEN
	--{
           OPEN Check_Category_Id(l_batch_in_rec.Category_Id);
           FETCH Check_Category_Id INTO l_batch_in_rec.Category_Id;
           IF ( Check_Category_Id%NOTFOUND ) THEN
	   --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CATEGORY_ID');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      CLOSE Check_Category_Id;
	      return;
           --}
	   END IF;
           CLOSE Check_Category_Id;
	   l_batch_grp_rec.Category_Id := l_batch_in_rec.Category_Id;
        ELSE
           l_batch_grp_rec.Category_Id := NULL;
        --}
	END IF;
     --} Passed the Values or Not
     END IF;
  --} Set_Id
  END IF;

-- End of Category_ID  Validations

-- Ignore_Shipset_Smc Validations

  IF ( l_batch_in_rec.Ship_Set_Smc_Flag  IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF ( l_batch_in_rec.Ship_Set_Smc_Flag  <> FND_API.G_MISS_CHAR ) THEN
     --{
        IF ( l_batch_in_rec.Ship_Set_Smc_Flag  NOT IN ('I','E','A') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SHIP_SET_SMC_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Ship_Set_Smc_Flag :=l_batch_in_rec.Ship_Set_Smc_Flag;
     ELSE
        l_batch_grp_rec.Ship_Set_Smc_Flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

--  End of Ignore_Shipset_Smc Validations


-- Auto_Pick_Confirm_Flag Validations
  IF ( l_batch_in_rec.Auto_Pick_Confirm_Flag  IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Auto_Pick_Confirm_Flag <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Auto_Pick_Confirm_Flag  NOT IN ('Y','N') )	THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','AUTO_PICK_CONFIRM_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Auto_Pick_Confirm_Flag := l_batch_in_rec.Auto_Pick_Confirm_Flag;
     ELSE
        l_batch_grp_rec.Auto_Pick_Confirm_Flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
-- End of Auto_Pick_Confirm_Flag Validations

-- Validating the Existing Reservations	Only Flag

  IF ( l_batch_in_rec.Existing_Rsvs_Only_Flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Existing_Rsvs_Only_Flag	<> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Existing_Rsvs_Only_Flag  NOT IN ('N','Y'))	THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','EXISTING_RSVS_ONLY_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Existing_Rsvs_Only_Flag := l_batch_in_rec.Existing_Rsvs_Only_Flag;
     ELSE
        l_batch_grp_rec.Existing_Rsvs_Only_Flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Validating the Existing Reservations Only Flag

-- Include Planned Lines Validations

  IF ( l_batch_in_rec.Include_Planned_Lines IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Include_Planned_Lines <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Include_Planned_Lines  NOT	IN ('Y','N') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INCLUDE_PLANNED_LINES');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Include_Planned_Lines := l_batch_in_rec.Include_Planned_Lines;
     ELSE
        l_batch_grp_rec.Include_Planned_Lines := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Include Planned Lines	Validations

-- Autodetail_Pr_Flag Validations

  IF ( l_batch_in_rec.Autodetail_Pr_Flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Autodetail_Pr_Flag <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Autodetail_Pr_Flag  NOT IN ('Y','N') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','AUTODETAIL_PR_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Autodetail_Pr_Flag :=l_batch_in_rec.Autodetail_Pr_Flag;
     ELSE
        l_batch_grp_rec.Autodetail_Pr_Flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Autodetail_Pr_Flag Validations


-- Autopack_Flag Validations

  IF ( l_batch_in_rec.Autopack_Flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Autopack_Flag <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Autopack_Flag  NOT IN ('Y','N') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','AUTOPACK_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Autopack_Flag :=l_batch_in_rec.Autopack_Flag;
     ELSE
        l_batch_grp_rec.Autopack_Flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;

-- End of Autopack_Flag	Validations

-- Autopack_Level Validations
-- Consider the Autopack_level only when the Autopack_Flag set to "Y"
  IF ( l_batch_grp_rec.Autopack_Flag = 'Y' ) THEN
  --{
    IF ( l_batch_in_rec.Autopack_Level IS NOT NULL ) THEN
    --{ Passed the Values or Not
       IF (l_batch_in_rec.Autopack_Level <> FND_API.G_MISS_NUM) THEN
       --{
          IF ( l_batch_in_rec.Autopack_Level NOT IN (0,1,2) ) THEN
	  --{
	      FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','AUTOPACK_LEVEL');
	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	      wsh_util_core.add_message(x_return_status);
	      return;
          --}
	  END IF;
	  l_batch_grp_rec.Autopack_Level := l_batch_in_rec.Autopack_Level;
       ELSE
          l_batch_grp_rec.Autopack_Level := NULL;
       --}
       END IF;
    --} Passed the Values or Not
    END IF;
  --}
  END IF;

-- End of Autopack_Level  Validations

-- Task_Planning_Flag Validations

  IF ( l_batch_in_rec.Task_Planning_Flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Task_Planning_Flag <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Task_Planning_Flag  NOT IN ('Y','N') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','TASK_PLANNING_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Task_Planning_Flag :=l_batch_in_rec.Task_Planning_Flag;
     ELSE
        l_batch_grp_rec.Task_Planning_Flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
-- End of Task_Planning_Flag Validations

-- Bug# 3480908 - Start - If the org is WMS enabled, and Plan task is yes then auto alocate is yes.
  IF l_batch_grp_rec.Task_Planning_Flag = 'Y' AND l_is_WMS_org = 'Y' THEN
	l_batch_grp_rec.Autodetail_Pr_Flag := 'Y';
  END IF;
-- Bug# 3480908 - End


--bug# 6689448 (replenishment project): begin
-- dynamic_replenishment_flag Validations

  IF ( l_batch_in_rec.dynamic_replenishment_flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.dynamic_replenishment_flag <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.dynamic_replenishment_flag  NOT IN ('Y','N') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','dynamic_replenishment_flag');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.dynamic_replenishment_flag :=l_batch_in_rec.dynamic_replenishment_flag;
     ELSE
        l_batch_grp_rec.dynamic_replenishment_flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
-- End of dynamic_replenishment_flag Validations

  -- If the org is WMS enabled, and Plan task is yes then auto alocate is yes.
  IF l_batch_grp_rec.dynamic_replenishment_flag = 'Y' AND l_is_WMS_org = 'Y' THEN
	l_batch_grp_rec.Autodetail_Pr_Flag := 'Y';
  END IF;

--bug# 6689448 (replenishment project): end

-- Non_Picking_flag  Validations
-- Bug#: 3266659 - Removing Non_Picking_flag validations
/*
  IF ( l_batch_in_rec.Non_Picking_flag IS NOT NULL ) THEN
  --{ Passed the Values or Not
     IF (l_batch_in_rec.Non_Picking_flag <> FND_API.G_MISS_CHAR) THEN
     --{
        IF ( l_batch_in_rec.Non_Picking_flag  NOT IN ('Y','N') ) THEN
	--{
	    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','NON_PICKING_FLAG');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	    return;
        --}
	END IF;
	l_batch_grp_rec.Non_Picking_flag :=l_batch_in_rec.Non_Picking_flag;
     ELSE
        l_batch_grp_rec.Non_Picking_flag := NULL;
     --}
     END IF;
  --} Passed the Values or Not
  END IF;
*/
-- End of Non_Picking_flag Validations

-- Shipment_Priority_Code Validations

  IF ( l_batch_in_rec.Shipment_Priority_Code  IS NOT NULL ) THEN
  --{
     IF (l_batch_in_rec.Shipment_Priority_Code <> FND_API.G_MISS_CHAR) THEN
     --{
        l_batch_in_rec.Shipment_Priority_Code  := l_batch_in_rec.Shipment_Priority_Code;
     ELSE
        l_batch_in_rec.Shipment_Priority_Code := NULL;
     --}
     END IF;
  --}
  END IF;

-- End of Validating the Shipment_Priority_Code


-- Project_Id  Validations
  IF ( l_batch_in_rec.Project_Id IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Project_Id <> FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_grp_rec.Project_Id := l_batch_in_rec.Project_Id;
     ELSE
        l_batch_grp_rec.Project_Id := NULL;
     --}
     END IF;
  --}
  END IF;
-- End of Project_Id  Validations


-- Task_Id Validations
  IF ( l_batch_in_rec.Task_Id IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Task_Id <> FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_grp_rec.Task_Id := l_batch_in_rec.Task_Id;
     ELSE
        l_batch_grp_rec.Task_Id := NULL;
     --}
     END IF;
  --}
  END IF;
-- End of Task_Id  Validations

-- From	Requested Date Validations

  IF ( l_batch_in_rec.From_Requested_Date IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.From_Requested_Date <> FND_API.G_MISS_DATE ) THEN
     --{
        l_batch_grp_rec.From_Requested_Date	:= l_batch_in_rec.From_Requested_Date;
     ELSE
        l_batch_grp_rec.From_Requested_Date := NULL;
     --}
     END IF;
  --}
  END IF;

-- End of From Requested Date  Validations

-- To Requested	Date Validations

  IF ( l_batch_in_rec.To_Requested_Date IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.To_Requested_Date <> FND_API.G_MISS_DATE ) THEN
     --{
        l_batch_grp_rec.To_Requested_Date := l_batch_in_rec.To_Requested_Date;
     ELSE
        l_batch_grp_rec.To_Requested_Date := NULL;
     --}
     END IF;
  --}
  END IF;

-- End of To_Requested_Date  Validations

-- From	Scheduled Ship Date  Validations

  IF ( l_batch_in_rec.From_Scheduled_Ship_Date IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.From_Scheduled_Ship_Date <> FND_API.G_MISS_DATE ) THEN
     --{
        l_batch_grp_rec.From_Scheduled_Ship_Date :=	l_batch_in_rec.From_Scheduled_Ship_Date;
     ELSE
        l_batch_grp_rec.From_Scheduled_Ship_Date := NULL;
     --}
     END IF;
  --}
  END IF;

-- End of From_Scheduled_Ship_Date   Validations

-- To Scheduled	Ship Date Validations

  IF ( l_batch_in_rec.To_Scheduled_Ship_Date IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.To_Scheduled_Ship_Date	<> FND_API.G_MISS_DATE ) THEN
     --{
        l_batch_grp_rec.To_Scheduled_Ship_Date := l_batch_in_rec.To_Scheduled_Ship_Date;
     ELSE
        l_batch_grp_rec.To_Scheduled_Ship_Date := NULL;
     --}
     END IF;
  --}
  END IF;

-- End of To Scheduled Ship Date  Validations

-- Validate all Attribute Fields
  IF ( l_batch_in_rec.Attribute_Category IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute_Category <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute_Category := l_batch_in_rec.Attribute_Category;
     ELSE
        l_batch_grp_rec.Attribute_Category := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute1 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute1 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute1 := l_batch_in_rec.Attribute1;
     ELSE
        l_batch_grp_rec.Attribute1 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute2 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute2 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute2 := l_batch_in_rec.Attribute2;
     ELSE
        l_batch_grp_rec.Attribute2 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute3 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute3 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute3 := l_batch_in_rec.Attribute3;
     ELSE
        l_batch_grp_rec.Attribute3 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute4 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute4 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute4 := l_batch_in_rec.Attribute4;
     ELSE
        l_batch_grp_rec.Attribute4 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute5 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute5 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute5 := l_batch_in_rec.Attribute5;
     ELSE
        l_batch_grp_rec.Attribute5 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute6 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute6 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute6 := l_batch_in_rec.Attribute6;
     ELSE
        l_batch_grp_rec.Attribute6 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute7 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute7 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute7 := l_batch_in_rec.Attribute7;
     ELSE
        l_batch_grp_rec.Attribute7 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute8 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute8 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute8 := l_batch_in_rec.Attribute8;
     ELSE
        l_batch_grp_rec.Attribute8 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute9 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute9 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute9 := l_batch_in_rec.Attribute9;
     ELSE
        l_batch_grp_rec.Attribute9 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute10 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute10 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute10 := l_batch_in_rec.Attribute10;
     ELSE
        l_batch_grp_rec.Attribute10 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute11 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute11 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute11 := l_batch_in_rec.Attribute11;
     ELSE
        l_batch_grp_rec.Attribute11 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute12 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute12 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute12 := l_batch_in_rec.Attribute12;
     ELSE
        l_batch_grp_rec.Attribute12 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute13 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute13 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute13 := l_batch_in_rec.Attribute13;
     ELSE
        l_batch_grp_rec.Attribute13 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute14 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute14 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute14 := l_batch_in_rec.Attribute14;
     ELSE
        l_batch_grp_rec.Attribute14 := NULL;
     --}
     END IF;
  --}
  END IF;

  IF ( l_batch_in_rec.Attribute15 IS NOT NULL ) THEN
  --{
     IF ( l_batch_in_rec.Attribute15 <> FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_grp_rec.Attribute15 := l_batch_in_rec.Attribute15;
     ELSE
        l_batch_grp_rec.Attribute15 := NULL;
     --}
     END IF;
  --}
  END IF;

 -- End of Validating  all Attribute Fields

-- Validatiing the Batch Name Prefix
  IF ( l_batch_name_prefix = FND_API.G_MISS_CHAR ) THEN
  --{
     l_batch_name_prefix := NULL;
  --}
  END IF;
-- End of Validating the Batch Name Prefix

  -- Bug 3463315 Append_Flag validation
  IF l_batch_in_rec.Append_Flag is NOT NULL THEN
     IF l_batch_in_rec.Append_Flag <> FND_API.G_MISS_CHAR THEN
        l_batch_grp_rec.Append_Flag := l_batch_in_rec.Append_Flag;
     ELSE
        l_batch_grp_rec.Append_Flag := NULL;
     END IF;
  END IF;

  -- Validating the Task Priority
  IF l_batch_in_rec.task_priority is NOT NULL THEN
    IF l_batch_in_rec.task_priority <> FND_API.G_MISS_NUM THEN
       l_batch_grp_rec.task_priority := l_batch_in_rec.task_priority;
    ELSE
       l_batch_grp_rec.task_priority := NULL;
    END IF;
  END IF;
  -- End of Validating the Task Priority

  --
  -- Autocreate Delivery Flag can only be Y or N
  --
  IF (l_batch_grp_rec.autocreate_delivery_flag IS NOT NULL AND
      l_batch_grp_rec.autocreate_Delivery_flag NOT IN ('Y', 'N')) THEN
   --{
   FND_MESSAGE.SET_NAME('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
   FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'AUTOCREATE_DELIVERY_FLAG');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   wsh_util_core.add_message(x_return_status);
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return;
   --}
  END IF;
  --
  --
  -- ac_delivery_criteria can be used
  -- only if autocreate_delivery_flag is Y
  --
  IF (l_batch_grp_rec.ac_delivery_criteria IS NOT NULL AND
      l_batch_grp_rec.autocreate_delivery_flag <> 'Y') THEN
   --{
   FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_ACDEL_CRITERIA');
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   wsh_util_core.add_message(x_return_status, l_module_name);
   --
   IF l_debug_on THEN
     wsh_debug_sv.pop(l_module_name);
   END IF;
   --
   RETURN;
   --}
  END IF;
  --
  IF l_batch_grp_rec.Append_Flag = 'Y' or l_batch_grp_rec.Append_Flag is NULL THEN

     IF l_batch_grp_rec.organization_id is NULL THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_ORGANIZATION');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

     WSH_SHIPPING_PARAMS_PVT.Get(
        p_organization_id  => l_batch_grp_rec.organization_id,
        x_param_info       => l_param_info,
        x_return_status    => l_return_status);

     IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'Return status from WSH_SHIPPING_PARAMS_PVT.Get is :'||l_return_status );
     END IF;

     wsh_util_core.api_post_call(
	       p_return_status => l_return_status,
	       x_num_warnings  => l_number_of_warnings,
	       x_num_errors    => l_number_of_errors,
	       p_msg_data      => l_msg_data
	       );

     IF NVL(l_param_info.appending_limit, 'N') = 'N' THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_APPENDING_LIMIT');
        FND_MESSAGE.SET_NAME('ORGANIZATION_NAME', WSH_UTIL_CORE.Get_Org_Name(l_batch_grp_rec.organization_id));
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

     IF NVL(l_batch_grp_rec.autocreate_delivery_flag, 'N') <> 'Y' THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_AUTOCREATE_DEL');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

     IF NVL(l_batch_grp_rec.ac_delivery_criteria, 'Y') <> 'N' THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_AC_DEL_CRITERIA');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

     IF NVL(l_batch_grp_rec.auto_pick_confirm_flag, 'Y') <> 'N'  THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_AUTO_PICK');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

     IF l_batch_grp_rec.ship_confirm_rule_id is not NULL THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_AUTO_SHIP');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

     IF NVL(l_batch_grp_rec.autopack_flag, 'Y') <> 'N' THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_APPEND_AUTO_PACK');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	wsh_util_core.add_message(x_return_status);
	IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
        END IF;
	return;
     END IF;

  ELSIF l_batch_grp_rec.Append_Flag <> 'N' THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'APPEND_FLAG');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     wsh_util_core.add_message(x_return_status);
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
  END IF;
-- Bug 3463315 End of Append_Flag validation

-- Bug# 3438300 - Start - Validating mutually exclusive Ship from and Organization
  IF l_batch_grp_rec.Organization_Id IS NOT NULL AND l_batch_grp_rec.Ship_From_Location_Id IS NOT NULL THEN
        --check whether both are valid combination
  	open c_location_id(l_batch_grp_rec.Organization_Id);
	FETCH c_location_id into l_ship_from_loc_id;
	close c_location_id;

	IF l_ship_from_loc_id <> l_batch_grp_rec.Ship_From_Location_Id THEN
		FND_MESSAGE.SET_NAME('WSH','WSH_ORG_SHIPFROM_NOT_COMP');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
                IF l_debug_on THEN
                   WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                return;
	END IF;
  ELSIF l_batch_grp_rec.Organization_Id IS NOT NULL THEN
  -- Org is provided, populate the Ship from
	open c_location_id(l_batch_grp_rec.Organization_Id);
	FETCH c_location_id into l_ship_from_loc_id;
	close c_location_id;
	l_batch_grp_rec.Ship_From_Location_Id := l_ship_from_loc_id;
  ELSIF l_batch_grp_rec.Ship_From_Location_Id IS NOT NULL THEN
  -- Ship from is provided, populate the Org
	open c_org_id(l_batch_grp_rec.Ship_From_Location_Id);
	FETCH c_org_id into l_org_id;
	close c_org_id;
	l_batch_grp_rec.Organization_Id := l_org_id;
  END IF;
-- Bug# 3438300 - End

  IF (l_batch_grp_rec.order_header_id IS NULL AND l_batch_grp_rec.ship_set_id IS NULL AND
      l_batch_grp_rec.Trip_id IS NULL AND l_batch_grp_rec.Delivery_Id IS NULL AND
      l_batch_grp_rec.Delivery_Detail_Id IS NULL AND l_batch_grp_rec.Trip_Stop_Id IS NULL AND
      l_batch_grp_rec.Project_Id IS NULL AND l_batch_grp_rec.Task_Id IS NULL ) THEN --{
         --
         IF l_batch_grp_rec.Organization_Id IS NULL THEN --{
           -- Fatal error if no warehouse specified
           FND_MESSAGE.SET_NAME('WSH','WSH_PR_NO_WAREHOUSE');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           wsh_util_core.add_message(x_return_status);
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
         ELSE --}{
           -- Warning if warehouse specified and others null
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PR_CRITICAL_NULL');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	   wsh_util_core.add_message(x_return_status);
         END IF; --}
         --
  END IF; --}

  -- X-dock
  -- Validating the Allocation method
  IF l_batch_in_rec.allocation_method is NOT NULL THEN
    IF l_batch_in_rec.allocation_method <> FND_API.G_MISS_CHAR THEN
       l_batch_grp_rec.allocation_method := l_batch_in_rec.allocation_method;
    ELSE
       l_batch_grp_rec.allocation_method := 'I';
    END IF;
  END IF;
  -- End of Validating the Allocation Method

  -- Validating the Crossdock Criteria id
  --
  -- Bug #7505524  : Copied the following validation code from the
  --                public API WSH_PICKING_BATCHES_PUB.create_batch.
  --
  -- X-dock
  -- 1)Validate CrossDock Criteria Name for WMS org.
  --   Always use crossdock_criteria_id except when crossdock_criteria_id is null
  --   and crossdock_criteria_name has been specified
  -- 2)The values of crossdock criteria will be ignored for non-WMS org
  --
  IF WSH_UTIL_VALIDATE.check_wms_org(l_batch_in_rec.organization_id) = 'Y' THEN
    IF (l_batch_in_rec.crossdock_criteria_id IS NULL AND
        l_batch_in_rec.crossdock_criteria_name IS NOT NULL) THEN
      -- derive crossdock criteria id
      WMS_CROSSDOCK_GRP.chk_planxd_crt_id_name
        (p_criterion_id   => l_batch_in_rec.crossdock_criteria_id,
         p_criterion_name => l_batch_in_rec.crossdock_criteria_name,
         x_return_status  => l_return_status);

      wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
    END IF;
  END IF;
  -- end of X-dock
  -- Bug #7505524: end of bug.
  --
  -- Public API would have already converted crossdock criteria name to id,
  --  so validation is only done for id.
  IF l_batch_in_rec.crossdock_criteria_id is NOT NULL THEN
    IF l_batch_in_rec.crossdock_criteria_id <> FND_API.G_MISS_NUM THEN
       l_batch_grp_rec.crossdock_criteria_id := l_batch_in_rec.crossdock_criteria_id;
    ELSE
       l_batch_grp_rec.crossdock_criteria_id := NULL;
    END IF;
  END IF;
  -- End of Validating the Crossdock Criteria id

  --
  -- Validate Values using l_batch_grp_rec as the values from l_batch_in_rec
  -- have been validated and transferred to l_batch_grp_rec
  IF WSH_UTIL_VALIDATE.check_wms_org(l_batch_grp_rec.organization_id) = 'Y' THEN
  --{
    IF (l_batch_grp_rec.allocation_method NOT IN
          (WSH_PICK_LIST.C_INVENTORY_ONLY,WSH_PICK_LIST.C_CROSSDOCK_ONLY,
           WSH_PICK_LIST.C_PRIORITIZE_CROSSDOCK,WSH_PICK_LIST.C_PRIORITIZE_INVENTORY
          )
       ) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ALLOCATION_METHOD');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    ELSIF l_batch_grp_rec.crossdock_criteria_id IS NOT NULL AND
          l_batch_grp_rec.allocation_method IN (WSH_PICK_LIST.C_CROSSDOCK_ONLY,
           WSH_PICK_LIST.C_PRIORITIZE_CROSSDOCK,WSH_PICK_LIST.C_PRIORITIZE_INVENTORY) THEN
      -- call WMS API to validate cross dock criteria
      WMS_CROSSDOCK_GRP.validate_planxdock_crt_id
        (p_criterion_id => l_batch_grp_rec.crossdock_criteria_id,
         x_return_status => l_return_status);
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_XDOCK_CRITERION');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;
    ELSIF (l_batch_grp_rec.crossdock_criteria_id IS NOT NULL AND
           l_batch_grp_rec.allocation_method = (WSH_PICK_LIST.C_INVENTORY_ONLY)) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_XDOCK_INVALID_ALLOCMETHOD');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    -- Bug#7168917: Dynamic_replenish_flag value should not be 'Yes' when
    -- allocation method is 'Cross Dock Only' OR 'Prioritize Inventory'.
    ELSIF (l_batch_grp_rec.dynamic_replenishment_flag = 'Y' AND
           l_batch_grp_rec.allocation_method IN (WSH_PICK_LIST.C_CROSSDOCK_ONLY,WSH_PICK_LIST.C_PRIORITIZE_INVENTORY)) THEN
      FND_MESSAGE.SET_NAME('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'DYNAMIC_REPLENISHMENT_FLAG');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
    -- Bug #7505524:begin
    -- ECO 4634966
    IF l_batch_grp_rec.existing_rsvs_only_flag = 'Y' AND
       l_batch_grp_rec.allocation_method IN (WSH_PICK_LIST.C_CROSSDOCK_ONLY,
                              WSH_PICK_LIST.C_PRIORITIZE_CROSSDOCK,
                              WSH_PICK_LIST.C_PRIORITIZE_INVENTORY) THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_XDOCK_INVALID_ALLOCMETHOD');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         wsh_util_core.add_message(x_return_status);
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         RETURN;
    END IF;
    -- End of ECO 4634966
    -- Bug #7505524: end of bug.
  ELSE -- non WMS org
    IF l_batch_grp_rec.allocation_method IN (WSH_PICK_LIST.C_CROSSDOCK_ONLY,
           WSH_PICK_LIST.C_PRIORITIZE_CROSSDOCK,WSH_PICK_LIST.C_PRIORITIZE_INVENTORY) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ALLOCATION_METHOD');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  --}
  END IF;
  -- end of X-dock
  --
--=======================================================================================================
-- End Of the VALIDATION
--=======================================================================================================

-- Calling the Private API to Create the Batch

  IF l_debug_on THEN
  --{
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_PKG.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
  --}
  END IF;
  --
  WSH_PICKING_BATCHES_PKG.Insert_Row(
                        X_Rowid                      => l_batch_grp_rec.Row_Id,
 			X_Batch_Id		      => l_batch_grp_rec.Batch_Id,
			P_Creation_Date		      => l_batch_grp_rec.Creation_Date,
			P_Created_By		      => l_batch_grp_rec.Created_By,
			P_Last_Update_Date            => l_batch_grp_rec.Last_Update_Date,
			P_Last_Updated_By             => l_batch_grp_rec.Last_Updated_By,
			P_Last_Update_Login           => l_batch_grp_rec.Last_Update_Login,
			p_batch_name_prefix           => l_batch_name_prefix,
			X_Name                        => l_batch_grp_rec.Name,
			P_Backorders_Only_Flag        => l_batch_grp_rec.Backorders_Only_Flag,
			P_Document_Set_Id             => l_batch_grp_rec.Document_Set_Id,
			P_Existing_Rsvs_Only_Flag     => l_batch_grp_rec.Existing_Rsvs_Only_Flag,
			P_Shipment_Priority_Code      => l_batch_grp_rec.Shipment_Priority_Code,
			P_Ship_Method_Code            => l_batch_grp_rec.Ship_Method_Code,
			P_Customer_Id                 => l_batch_grp_rec.Customer_Id,
			P_Order_Header_Id             => l_batch_grp_rec.Order_Header_Id,
			P_Ship_Set_Number             => l_batch_grp_rec.Ship_Set_Id,
			P_Inventory_Item_Id           => l_batch_grp_rec.Inventory_Item_Id,
			P_Order_Type_Id               => l_batch_grp_rec.Order_Type_Id,
			P_From_Requested_Date         => l_batch_grp_rec.From_Requested_Date,
			P_To_Requested_Date           => l_batch_grp_rec.To_Requested_Date,
			P_From_Scheduled_Ship_Date    => l_batch_grp_rec.From_Scheduled_Ship_Date,
			P_To_Scheduled_Ship_Date      => l_batch_grp_rec.To_Scheduled_Ship_Date,
			P_Ship_To_Location_Id         => l_batch_grp_rec.Ship_To_Location_Id,
			P_Ship_From_Location_Id       => l_batch_grp_rec.Ship_From_Location_Id,
			P_Trip_Id                     => l_batch_grp_rec.Trip_Id,
			p_Delivery_Id                 => l_batch_grp_rec.Delivery_Id,
			P_Include_Planned_Lines       => l_batch_grp_rec.Include_Planned_Lines,
			P_Pick_Grouping_Rule_Id       => l_batch_grp_rec.Pick_Grouping_Rule_Id,
			P_Pick_Sequence_Rule_Id       => l_batch_grp_rec.Pick_Sequence_Rule_Id,
			P_Autocreate_Delivery_Flag    => l_batch_grp_rec.Autocreate_Delivery_Flag,
			P_Attribute_Category          => l_batch_grp_rec.Attribute_Category,
			P_Attribute1                  => l_batch_grp_rec.Attribute1,
			P_Attribute2                  => l_batch_grp_rec.Attribute2,
			P_Attribute3                  => l_batch_grp_rec.Attribute3,
			P_Attribute4                  => l_batch_grp_rec.Attribute4,
			P_Attribute5                  => l_batch_grp_rec.Attribute5,
			P_Attribute6                  => l_batch_grp_rec.Attribute6,
			P_Attribute7                  => l_batch_grp_rec.Attribute7,
			P_Attribute8                  => l_batch_grp_rec.Attribute8,
			P_Attribute9                  => l_batch_grp_rec.Attribute9,
			P_Attribute10                 => l_batch_grp_rec.Attribute10,
			P_Attribute11                 => l_batch_grp_rec.Attribute11,
			P_Attribute12                 => l_batch_grp_rec.Attribute12,
			P_Attribute13                 => l_batch_grp_rec.Attribute13,
			P_Attribute14                 => l_batch_grp_rec.Attribute14,
			P_Attribute15                 => l_batch_grp_rec.Attribute15,
			P_Autodetail_Pr_Flag          => l_batch_grp_rec.Autodetail_Pr_Flag,
			-- Bug#: 3266659 - Setting carrier id to NULL
			P_Carrier_Id                  => NULL,
			P_Trip_Stop_Id                => l_batch_grp_rec.Trip_Stop_Id,
			P_Default_Stage_Subinventory  => l_batch_grp_rec.Default_Stage_Subinventory,
			P_Default_Stage_Locator_Id    => l_batch_grp_rec.Default_Stage_Locator_Id,
			P_Pick_From_Subinventory      => l_batch_grp_rec.Pick_From_Subinventory,
			P_Pick_From_locator_Id        => l_batch_grp_rec.Pick_From_locator_Id,
			P_Auto_Pick_Confirm_Flag      => l_batch_grp_rec.Auto_Pick_Confirm_Flag,
			P_Delivery_Detail_Id          => l_batch_grp_rec.Delivery_Detail_Id,
			P_Project_Id                  => l_batch_grp_rec.Project_Id,
			P_Task_Id                     => l_batch_grp_rec.Task_Id,
			P_Organization_Id             => l_batch_grp_rec.Organization_Id,
			P_Ship_Confirm_Rule_Id        => l_batch_grp_rec.Ship_Confirm_Rule_Id,
			P_Autopack_Flag               => l_batch_grp_rec.Autopack_Flag,
			P_Autopack_Level              => l_batch_grp_rec.Autopack_Level,
			P_Task_Planning_Flag          => l_batch_grp_rec.Task_Planning_Flag,
			-- Bug#: 3266659 - Removing non_picking_flag
			-- P_Non_Picking_Flag            => l_batch_grp_rec.Non_Picking_Flag,
			p_categorySetID             => l_batch_grp_rec.category_set_id,
			p_categoryID                 => l_batch_grp_rec.category_id,
			p_ship_set_smc_flag           => l_batch_grp_rec.ship_set_smc_flag,
		       -- Bug#: 3266659 - Adding the  columns like zone, region, delivery criteria, release
		       --		  subinventory and append flag
			p_regionID		      => l_batch_grp_rec.region_id,
			p_zoneId		      => l_batch_grp_rec.zone_id,
			p_acDelivCriteria	      => l_batch_grp_rec.ac_delivery_criteria,
			p_RelSubinventory             => l_batch_grp_rec.rel_subinventory,
			p_append_flag		      => l_batch_grp_rec.append_flag,
                        p_task_priority               => l_batch_grp_rec.task_priority,
                        p_actual_departure_date => l_batch_grp_rec.actual_departure_date,
                        p_allocation_method           => l_batch_grp_rec.allocation_method,  -- X-dock
                        p_crossdock_criteria_id       => l_batch_grp_rec.crossdock_criteria_id,  -- X-dock
                        p_dynamic_replenishment_flag       => l_batch_grp_rec.dynamic_replenishment_flag, --bug# 6689448 (replenishment project)
                        p_client_id                   => l_batch_grp_rec.client_id -- LSP PROJECT :
			);

  IF l_debug_on	THEN
  --{
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  --}
  END IF;
  --
  wsh_util_core.api_post_call(
        p_return_status => l_return_status,
	x_num_warnings  => l_number_of_warnings,
	x_num_errors    => l_number_of_errors,
	p_msg_data      => l_msg_data
	 );

  x_batch_id := l_batch_grp_rec.batch_id ;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
  --{
     COMMIT WORK;
  --}
  END IF;

  FND_MSG_PUB.Count_And_Get
      (
 	p_count	=>  x_msg_count,
 	p_data	=>  x_msg_data,
 	p_encoded => FND_API.G_FALSE
      );

  IF l_debug_on THEN
  --{
     WSH_DEBUG_SV.pop(l_module_name);
  --}
  END IF;
  --
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	     ROLLBACK TO PICKING_BATCH_GRP;
	     x_return_status :=	FND_API.G_RET_STS_ERROR	;
	     wsh_util_core.add_message(x_return_status);
	     FND_MSG_PUB.Count_And_Get
		 (
		   p_count  => x_msg_count,
		   p_data  =>  x_msg_data,
		   p_encoded =>	FND_API.G_FALSE
		  );

	    IF l_debug_on THEN
	    --{
		WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
	    --}
	    END	IF;
            --

	WHEN WSH_INVALID_CONSOL_DEL THEN
	     ROLLBACK TO PICKING_BATCH_GRP;
             FND_MESSAGE.SET_NAME('WSH', 'WSH_PUB_CONSOL_DEL_PR');
             FND_MESSAGE.SET_TOKEN('PARAMETER',l_batch_in_rec.Delivery_id);
	     x_return_status :=	FND_API.G_RET_STS_ERROR	;
	     wsh_util_core.add_message(x_return_status);
	     FND_MSG_PUB.Count_And_Get
		 (
		   p_count  => x_msg_count,
		   p_data  =>  x_msg_data,
		   p_encoded =>	FND_API.G_FALSE
		  );

	    IF l_debug_on THEN
	    --{
		WSH_DEBUG_SV.logmsg(l_module_name,'WSH_PUB_CONSOL_DEL_PR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_PUB_CONSOL_DEL_PR');
	    --}
	    END	IF;
            --

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     ROLLBACK TO PICKING_BATCH_GRP;
	     x_return_status :=	FND_API.G_RET_STS_UNEXP_ERROR ;
	     wsh_util_core.add_message(x_return_status,	l_module_name);
	     FND_MSG_PUB.Count_And_Get
		 (
		    p_count  =>	x_msg_count,
		    p_data  =>	x_msg_data,
		    p_encoded => FND_API.G_FALSE
		 );
		  --

	    IF l_debug_on THEN
	    --{
		WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has	occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
	    --}
	    END	IF;
       WHEN OTHERS THEN
	    ROLLBACK TO	PICKING_BATCH_GRP;
	    wsh_util_core.default_handler('WSH_PICKING_BATCHES_PUB.CREATE_BATCH');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get
		(
		    p_count  =>	x_msg_count,
		    p_data  =>	x_msg_data,
		    p_encoded => FND_API.G_FALSE
		 );

	    IF l_debug_on THEN
	    --{
	       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.	Oracle error message is	'|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	    --}
	    END	IF;
            --
END Create_Batch;


--============================================================================================
-- Start of comments
--
-- API Name          : Release_Batch
-- Type              : Group
-- Pre-reqs          : None.
-- Function          : The procedure takes in a Batch_id/ Batch_name and depending on the p_release_mode
--                     value it process the batch.   p_log_level value should be greator than 0 when
--                     customer want to get the pick release log fine incace of concurrent pick release
--                     release.
--                     It will do some basic validations on the  the input parameters
--                     like log_level should be positive  , and on the not null values of p_batch_rec.
--
-- PARAMETERS        : p_api_version_number    known api version  number
--                     p_init_msg_list         FND_API.G_TRUE to reset list
--                     p_commit                FND_API.G_TRUE to perform a commit
--                     x_return_status         return status
--                     x_msg_count             number of messages in the list
--                     x_msg_data              text of messages
--                     p_batch_id              Picking Batch Id which is used to get Batch
--					       information from the wsh_picking_batches table.
--                     p_batch_name            Picking Batch Name which is used to get Batch
--					       information from the wsh_picking_batches table.
--                     p_log_level             Controlls the log message generated by cuncurrent
--					       pick release process.
--                     p_release_mode          Used to do ONLINE or CONCURRENT pick release,
--                                             Default is "CONCURREN"
--                     p_num_workers           Number of Workers for Parallel Pick Release
--                                             Default is 1 -- Bug # 7505524.
--                                             For Online Mode it is always 1
--                                             For Concurrent Mode the value is determined by profile
--                     x_request_id            Out parameter contains the request Id for the concurrent request submitted
-- VERSION           : current version         1.0
--                     initial version         1.0
-- End of comments
--============================================================================================

PROCEDURE Release_Batch (
         -- Standard parameters
         p_api_version_number IN   NUMBER,
         p_init_msg_list      IN   VARCHAR2   DEFAULT  NULL,
         p_commit             IN   VARCHAR2   DEFAULT  NULL,
         x_return_status      OUT  NOCOPY     VARCHAR2,
         x_msg_count          OUT  NOCOPY     NUMBER,
         x_msg_data           OUT  NOCOPY     VARCHAR2,

         -- program specific paramters.
         p_batch_id           IN   NUMBER    DEFAULT  NULL,
	 p_batch_name         IN   VARCHAR2    DEFAULT  NULL,
         p_log_level          IN   NUMBER    DEFAULT  NULL,
	 p_release_mode       IN   VARCHAR2  DEFAULT  'CONCURRENT',
	-- p_num_workers        IN   NUMBER    , -- Bug # 7505524
	 x_request_id         OUT  NOCOPY    NUMBER
        ) IS

-- Standard call to check for call compatibility
l_api_version	     CONSTANT NUMBER :=	1.0;
l_api_name	     CONSTANT VARCHAR2(30) := 'WSH_PICKING_BATCHES_GRP';
l_return_status		      VARCHAR2(30);
l_msg_count		      NUMBER;
l_msg_data		      VARCHAR2(32767);
l_number_of_errors	      NUMBER :=	0;
l_number_of_warnings	      NUMBER :=	0;
l_debug_on BOOLEAN;
--
l_batch_id            NUMBER;
l_batch_name          VARCHAR2(30);
l_pick_result         VARCHAR2(30);
l_pick_phase          VARCHAR2(30);
l_pick_skip           VARCHAR2(30);
l_log_level           NUMBER;
l_num_workers         NUMBER; -- bug # 7505524

l_module_name CONSTANT VARCHAR2(100) :=	'wsh.plsql.' ||	G_PKG_NAME || '.' || 'RELEASE_BATCH';
--

BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on :=	WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on	IS NULL	 THEN
  --{
     l_debug_on	:= WSH_DEBUG_SV.is_debug_enabled;
  --}
  END IF;
  --
  SAVEPOINT PICKING_BATCH_GRP;

  -- Standard begin of API savepoint
  --
  -- Debug Statements
  --
  IF l_debug_on	THEN
  --{
     wsh_debug_sv.push(l_module_name);
     --
     wsh_debug_sv.LOG(l_module_name, 'P_API_VERSION_NUMER', p_api_version_number);
     wsh_debug_sv.LOG(l_module_name, 'P_INIT_MSG_LIST',	p_init_msg_list);
     wsh_debug_sv.LOG(l_module_name, 'P_COMMIT', p_commit);
     --wsh_debug_sv.LOG(l_module_name, 'P_NUM_WORKERS', p_num_workers); --  Bug # 7505524.
  --}
  END IF;

  IF NOT fnd_api.compatible_api_call(
		 l_api_version,
		 p_api_version_number,
		 l_api_name,
		 g_pkg_name)   THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
  -- Check p_init_msg_list
  IF fnd_api.to_boolean(p_init_msg_list) THEN
  --{
      fnd_msg_pub.initialize;
  --}
  END IF;
  x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_batch_id      :=  p_batch_id;
  l_batch_name    :=  p_batch_name;
  l_log_level     :=  p_log_level;


------------------------------------------------------------------------------------------------------------
-- VALIDATE ALL	THE INPUT VALUES
------------------------------------------------------------------------------------------------------------

-- Validating Batch Name and Batch Id
  IF ( ( l_batch_Id IS NOT NULL AND l_batch_Id <> FND_API.G_MISS_NUM ) OR ( l_batch_Name IS NOT NULL AND l_batch_name <>  FND_API.G_MISS_CHAR ) ) THEN
  --{
     IF ( l_batch_Id = FND_API.G_MISS_NUM ) THEN
     --{
        l_batch_Id := NULL;
     --}
     END IF;
     IF ( l_batch_name =  FND_API.G_MISS_CHAR ) THEN
     --{
        l_batch_name := NULL;
     --}
     END IF;
     IF ( ( l_batch_Id IS NOT NULL) OR ( l_batch_name IS NOT NULL ) ) THEN
     --{
        WSH_UTIL_VALIDATE.Validate_Picking_Batch_Name(
	      p_picking_batch_Id	=> l_batch_Id,
	      p_picking_batch_name      => l_batch_Name,
	      x_return_status           => l_return_status);

        IF l_debug_on THEN
	--{
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        --}
	END IF;
        --
        wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
     --}
     END IF;
  ELSE
     --
     --
     FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
     FND_MESSAGE.SET_TOKEN('FIELD_NAME ',' BATCH_ID OR BATCH_NAME ');
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     wsh_util_core.add_message(x_return_status);
     return;
  --}
  END IF;

-- End of Batch Name Validations

-- Validating the Release Mode
  IF ( ( p_release_mode IS NULL ) OR ( p_release_mode NOT IN ('CONCURRENT','ONLINE'))) THEN
  --{
    FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','P_RELEASE_MODE');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    return;
  --}
  END IF;
-- End of Validating the Release Mode

-- Validating the Log Level
  IF ( l_log_level <> 0 ) THEN
  --{
     WSH_UTIL_VALIDATE.Validate_Negative(
           	       p_value => l_log_level,
	               x_return_status  => l_return_status);

     IF l_debug_on THEN
     --{
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     --}
     END IF;
     --
     wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_number_of_warnings,
               x_num_errors    => l_number_of_errors,
               p_msg_data      => l_msg_data
               );
  --}
  END IF;
-- End of Log Level Validation


  IF ( p_release_mode = 'CONCURRENT' ) THEN
  --{
      -- Bug # 7505524: Copied the following validation code from the
  --                   public API WSH_PICKING_BATCHES_PUB.release_batch.
      l_num_workers := NVL(FND_PROFILE.Value('WSH_PR_NUM_WORKERS'), 1);

      IF l_debug_on THEN
      --{
         WSH_DEBUG_SV.log(l_module_name,'l_num_workers',l_num_workers);
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling  program unit WSH_PICKING_BATCHES_PKG.SUBMIT_RELEASE_REQUEST',WSH_DEBUG_SV.C_PROC_LEVEL);
      --}
      END IF;
      --
      x_request_id := WSH_PICKING_BATCHES_PKG.Submit_Release_Request(
							p_batch_id       => l_batch_id,
		 		                        p_log_level      => l_log_level,
		 		                        p_num_workers    => l_num_workers); -- bug # 7505524
      IF l_debug_on THEN
      --{
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling  program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      --}
      END IF;
     --
     wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors,
	   p_msg_data      => l_msg_data
	    );

     IF ( x_request_id > 0) THEN
     --{
        FND_MESSAGE.SET_NAME('ONT','SO_OTHER_CONCURRENT_REQUEST_ID');
        FND_MESSAGE.SET_TOKEN('REQUESTID',TO_CHAR(x_request_id));
     ELSE
       FND_MESSAGE.SET_NAME('WSH','WSH_PR_REVOKED');
       FND_MESSAGE.SET_NAME('ONT','SO_SH_NO_CREATE_PICK_SLIPS');
     --}
     END IF;

  ELSE
     IF l_debug_on THEN
     --{
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling  program unit WSH_PICK_LIST.ONLINE_RELEASE',WSH_DEBUG_SV.C_PROC_LEVEL);
     --}
     END IF;
     --
     WSH_PICK_LIST.Online_Release(
                      p_batch_id       => l_batch_id,
		      p_pick_result    => l_pick_result,
		      p_pick_phase     => l_pick_phase,
  		      p_pick_skip      => l_pick_skip);

     IF l_debug_on THEN
     --{
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling  program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     --}
     END IF;
     --
     wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_number_of_warnings,
           x_num_errors    => l_number_of_errors,
	   p_msg_data      => l_msg_data
	    );


     IF (nvl(l_pick_result,'F') = 'F' ) then
     --{
        IF (nvl(l_pick_phase,'START') ='MOVE_ORDER_LINES') then
	--{
           FND_MESSAGE.SET_NAME('WSH','WSH_PR_ONLINE_PARTIAL');
           FND_MESSAGE.SET_TOKEN('MOVE_ORDER', l_batch_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   wsh_util_core.add_message(x_return_status,l_module_name);
        ELSE
	   FND_MESSAGE.SET_NAME('WSH','WSH_PR_ONLINE_FAILED');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   wsh_util_core.add_message(x_return_status,l_module_name);
        --}
	END IF;
      ELSIF (nvl(l_pick_result, 'F') = 'W') then
        IF (nvl(l_pick_phase,'START') ='MOVE_ORDER_LINES') then
	--{
            FND_MESSAGE.SET_NAME('WSH','WSH_PR_ONLINE_PART_WARN');
            -- bug# 8340984 : Changed error to warning here (same behavior when performed
            --       pick release through release sales orders form)
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
 	    wsh_util_core.add_message(x_return_status,l_module_name);
        ELSE
          FND_MESSAGE.SET_NAME('WSH','WSH_PR_ONLINE_WARN');
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	  wsh_util_core.add_message(x_return_status,l_module_name);
        --}
	END IF;
     ELSE
        FND_MESSAGE.SET_NAME('WSH','WSH_PR_ONLINE_SUCCESS');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	wsh_util_core.add_message(x_return_status,l_module_name);
     --}
     END IF;
  --}
  END IF;


  IF l_debug_on	THEN
  --{
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  --}
  END IF;
  --
  wsh_util_core.api_post_call(
        p_return_status => l_return_status,
	x_num_warnings  => l_number_of_warnings,
	x_num_errors    => l_number_of_errors,
	p_msg_data      => l_msg_data
	 );

  IF FND_API.TO_BOOLEAN(p_commit) THEN
  --{
     COMMIT WORK;
  --}
  END IF;

  FND_MSG_PUB.Count_And_Get
      (
 	p_count	=>  x_msg_count,
 	p_data	=>  x_msg_data,
 	p_encoded => FND_API.G_FALSE
      );

  IF l_debug_on THEN
  --{
     WSH_DEBUG_SV.pop(l_module_name);
  --}
  END IF;
  --
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	     ROLLBACK TO PICKING_BATCH_GRP;
	     x_return_status :=	FND_API.G_RET_STS_ERROR	;
	     wsh_util_core.add_message(x_return_status);
	     FND_MSG_PUB.Count_And_Get
		 (
		   p_count  => x_msg_count,
		   p_data  =>  x_msg_data,
		   p_encoded =>	FND_API.G_FALSE
		  );

	    IF l_debug_on THEN
	    --{
		WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
	    --}
	    END	IF;
             --

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     ROLLBACK TO PICKING_BATCH_GRP;
	     x_return_status :=	FND_API.G_RET_STS_UNEXP_ERROR ;
	     wsh_util_core.add_message(x_return_status,	l_module_name);
	     FND_MSG_PUB.Count_And_Get
		 (
		    p_count  =>	x_msg_count,
		    p_data  =>	x_msg_data,
		    p_encoded => FND_API.G_FALSE
		 );
		  --

	    IF l_debug_on THEN
	    --{
		WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has	occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
	    --}
	    END	IF;
       WHEN OTHERS THEN
	    ROLLBACK TO	PICKING_BATCH_GRP;
	    wsh_util_core.default_handler('WSH_PICKING_BATCHES_GRP.RELEASE_BATCH');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get
		(
		    p_count  =>	x_msg_count,
		    p_data  =>	x_msg_data,
		    p_encoded => FND_API.G_FALSE
		 );

	    IF l_debug_on THEN
	    --{
	       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.	Oracle error message is	'|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	    --}
	    END	IF;
             --
END Release_Batch;

-- Bug 7505524 : Added a new api release_wms_wave
--============================================================================================
-- Start of comments
--
-- API Name          : release_wms_wave
-- Type              : Group
-- Pre-reqs          : None.
-- Function          : The procedure takes in a pick wave header id, pick release batch information and
--                     pick release mode. It creates new picking batch with the information provided in picking batch
--                     record. It creates the picking batch with delivery_detail_id of picking batch value as -1 so
--                     that while pick releasing it considers all delivery detail lines with the batch id stamped.
--                     Updates new batch id value on all delivery detail lines which are eligible for pick release
--                     and associated to the pick wave header id passed. Pick releases the batch created in the
--                     pick release mode(ONLINE/CONCURRENT) passed via p_release_mode.
--                     Sends the batch id and concurrent request number of pick release request to the caller.
--
-- PARAMETERS        : p_batch_rec             Contains the all the parameters for the batch
--                     p_release_mode          Used to do ONLINE or CONCURRENT pick release,
--                                             Default is "CONCURREN"
--                     p_pick_wave_header_id   pick wave header id value.
--                     x_return_status         return status
--                     x_msg_count             number of messages in the list
--                     x_msg_data              text of messages
--                     x_batch_id              Out parameter contains the batch id created
--                     x_request_id            Out parameter contains the request Id for the pick release
--                                             concurrent request submitted

-- End of comments
--============================================================================================

PROCEDURE release_wms_wave(
            p_batch_rec              IN   WSH_PICKING_BATCHES_PUB.Batch_Info_Rec,
            p_release_mode           IN   VARCHAR2  DEFAULT 'CONCURRENT',
            p_pick_wave_header_id    IN   NUMBER,
            x_batch_id               OUT  NOCOPY   NUMBER,
            x_request_id             OUT  NOCOPY   NUMBER,
            x_return_status          OUT  NOCOPY   VARCHAR2,
            x_msg_count              OUT  NOCOPY   NUMBER,
            x_msg_data               OUT  NOCOPY   VARCHAR2
            ) IS

CURSOR c_get_dds_for_wave (c_pick_wave_header_id NUMBER) IS
SELECT wdd.delivery_detail_id
FROM   wsh_delivery_details wdd,
       wms_wp_wave_lines wpl,
       wms_wp_wave_headers_vl wph
WHERE  wdd.delivery_detail_id = wpl.delivery_detail_id
AND    wpl.wave_header_id = c_pick_wave_header_id
AND    wpl.wave_header_id=wph.wave_header_id
AND    nvl(wpl.remove_from_wave_flag,'N') <> 'Y'
AND    (wph.wave_Status in ('Planned','Created') or (wph.wave_status = 'Released' and Re_release_flag = 'Y'))
AND    wdd.released_status in ('R', 'B', 'X')
AND    NVL(wdd.replenishment_status,'C') = 'C';

record_locked  EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);

l_batch_rec       WSH_PICKING_BATCHES_PUB.Batch_Info_Rec;
l_dd_tbl          WSH_UTIL_CORE.id_tab_type;
l_batch_id        NUMBER;
l_request_id      NUMBER;
l_log_level       NUMBER := 0;
l_tot_fetch       NUMBER;
l_pre_fetch       NUMBER;
l_cur_fetch       NUMBER;
l_batch_size      NUMBER :=5;
l_tot_upd_dds     NUMBER := 0;
l_dd_upd_tbl      WSH_UTIL_CORE.id_tab_type;
l_return_status   VARCHAR2(1);
l_temp_rec        WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
l_num_errors      NUMBER;
--
l_debug_on        BOOLEAN;
--
l_module_name     CONSTANT VARCHAR2(100) :=	'wsh.plsql.' ||	G_PKG_NAME || '.' || 'release_wms_wave';
--
BEGIN
--{
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
        l_debug_on	:= WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    savepoint create_batch;
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        l_log_level := 1;
        wsh_debug_sv.LOG(l_module_name, 'p_release_mode', p_release_mode);
        wsh_debug_sv.LOG(l_module_name, 'p_pick_wave_header_id', p_pick_wave_header_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_GRP.Create_Batch',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --pass delivery detail id as -1 as dd's are getting updated with batch id.
    l_batch_rec := p_batch_rec;
    l_batch_rec.Delivery_Detail_Id := -1;
    WSH_PICKING_BATCHES_GRP.Create_Batch(
        p_api_version_number => 1.1,
        p_batch_rec          => l_batch_rec,
        x_batch_id           => l_batch_id,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
        );
    IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'WSH_PICKING_BATCHES_GRP.Create_Batch return status', l_return_status);
        wsh_debug_sv.LOG(l_module_name, 'l_batch_id', l_batch_id);
    END IF;
    --
    IF NVL(l_batch_id,0) = 0 OR l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING)  THEN
    --{
        IF NVL(l_batch_id,0) = 0 AND l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        --{
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        ELSE
            x_return_status := l_return_status;
        --}
        END IF;
        x_batch_id      := NULL;
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
    --}
    END IF;
    --
    -- Updating batch Id value on WDD records associated to the pick wave header.
    savepoint update_batch_id_on_dd;
    --
    l_tot_fetch := 0;
    OPEN c_get_dds_for_wave (p_pick_wave_header_id);
    LOOP
    --{
        l_pre_fetch := l_tot_fetch;
        FETCH c_get_dds_for_wave BULK COLLECT INTO l_dd_tbl LIMIT l_batch_size;
        l_tot_fetch := c_get_dds_for_wave%ROWCOUNT;
        l_cur_fetch := l_tot_fetch - l_pre_fetch;
        EXIT WHEN ( l_cur_fetch <= 0);
        FOR i in 1..l_dd_tbl.COUNT LOOP
            BEGIN
                savepoint lock_delivery_detail_loop;
                WSH_DELIVERY_DETAILS_PKG.lock_detail_no_compare(p_delivery_detail_id  => l_dd_tbl(i));
                l_dd_upd_tbl(l_dd_upd_tbl.COUNT + 1) := l_dd_tbl(i);
            EXCEPTION
                WHEN app_exception.application_exception or app_exception.record_lock_exception THEN
                    rollback to lock_delivery_detail_loop;
                    FND_MESSAGE.SET_NAME('WSH', 'WSH_DLVB_LOCK_FAILED');
  	            FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_dd_tbl(i));
                    wsh_util_core.add_message(wsh_util_core.g_ret_sts_error, l_module_name);
                    l_num_errors := l_num_errors + 1;
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'Unable to obtain lock on the Delivery Detail Id',l_dd_tbl(i));
                    END IF;
                     --
                WHEN others THEN
                    rollback to lock_delivery_detail_loop;
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END;
        --
        END LOOP;
        --Update the detail lines with batch id.
        FORALL i in 1..l_dd_upd_tbl.count
        UPDATE wsh_delivery_details
        SET    batch_id          = l_batch_id,
               last_updated_by   = fnd_global.user_id,
               last_update_date  = SYSDATE,
               last_update_login = fnd_global.login_id
        WHERE  delivery_detail_id = l_dd_upd_tbl(i);
        l_tot_upd_dds := l_tot_upd_dds + sql%rowcount;
        IF l_debug_on THEN
            wsh_debug_sv.LOG(l_module_name, 'SQl updated',sql%rowcount);
        END IF;
    --}
    END LOOP;
    --
    CLOSE c_get_dds_for_wave;
    --
    IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'Total number of delivery details selected',l_tot_fetch);
        wsh_debug_sv.LOG(l_module_name, 'Total number of delivery details selected after locking',l_tot_upd_dds);
    END IF;
    IF l_tot_fetch = 0 THEN
    --{
        IF l_debug_on THEN
            wsh_debug_sv.LOG(l_module_name, 'There are no eligible delivery lines for the pick release',l_tot_fetch);
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        RETURN;
    --}
    END IF;
    IF l_tot_upd_dds < l_tot_fetch THEN
    --{
        IF l_debug_on THEN
            wsh_debug_sv.LOG(l_module_name, 'Number of delivery detail lines failed while locking',l_tot_fetch-l_tot_upd_dds);
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --}
    END IF;


    -- Call the pick release code only if there are one or more pick release eligible delivery lines.
    IF (l_tot_upd_dds > 0) THEN
    --{
        IF l_debug_on	THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_PUB.RELEASE_BATCH',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_PICKING_BATCHES_GRP.release_batch(
            p_api_version_number => 1.1,
            p_batch_id           => l_batch_id,
            p_log_level          => l_log_level,
            p_release_mode       => p_release_mode,
            x_return_status      => l_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_request_id         => l_request_id);
        IF l_debug_on THEN
            wsh_debug_sv.LOG(l_module_name, 'WSH_PICKING_BATCHES_GRP.release_batch return status:', l_return_status);
            wsh_debug_sv.LOG(l_module_name, 'pick release concurrent req.id:',l_request_id);
        END IF;
        IF ((l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING))
             AND ( p_release_mode='ONLINE' OR nvl(l_request_id,0) = 0 )) THEN
        --{
            ROLLBACK TO update_batch_id_on_dd;
        --}
        END IF;
        --
        x_batch_id      := l_batch_id;
        x_request_id    := l_request_id;
        x_return_status := l_return_status;
    ELSE  -- Get debug msgs when all dds failed while locking
        FND_MSG_PUB.Count_And_Get(
            p_count =>  x_msg_count,
            p_data  =>  x_msg_data,
            p_encoded => FND_API.G_FALSE
            );
    --}
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
    WHEN Others THEN
        ROLLBACK TO create_batch;
        WSH_UTIL_CORE.Default_Handler ('WSH_PICKING_BATCHES_GRP.release_wms_wave');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF c_get_dds_for_wave%ISOPEN THEN
            CLOSE c_get_dds_for_wave;
        END IF;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END release_wms_wave;

END WSH_PICKING_BATCHES_GRP;

/
