--------------------------------------------------------
--  DDL for Package BEN_PRTT_PREM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_PREM_BK3" AUTHID CURRENT_USER as
/* $Header: beppeapi.pkh 120.0.12000000.1 2007/01/19 21:44:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_PREM_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_PREM_b
  (
   p_prtt_prem_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_PREM_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_PREM_a
  (
   p_prtt_prem_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PRTT_PREM_bk3;

 

/
