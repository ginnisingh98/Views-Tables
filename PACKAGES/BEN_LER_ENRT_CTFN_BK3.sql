--------------------------------------------------------
--  DDL for Package BEN_LER_ENRT_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_ENRT_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: belncapi.pkh 120.0 2005/05/28 03:25:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ler_enrt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_enrt_ctfn_b
  (
   p_ler_enrt_ctfn_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ler_enrt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ler_enrt_ctfn_a
  (
   p_ler_enrt_ctfn_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ler_enrt_ctfn_bk3;

 

/
