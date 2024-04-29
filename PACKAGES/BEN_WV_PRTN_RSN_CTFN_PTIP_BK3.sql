--------------------------------------------------------
--  DDL for Package BEN_WV_PRTN_RSN_CTFN_PTIP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WV_PRTN_RSN_CTFN_PTIP_BK3" AUTHID CURRENT_USER as
/* $Header: bewctapi.pkh 120.0 2005/05/28 12:16:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_wv_prtn_rsn_ctfn_ptip_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wv_prtn_rsn_ctfn_ptip_b
  (
   p_wv_prtn_rsn_ctfn_ptip_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_wv_prtn_rsn_ctfn_ptip_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_wv_prtn_rsn_ctfn_ptip_a
  (
   p_wv_prtn_rsn_ctfn_ptip_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_wv_prtn_rsn_ctfn_ptip_bk3;

 

/
