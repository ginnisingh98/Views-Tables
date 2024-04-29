--------------------------------------------------------
--  DDL for Package BEN_PERSON_BNFTS_BAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_BNFTS_BAL_BK3" AUTHID CURRENT_USER as
/* $Header: bepbbapi.pkh 120.0 2005/05/28 10:02:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person_bnfts_bal_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_bnfts_bal_b
  (
   p_per_bnfts_bal_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person_bnfts_bal_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_bnfts_bal_a
  (
   p_per_bnfts_bal_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_person_bnfts_bal_bk3;

 

/
