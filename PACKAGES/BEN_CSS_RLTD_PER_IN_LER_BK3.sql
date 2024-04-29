--------------------------------------------------------
--  DDL for Package BEN_CSS_RLTD_PER_IN_LER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CSS_RLTD_PER_IN_LER_BK3" AUTHID CURRENT_USER as
/* $Header: becsrapi.pkh 120.0 2005/05/28 01:24:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Css_Rltd_Per_in_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Css_Rltd_Per_in_Ler_b
  (
   p_css_rltd_per_per_in_ler_id     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Css_Rltd_Per_in_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Css_Rltd_Per_in_Ler_a
  (
   p_css_rltd_per_per_in_ler_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Css_Rltd_Per_in_Ler_bk3;

 

/
