--------------------------------------------------------
--  DDL for Package BEN_RLTD_PER_CHG_CS_LER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RLTD_PER_CHG_CS_LER_BK3" AUTHID CURRENT_USER as
/* $Header: berclapi.pkh 120.0 2005/05/28 11:35:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Rltd_Per_Chg_Cs_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Rltd_Per_Chg_Cs_Ler_b
  (
   p_rltd_per_chg_cs_ler_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Rltd_Per_Chg_Cs_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Rltd_Per_Chg_Cs_Ler_a
  (
   p_rltd_per_chg_cs_ler_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Rltd_Per_Chg_Cs_Ler_bk3;

 

/
