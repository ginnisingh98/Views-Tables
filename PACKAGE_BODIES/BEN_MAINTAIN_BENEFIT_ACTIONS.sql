--------------------------------------------------------
--  DDL for Package Body BEN_MAINTAIN_BENEFIT_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MAINTAIN_BENEFIT_ACTIONS" as
/* $Header: benbmbft.pkb 120.1 2006/05/18 11:11:19 nhunur noship $ */
--
g_package varchar2(50) := 'ben_maintain_benefit_actions.';
--
PROCEDURE grab_next_batch_range
  (p_benefit_action_id      in     number
  --
  ,p_start_person_action_id    out nocopy number
  ,p_end_person_action_id      out nocopy number
  ,p_rows_found                out nocopy boolean
  )
IS
  --
  cursor c_range_thread
    (c_bft_id number
    )
  is
    select /*+ index(ran BEN_BATCH_RANGES_CK) */
           ran.rowid,
           ran.starting_person_action_id,
           ran.ending_person_action_id
    from   ben_batch_ranges ran
    where  ran.range_status_cd = 'U'
    and    ran.benefit_action_id = c_bft_id
    and    rownum < 2
    for    update of ran.range_status_cd;
  --
  l_rowid             rowid;
  --
BEGIN
  --
  p_rows_found        := false;
  --
  open c_range_thread
    (c_bft_id => p_benefit_action_id
    );
  fetch c_range_thread into l_rowid,
                            p_start_person_action_id,
                            p_end_person_action_id;
  if c_range_thread%found then
    --
    p_rows_found := true;
    --
    update ben_batch_ranges ran
    set    ran.range_status_cd = 'P'
    where  ran.rowid = l_rowid;
    --
  end if;
  close c_range_thread;
  --
END grab_next_batch_range;
--
procedure start_slaves
  (p_threads                  in number
  ,p_num_ranges               in number
  ,p_validate                 in varchar2
  ,p_benefit_action_id        in number
  ,p_effective_date           in varchar2
  ,p_pgm_id                   in number
  ,p_business_group_id        in number
  ,p_pl_id                    in number
  ,p_no_programs              in varchar2
  ,p_no_plans                 in varchar2
  ,p_rptg_grp_id              in number
  ,p_pl_typ_id                in number
  ,p_opt_id                   in number
  ,p_eligy_prfl_id            in number
  ,p_vrbl_rt_prfl_id          in number
  ,p_mode                     in varchar2
  ,p_person_selection_rule_id in number
  ,p_comp_selection_rule_id   in number
  ,p_derivable_factors        in varchar2
  ,p_cbr_tmprl_evt_flag       in varchar2
  ,p_lf_evt_ocrd_dt           in varchar2
  ,p_lmt_prpnip_by_org_flag   in varchar2
  ,p_gsp_eval_elig_flag       in varchar2 default null  -- GSP Rate Sync : Evaluate Eligibility
  ,p_lf_evt_oper_cd           in varchar2 default null  -- GSP Rate Sync : Life Event Operation code
  )
is
  --
  l_package        varchar2(80) := g_package||'.start_slaves';
  l_request_id     number;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  if p_threads > 0 then
    --
    for l_count in 1..least(p_threads,p_num_ranges) loop
      --
      hr_utility.set_location ('Submitting request '||l_package,10);
      --
      l_request_id := fnd_request.submit_request
        (application => 'BEN',
         program     => 'BENTHREAD',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_validate,
         argument2   => p_benefit_action_id,
         argument3   => p_effective_date,
         argument4   => p_pgm_id,
         argument5   => p_business_group_id,
         argument6   => p_pl_id,
         -- PB : 5422 :
         -- Temporarily uncommented.
         argument7   => null, -- p_popl_enrt_typ_cycl_id,
         argument8   => p_no_programs,
         argument9   => p_no_plans,
         argument10  => p_rptg_grp_id,
         argument11  => p_pl_typ_id,
         argument12  => p_opt_id,
         argument13  => p_eligy_prfl_id,
         argument14  => p_vrbl_rt_prfl_id,
         argument15  => p_mode,
         argument16  => p_person_selection_rule_id,
         argument17  => p_comp_selection_rule_id,
         argument18  => p_derivable_factors,
         argument19  => l_count,
         argument20  => p_lf_evt_ocrd_dt,
         argument21  => p_cbr_tmprl_evt_flag,
         argument22  => p_lmt_prpnip_by_org_flag,
         argument23  => p_gsp_eval_elig_flag,          -- GSP Rate Sync : Evaluate Eligibility
         argument24  => p_lf_evt_oper_cd               -- GSP Rate Sync : Life Event Operation code
         );
      --
      -- Store the request id of the concurrent request
      --
      ben_maintain_benefit_actions.g_num_processes := ben_maintain_benefit_actions.g_num_processes + 1;
      ben_maintain_benefit_actions.g_processes_rec(g_num_processes) := l_request_id;
      --
      hr_utility.set_location ('Submitted request '||l_package,10);
    end loop;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
  commit;
  --
end start_slaves;
--
procedure check_slaves_status
  (p_num_processes in     number
  ,p_processes_rec in     ben_maintain_benefit_actions.g_processes_table
  ,p_master        in     varchar2
  ,p_slave_errored    out nocopy boolean
  )
is
  --
  l_package        varchar2(80) := g_package||'.check_slaves_status';
  --
  l_no_slaves      boolean;
  l_poll_loops     pls_integer;
  l_slave_errored  boolean;
  --
  cursor c_slaves
    (c_request_id number
    )
  is
    select phase_code,
           status_code
    from   fnd_concurrent_requests fnd
    where  fnd.request_id = c_request_id;
  --
  l_slaves c_slaves%rowtype;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  if p_num_processes <> 0 and p_master = 'Y'
  then
    --
    -- 2237993 : threads are not synchronised as without initialization
    -- code is not being executed.
    --
    l_no_slaves := true;
    while l_no_slaves loop
      --
      l_no_slaves := false;
      --
      for elenum in 1..p_num_processes
      loop
        --
        open c_slaves
          (p_processes_rec(elenum)
          );
        fetch c_slaves into l_slaves;
        if l_slaves.phase_code <> 'C'
        then
          --
          l_no_slaves := true;
          --
        end if;
        --
        if l_slaves.status_code = 'E' then
          --
          l_slave_errored := true;
          --
        end if;
        --
        close c_slaves;
        --
        -- Loop to avoid over polling of fnd_concurrent_requests
        --
        -- l_poll_loops := 100000;
        dbms_lock.sleep(4);
	--
        -- for i in 1..l_poll_loops
        -- loop
        --
        --  null;
        --
        -- end loop;
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
  commit;
  --
end check_slaves_status;
--
procedure check_all_slaves_finished
  (p_benefit_action_id in     number
  ,p_business_group_id in     number
  ,p_slave_errored        out nocopy boolean
  )
is
  --
  l_package       varchar2(80) := g_package||'.check_all_slaves_finished';
  l_no_slaves     boolean := true;
  l_dummy         varchar2(1);
  l_master        varchar2(1) := 'N';
  l_param_rec     benutils.g_batch_param_rec;
  l_slave_errored boolean := false;
  --
  cursor c_master is
    select 'Y'
    from   ben_benefit_actions bft
    where  bft.benefit_action_id = p_benefit_action_id
    and    bft.request_id = fnd_global.conc_request_id;
  --
  cursor c_person_actions(p_status_cd varchar2) is
    select count(*)
    from   ben_person_actions pac
    where  pac.benefit_action_id = p_benefit_action_id
    and    pac.action_status_cd = nvl(p_status_cd,pac.action_status_cd);
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Work out if process is master
  --
  open c_master;
    --
    fetch c_master into l_master;
    --
  close c_master;
  --
  benutils.get_batch_parameters
    (p_benefit_action_id => p_benefit_action_id,
     p_rec               => l_param_rec);
  --
  -- Check slave status
  --
  ben_maintain_benefit_actions.check_slaves_status
    (p_num_processes => ben_maintain_benefit_actions.g_num_processes
    ,p_processes_rec => ben_maintain_benefit_actions.g_processes_rec
    ,p_master        => l_master
    --
    ,p_slave_errored => l_slave_errored
    );
  --
  hr_utility.set_location (l_package||' OUT NOCOPY slave loop ',20);
  --
  -- Log process information
  -- This is master specific only
  --
  if l_master = 'Y' then
    --
    ben_manage_life_events.write_bft_statistics
      (p_business_group_id => p_business_group_id
      ,p_benefit_action_id => p_benefit_action_id
      );
    --
  end if;
  hr_utility.set_location (l_package||' Write to file ',35);
  --
  benutils.write_table_and_file(p_table  =>  true,
                                p_file => false);
  commit;
  --
  -- Fire off Reports for BENMNGLE run.
  --
  if l_master = 'Y' then
    --
    -- Process Log
    -- Activity Summary
    -- Error by Error Type
    -- Error by Person
    --
    -- Don't do this code if we are running from SQL Plus
    --
    -- GLOBALCWB
    if fnd_global.conc_request_id <> -1
    then
      --
      if l_param_rec.mode_cd<>'W' then
      hr_utility.set_location (l_package||' Fire Reports ',40);
      ben_batch_reporting.batch_reports
        (p_concurrent_request_id => fnd_global.conc_request_id,
         p_report_type           => 'GENERIC_LOG');
      if l_param_rec.mode_cd<>'R' then
        ben_batch_reporting.batch_reports
        (p_concurrent_request_id => fnd_global.conc_request_id,
         p_mode                  => l_param_rec.mode_cd,
         p_report_type           => 'ACTIVITY_SUMMARY');
      end if;
        ben_batch_reporting.batch_reports
          (p_concurrent_request_id => fnd_global.conc_request_id,
           p_report_type           => 'ERROR_BY_ERROR_TYPE');
        ben_batch_reporting.batch_reports
          (p_concurrent_request_id => fnd_global.conc_request_id,
           p_report_type           => 'ERROR_BY_PERSON');
      hr_utility.set_location (l_package||' Dn Fire Reports ',40);
      --
      end if;
      commit;
      --
    end if;
    --
  end if;
  --
  p_slave_errored := l_slave_errored;
  --
  hr_utility.set_location ('Leaving '||l_package,50);
  --
end check_all_slaves_finished;
--
PROCEDURE get_peractionrange_persondets
  (p_benefit_action_id      in            number
  ,p_start_person_action_id in            number
  ,p_end_person_action_id   in            number
  --
  ,p_personid_va            in out nocopy benutils.g_number_table
  ,p_pactid_va              in out nocopy benutils.g_number_table
  ,p_pactovn_va             in out nocopy benutils.g_number_table
  ,p_lerid_va               in out nocopy benutils.g_number_table
  )
IS
  --
  l_personid_va  benutils.g_number_table   := benutils.g_number_table();
  l_pactid_va    benutils.g_number_table   := benutils.g_number_table();
  l_pactovn_va   benutils.g_number_table   := benutils.g_number_table();
  l_lerid_va     benutils.g_number_table   := benutils.g_number_table();
  --
  cursor c_person_details
    (c_bft_id     number
    ,c_stpact_id  number
    ,c_endpact_id number
    )
  is
    select pact.person_id,
           pact.person_action_id,
           pact.object_version_number,
           pact.ler_id
    from   ben_person_actions pact
    where  pact.benefit_action_id = c_bft_id
    and    pact.action_status_cd = 'U'
    and    pact.person_action_id
      between c_stpact_id and c_endpact_id;
  --
BEGIN
  --
  open c_person_details
    (c_bft_id     => p_benefit_action_id
    ,c_stpact_id  => p_start_person_action_id
    ,c_endpact_id => p_end_person_action_id
    );
  fetch c_person_details BULK COLLECT INTO l_personid_va,
                                           l_pactid_va,
                                           l_pactovn_va,
                                           l_lerid_va;
  close c_person_details;
  --
  p_personid_va := l_personid_va;
  p_pactid_va   := l_pactid_va;
  p_pactovn_va  := l_pactovn_va;
  p_lerid_va    := l_lerid_va;
  --
END get_peractionrange_persondets;
--
end ben_maintain_benefit_actions;

/
