--------------------------------------------------------
--  DDL for Package Body BEN_EFC_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_VALIDATION" as
/* $Header: beefcval.pkb 120.0.12010000.4 2008/08/05 14:23:49 ubhat ship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      12-Jul-01	mhoyes     Created.
  115.1      26-Jul-01	mhoyes     Enhanced for Patchset E+ patch.
  115.2      13-Aug-01	mhoyes     Enhanced for Patchset E+ patch.
  115.3      14-Aug-01	mhoyes     Removed patch checking.
  115.4      31-Aug-01	mhoyes     Enhanced for BEN July patch.
  115.5      13-Sep-01	mhoyes     Enhanced for BEN July patch.
  115.7      17-Sep-01	mhoyes     Raised error for batch ranges.
  115.8      28-Sep-01	mhoyes     Enhanced for BEN patchset F.
  115.9      05-Mar-02	mhoyes   - Fixed bug 2252610. Weakened vaildation
                                   to exclude online benmgle and extract
                                   benefit actions.
  115.10     13-Mar-02  ikasire    UTF8 Changes
  115.11     14-mar-02  ikasire    GSCC error
  115.12     16-Feb-06  rbingi     Bug5042850: Checking only for Unprocessed actual person
                                    rows eliminating with non_person_cd is null
  115.14     03-Nov-06  rtagarra   Bug 5049253 : Changed Phases.
  115.15     13-Nov-06  rtagarra   Closed the worker and updated the step to C_RECAL from
				   C_UPDATE.
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_efc_validation.';
--
procedure adjust_validation
  (p_worker_id           in     number   default null
  ,p_total_workers       in     number   default null
  ,p_ent_scode           in     varchar2 default null
  --
  ,p_disp_private        in     boolean  default false
  ,p_disp_succeeds       in     boolean  default false
  ,p_disp_exclusions     in     boolean  default false
  --
  ,p_valworker_id        in     number   default null
  ,p_valtotal_workers    in     number   default null
  --
  ,p_multithread_substep in     number   default null
  --
  ,p_business_group_id   in     number   default null
  )
is
  --
  l_proc                  varchar2(1000) := 'adjust_validation';
  --
  l_adjustment_counts     ben_efc_adjustments.g_adjustment_counts;
  --
  l_bftid_va              benutils.g_number_table := benutils.g_number_table();
  l_bftprdt_va            benutils.g_date_table := benutils.g_date_table();
  l_bftmdcd_va            benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_pgmid_va              benutils.g_number_table := benutils.g_number_table();
  l_bftdfflg_va           benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_bftcuflg_va           benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_bftnprflg_va          benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_bftnplflg_va          benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_bftvlflg_va           benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_cnt_va                benutils.g_number_table := benutils.g_number_table();
  --
  l_fixbftid_va           benutils.g_number_table := benutils.g_number_table();
  --
  l_action_id             number;
  l_bgp_id                number;
  l_chunk                 number;
  l_efc_component_id      number;
  --
  l_proccomp_name         varchar2(100);
  --
  l_pk1                   number;
  l_pk2                   date;
  l_pk3                   date;
  l_status                varchar2(1);
  l_pk2char               varchar2(2000) := '' ; -- UTF8 varchar2(100) := '';
  l_pk3char               varchar2(2000) := '' ; -- UTF8 varchar2(100) := '';
  l_pk4char               varchar2(2000) := '' ; -- UTF8 varchar2(100) := '';
  l_pk5char               varchar2(2000) := '' ; -- UTF8 varchar2(100) := '';
  l_efc_worker_id         number;
  l_worker_id             number;
  l_total_workers         number;
  l_rcu_action_id         number;
  --
  l_modify                boolean;
  l_validation            boolean;
  l_upbatrow_count        number;
  --
  l_table                 varchar2(100);
  l_bft_cnt               pls_integer;
  l_bftext_cnt            pls_integer;
  l_extract               boolean;
  --
/*
  CURSOR csr_find_batch_ranges
    (c_bg IN NUMBER
    )
  IS
    SELECT count(*)
      FROM ben_batch_ranges bbr,
           ben_benefit_actions bft
     WHERE bbr.benefit_action_id = bft.benefit_action_id
     and   bft.business_group_id = c_bg
     and   bbr.range_status_cd = 'U'
     group by bbr.benefit_action_id;
*/
-- Bug 5042850, non_person_cd is NN tells its not actually the person row
  CURSOR csr_find_batch_ranges
    (c_bg IN NUMBER
    )
  IS
    SELECT bft.benefit_action_id,
           bft.process_date,
           bft.mode_cd,
           bft.pgm_id,
           bft.derivable_factors_flag,
           bft.close_uneai_flag,
           bft.no_programs_flag,
           bft.no_plans_flag,
           bft.validate_flag,
           count(*)
      FROM ben_person_actions act,
           ben_benefit_actions bft
     WHERE act.benefit_action_id = bft.benefit_action_id
     and   bft.business_group_id = c_bg
     and   act.ACTION_STATUS_CD = 'U'
     and   act.non_person_cd is null -- Bug 5042850
     group by bft.benefit_action_id,
              bft.process_date,
              bft.mode_cd,
              bft.pgm_id,
              bft.derivable_factors_flag,
              bft.close_uneai_flag,
              bft.no_programs_flag,
              bft.no_plans_flag,
              bft.validate_flag
     having count(*) > 1
     order by bft.benefit_action_id desc;
  --
  cursor c_getexrsltdets
    (c_eff_date    date
    ,c_bgp_id      number
    ,c_ext_dfn_id  number
    )
  is
    select rst.ext_rslt_id
    from ben_ext_rslt rst
    where rst.eff_dt = c_eff_date
    and   rst.business_group_id = c_bgp_id
    and   rst.ext_dfn_id = c_ext_dfn_id;
  --
  l_getexrsltdets c_getexrsltdets%rowtype;
  --
begin
  --
  hr_general.g_data_migrator_mode := 'Y';
  --
  l_modify     := FALSE;
  l_validation := FALSE;
  --
  -- Running in standalone mode with no actions
  --
  if p_business_group_id is not null then
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line
      ('-- Re-calculating/adjusting in validate mode with no actions ');
    hr_efc_info.insert_line('-- ');
    --
    l_action_id     := null;
    l_pk1           := null;
    l_chunk         := null;
    l_efc_worker_id := null;
    l_bgp_id        := p_business_group_id;
    l_worker_id     := null;
    l_total_workers := null;
    l_validation    := TRUE;
    --
  --
  -- Running in validation mode with actions
  --
  elsif p_worker_id is null
    and p_total_workers is null
  then
    --
    hr_efc_info.get_action_details
      (l_action_id
      ,l_bgp_id
      ,l_chunk
      );
    --
    l_pk1           := null;
    l_chunk         := null;
    l_efc_worker_id := null;
    l_worker_id     := null;
    l_total_workers := null;
    l_validation    := TRUE;
    --
  --
  -- Running in conversion mode with actions
  --
  else
    --
    if p_multithread_substep is not null then
      --
      hr_efc_info.insert_line('-- ');
      hr_efc_info.insert_line
        ('-- Re-calculating/adjusting converted monetary values phase '||p_multithread_substep);
      hr_efc_info.insert_line('-- ');
      --
      if p_multithread_substep = 10 then
        --
        l_table := 'ben_elig_per_f';
l_proccomp_name := 'beadjefu';

        --
      elsif p_multithread_substep = 20 then
        --
        l_table := 'ben_enrt_prem';
l_proccomp_name := 'beaj1efu';

        --
      elsif p_multithread_substep = 30 then
        --
        l_table := 'ben_enrt_rt';
l_proccomp_name := 'beaj2efu';

        --
      elsif p_multithread_substep = 40 then
        --
        l_table := 'ben_prtt_rt_val';
l_proccomp_name := 'beaj3efu';

        --
      elsif p_multithread_substep = 50 then
        --
        l_table := 'pay_element_entry_values_f';
l_proccomp_name := 'beaj4efu';
        --
      end if;
      --
    else
      --
      hr_efc_info.insert_line('-- ');
      hr_efc_info.insert_line
        ('-- Re-calculating/adjusting converted monetary values for all phases ');
      hr_efc_info.insert_line('-- ');
      --
      l_table := 'ALLTABS';
l_proccomp_name := 'beadjust';

      --
    end if;
    --
    l_worker_id     := p_worker_id;
    l_total_workers := p_total_workers;
--    l_proccomp_name := 'beadjust';
    --
    hr_efc_info.get_action_details
      (l_action_id
      ,l_bgp_id
      ,l_chunk
      );
    --
    -- First processor only - insert a row into the HR_EFC_PROCESS_COMPONENTS
    -- table (procedure includes locking so that only 1 row is inserted)
    --
    hr_efc_info.insert_or_select_comp_row
      (p_action_id              => l_action_id
      ,p_process_component_name => l_proccomp_name
      ,p_table_name             => l_table
      ,p_total_workers          => l_total_workers
      ,p_worker_id              => l_worker_id
      ,p_step                   => 'C_RECAL'
      ,p_sub_step               => p_multithread_substep
      ,p_process_component_id   => l_efc_component_id
      );
    --
    -- Call procedure to check if this worker has already started (will detect
    -- if this worker has been restarted).
    --
    hr_efc_info.insert_or_select_worker_row
      (p_process_component_id   => l_efc_component_id
      ,p_process_component_name => l_proccomp_name
      ,p_action_id              => l_action_id
      ,p_worker_number          => l_worker_id
      --
      ,p_pk1                    => l_pk1
      ,p_pk2                    => l_pk2char
      ,p_pk3                    => l_pk3char
      ,p_pk4                    => l_pk4char
      ,p_pk5                    => l_pk5char
      ,p_status                 => l_status
      --
      ,p_efc_worker_id          => l_efc_worker_id
      );
    --
    l_modify := TRUE;
    --
  end if;
  --
  -- Remove all exclusions for the EFC action
  --
  delete from ben_efc_exclusions
  where efc_action_id = l_action_id;
  --
  -- Check for validate mode
  --
  l_rcu_action_id := l_action_id;
  --
  if l_validation then
    --
    -- Need to nullify action id in validate mode to avoid action
    -- specific validation
    --
    l_action_id := null;
    --
  end if;
  --
  -- Only validate the batch ranges in validation mode
  --
  if p_multithread_substep is null
    and p_ent_scode = 'BFT'
  then
    --
    -- Check for unprocessed batch ranges
    --
    hr_efc_info.insert_line('-- ');
    hr_efc_info.insert_line('-- Check for uncomplete benefit actions in BEN_BENEFIT_ACTIONS table...');
    hr_efc_info.insert_line('-- ');
    --
    OPEN csr_find_batch_ranges(l_bgp_id);
    FETCH csr_find_batch_ranges BULK COLLECT INTO l_bftid_va,
                                                  l_bftprdt_va,
                                                  l_bftmdcd_va,
                                                  l_pgmid_va,
                                                  l_bftdfflg_va,
                                                  l_bftcuflg_va,
                                                  l_bftnprflg_va,
                                                  l_bftnplflg_va,
                                                  l_bftvlflg_va,
                                                  l_cnt_va;
    CLOSE csr_find_batch_ranges;
    --
    if l_bftid_va.count > 0 then
      --
      l_bft_cnt    := 0;
      l_bftext_cnt := 0;
      --
      for elenum in l_bftid_va.first..l_bftid_va.last
      loop
        --
        l_extract := FALSE;
        --
        if l_bft_cnt = 20 then
          --
          exit;
          --
        end if;
        --
        -- Exclude out extracts
        --
        if l_bftmdcd_va(elenum) = 'S'
          and l_pgmid_va(elenum) is not null
          and l_bftdfflg_va(elenum) = 'N'
          and l_bftcuflg_va(elenum) = 'N'
          and l_bftnprflg_va(elenum) = 'N'
          and l_bftnplflg_va(elenum) = 'N'
          and l_bftvlflg_va(elenum) = 'N'
        then
          --
          -- Check if an extract result exists
          --
          open c_getexrsltdets
            (c_eff_date   => l_bftprdt_va(elenum)
            ,c_bgp_id     => l_bgp_id
            ,c_ext_dfn_id => l_pgmid_va(elenum)
            );
          fetch c_getexrsltdets into l_getexrsltdets;
          if c_getexrsltdets%found then
            --
            l_bftext_cnt := l_bftext_cnt+1;
            l_extract := TRUE;
            --
          else
            --
            l_extract := FALSE;
            --
          end if;
          close c_getexrsltdets;
          --
        else
          --
          l_extract := FALSE;
          --
        end if;
        --
        if not l_extract then
          --
          if l_bft_cnt = 0
          then
            --
            hr_efc_info.insert_line('-- Uncompleted batch information identified for the following');
            hr_efc_info.insert_line('-- rows in ben_benefit_actions ');
            hr_efc_info.insert_line('-- ');
            hr_efc_info.insert_line('-- Benefit Action ID /Mode Cd /Process date /Person Action Count');
            hr_efc_info.insert_line('-- ');
            --
          end if;
          --
          hr_efc_info.insert_line('-- '||l_bftid_va(elenum)
                                 ||' /'||l_bftmdcd_va(elenum)
                                 ||' /'||l_bftprdt_va(elenum)
                                 ||' /'||l_cnt_va(elenum)
                                 );
          --
          l_fixbftid_va.extend(1);
          l_fixbftid_va(l_bft_cnt+1) := l_bftid_va(elenum);
          l_bft_cnt := l_bft_cnt+1;
          --
        end if;
        --
      end loop;
      --
      if l_bft_cnt > 0 then
        --
        hr_efc_info.insert_line('-- ');
        hr_efc_info.insert_line('-- The uncompleted benefit actions above need to be resolved. Use ');
        hr_efc_info.insert_line('-- the restart process to complete. ');
        hr_efc_info.insert_line('-- ');
        --
        hr_efc_info.g_efc_error_app := 805;
        hr_efc_info.g_efc_error_message := 'BEN_92694_EFC_UNPROC_RANGES';
        --
      else
        --
        hr_efc_info.insert_line('-- ');
        hr_efc_info.insert_line('-- Detected '||l_bftext_cnt||' Extracts. ');
        hr_efc_info.insert_line('-- No Actions required ');
        hr_efc_info.insert_line('-- ');
        --
      end if;
      --
    END IF;
    --
  end if;
  --
  if nvl(p_multithread_substep,10) = 10 then
    --
    -- Only call the rounding code upgrade for adjustments
    --
    if p_multithread_substep is not null then
      --
      -- Upgrade rounding codes
      --
      -- Action is required in validate mode to perform the
      -- backup of the rounding codes.
      --
      -- We only need to backup the rounding codes for the first
      -- thread.
      --
      ben_efc_rndg_cd_upgrade.upgrade_rounding_codes
        (p_business_group_id => l_bgp_id
        ,p_action_id         => l_rcu_action_id
        ,p_modify            => l_modify
        );
      --
    end if;
    --
    if p_ent_scode is null
      or p_ent_scode = 'PEP'
    then
      --
      ben_efc_adjustments.pep_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'PEP'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_pep_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_pep_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_pep_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_pep_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
    if p_ent_scode is null
      or p_ent_scode = 'EPO'
    then
      --
      ben_efc_adjustments.epo_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'EPO'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_epo_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_epo_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_epo_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_epo_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
    if p_ent_scode is null
      or p_ent_scode = 'ENB'
    then
      --
      ben_efc_adjustments.enb_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'ENB'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_enb_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_enb_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_enb_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_enb_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
  end if;
  --
  if nvl(p_multithread_substep,20) = 20 then
    --
    if p_ent_scode is null
      or p_ent_scode = 'EPR'
    then
      --
      ben_efc_adjustments.epr_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'EPR'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_epr_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_epr_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_epr_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_epr_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
  end if;
  --
  if nvl(p_multithread_substep,30) = 30 then
    --
    if p_ent_scode is null
      or p_ent_scode = 'ECR'
    then
      --
      ben_efc_adjustments.ecr_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'ECR'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_ecr_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_ecr_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_ecr_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_ecr_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
  end if;
  --
  if nvl(p_multithread_substep,40) = 40 then
    --
    if p_ent_scode is null
      or p_ent_scode = 'PRV'
    then
      --
      ben_efc_adjustments1.prv_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'PRV'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_prv_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_prv_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_prv_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_prv_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
  end if;
  --
  if nvl(p_multithread_substep,50) = 50 then
    --
    if p_ent_scode is null
      or p_ent_scode = 'EEV'
    then
      --
      ben_efc_adjustments1.eev_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'EEV'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_eev_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_eev_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_eev_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_eev_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
    if p_ent_scode is null
      or p_ent_scode = 'BPL'
    then
      --
      ben_efc_adjustments1.bpl_adjustments
        (p_validate          => FALSE
        ,p_worker_id         => p_worker_id
        ,p_action_id         => l_action_id
        ,p_total_workers     => p_total_workers

        ,p_pk1               => l_pk1
        ,p_chunk             => l_chunk
        ,p_efc_worker_id     => l_efc_worker_id
        --
        ,p_valworker_id      => p_valworker_id
        ,p_valtotal_workers  => p_valtotal_workers
        --
        ,p_business_group_id => l_bgp_id
        --
        ,p_adjustment_counts => l_adjustment_counts
        );
      --
      if l_validation then
        --
        ben_efc_reporting.DisplayEFCInfo
          (p_ent_scode           => 'BPL'
          ,p_efc_action_id       => l_action_id
          ,p_adjustment_counts   => l_adjustment_counts
          --
          ,p_disp_private        => p_disp_private
          ,p_disp_succeeds       => p_disp_succeeds
          ,p_disp_exclusions     => p_disp_exclusions
          --
          ,p_rcoerr_val_set      => ben_efc_adjustments.g_bpl_rcoerr_val_set
          ,p_failed_adj_val_set  => ben_efc_adjustments.g_bpl_failed_adj_val_set
          ,p_fatal_error_val_set => ben_efc_adjustments.g_bpl_fatal_error_val_set
          ,p_success_val_set     => ben_efc_adjustments.g_bpl_success_adj_val_set
          );
        --
      end if;
      --
    end if;
    --
  end if;



    hr_efc_info.complete_worker_row
        (p_efc_worker_id => l_efc_worker_id
        ,p_pk1           => l_pk1
        );

commit;



  --
end adjust_validation;
--
end ben_efc_validation;

/
