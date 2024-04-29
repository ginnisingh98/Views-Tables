--------------------------------------------------------
--  DDL for Package BEN_LER_RQRS_ENRT_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_RQRS_ENRT_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: belreapi.pkh 120.0 2005/05/28 03:34:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ler_rqrs_enrt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_rqrs_enrt_ctfn_b
  (
   p_ler_rqrs_enrt_ctfn_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ler_rqrs_enrt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_rqrs_enrt_ctfn_a
  (
   p_ler_rqrs_enrt_ctfn_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ler_rqrs_enrt_ctfn_bk3;

 

/
