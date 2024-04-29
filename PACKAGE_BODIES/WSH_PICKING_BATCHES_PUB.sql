--------------------------------------------------------
--  DDL for Package Body WSH_PICKING_BATCHES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PICKING_BATCHES_PUB" AS
/* $Header: WSHPRPBB.pls 120.3.12010000.3 2009/12/03 14:23:11 gbhargav ship $ */

--
-- Package Variables
--
--===================
-- CONSTANTS
--===================
--
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PICKING_BATCHES_PUB';
-- add your constants here if any
--
--
--===================
-- PROCEDURES
--===================

   --===================================================================================================
   -- Start of comments
   --
   -- API Name          : Create_Batch
   -- Type		: Public
   -- Purpose
   -- Pre-reqs	        : None.
   -- Function          : The procedure takes in a rule_id / rule_name and brings up the default
   --                     values for a new batch to be created.
   --                     It then uses the information in the in parameter p_batch_rec and replaces the
   --                     values it picked up from the rule with the not null members of p_batch_rec
   --                     It then creates a new batch_id and inserts a new batch in the picking batch table
   --                     It will do some basic validations on the  the input parameters

   --
   -- PARAMETERS        : p_api_version_number    known api version  number
   --                     p_init_msg_list         FND_API.G_TRUE to reset list
   --                     p_commit                FND_API.G_TRUE to perform a commit
   --                     x_return_status         return status
   --			  x_msg_count             number of messages in the list
   --			  x_msg_data              text of messages
   --	                  p_rule_id               Pick Release Rule Id --For Defaulting purpose
   --			  p_rule_name             Pick Release Rule Name --For Defaulting purpose
   --			  p_batch_rec             which contains all the Picking Batch parameters.
   --                     p_batch_prefix          Which used to prefix for the Batch Name
   --                                             i.e, Batch_Name becomes p_batch_prefix-batch_id
   --                     x_batch_id              Returns the batch Id created
   -- VERSION          :  current version         1.0
   --                     initial version         1.0
   -- End of comments
   --===================================================================================================

PROCEDURE Create_Batch (
         -- Standard parameters
         p_api_version        IN   NUMBER,
         p_init_msg_list      IN   VARCHAR2  DEFAULT NULL,
         p_commit             IN   VARCHAR2  DEFAULT NULL,
         x_return_status      OUT NOCOPY     VARCHAR2,
         x_msg_count          OUT NOCOPY     NUMBER,
         x_msg_data           OUT NOCOPY     VARCHAR2,

         -- program specific paramters.
         p_rule_id            IN   NUMBER   DEFAULT NULL,
	     p_rule_name          IN   VARCHAR2 DEFAULT NULL,
         p_batch_rec          IN   WSH_PICKING_BATCHES_PUB.Batch_Info_Rec ,
         p_batch_prefix       IN   VARCHAR2 DEFAULT NULL ,
         x_batch_id           OUT  NOCOPY   NUMBER

 ) IS



l_api_version        CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'WSH_PICKING_BATCHES_PUB';

l_return_status VARCHAR2(30)  := NULL;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_errors          NUMBER := 0;
l_number_of_warnings        NUMBER := 0;

l_rule_id                   NUMBER;
l_rule_name                 VARCHAR2(150);
l_batch_rec                 WSH_PICKING_BATCHES_PUB.Batch_Info_Rec;
l_batch_prefix              VARCHAR2(30);
l_batch_id                  NUMBER;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_BATCH';
--

BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL  THEN
  --{
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  --}
  END IF;
  --
  SAVEPOINT PICKING_BATCH_PUB;
  IF l_debug_on THEN
  --{
	WSH_DEBUG_SV.push(l_module_name);
	--
        WSH_DEBUG_SV.logmsg(l_module_name,'CREATE_BATCH BEING CALLED WITH FOLLOWING PARAMETERS');
        WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
        WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
	WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
	WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
	WSH_DEBUG_SV.log(l_module_name,'P_RULE_ID',P_RULE_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_RULE_NAME',P_RULE_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_BATCH_PREFIX',P_BATCH_PREFIX);
	WSH_DEBUG_SV.log(l_module_name,'P_BACKORDERS_ONLY_FLAG',P_BATCH_REC.BACKORDERS_ONLY_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SET_ID',P_BATCH_REC.DOCUMENT_SET_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SET_NAME',P_BATCH_REC.DOCUMENT_SET_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_EXISTING_RSVS_ONLY_FLAG',P_BATCH_REC.EXISTING_RSVS_ONLY_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_PRIORITY_CODE',P_BATCH_REC.SHIPMENT_PRIORITY_CODE);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_BATCH_REC.SHIP_METHOD_CODE);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_NAME',P_BATCH_REC.SHIP_METHOD_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_BATCH_REC.CUSTOMER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_NUMBER',P_BATCH_REC.CUSTOMER_NUMBER);
	WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_BATCH_REC.ORDER_HEADER_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER',P_BATCH_REC.ORDER_NUMBER);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_ID',P_BATCH_REC.SHIP_SET_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_NUMBER',P_BATCH_REC.SHIP_SET_NUMBER);
	WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_BATCH_REC.INVENTORY_ITEM_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE_ID',P_BATCH_REC.ORDER_TYPE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE_NAME',P_BATCH_REC.ORDER_TYPE_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_FROM_REQUESTED_DATE',P_BATCH_REC.FROM_REQUESTED_DATE);
	WSH_DEBUG_SV.log(l_module_name,'P_TO_REQUESTED_DATE',P_BATCH_REC.TO_REQUESTED_DATE);
	WSH_DEBUG_SV.log(l_module_name,'P_FROM_SCHEDULED_SHIP_DATE',P_BATCH_REC.FROM_SCHEDULED_SHIP_DATE);
	WSH_DEBUG_SV.log(l_module_name,'P_TO_SCHEDULED_SHIP_DATE',P_BATCH_REC.TO_SCHEDULED_SHIP_DATE);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_LOCATION_ID',P_BATCH_REC.SHIP_TO_LOCATION_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_LOCATION_ID',P_BATCH_REC.SHIP_FROM_LOCATION_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_BATCH_REC.TRIP_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_TRIP_NAME',P_BATCH_REC.TRIP_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_BATCH_REC.DELIVERY_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_BATCH_REC.DELIVERY_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_INCLUDE_PLANNED_LINES',P_BATCH_REC.INCLUDE_PLANNED_LINES);
	WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_ID',P_BATCH_REC.PICK_GROUPING_RULE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_NAME',P_BATCH_REC.PICK_GROUPING_RULE_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQUENCE_RULE_ID',P_BATCH_REC.PICK_SEQUENCE_RULE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQUENCE_RULE_NAME',P_BATCH_REC.PICK_SEQUENCE_RULE_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_AUTOCREATE_DELIVERY_FLAG',P_BATCH_REC.AUTOCREATE_DELIVERY_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_BATCH_REC.ATTRIBUTE_CATEGORY);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_BATCH_REC.ATTRIBUTE1);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_BATCH_REC.ATTRIBUTE2);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_BATCH_REC.ATTRIBUTE3);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_BATCH_REC.ATTRIBUTE4);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_BATCH_REC.ATTRIBUTE5);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_BATCH_REC.ATTRIBUTE6);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_BATCH_REC.ATTRIBUTE7);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_BATCH_REC.ATTRIBUTE8);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_BATCH_REC.ATTRIBUTE9);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_BATCH_REC.ATTRIBUTE10);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_BATCH_REC.ATTRIBUTE11);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_BATCH_REC.ATTRIBUTE12);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_BATCH_REC.ATTRIBUTE13);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_BATCH_REC.ATTRIBUTE14);
	WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_BATCH_REC.ATTRIBUTE15);
	WSH_DEBUG_SV.log(l_module_name,'P_AUTODETAIL_PR_FLAG',P_BATCH_REC.AUTODETAIL_PR_FLAG);
	-- Bug#: 3266659 - Removing carrier params
	-- WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_ID',P_BATCH_REC.CARRIER_ID);
        -- WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_NAME',P_BATCH_REC.CARRIER_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_STOP_ID',P_BATCH_REC.TRIP_STOP_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_STOP_LOCATION_ID',P_BATCH_REC.TRIP_STOP_LOCATION_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_SUBINVENTORY',P_BATCH_REC.DEFAULT_STAGE_SUBINVENTORY);
	WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_STAGE_LOCATOR_ID',P_BATCH_REC.DEFAULT_STAGE_LOCATOR_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_SUBINVENTORY',P_BATCH_REC.PICK_FROM_SUBINVENTORY);
	WSH_DEBUG_SV.log(l_module_name,'P_PICK_FROM_LOCATOR_ID',P_BATCH_REC.PICK_FROM_LOCATOR_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_AUTO_PICK_CONFIRM_FLAG',P_BATCH_REC.AUTO_PICK_CONFIRM_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_BATCH_REC.DELIVERY_DETAIL_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_PROJECT_ID',P_BATCH_REC.PROJECT_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_TASK_ID',P_BATCH_REC.TASK_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_BATCH_REC.ORGANIZATION_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_CODE',P_BATCH_REC.ORGANIZATION_CODE);
	WSH_DEBUG_SV.log(l_module_name,'P_CONFIRM_RULE_ID',P_BATCH_REC.SHIP_CONFIRM_RULE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_CONFIRM_RULE_NAME',P_BATCH_REC.SHIP_CONFIRM_RULE_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_AUTOPACK_FLAG',P_BATCH_REC.AUTOPACK_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_AUTOPACK_LEVEL',P_BATCH_REC.AUTOPACK_LEVEL);
	WSH_DEBUG_SV.log(l_module_name,'P_TASK_PLANNING_FLAG',P_BATCH_REC.TASK_PLANNING_FLAG);
	-- Bug#: 3266659 - Removing carrier params
	-- WSH_DEBUG_SV.log(l_module_name,'P_NON_PICKING_FLAG',P_BATCH_REC.NON_PICKING_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'P_CATEGORY_SET_ID',P_BATCH_REC.CATEGORY_SET_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_CATEGORY_ID',P_BATCH_REC.CATEGORY_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_SMC_FLAG',P_BATCH_REC.SHIP_SET_SMC_FLAG);
	-- Bug# 3266659: Log messages for added attributes
	WSH_DEBUG_SV.log(l_module_name,'p_region_ID',P_BATCH_REC.region_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_zone_ID',P_BATCH_REC.zone_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ac_Delivery_Criteria',P_BATCH_REC.ac_Delivery_Criteria);
	WSH_DEBUG_SV.log(l_module_name,'P_rel_subinventory',P_BATCH_REC.rel_subinventory);
	WSH_DEBUG_SV.log(l_module_name,'P_append_flag',P_BATCH_REC.append_flag);
	WSH_DEBUG_SV.log(l_module_name,'P_task_priority',P_BATCH_REC.task_priority);
        WSH_DEBUG_SV.log(l_module_name,'Actual Departure Date',
          to_char(p_batch_rec.actual_departure_date, 'DD/MM/YYYY HH24:MI:SS'));
        -- X-dock
	WSH_DEBUG_SV.log(l_module_name,'P_allocation_method',P_BATCH_REC.allocation_method);
	WSH_DEBUG_SV.log(l_module_name,'P_crossdock_criteria_id',P_BATCH_REC.crossdock_criteria_id);
	WSH_DEBUG_SV.log(l_module_name,'P_crossdock_criteria_name',P_BATCH_REC.crossdock_criteria_name);
        -- end of X-dock
        WSH_DEBUG_SV.log(l_module_name,'P_dynamic_replenishment_flag',P_BATCH_REC.dynamic_replenishment_flag); -- bug# 6689448 (replenishment project)
        -- LSP PROJECT
        WSH_DEBUG_SV.log(l_module_name,'P_client_code',P_BATCH_REC.client_code);
        WSH_DEBUG_SV.log(l_module_name,'P_client_id',P_BATCH_REC.client_id);
        -- LSP PROJECT : end
	WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
     --}
     END IF;

  IF NOT FND_API.compatible_api_call( l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
  --{
    FND_MSG_PUB.initialize;
  --}
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_rule_id       :=  p_rule_id;
  l_rule_name     :=  p_rule_name;
  l_batch_rec     :=  p_batch_rec;
  l_batch_prefix  :=  p_batch_prefix;


  IF l_debug_on THEN
  --{
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_GRP.CREATE_BATCH',WSH_DEBUG_SV.C_PROC_LEVEL);
  --}
  END IF;

/* -- Bug # 7505524 :moved the following code to group API
                     WSH_PICKING_BATCHES_GRP.create_batch
  --
  -- X-dock
  -- 1)Validate CrossDock Criteria Name for WMS org.
  --   Always use crossdock_criteria_id except when crossdock_criteria_id is null
  --   and crossdock_criteria_name has been specified
  -- 2)The values of crossdock criteria will be ignored for non-WMS org
  --
  IF WSH_UTIL_VALIDATE.check_wms_org(p_batch_rec.organization_id) = 'Y' THEN
    IF (l_batch_rec.crossdock_criteria_id IS NULL AND
        l_batch_rec.crossdock_criteria_name IS NOT NULL) THEN
      -- derive crossdock criteria id
      WMS_CROSSDOCK_GRP.chk_planxd_crt_id_name
        (p_criterion_id   => l_batch_rec.crossdock_criteria_id,
         p_criterion_name => l_batch_rec.crossdock_criteria_name,
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
  --

  -- ECO 4634966
  IF l_batch_rec.existing_rsvs_only_flag = 'Y' AND
     WSH_UTIL_VALIDATE.check_wms_org(l_batch_rec.organization_id) = 'Y' AND
     l_batch_rec.allocation_method IN (WSH_PICK_LIST.C_CROSSDOCK_ONLY,
                              WSH_PICK_LIST.C_PRIORITIZE_CROSSDOCK,
                              WSH_PICK_LIST.C_PRIORITIZE_INVENTORY) THEN
    ROLLBACK TO PICKING_BATCH_PUB;
    FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_COMBINATION');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;
  -- End of ECO 4634966
Bug # 7505524*/

   WSH_PICKING_BATCHES_GRP.Create_Batch(
            p_api_version_number    => p_api_version,
            p_init_msg_list         => NULL,   --- Treated as False in  Group API
            p_commit                => NULL,   --- Treated as False in Group API
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_rule_id               => l_rule_id ,
            p_rule_name             => l_rule_name ,
	    p_batch_rec             => l_batch_rec,
            p_batch_prefix          => l_batch_prefix,
	    x_batch_id              => l_batch_id);

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

 x_batch_id := l_batch_id;

 IF l_number_of_warnings > 0 THEN
 --{
      x_return_status := wsh_util_core.g_ret_sts_warning;
 --}
 END IF;


 IF FND_API.TO_BOOLEAN(p_commit) THEN
 --{
    COMMIT WORK;
 --}
 END IF;

 FND_MSG_PUB.Count_And_Get
     (
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data,
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
             ROLLBACK TO PICKING_BATCH_PUB;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             wsh_util_core.add_message(x_return_status);
             FND_MSG_PUB.Count_And_Get
                 (
                   p_count  => x_msg_count,
                   p_data  =>  x_msg_data,
                   p_encoded => FND_API.G_FALSE
                  );

            IF l_debug_on THEN
	    --{
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            --}
	    END IF;
            --

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO PICKING_BATCH_PUB;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             wsh_util_core.add_message(x_return_status, l_module_name);
             FND_MSG_PUB.Count_And_Get
                 (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                 );
                  --

            IF l_debug_on THEN
	    --{
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
            --}
	    END IF;
       WHEN OTHERS THEN
            ROLLBACK TO PICKING_BATCH_PUB;
            wsh_util_core.default_handler('WSH_PICKING_BATCHES_PUB.CREATE_BATCH');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get
                (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                 );

            IF l_debug_on THEN
	    --{
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            --}
	    END IF;
            --
 END Create_Batch;
/*
--======================================================================================================
-- Start of comments
--
-- API Name          : Release_Batch
-- Type              : Public
-- Purpose
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
--                     p_release_mode          Returns the batch Id created
--                     x_request_id            Returns the Request Id for concurrent pick release request
-- VERSION           : current version         1.0
--                     initial version         1.0
-- End of comments
--======================================================================================================
*/

PROCEDURE Release_Batch (
         -- Standard parameters
         p_api_version        IN   NUMBER,
         p_init_msg_list      IN   VARCHAR2  DEFAULT  NULL,
         p_commit             IN   VARCHAR2  DEFAULT  NULL,
         x_return_status      OUT  NOCOPY    VARCHAR2,
         x_msg_count          OUT  NOCOPY    NUMBER,
         x_msg_data           OUT  NOCOPY    VARCHAR2,
         -- program specific paramters.
          p_batch_id          IN   NUMBER    DEFAULT NULL,
	  p_batch_name        IN   VARCHAR2    DEFAULT NULL,
          p_log_level         IN   NUMBER    DEFAULT NULL,
	  p_release_mode      IN   VARCHAR2  DEFAULT 'CONCURRENT',
	  x_request_id       OUT  NOCOPY    NUMBER
        )  IS

l_api_version        CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'WSH_PICKING_BATCHES_PUB';

l_return_status VARCHAR2(30)  := NULL;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_errors          NUMBER := 0;
l_number_of_warnings        NUMBER := 0;

l_batch_id                  NUMBER;
l_batch_name                VARCHAR2(60);
l_release_mode              VARCHAR2(20);
l_log_level                 NUMBER;
l_request_id                NUMBER;
-- l_num_workers               NUMBER;   bug # 7505524 :logic is moved to group API

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RELEASE_BATCH';
--

BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL  THEN
  --{
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  --}
  END IF;
  --
  IF l_debug_on THEN
  --{
  --
  	WSH_DEBUG_SV.push(l_module_name);
	--
        WSH_DEBUG_SV.logmsg(l_module_name,'RELEASE_BATCH BEING CALLED WITH FOLLOWING PARAMETERS');
        WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
        WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
	WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
	WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
	WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_BATCH_NAME',P_BATCH_NAME);
	WSH_DEBUG_SV.log(l_module_name,'P_RELEASE_MODE',P_RELEASE_MODE);
	WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);
        WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
  --}
  END IF;
  IF NOT FND_API.compatible_api_call( l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
  --{
    FND_MSG_PUB.initialize;
  --}
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_batch_id       :=  p_batch_id;
  l_batch_name     :=  p_batch_name;
  l_release_mode   :=  p_release_mode;
  l_log_level      :=  p_log_level;

/*  Bug # 7505524: moved the following code to group API
                   WSH_PICKING_BATCHES_GRP.release_batch
  IF l_release_mode = 'CONCURRENT' THEN
     l_num_workers := NVL(FND_PROFILE.Value('WSH_PR_NUM_WORKERS'), 1);
  ELSE
     l_num_workers := 1;
  END IF; */


  IF l_debug_on THEN
  --{
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICKING_BATCHES_GRP.RELASE_BATCH',WSH_DEBUG_SV.C_PROC_LEVEL);
  --}
  END IF;
  --
  WSH_PICKING_BATCHES_GRP.Release_Batch(
            p_api_version_number    => p_api_version,
            p_init_msg_list         => NULL,   --- Treated as False in  Group API
            p_commit                => NULL,   --- Treated as False in Group API
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_batch_id              => l_batch_id,
            p_batch_name            => l_batch_name,
	        p_release_mode          => l_release_mode,
            p_log_level             => l_log_level,
            -- p_num_workers           => l_num_workers, Bug # 7505524
            x_request_id            => l_request_id);

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

 x_request_id := l_request_id;

 IF l_number_of_warnings > 0 THEN
 --{
      x_return_status := wsh_util_core.g_ret_sts_warning;
 --}
 END IF;


 IF FND_API.TO_BOOLEAN(p_commit) THEN
 --{
    COMMIT WORK;
 --}
 END IF;

 FND_MSG_PUB.Count_And_Get
     (
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data,
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
              x_return_status := FND_API.G_RET_STS_ERROR ;
             wsh_util_core.add_message(x_return_status);
             FND_MSG_PUB.Count_And_Get
                 (
                   p_count  => x_msg_count,
                   p_data  =>  x_msg_data,
                   p_encoded => FND_API.G_FALSE
                  );

            IF l_debug_on THEN
	    --{
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            --}
	    END IF;
--

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             wsh_util_core.add_message(x_return_status, l_module_name);
             FND_MSG_PUB.Count_And_Get
                 (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                 );
                  --

            IF l_debug_on THEN
	    --{
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
            --}
	    END IF;
       WHEN OTHERS THEN
             wsh_util_core.default_handler('WSH_PICKING_BATCHES_PUB.RELEASE_BATCH');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get
                (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                 );

            IF l_debug_on THEN
	    --{
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            --}
	    END IF;
            --
END Release_Batch;






-- Start of comments
--
-- API Name          : Get_Batch_Record
-- Type              : Public
-- Purpose
-- Pre-reqs          : None.
-- Function          : The procedure takes in a Batch_id or Batch_name and retrieves
--                     the batch record from wsh_picking_batches.
--                     Note: Non-database attributes will be NULL.
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
--                     x_batch_rec             Batch record from wsh_picking_batches
-- VERSION           : current version         1.0
--                     initial version         1.0
-- End of comments

 PROCEDURE Get_Batch_Record(
         -- Standard parameters
         p_api_version        IN   NUMBER,
         p_init_msg_list      IN   VARCHAR2  DEFAULT NULL,
         p_commit             IN   VARCHAR2  DEFAULT NULL,
         x_return_status      OUT  NOCOPY    VARCHAR2,
         x_msg_count          OUT  NOCOPY    NUMBER,
         x_msg_data           OUT  NOCOPY    VARCHAR2,
         -- program specific paramters.
         p_batch_id           IN   NUMBER     DEFAULT NULL,
         p_batch_name         IN   VARCHAR2   DEFAULT NULL,
         x_batch_rec          OUT  NOCOPY     WSH_PICKING_BATCHES_PUB.Batch_Info_Rec
        ) IS
  l_api_version        CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'WSH_PICKING_BATCHES_PUB';

  l_return_status VARCHAR2(30)  := NULL;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32767);
  l_number_of_errors          NUMBER := 0;
  l_number_of_warnings        NUMBER := 0;

  l_batch_id                  NUMBER;
  l_batch_name                VARCHAR2(60);

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_BATCH_RECORD';
  --
  CURSOR c_batch_info(x_batch_id NUMBER) IS
  SELECT
     Backorders_Only_Flag,
     Document_Set_Id,
     NULL,               -- not in table: document_set_name
     Existing_Rsvs_Only_Flag,
     Shipment_Priority_Code,
     Ship_Method_Code,
     NULL,               -- not in table: ship_method_name
     Customer_Id,
     NULL,               -- not in table: customer_number
     Order_Header_Id,
     NULL,               -- not in table: order_number
     NULL,               -- not in table: ship_set_id
     Ship_Set_Number,
     Inventory_Item_Id,
     Order_Type_Id,
     NULL,               -- not in table: order_type_name
     From_Requested_Date,
     To_Requested_Date,
     From_Scheduled_Ship_Date,
     To_Scheduled_Ship_Date,
     Ship_To_Location_Id,
     NULL,               -- not in table: ship_to_location_code
     Ship_From_Location_Id,
     NULL,               -- not in table: ship_from_location_code
     Trip_Id,
     NULL,               -- not in table: trip_name
     Delivery_Id,
     NULL,               -- not in table: delivery_name
     Include_Planned_Lines,
     Pick_Grouping_Rule_Id,
     NULL,               -- not in table: pick_grouping_rule_name
     Pick_Sequence_Rule_Id,
     NULL,               -- not in table: pick_sequence_rule_name
     Autocreate_Delivery_Flag,
     Attribute_Category,
     Attribute1,
     Attribute2,
     Attribute3,
     Attribute4,
     Attribute5,
     Attribute6,
     Attribute7,
     Attribute8,
     Attribute9,
     Attribute10,
     Attribute11,
     Attribute12,
     Attribute13,
     Attribute14,
     Attribute15,
     Autodetail_Pr_Flag,
     Trip_Stop_Id,
     NULL,               -- not in table: trip_stop_location_id
     Default_Stage_Subinventory,
     Default_Stage_Locator_Id,
     Pick_From_Subinventory,
     Pick_From_locator_Id,
     Auto_Pick_Confirm_Flag,
     Delivery_Detail_Id,
     Project_Id,
     Task_Id,
     Organization_Id,
     NULL,               -- not in table: organization_code
     Ship_Confirm_Rule_Id,
     NULL,               -- not in table: ship_confirm_rule_name
     Autopack_Flag,
     Autopack_Level,
     Task_Planning_Flag,
     Category_Set_ID,
     Category_ID,
     Ship_Set_Smc_Flag,
     region_ID,
     zone_ID,
     ac_Delivery_Criteria,
     rel_subinventory,
     append_flag,
     task_priority,
     actual_departure_date,
     allocation_method, --  X-dock
     crossdock_criteria_id, --  X-dock
     NULL, -- not in the table:crossdock_criteria_name
     dynamic_replenishment_flag,  --bug# 6689448 (replenishment project)
     -- LSP PROJECT :
     client_id,
     NULL
     -- LSP PROJECT :
  FROM wsh_picking_batches
  WHERE batch_id = x_batch_id;

BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL  THEN
  --{
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  --}
  END IF;
  --
  IF l_debug_on THEN
  --{
  --
  	WSH_DEBUG_SV.push(l_module_name);
	--
        WSH_DEBUG_SV.logmsg(l_module_name,'GET_BATCH_RECORD BEING CALLED WITH FOLLOWING PARAMETERS');
        WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
        WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
	WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
	WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
	WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_BATCH_NAME',P_BATCH_NAME);
        WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
  --}
  END IF;
  IF NOT FND_API.compatible_api_call( l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list)  THEN
  --{
    FND_MSG_PUB.initialize;
  --}
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_batch_id       :=  p_batch_id;
  l_batch_name     :=  p_batch_name;

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
     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     return;
  --}
  END IF;

  -- End of Batch Name Validations

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'open cursor c_batch_info for l_batch_id', l_batch_id);
  END IF;

  OPEN  c_batch_info(l_batch_id);
  -- at this time, it should be valid, so the record would be found.
  FETCH c_batch_info INTO x_batch_rec;
  CLOSE c_batch_info;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'RECORD ATTRIBUTES LOOKED UP');
    WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
    WSH_DEBUG_SV.log(l_module_name,'BACKORDERS_ONLY_FLAG',X_BATCH_REC.BACKORDERS_ONLY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT_SET_ID',X_BATCH_REC.DOCUMENT_SET_ID);
    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT_SET_NAME',X_BATCH_REC.DOCUMENT_SET_NAME);
    WSH_DEBUG_SV.log(l_module_name,'EXISTING_RSVS_ONLY_FLAG',X_BATCH_REC.EXISTING_RSVS_ONLY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'SHIPMENT_PRIORITY_CODE',X_BATCH_REC.SHIPMENT_PRIORITY_CODE);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_METHOD_CODE',X_BATCH_REC.SHIP_METHOD_CODE);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_METHOD_NAME',X_BATCH_REC.SHIP_METHOD_NAME);
    WSH_DEBUG_SV.log(l_module_name,'CUSTOMER_ID',X_BATCH_REC.CUSTOMER_ID);
    WSH_DEBUG_SV.log(l_module_name,'CUSTOMER_NUMBER',X_BATCH_REC.CUSTOMER_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'ORDER_HEADER_ID',X_BATCH_REC.ORDER_HEADER_ID);
    WSH_DEBUG_SV.log(l_module_name,'ORDER_NUMBER',X_BATCH_REC.ORDER_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_SET_ID',X_BATCH_REC.SHIP_SET_ID);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_SET_NUMBER',X_BATCH_REC.SHIP_SET_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'INVENTORY_ITEM_ID',X_BATCH_REC.INVENTORY_ITEM_ID);
    WSH_DEBUG_SV.log(l_module_name,'ORDER_TYPE_ID',X_BATCH_REC.ORDER_TYPE_ID);
    WSH_DEBUG_SV.log(l_module_name,'ORDER_TYPE_NAME',X_BATCH_REC.ORDER_TYPE_NAME);
    WSH_DEBUG_SV.log(l_module_name,'FROM_REQUESTED_DATE',X_BATCH_REC.FROM_REQUESTED_DATE);
    WSH_DEBUG_SV.log(l_module_name,'TO_REQUESTED_DATE',X_BATCH_REC.TO_REQUESTED_DATE);
    WSH_DEBUG_SV.log(l_module_name,'FROM_SCHEDULED_SHIP_DATE',X_BATCH_REC.FROM_SCHEDULED_SHIP_DATE);
    WSH_DEBUG_SV.log(l_module_name,'TO_SCHEDULED_SHIP_DATE',X_BATCH_REC.TO_SCHEDULED_SHIP_DATE);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_LOCATION_ID',X_BATCH_REC.SHIP_TO_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_FROM_LOCATION_ID',X_BATCH_REC.SHIP_FROM_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',X_BATCH_REC.TRIP_ID);
    WSH_DEBUG_SV.log(l_module_name,'TRIP_NAME',X_BATCH_REC.TRIP_NAME);
    WSH_DEBUG_SV.log(l_module_name,'DELIVERY_ID',X_BATCH_REC.DELIVERY_ID);
    WSH_DEBUG_SV.log(l_module_name,'DELIVERY_NAME',X_BATCH_REC.DELIVERY_NAME);
    WSH_DEBUG_SV.log(l_module_name,'INCLUDE_PLANNED_LINES',X_BATCH_REC.INCLUDE_PLANNED_LINES);
    WSH_DEBUG_SV.log(l_module_name,'PICK_GROUPING_RULE_ID',X_BATCH_REC.PICK_GROUPING_RULE_ID);
    WSH_DEBUG_SV.log(l_module_name,'PICK_GROUPING_RULE_NAME',X_BATCH_REC.PICK_GROUPING_RULE_NAME);
    WSH_DEBUG_SV.log(l_module_name,'PICK_SEQUENCE_RULE_ID',X_BATCH_REC.PICK_SEQUENCE_RULE_ID);
    WSH_DEBUG_SV.log(l_module_name,'PICK_SEQUENCE_RULE_NAME',X_BATCH_REC.PICK_SEQUENCE_RULE_NAME);
    WSH_DEBUG_SV.log(l_module_name,'AUTOCREATE_DELIVERY_FLAG',X_BATCH_REC.AUTOCREATE_DELIVERY_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE_CATEGORY',X_BATCH_REC.ATTRIBUTE_CATEGORY);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE1',X_BATCH_REC.ATTRIBUTE1);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE2',X_BATCH_REC.ATTRIBUTE2);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE3',X_BATCH_REC.ATTRIBUTE3);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE4',X_BATCH_REC.ATTRIBUTE4);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE5',X_BATCH_REC.ATTRIBUTE5);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE6',X_BATCH_REC.ATTRIBUTE6);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE7',X_BATCH_REC.ATTRIBUTE7);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE8',X_BATCH_REC.ATTRIBUTE8);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE9',X_BATCH_REC.ATTRIBUTE9);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE10',X_BATCH_REC.ATTRIBUTE10);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE11',X_BATCH_REC.ATTRIBUTE11);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE12',X_BATCH_REC.ATTRIBUTE12);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE13',X_BATCH_REC.ATTRIBUTE13);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE14',X_BATCH_REC.ATTRIBUTE14);
    WSH_DEBUG_SV.log(l_module_name,'ATTRIBUTE15',X_BATCH_REC.ATTRIBUTE15);
    WSH_DEBUG_SV.log(l_module_name,'AUTODETAIL_PR_FLAG',X_BATCH_REC.AUTODETAIL_PR_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'STOP_ID',X_BATCH_REC.TRIP_STOP_ID);
    WSH_DEBUG_SV.log(l_module_name,'STOP_LOCATION_ID',X_BATCH_REC.TRIP_STOP_LOCATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'DEFAULT_STAGE_SUBINVENTORY',X_BATCH_REC.DEFAULT_STAGE_SUBINVENTORY);
    WSH_DEBUG_SV.log(l_module_name,'DEFAULT_STAGE_LOCATOR_ID',X_BATCH_REC.DEFAULT_STAGE_LOCATOR_ID);
    WSH_DEBUG_SV.log(l_module_name,'PICK_FROM_SUBINVENTORY',X_BATCH_REC.PICK_FROM_SUBINVENTORY);
    WSH_DEBUG_SV.log(l_module_name,'PICK_FROM_LOCATOR_ID',X_BATCH_REC.PICK_FROM_LOCATOR_ID);
    WSH_DEBUG_SV.log(l_module_name,'AUTO_PICK_CONFIRM_FLAG',X_BATCH_REC.AUTO_PICK_CONFIRM_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'DELIVERY_DETAIL_ID',X_BATCH_REC.DELIVERY_DETAIL_ID);
    WSH_DEBUG_SV.log(l_module_name,'PROJECT_ID',X_BATCH_REC.PROJECT_ID);
    WSH_DEBUG_SV.log(l_module_name,'TASK_ID',X_BATCH_REC.TASK_ID);
    WSH_DEBUG_SV.log(l_module_name,'ORGANIZATION_ID',X_BATCH_REC.ORGANIZATION_ID);
    WSH_DEBUG_SV.log(l_module_name,'ORGANIZATION_CODE',X_BATCH_REC.ORGANIZATION_CODE);
    WSH_DEBUG_SV.log(l_module_name,'CONFIRM_RULE_ID',X_BATCH_REC.SHIP_CONFIRM_RULE_ID);
    WSH_DEBUG_SV.log(l_module_name,'CONFIRM_RULE_NAME',X_BATCH_REC.SHIP_CONFIRM_RULE_NAME);
    WSH_DEBUG_SV.log(l_module_name,'AUTOPACK_FLAG',X_BATCH_REC.AUTOPACK_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'AUTOPACK_LEVEL',X_BATCH_REC.AUTOPACK_LEVEL);
    WSH_DEBUG_SV.log(l_module_name,'TASK_PLANNING_FLAG',X_BATCH_REC.TASK_PLANNING_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'CATEGORY_SET_ID',X_BATCH_REC.CATEGORY_SET_ID);
    WSH_DEBUG_SV.log(l_module_name,'CATEGORY_ID',X_BATCH_REC.CATEGORY_ID);
    WSH_DEBUG_SV.log(l_module_name,'SHIP_SET_SMC_FLAG',X_BATCH_REC.SHIP_SET_SMC_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'p_region_ID',X_BATCH_REC.region_ID);
    WSH_DEBUG_SV.log(l_module_name,'zone_ID',X_BATCH_REC.zone_ID);
    WSH_DEBUG_SV.log(l_module_name,'ac_Delivery_Criteria',X_BATCH_REC.ac_Delivery_Criteria);
    WSH_DEBUG_SV.log(l_module_name,'rel_subinventory',X_BATCH_REC.rel_subinventory);
    WSH_DEBUG_SV.log(l_module_name,'append_flag',X_BATCH_REC.append_flag);
    WSH_DEBUG_SV.log(l_module_name,'task_priority',X_BATCH_REC.task_priority);
    WSH_DEBUG_SV.log(l_module_name,'Actual Departure Date',x_batch_rec.actual_departure_date);
    WSH_DEBUG_SV.log(l_module_name,'allocation_method',X_BATCH_REC.allocation_method); -- X-dock
    WSH_DEBUG_SV.log(l_module_name,'crossdock_criteria_id',X_BATCH_REC.crossdock_criteria_id); -- X-dock
    WSH_DEBUG_SV.log(l_module_name,'dynamic_replenishment_flag ',X_BATCH_REC.dynamic_replenishment_flag); --bug# 6689448 (replenishment project)
    WSH_DEBUG_SV.logmsg(l_module_name,'************************************************************************');
    --}
  END IF;



  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
     (
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data,
        p_encoded => FND_API.G_FALSE
     );

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             IF c_batch_info%ISOPEN THEN
               CLOSE c_batch_info;
             END IF;
              x_return_status := FND_API.G_RET_STS_ERROR ;
             wsh_util_core.add_message(x_return_status);
             FND_MSG_PUB.Count_And_Get
                 (
                   p_count  => x_msg_count,
                   p_data  =>  x_msg_data,
                   p_encoded => FND_API.G_FALSE
                  );

            IF l_debug_on THEN
	    --{
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
            --}
	    END IF;
--

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF c_batch_info%ISOPEN THEN
               CLOSE c_batch_info;
             END IF;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             wsh_util_core.add_message(x_return_status, l_module_name);
             FND_MSG_PUB.Count_And_Get
                 (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                 );
                  --

            IF l_debug_on THEN
	    --{
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
            --}
	    END IF;

       WHEN OTHERS THEN
             IF c_batch_info%ISOPEN THEN
               CLOSE c_batch_info;
             END IF;
             wsh_util_core.default_handler('WSH_PICKING_BATCHES_PUB.GET_BATCH_RECORD');
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get
                (
                    p_count  => x_msg_count,
                    p_data  =>  x_msg_data,
                    p_encoded => FND_API.G_FALSE
                 );

            IF l_debug_on THEN
	    --{
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
            --}
	    END IF;
            --
END Get_Batch_Record;

END WSH_PICKING_BATCHES_PUB;

/
