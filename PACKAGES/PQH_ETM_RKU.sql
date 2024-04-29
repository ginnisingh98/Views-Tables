--------------------------------------------------------
--  DDL for Package PQH_ETM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ETM_RKU" AUTHID CURRENT_USER as
/* $Header: pqetmrhi.pkh 120.0 2005/05/29 01:52:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_ent_minutes_id               in number
  ,p_description                  in varchar2
  ,p_ent_minutes_cd               in varchar2
  ,p_tariff_group_cd              in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_description_o                in varchar2
  ,p_ent_minutes_cd_o             in varchar2
  ,p_tariff_group_cd_o            in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end pqh_etm_rku;

 

/
