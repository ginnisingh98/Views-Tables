--------------------------------------------------------
--  DDL for Package FTE_MLS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_MLS_UTIL" AUTHID CURRENT_USER AS
/* $Header: FTEMLUTS.pls 120.2 2005/06/20 06:40:56 appldev ship $ */

FTE_CHAR CONSTANT VARCHAR2(1) := chr(0);
FTE_NUM	CONSTANT	NUMBER	:=	-9999;
c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

--{
    PROCEDURE api_post_call
		(
		  p_api_name           IN     VARCHAR2,
		  p_api_return_status  IN     VARCHAR2,
		  p_message_name       IN     VARCHAR2,
		  p_trip_segment_id    IN     VARCHAR2 DEFAULT NULL,
		  p_trip_segment_name  IN     VARCHAR2 DEFAULT NULL,
		  p_trip_stop_id       IN     NUMBER DEFAULT NULL,
		  p_stop_seq_number    IN     NUMBER DEFAULT NULL,
		  p_trip_id            IN     VARCHAR2 DEFAULT NULL,
		  p_trip_name          IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_id        IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_name      IN     VARCHAR2 DEFAULT NULL,
		  x_number_of_errors   IN OUT NOCOPY  NUMBER,
		  x_number_of_warnings IN OUT NOCOPY  NUMBER,
		  x_return_status      OUT NOCOPY     VARCHAR2
		);
    --
    --
    PROCEDURE get_trip_segment_name
		(
		  p_trip_segment_id                 IN     NUMBER,
	          x_trip_segment_name      	    OUT NOCOPY 	   VARCHAR2,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    FUNCTION all_other_segments_closed
		(
	          P_trip_segment_id         IN	   NUMBER,
		  p_trip_id                 IN     NUMBER
		)
    RETURN BOOLEAN;
    --
    --IF x_next_segment_id IS NULL, it implies there is no next segment
    --
    --
    PROCEDURE get_next_segment_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_trip_id                 IN     NUMBER,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_next_segment_id	    OUT NOCOPY 	   NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    --IF x_previous_segment_id IS NULL, it implies there is no previous segment
    --
    --
    PROCEDURE get_previous_segment_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_trip_id                 IN     NUMBER,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_previous_segment_id	    OUT NOCOPY 	   NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    --IF x_first_stop_location_id IS NULL, it implies there are no stops
    --
    --
    PROCEDURE get_first_stop_location_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
		  x_first_stop_location_id  OUT NOCOPY     NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    --IF x_last_stop_location_id IS NULL, it implies there are no stops
    --
    --
    PROCEDURE get_last_stop_location_id
		(
	          P_trip_segment_id         IN	   NUMBER,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
		  x_last_stop_location_id   OUT NOCOPY      NUMBER,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    --	  p_trip_id                 : FTE Trip ID
    --    P_trip_segment_id         : WSH Trip ID
    --	  p_sequence_number         : Sequence of WSH Trip within FTE Trip
    --	  p_last_stop_location_id   : Last Stop location for WSH Trip
    --	  x_trip_name               : Name of FTE Trip
    --	  x_trip_segment_name       : Name of WSH Trip
    --
    --
    --
    PROCEDURE check_next_segment
		(
		  p_trip_id                 IN     NUMBER,
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_last_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    --	  p_trip_id                 : FTE Trip ID
    --    P_trip_segment_rec        : WSH Trip REcord
    --	  p_sequence_number         : Sequence of WSH Trip within FTE Trip
    --	  p_last_stop_location_id   : Last Stop location for WSH Trip
    --	  x_trip_name               : Name of FTE Trip
    --	  x_trip_segment_name       : Name of WSH Trip
    --
    --
    PROCEDURE check_next_segment
		(
		  p_trip_id                 IN     NUMBER,
	          p_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
		  p_sequence_number         IN     NUMBER,
		  p_last_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    --	  p_trip_id                 : FTE Trip ID
    --    P_trip_segment_id         : WSH Trip ID
    --	  p_sequence_number         : Sequence of WSH Trip within FTE Trip
    --	  p_first_stop_location_id  : First Stop location for WSH Trip
    --	  x_trip_name               : Name of FTE Trip
    --	  x_trip_segment_name       : Name of WSH Trip
    --
    --
    PROCEDURE check_previous_segment
		(
		  p_trip_id                 IN     NUMBER,
	          P_trip_segment_id         IN	   NUMBER,
		  p_sequence_number         IN     NUMBER,
		  p_first_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
		  x_trip_segment_name       IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    PROCEDURE check_previous_segment
		(
		  p_trip_id                 IN     NUMBER,
	          p_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
		  p_sequence_number         IN     NUMBER,
		  p_first_stop_location_id   IN     NUMBER   DEFAULT NULL,
		  x_trip_name               IN OUT NOCOPY  VARCHAR2,
	          x_connected	            OUT NOCOPY 	   BOOLEAN,
	          x_return_status	    OUT NOCOPY 	   VARCHAR2
		);
    --
    --
    FUNCTION segment_has_intransit_dlvy
		(
	          P_trip_segment_rec        IN	   WSH_TRIPS_GRP.Trip_Pub_Rec_Type
		)
    RETURN BOOLEAN;
    --
    --
    FUNCTION stop_has_intransit_dlvy
		(
	          P_trip_stop_rec        IN	   WSH_TRIP_STOPS_GRP.Trip_stop_Pub_Rec_Type
		)
    RETURN BOOLEAN;
    --
    --
    FUNCTION stop_has_intransit_dlvy
		(
	          P_trip_stop_id        IN	   NUMBER
		)
    RETURN BOOLEAN;
    --
    FUNCTION get_carrier_name
		(
	          p_carrier_id        IN	   NUMBER
		)
    RETURN VARCHAR2;
    --
    --
    PROCEDURE get_location_info
		(
	          p_location_id		IN	NUMBER,
	          x_location		OUT NOCOPY 	VARCHAR2,
	          x_csz			OUT NOCOPY 	VARCHAR2,
	          x_country		OUT NOCOPY 	VARCHAR2,
	          x_return_status	OUT NOCOPY 	VARCHAR2
		);
    --
    --
    PROCEDURE derive_ship_method
		(
		  p_carrier_id                IN     NUMBER,
		  p_mode_of_transport         IN     VARCHAR2,
		  p_service_level             IN     VARCHAR2,
		  p_carrier_name              IN     VARCHAR2,
		  p_mode_of_transport_meaning IN     VARCHAR2,
		  p_service_level_meaning     IN     VARCHAR2,
		  x_ship_method_code          OUT NOCOPY     VARCHAR2,
	          x_return_status	      OUT NOCOPY     VARCHAR2
		);
    --
    --
    FUNCTION segment_has_other_deliveries
		(
	          P_trip_segment_id        IN	   NUMBER,
		  p_delivery_id            IN      NUMBER
		)
    RETURN BOOLEAN;
    --
    --
    FUNCTION get_delivery_legs
    		(
    		  p_trip_segment_id	  IN NUMBER
   		)
    RETURN VARCHAR2;

    -- Added Pack I - HBHAGAVA
    FUNCTION get_message
		(
	          p_msg_count         IN	   NUMBER,
		  p_msg_data          IN     	   VARCHAR2
		)
    RETURN VARCHAR2;
    --
    --
    -- Return Mode of Transport meaning
    --
    FUNCTION get_mode_of_transport
		(
	          p_mode_code         IN	   VARCHAR2
		)
    RETURN VARCHAR2;
    --
    --
    FUNCTION GET_SERVICE_LEVEL
		(
	          p_service_level         IN	   VARCHAR2
		)
    RETURN VARCHAR2;
    --
    --
    PROCEDURE get_location_info
		(
	          p_location_id		IN	NUMBER,
	          x_location		OUT NOCOPY 	VARCHAR2,
	          x_return_status	OUT NOCOPY 	VARCHAR2
		);
    --
    --
    PROCEDURE GET_CARRIER_CONTACT_INFO
		(p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_tender_number		  IN	 NUMBER,
		x_return_status           OUT NOCOPY     VARCHAR2,
		x_msg_count               OUT NOCOPY     NUMBER,
		x_msg_data                OUT NOCOPY     VARCHAR2,
		x_contact_email		  OUT NOCOPY 	 VARCHAR2,
		x_contact_fax	  	  OUT NOCOPY 	 VARCHAR2,
		x_contact_phone		  OUT NOCOPY 	 VARCHAR2,
		x_contact_name		  OUT NOCOPY 	 VARCHAR2);
    --

    FUNCTION GET_ORG_NAME_BY_FIRSTSTOP
			(p_stop_id	IN	NUMBER)
    RETURN VARCHAR2;

	FUNCTION GET_PICKUP_DLVY_ORG_BY_TRIP
		(p_trip_id	IN	NUMBER)
	RETURN VARCHAR2;


	FUNCTION GET_PICKUP_DLVY_ORGID_BY_TRIP
			(p_trip_id	IN	NUMBER)
	RETURN NUMBER;

    PROCEDURE GET_SHIPPER_CONTACT_INFO
		(p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_shipper_name	  IN	 VARCHAR2,
		x_return_status           OUT NOCOPY     VARCHAR2,
		x_msg_count               OUT NOCOPY     NUMBER,
		x_msg_data                OUT NOCOPY     VARCHAR2,
		x_shipper_name		  OUT NOCOPY 	 VARCHAR2,
		x_contact_email		  OUT NOCOPY 	 VARCHAR2,
		x_contact_phone		  OUT NOCOPY 	 VARCHAR2,
		x_contact_fax		  OUT NOCOPY 	 VARCHAR2);
    --

    FUNCTION GET_CARRIER_ID(
                             p_tender_id IN NUMBER
			    )
    RETURN NUMBER;


    FUNCTION FTE_UOM_CONV
		(
	          p_from_quantity	IN NUMBER,
	          p_from_uom	IN VARCHAR2,
	          p_to_uom	IN VARCHAR2
		)
    RETURN NUMBER;

 --
    --========================================================================
    -- PROCEDURE : COPY_FTE_ID_TO_WSH_ID
    --
    -- PARAMETERS: p_fte_id_tab		IN		FTE_ID_TAB_TYPE
    --             x_wsh_id_tab		OUT NOCOPY 	WSH_UTIL_CORE.id_tab_type
    -- VERSION   : current version      1.0
    --             initial version      1.0
    --========================================================================

	PROCEDURE COPY_FTE_ID_TO_WSH_ID (p_fte_id_tab	IN FTE_ID_TAB_TYPE,
					 x_wsh_id_tab	OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE);


    --
    --========================================================================
    -- PROCEDURE : COPY_WSH_ID_TO_FTE_ID
    --
    -- PARAMETERS: p_wsh_id_tab		IN		WSH_UTIL_CORE.id_tab_type
    -- 		   x_fte_id_tab		OUT NOCOPY	FTE_ID_TAB_TYPE
    --
    -- VERSION   : current version         1.0
    --             initial version         1.0
    --========================================================================

	PROCEDURE COPY_WSH_ID_TO_FTE_ID (p_wsh_id_tab	IN WSH_UTIL_CORE.ID_TAB_TYPE,
					 x_fte_id_tab	IN OUT NOCOPY FTE_ID_TAB_TYPE);



	--{Rel 12 HBHAGAVA

	PROCEDURE GET_MESSAGE_MEANING (p_message_name	IN	VARCHAR2,
					x_message_text  OUT NOCOPY	VARCHAR2);


	--{Rel 12 HBHAGAVA

	FUNCTION Get_Lookup_Meaning(p_lookup_type       IN      VARCHAR2,
	                            P_lookup_code       IN      VARCHAR2)
	RETURN VARCHAR2;



	FUNCTION GET_TRIP_ORGANIZATION_ID(p_trip_id		     NUMBER) RETURN NUMBER;


	PROCEDURE GET_FIRST_LAST_STOP_INFO(x_return_status          OUT NOCOPY 	VARCHAR2,
			    x_arrival_date	     OUT NOCOPY		DATE,
			    x_departure_date	     OUT NOCOPY		DATE,
			    x_first_stop_id	     OUT NOCOPY		NUMBER,
			    x_last_stop_id	     OUT NOCOPY		NUMBER,
			    x_first_stop_loc_id	     OUT NOCOPY		NUMBER,
			    x_last_stop_loc_id	     OUT NOCOPY		NUMBER,
			    p_trip_id		     NUMBER);


PROCEDURE GET_CURRENCY_CODE(
	    p_init_msg_list          IN   		VARCHAR2,
	    x_return_status          OUT NOCOPY 	VARCHAR2,
	    x_msg_count              OUT NOCOPY 	NUMBER,
	    x_msg_data               OUT NOCOPY 	VARCHAR2,
	    x_currency_code	     OUT NOCOPY		VARCHAR2,
	    p_entity_type	     IN			VARCHAR2,
	    p_entity_id		     IN			NUMBER,
	    p_carrier_id	     IN			NUMBER);


PROCEDURE GET_SUPPLIER_INFO(
	    p_init_msg_list          IN   		VARCHAR2,
	    x_return_status          OUT NOCOPY 	VARCHAR2,
	    x_msg_count              OUT NOCOPY 	NUMBER,
	    x_msg_data               OUT NOCOPY 	VARCHAR2,
	    x_currency_code	     OUT NOCOPY		VARCHAR2,
	    x_supplier_id	     OUT NOCOPY		NUMBER,
	    x_supplier_site_id	     OUT NOCOPY		NUMBER,
	    x_carrier_site_id	     OUT NOCOPY		NUMBER,
	    p_entity_type	     IN			VARCHAR2,
	    p_entity_id		     IN			NUMBER);


--}
END FTE_MLS_UTIL;

 

/
