--------------------------------------------------------
--  DDL for Package PER_SBT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SBT_RKU" AUTHID CURRENT_USER as
/* $Header: pesbtrhi.pkh 120.0 2005/05/31 20:43:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_subjects_taken_id            in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_grade_attained               in varchar2
  ,p_source_lang_o                in varchar2
  ,p_grade_attained_o             in varchar2
  );
--
end per_sbt_rku;

 

/
