--------------------------------------------------------
--  DDL for Package PQH_TEM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEM_RKD" AUTHID CURRENT_USER as
/* $Header: pqtemrhi.pkh 120.4 2007/04/19 12:49:27 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_template_id                    in number
 ,p_template_name_o                in varchar2
 ,p_short_name_o                   in varchar2
 ,p_attribute_only_flag_o          in varchar2
 ,p_enable_flag_o                  in varchar2
 ,p_create_flag_o                  in varchar2
 ,p_transaction_category_id_o      in number
 ,p_under_review_flag_o            in varchar2
 ,p_object_version_number_o        in number
 ,p_freeze_status_cd_o             in varchar2
 ,p_template_type_cd_o             in varchar2
 ,p_legislation_code_o		   in varchar2
  );
--
end pqh_tem_rkd;

/
