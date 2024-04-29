--------------------------------------------------------
--  DDL for Package HR_AMM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AMM_RKU" AUTHID CURRENT_USER as
/* $Header: hrammrhi.pkh 120.0 2005/05/30 22:40:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_authoria_mapping_id          in number
  ,p_pl_id                        in number
  ,p_plip_id                      in number
  ,p_open_enrollment_flag         in varchar2
  ,p_target_page                  in varchar2
  ,p_object_version_number        in number
  ,p_pl_id_o                      in number
  ,p_plip_id_o                    in number
  ,p_open_enrollment_flag_o       in varchar2
  ,p_target_page_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_amm_rku;

 

/
