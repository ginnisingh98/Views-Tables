--------------------------------------------------------
--  DDL for Package BEN_PREM_CSTG_BY_SGMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREM_CSTG_BY_SGMT_BK3" AUTHID CURRENT_USER as
/* $Header: becbsapi.pkh 120.0 2005/05/28 00:56:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PREM_CSTG_BY_SGMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PREM_CSTG_BY_SGMT_b
  (
   p_prem_cstg_by_sgmt_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PREM_CSTG_BY_SGMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PREM_CSTG_BY_SGMT_a
  (
   p_prem_cstg_by_sgmt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PREM_CSTG_BY_SGMT_bk3;

 

/
