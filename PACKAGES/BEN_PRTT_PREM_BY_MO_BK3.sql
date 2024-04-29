--------------------------------------------------------
--  DDL for Package BEN_PRTT_PREM_BY_MO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_PREM_BY_MO_BK3" AUTHID CURRENT_USER as
/* $Header: beprmapi.pkh 120.0 2005/05/28 11:09:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_PREM_BY_MO_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_PREM_BY_MO_b
  (
   p_prtt_prem_by_mo_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_PREM_BY_MO_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_PREM_BY_MO_a
  (
   p_prtt_prem_by_mo_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PRTT_PREM_BY_MO_bk3;

 

/
