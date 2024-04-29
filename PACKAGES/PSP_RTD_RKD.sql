--------------------------------------------------------
--  DDL for Package PSP_RTD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_RTD_RKD" AUTHID CURRENT_USER as
/* $Header: PSPRDRHS.pls 120.0.12010000.3 2009/03/11 09:17:04 sabvenug ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_template_detail_id           in number
  ,p_template_id_o                in number
  ,p_object_version_number_o      in number
  ,p_criteria_lookup_type_o       in varchar2
  ,p_criteria_lookup_code_o       in varchar2
  ,p_include_exclude_flag_o       in varchar2
  ,p_criteria_value1_o            in varchar2
  ,p_criteria_value2_o            in varchar2
  ,p_criteria_value3_o            in varchar2
  );
--
end psp_rtd_rkd;

/
