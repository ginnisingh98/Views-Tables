--------------------------------------------------------
--  DDL for Package AME_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: amrulapi.pkh 120.4 2006/05/05 04:46:56 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< <create_ame_rule_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_rule_b
  (p_rule_key                      in     varchar2
  ,p_description                   in     varchar2
  ,p_rule_type                     in     varchar2
  ,p_item_class_id                 in     number
  ,p_condition_id                  in     number
  ,p_action_id                     in     number
  ,p_application_id                in     number
  ,p_priority                      in     number
  ,p_approver_category             in     varchar2
  ,p_rul_start_date                in     date
  ,p_rul_end_date                  in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ame_rule_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_rule_a
  (p_rule_key                      in     varchar2
  ,p_description                   in     varchar2
  ,p_rule_type                     in     varchar2
  ,p_item_class_id                 in     number
  ,p_condition_id                  in     number
  ,p_action_id                     in     number
  ,p_application_id                in     number
  ,p_priority                      in     number
  ,p_approver_category             in     varchar2
  ,p_rul_start_date                in     date
  ,p_rul_end_date                  in     date
  ,p_rule_id                       in     number
  ,p_rul_object_version_number     in     number
  ,p_rlu_object_version_number     in     number
  ,p_rlu_start_date                in     date
  ,p_rlu_end_date                  in     date
  ,p_cnu_object_version_number     in     number
  ,p_cnu_start_date                in     date
  ,p_cnu_end_date                  in     date
  ,p_acu_object_version_number     in     number
  ,p_acu_start_date                in     date
  ,p_acu_end_date                  in     date
  );
--
--
end ame_rule_bk1;

 

/
