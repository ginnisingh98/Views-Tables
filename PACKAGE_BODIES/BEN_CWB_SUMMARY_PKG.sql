--------------------------------------------------------
--  DDL for Package Body BEN_CWB_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_SUMMARY_PKG" as
/* $Header: bencwbsm.pkb 120.15.12010000.2 2008/09/08 06:15:58 cakunuru ship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_summary_pkg.'; --Global package name
g_debug boolean := hr_utility.debug_enabled;
--
type g_summary_type is table of ben_cwb_summary%rowtype
         index by binary_integer;
g_summary_rec g_summary_type;
--
   -- Get the rate information for this person.
   cursor csr_rates(v_per_in_ler_id number) is
   select rt.group_pl_id                  group_pl_id
         ,rt.group_oipl_id                group_oipl_id
         ,1                               elig_count
         ,decode(rt.ws_val,null,0,0,0,1)  emp_recv_count
         ,rt.elig_sal_val/decode(pl.elig_sal_nnmntry_uom,null
      ,xchg.xchg_rate,1) elig_sal_val
         ,rt.ws_val/decode(pl.ws_nnmntry_uom,null
      ,xchg.xchg_rate,1)       ws_val
         ,rt.stat_sal_val/decode(pl.stat_sal_nnmntry_uom,null
      ,xchg.xchg_rate,1) stat_sal_val
         ,rt.oth_comp_val/decode(pl.oth_comp_nnmntry_uom,null
      ,xchg.xchg_rate,1) oth_comp_val
         ,rt.tot_comp_val/decode(pl.tot_comp_nnmntry_uom,null
      ,xchg.xchg_rate,1) tot_comp_val
         ,rt.rec_val/decode(pl.rec_nnmntry_uom,null
      ,xchg.xchg_rate,1)      rec_val
         ,rt.rec_mn_val/decode(pl.rec_nnmntry_uom,null
      ,xchg.xchg_rate,1)   rec_mn_val
         ,rt.rec_mx_val/decode(pl.rec_nnmntry_uom,null
      ,xchg.xchg_rate,1)   rec_mx_val
         ,rt.misc1_val/decode(pl.misc1_nnmntry_uom,null
      ,xchg.xchg_rate,1)    misc1_val
         ,rt.misc2_val/decode(pl.misc2_nnmntry_uom,null
      ,xchg.xchg_rate,1)    misc2_val
         ,rt.misc3_val/decode(pl.misc3_nnmntry_uom,null
      ,xchg.xchg_rate,1)    misc3_val
   from ben_cwb_person_rates rt
       ,ben_cwb_pl_dsgn pl
       ,ben_cwb_xchg xchg
   where rt.group_per_in_ler_id = v_per_in_ler_id
   and   rt.pl_id = pl.pl_id
   and   rt.oipl_id = pl.oipl_id
   and   rt.lf_evt_ocrd_dt = pl.lf_evt_ocrd_dt
   and   rt.elig_flag = 'Y'
   and   xchg.group_pl_id = rt.group_pl_id
   and   xchg.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
   and   xchg.currency = rt.currency
   order by rt.group_pl_id, rt.group_oipl_id;

   -- Get the summary information for this person
   cursor csr_summary(v_per_in_ler_id number) is
   select group_pl_id                group_pl_id
         ,group_oipl_id              group_oipl_id
         ,sum(elig_count_all)        elig_count
         ,sum(emp_recv_count_all)    emp_recv_count
         ,sum(elig_sal_val_all)      elig_sal_val_all
         ,sum(ws_val_all)            ws_val
         ,sum(stat_sal_val_all)      stat_sal_val
         ,sum(oth_comp_val_all)      oth_comp_val
         ,sum(tot_comp_val_all)      tot_comp_val
         ,sum(rec_val_all)           rec_val
         ,sum(rec_mn_val_all)        rec_mn_val
         ,sum(rec_mx_val_all)        rec_mx_val
         ,sum(misc1_val_all)         misc1_val
         ,sum(misc2_val_all)         misc2_val
         ,sum(misc3_val_all)         misc3_val
   from ben_cwb_summary
   where group_per_in_ler_id = v_per_in_ler_id
   group by group_pl_id, group_oipl_id
   order by group_pl_id, group_oipl_id;

   -- While updating the old manager hierarchy, we need to go only until
   -- the point where the new manager hierarchy meets. Similarly while
   -- updating the new manager hierarchy, we just need to go up to the
   -- point where the old mgr hierarchy meets.
   cursor csr_mgr_ids(v_mgr_per_in_ler_id1 number
                     ,v_mgr_per_in_ler_id2 number) is
   select mgr_per_in_ler_id
         ,lvl_num
   from ben_cwb_group_hrchy hrchy1
   where emp_per_in_ler_id = v_mgr_per_in_ler_id1
   and mgr_per_in_ler_id not in
            (select mgr_per_in_ler_id
             from ben_cwb_group_hrchy hrchy2
             where emp_per_in_ler_id = v_mgr_per_in_ler_id2
             and   mgr_per_in_ler_id <> v_mgr_per_in_ler_id1
             and   lvl_num > 0)
   order by lvl_num;
   --
   cursor csr_mgrs(v_per_in_ler_id in number) is
      select mgr_per_in_ler_id
            ,lvl_num
      from   ben_cwb_group_hrchy
      where  emp_per_in_ler_id = v_per_in_ler_id
      and    lvl_num > 0
      order by lvl_num;

procedure check_refresh_jobs(p_group_pl_id in number
                            ,p_lf_evt_ocrd_dt in date
                            ,p_called_from_batch in varchar2 default 'N') is
  cursor c_refresh is
     select 'Y'
     from   ben_cwb_summary
     where  group_per_in_ler_id = -1
     and    group_pl_id = p_group_pl_id
     and    lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
     and    status = 'R'
     and    person_id = -1;
  --
  l_refresh varchar2(1);
  --
begin
  --
  if fnd_global.conc_request_id = -1 then    --7316806:check enforced only when the changes are done from worksheet (no conc. request is running)
  open  c_refresh;
  fetch c_refresh into l_refresh;
  close c_refresh;
  --
  if l_refresh = 'Y' then
    fnd_message.set_name('BEN', 'BEN_94676_CWB_SUMM_RFRSH_RUNNG');
    fnd_message.raise_error;
  end if;
  end if;      -- conc-req check
  --
end check_refresh_jobs;
--
procedure insert_refresh_job_marker(p_group_pl_id in number
                                   ,p_lf_evt_ocrd_dt in date) is
  pragma autonomous_transaction;
begin
  --
  insert into ben_cwb_summary
           (summary_id
           ,group_per_in_ler_id
           ,group_pl_id
           ,lf_evt_ocrd_dt
           ,status
           ,person_id)
  values
       (ben_cwb_summary_s.nextval
       ,-1
       ,p_group_pl_id
       ,p_lf_evt_ocrd_dt
       ,'R'
       ,-1);
  --
  commit;
  --
end insert_refresh_job_marker;
--
procedure delete_refresh_job_marker(p_group_pl_id in number
                                   ,p_lf_evt_ocrd_dt in date) is
  pragma autonomous_transaction;
begin
  --
  delete ben_cwb_summary
  where group_per_in_ler_id = -1
  and   group_pl_id = p_group_pl_id
  and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
  and   status = 'R'
  and   person_id = -1;
  --
  commit;
  --
end delete_refresh_job_marker;
--
-- --------------------------------------------------------------------------
-- |--------------------------< update_or_insert >---------------------------|
-- --------------------------------------------------------------------------
--
procedure update_or_insert (p_sum_rec in ben_cwb_summary%rowtype) is

   -- select all the summary ids for this combination
   cursor csr_summary_id is
   select summary_id
   from ben_cwb_summary
   where group_per_in_ler_id = p_sum_rec.group_per_in_ler_id
   and group_pl_id = p_sum_rec.group_pl_id
   and group_oipl_id = p_sum_rec.group_oipl_id;
   --
   cursor c_pil is
      select pil.person_id,
             pil.lf_evt_ocrd_dt
      from   ben_per_in_ler pil
      where  pil.per_in_ler_id = p_sum_rec.group_per_in_ler_id;
   --
   l_dummy varchar2(1);
   l_summary_id number;
   l_found varchar2(1) := null;
   l_status varchar2(30);
   --
   l_person_id number;
   l_lf_evt_ocrd_dt date;
   --
   l_proc     varchar2(72) := g_package||'update_or_insert';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --

      --
      l_person_id      := p_sum_rec.person_id;
      l_lf_evt_ocrd_dt := p_sum_rec.lf_evt_ocrd_dt;
      --
      -- If the pl/sql record does not have person_id or lf_evt_ocrd_dt,
      -- then get it from the per_in_ler record.
      --
      if l_person_id is null or l_lf_evt_ocrd_dt is null then
        --
        open  c_pil;
        fetch c_pil into l_person_id, l_lf_evt_ocrd_dt;
        close c_pil;
        --
      end if;
   --

   check_refresh_jobs(p_group_pl_id    => p_sum_rec.group_pl_id
                     ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt);
   --
   open csr_summary_id;
   fetch csr_summary_id into l_summary_id;

   if (csr_summary_id%notfound) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      -- No records are found. So set the flag to No records.
      l_found := 'N'; -- no records;
   else
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      -- try to get summary Id of one unlocked record
      loop
      begin
         select null into l_dummy
         from ben_cwb_summary
         where summary_id = l_summary_id
         for update nowait;

    -- Found one unlocked record. So set the flag and exit from the loop
         l_found :='F'; -- Found
         exit;
      exception
         when hr_api.object_locked then
       -- The present record is locked. So try for another
            fetch csr_summary_id into l_summary_id;
            if (csr_summary_id%notfound) then
          -- All records are locked. So set the flag to Locked
          -- exit from the loop
          l_found := 'L';  -- Locked
               exit;
            end if;
      end;
      end loop;
      --
   end if;
   close csr_summary_id;


   if (l_found = 'F') then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      -- Found one unlocked record. So update the summary.
      update ben_cwb_summary summ
      set elig_count_direct = nvl2(summ.elig_count_direct,
                                  summ.elig_count_direct+
                                  nvl(p_sum_rec.elig_count_direct,0),
                                  p_sum_rec.elig_count_direct)
      ,elig_count_all = nvl2(summ.elig_count_all,
                                  summ.elig_count_all+
                                  nvl(p_sum_rec.elig_count_all,0),
                                  p_sum_rec.elig_count_all)
      ,emp_recv_count_direct = nvl2(summ.emp_recv_count_direct,
                                  summ.emp_recv_count_direct+
                                  nvl(p_sum_rec.emp_recv_count_direct,0),
                                  p_sum_rec.emp_recv_count_direct)
      ,emp_recv_count_all = nvl2(summ.emp_recv_count_all,
                                  summ.emp_recv_count_all+
                                  nvl(p_sum_rec.emp_recv_count_all,0),
                                  p_sum_rec.emp_recv_count_all)
      ,elig_sal_val_direct = nvl2(summ.elig_sal_val_direct,
                                  summ.elig_sal_val_direct+
                                  nvl(p_sum_rec.elig_sal_val_direct,0),
                                  p_sum_rec.elig_sal_val_direct)
      ,elig_sal_val_all = nvl2(summ.elig_sal_val_all,
                                 summ.elig_sal_val_all +
                                 nvl(p_sum_rec.elig_sal_val_all,0),
                                 p_sum_rec.elig_sal_val_all)
      ,ws_val_direct = nvl2(summ.ws_val_direct,
                             summ.ws_val_direct +
                             nvl(p_sum_rec.ws_val_direct,0),
                             p_sum_rec.ws_val_direct)
      ,ws_val_all = nvl2(summ.ws_val_all,
                             summ.ws_val_all +
                             nvl(p_sum_rec.ws_val_all,0),
                             p_sum_rec.ws_val_all)
      ,ws_bdgt_val_direct =  nvl2(summ.ws_bdgt_val_direct,
                             summ.ws_bdgt_val_direct +
                             nvl(p_sum_rec.ws_bdgt_val_direct,0),
                             p_sum_rec.ws_bdgt_val_direct)
      ,ws_bdgt_val_all =  nvl2(summ.ws_bdgt_val_all,
                             summ.ws_bdgt_val_all +
                             nvl(p_sum_rec.ws_bdgt_val_all,0),
                             p_sum_rec.ws_bdgt_val_all)
      ,ws_bdgt_iss_val_direct =  nvl2(summ.ws_bdgt_iss_val_direct,
                             summ.ws_bdgt_iss_val_direct +
                             nvl(p_sum_rec.ws_bdgt_iss_val_direct,0),
                             p_sum_rec.ws_bdgt_iss_val_direct)
      ,ws_bdgt_iss_val_all =  nvl2(summ.ws_bdgt_iss_val_all,
                             summ.ws_bdgt_iss_val_all +
                             nvl(p_sum_rec.ws_bdgt_iss_val_all,0),
                             p_sum_rec.ws_bdgt_iss_val_all)
      ,bdgt_val_direct =  nvl2(summ.bdgt_val_direct,
                             summ.bdgt_val_direct +
                             nvl(p_sum_rec.bdgt_val_direct,0),
                             p_sum_rec.bdgt_val_direct)
      ,bdgt_iss_val_direct =  nvl2(summ.bdgt_iss_val_direct,
                             summ.bdgt_iss_val_direct +
                             nvl(p_sum_rec.bdgt_iss_val_direct,0),
                             p_sum_rec.bdgt_iss_val_direct)
      ,stat_sal_val_direct =  nvl2(summ.stat_sal_val_direct,
                             summ.stat_sal_val_direct +
                             nvl(p_sum_rec.stat_sal_val_direct,0),
                             p_sum_rec.stat_sal_val_direct)
      ,stat_sal_val_all = nvl2(summ.stat_sal_val_all,
                             summ.stat_sal_val_all +
                             nvl(p_sum_rec.stat_sal_val_all,0),
                             p_sum_rec.stat_sal_val_all)
      ,oth_comp_val_direct =  nvl2(summ.oth_comp_val_direct,
                             summ.oth_comp_val_direct +
                             nvl(p_sum_rec.oth_comp_val_direct,0),
                             p_sum_rec.oth_comp_val_direct)
      ,oth_comp_val_all =  nvl2(summ.oth_comp_val_all,
                             summ.oth_comp_val_all +
                             nvl(p_sum_rec.oth_comp_val_all,0),
                             p_sum_rec.oth_comp_val_all)
      ,tot_comp_val_direct =  nvl2(summ.tot_comp_val_direct,
                             summ.tot_comp_val_direct +
                             nvl(p_sum_rec.tot_comp_val_direct,0),
                             p_sum_rec.tot_comp_val_direct)
      ,tot_comp_val_all =  nvl2(summ.tot_comp_val_all,
                             summ.tot_comp_val_all +
                             nvl(p_sum_rec.tot_comp_val_all,0),
                             p_sum_rec.tot_comp_val_all)
      ,rec_val_direct =  nvl2(summ.rec_val_direct,
                             summ.rec_val_direct +
                             nvl(p_sum_rec.rec_val_direct,0),
                             p_sum_rec.rec_val_direct)
      ,rec_val_all =  nvl2(summ.rec_val_all,
                             summ.rec_val_all +
                             nvl(p_sum_rec.rec_val_all,0),
                             p_sum_rec.rec_val_all)
      ,rec_mn_val_direct =  nvl2(summ.rec_mn_val_direct,
                             summ.rec_mn_val_direct +
                             nvl(p_sum_rec.rec_mn_val_direct,0),
                             p_sum_rec.rec_mn_val_direct)
      ,rec_mn_val_all =  nvl2(summ.rec_mn_val_all,
                             summ.rec_mn_val_all +
                             nvl(p_sum_rec.rec_mn_val_all,0),
                             p_sum_rec.rec_mn_val_all)
      ,rec_mx_val_direct =  nvl2(summ.rec_mx_val_direct,
                             summ.rec_mx_val_direct +
                             nvl(p_sum_rec.rec_mx_val_direct,0),
                             p_sum_rec.rec_mx_val_direct)
      ,rec_mx_val_all =  nvl2(summ.rec_mx_val_all,
                             summ.rec_mx_val_all +
                             nvl(p_sum_rec.rec_mx_val_all,0),
                             p_sum_rec.rec_mx_val_all)
      ,misc1_val_direct =  nvl2(summ.misc1_val_direct,
                             summ.misc1_val_direct +
                             nvl(p_sum_rec.misc1_val_direct,0),
                             p_sum_rec.misc1_val_direct)
      ,misc1_val_all =  nvl2(summ.misc1_val_all,
                             summ.misc1_val_all +
                             nvl(p_sum_rec.misc1_val_all,0),
                             p_sum_rec.misc1_val_all)
      ,misc2_val_direct =  nvl2(summ.misc2_val_direct,
                             summ.misc2_val_direct +
                             nvl(p_sum_rec.misc2_val_direct,0),
                             p_sum_rec.misc2_val_direct)
      ,misc2_val_all =  nvl2(summ.misc2_val_all,
                             summ.misc2_val_all +
                             nvl(p_sum_rec.misc2_val_all,0),
                             p_sum_rec.misc2_val_all)
      ,misc3_val_direct = nvl2(summ.misc3_val_direct,
                             summ.misc3_val_direct +
                             nvl(p_sum_rec.misc3_val_direct,0),
                             p_sum_rec.misc3_val_direct)
      ,misc3_val_all =  nvl2(summ.misc3_val_all,
                             summ.misc3_val_all +
                             nvl(p_sum_rec.misc3_val_all,0),
                             p_sum_rec.misc3_val_all)
      where summ.summary_id = l_summary_id;
   else
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      if (l_found = 'L') then
         -- All the records are locked. So insert a 'P' record.
         l_status := 'P';
      else  -- l_found = 'N'
         -- No records are found. So this will be the first record.
         l_status := null;
      end if;

      insert into ben_cwb_summary (
                summary_id
               ,group_per_in_ler_id
               ,group_pl_id
               ,group_oipl_id
               ,status
               ,elig_count_direct
               ,elig_count_all
               ,emp_recv_count_direct
               ,emp_recv_count_all
               ,elig_sal_val_direct
               ,elig_sal_val_all
               ,ws_val_direct
               ,ws_val_all
               ,ws_bdgt_val_direct
               ,ws_bdgt_val_all
               ,ws_bdgt_iss_val_direct
               ,ws_bdgt_iss_val_all
               ,bdgt_val_direct
               ,bdgt_iss_val_direct
               ,stat_sal_val_direct
               ,stat_sal_val_all
               ,oth_comp_val_direct
               ,oth_comp_val_all
               ,tot_comp_val_direct
               ,tot_comp_val_all
               ,rec_val_direct
               ,rec_val_all
               ,rec_mn_val_direct
               ,rec_mn_val_all
               ,rec_mx_val_direct
               ,rec_mx_val_all
               ,misc1_val_direct
               ,misc1_val_all
               ,misc2_val_direct
               ,misc2_val_all
               ,misc3_val_direct
               ,misc3_val_all
               ,person_id
               ,lf_evt_ocrd_dt)
      values (
              ben_cwb_summary_s.nextval
             ,p_sum_rec.group_per_in_ler_id
             ,p_sum_rec.group_pl_id
             ,p_sum_rec.group_oipl_id
             ,l_status
             ,p_sum_rec.elig_count_direct
             ,p_sum_rec.elig_count_all
             ,p_sum_rec.emp_recv_count_direct
             ,p_sum_rec.emp_recv_count_all
             ,p_sum_rec.elig_sal_val_direct
             ,p_sum_rec.elig_sal_val_all
             ,p_sum_rec.ws_val_direct
             ,p_sum_rec.ws_val_all
             ,p_sum_rec.ws_bdgt_val_direct
             ,p_sum_rec.ws_bdgt_val_all
             ,p_sum_rec.ws_bdgt_iss_val_direct
             ,p_sum_rec.ws_bdgt_iss_val_all
             ,p_sum_rec.bdgt_val_direct
             ,p_sum_rec.bdgt_iss_val_direct
             ,p_sum_rec.stat_sal_val_direct
             ,p_sum_rec.stat_sal_val_all
             ,p_sum_rec.oth_comp_val_direct
             ,p_sum_rec.oth_comp_val_all
             ,p_sum_rec.tot_comp_val_direct
             ,p_sum_rec.tot_comp_val_all
             ,p_sum_rec.rec_val_direct
             ,p_sum_rec.rec_val_all
             ,p_sum_rec.rec_mn_val_direct
             ,p_sum_rec.rec_mn_val_all
             ,p_sum_rec.rec_mx_val_direct
             ,p_sum_rec.rec_mx_val_all
             ,p_sum_rec.misc1_val_direct
             ,p_sum_rec.misc1_val_all
             ,p_sum_rec.misc2_val_direct
             ,p_sum_rec.misc2_val_all
             ,p_sum_rec.misc3_val_direct
             ,p_sum_rec.misc3_val_all
             ,l_person_id
             ,l_lf_evt_ocrd_dt
             );
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- of procedure update_or_insert
--
-- --------------------------------------------------------------------------
-- |----------------------< consolidate_summary_rec >------------------------|
-- --------------------------------------------------------------------------
procedure consolidate_summary_rec(p_person_id in number) is

   -- get the records with status P
   cursor csr_pending_recs(p_person_id number) is
   select summ.*
   from ben_cwb_summary summ
   where summ.person_id = p_person_id
   and summ.status = 'P'
   order by summ.group_per_in_ler_id, summ.group_pl_id, summ.group_oipl_id;
   --
   l_sum_rec ben_cwb_summary%rowtype;
   --
   l_proc     varchar2(72) := g_package||'consolidate_summary_rec';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- for each pending record
   for pending_rec in csr_pending_recs(p_person_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      -- These will be executed only for the first iteration of the loop
      if l_sum_rec.group_per_in_ler_id is null then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 30);
         end if;
         --
         l_sum_rec.group_per_in_ler_id := pending_rec.group_per_in_ler_id;
         l_sum_rec.group_pl_id := pending_rec.group_pl_id;
         l_sum_rec.group_oipl_id := pending_rec.group_oipl_id;
         l_sum_rec.person_id := pending_rec.person_id;
      end if;

      -- check if group_per_in_ler_id, group_pl_id or group_oipl_id changes
      if ( l_sum_rec.group_per_in_ler_id <> pending_rec.group_per_in_ler_id
         or l_sum_rec.group_pl_id <> pending_rec.group_pl_id
         or l_sum_rec.group_oipl_id <>
               pending_rec.group_oipl_id) then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --
         -- combination changed. So call update_or_insert
         -- This procedure tries to update the main rec, if it is already
         -- locked then it will insert a new record with status "P".
         update_or_insert (l_sum_rec);

         -- Now clear the l_sum_rec to store the next combination.
         l_sum_rec.group_per_in_ler_id :=pending_rec.group_per_in_ler_id;
         l_sum_rec.group_pl_id :=pending_rec.group_pl_id;
         l_sum_rec.group_oipl_id  :=pending_rec.group_oipl_id;
         l_sum_rec.person_id  := pending_rec.person_id;
         l_sum_rec.status :=null;
         l_sum_rec.elig_count_direct :=null;
         l_sum_rec.elig_count_all :=null;
         l_sum_rec.emp_recv_count_direct :=null;
         l_sum_rec.emp_recv_count_all :=null;
         l_sum_rec.elig_sal_val_direct :=null;
         l_sum_rec.elig_sal_val_all  :=null;
         l_sum_rec.ws_val_direct :=null;
         l_sum_rec.ws_val_all :=null;
         l_sum_rec.ws_bdgt_val_direct :=null;
         l_sum_rec.ws_bdgt_val_all :=null;
         l_sum_rec.ws_bdgt_iss_val_direct :=null;
         l_sum_rec.ws_bdgt_iss_val_all :=null;
         l_sum_rec.bdgt_val_direct :=null;
         l_sum_rec.bdgt_iss_val_direct :=null;
         l_sum_rec.stat_sal_val_direct :=null;
         l_sum_rec.stat_sal_val_all :=null;
         l_sum_rec.oth_comp_val_direct :=null;
         l_sum_rec.oth_comp_val_all :=null;
         l_sum_rec.tot_comp_val_direct :=null;
         l_sum_rec.tot_comp_val_all :=null;
         l_sum_rec.rec_val_direct :=null;
         l_sum_rec.rec_val_all :=null;
         l_sum_rec.rec_mn_val_direct :=null;
         l_sum_rec.rec_mn_val_all :=null;
         l_sum_rec.rec_mx_val_direct :=null;
         l_sum_rec.rec_mx_val_all :=null;
         l_sum_rec.misc1_val_direct :=null;
         l_sum_rec.misc1_val_all :=null;
         l_sum_rec.misc2_val_direct :=null;
         l_sum_rec.misc2_val_all :=null;
         l_sum_rec.misc3_val_direct :=null;
         l_sum_rec.misc3_val_all :=null;
      end if; -- if change in combination
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      --Now, add the values
      l_sum_rec.elig_count_direct := ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.elig_count_direct,pending_rec.elig_count_direct);
      l_sum_rec.elig_count_all := ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.elig_count_all,pending_rec.elig_count_all);
      l_sum_rec.emp_recv_count_direct := ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.emp_recv_count_direct,pending_rec.emp_recv_count_direct);
      l_sum_rec.emp_recv_count_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.emp_recv_count_all,pending_rec.emp_recv_count_all);
      l_sum_rec.elig_sal_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.elig_sal_val_direct,pending_rec.elig_sal_val_direct);
      l_sum_rec.elig_sal_val_all := ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.elig_sal_val_all,pending_rec.elig_sal_val_all);
      l_sum_rec.ws_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.ws_val_direct,pending_rec.ws_val_direct);
      l_sum_rec.ws_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.ws_val_all,pending_rec.ws_val_all);
      l_sum_rec.ws_bdgt_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.ws_bdgt_val_direct,pending_rec.ws_bdgt_val_direct);
      l_sum_rec.ws_bdgt_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.ws_bdgt_val_all,pending_rec.ws_bdgt_val_all);
      l_sum_rec.ws_bdgt_iss_val_direct := ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.ws_bdgt_iss_val_direct,pending_rec.ws_bdgt_iss_val_direct);
      l_sum_rec.ws_bdgt_iss_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.ws_bdgt_iss_val_all,pending_rec.ws_bdgt_iss_val_all);
      l_sum_rec.bdgt_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.bdgt_val_direct,pending_rec.bdgt_val_direct);
      l_sum_rec.bdgt_iss_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.bdgt_iss_val_direct,pending_rec.bdgt_iss_val_direct);
      l_sum_rec.stat_sal_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.stat_sal_val_direct,pending_rec.stat_sal_val_direct);
      l_sum_rec.stat_sal_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.stat_sal_val_all,pending_rec.stat_sal_val_all);
      l_sum_rec.oth_comp_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.oth_comp_val_direct,pending_rec.oth_comp_val_direct);
      l_sum_rec.oth_comp_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.oth_comp_val_all,pending_rec.oth_comp_val_all);
      l_sum_rec.tot_comp_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.tot_comp_val_direct,pending_rec.tot_comp_val_direct);
      l_sum_rec.tot_comp_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.tot_comp_val_all,pending_rec.tot_comp_val_all);
      l_sum_rec.rec_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.rec_val_direct,pending_rec.rec_val_direct);
      l_sum_rec.rec_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.rec_val_all,pending_rec.rec_val_all);
      l_sum_rec.rec_mn_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.rec_mn_val_direct,pending_rec.rec_mn_val_direct);
      l_sum_rec.rec_mn_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.rec_mn_val_all,pending_rec.rec_mn_val_all);
      l_sum_rec.rec_mx_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.rec_mx_val_direct,pending_rec.rec_mx_val_direct);
      l_sum_rec.rec_mx_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.rec_mx_val_all,pending_rec.rec_mx_val_all);
      l_sum_rec.misc1_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.misc1_val_direct,pending_rec.misc1_val_direct);
      l_sum_rec.misc1_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.misc1_val_all,pending_rec.misc1_val_all);
      l_sum_rec.misc2_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.misc2_val_direct,pending_rec.misc2_val_direct);
      l_sum_rec.misc2_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.misc2_val_all,pending_rec.misc2_val_all);
      l_sum_rec.misc3_val_direct :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.misc3_val_direct,pending_rec.misc3_val_direct);
      l_sum_rec.misc3_val_all :=ben_cwb_utils.add_number_with_null_check
             (l_sum_rec.misc3_val_all,pending_rec.misc3_val_all);

      -- Now delete the record from ben_cwb_summary as it is already
      -- consolidated
      delete from ben_cwb_summary
      where summary_id = pending_rec.summary_id;
   end loop; -- of get_pening_recs
   --
   if g_debug then
      hr_utility.set_location(l_proc, 60);
   end if;
   --
   -- if the for loop fetches atleast one record then the last summary record
   -- values will not get updated in ben_cwb_summary. So call
   -- update_or_insert again to update the values

   if (l_sum_rec.group_per_in_ler_id is not null) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      update_or_insert(l_sum_rec);
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- end of procedure consolidate_summary_rec
--
-- --------------------------------------------------------------------------
-- |--------------------< consolidate_summary_rec_all >----------------------|
-- --------------------------------------------------------------------------
--
procedure consolidate_summary_rec_all is
   --
   -- cursor to get the person ids who have split rows in
   -- summary table
   cursor csr_get_person_ids is
   select distinct(person_id) person_id
   from  ben_cwb_summary
   where status = 'P';
--
   l_proc     varchar2(72) := g_package||'consolidate_summary_rec_all';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- for each person from csr_get_per_id
   for person in csr_get_person_ids
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      -- call the process that consolidates the summary records
      -- for this person
      consolidate_summary_rec(p_person_id => person.person_id);
   end loop;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end;
--
-- --------------------------------------------------------------------------
-- |------------------------< update_person_info >--------------------------|
-- --------------------------------------------------------------------------
--
-- Internal procedure to update the correct person_id in person_info record.
--
procedure update_person_info(p_group_pl_id    in number
                            ,p_lf_evt_ocrd_dt in date) is
   -- cursor to fetch the person_id from ben_per_in_ler for
   -- group_per_in_ler_ids with -1 as person_id in ben_cwb_person_info
   cursor csr_person_ids is
   select pi.group_per_in_ler_id, pil.person_id
   from ben_cwb_person_info pi
       ,ben_per_in_ler pil
   where pi.person_id = -1
   and   pi.group_pl_id = p_group_pl_id
   and   pi.lf_evt_ocrd_dt  = p_lf_evt_ocrd_dt
   and   pi.group_per_in_ler_id = pil.per_in_ler_id
   and   pil.per_in_ler_stat_cd in ('PROCD','STRTD');
   --
  type group_per_in_ler_id_type is table of
         ben_cwb_person_info.group_per_in_ler_id%type;
  type person_id_type is table of
         ben_per_in_ler.person_id%type;
   -- declare pl/sql tables
   l_group_per_in_ler_id_tab group_per_in_ler_id_type;
   l_person_id_tab person_id_type;
   --
   l_proc     varchar2(72) :=g_package||'update_person_info';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'update_person_info';
   ben_manage_cwb_life_events.g_error_log_rec.step_number := 77;
   --
   -- Set the person id in ben_cwb_person_info to correct values from -1.
   open csr_person_ids;
   fetch csr_person_ids bulk collect into l_group_per_in_ler_id_tab
                                         ,l_person_id_tab;
   close csr_person_ids;

   if nvl(l_group_per_in_ler_id_tab.count,0) > 0 then
      forall i in l_group_per_in_ler_id_tab.first..
                l_group_per_in_ler_id_tab.last
         update ben_cwb_person_info
         set person_id = l_person_id_tab(i)
         where group_per_in_ler_id = l_group_per_in_ler_id_tab(i);

      --
      -- Run Dynamic Calculations.
      --
      ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'run_dynamic_calc';
      ben_manage_cwb_life_events.g_error_log_rec.step_number := 78;
      --
      for i in l_group_per_in_ler_id_tab.first..
               l_group_per_in_ler_id_tab.last loop
        ben_cwb_dyn_calc_pkg.run_dynamic_calculations(
            p_group_per_in_ler_id => l_group_per_in_ler_id_tab(i)
           ,p_group_pl_id         => p_group_pl_id
           ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt);
      end loop;

   end if;
   --
   l_group_per_in_ler_id_tab.delete;
   l_person_id_tab.delete;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
end update_person_info;
--
-- --------------------------------------------------------------------------
-- |-----------------------< compute_bdgts_and_all >-------------------------|
-- --------------------------------------------------------------------------
--
-- Internal procedure for computing bdgts and _all inforation
--
procedure compute_bdgts_and_all(p_group_pl_id    in number
                               ,p_lf_evt_ocrd_dt in date) is

   -- cursor to get the ws bdgt info if it is stored in %
   cursor csr_directs_ws_bdgt_in_percnt(p_group_pl_id number
                                       ,p_lf_evt_ocrd_dt date) is
   select hrchy.mgr_per_in_ler_id
     ,grp.group_pl_id
     ,grp.group_oipl_id,
     sum(grp.ws_bdgt_val * summ.elig_sal_val_direct/100)
        ws_bdgt_val_direct
     ,sum(grp.ws_bdgt_iss_val * summ.elig_sal_val_direct / 100)
           ws_bdgt_iss_val_direct
   from  ben_cwb_group_hrchy hrchy
        ,ben_cwb_person_groups grp
        ,ben_cwb_person_info   info
        ,ben_cwb_summary summ
   where info.group_pl_id = p_group_pl_id
   and info.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and info.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and hrchy.lvl_num = 1
   and hrchy.emp_per_in_ler_id = grp.group_per_in_ler_id
   and grp.group_per_in_ler_id = summ.group_per_in_ler_id
   and grp.group_pl_id = summ.group_pl_id
   and grp.group_oipl_id = summ.group_oipl_id
   group by hrchy.mgr_per_in_ler_id, grp.group_pl_id, grp.group_oipl_id;

   -- cursor to get the db bdgt and ws bdgt info, if it is stored in amount
   cursor csr_directs_bdgt_in_amt(p_group_pl_id number
                                 ,p_lf_evt_ocrd_dt date) is
   select hrchy.mgr_per_in_ler_id
     ,grp.group_pl_id
     ,grp.group_oipl_id
     ,sum(grp.ws_bdgt_val)   ws_bdgt_val_direct
     ,sum(grp.ws_bdgt_iss_val) ws_bdgt_iss_val_direct
     ,sum(decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_val,
         grp.dist_bdgt_val)) bdgt_val_direct
     ,sum(decode(nvl(grp.dist_bdgt_val,0),0, grp.ws_bdgt_iss_val,
             grp.dist_bdgt_iss_val)) bdgt_iss_val_direct
   from  ben_cwb_group_hrchy hrchy
        ,ben_cwb_person_groups grp
        ,ben_cwb_person_info info
   where info.group_pl_id = p_group_pl_id
   and info.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and info.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and hrchy.lvl_num = 1
   and hrchy.emp_per_in_ler_id = grp.group_per_in_ler_id
   group by hrchy.mgr_per_in_ler_id, grp.group_pl_id, grp.group_oipl_id;

   -- cursor to get the _all info.
   cursor csr_all_info(p_group_pl_id number
                      ,p_lf_evt_ocrd_dt date) is
   select  hrchy.mgr_per_in_ler_id
           ,summ.group_pl_id, summ.group_oipl_id
           ,sum(elig_count_direct) elig_count_all
           ,sum(emp_recv_count_direct) emp_recv_count_all
           ,sum(elig_sal_val_direct)  elig_sal_val_all
           ,sum(ws_val_direct)  ws_val_all
           ,sum(ws_bdgt_val_direct)ws_bdgt_val_all
           ,sum(ws_bdgt_iss_val_direct) ws_bdgt_iss_val_all
           ,sum(stat_sal_val_direct) stat_sal_val_all
           ,sum(oth_comp_val_direct) oth_comp_val_all
           ,sum(tot_comp_val_direct) tot_comp_val_all
           ,sum(rec_val_direct)  rec_val_all
           ,sum(rec_mn_val_direct) rec_mn_val_all
           ,sum(rec_mx_val_direct) rec_mx_val_all
           ,sum(misc1_val_direct) misc1_val_all
           ,sum(misc2_val_direct) misc2_val_all
           ,sum(misc3_val_direct) misc3_val_all
   from  ben_cwb_group_hrchy hrchy
        ,ben_cwb_summary summ
        ,ben_cwb_person_info info
   where info.group_pl_id = p_group_pl_id
   and   info.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   info.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and   hrchy.lvl_num >=0
   and   hrchy.emp_per_in_ler_id = summ.group_per_in_ler_id
   group by hrchy.mgr_per_in_ler_id, summ.group_pl_id, summ.group_oipl_id;

   -- cursor to get the bdgt info if it stored in %
   cursor csr_directs_bdgt_in_prcnt(p_group_pl_id number
                                   ,p_lf_evt_ocrd_dt date) is
   select hrchy.mgr_per_in_ler_id
         ,grp.group_pl_id
         ,grp.group_oipl_id
         ,sum(decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_val,
         grp.dist_bdgt_val)*
            decode(nvl(grp.dist_bdgt_val,0),0,summ.elig_sal_val_direct,
                   summ.elig_sal_val_all) /100) bdgt_val_direct
         ,sum(decode(nvl(grp.dist_bdgt_val,0),0, grp.ws_bdgt_iss_val,
             grp.dist_bdgt_iss_val)* decode(nvl(grp.dist_bdgt_val,0),0,
             summ.elig_sal_val_direct,summ.elig_sal_val_all) /100)
            bdgt_iss_val_direct
   from  ben_cwb_group_hrchy hrchy
        ,ben_cwb_person_groups grp
        ,ben_cwb_summary summ
        ,ben_cwb_person_info info
   where info.group_pl_id = p_group_pl_id
   and info.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and info.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and hrchy.lvl_num = 1
   and hrchy.emp_per_in_ler_id = grp.group_per_in_ler_id
   and grp.group_per_in_ler_id = summ.group_per_in_ler_id
   and grp.group_pl_id = summ.group_pl_id
   and grp.group_oipl_id = summ.group_oipl_id
   group by hrchy.mgr_per_in_ler_id, grp.group_pl_id, grp.group_oipl_id;

   -- Type delcarations for pl/sql tables
   type group_per_in_ler_id_type is table of
         ben_cwb_summary.group_per_in_ler_id%type;
   type group_pl_id_type is table of
         ben_cwb_summary.group_pl_id%type;
   type group_oipl_id_type is table of
         ben_cwb_summary.group_oipl_id%type;
   type elig_count_all_type is table of
         ben_cwb_summary.elig_count_all%type;
   type emp_recv_count_all_type is table of
         ben_cwb_summary. emp_recv_count_all%type;
   type elig_sal_val_all_type is table of
         ben_cwb_summary.elig_sal_val_all%type;
   type ws_val_all_type is table of
         ben_cwb_summary.ws_val_all%type;
   type ws_bdgt_val_direct_type is table of
         ben_cwb_summary.ws_bdgt_val_direct%type;
   type ws_bdgt_val_all_type is table of
         ben_cwb_summary.ws_bdgt_val_all%type;
   type ws_bdgt_iss_val_direct_type is table of
         ben_cwb_summary.ws_bdgt_iss_val_direct%type;
   type ws_bdgt_iss_val_all_type is table of
         ben_cwb_summary.ws_bdgt_iss_val_all%type;
   type bdgt_val_direct_type is table of
         ben_cwb_summary.bdgt_val_direct%type;
   type bdgt_iss_val_direct_type is table of
         ben_cwb_summary.bdgt_iss_val_direct%type;
   type stat_sal_val_all_type is table of
         ben_cwb_summary.stat_sal_val_all%type;
   type oth_comp_val_all_type is table of
         ben_cwb_summary.oth_comp_val_all%type;
   type tot_comp_val_all_type is table of
         ben_cwb_summary.tot_comp_val_all%type;
   type rec_val_all_type is table of
         ben_cwb_summary.rec_val_all%type;
   type rec_mn_val_all_type is table of
         ben_cwb_summary.rec_mn_val_all%type;
   type rec_mx_val_all_type is table of
         ben_cwb_summary.rec_mx_val_all%type;
   type misc1_val_all_type is table of
         ben_cwb_summary.misc1_val_all%type;
   type misc2_val_all_type is table of
         ben_cwb_summary.misc2_val_all%type;
   type misc3_val_all_type is table of
         ben_cwb_summary.misc3_val_all%type;
   type person_id_type is table of
         ben_cwb_person_info.person_id%type;
--
   -- declare pl/sql tables
   l_group_per_in_ler_id_tab group_per_in_ler_id_type;
   l_group_pl_id_tab group_pl_id_type;
   l_group_oipl_id_tab group_oipl_id_type;
   l_elig_count_all_tab  elig_count_all_type;
   l_emp_recv_count_all_tab emp_recv_count_all_type;
   l_elig_sal_val_all_tab elig_sal_val_all_type;
   l_ws_val_all_tab  ws_val_all_type;
   l_ws_bdgt_val_direct_tab ws_bdgt_val_direct_type;
   l_ws_bdgt_val_all_tab ws_bdgt_val_all_type;
   l_ws_bdgt_iss_val_direct_tab ws_bdgt_iss_val_direct_type;
   l_ws_bdgt_iss_val_all_tab ws_bdgt_iss_val_all_type;
   l_bdgt_val_direct_tab bdgt_val_direct_type;
   l_bdgt_iss_val_direct_tab bdgt_iss_val_direct_type;
   l_stat_sal_val_all_tab stat_sal_val_all_type;
   l_oth_comp_val_all_tab oth_comp_val_all_type;
   l_tot_comp_val_all_tab tot_comp_val_all_type;
   l_rec_val_all_tab rec_val_all_type;
   l_rec_mn_val_all_tab rec_mn_val_all_type;
   l_rec_mx_val_all_tab rec_mx_val_all_type;
   l_misc1_val_all_tab misc1_val_all_type;
   l_misc2_val_all_tab misc2_val_all_type;
   l_misc3_val_all_tab misc3_val_all_type;
   l_person_id_tab person_id_type;
--
   l_prsrv_bdgt_cd varchar2(30);
   l_uses_bdgt_flag varchar2(30);
--
   l_proc     varchar2(72) :=g_package||'compute_bdgts_and_all';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- get the prsrv_bdgt_cd from pl_dsgn
   select prsrv_bdgt_cd, uses_bdgt_flag
   into l_prsrv_bdgt_cd, l_uses_bdgt_flag
   from ben_cwb_pl_dsgn
   where pl_id = p_group_pl_id
   and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   oipl_id = -1;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   if l_uses_bdgt_flag = 'Y' then
   -- process the budgets summary
      --
      -- If the Preserve Budget Code is 'P' then compute ws_bdgt_val_direct
      -- and ws_bdgt_iss_val_direct.
      if l_prsrv_bdgt_cd = 'P' then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 30);
         end if;
         --
         -- bulk collect the data
         open csr_directs_ws_bdgt_in_percnt(p_group_pl_id, p_lf_evt_ocrd_dt);
         fetch csr_directs_ws_bdgt_in_percnt bulk collect into
                           l_group_per_in_ler_id_tab
                          ,l_group_pl_id_tab
                          ,l_group_oipl_id_tab
                          ,l_ws_bdgt_val_direct_tab
                          ,l_ws_bdgt_iss_val_direct_tab;
         close csr_directs_ws_bdgt_in_percnt;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --
         if nvl(l_group_per_in_ler_id_tab.count,0) > 0 then
            -- bulk update the table
            forall i in l_group_per_in_ler_id_tab.first..
            l_group_per_in_ler_id_tab.last
               update ben_cwb_summary
               set ws_bdgt_val_direct = l_ws_bdgt_val_direct_tab(i)
                  ,ws_bdgt_iss_val_direct = l_ws_bdgt_iss_val_direct_tab(i)
               where group_per_in_ler_id = l_group_per_in_ler_id_tab(i)
               and   group_pl_id = l_group_pl_id_tab(i)
               and   group_oipl_id = l_group_oipl_id_tab(i);
         end if;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 50);
         end if;
         --
         l_group_per_in_ler_id_tab.delete;
         l_group_pl_id_tab.delete;
         l_group_oipl_id_tab.delete;
         l_ws_bdgt_val_direct_tab.delete;
         l_ws_bdgt_iss_val_direct_tab.delete;

      else
         --
         if g_debug then
            hr_utility.set_location(l_proc, 60);
         end if;
         --
         -- the code is 'A', compute bdgt_val_direct, bdgt_iss_va_direct
         -- ws_bdgt_val_direct, ws_bdgt_iss_val_direct
         open csr_directs_bdgt_in_amt(p_group_pl_id, p_lf_evt_ocrd_dt);
         fetch csr_directs_bdgt_in_amt bulk collect into
                           l_group_per_in_ler_id_tab
                          ,l_group_pl_id_tab
                          ,l_group_oipl_id_tab
                          ,l_ws_bdgt_val_direct_tab
                          ,l_ws_bdgt_iss_val_direct_tab
                          ,l_bdgt_val_direct_tab
                          ,l_bdgt_iss_val_direct_tab;
         close csr_directs_bdgt_in_amt;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 70);
         end if;
         --
         if  nvl(l_group_per_in_ler_id_tab.count,0) > 0 then
            -- bulk update the table
            forall i in l_group_per_in_ler_id_tab.first..
            l_group_per_in_ler_id_tab.last
               update ben_cwb_summary
               set ws_bdgt_val_direct = l_ws_bdgt_val_direct_tab(i)
                  ,ws_bdgt_iss_val_direct = l_ws_bdgt_iss_val_direct_tab(i)
                  ,bdgt_val_direct = l_bdgt_val_direct_tab(i)
                  ,bdgt_iss_val_direct = l_bdgt_iss_val_direct_tab(i)
               where group_per_in_ler_id = l_group_per_in_ler_id_tab(i)
               and   group_pl_id = l_group_pl_id_tab(i)
               and   group_oipl_id = l_group_oipl_id_tab(i);
         end if;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 80);
         end if;
         --
         l_group_per_in_ler_id_tab.delete;
         l_group_pl_id_tab.delete;
         l_group_oipl_id_tab.delete;
         l_ws_bdgt_val_direct_tab.delete;
         l_ws_bdgt_iss_val_direct_tab.delete;
         l_bdgt_val_direct_tab.delete;
         l_bdgt_iss_val_direct_tab.delete;
      end if; -- of prsrv_bdgt_cd
   end if; -- of uses_bdgts_flag
   --
   if g_debug then
      hr_utility.set_location(l_proc, 90);
   end if;

   -- Now compute the _all information
   open csr_all_info(p_group_pl_id
                    ,p_lf_evt_ocrd_dt);
   fetch csr_all_info bulk collect into l_group_per_in_ler_id_tab
                                       ,l_group_pl_id_tab
                                       ,l_group_oipl_id_tab
                                       ,l_elig_count_all_tab
                                       ,l_emp_recv_count_all_tab
                                       ,l_elig_sal_val_all_tab
                                       ,l_ws_val_all_tab
                                       ,l_ws_bdgt_val_all_tab
                                       ,l_ws_bdgt_iss_val_all_tab
                                       ,l_stat_sal_val_all_tab
                                       ,l_oth_comp_val_all_tab
                                       ,l_tot_comp_val_all_tab
                                       ,l_rec_val_all_tab
                                       ,l_rec_mn_val_all_tab
                                       ,l_rec_mx_val_all_tab
                                       ,l_misc1_val_all_tab
                                       ,l_misc2_val_all_tab
                                       ,l_misc3_val_all_tab;
   close csr_all_info;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 100);
   end if;
   --
   if  nvl(l_group_per_in_ler_id_tab.count,0) > 0 then
      -- bulk update the data into ben_cwb_summary
      forall i in l_group_per_in_ler_id_tab.first..
         l_group_per_in_ler_id_tab.last
         update ben_cwb_summary
         set  elig_count_all = l_elig_count_all_tab(i)
             ,emp_recv_count_all = l_emp_recv_count_all_tab(i)
             ,elig_sal_val_all = l_elig_sal_val_all_tab(i)
             ,ws_val_all = l_ws_val_all_tab(i)
             ,ws_bdgt_val_all = l_ws_bdgt_val_all_tab(i)
             ,ws_bdgt_iss_val_all = l_ws_bdgt_iss_val_all_tab(i)
             ,stat_sal_val_all = l_stat_sal_val_all_tab(i)
             ,oth_comp_val_all = l_oth_comp_val_all_tab(i)
             ,tot_comp_val_all = l_tot_comp_val_all_tab(i)
             ,rec_val_all = l_rec_val_all_tab(i)
             ,rec_mn_val_all = l_rec_mn_val_all_tab(i)
             ,rec_mx_val_all = l_rec_mx_val_all_tab(i)
             ,misc1_val_all = l_misc1_val_all_tab(i)
             ,misc2_val_all = l_misc2_val_all_tab(i)
             ,misc3_val_all = l_misc3_val_all_tab(i)
         where group_per_in_ler_id = l_group_per_in_ler_id_tab(i)
         and   group_pl_id = l_group_pl_id_tab(i)
         and   group_oipl_id = l_group_oipl_id_tab(i);
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 110);
   end if;
   --
   l_group_per_in_ler_id_tab.delete;
   l_group_pl_id_tab.delete;
   l_group_oipl_id_tab.delete;
   l_elig_count_all_tab.delete;
   l_emp_recv_count_all_tab.delete;
   l_elig_sal_val_all_tab.delete;
   l_ws_val_all_tab.delete;
   l_ws_bdgt_val_all_tab.delete;
   l_ws_bdgt_iss_val_all_tab.delete;
   l_stat_sal_val_all_tab.delete;
   l_oth_comp_val_all_tab.delete;
   l_tot_comp_val_all_tab.delete;
   l_rec_val_all_tab.delete;
   l_rec_mn_val_all_tab.delete;
   l_rec_mx_val_all_tab.delete;
   l_misc1_val_all_tab.delete;
   l_misc2_val_all_tab.delete;
   l_misc3_val_all_tab.delete;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 120);
   end if;
   --
   if l_uses_bdgt_flag = 'Y' then
   -- process the budgets info
      --
      if l_prsrv_bdgt_cd = 'P' then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 130);
         end if;
         --
         -- bulk collect the data
         open csr_directs_bdgt_in_prcnt(p_group_pl_id, p_lf_evt_ocrd_dt);
         fetch csr_directs_bdgt_in_prcnt bulk collect into
                           l_group_per_in_ler_id_tab
                          ,l_group_pl_id_tab
                          ,l_group_oipl_id_tab
                          ,l_bdgt_val_direct_tab
                          ,l_bdgt_iss_val_direct_tab;
         close csr_directs_bdgt_in_prcnt;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 140);
         end if;
         --
         -- bulk update the table
         if nvl(l_group_per_in_ler_id_tab.count,0) > 0 then
            forall i in l_group_per_in_ler_id_tab.first..
            l_group_per_in_ler_id_tab.last
               update ben_cwb_summary
               set bdgt_val_direct = l_bdgt_val_direct_tab(i)
                  ,bdgt_iss_val_direct = l_bdgt_iss_val_direct_tab(i)
               where group_per_in_ler_id = l_group_per_in_ler_id_tab(i)
               and   group_pl_id = l_group_pl_id_tab(i)
               and   group_oipl_id = l_group_oipl_id_tab(i);
         end if;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 150);
         end if;
         --
         l_group_per_in_ler_id_tab.delete;
         l_group_pl_id_tab.delete;
         l_group_oipl_id_tab.delete;
         l_bdgt_val_direct_tab.delete;
         l_bdgt_iss_val_direct_tab.delete;
      end if; -- of prsrv_bdgt_cd
   end if; -- of uses_bdgt_flag
   --
   if g_debug then
       hr_utility.set_location(l_proc, 160);
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
end; -- of compute_bdgts_and_all
--
-- --------------------------------------------------------------------------
-- |----------------------< refresh_summary_group_pl >-----------------------|
-- --------------------------------------------------------------------------
procedure refresh_summary_group_pl(p_group_pl_id    in number
                                  ,p_lf_evt_ocrd_dt in date) is

   -- Cursor for retrieving directs info. No budget info
   cursor csr_directs_info is
   select hrchy.mgr_per_in_ler_id     group_per_in_ler_id
     ,rt.group_pl_id                  group_pl_id
     ,rt.group_oipl_id                group_oipl_id
     ,count(rt.group_per_in_ler_id)   elig_count_direct
     ,sum(decode(rt.ws_val,null,0,0,0,1))  emp_recv_count_direct
     ,sum(rt.elig_sal_val/decode(pl.elig_sal_nnmntry_uom,null
		,xchg.xchg_rate,1))	   elig_sal_val_direct
     ,sum(rt.ws_val/decode(pl.ws_nnmntry_uom,null
		,xchg.xchg_rate,1))       ws_val_direct
     ,sum(rt.stat_sal_val/decode(pl.stat_sal_nnmntry_uom,null
		,xchg.xchg_rate,1)) stat_sal_val_direct
     ,sum(rt.oth_comp_val/decode(pl.oth_comp_nnmntry_uom,null
		,xchg.xchg_rate,1)) oth_comp_val_direct
     ,sum(rt.tot_comp_val/decode(pl.tot_comp_nnmntry_uom,null
		,xchg.xchg_rate,1)) tot_comp_val_direct
     ,sum(rt.rec_val/decode(pl.rec_nnmntry_uom,null
		,xchg.xchg_rate,1))      rec_val_direct
     ,sum(rt.rec_mn_val/decode(pl.rec_nnmntry_uom,null
		,xchg.xchg_rate,1))   rec_mn_val_direct
     ,sum(rt.rec_mx_val/decode(pl.rec_nnmntry_uom,null
		,xchg.xchg_rate,1))   rec_mx_val_direct
     ,sum(rt.misc1_val/decode(pl.misc1_nnmntry_uom,null
		,xchg.xchg_rate,1))    misc1_val_direct
     ,sum(rt.misc2_val/decode(pl.misc2_nnmntry_uom,null
		,xchg.xchg_rate,1))    misc2_val_direct
     ,sum(rt.misc3_val/decode(pl.misc3_nnmntry_uom,null
		,xchg.xchg_rate,1))    misc3_val_direct
   from ben_cwb_group_hrchy hrchy
        ,ben_cwb_person_rates rt
        ,ben_cwb_pl_dsgn pl
	,ben_cwb_xchg xchg
   where rt.group_pl_id = p_group_pl_id
   and   rt.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   rt.elig_flag = 'Y'
   and   rt.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and   hrchy.lvl_num = 1
   and   rt.pl_id = pl.pl_id
   and   pl.oipl_id  = rt.oipl_id
   and   pl.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
   and   xchg.group_pl_id = rt.group_pl_id
   and   xchg.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
   and   xchg.currency = rt.currency
   group by hrchy.mgr_per_in_ler_id,rt.group_pl_id, rt.group_oipl_id;
--
   type group_per_in_ler_id_type is table of
      ben_cwb_summary.group_per_in_ler_id%type;
   type group_pl_id_type is table of ben_cwb_summary.group_pl_id%type;
   type group_oipl_id_type is table of ben_cwb_summary.group_oipl_id%type;
   type elig_count_direct_type is table of
      ben_cwb_summary.elig_count_direct%type;
   type emp_recv_count_direct_type is table of
      ben_cwb_summary.emp_recv_count_direct%type;
   type elig_sal_val_direct_type is table of
      ben_cwb_summary.elig_sal_val_direct%type;
   type ws_val_direct_type is table of ben_cwb_summary.ws_val_direct%type;
   type stat_sal_val_direct_type is table of
      ben_cwb_summary.stat_sal_val_direct%type;
   type oth_comp_val_direct_type is table of
      ben_cwb_summary.oth_comp_val_direct%type;
   type tot_comp_val_direct_type is table of
      ben_cwb_summary.tot_comp_val_direct%type;
   type rec_val_direct_type is table of ben_cwb_summary.rec_val_direct%type;
   type rec_mn_val_direct_type is table of
      ben_cwb_summary.rec_mn_val_direct%type;
   type rec_mx_val_direct_type is table of
      ben_cwb_summary.rec_mx_val_direct%type;
   type misc1_val_direct_type is table of
      ben_cwb_summary.misc1_val_direct%type;
   type misc2_val_direct_type is table of
      ben_cwb_summary.misc2_val_direct%type;
   type misc3_val_direct_type is table of
      ben_cwb_summary.misc3_val_direct%type;
--
   l_group_per_in_ler_id_tab group_per_in_ler_id_type;
   l_group_pl_id_tab group_pl_id_type;
   l_group_oipl_id_tab group_oipl_id_type;
   l_elig_count_direct_tab elig_count_direct_type;
   l_emp_recv_count_direct_tab emp_recv_count_direct_type;
   l_elig_sal_val_direct_tab elig_sal_val_direct_type;
   l_ws_val_direct_tab ws_val_direct_type;
   l_stat_sal_val_direct_tab stat_sal_val_direct_type;
   l_oth_comp_val_direct_tab oth_comp_val_direct_type;
   l_tot_comp_val_direct_tab tot_comp_val_direct_type;
   l_rec_val_direct_tab rec_val_direct_type;
   l_rec_mn_val_direct_tab rec_mn_val_direct_type;
   l_rec_mx_val_direct_tab rec_mx_val_direct_type;
   l_misc1_val_direct_tab misc1_val_direct_type;
   l_misc2_val_direct_tab misc2_val_direct_type;
   l_misc3_val_direct_tab misc3_val_direct_type;
--
   l_proc     varchar2(72) := g_package||'refresh_summary_group_pl';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'refresh_summary_group_pl';
   ben_manage_cwb_life_events.g_error_log_rec.step_number := 711;
   --
   check_refresh_jobs(p_group_pl_id    => p_group_pl_id
                     ,p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt);
   --
  begin
   --
   insert_refresh_job_marker(p_group_pl_id    => p_group_pl_id
                            ,p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt);
   --
   -- delete all the summary rows from ben_cwb_summary for
   -- this group_pl_id and lf_evt_ocrd_dt
   delete from ben_cwb_summary  summ
   where group_pl_id = p_group_pl_id
   and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and group_per_in_ler_id <> -1;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   -- Insert an empty summary row for each managers. This summary row
   -- will contain only the group_per_in_ler_id, group_pl_id, group_oipl_id,
   -- person_id and lf_evt_ocrd_dt
   insert into ben_cwb_summary
            (summary_id
            ,group_per_in_ler_id
            ,group_pl_id
            ,group_oipl_id
            ,person_id
            ,lf_evt_ocrd_dt)
            select ben_cwb_summary_s.nextval
	           ,hrchy.emp_per_in_ler_id
                   ,p_group_pl_id
                   ,grp.group_oipl_id
                   ,pil.person_id
                   ,p_lf_evt_ocrd_dt
             from ben_cwb_group_hrchy hrchy
                 ,ben_cwb_person_groups grp
                 ,ben_per_in_ler pil
             where hrchy.lvl_num=0
             and hrchy.emp_per_in_ler_id = grp.group_per_in_ler_id
             and pil.group_pl_id = p_group_pl_id
             and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
             and grp.group_per_in_ler_id = pil.per_in_ler_id
	     and pil.per_in_ler_stat_cd in ('PROCD','STRTD');

   --
   if g_debug then
      hr_utility.set_location(l_proc, 30);
   end if;
   --
   -- get the directs info
   open csr_directs_info;
   fetch csr_directs_info bulk collect into l_group_per_in_ler_id_tab
                                           ,l_group_pl_id_tab
                                           ,l_group_oipl_id_tab
                                           ,l_elig_count_direct_tab
                                           ,l_emp_recv_count_direct_tab
                                           ,l_elig_sal_val_direct_tab
                                           ,l_ws_val_direct_tab
                                           ,l_stat_sal_val_direct_tab
                                           ,l_oth_comp_val_direct_tab
                                           ,l_tot_comp_val_direct_tab
                                           ,l_rec_val_direct_tab
                                           ,l_rec_mn_val_direct_tab
                                           ,l_rec_mx_val_direct_tab
                                           ,l_misc1_val_direct_tab
                                           ,l_misc2_val_direct_tab
                                           ,l_misc3_val_direct_tab;
   close csr_directs_info;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 40);
   end if;
   --
   if (nvl(l_group_per_in_ler_id_tab.count,0) > 0)then
      forall i in l_group_per_in_ler_id_tab.first..
            l_group_per_in_ler_id_tab.last
         update ben_cwb_summary
         set elig_count_direct     = l_elig_count_direct_tab(i)
            ,emp_recv_count_direct = l_emp_recv_count_direct_tab(i)
            ,elig_sal_val_direct   = l_elig_sal_val_direct_tab(i)
	    ,ws_val_direct         = l_ws_val_direct_tab(i)
            ,stat_sal_val_direct   = l_stat_sal_val_direct_tab(i)
            ,oth_comp_val_direct   = l_oth_comp_val_direct_tab(i)
            ,tot_comp_val_direct   = l_tot_comp_val_direct_tab(i)
            ,rec_val_direct        = l_rec_val_direct_tab(i)
            ,rec_mn_val_direct     = l_rec_mn_val_direct_tab(i)
            ,rec_mx_val_direct     = l_rec_mx_val_direct_tab(i)
            ,misc1_val_direct      = l_misc1_val_direct_tab(i)
            ,misc2_val_direct      = l_misc2_val_direct_tab(i)
            ,misc3_val_direct      = l_misc3_val_direct_tab(i)
	 where group_per_in_ler_id = l_group_per_in_ler_id_tab(i)
         and   group_pl_id         = l_group_pl_id_tab(i)
         and   group_oipl_id       = l_group_oipl_id_tab(i);

      --
      -- delete the pl_sql tables
      l_group_per_in_ler_id_tab.delete;
      l_group_pl_id_tab.delete;
      l_group_oipl_id_tab.delete;
      l_elig_count_direct_tab.delete;
      l_emp_recv_count_direct_tab.delete;
      l_elig_sal_val_direct_tab.delete;
      l_ws_val_direct_tab.delete;
      l_stat_sal_val_direct_tab.delete;
      l_oth_comp_val_direct_tab.delete;
      l_tot_comp_val_direct_tab.delete;
      l_rec_val_direct_tab.delete;
      l_rec_mn_val_direct_tab.delete;
      l_rec_mx_val_direct_tab.delete;
      l_misc1_val_direct_tab.delete;
      l_misc2_val_direct_tab.delete;
      l_misc3_val_direct_tab.delete;

      -- Call the compute_bdgts_and_all procedure to compute the Bdgets and
      -- and _all information.
      compute_bdgts_and_all(p_group_pl_id
                           ,p_lf_evt_ocrd_dt);
   end if;
   -- Now the summary is populated. Set the person id in ben_cwb_person_info
   -- to correct values from -1.
   update_person_info(p_group_pl_id,p_lf_evt_ocrd_dt);
   --
   delete_refresh_job_marker(p_group_pl_id    => p_group_pl_id
                            ,p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt);
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
  exception
    when others then
      delete_refresh_job_marker(p_group_pl_id    => p_group_pl_id
                               ,p_lf_evt_ocrd_dt => p_lf_evt_ocrd_dt);
      raise;
  end;
end refresh_summary_group_pl; -- of refresh_summary_group_pl
--
-- --------------------------------------------------------------------------
-- |---------------------< update_budgets_summary >-------------------------|
-- --------------------------------------------------------------------------
-- This procedure is used by reassign_mgr and reassign_emp to compute the
-- budgts of a given person. Before calling this procedure, save_pl_sql_tab
-- should be called to transfer the data in pl/sql tables to the database.
--
procedure update_budgets_summary(p_group_per_in_ler_id in number
                                ,p_prsrv_bdgt_cd in varchar2
                                ,p_only_all in boolean default false) is

   -- cursor to compute the prcnt bdgts direct
   cursor csr_prcnt_bdgts_direct(p_group_per_in_ler_id number) is
   select grp.group_pl_id group_pl_id
         ,grp.group_oipl_id group_oipl_id
         ,sum(grp.ws_bdgt_val * summ.elig_sal_val_direct / 100)
                  ws_bdgt_val_direct
         ,sum(grp.ws_bdgt_iss_val * summ.elig_sal_val_direct / 100)
                  ws_bdgt_iss_val_direct
         ,sum(decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_val,
          grp.dist_bdgt_val) * decode(nvl(grp.dist_bdgt_val,0),0,
          summ.elig_sal_val_direct, summ.elig_sal_val_all) / 100)
                  bdgt_val_direct
         ,sum(decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_iss_val,
          grp.dist_bdgt_iss_val) * decode(nvl(grp.dist_bdgt_val,0),0,
          summ.elig_sal_val_direct, summ.elig_sal_val_all) / 100)
               bdgt_iss_val_direct
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_person_groups grp
       ,ben_cwb_summary summ
   where hrchy.mgr_per_in_ler_id = p_group_per_in_ler_id
   and   hrchy.lvl_num = 1
   and   grp.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and   summ.group_per_in_ler_id (+)= grp.group_per_in_ler_id
   and   summ.group_pl_id (+)= grp.group_pl_id
   and   summ.group_oipl_id (+)= grp.group_oipl_id
   group by grp.group_pl_id, grp.group_oipl_id
   order by grp.group_pl_id, grp.group_oipl_id;

   -- cursor to compute the amount bdgts direct
   cursor csr_amt_bdgts_direct(p_group_per_in_ler_id number) is
   select grp.group_pl_id group_pl_id
         ,grp.group_oipl_id group_oipl_id
         ,sum(grp.ws_bdgt_val) ws_bdgt_val_direct
         ,sum(grp.ws_bdgt_iss_val) ws_bdgt_iss_val_direct
         ,sum(decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_val,
          grp.dist_bdgt_val)) bdgt_val_direct
         ,sum(decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_iss_val,
          grp.dist_bdgt_iss_val)) bdgt_iss_val_direct
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_person_groups grp
   where hrchy.mgr_per_in_ler_id = p_group_per_in_ler_id
   and   hrchy.lvl_num = 1
   and   grp.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   group by grp.group_pl_id, grp.group_oipl_id
   order by grp.group_pl_id, grp.group_oipl_id;

   -- cursor to compute the prcnt ws_bdgt_all
   cursor csr_prcnt_ws_bdgts_all(p_group_per_in_ler_id number) is
   select grp.group_pl_id group_pl_id
         ,grp.group_oipl_id group_oipl_id
         ,sum(grp.ws_bdgt_val * summ.elig_sal_val_direct / 100)
                  ws_bdgt_val_all
         ,sum(grp.ws_bdgt_iss_val * summ.elig_sal_val_direct / 100)
                  ws_bdgt_iss_val_all
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_person_groups grp
       ,ben_cwb_summary summ
   where hrchy.mgr_per_in_ler_id = p_group_per_in_ler_id
   and   hrchy.lvl_num >= 1
   and   grp.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and   summ.group_per_in_ler_id (+)= grp.group_per_in_ler_id
   and   summ.group_pl_id (+)= grp.group_pl_id
   and   summ.group_oipl_id (+)= grp.group_oipl_id
   group by grp.group_pl_id, grp.group_oipl_id
   order by grp.group_pl_id, grp.group_oipl_id;

   -- cursor to compute the amount ws_bdgt_all
   cursor csr_amt_ws_bdgts_all(p_group_per_in_ler_id number) is
   select grp.group_pl_id group_pl_id
         ,grp.group_oipl_id group_oipl_id
         ,sum(grp.ws_bdgt_val) ws_bdgt_val_all
         ,sum(grp.ws_bdgt_iss_val) ws_bdgt_iss_val_all
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_person_groups grp
   where hrchy.mgr_per_in_ler_id = p_group_per_in_ler_id
   and   hrchy.lvl_num >= 1
   and   grp.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   group by grp.group_pl_id, grp.group_oipl_id
   order by grp.group_pl_id, grp.group_oipl_id;

   -- cursor to fetch the old summary
   cursor csr_old_bdgts_summary(p_group_per_in_ler_id number) is
   select sum(ws_bdgt_val_direct) ws_bdgt_val_direct
         ,sum(ws_bdgt_val_all) ws_bdgt_val_all
         ,sum(ws_bdgt_iss_val_direct) ws_bdgt_iss_val_direct
         ,sum(ws_bdgt_iss_val_all) ws_bdgt_iss_val_all
         ,sum(bdgt_val_direct) bdgt_val_direct
         ,sum(bdgt_iss_val_direct) bdgt_iss_val
   from ben_cwb_summary
   where group_per_in_ler_id = p_group_per_in_ler_id
   group by group_pl_id, group_oipl_id
   order by group_pl_id, group_oipl_id;
--
   -- Type delcarations for pl/sql tables
   type group_pl_id_type is table of
         ben_cwb_summary.group_pl_id%type;
   type group_oipl_id_type is table of
         ben_cwb_summary.group_oipl_id%type;
   type ws_bdgt_val_direct_type is table of
         ben_cwb_summary.ws_bdgt_val_direct%type;
   type ws_bdgt_val_all_type is table of
         ben_cwb_summary.ws_bdgt_val_all%type;
   type ws_bdgt_iss_val_direct_type is table of
         ben_cwb_summary.ws_bdgt_iss_val_direct%type;
   type ws_bdgt_iss_val_all_type is table of
         ben_cwb_summary.ws_bdgt_iss_val_all%type;
   type bdgt_val_direct_type is table of
         ben_cwb_summary.bdgt_val_direct%type;
   type bdgt_iss_val_direct_type is table of
         ben_cwb_summary.bdgt_iss_val_direct%type;
--
   l_group_pl_id_tab group_pl_id_type;
   l_group_oipl_id_tab group_oipl_id_type;
   l_ws_bdgt_val_direct_tab ws_bdgt_val_direct_type;
   l_ws_bdgt_val_all_tab ws_bdgt_val_all_type;
   l_ws_bdgt_iss_val_direct_tab ws_bdgt_iss_val_direct_type;
   l_ws_bdgt_iss_val_all_tab ws_bdgt_iss_val_all_type;
   l_bdgt_val_direct_tab bdgt_val_direct_type;
   l_bdgt_iss_val_direct_tab bdgt_iss_val_direct_type;
   l_old_ws_bdgt_val_direct_tab ws_bdgt_val_direct_type;
   l_old_ws_bdgt_val_all_tab ws_bdgt_val_all_type;
   l_old_ws_bdgt_iss_val_dir_tab ws_bdgt_iss_val_direct_type;
   l_old_ws_bdgt_iss_val_all_tab ws_bdgt_iss_val_all_type;
   l_old_bdgt_val_direct_tab bdgt_val_direct_type;
   l_old_bdgt_iss_val_direct_tab bdgt_iss_val_direct_type;
--
   l_proc     varchar2(72) := g_package||'update_budgets_summary';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- get the Ws Bdgt Direct and Dist Bdgt Direct
   if p_prsrv_bdgt_cd = 'P' then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      if not (p_only_all) then
        open csr_prcnt_bdgts_direct(p_group_per_in_ler_id);
        fetch csr_prcnt_bdgts_direct bulk collect into
                                   l_group_pl_id_tab
                                  ,l_group_oipl_id_tab
                                  ,l_ws_bdgt_val_direct_tab
                                  ,l_ws_bdgt_iss_val_direct_tab
                                  ,l_bdgt_val_direct_tab
                                  ,l_bdgt_iss_val_direct_tab;
        close csr_prcnt_bdgts_direct;
      end if;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      open csr_prcnt_ws_bdgts_all(p_group_per_in_ler_id);
      fetch csr_prcnt_ws_bdgts_all bulk collect into
                                 l_group_pl_id_tab
                                ,l_group_oipl_id_tab
                                ,l_ws_bdgt_val_all_tab
                                ,l_ws_bdgt_iss_val_all_tab;
      close csr_prcnt_ws_bdgts_all;
   else
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      if not (p_only_all) then
        open csr_amt_bdgts_direct(p_group_per_in_ler_id);
        fetch csr_amt_bdgts_direct bulk collect into
                                   l_group_pl_id_tab
                                  ,l_group_oipl_id_tab
                                  ,l_ws_bdgt_val_direct_tab
                                  ,l_ws_bdgt_iss_val_direct_tab
                                  ,l_bdgt_val_direct_tab
                                  ,l_bdgt_iss_val_direct_tab;
        close csr_amt_bdgts_direct;
      end if;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      open csr_amt_ws_bdgts_all(p_group_per_in_ler_id);
      fetch csr_amt_ws_bdgts_all bulk collect into
                                 l_group_pl_id_tab
                                ,l_group_oipl_id_tab
                                ,l_ws_bdgt_val_all_tab
                                ,l_ws_bdgt_iss_val_all_tab;
      close csr_amt_ws_bdgts_all;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 60);
   end if;
   --
   -- get the old bdgts summary
   open csr_old_bdgts_summary(p_group_per_in_ler_id);
   fetch csr_old_bdgts_summary bulk collect into
                              l_old_ws_bdgt_val_direct_tab
                             ,l_old_ws_bdgt_val_all_tab
                             ,l_old_ws_bdgt_iss_val_dir_tab
                             ,l_old_ws_bdgt_iss_val_all_tab
                             ,l_old_bdgt_val_direct_tab
                             ,l_old_bdgt_iss_val_direct_tab;
   close csr_old_bdgts_summary;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 70);
   end if;
   --
   if nvl(l_group_pl_id_tab.count,0) = 0 then
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 79);
      end if;
      -- no records to process
      return;
   end if;
   --
   for i in l_group_pl_id_tab.first..l_group_pl_id_tab.last
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 80);
         hr_utility.set_location('grp pil :'||p_group_per_in_ler_id,85);
         hr_utility.set_location('Ws bdgt All :'||l_ws_bdgt_val_all_tab(i),85);
         hr_utility.set_location('Ws bdgt Iss All  :'||l_ws_bdgt_iss_val_all_tab(i),85);
      end if;
      --
      -- call the update_or_insert_pl_sql_tab with the diff
      if not (p_only_all) then
        update_or_insert_pl_sql_tab
           (p_group_per_in_ler_id => p_group_per_in_ler_id
           ,p_group_pl_id         => l_group_pl_id_tab(i)
           ,p_group_oipl_id       => l_group_oipl_id_tab(i)
           ,p_ws_bdgt_val_direct  => ben_cwb_utils.add_number_with_null_check
                                     (l_ws_bdgt_val_direct_tab(i),
                                      -l_old_ws_bdgt_val_direct_tab(i))
           ,p_ws_bdgt_val_all     => ben_cwb_utils.add_number_with_null_check
                                     (l_ws_bdgt_val_all_tab(i),
                                      -l_old_ws_bdgt_val_all_tab(i))
           ,p_ws_bdgt_iss_val_direct => ben_cwb_utils.add_number_with_null_check
                                        (l_ws_bdgt_iss_val_direct_tab(i),
                                         -l_old_ws_bdgt_iss_val_dir_tab(i))
           ,p_ws_bdgt_iss_val_all  => ben_cwb_utils.add_number_with_null_check
                                      (l_ws_bdgt_iss_val_all_tab(i),
                                       -l_old_ws_bdgt_iss_val_all_tab(i))
           ,p_bdgt_val_direct     => ben_cwb_utils.add_number_with_null_check
                                     (l_bdgt_val_direct_tab(i),
                                      -l_old_bdgt_val_direct_tab(i))
           ,p_bdgt_iss_val_direct => ben_cwb_utils.add_number_with_null_check
                                     (l_bdgt_iss_val_direct_tab(i),
                                      -l_old_bdgt_iss_val_direct_tab(i)));
     else
       update_or_insert_pl_sql_tab
           (p_group_per_in_ler_id => p_group_per_in_ler_id
           ,p_group_pl_id         => l_group_pl_id_tab(i)
           ,p_group_oipl_id       => l_group_oipl_id_tab(i)
           ,p_ws_bdgt_val_all     => ben_cwb_utils.add_number_with_null_check
                                     (l_ws_bdgt_val_all_tab(i),
                                      -l_old_ws_bdgt_val_all_tab(i))
           ,p_ws_bdgt_iss_val_all  => ben_cwb_utils.add_number_with_null_check
                                      (l_ws_bdgt_iss_val_all_tab(i),
                                       -l_old_ws_bdgt_iss_val_all_tab(i)));
     end if;
   end loop;
   --
   -- call save_pl_sql_tab to transfer from pl/sql table to database
   save_pl_sql_tab;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 90);
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- update_budgets_summary
--
-- --------------------------------------------------------------------------
-- |----------------------< refresh_summary_persons >-----------------------|
-- --------------------------------------------------------------------------
--
procedure refresh_summary_persons(p_group_pl_id    in number
                                 ,p_lf_evt_ocrd_dt in date) is

   -- cursor of employees which were processed in the current run
   cursor csr_emps is
    select per.group_per_in_ler_id
          ,hrchy.mgr_per_in_ler_id
   from ben_cwb_person_info per
       ,ben_cwb_group_hrchy hrchy
   where per.person_id = -1
   and   per.group_pl_id = p_group_pl_id
   and   per.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   per.group_per_in_ler_id = hrchy.emp_per_in_ler_id (+)
   and   per.group_per_in_ler_id = hrchy.mgr_per_in_ler_id (+);

   -- cursor for computing the empty summary rows for managers
   cursor csr_empty_summary(p_group_pl_id number
                           ,p_lf_evt_ocrd_dt date)is
   select hrchy.mgr_per_in_ler_id
         ,p_group_pl_id group_pl_id
         ,grp.group_oipl_id
         ,pil.person_id
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_person_info per
       ,ben_cwb_person_groups grp
       ,ben_per_in_ler pil
   where per.person_id = -1
   and   per.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and   hrchy.mgr_per_in_ler_id = grp.group_per_in_ler_id
   and   grp.group_pl_id = p_group_pl_id
   and   grp.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   grp.group_per_in_ler_id = pil.per_in_ler_id
   and   pil.per_in_ler_stat_cd in ('PROCD','STRTD')
   and   not exists (select 'Y'
                     from   ben_cwb_summary sm
                     where sm.group_per_in_ler_id = grp.group_per_in_ler_id
                     and   sm.group_pl_id = grp.group_pl_id
                     and   sm.group_oipl_id = grp.group_oipl_id)
   group by hrchy.mgr_per_in_ler_id, group_oipl_id, pil.person_id;
   -- Cursor for retrieving directs info. No budget info
   cursor csr_directs_info(v_group_per_in_ler_id in number) is
   select hrchy.mgr_per_in_ler_id     group_per_in_ler_id
     ,rt.group_pl_id                  group_pl_id
     ,rt.group_oipl_id                group_oipl_id
     ,count(rt.group_per_in_ler_id)   elig_count
     ,sum(decode(rt.ws_val,null,0,0,0,1))  emp_recv_count
     ,sum(rt.elig_sal_val/decode(pl.elig_sal_nnmntry_uom,null
                ,xchg.xchg_rate,1))        elig_sal_val
     ,sum(rt.ws_val/decode(pl.ws_nnmntry_uom,null
                ,xchg.xchg_rate,1))       ws_val
     ,sum(rt.stat_sal_val/decode(pl.stat_sal_nnmntry_uom,null
                ,xchg.xchg_rate,1)) stat_sal_val
     ,sum(rt.oth_comp_val/decode(pl.oth_comp_nnmntry_uom,null
                ,xchg.xchg_rate,1)) oth_comp_val
     ,sum(rt.tot_comp_val/decode(pl.tot_comp_nnmntry_uom,null
                ,xchg.xchg_rate,1)) tot_comp_val
     ,sum(rt.rec_val/decode(pl.rec_nnmntry_uom,null
                ,xchg.xchg_rate,1))      rec_val
     ,sum(rt.rec_mn_val/decode(pl.rec_nnmntry_uom,null
                ,xchg.xchg_rate,1))   rec_mn_val
     ,sum(rt.rec_mx_val/decode(pl.rec_nnmntry_uom,null
                ,xchg.xchg_rate,1))   rec_mx_val
     ,sum(rt.misc1_val/decode(pl.misc1_nnmntry_uom,null
                ,xchg.xchg_rate,1))    misc1_val
     ,sum(rt.misc2_val/decode(pl.misc2_nnmntry_uom,null
                ,xchg.xchg_rate,1))    misc2_val
     ,sum(rt.misc3_val/decode(pl.misc3_nnmntry_uom,null
                ,xchg.xchg_rate,1))    misc3_val
   from ben_cwb_group_hrchy hrchy
        ,ben_cwb_person_rates rt
        ,ben_cwb_pl_dsgn pl
        ,ben_cwb_xchg xchg
   where hrchy.mgr_per_in_ler_id = v_group_per_in_ler_id
   and   rt.group_per_in_ler_id = hrchy.emp_per_in_ler_id
   and   hrchy.lvl_num = 1
   and   rt.elig_flag = 'Y'
   and   rt.pl_id = pl.pl_id
   and   pl.oipl_id  = rt.oipl_id
   and   pl.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
   and   xchg.group_pl_id = rt.group_pl_id
   and   xchg.lf_evt_ocrd_dt = rt.lf_evt_ocrd_dt
   and   xchg.currency = rt.currency
   group by hrchy.mgr_per_in_ler_id,rt.group_pl_id, rt.group_oipl_id;
   -- cursor to get the _all info.
   cursor csr_all_info(v_group_per_in_ler_id number) is
   select  hrchy.mgr_per_in_ler_id
           ,summ.group_pl_id, summ.group_oipl_id
           ,sum(elig_count_direct) elig_count
           ,sum(emp_recv_count_direct) emp_recv_count
           ,sum(elig_sal_val_direct)  elig_sal_val
           ,sum(ws_val_direct)  ws_val
           ,sum(ws_bdgt_val_direct)ws_bdgt_val
           ,sum(ws_bdgt_iss_val_direct) ws_bdgt_iss_val
           ,sum(stat_sal_val_direct) stat_sal_val
           ,sum(oth_comp_val_direct) oth_comp_val
           ,sum(tot_comp_val_direct) tot_comp_val
           ,sum(rec_val_direct)  rec_val
           ,sum(rec_mn_val_direct) rec_mn_val
           ,sum(rec_mx_val_direct) rec_mx_val
           ,sum(misc1_val_direct) misc1_val
           ,sum(misc2_val_direct) misc2_val
           ,sum(misc3_val_direct) misc3_val
   from  ben_cwb_group_hrchy hrchy
        ,ben_cwb_summary summ
   where hrchy.mgr_per_in_ler_id = v_group_per_in_ler_id
   and   hrchy.lvl_num >=0
   and   hrchy.emp_per_in_ler_id = summ.group_per_in_ler_id
   group by hrchy.mgr_per_in_ler_id, summ.group_pl_id, summ.group_oipl_id;
   --
   cursor csr_mgrs_info(v_per_in_ler_id in number) is
    select h.mgr_per_in_ler_id
          ,h.lvl_num
          ,i.person_id
    from   ben_cwb_group_hrchy h
          ,ben_cwb_person_info i
    where  h.emp_per_in_ler_id = v_per_in_ler_id
    and    h.lvl_num > 0
    and    h.mgr_per_in_ler_id = i.group_per_in_ler_id
    order by h.lvl_num;
   --
   l_prsrv_bdgt_cd varchar2(30);
   l_uses_bdgt_flag varchar2(30);
   l_count          number;
   l_immd_mgr       number;
--
   l_proc     varchar2(72) := g_package||'refresh_summary_persons';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   -- Need to execute this procedure only when the number of persons with
   -- person_id as -1 is less. If records are more, call the procedure
   -- refresh_summary_group_pl

   select count(per.group_per_in_ler_id) into l_count
   from ben_cwb_person_info per
   where per.person_id = -1
   and   per.group_pl_id = p_group_pl_id
   and   per.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

   if l_count = 0 then
     -- No new life event.
     return;
   elsif l_count > 2 then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 15);
      end if;
      -- call the refresh_summary_group_pl to improve performance
      ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'refresh_summary_group_pl';
      ben_manage_cwb_life_events.g_error_log_rec.step_number := 71;
      --
     refresh_summary_group_pl(p_group_pl_id, p_lf_evt_ocrd_dt);
     --
     return;
     --
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   ben_manage_cwb_life_events.g_error_log_rec.calling_proc :=
                      'refresh_summary_persons';
   ben_manage_cwb_life_events.g_error_log_rec.step_number := 72;
   --
   -- Insert an empty summary row for each managers. This summary row
   -- will contain only the group_per_in_ler_id, group_pl_id, group_oipl_id,
   -- person_id and lf_evt_ocrd_dt
   for l_empty_summ in csr_empty_summary(p_group_pl_id,p_lf_evt_ocrd_dt) loop
     --
     insert into ben_cwb_summary
                (summary_id
                ,group_per_in_ler_id
                ,group_pl_id
                ,group_oipl_id
                ,person_id
                ,lf_evt_ocrd_dt)
      values    (ben_cwb_summary_s.nextval
                ,l_empty_summ.mgr_per_in_ler_id
                ,l_empty_summ.group_pl_id
                ,l_empty_summ.group_oipl_id
                ,l_empty_summ.person_id
                ,p_lf_evt_ocrd_dt);
     --
   end loop;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 30);
   end if;
   --
   for l_emps in csr_emps loop
     --
     for l_rates in csr_rates(l_emps.group_per_in_ler_id) loop
       --
       l_immd_mgr := 1;
       --
       for l_mgrs in csr_mgrs_info(l_emps.group_per_in_ler_id) loop
         -- If the manager is also part of the current summary refresh,
         -- it will be taken care by manager's summary.
         if l_mgrs.person_id = -1 then
           exit;
         end if;
         --
         update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id => l_mgrs.mgr_per_in_ler_id
            ,p_group_pl_id         => l_rates.group_pl_id
            ,p_group_oipl_id       => l_rates.group_oipl_id
            ,p_elig_count_direct   => l_rates.elig_count*l_immd_mgr
            ,p_elig_count_all      => l_rates.elig_count
            ,p_emp_recv_count_direct => l_rates.emp_recv_count*l_immd_mgr
            ,p_emp_recv_count_all  => l_rates.emp_recv_count
            ,p_elig_sal_val_direct => l_rates.elig_sal_val*l_immd_mgr
            ,p_elig_sal_val_all    => l_rates.elig_sal_val
            ,p_ws_val_direct       => l_rates.ws_val*l_immd_mgr
            ,p_ws_val_all          => l_rates.ws_val
            ,p_stat_sal_val_direct => l_rates.stat_sal_val*l_immd_mgr
            ,p_stat_sal_val_all    => l_rates.stat_sal_val
            ,p_oth_comp_val_direct => l_rates.oth_comp_val*l_immd_mgr
            ,p_oth_comp_val_all    => l_rates.oth_comp_val
            ,p_tot_comp_val_direct => l_rates.tot_comp_val*l_immd_mgr
            ,p_tot_comp_val_all    => l_rates.tot_comp_val
            ,p_rec_val_direct      => l_rates.rec_val*l_immd_mgr
            ,p_rec_val_all         => l_rates.rec_val
            ,p_rec_mn_val_direct   => l_rates.rec_mn_val*l_immd_mgr
            ,p_rec_mn_val_all      => l_rates.rec_mn_val
            ,p_rec_mx_val_direct   => l_rates.rec_mx_val*l_immd_mgr
            ,p_rec_mx_val_all      => l_rates.rec_mx_val
            ,p_misc1_val_direct    => l_rates.misc1_val*l_immd_mgr
            ,p_misc1_val_all       => l_rates.misc1_val
            ,p_misc2_val_direct    => l_rates.misc2_val*l_immd_mgr
            ,p_misc2_val_all       => l_rates.misc2_val
            ,p_misc3_val_direct    => l_rates.misc3_val*l_immd_mgr
            ,p_misc3_val_all       => l_rates.misc3_val);

         l_immd_mgr := 0;
         --
       end loop; --mgrs
       --
     end loop; -- rates
     --
     if l_emps.mgr_per_in_ler_id is not null then
       --
       -- The person is a manager, so take care of it's direct summary
       --
       for l_directs in csr_directs_info(l_emps.group_per_in_ler_id) loop
          update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id => l_emps.group_per_in_ler_id
            ,p_group_pl_id         => l_directs.group_pl_id
            ,p_group_oipl_id       => l_directs.group_oipl_id
            ,p_elig_count_direct   => l_directs.elig_count
            ,p_emp_recv_count_direct => l_directs.emp_recv_count
            ,p_elig_sal_val_direct => l_directs.elig_sal_val
            ,p_ws_val_direct       => l_directs.ws_val
            ,p_stat_sal_val_direct => l_directs.stat_sal_val
            ,p_oth_comp_val_direct => l_directs.oth_comp_val
            ,p_tot_comp_val_direct => l_directs.tot_comp_val
            ,p_rec_val_direct      => l_directs.rec_val
            ,p_rec_mn_val_direct   => l_directs.rec_mn_val
            ,p_rec_mx_val_direct   => l_directs.rec_mx_val
            ,p_misc1_val_direct    => l_directs.misc1_val
            ,p_misc2_val_direct    => l_directs.misc2_val
            ,p_misc3_val_direct    => l_directs.misc3_val);
       end loop; --directs
     end if;
   end loop; -- emps
   --
   save_pl_sql_tab;
   --
   for l_emps in csr_emps loop
     if l_emps.mgr_per_in_ler_id is not null then
       --
       -- The person is a manager, so take care of it's all summary
       --
       for l_all in csr_all_info(l_emps.group_per_in_ler_id) loop
         update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id => l_emps.group_per_in_ler_id
            ,p_group_pl_id         => l_all.group_pl_id
            ,p_group_oipl_id       => l_all.group_oipl_id
            ,p_elig_count_all      => l_all.elig_count
            ,p_emp_recv_count_all  => l_all.emp_recv_count
            ,p_elig_sal_val_all    => l_all.elig_sal_val
            ,p_ws_val_all          => l_all.ws_val
            ,p_stat_sal_val_all    => l_all.stat_sal_val
            ,p_oth_comp_val_all    => l_all.oth_comp_val
            ,p_tot_comp_val_all    => l_all.tot_comp_val
            ,p_rec_val_all         => l_all.rec_val
            ,p_rec_mn_val_all      => l_all.rec_mn_val
            ,p_rec_mx_val_all      => l_all.rec_mx_val
            ,p_misc1_val_all       => l_all.misc1_val
            ,p_misc2_val_all       => l_all.misc2_val
            ,p_misc3_val_all       => l_all.misc3_val);
          --
          for l_mgrs in csr_mgrs_info(l_emps.group_per_in_ler_id) loop
            -- If the manager is also part of the current summary refresh,
            -- it will be taken care by manager's summary.
            if l_mgrs.person_id = -1 then
              exit;
            end if;
            --
            update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id => l_mgrs.mgr_per_in_ler_id
            ,p_group_pl_id         => l_all.group_pl_id
            ,p_group_oipl_id       => l_all.group_oipl_id
            ,p_elig_count_all      => l_all.elig_count
            ,p_emp_recv_count_all  => l_all.emp_recv_count
            ,p_elig_sal_val_all    => l_all.elig_sal_val
            ,p_ws_val_all          => l_all.ws_val
            ,p_stat_sal_val_all    => l_all.stat_sal_val
            ,p_oth_comp_val_all    => l_all.oth_comp_val
            ,p_tot_comp_val_all    => l_all.tot_comp_val
            ,p_rec_val_all         => l_all.rec_val
            ,p_rec_mn_val_all      => l_all.rec_mn_val
            ,p_rec_mx_val_all      => l_all.rec_mx_val
            ,p_misc1_val_all       => l_all.misc1_val
            ,p_misc2_val_all       => l_all.misc2_val
            ,p_misc3_val_all       => l_all.misc3_val);
          end loop; --mgrs
       end loop; -- all
     end if;
     --
   end loop; --emps
   --
   select prsrv_bdgt_cd, uses_bdgt_flag
   into l_prsrv_bdgt_cd, l_uses_bdgt_flag
   from ben_cwb_pl_dsgn
   where pl_id = p_group_pl_id
   and   lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   oipl_id = -1;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 90);
   end if;

   -- check if the uses_bdgt_flag is set
   if l_uses_bdgt_flag = 'Y' then
     --
     save_pl_sql_tab;
     --
     for l_emps in csr_emps loop
       --
       for l_mgrs in csr_mgrs(l_emps.group_per_in_ler_id) loop
         --
         -- After 2 levels, only need to update all level budget.
         --
         update_budgets_summary(l_mgrs.mgr_per_in_ler_id,l_prsrv_bdgt_cd,
                                (l_mgrs.lvl_num > 2));
       end loop;
       --
     end loop;
   end if; -- of uses_bdgt_flag
   --
   if g_debug then
      hr_utility.set_location(l_proc, 160);
   end if;
   --
   save_pl_sql_tab;
   --
   --
   -- Now the summary is populated. Set the person id in ben_cwb_person_info
   -- to correct values from -1.
   update_person_info(p_group_pl_id,p_lf_evt_ocrd_dt);
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
end; -- of refresh_summary_persons
--
-- --------------------------------------------------------------------------
-- |--------------------< update_or_insert_pl_sql_tab >----------------------|
-- --------------------------------------------------------------------------
--
procedure update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id     in number
            ,p_group_pl_id             in number
            ,p_group_oipl_id           in number
            ,p_elig_count_direct       in number default null
            ,p_elig_count_all          in number default null
            ,p_emp_recv_count_direct   in number default null
            ,p_emp_recv_count_all      in number default null
            ,p_elig_sal_val_direct     in number default null
            ,p_elig_sal_val_all        in number default null
            ,p_ws_val_direct           in number default null
            ,p_ws_val_all              in number default null
            ,p_ws_bdgt_val_direct      in number default null
            ,p_ws_bdgt_val_all         in number default null
            ,p_ws_bdgt_iss_val_direct  in number default null
            ,p_ws_bdgt_iss_val_all     in number default null
            ,p_bdgt_val_direct         in number default null
            ,p_bdgt_iss_val_direct     in number default null
            ,p_stat_sal_val_direct     in number default null
            ,p_stat_sal_val_all        in number default null
            ,p_oth_comp_val_direct     in number default null
            ,p_oth_comp_val_all        in number default null
            ,p_tot_comp_val_direct     in number default null
            ,p_tot_comp_val_all        in number default null
            ,p_rec_val_direct          in number default null
            ,p_rec_val_all             in number default null
            ,p_rec_mn_val_direct       in number default null
            ,p_rec_mn_val_all          in number default null
            ,p_rec_mx_val_direct       in number default null
            ,p_rec_mx_val_all          in number default null
            ,p_misc1_val_direct        in number default null
            ,p_misc1_val_all           in number default null
            ,p_misc2_val_direct        in number default null
            ,p_misc2_val_all           in number default null
            ,p_misc3_val_direct        in number default null
            ,p_misc3_val_all           in number default null
            ,p_person_id               in number default null
            ,p_lf_evt_ocrd_dt          in date default null) is
--
   l_found boolean := false;
   j binary_integer;
--
   l_proc     varchar2(72) := g_package||'update_or_insert_pl_sql_tab';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   hr_utility.set_location('Count :'||g_summary_rec.count,20);
   --
   if nvl(g_summary_rec.count,0) > 0 then
      for i in g_summary_rec.first..g_summary_rec.last
      loop
         if(g_summary_rec(i).group_per_in_ler_id = p_group_per_in_ler_id and
            g_summary_rec(i).group_pl_id = p_group_pl_id and
            g_summary_rec(i).group_oipl_id = p_group_oipl_id) then
         --
            l_found := true;
            j := i;
            exit;
         end if;
      end loop;
   end if;
   --
   if (l_found) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      -- record alredy exists. So update the summary
      g_summary_rec(j).elig_count_direct := ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).elig_count_direct,p_elig_count_direct);
      g_summary_rec(j).elig_count_all := ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).elig_count_all,p_elig_count_all);
      g_summary_rec(j).emp_recv_count_direct := ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).emp_recv_count_direct,p_emp_recv_count_direct);
      g_summary_rec(j).emp_recv_count_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).emp_recv_count_all,p_emp_recv_count_all);
      g_summary_rec(j).elig_sal_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).elig_sal_val_direct,p_elig_sal_val_direct);
      g_summary_rec(j).elig_sal_val_all := ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).elig_sal_val_all,p_elig_sal_val_all);
      g_summary_rec(j).ws_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).ws_val_direct,p_ws_val_direct);
      g_summary_rec(j).ws_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).ws_val_all,p_ws_val_all);
      g_summary_rec(j).ws_bdgt_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).ws_bdgt_val_direct,p_ws_bdgt_val_direct);
      g_summary_rec(j).ws_bdgt_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).ws_bdgt_val_all,p_ws_bdgt_val_all);
      g_summary_rec(j).ws_bdgt_iss_val_direct := ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).ws_bdgt_iss_val_direct,p_ws_bdgt_iss_val_direct);
      g_summary_rec(j).ws_bdgt_iss_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).ws_bdgt_iss_val_all,p_ws_bdgt_iss_val_all);
      g_summary_rec(j).bdgt_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).bdgt_val_direct,p_bdgt_val_direct);
      g_summary_rec(j).bdgt_iss_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).bdgt_iss_val_direct,p_bdgt_iss_val_direct);
      g_summary_rec(j).stat_sal_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).stat_sal_val_direct,p_stat_sal_val_direct);
      g_summary_rec(j).stat_sal_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).stat_sal_val_all,p_stat_sal_val_all);
      g_summary_rec(j).oth_comp_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).oth_comp_val_direct,p_oth_comp_val_direct);
      g_summary_rec(j).oth_comp_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).oth_comp_val_all,p_oth_comp_val_all);
      g_summary_rec(j).tot_comp_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).tot_comp_val_direct,p_tot_comp_val_direct);
      g_summary_rec(j).tot_comp_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).tot_comp_val_all,p_tot_comp_val_all);
      g_summary_rec(j).rec_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).rec_val_direct,p_rec_val_direct);
      g_summary_rec(j).rec_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).rec_val_all,p_rec_val_all);
      g_summary_rec(j).rec_mn_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).rec_mn_val_direct,p_rec_mn_val_direct);
      g_summary_rec(j).rec_mn_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).rec_mn_val_all,p_rec_mn_val_all);
      g_summary_rec(j).rec_mx_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).rec_mx_val_direct,p_rec_mx_val_direct);
      g_summary_rec(j).rec_mx_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).rec_mx_val_all,p_rec_mx_val_all);
      g_summary_rec(j).misc1_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).misc1_val_direct,p_misc1_val_direct);
      g_summary_rec(j).misc1_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).misc1_val_all,p_misc1_val_all);
      g_summary_rec(j).misc2_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).misc2_val_direct,p_misc2_val_direct);
      g_summary_rec(j).misc2_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).misc2_val_all,p_misc2_val_all);
      g_summary_rec(j).misc3_val_direct :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).misc3_val_direct,p_misc3_val_direct);
      g_summary_rec(j).misc3_val_all :=ben_cwb_utils.add_number_with_null_check
             (g_summary_rec(j).misc3_val_all,p_misc3_val_all);
      g_summary_rec(j).person_id:=nvl(p_person_id,g_summary_rec(j).person_id);
      g_summary_rec(j).lf_evt_ocrd_dt:=nvl(p_lf_evt_ocrd_dt,g_summary_rec(j).lf_evt_ocrd_dt);
   else
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      if nvl(g_summary_rec.count,0) > 0 then
         j := g_summary_rec.last + 1;
      else
         j :=1;
      end if;
      -- insert the new record.
      g_summary_rec(j).group_per_in_ler_id    := p_group_per_in_ler_id;
      g_summary_rec(j).group_pl_id            := p_group_pl_id;
      g_summary_rec(j).group_oipl_id          := p_group_oipl_id;
      g_summary_rec(j).elig_count_direct      := p_elig_count_direct;
      g_summary_rec(j).elig_count_all         := p_elig_count_all;
      g_summary_rec(j).emp_recv_count_direct  := p_emp_recv_count_direct;
      g_summary_rec(j).emp_recv_count_all     := p_emp_recv_count_all;
      g_summary_rec(j).elig_sal_val_direct    := p_elig_sal_val_direct;
      g_summary_rec(j).elig_sal_val_all       := p_elig_sal_val_all;
      g_summary_rec(j).ws_val_direct          := p_ws_val_direct;
      g_summary_rec(j).ws_val_all             := p_ws_val_all;
      g_summary_rec(j).ws_bdgt_val_direct     := p_ws_bdgt_val_direct;
      g_summary_rec(j).ws_bdgt_val_all        := p_ws_bdgt_val_all;
      g_summary_rec(j).ws_bdgt_iss_val_direct := p_ws_bdgt_iss_val_direct;
      g_summary_rec(j).ws_bdgt_iss_val_all    := p_ws_bdgt_iss_val_all;
      g_summary_rec(j).bdgt_val_direct        := p_bdgt_val_direct;
      g_summary_rec(j).bdgt_iss_val_direct    := p_bdgt_iss_val_direct;
      g_summary_rec(j).stat_sal_val_direct    := p_stat_sal_val_direct;
      g_summary_rec(j).stat_sal_val_all       := p_stat_sal_val_all;
      g_summary_rec(j).oth_comp_val_direct    := p_oth_comp_val_direct;
      g_summary_rec(j).oth_comp_val_all       := p_oth_comp_val_all;
      g_summary_rec(j).tot_comp_val_direct    := p_tot_comp_val_direct;
      g_summary_rec(j).tot_comp_val_all       := p_tot_comp_val_all;
      g_summary_rec(j).rec_val_direct         := p_rec_val_direct;
      g_summary_rec(j).rec_val_all            := p_rec_val_all;
      g_summary_rec(j).rec_mn_val_direct      := p_rec_mn_val_direct;
      g_summary_rec(j).rec_mn_val_all         := p_rec_mn_val_all;
      g_summary_rec(j).rec_mx_val_direct      := p_rec_mx_val_direct;
      g_summary_rec(j).rec_mx_val_all         := p_rec_mx_val_all;
      g_summary_rec(j).misc1_val_direct       := p_misc1_val_direct;
      g_summary_rec(j).misc1_val_all          := p_misc1_val_all;
      g_summary_rec(j).misc2_val_direct       := p_misc2_val_direct;
      g_summary_rec(j).misc2_val_all          := p_misc2_val_all;
      g_summary_rec(j).misc3_val_direct       := p_misc3_val_direct;
      g_summary_rec(j).misc3_val_all          := p_misc3_val_all;
      g_summary_rec(j).person_id              := p_person_id;
      g_summary_rec(j).lf_evt_ocrd_dt         := p_lf_evt_ocrd_dt;
   end if; -- of l_found
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end;  -- update_or_insert_pl_sql_tab
--
-- --------------------------------------------------------------------------
-- |---------------------------< save_pl_sql_tab >---------------------------|
-- --------------------------------------------------------------------------
procedure save_pl_sql_tab is
--
   l_proc     varchar2(72) := g_package||'save_pl_sql_tab';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if nvl(g_summary_rec.count,0) = 0 then
      return;
   end if;
   --
   for i in g_summary_rec.first..g_summary_rec.last
   loop
      update_or_insert(g_summary_rec(i));
   end loop;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   g_summary_rec.delete;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- save_pl_sql_tab
--
-- --------------------------------------------------------------------------
-- |--------------------------< delete_pl_sql_tab >--------------------------|
-- --------------------------------------------------------------------------
procedure delete_pl_sql_tab is
--
   l_proc     varchar2(72) := g_package||'delete_pl_sql_tab';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   g_summary_rec.delete;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- delete_pl_sql_tab
--
--
-- --------------------------------------------------------------------------
-- |--------------------------< clean_budget_data >-------------------------|
-- --------------------------------------------------------------------------
procedure clean_budget_data(p_per_in_ler_id in number
                           ,p_lvl_up        in number default null) is
  --
  l_proc          varchar2(72) := g_package||'clean_budget_data';
  l_per_in_ler_id number       := null;
  --
  cursor c_mgr_id is
    select hrchy.mgr_per_in_ler_id
    from   ben_cwb_group_hrchy hrchy
    where  hrchy.emp_per_in_ler_id = p_per_in_ler_id
    and    hrchy.lvl_num           = p_lvl_up;
  --
  cursor c_summary is
    select sum(sm.elig_count_all)-sum(sm.elig_count_direct) indirect_count
          ,sum(sm.elig_count_all) all_count
          ,max(grp.bdgt_pop_cd)   bdgt_pop_cd
    from   ben_cwb_summary sm
          ,ben_cwb_person_groups grp
    where  sm.group_per_in_ler_id = l_per_in_ler_id
    and    sm.group_oipl_id       = -1
    and    sm.group_per_in_ler_id = grp.group_per_in_ler_id
    and    sm.group_pl_id         = grp.group_pl_id
    and    sm.group_oipl_id       = grp.group_oipl_id;
  l_summary c_summary%rowtype;
  --
  cursor c_grps is
     select grp.group_pl_id
           ,grp.group_oipl_id
           ,grp.lf_evt_ocrd_dt
           ,grp.object_version_number
           ,grp.dist_bdgt_val
           ,grp.dist_bdgt_iss_val
           ,grp.ws_bdgt_val
           ,grp.ws_bdgt_iss_val
           ,grp.ws_bdgt_iss_date
     from ben_cwb_person_groups grp
     where  grp.group_per_in_ler_id = l_per_in_ler_id;
   --
   cursor c_mgr_pop_cd is
      select grp.bdgt_pop_cd
      from   ben_cwb_group_hrchy hrchy
            ,ben_cwb_person_groups grp
      where  hrchy.emp_per_in_ler_id = l_per_in_ler_id
      and    hrchy.mgr_per_in_ler_id = grp.group_per_in_ler_id
      and    hrchy.lvl_num           = 1
      and    grp.group_oipl_id       = -1;
  --
  l_is_hlm boolean          := false;
  l_mgr_pop_cd varchar2(30) := null;
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --

  if p_lvl_up is not null then
    open  c_mgr_id;
    fetch c_mgr_id into l_per_in_ler_id;
    close c_mgr_id;
  else
    l_per_in_ler_id := p_per_in_ler_id;
  end if;
  --
  if l_per_in_ler_id is null then
    return;
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  open  c_summary;
  fetch c_summary into l_summary;
  close c_summary;

  --
  if l_summary.indirect_count > 0 then
    l_is_hlm := true;
  end if;
  --
  if l_is_hlm and l_summary.bdgt_pop_cd is not null then
    -- Is now an HLM and has already done budgeting, so no status change.
    return;
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  for l_grps in c_grps loop

    if l_summary.all_count < 1 then
      -- No longer a manager.
      -- Remove the worksheet and dist bdgt.
      ben_cwb_person_groups_api.update_group_budget(
           p_group_per_in_ler_id   => l_per_in_ler_id
          ,p_group_pl_id           => l_grps.group_pl_id
          ,p_group_oipl_id         => l_grps.group_oipl_id
          ,p_lf_evt_ocrd_dt        => l_grps.lf_evt_ocrd_dt
          ,p_bdgt_pop_cd           => null
          ,p_dist_bdgt_val         => null
          ,p_dist_bdgt_iss_val     => null
          ,p_dist_bdgt_iss_date    => null
          ,p_ws_bdgt_val           => null
          ,p_ws_bdgt_iss_val       => null
          ,p_ws_bdgt_iss_date      => null
          ,p_object_version_number => l_grps.object_version_number
          ,p_perf_min_max_edit     => 'N');
      --
    elsif not(l_is_hlm) and
       (l_grps.dist_bdgt_val is not null or
        l_grps.dist_bdgt_iss_val is not null) then
      -- Is LLM and has distribution budget.
      -- Null them.
      if g_debug then
        hr_utility.set_location(l_proc, 40);
      end if;
      --
      ben_cwb_person_groups_api.update_group_budget(
           p_group_per_in_ler_id   => l_per_in_ler_id
          ,p_group_pl_id           => l_grps.group_pl_id
          ,p_group_oipl_id         => l_grps.group_oipl_id
          ,p_lf_evt_ocrd_dt        => l_grps.lf_evt_ocrd_dt
          ,p_bdgt_pop_cd           => null
          ,p_dist_bdgt_val         => null
          ,p_dist_bdgt_iss_val     => null
          ,p_dist_bdgt_iss_date    => null
          ,p_object_version_number => l_grps.object_version_number
          ,p_perf_min_max_edit     => 'N');
      --
    elsif l_is_hlm and l_summary.bdgt_pop_cd is null and
          nvl(l_grps.dist_bdgt_val,0) = 0 and
          (nvl(l_grps.ws_bdgt_val,0) <> 0 or
           nvl(l_grps.ws_bdgt_iss_val,0) <> 0) then
      -- Is HLM and has Worksheet Budget and no distribution budget.
      -- Check if they are allowed to budget
      -- A person is allowed to Budget only when they are HLM and the
      -- manager above them have a budgeting population of "Direct Managers"
      if g_debug then
        hr_utility.set_location(l_proc, 50);
      end if;
      --
      open  c_mgr_pop_cd;
      fetch c_mgr_pop_cd into l_mgr_pop_cd;
      close c_mgr_pop_cd;

      if l_mgr_pop_cd = 'D' then
        -- Copy the worksheet budget to distribution budget.
        ben_cwb_person_groups_api.update_group_budget(
           p_group_per_in_ler_id   => l_per_in_ler_id
          ,p_group_pl_id           => l_grps.group_pl_id
          ,p_group_oipl_id         => l_grps.group_oipl_id
          ,p_lf_evt_ocrd_dt        => l_grps.lf_evt_ocrd_dt
          ,p_bdgt_pop_cd           => 'D'
          ,p_dist_bdgt_val         => l_grps.ws_bdgt_val
          ,p_dist_bdgt_iss_val     => l_grps.ws_bdgt_iss_val
          ,p_dist_bdgt_iss_date    => l_grps.ws_bdgt_iss_date
          ,p_object_version_number => l_grps.object_version_number
          ,p_perf_min_max_edit     => 'N');
      end if;
    end if;

  end loop; --c_grps

  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 999);
  end if;
  --

end clean_budget_data;

--
-- --------------------------------------------------------------------------
-- |----------------------------< reassign_mgr >-----------------------------|
-- --------------------------------------------------------------------------
procedure reassign_mgr(p_old_mgr_per_in_ler_id in number
                      ,p_new_mgr_per_in_ler_id in number
                      ,p_emp_per_in_ler_id     in number) is


   -- Type delcarations for pl/sql tables
   type group_pl_id_type is table of
         ben_cwb_summary.group_pl_id%type index by binary_integer;
   type group_oipl_id_type is table of
         ben_cwb_summary.group_oipl_id%type index by binary_integer;
   type elig_count_direct_type is table of
         ben_cwb_summary.elig_count_direct%type index by binary_integer;
   type elig_count_all_type is table of
         ben_cwb_summary.elig_count_all%type index by binary_integer;
   type emp_recv_count_direct_type is table of
         ben_cwb_summary.emp_recv_count_direct%type index by binary_integer;
   type emp_recv_count_all_type is table of
         ben_cwb_summary. emp_recv_count_all%type index by binary_integer;
   type elig_sal_val_all_type is table of
         ben_cwb_summary.elig_sal_val_all%type index by binary_integer;
   type ws_val_direct_type is table of
         ben_cwb_summary.ws_val_direct%type index by binary_integer;
   type ws_val_all_type is table of
         ben_cwb_summary.ws_val_all%type index by binary_integer;
   type stat_sal_val_direct_type is table of
         ben_cwb_summary.stat_sal_val_direct%type index by binary_integer;
   type stat_sal_val_all_type is table of
         ben_cwb_summary.stat_sal_val_all%type index by binary_integer;
   type oth_comp_val_direct_type is table of
         ben_cwb_summary.oth_comp_val_direct%type index by binary_integer;
   type oth_comp_val_all_type is table of
         ben_cwb_summary.oth_comp_val_all%type index by binary_integer;
   type tot_comp_val_direct_type is table of
         ben_cwb_summary.tot_comp_val_direct%type index by binary_integer;
   type tot_comp_val_all_type is table of
         ben_cwb_summary.tot_comp_val_all%type index by binary_integer;
   type rec_val_direct_type is table of
         ben_cwb_summary.rec_val_direct%type index by binary_integer;
   type rec_val_all_type is table of
         ben_cwb_summary.rec_val_all%type index by binary_integer;
   type rec_mn_val_direct_type is table of
         ben_cwb_summary.rec_mn_val_direct%type index by binary_integer;
   type rec_mn_val_all_type is table of
         ben_cwb_summary.rec_mn_val_all%type index by binary_integer;
   type rec_mx_val_direct_type is table of
         ben_cwb_summary.rec_mx_val_direct%type index by binary_integer;
   type rec_mx_val_all_type is table of
         ben_cwb_summary.rec_mx_val_all%type index by binary_integer;
   type misc1_val_direct_type is table of
         ben_cwb_summary.misc1_val_direct%type index by binary_integer;
   type misc1_val_all_type is table of
         ben_cwb_summary.misc1_val_all%type index by binary_integer;
   type misc2_val_direct_type is table of
         ben_cwb_summary.misc2_val_direct%type index by binary_integer;
   type misc2_val_all_type is table of
         ben_cwb_summary.misc2_val_all%type index by binary_integer;
   type misc3_val_direct_type is table of
         ben_cwb_summary.misc3_val_direct%type index by binary_integer;
   type misc3_val_all_type is table of
         ben_cwb_summary.misc3_val_all%type index by binary_integer;
   type person_id_type is table of
         ben_cwb_summary.person_id%type index by binary_integer;
--
   -- declare pl/sql tables
   l_rts_group_pl_id_tab group_pl_id_type;
   l_rts_group_oipl_id_tab group_oipl_id_type;
   l_all_group_pl_id_tab group_pl_id_type;
   l_all_group_oipl_id_tab group_oipl_id_type;
   --
   l_elig_count_tab elig_count_direct_type;
   l_elig_count_all_tab  elig_count_all_type;
   l_emp_recv_count_tab emp_recv_count_direct_type;
   l_emp_recv_count_all_tab emp_recv_count_all_type;
   l_elig_sal_val_tab elig_sal_val_all_type;
   l_elig_sal_val_all_tab elig_sal_val_all_type;
   l_ws_val_tab ws_val_direct_type;
   l_ws_val_all_tab  ws_val_all_type;
   l_stat_sal_val_tab stat_sal_val_direct_type;
   l_stat_sal_val_all_tab stat_sal_val_all_type;
   l_oth_comp_val_tab oth_comp_val_direct_type;
   l_oth_comp_val_all_tab oth_comp_val_all_type;
   l_tot_comp_val_tab tot_comp_val_direct_type;
   l_tot_comp_val_all_tab tot_comp_val_all_type;
   l_rec_val_tab rec_val_direct_type;
   l_rec_val_all_tab rec_val_all_type;
   l_rec_mn_val_tab rec_mn_val_direct_type;
   l_rec_mn_val_all_tab rec_mn_val_all_type;
   l_rec_mx_val_tab rec_mx_val_direct_type;
   l_rec_mx_val_all_tab rec_mx_val_all_type;
   l_misc1_val_tab misc1_val_direct_type;
   l_misc1_val_all_tab misc1_val_all_type;
   l_misc2_val_tab misc2_val_direct_type;
   l_misc2_val_all_tab misc2_val_all_type;
   l_misc3_val_tab misc3_val_direct_type;
   l_misc3_val_all_tab misc3_val_all_type;
--
   l_immd_mgr number;
   l_last_mgr_id number;
   l_prsrv_bdgt_cd varchar2(1);
   l_uses_bdgt_flag varchar2(1);
--
   l_proc     varchar2(72) := g_package||'reassign_mgr';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   open csr_rates(p_emp_per_in_ler_id);
   fetch csr_rates bulk collect into l_rts_group_pl_id_tab
                                    ,l_rts_group_oipl_id_tab
                                    ,l_elig_count_tab
                                    ,l_emp_recv_count_tab
                                    ,l_elig_sal_val_tab
                                    ,l_ws_val_tab
                                    ,l_stat_sal_val_tab
                                    ,l_oth_comp_val_tab
                                    ,l_tot_comp_val_tab
                                    ,l_rec_val_tab
                                    ,l_rec_mn_val_tab
                                    ,l_rec_mx_val_tab
                                    ,l_misc1_val_tab
                                    ,l_misc2_val_tab
                                    ,l_misc3_val_tab;
   close csr_rates;

   open csr_summary(p_emp_per_in_ler_id);
   fetch csr_summary bulk collect into l_all_group_pl_id_tab
                    ,l_all_group_oipl_id_tab
                    ,l_elig_count_all_tab
                    ,l_emp_recv_count_all_tab
                    ,l_elig_sal_val_all_tab
                    ,l_ws_val_all_tab
                    ,l_stat_sal_val_all_tab
                    ,l_oth_comp_val_all_tab
                    ,l_tot_comp_val_all_tab
                    ,l_rec_val_all_tab
                    ,l_rec_mn_val_all_tab
                    ,l_rec_mx_val_all_tab
                    ,l_misc1_val_all_tab
                    ,l_misc2_val_all_tab
                    ,l_misc3_val_all_tab;
   close csr_summary;
   --
   if nvl(l_rts_group_pl_id_tab.count,0) = 0 then
      -- though the person is not having person_rates record, the person
      -- may be having eligible employees reporting to him. so insert 0
      for j in l_all_group_pl_id_tab.first .. l_all_group_pl_id_tab.last
      loop
         l_rts_group_pl_id_tab(j) := l_all_group_pl_id_tab(j);
         l_rts_group_oipl_id_tab(j) := l_all_group_oipl_id_tab(j);
         l_elig_count_tab(j) := 0;
         l_emp_recv_count_tab(j) := 0;
         l_elig_sal_val_tab(j) := null;
         l_ws_val_tab(j) := null;
         l_stat_sal_val_tab(j) := null;
         l_oth_comp_val_tab(j) := null;
         l_tot_comp_val_tab(j) := null;
         l_rec_val_tab(j) := null;
         l_rec_mn_val_tab(j) := null;
         l_rec_mx_val_tab(j) := null;
         l_misc1_val_tab(j) := null;
         l_misc2_val_tab(j) := null;
         l_misc3_val_tab(j) :=null;
      end loop;
   end if;
   --
   if nvl(l_rts_group_pl_id_tab.count,0) = 0 then
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 99);
      end if;
      -- no records to process. return
      return;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   l_immd_mgr := 1;
   for mgr in csr_mgr_ids(p_old_mgr_per_in_ler_id
                     ,p_new_mgr_per_in_ler_id) loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --
         for i in l_rts_group_pl_id_tab.first..l_rts_group_pl_id_tab.last
         loop
            update_or_insert_pl_sql_tab
               (p_group_per_in_ler_id => mgr.mgr_per_in_ler_id
               ,p_group_pl_id         => l_rts_group_pl_id_tab(i)
               ,p_group_oipl_id       => l_rts_group_oipl_id_tab(i)
               ,p_elig_count_direct   => -(l_elig_count_tab(i)) *
                                          l_immd_mgr
               ,p_elig_count_all      => -(nvl(l_elig_count_tab(i),0)
                                     + nvl(l_elig_count_all_tab(i),0))
               ,p_emp_recv_count_direct => -(l_emp_recv_count_tab(i)) *
                                          l_immd_mgr
               ,p_emp_recv_count_all  =>
                              -(nvl(l_emp_recv_count_tab(i),0) +
                                nvl(l_emp_recv_count_all_tab(i),0))
               ,p_elig_sal_val_direct => -(l_elig_sal_val_tab(i))  *
                                          l_immd_mgr
               ,p_elig_sal_val_all    => - ben_cwb_utils.add_number_with_null_check
                                          (l_elig_sal_val_tab(i),
                                           l_elig_sal_val_all_tab(i))
               ,p_ws_val_direct       =>-(l_ws_val_tab(i)) * l_immd_mgr
               ,p_ws_val_all          => - ben_cwb_utils.add_number_with_null_check
                                          (l_ws_val_tab(i),
                                           l_ws_val_all_tab(i))
               ,p_stat_sal_val_direct => -(l_stat_sal_val_tab(i)) *
                                          l_immd_mgr
               ,p_stat_sal_val_all    => - ben_cwb_utils.add_number_with_null_check
                                          (l_stat_sal_val_tab(i),
                                           l_stat_sal_val_all_tab(i))
               ,p_oth_comp_val_direct => -(l_oth_comp_val_tab(i)) *
                                          l_immd_mgr
               ,p_oth_comp_val_all    => - ben_cwb_utils.add_number_with_null_check
                                          (l_oth_comp_val_tab(i),
                                           l_oth_comp_val_all_tab(i))
               ,p_tot_comp_val_direct => -(l_tot_comp_val_tab(i)) *
                                          l_immd_mgr
               ,p_tot_comp_val_all    =>  - ben_cwb_utils.add_number_with_null_check
                                          (l_tot_comp_val_tab(i),
                                           l_tot_comp_val_all_tab(i))
               ,p_rec_val_direct      => -(l_rec_val_tab(i)) *
                                          l_immd_mgr
               ,p_rec_val_all         =>  - ben_cwb_utils.add_number_with_null_check
                                          (l_rec_val_tab(i),
                                           l_rec_val_all_tab(i))
               ,p_rec_mn_val_direct   => -(l_rec_mn_val_tab(i)) *
                                          l_immd_mgr
               ,p_rec_mn_val_all      =>  - ben_cwb_utils.add_number_with_null_check
                                          (l_rec_mn_val_tab(i),
                                           l_rec_mn_val_all_tab(i))
               ,p_rec_mx_val_direct   => -(l_rec_mx_val_tab(i)) *
                                          l_immd_mgr
               ,p_rec_mx_val_all      =>  - ben_cwb_utils.add_number_with_null_check
                                          (l_rec_mx_val_tab(i),
                                           l_rec_mx_val_all_tab(i))
               ,p_misc1_val_direct    => -(l_misc1_val_tab(i)) *
                                          l_immd_mgr
               ,p_misc1_val_all       => - ben_cwb_utils.add_number_with_null_check
                                          (l_misc1_val_tab(i),
                                           l_misc1_val_all_tab(i))
               ,p_misc2_val_direct    => -(l_misc2_val_tab(i)) *
                                          l_immd_mgr
               ,p_misc2_val_all       =>  - ben_cwb_utils.add_number_with_null_check
                                          (l_misc2_val_tab(i),
                                           l_misc2_val_all_tab(i))
               ,p_misc3_val_direct    => -(l_misc3_val_all_tab(i)) *
                                          l_immd_mgr
               ,p_misc3_val_all       => - ben_cwb_utils.add_number_with_null_check
                                          (l_misc3_val_tab(i),
                                           l_misc3_val_all_tab(i))
               );
         end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      -- Now change the l_immd_mgr value to false
      l_immd_mgr := 0;
   end loop; -- of csr_mgr_ids cursor
   --
   if g_debug then
      hr_utility.set_location(l_proc, 60);
   end if;
   --

   -- Now add the values to new manager hierarchy
   l_immd_mgr := 1;
   for mgr in csr_mgr_ids(p_new_mgr_per_in_ler_id
                     ,p_old_mgr_per_in_ler_id) loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 70);
      end if;
         for i in l_rts_group_pl_id_tab.first..l_rts_group_pl_id_tab.last
         loop
            update_or_insert_pl_sql_tab
               (p_group_per_in_ler_id => mgr.mgr_per_in_ler_id
               ,p_group_pl_id         => l_rts_group_pl_id_tab(i)
               ,p_group_oipl_id       => l_rts_group_oipl_id_tab(i)
               ,p_elig_count_direct   => (l_elig_count_tab(i)) *
                                          l_immd_mgr
               ,p_elig_count_all      => (nvl(l_elig_count_tab(i),0)
                                     + nvl(l_elig_count_all_tab(i),0))
               ,p_emp_recv_count_direct => (l_emp_recv_count_tab(i)) *
                                          l_immd_mgr
               ,p_emp_recv_count_all  =>
                              (nvl(l_emp_recv_count_tab(i),0) +
                                nvl(l_emp_recv_count_all_tab(i),0))
               ,p_elig_sal_val_direct => (l_elig_sal_val_tab(i))  *
                                          l_immd_mgr
               ,p_elig_sal_val_all    => ben_cwb_utils.add_number_with_null_check
                                          (l_elig_sal_val_tab(i),
                                           l_elig_sal_val_all_tab(i))
               ,p_ws_val_direct       =>(l_ws_val_tab(i)) * l_immd_mgr
               ,p_ws_val_all          => ben_cwb_utils.add_number_with_null_check
                                          (l_ws_val_tab(i),
                                           l_ws_val_all_tab(i))
               ,p_stat_sal_val_direct => (l_stat_sal_val_tab(i)) *
                                          l_immd_mgr
               ,p_stat_sal_val_all    => ben_cwb_utils.add_number_with_null_check
                                          (l_stat_sal_val_tab(i),
                                           l_stat_sal_val_all_tab(i))
               ,p_oth_comp_val_direct => (l_oth_comp_val_tab(i)) *
                                          l_immd_mgr
               ,p_oth_comp_val_all    => ben_cwb_utils.add_number_with_null_check
                                          (l_oth_comp_val_tab(i),
                                           l_oth_comp_val_all_tab(i))
               ,p_tot_comp_val_direct => (l_tot_comp_val_tab(i)) *
                                          l_immd_mgr
               ,p_tot_comp_val_all    => ben_cwb_utils.add_number_with_null_check
                                          (l_tot_comp_val_tab(i),
                                           l_tot_comp_val_all_tab(i))
               ,p_rec_val_direct      => (l_rec_val_tab(i)) *
                                          l_immd_mgr
               ,p_rec_val_all         => ben_cwb_utils.add_number_with_null_check
                                          (l_rec_val_tab(i),
                                           l_rec_val_all_tab(i))
               ,p_rec_mn_val_direct   => (l_rec_mn_val_tab(i)) *
                                          l_immd_mgr
               ,p_rec_mn_val_all      => ben_cwb_utils.add_number_with_null_check
                                          (l_rec_mn_val_tab(i),
                                           l_rec_mn_val_all_tab(i))
               ,p_rec_mx_val_direct   => (l_rec_mx_val_tab(i)) *
                                          l_immd_mgr
               ,p_rec_mx_val_all      => ben_cwb_utils.add_number_with_null_check
                                          (l_rec_mx_val_tab(i),
                                           l_rec_mx_val_all_tab(i))
               ,p_misc1_val_direct    => (l_misc1_val_tab(i)) *
                                          l_immd_mgr
               ,p_misc1_val_all       => ben_cwb_utils.add_number_with_null_check
                                          (l_misc1_val_tab(i),
                                           l_misc1_val_all_tab(i))
               ,p_misc2_val_direct    => (l_misc2_val_tab(i)) *
                                          l_immd_mgr
               ,p_misc2_val_all       => ben_cwb_utils.add_number_with_null_check
                                          (l_misc2_val_tab(i),
                                           l_misc2_val_all_tab(i))
               ,p_misc3_val_direct    => (l_misc3_val_all_tab(i)) *
                                          l_immd_mgr
               ,p_misc3_val_all       => ben_cwb_utils.add_number_with_null_check
                                          (l_misc3_val_tab(i),
                                           l_misc3_val_all_tab(i))
               );
         end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 80);
      end if;
      --
      --
      -- Now change the l_immd_mgr value to false
      l_immd_mgr := 0;
   end loop; -- of csr_mgr_ids cursor
   --
   if g_debug then
      hr_utility.set_location(l_proc, 90);
   end if;
   --
   -- Bug 3812624. Added nvl to p_new_mgr_per_in_ler_id. Atleast one of them
   -- is always not null.

   --
   -- Now update the budgets
   --
   select pl.prsrv_bdgt_cd
         ,pl.uses_bdgt_flag
   into l_prsrv_bdgt_cd
       ,l_uses_bdgt_flag
   from ben_cwb_pl_dsgn pl
       ,ben_cwb_person_groups grp
   where grp.group_per_in_ler_id = nvl(p_new_mgr_per_in_ler_id,p_old_mgr_per_in_ler_id)
   and   grp.group_oipl_id = -1
   and   pl.pl_id = grp.group_pl_id
   and   pl.oipl_id = grp.group_oipl_id
   and   pl.lf_evt_ocrd_dt = grp.lf_evt_ocrd_dt;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 100);
   end if;
   --
   if l_uses_bdgt_flag = 'N' then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 109);
      end if;
      --
      -- Budgets are not used. So no processing required.
      return;
   end if;
   --
   -- call the save_pl_sql_tab to transfer the data in the pl/sql tab
   -- to the database. This is required to for computing the budgets
   -- correctly.
   save_pl_sql_tab;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 110);
   end if;
   --
   -- update the budgets in the old mgr hiearchy
   --
   for mgr in csr_mgr_ids(p_old_mgr_per_in_ler_id
                     ,p_new_mgr_per_in_ler_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 120);
      end if;
      --
      -- If lvl_num = 0,1 , do everything
      -- For lvl_num > 1, only all.
      --
      -- call update_budgets_summary to update the budgets for this manager
      --
      update_budgets_summary(mgr.mgr_per_in_ler_id
                           ,l_prsrv_bdgt_cd
                           ,(mgr.lvl_num > 1));
    end loop;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 130);
   end if;
   --
   -- update the budgets in the new mgr hiearchy
   --
   l_last_mgr_id :=null;
   for mgr in csr_mgr_ids(p_new_mgr_per_in_ler_id
                     ,p_old_mgr_per_in_ler_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 140);
      end if;
      --
      -- If lvl_num = 0,1 , do everything
      -- For lvl_num > 1, only all.
      --
      -- call update_budgets_summary to update the budgets for this manager
      --
      update_budgets_summary(mgr.mgr_per_in_ler_id
                            ,l_prsrv_bdgt_cd
                            ,(mgr.lvl_num > 1));
      -- take the mgr id in l_last_mgr_id
      l_last_mgr_id := mgr.mgr_per_in_ler_id;
   end loop;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 150);
   end if;
   --
   -- when budgets are stored as % we need to update the ws_bdgt_val_all
   -- till the top
   if l_prsrv_bdgt_cd = 'P' then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 160);
      end if;
      --
      for l_mgrs in csr_mgrs(l_last_mgr_id) loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 170);
         end if;
         --
         -- lvl_num = 1, do everything.
         -- when lvl_num > 1, then only update budgets for all.
         --
         update_budgets_summary(l_mgrs.mgr_per_in_ler_id
                               ,l_prsrv_bdgt_cd
                               ,(l_mgrs.lvl_num > 1));
         --
      end loop;
   end if; -- of prsrv_bdgt_cd
   --
   -- Clean Budget data for old and new managers. Their role may
   -- have changed from LLM to HLM or HLM to LLM.
   --
   if g_debug then
     hr_utility.set_location(l_proc, 180);
   end if;
   --
   clean_budget_data(p_per_in_ler_id => p_old_mgr_per_in_ler_id);
   clean_budget_data(p_per_in_ler_id => p_new_mgr_per_in_ler_id);
   save_pl_sql_tab;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
end; -- end of reassign_mgr
--
--
-- --------------------------------------------------------------------------
-- |----------------------------< reassign_emp >-----------------------------|
-- --------------------------------------------------------------------------
procedure reassign_emp(p_old_mgr_per_in_ler_id in number
                      ,p_new_mgr_per_in_ler_id in number
                      ,p_emp_per_in_ler_id     in number) is

   -- Type delcarations for pl/sql tables
   type group_pl_id_type is table of
         ben_cwb_summary.group_pl_id%type index by binary_integer;
   type group_oipl_id_type is table of
         ben_cwb_summary.group_oipl_id%type index by binary_integer;
   type elig_count_direct_type is table of
         ben_cwb_summary.elig_count_direct%type index by binary_integer;
   type emp_recv_count_direct_type is table of
         ben_cwb_summary.emp_recv_count_direct%type index by binary_integer;
   type elig_sal_val_direct_type is table of
         ben_cwb_summary.elig_sal_val_direct%type index by binary_integer;
   type ws_val_direct_type is table of
         ben_cwb_summary.ws_val_direct%type index by binary_integer;
   type stat_sal_val_direct_type is table of
         ben_cwb_summary.stat_sal_val_direct%type index by binary_integer;
   type oth_comp_val_direct_type is table of
         ben_cwb_summary.oth_comp_val_direct%type index by binary_integer;
   type tot_comp_val_direct_type is table of
         ben_cwb_summary.tot_comp_val_direct%type index by binary_integer;
   type rec_val_direct_type is table of
         ben_cwb_summary.rec_val_direct%type index by binary_integer;
   type rec_mn_val_direct_type is table of
         ben_cwb_summary.rec_mn_val_direct%type index by binary_integer;
   type rec_mx_val_direct_type is table of
         ben_cwb_summary.rec_mx_val_direct%type index by binary_integer;
   type misc1_val_direct_type is table of
         ben_cwb_summary.misc1_val_direct%type index by binary_integer;
   type misc2_val_direct_type is table of
         ben_cwb_summary.misc2_val_direct%type index by binary_integer;
   type misc3_val_direct_type is table of
         ben_cwb_summary.misc3_val_direct%type index by binary_integer;
   -- declare pl/sql tables
   l_rts_group_pl_id_tab group_pl_id_type;
   l_rts_group_oipl_id_tab group_oipl_id_type;
   l_grp_group_pl_id_tab group_pl_id_type;
   l_grp_group_oipl_id_tab group_oipl_id_type;
   --
   l_elig_count_tab elig_count_direct_type;
   l_emp_recv_count_tab emp_recv_count_direct_type;
   l_elig_sal_val_tab elig_sal_val_direct_type;
   l_ws_val_tab ws_val_direct_type;
   l_stat_sal_val_tab stat_sal_val_direct_type;
   l_oth_comp_val_tab oth_comp_val_direct_type;
   l_tot_comp_val_tab tot_comp_val_direct_type;
   l_rec_val_tab rec_val_direct_type;
   l_rec_mn_val_tab rec_mn_val_direct_type;
   l_rec_mx_val_tab rec_mx_val_direct_type;
   l_misc1_val_tab misc1_val_direct_type;
   l_misc2_val_tab misc2_val_direct_type;
   l_misc3_val_tab misc3_val_direct_type;
--
   l_immd_mgr number;
   l_last_mgr_id number;
   l_prsrv_bdgt_cd varchar2(1);
   l_uses_bdgt_flag varchar2(1);
--
   l_ws_bdgt_val number;
   l_ws_bdgt_iss_val number;
   l_bdgt_val number;
   l_bdgt_iss_val number;
--
   l_proc     varchar2(72) := g_package||'reassign_emp';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   open csr_rates(p_emp_per_in_ler_id);
   fetch csr_rates bulk collect into l_rts_group_pl_id_tab
                                    ,l_rts_group_oipl_id_tab
                                    ,l_elig_count_tab
                                    ,l_emp_recv_count_tab
                                    ,l_elig_sal_val_tab
                                    ,l_ws_val_tab
                                    ,l_stat_sal_val_tab
                                    ,l_oth_comp_val_tab
                                    ,l_tot_comp_val_tab
                                    ,l_rec_val_tab
                                    ,l_rec_mn_val_tab
                                    ,l_rec_mx_val_tab
                                    ,l_misc1_val_tab
                                    ,l_misc2_val_tab
                                    ,l_misc3_val_tab;
   close csr_rates;
   --
   if nvl(l_rts_group_pl_id_tab.count,0) = 0 then
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 99);
      end if;
      --
      return;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   l_immd_mgr := 1;
   for mgr in csr_mgr_ids(p_old_mgr_per_in_ler_id
                     ,p_new_mgr_per_in_ler_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      --
      for i in l_rts_group_pl_id_tab.first..l_rts_group_pl_id_tab.last
      loop
        update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id => mgr.mgr_per_in_ler_id
            ,p_group_pl_id         => l_rts_group_pl_id_tab(i)
            ,p_group_oipl_id       => l_rts_group_oipl_id_tab(i)
            ,p_elig_count_direct   => -(l_elig_count_tab(i)) *
                                       l_immd_mgr
            ,p_elig_count_all      => -(l_elig_count_tab(i))
            ,p_emp_recv_count_direct => -(l_emp_recv_count_tab(i))
                                       * l_immd_mgr
            ,p_emp_recv_count_all  => -(l_emp_recv_count_tab(i))
            ,p_elig_sal_val_direct => -(l_elig_sal_val_tab(i)) *
                                       l_immd_mgr
            ,p_elig_sal_val_all    => -(l_elig_sal_val_tab(i))
            ,p_ws_val_direct       => -(l_ws_val_tab(i)) *
                                       l_immd_mgr
            ,p_ws_val_all          => -(l_ws_val_tab(i))
            ,p_stat_sal_val_direct => -(l_stat_sal_val_tab(i)) *
                                       l_immd_mgr
            ,p_stat_sal_val_all    => -(l_stat_sal_val_tab(i))
            ,p_oth_comp_val_direct => -(l_oth_comp_val_tab(i)) *
                                       l_immd_mgr
            ,p_oth_comp_val_all    => -(l_oth_comp_val_tab(i))
            ,p_tot_comp_val_direct => -(l_tot_comp_val_tab(i)) *
                                       l_immd_mgr
            ,p_tot_comp_val_all    => -(l_tot_comp_val_tab(i))
            ,p_rec_val_direct      => -(l_rec_val_tab(i)) *
                                       l_immd_mgr
            ,p_rec_val_all         => -(l_rec_val_tab(i))
            ,p_rec_mn_val_direct   => -(l_rec_mn_val_tab(i)) *
                                       l_immd_mgr
            ,p_rec_mn_val_all      => -(l_rec_mn_val_tab(i))
            ,p_rec_mx_val_direct   => -(l_rec_mx_val_tab(i)) *
                                       l_immd_mgr
            ,p_rec_mx_val_all      => -(l_rec_mx_val_tab(i))
            ,p_misc1_val_direct    => -(l_misc1_val_tab(i)) *
                                       l_immd_mgr
            ,p_misc1_val_all       => -(l_misc1_val_tab(i))
            ,p_misc2_val_direct    => -(l_misc2_val_tab(i)) *
                                       l_immd_mgr
            ,p_misc2_val_all       => -(l_misc2_val_tab(i))
            ,p_misc3_val_direct    => -(l_misc3_val_tab(i)) *
                                       l_immd_mgr
            ,p_misc3_val_all       => -(l_misc3_val_tab(i))
            );
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      -- Now change the l_immd_mgr value to false
      l_immd_mgr := 0;
   end loop; -- of csr_mgr_ids cursor
   --
   if g_debug then
      hr_utility.set_location(l_proc, 50);
   end if;
   --

   -- Now add the values to new manager hierarchy
   l_immd_mgr := 1;
   for mgr in csr_mgr_ids(p_new_mgr_per_in_ler_id
                     ,p_old_mgr_per_in_ler_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 60);
      end if;
      --
      for i in l_rts_group_pl_id_tab.first..l_rts_group_pl_id_tab.last
      loop
        update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id => mgr.mgr_per_in_ler_id
            ,p_group_pl_id         => l_rts_group_pl_id_tab(i)
            ,p_group_oipl_id       => l_rts_group_oipl_id_tab(i)
            ,p_elig_count_direct   => (l_elig_count_tab(i)) *
                                       l_immd_mgr
            ,p_elig_count_all      => (l_elig_count_tab(i))
            ,p_emp_recv_count_direct => (l_emp_recv_count_tab(i))
                                       * l_immd_mgr
            ,p_emp_recv_count_all  => (l_emp_recv_count_tab(i))
            ,p_elig_sal_val_direct => (l_elig_sal_val_tab(i)) *
                                       l_immd_mgr
            ,p_elig_sal_val_all    => (l_elig_sal_val_tab(i))
            ,p_ws_val_direct       => (l_ws_val_tab(i)) *
                                       l_immd_mgr
            ,p_ws_val_all          => (l_ws_val_tab(i))
            ,p_stat_sal_val_direct => (l_stat_sal_val_tab(i)) *
                                       l_immd_mgr
            ,p_stat_sal_val_all    => (l_stat_sal_val_tab(i))
            ,p_oth_comp_val_direct => (l_oth_comp_val_tab(i)) *
                                       l_immd_mgr
            ,p_oth_comp_val_all    => (l_oth_comp_val_tab(i))
            ,p_tot_comp_val_direct => (l_tot_comp_val_tab(i)) *
                                       l_immd_mgr
            ,p_tot_comp_val_all    => (l_tot_comp_val_tab(i))
            ,p_rec_val_direct      => (l_rec_val_tab(i)) *
                                       l_immd_mgr
            ,p_rec_val_all         => (l_rec_val_tab(i))
            ,p_rec_mn_val_direct   => (l_rec_mn_val_tab(i)) *
                                       l_immd_mgr
            ,p_rec_mn_val_all      => (l_rec_mn_val_tab(i))
            ,p_rec_mx_val_direct   => (l_rec_mx_val_tab(i)) *
                                       l_immd_mgr
            ,p_rec_mx_val_all      => (l_rec_mx_val_tab(i))
            ,p_misc1_val_direct    => (l_misc1_val_tab(i)) *
                                       l_immd_mgr
            ,p_misc1_val_all       => (l_misc1_val_tab(i))
            ,p_misc2_val_direct    => (l_misc2_val_tab(i)) *
                                       l_immd_mgr
            ,p_misc2_val_all       => (l_misc2_val_tab(i))
            ,p_misc3_val_direct    => (l_misc3_val_tab(i)) *
                                       l_immd_mgr
            ,p_misc3_val_all       => (l_misc3_val_tab(i))
            );
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 70);
      end if;
      --
      --
      -- Now change the l_immd_mgr value to false
      l_immd_mgr := 0;
   end loop; -- of csr_mgr_ids cursor
   --
   if g_debug then
      hr_utility.set_location(l_proc, 80);
   end if;
   --
   -- if the Prsrv Bdgt Cd is P then, the managers budget also need to
   -- updated.
   select pl.prsrv_bdgt_cd
         ,pl.uses_bdgt_flag
   into l_prsrv_bdgt_cd
       ,l_uses_bdgt_flag
   from ben_cwb_pl_dsgn pl
       ,ben_cwb_person_groups grp
   where grp.group_per_in_ler_id = nvl(p_new_mgr_per_in_ler_id, p_old_mgr_per_in_ler_id)
   and   grp.group_oipl_id = -1
   and   pl.pl_id = grp.group_pl_id
   and   pl.oipl_id = grp.group_oipl_id
   and   pl.lf_evt_ocrd_dt = grp.lf_evt_ocrd_dt;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 90);
   end if;
   --
   if l_uses_bdgt_flag = 'N' then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 99);
      end if;
      --
      -- Budgets are not used. So no process required.
      return;
      --
   end if;
   --
   -- call the save_pl_sql_tab to transfer the data in the pl/sql tab
   -- to the database. This is required to for computing the budgets
   -- correctly.
   save_pl_sql_tab;
   --
   if l_prsrv_bdgt_cd = 'P' then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 100);
      end if;
      --
      for mgr in csr_mgr_ids(p_old_mgr_per_in_ler_id
                        ,p_new_mgr_per_in_ler_id)
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 110);
         end if;
         --
         -- lvl_num = 0, ignore that row as emps do not have budget.
         -- lvl_num = 1, do everything.
         -- when lvl_num > 1, then only update budgets for all.

         --
         -- call update_budgets_summary to update the budgets for this manager
         --
         if mgr.lvl_num > 0 then
           update_budgets_summary(mgr.mgr_per_in_ler_id
                                 ,l_prsrv_bdgt_cd
                                 ,(mgr.lvl_num>1));
         end if;
     end loop;
     --
     if g_debug then
        hr_utility.set_location(l_proc, 120);
     end if;
      --
      -- update the budgets in the new mgr hiearchy
      --
      l_last_mgr_id :=null;
      for mgr in csr_mgr_ids(p_new_mgr_per_in_ler_id
                        ,p_old_mgr_per_in_ler_id)
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 130);
         end if;
         --
         -- lvl_num = 0, ignore that row as emps do not have budget.
         -- lvl_num = 1, do everything.
         -- when lvl_num > 1, then only update budgets for all.

         --
         -- call update_budgets_summary to update the budgets for this manager
         --
         if mgr.lvl_num > 0 then
           update_budgets_summary(mgr.mgr_per_in_ler_id
                                 ,l_prsrv_bdgt_cd
                                 ,(mgr.lvl_num>1));
         end if;
         -- take the mgr id in l_last_mgr_id
         l_last_mgr_id := mgr.mgr_per_in_ler_id;
      end loop;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 140);
      end if;
      --
      -- when budgets are stored as % the ws_bdgt_val_all will be affected
      -- till top
      for l_mgrs in csr_mgrs(l_last_mgr_id) loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 150);
         end if;
         --
         -- lvl_num = 1, do everything.
         -- when lvl_num > 1, then only update budgets for all.
         --
         update_budgets_summary(l_mgrs.mgr_per_in_ler_id
                               ,l_prsrv_bdgt_cd
                               ,(l_mgrs.lvl_num>1));
         --
      end loop;
   --
   end if; -- of if prsrv_bdgt_cd
   --
   -- If the reassigned employee is not a manager,
   -- then the budget cleanup is needed for old and
   -- new manager's manager
   --
   if g_debug then
     hr_utility.set_location(l_proc, 160);
   end if;
   --
   clean_budget_data(p_per_in_ler_id => p_old_mgr_per_in_ler_id);
   clean_budget_data(p_per_in_ler_id => p_new_mgr_per_in_ler_id);
   save_pl_sql_tab;

   clean_budget_data(p_per_in_ler_id => p_old_mgr_per_in_ler_id
                    ,p_lvl_up        => 1);
   clean_budget_data(p_per_in_ler_id => p_new_mgr_per_in_ler_id
                    ,p_lvl_up        => 1);
   save_pl_sql_tab;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --
end; -- end of reassign_emp
--
-- --------------------------------------------------------------------------
-- |-------------------< update_summary_on_reassignment >--------------------|
-- --------------------------------------------------------------------------
procedure update_summary_on_reassignment(p_old_mgr_per_in_ler_id in number
                                        ,p_new_mgr_per_in_ler_id in number
                                        ,p_emp_per_in_ler_id     in number) is
--
   l_is_mgr varchar2(1);
   l_dummy varchar2(1);
   l_insert_old_mgr boolean;
--
   l_proc     varchar2(72) := g_package||'update_summary_on_reassignment';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   --check if the emp was a manager earlier
   begin
      select null into l_dummy
      from ben_cwb_group_hrchy
      where mgr_per_in_ler_id = p_emp_per_in_ler_id
      and lvl_num = 0;
      --
      l_is_mgr := 'Y';
   exception
      when no_data_found then
         l_is_mgr := 'N';
   end;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;

   --
   -- if the old_mgr_pil is already deleted from group_hrchy then insert
   -- it. The row will be used the reassign_mgr and reassign_emp. But if
   -- the old_mgr_pil is null(i.e., we are re-assigning the top level mgr
   -- of one hierarchy to another person) dont insert the rec.
   if (p_old_mgr_per_in_ler_id is not null) then
      begin
         select null into l_dummy
         from ben_cwb_group_hrchy hrchy
         where emp_per_in_ler_id = p_old_mgr_per_in_ler_id
         and lvl_num = 0;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 30);
         end if;
         --
      exception
         when no_data_found then
         -- row is not present;
         insert into ben_cwb_group_hrchy(mgr_per_in_ler_id
                                        ,emp_per_in_ler_id
                                        ,lvl_num)
                                  values(p_old_mgr_per_in_ler_id
                                        ,p_old_mgr_per_in_ler_id
                                        ,0);
         -- set the flag
         l_insert_old_mgr :=true;
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --
      end;
   end if;

   -- if the new_mgr_per_in_ler_id was not manager earlier then,
   -- add the summary row for the person.

   insert into ben_cwb_summary
            (summary_id
            ,group_per_in_ler_id
            ,group_pl_id
            ,group_oipl_id
            ,person_id
            ,lf_evt_ocrd_dt)
            select ben_cwb_summary_s.nextval
               ,grp.group_per_in_ler_id
               ,grp.group_pl_id
               ,grp.group_oipl_id
               ,pil.person_id
               ,pil.lf_evt_ocrd_dt
            from ben_cwb_person_groups grp
                ,ben_per_in_ler pil
            where grp.group_per_in_ler_id = p_new_mgr_per_in_ler_id
            and grp.group_per_in_ler_id = pil.per_in_ler_id
            and pil.per_in_ler_stat_cd in ('PROCD','STRTD')
            and not exists(select null
                          from ben_cwb_summary
                          where group_per_in_ler_id = p_new_mgr_per_in_ler_id);

   if l_is_mgr = 'Y' then
     -- call reassign_mgr
     reassign_mgr(p_old_mgr_per_in_ler_id => p_old_mgr_per_in_ler_id
                 ,p_new_mgr_per_in_ler_id => p_new_mgr_per_in_ler_id
                 ,p_emp_per_in_ler_id     => p_emp_per_in_ler_id);
   else
     -- call reassign_emp
     reassign_emp(p_old_mgr_per_in_ler_id => p_old_mgr_per_in_ler_id
                 ,p_new_mgr_per_in_ler_id => p_new_mgr_per_in_ler_id
                 ,p_emp_per_in_ler_id     => p_emp_per_in_ler_id);
   end if;
   --
   save_pl_sql_tab;
   --
   -- before leaving, delete the row from group_hrchy, if it is
   -- inserted in this procedure
   if l_insert_old_mgr then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 50);
      end if;
      --
      delete from ben_cwb_group_hrchy
      where mgr_per_in_ler_id = p_old_mgr_per_in_ler_id
      and lvl_num = 0;
   end if;

   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end;
--
-- --------------------------------------------------------------------------
-- |----------------------< delete_summary_group_pl >------------------------|
-- --------------------------------------------------------------------------
procedure delete_summary_group_pl(p_group_pl_id number
                                 ,p_lf_evt_ocrd_dt date)
is
--
   l_proc     varchar2(72) := g_package||'delete_summary_group_pl';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   delete from ben_cwb_summary
   where group_pl_id = p_group_pl_id
   and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 170);
   end if;
   --
end;
--
-- --------------------------------------------------------------------------
-- |----------------< upd_summary_on_elig_sal_change >--------------------|
-- --------------------------------------------------------------------------
procedure upd_summary_on_elig_sal_change(p_group_per_in_ler_id in number
                                        ,p_elig_sal_change in number) is
   -- get the managers' ids and change in Ws Bdgts
   cursor csr_ws_bdgts(p_group_per_in_ler_id number
                      ,p_sal number) is
   select grp.group_pl_id
         ,grp.group_oipl_id
         ,grp.ws_bdgt_val * p_sal / 100 ws_bdgt_val
         ,grp.ws_bdgt_iss_val * p_sal / 100 ws_bdgt_iss_val
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_person_groups grp
   where hrchy.emp_per_in_ler_id = p_group_per_in_ler_id
   and   hrchy.mgr_per_in_ler_id = grp.group_per_in_ler_id
   and   hrchy.lvl_num = 1
   order by grp.group_pl_id, grp.group_oipl_id;

   -- get the mgr ids of the person.
   cursor mgr_ids(p_group_per_in_ler_id number) is
   select hrchy.mgr_per_in_ler_id per_in_ler_id
         ,mgr.mgr_per_in_ler_id next_mgr_id
   from ben_cwb_group_hrchy hrchy
       ,ben_cwb_group_hrchy mgr
   where hrchy.emp_per_in_ler_id = p_group_per_in_ler_id
   and   hrchy.lvl_num > 0
   and   mgr.emp_per_in_ler_id (+) = hrchy.mgr_per_in_ler_id
   and   mgr.lvl_num (+) = 1
   order by hrchy.lvl_num;


   -- Type delcarations for pl/sql tables
   type group_per_in_ler_id_type is table of
         ben_cwb_person_groups.group_per_in_ler_id%type;
   type group_pl_id_type is table of
         ben_cwb_person_groups.group_pl_id%type;
   type group_oipl_id_type is table of
         ben_cwb_person_groups.group_oipl_id%type;
   type ws_bdgt_val_type is table of
         ben_cwb_person_groups.ws_bdgt_val%type;
   type ws_bdgt_iss_val_type is table of
         ben_cwb_person_groups.ws_bdgt_iss_val%type;

   -- declare pl/sql tables
   l_group_pl_id_tab group_pl_id_type;
   l_group_oipl_id_tab group_oipl_id_type;
   l_ws_bdgt_val_tab ws_bdgt_val_type;
   l_ws_bdgt_iss_val_tab ws_bdgt_iss_val_type;
--
   l_immd_mgr number;
--
   l_bdgt_val number;
   l_bdgt_iss_val number;
   l_prsrv_bdgt_cd varchar2(1);
   l_uses_bdgt_flag varchar2(1);
--
   l_proc     varchar2(72) := g_package||'upd_summary_on_elig_sal_change';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select pl.prsrv_bdgt_cd
         ,pl.uses_bdgt_flag
   into l_prsrv_bdgt_cd
       ,l_uses_bdgt_flag
   from ben_cwb_pl_dsgn pl
       ,ben_cwb_person_groups grp
   where grp.group_per_in_ler_id = p_group_per_in_ler_id
   and   grp.group_oipl_id = -1
   and   pl.pl_id = grp.group_pl_id
   and   pl.oipl_id = grp.group_oipl_id
   and   pl.lf_evt_ocrd_dt = grp.lf_evt_ocrd_dt;

   if l_prsrv_bdgt_cd = 'A'  or l_uses_bdgt_flag = 'N'
      or p_elig_sal_change = 0 then
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 19);
      end if;
      -- no changes are required
      return;
   end if;
   --
   open csr_ws_bdgts(p_group_per_in_ler_id, p_elig_sal_change);
   fetch csr_ws_bdgts bulk collect into l_group_pl_id_tab
                                       ,l_group_oipl_id_tab
                                       ,l_ws_bdgt_val_tab
                                       ,l_ws_bdgt_iss_val_tab;
   close csr_ws_bdgts;

   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   --
   l_immd_mgr := 1;
   --
   for mgr in mgr_ids(p_group_per_in_ler_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --
      for i in l_group_pl_id_tab.first..l_group_pl_id_tab.last
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;

         -- for Dist Bdgts, get the current mgr bdgt
         select decode(nvl(grp.dist_bdgt_val,0),0,grp.ws_bdgt_val,
                  grp.dist_bdgt_val) * p_elig_sal_change /100
               ,decode(nvl(grp.dist_bdgt_iss_val,0),0,grp.ws_bdgt_iss_val,
                  grp.dist_bdgt_iss_val) * p_elig_sal_change /100
         into l_bdgt_val
             ,l_bdgt_iss_val
         from ben_cwb_person_groups grp
         where grp.group_per_in_ler_id = mgr.per_in_ler_id
         and   grp.group_pl_id = l_group_pl_id_tab(i)
         and   grp.group_oipl_id = l_group_oipl_id_tab(i);
         --
         if g_debug then
            hr_utility.set_location(l_proc, 50);
         end if;

         -- this is the change in bdgts of current mgr. so his/her immd
         -- mgr summary will need to be updated.
         if mgr.next_mgr_id is not null then
            --
            if g_debug then
               hr_utility.set_location(l_proc, 60);
            end if;
            --
            update_or_insert_pl_sql_tab
               (p_group_per_in_ler_id => mgr.next_mgr_id
               ,p_group_pl_id         => l_group_pl_id_tab(i)
               ,p_group_oipl_id       => l_group_oipl_id_tab(i)
               ,p_ws_bdgt_val_direct  => l_ws_bdgt_val_tab(i) * l_immd_mgr
               ,p_ws_bdgt_val_all     => l_ws_bdgt_val_tab(i)
               ,p_ws_bdgt_iss_val_direct => l_ws_bdgt_iss_val_tab(i) * l_immd_mgr
               ,p_ws_bdgt_iss_val_all => l_ws_bdgt_iss_val_tab(i)
               ,p_bdgt_val_direct     => l_bdgt_val
               ,p_bdgt_iss_val_direct => l_bdgt_iss_val
               );
         end if; -- if mgr.next_mgr_id
      end loop;
      --
      l_immd_mgr := 0;
      --
      if g_debug then
            hr_utility.set_location(l_proc, 70);
      end if;
         --
   end loop; -- of mgr_ids cursor
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- end of update_summary_on_elig_sal_change
--
-- --------------------------------------------------------------------------
-- |-------------------< refresh_summary_all_plans >-----------------------|
-- --------------------------------------------------------------------------
procedure refresh_summary_all_plans
is
--
--
    cursor csr_plans_to_refresh
    is
    select distinct group_pl_id
          ,lf_evt_ocrd_dt
      from ben_cwb_person_info cpi
     where cpi.person_id = -1;
--
--
begin
--
--
for l_rec in csr_plans_to_refresh loop
refresh_summary_persons(l_rec.group_pl_id, l_rec.lf_evt_ocrd_dt);
commit;
end loop;
--
--
end;
--
end ben_cwb_summary_pkg; -- end of package


/
