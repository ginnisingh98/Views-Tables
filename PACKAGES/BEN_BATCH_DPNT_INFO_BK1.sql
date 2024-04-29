--------------------------------------------------------
--  DDL for Package BEN_BATCH_DPNT_INFO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_DPNT_INFO_BK1" AUTHID CURRENT_USER as
/* $Header: bebdiapi.pkh 120.0 2005/05/28 00:36:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_dpnt_info_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_dpnt_info_b
  (p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_contact_typ_cd                 in  varchar2
  ,p_dpnt_person_id                 in  number
  ,p_business_group_id              in  number
  ,p_enrt_cvg_strt_dt               in  date
  ,p_enrt_cvg_thru_dt               in  date
  ,p_actn_cd                        in  varchar2
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_dpnt_info_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_dpnt_info_a
  (p_batch_dpnt_id                  in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_contact_typ_cd                 in  varchar2
  ,p_dpnt_person_id                 in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  varchar2
  ,p_enrt_cvg_strt_dt               in  date
  ,p_enrt_cvg_thru_dt               in  date
  ,p_actn_cd                        in  varchar2
  ,p_effective_date                 in  date);
--
end ben_batch_dpnt_info_bk1;

 

/
