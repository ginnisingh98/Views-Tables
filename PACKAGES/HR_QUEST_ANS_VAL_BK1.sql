--------------------------------------------------------
--  DDL for Package HR_QUEST_ANS_VAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANS_VAL_BK1" AUTHID CURRENT_USER as

/* $Header: hrqsvapi.pkh 120.0 2005/05/31 02:30:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_quest_answer_val_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_quest_answer_val_b
  (
    p_questionnaire_answer_id        in     number
   ,p_field_id                       in     number
   ,p_value                          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_quest_answer_val_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_quest_answer_val_a
  (
    p_questionnaire_answer_id        in     number
   ,p_field_id                       in     number
   ,p_value                          in     varchar2
   ,p_quest_answer_val_id            in     number
   ,p_object_version_number          in     number
  );
--
end hr_quest_ans_val_bk1;

 

/
