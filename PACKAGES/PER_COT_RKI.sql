--------------------------------------------------------
--  DDL for Package PER_COT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_COT_RKI" AUTHID CURRENT_USER as
/* $Header: pecotrhi.pkh 120.0 2005/05/31 07:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_outcome_id                   in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  ,p_assessment_criteria          in varchar2
  );
end per_cot_rki;

 

/
