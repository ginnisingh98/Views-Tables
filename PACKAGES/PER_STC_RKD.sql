--------------------------------------------------------
--  DDL for Package PER_STC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STC_RKD" AUTHID CURRENT_USER as
/* $Header: pestcrhi.pkh 120.0 2005/05/31 21:58:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_component_name               in varchar2
  ,p_solution_type_name           in varchar2
  ,p_legislation_code             in varchar2
  ,p_api_name_o                   in varchar2
  ,p_parent_component_name_o      in varchar2
  ,p_updateable_o                 in varchar2
  ,p_extensible_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_stc_rkd;

 

/
