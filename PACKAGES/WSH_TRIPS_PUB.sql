--------------------------------------------------------
--  DDL for Package WSH_TRIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIPS_PUB" AUTHID CURRENT_USER as
/* $Header: WSHTRPBS.pls 120.3 2006/11/17 19:54:35 wrudge noship $ */
/*#
 * This is the Trip Public Application Program Interface. It allows Creation
 * of Trips, Updation of Trips and perform various Actions on Trips.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Trip
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WSH_TRIP
 */

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
 	CREATION_DATE                   DATE DEFAULT FND_API.G_MISS_DATE,
 	CREATED_BY                      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	LAST_UPDATE_DATE                DATE DEFAULT FND_API.G_MISS_DATE,
 	LAST_UPDATED_BY                 NUMBER DEFAULT FND_API.G_MISS_NUM,
 	LAST_UPDATE_LOGIN               NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PROGRAM_APPLICATION_ID          NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PROGRAM_ID                      NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PROGRAM_UPDATE_DATE             DATE DEFAULT FND_API.G_MISS_DATE,
 	REQUEST_ID                      NUMBER DEFAULT FND_API.G_MISS_NUM,
        SERVICE_LEVEL                   VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
        MODE_OF_TRANSPORT               VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
        OPERATOR                        VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
        FREIGHT_TERMS_CODE              VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
        FREIGHT_TERMS_NAME              VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
        CARRIER_REFERENCE_NUMBER        VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
        CONSIGNEE_CARRIER_AC_NO         VARCHAR2(240) DEFAULT FND_API.G_MISS_CHAR,
        SEAL_CODE                       VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR);

TYPE Action_Param_Rectype IS RECORD (
         ACTION_CODE                    VARCHAR2(500)
        ,ORGANIZATION_ID                NUMBER
        ,REPORT_SET_NAME                VARCHAR2(30)
        ,REPORT_SET_ID                  NUMBER
        ,OVERRIDE_FLAG                  VARCHAR2(1)
        ,ACTUAL_DATE                    DATE
        ,ACTION_FLAG                    VARCHAR2(1)   DEFAULT 'S'
        ,AUTOINTRANSIT_FLAG             VARCHAR2(1)   DEFAULT 'Y'
        ,AUTOCLOSE_FLAG                 VARCHAR2(1)   DEFAULT 'Y'
        ,STAGE_DEL_FLAG                 VARCHAR2(1)   DEFAULT 'Y'
        ,SHIP_METHOD                    VARCHAR2(30)
        ,BILL_OF_LADING_FLAG            VARCHAR2(1)   DEFAULT 'Y'
        ,DEFER_INTERFACE_FLAG           VARCHAR2(1)   DEFAULT 'N'
        ,ACTUAL_DEPARTURE_DATE          DATE          DEFAULT SYSDATE
      );


--===================
-- PROCEDURES
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
/*#
 * The Create_Update_Trip procedure enables you to create a new Trip record or
 * update an existing Trip Record in the WSH_TRIPS table. The TRIP_ID,NAME and return
 * status of a new Trip are passed as OUT parameters, while the Trip Name of an
 * existing Trip for update is passed as IN parameter.
 * @param p_api_version_number  Version number of the API
 * @param p_init_msg_list       Messages will be initialized, if set as true
 * @param x_return_status       Return Status of the API
 * @param x_msg_count           Number of Messages, if any
 * @param x_msg_data            Message Text, if any
 * @param p_action_code         Trip Action Code
 * @param p_trip_info           Trip Information (or) Attributes of Trip Entity
 * @param p_trip_name           Trip Name
 * @param x_trip_id             New Trip ID
 * @param x_trip_name           New Trip Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Update Trip
 */

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
/*#
 * The Trip_Action procedure enables you to carry out various Actions on a Trip. It
 * accepts as IN parameters the trip identifiers, an action code and any additional
 * parameters needed for specific actions, and returns a completion status.
 * @param p_api_version_number  Version number of the API
 * @param p_init_msg_list       Messages will be initialized, if set as true
 * @param x_return_status       Return Status of the API
 * @param x_msg_count           Number of Messages, if any
 * @param x_msg_data            Message Text, if any
 * @param p_action_code         Trip Action Code
 * @param p_trip_id             Trip ID
 * @param p_trip_name           Trip Name
 * @param p_wv_override_flag    Weight/Volume re-calculations flag
 * @param p_report_set_name     Name of Report set
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Trip Actions
 */

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    p_report_set_name        IN   VARCHAR2 DEFAULT NULL);


--========================================================================
-- PROCEDURE : Trip_Action         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_commit                FND_API.G_TRUE to commit
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_param_rec      Record of Parameters for various actions
--                                     Valid action codes are
--                                     'PLAN','UNPLAN',
--                                     'WT-VOL'
--                                     'PICK-RELEASE'
--                                     'DELETE'
--                                     'TRIP-CONFIRM'
--             p_trip_id               Trip identifier
--             p_trip_name             Trip name
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified in p_action_param_rec
--             on an existing trip identified by p_trip_id or trip_name
--
--========================================================================
/*#
 * The Over-Loaded Trip_Action procedure enables you to carry out various Actions on
 * a Trip. It accepts as IN parameters the trip identifiers, an action parameters
 * Record and any additional parameters needed for specific actions, and returns a
 * completion status.
 * @param p_api_version_number  Version number of the API
 * @param p_init_msg_list       Messages will be initialized, if set as true
 * @param p_commit              commits the transaction, if set as true
 * @param x_return_status       Return Status of the API
 * @param x_msg_count           Number of Messages, if any
 * @param x_msg_data            Message Text, if any
 * @param p_action_param_rec    Action Parameters Record
 * @param p_trip_id             Trip ID
 * @param p_trip_name           Trip Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Trip Actions
 */

  PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT  NOCOPY   VARCHAR2,
    x_msg_count              OUT  NOCOPY   NUMBER,
    x_msg_data               OUT  NOCOPY   VARCHAR2,
    p_action_param_rec       IN   WSH_TRIPS_PUB.Action_Param_Rectype,
    p_trip_id                IN   NUMBER DEFAULT NULL,
    p_trip_name              IN   VARCHAR2 DEFAULT NULL );

END WSH_TRIPS_PUB;

 

/
