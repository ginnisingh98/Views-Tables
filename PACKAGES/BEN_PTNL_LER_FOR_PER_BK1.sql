--------------------------------------------------------
--  DDL for Package BEN_PTNL_LER_FOR_PER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTNL_LER_FOR_PER_BK1" AUTHID CURRENT_USER as
/* $Header: bepplapi.pkh 120.0 2005/05/28 10:58:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ptnl_ler_for_per_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptnl_ler_for_per_b
  (p_lf_evt_ocrd_dt                 in  date
  ,p_trgr_table_pk_id               in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2
  ,p_ptnl_ler_for_per_src_cd        in  varchar2
  ,p_mnl_dt                         in  date
  ,p_enrt_perd_id                   in  number
  ,p_ler_id                         in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_dtctd_dt                       in  date
  ,p_procd_dt                       in  date
  ,p_unprocd_dt                     in  date
  ,p_voidd_dt                       in  date
  ,p_mnlo_dt                        in  date
  ,p_ntfn_dt                        in  date
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ptnl_ler_for_per_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptnl_ler_for_per_a
  (p_ptnl_ler_for_per_id            in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number
  ,p_lf_evt_ocrd_dt                 in  date
  ,p_trgr_table_pk_id               in  number
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2
  ,p_ptnl_ler_for_per_src_cd        in  varchar2
  ,p_mnl_dt                         in  date
  ,p_enrt_perd_id                   in  number
  ,p_ler_id                         in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_dtctd_dt                       in  date
  ,p_procd_dt                       in  date
  ,p_unprocd_dt                     in  date
  ,p_voidd_dt                       in  date
  ,p_mnlo_dt                        in  date
  ,p_ntfn_dt                        in  date
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_ptnl_ler_for_per_bk1;

 

/
