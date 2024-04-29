--------------------------------------------------------
--  DDL for Package BEN_PRTT_RMT_APRVD_PYMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_RMT_APRVD_PYMT_BK3" AUTHID CURRENT_USER as
/* $Header: bepryapi.pkh 120.1 2005/12/19 12:19:35 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_prtt_rmt_aprvd_pymt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prtt_rmt_aprvd_pymt_b
  (
   p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_prtt_rmt_aprvd_pymt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prtt_rmt_aprvd_pymt_a
  (
   p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_prtt_rmt_aprvd_pymt_bk3;

 

/
