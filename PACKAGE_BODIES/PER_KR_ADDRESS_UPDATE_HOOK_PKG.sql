--------------------------------------------------------
--  DDL for Package Body PER_KR_ADDRESS_UPDATE_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_ADDRESS_UPDATE_HOOK_PKG" as
/* $Header: pekradup.pkb 115.0 2003/05/06 12:27:34 krapolu noship $ */


 procedure update_address_line1_ai(
          p_address_id          in number
         ,p_business_group_id   in number
         ,p_person_id           in number
         ,p_style               in varchar2
         ,p_add_information17   in varchar2)
 is

 cursor csr_kr_person_address
 is
 select pka.city_province||' '||pka.district||' '||pka.town_village kr_address
 from per_kr_addresses pka
 where postal_code_id=to_number(p_add_information17);

 l_kr_address varchar2(200);

 begin

   if p_style ='KR' then

     open csr_kr_person_address;
     fetch csr_kr_person_address into l_kr_address;
     close csr_kr_person_address;

     hr_general.g_data_migrator_mode:='Y';

     update per_addresses
        set address_line1     = l_kr_address
     where person_id          = p_person_id
       and business_group_id  = p_business_group_id
       and  address_id        = p_address_id;

     hr_general.g_data_migrator_mode:='N';

   end if;


 end update_address_line1_ai;

 procedure update_address_line1_au(
           p_address_id           in number
          ,p_business_group_id_o  in number
          ,p_person_id_o          in number
          ,p_style_o              in varchar2
          ,p_add_information17    in varchar2)
 is

 begin

   update_address_line1_ai(p_address_id          => p_address_id
                          ,p_business_group_id   => p_business_group_id_o
                          ,p_person_id           => p_person_id_o
                          ,p_style               => p_style_o
                          ,p_add_information17   => p_add_information17);

 end update_address_line1_au;

end per_kr_address_update_hook_pkg;


/
