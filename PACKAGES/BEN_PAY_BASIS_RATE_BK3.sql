--------------------------------------------------------
--  DDL for Package BEN_PAY_BASIS_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAY_BASIS_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bepbrapi.pkh 120.0 2005/05/28 10:08:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PAY_BASIS_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PAY_BASIS_RATE_b
  (
   p_py_bss_rt_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PAY_BASIS_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PAY_BASIS_RATE_a
  (
   p_py_bss_rt_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PAY_BASIS_RATE_bk3;

 

/
