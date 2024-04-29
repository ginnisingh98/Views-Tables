--------------------------------------------------------
--  DDL for Package PQH_RMV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RMV_RKD" AUTHID CURRENT_USER as
/* $Header: pqrmvrhi.pkh 120.2 2005/06/23 03:42 srenukun noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_node_value_id                in number
  ,p_rate_matrix_node_id_o        in number
  ,p_short_code_o                 in varchar2
  ,p_char_value1_o                in varchar2
  ,p_char_value2_o                in varchar2
  ,p_char_value3_o                in varchar2
  ,p_char_value4_o                in varchar2
  ,p_number_value1_o              in number
  ,p_number_value2_o              in number
  ,p_number_value3_o              in number
  ,p_number_value4_o              in number
  ,p_date_value1_o                in date
  ,p_date_value2_o                in date
  ,p_date_value3_o                in date
  ,p_date_value4_o                in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_rmv_rkd;

 

/
