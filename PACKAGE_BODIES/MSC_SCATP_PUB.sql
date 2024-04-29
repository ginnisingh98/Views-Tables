--------------------------------------------------------
--  DDL for Package Body MSC_SCATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCATP_PUB" AS
    /* $Header: MSCVATPB.pls 115.8 2003/06/26 07:52:24 rajjain ship $*/

-- savirine added parameters p_session_id and p_partner_site_id on Sep 10, 2001.

FUNCTION    get_default_ship_method (p_from_location_id IN NUMBER,
                                     p_from_instance_id IN NUMBER,
                                     p_to_location_id IN NUMBER,
                                     p_to_instance_id IN NUMBER,
                                     p_session_id IN NUMBER,
                                     p_partner_site_id IN NUMBER)
return VARCHAR2 IS

l_ship_method     VARCHAR2(204);
l_level           NUMBER;
CURSOR c_ship_method
IS
SELECT ship_method,
       ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM   msc_interorg_ship_methods mism,
       msc_regions_temp mrt
WHERE  plan_id = -1
AND    from_location_id = p_from_location_id
AND    sr_instance_id = p_from_instance_id
AND    mism.to_region_id = mrt.region_id
AND    mrt.session_id = p_session_id
AND    mrt.partner_site_id = p_partner_site_id
AND    sr_instance_id2 = p_to_instance_id
AND    default_flag = 1
ORDER BY 2;

BEGIN

    BEGIN
       -- bug 2958287
        SELECT ship_method
        INTO   l_ship_method
        FROM   msc_interorg_ship_methods
        WHERE  plan_id = -1
        AND    from_location_id = p_from_location_id
        AND    sr_instance_id = p_from_instance_id
        AND    to_location_id = p_to_location_id
        AND    sr_instance_id2 = p_to_instance_id
        and    to_region_id is null
        AND    default_flag = 1
        AND    rownum = 1;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- savirine added the following select statement on Aug 29, 2001
        --- BUG 21130222: chnage sql into cursor to select right ship method
        --- THE sql below selects the wrong ship method
        /*SELECT ship_method
        INTO   l_ship_method
        FROM   msc_interorg_ship_methods mism,
               msc_regions_temp mrt
        WHERE  plan_id = -1
        AND    from_location_id = p_from_location_id
        AND    sr_instance_id = p_from_instance_id
        AND    mism.to_region_id = mrt.region_id
        AND    mrt.session_id = p_session_id
        AND    mrt.partner_site_id = p_partner_site_id
        AND    sr_instance_id2 = p_to_instance_id
        AND    default_flag = 1
        AND    rownum = 1; */
        OPEN c_ship_method;
        FETCH c_ship_method INTO l_ship_method, l_level;
        CLOSE c_ship_method;
        --msc_sch_wb.atp_debug('l_ship_method := ' || l_ship_method);
        --msc_sch_wb.atp_debug('l_level := ' || l_level);

   END;

   return l_ship_method;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return null;
END get_default_ship_method;

FUNCTION  get_default_intransit_time (p_from_location_id IN NUMBER,
                                      p_from_instance_id IN NUMBER,
                                      p_to_location_id  IN NUMBER,
                                      p_to_instance_id IN NUMBER,
                                      p_session_id IN NUMBER,
                                      p_partner_site_id IN NUMBER)
            				return NUMBER IS
l_intransit_time        NUMBER;
l_level                 NUMBER;
CURSOR c_lead_time is
SELECT  intransit_time,
        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    msc_interorg_ship_methods,
        msc_regions_temp mrt
WHERE   plan_id = -1
AND     from_location_id = p_from_location_id
AND     sr_instance_id = p_from_instance_id
AND     to_region_id =  mrt.region_id
AND mrt.session_id = p_session_id
AND mrt.partner_site_id = p_partner_site_id
AND sr_instance_id2 = p_to_instance_id
AND     default_flag = 1
ORDER BY 2;

BEGIN

    BEGIN
       -- bug 2958287
        SELECT  intransit_time
        INTO    l_intransit_time
        FROM    msc_interorg_ship_methods
        WHERE   plan_id = -1
        AND     from_location_id = p_from_location_id
        AND     sr_instance_id = p_from_instance_id
        AND     to_location_id = p_to_location_id
        AND     sr_instance_id2 = p_to_instance_id
        AND     to_region_id is null
        AND     default_flag = 1
        AND     rownum = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           --- BUG 2113022. The SQL below selects wrond lead time
           -- changed to cursor

           /*
            SELECT  intransit_time
            INTO    l_intransit_time
            FROM    msc_interorg_ship_methods,
	    	    msc_regions_temp mrt
            WHERE   plan_id = -1
            AND     from_location_id = p_from_location_id
            AND     sr_instance_id = p_from_instance_id
            AND     to_region_id =  mrt.region_id
            AND	mrt.session_id = p_session_id
            AND	mrt.partner_site_id = p_partner_site_id
            AND	sr_instance_id2 = p_to_instance_id
            AND     default_flag = 1
            AND     rownum = 1; */
            OPEN c_lead_time;
            FETCH c_lead_time INTO l_intransit_time, l_level;
            CLOSE c_lead_time;

    END;
    return l_intransit_time;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	return null;
END get_default_intransit_time;

FUNCTION get_ship_method (p_from_org_id IN NUMBER,
                          p_from_org_instance_id IN NUMBER,
                          p_to_org_id IN NUMBER,
                          p_to_org_instance_id IN NUMBER,
			  p_source_ship_method IN VARCHAR2,
			  p_receipt_org_id IN NUMBER )
		               	     return VARCHAR2 IS

l_ship_method VARCHAR2(30);

BEGIN


	IF (p_receipt_org_id is NOT NULL and
		p_source_ship_method is NOT NULL) THEN

		 return p_source_ship_method;

        END IF;

       -- bug 2958287
	select  ship_method
	into 	l_ship_method
	from    msc_interorg_ship_methods
	where   plan_id = -1
        and     from_organization_id = p_from_org_id
        and     sr_instance_id = p_from_org_instance_id
	and     to_organization_id = p_to_org_id
        and     sr_instance_id2 = p_to_org_instance_id
        and     to_region_id is null
	and     default_flag = 1
	and	rownum = 1;

	return l_ship_method;

   EXCEPTION WHEN NO_DATA_FOUND THEN
   return null;

END get_ship_method;

FUNCTION get_intransit_time (p_from_org_id IN NUMBER,
                             p_from_org_instance_id IN NUMBER,
                             p_to_org_id IN NUMBER,
                             p_to_org_instance_id IN NUMBER,
			     p_source_ship_method IN VARCHAR2,
			     p_receipt_org_id IN NUMBER)
						 return NUMBER IS
l_intransit_time NUMBER;

BEGIN

	IF (p_receipt_org_id is NOT NULL and
		p_source_ship_method is NOT NULL) THEN

		BEGIN
                        -- bug 2958287
			select  intransit_time
			into	l_intransit_time
			from    msc_interorg_ship_methods
			where   plan_id = -1
                        and     from_organization_id = p_from_org_id
                        and     sr_instance_id = p_from_org_instance_id
			and     to_organization_id = p_to_org_id
                        and     sr_instance_id2 = p_to_org_instance_id
			and     ship_method = p_source_ship_method
                        and     to_region_id is null
			and     rownum = 1;

			return l_intransit_time;

			EXCEPTION WHEN NO_DATA_FOUND THEN
				return null;

		END;

	END IF;


	BEGIN
               -- bug 2958287
		select  intransit_time
		into    l_intransit_time
		from    msc_interorg_ship_methods
		where   plan_id = -1
                and     from_organization_id = p_from_org_id
                and     sr_instance_id = p_from_org_instance_id
		and     to_organization_id = p_to_org_id
                and     sr_instance_id2 = p_to_org_instance_id
                and     to_region_id is null
		and     default_flag = 1
		and     rownum = 1;

		return l_intransit_time;

	   EXCEPTION
             WHEN NO_DATA_FOUND THEN
		return null;
        END;

END get_intransit_time;

FUNCTION get_weight_cost (p_from_org_id IN NUMBER,
                          p_from_org_instance_id IN NUMBER,
                          p_to_org_id IN NUMBER,
                          p_to_org_instance_id IN NUMBER,
		          p_source_ship_method IN VARCHAR2,
			  p_receipt_org_id IN NUMBER)
						 return NUMBER IS
l_weight_cost NUMBER;

BEGIN

	IF (p_receipt_org_id is NOT NULL and
		p_source_ship_method is NOT NULL) THEN

		BEGIN
                        -- bug 2958287
			select  cost_per_weight_unit
			into	l_weight_cost
			from    msc_interorg_ship_methods
			where   plan_id = -1
                        and     from_organization_id = p_from_org_id
                        and     sr_instance_id = p_from_org_instance_id
			and     to_organization_id = p_to_org_id
                        and     sr_instance_id2 = p_to_org_instance_id
			and     ship_method = p_source_ship_method
                        and     to_region_id is null
			and     rownum = 1;

			return l_weight_cost;

			EXCEPTION WHEN NO_DATA_FOUND THEN
				return null;
		END;

	END IF;

	BEGIN
                -- bug 2958287
		select  cost_per_weight_unit
		into    l_weight_cost
		from    msc_interorg_ship_methods
		where   plan_id = -1
                and     from_organization_id = p_from_org_id
                and     sr_instance_id = p_from_org_instance_id
		and     to_organization_id = p_to_org_id
                and     sr_instance_id2 = p_to_org_instance_id
		and     default_flag = 1
                and     to_region_id is null
		and     rownum = 1;

		return l_weight_cost;

	   EXCEPTION
             WHEN NO_DATA_FOUND THEN
		return null;
        END;

END get_weight_cost;

FUNCTION get_transport_cost (p_from_org_id IN NUMBER,
                          p_from_org_instance_id IN NUMBER,
                          p_to_org_id IN NUMBER,
                          p_to_org_instance_id IN NUMBER,
		          p_source_ship_method IN VARCHAR2,
			  p_receipt_org_id IN NUMBER)
						 return NUMBER IS
l_transport_cost NUMBER;

BEGIN
	IF (p_receipt_org_id is NOT NULL and
		p_source_ship_method is NOT NULL) THEN

		BEGIN
                        -- bug 2958287
			select  transport_cap_over_util_cost
			into	l_transport_cost
			from    msc_interorg_ship_methods
			where   plan_id = -1
                        and     from_organization_id = p_from_org_id
                        and     sr_instance_id = p_from_org_instance_id
			and     to_organization_id = p_to_org_id
                        and     sr_instance_id2 = p_to_org_instance_id
			and     ship_method = p_source_ship_method
                        and     to_region_id is null
			and     rownum = 1;

			return l_transport_cost;

			EXCEPTION WHEN NO_DATA_FOUND THEN
				return null;
		END;

	END IF;

	BEGIN
                -- bug 2958287
		select  transport_cap_over_util_cost
		into    l_transport_cost
		from    msc_interorg_ship_methods
		where   plan_id = -1
                and     from_organization_id = p_from_org_id
                and     sr_instance_id = p_from_org_instance_id
		and     to_organization_id = p_to_org_id
                and     sr_instance_id2 = p_to_org_instance_id
		and     default_flag = 1
                and     to_region_id is null
		and     rownum = 1;

		return l_transport_cost;

	   EXCEPTION
             WHEN NO_DATA_FOUND THEN
		return null;
        END;

END get_transport_cost;

END MSC_SCATP_PUB;

/
