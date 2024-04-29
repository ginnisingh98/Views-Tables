--------------------------------------------------------
--  DDL for Package BEN_BATCH_ELIG_INFO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_ELIG_INFO_BK1" AUTHID CURRENT_USER as
/* $Header: bebeiapi.pkh 120.0 2005/05/28 00:37:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_elig_info_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_elig_info_b
  (p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_elig_flag                      in  varchar2
  ,p_inelig_text                    in  varchar2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_elig_info_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_elig_info_a
  (p_batch_elig_id                  in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_elig_flag                      in  varchar2
  ,p_inelig_text                    in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_batch_elig_info_bk1;

 

/
