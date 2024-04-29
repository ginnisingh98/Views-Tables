--------------------------------------------------------
--  DDL for Package BEN_LIFE_EVENT_REASON_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_EVENT_REASON_BK3" AUTHID CURRENT_USER as
/* $Header: belerapi.pkh 120.1 2006/11/03 10:37:41 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Life_Event_Reason_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Life_Event_Reason_b
  (
   p_ler_id                         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Life_Event_Reason_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Life_Event_Reason_a
  (
   p_ler_id                         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Life_Event_Reason_bk3;

/
