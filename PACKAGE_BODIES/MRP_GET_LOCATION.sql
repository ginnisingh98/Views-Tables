--------------------------------------------------------
--  DDL for Package Body MRP_GET_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GET_LOCATION" AS
/* $Header: MRPGLOCB.pls 115.0 99/07/16 12:21:26 porting ship $ */

FUNCTION location (arg_location_id IN NUMBER, arg_org_id IN NUMBER) return varchar2 IS
	var_location_name	VARCHAR2(240);

	cursor C1 is
		select concatenated_segments
		from mtl_item_locations_kfv
		where inventory_location_id = arg_location_id
		and organization_id = arg_org_id;

BEGIN

	IF arg_location_id IS NULL THEN
		return NULL;
	END IF;

	OPEN C1;
	LOOP
		FETCH C1 INTO var_location_name;
		EXIT;
	END LOOP;

	return var_location_name;
END location;

END mrp_get_location;

/
