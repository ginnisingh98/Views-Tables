--------------------------------------------------------
--  DDL for Package FTE_WSH_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_WSH_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEWSHIS.pls 120.1 2005/06/03 16:27:52 appldev  $ */
--{
    G_PKG_NAME      CONSTANT VARCHAR2(30):= 'FTE_WSH_INTERFACE_PKG';
    --
    --
    -- These constants indicate type of change for each record.
    --
    G_ADD       CONSTANT VARCHAR2(30) := 'ADD';
    G_UPDATE    CONSTANT VARCHAR2(30) := 'UPDATE';
    G_DELETE    CONSTANT VARCHAR2(30) := 'DELETE';
    G_NO_CHANGE CONSTANT VARCHAR2(30) := 'NO_CHANGE';
    G_TRIP_SEGMENT_DELETE CONSTANT VARCHAR2(30) := 'TRIP_SEGMENT_DELETE';
    --
    --
    TYPE tripSegmentChangeInRecType
    IS
    RECORD
      (
        action_type VARCHAR2(32767)
      );
    --
    --
    TYPE tripSegmentChangeOutRecType
    IS
    RECORD
      (
        parameter1 VARCHAR2(32767) DEFAULT FND_API.G_MISS_CHAR
      );
    --
    --
    TYPE segmentStopChangeInRecType
    IS
    RECORD
      (
        action_type VARCHAR2(32767)
      );
    --
    --
    TYPE segmentStopChangeOutRecType
    IS
    RECORD
      (
        parameter1 VARCHAR2(32767) DEFAULT FND_API.G_MISS_CHAR
      );
    --
    --
    --
    PROCEDURE trip_segment_change
		(
	          P_api_version		    IN	   NUMBER,
	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          P_commit		    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          X_return_status	    OUT NOCOPY	   VARCHAR2,
	          X_msg_count		    OUT NOCOPY	   NUMBER,
	          X_msg_data		    OUT NOCOPY	   VARCHAR2,
	          P_old_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_new_trip_segment_rec    IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
		  p_tripSegmentChangeInRec  IN     tripSegmentChangeInRecType,
		  p_tripSegmentChangeOutRec OUT NOCOPY    tripSegmentChangeOutRecType
		);
    --
    --
    PROCEDURE segment_stop_change
		(
	          P_api_version		    IN	   NUMBER,
	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          P_commit		    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          X_return_status	    OUT NOCOPY	   VARCHAR2,
	          X_msg_count		    OUT NOCOPY	   NUMBER,
	          X_msg_data		    OUT NOCOPY	   VARCHAR2,
	          P_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_old_segment_stop_rec    IN	   WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
	          P_new_segment_stop_rec    IN	   WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
		  p_segmentStopChangeInRec  IN     segmentStopChangeInRecType,
		  p_segmentStopChangeOutRec OUT NOCOPY     segmentStopChangeOutRecType
		);
--}

--{
-- Rel12 HBHAGAVA

PROCEDURE GET_ORG_ORGANIZATION_INFO(
	    p_init_msg_list          IN   		VARCHAR2,
	    x_return_status          OUT NOCOPY 	VARCHAR2,
	    x_msg_count              OUT NOCOPY 	NUMBER,
	    x_msg_data               OUT NOCOPY 	VARCHAR2,
	    x_organization_id	     OUT NOCOPY		NUMBER,
	    x_org_id		     OUT NOCOPY		NUMBER,
	    p_entity_id	     	     IN			NUMBER,
	    p_entity_type	     IN			VARCHAR2,
	    p_org_id_flag	     IN			VARCHAR2 DEFAULT FND_API.G_FALSE);


--}

END FTE_WSH_INTERFACE_PKG;

 

/
