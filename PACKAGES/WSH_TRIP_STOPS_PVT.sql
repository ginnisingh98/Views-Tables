--------------------------------------------------------
--  DDL for Package WSH_TRIP_STOPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_STOPS_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHSTTHS.pls 120.1.12010000.1 2008/07/29 06:18:49 appldev ship $ */

-- OTM R12, glog project
-- Declare Constants for the possible values of tms_interface_flag
-- at Stop Level
-- The Code and Description are
--      NS -- Not to be Sent
--     ASP -- Actual Shipment in Process
--     ASR -- Actual Shipment Request
--     CMP -- Completed
  C_TMS_NOT_TO_BE_SENT    CONSTANT VARCHAR2(2) := 'NS';
  C_TMS_COMPLETED         CONSTANT VARCHAR2(3) := 'CMP';
  C_TMS_ACTUAL_IN_PROCESS CONSTANT VARCHAR2(3) := 'ASP';
  C_TMS_ACTUAL_REQUEST    CONSTANT VARCHAR2(3) := 'ASR';
-- end of OTM R12, glog proj

--
-- Type: 			trip_stop_rec_type
-- Definition:		In sync with the table definition for trip stops
-- Use:			In table handlers, calling packages


TYPE trip_stop_rec_type IS RECORD (
 	STOP_ID                         NUMBER,
 	TRIP_ID                         NUMBER,
 	STOP_LOCATION_ID                NUMBER,
 	STATUS_CODE                     VARCHAR2(2),
 	STOP_SEQUENCE_NUMBER            NUMBER,
 	PLANNED_ARRIVAL_DATE            DATE,
 	PLANNED_DEPARTURE_DATE          DATE,
 	ACTUAL_ARRIVAL_DATE             DATE,
 	ACTUAL_DEPARTURE_DATE           DATE,
 	DEPARTURE_GROSS_WEIGHT          NUMBER,
 	DEPARTURE_NET_WEIGHT            NUMBER,
 	WEIGHT_UOM_CODE                 VARCHAR2(3),
 	DEPARTURE_VOLUME                NUMBER,
 	VOLUME_UOM_CODE                 VARCHAR2(3),
 	DEPARTURE_SEAL_CODE             VARCHAR2(30),
 	DEPARTURE_FILL_PERCENT          NUMBER,
 	TP_ATTRIBUTE_CATEGORY           VARCHAR2(150),
 	TP_ATTRIBUTE1                   VARCHAR2(150),
 	TP_ATTRIBUTE2                   VARCHAR2(150),
 	TP_ATTRIBUTE3                   VARCHAR2(150),
 	TP_ATTRIBUTE4                   VARCHAR2(150),
 	TP_ATTRIBUTE5                   VARCHAR2(150),
 	TP_ATTRIBUTE6                   VARCHAR2(150),
 	TP_ATTRIBUTE7                   VARCHAR2(150),
 	TP_ATTRIBUTE8                   VARCHAR2(150),
 	TP_ATTRIBUTE9                   VARCHAR2(150),
 	TP_ATTRIBUTE10                  VARCHAR2(150),
 	TP_ATTRIBUTE11                  VARCHAR2(150),
 	TP_ATTRIBUTE12                  VARCHAR2(150),
 	TP_ATTRIBUTE13                  VARCHAR2(150),
 	TP_ATTRIBUTE14                  VARCHAR2(150),
 	TP_ATTRIBUTE15                  VARCHAR2(150),
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
	WSH_LOCATION_ID			NUMBER,
	TRACKING_DRILLDOWN_FLAG		VARCHAR2(1),
	TRACKING_REMARKS		VARCHAR2(4000),
	CARRIER_EST_DEPARTURE_DATE	DATE,
	CARRIER_EST_ARRIVAL_DATE	DATE,
	LOADING_START_DATETIME		DATE,
	LOADING_END_DATETIME		DATE,
	UNLOADING_START_DATETIME	DATE,
	UNLOADING_END_DATETIME		DATE,
/* I Harmonization: Non Database Columns Added rvishnuv */
	ROWID				VARCHAR2(4000),
	TRIP_NAME                       VARCHAR2(30),
        STOP_LOCATION_CODE              wsh_locations.UI_LOCATION_CODE%TYPE,
        WEIGHT_UOM_DESC                 VARCHAR2(25),
        VOLUME_UOM_DESC                 VARCHAR2(25),
        LOCK_STOP_ID                    NUMBER,
        PENDING_INTERFACE_FLAG          VARCHAR2(1),
        TRANSACTION_HEADER_ID           NUMBER,
/* J Inbound Logistics new columns jckwok */
        SHIPMENTS_TYPE_FLAG             VARCHAR2(30),
-- J: W/V Changes
        WV_FROZEN_FLAG                  VARCHAR2(1),
/* J TP/TL  ttrichy*/
        WKEND_LAYOVER_STOPS             NUMBER,
        WKDAY_LAYOVER_STOPS             NUMBER,
        TP_STOP_ID                      NUMBER,
        PHYSICAL_STOP_ID                NUMBER,
        PHYSICAL_LOCATION_ID            NUMBER,
        TMS_INTERFACE_FLAG              WSH_TRIP_STOPS.TMS_INTERFACE_FLAG%TYPE  --OTM R12, glog proj
);

--
--  Procedure:          Create_Trip_Stop
--  Parameters:         Trip_Stop_info; rowid, stop_id
--				    and x_return_status as OUT
--  Description:        This procedure will create a trip. It will
--                      return to the use the trip_id and generates a name if
--				    trip name is not specified.
--
TYPE Stop_Attr_Tbl_Type is TABLE of trip_stop_rec_type index by binary_integer;

PROCEDURE Create_Trip_Stop(
  p_trip_stop_info	IN  		trip_stop_rec_type,
  x_rowid			OUT NOCOPY  		VARCHAR2,
  x_stop_id		OUT NOCOPY  		NUMBER,
  x_return_status	OUT NOCOPY 		VARCHAR2
);

--
--  Procedure:          Delete_Trip_Stop
--  Parameters:         Row_id,trip_id and validate_flag IN, x_return_status OUT
--  Description:        This procedure will delete a trip. If rowid is not null
--				    trip_stop_id is found; trip_stop_id is then used to
--				    delete trip.
--                      validate_flag - 'Y' calls check_stop_delete procedure
--

procedure Delete_Trip_Stop(
  p_rowid			IN		VARCHAR2,
  p_stop_id		IN		NUMBER,
  x_return_status	OUT NOCOPY 		VARCHAR2,
  p_validate_flag   IN        VARCHAR2 DEFAULT 'Y',
  p_caller          IN  VARCHAR2 DEFAULT NULL
);


--
--  Procedure:          Update_Trip_Stop
--  Parameters:         Rowid, Trip_Stop_info IN; x_return_status OUT
--  Description:        This procedure will update a trip.
--

procedure Update_Trip_Stop(
	p_rowid			IN		VARCHAR2,
	p_stop_info		IN		trip_stop_rec_type,
	x_return_status	OUT NOCOPY 		VARCHAR2
);

--
--  Procedure:          Lock_Trip_Stop
--  Parameters:         Rowid, Trip_Stop_info IN; x_return_status OUT
--  Description:        This procedure will lock a trip row after checking
--				    to see if all attributes remain the same
--

procedure Lock_Trip_Stop(
	p_rowid			IN		VARCHAR2,
	p_stop_info		IN		trip_stop_rec_type
);

--
--  Procedure:          Populate_Record
--  Parameters:         Stop id as IN, Stop Record info and return status as OUT
--  Description:        This procedure will populate a Stop Record.
--

Procedure Populate_Record(
	p_stop_id			IN	NUMBER,
	x_stop_info		OUT NOCOPY 	trip_stop_rec_type,
	x_return_status	OUT NOCOPY 	VARCHAR2);

--
--  Function:		Get_Name
--  Parameters:		p_stop_id - Id for stop
--  Description:	This procedure will return Stop Location Name for a Stop Id
--

  FUNCTION Get_Name
		(p_stop_id		IN	NUMBER,
                 p_caller               IN      VARCHAR2 DEFAULT 'WSH'
		 ) RETURN VARCHAR2;


-----------------------------------------------------------------------------
--
-- Procedure:     Get_Disabled_List
-- Parameters:    stop_id, x_return_status, p_trip_flag
-- Description:   Get the disabled columns/fields in a trip stop
--
-----------------------------------------------------------------------------

PROCEDURE Get_Disabled_List (
						p_stop_id        IN  NUMBER,
						p_parent_entity_id IN NUMBER ,
						p_list_type		  IN  VARCHAR2,
						x_return_status  OUT NOCOPY  VARCHAR2,
						x_disabled_list  OUT NOCOPY  wsh_util_core.column_tab_type,
						x_msg_count             OUT NOCOPY      NUMBER,
						x_msg_data              OUT NOCOPY      VARCHAR2,
						p_caller IN VARCHAR2 DEFAULT NULL --3509004:public api changes
						);


--
--  Procedure:   Lock_Trip_Stop Wrapper
--  Parameters:  A table of all attributes of a Trip Stop Record,
--               Caller in
--               Return_Status,Valid_index_id_tab out
--  Description: This procedure will lock multiple Trip Stops.

procedure Lock_Trip_Stop(
	p_rec_attr_tab		IN		Stop_Attr_Tbl_Type,
        p_caller		IN		VARCHAR2,
        p_valid_index_tab       IN              wsh_util_core.id_tab_type,
        x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
	x_return_status		OUT		NOCOPY VARCHAR2
);

PROCEDURE lock_trip_stop_no_compare (p_stop_id IN  NUMBER);

--OTM R12, glog proj, new procedure added
--
--  Procedure:   Update_TMS_Interface_Flag
--  Parameters:
--    IN
--      p_stop_id_tab            - Table of Stop ids
--      p_tms_interface_flag_tab - Table of Tms Interface flag
--    OUT
--      x_return_status          - return status
--
--  Description: This procedure will update tms_interface_flag
--               at Stop level, based on the input Stop id and
--               Tms Interface flag value
--
PROCEDURE Update_TMS_interface_flag
  (p_stop_id_tab            IN            WSH_UTIL_CORE.ID_TAB_TYPE,
   p_tms_interface_flag_tab IN            WSH_UTIL_CORE.COLUMN_TAB_TYPE,
   x_return_status             OUT NOCOPY VARCHAR2);

END WSH_TRIP_STOPS_PVT;

/
