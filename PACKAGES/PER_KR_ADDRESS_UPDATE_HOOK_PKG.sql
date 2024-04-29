--------------------------------------------------------
--  DDL for Package PER_KR_ADDRESS_UPDATE_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_ADDRESS_UPDATE_HOOK_PKG" AUTHID CURRENT_USER as
/* $Header: pekradup.pkh 120.0 2005/05/31 11:01:45 appldev noship $ */

  procedure update_address_line1_ai(
            p_address_id          in number
           ,p_business_group_id   in number
           ,p_person_id           in number
           ,p_style               in varchar2
           ,p_add_information17   in varchar2);


  procedure update_address_line1_au(
            p_address_id           in number
           ,p_business_group_id_o  in number
           ,p_person_id_o          in number
           ,p_style_o              in varchar2
           ,p_add_information17    in varchar2);

end per_kr_address_update_hook_pkg;

 

/
