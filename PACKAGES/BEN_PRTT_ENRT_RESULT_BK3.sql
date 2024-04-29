--------------------------------------------------------
--  DDL for Package BEN_PRTT_ENRT_RESULT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_ENRT_RESULT_BK3" AUTHID CURRENT_USER as
/* $Header: bepenapi.pkh 120.2.12010000.1 2008/07/29 12:46:49 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_ENRT_RESULT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_RESULT_b
  (
   p_prtt_enrt_rslt_id           in  number
  ,p_object_version_number       in  number
  ,p_effective_date              in  date
  ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_ENRT_RESULT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_RESULT_a
  (
   p_prtt_enrt_rslt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in varchar2
  );
--
end ben_PRTT_ENRT_RESULT_bk3;

/
