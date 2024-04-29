--------------------------------------------------------
--  DDL for Package BEN_ELIG_PER_WV_PL_TYP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PER_WV_PL_TYP_BK3" AUTHID CURRENT_USER as
/* $Header: beetwapi.pkh 120.0 2005/05/28 03:03:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_elig_per_wv_pl_typ_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_per_wv_pl_typ_b
  (
   p_elig_per_wv_pl_typ_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_elig_per_wv_pl_typ_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_per_wv_pl_typ_a
  (
   p_elig_per_wv_pl_typ_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_elig_per_wv_pl_typ_bk3;

 

/
