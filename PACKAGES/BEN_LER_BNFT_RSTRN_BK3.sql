--------------------------------------------------------
--  DDL for Package BEN_LER_BNFT_RSTRN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_BNFT_RSTRN_BK3" AUTHID CURRENT_USER as
/* $Header: belbrapi.pkh 120.0 2005/05/28 03:16:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LER_BNFT_RSTRN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LER_BNFT_RSTRN_b
  (
   p_ler_bnft_rstrn_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LER_BNFT_RSTRN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LER_BNFT_RSTRN_a
  (
   p_ler_bnft_rstrn_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_LER_BNFT_RSTRN_bk3;

 

/
