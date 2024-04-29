--------------------------------------------------------
--  DDL for Package BEN_PRTT_REIMBMT_RQST_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_REIMBMT_RQST_BK3" AUTHID CURRENT_USER as
/* $Header: beprcapi.pkh 120.1 2005/12/19 12:16:54 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_REIMBMT_RQST_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_REIMBMT_RQST_b
  (
   p_prtt_reimbmt_rqst_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_REIMBMT_RQST_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_REIMBMT_RQST_a
  (
   p_prtt_reimbmt_rqst_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PRTT_REIMBMT_RQST_bk3;

 

/
