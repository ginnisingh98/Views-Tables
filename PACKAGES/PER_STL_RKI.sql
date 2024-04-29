--------------------------------------------------------
--  DDL for Package PER_STL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STL_RKI" AUTHID CURRENT_USER as
/* $Header: pestlrhi.pkh 120.1 2006/06/07 23:05:20 ndorai noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_setup_task_code              in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_setup_task_name              in varchar2
  ,p_setup_task_description       in varchar2
  );
end per_stl_rki;

 

/
