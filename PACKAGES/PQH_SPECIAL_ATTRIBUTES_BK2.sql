--------------------------------------------------------
--  DDL for Package PQH_SPECIAL_ATTRIBUTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SPECIAL_ATTRIBUTES_BK2" AUTHID CURRENT_USER as
/* $Header: pqsatapi.pkh 120.0 2005/05/29 02:40:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_special_attribute_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_special_attribute_b
  (
   p_special_attribute_id           in  number
  ,p_txn_category_attribute_id      in  number
  ,p_attribute_type_cd              in  varchar2
  ,p_key_attribute_type              in  varchar2
  ,p_enable_flag              in  varchar2
  ,p_flex_code                      in  varchar2
  ,p_object_version_number          in  number
  ,p_ddf_column_name                in  varchar2
  ,p_ddf_value_column_name          in  varchar2
  ,p_context                        in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_special_attribute_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_special_attribute_a
  (
   p_special_attribute_id           in  number
  ,p_txn_category_attribute_id      in  number
  ,p_attribute_type_cd              in  varchar2
  ,p_key_attribute_type              in  varchar2
  ,p_enable_flag              in  varchar2
  ,p_flex_code                      in  varchar2
  ,p_object_version_number          in  number
  ,p_ddf_column_name                in  varchar2
  ,p_ddf_value_column_name          in  varchar2
  ,p_context                        in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_special_attributes_bk2;

 

/
