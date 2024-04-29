--------------------------------------------------------
--  DDL for Package BEN_ENRT_BNFT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_BNFT_BK3" AUTHID CURRENT_USER as
/* $Header: beenbapi.pkh 120.0 2005/05/28 02:27:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_bnft_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_bnft_b
  (
   p_enrt_bnft_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_enrt_bnft_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_bnft_a
  (
   p_enrt_bnft_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_enrt_bnft_bk3;

 

/
