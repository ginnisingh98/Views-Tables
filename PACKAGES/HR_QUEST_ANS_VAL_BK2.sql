--------------------------------------------------------
--  DDL for Package HR_QUEST_ANS_VAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANS_VAL_BK2" AUTHID CURRENT_USER as
/* $Header: hrqsvapi.pkh 120.0 2005/05/31 02:30:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_quest_answer_val_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_answer_val_b
  (
   p_quest_answer_val_id          in     number
  ,p_object_version_number        in     number
  ,p_value                        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_quest_answer_val_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_answer_val_a
  (
   p_quest_answer_val_id          in     number
  ,p_object_version_number        in     number
  ,p_value                        in     varchar2
  );
--
end hr_quest_ans_val_bk2;

 

/
