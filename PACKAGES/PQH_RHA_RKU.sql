--------------------------------------------------------
--  DDL for Package PQH_RHA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RHA_RKU" AUTHID CURRENT_USER as
/* $Header: pqrharhi.pkh 120.1 2005/08/03 13:43:13 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
  ,p_routing_history_id_o         in number
  ,p_attribute_id_o               in number
  ,p_from_char_o                  in varchar2
  ,p_from_date_o                  in date
  ,p_from_number_o                in number
  ,p_to_char_o                    in varchar2
  ,p_to_date_o                    in date
  ,p_to_number_o                  in number
  ,p_object_version_number_o      in number
  ,p_range_type_cd_o              in varchar2
  ,p_value_date_o                 in date
  ,p_value_number_o               in number
  ,p_value_char_o                 in varchar2
  );
--
end pqh_rha_rku;

 

/
