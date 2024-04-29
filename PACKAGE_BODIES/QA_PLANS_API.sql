--------------------------------------------------------
--  DDL for Package Body QA_PLANS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PLANS_API" AS
/* $Header: qltplanb.plb 120.1 2006/01/31 04:51:08 saugupta noship $ */

--
-- Type definition.  These are tables used to create internal
-- cache to improve performance.  Any records retrieved will be
-- temporarily saved into these tables.
--

TYPE qa_plans_table IS TABLE OF qa_plans%ROWTYPE INDEX BY BINARY_INTEGER;

x_qa_plans_array qa_plans_table;

FUNCTION exists_qa_plans(plan_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    RETURN x_qa_plans_array.EXISTS(plan_id);

END exists_qa_plans;


PROCEDURE fetch_qa_plans (plan_id IN NUMBER) IS

    CURSOR C1 (p_id NUMBER) IS
	SELECT *
	FROM qa_plans
	WHERE plan_id = p_id;

BEGIN

    IF NOT exists_qa_plans(plan_id) THEN
	 OPEN C1(plan_id);
	 FETCH C1 INTO x_qa_plans_array(plan_id);
	 CLOSE C1;
    END IF;

END fetch_qa_plans;


FUNCTION org_id(plan_id IN NUMBER)
    RETURN NUMBER IS

BEGIN

    fetch_qa_plans(plan_id);
    IF NOT exists_qa_plans(plan_id) THEN
	RETURN NULL;
    END IF;
    RETURN x_qa_plans_array(plan_id).organization_id;

END org_id;


FUNCTION plan_name (plan_id IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    fetch_qa_plans(plan_id);
    IF NOT exists_qa_plans(plan_id) THEN
	RETURN NULL;
    END IF;
    RETURN x_qa_plans_array(plan_id).name;

END plan_name;


FUNCTION valid_plan_id (plan_id IN NUMBER)
    RETURN BOOLEAN IS

BEGIN

    fetch_qa_plans(plan_id);
    IF exists_qa_plans(plan_id) THEN
	RETURN TRUE;
    ELSE
	RETURN FALSE;
    END IF;

END valid_plan_id;


FUNCTION plan_id (plan_name IN VARCHAR2)
    RETURN NUMBER IS

    CURSOR c IS
	SELECT plan_id
	FROM qa_plans
	WHERE name = plan_name;

    l_plan_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_plan_id;
    CLOSE c;

    RETURN l_plan_id;

END plan_id;


FUNCTION get_org_id (p_org_code IN VARCHAR2)
    RETURN NUMBER IS

    -- Bug 4958764. SQL Repository Fix SQL ID: 15008188
    CURSOR c IS
        SELECT organization_id
        FROM mtl_parameters
        WHERE organization_code = upper(p_org_code);
/*
	SELECT organization_id
	FROM org_organization_definitions
	WHERE organization_code = p_org_code;
*/
    l_org_id NUMBER;

BEGIN

    OPEN c;
    FETCH c INTO l_org_id;
    CLOSE c;

    RETURN l_org_id;

END get_org_id;

FUNCTION get_plan_type (p_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS


 -- anagarwa Tue Jun  8 14:57:05 PDT 2004
 -- bug  3384507
 -- to show correct plan type in user's language, we should
 -- restrict search by user's language
CURSOR c IS
 SELECT meaning
 FROM   fnd_lookup_values
 WHERE  lookup_type  = 'COLLECTION_PLAN_TYPE'
 AND    lookup_code = p_lookup_code
 AND    LANGUAGE = userenv('LANG');

ret_val VARCHAR2(80);
BEGIN

   OPEN c;
   FETCH c INTO ret_val;
   IF  c%NOTFOUND THEN
     ret_val := '';
   END IF;

   CLOSE c;
   RETURN ret_val;

END get_plan_type;


END qa_plans_api;

/
