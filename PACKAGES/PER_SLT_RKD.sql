--------------------------------------------------------
--  DDL for Package PER_SLT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SLT_RKD" AUTHID CURRENT_USER as
/* $Header: pesltrhi.pkh 120.0 2005/05/31 21:17:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_solution_type_name           in varchar2
  ,p_solution_category_o          in varchar2
  ,p_updateable_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_slt_rkd;

 

/
