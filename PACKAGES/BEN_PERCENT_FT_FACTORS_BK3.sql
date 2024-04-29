--------------------------------------------------------
--  DDL for Package BEN_PERCENT_FT_FACTORS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERCENT_FT_FACTORS_BK3" AUTHID CURRENT_USER as
/* $Header: bepffapi.pkh 120.0 2005/05/28 10:42:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_percent_ft_factors_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_percent_ft_factors_b
  (
   p_pct_fl_tm_fctr_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_percent_ft_factors_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_percent_ft_factors_a
  (
   p_pct_fl_tm_fctr_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_percent_ft_factors_bk3;

 

/
