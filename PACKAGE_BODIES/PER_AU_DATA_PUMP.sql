--------------------------------------------------------
--  DDL for Package Body PER_AU_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AU_DATA_PUMP" as
/* $Header: hraudpmf.pkb 120.0 2005/05/30 22:54:36 appldev noship $
   Name        Date         Version      Bug               Text
------------------------------------------------------------------
  apunekar    01-MAY-2001     115.0     1620646         Created

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
  and hoi.org_information_context = 'AU_LEGAL_EMPLOYER'
  and hoi.org_information3 = p_legal_employer_name;
  return to_char(l_legal_employer_id);
exception
  when others then
    hr_data_pump.fail('get_legal_employer_id', sqlerrm,
                       p_legal_employer_name, p_business_group_id);
    raise;

end get_legal_employer_id;
end per_au_data_pump ;

/
