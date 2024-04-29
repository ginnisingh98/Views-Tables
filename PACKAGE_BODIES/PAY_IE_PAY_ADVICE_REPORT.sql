--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAY_ADVICE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAY_ADVICE_REPORT" as
/* $Header: pyiersoe.pkb 115.1 2003/09/15 10:56:48 vmkhande noship $ */
   g_package          CONSTANT VARCHAR2(33) := 'pay_ie_pay_advice_report.';

   Function get_address_line_1 (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2
   is
   l_address_line_1 varchar2(150);
   begin
       hr_utility.trace('Entering ' ||g_package || 'get_address_line_1' );
       select ADDRESS_LINE_1 into l_address_line_1
       from  hr_locations_all
           where location_code = p_location_code and
                 nvl(BUSINESS_GROUP_ID,p_business_group_id) =
                                        p_business_group_id;

       hr_utility.trace('l_address_line_1 ' ||l_address_line_1 );
       return l_address_line_1;
       Exception
       when others then
            hr_utility.trace('Exception! Setting l_address_line_1 as null' ||l_address_line_1 );
            l_address_line_1 := null;
            return l_address_line_1;
   end;

   Function get_address_line_2 (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2
   is
   l_address_line_2 varchar2(150);
   begin
       hr_utility.trace('Entering ' ||g_package || 'get_address_line_2' );
       select ADDRESS_LINE_2 into l_address_line_2
       from  hr_locations_all
           where location_code = p_location_code and
                 nvl(BUSINESS_GROUP_ID,p_business_group_id) =
                                        p_business_group_id;

       hr_utility.trace('l_address_line_2 ' ||l_address_line_2 );
       return l_address_line_2;
       Exception
       when others then
            hr_utility.trace('Exception! Setting l_address_line_2 as null' ||l_address_line_2 );
            l_address_line_2 := null;
            return l_address_line_2;
   end;

   Function get_address_line_3 (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2
   is
   l_address_line_3 varchar2(150);
   begin
       hr_utility.trace('Entering ' ||g_package || 'get_address_line_3' );
       select ADDRESS_LINE_3 into l_address_line_3
       from  hr_locations_all
           where location_code = p_location_code and
                 nvl(BUSINESS_GROUP_ID,p_business_group_id) =
                                        p_business_group_id;

       hr_utility.trace('l_address_line_3 ' ||l_address_line_3 );
       return l_address_line_3;
       Exception
       when others then
            hr_utility.trace('Exception! Setting l_address_line_3 as null' ||l_address_line_3 );
            l_address_line_3 := null;
            return l_address_line_3;
   end;

 -- region 1 is county
   Function get_region_1       (p_location_code varchar2,
                               p_business_group_id varchar2,
                               p_effective_date Date)
   return varchar2

   is
   l_REGION_1 varchar2(150);
   begin

    hr_utility.trace('Entering ' ||g_package || 'get_region1' );
    select HR_COUNTY.meaning into l_REGION_1
       from  hr_locations_all,
           	 HR_LOOKUPS  HR_COUNTY
           where location_code = p_location_code and
                 nvl(BUSINESS_GROUP_ID,p_business_group_id) =
                                        p_business_group_id   AND
                 HR_COUNTY.LOOKUP_TYPE(+) ='IE_COUNTY' AND
                 HR_COUNTY.LOOKUP_CODE(+) = REGION_1 AND
                 p_effective_date between nvl(START_DATE_ACTIVE,p_effective_date)
                 and  nvl(END_DATE_ACTIVE,p_effective_date);
       hr_utility.trace('l_REGION_1 ' ||l_REGION_1);
       return l_REGION_1;
       Exception
       when others then
            hr_utility.trace('Exception! Setting l_REGION_1 as null' );
            l_REGION_1 := null;
            return l_REGION_1;
   end;

   Function get_region_2   (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2
   is
   l_region_2 varchar2(150);
   begin
       hr_utility.trace('Entering ' ||g_package || 'get_region_2' );
       select REGION_2 into l_region_2
       from  hr_locations_all
           where location_code = p_location_code and
                 nvl(BUSINESS_GROUP_ID,p_business_group_id) =
                                        p_business_group_id;

       hr_utility.trace('l_region_2 ' ||l_region_2 );
       return l_region_2;
       Exception
       when others then
            hr_utility.trace('Exception! Setting l_region_2 as null'  );
            l_region_2 := null;
            return l_region_2;
   end;

   Function get_country       (p_location_code varchar2,
                               p_business_group_id varchar2)
  return varchar2
  is
  l_country varchar2(150);
   begin
       hr_utility.trace('Entering ' ||g_package || 'get_country' );
       select TERRITORY_SHORT_NAME into l_country
       from  hr_locations_all,
            FND_TERRITORIES_VL fnd_ter
           where location_code = p_location_code and
                 nvl(BUSINESS_GROUP_ID,p_business_group_id) =
                                        p_business_group_id and
                 FND_TER.TERRITORY_CODE(+) = COUNTRY;
       hr_utility.trace('l_country ' ||l_country );
       return l_country;
       Exception
       when others then
            hr_utility.trace('Exception! Setting l_country as null'  );
            l_country := null;
            return l_country;
   end;
end;

/
