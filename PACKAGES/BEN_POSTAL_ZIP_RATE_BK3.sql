--------------------------------------------------------
--  DDL for Package BEN_POSTAL_ZIP_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POSTAL_ZIP_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bepzrapi.pkh 120.0 2005/05/28 11:30:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POSTAL_ZIP_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POSTAL_ZIP_RATE_b
  (
   p_pstl_zip_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POSTAL_ZIP_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POSTAL_ZIP_RATE_a
  (
   p_pstl_zip_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_POSTAL_ZIP_RATE_bk3;

 

/
