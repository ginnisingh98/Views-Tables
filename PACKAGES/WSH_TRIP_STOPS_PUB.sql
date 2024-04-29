--------------------------------------------------------
--  DDL for Package WSH_TRIP_STOPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_STOPS_PUB" AUTHID CURRENT_USER as
/* $Header: WSHSTPBS.pls 120.2 2006/11/17 19:53:00 wrudge noship $ */
/*#
 * This is the Stop Public Application Program Interface. It allows Creation
 * of Stops, Updation of exisiting Stops and perform various Actions on Stops.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Trip Stop
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY  WSH_TRIP_STOPS_PUB
 */

--===================
-- PUBLIC VARS
--===================

TYPE Trip_Stop_Pub_Rec_Type IS RECORD (
 	STOP_ID                         NUMBER DEFAULT FND_API.G_MISS_NUM,
 	TRIP_ID                         NUMBER DEFAULT FND_API.G_MISS_NUM,
	TRIP_NAME                       VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
 	STOP_LOCATION_ID                NUMBER DEFAULT FND_API.G_MISS_NUM,
/* When this is called for Update need to populate status code
   and stop sequence number */
/* H integration for FTE- anxsharm */
 	STOP_SEQUENCE_NUMBER            NUMBER DEFAULT FND_API.G_MISS_NUM,
--commented status code for H integration
-- never give user access to status code update directly
--	STATUS_CODE                     VARCHAR2(2) DEFAULT FND_API.G_MISS_CHAR,
/* End of H integration for FTE- anxsharm */
	STOP_LOCATION_CODE              wsh_locations.UI_LOCATION_CODE%TYPE DEFAULT FND_API.G_MISS_CHAR,
 	PLANNED_ARRIVAL_DATE            DATE DEFAULT FND_API.G_MISS_DATE,
 	PLANNED_DEPARTURE_DATE          DATE DEFAULT FND_API.G_MISS_DATE,
 	ACTUAL_ARRIVAL_DATE             DATE DEFAULT FND_API.G_MISS_DATE,
 	ACTUAL_DEPARTURE_DATE           DATE DEFAULT FND_API.G_MISS_DATE,
 	DEPARTURE_GROSS_WEIGHT          NUMBER DEFAULT FND_API.G_MISS_NUM,
 	DEPARTURE_NET_WEIGHT            NUMBER DEFAULT FND_API.G_MISS_NUM,
 	WEIGHT_UOM_CODE                 VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
	WEIGHT_UOM_DESC                 VARCHAR2(25) DEFAULT FND_API.G_MISS_CHAR,
 	DEPARTURE_VOLUME                NUMBER DEFAULT FND_API.G_MISS_NUM,
 	VOLUME_UOM_CODE                 VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
	VOLUME_UOM_DESC                 VARCHAR2(25) DEFAULT FND_API.G_MISS_CHAR,
 	DEPARTURE_SEAL_CODE             VARCHAR2(30) DEFAULT FND_API.G_MISS_CHAR,
 	DEPARTURE_FILL_PERCENT          NUMBER DEFAULT FND_API.G_MISS_NUM,
 	TP_ATTRIBUTE_CATEGORY           VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE1                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE2                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE3                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE4                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE5                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE6                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE7                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE8                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE9                   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE10                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE11                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE12                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE13                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE14                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
 	TP_ATTRIBUTE15                  VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
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
 	-- csun 10+ internal location change
 	PHYSICAL_LOCATION_ID            NUMBER DEFAULT FND_API.G_MISS_NUM,
 	PHYSICAL_STOP_ID                NUMBER DEFAULT FND_API.G_MISS_NUM);

--===================
-- PROCEDURES
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
/*#
 * The Create_Update_Stop procedure enables you to create a new Stop record or
 * update an existing Stop Record in the WSH_TRIP_STOPS table. The STOP_ID and return
 * status of a new Stop are passed as OUT parameters, while the TRIP_ID of an existing
 * stop for update is passed as an IN parameter.
 * @param p_api_version_number  Version number of the API
 * @param p_init_msg_list       Messages will be initialized, if set as true
 * @param x_return_status       Return Status of the API
 * @param x_msg_count           Number of Messages, if any
 * @param x_msg_data            Message Text, if any
 * @param p_action_code         Action Code
 * @param p_stop_info           Stop Information (or) Attributes of Stop Entity
 * @param p_trip_id             Trip ID
 * @param p_trip_name           Trip Name
 * @param p_stop_location_id    Stop Location ID
 * @param p_stop_location_code  Stop Location Code
 * @param p_planned_dep_date    Planned Date of Departure
 * @param x_stop_id             New Stop ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Update Stop
 */

  PROCEDURE Create_Update_Stop
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_stop_info	         IN OUT NOCOPY   Trip_Stop_Pub_Rec_Type,
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
/*#
 * The Stop_Action procedure enables you to carry out various Actions on a Stop.
 * It accepts as IN parameters the Stop and Trip identifiers, an action code and
 * any additional parameters needed for specific actions, and returns a completion
 * status.
 * @param p_api_version_number    Version number of the API
 * @param p_init_msg_list         Messages will be initialized, if set as true
 * @param x_return_status         Return Status of the API
 * @param x_msg_count             Number of Messages, if any
 * @param x_msg_data              Message Text, if any
 * @param p_action_code           Stop Action Code
 * @param p_stop_id               Stop ID
 * @param p_trip_id               Trip ID
 * @param p_trip_name             Trip Name
 * @param p_stop_location_id      Stop Location ID
 * @param p_stop_location_code    Stop Location Code
 * @param p_planned_dep_date      Planned Departure Date
 * @param p_actual_date           Actual Date of Arrival/Departure
 * @param p_defer_interface_flag  Submit/Defer Concurrent Request
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Stop Actions
 */

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

END WSH_TRIP_STOPS_PUB;

 

/
