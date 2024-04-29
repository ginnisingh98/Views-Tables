--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_ACTIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_ACTIONS_BK3" AUTHID CURRENT_USER as
/* $Header: bebftapi.pkh 120.0 2005/05/28 00:40:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_benefit_actions_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_benefit_actions_b
  (p_benefit_action_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_benefit_actions_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_benefit_actions_a
  (p_benefit_action_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_benefit_actions_bk3;

 

/
