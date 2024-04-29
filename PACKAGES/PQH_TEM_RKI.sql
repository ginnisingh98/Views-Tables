--------------------------------------------------------
--  DDL for Package PQH_TEM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEM_RKI" AUTHID CURRENT_USER as
/* $Header: pqtemrhi.pkh 120.4 2007/04/19 12:49:27 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_template_name                  in varchar2
 ,p_short_name                     in varchar2
 ,p_template_id                    in number
 ,p_attribute_only_flag            in varchar2
 ,p_enable_flag                    in varchar2
 ,p_create_flag                    in varchar2
 ,p_transaction_category_id        in number
 ,p_under_review_flag              in varchar2
 ,p_object_version_number          in number
 ,p_freeze_status_cd               in varchar2
 ,p_template_type_cd               in varchar2
 ,p_legislation_code		   in varchar2
 ,p_effective_date                 in date
  );
end pqh_tem_rki;

/
