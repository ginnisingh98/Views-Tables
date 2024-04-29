--------------------------------------------------------
--  DDL for Package FTE_DELIVERY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_DELIVERY_PUB" AUTHID CURRENT_USER AS
/* $Header: FTEPDELS.pls 120.0 2005/05/26 18:00:59 appldev noship $ */

--===================
-- PUBLIC TYPES
--===================

TYPE delivery_in_rec_type IS RECORD (
	name				VARCHAR2(30),
	carrier_name			VARCHAR2(360),
	mode_of_transport		VARCHAR2(30),
	service_level			VARCHAR2(30)
	);

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Rate_Delivery
-- API TYPE  : PUBLIC
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
-- VERSION   : current version         1.0
--             initial version         1.0
--
-- CREATED  BY : version 1.0                 XIZHANG
-- CREATION DT : version 1.0                 MAR/23/2004
--
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

PROCEDURE Rate_Delivery (
  p_api_version         IN		NUMBER,
  p_init_msg_list	IN		VARCHAR2,
  p_commit	    	IN  		VARCHAR2,
  x_return_status	OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  p_action_code		IN		VARCHAR2,
  p_delivery_in_rec	IN		delivery_in_rec_type
);

END FTE_DELIVERY_PUB;

 

/
