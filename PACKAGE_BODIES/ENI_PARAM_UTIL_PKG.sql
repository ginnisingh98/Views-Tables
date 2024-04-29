--------------------------------------------------------
--  DDL for Package Body ENI_PARAM_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_PARAM_UTIL_PKG" AS
/*$Header: ENIPUTPB.pls 120.1 2006/02/22 04:51:10 lparihar noship $*/
-- Retrieve the default parameter values
-- for the Product Performance - Development
-- parameter portlet
FUNCTION get_dbi_pme_params RETURN VARCHAR2 IS

CURSOR c_first_item IS
	SELECT
		id,
		value
	FROM
		eni_oltp_item_star
        WHERE rownum = 1;

r_first_item c_first_item%ROWTYPE;

BEGIN

   OPEN c_first_item;

   BEGIN
   	FETCH c_first_item into r_first_item;
   EXCEPTION
   	WHEN OTHERS THEN
		NULL;
   END;

   RETURN '&'||'ENI_ITEM_ORG='||r_first_item.id;

EXCEPTION
	WHEN OTHERS THEN
		NULL;

END get_dbi_pme_params;

--Returns a random ItemID for the org value stored in g_default_org. If this variable is NULL it picks
--up a random record.
FUNCTION get_dbi_pme_c_params RETURN VARCHAR2 IS
l_first_item varchar2(50);
BEGIN
   if eni_param_util_pkg.g_default_org <> null then
	select id into l_first_item from eni_oltp_item_star
	where organization_id = to_number(eni_param_util_pkg.g_default_org) and rownum = 1;
   else
	select id into l_first_item from eni_oltp_item_star
	where rownum = 1;
   end if;
   eni_param_util_pkg.g_default_org := null;
   RETURN l_first_item;
END get_dbi_pme_c_params;

FUNCTION get_dbi_pms_params RETURN VARCHAR2 IS
BEGIN
	RETURN '&'||'FND_CATEGORY=2067';

END get_dbi_pms_params;
FUNCTION is_valid_org(
	p_org_id IN NUMBER,
	p_resp_id IN NUMBER,
	p_as_of_date IN VARCHAR2) RETURN VARCHAR2
IS
CURSOR c_valid_org(resp_id NUMBER, as_of_date VARCHAR2)
IS
SELECT
	'Y'
FROM
/*Bug: 4960454*/
	fnd_user_resp_groups_all
WHERE
	responsibility_id = resp_id
	AND as_of_date BETWEEN start_date AND NVL(end_date, SYSDATE)
	AND user_id = FND_GLOBAL.USER_ID;

r_valid_org c_valid_org%ROWTYPE;
CURSOR c_inv_org(org_id NUMBER)
IS
SELECT
	'Y'
FROM
	mtl_parameters
WHERE
	organization_id = org_id;

r_inv_org c_inv_org%ROWTYPE;
BEGIN
	-- Is the organization an inventory org?
	OPEN c_inv_org(p_org_id);

	FETCH c_inv_org INTO r_inv_org;

	IF c_inv_org%NOTFOUND THEN
		RETURN 'N';
	END IF;

	CLOSE c_inv_org;

	-- Does the user have access to the inventory org?
	OPEN c_valid_org(p_resp_id, p_as_of_date);

	FETCH c_valid_org INTO r_valid_org;

	IF c_valid_org%NOTFOUND THEN
		RETURN 'N';
	END IF;

	CLOSE c_valid_org;



	RETURN 'Y';

EXCEPTION
	WHEN OTHERS THEN

		IF c_valid_org%ISOPEN THEN
			CLOSE c_valid_org;
		END IF;

		IF c_inv_org%ISOPEN THEN
			CLOSE c_inv_org;
		END IF;
		RETURN 'N';
END is_valid_org;

--Bug#3967047
--Retrieve an organization id and store in the global variable g_default_org for the
--API get_dbi_pme_c_params so that it fetches an ItemID from the same org.
FUNCTION get_dbi_pme_org RETURN VARCHAR2 IS
l_first_item_org varchar2(50);

BEGIN
   SELECT organization_id into l_first_item_org	FROM	eni_oltp_item_star
       WHERE rownum = 1;

   g_default_org := l_first_item_org;

   RETURN l_first_item_org;
END get_dbi_pme_org;


END eni_param_util_pkg;

/
