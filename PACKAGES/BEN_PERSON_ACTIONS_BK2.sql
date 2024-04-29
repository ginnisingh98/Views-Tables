--------------------------------------------------------
--  DDL for Package BEN_PERSON_ACTIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_ACTIONS_BK2" AUTHID CURRENT_USER as
/* $Header: beactapi.pkh 120.0 2005/05/28 00:20:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person_actions_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_actions_b
  (
   p_person_action_id               in  number
  ,p_person_id                      in  number
  ,p_ler_id                         in  number
  ,p_benefit_action_id              in  number
  ,p_action_status_cd               in  varchar2
  ,p_chunk_number                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person_actions_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_actions_a
  (
   p_person_action_id               in  number
  ,p_person_id                      in  number
  ,p_ler_id                         in  number
  ,p_benefit_action_id              in  number
  ,p_action_status_cd               in  varchar2
  ,p_chunk_number                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_person_actions_bk2;

 

/
