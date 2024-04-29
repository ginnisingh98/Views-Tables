--------------------------------------------------------
--  DDL for Package PQH_SAT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SAT_RKI" AUTHID CURRENT_USER as
/* $Header: pqsatrhi.pkh 120.2 2005/10/12 20:19:34 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_special_attribute_id           in number
 ,p_txn_category_attribute_id      in number
 ,p_attribute_type_cd              in varchar2
 ,p_key_attribute_type              in varchar2
 ,p_enable_flag              in varchar2
 ,p_flex_code                      in varchar2
 ,p_object_version_number          in number
 ,p_ddf_column_name                in varchar2
 ,p_ddf_value_column_name          in varchar2
 ,p_context                        in varchar2
 ,p_effective_date                 in date
  );
end pqh_sat_rki;

 

/
