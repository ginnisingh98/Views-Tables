--------------------------------------------------------
--  DDL for Package PQH_TRANSACTION_TEMPLATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TRANSACTION_TEMPLATES_BK3" AUTHID CURRENT_USER as
/* $Header: pqttmapi.pkh 120.0 2005/05/29 02:51:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_transaction_template_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_transaction_template_b
  (
   p_transaction_template_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_transaction_template_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_transaction_template_a
  (
   p_transaction_template_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_transaction_templates_bk3;

 

/
