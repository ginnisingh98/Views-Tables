--------------------------------------------------------
--  DDL for Package WSH_PICKING_BATCHES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PICKING_BATCHES_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHPRGPS.pls 120.1.12010000.3 2009/12/03 14:26:29 gbhargav ship $ */
--
--
--===================
-- PUBLIC VARS
--===================
--
 TYPE Batch_Info_rec  IS Record (
             Row_id                     VARCHAR2(18),
             Batch_Id			wsh_picking_batches.Batch_Id%TYPE,
             Creation_Date		DATE,
             Created_By			wsh_picking_batches.Created_By%TYPE,
             Last_Update_Date		DATE,
             Last_Updated_By		wsh_picking_batches.Last_Updated_By%TYPE,
             Last_Update_Login		wsh_picking_batches.Last_Update_Login%TYPE,
             Name			wsh_picking_batches.Name%TYPE,
             Backorders_Only_Flag	wsh_picking_batches.Backorders_Only_Flag%TYPE,
             Document_Set_Id		wsh_picking_batches.Document_Set_Id%TYPE,
             Existing_Rsvs_Only_Flag	wsh_picking_batches.Existing_Rsvs_Only_Flag%TYPE,
             Shipment_Priority_Code	wsh_picking_batches.Shipment_Priority_Code%TYPE,
             Ship_Method_Code		wsh_picking_batches.Ship_Method_Code%TYPE,
             Customer_Id		wsh_picking_batches.Customer_Id%TYPE,
             Order_Header_Id		wsh_picking_batches.Order_Header_Id%TYPE,
             Ship_Set_id		wsh_picking_batches.Ship_Set_number%TYPE,
             Inventory_Item_Id		wsh_picking_batches.Inventory_Item_Id%TYPE,
             Order_Type_Id		wsh_picking_batches.Order_Type_Id%TYPE,
             From_Requested_Date	DATE,
             To_Requested_Date		DATE,
             From_Scheduled_Ship_Date	DATE,
             To_Scheduled_Ship_Date	DATE,
             Ship_To_Location_Id	wsh_picking_batches.Ship_To_Location_Id%TYPE,
             Ship_From_Location_Id	wsh_picking_batches.Ship_From_Location_Id%TYPE,
             Trip_Id			wsh_picking_batches.Trip_Id%TYPE,
             Delivery_Id		wsh_picking_batches.Delivery_Id%TYPE,
             Include_Planned_Lines	wsh_picking_batches.Include_Planned_Lines%TYPE,
             Pick_Grouping_Rule_Id	wsh_picking_batches.Pick_Grouping_Rule_Id%TYPE,
             Pick_Sequence_Rule_Id	wsh_picking_batches.Pick_Sequence_Rule_Id%TYPE,
             Autocreate_Delivery_Flag	wsh_picking_batches.Autocreate_Delivery_Flag%TYPE,
             Attribute_Category		wsh_picking_batches.Attribute_Category%TYPE,
             Attribute1			wsh_picking_batches.Attribute1%TYPE,
             Attribute2			wsh_picking_batches.Attribute2%TYPE,
             Attribute3			wsh_picking_batches.Attribute3%TYPE,
             Attribute4			wsh_picking_batches.Attribute4%TYPE,
             Attribute5			wsh_picking_batches.Attribute5%TYPE,
             Attribute6			wsh_picking_batches.Attribute6%TYPE,
             Attribute7			wsh_picking_batches.Attribute7%TYPE,
             Attribute8			wsh_picking_batches.Attribute8%TYPE,
             Attribute9			wsh_picking_batches.Attribute9%TYPE,
             Attribute10		wsh_picking_batches.Attribute10%TYPE,
             Attribute11		wsh_picking_batches.Attribute11%TYPE,
             Attribute12		wsh_picking_batches.Attribute12%TYPE,
             Attribute13		wsh_picking_batches.Attribute13%TYPE,
             Attribute14		wsh_picking_batches.Attribute14%TYPE,
             Attribute15		wsh_picking_batches.Attribute15%TYPE,
             Autodetail_Pr_Flag		wsh_picking_batches.Autodetail_Pr_Flag%TYPE,
	     -- Bug#: 3266659 - Removing carrier params
             -- Carrier_Id			wsh_picking_batches.Carrier_Id%TYPE,
             Trip_Stop_Id		wsh_picking_batches.Trip_Stop_Id%TYPE,
             Default_Stage_Subinventory wsh_picking_batches.Default_Stage_Subinventory%TYPE,
             Default_Stage_Locator_Id   wsh_picking_batches.Default_Stage_Locator_Id%TYPE,
             Pick_From_Subinventory	wsh_picking_batches.Pick_From_Subinventory%TYPE,
             Pick_From_locator_Id	wsh_picking_batches.Pick_From_locator_Id%TYPE,
             Auto_Pick_Confirm_Flag     wsh_picking_batches.Auto_Pick_Confirm_Flag%TYPE,
             Delivery_Detail_Id		wsh_picking_batches.Delivery_Detail_Id%TYPE,
             Project_Id			wsh_picking_batches.Project_Id%TYPE,
             Task_Id			wsh_picking_batches.Task_Id%TYPE,
             Organization_Id		wsh_picking_batches.Organization_Id%TYPE,
             Ship_Confirm_Rule_Id       wsh_picking_batches.Ship_Confirm_Rule_Id%TYPE,
             Autopack_Flag		wsh_picking_batches.Autopack_Flag%TYPE,
             Autopack_Level             wsh_picking_batches.Autopack_Level%TYPE,
             Task_Planning_Flag         wsh_picking_batches.Task_Planning_Flag%TYPE,
	     -- Bug#: 3266659 - Removing carrier params
             -- Non_Picking_Flag           wsh_picking_batches.Non_Picking_Flag%TYPE,
	     category_set_id            wsh_picking_batches.category_set_id%TYPE,
	     category_id                wsh_picking_batches.category_id%TYPE,
	     ship_set_smc_flag          wsh_picking_batches.ship_set_smc_flag%TYPE,
	     -- Bug#: 3266659 - Adding the  columns like zone, region, delivery criteria, release
	     --			subinventory and append flag
	     region_ID                  wsh_picking_batches.region_id%TYPE,
	     zone_ID                    wsh_picking_batches.zone_id%TYPE,
	     ac_Delivery_Criteria       wsh_picking_batches.ac_delivery_criteria%TYPE,
	     rel_subinventory           wsh_picking_batches.rel_subinventory%TYPE,
	     append_flag                wsh_picking_batches.append_flag%TYPE,
             task_priority              wsh_picking_batches.task_priority%TYPE,
             actual_departure_date      WSH_PICKING_BATCHES.ACTUAL_DEPARTURE_DATE%TYPE,
             allocation_method          WSH_PICKING_BATCHES.ALLOCATION_METHOD%TYPE, --anxsharm, X-dock
             crossdock_criteria_id      WSH_PICKING_BATCHES.CROSSDOCK_CRITERIA_ID%TYPE, -- anxsharm, X-dock
             dynamic_replenishment_flag      WSH_PICKING_BATCHES.dynamic_replenishment_flag%TYPE, ----bug# 6689448 (replenishment project)
             client_id                      WSH_PICKING_BATCHES.client_id%TYPE -- LSP PROJECT
	     );
--
--
--===================
-- PROCEDURES
--===================
--
--======================================================================================================
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
--======================================================================================================


PROCEDURE   Create_Batch(
            p_api_version_number     IN   NUMBER,
            p_init_msg_list          IN   VARCHAR2  DEFAULT NULL,
            p_commit                 IN   VARCHAR2  DEFAULT NULL,
	    x_return_status          OUT  NOCOPY   VARCHAR2,
            x_msg_count              OUT  NOCOPY   NUMBER,
            x_msg_data               OUT  NOCOPY   VARCHAR2,
            p_rule_id                IN   NUMBER   DEFAULT NULL,
	    p_rule_name              IN   VARCHAR2 DEFAULT NULL,
            p_batch_rec              IN   WSH_PICKING_BATCHES_PUB.Batch_Info_Rec,
            p_batch_prefix           IN   VARCHAR2 DEFAULT NULL,
            x_batch_id               OUT  NOCOPY   NUMBER
	    );

--
--======================================================================================================
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
--                     like log_level shoud be positive  , and on the not null values of p_batch_rec.
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
--                                             Default is 1.
--                                             For Online Mode it is always 1
--                                             For Concurrent Mode the value is determined by profile
--                     x_request_id            Out parameter contains request id for concurrent pick release request
--                                             Submitted
-- VERSION           : current version         1.0
--                     initial version         1.0
-- End of comments
--======================================================================================================


 PROCEDURE Release_Batch (
         -- Standard parameters
         p_api_version_number IN   NUMBER,
         p_init_msg_list      IN   VARCHAR2  DEFAULT NULL,
         p_commit             IN   VARCHAR2  DEFAULT NULL,
	 x_return_status      OUT  NOCOPY    VARCHAR2,
         x_msg_count          OUT  NOCOPY    NUMBER,
         x_msg_data           OUT  NOCOPY    VARCHAR2,
	 -- program specific paramters.
          p_batch_id          IN   NUMBER    DEFAULT NULL,
	  p_batch_name        IN   VARCHAR2    DEFAULT NULL,
          p_log_level         IN   NUMBER    DEFAULT NULL,
	  p_release_mode      IN   VARCHAR2  DEFAULT 'CONCURRENT',
         -- p_num_workers       IN   NUMBER    DEFAULT 1, -- bug 7505524
	  x_request_id        OUT  NOCOPY    NUMBER
        );
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
PROCEDURE release_wms_wave (
            p_batch_rec              IN   WSH_PICKING_BATCHES_PUB.Batch_Info_Rec,
            p_release_mode           IN   VARCHAR2  DEFAULT 'CONCURRENT',
            p_pick_wave_header_id    IN   NUMBER,
            x_batch_id               OUT  NOCOPY   NUMBER,
            x_request_id             OUT  NOCOPY   NUMBER,
            x_return_status          OUT  NOCOPY   VARCHAR2,
            x_msg_count              OUT  NOCOPY   NUMBER,
            x_msg_data               OUT  NOCOPY   VARCHAR2
            );


END WSH_PICKING_BATCHES_GRP;

/
