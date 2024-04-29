--------------------------------------------------------
--  DDL for Package AME_RULE_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: ameruleutility.pkh 120.1 2005/10/24 21:46 tkolla noship $ */
  ActionNotAllowed constant number := 1;
  GroupNotAllowed constant number := 2;
  PosActionNotAllowed constant number := 3;
  ActionNotAllowedInTTY constant number := 4;
  GroupNotAllowedInTTY constant number := 5;
  PosActionNotAllowedInTTY constant number := 6;
  NoErrors constant number := 7;
--+
  procedure syncRuleObjects(p_rule_id  in           number
                           ,p_effective_date  in    date      default null);
--+
  procedure checkRuleId(p_rule_id  in           number);
--+
  procedure checkActionId(p_action_id  in           number);
--+
  procedure checkConditionId(p_condition_id  in           number);
--+
  procedure checkApplicationId(p_application_id  in           number);
--+
  procedure getAttributeName(p_attribute_id       in         number
                            ,p_attribute_name_out out nocopy varchar2);
--+
  procedure checkRuleForUsage(ruleIdIn        in integer
                             ,applicationIdIn in integer
                             ,endDateIn       in varchar2
                             ,resultOut       out nocopy varchar2);
--+
  -- returns 1 if the rule can be re-enabled
  -- and returns 0 otherwise
  function isRuleReenabled(ruleIdIn        in integer
                          ,applicationIdIn in integer
                          ,endDateIn       in varchar2) return integer;
--+
  procedure enableRule(ruleIdIn        in integer
                      ,ruleEndDateIn   in date
                      ,startDateIn     in date
                      ,endDateIn       in date
                      ,resultOut       out nocopy varchar2);
--+
  procedure checkAllApplications(ruleIdIn      in integer
                                ,conditionIdIn in integer);
--+
  procedure chekActionForAllApplications(ruleIdIn   in integer
                                        ,actionIdIn in integer);
--+
  function rule_conditions_count(p_rule_id  in integer) return integer;
--+
  function is_action_allowed(p_application_id   in integer
                            ,p_action_id        in integer) return number;
--+
  function is_rule_usage_allowed(p_application_id in integer
                                ,p_rule_id        in integer) return number;
--+
  function is_LM_comb_rule(p_rule_id in integer) return boolean;
--+
  function is_prod_action_allowed(p_application_id in integer) return boolean;
--+
  function chk_rule_type(p_rule_id                    in integer
                        ,p_rule_type                  in integer
                        ,p_action_rule_type           in integer
                        ,p_application_id             in integer
                        ,p_allow_production_action    in boolean) return boolean;
--+
  function is_condition_allowed(p_application_id in integer
                               ,p_condition_id   in integer) return boolean;
--+
  function is_action_deletion_allowed(p_rule_id   in integer
                                     ,p_action_id in integer) return boolean;
--+
  function is_rule_usage_cond_allowed(p_application_id in integer
                                     ,p_rule_id        in integer) return boolean;
--+
  procedure chk_LM_action_Condition(p_condition_id in integer
                                   ,p_action_id    in integer
                                   ,is_first_condition in boolean);
--+
  function is_group_allowed(p_application_id    in integer
                           ,p_approval_group_id in integer) return boolean;
--+
  function is_all_approver_types_allowed(p_application_id    in integer) return boolean;
--+
  function is_per_approver(p_name in varchar2) return boolean;
--+
  function is_pos_approver(p_name in varchar2) return boolean;
  --+
  procedure chk_rule_and_item_class(p_rule_id      in integer
                                   ,p_condition_id in integer);
  --+
  function is_cond_exist_in_rule(p_rule_id      in integer
                                ,p_condition_id in integer) return boolean;
--+
  function chk_lm_actions(p_rule_id   in integer
                         ,p_action_id in integer) return boolean;
end ame_rule_utility_pkg;

 

/
