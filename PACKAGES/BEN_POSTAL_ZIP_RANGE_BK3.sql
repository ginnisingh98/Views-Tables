--------------------------------------------------------
--  DDL for Package BEN_POSTAL_ZIP_RANGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POSTAL_ZIP_RANGE_BK3" AUTHID CURRENT_USER as
/* $Header: berzrapi.pkh 120.0 2005/05/28 11:45:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_postal_zip_range_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_postal_zip_range_b
  (
   p_pstl_zip_rng_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_postal_zip_range_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_postal_zip_range_a
  (
   p_pstl_zip_rng_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_postal_zip_range_bk3;

 

/
