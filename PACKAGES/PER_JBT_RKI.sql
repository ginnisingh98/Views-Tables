--------------------------------------------------------
--  DDL for Package PER_JBT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JBT_RKI" AUTHID CURRENT_USER as
/* $Header: pejbtrhi.pkh 120.0 2005/05/31 10:35:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_job_id                       in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  );
end per_jbt_rki;

 

/
