--------------------------------------------------------
--  DDL for Package BEN_PRV_CTFN_PRVDD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRV_CTFN_PRVDD_BK3" AUTHID CURRENT_USER as
/* $Header: bervcapi.pkh 120.0 2005/05/28 11:44:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRV_CTFN_PRVDD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRV_CTFN_PRVDD_b
  (
   p_prtt_rt_val_ctfn_prvdd_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRV_CTFN_PRVDD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRV_CTFN_PRVDD_a
  (
   p_prtt_rt_val_ctfn_prvdd_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_PRV_CTFN_PRVDD_bk3;

 

/
