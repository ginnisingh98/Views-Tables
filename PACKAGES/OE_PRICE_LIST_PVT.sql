--------------------------------------------------------
--  DDL for Package OE_PRICE_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICE_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVLSTS.pls 115.1 99/07/16 08:17:05 porting shi $ */

-- Start of Comments
-- API name	: Fetch_List_Price
-- Type		: PRIVATE
-- Function	: Return the list price of an item based on a specified
--                price list, item, and unit code.
-- Pre-reqs	: None
-- Parameters	:
-- IN		: p_api_version_number	IN NUMBER	required
--  		  p_init_msg_list	IN VARCHAR2	optional
-- 			default = FND_API.G_FALSE
--		  p_validation_level	IN NUMBER	optional
--			default = FND_API.G_VALID_LEVEL_FULL
--		  p_price_list_id	IN NUMBER	required
--  		  p_inventory_item_id	IN NUMBER	required
--		  p_unit_code		IN VARCHAR2	required
--		  p_service_duration	IN NUMBER	optional
--		  p_item_type_code	IN VARCHAR2	optional
-- 		  p_prc_method_code	IN VARCHAR2	optional
--                p_pricing_attribute1	IN VARCHAR2 	optional
--                p_pricing_attribute2	IN VARCHAR2 	optional
--                p_pricing_attribute3	IN VARCHAR2 	optional
--                p_pricing_attribute4	IN VARCHAR2 	optional
--                p_pricing_attribute5	IN VARCHAR2 	optional
--                p_pricing_attribute6	IN VARCHAR2 	optional
--                p_pricing_attribute7	IN VARCHAR2 	optional
--                p_pricing_attribute8	IN VARCHAR2 	optional
--                p_pricing_attribute9	IN VARCHAR2 	optional
--                p_pricing_attribute10	IN VARCHAR2 	optional
--                p_pricing_attribute11	IN VARCHAR2 	optional
--                p_pricing_attribute12	IN VARCHAR2 	optional
--                p_pricing_attribute13	IN VARCHAR2 	optional
--                p_pricing_attribute14	IN VARCHAR2 	optional
--                p_pricing_attribute15	IN VARCHAR2 	optional
--		  p_base_price		IN NUMBER	optional
--		  p_fetch_attempts	IN NUMBER	optional
-- 			default = G_PRC_LST_DEF_ATTEMPTS
-- OUT		: p_return_status   	OUT VARCHAR2(1)
--		  p_msg_count		OUT NUMBER
--		  p_msg_data		OUT VARCHAR2(2000)
--		  p_price_list_id_out	OUT NUMBER
-- 		  p_prc_method_code_out	OUT VARCHAR2(4)
--		  p_list_price		OUT NUMBER
--		  p_list_percent	OUT NUMBER
--		  p_rounding_factor	OUT NUMBER
-- Version	: Current Version 1.0
--		  Initial Version 1.0
-- Notes	:
-- End Of Comments



--  Global constants holding the maximum number of fetch attempts allowed.

G_PRC_LST_MAX_ATTEMPTS    CONSTANT	NUMBER := 2 ;
G_PRC_LST_DEF_ATTEMPTS    CONSTANT	NUMBER := 2 ;

--  Global constants representing pricing method codes

G_PRC_METHOD_AMOUNT	CONSTANT    VARCHAR2(10) := 'AMNT';
G_PRC_METHOD_PERCENT	CONSTANT    VARCHAR2(10) := 'PERC';

--  Global constant Item type codes

G_PRC_ITEM_SERVICE	CONSTANT    VARCHAR2(10) := 'SERVICE';



PROCEDURE Fetch_List_Price
( p_api_version_number	IN  NUMBER	    	    	    	    	,
  p_init_msg_list	IN  VARCHAR2    := FND_API.G_FALSE		,
  p_validation_level	IN  NUMBER	:= FND_API.G_VALID_LEVEL_FULL	,
  p_return_status   	OUT VARCHAR2					,
  p_msg_count		OUT NUMBER					,
  p_msg_data		OUT VARCHAR2					,
  p_price_list_id	IN  NUMBER	:= NULL				,
  p_inventory_item_id	IN  NUMBER	:= NULL				,
  p_unit_code		IN  VARCHAR2	:= NULL				,
  p_service_duration	IN  NUMBER	:= NULL				,
  p_item_type_code	IN  VARCHAR2	:= NULL				,
  p_prc_method_code	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute1	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute2	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute3	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute4	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute5	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute6	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute7	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute8	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute9	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute10	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute11	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute12	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute13	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute14	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute15	IN  VARCHAR2	:= NULL				,
  p_base_price		IN  NUMBER	:= NULL				,
  p_fetch_attempts	IN  NUMBER	:= G_PRC_LST_DEF_ATTEMPTS	,
  p_price_list_id_out	    OUT	NUMBER					,
  p_prc_method_code_out	    OUT	VARCHAR2				,
  p_list_price		    OUT	NUMBER					,
  p_list_percent	    OUT	NUMBER					,
  p_rounding_factor	    OUT	NUMBER
);

END; -- OE_Price_List_PVT


 

/
