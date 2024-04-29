--------------------------------------------------------
--  DDL for Package PER_CPL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPL_RKI" AUTHID CURRENT_USER as
/* $Header: pecplrhi.pkh 120.0 2005/05/31 07:12:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_competence_id                in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  ,p_competence_alias             in varchar2
  ,p_behavioural_indicator        in varchar2
  ,p_description                  in varchar2
  );
end per_cpl_rki;

 

/
