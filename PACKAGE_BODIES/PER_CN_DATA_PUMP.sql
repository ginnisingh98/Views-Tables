--------------------------------------------------------
--  DDL for Package Body PER_CN_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_DATA_PUMP" AS
/* $Header: hrcndpmf.pkb 115.0 2003/01/02 09:17:29 statkar noship $ */

FUNCTION get_employer_id
(p_employer_name       IN VARCHAR2,
 p_business_group_id   IN NUMBER )
 RETURN VARCHAR2 IS

 l_employer_id NUMBER;

BEGIN

  SELECT organization_id
  INTO l_employer_id
  FROM hr_organization_units
  WHERE name= p_employer_name
  AND   business_group_id = p_business_group_id;
  RETURN TO_CHAR(l_employer_id);

  EXCEPTION
    WHEN OTHERS THEN
       hr_data_pump.fail('get_employer_id',sqlerrm,p_employer_name, p_business_group_id);
    RAISE;

END get_employer_id;

END per_cn_data_pump ;

/
