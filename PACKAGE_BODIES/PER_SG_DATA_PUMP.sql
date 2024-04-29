--------------------------------------------------------
--  DDL for Package Body PER_SG_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SG_DATA_PUMP" as
/* $Header: hrsgdpmf.pkb 120.0 2005/05/31 02:41:12 appldev noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    01-MAY-2001     115.0     1554453         Created

*/

function get_legal_employer_id
(p_legal_employer_name in varchar2,
 p_business_group_id   in number)
 return varchar2 is
 l_legal_employer_id number;

begin

  select hou.organization_id
  into l_legal_employer_id
  from hr_organization_information hoi, hr_organization_units hou
  where hoi.organization_id = hou.organization_id
  and hou.business_group_id = p_business_group_id
  and hoi.org_information_context = 'SG_LEGAL_ENTITY'
  and hoi.org_information1 = p_legal_employer_name;
  return to_char(l_legal_employer_id);
exception
  when others then
    hr_data_pump.fail('get_legal_employer_id', sqlerrm,
                       p_legal_employer_name, p_business_group_id);
    raise;

end get_legal_employer_id;
end per_sg_data_pump ;

/
