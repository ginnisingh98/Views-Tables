--------------------------------------------------------
--  DDL for Package HR_QUEST_ANSWER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANSWER_BK2" AUTHID CURRENT_USER as
/* $Header: hrqsaapi.pkh 120.0 2005/05/31 02:25:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_quest_answer_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_answer_b
  (
    p_effective_date               in     date
   ,p_questionnaire_answer_id      in     number
   ,p_questionnaire_template_id    in     number
   ,p_type                         in     varchar2
   ,p_type_object_id               in     number
   ,p_business_group_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_quest_answer_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_answer_a
  (
    p_effective_date               in     date
   ,p_questionnaire_answer_id      in     number
   ,p_questionnaire_template_id    in     number
   ,p_type                         in     varchar2
   ,p_type_object_id               in     number
   ,p_business_group_id            in     number
  );
--
end hr_quest_answer_bk2;

 

/
