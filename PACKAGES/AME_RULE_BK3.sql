--------------------------------------------------------
--  DDL for Package AME_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: amrulapi.pkh 120.4 2006/05/05 04:46:56 avarri noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_rule_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_rule_b
  (p_rule_id                       in     number
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_rule_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_rule_a
  (p_rule_id                       in     number
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date

  );
--
--
end ame_rule_bk3;

 

/
