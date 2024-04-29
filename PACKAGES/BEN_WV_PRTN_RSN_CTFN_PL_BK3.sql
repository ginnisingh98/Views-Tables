--------------------------------------------------------
--  DDL for Package BEN_WV_PRTN_RSN_CTFN_PL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WV_PRTN_RSN_CTFN_PL_BK3" AUTHID CURRENT_USER as
/* $Header: bewcnapi.pkh 120.0 2005/05/28 12:14:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WV_PRTN_RSN_CTFN_PL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WV_PRTN_RSN_CTFN_PL_b
  (
   p_wv_prtn_rsn_ctfn_pl_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WV_PRTN_RSN_CTFN_PL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WV_PRTN_RSN_CTFN_PL_a
  (
   p_wv_prtn_rsn_ctfn_pl_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_WV_PRTN_RSN_CTFN_PL_bk3;

 

/
