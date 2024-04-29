--------------------------------------------------------
--  DDL for Package BEN_PL_R_OIPL_PREM_BY_MO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_R_OIPL_PREM_BY_MO_BK3" AUTHID CURRENT_USER as
/* $Header: bepbmapi.pkh 120.0 2005/05/28 10:05:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PL_R_OIPL_PREM_BY_MO_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PL_R_OIPL_PREM_BY_MO_b
  (
   p_pl_r_oipl_prem_by_mo_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PL_R_OIPL_PREM_BY_MO_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PL_R_OIPL_PREM_BY_MO_a
  (
   p_pl_r_oipl_prem_by_mo_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PL_R_OIPL_PREM_BY_MO_bk3;

 

/
