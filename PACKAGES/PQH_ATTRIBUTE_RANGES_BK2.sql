--------------------------------------------------------
--  DDL for Package PQH_ATTRIBUTE_RANGES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ATTRIBUTE_RANGES_BK2" AUTHID CURRENT_USER as
/* $Header: pqrngapi.pkh 120.1 2005/10/02 02:27:43 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ATTRIBUTE_RANGE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ATTRIBUTE_RANGE_b
  (
   p_attribute_range_id             in  number
  ,p_approver_flag                  in  varchar2
  ,p_enable_flag                  in  varchar2
  ,p_delete_flag                  in  varchar2
  ,p_assignment_id                  in  number
  ,p_attribute_id                   in  number
  ,p_from_char                      in  varchar2
  ,p_from_date                      in  date
  ,p_from_number                    in  number
  ,p_position_id                    in  number
  ,p_range_name                     in  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number
  ,p_to_char                        in  varchar2
  ,p_to_date                        in  date
  ,p_to_number                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ATTRIBUTE_RANGE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ATTRIBUTE_RANGE_a
  (
   p_attribute_range_id             in  number
  ,p_approver_flag                  in  varchar2
  ,p_enable_flag                  in  varchar2
  ,p_delete_flag                  in  varchar2
  ,p_assignment_id                  in  number
  ,p_attribute_id                   in  number
  ,p_from_char                      in  varchar2
  ,p_from_date                      in  date
  ,p_from_number                    in  number
  ,p_position_id                    in  number
  ,p_range_name                     in  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number
  ,p_to_char                        in  varchar2
  ,p_to_date                        in  date
  ,p_to_number                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ATTRIBUTE_RANGES_bk2;

 

/
