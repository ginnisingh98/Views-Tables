--------------------------------------------------------
--  DDL for Package FTE_FREIGHT_RATING_DLVY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_FREIGHT_RATING_DLVY_GRP" AUTHID CURRENT_USER AS
/* $Header: FTEFRDTS.pls 120.1 2005/06/30 12:39:27 susurend noship $ */

-- types for Rate_Delivery
TYPE rate_del_in_param_rec IS RECORD(
  delivery_id_list	WSH_UTIL_CORE.id_tab_type,
  action		VARCHAR2(30),
  seq_tender_flag VARCHAR2(1)
  );

TYPE rate_del_out_param_rec IS RECORD(
  failed_delivery_id_list	WSH_UTIL_CORE.id_tab_type);

--type for public rating API
TYPE delivery_in_rec_type IS RECORD (
	name				VARCHAR2(30),
	carrier_name			VARCHAR2(360),
	mode_of_transport		VARCHAR2(30),
	service_level			VARCHAR2(30)
	);





  -- this is the wrapper for STF get-freight-costs action
  PROCEDURE Rate_Delivery  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit                  	IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_in_param_rec		IN rate_del_in_param_rec,
			     x_out_param_rec		OUT NOCOPY  rate_del_out_param_rec,
                             x_return_status            OUT NOCOPY  VARCHAR2,
		       	     x_msg_count	        OUT NOCOPY  NUMBER,
			     x_msg_data	                OUT NOCOPY  VARCHAR2);

-- Procedure : Delivery_Rating
-- Parameters :
--               p_delivery_id
--               p_action (valid values : 'RATE')
-- 		 -- J+ enhancement
-- 		 p_carrier_id, p_mode_of_transport, p_service_level are added in J+
--		 if any of carrier, mode or service level is passed in
--		 Rate_delivery will use there instead of trip's shipmethod
--		 to search services
-- 		 -- end of J+ enhancement
-- Description : This is the main api for the wsh delivery rating (demo) flow
--               Will be invoked from wsh_fte_integration package for use with the shipping
--               transaction form and the delivery rating concurrent program.
--               Searches for lanes, creates trip and rates.
--

  PROCEDURE Rate_Delivery  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_delivery_id              IN  NUMBER DEFAULT NULL,
			     p_trip_id			IN  NUMBER DEFAULT NULL,
                             p_action                   IN  VARCHAR2 DEFAULT 'RATE',
                             p_commit                  	IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_init_prc_log		IN  VARCHAR2 DEFAULT 'Y',
			     p_carrier_id		IN NUMBER DEFAULT NULL,
			     p_mode_of_transport	IN VARCHAR2 DEFAULT NULL,
			     p_service_level		IN VARCHAR2 DEFAULT NULL,
			     p_seq_tender_flag 		IN VARCHAR2 DEFAULT 'N',
                             x_return_status            OUT NOCOPY  VARCHAR2,
		       	     x_msg_count	        OUT NOCOPY  NUMBER,
			     x_msg_data	                OUT NOCOPY  VARCHAR2);

-- This procedure is called by 10+ rating public API
--========================================================================
-- PARAMETERS:
--   p_api_version   	API version number
--   p_init_msg_list	FND_API.G_TRUE to reset the list,
--                    	or FND_API.G_FLASE not to reset the list
--   p_commit	 	FND_API.G_TRUE to commit the work,
--			or FND_API.G_FLASE not to commit the work
--   x_return_status	API return status,
--			FND_API.G_RET_STS_SUCCESS, if delivery is rated
--			successfully,
--			FND_API.G_RET_STS_ERROR, if delivery failed to rate
--			FND_API.G_RET_STS_UNEXP_ERROR, unexpected error
--   x_msg_count	number of messages on the list
--   x_msg_data		message text if x_msg_count = 1
--   p_action_code	'RATE'
--   p_delivery_in_rec	delivery input, delivery name is required;
--			carrier_name, mode_of_transport, service_level are optional
-- COMMENT   :  This procedure is used to rate an input delivery
--		If delivery is on multiple trips,
--		  API will error out;
--		If delivery is on a trip with multiple deliveries,
--		  API will error out;
-- 		If delivery has no trip and input ship method is null,
--		  API will do LCCS using delivery ship method;
-- 		If delivery has no trip and input ship method is not null,
--		  API will do LCCS using input ship method;
-- 		If delivery has one trip and input ship method is null,
-- 		  API will rate delivery on existing service.
-- 		If delivery has one trip and input ship method is not null,
--		  API will do LCCS using input ship method.
--
--		API will not update delivery with input ship method
--
-- 		If delivery is rated successfully, trip ship method will be
--		LCCS result ship method.
--========================================================================

PROCEDURE Rate_Delivery2 (
  p_api_version         IN		NUMBER DEFAULT 1.0,
  p_init_msg_list	IN		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit	    	IN  		VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status	OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  p_init_prc_log	IN  		VARCHAR2 DEFAULT 'Y',
  p_delivery_in_rec	IN		delivery_in_rec_type
);


  PROCEDURE Cancel_Service  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_delivery_id              IN  NUMBER,
                 p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                 p_commit                  	IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                 x_return_status            OUT NOCOPY  VARCHAR2,
                 x_msg_count	        OUT NOCOPY  NUMBER,
                 x_msg_data	                OUT NOCOPY  VARCHAR2);

  PROCEDURE Cancel_Service  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_delivery_list           	IN  WSH_UTIL_CORE.id_tab_type,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
		       	     x_msg_count	        OUT NOCOPY  NUMBER,
			     x_msg_data	                OUT NOCOPY  VARCHAR2);

    PROCEDURE api_post_call
		(
		  p_api_name           IN     VARCHAR2,
		  p_api_return_status  IN     VARCHAR2,
		  p_message_name       IN     VARCHAR2,
		  p_trip_id            IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_id        IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_leg_id    IN     VARCHAR2 DEFAULT NULL,
		  x_number_of_errors   IN OUT NOCOPY  NUMBER,
		  x_number_of_warnings IN OUT NOCOPY  NUMBER,
		  x_return_status      OUT NOCOPY     VARCHAR2
                 );

END FTE_FREIGHT_RATING_DLVY_GRP;

 

/
