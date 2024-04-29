--------------------------------------------------------
--  DDL for Package BEN_PRTL_MO_RT_PRTN_VAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTL_MO_RT_PRTN_VAL_BK3" AUTHID CURRENT_USER as
/* $Header: beppvapi.pkh 120.0 2005/05/28 11:01:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Prtl_Mo_Rt_Prtn_Val_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Prtl_Mo_Rt_Prtn_Val_b
  (
   p_prtl_mo_rt_prtn_val_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Prtl_Mo_Rt_Prtn_Val_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Prtl_Mo_Rt_Prtn_Val_a
  (
   p_prtl_mo_rt_prtn_val_id         in  number
  ,p_effective_end_date             in  date
  ,p_effective_start_date           in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Prtl_Mo_Rt_Prtn_Val_bk3;

 

/
