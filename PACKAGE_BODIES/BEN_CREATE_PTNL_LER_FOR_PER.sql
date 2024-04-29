--------------------------------------------------------
--  DDL for Package Body BEN_CREATE_PTNL_LER_FOR_PER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CREATE_PTNL_LER_FOR_PER" as
/* $Header: bencrler.pkb 120.1 2005/09/30 08:33:45 tpapired noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ben_create_ptnl_ler_for_per.';
g_debug boolean := hr_utility.debug_enabled;
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
  ,p_effective_date                 in  date) is
  --
  l_proc varchar2(72) ;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'create_ptnl_ler_event';
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.set_location('LE reason type  :'|| p_ler_typ_cd, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if nvl(p_ler_typ_cd,'-1')  = 'CHECKLIST'  then
     -- call to HR package to create checklist ptn_ler
      hr_utility.set_location('Call to HR PNTL_LER creation :'|| l_proc, 10);
      --
      PER_CHECKLIST_EVENTS.CREATE_EVENT
          (p_effective_date => p_effective_date
          ,p_person_id      => p_person_id
          ,p_assignment_id  => p_assignment_id
          ,p_ler_id         => p_ler_id
          );
      --
      hr_utility.set_location('Call to HR PNTL_LER creation :'|| l_proc, 20);
      --
  else

       ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
                           (p_validate                       => p_validate
                           ,p_ptnl_ler_for_per_id            => p_ptnl_ler_for_per_id
                           ,p_csd_by_ptnl_ler_for_per_id     => p_csd_by_ptnl_ler_for_per_id
                           ,p_lf_evt_ocrd_dt                 => p_lf_evt_ocrd_dt
                           ,p_trgr_table_pk_id               => p_trgr_table_pk_id
                           ,p_ptnl_ler_for_per_stat_cd       => p_ptnl_ler_for_per_stat_cd
                           ,p_ptnl_ler_for_per_src_cd        => p_ptnl_ler_for_per_src_cd
                           ,p_mnl_dt                         => p_mnl_dt
                           ,p_enrt_perd_id                   => p_enrt_perd_id
                           ,p_ler_id                         => p_ler_id
                           ,p_person_id                      => p_person_id
                           ,p_business_group_id              => p_business_group_id
                           ,p_dtctd_dt                       => p_dtctd_dt
                           ,p_procd_dt                       => p_procd_dt
                           ,p_unprocd_dt                     => p_unprocd_dt
                           ,p_voidd_dt                       => p_voidd_dt
                           ,p_mnlo_dt                        => p_mnlo_dt
                           ,p_ntfn_dt                        => p_ntfn_dt
                           ,p_request_id                     => p_request_id
                           ,p_program_application_id         => p_program_application_id
                           ,p_program_id                     => p_program_id
                           ,p_program_update_date            => p_program_update_date
                           ,p_object_version_number          => p_object_version_number
                           ,p_effective_date                 => p_effective_date) ;

  end if ;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 05);
  end if;



end create_ptnl_ler_event;




end ben_create_ptnl_ler_for_per;

/
