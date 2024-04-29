--------------------------------------------------------
--  DDL for Package PQP_FFA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FFA_RKI" AUTHID CURRENT_USER as
/* $Header: pqffarhi.pkh 120.0 2006/04/26 23:47 pbhure noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_flxdu_func_attribute_id      in number
  ,p_flxdu_func_name              in varchar2
  ,p_flxdu_func_source_type       in varchar2
  ,p_flxdu_func_integrator_code   in varchar2
  ,p_flxdu_func_xml_data          in varchar2
  ,p_legislation_code             in varchar2
  ,p_description                  in varchar2
  ,p_object_version_number        in number
  );
end pqp_ffa_rki;

 

/
