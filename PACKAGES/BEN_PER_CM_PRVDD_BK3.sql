--------------------------------------------------------
--  DDL for Package BEN_PER_CM_PRVDD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PER_CM_PRVDD_BK3" AUTHID CURRENT_USER as
/* $Header: bepcdapi.pkh 120.0 2005/05/28 10:09:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PER_CM_PRVDD_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM_PRVDD_b
  (p_per_cm_prvdd_id                in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PER_CM_PRVDD_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM_PRVDD_a
  (p_per_cm_prvdd_id             in number
  ,p_effective_start_date        in date
  ,p_effective_end_date          in date
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
end ben_PER_CM_PRVDD_bk3;

 

/
