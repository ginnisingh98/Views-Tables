--------------------------------------------------------
--  DDL for Package BEN_CVG_AMT_CALC_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CVG_AMT_CALC_BK3" AUTHID CURRENT_USER as
/* $Header: beccmapi.pkh 120.0 2005/05/28 00:57:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Cvg_Amt_Calc_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Cvg_Amt_Calc_b
  (p_cvg_amt_calc_mthd_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Cvg_Amt_Calc_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Cvg_Amt_Calc_a
  (p_cvg_amt_calc_mthd_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_Cvg_Amt_Calc_bk3;

 

/
