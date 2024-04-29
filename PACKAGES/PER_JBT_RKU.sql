--------------------------------------------------------
--  DDL for Package PER_JBT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JBT_RKU" AUTHID CURRENT_USER as
/* $Header: pejbtrhi.pkh 120.0 2005/05/31 10:35:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_job_id                       in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end per_jbt_rku;

 

/
