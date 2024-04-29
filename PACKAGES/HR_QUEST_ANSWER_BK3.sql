--------------------------------------------------------
--  DDL for Package HR_QUEST_ANSWER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_ANSWER_BK3" AUTHID CURRENT_USER as
/* $Header: hrqsaapi.pkh 120.0 2005/05/31 02:25:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_answer_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_answer_b
  (
   p_questionnaire_answer_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_answer_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_answer_a
  (
    p_questionnaire_answer_id              in     number
  );
--
end hr_quest_answer_bk3;

 

/
