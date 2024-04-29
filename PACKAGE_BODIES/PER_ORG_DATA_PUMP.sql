--------------------------------------------------------
--  DDL for Package Body PER_ORG_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_DATA_PUMP" AS
/* $Header: perorgdp.pkb 115.1 2002/10/09 09:03:27 fsheikh noship $ */

--
-- Declare global variables
--
l_package_name    VARCHAR2(30) DEFAULT 'PER_ORG_DATA_PUMP.';
-- -------------------------------------------------------------------------
-- --------------------< get_company_valueset_id >--------------------------
-- -------------------------------------------------------------------------
FUNCTION GET_COMPANY_VALUESET_ID
  (P_COMPANY_VALUESET_NAME IN varchar2 )
RETURN BINARY_INTEGER
IS
l_company_valueset_id NUMBER DEFAULT null;
BEGIN
       SELECT flex_value_set_id
       INTO   l_company_valueset_id
       FROM   fnd_flex_value_sets
       WHERE  flex_value_set_name = p_company_valueset_name;

   RETURN(l_company_valueset_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_company_valueset_id'
		    , sqlerrm
		    , p_company_valueset_name);
   RAISE;
END GET_COMPANY_VALUESET_ID;
-- -------------------------------------------------------------------------
-- --------------------< get_costcenter_valueset_id >--------------------------
-- -------------------------------------------------------------------------
FUNCTION GET_COSTCENTER_VALUESET_ID
  (P_COSTCENTER_VALUESET_NAME IN varchar2 )
RETURN BINARY_INTEGER
IS
l_costcenter_valueset_id NUMBER DEFAULT null;
BEGIN
       SELECT flex_value_set_id
       INTO   l_costcenter_valueset_id
       FROM   fnd_flex_value_sets
       WHERE  flex_value_set_name = p_costcenter_valueset_name;

   RETURN(l_costcenter_valueset_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_costcenter_valueset_id'
		    , sqlerrm
		    , p_costcenter_valueset_name);
   RAISE;
END GET_COSTCENTER_VALUESET_ID;
END PER_ORG_DATA_PUMP;

/
