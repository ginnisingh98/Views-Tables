--------------------------------------------------------
--  DDL for Package HR_QSV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSV_RKI" AUTHID CURRENT_USER as
/* $Header: hrqsvrhi.pkh 120.0 2005/05/31 02:31:14 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |---------------------------< after_insert >------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure after_insert
   (p_quest_answer_val_id   in  number
   ,p_questionnaire_answer_id   in   number
   ,p_field_id      in  number
   ,p_object_version_number  in  number
   ,p_value      in  varchar2
   );
--
end hr_qsv_rki;

 

/
