--------------------------------------------------------
--  DDL for Package AME_RULE_BK9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_BK9" AUTHID CURRENT_USER as
/* $Header: amrulapi.pkh 120.4 2006/05/05 04:46:56 avarri noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_rule_action_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_rule_action_b
  (p_rule_id                       in     number
  ,p_action_id                     in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_rule_action_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_rule_action_a
  (p_rule_id                       in     number
  ,p_action_id                     in     number
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  );
--
--
end ame_rule_bk9;

 

/
