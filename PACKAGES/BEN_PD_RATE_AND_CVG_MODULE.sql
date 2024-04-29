--------------------------------------------------------
--  DDL for Package BEN_PD_RATE_AND_CVG_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_RATE_AND_CVG_MODULE" AUTHID CURRENT_USER as
/* $Header: bepdcrtc.pkh 115.7 2004/01/13 11:45:26 rpillay noship $ */
--
procedure create_rate_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  --
  ,p_opt_id                         in  number    default null
  --
  ) ;
--
procedure create_coverage_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ) ;
--
procedure create_premium_results
  (
   p_validate                       in  number    default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ) ;
--
procedure create_drpar_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_hrs_wkd_in_perd_fctr_id        in  number    default null
  ,p_los_fctr_id                    in  number    default null
  ,p_pct_fl_tm_fctr_id              in  number    default null
  ,p_age_fctr_id                    in  number    default null
  ,p_cmbn_age_los_fctr_id           in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in varchar2   default null
  ) ;
--
procedure create_vapro_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ,p_no_dup_rslt                    in varchar2   default null
  ) ;
--
procedure create_bnft_pool_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ) ;
--
procedure create_service_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_svc_area_id                    in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) ;
--
procedure create_postal_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pstl_zip_rng_id                in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) ;
--
procedure create_bnft_bal_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_bnfts_bal_id                    in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) ;
--
procedure create_bnft_group_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_benfts_grp_id                  in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) ;
--
procedure create_acrs_ptip_cvg_results
    (
     p_validate                       in  number    default 0 -- false
    ,p_copy_entity_result_id          in  number    -- Parent row
    ,p_copy_entity_txn_id             in  number    default null
    ,p_pgm_id                         in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ) ;
--
end ben_pd_rate_and_cvg_module;

 

/
