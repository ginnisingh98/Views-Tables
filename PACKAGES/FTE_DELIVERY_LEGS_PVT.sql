--------------------------------------------------------
--  DDL for Package FTE_DELIVERY_LEGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_DELIVERY_LEGS_PVT" AUTHID CURRENT_USER as
/* $Header: FTEVDLGS.pls 120.3 2005/07/28 12:34:18 nltan ship $ */
--{
  GK_DLEG_WB_PAGE        CONSTANT VARCHAR2(32767) := 'FTE_MLS_DLEG_WB_PAGE';
  GK_SEARCH_SEGMENTS_PAGE CONSTANT VARCHAR2(32767) := 'FTE_MLS_SEARCH_SEG_PAGE';

  PROCEDURE search_segment_save
	      (
	        P_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        X_return_status           OUT NOCOPY    VARCHAR2,
	        X_msg_count               OUT NOCOPY    NUMBER,
	        X_msg_data                OUT NOCOPY    VARCHAR2,
		p_delivery_id             IN     NUMBER,
		p_delivery_name           IN     VARCHAR2 DEFAULT NULL,
		p_wsh_trip_id             IN     NUMBER,
		p_wsh_trip_name           IN     VARCHAR2,
		p_pickup_stop_id          IN     NUMBER,
		p_pickup_location_id      IN     NUMBER,
		p_pickup_stop_seq         IN     NUMBER,
		p_pickup_departure_date   IN     DATE,
		p_pickup_arrival_date     IN     DATE,
		p_dropoff_stop_id         IN     NUMBER,
		p_dropoff_location_id     IN     NUMBER,
		p_dropoff_stop_seq        IN     NUMBER,
		p_dropoff_departure_date  IN     DATE,
		p_dropoff_arrival_date    IN     DATE,
		p_move_stop_seq_start     IN     NUMBER,
		p_move_stop_seq_to        IN     NUMBER,
		p_fte_trip_id             IN     NUMBER,
		p_pricing_request_id      IN     NUMBER,
		p_lane_id                 IN     NUMBER,
		p_schedule_id             IN     NUMBER,
		p_ignore_for_planning	  IN     VARCHAR2 DEFAULT NULL,
		x_pickup_stop_id          OUT NOCOPY    NUMBER,
		x_dropoff_stop_id         OUT NOCOPY    NUMBER,
		x_delivery_leg_id         OUT NOCOPY    NUMBER,
		x_delivery_leg_seq        OUT NOCOPY    NUMBER,
		x_pickup_stop_seq         OUT NOCOPY    NUMBER,
		x_dropoff_stop_seq        OUT NOCOPY    NUMBER
	      );

  PROCEDURE process_delivery_leg
	      (
	        P_init_msg_list             IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        X_return_status             OUT NOCOPY    VARCHAR2,
	        X_msg_count                 OUT NOCOPY    NUMBER,
	        X_msg_data                  OUT NOCOPY    VARCHAR2,
		p_ui_page_name              IN     VARCHAR2 DEFAULT GK_DLEG_WB_PAGE,
		p_delivery_id               IN     NUMBER,
		p_delivery_name             IN     VARCHAR2 DEFAULT NULL,
		p_delivery_leg_id           IN     NUMBER   DEFAULT NULL,
		p_delivery_leg_seq          IN     NUMBER   DEFAULT NULL,
		p_wsh_trip_id               IN     NUMBER   DEFAULT NULL,
		p_wsh_trip_name             IN     VARCHAR2 DEFAULT NULL,
		p_lane_id                   IN     NUMBER   DEFAULT NULL,
		p_schedule_id               IN     NUMBER   DEFAULT NULL,
		p_carrier_id                IN     NUMBER   DEFAULT NULL,
		p_mode_of_transport         IN     VARCHAR2 DEFAULT NULL,
		p_service_level             IN     VARCHAR2 DEFAULT NULL,
		p_carrier_name              IN     VARCHAR2 DEFAULT NULL,
		p_mode_of_transport_meaning IN     VARCHAR2 DEFAULT NULL,
		p_service_level_meaning     IN     VARCHAR2 DEFAULT NULL,
		p_pickup_stop_id            IN     NUMBER   DEFAULT NULL,
		p_pickup_stop_seq           IN     NUMBER   DEFAULT NULL,
		p_pickup_location_id        IN     NUMBER   DEFAULT NULL,
		p_pickup_departure_date     IN     DATE     DEFAULT NULL,
		p_pickup_arrival_date       IN     DATE     DEFAULT NULL,
		p_dropoff_stop_id           IN     NUMBER   DEFAULT NULL,
		p_dropoff_stop_seq          IN     NUMBER   DEFAULT NULL,
		p_dropoff_location_id       IN     NUMBER   DEFAULT NULL,
		p_dropoff_departure_date    IN     DATE     DEFAULT NULL,
		p_dropoff_arrival_date      IN     DATE     DEFAULT NULL,
		p_fte_trip_id               IN     NUMBER   DEFAULT NULL,
		p_fte_trip_name             IN     VARCHAR2 DEFAULT NULL,
		p_pricing_request_id        IN     NUMBER   DEFAULT NULL,
		p_move_stop_seq_start       IN     NUMBER   DEFAULT NULL,
		p_move_stop_seq_to          IN     NUMBER   DEFAULT NULL,
		p_first_stop_id             IN     NUMBER   DEFAULT NULL,
		p_first_stop_location_id    IN     NUMBER   DEFAULT NULL,
		p_first_stop_seq            IN     NUMBER   DEFAULT NULL,
		p_first_stop_departure_date IN     DATE     DEFAULT NULL,
		p_first_stop_arrival_date   IN     DATE     DEFAULT NULL,
		p_last_stop_id              IN     NUMBER   DEFAULT NULL,
		p_last_stop_location_id     IN     NUMBER   DEFAULT NULL,
		p_last_stop_seq             IN     NUMBER   DEFAULT NULL,
		p_last_stop_departure_date  IN     DATE     DEFAULT NULL,
		p_last_stop_arrival_date    IN     DATE     DEFAULT NULL,
		p_veh_org_id		    IN 	   NUMBER   DEFAULT NULL,
		p_veh_num		    IN 	   NUMBER   DEFAULT NULL,
		p_veh_num_pre	    	    IN 	   NUMBER   DEFAULT NULL,
                p_ignore_for_planning	    IN VARCHAR2 DEFAULT NULL,
                p_veh_item_id		    IN     NUMBER   DEFAULT NULL,
		x_wsh_trip_id               OUT NOCOPY    NUMBER,
		x_wsh_trip_name             OUT NOCOPY    VARCHAR2,
		x_ship_method_code          OUT NOCOPY    VARCHAR2,
		x_fte_trip_id               OUT NOCOPY    NUMBER,
		x_fte_trip_name             OUT NOCOPY    VARCHAR2,
		x_pickup_stop_id            OUT NOCOPY    NUMBER,
		x_dropoff_stop_id           OUT NOCOPY    NUMBER,
		x_delivery_leg_id           OUT NOCOPY    NUMBER,
		x_delivery_leg_seq           OUT NOCOPY    NUMBER,
		x_pickup_stop_seq           OUT NOCOPY    NUMBER,
		x_dropoff_stop_seq          OUT NOCOPY    NUMBER
	      );
  PROCEDURE assign_service_to_segment
	      (
	        P_init_msg_list             IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        X_return_status             OUT NOCOPY    VARCHAR2,
	        X_msg_count                 OUT NOCOPY    NUMBER,
	        X_msg_data                  OUT NOCOPY    VARCHAR2,
		p_ui_page_name              IN     VARCHAR2 DEFAULT GK_DLEG_WB_PAGE,
		p_wsh_trip_id               IN     NUMBER,
		p_wsh_trip_name             IN     VARCHAR2,
		p_lane_id                   IN     NUMBER,
		p_carrier_id                IN     NUMBER,
		p_mode_of_transport         IN     VARCHAR2,
		p_service_level             IN     VARCHAR2,
		p_carrier_name              IN     VARCHAR2,
		p_mode_of_transport_meaning IN     VARCHAR2,
		p_service_level_meaning     IN     VARCHAR2,
		p_ship_method_code          IN     VARCHAR2 DEFAULT NULL,
		p_schedule_id               IN     NUMBER   DEFAULT NULL,
		p_first_stop_id             IN     NUMBER   DEFAULT NULL,
		p_first_stop_seq            IN     NUMBER   DEFAULT NULL,
		p_first_stop_location_id    IN     NUMBER   DEFAULT NULL,
		p_first_stop_new_location_id IN    NUMBER   DEFAULT NULL,
		p_first_stop_departure_date IN     DATE     DEFAULT NULL,
		p_first_stop_arrival_date   IN     DATE     DEFAULT NULL,
		p_last_stop_id              IN     NUMBER   DEFAULT NULL,
		p_last_stop_seq             IN     NUMBER   DEFAULT NULL,
		p_last_stop_location_id     IN     NUMBER   DEFAULT NULL,
		p_last_stop_new_location_id IN     NUMBER   DEFAULT NULL,
		p_last_stop_departure_date  IN     DATE     DEFAULT NULL,
		p_last_stop_arrival_date    IN     DATE     DEFAULT NULL,
		p_veh_org_id		    IN     NUMBER   DEFAULT NULL,
		p_veh_item_id		    IN     NUMBER   DEFAULT NULL
	      );
    --
    --
    PROCEDURE build_delivery_leg_info
    		(
		  P_init_msg_list               IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
		  X_return_status               OUT NOCOPY     VARCHAR2,
		  X_msg_count                   OUT NOCOPY     NUMBER,
		  X_msg_data                    OUT NOCOPY     VARCHAR2,
    		  p_dleg_id		        IN      NUMBER,
    		  x_PUStopId			OUT NOCOPY	NUMBER,
    		  x_PUStopLocationId		OUT NOCOPY	NUMBER,
    		  x_PUStopLocation		OUT NOCOPY	VARCHAR2,
    		  x_PUStopCSZ			OUT NOCOPY	VARCHAR2,
    		  x_PUStopCountry		OUT NOCOPY	VARCHAR2,
    		  x_PUStopActualArrivalDate	OUT NOCOPY	DATE,
    		  x_PUStopActualDepartureDate	OUT NOCOPY	DATE,
    		  x_PUStopPlannedArrivalDate	OUT NOCOPY	DATE,
    		  x_PUStopPlannedDepartureDate	OUT NOCOPY	DATE,
    		  x_PUStopSequenceNumber	OUT NOCOPY	NUMBER,
    		  x_PUStopStatusCode		OUT NOCOPY	VARCHAR2,
    		  x_PUStopTripId		OUT NOCOPY	NUMBER,
    		  x_DOStopId			OUT NOCOPY	NUMBER,
    		  x_DOStopLocationId		OUT NOCOPY	NUMBER,
    		  x_DOStopLocation		OUT NOCOPY	VARCHAR2,
    		  x_DOStopCSZ			OUT NOCOPY	VARCHAR2,
    		  x_DOStopCountry		OUT NOCOPY	VARCHAR2,
    		  x_DOStopActualArrivalDate	OUT NOCOPY	DATE,
    		  x_DOStopActualDepartureDate	OUT NOCOPY	DATE,
    		  x_DOStopPlannedArrivalDate	OUT NOCOPY	DATE,
    		  x_DOStopPlannedDepartureDate	OUT NOCOPY	DATE,
    		  x_DOStopSequenceNumber	OUT NOCOPY	NUMBER,
    		  x_DOStopStatusCode		OUT NOCOPY	VARCHAR2,
    		  x_DOStopTripId		OUT NOCOPY	NUMBER,
		  x_CarrierId			OUT NOCOPY	NUMBER,
		  x_CarrierName			OUT NOCOPY	VARCHAR2,
		  x_LaneId			OUT NOCOPY	NUMBER,
		  x_LaneNumber			OUT NOCOPY	VARCHAR2,
		  x_ScheduleId			OUT NOCOPY	NUMBER,
		  x_ModeOfTransport		OUT NOCOPY	VARCHAR2,
		  x_ModeOfTransportMeaning	OUT NOCOPY	VARCHAR2,
		  x_ServiceLevel		OUT NOCOPY	VARCHAR2,
		  x_ServiceLevelMeaning		OUT NOCOPY	VARCHAR2,
		  x_ShipMethodCode		OUT NOCOPY	VARCHAR2,
		  x_TripSegmentId		OUT NOCOPY	NUMBER,
		  x_TripSegmentName		OUT NOCOPY	VARCHAR2,
		  x_TripSegmentStatusCode	OUT NOCOPY	VARCHAR2,
		  x_Price			OUT NOCOPY	NUMBER,
		  x_Currency			OUT NOCOPY	VARCHAR2,
		  x_OriginStopId		OUT NOCOPY	NUMBER,
		  x_OriginStopStatusCode	OUT NOCOPY	VARCHAR2,
		  x_OriginStopSequenceNumber	OUT NOCOPY	NUMBER,
		  x_OriginStopLocationId	OUT NOCOPY	NUMBER,
		  x_OriginLocation		OUT NOCOPY	VARCHAR2,
		  x_OriginCSZ			OUT NOCOPY	VARCHAR2,
		  x_OriginCountry		OUT NOCOPY	VARCHAR2,
		  x_OriginDepartureDate		OUT NOCOPY	DATE,
		  x_OriginArrivalDate		OUT NOCOPY	DATE,
		  x_DestStopId			OUT NOCOPY	NUMBER,
		  x_DestStopStatusCode		OUT NOCOPY	VARCHAR2,
		  x_DestStopSequenceNumber	OUT NOCOPY	NUMBER,
		  x_DestStopLocationId		OUT NOCOPY	NUMBER,
		  x_DestLocation		OUT NOCOPY	VARCHAR2,
		  x_DestCSZ			OUT NOCOPY	VARCHAR2,
		  x_DestCountry			OUT NOCOPY	VARCHAR2,
		  x_DestDepartureDate		OUT NOCOPY	DATE,
		  x_DestArrivalDate		OUT NOCOPY	DATE,
		  x_TenderStatus                OUT NOCOPY      VARCHAR2,
		  x_TripPlannedFlag             OUT NOCOPY      VARCHAR2,
		  x_TripShipmentsTypeFlag       OUT NOCOPY      VARCHAR2,
		  x_DOStopPhysLocationId        OUT NOCOPY      NUMBER,
		  x_DestStopPhysLocationId      OUT NOCOPY      NUMBER,
		  x_BolNumber                   OUT NOCOPY      VARCHAR2,
		  x_VehicleOrgId		OUT NOCOPY	NUMBER,
		  x_VehicleItemId		OUT NOCOPY	NUMBER,
		  x_ParentDLegId		OUT NOCOPY	NUMBER,
		  x_RankId			OUT NOCOPY	NUMBER,
		  x_RoutingRuleId		OUT NOCOPY	NUMBER,
		  x_AppendFlag			OUT NOCOPY	VARCHAR2,
		  x_ParentDlvyName		OUT NOCOPY	VARCHAR2
		 );
--}
END FTE_DELIVERY_LEGS_PVT;

 

/
