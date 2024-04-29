--------------------------------------------------------
--  DDL for Package PER_STL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STL_RKU" AUTHID CURRENT_USER as
/* $Header: pestlrhi.pkh 120.1 2006/06/07 23:05:20 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_setup_task_code              in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_setup_task_name              in varchar2
  ,p_setup_task_description       in varchar2
  ,p_language_o                   in varchar2
  ,p_source_lang_o                in varchar2
  ,p_setup_task_name_o            in varchar2
  ,p_setup_task_description_o     in varchar2
  );
--
end per_stl_rku;

 

/
