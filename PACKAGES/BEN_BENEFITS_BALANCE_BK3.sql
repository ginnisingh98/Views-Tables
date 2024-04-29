--------------------------------------------------------
--  DDL for Package BEN_BENEFITS_BALANCE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFITS_BALANCE_BK3" AUTHID CURRENT_USER as
/* $Header: bebnbapi.pkh 120.0 2005/05/28 00:44:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_benefits_balance_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_benefits_balance_b
  (
   p_bnfts_bal_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_benefits_balance_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_benefits_balance_a
  (
   p_bnfts_bal_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_benefits_balance_bk3;

 

/
