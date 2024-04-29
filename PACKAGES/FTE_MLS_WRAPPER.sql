--------------------------------------------------------
--  DDL for Package FTE_MLS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_MLS_WRAPPER" AUTHID CURRENT_USER as
/* $Header: FTEMLWRS.pls 120.3 2005/06/30 13:24:15 hbhagava noship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;
   G_STOPS_TAB_REC	WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type;

   TYPE stop_seq_rec IS RECORD (
        OLD_STOP_SEQUENCE_NUMBER                        NUMBER,
        NEW_STOP_SEQUENCE_NUMBER                         NUMBER
   );

   TYPE stop_seq_rec_tbl_type is TABLE of stop_seq_rec index by binary_integer;

   G_STOPS_SEQ_TAB	STOP_SEQ_REC_TBL_TYPE;


--========================================================================
-- PROCEDURE : Create_Update_Stop         FTE wrapper
--
-- COMMENT   : Wrapper around WSH_TRIP_STOPS_PUB.Create_Update
--             Passes in all the parameters reqd (record type input changed to
--             number of parameters which are collected, assigned to a record
--             and call WSH_TRIP_STOPS_PUB.Create_Update
--========================================================================
  PROCEDURE Create_Update_Stop
	( p_api_version_number     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2,
	x_return_status          OUT NOCOPY   VARCHAR2,
	x_msg_count              OUT NOCOPY   NUMBER,
	x_msg_data               OUT NOCOPY   VARCHAR2,
	p_action_code            IN   VARCHAR2,
	p_trip_id                IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_stop_location_id       IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_stop_location_code     IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_planned_dep_date       IN   DATE DEFAULT FND_API.G_MISS_DATE,
	x_stop_id                OUT NOCOPY   NUMBER,
--add trip stop info rec fields
	pp_STOP_ID                   IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_TRIP_ID                   IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_TRIP_NAME                 IN        VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_STOP_LOCATION_ID          IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
	pp_STOP_LOCATION_CODE        IN        VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_PLANNED_ARRIVAL_DATE      IN        DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_PLANNED_DEPARTURE_DATE    IN        DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_ACTUAL_ARRIVAL_DATE       IN        DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_ACTUAL_DEPARTURE_DATE     IN        DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_DEPARTURE_GROSS_WEIGHT    IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_DEPARTURE_NET_WEIGHT      IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_WEIGHT_UOM_CODE           IN        VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
	pp_WEIGHT_UOM_DESC           IN        VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_DEPARTURE_VOLUME          IN        NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_VOLUME_UOM_CODE           IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
	pp_VOLUME_UOM_DESC           IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_DEPARTURE_SEAL_CODE       IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_DEPARTURE_FILL_PERCENT    IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_STOP_SEQUENCE_NUMBER      IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
 	pp_LOCK_STOP_ID              IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	pp_STATUS_CODE               IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 	pp_PENDING_INTERFACE_FLAG    IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 	pp_TRANSACTION_HEADER_ID     IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	pp_WSH_LOCATION_ID           IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	pp_TRACKING_DRILLDOWN_FLAG   IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 	pp_TRACKING_REMARKS          IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
 	pp_CARRIER_EST_DEPARTURE_DATE IN     DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_CARRIER_EST_ARRIVAL_DATE   IN     DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_LOADING_START_DATETIME     IN     DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_LOADING_END_DATETIME       IN     DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_UNLOADING_START_DATETIME   IN     DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_UNLOADING_END_DATETIME     IN     DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_TP_ATTRIBUTE_CATEGORY     IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE1             IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_TP_ATTRIBUTE2             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE3             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE4             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE5             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE6             IN      VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_TP_ATTRIBUTE7             IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_TP_ATTRIBUTE8             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE9             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE10            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE11            IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_TP_ATTRIBUTE12            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE13            IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_TP_ATTRIBUTE14            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_TP_ATTRIBUTE15            IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE_CATEGORY        IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_ATTRIBUTE1                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE2                IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_ATTRIBUTE3                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE4                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE5                IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_ATTRIBUTE6                IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_ATTRIBUTE7                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE8                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE9                IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE10               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE11               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE12               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE13               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE14               IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR ,
 	pp_ATTRIBUTE15               IN       VARCHAR2   DEFAULT FND_API.G_MISS_CHAR,
 	pp_CREATION_DATE             IN       DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_CREATED_BY                IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_LAST_UPDATE_DATE          IN       DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_LAST_UPDATED_BY           IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_LAST_UPDATE_LOGIN         IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_PROGRAM_APPLICATION_ID    IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_PROGRAM_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM  ,
 	pp_PROGRAM_UPDATE_DATE       IN       DATE DEFAULT FND_API.G_MISS_DATE,
 	pp_REQUEST_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_new_stop_sequence	     IN	      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	p_is_temp		     IN	      VARCHAR2	DEFAULT 'N',
 	p_wkend_layover_stops	     IN	      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	p_wkday_layover_stops	     IN	      NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_shipments_type_flag	     IN	      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
);

-- Wrapper around wsh_trip_stops_pub.Stop_Action for deleting stops
-- PROCEDURE : Stop_Action
-- p_action_code           'DELETE'
  PROCEDURE Stop_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_stop_id                IN   NUMBER DEFAULT NULL,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_stop_location_id       IN   NUMBER DEFAULT NULL,
    p_stop_location_code     IN   VARCHAR2 DEFAULT NULL,
    p_planned_dep_date       IN   DATE   DEFAULT NULL,
    p_actual_date            IN   DATE   DEFAULT NULL,
    p_defer_interface_flag   IN   VARCHAR2 DEFAULT 'Y');

-- Wrapper around WSH_DELIVERIES_PUB.Delivery_Action for assign/unassign to trip
-- PROCEDURE Delivery_Action
-- p_action_code will be either 'ASSIGN-TRIP','UNASSIGN-TRIP'
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_id            IN   NUMBER DEFAULT NULL,
    p_delivery_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_trip_id            IN   NUMBER DEFAULT NULL,
    p_asg_trip_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_stop_id     IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_id      IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_code    IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_arr_date    IN   DATE   DEFAULT NULL,
    p_asg_pickup_dep_date    IN   DATE   DEFAULT NULL,
    p_asg_dropoff_stop_id    IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_id     IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_code   IN   VARCHAR2 DEFAULT NULL,
    p_asg_dropoff_arr_date   IN   DATE   DEFAULT NULL,
    p_asg_dropoff_dep_date   IN   DATE   DEFAULT NULL,
    p_sc_action_flag         IN   VARCHAR2 DEFAULT 'S',
    p_sc_intransit_flag      IN   VARCHAR2 DEFAULT 'N',
    p_sc_close_trip_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_create_bol_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_stage_del_flag      IN   VARCHAR2 DEFAULT 'Y',
    p_sc_trip_ship_method    IN   VARCHAR2 DEFAULT NULL,
    p_sc_actual_dep_date     IN   DATE     DEFAULT NULL,
    p_sc_report_set_id       IN   NUMBER DEFAULT NULL,
    p_sc_report_set_name     IN   VARCHAR2 DEFAULT NULL,
    p_sc_defer_interface_flag	IN  VARCHAR2 DEFAULT 'Y',
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    x_trip_id                OUT NOCOPY   VARCHAR2,
    x_trip_name              OUT NOCOPY   VARCHAR2,
    x_delivery_leg_id        OUT NOCOPY   NUMBER,
    x_delivery_leg_seq           OUT NOCOPY     NUMBER
    );

  PROCEDURE Create_Update_Trip

  ( p_api_version_number     		IN   NUMBER,
	p_init_msg_list      		IN   VARCHAR2,
	x_return_status      		OUT NOCOPY   VARCHAR2,
	x_msg_count          		OUT NOCOPY   NUMBER,
	x_msg_data           	        OUT NOCOPY   VARCHAR2,
        x_trip_id                       OUT NOCOPY       NUMBER,
        x_trip_name                     OUT NOCOPY       VARCHAR2,
	p_action_code            	IN   VARCHAR2,
	p_rec_TRIP_ID                   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_NAME                      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ARRIVE_AFTER_TRIP_ID      IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ARRIVE_AFTER_TRIP_NAME    IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ITEM_ID           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ITEM_DESC         IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ORGANIZATION_ID   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ORGANIZATION_COD  IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUMBER            IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUM_PREFIX        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CARRIER_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SHIP_METHOD_CODE          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SHIP_METHOD_NAME          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_ID                  IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ROUTING_INSTRUCTIONS      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE_CATEGORY        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE1                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE2                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE3                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE4                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE5                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE6                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE7                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE8                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE9                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE10               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE11               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE12               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE13               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE14               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE15               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SERVICE_LEVEL             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_MODE_OF_TRANSPORT         IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CONSOLIDATION_ALLOWED     IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_PLANNED_FLAG          	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_STATUS_CODE           	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_FREIGHT_TERMS_CODE    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_LOAD_TENDER_STATUS    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_LANE_ID         	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LANE_ID              	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SCHEDULE_ID          	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_BOOKING_NUMBER     	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CREATION_DATE             IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_CREATED_BY                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_DATE          IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_LAST_UPDATED_BY           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_LOGIN         IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_APPLICATION_ID    IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_UPDATE_DATE       IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_REQUEST_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_trip_name              	IN   	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_carrier_contact_id 	    	IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_carrier_contact_name	    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_shipper_name		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_shipper_wait_time		IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_wait_time_uom		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_name			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_process_name		IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_wf_item_key		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_load_tender_number	    	IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_action			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_autoaccept			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_url				IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_carrier_remarks		IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_operator                      IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_IGNORE_FOR_PLANNING       IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CONSIGNEE_CAR_AC_NO	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CARRIER_REF_NUMBER	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_ROUTING_RULE_ID		IN	 NUMBER DEFAULT FND_API.G_MISS_NUM,
        p_rec_APPEND_FLAG		IN 	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_RANK_ID			IN	 NUMBER DEFAULT FND_API.G_MISS_NUM
	);



--========================================================================
-- PROCEDURE : Create_Update_Trip         FTE wrapper
--
-- COMMENT   : Wrapper around WSH_TRIPS_PUB.Create_Update_Trip
--             Passes in all the parameters reqd (record type input changed to
--             number of parameters which are collected, assigned to a record
--             and call WSH_TRIPS_PUB.Create_Update_Trip
-- MODIFIED    09/04/2002 HBHAGAVA
--	       Added new paramters for Load Tender
--			p_rec_tender_id
--			p_delivery_leg_ids
--========================================================================
  PROCEDURE Create_Update_Trip
  ( p_api_version_number     		IN   NUMBER,
	p_init_msg_list      		IN   VARCHAR2,
	x_return_status          	OUT NOCOPY   VARCHAR2,
	x_msg_count              	OUT NOCOPY   NUMBER,
	x_msg_data               	OUT NOCOPY   VARCHAR2,
        x_trip_id                       OUT NOCOPY       NUMBER,
        x_trip_name                     OUT NOCOPY       VARCHAR2,
	x_CREATION_DATE          	OUT NOCOPY	DATE,
	x_CREATED_BY             	OUT NOCOPY 	NUMBER,
	x_LAST_UPDATE_DATE       	OUT NOCOPY 	DATE,
	x_LAST_UPDATED_BY        	OUT NOCOPY 	NUMBER,
	x_LAST_UPDATE_LOGIN      	OUT NOCOPY 	NUMBER,
	p_action_code            	IN   VARCHAR2,
	p_rec_TRIP_ID                   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_NAME                      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ARRIVE_AFTER_TRIP_ID      IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ARRIVE_AFTER_TRIP_NAME    IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ITEM_ID           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ITEM_DESC         IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_ORGANIZATION_ID   IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_VEHICLE_ORGANIZATION_COD  IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUMBER            IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_VEHICLE_NUM_PREFIX        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CARRIER_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SHIP_METHOD_CODE          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SHIP_METHOD_NAME          IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_ID                  IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_ROUTING_INSTRUCTIONS      IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE_CATEGORY        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE1                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE2                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE3                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE4                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE5                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE6                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE7                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE8                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE9                IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE10               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE11               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE12               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE13               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE14               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ATTRIBUTE15               IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_rec_SERVICE_LEVEL             IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_MODE_OF_TRANSPORT         IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CONSOLIDATION_ALLOWED     IN       VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_PLANNED_FLAG          	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_STATUS_CODE           	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_FREIGHT_TERMS_CODE    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_LOAD_TENDER_STATUS    	IN 	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_ROUTE_LANE_ID         	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LANE_ID              	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_SCHEDULE_ID          	IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_BOOKING_NUMBER     	IN	 VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
	p_rec_CREATION_DATE             IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_CREATED_BY                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_DATE          IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_LAST_UPDATED_BY           IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_LAST_UPDATE_LOGIN         IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_APPLICATION_ID    IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_rec_PROGRAM_UPDATE_DATE       IN       DATE DEFAULT FND_API.G_MISS_DATE,
	p_rec_REQUEST_ID                IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_carrier_contact_id 	    	IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_shipper_name		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_shipper_wait_time		IN	     NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_wait_time_uom		    	IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_action			IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
	p_carrier_remarks		IN	     VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_operator                      IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_IGNORE_FOR_PLANNING       IN           VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CONSIGNEE_CAR_AC_NO	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_CARRIER_REF_NUMBER	IN	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_ROUTING_RULE_ID		IN	 NUMBER DEFAULT FND_API.G_MISS_NUM,
        p_rec_APPEND_FLAG		IN 	 VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
        p_rec_RANK_ID			IN	 NUMBER DEFAULT FND_API.G_MISS_NUM
        );



--========================================================================
-- PROCEDURE : Trip_Action         FTE wrapper
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N');
  --
  --

--========================================================================
-- Added Following procedure for PACK J
--========================================================================


--========================================================================
-- PROCEDURE : TRIP_ACTION         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_trip_id_tab	       table of trip id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    p_trip_id_tab	     IN			FTE_ID_TAB_TYPE,
    p_action_prms	     IN			FTE_TRIP_ACTION_PARAM_REC,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2
  );


--========================================================================
-- PROCEDURE : STOP_ACTION         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--	       p_stop_id_tab	       table of stop id's
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       x_action_out_rec	       Out rec based on actions.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

  PROCEDURE STOP_ACTION
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    p_stop_id_tab	     IN			FTE_ID_TAB_TYPE,
    p_action_prms	     IN			FTE_STOP_ACTION_PARAM_REC,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2
  );


  PROCEDURE INIT_STOPS_PLS_TABLE
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2
  );

  PROCEDURE CREATE_UPDATE_STOP
  (
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_in_rec                IN WSH_TRIP_STOPS_GRP.stopInRecType,
        p_rec_attr_tab          IN WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY WSH_TRIP_STOPS_GRP.stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
  );

  PROCEDURE PROCESS_STOPS(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
	x_stop_out_tab	     	OUT NOCOPY FTE_ID_TAB_TYPE,
	x_stop_seq_tab		OUT NOCOPY FTE_ID_TAB_TYPE,
	x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2
  );


  PROCEDURE REPRICE_TRIP (
  	p_api_version              IN  NUMBER DEFAULT 1.0,
        p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_trip_id		   IN  NUMBER,
        x_return_status            OUT NOCOPY  VARCHAR2,
        x_msg_count                OUT NOCOPY  NUMBER,
        x_msg_data                 OUT NOCOPY  VARCHAR2
  );
--
PROCEDURE Delivery_Detail_Action
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list          	IN 	VARCHAR2,
    p_mls_id_tab	     	IN 	FTE_ID_TAB_TYPE,
    p_action_params		IN 	FTE_DDL_ACTION_PARAM_REC,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data               	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  );
--
PROCEDURE Create_Update_Delivery_Detail
  (
    p_api_version_number	IN	NUMBER,
    p_init_msg_list           	IN 	VARCHAR2,
    p_commit                  	IN 	VARCHAR2,
    p_detail_info_tab		IN	FTE_DDL_ATTR_TAB_TYPE,
    p_action_code		IN 	VARCHAR2,
    x_return_status           	OUT NOCOPY	VARCHAR2,
    x_msg_count               	OUT NOCOPY 	NUMBER,
    x_msg_data                	OUT NOCOPY	VARCHAR2,
    x_detail_id_tab		OUT NOCOPY	FTE_ID_TAB_TYPE
  );
--
PROCEDURE Delivery_Action
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list          	IN 	VARCHAR2,
    p_mls_id_tab	     	IN 	FTE_ID_TAB_TYPE,
    p_action_params		IN 	FTE_DLV_ACTION_PARAM_REC,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data               	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  );
--
PROCEDURE Delivery_Action_On_Trip
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list          	IN 	VARCHAR2,
    p_mls_delivery_id_tab	IN 	FTE_ID_TAB_TYPE,
    p_mls_trip_id_tab	     	IN 	FTE_ID_TAB_TYPE,
    p_action_params		IN 	FTE_DLV_ACTION_PARAM_REC,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data               	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  );
--
PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit		     IN   VARCHAR2,
    p_dlvy_info_tab	     IN   FTE_DLV_ATTR_TAB_TYPE,
    p_action_code	     IN	  VARCHAR2,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2,
    x_dlvy_id_tab		     OUT  NOCOPY FTE_ID_TAB_TYPE
   );
--
PROCEDURE Exception_Action
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list         	IN 	VARCHAR2,
    p_validation_level		IN	NUMBER,
    p_commit			IN	VARCHAR2,
    p_action			IN	VARCHAR2,
    p_xc_action_tab		IN 	FTE_XC_ACTION_TAB_TYPE,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data              	OUT NOCOPY   VARCHAR2,
    x_action_out_rec		OUT NOCOPY   FTE_ACTION_OUT_REC
  );
--
PROCEDURE GROUP_DETAIL_SEARCH_DLVY
  ( p_api_version_number	IN 	NUMBER,
    p_init_msg_list         	IN 	VARCHAR2,
    p_commit			IN	VARCHAR2,
    p_id_tab			IN 	FTE_ID_TAB_TYPE,
    x_return_status          	OUT NOCOPY   VARCHAR2,
    x_msg_count              	OUT NOCOPY   NUMBER,
    x_msg_data              	OUT NOCOPY   VARCHAR2
  );
--

PROCEDURE Get_Disabled_List
  ( p_entity_type IN VARCHAR2,
    p_entity_id     IN NUMBER,
    p_parent_entity_id In NUMBER DEFAULT NULL,
    x_disabled_list  OUT NOCOPY FTE_NAME_TAB_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
   );
--
--**************************************************************************
-- Rel 12
--***************************************************************************
--========================================================================
-- PROCEDURE : TRIP_ACTION         Wrapper API      PUBLIC
--		Added for Rel 12
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       x_action_out_rec	       Out rec based on actions.
--	       p_trip_info_rec	       trip id record
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    p_trip_info_rec	     IN			FTE_TENDER_ATTR_REC,
    p_action_prms	     IN			FTE_TRIP_ACTION_PARAM_REC
  );
--

--***************************************************************************
--========================================================================
-- PROCEDURE : TRIP_ACTION         Wrapper API      PUBLIC
--		Added for Rel 12
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       x_action_out_rec	       Out rec based on actions.
--	       p_tripId		       trip id
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
-- HBHAGAVA Rel12
-- This procedure is used to handle trip actions give a trip id
  PROCEDURE Trip_Action
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2,
    x_action_out_rec	     OUT NOCOPY		FTE_ACTION_OUT_REC,
    p_tripId		     IN			NUMBER,
    p_action_prms	     IN			FTE_TRIP_ACTION_PARAM_REC
  );


--
PROCEDURE UPDATE_SERVICE_ON_TRIP
(
	p_API_VERSION_NUMBER	IN	NUMBER,
	p_INIT_MSG_LIST		IN	VARCHAR2,
	p_COMMIT		IN	VARCHAR2,
	p_CALLER		IN	VARCHAR2,
	p_SERVICE_ACTION	IN	VARCHAR2,
	p_DELIVERY_ID		IN 	NUMBER,
	p_DELIVERY_LEG_ID	IN 	NUMBER,
	p_TRIP_ID		IN	NUMBER,
	p_LANE_ID		IN	NUMBER,
	p_SCHEDULE_ID		IN	NUMBER,
	p_CARRIER_ID		IN	NUMBER,
	p_SERVICE_LEVEL		IN	VARCHAR2,
	p_MODE_OF_TRANSPORT	IN	VARCHAR2,
	p_VEHICLE_ITEM_ID	IN	NUMBER,
	p_VEHICLE_ORG_ID	IN	NUMBER,
	p_CONSIGNEE_CARRIER_AC_NO IN    VARCHAR2,
	p_FREIGHT_TERMS_CODE	IN	VARCHAR2,
	x_RETURN_STATUS		OUT NOCOPY	VARCHAR2,
	x_MSG_COUNT		OUT NOCOPY	NUMBER,
	x_MSG_DATA		OUT NOCOPY	VARCHAR2
);

PROCEDURE INITIALIZE_TRIP_REC(x_trip_info OUT NOCOPY WSH_TRIPS_PVT.Trip_Rec_Type);


--
END FTE_MLS_WRAPPER;

 

/
