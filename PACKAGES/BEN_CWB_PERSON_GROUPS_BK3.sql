--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_GROUPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_GROUPS_BK3" AUTHID CURRENT_USER as
/* $Header: becpgapi.pkh 120.2.12000000.1 2007/01/19 02:23:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_group_budget_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_group_budget_b
  (p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_group_budget_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_group_budget_a
  (p_group_per_in_ler_id           in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_PERSON_GROUPS_BK3;

 

/
