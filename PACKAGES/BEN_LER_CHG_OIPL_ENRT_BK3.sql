--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_OIPL_ENRT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_OIPL_ENRT_BK3" AUTHID CURRENT_USER as
/* $Header: belopapi.pkh 120.0 2005/05/28 03:27:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ler_Chg_Oipl_Enrt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Chg_Oipl_Enrt_b
  (
   p_ler_chg_oipl_enrt_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ler_Chg_Oipl_Enrt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Chg_Oipl_Enrt_a
  (
   p_ler_chg_oipl_enrt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Ler_Chg_Oipl_Enrt_bk3;

 

/
