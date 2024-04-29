--------------------------------------------------------
--  DDL for Package BEN_PRTT_RT_VAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_RT_VAL_BK3" AUTHID CURRENT_USER as
/* $Header: beprvapi.pkh 120.0.12000000.1 2007/01/19 22:14:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_prtt_rt_val_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prtt_rt_val_b
  (
   p_prtt_rt_val_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_prtt_rt_val_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prtt_rt_val_a
  (
   p_prtt_rt_val_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
--
end ben_prtt_rt_val_bk3;

 

/
