--------------------------------------------------------
--  DDL for Package HR_QUEST_PERFORM_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUEST_PERFORM_WEB" AUTHID CURRENT_USER AS
/* $Header: hrqtpp1w.pkh 120.3 2005/12/13 13:52:41 svittal noship $ */
--
-- |--------------------------------------------------------------------------|
-- |--< Global Variable Declarations >----------------------------------------|
-- |--------------------------------------------------------------------------|
--
g_tag_not_found_exception EXCEPTION;
g_invalid_tag_exception   EXCEPTION;
g_handled_exception       EXCEPTION;
PRAGMA EXCEPTION_INIT(g_tag_not_found_exception, -20001);
PRAGMA EXCEPTION_INIT(g_invalid_tag_exception, -20002);
--
c_max_size  CONSTANT NUMBER  := 27648;
c_debug     CONSTANT BOOLEAN := FALSE;
--
-- |--------------------------------------------------------------------------|
-- |--< Type Declarations >---------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
TYPE r_field_structure IS RECORD
   (a_tag                  VARCHAR2 (30)  DEFAULT NULL
   ,a_name                 VARCHAR2 (30)  DEFAULT NULL
   ,a_type                 VARCHAR2 (30)  DEFAULT NULL
   ,a_value                LONG           DEFAULT NULL
   ,a_text                 LONG           DEFAULT NULL
   ,a_checked              VARCHAR2 (1)   DEFAULT 'N'
   ,a_size                 NUMBER         DEFAULT 0
   ,a_cols                 NUMBER         DEFAULT 0
   ,a_rows                 NUMBER         DEFAULT 0
   ,a_token                VARCHAR2 (30)  DEFAULT NULL
   ,field_id               NUMBER         DEFAULT NULL
   ,object_version_number  NUMBER         DEFAULT 0
   );
--
TYPE t_field_structure IS TABLE OF r_field_structure INDEX BY BINARY_INTEGER;

PROCEDURE Delete_Quest_Answer
   (p_questionnaire_answer_id    IN NUMBER
   );
--
-- |--------------------------------------------------------------------------|
-- |--< Delete_Quest_Answer_Values >------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--    This procedure is a wrapper around hr_qsv_del.del procedure , and it
--    allows to delete the question answer values from hr_quest_answer_values
--    tables if the entries of "VALUE" column are null.
--
PROCEDURE Delete_Quest_Answer_Values
   (p_quest_answer_val_id         IN NUMBER
   ,p_object_version_number       IN NUMBER
   );
--
--
-- |--------------------------------------------------------------------------|
-- |--< Debug >---------------------------------------------------------------|
-- |--------------------------------------------------------------------------|
END HR_QUEST_PERFORM_WEB;

 

/
