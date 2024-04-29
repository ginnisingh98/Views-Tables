--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PERSON_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PERSON_RATES_API" as
/* $Header: bertsapi.pkb 120.5.12000000.1 2007/01/19 23:09:06 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_CWB_PERSON_RATES_API.';
g_debug boolean := hr_utility.debug_enabled;
  cursor csr_rates(v_group_per_in_ler_id number
                ,v_pl_id               number
                ,v_oipl_id             number) is
   select *
   from ben_cwb_person_rates
   where group_per_in_ler_id = v_group_per_in_ler_id
   and   pl_id = v_pl_id
   and   oipl_id = v_oipl_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_person_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_rate
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_group_pl_id                   in     number
  ,p_group_oipl_id                 in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_person_id                     in     number   default null
  ,p_assignment_id                 in     number   default null
  ,p_elig_flag                     in     varchar2 default null
  ,p_ws_val                        in     number   default null
  ,p_ws_mn_val                     in     number   default null
  ,p_ws_mx_val                     in     number   default null
  ,p_ws_incr_val                   in     number   default null
  ,p_elig_sal_val                  in     number   default null
  ,p_stat_sal_val                  in     number   default null
  ,p_oth_comp_val                  in     number   default null
  ,p_tot_comp_val                  in     number   default null
  ,p_misc1_val                     in     number   default null
  ,p_misc2_val                     in     number   default null
  ,p_misc3_val                     in     number   default null
  ,p_rec_val                       in     number   default null
  ,p_rec_mn_val                    in     number   default null
  ,p_rec_mx_val                    in     number   default null
  ,p_rec_incr_val                  in     number   default null
  ,p_ws_val_last_upd_date          in     date     default null
  ,p_ws_val_last_upd_by            in     number   default null
  ,p_pay_proposal_id               in     number   default null
  ,p_element_entry_value_id        in     number   default null
  ,p_inelig_rsn_cd                 in     varchar2 default null
  ,p_elig_ovrid_dt                 in     date     default null
  ,p_elig_ovrid_person_id          in     number   default null
  ,p_copy_dist_bdgt_val            in     number   default null
  ,p_copy_ws_bdgt_val              in     number   default null
  ,p_copy_rsrv_val                 in     number   default null
  ,p_copy_dist_bdgt_mn_val         in     number   default null
  ,p_copy_dist_bdgt_mx_val         in     number   default null
  ,p_copy_dist_bdgt_incr_val       in     number   default null
  ,p_copy_ws_bdgt_mn_val           in     number   default null
  ,p_copy_ws_bdgt_mx_val           in     number   default null
  ,p_copy_ws_bdgt_incr_val         in     number   default null
  ,p_copy_rsrv_mn_val              in     number   default null
  ,p_copy_rsrv_mx_val              in     number   default null
  ,p_copy_rsrv_incr_val            in     number   default null
  ,p_copy_dist_bdgt_iss_val        in     number   default null
  ,p_copy_ws_bdgt_iss_val          in     number   default null
  ,p_copy_dist_bdgt_iss_date       in     date     default null
  ,p_copy_ws_bdgt_iss_date         in     date     default null
  ,p_comp_posting_date             in     date     default null
  ,p_ws_rt_start_date              in     date     default null
  ,p_currency                      in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_person_rate_id                   out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_person_rate_id ben_cwb_person_rates.person_rate_id%type;
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'create_person_rate';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_person_rate;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_rates_bk1.create_person_rate_b
      (p_group_per_in_ler_id       => p_group_per_in_ler_id
      ,p_pl_id                     => p_pl_id
      ,p_oipl_id                   => p_oipl_id
      ,p_group_pl_id               => p_group_pl_id
      ,p_group_oipl_id             => p_group_oipl_id
      ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
      ,p_person_id                 => p_person_id
      ,p_assignment_id             => p_assignment_id
      ,p_elig_flag                 => p_elig_flag
      ,p_ws_val                    => p_ws_val
      ,p_ws_mn_val                 => p_ws_mn_val
      ,p_ws_mx_val                 => p_ws_mx_val
      ,p_ws_incr_val               => p_ws_incr_val
      ,p_elig_sal_val              => p_elig_sal_val
      ,p_stat_sal_val              => p_stat_sal_val
      ,p_oth_comp_val              => p_oth_comp_val
      ,p_tot_comp_val              => p_tot_comp_val
      ,p_misc1_val                 => p_misc1_val
      ,p_misc2_val                 => p_misc2_val
      ,p_misc3_val                 => p_misc3_val
      ,p_rec_val                   => p_rec_val
      ,p_rec_mn_val                => p_rec_mn_val
      ,p_rec_mx_val                => p_rec_mx_val
      ,p_rec_incr_val              => p_rec_incr_val
      ,p_ws_val_last_upd_date      => p_ws_val_last_upd_date
      ,p_ws_val_last_upd_by        => p_ws_val_last_upd_by
      ,p_pay_proposal_id           => p_pay_proposal_id
      ,p_element_entry_value_id    => p_element_entry_value_id
      ,p_inelig_rsn_cd             => p_inelig_rsn_cd
      ,p_elig_ovrid_dt             => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id      => p_elig_ovrid_person_id
      ,p_copy_dist_bdgt_val        => p_copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val          => p_copy_ws_bdgt_val
      ,p_copy_rsrv_val             => p_copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val     => p_copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val     => p_copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val   => p_copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val       => p_copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val       => p_copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val     => p_copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val          => p_copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val          => p_copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val        => p_copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val    => p_copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val      => p_copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date   => p_copy_dist_bdgt_iss_date
      ,p_comp_posting_date         => p_comp_posting_date
      ,p_copy_ws_bdgt_iss_date     => p_copy_ws_bdgt_iss_date
      ,p_ws_rt_start_date          => p_ws_rt_start_date
      ,p_currency                  => p_currency
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_RATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
    ben_rts_ins.ins
      (p_group_per_in_ler_id       => p_group_per_in_ler_id
      ,p_pl_id                     => p_pl_id
      ,p_oipl_id                   => p_oipl_id
      ,p_group_pl_id               => p_group_pl_id
      ,p_group_oipl_id             => p_group_oipl_id
      ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
      ,p_person_id                 => p_person_id
      ,p_assignment_id             => p_assignment_id
      ,p_elig_flag                 => p_elig_flag
      ,p_ws_val                    => p_ws_val
      ,p_ws_mn_val                 => p_ws_mn_val
      ,p_ws_mx_val                 => p_ws_mx_val
      ,p_ws_incr_val               => p_ws_incr_val
      ,p_elig_sal_val              => p_elig_sal_val
      ,p_stat_sal_val              => p_stat_sal_val
      ,p_oth_comp_val              => p_oth_comp_val
      ,p_tot_comp_val              => p_tot_comp_val
      ,p_misc1_val                 => p_misc1_val
      ,p_misc2_val                 => p_misc2_val
      ,p_misc3_val                 => p_misc3_val
      ,p_rec_val                   => p_rec_val
      ,p_rec_mn_val                => p_rec_mn_val
      ,p_rec_mx_val                => p_rec_mx_val
      ,p_rec_incr_val              => p_rec_incr_val
      ,p_ws_val_last_upd_date      => p_ws_val_last_upd_date
      ,p_ws_val_last_upd_by        => p_ws_val_last_upd_by
      ,p_pay_proposal_id           => p_pay_proposal_id
      ,p_element_entry_value_id    => p_element_entry_value_id
      ,p_inelig_rsn_cd             => p_inelig_rsn_cd
      ,p_elig_ovrid_dt             => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id      => p_elig_ovrid_person_id
      ,p_copy_dist_bdgt_val        => p_copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val          => p_copy_ws_bdgt_val
      ,p_copy_rsrv_val             => p_copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val     => p_copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val     => p_copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val   => p_copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val       => p_copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val       => p_copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val     => p_copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val          => p_copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val          => p_copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val        => p_copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val    => p_copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val      => p_copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date   => p_copy_dist_bdgt_iss_date
      ,p_copy_ws_bdgt_iss_date     => p_copy_ws_bdgt_iss_date
      ,p_comp_posting_date         => p_comp_posting_date
      ,p_ws_rt_start_date          => p_ws_rt_start_date
      ,p_currency                  => p_currency
      ,p_object_version_number     => l_object_version_number
      ,p_person_rate_id            => l_person_rate_id
      );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_rates_bk1.create_person_rate_a
          (p_person_rate_id            => l_person_rate_id
          ,p_group_per_in_ler_id       => p_group_per_in_ler_id
          ,p_pl_id                     => p_pl_id
          ,p_oipl_id                   => p_oipl_id
          ,p_group_pl_id               => p_group_pl_id
          ,p_group_oipl_id             => p_group_oipl_id
          ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
          ,p_person_id                 => p_person_id
          ,p_assignment_id             => p_assignment_id
          ,p_elig_flag                 => p_elig_flag
          ,p_ws_val                    => p_ws_val
          ,p_ws_mn_val                 => p_ws_mn_val
          ,p_ws_mx_val                 => p_ws_mx_val
          ,p_ws_incr_val               => p_ws_incr_val
          ,p_elig_sal_val              => p_elig_sal_val
          ,p_stat_sal_val              => p_stat_sal_val
          ,p_oth_comp_val              => p_oth_comp_val
          ,p_tot_comp_val              => p_tot_comp_val
          ,p_misc1_val                 => p_misc1_val
          ,p_misc2_val                 => p_misc2_val
          ,p_misc3_val                 => p_misc3_val
          ,p_rec_val                   => p_rec_val
          ,p_rec_mn_val                => p_rec_mn_val
          ,p_rec_mx_val                => p_rec_mx_val
          ,p_rec_incr_val              => p_rec_incr_val
          ,p_ws_val_last_upd_date      => p_ws_val_last_upd_date
          ,p_ws_val_last_upd_by        => p_ws_val_last_upd_by
          ,p_pay_proposal_id           => p_pay_proposal_id
          ,p_element_entry_value_id    => p_element_entry_value_id
          ,p_inelig_rsn_cd             => p_inelig_rsn_cd
          ,p_elig_ovrid_dt             => p_elig_ovrid_dt
          ,p_elig_ovrid_person_id      => p_elig_ovrid_person_id
          ,p_copy_dist_bdgt_val        => p_copy_dist_bdgt_val
          ,p_copy_ws_bdgt_val          => p_copy_ws_bdgt_val
          ,p_copy_rsrv_val             => p_copy_rsrv_val
          ,p_copy_dist_bdgt_mn_val     => p_copy_dist_bdgt_mn_val
          ,p_copy_dist_bdgt_mx_val     => p_copy_dist_bdgt_mx_val
          ,p_copy_dist_bdgt_incr_val   => p_copy_dist_bdgt_incr_val
          ,p_copy_ws_bdgt_mn_val       => p_copy_ws_bdgt_mn_val
          ,p_copy_ws_bdgt_mx_val       => p_copy_ws_bdgt_mx_val
          ,p_copy_ws_bdgt_incr_val     => p_copy_ws_bdgt_incr_val
          ,p_copy_rsrv_mn_val          => p_copy_rsrv_mn_val
          ,p_copy_rsrv_mx_val          => p_copy_rsrv_mx_val
          ,p_copy_rsrv_incr_val        => p_copy_rsrv_incr_val
          ,p_copy_dist_bdgt_iss_val    => p_copy_dist_bdgt_iss_val
          ,p_copy_ws_bdgt_iss_val      => p_copy_ws_bdgt_iss_val
          ,p_copy_dist_bdgt_iss_date   => p_copy_dist_bdgt_iss_date
          ,p_copy_ws_bdgt_iss_date     => p_copy_ws_bdgt_iss_date
          ,p_comp_posting_date         => p_comp_posting_date
          ,p_ws_rt_start_date          => p_ws_rt_start_date
          ,p_currency                  => p_currency
          ,p_object_version_number     => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_RATE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_person_rate_id := l_person_rate_id;
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_rate;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_person_rate;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_person_rate;
--
-- --------------------------------------------------------------------------
-- |----------------------------< check_min_max >----------------------------|
-- --------------------------------------------------------------------------
procedure check_min_max(p_val in number
		       ,p_min_val in number
		       ,p_max_val in number
		       ,p_incr_val in number
		       ,p_group_per_in_ler_id number)
is
--
  l_person_name varchar2(240);
--
  l_proc  varchar2(72) := g_package||'check_min_max';
--
Begin
  --
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
     hr_utility.set_location('p_val :'||p_val, 10);
     hr_utility.set_location('p_min_val :'||p_min_val, 10);
     hr_utility.set_location('p_max_val :'||p_max_val, 10);
     hr_utility.set_location('p_incr_val :'||p_incr_val, 10);
  end if;
  --
  select full_name into l_person_name
  from ben_cwb_person_info
  where group_per_in_ler_id = p_group_per_in_ler_id;
  --
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number and
      p_min_val is not null) then
    if (p_val < p_min_val) then
      fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
      fnd_message.set_token('VAL',p_val);
      fnd_message.set_token('MIN',p_min_val);
      fnd_message.set_token('MAX',p_max_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;
    end if;
  end if;
  --
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number and
      p_max_val is not null) then
    if (p_val > p_max_val) then
      fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
      fnd_message.set_token('VAL',p_val);
      fnd_message.set_token('MIN',p_min_val);
      fnd_message.set_token('MAX',p_max_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number and
      p_incr_val is not null) then
    if (mod(p_val,p_incr_val) <> 0) then
      fnd_message.set_name('BEN','BEN_92985_CWB_VAL_NOT_INCRMNT');
      fnd_message.set_token('VAL',p_val);
      fnd_message.set_token('INCREMENT', p_incr_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;
    end if;
  end if;
  if g_debug then
     hr_utility.set_location(l_proc, 70);
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 90);
  end if;
end check_min_max;
--
--
-- --------------------------------------------------------------------------
-- |---------------------< update_person_rates_summary >---------------------|
-- --------------------------------------------------------------------------
-- Description
-- This is an internal procedure called only by update_person_rates to
-- update the summary table after updating the ben_cwb_person_rates.
--
procedure update_rates_summary(p_rates_old csr_rates%rowtype,
                               p_rates_new csr_rates%rowtype) is
   --cursor to fetch the managers of the person
   cursor csr_mgr_pil_ids(p_group_per_in_ler_id number) is
   select mgr_per_in_ler_id
   from ben_cwb_group_hrchy
   where emp_per_in_ler_id = p_group_per_in_ler_id
   and lvl_num  <> 0
   order by lvl_num;
   --
   cursor csr_xchg_rt(p_pl_id number
                     ,p_oipl_id number
	             ,p_lf_evt_ocrd_dt date
		     ,p_currency varchar2) is
   select decode(ws_nnmntry_uom, null, xchg_rate, 1) ws_xchg_rt
         ,decode(elig_sal_nnmntry_uom, null, xchg_rate, 1) elig_sal_xchg_rt
	 ,decode(stat_sal_nnmntry_uom, null, xchg_rate, 1) stat_sal_xchg_rt
	 ,decode(oth_comp_nnmntry_uom, null, xchg_rate, 1) oth_comp_xchg_rt
	 ,decode(tot_comp_nnmntry_uom, null, xchg_rate, 1) tot_comp_xchg_rt
	 ,decode(misc1_nnmntry_uom, null, xchg_rate, 1) misc1_xchg_rt
	 ,decode(misc2_nnmntry_uom, null, xchg_rate, 1) misc2_xchg_rt
	 ,decode(misc3_nnmntry_uom, null, xchg_rate, 1) misc3_xchg_rt
	 ,decode(rec_nnmntry_uom, null, xchg_rate, 1) rec_xchg_rt
         ,uses_bdgt_flag uses_bdgt_flag
   from ben_cwb_pl_dsgn pl
       ,ben_cwb_xchg xchg
   where pl.pl_id = p_pl_id
   and   pl.oipl_id = p_oipl_id
   and   pl.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
   and   xchg.group_pl_id = pl.group_pl_id
   and   xchg.lf_evt_ocrd_dt = pl.lf_evt_ocrd_dt
   and   xchg.currency = p_currency;
   --
   l_new_xchg_rt csr_xchg_rt%rowtype;
   l_old_xchg_rt csr_xchg_rt%rowtype;
   --
   l_elig_count_d        number:=0;
   l_emp_recv_count_d    number:=0;
   l_ws_val_d            number;
   l_elig_sal_val_d      number;
   l_stat_sal_val_d      number;
   l_oth_comp_val_d      number;
   l_tot_comp_val_d      number;
   l_misc1_val_d         number;
   l_misc2_val_d         number;
   l_misc3_val_d         number;
   l_rec_val_d           number;
   l_rec_mn_val_d        number;
   l_rec_mx_val_d        number;
   --
   l_immd_mgr        number;
   --
   l_proc            varchar2(72) :=g_package||'update_person_rates_summary';
begin
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   -- get the pl_xchg_rate and nnmntry_uom from pl_dsgn
   open csr_xchg_rt(p_rates_new.pl_id
                   ,p_rates_new.oipl_id
		   ,p_rates_new.lf_evt_ocrd_dt
		   ,p_rates_new.currency);
   fetch csr_xchg_rt into l_new_xchg_rt;
   close csr_xchg_rt;
   --
   if p_rates_new.currency <> p_rates_old.currency then
     open csr_xchg_rt(p_rates_new.pl_id
                   ,p_rates_new.oipl_id
                   ,p_rates_new.lf_evt_ocrd_dt
                   ,p_rates_old.currency);
     fetch csr_xchg_rt into l_old_xchg_rt;
     close csr_xchg_rt;
   else
     l_old_xchg_rt := l_new_xchg_rt;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 30);
   end if;
   --
   -- check if the eligibility is changed
   if nvl(p_rates_new.elig_flag,'N') <> nvl(p_rates_old.elig_flag,'N') then
      -- there is a change in eligibility.
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      if nvl(p_rates_new.elig_flag,'N') = 'Y' then
         -- the person has become eligible
         l_elig_count_d :=1;
         if(nvl(p_rates_new.ws_val,0)<>0) then
            l_emp_recv_count_d :=1;
         end if;
         --take the new values as diff values
         l_ws_val_d := p_rates_new.ws_val / l_new_xchg_rt.ws_xchg_rt;
         l_elig_sal_val_d := p_rates_new.elig_sal_val /
			      l_new_xchg_rt.elig_sal_xchg_rt;
         l_stat_sal_val_d := p_rates_new.stat_sal_val /
			      l_new_xchg_rt.stat_sal_xchg_rt;
         l_oth_comp_val_d := p_rates_new.oth_comp_val /
			      l_new_xchg_rt.oth_comp_xchg_rt;
         l_tot_comp_val_d := p_rates_new.tot_comp_val /
			      l_new_xchg_rt.tot_comp_xchg_rt;
         l_misc1_val_d := p_rates_new.misc1_val / l_new_xchg_rt.misc1_xchg_rt;
         l_misc2_val_d := p_rates_new.misc2_val / l_new_xchg_rt.misc2_xchg_rt;
         l_misc3_val_d := p_rates_new.misc3_val / l_new_xchg_rt.misc3_xchg_rt;
         l_rec_val_d  := p_rates_new.rec_val / l_new_xchg_rt.rec_xchg_rt;
         l_rec_mn_val_d := p_rates_new.rec_mn_val / l_new_xchg_rt.rec_xchg_rt;
         l_rec_mx_val_d := p_rates_new.rec_mx_val / l_new_xchg_rt.rec_xchg_rt;
         --
         -- update the bdgt summary,
         if l_new_xchg_rt.uses_bdgt_flag = 'Y' and l_elig_sal_val_d <> 0 then
           ben_cwb_summary_pkg.upd_summary_on_elig_sal_change(
                  p_group_per_in_ler_id => p_rates_new.group_per_in_ler_id
                 ,p_elig_sal_change     => l_elig_sal_val_d);
         end if;
      else
        if g_debug then
           hr_utility.set_location(l_proc, 50);
        end if;
         -- the person has become in-eligible
         l_elig_count_d := -1;
         if(nvl(p_rates_old.ws_val,0)<>0) then
            l_emp_recv_count_d := -1;
         end if;
         -- take the old values as diff values
         l_ws_val_d := -(p_rates_old.ws_val) / l_old_xchg_rt.ws_xchg_rt;
         l_elig_sal_val_d := -(p_rates_old.elig_sal_val) /
			l_old_xchg_rt.elig_sal_xchg_rt;
         l_stat_sal_val_d := -(p_rates_old.stat_sal_val) /
			l_old_xchg_rt.stat_sal_xchg_rt;
         l_oth_comp_val_d := -(p_rates_old.oth_comp_val) /
			l_old_xchg_rt.oth_comp_xchg_rt;
         l_tot_comp_val_d := -(p_rates_old.tot_comp_val) /
			l_old_xchg_rt.tot_comp_xchg_rt;
         l_misc1_val_d := -(p_rates_old.misc1_val) / l_old_xchg_rt.misc1_xchg_rt;
         l_misc2_val_d := -(p_rates_old.misc2_val) / l_old_xchg_rt.misc2_xchg_rt;
         l_misc3_val_d := -(p_rates_old.misc3_val) / l_old_xchg_rt.misc3_xchg_rt;
         l_rec_val_d  := -(p_rates_old.rec_val) /l_old_xchg_rt.rec_xchg_rt;
         l_rec_mn_val_d := -(p_rates_old.rec_mn_val) / l_old_xchg_rt.rec_xchg_rt;
         l_rec_mx_val_d := -(p_rates_old.rec_mx_val) / l_old_xchg_rt.rec_xchg_rt;
         --
         -- update the bdgt summary
         if l_new_xchg_rt.uses_bdgt_flag = 'Y' and l_elig_sal_val_d <> 0 then
           ben_cwb_summary_pkg.upd_summary_on_elig_sal_change(
                    p_group_per_in_ler_id => p_rates_new.group_per_in_ler_id
                   ,p_elig_sal_change     => l_elig_sal_val_d);
         end if;
      end if; -- of elig_flg = 'Y'
   else
      if g_debug then
         hr_utility.set_location(l_proc, 60);
      end if;
      -- there is no change in the eligibiltiy.
      if nvl(p_rates_new.elig_flag,'N') = 'N' then
         -- The emp remains in-eligible. So no change in summary
         return;
      end if;
      --
      l_elig_count_d := 0;
      if (nvl(p_rates_new.ws_val,0) <> 0 and nvl(p_rates_old.ws_val,0)=0) then
         -- The employee got WS val. So increment the emp_recv_count
         l_emp_recv_count_d := 1;
      end if;
      --
      if (nvl(p_rates_new.ws_val,0) = 0 and nvl(p_rates_old.ws_val,0)<>0) then
         -- The employee WS value is cleared. So reduce the emp_recv_count
         l_emp_recv_count_d := -1;
      end if;
      l_ws_val_d       := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.ws_val/l_new_xchg_rt.ws_xchg_rt,
                           -p_rates_old.ws_val/l_old_xchg_rt.ws_xchg_rt);
      l_elig_sal_val_d := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.elig_sal_val/l_new_xchg_rt.elig_sal_xchg_rt,
                           -p_rates_old.elig_sal_val/l_old_xchg_rt.elig_sal_xchg_rt);
      l_stat_sal_val_d := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.stat_sal_val/l_new_xchg_rt.stat_sal_xchg_rt,
                           -p_rates_old.stat_sal_val/l_old_xchg_rt.stat_sal_xchg_rt);
      l_oth_comp_val_d := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.oth_comp_val/l_new_xchg_rt.oth_comp_xchg_rt,
                           -p_rates_old.oth_comp_val/l_old_xchg_rt.oth_comp_xchg_rt);
      l_tot_comp_val_d := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.tot_comp_val/l_new_xchg_rt.tot_comp_xchg_rt,
                           -p_rates_old.tot_comp_val/l_old_xchg_rt.tot_comp_xchg_rt);
      l_misc1_val_d    := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.misc1_val/l_new_xchg_rt.misc1_xchg_rt,
                           -p_rates_old.misc1_val/l_old_xchg_rt.misc1_xchg_rt);
      l_misc2_val_d    := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.misc2_val/l_new_xchg_rt.misc2_xchg_rt,
                           -p_rates_old.misc2_val/l_old_xchg_rt.misc2_xchg_rt);
      l_misc3_val_d    := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.misc3_val/l_new_xchg_rt.misc3_xchg_rt,
                           -p_rates_old.misc3_val/l_old_xchg_rt.misc3_xchg_rt);
      l_rec_val_d      := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.rec_val/l_new_xchg_rt.rec_xchg_rt,
                           -p_rates_old.rec_val/l_old_xchg_rt.rec_xchg_rt);
      l_rec_mn_val_d   := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.rec_mn_val/l_new_xchg_rt.rec_xchg_rt,
                           -p_rates_old.rec_mn_val/l_old_xchg_rt.rec_xchg_rt);
      l_rec_mx_val_d   := ben_cwb_utils.add_number_with_null_check
                          (p_rates_new.rec_mx_val/l_new_xchg_rt.rec_xchg_rt,
                           -p_rates_old.rec_mx_val/l_old_xchg_rt.rec_xchg_rt);
      --
      -- update the bdgt summary,
      if l_new_xchg_rt.uses_bdgt_flag = 'Y' and l_elig_sal_val_d <> 0 then
        ben_cwb_summary_pkg.upd_summary_on_elig_sal_change(
                  p_group_per_in_ler_id => p_rates_new.group_per_in_ler_id
                 ,p_elig_sal_change     => l_elig_sal_val_d);
      end if;
   end if; -- of check comare elig flags.
   if g_debug then
      hr_utility.set_location(l_proc, 70);
   end if;
   --
   -- Check the differences
   if (l_elig_count_d <> 0 or l_emp_recv_count_d <> 0 or l_ws_val_d <> 0 or
       l_elig_sal_val_d <> 0 or l_stat_sal_val_d <> 0 or l_oth_comp_val_d <> 0 or
       l_tot_comp_val_d <> 0 or l_misc1_val_d <> 0 or l_misc2_val_d <> 0 or
       l_misc3_val_d <> 0 or l_rec_val_d <> 0 or l_rec_mn_val_d <> 0 or
       l_rec_mx_val_d <> 0 ) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 80);
      end if;
      --There is a change in the record
      l_immd_mgr := 1;
      for mgr in csr_mgr_pil_ids(p_rates_new.group_per_in_ler_id)
      loop
         ben_cwb_summary_pkg.update_or_insert_pl_sql_tab
               (p_group_per_in_ler_id     => mgr.mgr_per_in_ler_id
               ,p_group_pl_id             => p_rates_old.group_pl_id
               ,p_group_oipl_id           => p_rates_old.group_oipl_id
               ,p_elig_count_direct       => l_elig_count_d * l_immd_mgr
               ,p_elig_count_all          => l_elig_count_d
               ,p_emp_recv_count_direct   => l_emp_recv_count_d * l_immd_mgr
               ,p_emp_recv_count_all      => l_emp_recv_count_d
               ,p_elig_sal_val_direct     => l_elig_sal_val_d * l_immd_mgr
               ,p_elig_sal_val_all        => l_elig_sal_val_d
               ,p_ws_val_direct           => l_ws_val_d * l_immd_mgr
               ,p_ws_val_all              => l_ws_val_d
               ,p_stat_sal_val_direct     => l_stat_sal_val_d * l_immd_mgr
               ,p_stat_sal_val_all        => l_stat_sal_val_d
               ,p_oth_comp_val_direct     => l_oth_comp_val_d * l_immd_mgr
               ,p_oth_comp_val_all        => l_oth_comp_val_d
               ,p_tot_comp_val_direct     => l_tot_comp_val_d * l_immd_mgr
               ,p_tot_comp_val_all        => l_tot_comp_val_d
               ,p_rec_val_direct          => l_rec_val_d * l_immd_mgr
               ,p_rec_val_all             => l_rec_val_d
               ,p_rec_mn_val_direct       => l_rec_mn_val_d * l_immd_mgr
               ,p_rec_mn_val_all          => l_rec_mn_val_d
               ,p_rec_mx_val_direct       => l_rec_mx_val_d * l_immd_mgr
               ,p_rec_mx_val_all          => l_rec_mx_val_d
               ,p_misc1_val_direct        => l_misc1_val_d * l_immd_mgr
               ,p_misc1_val_all           => l_misc1_val_d
               ,p_misc2_val_direct        => l_misc2_val_d * l_immd_mgr
               ,p_misc2_val_all           => l_misc2_val_d
               ,p_misc3_val_direct        => l_misc3_val_d * l_immd_mgr
               ,p_misc3_val_all           => l_misc3_val_d
               );
          l_immd_mgr :=0;
      end loop; -- of csr_mgr_pil_ids;
   end if; -- of check differences
   --
   -- When eligibility changes, we need to check whether the employee's
   -- manager's manager is stil a HLM (when made ineligible) or is now
   -- a HLM (when made eligible).
   --
   if l_new_xchg_rt.uses_bdgt_flag = 'Y' and l_elig_count_d <> 0 then
     ben_cwb_summary_pkg.save_pl_sql_tab;
     ben_cwb_summary_pkg.clean_budget_data(
                  p_per_in_ler_id       => p_rates_new.group_per_in_ler_id
                 ,p_lvl_up              => 2);
     ben_cwb_summary_pkg.save_pl_sql_tab;
   end if;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- update_rates_summary
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_audit_record >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This is an internal procedure to write into the BEN_CWB_AUDIT table to
-- record particular changes in the values of BEN_CWB_PERSON_RATES.
-- Changes evaluated:
-- Code              Desciption
-- CA              Update Compensation Amount
-- ES              Update Eligible Salary
-- SS              Update Started Salary
-- RA              Update Recommended Amount
-- TC              Update Total Compensation Amount
-- OC              Update Other Compensation Amount
-- M1              Update Misc Rate 1
-- M2              Update Misc Rate 2
-- M3              Update Misc Rate 3
-- WN              Update Worksheet Min
-- WX              Update Worksheet Max
-- RN              Update Worksheet Min
-- RX              Update Worksheet Max
-- EL              Update Eligibility Status
-- ER              Update Eligibility Reason
--
procedure create_audit_record
         (p_rates_old csr_rates%rowtype
         ) is

   l_rates_new csr_rates%rowtype;
   l_cwb_audit_id ben_cwb_audit.cwb_audit_id%type;
   l_object_version_number ben_cwb_audit.object_version_number%type;
   l_cd_meaning_old hr_lookups.meaning%type;
   l_cd_meaning_new hr_lookups.meaning%type;
   l_person_id fnd_user.employee_id%type;

    begin

      if g_debug then
        hr_utility.set_location('entering:'|| g_package, 203);
      end if;

      open  csr_rates(p_rates_old.group_per_in_ler_id,
                      p_rates_old.pl_id,
                      p_rates_old.oipl_id);
      fetch csr_rates into l_rates_new;
      close csr_rates;

      select employee_id into l_person_id
      from fnd_user
      where user_id = l_rates_new.last_updated_by;

      if g_debug then
        hr_utility.set_location('person_id:'|| l_person_id, 23);
      end if;
      if g_debug then
        hr_utility.set_location('user_id:'|| l_rates_new.last_updated_by, 24);
      end if;


    if(  ((p_rates_old.ws_val is null)
      and (l_rates_new.ws_val is not null))
      or ((l_rates_new.ws_val is null)
      and (p_rates_old.ws_val is not null))
      or (p_rates_old.ws_val <> l_rates_new.ws_val) ) then

     -- if(nvl(p_rates_old.ws_val,-1)<>nvl(l_rates_new.ws_val,-1)) then
       if(ben_cwb_audit_api.return_lookup_validity('CA')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'CA'
        ,p_old_val_number           => p_rates_old.ws_val
        ,p_new_val_number           => l_rates_new.ws_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
     end if;

    if(  ((p_rates_old.elig_sal_val is null)
      and (l_rates_new.elig_sal_val is not null))
      or ((l_rates_new.elig_sal_val is null)
      and (p_rates_old.elig_sal_val is not null))
      or (p_rates_old.elig_sal_val <> l_rates_new.elig_sal_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('ES')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'ES'
        ,p_old_val_number           => p_rates_old.elig_sal_val
        ,p_new_val_number           => l_rates_new.elig_sal_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.stat_sal_val is null)
      and (l_rates_new.stat_sal_val is not null))
      or ((l_rates_new.stat_sal_val is null)
      and (p_rates_old.stat_sal_val is not null))
      or (p_rates_old.stat_sal_val <> l_rates_new.stat_sal_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('SS')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'SS'
        ,p_old_val_number           => p_rates_old.stat_sal_val
        ,p_new_val_number           => l_rates_new.stat_sal_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.rec_val is null)
      and (l_rates_new.rec_val is not null))
      or ((l_rates_new.rec_val is null)
      and (p_rates_old.rec_val is not null))
      or (p_rates_old.rec_val <> l_rates_new.rec_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('RA')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'RA'
        ,p_old_val_number           => p_rates_old.rec_val
        ,p_new_val_number           => l_rates_new.rec_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.tot_comp_val is null)
      and (l_rates_new.tot_comp_val is not null))
      or ((l_rates_new.tot_comp_val is null)
      and (p_rates_old.tot_comp_val is not null))
      or (p_rates_old.tot_comp_val <> l_rates_new.tot_comp_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('TC')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'TC'
        ,p_old_val_number           => p_rates_old.tot_comp_val
        ,p_new_val_number           => l_rates_new.tot_comp_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.oth_comp_val is null)
      and (l_rates_new.oth_comp_val is not null))
      or ((l_rates_new.oth_comp_val is null)
      and (p_rates_old.oth_comp_val is not null))
      or (p_rates_old.oth_comp_val <> l_rates_new.oth_comp_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('OC')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'OC'
        ,p_old_val_number           => p_rates_old.oth_comp_val
        ,p_new_val_number           => l_rates_new.oth_comp_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.misc1_val is null)
      and (l_rates_new.misc1_val is not null))
      or ((l_rates_new.misc1_val is null)
      and (p_rates_old.misc1_val is not null))
      or (p_rates_old.misc1_val <> l_rates_new.misc1_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('M1')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'M1'
        ,p_old_val_number           => p_rates_old.misc1_val
        ,p_new_val_number           => l_rates_new.misc1_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.misc2_val is null)
      and (l_rates_new.misc2_val is not null))
      or ((l_rates_new.misc2_val is null)
      and (p_rates_old.misc2_val is not null))
      or (p_rates_old.misc2_val <> l_rates_new.misc2_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('M2')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'M2'
        ,p_old_val_number           => p_rates_old.misc2_val
        ,p_new_val_number           => l_rates_new.misc2_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.misc3_val is null)
      and (l_rates_new.misc3_val is not null))
      or ((l_rates_new.misc3_val is null)
      and (p_rates_old.misc3_val is not null))
      or (p_rates_old.misc3_val <> l_rates_new.misc3_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('M3')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'M3'
        ,p_old_val_number           => p_rates_old.misc3_val
        ,p_new_val_number           => l_rates_new.misc3_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.ws_mn_val is null)
      and (l_rates_new.ws_mn_val is not null))
      or ((l_rates_new.ws_mn_val is null)
      and (p_rates_old.ws_mn_val is not null))
      or (p_rates_old.ws_mn_val <> l_rates_new.ws_mn_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('WN')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'WN'
        ,p_old_val_number           => p_rates_old.ws_mn_val
        ,p_new_val_number           => l_rates_new.ws_mn_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.ws_mx_val is null)
      and (l_rates_new.ws_mx_val is not null))
      or ((l_rates_new.ws_mx_val is null)
      and (p_rates_old.ws_mx_val is not null))
      or (p_rates_old.ws_mx_val <> l_rates_new.ws_mx_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('WX')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'WX'
        ,p_old_val_number           => p_rates_old.ws_mx_val
        ,p_new_val_number           => l_rates_new.ws_mx_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.rec_mn_val is null)
      and (l_rates_new.rec_mn_val is not null))
      or ((l_rates_new.rec_mn_val is null)
      and (p_rates_old.rec_mn_val is not null))
      or (p_rates_old.rec_mn_val <> l_rates_new.rec_mn_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('RN')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'RN'
        ,p_old_val_number           => p_rates_old.rec_mn_val
        ,p_new_val_number           => l_rates_new.rec_mn_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.rec_mx_val is null)
      and (l_rates_new.rec_mx_val is not null))
      or ((l_rates_new.rec_mx_val is null)
      and (p_rates_old.rec_mx_val is not null))
      or (p_rates_old.rec_mx_val <> l_rates_new.rec_mx_val) ) then
       if(ben_cwb_audit_api.return_lookup_validity('RX')=true) then
        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'RX'
        ,p_old_val_number           => p_rates_old.rec_mx_val
        ,p_new_val_number           => l_rates_new.rec_mx_val
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.elig_flag is null)
      and (l_rates_new.elig_flag is not null))
      or ((l_rates_new.elig_flag is null)
      and (p_rates_old.elig_flag is not null))
      or (p_rates_old.elig_flag <> l_rates_new.elig_flag) ) then
       if(ben_cwb_audit_api.return_lookup_validity('EL')=true) then

        begin
         select meaning into l_cd_meaning_old
         from hr_lookups
         where lookup_type='BEN_CWB_ELIG_CRITERIA'
         and lookup_code = p_rates_old.elig_flag;
        exception
         when no_data_found then
         -- record does not exist. return null
         l_cd_meaning_old:= p_rates_old.elig_flag;
        end;

        begin
         select meaning into l_cd_meaning_new
         from hr_lookups
         where lookup_type='BEN_CWB_ELIG_CRITERIA'
         and lookup_code = l_rates_new.elig_flag;
        exception
         when no_data_found then
         -- record does not exist. return null
         l_cd_meaning_new:= l_rates_new.elig_flag;
        end;

        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'EL'
        ,p_old_val_varchar          => l_cd_meaning_old
        ,p_new_val_varchar          => l_cd_meaning_new
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
    if(  ((p_rates_old.inelig_rsn_cd is null)
      and (l_rates_new.inelig_rsn_cd is not null))
      or ((l_rates_new.inelig_rsn_cd is null)
      and (p_rates_old.inelig_rsn_cd is not null))
      or (p_rates_old.inelig_rsn_cd <> l_rates_new.inelig_rsn_cd) ) then
       if(ben_cwb_audit_api.return_lookup_validity('ER')=true) then

        begin
         select meaning into l_cd_meaning_old
         from hr_lookups
         where lookup_type='BEN_INELG_RSN'
         and lookup_code = p_rates_old.inelig_rsn_cd;
        exception
         when no_data_found then
         -- record does not exist. return null
         l_cd_meaning_old:= null;
        end;

        begin
         select meaning into l_cd_meaning_new
         from hr_lookups
         where lookup_type='BEN_INELG_RSN'
         and lookup_code = l_rates_new.inelig_rsn_cd;
        exception
         when no_data_found then
         -- record does not exist. return null
         l_cd_meaning_new:= null;
        end;

        ben_cwb_audit_api.create_audit_entry
        (p_group_per_in_ler_id      => l_rates_new.group_per_in_ler_id
        ,p_group_pl_id              => l_rates_new.group_pl_id
        ,p_lf_evt_ocrd_dt           => l_rates_new.lf_evt_ocrd_dt
        ,p_pl_id                    => l_rates_new.pl_id
        ,p_group_oipl_id            => l_rates_new.group_oipl_id
        ,p_audit_type_cd            => 'ER'
        ,p_old_val_varchar          => l_cd_meaning_old
        ,p_new_val_varchar          => l_cd_meaning_new
        ,p_date_stamp               => sysdate
        ,p_change_made_by_person_id => l_person_id
        ,p_cwb_audit_id             => l_cwb_audit_id
        ,p_object_version_number    => l_object_version_number
        );
       end if;
      end if;
   end create_audit_record;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_person_rate >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_rate
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_group_pl_id                   in     number   default hr_api.g_number
  ,p_group_oipl_id                 in     number   default hr_api.g_number
  ,p_lf_evt_ocrd_dt                in     date     default hr_api.g_date
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_elig_flag                     in     varchar2 default hr_api.g_varchar2
  ,p_ws_val                        in     number   default hr_api.g_number
  ,p_ws_mn_val                     in     number   default hr_api.g_number
  ,p_ws_mx_val                     in     number   default hr_api.g_number
  ,p_ws_incr_val                   in     number   default hr_api.g_number
  ,p_elig_sal_val                  in     number   default hr_api.g_number
  ,p_stat_sal_val                  in     number   default hr_api.g_number
  ,p_oth_comp_val                  in     number   default hr_api.g_number
  ,p_tot_comp_val                  in     number   default hr_api.g_number
  ,p_misc1_val                     in     number   default hr_api.g_number
  ,p_misc2_val                     in     number   default hr_api.g_number
  ,p_misc3_val                     in     number   default hr_api.g_number
  ,p_rec_val                       in     number   default hr_api.g_number
  ,p_rec_mn_val                    in     number   default hr_api.g_number
  ,p_rec_mx_val                    in     number   default hr_api.g_number
  ,p_rec_incr_val                  in     number   default hr_api.g_number
  ,p_ws_val_last_upd_date          in     date     default hr_api.g_date
  ,p_ws_val_last_upd_by            in     number   default hr_api.g_number
  ,p_pay_proposal_id               in     number   default hr_api.g_number
  ,p_element_entry_value_id        in     number   default hr_api.g_number
  ,p_inelig_rsn_cd                 in     varchar2 default hr_api.g_varchar2
  ,p_elig_ovrid_dt                 in     date     default hr_api.g_date
  ,p_elig_ovrid_person_id          in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_val            in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_val              in     number   default hr_api.g_number
  ,p_copy_rsrv_val                 in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_mn_val         in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_mx_val         in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_incr_val       in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_mn_val           in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_mx_val           in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_incr_val         in     number   default hr_api.g_number
  ,p_copy_rsrv_mn_val              in     number   default hr_api.g_number
  ,p_copy_rsrv_mx_val              in     number   default hr_api.g_number
  ,p_copy_rsrv_incr_val            in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_iss_val        in     number   default hr_api.g_number
  ,p_copy_ws_bdgt_iss_val          in     number   default hr_api.g_number
  ,p_copy_dist_bdgt_iss_date       in     date     default hr_api.g_date
  ,p_copy_ws_bdgt_iss_date         in     date     default hr_api.g_date
  ,p_comp_posting_date             in     date     default hr_api.g_date
  ,p_ws_rt_start_date              in     date     default hr_api.g_date
  ,p_currency                      in     varchar2 default hr_api.g_varchar2
  ,p_perf_min_max_edit             in     varchar2   default 'Y'
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_rates_old csr_rates%rowtype;
  l_rates_new csr_rates%rowtype;
  --
  cursor csr_mn_mx_vals is
  select ws_mn_val
        ,ws_mx_val
	,ws_incr_val
	,rec_mn_val
	,rec_mx_val
	,rec_incr_val
  from ben_cwb_person_rates rts
  where group_per_in_ler_id = p_group_per_in_ler_id
  and   pl_id = p_pl_id
  and   oipl_id = p_oipl_id;
  --
  l_mn_mx_vals csr_mn_mx_vals%rowtype;
  --
  l_proc                varchar2(72) := g_package||'update_person_rate';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_person_rate;
  --
  -- select the existing values from table.
  open  csr_rates(p_group_per_in_ler_id,p_pl_id,p_oipl_id);
  fetch csr_rates into l_rates_old;
  close csr_rates;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_rates_bk2.update_person_rate_b
      (p_group_per_in_ler_id       => p_group_per_in_ler_id
      ,p_pl_id                     => p_pl_id
      ,p_oipl_id                   => p_oipl_id
      ,p_group_pl_id               => p_group_pl_id
      ,p_group_oipl_id             => p_group_oipl_id
      ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
      ,p_person_id                 => p_person_id
      ,p_assignment_id             => p_assignment_id
      ,p_elig_flag                 => p_elig_flag
      ,p_ws_val                    => p_ws_val
      ,p_ws_mn_val                 => p_ws_mn_val
      ,p_ws_mx_val                 => p_ws_mx_val
      ,p_ws_incr_val               => p_ws_incr_val
      ,p_elig_sal_val              => p_elig_sal_val
      ,p_stat_sal_val              => p_stat_sal_val
      ,p_oth_comp_val              => p_oth_comp_val
      ,p_tot_comp_val              => p_tot_comp_val
      ,p_misc1_val                 => p_misc1_val
      ,p_misc2_val                 => p_misc2_val
      ,p_misc3_val                 => p_misc3_val
      ,p_rec_val                   => p_rec_val
      ,p_rec_mn_val                => p_rec_mn_val
      ,p_rec_mx_val                => p_rec_mx_val
      ,p_rec_incr_val              => p_rec_incr_val
      ,p_ws_val_last_upd_date      => p_ws_val_last_upd_date
      ,p_ws_val_last_upd_by        => p_ws_val_last_upd_by
      ,p_pay_proposal_id           => p_pay_proposal_id
      ,p_element_entry_value_id    => p_element_entry_value_id
      ,p_inelig_rsn_cd             => p_inelig_rsn_cd
      ,p_elig_ovrid_dt             => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id      => p_elig_ovrid_person_id
      ,p_copy_dist_bdgt_val        => p_copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val          => p_copy_ws_bdgt_val
      ,p_copy_rsrv_val             => p_copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val     => p_copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val     => p_copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val   => p_copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val       => p_copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val       => p_copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val     => p_copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val          => p_copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val          => p_copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val        => p_copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val    => p_copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val      => p_copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date   => p_copy_dist_bdgt_iss_date
      ,p_copy_ws_bdgt_iss_date     => p_copy_ws_bdgt_iss_date
      ,p_comp_posting_date         => p_comp_posting_date
      ,p_ws_rt_start_date          => p_ws_rt_start_date
      ,p_currency                  => p_currency
      ,p_object_version_number     => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_RATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Min Max Edits
  --
  if p_perf_min_max_edit = 'Y' then
    --
    open csr_mn_mx_vals;
    fetch csr_mn_mx_vals into l_mn_mx_vals;
    close csr_mn_mx_vals;
    --
    if (p_ws_mx_val is null) then
      l_mn_mx_vals.ws_mx_val := null;
    end if;
    if (p_ws_mx_val <> hr_api.g_number) then
       l_mn_mx_vals.ws_mx_val := p_ws_mx_val;
    end if;
    --
    if (p_ws_mn_val is null) then
      l_mn_mx_vals.ws_mn_val := null;
    end if;
    if (p_ws_mn_val <> hr_api.g_number) then
      l_mn_mx_vals.ws_mn_val := p_ws_mn_val;
    end if;
    --
    if (p_ws_incr_val is null) then
      l_mn_mx_vals.ws_incr_val := null;
    end if;
    if (p_ws_incr_val <> hr_api.g_number) then
      l_mn_mx_vals.ws_incr_val := p_ws_incr_val;
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_proc, 30);
    end if;
    --
    if (p_rec_mx_val is null) then
      l_mn_mx_vals.rec_mx_val := null;
    end if;
    if (p_rec_mx_val <> hr_api.g_number) then
       l_mn_mx_vals.rec_mx_val := p_rec_mx_val;
    end if;
    --
    if (p_rec_mn_val is null) then
      l_mn_mx_vals.rec_mn_val := null;
    end if;
    if (p_rec_mn_val <> hr_api.g_number) then
      l_mn_mx_vals.rec_mn_val := p_rec_mn_val;
    end if;
    --
    if (p_rec_incr_val is null) then
      l_mn_mx_vals.rec_incr_val := null;
    end if;
    if (p_rec_incr_val <> hr_api.g_number) then
      l_mn_mx_vals.rec_incr_val := p_rec_incr_val;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 40);
    end if;
    --
    -- Check Min, Max and Inc for Ws Val
    --
    check_min_max(p_val     => p_ws_val
                 ,p_min_val => l_mn_mx_vals.ws_mn_val
	         ,p_max_val => l_mn_mx_vals.ws_mx_val
	         ,p_incr_val => l_mn_mx_vals.ws_incr_val
	         ,p_group_per_in_ler_id => p_group_per_in_ler_id);
    --
    if g_debug then
      hr_utility.set_location(l_proc, 50);
    end if;
    --
    --
    -- Check Min, Max and Inc for Rec Val
    --
    check_min_max(p_val     => p_rec_val
                 ,p_min_val => l_mn_mx_vals.rec_mn_val
                 ,p_max_val => l_mn_mx_vals.rec_mx_val
	         ,p_incr_val => l_mn_mx_vals.rec_incr_val
                 ,p_group_per_in_ler_id => p_group_per_in_ler_id);
     --
     if g_debug then
       hr_utility.set_location(l_proc, 60);
     end if;
     --
  end if; -- of p_perf_min_max_edit
  --
  -- Process Logic
  --
    ben_rts_upd.upd
      (p_group_per_in_ler_id       => p_group_per_in_ler_id
      ,p_pl_id                     => p_pl_id
      ,p_oipl_id                   => p_oipl_id
      ,p_group_pl_id               => p_group_pl_id
      ,p_group_oipl_id             => p_group_oipl_id
      ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
      ,p_person_id                 => p_person_id
      ,p_assignment_id             => p_assignment_id
      ,p_elig_flag                 => p_elig_flag
      ,p_ws_val                    => p_ws_val
      ,p_ws_mn_val                 => p_ws_mn_val
      ,p_ws_mx_val                 => p_ws_mx_val
      ,p_ws_incr_val               => p_ws_incr_val
      ,p_elig_sal_val              => p_elig_sal_val
      ,p_stat_sal_val              => p_stat_sal_val
      ,p_oth_comp_val              => p_oth_comp_val
      ,p_tot_comp_val              => p_tot_comp_val
      ,p_misc1_val                 => p_misc1_val
      ,p_misc2_val                 => p_misc2_val
      ,p_misc3_val                 => p_misc3_val
      ,p_rec_val                   => p_rec_val
      ,p_rec_mn_val                => p_rec_mn_val
      ,p_rec_mx_val                => p_rec_mx_val
      ,p_rec_incr_val              => p_rec_incr_val
      ,p_ws_val_last_upd_date      => p_ws_val_last_upd_date
      ,p_ws_val_last_upd_by        => p_ws_val_last_upd_by
      ,p_pay_proposal_id           => p_pay_proposal_id
      ,p_element_entry_value_id    => p_element_entry_value_id
      ,p_inelig_rsn_cd             => p_inelig_rsn_cd
      ,p_elig_ovrid_dt             => p_elig_ovrid_dt
      ,p_elig_ovrid_person_id      => p_elig_ovrid_person_id
      ,p_copy_dist_bdgt_val        => p_copy_dist_bdgt_val
      ,p_copy_ws_bdgt_val          => p_copy_ws_bdgt_val
      ,p_copy_rsrv_val             => p_copy_rsrv_val
      ,p_copy_dist_bdgt_mn_val     => p_copy_dist_bdgt_mn_val
      ,p_copy_dist_bdgt_mx_val     => p_copy_dist_bdgt_mx_val
      ,p_copy_dist_bdgt_incr_val   => p_copy_dist_bdgt_incr_val
      ,p_copy_ws_bdgt_mn_val       => p_copy_ws_bdgt_mn_val
      ,p_copy_ws_bdgt_mx_val       => p_copy_ws_bdgt_mx_val
      ,p_copy_ws_bdgt_incr_val     => p_copy_ws_bdgt_incr_val
      ,p_copy_rsrv_mn_val          => p_copy_rsrv_mn_val
      ,p_copy_rsrv_mx_val          => p_copy_rsrv_mx_val
      ,p_copy_rsrv_incr_val        => p_copy_rsrv_incr_val
      ,p_copy_dist_bdgt_iss_val    => p_copy_dist_bdgt_iss_val
      ,p_copy_ws_bdgt_iss_val      => p_copy_ws_bdgt_iss_val
      ,p_copy_dist_bdgt_iss_date   => p_copy_dist_bdgt_iss_date
      ,p_copy_ws_bdgt_iss_date     => p_copy_ws_bdgt_iss_date
      ,p_comp_posting_date         => p_comp_posting_date
      ,p_ws_rt_start_date          => p_ws_rt_start_date
      ,p_currency                  => p_currency
      ,p_object_version_number     => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_rates_bk2.update_person_rate_a
          (p_group_per_in_ler_id       => p_group_per_in_ler_id
          ,p_pl_id                     => p_pl_id
          ,p_oipl_id                   => p_oipl_id
          ,p_group_pl_id               => p_group_pl_id
          ,p_group_oipl_id             => p_group_oipl_id
          ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
          ,p_person_id                 => p_person_id
          ,p_assignment_id             => p_assignment_id
          ,p_elig_flag                 => p_elig_flag
          ,p_ws_val                    => p_ws_val
          ,p_ws_mn_val                 => p_ws_mn_val
          ,p_ws_mx_val                 => p_ws_mx_val
          ,p_ws_incr_val               => p_ws_incr_val
          ,p_elig_sal_val              => p_elig_sal_val
          ,p_stat_sal_val              => p_stat_sal_val
          ,p_oth_comp_val              => p_oth_comp_val
          ,p_tot_comp_val              => p_tot_comp_val
          ,p_misc1_val                 => p_misc1_val
          ,p_misc2_val                 => p_misc2_val
          ,p_misc3_val                 => p_misc3_val
          ,p_rec_val                   => p_rec_val
          ,p_rec_mn_val                => p_rec_mn_val
          ,p_rec_mx_val                => p_rec_mx_val
          ,p_rec_incr_val              => p_rec_incr_val
          ,p_ws_val_last_upd_date      => p_ws_val_last_upd_date
          ,p_ws_val_last_upd_by        => p_ws_val_last_upd_by
          ,p_pay_proposal_id           => p_pay_proposal_id
          ,p_element_entry_value_id    => p_element_entry_value_id
          ,p_inelig_rsn_cd             => p_inelig_rsn_cd
          ,p_elig_ovrid_dt             => p_elig_ovrid_dt
          ,p_elig_ovrid_person_id      => p_elig_ovrid_person_id
          ,p_copy_dist_bdgt_val        => p_copy_dist_bdgt_val
          ,p_copy_ws_bdgt_val          => p_copy_ws_bdgt_val
          ,p_copy_rsrv_val             => p_copy_rsrv_val
          ,p_copy_dist_bdgt_mn_val     => p_copy_dist_bdgt_mn_val
          ,p_copy_dist_bdgt_mx_val     => p_copy_dist_bdgt_mx_val
          ,p_copy_dist_bdgt_incr_val   => p_copy_dist_bdgt_incr_val
          ,p_copy_ws_bdgt_mn_val       => p_copy_ws_bdgt_mn_val
          ,p_copy_ws_bdgt_mx_val       => p_copy_ws_bdgt_mx_val
          ,p_copy_ws_bdgt_incr_val     => p_copy_ws_bdgt_incr_val
          ,p_copy_rsrv_mn_val          => p_copy_rsrv_mn_val
          ,p_copy_rsrv_mx_val          => p_copy_rsrv_mx_val
          ,p_copy_rsrv_incr_val        => p_copy_rsrv_incr_val
          ,p_copy_dist_bdgt_iss_val    => p_copy_dist_bdgt_iss_val
          ,p_copy_ws_bdgt_iss_val      => p_copy_ws_bdgt_iss_val
          ,p_copy_dist_bdgt_iss_date   => p_copy_dist_bdgt_iss_date
          ,p_copy_ws_bdgt_iss_date     => p_copy_ws_bdgt_iss_date
          ,p_comp_posting_date         => p_comp_posting_date
          ,p_ws_rt_start_date          => p_ws_rt_start_date
          ,p_currency                  => p_currency
          ,p_object_version_number     => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_RATE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Update is successful. So call the update_rates_summary to process
  -- the summary information
  open  csr_rates(p_group_per_in_ler_id,p_pl_id,p_oipl_id);
  fetch csr_rates into l_rates_new;
  close csr_rates;

  update_rates_summary(l_rates_old,l_rates_new);

  -- Now call to record changes in audit history table
  create_audit_record(l_rates_old);

  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person_rate;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_person_rate;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_person_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_person_rate >--------------------------|
-- ----------------------------------------------------------------------------
procedure delete_person_rate
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_object_version_number         in     number
  ,p_update_summary                in     boolean default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_person_rate';
  l_rates_old csr_rates%rowtype;
  l_rates_new csr_rates%rowtype;
  --
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_person_rate;
  --
  open  csr_rates(p_group_per_in_ler_id,p_pl_id,p_oipl_id);
  fetch csr_rates into l_rates_old;
  close csr_rates;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_rates_bk3.delete_person_rate_b
          (p_group_per_in_ler_id       => p_group_per_in_ler_id
          ,p_pl_id                     => p_pl_id
          ,p_oipl_id                   => p_oipl_id
          ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_RATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_rts_del.del
      (p_group_per_in_ler_id       => p_group_per_in_ler_id
      ,p_pl_id                     => p_pl_id
      ,p_oipl_id                   => p_oipl_id
      ,p_object_version_number     => p_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_rates_bk3.delete_person_rate_a
          (p_group_per_in_ler_id       => p_group_per_in_ler_id
          ,p_pl_id                     => p_pl_id
          ,p_oipl_id                   => p_oipl_id
          ,p_object_version_number     => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_RATE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Delete is successful. So call the update_rates_summary to process
  -- the summary information
  --
  if p_update_summary then
    l_rates_new := l_rates_old;
    l_rates_new.elig_flag := 'N'; --Making a rec inelig is like deleting.
    update_rates_summary(l_rates_old,l_rates_new);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_person_rate;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_person_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_person_rate;
--
--
end ben_cwb_person_rates_api;

/
