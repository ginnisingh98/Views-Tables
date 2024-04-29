--------------------------------------------------------
--  DDL for Package BEN_NO_OTHR_CVG_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_NO_OTHR_CVG_RT_BK3" AUTHID CURRENT_USER as
/* $Header: benocapi.pkh 120.0 2005/05/28 09:10:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_NO_OTHR_CVG_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_NO_OTHR_CVG_RT_b
  (
   p_no_othr_cvg_rt_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_NO_OTHR_CVG_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_NO_OTHR_CVG_RT_a
  (
   p_no_othr_cvg_rt_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_NO_OTHR_CVG_RT_bk3;

 

/
