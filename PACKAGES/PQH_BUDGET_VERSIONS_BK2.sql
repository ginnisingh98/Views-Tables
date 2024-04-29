--------------------------------------------------------
--  DDL for Package PQH_BUDGET_VERSIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_VERSIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqbvrapi.pkh 120.1 2005/10/02 02:26:21 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_version_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_version_b
  (
   p_budget_version_id              in  number
  ,p_budget_id                      in  number
  ,p_version_number                 in  number
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_transfered_to_gl_flag          in  varchar2
  ,p_gl_status                      in  varchar2
  ,p_xfer_to_other_apps_cd          in  varchar2
  ,p_object_version_number          in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_budget_unit1_available         in  number
  ,p_budget_unit2_available         in  number
  ,p_budget_unit3_available         in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_version_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_version_a
  (
   p_budget_version_id              in  number
  ,p_budget_id                      in  number
  ,p_version_number                 in  number
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_transfered_to_gl_flag          in  varchar2
  ,p_gl_status                      in  varchar2
  ,p_xfer_to_other_apps_cd          in  varchar2
  ,p_object_version_number          in  number
  ,p_budget_unit1_value             in  number
  ,p_budget_unit2_value             in  number
  ,p_budget_unit3_value             in  number
  ,p_budget_unit1_available         in  number
  ,p_budget_unit2_available         in  number
  ,p_budget_unit3_available         in  number
  ,p_effective_date                 in  date
  );
--
end pqh_budget_versions_bk2;

 

/
