--------------------------------------------------------
--  DDL for Package BEN_PER_CM_TRGR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PER_CM_TRGR_BK3" AUTHID CURRENT_USER as
/* $Header: bepcrapi.pkh 120.0 2005/05/28 10:14:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PER_CM_TRGR_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM_TRGR_b
  (p_per_cm_trgr_id              in number
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PER_CM_TRGR_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM_TRGR_a
  (p_per_cm_trgr_id              in number
  ,p_effective_start_date        in date
  ,p_effective_end_date          in date
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
end ben_PER_CM_TRGR_bk3;

 

/
