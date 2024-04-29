--------------------------------------------------------
--  DDL for Package BEN_ENRT_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: beecfapi.pkh 120.0 2005/05/28 01:49:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Enrt_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrt_Ctfn_b
  (
   p_enrt_ctfn_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Enrt_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrt_Ctfn_a
  (
   p_enrt_ctfn_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Enrt_Ctfn_bk3;

 

/
