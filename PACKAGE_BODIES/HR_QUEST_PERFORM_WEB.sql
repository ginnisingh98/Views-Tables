--------------------------------------------------------
--  DDL for Package Body HR_QUEST_PERFORM_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_PERFORM_WEB" AS
/* $Header: hrqtpp1w.pkb 120.3 2005/12/13 13:53:10 svittal noship $ */
--
-- Global variables
   g_space              varchar2(1) default ' ';
   g_chr10  varchar2(2000) := hr_util_misc_web.g_new_line;
   g_chr13  varchar2(2000) := hr_util_misc_web.g_carriage_return;
   g_package  varchar2(30) := 'HR_QUEST_PERFORM_WEB';


-- |--------------------------------------------------------------------------|
-- |--< Delete_Quest_Answer_Values >------------------------------------------|
-- |--------------------------------------------------------------------------|
--
PROCEDURE Delete_Quest_Answer_Values
   (p_quest_answer_val_id    IN NUMBER
   ,P_object_version_number  IN NUMBER
   )
IS
l_proc varchar2(200) := g_package || 'Delete_Quest_Answer_Values';

--
BEGIN
--
  hr_utility.set_location(' Entering:' || l_proc,5);

    hr_qsv_del.del(p_quest_answer_val_id => p_quest_answer_val_id
                  ,p_object_version_number=> p_object_version_number);

  hr_utility.set_location(' Leaving:' || l_proc,50);

EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Exception while deleting the answer values',40);
    RAISE;

--
END Delete_Quest_Answer_Values;
--
-- |--------------------------------------------------------------------------|
-- |--< Delete_Quest_Answer >-------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
PROCEDURE Delete_Quest_Answer
   (p_questionnaire_answer_id    IN NUMBER
   )
IS
--
l_proc varchar2(200) := g_package || 'Delete_Quest_Answer';


BEGIN
--

DECLARE
--
   Cursor C_Quest_Answer_Values
   is
   select quest_answer_val_id,object_version_number
   from hr_quest_answer_values
   where questionnaire_answer_id = p_questionnaire_answer_id;

   begin
      hr_utility.set_location(' Entering:' || l_proc,5);


      For R_C_Quest_Answer_Values in C_Quest_Answer_Values
      LOOP
        Delete_Quest_Answer_Values
        (p_quest_answer_val_id=>R_C_Quest_Answer_Values.quest_answer_val_id
        ,p_object_version_number=>R_C_Quest_Answer_Values.object_version_number
        );
      END LOOP;

     hr_qsa_del.del(p_questionnaire_answer_id => p_questionnaire_answer_id);
     hr_utility.set_location(' Entering:' || l_proc,5);

--
   EXCEPTION
    WHEN OTHERS THEN
        hr_utility.set_location('Exception while deleting the answer ',40);
    RAISE;

  end;

--
END Delete_Quest_Answer;
--

END HR_QUEST_PERFORM_WEB;

/
