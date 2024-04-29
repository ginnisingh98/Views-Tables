--------------------------------------------------------
--  DDL for Package WSH_TRIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHTRTHS.pls 120.0.12000000.1 2007/01/16 05:51:45 appldev ship $ */

--
-- Type: 			Trip_Rectype
-- Definition:		In sync with the table definition for trips
-- Use:			In table handlers, calling packages


TYPE trip_rec_type IS RECORD (
 	TRIP_ID                         NUMBER,
 	NAME                            VARCHAR2(30),
 	PLANNED_FLAG                    VARCHAR2(1),
 	ARRIVE_AFTER_TRIP_ID            NUMBER,
 	STATUS_CODE                     VARCHAR2(2),
 	VEHICLE_ITEM_ID                 NUMBER,
 	VEHICLE_ORGANIZATION_ID         NUMBER,
 	VEHICLE_NUMBER                  VARCHAR2(30),
 	VEHICLE_NUM_PREFIX              VARCHAR2(10),
 	CARRIER_ID                      NUMBER,
 	SHIP_METHOD_CODE                VARCHAR2(30),
 	ROUTE_ID                        NUMBER,
 	ROUTING_INSTRUCTIONS            VARCHAR2(2000),
 	ATTRIBUTE_CATEGORY              VARCHAR2(150),
 	ATTRIBUTE1                      VARCHAR2(150),
 	ATTRIBUTE2                      VARCHAR2(150),
 	ATTRIBUTE3                      VARCHAR2(150),
 	ATTRIBUTE4                      VARCHAR2(150),
 	ATTRIBUTE5                      VARCHAR2(150),
 	ATTRIBUTE6                      VARCHAR2(150),
 	ATTRIBUTE7                      VARCHAR2(150),
 	ATTRIBUTE8                      VARCHAR2(150),
 	ATTRIBUTE9                      VARCHAR2(150),
 	ATTRIBUTE10                     VARCHAR2(150),
 	ATTRIBUTE11                     VARCHAR2(150),
 	ATTRIBUTE12                     VARCHAR2(150),
 	ATTRIBUTE13                     VARCHAR2(150),
 	ATTRIBUTE14                     VARCHAR2(150),
 	ATTRIBUTE15                     VARCHAR2(150),
 	CREATION_DATE                   DATE,
 	CREATED_BY                      NUMBER,
 	LAST_UPDATE_DATE                DATE,
 	LAST_UPDATED_BY                 NUMBER,
 	LAST_UPDATE_LOGIN               NUMBER,
 	PROGRAM_APPLICATION_ID          NUMBER,
 	PROGRAM_ID                      NUMBER,
 	PROGRAM_UPDATE_DATE             DATE,
 	REQUEST_ID                      NUMBER,
/* H Integration: datamodel changes wrudge */
	SERVICE_LEVEL			VARCHAR2(30),
	MODE_OF_TRANSPORT		VARCHAR2(30),
	FREIGHT_TERMS_CODE		VARCHAR2(30),
	CONSOLIDATION_ALLOWED		VARCHAR2(1),
/* I WSH-FTE Integration  , update to 30 */
	LOAD_TENDER_STATUS		VARCHAR2(30),
	ROUTE_LANE_ID			NUMBER,
	LANE_ID				NUMBER,
	SCHEDULE_ID			NUMBER,
	BOOKING_NUMBER			VARCHAR2(30),
/* I Harmonization: Non Database Columns Added rvishnuv */
	ROWID				VARCHAR2(4000),
	ARRIVE_AFTER_TRIP_NAME		VARCHAR2(30),
	SHIP_METHOD_NAME		VARCHAR2(240),
	VEHICLE_ITEM_DESC		VARCHAR2(240),
	VEHICLE_ORGANIZATION_CODE	VARCHAR2(3),
/* I WSH-FTE LOAD TENDER Integration */
        LOAD_TENDER_NUMBER              NUMBER,
        VESSEL                          VARCHAR2(100),
        VOYAGE_NUMBER                   VARCHAR2(100),
        PORT_OF_LOADING                 VARCHAR2(240),
        PORT_OF_DISCHARGE               VARCHAR2(240),
        WF_NAME                         VARCHAR2(8),
        WF_PROCESS_NAME                 VARCHAR2(30),
        WF_ITEM_KEY                     VARCHAR2(240),
        CARRIER_CONTACT_ID              NUMBER,
        SHIPPER_WAIT_TIME               NUMBER,
        WAIT_TIME_UOM                   VARCHAR2(3),
        LOAD_TENDERED_TIME              DATE,
        CARRIER_RESPONSE                VARCHAR2(2000),
/* J Inbound Logistics new columns jckwok */
        SHIPMENTS_TYPE_FLAG             VARCHAR2(30),
/* J TP Release : ttrichy */
 IGNORE_FOR_PLANNING                      VARCHAR2(1),
 TP_PLAN_NAME                             VARCHAR2(10),
 TP_TRIP_NUMBER                           NUMBER,
        SEAL_CODE                         VARCHAR2(30),
        OPERATOR                          VARCHAR2(150),
/* R12 attributes */
        CARRIER_REFERENCE_NUMBER          VARCHAR2(30),
        RANK_ID                           NUMBER,
        CONSIGNEE_CARRIER_AC_NO           VARCHAR2(240),
        ROUTING_RULE_ID                   NUMBER,
        APPEND_FLAG                       VARCHAR2(1)
	);


TYPE Trip_Attr_Tbl_Type is TABLE of trip_rec_type index by binary_integer;
--
--  Procedure:          Create_Trip
--  Parameters:         Trip Record info; rowid, trip_id, name, return_status as OUT
--  Description:        This procedure will create a trip. It will
--                      return to the use the trip_id and generates a name if
--				    trip name is not specified.
--

PROCEDURE Create_Trip(
  p_trip_info		IN  		trip_rec_type,
  x_rowid			OUT NOCOPY  		VARCHAR2,
  x_trip_id		OUT NOCOPY  		NUMBER,
  x_name			OUT NOCOPY  		VARCHAR2,
  x_return_status	OUT NOCOPY 		VARCHAR2
);

--
--  Procedure:          Delete_Trip
--  Parameters:         Row_id, trip_id, return_status and validate_flag
--  Description:        This procedure will delete a trip. If rowid is not null
--				    trip_id is found, and trip_id is used to delete trip.
--                      validate_flag - 'Y' means check_delete_trip is called
--

procedure Delete_Trip(
  p_rowid			IN	VARCHAR2,
  p_trip_id	     IN	NUMBER,
  x_return_status	OUT NOCOPY 	VARCHAR2,
  p_validate_flag   IN   VARCHAR2 DEFAULT 'Y',
  p_caller        IN      VARCHAR2 DEFAULT NULL
);


--
--  Procedure:          Update_Trip
--  Parameters:         Trip rowid, Trip Record info and return_status
--  Description:        This procedure will update a trip.
--

procedure Update_Trip(
	p_rowid			IN	VARCHAR2,
	p_trip_info		IN	trip_rec_type,
	x_return_status	OUT NOCOPY 	VARCHAR2
);

--
--  Procedure:          Lock_Trip
--  Parameters:         Trip rowid, Trip Record info and return_status
--  Description:        This procedure will lock a trip row.
--

procedure Lock_Trip(
	p_rowid			IN	VARCHAR2,
	p_trip_info		IN	trip_rec_type
);

--
--  Procedure:          Populate_Record
--  Parameters:         Trip id as IN, Trip Record info and return status as OUT
--  Description:        This procedure will populate a Trip Record.
--

procedure Populate_Record(
	p_trip_id			IN	NUMBER,
	x_trip_info		OUT NOCOPY 	trip_rec_type,
	x_return_status	OUT NOCOPY 	VARCHAR2);


--
--  Function:		Get_Name
--  Parameters:		p_trip_id - Id for trip
--  Description:	This procedure will return Trip Name for a Trip Id
--

FUNCTION Get_Name
	(p_trip_id		IN	NUMBER
	 ) RETURN VARCHAR2;


--
--  Procedure:   Lock_Trip Wrapper
--  Parameters:  A table of all Attributes of a Trip Record,
--               Caller in
--               Return_Status,Valid_index_id_tab out
--  Description: This procedure will lock multiple Trips.

procedure Lock_Trip(
	p_rec_attr_tab		IN		Trip_Attr_Tbl_Type,
        p_caller		IN		VARCHAR2,
        p_valid_index_tab       IN              wsh_util_core.id_tab_type,
        x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
	x_return_status		OUT		NOCOPY VARCHAR2
);

PROCEDURE lock_trip_no_compare (p_trip_id IN NUMBER);

END WSH_TRIPS_PVT;

 

/
