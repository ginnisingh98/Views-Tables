--------------------------------------------------------
--  DDL for Package PQH_TEMPLATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEMPLATES_BK2" AUTHID CURRENT_USER as
/* $Header: pqtemapi.pkh 120.1 2005/10/02 02:28:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_GENERIC_TEMPLATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_GENERIC_TEMPLATE_b
  (
   p_template_name                  in  varchar2
  ,p_short_name                     in  varchar2
  ,p_template_id                    in  number
  ,p_attribute_only_flag            in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_create_flag                    in  varchar2
  ,p_transaction_category_id        in  number
  ,p_under_review_flag              in  varchar2
  ,p_object_version_number          in  number
  ,p_freeze_status_cd               in  varchar2
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_GENERIC_TEMPLATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_GENERIC_TEMPLATE_a
  (
   p_template_name                  in  varchar2
  ,p_short_name                     in  varchar2
  ,p_template_id                    in  number
  ,p_attribute_only_flag            in  varchar2
  ,p_enable_flag                    in  varchar2
  ,p_create_flag                    in  varchar2
  ,p_transaction_category_id        in  number
  ,p_under_review_flag              in  varchar2
  ,p_object_version_number          in  number
  ,p_freeze_status_cd               in  varchar2
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_effective_date                 in  date
  );
--
end pqh_TEMPLATES_bk2;

 

/
