--------------------------------------------------------
--  DDL for Package Body HR_QSN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSN_RKD" as
/* $Header: hrqsnrhi.pkb 120.4.12010000.3 2008/11/05 09:57:56 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)  := '  hr_qsn_rkd.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
procedure after_delete
  (p_questionnaire_template_id    in number
  ,p_name_o                       in varchar2
--  ,p_text_o                       in CLOB
  ,p_available_flag_o             in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  ) is
begin
  hr_utility.set_location('Entering: HR_QSN_RKD.AFTER_DELETE', 10);
  hr_utility.set_location(' Leaving: HR_QSN_RKD.AFTER_DELETE', 20);
end after_delete;
end hr_qsn_rkd;

/
