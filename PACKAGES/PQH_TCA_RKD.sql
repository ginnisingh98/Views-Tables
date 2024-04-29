--------------------------------------------------------
--  DDL for Package PQH_TCA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCA_RKD" AUTHID CURRENT_USER as
/* $Header: pqtcarhi.pkh 120.2 2005/10/12 20:19:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_txn_category_attribute_id      in number
 ,p_attribute_id_o                 in number
 ,p_transaction_category_id_o      in number
 ,p_value_set_id_o                 in number
 ,p_object_version_number_o        in number
 ,p_transaction_table_route_id_o   in number
 ,p_form_column_name_o             in varchar2
 ,p_identifier_flag_o              in varchar2
 ,p_list_identifying_flag_o        in varchar2
 ,p_member_identifying_flag_o      in varchar2
 ,p_refresh_flag_o                 in varchar2
 ,p_select_flag_o                 in varchar2
 ,p_value_style_cd_o               in varchar2
  );
--
end pqh_tca_rkd;

 

/
