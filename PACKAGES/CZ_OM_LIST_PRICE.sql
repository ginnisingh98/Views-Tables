--------------------------------------------------------
--  DDL for Package CZ_OM_LIST_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_OM_LIST_PRICE" AUTHID CURRENT_USER AS
/* $Header: czomlprs.pls 115.9 2002/12/03 15:23:23 askhacha ship $ */

-- Start of Comments
-- API name	: Fetch_List_Price
-- Type		: PRIVATE
-- Function	: Return the list price of an item based on a specified
--            price list, item, and unit code.
-- Pre-reqs	: None
-- Parameters	:
-- IN		:     p_price_list_id	IN NUMBER	required
--  		      p_inventory_item_id	IN NUMBER	required
--		          p_unit_code		IN VARCHAR2	required
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
--		          p_fetch_attempts	IN NUMBER	optional
-- 			        default = G_PRC_LST_DEF_ATTEMPTS
--   OUT NOCOPY 	: p_return_status   	OUT VARCHAR2(1)
--		      p_msg_data		OUT VARCHAR2(2000)
--		      p_list_price		OUT NUMBER
--		      p_rounding_factor	OUT NUMBER
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

--  Global constants holding return status values.

G_RET_STS_SUCCESS CONSTANT CHAR := 'S';
G_RET_STS_ERROR CONSTANT CHAR := 'E';
G_RET_STS_UNEXP_ERROR CONSTANT CHAR := 'U';

--  Global constant Item type codes

G_PRC_ITEM_SERVICE	CONSTANT    VARCHAR2(10) := 'SERVICE';



PROCEDURE Fetch_List_Price
( p_return_status   	OUT  NOCOPY VARCHAR2					,
  p_msg_data		    OUT NOCOPY VARCHAR2					,
  p_list_price		      OUT NOCOPY NUMBER					,
  p_list_percent	      OUT NOCOPY NUMBER					,
  p_rounding_factor	      OUT NOCOPY NUMBER					,
  p_price_list_id	    IN  NUMBER	:= NULL				,
  p_inventory_item_id	IN  NUMBER	:= NULL				,
  p_unit_code		    IN  VARCHAR2	:= NULL				,
  p_service_duration	IN  NUMBER	:= NULL                         ,
  p_item_type_code	IN  VARCHAR2	:= NULL				,
  p_prc_method_code	IN  VARCHAR2	:= NULL			,
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
  p_pricing_date	IN  DATE	:= NULL				,
  p_prc_method_code_out	      OUT NOCOPY VARCHAR2			        ,
  p_fetch_attempts	    IN  NUMBER	:= G_PRC_LST_DEF_ATTEMPTS
);

END CZ_OM_LIST_PRICE;

 

/
