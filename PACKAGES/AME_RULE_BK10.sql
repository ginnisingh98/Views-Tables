--------------------------------------------------------
--  DDL for Package AME_RULE_BK10
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_BK10" AUTHID CURRENT_USER as
/* $Header: amrulapi.pkh 120.4 2006/05/05 04:46:56 avarri noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< replace_lm_condition_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure replace_lm_condition_b
  (p_rule_id                       in     number
  ,p_condition_id                  in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< replace_lm_condition_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure replace_lm_condition_a
  (p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  );
--
--
end ame_rule_bk10;

 

/