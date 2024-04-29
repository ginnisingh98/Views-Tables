--------------------------------------------------------
--  DDL for Package HR_QSA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSA_RKD" AUTHID CURRENT_USER as
/* $Header: hrqsarhi.pkh 120.0 2005/05/31 02:26:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< after_delete >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
   (p_questionnaire_answer_id    in  number
   ,p_questionnaire_template_id_o  in  number
   ,p_type_o        in  varchar2
   ,p_type_object_id_o      in  number
   ,p_business_group_id_o    in  number
   );
--
end hr_qsa_rkd;

 

/
