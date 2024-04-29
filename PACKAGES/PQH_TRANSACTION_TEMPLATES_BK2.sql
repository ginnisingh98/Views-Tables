--------------------------------------------------------
--  DDL for Package PQH_TRANSACTION_TEMPLATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRANSACTION_TEMPLATES_BK2" AUTHID CURRENT_USER as
/* $Header: pqttmapi.pkh 120.0 2005/05/29 02:51:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_transaction_template_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_transaction_template_b
  (
   p_transaction_template_id        in  number
  ,p_enable_flag                    in  varchar2
  ,p_template_id                    in  number
  ,p_transaction_id                 in  number
  ,p_transaction_category_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_transaction_template_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_transaction_template_a
  (
   p_transaction_template_id        in  number
  ,p_enable_flag                    in  varchar2
  ,p_template_id                    in  number
  ,p_transaction_id                 in  number
  ,p_transaction_category_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_transaction_templates_bk2;

 

/
