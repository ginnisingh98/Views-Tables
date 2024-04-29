--------------------------------------------------------
--  DDL for Package Body ECE_INVENTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_INVENTORY" AS
-- $Header: ECEINVYB.pls 115.1 99/08/23 15:39:50 porting ship $


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
	o_attribute_15		OUT	VARCHAR2)
IS

	cItem_num		VARCHAR2(2000);

BEGIN

IF i_item_id IS NOT NULL THEN

	SELECT  MIN(ITEM_NUMBER) INTO cItem_num
	FROM 	MTL_ITEM_FLEXFIELDS MSIV
	WHERE   MSIV.ITEM_ID = i_item_id
	AND	MSIV.ORGANIZATION_ID = i_org_id;

    IF cItem_num IS NOT NULL THEN

	SELECT	MSIV.ATTRIBUTE_CATEGORY,
		MSIV.ATTRIBUTE1,
		MSIV.ATTRIBUTE2,
		MSIV.ATTRIBUTE3,
		MSIV.ATTRIBUTE4,
		MSIV.ATTRIBUTE5,
		MSIV.ATTRIBUTE6,
		MSIV.ATTRIBUTE7,
		MSIV.ATTRIBUTE8,
		MSIV.ATTRIBUTE9,
		MSIV.ATTRIBUTE10,
		MSIV.ATTRIBUTE11,
		MSIV.ATTRIBUTE12,
		MSIV.ATTRIBUTE13,
		MSIV.ATTRIBUTE14,
		MSIV.ATTRIBUTE15
	INTO	o_attribute_category,
		o_attribute_1,
		o_attribute_2,
		o_attribute_3,
		o_attribute_4,
		o_attribute_5,
		o_attribute_6,
		o_attribute_7,
		o_attribute_8,
		o_attribute_9,
		o_attribute_10,
		o_attribute_11,
		o_attribute_12,
		o_attribute_13,
		o_attribute_14,
		o_attribute_15
	FROM 	MTL_ITEM_FLEXFIELDS MSIV
	WHERE   MSIV.ITEM_ID = i_item_id
	AND	MSIV.ORGANIZATION_ID = i_org_id
	AND	MSIV.ITEM_NUMBER = cItem_num
	AND	ROWNUM = 1;

	o_item_number := cItem_num;

    END IF;
END IF;


EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000,sqlerrm||'. '||
    'ERROR: ECE_INVENTORY.GET_ITEM_NUMBER '||
    'ITEM_ID  = '|| NVL(get_item_number.i_item_id,0)||
    ' ORG_ID = ' || get_item_number.i_org_id ||
    ' ITEM_NUMBER = ' || get_item_number.cItem_num);

END GET_ITEM_NUMBER;


PROCEDURE GET_ITEM_LOCATION (
	i_inventory_location_id	IN 	NUMBER,
	i_organization_id	IN	NUMBER,
	o_location 		OUT 	VARCHAR2)
IS

BEGIN

SELECT  SUBSTRB(MIN(CONCATENATED_SEGMENTS),1,100) INTO o_location
FROM 	MTL_ITEM_LOCATIONS_KFV MILK
WHERE   MILK.INVENTORY_LOCATION_ID = i_inventory_location_id
AND	MILK.ORGANIZATION_ID = i_organization_id;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000,sqlerrm||'. '||
    'ERROR: ECE_INVENTORY.GET_ITEM_LOCATION '||
    'LOCATE_ID  = '|| NVL(get_item_location.i_inventory_location_id,0)||
    ' ORG_ID = ' || get_item_location.i_organization_id);

END GET_ITEM_LOCATION;

END ECE_INVENTORY;

/
