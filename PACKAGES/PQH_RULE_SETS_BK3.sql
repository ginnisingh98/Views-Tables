--------------------------------------------------------
--  DDL for Package PQH_RULE_SETS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_SETS_BK3" AUTHID CURRENT_USER as
/* $Header: pqrstapi.pkh 120.2 2005/10/28 17:59:06 deenath noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_RULE_SET_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_RULE_SET_b
  (
   p_rule_set_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_RULE_SET_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_RULE_SET_a
  (
   p_rule_set_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_RULE_SETS_bk3;

 

/
