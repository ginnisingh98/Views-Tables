--------------------------------------------------------
--  DDL for Package BEN_CREATE_PTNL_LER_FOR_PER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CREATE_PTNL_LER_FOR_PER" AUTHID CURRENT_USER as
/* $Header: bencrler.pkh 120.0 2005/05/28 03:54:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ptnl_ler_event >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
procedure create_ptnl_ler_event
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            out nocopy number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
  ,p_mnl_dt                         in  date      default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_ler_typ_cd                     in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dtctd_dt                       in  date      default null
  ,p_procd_dt                       in  date      default null
  ,p_unprocd_dt                     in  date      default null
  ,p_voidd_dt                       in  date      default null
  ,p_mnlo_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_assignment_id                  in  number    default null
  ,p_effective_date                 in  date);


end ;

 

/
