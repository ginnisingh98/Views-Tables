--------------------------------------------------------
--  DDL for Package Body PQH_INST_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_INST_TYPE_PKG" as
/* $Header: pqhipedin.pkb 115.1 2002/10/18 00:31:16 rthiagar noship $ */

function get_inst_type( p_org_id number)
return varchar2
is

  cursor c1(cp_org_id number)
  is

   select distinct 1
   from hr_organization_information org
   where org.organization_id = cp_org_id
   and not exists (select org1.org_information_context
   from hr_organization_information org1
   where org1.org_information_context = 'IPEDS_INSTITUTION_TYPE'
   and org1.organization_id = cp_org_id);

  cursor c2(cp_org_id number)
  is

   select org.org_information1
   from hr_organization_information org
   where org.organization_id = cp_org_id
   and org.org_information_context = 'IPEDS_INSTITUTION_TYPE';

   l_inst_not_exists varchar2(5);
   l_inst_type varchar2(10);

begin

   open c1(p_org_id);

   fetch c1 into l_inst_not_exists;

   close c1;

   if (l_inst_not_exists = 1) then
       l_inst_type := 'NON-MED';
   else
       open c2(p_org_id);
       fetch c2 into l_inst_type;
       close c2;
   end if;

   return l_inst_type;
end;

end;

/
