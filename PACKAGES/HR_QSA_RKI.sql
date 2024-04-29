--------------------------------------------------------
--  DDL for Package HR_QSA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSA_RKI" AUTHID CURRENT_USER as
/* $Header: hrqsarhi.pkh 120.0 2005/05/31 02:26:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< after_insert >-----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
   (p_questionnaire_answer_id    in   number
   ,p_questionnaire_template_id    in  number
   ,p_type        in  varchar2
   ,p_type_object_id      in  number
   ,p_business_group_id      in  number
   ,p_effective_date      in   date
   );
--
end hr_qsa_rki;

 

/
