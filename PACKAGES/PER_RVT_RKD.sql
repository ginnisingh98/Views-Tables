--------------------------------------------------------
--  DDL for Package PER_RVT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RVT_RKD" AUTHID CURRENT_USER as
/* $Header: pervtrhi.pkh 120.1 2006/06/13 00:04:04 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_workbench_view_report_code   in varchar2
  ,p_language                     in varchar2
  ,p_workbench_view_report_name_o in varchar2
  ,p_wb_view_report_description_o in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_rvt_rkd;

 

/
