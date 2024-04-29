--------------------------------------------------------
--  DDL for Package PER_STC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STC_RKI" AUTHID CURRENT_USER as
/* $Header: pestcrhi.pkh 120.0 2005/05/31 21:58:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_component_name               in varchar2
  ,p_solution_type_name           in varchar2
  ,p_legislation_code             in varchar2
  ,p_api_name                     in varchar2
  ,p_parent_component_name        in varchar2
  ,p_updateable                   in varchar2
  ,p_extensible                   in varchar2
  ,p_object_version_number        in number
  );
end per_stc_rki;

 

/
