--------------------------------------------------------
--  DDL for Package BEN_PARTICIPATION_ELIG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PARTICIPATION_ELIG_BK3" AUTHID CURRENT_USER as
/* $Header: beepaapi.pkh 120.0 2005/05/28 02:35:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_Participation_Elig_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Participation_Elig_b
  (p_prtn_elig_id                in  number
  ,p_object_version_number       in  number
  ,p_effective_date              in  date
  ,p_datetrack_mode              in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_Participation_Elig_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Participation_Elig_a
  (p_prtn_elig_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_Participation_Elig_bk3;

 

/
