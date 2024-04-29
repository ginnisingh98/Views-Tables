--------------------------------------------------------
--  DDL for Package BEN_ENRT_PERD_FOR_PL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_PERD_FOR_PL_BK3" AUTHID CURRENT_USER as
/* $Header: beerpapi.pkh 120.0 2005/05/28 02:53:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_perd_for_pl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_perd_for_pl_b
  (
   p_enrt_perd_for_pl_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_perd_for_pl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_perd_for_pl_a
  (
   p_enrt_perd_for_pl_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_enrt_perd_for_pl_bk3;

 

/
