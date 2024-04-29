--------------------------------------------------------
--  DDL for Package PQH_RNG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RNG_RKI" AUTHID CURRENT_USER as
/* $Header: pqrngrhi.pkh 120.0 2005/05/29 02:36:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_attribute_range_id             in number
 ,p_approver_flag                  in varchar2
 ,p_enable_flag                   in varchar2
 ,p_delete_flag                   in varchar2
 ,p_assignment_id                  in number
 ,p_attribute_id                   in number
 ,p_from_char                      in varchar2
 ,p_from_date                      in date
 ,p_from_number                    in number
 ,p_position_id                    in number
 ,p_range_name                     in varchar2
 ,p_routing_category_id            in number
 ,p_routing_list_member_id         in number
 ,p_to_char                        in varchar2
 ,p_to_date                        in date
 ,p_to_number                      in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end pqh_rng_rki;

 

/
