--------------------------------------------------------
--  DDL for Package BEN_LIFE_EVENT_ENROLL_RSN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_EVENT_ENROLL_RSN_BK3" AUTHID CURRENT_USER as
/* $Header: belenapi.pkh 120.1 2007/05/13 22:54:06 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Life_Event_Enroll_Rsn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Life_Event_Enroll_Rsn_b
  (
   p_lee_rsn_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Life_Event_Enroll_Rsn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Life_Event_Enroll_Rsn_a
  (
   p_lee_rsn_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Life_Event_Enroll_Rsn_bk3;

/
