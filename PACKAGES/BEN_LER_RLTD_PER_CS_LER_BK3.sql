--------------------------------------------------------
--  DDL for Package BEN_LER_RLTD_PER_CS_LER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_RLTD_PER_CS_LER_BK3" AUTHID CURRENT_USER as
/* $Header: belrcapi.pkh 120.0 2005/05/28 03:33:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ler_Rltd_Per_Cs_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Rltd_Per_Cs_Ler_b
  (
   p_ler_rltd_per_cs_ler_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Ler_Rltd_Per_Cs_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Rltd_Per_Cs_Ler_a
  (
   p_ler_rltd_per_cs_ler_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Ler_Rltd_Per_Cs_Ler_bk3;

 

/
