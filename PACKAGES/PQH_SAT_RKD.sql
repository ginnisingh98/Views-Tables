--------------------------------------------------------
--  DDL for Package PQH_SAT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SAT_RKD" AUTHID CURRENT_USER as
/* $Header: pqsatrhi.pkh 120.2 2005/10/12 20:19:34 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_special_attribute_id           in number
 ,p_txn_category_attribute_id_o    in number
 ,p_attribute_type_cd_o            in varchar2
 ,p_key_attribute_type_o           in varchar2
 ,p_enable_flag_o                  in varchar2
 ,p_flex_code_o                    in varchar2
 ,p_object_version_number_o        in number
 ,p_ddf_column_name_o              in varchar2
 ,p_ddf_value_column_name_o        in varchar2
 ,p_context_o                      in varchar2
  );
--
end pqh_sat_rkd;

 

/
