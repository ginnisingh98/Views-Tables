--------------------------------------------------------
--  DDL for Package PER_STL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STL_RKD" AUTHID CURRENT_USER as
/* $Header: pestlrhi.pkh 120.1 2006/06/07 23:05:20 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_setup_task_code              in varchar2
  ,p_language_o                   in varchar2
  ,p_source_lang_o                in varchar2
  ,p_setup_task_name_o            in varchar2
  ,p_setup_task_description_o     in varchar2
  );
--
end per_stl_rkd;

 

/
