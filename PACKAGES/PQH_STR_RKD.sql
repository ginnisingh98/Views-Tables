--------------------------------------------------------
--  DDL for Package PQH_STR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_STR_RKD" AUTHID CURRENT_USER as
/* $Header: pqstrrhi.pkh 120.0 2005/05/29 02:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_stat_situation_rule_id       in number
  ,p_statutory_situation_id_o     in number
  ,p_processing_sequence_o        in number
  ,p_txn_category_attribute_id_o  in number
  ,p_from_value_o                 in varchar2
  ,p_to_value_o                   in varchar2
  ,p_enabled_flag_o               in varchar2
  ,p_required_flag_o              in varchar2
  ,p_exclude_flag_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_str_rkd;

 

/
