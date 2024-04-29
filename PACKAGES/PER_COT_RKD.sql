--------------------------------------------------------
--  DDL for Package PER_COT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_COT_RKD" AUTHID CURRENT_USER as
/* $Header: pecotrhi.pkh 120.0 2005/05/31 07:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_outcome_id                   in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  ,p_assessment_criteria_o        in varchar2
  );
--
end per_cot_rkd;

 

/
