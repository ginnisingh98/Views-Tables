--------------------------------------------------------
--  DDL for Package Body POS_VALIDATE_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VALIDATE_ASN" AS
/* $Header: POSASNVB.pls 115.3 2002/11/26 02:13:36 mji ship $*/

PROCEDURE shipment_num(
		P_SHIPMENT_NUM	        IN VARCHAR2,
                P_VENDOR_ID IN NUMBER,
                P_VENDOR_SITE_ID IN NUMBER,
                P_COUNT       OUT NOCOPY     NUMBER) is

	v_temp NUMBER;
BEGIN

	select count(*)
	into v_temp
	from rcv_headers_interface
	where shipment_num = P_SHIPMENT_NUM
        and vendor_id = P_VENDOR_ID
        and nvl(vendor_site_id, -99) = nvl(P_VENDOR_SITE_ID, -99);
        /* and shipped_date >= add_months(sysdate,-12) */

	select count(*)
	into p_count
	from rcv_shipment_headers
	where shipment_num = P_SHIPMENT_NUM
        and vendor_id = P_VENDOR_ID
        and nvl(vendor_site_id, -99) = nvl(P_VENDOR_SITE_ID, -99);
        /* and shipped_date >= add_months(sysdate,-12) */

	p_count := p_count + v_temp;


END shipment_num;




PROCEDURE freight_terms	 (P_DESCRIPTION IN VARCHAR2,
			  P_LOOKUP_CODE IN OUT NOCOPY  VARCHAR2,
			  P_COUNT	IN OUT NOCOPY 	NUMBER) IS

BEGIN

	select count(*)
	into P_COUNT
	from po_lookup_codes
	where lookup_type = 'FREIGHT TERMS'
	and description = P_DESCRIPTION
	and sysdate < nvl(inactive_date, sysdate + 1);

	if (P_COUNT = 1) then
	select lookup_code
	into P_LOOKUP_CODE
	from po_lookup_codes
	where lookup_type = 'FREIGHT TERMS'
	and description = P_DESCRIPTION
	and sysdate < nvl(inactive_date, sysdate + 1);
	end if;

END freight_terms;


PROCEDURE freight_carrier (P_DESCRIPTION IN VARCHAR2,
			   P_ORGANIZATION_ID IN NUMBER,
			   P_FREIGHT_CARRIER_CODE IN OUT NOCOPY VARCHAR2,
			   P_COUNT IN OUT NOCOPY NUMBER) IS

BEGIN

	SELECT count(*)
	INTO P_COUNT
	FROM org_freight ofg
	WHERE ofg.description = P_DESCRIPTION and
      	-- ofg.organization_id = P_ORGANIZATION_ID and
	nvl(ofg.disable_date, sysdate) <= sysdate;

	IF (P_COUNT = 1) THEN
	SELECT FREIGHT_CODE
	INTO P_FREIGHT_CARRIER_CODE
	FROM org_freight ofg
	WHERE ofg.description = P_DESCRIPTION and
      	-- ofg.organization_id = P_ORGANIZATION_ID and
	nvl(ofg.disable_date, sysdate) <= sysdate;
	END IF;


END freight_carrier;


PROCEDURE payment_terms (P_NAME IN VARCHAR2,
			P_TERM_ID IN OUT NOCOPY NUMBER,
			   P_COUNT IN OUT NOCOPY NUMBER) IS

BEGIN
	SELECT COUNT(*)
	INTO P_COUNT
	FROM ap_terms_val_v
	WHERE NAME = P_NAME;


	IF (P_COUNT = 1) THEN
		SELECT TERM_ID
		INTO P_TERM_ID
		FROM ap_terms_val_v
		WHERE NAME = P_NAME;
	END IF;
END payment_terms;


PROCEDURE country_of_origin(P_TERRITORY_SHORT_NAME IN VARCHAR,
			    P_TERRITORY_CODE IN OUT NOCOPY VARCHAR,
			    P_COUNT IN OUT NOCOPY NUMBER) IS

BEGIN

	SELECT COUNT(*)
	INTO P_COUNT
	FROM fnd_territories_vl
	WHERE territory_short_name = P_TERRITORY_SHORT_NAME;

	IF (P_COUNT = 1) THEN
		SELECT territory_code
		INTO P_TERRITORY_CODE
		FROM fnd_territories_vl
		WHERE territory_short_name = P_TERRITORY_SHORT_NAME;
	END IF;

END country_of_origin;


END POS_VALIDATE_ASN;


/
