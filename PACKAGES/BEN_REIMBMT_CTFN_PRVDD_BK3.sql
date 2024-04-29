--------------------------------------------------------
--  DDL for Package BEN_REIMBMT_CTFN_PRVDD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REIMBMT_CTFN_PRVDD_BK3" AUTHID CURRENT_USER as
/* $Header: bepqcapi.pkh 120.0 2005/05/28 11:02:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_reimbmt_ctfn_prvdd_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reimbmt_ctfn_prvdd_b
  (
   p_prtt_rmt_rqst_ctfn_prvdd_id    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_reimbmt_ctfn_prvdd_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reimbmt_ctfn_prvdd_a
  (
   p_prtt_rmt_rqst_ctfn_prvdd_id    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_reimbmt_ctfn_prvdd_bk3;

 

/
