--------------------------------------------------------
--  DDL for Package PQH_ROUTING_HIST_ATTRIB_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_HIST_ATTRIB_BK1" AUTHID CURRENT_USER as
/* $Header: pqrhaapi.pkh 120.0 2005/05/29 02:28:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_routing_hist_attrib_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_hist_attrib_b
  (
   p_routing_history_id             in  number
  ,p_attribute_id                   in  number
  ,p_from_char                      in  varchar2
  ,p_from_date                      in  date
  ,p_from_number                    in  number
  ,p_to_char                        in  varchar2
  ,p_to_date                        in  date
  ,p_to_number                      in  number
  ,p_range_type_cd                  in  varchar2
  ,p_value_date                     in  date
  ,p_value_number                   in  number
  ,p_value_char                     in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_routing_hist_attrib_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_hist_attrib_a
  (
   p_routing_hist_attrib_id         in  number
  ,p_routing_history_id             in  number
  ,p_attribute_id                   in  number
  ,p_from_char                      in  varchar2
  ,p_from_date                      in  date
  ,p_from_number                    in  number
  ,p_to_char                        in  varchar2
  ,p_to_date                        in  date
  ,p_to_number                      in  number
  ,p_object_version_number          in  number
  ,p_range_type_cd                  in  varchar2
  ,p_value_date                     in  date
  ,p_value_number                   in  number
  ,p_value_char                     in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_routing_hist_attrib_bk1;

 

/
