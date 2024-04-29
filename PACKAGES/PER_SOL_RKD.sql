--------------------------------------------------------
--  DDL for Package PER_SOL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOL_RKD" AUTHID CURRENT_USER as
/* $Header: pesolrhi.pkh 120.0 2005/05/31 21:22:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_solution_id                  in number
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
end per_sol_rkd;

 

/
