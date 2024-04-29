--------------------------------------------------------
--  DDL for Package Body MRP_SCATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCATP_PVT" AS
    /* $Header: MRPVATPB.pls 115.0 99/07/16 12:41:22 porting ship $*/
FUNCTION    get_default_ship_method (p_from_location_id IN NUMBER, p_to_location_id IN NUMBER)
            return VARCHAR2
IS
l_ship_method     VARCHAR2(204);
BEGIN

        SELECT ship_method
        INTO   l_ship_method
        FROM   mtl_interorg_ship_methods
        WHERE  from_location_id = p_from_location_id
        AND    to_location_id = p_to_location_id
        AND    default_flag = 1
        AND    rownum = 1;

    return l_ship_method;
EXCEPTION WHEN NO_DATA_FOUND THEN
        return null;

END get_default_ship_method;

FUNCTION    get_default_intransit_time (p_from_location_id IN NUMBER, p_to_location_id  IN NUMBER)
            return NUMBER
IS
l_intransit_time        NUMBER;
BEGIN

    SELECT  intransit_time
    INTO    l_intransit_time
    FROM    mtl_interorg_ship_methods
    WHERE   from_location_id = p_from_location_id
    AND     to_location_id = p_to_location_id
    AND     default_flag = 1
    AND     rownum = 1;

    return l_intransit_time;
EXCEPTION WHEN NO_DATA_FOUND THEN
	return null;
END get_default_intransit_time;

FUNCTION get_ship_method (p_from_org_id IN NUMBER, p_to_org_id IN NUMBER,
						  p_source_ship_method IN VARCHAR2,
						  p_receipt_org_id IN NUMBER)
					     return VARCHAR2 IS

l_ship_method VARCHAR2(30);

BEGIN


	IF (p_receipt_org_id is NOT NULL and
			p_source_ship_method is NOT NULL) THEN

		 return p_source_ship_method;

    END IF;

	select  ship_method
	into 	l_ship_method
	from    mtl_interorg_ship_methods
	where   from_organization_id = p_from_org_id
	and     to_organization_id = p_to_org_id
	and     default_flag = 1
	and		rownum = 1;

	return l_ship_method;

	EXCEPTION WHEN NO_DATA_FOUND THEN
		return null;

END get_ship_method;


FUNCTION get_intransit_time (p_from_org_id IN NUMBER, p_to_org_id IN NUMBER,
						     p_source_ship_method IN VARCHAR2,
							 p_receipt_org_id IN NUMBER)
							 return NUMBER IS
l_intransit_time NUMBER;
BEGIN


	IF (p_receipt_org_id is NOT NULL and
				p_source_ship_method is NOT NULL) THEN

		BEGIN
			select  intransit_time
			into	l_intransit_time
			from    mtl_interorg_ship_methods
			where   from_organization_id = p_from_org_id
			and		to_organization_id = p_to_org_id
			and     ship_method = p_source_ship_method
			and		rownum = 1;

			return l_intransit_time;

			EXCEPTION WHEN NO_DATA_FOUND THEN
				return null;

		END;

	END IF;


	BEGIN
				select  intransit_time
				into    l_intransit_time
				from    mtl_interorg_ship_methods
				where   from_organization_id = p_from_org_id
				and     to_organization_id = p_to_org_id
				and     default_flag = 1
				and     rownum = 1;

				return l_intransit_time;

				EXCEPTION WHEN NO_DATA_FOUND THEN
					return null;

    END;
END;
END MRP_SCATP_PVT;

/
