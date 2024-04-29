--------------------------------------------------------
--  DDL for Package BEN_PERSON_CHANGE_CS_LER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_CHANGE_CS_LER_BK3" AUTHID CURRENT_USER as
/* $Header: bepslapi.pkh 120.0 2005/05/28 11:18:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Person_Change_Cs_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Person_Change_Cs_Ler_b
  (
   p_per_info_chg_cs_ler_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Person_Change_Cs_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Person_Change_Cs_Ler_a
  (
   p_per_info_chg_cs_ler_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Person_Change_Cs_Ler_bk3;

 

/
