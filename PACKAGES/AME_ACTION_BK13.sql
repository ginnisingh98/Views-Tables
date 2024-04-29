--------------------------------------------------------
--  DDL for Package AME_ACTION_BK13
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_BK13" AUTHID CURRENT_USER as
/* $Header: amatyapi.pkh 120.3 2006/09/28 14:03:56 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< <create_ame_action_type_usage_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_type_usage_b
  (p_action_type_id          in     number
  ,p_rule_type               in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_ame_action_type_usage_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_type_usage_a
  (p_action_type_id          in     number
  ,p_rule_type               in     number
  ,p_object_version_number   in     number
  ,p_start_date              in     date
  ,p_end_date                in     date
  );
end ame_action_bk13;

 

/
