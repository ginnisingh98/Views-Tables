--------------------------------------------------------
--  DDL for Package BEN_BNFT_RSTRN_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_RSTRN_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: bebrcapi.pkh 120.0 2005/05/28 00:49:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_BNFT_RSTRN_CTFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BNFT_RSTRN_CTFN_b
  (
   p_bnft_rstrn_ctfn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_BNFT_RSTRN_CTFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BNFT_RSTRN_CTFN_a
  (
   p_bnft_rstrn_ctfn_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_BNFT_RSTRN_CTFN_bk3;

 

/
