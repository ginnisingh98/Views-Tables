--------------------------------------------------------
--  DDL for Package BEN_SVC_AREA_PSTL_ZIP_RNG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SVC_AREA_PSTL_ZIP_RNG_BK3" AUTHID CURRENT_USER as
/* $Header: besazapi.pkh 120.0 2005/05/28 11:48:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_SVC_AREA_PSTL_ZIP_RNG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SVC_AREA_PSTL_ZIP_RNG_b
  (
   p_svc_area_pstl_zip_rng_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_SVC_AREA_PSTL_ZIP_RNG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SVC_AREA_PSTL_ZIP_RNG_a
  (
   p_svc_area_pstl_zip_rng_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_SVC_AREA_PSTL_ZIP_RNG_bk3;

 

/
