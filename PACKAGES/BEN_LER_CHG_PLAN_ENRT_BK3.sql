--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_PLAN_ENRT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_PLAN_ENRT_BK3" AUTHID CURRENT_USER as
/* $Header: belprapi.pkh 120.0 2005/05/28 03:32:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ler_chg_plan_enrt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_chg_plan_enrt_b
  (
   p_ler_chg_plip_enrt_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ler_chg_plan_enrt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_chg_plan_enrt_a
  (
   p_ler_chg_plip_enrt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ler_chg_plan_enrt_bk3;

 

/