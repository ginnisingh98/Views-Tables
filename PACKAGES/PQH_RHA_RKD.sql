--------------------------------------------------------
--  DDL for Package PQH_RHA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RHA_RKD" AUTHID CURRENT_USER as
/* $Header: pqrharhi.pkh 120.1 2005/08/03 13:43:13 nsanghal noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_routing_hist_attrib_id       in number
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
end pqh_rha_rkd;

 

/
