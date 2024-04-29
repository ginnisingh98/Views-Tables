--------------------------------------------------------
--  DDL for Package HR_QSV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSV_RKU" AUTHID CURRENT_USER as
/* $Header: hrqsvrhi.pkh 120.0 2005/05/31 02:31:14 appldev noship $ */

--
-- ---------------------------------------------------------------------------
-- |---------------------------< after_update >------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure after_update
  (p_quest_answer_val_id    in  number
  ,p_object_version_number    in  number
  ,p_value        in  varchar2
  ,p_questionnaire_answer_id_o    in  number
  ,p_field_id_o        in  number
  ,p_object_version_number_o    in  number
  ,p_value_o        in  varchar2
  );
--
end hr_qsv_rku;

 

/
