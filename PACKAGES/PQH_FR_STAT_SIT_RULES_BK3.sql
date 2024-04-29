--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SIT_RULES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SIT_RULES_BK3" AUTHID CURRENT_USER as
/* $Header: pqstrapi.pkh 120.1 2005/10/02 02:28:01 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_stat_situation_rule_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_stat_situation_rule_b
(
  p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_stat_situation_rule_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_stat_situation_rule_a
(
  p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
);

--
end pqh_fr_stat_sit_rules_bk3;

 

/
