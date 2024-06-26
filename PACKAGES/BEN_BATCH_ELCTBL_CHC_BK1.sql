--------------------------------------------------------
--  DDL for Package BEN_BATCH_ELCTBL_CHC_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_ELCTBL_CHC_BK1" AUTHID CURRENT_USER as
/* $Header: bebecapi.pkh 120.0 2005/05/28 00:37:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_elctbl_chc_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_elctbl_chc_b
  (p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_enrt_cvg_strt_dt               in  date
  ,p_enrt_perd_strt_dt              in  date
  ,p_enrt_perd_end_dt               in  date
  ,p_erlst_deenrt_dt                in  date
  ,p_dflt_enrt_dt                   in  date
  ,p_enrt_typ_cycl_cd               in  varchar2
  ,p_comp_lvl_cd                    in  varchar2
  ,p_mndtry_flag                    in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_batch_elctbl_chc_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_elctbl_chc_a
  (p_batch_elctbl_id                in  number
  ,p_benefit_action_id              in  number
  ,p_person_id                      in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_oipl_id                        in  number
  ,p_enrt_cvg_strt_dt               in  date
  ,p_enrt_perd_strt_dt              in  date
  ,p_enrt_perd_end_dt               in  date
  ,p_erlst_deenrt_dt                in  date
  ,p_dflt_enrt_dt                   in  date
  ,p_enrt_typ_cycl_cd               in  varchar2
  ,p_comp_lvl_cd                    in  varchar2
  ,p_mndtry_flag                    in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_batch_elctbl_chc_bk1;

 

/
