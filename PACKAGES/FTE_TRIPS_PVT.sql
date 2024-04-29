--------------------------------------------------------
--  DDL for Package FTE_TRIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TRIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: FTETRTHS.pls 115.8 2002/12/17 02:17:16 nltan noship $ */

   c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
   c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--
-- Type: 			Trip_Rectype
-- Definition:		In sync with the table definition for trips
-- Use:			In table handlers, calling packages


TYPE fte_trip_rec_type IS RECORD (
 FTE_TRIP_ID                              NUMBER,
 NAME                                     VARCHAR2(30),
 STATUS_CODE                              VARCHAR2(30),
 PRIVATE_TRIP                             VARCHAR2(1),
 VALIDATION_REQUIRED                      VARCHAR2(1),
 CREATION_DATE                            DATE,
 CREATED_BY                               NUMBER,
 LAST_UPDATE_DATE                         DATE,
 LAST_UPDATED_BY                          NUMBER,
 LAST_UPDATE_LOGIN                        NUMBER,
 PROGRAM_APPLICATION_ID                   NUMBER,
 PROGRAM_ID                               NUMBER,
 PROGRAM_UPDATE_DATE                      DATE,
 REQUEST_ID                               NUMBER,
 ATTRIBUTE_CATEGORY                       VARCHAR2(150),
 ATTRIBUTE1                               VARCHAR2(150),
 ATTRIBUTE2                               VARCHAR2(150),
 ATTRIBUTE3                               VARCHAR2(150),
 ATTRIBUTE4                               VARCHAR2(150),
 ATTRIBUTE5                               VARCHAR2(150),
 ATTRIBUTE6                               VARCHAR2(150),
 ATTRIBUTE7                               VARCHAR2(150),
 ATTRIBUTE8                               VARCHAR2(150),
 ATTRIBUTE9                               VARCHAR2(150),
 ATTRIBUTE10                              VARCHAR2(150),
 ATTRIBUTE11                              VARCHAR2(150),
 ATTRIBUTE12                              VARCHAR2(150),
 ATTRIBUTE13                              VARCHAR2(150),
 ATTRIBUTE14                              VARCHAR2(150),
 ATTRIBUTE15                              VARCHAR2(150),
 ROUTE_ID                                 NUMBER
);


    PROCEDURE get_trip_name
		(
		  p_trip_id                 IN     NUMBER,
	          x_trip_name      	    OUT NOCOPY	   VARCHAR2,
	          x_return_status	    OUT NOCOPY	   VARCHAR2
		);

-- Wrapper around create_trip and update_trip
-- (create pl/sql record and depending on p_action_code is 'CREATE' or 'UPDATE' or 'DELETE'

 PROCEDURE Create_Update_Delete_Fte_Trip
		(
 		p_api_version_number     IN   NUMBER,
		p_init_msg_list          IN   VARCHAR2,
		x_msg_count              OUT NOCOPY  NUMBER,
		x_msg_data               OUT NOCOPY  VARCHAR2,
		 pp_FTE_TRIP_ID                        IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_NAME                               IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_STATUS_CODE                        IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_PRIVATE_TRIP                       IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		pp_VALIDATION_REQUIRED                IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_CREATION_DATE                      IN      DATE DEFAULT FND_API.G_MISS_DATE,
		 pp_CREATED_BY                         IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_LAST_UPDATE_DATE                   IN      DATE DEFAULT FND_API.G_MISS_DATE,
		 pp_LAST_UPDATED_BY                    IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_LAST_UPDATE_LOGIN                  IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_PROGRAM_APPLICATION_ID             IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_PROGRAM_ID                         IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_PROGRAM_UPDATE_DATE                IN      DATE DEFAULT FND_API.G_MISS_DATE,
		 pp_REQUEST_ID                         IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_ATTRIBUTE_CATEGORY                 IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE1                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE2                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE3                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE4                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE5                        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE6                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE7                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE8                        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE9                        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE10                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE11                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE12                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE13                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE14                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE15                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ROUTE_ID                          IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
		 p_action_code			   IN 	    VARCHAR2,
		 x_trip_id		OUT NOCOPY	NUMBER,
		 x_name             OUT NOCOPY  VARCHAR2,
		 x_return_status	OUT NOCOPY	VARCHAR2
		);


--========================================================================
-- PROCEDURE : Create_Trip
--
-- PARAMETERS: p_trip_info         Attributes for the trip entity
--             x_return_status     Return status of API
-- COMMENT   : Creates trip record with p_trip_info information
--========================================================================

 PROCEDURE Create_Trip
		(p_trip_info	     IN	fte_trip_rec_type,
		 x_trip_id		OUT NOCOPY	NUMBER,
		 x_name             OUT NOCOPY  VARCHAR2,
		 x_return_status	OUT NOCOPY	VARCHAR2
		);


 PROCEDURE Validate_CreateTrip
		(p_trip_id	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
		 p_trip_name	IN VARCHAR2,
		 x_return_status	OUT NOCOPY	VARCHAR2
		);

--========================================================================
-- PROCEDURE : Update_Trip
--
-- PARAMETERS: p_trip_info         Attributes for the trip entity
--             x_return_status     Return status of API
-- COMMENT   : Updates trip record with p_trip_info information
--========================================================================

PROCEDURE Update_Trip(
	p_trip_info		IN	fte_trip_rec_type,
	x_return_status 	OUT NOCOPY 	VARCHAR2);


PROCEDURE Validate_UpdateTrip(
	p_trip_id		IN	NUMBER,
	p_trip_name		IN	VARCHAR2,
	p_trip_status		IN	VARCHAR2,
	x_return_status 	OUT NOCOPY 	VARCHAR2);


PROCEDURE Delete_Trip(
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY	VARCHAR2
  );


PROCEDURE Validate_DeleteTrip(
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY	VARCHAR2
  );


-- Trip Segment validation for a Trip
PROCEDURE Validate_Trip(
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY	VARCHAR2,
  x_msg_count 		OUT NOCOPY 	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2
  );

-- pass in del ids as a comma seperated list which will
-- be assigned to fte_trip
-- comma seperated list will be of form d100, d101, .. (have to remove
-- "d" before update)

    PROCEDURE assign_deliveries_to_ftetrip
		(
                p_del_ids               IN      VARCHAR2,
		p_fte_trip_id		IN	NUMBER,
		p_wsh_trip_id		IN	NUMBER,
  		x_return_status		OUT NOCOPY	VARCHAR2,
  		x_msg_count 		OUT NOCOPY 	NUMBER,
 		x_msg_data		OUT NOCOPY	VARCHAR2
		);

-- Added in Pack I (hbhagava) --


FUNCTION GET_TRIP_BY_TENDER_NUMBER(p_tender_number	NUMBER)	RETURN NUMBER;


---
PROCEDURE GET_LAST_STOP_LOCATION_INFO
	(
	  P_trip_segment_id         	IN		NUMBER,
	  x_trip_segment_name       	IN OUT NOCOPY 		VARCHAR2,
	  x_last_stop_location_id   	OUT NOCOPY     	NUMBER,
	  x_return_status		OUT NOCOPY	   	VARCHAR2,
	  x_planned_arvl_dt    		OUT NOCOPY		DATE,
	  x_planned_dept_dt		OUT NOCOPY		DATE
	);

---
---
PROCEDURE GET_FIRST_STOP_LOCATION_INFO
	(
	  P_trip_segment_id         	IN		NUMBER,
	  x_trip_segment_name       	IN OUT NOCOPY 		VARCHAR2,
	  x_first_stop_location_id   	OUT NOCOPY     	NUMBER,
	  x_return_status		OUT NOCOPY	   	VARCHAR2,
	  x_planned_arvl_dt    		OUT NOCOPY		DATE,
	  x_planned_dept_dt		OUT NOCOPY		DATE
	);

---
--
--
PROCEDURE GET_TRIP_SEGMENT_NAME
	(
	  p_trip_segment_id                 IN     NUMBER,
	  x_trip_segment_name      	    OUT NOCOPY	   VARCHAR2,
	  x_return_status	    OUT NOCOPY	   VARCHAR2
	);
--
--

PROCEDURE GET_SHIPMENT_INFORMATION
	(p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_tender_number		  IN	 NUMBER,
	x_return_status           OUT NOCOPY    VARCHAR2,
	x_msg_count               OUT NOCOPY    NUMBER,
	x_msg_data                OUT NOCOPY    VARCHAR2,
	x_shipment_info		  OUT NOCOPY	 VARCHAR2,
	x_shipping_org_name	  OUT NOCOPY	 VARCHAR2);

PROCEDURE GET_TRIP_INFO_FROM_DLVY
		(p_tender_number		  IN	 NUMBER,
		 p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	 	 x_return_status           OUT NOCOPY    VARCHAR2,
 		 x_msg_count               OUT NOCOPY    NUMBER,
		 x_msg_data                OUT NOCOPY    VARCHAR2,
		 x_total_weight		 OUT NOCOPY NUMBER,
		 x_weight_uom		 OUT NOCOPY VARCHAR2,
		 x_total_volume		 OUT NOCOPY NUMBER,
		 x_volume_uom		 OUT NOCOPY VARCHAR2);


END fte_trips_pvt;

 

/
