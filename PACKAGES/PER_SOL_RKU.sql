--------------------------------------------------------
--  DDL for Package PER_SOL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOL_RKU" AUTHID CURRENT_USER as
/* $Header: pesolrhi.pkh 120.0 2005/05/31 21:22:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_solution_name                in varchar2
  ,p_solution_id                  in number
  ,p_description                  in varchar2
  ,p_link_to_full_description     in varchar2
  ,p_solution_type_name           in varchar2
  ,p_vertical                     in varchar2
  ,p_legislation_code             in varchar2
  ,p_user_id                      in number
  ,p_object_version_number        in number
  ,p_solution_name_o              in varchar2
  ,p_description_o                in varchar2
  ,p_link_to_full_description_o   in varchar2
  ,p_solution_type_name_o         in varchar2
  ,p_vertical_o                   in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_user_id_o                    in number
  ,p_object_version_number_o      in number
  );
--
end per_sol_rku;

 

/
