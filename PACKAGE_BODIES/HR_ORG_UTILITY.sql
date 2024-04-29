--------------------------------------------------------
--  DDL for Package Body HR_ORG_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORG_UTILITY" as
/* $Header: peorgutl.pkb 120.0 2006/06/13 12:55:32 hmehta noship $ */

g_package  Varchar2(30) := 'hr_org_utility.';
g_debug boolean := hr_utility.debug_enabled;

--
---------------------------get_ccm_org-----------------------------
--
   FUNCTION get_ccm_org
     ( p_organization_id IN Number,
       p_restricted_class in varchar2)
     RETURN  varchar2 is
     l_flag varchar2(1) := 'Y';
     l_cnt  number;

     Cursor c1 is
     select 1
     from hr_organization_information org2,
          hr_org_info_types_by_class oitbc
     where org2.organization_id = p_organization_id
     and org2.org_information_context||'' = 'CLASS'
     and org2.org_information2 = 'Y'
     and org2.org_information1 = nvl(p_restricted_class,org2.org_information1)
     and org2.org_information1 = oitbc.org_classification
     and oitbc.org_information_type = 'Organization Name Alias';

   BEGIN
     select count(distinct org_information_context)
     into l_cnt
     from  hr_organization_information
     where organization_id = p_organization_id
     and   org_information_context in ('Organization Name Alias', 'CLASS');

     --Return if both classifications are not present.
     if l_cnt < 2 then
       return 'N';
     else
       l_cnt := 0;
       Open  c1;
       Fetch c1 into l_cnt;
       close c1;
       if l_cnt = 0 then --Conditions not met, return N.
          return 'N';
       else --Found...all conditions met, return Y
          return 'Y';
       end if;
     end if;
   EXCEPTION
      WHEN others THEN
          raise;
   END get_ccm_org;
--
End hr_org_utility;


/
