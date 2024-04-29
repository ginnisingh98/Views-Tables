--------------------------------------------------------
--  DDL for Package PQH_LVL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_LVL_RKU" AUTHID CURRENT_USER as
/* $Header: pqlvlrhi.pkh 120.0 2005/05/29 02:12:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_wrkplc_vldtn_lvlnum_id       in number
  ,p_wrkplc_vldtn_ver_id          in number
  ,p_level_number_id              in varchar2
  ,p_level_code_id                in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_wrkplc_vldtn_ver_id_o        in number
  ,p_level_number_id_o            in varchar2
  ,p_level_code_id_o              in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end pqh_lvl_rku;

 

/
