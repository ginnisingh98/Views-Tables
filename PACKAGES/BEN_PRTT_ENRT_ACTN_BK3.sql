--------------------------------------------------------
--  DDL for Package BEN_PRTT_ENRT_ACTN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ENRT_ACTN_BK3" AUTHID CURRENT_USER as
/* $Header: bepeaapi.pkh 120.0.12000000.1 2007/01/19 20:59:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_ENRT_ACTN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_ACTN_b
  (
   p_prtt_enrt_actn_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_ENRT_ACTN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_ACTN_a
  (p_prtt_enrt_actn_id              in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
end ben_PRTT_ENRT_ACTN_bk3;

 

/
