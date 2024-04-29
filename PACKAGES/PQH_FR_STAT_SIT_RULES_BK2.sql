--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SIT_RULES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SIT_RULES_BK2" AUTHID CURRENT_USER as
/* $Header: pqstrapi.pkh 120.1 2005/10/02 02:28:01 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_stat_situation_rule_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_stat_situation_rule_b
(
  p_effective_date                 in     date
  ,p_statutory_situation_id         in     number
  ,p_processing_sequence            in     number
  ,p_txn_category_attribute_id      in     number
  ,p_from_value                     in     varchar2
  ,p_to_value                       in     varchar2
  ,p_enabled_flag                   in     varchar2
  ,p_required_flag                  in     varchar2
  ,p_exclude_flag                   in     varchar2
  ,p_stat_situation_rule_id         in 	   number
  ,p_object_version_number          in     number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_stat_situation_rule_a>-------------------------|
-- ----------------------------------------------------------------------------
--
  procedure update_stat_situation_rule_a
  (
  p_effective_date                 in     date
  ,p_statutory_situation_id         in     number
  ,p_processing_sequence            in     number
  ,p_txn_category_attribute_id      in     number
  ,p_from_value                     in     varchar2
  ,p_to_value                       in     varchar2
  ,p_enabled_flag                   in     varchar2
  ,p_required_flag                  in     varchar2
  ,p_exclude_flag                   in     varchar2
  ,p_stat_situation_rule_id         in 	   number
  ,p_object_version_number          in     number
   );
--
end pqh_fr_stat_sit_rules_bk2;

 

/
