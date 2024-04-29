--------------------------------------------------------
--  DDL for Package BEN_ENRT_RT_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_RT_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: beercapi.pkh 120.0 2005/05/28 02:50:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_rt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_rt_ctfn_b
  (
   p_enrt_rt_ctfn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_rt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_rt_ctfn_a
  (
   p_enrt_rt_ctfn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_enrt_rt_ctfn_bk3;

 

/
