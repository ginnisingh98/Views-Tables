--------------------------------------------------------
--  DDL for Package Body HR_QSF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSF_RKD" as
/* $Header: hrqsfrhi.pkb 115.11 2003/08/27 00:16:45 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsf_rkd.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
procedure after_delete
  (p_field_id                     in number
  ,p_questionnaire_template_id_o  in number
  ,p_name_o                       in varchar2
  ,p_type_o                       in varchar2
  ,p_html_text_o                  in varchar2
  ,p_sql_required_flag_o          in varchar2
  ,p_sql_text_o                   in varchar2
  ,p_object_version_number_o      in number
  ) is
begin
  hr_utility.set_location('Entering: HR_QSF_RKD.AFTER_DELETE', 10);
  hr_utility.set_location(' Leaving: HR_QSF_RKD.AFTER_DELETE', 20);
end after_delete;
end hr_qsf_rkd;

/
