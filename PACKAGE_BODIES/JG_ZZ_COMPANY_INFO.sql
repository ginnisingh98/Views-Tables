--------------------------------------------------------
--  DDL for Package Body JG_ZZ_COMPANY_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_COMPANY_INFO" AS
/*$Header: jgzzcib.pls 120.1 2005/06/29 01:58:56 sachandr ship $*/


FUNCTION get_location_id RETURN NUMBER IS
/*----------------------------------------------------------------------
  Name:        get_location_id

  Description: This function returns a location_id of the organization
               that the current responsibility is connecting.

               Diffent profile option is refered to obtain the current
               organization depending on the architecture:
               "MO: Operating Unit" for Multi-Org
               "JG: Company" for non Multi-Org.

               This function can be used from Reports, Concurrent Program
               Forms that need to access company information stored in the
               HR_LOCATIONS Global FlexFields.

  Arguments:   None

------------------------------------------------------------------------*/
  location_id NUMBER(15);
BEGIN

  BEGIN
    SELECT org.location_id
    INTO   location_id
    FROM   hr_organization_units org,
           fnd_product_groups prod
    WHERE  org.organization_id = to_number(decode(nvl(prod.multi_org_flag,'N'), 'Y',
                                           fnd_profile.value_wnps('ORG_ID'),
                                           fnd_profile.value_wnps('JGZZ_COMP_ID')));
  EXCEPTION

    WHEN OTHERS THEN
      raise;
  END;

  return(location_id);

END get_location_id;

END JG_ZZ_COMPANY_INFO;

/
