--------------------------------------------------------
--  DDL for Package PQH_BVR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BVR_RKI" AUTHID CURRENT_USER as
/* $Header: pqbvrrhi.pkh 120.0 2005/05/29 01:36:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_budget_version_id              in number
 ,p_budget_id                      in number
 ,p_version_number                 in number
 ,p_date_from                      in date
 ,p_date_to                        in date
 ,p_transfered_to_gl_flag          in varchar2
 ,p_gl_status                      in varchar2
 ,p_xfer_to_other_apps_cd          in varchar2
 ,p_object_version_number          in number
 ,p_budget_unit1_value             in number
 ,p_budget_unit2_value             in number
 ,p_budget_unit3_value             in number
 ,p_budget_unit1_available         in number
 ,p_budget_unit2_available         in number
 ,p_budget_unit3_available         in number
 ,p_effective_date                 in date
  );
end pqh_bvr_rki;

 

/
