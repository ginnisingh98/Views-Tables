--------------------------------------------------------
--  DDL for Package BEN_WV_PRTN_RSN_PTIP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WV_PRTN_RSN_PTIP_BK3" AUTHID CURRENT_USER as
/* $Header: bewptapi.pkh 120.0 2005/05/28 12:19:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WV_PRTN_RSN_PTIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WV_PRTN_RSN_PTIP_b
  (
   p_wv_prtn_rsn_ptip_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WV_PRTN_RSN_PTIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WV_PRTN_RSN_PTIP_a
  (
   p_wv_prtn_rsn_ptip_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_WV_PRTN_RSN_PTIP_bk3;

 

/
