--------------------------------------------------------
--  DDL for Package HR_AMM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AMM_RKI" AUTHID CURRENT_USER as
/* $Header: hrammrhi.pkh 120.0 2005/05/30 22:40:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_authoria_mapping_id          in number
  ,p_pl_id                        in number
  ,p_plip_id                      in number
  ,p_open_enrollment_flag         in varchar2
  ,p_target_page                  in varchar2
  ,p_object_version_number        in number
  );
end hr_amm_rki;

 

/
