--------------------------------------------------------
--  DDL for Package HR_QSF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSF_RKI" AUTHID CURRENT_USER as
/* $Header: hrqsfrhi.pkh 120.0 2005/05/31 02:27:54 appldev noship $ */

--
-- ---------------------------------------------------------------------------
-- |---------------------------< after_insert >------------------------------|
-- ---------------------------------------------------------------------------
--
Procedure after_insert
  (p_field_id                    in  number
  ,p_questionnaire_template_id   in  number
  ,p_name                        in  varchar2
  ,p_type                        in  varchar2
  ,p_html_text                   in  varchar2
  ,p_sql_required_flag           in  varchar2
  ,p_sql_text                    in  varchar2
  ,p_object_version_number       in  number
  ,p_effective_date              in  date
  );
--
end hr_qsf_rki;

 

/
