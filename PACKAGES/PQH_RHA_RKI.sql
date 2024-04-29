--------------------------------------------------------
--  DDL for Package PQH_RHA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RHA_RKI" AUTHID CURRENT_USER as
/* $Header: pqrharhi.pkh 120.1 2005/08/03 13:43:13 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_routing_hist_attrib_id       in number
  ,p_routing_history_id           in number
  ,p_attribute_id                 in number
  ,p_from_char                    in varchar2
  ,p_from_date                    in date
  ,p_from_number                  in number
  ,p_to_char                      in varchar2
  ,p_to_date                      in date
  ,p_to_number                    in number
  ,p_object_version_number        in number
  ,p_range_type_cd                in varchar2
  ,p_value_date                   in date
  ,p_value_number                 in number
  ,p_value_char                   in varchar2
  );
end pqh_rha_rki;

 

/
