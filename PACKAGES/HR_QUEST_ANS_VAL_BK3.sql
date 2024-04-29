--------------------------------------------------------
--  DDL for Package HR_QUEST_ANS_VAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANS_VAL_BK3" AUTHID CURRENT_USER as
/* $Header: hrqsvapi.pkh 120.0 2005/05/31 02:30:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_answer_val_b >-------------------------|
-- ----------------------------------------------------------------------------
--
 procedure delete_quest_answer_val_b
  (
   p_quest_answer_val_id                  in     number
  ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_answer_val_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_answer_val_a
  (
   p_quest_answer_val_id                  in     number
  ,p_object_version_number                in     number
  );
--
end hr_quest_ans_val_bk3;

 

/
