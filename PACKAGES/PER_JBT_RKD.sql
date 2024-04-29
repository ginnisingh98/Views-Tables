--------------------------------------------------------
--  DDL for Package PER_JBT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JBT_RKD" AUTHID CURRENT_USER as
/* $Header: pejbtrhi.pkh 120.0 2005/05/31 10:35:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_job_id                       in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end per_jbt_rkd;

 

/
