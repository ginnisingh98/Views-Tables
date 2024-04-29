--------------------------------------------------------
--  DDL for Package BEN_PAIRED_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAIRED_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beprdapi.pkh 120.0 2005/05/28 11:06:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PAIRED_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PAIRED_RATE_b
  (
   p_paird_rt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PAIRED_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PAIRED_RATE_a
  (
   p_paird_rt_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PAIRED_RATE_bk3;

 

/
