--------------------------------------------------------
--  DDL for Package PER_SCN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SCN_RKI" AUTHID CURRENT_USER as
/* $Header: pescnrhi.pkh 120.0 2005/05/31 20:46:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_solution_id                  in number
  ,p_component_name               in varchar2
  ,p_solution_type_name           in varchar2
  ,p_name                         in varchar2
  ,p_object_version_number        in number
  );
end per_scn_rki;

 

/
