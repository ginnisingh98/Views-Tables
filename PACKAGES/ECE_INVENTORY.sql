--------------------------------------------------------
--  DDL for Package ECE_INVENTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_INVENTORY" AUTHID CURRENT_USER AS
-- $Header: ECEINVYS.pls 115.0 99/07/17 05:19:16 porting ship $

PROCEDURE GET_ITEM_NUMBER (
	i_item_id 		IN 	NUMBER,
	i_org_id		IN	NUMBER,
	o_item_number 		OUT 	VARCHAR2,
	o_attribute_category 	OUT 	VARCHAR2,
	o_attribute_1		OUT	VARCHAR2,
	o_attribute_2		OUT	VARCHAR2,
	o_attribute_3		OUT	VARCHAR2,
	o_attribute_4		OUT	VARCHAR2,
	o_attribute_5		OUT	VARCHAR2,
	o_attribute_6		OUT	VARCHAR2,
	o_attribute_7		OUT	VARCHAR2,
	o_attribute_8		OUT	VARCHAR2,
	o_attribute_9		OUT	VARCHAR2,
	o_attribute_10		OUT	VARCHAR2,
	o_attribute_11		OUT	VARCHAR2,
	o_attribute_12		OUT	VARCHAR2,
	o_attribute_13		OUT	VARCHAR2,
	o_attribute_14		OUT	VARCHAR2,
	o_attribute_15		OUT	VARCHAR2);

PROCEDURE GET_ITEM_LOCATION (
	i_inventory_location_id	IN 	NUMBER,
	i_organization_id	IN	NUMBER,
	o_location 		OUT 	VARCHAR2);

END ECE_INVENTORY;

 

/
