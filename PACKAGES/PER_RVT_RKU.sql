--------------------------------------------------------
--  DDL for Package PER_RVT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RVT_RKU" AUTHID CURRENT_USER as
/* $Header: pervtrhi.pkh 120.1 2006/06/13 00:04:04 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_workbench_view_report_code   in varchar2
  ,p_language                     in varchar2
  ,p_workbench_view_report_name   in varchar2
  ,p_wb_view_report_description   in varchar2
  ,p_source_lang                  in varchar2
  ,p_workbench_view_report_name_o in varchar2
  ,p_wb_view_report_description_o in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_rvt_rku;

 

/
