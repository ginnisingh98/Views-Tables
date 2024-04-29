--------------------------------------------------------
--  DDL for Package Body PER_HK_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HK_DATA_PUMP" as
/* $Header: hrhkdpmf.pkb 120.0 2005/05/31 00:42:39 appldev noship $
   Name        Date         Version      Bug               Text
-------------------------------------------------------------------------------
  apunekar    29-MAY-2001     115.0     1620654         Created mapping function

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
  and hou.name = p_legal_employer_name
  and hou.business_group_id = p_business_group_id
  and hoi.org_information_context = 'HK_LEGAL_EMPLOYER';
  return to_char(l_legal_employer_id);
exception
  when others then
    hr_data_pump.fail('get_legal_employer_id', sqlerrm,
                       p_legal_employer_name, p_business_group_id);
    raise;

end get_legal_employer_id;
end per_hk_data_pump ;

/
