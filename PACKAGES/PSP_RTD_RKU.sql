--------------------------------------------------------
--  DDL for Package PSP_RTD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_RTD_RKU" AUTHID CURRENT_USER as
/* $Header: PSPRDRHS.pls 120.0.12010000.3 2009/03/11 09:17:04 sabvenug ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_template_detail_id           in number
  ,p_template_id                  in number
  ,p_object_version_number        in number
  ,p_criteria_lookup_type         in varchar2
  ,p_criteria_lookup_code         in varchar2
  ,p_include_exclude_flag         in varchar2
  ,p_criteria_value1              in varchar2
  ,p_criteria_value2              in varchar2
  ,p_criteria_value3              in varchar2
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
end psp_rtd_rku;

/
