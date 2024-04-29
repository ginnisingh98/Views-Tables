--------------------------------------------------------
--  DDL for Package Body HZ_DNBUI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DNBUI_PVT" AS
/*$Header: ARHDNBUB.pls 120.11.12010000.2 2009/11/23 09:47:08 vsegu ship $*/

/*======================================================================
 | FUNCTION
 |              get_lookup_meaning
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_lookup_type
 |                      p_lookup_code
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |
 +======================================================================*/

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_meaning ar_lookups.meaning%TYPE;
BEGIN

  SELECT meaning
  INTO   l_meaning
  FROM   ar_lookups
  WHERE  lookup_type = p_lookup_type
    AND  lookup_code = p_lookup_code ;
  return(l_meaning);
EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;

/*======================================================================
 | FUNCTION
 |              get_financial_number
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_financial_name
 |                      p_financial_report_id
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |     17-OCT-00  Jianying Huang  Bug 1462704: Rename table HZ_FINANCIAL_NUMBERS to
 |                       HZ_FINANCIAL_NUMBERS_R1
 |     30-OCT-00  Jianying Huang  Roll back the renaming table changes.
 |
 +======================================================================*/

function get_financial_number(p_financial_name IN VARCHAR2, p_financial_report_id IN NUMBER) RETURN NUMBER
IS
v_financial_number NUMBER;

BEGIN

select financial_number into v_financial_number from hz_financial_numbers
where financial_report_id   = p_financial_report_id
and   financial_number_name = p_financial_name;

RETURN v_financial_number;
END get_financial_number;

/*======================================================================
 | FUNCTION
 |              get_financial_number_currency
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_financial_name
 |                      p_financial_report_id
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |     17-OCT-00  Jianying Huang  Bug 1462704: Rename table HZ_FINANCIAL_NUMBERS to
 |                       HZ_FINANCIAL_NUMBERS_R1
 |     30-OCT-00  Jianying Huang  Roll back the renaming table changes.
 |
 +======================================================================*/

function get_financial_number_currency(p_financial_name IN VARCHAR2, p_financial_report_id IN NUMBER) RETURN VARCHAR2
IS
v_financial_number_currency VARCHAR2(240);

BEGIN

select financial_number_currency into v_financial_number_currency from hz_financial_numbers
where financial_report_id   = p_financial_report_id
and   financial_number_name = p_financial_name;

RETURN v_financial_number_currency;

END get_financial_number_currency;

/*======================================================================
 | FUNCTION
 |              get_financial_number_actflg
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_financial_name
 |                      p_financial_report_id
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |     17-OCT-00  Jianying HUang  Bug 1462704: Rename table HZ_FINANCIAL_NUMBERS to
 |                       HZ_FINANCIAL_NUMBERS_R1
 |     30-OCT-00  Jianying Huang  Roll back the renaming table changes.
 |
 +======================================================================*/

function get_financial_number_actflg(p_financial_name IN VARCHAR2, p_financial_report_id IN NUMBER) RETURN VARCHAR2
IS
v_financial_number_actflg VARCHAR2(240);

BEGIN

select projected_actual_flag into v_financial_number_actflg from hz_financial_numbers
where financial_report_id   = p_financial_report_id
and   financial_number_name = p_financial_name;

RETURN v_financial_number_actflg;

END get_financial_number_actflg;

/*======================================================================
 | FUNCTION
 |              get_primary_phone_number
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_party_id
 |                      p_source_type
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |     17-OCT-00  Jianying Huang  Bug 1462704: Rename table HZ_CONTACT_POINTS to
 |                    HZ_CONTACT_POINTS_R1
 |     30-OCT-00  Jianying Huang  Roll back the renaming table changes.
 |
 +======================================================================*/

function get_primary_phone_number(
 	p_party_id 	IN 	NUMBER,
	p_source_type 	IN	VARCHAR2)
RETURN VARCHAR2 IS

l_phone_number HZ_CONTACT_POINTS.raw_phone_number%TYPE;
cursor primary_phone is
SELECT cp.raw_phone_number
  FROM HZ_CONTACT_POINTS cp
  WHERE cp.owner_table_id = p_party_id
  AND   cp.owner_table_name = 'HZ_PARTIES'
  AND   cp.actual_content_source = p_source_type
  AND   cp.CONTACT_POINT_TYPE = 'PHONE'
  AND   cp.status = 'A'
  AND   cp.primary_flag = 'Y'
  AND   cp.phone_line_type <> 'FAX';

cursor all_phones is
SELECT cp.raw_phone_number
  FROM HZ_CONTACT_POINTS cp
  WHERE cp.owner_table_id = p_party_id
  AND   cp.owner_table_name = 'HZ_PARTIES'
  AND   cp.actual_content_source = p_source_type
  AND   cp.CONTACT_POINT_TYPE = 'PHONE'
  AND   cp.status = 'A'
  AND   cp.phone_line_type <> 'FAX';
BEGIN

  open primary_phone;
  fetch primary_phone into l_phone_number;

  	if primary_phone%NOTFOUND then
        	open all_phones;
		fetch all_phones into l_phone_number;
                close all_phones;
        end if;

  close primary_phone;
  RETURN l_phone_number;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_primary_phone_number;

/*======================================================================
 | FUNCTION
 |              get_primary_fax_number
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_party_id
 |                      p_source_type
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |     17-OCT-00  Jianying Huang  Bug 1462704: Rename table HZ_CONTACT_POINTS to
 |                    HZ_CONTACT_POINTS_R1
 |     30-OCT-00  Jianying Huang  Roll back the renaming table changes.
 |
 +======================================================================*/

function get_primary_fax_number(
 	p_party_id 	IN 	NUMBER,
	p_source_type 	IN	VARCHAR2)
RETURN VARCHAR2 IS
l_fax_number HZ_CONTACT_POINTS.raw_phone_number%TYPE;
cursor primary_phone is
SELECT cp.raw_phone_number
  FROM HZ_CONTACT_POINTS cp
  WHERE cp.owner_table_id = p_party_id
  AND   cp.owner_table_name = 'HZ_PARTIES'
  AND   cp.actual_content_source = p_source_type
  AND   cp.CONTACT_POINT_TYPE = 'PHONE'
  AND   cp.status = 'A'
  AND   cp.primary_flag = 'Y'
  AND   cp.phone_line_type = 'FAX';

cursor all_phones is
SELECT cp.raw_phone_number
  FROM HZ_CONTACT_POINTS cp
  WHERE cp.owner_table_id = p_party_id
  AND   cp.owner_table_name = 'HZ_PARTIES'
  AND   cp.actual_content_source = p_source_type
  AND   cp.CONTACT_POINT_TYPE = 'PHONE'
  AND   cp.status = 'A'
  AND   cp.phone_line_type = 'FAX';
BEGIN

  open primary_phone;
  fetch primary_phone into l_fax_number;

  	if primary_phone%NOTFOUND then
        	open all_phones;
		fetch all_phones into l_fax_number;
                close all_phones;
        end if;

  close primary_phone;
  RETURN l_fax_number;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_primary_fax_number;

/*======================================================================
 | FUNCTION
 |              get_all_phone_numbers
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_party_id
 |                      p_source_type
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |     17-OCT-00  Jianying Huang  Bug 1462704: Rename table HZ_CONTACT_POINTS to
 |                    HZ_CONTACT_POINTS_R1
 |     30-OCT-00  Jianying Huang  Roll back the renaming table changes.
 |
 +======================================================================*/

function get_all_phone_numbers(
	p_party_id 	IN 	NUMBER,
	p_source_type 	IN	VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c_phone_number IS
  SELECT cp.raw_phone_number
  FROM	HZ_CONTACT_POINTS cp
  WHERE cp.owner_table_id = p_party_id
  AND   cp.owner_table_name = 'HZ_PARTIES'
  AND   cp.actual_content_source = p_source_type
  AND 	cp.status = 'A'
  AND   cp.CONTACT_POINT_TYPE = 'PHONE'
  AND   cp.phone_line_type='GEN';

l_phone_num VARCHAR2(200);
l_all_numbers	VARCHAR2(2000);
BEGIN

  OPEN c_phone_number;
  LOOP
    FETCH c_phone_number INTO l_phone_num;
    EXIT WHEN c_phone_number%NOTFOUND;

    IF l_all_numbers IS NOT NULL THEN
      l_all_numbers := l_all_numbers || '##';
    END IF;

    l_all_numbers := l_all_numbers || l_phone_num;
  END LOOP;
  CLOSE c_phone_number;

  RETURN l_all_numbers;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_all_phone_numbers;

/*======================================================================
 | FUNCTION
 |              get_country_name
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                      p_country_code
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 | 10-18-2000  Chirag Mehta  Changed select clause
 +======================================================================*/

function get_country_name(p_country_code IN VARCHAR2) RETURN VARCHAR2 IS

country_name                 fnd_territories_vl.TERRITORY_SHORT_NAME%TYPE;

BEGIN

select TERRITORY_SHORT_NAME into country_name from fnd_territories_vl
where TERRITORY_CODE=p_country_code;

return country_name;

EXCEPTION
 WHEN no_data_found  THEN
  return null;
 WHEN OTHERS THEN
  raise;
END get_country_name;


function get_max_financial_report_id(
        p_party_id      		IN      NUMBER,
        p_type_of_financial_report	IN      VARCHAR2,
	p_actual_content_source		IN	VARCHAR2)
RETURN NUMBER IS

	l_financial_report_id	NUMBER;
        l_date_report_issued    DATE;
        l_report_end_date       DATE;
-- Bug 3395969 : Added variable
	l_creation_date DATE;

BEGIN
/* Bug 3395969 : donot consider date_report_issued
 * and report_end_date, issued_period for finding
 * latest financial report
 *
        SELECT MAX(date_report_issued)
        INTO   l_date_report_issued
        FROM   hz_financial_reports
        WHERE  party_id = p_party_id
        AND    type_of_financial_report = p_type_of_financial_report
        AND    actual_content_source = p_actual_content_source;

        SELECT MAX(report_end_date)
        INTO   l_report_end_date
        FROM   hz_financial_reports
        WHERE  party_id = p_party_id
        AND    type_of_financial_report = p_type_of_financial_report
        AND    actual_content_source = p_actual_content_source;
*/
	SELECT MAX(creation_date)
	INTO   l_creation_date
        FROM   hz_financial_reports
        WHERE  party_id = p_party_id
        AND    type_of_financial_report = p_type_of_financial_report
        AND    actual_content_source = p_actual_content_source;

        SELECT financial_report_id
        INTO   l_financial_report_id
        FROM   hz_financial_reports
        WHERE  party_id = p_party_id
        AND    type_of_financial_report = p_type_of_financial_report
        AND    actual_content_source = p_actual_content_source
-- Bug 3395969 : Change the conditino to creation_date
	AND creation_date = l_creation_date
        AND rownum=1;

        RETURN l_financial_report_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
	RETURN to_number(NULL);
END;


function get_max_credit_rating_id(
        p_party_id      	IN      NUMBER,
        p_actual_content_source   IN      VARCHAR2)
RETURN NUMBER IS

	l_credit_rating_id	NUMBER;
        l_max_rated_as_of_date  DATE;

BEGIN

        SELECT MAX(rated_as_of_date)
        INTO   l_max_rated_as_of_date
        FROM   hz_credit_ratings
        WHERE  party_id = p_party_id
        AND    actual_content_source = p_actual_content_source;

        SELECT credit_rating_id
        INTO   l_credit_rating_id
        FROM   hz_credit_ratings
        WHERE  party_id = p_party_id
        AND    actual_content_source = p_actual_content_source
        AND    NVL(rated_as_of_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))=
               NVL(l_max_rated_as_of_date, TO_DATE('31-12-4712', 'DD-MM-YYYY'))
        AND    rownum = 1;

        RETURN l_credit_rating_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN to_number(NULL);
END;

/*
function get_currency_symbol(
	p_financial_name IN VARCHAR2,
	p_financial_report_id NUMBER)

RETURN VARCHAR2  IS
    l_financial_number_currency VARCHAR2(240);
	l_symbol	fnd_currencies.symbol%TYPE;

BEGIN

    l_financial_number_currency := get_financial_number_currency(p_financial_name, p_financial_report_id);
    select symbol  into l_symbol
    from fnd_currencies
    where currency_code = l_financial_number_currency
    AND    rownum = 1;

    RETURN l_symbol;

EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN to_char(NULL);
END;
*/

function get_financial_symbol_number(
    p_financial_name IN VARCHAR2,
    p_financial_report_id NUMBER)
RETURN VARCHAR2
IS
    l_financial_symbol_number varchar2(240);
BEGIN

    select
    DECODE( HZ_DNBUI_PVT.GET_FINANCIAL_NUMBER(p_financial_name, p_financial_report_id),
            null, null,
            nvl(HZ_DNBUI_PVT.get_financial_number_currency(p_financial_name, p_financial_report_id), 'USD') || ' ' ||
            HZ_DNBUI_PVT.GET_FINANCIAL_NUMBER(p_financial_name, p_financial_report_id))
    into l_financial_symbol_number
    from dual;

    RETURN l_financial_symbol_number;
EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN to_char(NULL);

END;


function get_SIC_code(
    p_class_category IN VARCHAR2,
    p_party_id       IN NUMBER,
    p_sequence       IN NUMBER,
    p_actual_content_source IN VARCHAR2
    )
RETURN VARCHAR2
IS

CURSOR c_SIC_CODE IS
    select CLASS_CODE
    from HZ_CODE_ASSIGNMENTS
    where OWNER_TABLE_NAME = 'HZ_PARTIES' AND
          OWNER_TABLE_ID = p_party_id AND
	  CLASS_CATEGORY = p_class_category AND
	  actual_content_source = p_actual_content_source AND   --Bug 9071339
	  (END_DATE_ACTIVE IS NULL OR
	   (END_DATE_ACTIVE IS not NULL and END_DATE_ACTIVE >= SYSDATE))
          order by code_assignment_id;


    l_SIC_code   VARCHAR2(30);
    l_count      NUMBER :=0;
BEGIN

  OPEN c_SIC_CODE;
  LOOP
    FETCH c_SIC_CODE INTO l_SIC_code;
    EXIT WHEN c_SIC_CODE%NOTFOUND;

    l_count := l_count + 1;
    IF l_count = p_sequence THEN
        EXIT;
    END IF;

  END LOOP;
  CLOSE c_SIC_CODE;

  IF l_count < p_sequence THEN
    l_SIC_code := NULL;
  END IF;

  RETURN l_SIC_code;

EXCEPTION WHEN OTHERS THEN
        RETURN NULL;

END;

/*======================================================================
 | FUNCTION
 |              get_location_id
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                   p_party_id,
 |                   p_actual_content_source
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 | 06-03-2002  Kashan
 +======================================================================*/

function get_location_id (
    p_party_id IN NUMBER,
    p_actual_content_source in VARCHAR2)
RETURN NUMBER
IS
    l_location_id NUMBER;
    l_displayed_duns_party_id NUMBER;
BEGIN

   IF p_actual_content_source = 'DNB' THEN
         BEGIN

         BEGIN
	   select displayed_duns_party_id into l_displayed_duns_party_id
           from hz_organization_profiles
           where party_id = p_party_id and
               effective_end_date is null
               and actual_content_source = 'DNB';
         EXCEPTION WHEN NO_DATA_FOUND THEN
           NULL;
         END;


         IF l_displayed_duns_party_id is null THEN
         BEGIN
           l_displayed_duns_party_id := p_party_id;
         end;
         END IF;

            select loc.location_id
            into l_location_id
            from HZ_LOCATIONS loc, HZ_PARTY_SITES ps
            where
	        ps.party_id = l_displayed_duns_party_id AND
                loc.location_id = ps.location_id AND
	        loc.actual_content_source = p_actual_content_source AND
                ps.actual_content_source = p_actual_content_source AND
                nvl(ps.end_date_active, sysdate+1) >= sysdate AND
                ps.status = 'A' AND
                rownum=1;

	return l_location_id;

	EXCEPTION WHEN NO_DATA_FOUND THEN
	    return null;
	END;

   ELSE  --   p_actual_content_source = 'USER_ENTERED'
     BEGIN
	select loc.location_id
	into l_location_id
	from HZ_LOCATIONS loc, HZ_PARTY_SITES ps
	where
	    ps.party_id = p_party_id AND
	    loc.location_id = ps.location_id AND
	    loc.actual_content_source = p_actual_content_source AND
	    ps.identifying_address_flag = 'Y';

	return l_location_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN

	BEGIN
            select loc.location_id
            into l_location_id
            from HZ_LOCATIONS loc, HZ_PARTY_SITES ps
            where
                ps.party_id = p_party_id AND
                loc.location_id = ps.location_id AND
                loc.actual_content_source = p_actual_content_source AND
		nvl(ps.end_date_active, sysdate+1) >= sysdate AND
		ps.status = 'A' AND
                Loc.last_update_date =
                    (select max(l_temp.last_update_date)
	            from hz_locations l_temp, hz_party_sites ps_temp
                    where l_temp.location_id = ps_temp.location_id AND
                    ps_temp.party_id = p_party_id  AND
                    l_temp.actual_content_source = p_actual_content_source  AND
		    nvl(ps_temp.end_date_active, sysdate+1) >= sysdate AND
		    ps_temp.status = 'A' );

	    return l_location_id;

	EXCEPTION WHEN NO_DATA_FOUND THEN

-- Bug 3325884 : When there is no user entered location and party site, return
--		 location_id for the DNB record.

		BEGIN
                        BEGIN
                          select displayed_duns_party_id into l_displayed_duns_party_id
                          from hz_organization_profiles
                          where party_id = p_party_id and effective_end_date is null and actual_content_source = 'DNB';
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                          null;
        	        END;

		        IF l_displayed_duns_party_id is null THEN
           			l_displayed_duns_party_id := p_party_id;
         		END IF;

            		select loc.location_id
            		into l_location_id
            		from HZ_LOCATIONS loc, HZ_PARTY_SITES ps
            		where ps.party_id = l_displayed_duns_party_id AND
                	loc.location_id = ps.location_id AND
                	loc.actual_content_source = 'DNB' AND
        		nvl(ps.end_date_active, sysdate+1) >= sysdate AND
                	ps.status = 'A' and
                	rownum=1;

        		return l_location_id;

                EXCEPTION WHEN NO_DATA_FOUND THEN
                  return null;
        	END;
	END;
      END;
    END IF;
END;

/*======================================================================
 | FUNCTION
 |              get_first_available_report
 |
 | DESCRIPTION
 |
 | ARGUMENTS  : IN:
 |                   p_party_id,
 |                   p_actual_content_source
 |              OUT:
 |           IN/OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 | 10-13-2004  Kashan
 +======================================================================*/

function get_first_available_report(
        p_party_id      		IN      NUMBER,
        p_actual_content_source		IN	VARCHAR2)
RETURN VARCHAR2 IS
    l_displayed_duns_party_id NUMBER;
BEGIN

    IF p_actual_content_source = 'DNB' THEN

      BEGIN
        select displayed_duns_party_id into l_displayed_duns_party_id
        from hz_organization_profiles
        where party_id = p_party_id and
              effective_end_date is null and
              actual_content_source = 'DNB';
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;

    END IF;

    IF l_displayed_duns_party_id is null THEN
    BEGIN
      l_displayed_duns_party_id := p_party_id;
    end;
    END IF;

    IF get_max_financial_report_id(l_displayed_duns_party_id, 'BALANCE_SHEET', p_actual_content_source) is not null THEN
      return 'BALANCE_SHEET';
    END IF;

    IF get_max_financial_report_id(l_displayed_duns_party_id, 'INCOME_STATEMENT', p_actual_content_source) is not null THEN
      return 'INCOME_STATEMENT';
    END IF;

    IF get_max_financial_report_id(l_displayed_duns_party_id, 'TANGIBLE_NET_WORTH', p_actual_content_source) is not null THEN
      return 'TANGIBLE_NET_WORTH';
    END IF;

     IF get_max_financial_report_id(l_displayed_duns_party_id, 'ANNUAL_SALES_VOLUME', p_actual_content_source) is not null THEN
      return 'ANNUAL_SALES_VOLUME';
    END IF;

    RETURN null;

 END get_first_available_report;

END HZ_DNBUI_PVT;

/
