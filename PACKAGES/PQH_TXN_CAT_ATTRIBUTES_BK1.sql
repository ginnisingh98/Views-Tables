--------------------------------------------------------
--  DDL for Package PQH_TXN_CAT_ATTRIBUTES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_CAT_ATTRIBUTES_BK1" AUTHID CURRENT_USER as
/* $Header: pqtcaapi.pkh 120.1 2005/10/02 02:28:20 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_TXN_CAT_ATTRIBUTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_TXN_CAT_ATTRIBUTE_b
  (
   p_attribute_id                   in  number
  ,p_transaction_category_id        in  number
  ,p_value_set_id                   in  number
  ,p_transaction_table_route_id     in  number
  ,p_form_column_name               in  varchar2
  ,p_identifier_flag                in  varchar2
  ,p_list_identifying_flag          in  varchar2
  ,p_member_identifying_flag        in  varchar2
  ,p_refresh_flag                   in  varchar2
  ,p_select_flag                    in  varchar2
  ,p_value_style_cd                 in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_TXN_CAT_ATTRIBUTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_TXN_CAT_ATTRIBUTE_a
  (
   p_txn_category_attribute_id      in  number
  ,p_attribute_id                   in  number
  ,p_transaction_category_id        in  number
  ,p_value_set_id                   in  number
  ,p_object_version_number          in  number
  ,p_transaction_table_route_id     in  number
  ,p_form_column_name               in  varchar2
  ,p_identifier_flag                in  varchar2
  ,p_list_identifying_flag          in  varchar2
  ,p_member_identifying_flag        in  varchar2
  ,p_refresh_flag                   in  varchar2
  ,p_select_flag                    in  varchar2
  ,p_value_style_cd                 in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_TXN_CAT_ATTRIBUTES_bk1;

 

/
