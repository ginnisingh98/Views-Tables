--------------------------------------------------------
--  DDL for Package FTE_TENDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TENDER_PVT" AUTHID CURRENT_USER AS
/* $Header: FTETEPVS.pls 120.1.12000000.1 2007/01/18 21:26:08 appldev ship $ */


S_TENDERED 	CONSTANT	VARCHAR2(30)	:= 	'TENDERED';
S_ACCEPTED	CONSTANT	VARCHAR2(30)	:=	'ACCEPTED';
S_REJECTED	CONSTANT	VARCHAR2(30)	:=	'REJECTED';
S_SHIPPER_CANCELLED	CONSTANT	VARCHAR2(30)	:=	'SHIPPER_CANCELLED';
S_AUTO_ACCEPTED		CONSTANT	VARCHAR2(30)	:=	'AUTO_ACCEPTED';
S_NORESPONSE	CONSTANT	VARCHAR2(30)		:=	'NORESPONSE';
S_RETENDERED	CONSTANT	VARCHAR2(30)	:=	'RETENDERED';
S_SHIPPER_UPDATED	CONSTANT	VARCHAR2(30)	:=	'SHIPPER_UPDATED';

S_SOURCE_XML	CONSTANT	VARCHAR2(10)	:=	'XML';
S_SOURCE_CP	CONSTANT	VARCHAR2(10)	:=	'CP';
S_SOURCE_WL	CONSTANT	VARCHAR2(10)	:=	'WL';


PROCEDURE RAISE_TENDER_EVENT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_item_key		  IN	 VARCHAR2,
	        	p_shipper_wait_time	  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_autoaccept		  IN	 VARCHAR2,
	        	p_action		  IN 	 VARCHAR2,
	        	p_url			  IN	 VARCHAR2);


FUNCTION CAN_PERFORM_THIS_ACTION (
				p_trip_seg_status	VARCHAR2,
				p_tender_action		VARCHAR2)
				RETURN BOOLEAN;

FUNCTION CAN_PERFORM_THIS_ACTION_STR (
				p_trip_seg_status	VARCHAR2,
				p_tender_action		VARCHAR2)
				RETURN VARCHAR2;

PROCEDURE VALIDATE_TENDER_REQUEST(
		p_api_version_number	IN	NUMBER,
		p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
		x_return_status		OUT NOCOPY 	VARCHAR2,
		x_msg_count		OUT NOCOPY 	NUMBER,
		x_msg_data		OUT NOCOPY 	VARCHAR2,
            	p_trip_id               IN	NUMBER,
            	p_action_code           IN	VARCHAR2,
            	p_tender_action		IN	VARCHAR2,
            	p_trip_name             IN	VARCHAR2	DEFAULT	NULL);


FUNCTION IS_AUTO_ACCEPT_ENABLED  (p_carrier_id	VARCHAR2) RETURN BOOLEAN;


FUNCTION GET_ITEM_KEY(p_trip_seg_id	NUMBER) RETURN VARCHAR2;

PROCEDURE DELETE_TENDER_SNAPSHOT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2);

PROCEDURE TAKE_TENDER_SNAPSHOT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
			p_trip_id		  IN	 NUMBER,
			p_stop_id		  IN	 NUMBER,
			p_total_weight		  IN	 NUMBER,
			p_total_volume		  IN	 NUMBER,
			p_weight_uom		  IN	 VARCHAR2,
			p_volume_uom		  IN	 VARCHAR2,
			p_session_value		  IN	 VARCHAR2,
			p_action		  IN	 VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2);


PROCEDURE CHECK_THRESHOLD_FOR_STOP(
	          P_api_version		    IN	   NUMBER,
	          P_init_msg_list	    IN	   VARCHAR2 DEFAULT FND_API.G_FALSE,
	          X_return_status	    OUT NOCOPY 	   VARCHAR2,
	          X_msg_count		    OUT NOCOPY 	   NUMBER,
	          X_msg_data		    OUT NOCOPY 	   VARCHAR2,
	          P_trip_segment_rec        IN	   WSH_TRIPS_PVT.Trip_Rec_Type,
	          P_new_segment_stop_rec    IN	   WSH_TRIP_STOPS_PVT.trip_stop_rec_type);

PROCEDURE RAISE_TENDER_ACCEPT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2);

PROCEDURE RAISE_TENDER_REJECT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_shipper_name		  IN	 VARCHAR2,
	        	p_carrier_name		  IN 	 VARCHAR2,
	        	p_contact_name		  IN	 VARCHAR2,
	        	p_contact_perf		  IN	 VARCHAR2);

PROCEDURE RAISE_TENDER_UPDATE(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_item_key		  IN     VARCHAR2,
	        	p_tender_id		  IN	 NUMBER,
	        	p_contact_perf		  IN	 VARCHAR2);


--Added for Rel 12 Shravisa
PROCEDURE CHECK_CARRIER_ARRIVAL_TIME(
			p_tender_id   IN	NUMBER,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2
			) ;
--Added for Rel 12 Shravisa
PROCEDURE LOG_CARRIER_ARR_EXC(
			p_tender_id			 IN	NUMBER,
			p_planned_arrival_date		 IN DATE,
			p_carrier_est_arrival_date	 IN DATE,
		        p_first_stop_location_id	 IN NUMBER,
			P_planned_departure_date	 in date,
			P_carrier_est_departure_date	 in  date,
			P_last_stop_location_id		 in Number,
	        	x_return_status			 OUT NOCOPY     VARCHAR2,
	        	x_msg_count			 OUT NOCOPY     NUMBER,
	        	x_msg_data			 OUT NOCOPY     VARCHAR2
			);

PROCEDURE COMPLETE_CANCEL_TENDER (
			p_tender_id   IN	NUMBER,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2) ;

--End of Rel 12 Shravisa

---For Rel 12 HBHAGAVA
PROCEDURE RAISE_TENDER_EVENT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC,
	        	p_mbol_number		  IN	 VARCHAR2);


PROCEDURE UPDATE_CARRIER_RESPONSE(
		p_init_msg_list  	  IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_carrier_response_rec	  IN	      FTE_TENDER_ATTR_REC,
	        x_return_status           OUT NOCOPY  VARCHAR2,
		x_msg_count               OUT NOCOPY  NUMBER,
		x_msg_data                OUT NOCOPY  VARCHAR2);



PROCEDURE HANDLE_TENDER_RESPONSE(
			p_init_msg_list           IN     VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC);

PROCEDURE HANDLE_CANCEL_TENDER(
			p_init_msg_list           IN     VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC);



PROCEDURE RELEASE_TENDER_BLOCK(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 FTE_TENDER_ATTR_REC);

PROCEDURE HANDLE_UPDATE_TENDER(
	        	p_init_msg_list           IN     	 VARCHAR2,
	        	x_return_status           OUT NOCOPY     VARCHAR2,
	        	x_msg_count               OUT NOCOPY     NUMBER,
	        	x_msg_data                OUT NOCOPY     VARCHAR2,
	        	p_trip_info		  IN	 	 FTE_TENDER_ATTR_REC);


PROCEDURE TAKE_TENDER_SNAPSHOT(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_trip_id		  IN	 NUMBER,
			p_action		  IN	 VARCHAR2,
	        	x_return_status           OUT   NOCOPY VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2);
--- For rel 12 hbhagava


END FTE_TENDER_PVT;

 

/
