--------------------------------------------------------
--  DDL for Package Body CZ_OM_LIST_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_OM_LIST_PRICE" AS
/* $Header: czomlprb.pls 115.9 2002/12/03 15:22:35 askhacha ship $ */

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
  p_fetch_attempts	    IN  NUMBER	:= G_PRC_LST_DEF_ATTEMPTS) IS

  BEGIN
    p_return_status := G_RET_STS_ERROR;
    p_msg_data := 'Stubbed procedure';
  END fetch_list_price;

END CZ_OM_LIST_PRICE;

/
