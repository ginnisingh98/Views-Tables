--------------------------------------------------------
--  DDL for Package PQH_RNG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RNG_RKD" AUTHID CURRENT_USER as
/* $Header: pqrngrhi.pkh 120.0 2005/05/29 02:36:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_attribute_range_id             in number
 ,p_approver_flag_o                in varchar2
 ,p_enable_flag_o                   in varchar2
 ,p_delete_flag_o                 in varchar2
 ,p_assignment_id_o                in number
 ,p_attribute_id_o                 in number
 ,p_from_char_o                    in varchar2
 ,p_from_date_o                    in date
 ,p_from_number_o                  in number
 ,p_position_id_o                  in number
 ,p_range_name_o                   in varchar2
 ,p_routing_category_id_o          in number
 ,p_routing_list_member_id_o       in number
 ,p_to_char_o                      in varchar2
 ,p_to_date_o                      in date
 ,p_to_number_o                    in number
 ,p_object_version_number_o        in number
  );
--
end pqh_rng_rkd;

 

/
