--------------------------------------------------------
--  DDL for Package BEN_PERSON_LIFE_EVENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_LIFE_EVENT_BK3" AUTHID CURRENT_USER as
/* $Header: bepilapi.pkh 120.0 2005/05/28 10:49:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Person_Life_Event_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Person_Life_Event_b
  (p_per_in_ler_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Person_Life_Event_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Person_Life_Event_a
  (p_per_in_ler_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_Person_Life_Event_bk3;

 

/
