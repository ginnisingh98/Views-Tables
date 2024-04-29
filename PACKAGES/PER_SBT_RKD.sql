--------------------------------------------------------
--  DDL for Package PER_SBT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SBT_RKD" AUTHID CURRENT_USER as
/* $Header: pesbtrhi.pkh 120.0 2005/05/31 20:43:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_subjects_taken_id            in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_grade_attained_o             in varchar2
  );
--
end per_sbt_rkd;

 

/
