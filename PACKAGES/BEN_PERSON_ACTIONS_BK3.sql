--------------------------------------------------------
--  DDL for Package BEN_PERSON_ACTIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_ACTIONS_BK3" AUTHID CURRENT_USER as
/* $Header: beactapi.pkh 120.0 2005/05/28 00:20:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person_actions_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_actions_b
  (
   p_person_action_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person_actions_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_actions_a
  (
   p_person_action_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_person_actions_bk3;

 

/
