--------------------------------------------------------
--  DDL for Package PQH_ROLE_TEMPLATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLE_TEMPLATES_BK2" AUTHID CURRENT_USER as
/* $Header: pqrtmapi.pkh 120.1 2005/10/02 02:27:52 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_role_template_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_role_template_b
  (
   p_role_template_id               in  number
  ,p_role_id                        in  number
  ,p_transaction_category_id        in  number
  ,p_template_id                    in  number
  ,p_enable_flag                    in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_role_template_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_role_template_a
  (
   p_role_template_id               in  number
  ,p_role_id                        in  number
  ,p_transaction_category_id        in  number
  ,p_template_id                    in  number
  ,p_enable_flag                    in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end PQH_ROLE_TEMPLATES_bk2;

 

/
