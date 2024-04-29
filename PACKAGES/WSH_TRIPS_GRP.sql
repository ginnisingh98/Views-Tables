--------------------------------------------------------
--  DDL for Package WSH_TRIPS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIPS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHTRGPS.pls 120.0.12000000.1 2007/01/16 05:51:38 appldev ship $ */

--===================
-- PUBLIC VARS
--===================

TYPE Trip_Pub_Rec_Type IS RECORD (
 	TRIP_ID                         NUMBER DEFAULT FND_API.G_MISS_NUM,
	NAME                            VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
 	ARRIVE_AFTER_TRIP_ID            NUMBER DEFAULT FND_API.G_MISS_NUM,
	ARRIVE_AFTER_TRIP_NAME          VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
 	VEHICLE_ITEM_ID                 NUMBER DEFAULT FND_API.G_MISS_NUM,
	VEHICLE_ITEM_DESC               VARCHAR2(240) DEFAULT FND_API.G_MISS_CHAR,
 	VEHICLE_ORGANIZATION_ID         NUMBER DEFAULT FND_API.G_MISS_NUM,
 	VEHICLE_ORGANIZATION_CODE       VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
 	VEHICLE_NUMBER                  VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
 	VEHICLE_NUM_PREFIX              VARCHAR2(10) DEFAULT FND_API.G_MISS_CHAR,
 	CARRIER_ID                      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	SHIP_METHOD_CODE                VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
 	SHIP_METHOD_NAME                VARCHAR2(80) DEFAULT FND_API.G_MISS_CHAR,
 	ROUTE_ID                        NUMBER DEFAULT FND_API.G_MISS_NUM,
 	ROUTING_INSTRUCTIONS            VARCHAR2(2000) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE_CATEGORY              VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE1                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE2                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE3                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE4                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE5                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE6                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE7                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE8                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE9                      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE10                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE11                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE12                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE13                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE14                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	ATTRIBUTE15                     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
        SERVICE_LEVEL                   VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
        MODE_OF_TRANSPORT               VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
        CONSOLIDATION_ALLOWED           VARCHAR2(1)  DEFAULT FND_API.G_MISS_CHAR,
        PLANNED_FLAG           		VARCHAR2(1)  DEFAULT FND_API.G_MISS_CHAR,
        STATUS_CODE           		VARCHAR2(2)  DEFAULT FND_API.G_MISS_CHAR,
        FREIGHT_TERMS_CODE     		VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
-- anxsharm for Load Tender, increase to 30
        LOAD_TENDER_STATUS     		VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
 	ROUTE_LANE_ID                   NUMBER DEFAULT FND_API.G_MISS_NUM,
 	LANE_ID                         NUMBER DEFAULT FND_API.G_MISS_NUM,
 	SCHEDULE_ID                     NUMBER DEFAULT FND_API.G_MISS_NUM,
        BOOKING_NUMBER     		VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
 	CREATION_DATE                   DATE DEFAULT FND_API.G_MISS_DATE,
 	CREATED_BY                      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	LAST_UPDATE_DATE                DATE DEFAULT FND_API.G_MISS_DATE,
 	LAST_UPDATED_BY                 NUMBER DEFAULT FND_API.G_MISS_NUM,
 	LAST_UPDATE_LOGIN               NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PROGRAM_APPLICATION_ID          NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PROGRAM_ID                      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PROGRAM_UPDATE_DATE             DATE DEFAULT FND_API.G_MISS_DATE,
 	REQUEST_ID                      NUMBER DEFAULT FND_API.G_MISS_NUM,
        CARRIER_REFERENCE_NUMBER        VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
        CONSIGNEE_CARRIER_AC_NO         VARCHAR2(240) DEFAULT FND_API.G_MISS_CHAR);


--Harmonizing Project -I
    TYPE TripInRecType is RECORD(
        caller          VARCHAR2(32767),
        phase           NUMBER,
        action_code     VARCHAR2(32767));

    TYPE tripActionInRecType
    IS
    RECORD
      (
        action_code VARCHAR2(32767),
        wv_override_flag VARCHAR2(1) DEFAULT 'N'
      );

    TYPE tripOutRecType IS RECORD
      (
        rowid 		VARCHAR2(32767),
        trip_id		NUMBER,
        trip_name	VARCHAR2(32767)
      );

    TYPE tripActionOutRecType
    IS
    RECORD
      (
          result_id_tab            wsh_util_core.id_tab_type,
          valid_ids_tab            wsh_util_core.id_tab_type,
          selection_issue_flag     VARCHAR2(1)
      );

     TYPE default_parameters_rectype IS RECORD (
        parameter1          varchar2(1),
        defer_interface_flag     VARCHAR2(1),    --] These parameters
        report_set_id            NUMBER,         --] are used for
        report_set_name          VARCHAR2(30),   --] action_code = 'CONFIRM'
        trip_multiple_pickup     VARCHAR2(1),    --]
        stop_location_code       VARCHAR2(100)   --]
     );
--Harmonizing Project -I

      TYPE action_parameters_rectype IS RECORD(
         caller                         VARCHAR2(500)
        ,phase                          NUMBER
        ,action_code                    VARCHAR2(500)
        ,organization_id                NUMBER
        ,report_set_id                  NUMBER
        ,override_flag                  VARCHAR2(500)
        ,trip_name                      wsh_trips.name%TYPE
        ,actual_date                    DATE
        ,stop_id                        NUMBER                    --] These parameters
        ,action_flag                    VARCHAR2(1)               --] are used for
        ,autointransit_flag             VARCHAR2(1)               --] action_code = 'CONFIRM'
        ,autoclose_flag                 VARCHAR2(1)               --]
        ,stage_del_flag                 VARCHAR2(1)               --]
        ,ship_method                    VARCHAR2(30)              --]
        ,bill_of_lading_flag            VARCHAR2(1)               --]
        ,defer_interface_flag           VARCHAR2(1)               --]
        ,actual_departure_date          DATE                      --]
	,mbol_flag                      VARCHAR2(1)               --] Added for Master Bill of Lading
      );

--===================
-- NEW PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Update_Trip         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       p_trip_info             Attributes for the trip entity
--	       p_trip_IN_rec           Input Attributes for the trip entity
--	       p_trip_OUT_rec          Output Attributes for the trip entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trips table with information
--             specified in p_trip_info
--========================================================================
  PROCEDURE Create_Update_Trip_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_trip_info	         IN OUT NOCOPY   Trip_Pub_Rec_Type,
    p_trip_IN_rec            IN  tripInRecType,
    p_trip_OUT_rec           OUT NOCOPY  tripOutRecType);

--========================================================================
-- PROCEDURE : Trip_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       p_trip_info             Attributes for the trip entity
--	       p_trip_IN_rec           Input Attributes for the trip entity
--	       p_trip_OUT_rec          Output Attributes for the trip entity
--             p_action_code           Trip action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'WT-VOL'
--                                     'PICK-RELEASE'
--                                     'DELETE'
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing trip identified by p_trip_id or trip_name
--
--========================================================================

  PROCEDURE Trip_Action_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_trip_info	         IN OUT NOCOPY   Trip_Pub_Rec_Type,
    p_trip_IN_rec            IN  tripActionInRecType,
    p_trip_OUT_rec           OUT NOCOPY  tripActionOutRecType);

--===================
-- OLD PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Update_Trip         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--		     p_trip_info             Attributes for the trip entity
--             p_trip_name             Trip name for update
--  	          x_trip_id               Trip id of new trip
--  	          x_trip_name             Trip name of new trip
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trips table with information
--             specified in p_trip_info
--========================================================================
  PROCEDURE Create_Update_Trip
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_trip_info	         IN OUT NOCOPY   Trip_Pub_Rec_Type,
    p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_trip_id                OUT NOCOPY   NUMBER,
    x_trip_name              OUT NOCOPY   VARCHAR2);


--========================================================================
-- PROCEDURE : Trip_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_code           Trip action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'WT-VOL'
--                                     'PICK-RELEASE'
--                                     'DELETE'
--		     p_trip_id               Trip identifier
--             p_trip_name             Trip name
--             p_wv_override_flag      Override flag for weight/volume calc
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing trip identified by p_trip_id or trip_name
--
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



  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_action_prms            IN   action_parameters_rectype,
    p_rec_attr_tab           IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
    x_trip_out_rec           OUT  NOCOPY tripActionOutRecType,
    x_def_rec                OUT  NOCOPY   default_parameters_rectype,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);



--Harmonizing Project -I
TYPE trip_out_tab_type IS TABLE OF TripOutRecType INDEX BY BINARY_INTEGER;

PROCEDURE Create_Update_Trip(
        p_api_version_number     IN   NUMBER,
        p_init_msg_list          IN   VARCHAR2,
        p_commit                 IN   VARCHAR2,
        p_trip_info_tab          IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
        p_In_rec                 IN   tripInRecType,
        x_Out_Tab                OUT  NOCOPY  trip_Out_Tab_Type,
        x_return_status          OUT  NOCOPY   VARCHAR2,
        x_msg_count              OUT  NOCOPY  NUMBER,
        x_msg_data               OUT  NOCOPY   VARCHAR2);

--Harmonizing Project -I

-- API to get trip details
PROCEDURE get_trip_details_pvt
  (p_trip_id IN NUMBER,
   x_trip_rec OUT NOCOPY WSH_TRIPS_PVT.TRIP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2);

END WSH_TRIPS_GRP;

 

/
