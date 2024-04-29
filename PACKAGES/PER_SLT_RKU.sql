--------------------------------------------------------
--  DDL for Package PER_SLT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SLT_RKU" AUTHID CURRENT_USER as
/* $Header: pesltrhi.pkh 120.0 2005/05/31 21:17:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_solution_type_name           in varchar2
  ,p_solution_category            in varchar2
  ,p_updateable                   in varchar2
  ,p_object_version_number        in number
  ,p_solution_category_o          in varchar2
  ,p_updateable_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_slt_rku;

 

/
