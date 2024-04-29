--------------------------------------------------------
--  DDL for Package PQH_TCA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TCA_RKI" AUTHID CURRENT_USER as
/* $Header: pqtcarhi.pkh 120.2 2005/10/12 20:19:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_txn_category_attribute_id      in number
 ,p_attribute_id                   in number
 ,p_transaction_category_id        in number
 ,p_value_set_id                   in number
 ,p_object_version_number          in number
 ,p_transaction_table_route_id     in number
 ,p_form_column_name               in varchar2
 ,p_identifier_flag                in varchar2
 ,p_list_identifying_flag          in varchar2
 ,p_member_identifying_flag        in varchar2
 ,p_refresh_flag                   in varchar2
 ,p_select_flag                   in varchar2
 ,p_value_style_cd                 in varchar2
 ,p_effective_date                 in date
  );
end pqh_tca_rki;

 

/
