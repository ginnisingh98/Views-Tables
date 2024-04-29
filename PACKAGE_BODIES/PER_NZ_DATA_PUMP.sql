--------------------------------------------------------
--  DDL for Package Body PER_NZ_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NZ_DATA_PUMP" as
/* $Header: hrnzdpmf.pkb 120.1 2005/12/22 03:53:37 abhjain noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    01-MAY-2001     115.0     1620642    CreatedMapping Function
  abhjain     22-dec-2005     115.1     4901666    Added function get_run_type_id
                                                   and added dbdrv

*/

function get_registered_employer_id
(p_employer_ird_number in varchar2,
 p_business_group_id   in number)
 return varchar2  is
 l_registered_employer_id number;

begin

  select hoi.organization_id
  into l_registered_employer_id
  from hr_organization_information hoi, hr_organization_units hou
  where hoi.organization_id = hou.organization_id
  and hou.business_group_id = p_business_group_id
  and hoi.org_information_context = 'NZ_IRD_EMPLOYER'
  and hoi.org_information1 = p_employer_ird_number;
  return to_char(l_registered_employer_id);
exception
  when others then
    hr_data_pump.fail('get_registered_employer_id', sqlerrm,
                       p_employer_ird_number, p_business_group_id);
    raise;

end get_registered_employer_id;


FUNCTION get_run_type_id
RETURN NUMBER  IS

  l_run_type_id NUMBER;

BEGIN

  RETURN l_run_type_id;

END get_run_type_id;

end per_nz_data_pump ;

/
