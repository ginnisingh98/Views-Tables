--------------------------------------------------------
--  DDL for Package HR_QSF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSF_RKU" AUTHID CURRENT_USER as
/* $Header: hrqsfrhi.pkh 120.0 2005/05/31 02:27:54 appldev noship $ */

--
-- ---------------------------------------------------------------------------
-- |---------------------------< after_update >------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure after_update
  (p_field_id                    in  number
  ,p_sql_text                    in  varchar2
  ,p_object_version_number       in  number
  ,p_questionnaire_template_id_o in  number
  ,p_name_o                      in  varchar2
  ,p_type_o                      in  varchar2
  ,p_html_text_o                 in  varchar2
  ,p_sql_required_flag_o         in  varchar2
  ,p_sql_text_o                  in  varchar2
  ,p_object_version_number_o     in  number
  ,p_effective_date              in  date
  );
--
end hr_qsf_rku;

 

/
