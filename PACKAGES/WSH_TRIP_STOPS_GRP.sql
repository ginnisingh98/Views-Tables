--------------------------------------------------------
--  DDL for Package WSH_TRIP_STOPS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_STOPS_GRP" AUTHID CURRENT_USER as
/* $Header: WSHSTGPS.pls 120.1.12000000.1 2007/01/16 05:50:43 appldev ship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--===================
-- PUBLIC VARS
--===================

TYPE Trip_Stop_Pub_Rec_Type IS RECORD (
 	STOP_ID                         NUMBER DEFAULT 9.99E125,
 	TRIP_ID                         NUMBER DEFAULT 9.99E125,
	TRIP_NAME                       VARCHAR2(30) DEFAULT chr(0),
 	STOP_LOCATION_ID                NUMBER DEFAULT 9.99E125,
	STOP_LOCATION_CODE              VARCHAR2(20) DEFAULT chr(0),
 	PLANNED_ARRIVAL_DATE            DATE DEFAULT TO_DATE('1','j'),
 	PLANNED_DEPARTURE_DATE          DATE DEFAULT TO_DATE('1','j'),
 	ACTUAL_ARRIVAL_DATE             DATE DEFAULT TO_DATE('1','j'),
 	ACTUAL_DEPARTURE_DATE           DATE DEFAULT TO_DATE('1','j'),
 	DEPARTURE_GROSS_WEIGHT          NUMBER DEFAULT 9.99E125,
 	DEPARTURE_NET_WEIGHT            NUMBER DEFAULT 9.99E125,
 	WEIGHT_UOM_CODE                 VARCHAR2(3) DEFAULT chr(0),
	WEIGHT_UOM_DESC                 VARCHAR2(25) DEFAULT chr(0),
 	DEPARTURE_VOLUME                NUMBER DEFAULT 9.99E125,
 	VOLUME_UOM_CODE                 VARCHAR2(3) DEFAULT chr(0),
	VOLUME_UOM_DESC                 VARCHAR2(25) DEFAULT chr(0),
 	DEPARTURE_SEAL_CODE             VARCHAR2(30) DEFAULT chr(0),
 	DEPARTURE_FILL_PERCENT          NUMBER DEFAULT 9.99E125,
 	STOP_SEQUENCE_NUMBER          	NUMBER DEFAULT 9.99E125,
 	LOCK_STOP_ID                    NUMBER DEFAULT 9.99E125,
 	STATUS_CODE                     VARCHAR2(2) DEFAULT chr(0),
 	PENDING_INTERFACE_FLAG          VARCHAR2(1) DEFAULT chr(0),
 	TRANSACTION_HEADER_ID           NUMBER DEFAULT 9.99E125,
 	WSH_LOCATION_ID                 NUMBER DEFAULT 9.99E125,
 	TRACKING_DRILLDOWN_FLAG         VARCHAR2(1) DEFAULT chr(0),
 	TRACKING_REMARKS                VARCHAR2(1) DEFAULT chr(0),
 	CARRIER_EST_DEPARTURE_DATE      DATE DEFAULT TO_DATE('1','j'),
 	CARRIER_EST_ARRIVAL_DATE        DATE DEFAULT TO_DATE('1','j'),
 	LOADING_START_DATETIME          DATE DEFAULT TO_DATE('1','j'),
 	LOADING_END_DATETIME            DATE DEFAULT TO_DATE('1','j'),
 	UNLOADING_START_DATETIME        DATE DEFAULT TO_DATE('1','j'),
 	UNLOADING_END_DATETIME          DATE DEFAULT TO_DATE('1','j'),
 	TP_ATTRIBUTE_CATEGORY           VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE1                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE2                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE3                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE4                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE5                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE6                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE7                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE8                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE9                   VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE10                  VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE11                  VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE12                  VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE13                  VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE14                  VARCHAR2(150) DEFAULT chr(0),
 	TP_ATTRIBUTE15                  VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE_CATEGORY              VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE1                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE2                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE3                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE4                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE5                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE6                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE7                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE8                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE9                      VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE10                     VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE11                     VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE12                     VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE13                     VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE14                     VARCHAR2(150) DEFAULT chr(0),
 	ATTRIBUTE15                     VARCHAR2(150) DEFAULT chr(0),
 	CREATION_DATE                   DATE DEFAULT TO_DATE('1','j'),
 	CREATED_BY                      NUMBER DEFAULT 9.99E125,
 	LAST_UPDATE_DATE                DATE DEFAULT TO_DATE('1','j'),
 	LAST_UPDATED_BY                 NUMBER DEFAULT 9.99E125,
 	LAST_UPDATE_LOGIN               NUMBER DEFAULT 9.99E125,
 	PROGRAM_APPLICATION_ID          NUMBER DEFAULT 9.99E125,
 	PROGRAM_ID                      NUMBER DEFAULT 9.99E125,
 	PROGRAM_UPDATE_DATE             DATE DEFAULT TO_DATE('1','j'),
 	REQUEST_ID                      NUMBER DEFAULT 9.99E125);

--Harmonizing Project -I
    TYPE stopInRecType is RECORD(
        caller          VARCHAR2(32767),
        phase           NUMBER,
        action_code     VARCHAR2(32767));


    --bug 2796095
    TYPE Stop_Wt_Vol_Rec_Type IS RECORD (
 	STOP_ID                         NUMBER,
 	DEPARTURE_GROSS_WEIGHT          NUMBER,
 	DEPARTURE_NET_WEIGHT            NUMBER,
 	DEPARTURE_VOLUME                NUMBER,
 	DEPARTURE_FILL_PERCENT          NUMBER);

    TYPE Stop_Wt_Vol_tab_type IS TABLE OF  Stop_Wt_Vol_Rec_Type INDEX BY BINARY_INTEGER;
    --bug 2796095

    TYPE stopOutRecType IS RECORD (
        parameter1 VARCHAR2(32767) DEFAULT chr(0),
        rowid           VARCHAR2(32767),
        stop_id		NUMBER
      );

    TYPE stopActionInRecType
    IS
    RECORD
      (
        action_code VARCHAR2(32767),
        actual_date        DATE        DEFAULT FND_API.G_MISS_DATE,
        defer_interface_flag VARCHAR2(1) DEFAULT 'Y'
      );

     TYPE action_parameters_rectype IS RECORD (
         caller                         VARCHAR2(500)
        ,phase                          NUMBER
        ,action_code                    VARCHAR2(500)
        ,stop_action                    VARCHAR2(30)
        ,organization_id                NUMBER
        ,actual_date                    DATE
        ,defer_interface_flag           VARCHAR2(500)
        ,report_set_id                  NUMBER
        ,override_flag                  VARCHAR2(500)
     );

     TYPE default_parameters_rectype IS RECORD (
        status_code                     wsh_trip_stops.status_code%TYPE
        ,date_field                     VARCHAR2(500)
        ,defer_interface_flag           VARCHAR2(500)
        ,status_name                    VARCHAR2(500)
        ,stop_action                    VARCHAR2(500)
     );
    --Harmonization Project
    TYPE stopActionOutRecType
    IS
    RECORD
      (
         result_id_tab            wsh_util_core.id_tab_type,
         valid_ids_tab            wsh_util_core.id_tab_type,
         selection_issue_flag     VARCHAR2(1)
      );
--===================
-- NEW PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Update_Stop         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       p_stop_info             Attributes for the stop entity
--	       p_stop_IN_rec           Input Attributes for the stop entity
--	       p_stop_OUT_rec          Output Attributes for the stop entity
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trip_stops table with information
--             specified in p_stop_info. Use p_trip_id, p_trip_name, p_stop_location_id,
--             p_stop_location_code or p_planned_dep_date to update these values
--             on an existing stop.These are part of p_stop_info.
--========================================================================
  PROCEDURE Create_Update_Stop_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_stop_info	             IN OUT NOCOPY   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
    p_stop_IN_rec            IN  stopInRecType,
    x_stop_OUT_rec           OUT NOCOPY  stopOutRecType);

--========================================================================
-- PROCEDURE : Stop_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--	       p_stop_info             Attributes for the stop entity
--	       p_stop_IN_rec           Input Attributes for the stop entity
--	       p_stop_OUT_rec          Output Attributes for the stop entity
--             p_action_code           Stop action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'ARRIVE','CLOSE'
--                                     'PICK-RELEASE'
--                                     'DELETE'
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing stop identified by p_stop_id or a unique combination of
--             trip_id/trip_name, stop_location_id/stop_location_code or planned_departure_date.
--
--========================================================================

  PROCEDURE Stop_Action_New
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_stop_info	             IN OUT NOCOPY   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
    p_stop_IN_rec            IN  stopActionInRecType,
    x_stop_OUT_rec           OUT NOCOPY  stopActionOutRecType);

--===================
-- OLD PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Update_Stop         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--		     p_stop_info             Attributes for the stop entity
--             p_trip_id               Trip id for update
--             p_trip_name             Trip name for update
--             p_stop_location_id      Stop location id for update
--             p_stop_location_code    Stop location code for update
--             p_planned_dep_date      Planned departure date for update
--  	          x_stop_id - stop id of new stop
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_trip_stops table with information
--             specified in p_stop_info. Use p_trip_id, p_trip_name, p_stop_location_id,
--             p_stop_location_code or p_planned_dep_date to update these values
--             on an existing stop.
--========================================================================
  PROCEDURE Create_Update_Stop
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_stop_info	         IN OUT NOCOPY   WSH_TRIP_STOPS_GRP.Trip_Stop_Pub_Rec_Type,
    p_trip_id                IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_trip_name              IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_stop_location_id       IN   NUMBER DEFAULT FND_API.G_MISS_NUM,
    p_stop_location_code     IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_planned_dep_date       IN   DATE DEFAULT FND_API.G_MISS_DATE,
    x_stop_id                OUT NOCOPY   NUMBER);


--========================================================================
-- PROCEDURE : Stop_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_code           Stop action code. Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'ARRIVE','CLOSE'
--                                     'PICK-RELEASE'
--                                     'DELETE'
--		     p_stop_id               Stop identifier
--             p_trip_id               Stop identifier - trip id it belongs to
--             p_trip_name             Stop identifier - trip name it belongs to
--             p_stop_location_id      Stop identifier - stop location id
--             p_stop_location_code    Stop identifier - stop location code
--             p_planned_dep_date      Stop identifier - stop planned dep date
--             p_actual_date           Actual arrival/departure date of the stop
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_code
--             on an existing stop identified by p_stop_id or a unique combination of
--             trip_id/trip_name, stop_location_id/stop_location_code or planned_departure_date.
--
--========================================================================

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


  PROCEDURE Stop_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_action_prms            IN   action_parameters_rectype,
    p_rec_attr_tab           IN   WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
    x_stop_out_rec           OUT  NOCOPY   stopActionOutRecType,
    x_def_rec                OUT  NOCOPY   default_parameters_rectype,
    x_return_status          OUT  NOCOPY  VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY  VARCHAR2);



--Harmonizing Project -I
TYPE stop_out_tab_type IS TABLE OF StopOutRecType INDEX BY BINARY_INTEGER;

PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_in_rec                IN stopInRecType,
        p_rec_attr_tab          IN WSH_TRIP_STOPS_PVT.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_stop_wt_vol_out_tab   OUT NOCOPY Stop_Wt_Vol_tab_type --bug 2796095
     );

--Harmonizing Project -I

-- API to get Stop Details
PROCEDURE get_stop_details_pvt
  (p_stop_id IN NUMBER,
   x_stop_rec OUT NOCOPY WSH_TRIP_STOPS_PVT.TRIP_STOP_REC_TYPE,
   x_return_status OUT NOCOPY VARCHAR2);


END WSH_TRIP_STOPS_GRP;

 

/
