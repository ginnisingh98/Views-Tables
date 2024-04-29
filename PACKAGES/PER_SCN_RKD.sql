--------------------------------------------------------
--  DDL for Package PER_SCN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SCN_RKD" AUTHID CURRENT_USER as
/* $Header: pescnrhi.pkh 120.0 2005/05/31 20:46:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_solution_id                  in number
  ,p_component_name               in varchar2
  ,p_solution_type_name           in varchar2
  ,p_name_o                       in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_scn_rkd;

 

/