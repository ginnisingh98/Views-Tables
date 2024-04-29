--------------------------------------------------------
--  DDL for Package Body BEN_CWB_REFRESH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_REFRESH_PKG" as
/* $Header: bencwbrf.pkb 120.8.12010000.1 2008/07/29 12:07:42 appldev ship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_refresh_pkg.'; --Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- --------------------------------------------------------------------------
-- |------------------------------< refresh >-------------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure contains calls for refreshing person_info, pl_dsgn,
-- summary and consolidation of summary. This will be called by a concurent
-- process.
procedure refresh(errbuf  out  nocopy  varchar2
                 ,retcode out  nocopy  number
                 ,p_group_pl_id number
                 ,p_lf_evt_ocrd_dt varchar2
                 ,p_effective_date varchar2 default null
                 ,p_refresh_summary_flag varchar2
                 ,p_refresh_person_info_flag varchar2
                 ,p_refresh_pl_dsgn_flag varchar2
                 ,p_consolidate_summary_flag varchar2
		 ,p_init_rank varchar2
                 ,p_refresh_xchg varchar2
		 ,p_refresh_rate_from_rule varchar2 default 'N')
is

  cursor c_formula_inputs(p_group_pl_id number,p_lf_evt_ocrd_dt date)
  is
   select
     dsgn.pl_id
    ,dsgn.oipl_id
    ,ws_abr_id
    ,rates.group_per_in_ler_id
    ,enrt.rt_strt_dt_rl
    ,enrt.rt_strt_dt_cd
    ,rates.person_id
    ,enrt.business_group_id
    ,rates.object_version_number
   from
     ben_cwb_pl_dsgn dsgn
    ,ben_cwb_person_rates rates
    ,ben_popl_enrt_typ_cycl_f popl
    ,ben_cwb_person_info info
    ,ben_enrt_perd enrt
   where dsgn.group_pl_id = p_group_pl_id
     and dsgn.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
     and info.group_per_in_ler_id = rates.group_per_in_ler_id
     and nvl(info.post_process_stat_cd,'N') <> 'PR'
     and dsgn.ws_abr_id is not null
     and rates.group_pl_id = dsgn.group_pl_id
     and rates.group_oipl_id = dsgn.group_oipl_id
     and rates.pl_id = dsgn.pl_id
     and rates.oipl_id = dsgn.oipl_id
     and rates.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
     and popl.pl_id = dsgn.pl_id
     and enrt.asnd_lf_evt_dt = dsgn.lf_evt_ocrd_dt
     and popl.popl_enrt_typ_cycl_id = enrt.popl_enrt_typ_cycl_id;
     --and enrt.rt_strt_dt_rl is not null;

  cursor c_ranking_info
  is
    select assignment_extra_info_id
          ,object_version_number
      from per_assignment_extra_info xtra_info
      where xtra_info.information_type = 'CWBRANK'
      and xtra_info.aei_information3 IS NULL;

   cursor csr_person_ids(p_group_pl_id number
                        ,p_lf_evt_ocrd_dt date) is
   select distinct(person_id) person_id
   from  ben_cwb_summary
   where status = 'P'
   and group_pl_id = p_group_pl_id
   and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
--
   l_effective_date date;
   l_lf_evt_ocrd_dt date;
--
   l_proc     varchar2(72) := g_package||'refresh';
   l_ranks_initialised number;
--
   l_returned_date date;
   l_commit number;
   l_object_version_number number;
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   l_effective_date :=trunc(to_date(p_effective_date,'yyyy/mm/dd hh24:mi:ss'));
   l_lf_evt_ocrd_dt :=trunc(to_date(p_lf_evt_ocrd_dt,'yyyy/mm/dd hh24:mi:ss'));
   l_ranks_initialised := 0;

   if g_debug then
      hr_utility.set_location('Group Pl Id :'||p_group_pl_id, 20);
      hr_utility.set_location('Lf Evt Date :'||l_lf_evt_ocrd_dt, 20);
      hr_utility.set_location('Eff Date :'||l_effective_date, 20);
      hr_utility.set_location('Refresh Summary :'||p_refresh_summary_flag, 20);
      hr_utility.set_location('Refresh Person Info :'||
               p_refresh_person_info_flag, 20);
      hr_utility.set_location('Refresh Pl Dsgn :'||p_refresh_pl_dsgn_flag, 20);
      hr_utility.set_location('Consolidate Summary:'||
               p_consolidate_summary_flag, 20);
      hr_utility.set_location('Initialising Rankings:'||
               p_init_rank, 20);
      hr_utility.set_location('Refresh Exchange Rate:'||
               p_refresh_xchg, 20);
   end if;
   --
   --
   if p_init_rank = 'Y' then
   ben_batch_utils.WRITE('Initialising Rankings');
    if g_debug then
     hr_utility.set_location(l_proc, 21);
    end if;
   for l_ranking_info in c_ranking_info loop
     hr_assignment_extra_info_api.delete_assignment_extra_info
     (p_validate                 => false
     ,p_assignment_extra_info_id => l_ranking_info.assignment_extra_info_id
     ,p_object_version_number    => l_ranking_info.object_version_number);
     l_ranks_initialised := l_ranks_initialised + 1;
    end loop;
    commit;
    ben_batch_utils.WRITE ('Number of Employees with Rankings Initialized: '||l_ranks_initialised);
   end if;
   --
   if p_refresh_pl_dsgn_flag = 'Y' then
      --
      ben_batch_utils.WRITE('Refreshing Plan Design');
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      ben_cwb_pl_dsgn_pkg.refresh_pl_dsgn
            (p_group_pl_id    => p_group_pl_id
            ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
            ,p_effective_date => l_effective_date
            ,p_refresh_always => 'Y');
      commit;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
   end if;
   --
   begin
    savepoint before_refresh_xchg;
    if p_refresh_xchg = 'Y' then
     ben_batch_utils.WRITE('Initialising Refresh');
     if g_debug then
      hr_utility.set_location(l_proc, 21);
     end if;
     ben_cwb_xchg_pkg.insert_into_ben_cwb_xchg(p_group_pl_id
                                            ,l_lf_evt_ocrd_dt
                                            ,l_effective_date
                                            ,'Y'
                                            );
     commit;
     ben_batch_utils.WRITE('Completed Refresh');
   end if;
   exception
   when others then
     ben_batch_utils.WRITE(SQLERRM);
     ben_batch_utils.WRITE('Exchange Rate refresh failed');
     rollback to before_refresh_xchg;
   end;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 50);
   end if;
   --
   if p_refresh_person_info_flag = 'Y' then
      --
      ben_batch_utils.WRITE('Refreshing Person Info');
      if g_debug then
         hr_utility.set_location(l_proc, 60);
      end if;
      --
      ben_cwb_person_info_pkg.refresh_person_info_group_pl
                      (p_group_pl_id    => p_group_pl_id
                      ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                      ,p_effective_date => l_effective_date);
      --
      commit;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 70);
      end if;
      --
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 80);
   end if;
   --
   if p_refresh_summary_flag = 'Y' then
      --
      ben_batch_utils.WRITE('Refreshing Summary');
      if g_debug then
         hr_utility.set_location(l_proc, 90);
      end if;
      --
      ben_cwb_summary_pkg.refresh_summary_group_pl
            (p_group_pl_id    => p_group_pl_id
            ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt);
      --
      commit;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 100);
      end if;
      --
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 110);
   end if;
   --
   -- if the summary is refreshed then there is no need to consolidate the
   -- summary
   if p_consolidate_summary_flag = 'Y' and p_refresh_summary_flag <> 'Y' then

   ben_batch_utils.WRITE('Consolidating Summary');
      --
      if g_debug then
         hr_utility.set_location(l_proc, 120);
      end if;
      --
      for rec in csr_person_ids(p_group_pl_id,l_lf_evt_ocrd_dt) loop
      --
         if g_debug then
            hr_utility.set_location(l_proc, 130);
         end if;
      --
         ben_cwb_summary_pkg.consolidate_summary_rec
                         (p_person_id => rec.person_id);
      end loop;
      commit;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 140);
      end if;
      --
   end if;
   --
   if p_refresh_rate_from_rule = 'Y' then
   ben_batch_utils.WRITE('Refreshing worksheet rate start date');
 --
 -- Put row in fnd_sessions
 --
 dt_fndate.change_ses_date
        (p_ses_date => l_effective_date,
         p_commit   => l_commit);
 ben_batch_utils.WRITE ('Changing Session Date: '||l_effective_date);
 ben_batch_utils.WRITE ('Commit on date       : '||l_commit);

 for rec in c_formula_inputs(p_group_pl_id,l_lf_evt_ocrd_dt) loop

  l_object_version_number := rec.object_version_number;

 if rec.rt_strt_dt_cd = 'RL' AND rec.rt_strt_dt_rl is not null then
  BEN_DETERMINE_DATE.main
    (
   p_date_cd                => 'RL'
  ,p_per_in_ler_id          => rec.group_per_in_ler_id
  ,p_person_id              => rec.person_id
  ,p_pl_id                  => rec.pl_id
  ,p_oipl_id                => rec.oipl_id
  ,p_business_group_id      => rec.business_group_id
  ,p_formula_id             => rec.rt_strt_dt_rl
  ,p_acty_base_rt_id        => rec.ws_abr_id
  ,p_effective_date         => l_effective_date
  ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt
  ,p_returned_date          => l_returned_date
    );
    -- ben_batch_utils.WRITE(rec.group_per_in_ler_id||' '||l_returned_date||' '||rec.oipl_id);
  if g_debug then
   hr_utility.set_location(' p_returned_date:'|| l_returned_date, 11);
   hr_utility.set_location(' p_per_in_ler_id:'|| rec.group_per_in_ler_id, 22);
  end if;

  BEN_CWB_PERSON_RATES_API.update_person_rate(
    p_group_per_in_ler_id => rec.group_per_in_ler_id
   ,p_pl_id               => rec.pl_id
   ,p_oipl_id             => rec.oipl_id
   ,p_ws_rt_start_date    => l_returned_date
   ,p_object_version_number => l_object_version_number
   );

  elsif REC.RT_STRT_DT_CD = 'ENTRBL' then

    BEN_CWB_PERSON_RATES_API.update_person_rate(
    p_group_per_in_ler_id => rec.group_per_in_ler_id
   ,p_pl_id               => rec.pl_id
   ,p_oipl_id             => rec.oipl_id
   ,p_ws_rt_start_date    => null
   ,p_object_version_number => l_object_version_number
   );
  end if;

  end loop;

 --
 commit;
 --
 end if;

   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
   exception
    when others then
    ben_batch_utils.WRITE(SQLERRM);
    ben_batch_utils.WRITE('Process Errored : Rolled Back');
    ROLLBACK;

end refresh;

end BEN_CWB_REFRESH_PKG;


/
