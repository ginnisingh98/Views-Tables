--------------------------------------------------------
--  DDL for Package HR_QSN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QSN_RKD" AUTHID CURRENT_USER as
/* $Header: hrqsnrhi.pkh 120.1.12010000.3 2008/11/05 10:22:27 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_questionnaire_template_id    in number
  ,p_name_o                       in varchar2
 -- ,p_text_o                       in CLOB
  ,p_available_flag_o             in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end hr_qsn_rkd;

/
