--------------------------------------------------------
--  DDL for Package HR_QUEST_ANSWER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANSWER_BK1" AUTHID CURRENT_USER as
/* $Header: hrqsaapi.pkh 120.0 2005/05/31 02:25:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_quest_answer_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_quest_answer_b
  (
    p_effective_date                 in     date
   ,p_questionnaire_template_id      in     number
   ,p_type                           in     varchar2
   ,p_type_object_id                 in     number
   ,p_business_group_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_quest_answer_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_quest_answer_a
  (
    p_effective_date                 in     date
   ,p_questionnaire_template_id      in     number
   ,p_type                           in     varchar2
   ,p_type_object_id                 in     number
   ,p_business_group_id              in     number
   ,p_questionnaire_answer_id        in     number
  );
--
end hr_quest_answer_bk1;

 

/
