--------------------------------------------------------
--  DDL for Package BEN_ACT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACT_RKI" AUTHID CURRENT_USER as
/* $Header: beactrhi.pkh 120.0 2005/05/28 00:20:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_person_action_id               in number
  ,p_person_id                      in number
  ,p_ler_id                         in number
  ,p_benefit_action_id              in number
  ,p_action_status_cd               in varchar2
  ,p_chunk_number                   in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date);
end ben_act_rki;

 

/
