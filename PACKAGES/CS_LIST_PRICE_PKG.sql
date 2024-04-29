--------------------------------------------------------
--  DDL for Package CS_LIST_PRICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_LIST_PRICE_PKG" AUTHID CURRENT_USER as
/* $Header: csxlists.pls 115.0 99/07/16 09:08:29 porting ship $ */

	PROCEDURE  call_fetch_list_price (
	p_inventory_item_id		IN 	NUMBER,
 	p_price_list_id		IN 	NUMBER,
 	p_unit_code			IN 	VARCHAR2,
 	p_service_duration		IN 	NUMBER,
 	p_item_Type_code		IN 	VARCHAR2 ,
 	p_pricing_attribute1	IN 	VARCHAR2 ,
 	p_pricing_attribute2	IN 	VARCHAR2 ,
 	p_pricing_attribute3	IN 	VARCHAR2 ,
 	p_pricing_attribute4	IN 	VARCHAR2 ,
 	p_pricing_attribute5	IN 	VARCHAR2 ,
 	p_pricing_attribute6	IN 	VARCHAR2 ,
 	p_pricing_attribute7	IN 	VARCHAR2 ,
 	p_pricing_attribute8	IN 	VARCHAR2 ,
 	p_pricing_attribute9	IN 	VARCHAR2 ,
 	p_pricing_attribute10	IN 	VARCHAR2 ,
 	p_pricing_attribute11	IN 	VARCHAR2 ,
 	p_pricing_attribute12	IN 	VARCHAR2 ,
 	p_pricing_attribute13	IN 	VARCHAR2 ,
 	p_pricing_attribute14	IN 	VARCHAR2 ,
 	p_pricing_attribute15	IN 	VARCHAR2 ,
	p_base_price			IN 	NUMBER ,
	p_price_list_id_out		OUT 	NUMBER ,
	p_prc_method_code_out	OUT 	VARCHAR2 ,
	p_list_price			OUT 	NUMBER ,
	p_list_percent			OUT 	NUMBER ,
	p_rounding_factor		OUT 	NUMBER ,
	p_error_flag			OUT VARCHAR2,
	p_error_message		OUT VARCHAR2);

END cs_list_price_pkg;

 

/
