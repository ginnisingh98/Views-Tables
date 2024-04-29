--------------------------------------------------------
--  DDL for Package AME_RULE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_BK4" AUTHID CURRENT_USER as
/* $Header: amrulapi.pkh 120.4 2006/05/05 04:46:56 avarri noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_rule_usage_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_rule_usage_b
  (p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_priority                      in     number
  ,p_approver_category             in     varchar2
  ,p_old_start_date                in     date
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_rule_usage_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_rule_usage_a
  (p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_priority                      in     number
  ,p_approver_category             in     varchar2
  ,p_old_start_date                in     date
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  );
--
--
end ame_rule_bk4;

 

/
