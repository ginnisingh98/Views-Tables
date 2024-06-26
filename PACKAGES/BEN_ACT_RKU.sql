--------------------------------------------------------
--  DDL for Package BEN_ACT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACT_RKU" AUTHID CURRENT_USER as
/* $Header: beactrhi.pkh 120.0 2005/05/28 00:20:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_person_action_id               in number
  ,p_person_id                      in number
  ,p_ler_id                         in number
  ,p_benefit_action_id              in number
  ,p_action_status_cd               in varchar2
  ,p_chunk_number                   in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_person_id_o                    in number
  ,p_ler_id_o                       in number
  ,p_benefit_action_id_o            in number
  ,p_action_status_cd_o             in varchar2
  ,p_chunk_number_o                 in number
  ,p_object_version_number_o        in number);
--
end ben_act_rku;

 

/
