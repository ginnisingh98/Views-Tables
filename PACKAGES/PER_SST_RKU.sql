--------------------------------------------------------
--  DDL for Package PER_SST_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SST_RKU" AUTHID CURRENT_USER as
/* $Header: pesstrhi.pkh 120.1 2006/06/07 23:04:52 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_setup_sub_task_code          in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_setup_sub_task_name          in varchar2
  ,p_setup_sub_task_description   in varchar2
  ,p_language_o                   in varchar2
  ,p_source_lang_o                in varchar2
  ,p_setup_sub_task_name_o        in varchar2
  ,p_setup_sub_task_description_o in varchar2
  );
--
end per_sst_rku;

 

/
