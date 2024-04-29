--------------------------------------------------------
--  DDL for Package Body BEN_MANAGE_CWB_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MANAGE_CWB_LIFE_EVENTS" as
/* $Header: bencwbcm.pkb 120.31.12010000.4 2009/02/20 10:35:09 sgnanama ship $ */
--
/*
+========================================================================+
|             Copyright (c) 1997 Oracle Corporation                      |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
--
Name
    Manage Life Events
Purpose
        This package is used to handle cwb pre-benmngle process and post
        benmngle cwb relevent actions like populating the cross business group
        and other hierarchy data.
History
     Date             Who        Version    What?
     ----             ---        -------    -----
     19 Dec 03        pbodla/
                      Indrasen   115.0      Created.
     22 Dec 03        Indrasen   115.1      removed 1 from package name
     29 Dec 03        Indrasen   115.3      Added more procedures
     05 Jan 03        Indrasen   115.4      Adding rebuild Hierarchy
     06 Jan 03        pbodla     115.4      Added code to populate cwb_tasks
                                            and populate_cwb_rates
     07 Jan 03        pbodla     115.5      Added code to populate cwb_rates
     08 Jan 03        pbodla/    115.6      Added code to populate cwb_rates
                      ikasire               as suggested by cwb team.
     08 Jan 03        pbodla     115.7      Added code to for auto budget issue
     17 Jan 03        pbodla/    115.8      Added code to populate missing pils
                      ikasire               Added code for global logging.
                                            Added calls for missing group pils
                                            and biuild Hierarchy
     21 Jan 03        pbodla     115.8      Integrated with CWB procedures.
     21 Jan 03        pbodla     115.9      Fixed popu_missing_person_pil to
                                            populate data properly.
     28 Jan 03        pbodla     115.12     Added code populate group pil id on
                                            ben_cwb_person_rates if group pil
                                            is null
     02 Feb 04        pbodla     115.13     Added c_benfts_grp cursor to fetch
                                            the benefit group based on name.
                                            Plans business group id have to
                                            be passed when cwb_process is
                                            called.
     04 Feb 04        pbodla/    115.14     Modified get_gpil_id cursor.
                      ikasire

     04 Feb 04        pbodla     115.15     Added code to get the group oipl id
     05 Feb 04        ikasire    115.14/15  fixed slaves issue
     05 Feb 04        ikasire    115.16     Added new procedure and changes for the
                                            online call
     06 Feb 04        pbodla     115.17     Added code to populate WS_RT_START_DAT
     25 Feb 04        pbodla     115.18     Added params p_no_person_rates,
                                                    p_no_person_groups for the
                                            populate_cwb_rates procedure.
                                            These parameters will be used later
                                            for reducing the data inserts.
     27 Feb 04        ikasire    115.19     Added cursor to generate and pass
                                            person selection rule in different
                                            business groups
     03 Mar 04        ikasire    115.20     Bug 3482033 fixes
     22 Mar 04        pbodla     115.21     Bug 3517726 : Do not consider any
                                            data which is not deleted by backout.
     06 Apr 04        pbodla     115.22     Added the code to submit the reports
     28 Apr 04        pbodla     115.23     Added the code to copy budget
                                            columns from cwb_person_rates to
                                            cwb_person_groups.
     06 May 04        pbodla     115.24     Added procedure del_all_cwb_pils
                                            to delete all data if person is
                                            ineligible and track ineligible
                                            flag is N.
     26 May 04        pbodla     115.25     Added cursor get_per_info
                                            to be used for online calls.
     10 Jun 04        maagrawa   115.26     Pass null as effective_date to
                                            ben_cwb_pl_dsgn_pkg and
                                            ben_cwb_person_info_pkg
     12 Jul 04        pbodla     115.27     Bug 3748539: This situation indicates
                                            it is a recursive supervisory heirarchy.
     13 Jul 04        pbodla     115.28     Bug 3748539: Added MGRPERSONID token.
     20 Jul 04        pbodla     115.29     Added logic for single person run.
                                            p_single_per_clone_all_data
     21 Jul 04        pbodla     115.30     Added p_use_eff_dt_flag to
                                            global_online_process_w and other
                                            procedures, if front end
                                            takes the decision to take full control
                                            to clone data then this flag is passed
                                            as Y.
     08 oct 04        pbodla     115.31     Added extra parameters to
                                            global_online_process_w, to handle
                                            backout.
     11 oct 04        pbodla     115.32     passed correct date parameters to
                                            global_online_process_w
     01 Nov 04        pbodla     115.33     Added procedure
                                            sum_oipl_rates_and_upd_pl_rate
                                            Bug : 3968065
     03 Nov 04        pbodla     115.34     modified procedure to handle nulls
                                            sum_oipl_rates_and_upd_pl_rate
     17 Nov 04        pbodla     115.35     Bug 3510081 : data model changes
                                            and code changes for auto allocation
                                            of budgets.
     01 Dec 04        pbodla     115.36     ACCESS_CD in ben_cwb_person_tasks
                                            is populated with UP
     06-Dec-04       bmanyam     115.37     Bug: 3979082. Use AME Hierarchy to
                                            fetch manager hierarchy.
     06-Dec-04       bmanyam     115.38     Bug: 3979082. Use RULE to
                                            fetch manager hierarchy.
     10-Dec-04        pbodla     115.39     Modified p_single_per_clone_all_data
                                            commented the code which nullifies l_ws_mgr_id
                                            if mgr per_in_ler not found.
     14-Dec-04        pbodla     115.40     bug 4040013 - Modified cursor c_oipl_exists
                                            to check ws rate at plan level also.
     23-Dec-04        pbodla     115.41     bug 4052530 - initialisation of
                                            g_group_per_in_ler is moved
                                            within  p_single_per_clone_all proc.
     27-Dec-04        pbodla     115.42     Added initialization of globals to
                                            global_online_process_w procedure
     06-jan-05        pbodla     115.43     Pop cd is populated only for
                                            auto allocation of budgets and at
                                            plan level only.
     24-jan-05        nhunur     115.44     4128034: Pass correct assignment id to the RL
     21-Feb-05        pbodla     115.45     bug 4198404 - Added record structure
                                            g_error_log_rec_type to log proper
                                            error messages.

                                            Commit data after refresh_pl_dsgn
                                            only if the call is from conc manager

     17-May-05        pbodla     115.46     Added performance hint for cursor
                                            c_person_rates

     27-May-05        pbodla     115.47     Bug 4399281 : Assume recursive heirarchy
                          : A reports to B, B reports to
                          C, C Reports to B. This scenario is not caught by error
                          BEN_94020_RECURSIVE_EMP_HEIRAR if  person A is picked up
                          in heirarchy build first.
                          By adding check l_level > 75 infinite loop is broken and
                          when person B is picked up to build heirarchy above error
                          is raised.
    14-Jun-05         kmahendr   115.48     Bug#4258200 - l_copy_person_bdgt_count initialised
                                            to 0
    20-Jun-05         pbodla     115.49     Bug#4258200 - Data from copy_ attributes are
                                            not copied over for cross business group data.
    17-aug-05         pbodla     115.50     Bug#4547916 - Even if manager is processed still
                                            do not re create the group pil data.
                                            Also allow creating heirarchy data based on processed pils.
    28-Sep-05         tjesumic   115.51     audit_log_flag support 4 values
                                            Y           Log Yes   Report YES
                                            N           Log NO    Report YES
                                            NN          Log NO    Report NO
                                            YN          Log Yes   Report No
    17-aug-05         pbodla     115.52     Bug#4720746 - typing error corrected.
    28-Nov-05         maagrawa   115.53     4766589. Default person task's access
                                            to task definition's hidden_cd.
    29-dec-05         pbodla     115.54     PERF 4587770 : Added performance related
                                            changes. Some of the potential code chages are
                                            in comments as, we are waiting for GSI to
                                            validate the fixes. Once GSI gets back
                                            with results, this code can be merged.
    03-Jan-06         nhunur     115.55    cwb - changes for person type param.
    29-dec-05         pbodla     115.56     Enhancement to handle the recursive
                                            heirarchy properly, so that string containing
                                            personid's will be printed.
                                            Process will not error out, it will
                                            continue building the heirarchy.
                                            Users have to use admin page and reassign
                                            one employee who is in recursive relationship.
    23-jan-06         pbodla     115.57     Enhancement to handle the recursive
                                            heirarchy in online run. Added error
                                            message - BEN_94537_REC_REPORTING
    08-Feb-06         abparekh   115.58     Bug 4875181 - Added p_run_rollup_only to process
                                 115.59                   only Rollup Processes
    07-Feb-06         mmudigon   115.59     CWB Multi currency support. Added
                                            procs() exec_element_det_rl and
                                            get_abr_ele_inp
                                            determine_curr_code
    17-Feb-06         pbodla/stee115.59     CWB Multi currency support. Added
                                            determine_curr_code
    21-Feb-06         pbodla     115.60     currency col populated in ben_cwb_person_rates.
    28-Feb-06         pbodla     115.62     Fix currency_det_cd for salary basis and standard
                                            rates.
    04-Mar-06         maagrawa   115.63     Include call for exchange rate creation.
    24-Mar-06         maagrawa   115.64     GSCC nocopy error.
    27-Mar-06         stee       115.65     Populate currency when cloning
                                            person data - Bug 5104388.
    07-Apr-06         swjain     115.67     Bug 5141153: Updated procedure exec_element_det_rl
    21-Apr-06         ikasired   115.68     5148387 handling for benefit assignment
    26-Apr-06         maagrawa   115.70     4636102:Error getting killed in
                                            online mode also.
    12-May-06         bmanyam    115.71     Text for BEN_94537_REC_REPORTING changed by anadi.
                                            So, the corresponding log-file buff is also
                                            changed.
    12-May-06         bmanyam    115.72     -- do --
    22-May-06         pbodla     115.73     Bug 5232223 - Added code to handle the trk inelig flag
                                            If trk inelig flag is set to N at group plan level
                                            then do not create cwb per in ler and all associated data.

    22-Jun-06         rbingi     115.74     Bug 5232223 - Calling del_all_cwb_pils when elpros attacthed to
                                             local plan.
    26-Jun-06         rbingi     115.75     Contd.5232223.
    18-Oct-06         maagrawa   115.76     4587770.Tuned c_no_0_hrchy
    01-dec-06         ssarkar    115.77     5124534 :  modified popu_missing_person_pil
    13-dec-06         ssarkar    115.78     5124534/5702794 : populate cwb_group_persons with pl_id/oipl_id
    20-Feb-07         maagrawa   115.79     Further tuned c_no_0_hrchy. Use
                                            ben_cwb_person_info instead of
                                            ben_per_in_ler.
    04-Jun-07         maagrawa   115.80     Further tuned c_no_0_hrchy. Check only
                                            level 1 hierarchy.
    24-Sep-08         sgnanama   115.81     7393142: process for terminated employee
    19-Feb-09  sgnanama  120.31.12010000.3   ER: added logic to copy integrator
*/
--------------------------------------------------------------------------------
--
g_package             varchar2(80) := 'ben_manage_cwb_life_events';
--
g_debug boolean := hr_utility.debug_enabled;
g_rebuild_pl_id            number := null;
g_rebuild_lf_evt_ocrd_dt   date := null;
g_rebuild_business_group_id   number := null;
g_opt_exists boolean;
-- RECUR
TYPE g_hrchy_rec_type Is RECORD(
   hrchy_cat_string     varchar2(80)
   );
--
g_hrchy_rec  g_hrchy_rec_type ;
TYPE hrchy_table is table of g_hrchy_rec_type index by binary_integer ;
g_hrchy_tbl                    hrchy_table ;
-- END RECUR
--
-- Globals needed to copy copy_<budget> columns from rates table to group
-- table.
--
type g_cache_copy_person_bdgt_rt is record
  (person_id                   ben_cwb_person_rates.person_id%type,
   group_pl_id                 ben_pl_f.pl_id%type,
   group_oipl_id               ben_cwb_person_rates.group_oipl_id%type,
   group_lf_evt_ocrd_dt        date,
   copy_ws_bdgt_val            ben_cwb_person_rates.copy_ws_bdgt_val%type,
   copy_dist_bdgt_val          ben_cwb_person_rates.copy_dist_bdgt_val%type,
   copy_rsrv_val               ben_cwb_person_rates.copy_rsrv_val%type,
   copy_dist_bdgt_mn_val       ben_cwb_person_rates.copy_dist_bdgt_mn_val%type,
   copy_dist_bdgt_mx_val       ben_cwb_person_rates.copy_dist_bdgt_mx_val%type,
   copy_dist_bdgt_incr_val     ben_cwb_person_rates.copy_dist_bdgt_incr_val%type,
   copy_ws_bdgt_mn_val         ben_cwb_person_rates.copy_ws_bdgt_mn_val%type,
   copy_ws_bdgt_mx_val         ben_cwb_person_rates.copy_ws_bdgt_mx_val%type,
   copy_ws_bdgt_incr_val       ben_cwb_person_rates.copy_ws_bdgt_incr_val%type,
   copy_rsrv_mn_val            ben_cwb_person_rates.copy_rsrv_mn_val%type,
   copy_rsrv_mx_val            ben_cwb_person_rates.copy_rsrv_mx_val%type,
   copy_rsrv_incr_val          ben_cwb_person_rates.copy_rsrv_incr_val%type,
   copy_dist_bdgt_iss_val      ben_cwb_person_rates.copy_dist_bdgt_iss_val%type,
   copy_ws_bdgt_iss_val        ben_cwb_person_rates.copy_ws_bdgt_iss_val%type,
   copy_dist_bdgt_iss_date     ben_cwb_person_rates.copy_dist_bdgt_iss_date%type,
   copy_ws_bdgt_iss_date       ben_cwb_person_rates.copy_ws_bdgt_iss_date%type
  );
type g_cache_copy_person_bdgt_typ is table of g_cache_copy_person_bdgt_rt index
  by binary_integer;
g_cache_copy_person_bdgt_tbl  g_cache_copy_person_bdgt_typ;
g_cache_copy_person_bdgt_tbl1 g_cache_copy_person_bdgt_typ;

--
procedure check_slaves_status
  (p_num_cwb_processes in     number
  ,p_cwb_processes_rec in     ben_manage_cwb_life_events.g_cwb_processes_table
--  ,p_master            in     varchar2
  ,p_slave_errored    out     nocopy boolean
  )
is
  --
  l_package        varchar2(80) := g_package||'.check_slaves_status';
  --
  l_no_slaves      boolean := true;
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
  if g_debug then
     hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  if p_num_cwb_processes <> 0 -- and p_master = 'Y'
  then
    --
    while l_no_slaves loop
      --
      l_no_slaves := false;
      --
      for elenum in 1..p_num_cwb_processes
      loop
        --
        open c_slaves
          (p_cwb_processes_rec(elenum)
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
        l_poll_loops := 100000;
        --
        for i in 1..l_poll_loops
        loop
          --
          null;
          --
        end loop;
        --
      end loop;
      --
    end loop;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
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
  /*
  cursor c_master is
    select 'Y'
    from   ben_benefit_actions bft
    where  bft.benefit_action_id = p_benefit_action_id
    and    bft.request_id = fnd_global.conc_request_id;
  */
  --
begin
  --
  if g_debug then
     hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  /*
  -- Work out if process is master
  --
  open c_master;
    --
    fetch c_master into l_master;
    --
  close c_master;
  --
  */
  -- Check slave status
  --
  check_slaves_status
    (p_num_cwb_processes => ben_manage_cwb_life_events.g_num_cwb_processes
    ,p_cwb_processes_rec => ben_manage_cwb_life_events.g_cwb_processes_rec
  --  ,p_master            => l_master
    --
    ,p_slave_errored => l_slave_errored
    );
  --
  if g_debug then
     hr_utility.set_location (l_package||' OUT NOCOPY slave loop ',20);
  end if;
  --
  /*
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
  */
  --
  commit;
  --
  p_slave_errored := l_slave_errored;
  --
  hr_utility.set_location ('Leaving '||l_package,50);
  --
end check_all_slaves_finished;
--
-- Evaluates element determination rule
--
procedure exec_element_det_rl
(p_element_det_rl           number    default null,
 p_acty_base_rt_id          number    default null,
 p_effective_date           date,
 p_assignment_id            number    default null,
 p_organization_id          number    default null,
 p_business_group_id        number    default null,
 p_pl_id                    number    default null,
 p_ler_id                   number    default null,
 p_element_type_id      out nocopy number,
 p_input_value_id       out nocopy number,
 p_currency_cd          out nocopy varchar2) is

l_proc              varchar2(80) := g_package||'.exec_element_det_rl' ;
l_element_det_rl    number;
l_outputs           ff_exec.outputs_t;

cursor c_abr is
select element_det_rl
  from ben_acty_base_rt_f
 where acty_base_rt_id = p_acty_base_rt_id
   and p_effective_date between effective_start_date
   and effective_end_date;

begin
  --
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  if p_element_det_rl is null then
     --
     if p_acty_base_rt_id is null then
        --
        hr_utility.set_location('Incorrect args '||l_proc,15);
        --
        hr_api.mandatory_arg_error
       (p_api_name       => l_proc,
        p_argument       => 'p_element_det_rl,p_acty_base_rt_id',
        p_argument_value => p_element_det_rl);
        --
     else
        --
        open c_abr;
        fetch c_abr into l_element_det_rl;
	if c_abr%NotFound then     /* Bug 5141153 : Added if condition */
          close c_abr;
          --
          if g_debug then
             hr_utility.set_location('No RL found '||l_proc,15);
             hr_utility.set_location('Leaving: '||l_proc,15);
          end if;
          --
          return;
	  --
	end if;                     /* End Bug 5141153 */
	close c_abr;
     --
     end if;
  else
      l_element_det_rl := p_element_det_rl;
  end if;

  if g_debug then
    hr_utility.set_location('element_det_rl: '||l_element_det_rl,25);
  end if;

  l_outputs := benutils.formula
              (p_formula_id        => l_element_det_rl,
               p_effective_date    => p_effective_date,
               p_assignment_id     => p_assignment_id,
               p_acty_base_rt_id   => p_acty_base_rt_id,
               p_organization_id   => p_organization_id,
               p_business_group_id => p_business_group_id,
               p_pl_id             => p_pl_id,
               p_ler_id            => p_ler_id);

  for l_count in l_outputs.first..l_outputs.last
  loop
      --
      if l_outputs(l_count).name = 'ELEMENT_TYPE_ID' then
         p_element_type_id := to_number(l_outputs(l_count).value);
      elsif l_outputs(l_count).name = 'INPUT_VALUE_ID' then
         p_input_value_id := to_number(l_outputs(l_count).value);
      elsif l_outputs(l_count).name = 'CURRENCY_CODE' then
         p_currency_cd := l_outputs(l_count).value;
      else
         -- error
         null;
      end if;
      --
  end loop;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
exception
  when others then
     if g_debug then
        hr_utility.set_location('In exception block '||l_proc,10);
     end if;
     --
     p_element_type_id := null;
     p_input_value_id := null;
     p_currency_cd := null;
     raise;

end exec_element_det_rl;
--
-- call this proc to determine which ele and inp value to send to benelmen
--
procedure get_abr_ele_inp
(p_person_id                 number,
 p_acty_base_rt_id           number,
 p_effective_date            date,
 p_element_type_id_in        number default null,
 p_input_value_id_in         number default null,
 p_pl_id                     number default null,
 p_element_type_id_out  out  nocopy number,
 p_input_value_id_out   out  nocopy number ) is

l_proc              varchar2(80) := g_package||'.get_abr_ele_inp' ;
l_payroll_id        number;
l_organization_id   number;
l_assignment_id     number;
l_element_type_id   number;
l_input_value_id    number;
l_dummy_varchar2    varchar2(255);

begin
  --
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  ben_element_entry.get_abr_assignment
  (p_person_id       => p_person_id
  ,p_effective_date  => p_effective_date
  ,p_acty_base_rt_id => p_acty_base_rt_id
  ,p_organization_id => l_organization_id
  ,p_payroll_id      => l_dummy_varchar2
  ,p_assignment_id   => l_assignment_id);
  --
  exec_element_det_rl
  (p_element_det_rl           => null,
   p_acty_base_rt_id          => p_acty_base_rt_id,
   p_effective_date           => p_effective_date,
   p_assignment_id            => l_assignment_id,
   p_organization_id          => l_organization_id,
   p_pl_id                    => p_pl_id,
   p_element_type_id          => l_element_type_id,
   p_input_value_id           => l_input_value_id,
   p_currency_cd              => l_dummy_varchar2);
  --
  if l_element_type_id is not null and
     l_input_value_id is not null then
     --
     p_element_type_id_out := l_element_type_id;
     p_input_value_id_out  := l_input_value_id;
     --
  else
     --
     p_element_type_id_out := p_element_type_id_in;
     p_input_value_id_out  := p_input_value_id_in;
     --
  end if;
  --
  if g_debug then
    hr_utility.set_location('elt: '||p_element_type_id_out,10);
    hr_utility.set_location('inp: '||p_input_value_id_out,10);
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
exception
  when others then
     if g_debug then
        hr_utility.set_location('In exception block '||l_proc,10);
     end if;
     --
     p_element_type_id_out := null;
     p_input_value_id_out := null;
     raise;

end get_abr_ele_inp;
--
-- Determine curency code
--
procedure determine_curr_code
(p_element_det_rl           number    default null,
 p_acty_base_rt_id          number    default null,
 p_currency_det_cd          varchar2  default null,
 p_base_element_type_id     number    default null,
 p_effective_date           date,
 p_assignment_id            number    default null,
 p_organization_id          number    default null,
 p_business_group_id        number    default null,
 p_pl_id                    number    default null,
 p_opt_id                   number    default null,
 p_ler_id                   number    default null,
 p_element_type_id      out nocopy number,
 p_input_value_id       out nocopy number,
 p_currency_cd          out nocopy varchar2) is

  l_proc                 varchar2(80) := g_package||'.determine_curr_code' ;

  l_element_type_id      number;
  l_input_value_id       number;
  l_currency_cd          varchar2(200);
  --
  cursor c_get_et_currency_cd (l_element_type_id in number)
  is
    select input_currency_code
    from pay_element_types_f
    where element_type_id = l_element_type_id
    and p_effective_date between effective_start_date
    and effective_end_date;
  --
  cursor c_get_sb_currency_cd
  is
    select et.input_currency_code
    from pay_element_types_f et
        ,per_pay_bases pb
        ,pay_input_values_f iv
        ,per_all_assignments_f asg
    where asg.pay_basis_id = pb.pay_basis_id
    and   pb.input_value_id = iv.input_value_id
    and   iv.element_type_id = et.element_type_id
    and   asg.assignment_id = p_assignment_id
    and   p_effective_date between
          asg.effective_start_date and asg.effective_end_date
    and   p_effective_date between
          iv.effective_start_date and iv.effective_end_date
    and   p_effective_date between
          et.effective_start_date and et.effective_end_date;
    --
  cursor c_get_pl_currency_cd
  is
    select pln.nip_pl_uom
    from ben_pl_f pln
    where pln.pl_id = p_pl_id
    and   p_effective_date between
          pln.effective_start_date and pln.effective_end_date;
begin
  --
  if g_debug then
    hr_utility.set_location('Entering: '||l_proc,10);
    hr_utility.set_location('p_currency_det_cd: '||p_currency_det_cd,10);
  end if;
  --
  if nvl(p_currency_det_cd, 'AUTO') in ('STDRTEL', 'AUTO') then
     --
     if p_element_det_rl is not null then
        --
        exec_element_det_rl
         (p_element_det_rl           => p_element_det_rl,
          p_acty_base_rt_id          => p_acty_base_rt_id,
          p_effective_date           => p_effective_date,
          p_assignment_id            => p_assignment_id,
          p_organization_id          => p_organization_id,
          p_business_group_id        => p_business_group_id,
          p_pl_id                    => p_pl_id,
          -- p_opt_id                => p_opt_id,
          p_ler_id                   => p_ler_id,
          p_element_type_id          => l_element_type_id,
          p_input_value_id           => l_input_value_id,
          p_currency_cd              => l_currency_cd
          );
        --
     end if;
     --
     if l_currency_cd is null and l_element_type_id is not null then
        --
        -- get it from the l_element_type_id
        --
        open c_get_et_currency_cd(l_element_type_id);
        fetch c_get_et_currency_cd into l_currency_cd;
        close c_get_et_currency_cd;
        --
     end if;
     --
     if l_currency_cd is null and p_base_element_type_id is not null then
        --
        -- get it from the p_base_element_type_id
        --
        open c_get_et_currency_cd(p_base_element_type_id);
        fetch c_get_et_currency_cd into l_currency_cd;
        close c_get_et_currency_cd;
        --
     end if;
     --
     if l_currency_cd is null and nvl(p_currency_det_cd, 'AUTO') = 'AUTO' then
        --
        -- get it from salary basis element.
        --
        open c_get_sb_currency_cd;
        fetch c_get_sb_currency_cd into l_currency_cd;
        close c_get_sb_currency_cd;
        --
     end if;
     --
  end if;
  --
  if l_currency_cd is null and p_currency_det_cd = 'SALBEL' then
     --
     -- Get it from salary basis element.
     --
     open c_get_sb_currency_cd;
     fetch c_get_sb_currency_cd into l_currency_cd;
     close c_get_sb_currency_cd;
     --
  end if;
  --
  -- Either currency_cd is PLAN or can't be determined earlier.
  --
  if l_currency_cd is null then
     --
     -- Get it from plan level.
     --
     open c_get_pl_currency_cd;
     fetch c_get_pl_currency_cd into l_currency_cd;
     close c_get_pl_currency_cd;
     --
  end if;
  --
  p_currency_cd := l_currency_cd;
  p_input_value_id := l_input_value_id;
  p_element_type_id := l_element_type_id;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
end determine_curr_code;

--
-- RECUR
--
procedure p_add_to_recur_hrchy(p_hrchy_string varchar2, p_hrchy_search varchar2) is
l_proc     varchar2(80) ;
l_found                        boolean := false;
l_counter number;
begin
  --
  if g_debug then
    l_proc := g_package||  '.p_add_to_recur_hrchy';
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  l_counter := nvl(g_hrchy_tbl.LAST, 0);
  if l_counter > 0  and p_hrchy_search is not null then
     --
     for i in 1..l_counter loop
           if instr(g_hrchy_tbl(i).hrchy_cat_string,  p_hrchy_search) > 0
           then
              l_found := true;
              exit;
           end if;
     end loop;
     --
  end if;
  --
  if not l_found then
        --
        g_hrchy_tbl(l_counter+1).hrchy_cat_string := p_hrchy_string;
        --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
end p_add_to_recur_hrchy;
--
-- CWB Procedure for population of the CWB Hierarchy table
--
procedure popu_group_pil_heir(p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number) is
  --
  l_proc         VARCHAR2(80);
  l_level        number             := 1 ;
  l_emp_pil           number ;
  l_mgr_pil           number ;
  l_mgr_person_id     number ;
  l_mgr_person_id_out number ;
  l_business_group_id number ;
  l_pl_id             number;
  l_person_id         number;
  l_lf_evt_ocrd_dt    date;
  l_ler_id            number;
  l_rec             benutils.g_batch_param_rec;
  lv_pl_id          number;
  lv_business_group_id number;
  lv_ler_id            number;
  lv_lf_evt_ocrd_dt date;
  l_recursive_found  boolean := false;
  l_heirarchy_string varchar2(2000);
  l_mgr_per_id_pos   number;
  --
  -- Bug 2288042 : Create 0 level heirarchy data if manager is
  -- is processed first and employee is processed later.
  --
  cursor c_no_0_hrchy(p_pl_id number,
                      p_lf_evt_ocrd_dt date) is
  select unique hrh_0.mgr_per_in_ler_id
  from ben_cwb_group_hrchy hrh_0,
     ben_cwb_person_info mgr_info_0
  where mgr_info_0.group_per_in_ler_id = hrh_0.emp_per_in_ler_id
   and mgr_info_0.group_pl_id    = p_pl_id
   and mgr_info_0.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
  and hrh_0.lvl_num = 1
  and not exists
  ( select 'Y'
    from ben_cwb_group_hrchy hrh
    where hrh.mgr_per_in_ler_id = hrh_0.mgr_per_in_ler_id
      and hrh.emp_per_in_ler_id = hrh_0.mgr_per_in_ler_id
      and hrh.lvl_num = 0
  );
  --
  -- Cursor to select the pil records for emp
  -- These are the records created initially with mgr_per_in_ler_id and
  -- lvl_num as '-1'
  --
  cursor c_pil(cv_pl_id number, cv_lf_evt_ocrd_dt date) is
    select
      cwb.emp_per_in_ler_id,
      pil.ws_mgr_id,
      pil.person_id
    from
      ben_cwb_group_hrchy  cwb,
      ben_per_in_ler pil
    where
          cwb.mgr_per_in_ler_id = -1
      and pil.per_in_ler_id = cwb.emp_per_in_ler_id
      and pil.per_in_ler_stat_cd = 'STRTD'
      and pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
      and pil.group_pl_id = cv_pl_id
      and cwb.lvl_num = -1;
  --
  cursor c_per_name(cv_person_id number, cv_lf_evt_ocrd_dt date) is
    select full_name
    from per_all_people_f per
    where person_id = cv_person_id
      and cv_lf_evt_ocrd_dt between effective_start_date
                                and effective_end_date;
  --
  -- This private procedure determines the Manager pil
  -- This will get the manager pel record for a given emp - cascading
  --
  procedure mgr( p_person_id number,
                p_business_group_id number,
                p_pl_id number,
                p_lf_evt_ocrd_dt date,
                p_ler_id number,
                p_ws_mgr_id out nocopy number,
                p_per_in_ler_id out nocopy number ) is
    --
    cursor c_mgr(p_person_id number,
                 p_pl_id number,
                 p_lf_evt_ocrd_dt date,
                 p_ler_id number,
                 p_business_group_id number) is
      select pil.ws_mgr_id,
             pil.per_in_ler_id
      from ben_per_in_ler pil
      where pil.group_pl_id         = p_pl_id
      and   pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
      and   pil.ler_id        = p_ler_id
      and   pil.person_id     = p_person_id
      and   pil.business_group_id = p_business_group_id
      and   pil.per_in_ler_stat_cd in ('STRTD', 'PROCD'); -- gsi also consider processed pils
    --
  l_ws_mgr_id number := null ;
  l_per_in_ler_id number := null ;
  begin
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location('MGR p_person_id '||p_person_id,22);
      hr_utility.set_location('MGR p_business_group_id '||p_business_group_id,23);
    end if;
    --
    open c_mgr (p_person_id,p_pl_id,p_lf_evt_ocrd_dt,p_ler_id,p_business_group_id);
    fetch c_mgr into l_ws_mgr_id,l_per_in_ler_id ;
    close c_mgr ;
    --
    if g_debug then
      hr_utility.set_location('MGR OUT l_per_in_ler_id '||l_per_in_ler_id,30);
      hr_utility.set_location('MGR OUT l_ws_mgr_id '||l_ws_mgr_id,40);
    end if;
    --
    p_per_in_ler_id := l_per_in_ler_id ;
    p_ws_mgr_id := l_ws_mgr_id ;
  end;
  --
  -- This procedure inserts records into hierarchy table
  --
  procedure insert_mgr_hrchy ( p_emp_per_in_ler_id number,
                               p_mgr_per_in_ler_id number,
                               p_lvl_num number ) is
  begin
    --
    if g_debug then
      hr_utility.set_location('insert_mgr_hrchy p_emp_per_in_ler_id '
                                     ||p_emp_per_in_ler_id,10);
      hr_utility.set_location('insert_mgr_hrchy p_mgr_per_in_ler_id '
                                     ||p_mgr_per_in_ler_id || ' lvl = '
                                     || p_lvl_num, 20);
    end if;
    insert into ben_cwb_group_hrchy (
          emp_per_in_ler_id,
          mgr_per_in_ler_id,
          lvl_num  )
    values (
          p_emp_per_in_ler_id,
          p_mgr_per_in_ler_id,
          p_lvl_num );
    --
  exception when others then
    --
    null; -- For Bug 2712602
    --
  end insert_mgr_hrchy;
  --
  procedure update_init_pil(cv_pl_id number, cv_lf_evt_ocrd_dt date)  is
    --
    -- CWB bug : 2712602
    --
    cursor c_cwh is
     select rowid
     from ben_cwb_group_hrchy cwh
           where cwh.lvl_num = -1 and
             cwh.mgr_per_in_ler_id = -1
         --
         -- Bug 2541072 : Do not consider all per in ler's.
         --
        and exists
         (select null
          from ben_per_in_ler pil
          where pil.per_in_ler_id = cwh.emp_per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
          and pil.group_pl_id = cv_pl_id
         ) ;
    --
    begin
      --
      -- Also delete the rows for employees who do not have
      -- subordinates and with level -1 .
      -- And also the last subordinate is now reporting to another manager
      -- we need to delete the pil,0,0 row of the employee.
      --
      delete
      from ben_cwb_group_hrchy cwh
      where (( cwh.lvl_num = -1
              and cwh.mgr_per_in_ler_id = -1) OR
             ( cwh.lvl_num = 0 and
              cwh.mgr_per_in_ler_id = cwh.emp_per_in_ler_id ) )
        and not exists
        (select null
         from ben_cwb_group_hrchy cwh1
         where cwh1.mgr_per_in_ler_id = cwh.emp_per_in_ler_id
         and cwh1.lvl_num <> 0
        )
         --
         -- Bug 2541072 : Do not consider all per in ler's.
         --
        and exists
         (select null
          from ben_per_in_ler pil
          where pil.per_in_ler_id = cwh.emp_per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
          and pil.group_pl_id = cv_pl_id
         ) ;
      /*
      --
      -- For performance this query can be used instead of above
      -- delete, but waiting for GSI to validate it scales better.
      -- For bug 4587770
      --
      select cwh.rowid
      from ben_per_in_ler pil, ben_cwb_group_hrchy cwh
      where pil.per_in_ler_id = cwh.emp_per_in_ler_id
          and   pil.per_in_ler_stat_cd = 'STRTD'
          and pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
          and pil.group_pl_id = cv_pl_id
          and (( cwh.lvl_num = -1
              and cwh.mgr_per_in_ler_id = -1) OR
             ( cwh.lvl_num = 0 and
              cwh.mgr_per_in_ler_id = cwh.emp_per_in_ler_id ) )
        and not exists
        (select null
         from ben_cwb_group_hrchy cwh1
         where cwh1.mgr_per_in_ler_id = cwh.emp_per_in_ler_id
         and cwh1.lvl_num <> 0
        );
      */
      --
      -- Bug 2712602
      --
      for l_cwh in c_cwh loop
        --
        begin
          --
          update ben_cwb_group_hrchy cwh
          set cwh.mgr_per_in_ler_id = cwh.emp_per_in_ler_id,
              cwh.lvl_num = 0
          where cwh.lvl_num = -1
            and cwh.mgr_per_in_ler_id = -1
            and cwh.rowid = l_cwh.rowid;
        exception
         when others then
           delete from ben_cwb_group_hrchy where rowid = l_cwh.rowid;null;
        end;
        --
      end loop;
      --
    exception when others then
      raise ;
    end ;
  --
begin
  --
  if g_debug then
    l_proc := g_package||  '.popu_group_pil_heir';
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  lv_pl_id             := p_group_pl_id;
  lv_business_group_id := p_group_business_group_id;
  lv_lf_evt_ocrd_dt    := p_group_lf_evt_ocrd_dt;
  lv_ler_id            := p_group_ler_id;
  --
  if g_debug then
    hr_utility.set_location(l_proc || ' lv_pl_id = ' || lv_pl_id, 9876);
    hr_utility.set_location(l_proc || ' lv_lf_evt_ocrd_dt = '
                                   || lv_lf_evt_ocrd_dt, 9876);
    hr_utility.set_location(l_proc || ' lv_business_group_id = '
                                   || lv_business_group_id, 9876);
    hr_utility.set_location(l_proc || ' lv_ler_id = ' || lv_ler_id, 9876);
  end if;
  open c_pil(lv_pl_id, lv_lf_evt_ocrd_dt);
  fetch c_pil into l_emp_pil,l_mgr_person_id,l_person_id ;
  --
  -- RECUR
  --
  g_hrchy_tbl.delete;
  l_recursive_found := false;
  l_heirarchy_string := '~'||to_char(l_person_id)||'~'||to_char(l_mgr_person_id)||'~';
  --
  -- RECUR END
  --
  --
  if g_debug then
    hr_utility.set_location(' l_emp_pil '||l_emp_pil,99);
    hr_utility.set_location(' l_mgr_person_id '||l_mgr_person_id,99);
  end if;
  --
  <<pil>>
  loop
    --
    exit pil when c_pil%notfound ;
    l_level := 1 ;
      --
      <<mgr_loop>>
      loop
        --
        if g_debug then
          hr_utility.set_location('Before mgr l_mgr_person_id '
                                 ||l_mgr_person_id,10);
        end if;
        --
        mgr(l_mgr_person_id,
            lv_business_group_id,
            lv_pl_id,
            lv_lf_evt_ocrd_dt,
            lv_ler_id,
            l_mgr_person_id_out,
            l_mgr_pil);
        --
        if g_debug then
          hr_utility.set_location('After Mgr l_mgr_person_id '
                                   ||l_mgr_person_id,20);
          hr_utility.set_location('After Mgr l_mgr_person_id_out '
                                   ||l_mgr_person_id_out,20);
          hr_utility.set_location('After Mgr l_mgr_pil '|| l_mgr_pil,30);
        end if;
        --
        --
        -- RECUR
        --
        if l_mgr_person_id_out is not null then
           l_mgr_per_id_pos   := instr (l_heirarchy_string, '~'|| to_char(l_mgr_person_id_out) || '~');
           if l_mgr_per_id_pos > 0 then
              --
              l_recursive_found := true;
              -- hr_utility.set_location('level = ' || l_level, 99);
              -- hr_utility.set_location('l_heirarchy_string = ' || l_heirarchy_string, 99);
              -- Now go ahead and store in a pl/sql table so that we print each occurance only once
              p_add_to_recur_hrchy(l_heirarchy_string|| to_char(l_mgr_person_id_out) || '~',
                            '~'||to_char(l_mgr_person_id) || '~' || to_char(l_mgr_person_id_out) || '~');
              --
           end if;
           l_heirarchy_string := l_heirarchy_string || to_char(l_mgr_person_id_out) || '~';
        end if;
        --
        -- RECUR END
        --
        if l_mgr_pil is not null then
          --
          if l_emp_pil = l_mgr_pil and l_level > 0 then
             --
             -- Bug 3748539
             -- This situation indicates it is a recursive supervisory heirarchy.
             -- Raise error and rollback the heirarchy rebuild.
             --
             hr_utility.set_location('BEN_94020_RECURSIVE_EMP_HEIRAR', 999);
             /* RECUR
             fnd_message.set_name('BEN', 'BEN_94020_RECURSIVE_EMP_HEIRAR');
             fnd_message.set_token('PERSONID',to_char(l_person_id));
             fnd_message.set_token('MGRPERSONID',to_char(l_mgr_person_id));
             fnd_message.raise_error;
             */ -- RECUR
             --
          end if;
          --
          insert_mgr_hrchy(l_emp_pil,l_mgr_pil,l_level);
          --
        end if;
        --
        -- Bug 4399281 : Assume recursive heirarchy : A reports to B, B reports to
        --                C, C Reports to B. This scenario is not caught by error
        --                BEN_94020_RECURSIVE_EMP_HEIRAR if  person A is picked up in
        --                heirarchy build first.
        --                By adding check l_level > 75 infinite loop is broken and
        --                when person B is picked up to build heirarchy above error
        --                is raised.
        --
        exit mgr_loop when (l_mgr_person_id = l_mgr_person_id_out
                            OR l_mgr_person_id_out is null or l_recursive_found or
                            l_level > 75) ;
        --call to insert routne
        if g_debug then
          hr_utility.set_location('Emp EPE '||l_emp_pil , 20);
          hr_utility.set_location('Mgr EPE '||l_mgr_pil , 30);
          hr_utility.set_location('Level   '||l_level   , 40);
        end if;
        --
        --
        --after call to insert routine
        --
        l_mgr_person_id := l_mgr_person_id_out ;
        l_level         := l_level + 1 ;
        l_mgr_pil       := null ;
        --
      end loop mgr_loop;
    --
    fetch c_pil into l_emp_pil,l_mgr_person_id, l_person_id ;
    l_recursive_found := false;
    l_heirarchy_string := '~'||to_char(l_person_id)||'~'||to_char(l_mgr_person_id)||'~';
    --
    if g_debug then
      hr_utility.set_location(' End of mgr_loop ',99);
    end if;
  end loop pil ;
  --
  close c_pil ;
  --
  --call to delete the intial pil records
  if g_debug then
    hr_utility.set_location('Before call to delete_init_pil',10);
  end if;
  update_init_pil(lv_pl_id, lv_lf_evt_ocrd_dt) ;
  if g_debug then
    hr_utility.set_location('After  call to delete_init_pil',10);
  end if;

  -- Bug 4587770
  -- Backout already deletes the data, so no need to call again here,
  -- but keeping it for now and should be called only called from the
  -- concurrent programs.
  --
  if fnd_global.conc_request_id not in ( 0,-1) then
     --
     -- CWB 2712602 : Delete all the hrchy data linked to backed out per in ler.
     --
     delete from ben_cwb_group_hrchy
     where emp_per_in_ler_id in (
        select pil.per_in_ler_id
        from ben_per_in_ler pil
        where pil.group_pl_id = lv_pl_id
          and pil.lf_evt_ocrd_dt = lv_lf_evt_ocrd_dt
          and pil.per_in_ler_stat_cd = 'BCKDT');
     --
     delete from ben_cwb_group_hrchy
     where mgr_per_in_ler_id in (
        select pil.per_in_ler_id
        from ben_per_in_ler pil
        where pil.group_pl_id = lv_pl_id
          and pil.lf_evt_ocrd_dt = lv_lf_evt_ocrd_dt
          and pil.per_in_ler_stat_cd = 'BCKDT');
  --
  end if;
  --
  -- Bug 2288042
  -- Create 0 level heirarchy data for managers for whom this data
  -- is missing.
  --
  for l_no_0_hrchy in
      c_no_0_hrchy(lv_pl_id, lv_lf_evt_ocrd_dt) loop
      --
      begin
        --
        insert into ben_cwb_group_hrchy (
          emp_per_in_ler_id,
          mgr_per_in_ler_id,
          lvl_num  )
        values (
          l_no_0_hrchy.mgr_per_in_ler_id,
          l_no_0_hrchy.mgr_per_in_ler_id,
          0 );
        --
      exception when others then
        null;
      end;
      --
  end loop;
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,10);
  end if;
  --
end popu_group_pil_heir;
--
procedure get_group_plan_info(p_pl_id    in number,
                              p_lf_evt_ocrd_dt in date,
                              p_business_group_id    in number default null,
                              -- 9999IK Not required if we only run for group pl
                              p_group_pl_id in number default null
) is
  --
  l_proc         VARCHAR2(80);
  --
  cursor get_group_pl_fr_act_pl_info(cv_pl_id number,
                           cv_lf_evt_ocrd_dt date) is
    select pet.pl_id, enp.ASND_LF_EVT_DT,
           pet.business_group_id, enp.ler_id,
           enp.hrchy_to_use_cd,
           enp.pos_structure_version_id,
           enp.dflt_ws_acc_cd,
           enp.end_dt,
           enp.auto_distr_flag,
           enp.ws_upd_strt_dt,
           enp.ws_upd_end_dt,
           enp.uses_bdgt_flag,
           enp.hrchy_ame_trn_cd,
           enp.hrchy_rl,
           -- Bug 5232223
           group_pln.trk_inelig_per_flag
    from   ben_popl_enrt_typ_cycl_f pet,
           ben_enrt_perd enp,
           ben_ler_f ler,
           ben_pl_f pln,
           ben_pl_f group_pln
    where  enp.asnd_lf_evt_dt  = cv_lf_evt_ocrd_dt
        and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
        and    pet.business_group_id  = enp.business_group_id
        and    cv_lf_evt_ocrd_dt
               between pet.effective_start_date
               and     pet.effective_end_date
        and    ler.typ_cd = 'COMP'
        and    ler.business_group_id  = pet.business_group_id
        and    cv_lf_evt_ocrd_dt
               between ler.effective_start_date
               and     ler.effective_end_date
        and    ler.ler_id = enp.ler_id
        and    pet.pl_id = group_pln.pl_id
        and    cv_lf_evt_ocrd_dt
               between group_pln.effective_start_date
               and     group_pln.effective_end_date
        and    pln.group_pl_id = group_pln.pl_id
        and    pln.pl_id       = cv_pl_id
        and    cv_lf_evt_ocrd_dt
               between pln.effective_start_date
               and     pln.effective_end_date;
  --
  cursor get_group_pl_info(cv_pl_id number,
                           cv_lf_evt_ocrd_dt date) is
    select pet.pl_id,
           enp.ASND_LF_EVT_DT,
           pet.business_group_id, enp.ler_id,
           enp.hrchy_to_use_cd,
           enp.pos_structure_version_id,
           enp.dflt_ws_acc_cd,
           enp.end_dt,
           enp.auto_distr_flag,
           enp.ws_upd_strt_dt,
           enp.ws_upd_end_dt,
           enp.uses_bdgt_flag,
           enp.hrchy_ame_trn_cd,
           enp.hrchy_rl,
           -- Bug 5232223
           group_pln.trk_inelig_per_flag
    from   ben_popl_enrt_typ_cycl_f pet,
           ben_enrt_perd enp,
           ben_ler_f ler,
           ben_pl_f group_pln
    where  enp.asnd_lf_evt_dt  = cv_lf_evt_ocrd_dt
        and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
      --  and    pet.business_group_id  = enp.business_group_id
        and    cv_lf_evt_ocrd_dt
               between pet.effective_start_date
               and     pet.effective_end_date
        and    ler.typ_cd = 'COMP'
      --  and    ler.business_group_id  = pet.business_group_id
        and    cv_lf_evt_ocrd_dt
               between ler.effective_start_date
               and     ler.effective_end_date
        and    ler.ler_id = enp.ler_id
        and    pet.pl_id = group_pln.pl_id
        and    cv_lf_evt_ocrd_dt
               between group_pln.effective_start_date
               and     group_pln.effective_end_date
        and    group_pln.pl_id       = cv_pl_id
        and    cv_lf_evt_ocrd_dt
               between group_pln.effective_start_date
               and     group_pln.effective_end_date;
  --
  cursor get_pl_wthn_group_pl(cv_group_pl_id number,
                           cv_lf_evt_ocrd_dt date) is
    select count(*)
    from ben_pl_f
    where group_pl_id = cv_group_pl_id
      and cv_lf_evt_ocrd_dt between effective_start_date and
                                    effective_end_date;
  --
begin
  --
  if g_debug then
    l_proc := g_package||  '.get_group_plan_info';
    hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  --
  if g_cache_group_plan_rec.group_pl_id is null then
     --
     if p_group_pl_id is not null then
        --
        open get_group_pl_info(p_group_pl_id, p_lf_evt_ocrd_dt);
        fetch get_group_pl_info into g_cache_group_plan_rec.group_pl_id,
                               g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
                               g_cache_group_plan_rec.group_business_group_id,
                               g_cache_group_plan_rec.group_ler_id,
                               g_cache_group_plan_rec.hrchy_to_use_cd,
                               g_cache_group_plan_rec.pos_structure_version_id,
                               g_cache_group_plan_rec.access_cd,
                               g_cache_group_plan_rec.end_dt,
                               g_cache_group_plan_rec.auto_distr_flag,
                               g_cache_group_plan_rec.ws_upd_strt_dt,
                               g_cache_group_plan_rec.ws_upd_end_dt,
                               g_cache_group_plan_rec.uses_bdgt_flag,
                               g_cache_group_plan_rec.hrchy_ame_trn_cd,
                               g_cache_group_plan_rec.hrchy_rl,
                               -- Bug 5232223
                               g_cache_group_plan_rec.trk_inelig_per_flag;
        close get_group_pl_info;
        --
     else
        --
        open get_group_pl_fr_act_pl_info(p_pl_id, p_lf_evt_ocrd_dt);
        fetch get_group_pl_fr_act_pl_info into g_cache_group_plan_rec.group_pl_id,
                               g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
                               g_cache_group_plan_rec.group_business_group_id,
                               g_cache_group_plan_rec.group_ler_id,
                               g_cache_group_plan_rec.hrchy_to_use_cd,
                               g_cache_group_plan_rec.pos_structure_version_id,
                               g_cache_group_plan_rec.access_cd,
                               g_cache_group_plan_rec.end_dt,
                               g_cache_group_plan_rec.auto_distr_flag,
                               g_cache_group_plan_rec.ws_upd_strt_dt,
                               g_cache_group_plan_rec.ws_upd_end_dt,
                               g_cache_group_plan_rec.uses_bdgt_flag,
                               g_cache_group_plan_rec.hrchy_ame_trn_cd,
                               g_cache_group_plan_rec.hrchy_rl,
                               -- Bug 5232223
                               g_cache_group_plan_rec.trk_inelig_per_flag;
        close get_group_pl_fr_act_pl_info;
        --
     end if;
     --
     open get_pl_wthn_group_pl(g_cache_group_plan_rec.group_pl_id,
                               g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
     fetch get_pl_wthn_group_pl into g_cache_group_plan_rec.plans_wthn_group_pl;
     close get_pl_wthn_group_pl;
     --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,100);
  end if;
  --
end get_group_plan_info;
--
procedure popu_cwb_tables(
                        p_group_per_in_ler_id in number,
                        p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number,
                        p_use_eff_dt_flag      in     varchar2 default 'N',
                        p_effective_date       in date default null
) is
  --
  l_proc varchar2(80);
  --
  l_emp_pil_id     number;
  l_effective_date date := p_effective_date;
  l_uses_custom_intg varchar2(5);
  --
  cursor c_cwb_hrchy(cv_emp_pil_id in number) is
   select emp_per_in_ler_id
   from ben_cwb_group_hrchy
   where emp_per_in_ler_id = cv_emp_pil_id;
  --
  cursor c_cwb_tasks(cv_pl_id in number) is
   select *
   from ben_cwb_wksht_grp
   where PL_ID  = cv_PL_ID
     and STATUS_CD = 'A';

   cursor c_uses_custom_intg is
   select pli_information1
   from ben_pl_extra_info
   where pl_id = p_group_pl_id
   and information_type = 'CWB_CUSTOM_DOWNLOAD';
  --
begin
  --
  --
  if g_debug then
    l_proc := g_package||  '.popu_cwb_tables';
    hr_utility.set_location('Entering: '||l_proc,100);
  end if;
  --
  g_cache_group_plan_rec.group_per_in_ler_id := p_group_per_in_ler_id;
  --
  -- Populate ben_cwb_group_hrchy
  --
  open c_cwb_hrchy(p_group_per_in_ler_id);
  fetch c_cwb_hrchy into l_emp_pil_id;
  --
  hr_utility.set_location('p_group_per_in_ler_id: '||p_group_per_in_ler_id,111);
  if c_cwb_hrchy%notfound then
     --
     insert into ben_cwb_group_hrchy (
             emp_per_in_ler_id,
             mgr_per_in_ler_id,
             lvl_num,
             OBJECT_VERSION_NUMBER  )
     values(
             p_group_per_in_ler_id,
             -1,
             -1,
              1);
     --
  end if;
  --
  close c_cwb_hrchy;
  --
  -- Populate ben_cwb_person tasks
  --
  for l_cwb_tasks in c_cwb_tasks(p_group_pl_id) loop
      --
      insert into ben_cwb_person_tasks
        (GROUP_PER_IN_LER_ID
         ,TASK_ID
         ,GROUP_PL_ID
         ,LF_EVT_OCRD_DT
         ,STATUS_CD
         ,ACCESS_CD
         ,OBJECT_VERSION_NUMBER)
      values
        (p_group_per_in_ler_id,
         l_cwb_tasks.CWB_WKSHT_GRP_ID,
         p_group_pl_id,
         p_group_lf_evt_ocrd_dt,
         'NS',
         nvl(l_cwb_tasks.hidden_cd, 'UP'),
         1
         );
      --
  end loop;
  --
  if p_use_eff_dt_flag = 'N' then
     l_effective_date := null;
  end if;
  --
  BEN_CWB_PERSON_INFO_PKG.refresh_person_info
     (p_group_per_in_ler_id   => p_group_per_in_ler_id,
      p_effective_date        => l_effective_date,
      p_called_from_benmngle  => true);

  open c_uses_custom_intg;
  fetch c_uses_custom_intg into l_uses_custom_intg;
  close c_uses_custom_intg;
  if l_uses_custom_intg = 'Y' then
    ben_cwb_integrator_copy.copy_integrator(p_group_pl_id,'BEN_CWB_WRK_SHT_INTG');
  end if;

  --
  if g_debug then
    hr_utility.set_location('Leaving: '||l_proc,100);
  end if;
  --
end popu_cwb_tables;
--
procedure get_cwb_manager_and_assignment
             (p_person_id in number,
              p_hrchy_to_use_cd in varchar2,
              p_pos_structure_version_id in number,
              p_effective_date in date,
              p_manager_id out nocopy number,
              p_assignment_id out nocopy number )
  is
    --Bug 2827121 Manager can be a contingent worker also.

    CURSOR c_get_assignment IS
        SELECT assignment_id, position_id, organization_id, supervisor_id, business_group_id
          FROM per_all_assignments_f
         WHERE person_id = p_person_id
           AND primary_flag = 'Y'
           AND assignment_type IN ('E', 'C','B') -- Bug 2827121 --Bug 5148387
           AND p_effective_date BETWEEN effective_start_date AND effective_end_date
    order by decode(assignment_type,'E',1,'C',2,3);

    --
    l_get_assignment        c_get_assignment%ROWTYPE;

    --
    CURSOR c_parent_position_id (p_position_id NUMBER) IS
        SELECT parent_position_id
          FROM per_pos_structure_elements
         WHERE subordinate_position_id = p_position_id
           AND pos_structure_version_id = p_pos_structure_version_id;

    --
    CURSOR c_manager_id (p_position_id NUMBER) IS
        SELECT person_id
          FROM per_all_assignments_f ass,
               per_assignment_status_types ast
         WHERE ass.position_id = p_position_id
           AND ass.primary_flag = 'Y'
           AND ass.assignment_type IN ('E', 'C') -- Bug 2827121
           AND p_effective_date BETWEEN ass.effective_start_date
                                    AND ass.effective_end_date
           --Bug 3044311 -- Need to verify what other system types should be considered.
           AND ass.assignment_status_type_id = ast.assignment_status_type_id
           -- and ast.active_flag = 'Y'
           AND ast.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

    --
/*
    CURSOR c_sched_enrol_period_for_plan IS
      SELECT   enrtp.enrt_perd_id,
               enrtp.strt_dt,
               enrtp.end_dt,
               enrtp.procg_end_dt,
               enrtp.dflt_enrt_dt,
               petc.enrt_typ_cycl_cd,
               enrtp.cls_enrt_dt_to_use_cd,
               enrtp.hrchy_to_use_cd,
               enrtp.pos_structure_version_id,
               enrtp.enrt_perd_det_ovrlp_bckdt_cd
      FROM     ben_popl_enrt_typ_cycl_f petc,
               ben_enrt_perd enrtp,
                ben_ler_f ler
      WHERE    petc.pl_id = l_pl_id
      AND      petc.business_group_id = p_business_group_id
      AND      l_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                   AND petc.effective_end_date
      AND      petc.enrt_typ_cycl_cd <> 'L'
      AND      enrtp.business_group_id = p_business_group_id
      AND      enrtp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
      AND      enrtp.popl_enrt_typ_cycl_id  = petc.popl_enrt_typ_cycl_id
      and      ler.ler_id (+) = enrtp.ler_id
      and      ler.ler_id (+) = p_ler_id
      and      l_lf_evt_ocrd_dt between ler.effective_start_date (+)
                                    and ler.effective_end_date (+);
*/
  --
    l_proc varchar2(80);

    l_parent_position_id    NUMBER (15);
    l_manager_id            NUMBER (15);
    l_assignment_id         NUMBER (15);
    l_position_id           NUMBER (15);
    l_transaction_type_id   VARCHAR2 (50);
    l_application_id_out    NUMBER;
    l_application_id        NUMBER;
    l_ame_approver          ame_util.approverrecord;
    l_outputs               ff_exec.outputs_t;
    l_loc_rec               hr_locations_all%ROWTYPE;
--    l_ass_rec               per_all_assignments_f%ROWTYPE;
    l_jurisdiction_code     VARCHAR2 (30);
--

BEGIN
    --
    if g_debug then
        l_proc := g_package||  '.get_cwb_manager_and_assignment';
        hr_utility.set_location('Entering: '||l_proc,100);
    end if;
    --
    hr_utility.set_location('p_hrchy_to_use_cd '|| p_hrchy_to_use_cd,100);
    --
    OPEN c_get_assignment;
    FETCH c_get_assignment INTO l_get_assignment;
    CLOSE c_get_assignment;
    --
    l_assignment_id := l_get_assignment.assignment_id;

    --
    IF p_hrchy_to_use_cd = 'S' THEN
        l_manager_id := l_get_assignment.supervisor_id;
    ELSIF p_hrchy_to_use_cd = 'P' THEN
        -- Start Bug 2684227
        -- Upon a vacancy, continue to climb the position hierarchy
        -- until a person is found
        l_position_id := l_get_assignment.position_id;

        --
        LOOP
            OPEN c_parent_position_id (l_position_id);
            FETCH c_parent_position_id INTO l_parent_position_id;
            EXIT WHEN c_parent_position_id%NOTFOUND;
            CLOSE c_parent_position_id;

            IF l_parent_position_id IS NOT NULL THEN
                OPEN c_manager_id (l_parent_position_id);
                FETCH c_manager_id INTO l_manager_id;
                CLOSE c_manager_id;

                IF l_manager_id IS NOT NULL THEN
                    EXIT;
                END IF;
            END IF;

            l_position_id := l_parent_position_id;
        END LOOP;

        -- End Bug 2684227
        -- Bug 2230922 : If manager id not found then default to supervisor.
        IF l_manager_id IS NULL THEN
            --
            l_manager_id := l_get_assignment.supervisor_id;
        --
        END IF;
     --
    --  Bug: 3979082: Changes start here
    ELSIF p_hrchy_to_use_cd = 'AME' THEN
        -- Use AME Hierarchy to fetch manager hierarchy.
        l_application_id := 805; -- Default it to 805
                                 -- Fetch the next approver
        hr_utility.set_location(' g_cache_group_plan_rec.hrchy_ame_trn_cd '
                                    || g_cache_group_plan_rec.hrchy_ame_trn_cd, 20);
        hr_utility.set_location(' p_person_id '|| p_person_id, 20);
        --
        BEGIN
            ame_api.getnextapprover (applicationidin         => l_application_id,
                                     transactionidin         => p_person_id,
                                     transactiontypein       => g_cache_group_plan_rec.hrchy_ame_trn_cd,
                                     nextapproverout         => l_ame_approver
                                    );
        EXCEPTION
            WHEN OTHERS THEN
             fnd_message.set_name('BEN','BEN_94119_AME_APPL_ERR');
             fnd_message.set_token('AME_ERROR', SQLERRM);
             fnd_message.raise_error;
        END;
        hr_utility.set_location(' l_ame_approver.person_id '|| l_ame_approver.person_id, 20);
        --
        l_manager_id := l_ame_approver.person_id;
    --
    ELSIF p_hrchy_to_use_cd = 'RL' THEN
        -- Use Rule to fetch Manager Id.
        hr_utility.set_location(' process RULE hrchy_rl '||g_cache_group_plan_rec.hrchy_rl, 20);
        --
        l_outputs :=
            benutils.formula (p_formula_id              => g_cache_group_plan_rec.hrchy_rl
                              ,p_effective_date          => NVL(g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
                                                                  p_effective_date)
                              ,p_assignment_id           => l_get_assignment.assignment_id
                              ,p_organization_id         => l_get_assignment.organization_id
                              ,p_business_group_id       => l_get_assignment.business_group_id
                              ,p_pl_id                   => g_cache_group_plan_rec.group_pl_id
                              ,p_ler_id                  => g_cache_group_plan_rec.group_ler_id
                              -- ENTER INPUT VALUES HERE
                              ,p_param1             => 'BEN_IV_PERSON_ID'
                              ,p_param1_value       => p_person_id
                              ,p_param2             => 'BEN_IV_ACCESS_CD'
                              ,p_param2_value       => g_cache_group_plan_rec.access_cd
                              ,p_param3             => 'BEN_IV_END_DT'
                              ,p_param3_value       => fnd_date.date_to_canonical(g_cache_group_plan_rec.end_dt)
                              ,p_param4             => 'BEN_IV_AUTO_DISTR_FLAG'
                              ,p_param4_value       => g_cache_group_plan_rec.auto_distr_flag
                              ,p_param5             => 'BEN_IV_WS_UPD_STRT_DT'
                              ,p_param5_value       => fnd_date.date_to_canonical(g_cache_group_plan_rec.ws_upd_strt_dt)
                              ,p_param6             => 'BEN_IV_WS_UPD_END_DT'
                              ,p_param6_value       => fnd_date.date_to_canonical(g_cache_group_plan_rec.ws_upd_end_dt)
                              ,p_param7             => 'BEN_IV_USES_BDGT_FLAG'
                              ,p_param7_value       => g_cache_group_plan_rec.uses_bdgt_flag
                             );
        --
        l_manager_id := TO_NUMBER(l_outputs(l_outputs.FIRST).VALUE);
        --
        hr_utility.set_location(' Rule ret MGR_ID '|| l_manager_id, 20);
        --
    --  Bug: 3979082: Changes end here
    END IF;
    --
    p_manager_id := l_manager_id;
    p_assignment_id := l_assignment_id;
    --
    if g_debug then
        l_proc := g_package||  '.get_cwb_manager_and_assignment';
        hr_utility.set_location('Leaving: '||l_proc,100);
    end if;
--
EXCEPTION          -- nocopy changes
          --
    WHEN OTHERS THEN
        --
        p_manager_id := NULL;
        p_assignment_id := NULL;
        RAISE;
end get_cwb_manager_and_assignment;
--
-- NOTE : THIS PROCEDURE SHOULD NOT BE CALLED/USED WITHOUT CONTACTING
-- TY HAYDEN OR PRASAD BODLA
-- TRACK INELIG FLAG IS NO LONGER USED.
-- deletes per in lers and associated data for people with no elctble chc
-- for actual plans, if trk_inelig_per_flag is set to N
--
procedure del_all_cwb_pils
(p_person_id      in  number default null,
 p_group_pl_id     in  number,
 p_group_ler_id   in  number,
 p_group_lf_evt_ocrd_dt in  date) is
  --
  cursor c_popl(cv_per_in_ler_id number) is
  select pel.pil_elctbl_chc_popl_id,
       pel.object_version_number pel_ovn
  from ben_pil_elctbl_chc_popl pel
  where pel.per_in_ler_id = cv_per_in_ler_id;
  --
  l_popl_rec c_popl%rowtype;
  --
  cursor c_epe(cv_per_in_ler_id number,
               cv_pil_elctbl_chc_popl_id number) is
  select epe.elig_per_elctbl_chc_id,
       epe.object_version_number epe_ovn
  from ben_elig_per_elctbl_chc epe
  where epe.per_in_ler_id = cv_per_in_ler_id
   and cv_pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id;
  --
  cursor c_pln(cv_effective_date date) is
  select pl.trk_inelig_per_flag
    from ben_pl_f pl
   where pl.pl_id = p_group_pl_id
     and cv_effective_date between pl.effective_start_date and
         pl.effective_end_date;
  --
  l_trk_inelig_flag varchar2(30);
  --
  -- Can we identify seeing group_per_in_ler_id is -1 and
  -- all rows for people with non -1 group_per_in_ler_id
  -- and not in ws_mgr_id
  --
  -- Bug 5232223 : modified cursor
  cursor c_del_inelg_per(cv_group_pl_id number, cv_lf_evt_ocrd_dt date)
  is
  select pil.per_in_ler_id,
       pil.object_version_number pil_ovn,
       pil.business_group_id,
       ptnl.ptnl_ler_for_per_id,
       ptnl.object_version_number ptnl_ovn
  from ben_per_in_ler pil,
       ben_ptnl_ler_for_per ptnl,
       ben_cwb_person_info cpi
  where pil.group_pl_id = cv_group_pl_id
   and pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
   and pil.per_in_ler_stat_cd = 'STRTD'
   and cpi.group_per_in_ler_id = pil.per_in_ler_id
   and cpi.person_id = -1
   and ptnl.ptnl_ler_for_per_id = pil.ptnl_ler_for_per_id
   and ptnl.ptnl_ler_for_per_stat_cd = 'PROCD'
   and not exists
       (select 'Y'
        from ben_cwb_group_hrchy hrh
        where hrh.mgr_per_in_ler_id = pil.per_in_ler_id
          and hrh.lvl_num > 0)
   and not exists
       (select 'Y'
        from ben_cwb_person_rates
        where group_pl_id = cv_group_pl_id
          and person_id   = pil.person_id
          and lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
          and elig_flag = 'Y');
 --
 l_package varchar2(80);
 --
begin
   --
   /*  If track inelig flag is N for group plan then
    *
    *     For given GROUP_PL_ID, GROUP_OIPL_ID, LF_EVT_OCRD_DT
    *
    *     if there are no rows in ben_cwb_person_rates with
    *     ELIG_FLAG = Y  and only consider uncloned data
    *     then
    *
    *         Delete data from ben_cwb_person_rates, ben_cwb_person_groups,
    *           ben_per_in_ler, ben_ptnl_ler_for_per, ben_pil_elctbl_chc_popl,
    *           ben_elig_per_elctbl_chc, ben_group_heirarchy,
    *           ben_cwb_person_tasks.
    */
   if g_debug then
     l_package := g_package||'.del_all_cwb_pils';
     hr_utility.set_location ('Entering '||l_package,10);
   end if;
   --
   -- This cursor can be avoided if it is fetched in main process.
   --
   open c_pln(p_group_lf_evt_ocrd_dt);
   fetch c_pln into g_trk_inelig_flag;
   if g_trk_inelig_flag = 'N' then
      --
      for del_inelg_per_rec in c_del_inelg_per(p_group_pl_id,
                                               p_group_lf_evt_ocrd_dt)
      loop
        --
        for l_popl_rec in c_popl(del_inelg_per_rec.per_in_ler_id)
        loop
           --
           -- First delete epe data.
           --
           for l_epe_rec in c_epe(del_inelg_per_rec.per_in_ler_id,
                                  l_popl_rec.pil_elctbl_chc_popl_id)
           loop
              --
              ben_elig_per_elc_chc_api.delete_ELIG_PER_ELC_CHC
             (p_elig_per_elctbl_chc_id => l_epe_rec.elig_per_elctbl_chc_id,
              p_object_version_number  => l_epe_rec.epe_ovn,
              p_effective_date         => p_group_lf_evt_ocrd_dt);
              --
           end loop;
           --
           ben_Pil_Elctbl_chc_Popl_api.delete_Pil_Elctbl_chc_Popl
          (p_pil_elctbl_chc_popl_id   => l_popl_rec.pil_elctbl_chc_popl_id,
           p_object_version_number  => l_popl_rec.pel_ovn,
           p_effective_date         => p_group_lf_evt_ocrd_dt);
           --
        end loop;
        --
        --
        -- Now delete CWB data.
        --
        ben_cwb_back_out_conc.delete_cwb_data(
                        p_per_in_ler_id      => del_inelg_per_rec.per_in_ler_id
                       ,p_business_group_id  => del_inelg_per_rec.business_group_id
                       );
        --
        ben_Person_Life_Event_api.delete_Person_Life_Event
        (p_per_in_ler_id          => del_inelg_per_rec.per_in_ler_id,
         p_object_version_number  => del_inelg_per_rec.pil_ovn,
         p_effective_date         => p_group_lf_evt_ocrd_dt);

         ben_ptnl_ler_for_per_api.delete_ptnl_ler_for_per
        (p_ptnl_ler_for_per_id    => del_inelg_per_rec.ptnl_ler_for_per_id,
         p_object_version_number  => del_inelg_per_rec.ptnl_ovn,
         p_effective_date         => p_group_lf_evt_ocrd_dt);
        --
      end loop;
      --
   end if;
   --
   if g_debug then
     hr_utility.set_location ('Leaving '||l_package,10);
   end if;
   --
end del_all_cwb_pils;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< p_single_per_clone_all_data >----------------------|
-- ----------------------------------------------------------------------------
--
procedure p_single_per_clone_all_data(
                                p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_effective_date in date
                               ,p_lf_evt_ocrd_dt in date
                               ,p_pl_id          in number
                               ,p_clone_only_cpg in varchar2 default 'N'
                               ) is
  --
  l_ptnl_ler_for_per_id     BEN_PTNL_LER_FOR_PER.PTNL_LER_FOR_PER_ID%TYPE;
  l_curr_per_in_ler_id      number;
  l_object_version_number   BEN_PTNL_LER_FOR_PER.OBJECT_VERSION_NUMBER%TYPE;
  l_pil_object_version_number   BEN_PTNL_LER_FOR_PER.OBJECT_VERSION_NUMBER%TYPE;
  l_ws_mgr_id               number;
  l_assignment_id           number;
  l_ler_id                  number;
  l_procd_dt                date;
  l_strtd_dt                date;
  l_voidd_dt                date;
  l_proc                    varchar2(72) := g_package||'.p_single_per_clone_all_data';
  --
  cursor c_popl_enrt_typ_cycl(cv_lf_evt_ocrd_dt    date,
                              cv_business_group_id number,
                              cv_effective_date    date,
                              cv_pl_id             number) is
     select ler.ler_id
     from   ben_popl_enrt_typ_cycl_f pet,
           ben_enrt_perd enp,
           ben_ler_f ler
     where  enp.business_group_id  = cv_business_group_id
     and    enp.asnd_lf_evt_dt  = cv_lf_evt_ocrd_dt
     and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
     and    pet.business_group_id  = enp.business_group_id
     and    cv_effective_date between pet.effective_start_date
                              and     pet.effective_end_date
     and    ler.typ_cd = 'COMP'
     and    ler.business_group_id  = pet.business_group_id
     and    cv_effective_date between ler.effective_start_date
                              and     ler.effective_end_date
     and    ler.ler_id = enp.ler_id
     and    pet.pl_id = cv_pl_id;
  --
  cursor c_cpg(c_group_pl_id number, c_group_lf_evt_ocrd_dt date) is
     select cpg.*
     from ben_cwb_person_groups cpg
     where cpg.group_pl_id = c_group_pl_id
       and cpg.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
       and cpg.group_per_in_ler_id =
           (select cpg1.group_per_in_ler_id
            from ben_cwb_person_groups cpg1
            where cpg1.group_pl_id = c_group_pl_id
              and cpg1.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
              and rownum = 1);
  --
  CURSOR c_person_rates
    (c_group_lf_evt_ocrd_dt     IN DATE
    ,c_group_pl_id              IN NUMBER
    ,c_pl_id                    IN NUMBER
    )
   is
    select cpr.rowid, cpr.*
    from ben_cwb_person_rates cpr
    where cpr.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
      and cpr.group_pl_id    = c_group_pl_id
      and cpr.pl_id         = c_pl_id
      and cpr.person_id =
           (select cpr1.person_id
            from ben_cwb_person_rates cpr1
            where cpr1.group_pl_id = c_group_pl_id
              and cpr1.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
              and cpr1.pl_id          = c_pl_id
              and rownum = 1);
  --
  cursor c_asg is
    select asg.assignment_id
    from   per_all_assignments_f asg
    where  asg.person_id = p_person_id
    and    asg.primary_flag = 'Y'
    and    p_effective_date
           between asg.effective_start_date
           and     asg.effective_end_date
    order by asg.assignment_type desc;
  --
  cursor get_mgr_pil_id (cv_person_id in number,
                       cv_lf_evt_ocrd_dt in date,
                       cv_group_ler_id in number) is
     select per_in_ler_id
     from ben_per_in_ler
     where person_id = cv_person_id
       and lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
       and ler_id = cv_group_ler_id
       and per_in_ler_stat_cd = 'STRTD';
  --
  l_mgr_per_in_ler_id  number;
  --
begin
  --
  -- Clone the data for current plan only.
  -- Group plan cloning should happen at the end of the loop.
  --
  hr_utility.set_location ('Entering  '||l_proc,10);
  open c_popl_enrt_typ_cycl(p_lf_evt_ocrd_dt,
                            p_business_group_id,
                            p_effective_date,
                            p_pl_id);
  --
  fetch c_popl_enrt_typ_cycl into l_ler_id;
  if c_popl_enrt_typ_cycl%notfound then
  --
     close c_popl_enrt_typ_cycl;
     fnd_message.set_name('BEN','BEN_91668_NO_FIND_POPL_ENRT');
     fnd_message.raise_error;
  end if;
  close c_popl_enrt_typ_cycl;
  hr_utility.set_location('p_lf_evt_ocrd_dt = ' || p_lf_evt_ocrd_dt, 1234);
  hr_utility.set_location('l_ler_id = ' || l_ler_id, 1234);
  hr_utility.set_location('p_pl_id = ' || p_pl_id, 1234);
  hr_utility.set_location('p_business_group_id = ' || p_business_group_id, 1234);
  --
  ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf
      (p_validate                 => false,
       p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
       p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt,
       p_ptnl_ler_for_per_stat_cd => 'PROCD',
       p_ler_id                   => l_ler_id,
       p_person_id                => p_person_id,
       -- p_ntfn_dt                  => l_ntfn_dt,
       -- p_unprocd_dt               => l_unprocd_dt,
       -- p_dtctd_dt                 => l_dtctd_dt,
       p_business_group_id        => p_business_group_id,
       p_object_version_number    => l_object_version_number,
       p_effective_date           => p_effective_date,
       p_program_application_id   => fnd_global.prog_appl_id,
       p_program_id               => fnd_global.conc_program_id,
       p_request_id               => fnd_global.conc_request_id,
       p_program_update_date      => sysdate);
  --
  ben_manage_cwb_life_events.get_group_plan_info(
       p_pl_id                => p_pl_id,
       p_lf_evt_ocrd_dt       => p_lf_evt_ocrd_dt,
       p_business_group_id    => p_business_group_id);
  --
  hr_utility.set_location('group_pl_id ' ||
       ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id ,20);
  if p_pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id
  then
    --
    ben_manage_cwb_life_events.g_cache_group_plan_rec.group_per_in_ler_id := null;
    --
    ben_manage_cwb_life_events.get_cwb_manager_and_assignment
      (p_person_id                => p_person_id,
       p_hrchy_to_use_cd          => ben_manage_cwb_life_events.g_cache_group_plan_rec.hrchy_to_use_cd,
       p_pos_structure_version_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.pos_structure_version_id,
       p_effective_date           => p_effective_date,
       p_manager_id               => l_ws_mgr_id,
       p_assignment_id            => l_assignment_id ) ;
        --
    --
    -- If manager is not processed previously then system should
    -- not attempt to clone for the manager later, so make the
    -- current person's ws_mgr_id as null
    --
    l_mgr_per_in_ler_id := null;
    open get_mgr_pil_id (l_ws_mgr_id,
                      g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
                      g_cache_group_plan_rec.group_ler_id);
    fetch get_mgr_pil_id into l_mgr_per_in_ler_id;
    close get_mgr_pil_id;
    --
    /* Following condition is causing data not cloned for manager
       so commenting. Need to identify why this was put. Currnetly commented
       as following case is not working.
       Case 1 :

       Manager Name : SPP PRocess 16
          Hire Date : 30-Nov-2000
       Employee Name : SPP PRocess 17 (SPP Process 16 is the supervisor for
         this person)
       Hire Date : 30-Nov-2004

       Plan Name : Single Run Bonus
          lv_evt_ocrd_dt : 01-Jan-2004

      Ran the particiption process for this person with effective date :
      01-Dec-2004, SPP Process 16 was not processed as place-holder person.
      SPP PRocess 16 have to be processed as place holder
      ***************
    if l_mgr_per_in_ler_id is null then
       --
       l_ws_mgr_id := null;
       --
    end if;
    --
   */
  end if;
  --
  hr_utility.set_location('group_pl_id = ' ||
           ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id, 30);
  --
  hr_utility.set_location('l_ws_mgr_id = ' || l_ws_mgr_id, 1234);
  hr_utility.set_location('l_assignment_id = ' || l_assignment_id, 1234);
  ben_Person_Life_Event_api.create_Person_Life_Event_perf
    (p_validate                => false
    ,p_per_in_ler_id           => l_curr_per_in_ler_id
    ,p_ler_id                  => l_ler_id
    ,p_person_id               => p_person_id
    ,p_per_in_ler_stat_cd      => 'STRTD'
    ,p_ptnl_ler_for_per_id     => l_ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt          => p_lf_evt_ocrd_dt
    ,p_business_group_id       => p_business_group_id
    ,p_ntfn_dt                 => trunc(sysdate)
    ,p_group_pl_id             => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id
    ,p_ws_mgr_id               => l_ws_mgr_id
    ,p_assignment_id           => l_assignment_id
    ,p_object_version_number   => l_pil_object_version_number
    ,p_effective_date          => p_effective_date
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    ,p_procd_dt                => l_procd_dt
    ,p_strtd_dt                => l_strtd_dt
    ,p_voidd_dt                => l_voidd_dt);
  --
  -- Now clone the ben_cwb_person_rates, ben_cwb_group_rates.
  --
  if p_pl_id = ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id then
        --
        -- Per in ler created is a group per in ler so populate other
        -- plan design tables.
        --
        ben_manage_cwb_life_events.g_cache_group_plan_rec.group_per_in_ler_id := l_curr_per_in_ler_id;
        --
        hr_utility.set_location('Call ben_manage_cwb_life_events.popu_cwb_tables', 40);
        ben_manage_cwb_life_events.popu_cwb_tables(
            p_group_per_in_ler_id    =>  l_curr_per_in_ler_id,
            p_group_pl_id            =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id,
            p_group_lf_evt_ocrd_dt   =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
            p_group_business_group_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_business_group_id,
            p_group_ler_id           =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_ler_id,
            p_effective_date         =>  p_effective_date,
            p_use_eff_dt_flag        =>  'Y');
        --
        -- For each of the group rates rows for a sample person
        --   copy data to current person.
        --
        for l_cpg_rec in c_cpg(ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id,
                               ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt)
        loop
             --
             -- create row in ben_cwb_person_groups
             --
             hr_utility.set_location('Creating missing ben_cwb_person_groups', 50);
             insert into ben_cwb_person_groups
                   (group_per_in_ler_id,
                    group_pl_id        ,
                    group_oipl_id      ,
                    lf_evt_ocrd_dt     ,
                    bdgt_pop_cd        ,
                    due_dt             ,
                    access_cd          ,
                    approval_cd        ,
                    approval_date      ,
                    approval_comments  ,
                    submit_cd          ,
                    submit_date        ,
                    submit_comments    ,
                    dist_bdgt_val      ,
                    ws_bdgt_val        ,
                    rsrv_val           ,
                    dist_bdgt_mn_val   ,
                    dist_bdgt_mx_val   ,
                    dist_bdgt_incr_val ,
                    ws_bdgt_mn_val     ,
                    ws_bdgt_mx_val     ,
                    ws_bdgt_incr_val   ,
                    rsrv_mn_val        ,
                    rsrv_mx_val        ,
                    rsrv_incr_val      ,
                    dist_bdgt_iss_val  ,
                    ws_bdgt_iss_val    ,
                    dist_bdgt_iss_date ,
                    ws_bdgt_iss_date   ,
                    ws_bdgt_val_last_upd_date ,
                    dist_bdgt_val_last_upd_date  ,
                    rsrv_val_last_upd_date       ,
                    ws_bdgt_val_last_upd_by      ,
                    dist_bdgt_val_last_upd_by    ,
                    rsrv_val_last_upd_by         ,
                    object_version_number      /*  ,
                    last_update_date         ,
                    last_updated_by          ,
                    last_update_login        ,
                    created_by               ,
                    creation_date  */
                 ) values (
                    l_curr_per_in_ler_id,
                    l_cpg_rec.group_pl_id        ,
                    nvl(l_cpg_rec.group_oipl_id, -1) ,
                    l_cpg_rec.lf_evt_ocrd_dt     ,
                    null,  --  bdgt_pop_cd
                    null,  -- l_cpg_rec.due_dt,
                    g_cache_group_plan_rec.access_cd, -- l_cpg_rec.access_cd,
                    null,  -- approval_cd
                    null,  -- approval_date
                    null,  -- approval_comments
                    'NS',  -- submit_cd
                    null,  -- submit_date
                    null,  -- submit_comments
                    null,  -- l_copy_dist_bdgt_val,
                    null,  -- l_copy_ws_bdgt_val,
                    null,  -- l_copy_rsrv_val,
                    null,  -- l_copy_dist_bdgt_mn_val,
                    null,  -- l_copy_dist_bdgt_mx_val,
                    null,  -- l_copy_dist_bdgt_incr_val,
                    null,  -- l_copy_ws_bdgt_mn_val,
                    null,  -- l_copy_ws_bdgt_mx_val,
                    null,  -- l_copy_ws_bdgt_incr_val,
                    null,  -- l_copy_rsrv_mn_val,
                    null,  -- l_copy_rsrv_mx_val,
                    null,  -- l_copy_rsrv_incr_val,
                    null,  -- l_copy_dist_bdgt_iss_val,
                    null,  -- l_copy_ws_bdgt_iss_val,
                    null,  -- l_copy_dist_bdgt_iss_date,
                    null,  -- l_copy_ws_bdgt_iss_date,
                    null,  -- l_cpg_rec.ws_bdgt_val_last_upd_date ,
                    null,  -- l_cpg_rec.dist_bdgt_val_last_upd_date  ,
                    null,  -- l_cpg_rec.rsrv_val_last_upd_date       ,
                    null,  -- l_cpg_rec.ws_bdgt_val_last_upd_by      ,
                    null,  -- l_cpg_rec.dist_bdgt_val_last_upd_by    ,
                    null,  -- l_cpg_rec.rsrv_val_last_upd_by         ,
                    1-- , -- object_version_number
                    /*
                    l_cpg_rec.last_update_date         ,
                    l_cpg_rec.last_updated_by          ,
                    l_cpg_rec.last_update_login        ,
                    l_cpg_rec.created_by               ,
                    l_cpg_rec.creation_date
                    */
             ) ;
            --
        end loop;
        --
    end if;
    --
    if p_clone_only_cpg = 'N' then
       --
       -- Copy relevant content from populate_cwb_rates
       --
       -- For each of the person rates rows for a sample person
       --   copy data to current person.
       --
       --  Populate
       --  BEN_CWB_PERSON_RATES
       --    Primary Key: PERSON_RATE_ID
       --
       hr_utility.set_location ('p_pl_id  ' || p_pl_id,60);
       hr_utility.set_location ('g_cache_group_plan_rec.group_pl_id  '||
                                 g_cache_group_plan_rec.group_pl_id ,60);
       hr_utility.set_location ('g_cache_group_plan_rec.plans_wthn_group_pl  '
                                || g_cache_group_plan_rec.plans_wthn_group_pl ,60);
       if ((p_pl_id = g_cache_group_plan_rec.group_pl_id and
          g_cache_group_plan_rec.plans_wthn_group_pl = 1
         ) OR
         (p_pl_id <> g_cache_group_plan_rec.group_pl_id)
        )
       then
         --
         if g_debug then
            hr_utility.set_location ('Person rate  ' ,70);
         end if;
         --
         for l_cpr_rec in c_person_rates(
             c_group_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt
            ,c_group_pl_id              => g_cache_group_plan_rec.group_pl_id
            ,c_pl_id                    => p_pl_id)
         loop
             --
             if l_assignment_id is null then
                --
                open c_asg;
                fetch c_asg into l_assignment_id;
                close c_asg;
                --
             end if;
             --
             insert into ben_cwb_person_rates
              (person_rate_id                   ,
               group_per_in_ler_id              ,
               pl_id                            ,
               oipl_id                          ,
               group_pl_id                      ,
               group_oipl_id                    ,
               lf_evt_ocrd_dt                   ,
               person_id                        ,
               assignment_id                    ,
               elig_flag                        ,
               ws_val                           ,
               ws_mn_val                        ,
               ws_mx_val                        ,
               ws_incr_val                      ,
               elig_sal_val                     ,
               stat_sal_val                     ,
               oth_comp_val                     ,
               tot_comp_val                     ,
               misc1_val                        ,
               misc2_val                        ,
               misc3_val                        ,
               rec_val                          ,
               rec_mn_val                       ,
               rec_mx_val                       ,
               rec_incr_val                     ,
               ws_val_last_upd_date             ,
               ws_val_last_upd_by               ,
               pay_proposal_id                  ,
               element_entry_value_id           ,
               inelig_rsn_cd                    ,
               elig_ovrid_dt                    ,
               elig_ovrid_person_id             ,
               copy_dist_bdgt_val               ,
               copy_ws_bdgt_val                 ,
               copy_rsrv_val                    ,
               copy_dist_bdgt_mn_val            ,
               copy_dist_bdgt_mx_val            ,
               copy_dist_bdgt_incr_val          ,
               copy_ws_bdgt_mn_val              ,
               copy_ws_bdgt_mx_val              ,
               copy_ws_bdgt_incr_val            ,
               copy_rsrv_mn_val                 ,
               copy_rsrv_mx_val                 ,
               copy_rsrv_incr_val               ,
               copy_dist_bdgt_iss_val           ,
               copy_ws_bdgt_iss_val             ,
               copy_dist_bdgt_iss_date          ,
               copy_ws_bdgt_iss_date            ,
               COMP_POSTING_DATE                ,
               WS_RT_START_DATE                 ,
               currency                         ,
               object_version_number            /*,
               last_update_date                 ,
               last_updated_by                  ,
               last_update_login                ,
               created_by                       ,
               creation_date  */
              ) values
              (ben_cwb_person_rates_s.nextval,
               nvl(g_cache_group_plan_rec.group_per_in_ler_id, -1),
               l_cpr_rec.pl_id,
               nvl(l_cpr_rec.oipl_id, -1),
               l_cpr_rec.group_pl_id,
               nvl(l_cpr_rec.group_oipl_id, -1), -- group_oipl_id ,
               l_cpr_rec.lf_evt_ocrd_dt,
               p_person_id,
               l_assignment_id                    ,
               'Y',  -- l_elig_flag                        ,
               null, -- l_cpr_rec.ws_val                           ,
               null, -- l_cpr_rec.ws_mn_val                        ,
               null, -- l_cpr_rec.ws_mx_val                        ,
               null, -- l_cpr_rec.ws_incr_val                      ,
               null, -- l_cpr_rec.elig_sal_val                     ,
               null, -- l_cpr_rec.stat_sal_val                     ,
               null, -- l_cpr_rec.oth_comp_val                     ,
               null, -- l_cpr_rec.tot_comp_val                     ,
               null, -- l_cpr_rec.misc1_val                        ,
               null, -- l_cpr_rec.misc2_val                        ,
               null, -- l_cpr_rec.misc3_val                        ,
               null, -- l_cpr_rec.rec_val                          ,
               null, -- l_cpr_rec.rec_mn_val                       ,
               null, -- l_cpr_rec.rec_mx_val                       ,
               null, -- l_cpr_rec.rec_incr_val                     ,
               null, -- l_cpr_rec.ws_val_last_upd_date             ,
               null, -- l_cpr_rec.ws_val_last_upd_by               ,
               null, -- g_cwb_person_rates_rec.pay_proposal_id                  ,
               null, -- g_cwb_person_rates_rec.element_entry_value_id           ,
               null, -- l_inelig_rsn_cd                    ,
               null, -- l_cpr_rec.elig_ovrid_dt                    ,
               null, -- l_cpr_rec.elig_ovrid_person_id             ,
               null, -- g_cwb_person_rates_rec.copy_dist_bdgt_val               ,
               null, -- g_cwb_person_rates_rec.copy_ws_bdgt_val                 ,
               null, -- g_cwb_person_rates_rec.copy_rsrv_val                    ,
               null, -- g_cwb_person_rates_rec.copy_dist_bdgt_mn_val            ,
               null, -- g_cwb_person_rates_rec.copy_dist_bdgt_mx_val            ,
               null, -- g_cwb_person_rates_rec.copy_dist_bdgt_incr_val          ,
               null, -- g_cwb_person_rates_rec.copy_ws_bdgt_mn_val              ,
               null, -- g_cwb_person_rates_rec.copy_ws_bdgt_mx_val              ,
               null, -- g_cwb_person_rates_rec.copy_ws_bdgt_incr_val            ,
               null, -- g_cwb_person_rates_rec.copy_rsrv_mn_val                 ,
               null, -- g_cwb_person_rates_rec.copy_rsrv_mx_val                 ,
               null, -- g_cwb_person_rates_rec.copy_rsrv_incr_val               ,
               null, -- g_cwb_person_rates_rec.copy_dist_bdgt_iss_val           ,
               null, -- g_cwb_person_rates_rec.copy_ws_bdgt_iss_val             ,
               null, -- g_cwb_person_rates_rec.copy_dist_bdgt_iss_date          ,
               null, -- g_cwb_person_rates_rec.copy_ws_bdgt_iss_date            ,
               null, -- l_cpr_rec.COMP_POSTING_DATE,
               null, -- l_cpr_rec.WS_RT_START_DATE,
               l_cpr_rec.currency, -- Bug 5104388
               1 -- object_version_number            ,
               /* l_cpr_rec.last_update_date                 ,
               l_cpr_rec.last_updated_by                  ,
               l_cpr_rec.last_update_login                ,
               l_cpr_rec.created_by                       ,
               l_cpr_rec.creation_date
               */
               );
               --
         end loop;
       end if;
    end if;
    --
end p_single_per_clone_all_data;
--
procedure global_process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'W'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  ,p_trace_plans_flag         in     varchar2 default 'N'
  ,p_online_call_flag         in     varchar2 default 'N'
  ,p_clone_all_data_flag      in     varchar2 default 'N'
  ,p_cwb_person_type          in     varchar2 default NULL
  ,p_run_rollup_only          in     varchar2 default 'N'     /* Bug 4875181 */
  ) is
    --
    l_package                   varchar2(80) := g_package||'.global_process';
    --
    l_retcode                   number;
    l_errbuf                    varchar2(1000);
    l_encoded_message   varchar2(2000);
    l_app_short_name    varchar2(2000);
    l_message_name      varchar2(2000);
    --
    l_prog_count     number;
    l_plan_count     number;
    l_oipl_count     number;
    l_person_count   number;
    l_plan_nip_count number;
    l_oipl_nip_count number;

    l_request_id                number;
    l_slave_errored             boolean ;
    l_lf_evt_ocrd_dt            date := fnd_date.canonical_to_date(p_lf_evt_ocrd_dt);
    l_effective_date            date := fnd_date.canonical_to_date(p_effective_date);
    --Build Hierarchy
    l_pl_id                     number := p_pl_id ;
    l_business_group_id         number;
    l_ler_id                    number;
    L_USE_EFF_DT_FLAG           varchar2(1) := 'N';
    --
    -- Bug 3482033 fixes
    --
    cursor c_pln(p_pl_id number) is
      select '1' pln_order,
             pln.pl_id,
             pln.business_group_id,
             pln.name
        from ben_pl_f pln
       where pln.group_pl_id = p_pl_id
         and l_lf_evt_ocrd_dt between pln.effective_start_date
                                  and pln.effective_end_date
         and pln.pl_id =pln.group_pl_id
         and pln.pl_stat_cd = 'A'
      union
      select '2' pln_order,
             pln.pl_id,
             pln.business_group_id,
             pln.name
        from ben_pl_f pln
       where pln.group_pl_id = p_pl_id
         and l_lf_evt_ocrd_dt between pln.effective_start_date
                                  and pln.effective_end_date
         and pln.pl_id <> pln.group_pl_id
         and pln.pl_stat_cd = 'A'
       order by pln_order ;
    --
    cursor c_benfts_grp(cv_benfts_grp_id number, cv_business_group_id number) is
      select bnb.benfts_grp_id
      from ben_benfts_grp bnb,
           ben_benfts_grp bnb1
      where bnb.business_group_id = cv_business_group_id
        and bnb.name = bnb1.name
        and bnb1.benfts_grp_id    = cv_benfts_grp_id;
    --
    l_benfts_grp_id        number;
    --
    cursor c_person_selection_rl(cv_formula_id number, cv_business_group_id number,
                        cv_effective_date date ) is
      select fff.formula_id
      from ff_formulas_f fff,
           ff_formulas_f fff1
      where fff.business_group_id = cv_business_group_id
        and cv_effective_date between fff.effective_start_date
                                  and fff.effective_end_date
        and fff.formula_name      = fff1.formula_name
        and cv_effective_date between fff1.effective_start_date
                                  and fff1.effective_end_date
        and fff1.formula_id        = cv_formula_id;
    --
    cursor get_per_info (p_person_id number, p_effective_date date) is
    Select ppf.person_id        person_id
        ,paf.assignment_id          assignment_id
        , ppf.original_date_of_hire original_start_date
        , ppf.start_date            latest_start_date
        , ppp.date_start   latest_placement_start_date
        , ppp.projected_termination_date
        /* Changed for bug#7393142
         , DECODE(Ppf.CURRENT_EMPLOYEE_FLAG,'Y',PPS.DATE_START,
                                           DECODE(Ppf.CURRENT_NPW_FLAG,
                                                  'Y',PPP.DATE_START,
                                                   NULL)
                ) Hire_Date
                */
        ,(CASE WHEN ppf.employee_number IS NOT NULL THEN
               pps.date_start
              WHEN ppf.npw_number IS NOT NULL THEN
               ppp.date_start
           END) HIRE_DATE
        ,pps.actual_termination_date actual_termination_date
    from per_all_people_f           ppf
        ,per_all_assignments_f      paf
        ,PER_PERIODS_OF_PLACEMENT   PPP
        ,PER_PERIODS_OF_SERVICE     PPS
    where ppf.person_id = paf.person_id
    and   paf. assignment_type in ('E','B') -- Need to consider Ex-Employee too
    and p_effective_date between
        ppf.effective_start_date and ppf.effective_end_date
    and p_effective_date between
        paf.effective_start_date and paf.effective_end_date
    and ppp.person_id (+) = ppf.person_id
    and ((ppf.employee_number is null)
          or
         (Ppf.EMPLOYEE_NUMBER IS NOT NULL
          AND PPS.DATE_START =
                (SELECT MAX(PPS1.DATE_START)
                 FROM PER_PERIODS_OF_SERVICE PPS1
                 WHERE PPS1.PERSON_ID = Ppf.PERSON_ID
                 AND PPS1.DATE_START <= Ppf.EFFECTIVE_END_DATE)
          )
        )
    AND ((Ppf.NPW_NUMBER IS NULL)
          OR
         (Ppf.NPW_NUMBER IS NOT NULL AND
          PPP.DATE_START =
                (SELECT MAX(PPP1.DATE_START)
                 FROM PER_PERIODS_OF_PLACEMENT PPP1
                 WHERE PPP1.PERSON_ID = Ppf.PERSON_ID
                 AND PPP1.DATE_START <= Ppf.EFFECTIVE_END_DATE
                )
         )
        )
    AND PPS.PERSON_ID (+) = Ppf.PERSON_ID
    and ppf.person_id = p_person_id;
    --
    cursor c_get_ler(cv_business_group_id number,
                     cv_lf_evt_ocrd_dt in date,
                     cv_effective_date in date,
                     cv_pl_id          in number) is
        select ler.ler_id
        from   ben_popl_enrt_typ_cycl_f pet,
           ben_enrt_perd enp,
           ben_ler_f ler
        where  enp.business_group_id  = cv_business_group_id
        and    enp.asnd_lf_evt_dt  = cv_lf_evt_ocrd_dt
        and    enp.popl_enrt_typ_cycl_id = pet.popl_enrt_typ_cycl_id
        and    pet.business_group_id  = enp.business_group_id
        and    cv_effective_date
           between pet.effective_start_date
           and     pet.effective_end_date
        and    ler.typ_cd = 'COMP'
        and    ler.business_group_id  = pet.business_group_id
        and    cv_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
        and    ler.ler_id = enp.ler_id
        and pet.pl_id = cv_pl_id;
    --
    cursor c_get_pil(cv_person_id number,
                 cv_pl_id number,
                 cv_lf_evt_ocrd_dt date,
                 cv_ler_id number,
                 cv_business_group_id number) is
      select pil.per_in_ler_id
      from ben_per_in_ler pil
      where pil.group_pl_id         = cv_pl_id
      and   pil.lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
      and   pil.ler_id        = cv_ler_id
      and   pil.person_id     = cv_person_id
      and   pil.business_group_id = cv_business_group_id
      and   pil.per_in_ler_stat_cd = 'STRTD';
    --
    -- 5232223
    cursor c_elpros_attchd_grp(cv_pl_id number,
                           cv_eff_dt date) is
      select null
      from BEN_PRTN_ELIG_F epa,
           BEN_PRTN_ELIG_PRFL_f cep
      where epa.pl_id = cv_pl_id
        and epa.prtn_elig_id = cep.prtn_elig_id
        and cv_eff_dt between epa.effective_start_date
                          and epa.effective_end_date
        and cv_eff_dt between cep.effective_start_date
                          and cep.effective_end_date;
    -- 5232223
    --
    cursor c_elpros_attchd_loc(cv_pl_id number,
                           cv_eff_dt date) is
    select null
    from BEN_PRTN_ELIG_F epa,
         BEN_PRTN_ELIG_PRFL_f cep,
         ben_pl_f pln
    where pln.group_pl_id = cv_pl_id
    and pln.group_pl_id <> pln.pl_id
    and epa.pl_id = pln.pl_id
      and epa.prtn_elig_id = cep.prtn_elig_id
      and cv_eff_dt between epa.effective_start_date
                        and epa.effective_end_date
      and cv_eff_dt between cep.effective_start_date
                        and cep.effective_end_date;
    -- 5232223
    --
    l_local_ler_id                    number;
    l_local_pil_id                    number;
    l_per_rec                         get_per_info%rowtype;
    l_person_selection_rule_id        number;
    l_audit_log_flag                  varchar2(1) ;
    l_supress_report                  varchar2(1) ;
    l_run_rollup_only                 varchar2(30);
    l_dummy                           number;            -- 5232223
    l_elpro_attcd_grp_pln             boolean := false;  -- 5232223
    l_elpro_attcd_act_pln             boolean := false;  -- 5232223
    --
  begin
    --
    g_debug := hr_utility.debug_enabled;
    --  decide the  sudit log and supress report flag
    l_audit_log_flag  := substr(P_audit_log_flag,1,1) ;
    l_supress_report  := nvl(substr(P_audit_log_flag,2,1),'Y') ;
    l_run_rollup_only := nvl(p_run_rollup_only, 'N');

    --- Value     Log     report
    ---  N         N        Y
    ---  Y         Y        Y
    ---  NN        N        N
    ---  YN        Y        N
    --
    hr_utility.set_location ('Entering  '||l_package,10);
    hr_utility.set_location ('audit log   '||l_audit_log_flag ,10);
    hr_utility.set_location ('supress log   '|| l_supress_report ,10);
    hr_utility.set_location ('process rollup ' || p_run_rollup_only, 10);
    --
    if p_online_call_flag = 'N' then
      --
      fnd_file.put_line(which => fnd_file.log,
                        buff  => 'GLOBAL COMPENSATION PROCESS - SUMMARY lOG');
      fnd_file.put_line(which => fnd_file.log,
                        buff  => '------------------------------------------');
      --
    end if;
    --
    -- Populate ben_cwb_plan_design, it should be committed as 9999 autonmous trxn.
    --
    -- refresh plan design will be smart enough to refresh or not.
    --
    BEN_CWB_PL_DSGN_PKG.refresh_pl_dsgn(p_group_pl_id     => l_pl_id
                          ,p_lf_evt_ocrd_dt => l_lf_evt_ocrd_dt
                          ,p_effective_date => null);
    --
    if nvl(p_online_call_flag, 'N') = 'N'  then
       commit;
    end if;
    --
    -- Bug 4875181 - Submit individual concurrent requests only if Run Rollup Process Only = No
    --
    if l_run_rollup_only = 'N'
    then
       --
       hr_utility.set_location('Entire process', 8888);
       --
       for l_count in c_pln(p_pl_id) loop
         --
         if p_benfts_grp_id is not null then
            --
            open c_benfts_grp(p_benfts_grp_id, l_count.business_group_id);
            fetch c_benfts_grp into l_benfts_grp_id;
            close c_benfts_grp;
            hr_utility.set_location('l_benfts_grp_id = ' || l_benfts_grp_id, 1234);
            --
         end if;
         --
         if p_person_selection_rule_id is not null then
            --
            open c_person_selection_rl(p_person_selection_rule_id,l_count.business_group_id,l_lf_evt_ocrd_dt);
            fetch c_person_selection_rl into l_person_selection_rule_id ;
            close c_person_selection_rl ;
             hr_utility.set_location('l_person_selection_rule_id = '||l_person_selection_rule_id,4321);
            --
         end if;
         --
         if p_trace_plans_flag = 'N' then
           --
           l_request_id := fnd_request.submit_request
             (application => 'BEN',
              program     => 'BENCOMOD',
              description => NULL,
              sub_request => FALSE,
              argument1   => p_benefit_action_id,
              argument2   => p_effective_date,
              argument3   => p_mode,
              argument4   => p_derivable_factors,
              argument5   => p_validate,
              argument6   => p_person_id,
              argument7   => p_pgm_id,
              argument8   => l_count.business_group_id,
              argument9   => l_count.pl_id,
              argument10  => null,
              argument11  => p_lf_evt_ocrd_dt,
              argument12  => p_person_type_id,
              argument13  => p_no_programs,
              argument14  => p_no_plans,
              argument15  => p_comp_selection_rule_id,
              argument16  => l_person_selection_rule_id,
              argument17  => p_ler_id,
              argument18  => p_organization_id,
              argument19  => l_benfts_grp_id,
              argument20  => p_location_id,
              argument21  => p_pstl_zip_rng_id,
              argument22  => p_rptg_grp_id,
              argument23  => p_pl_typ_id,
              argument24  => p_opt_id,
              argument25  => p_eligy_prfl_id,
              argument26  => p_vrbl_rt_prfl_id,
              argument27  => p_legal_entity_id,
              argument28  => p_payroll_id,
              argument29  => p_commit_data,
              argument30  => l_audit_log_flag,
              argument31  => p_lmt_prpnip_by_org_flag,
              argument32  => p_cbr_tmprl_evt_flag,
   	   argument33  => p_cwb_person_type
              );
           --
           commit ;
           --
           ben_manage_cwb_life_events.g_num_cwb_processes :=
                                 ben_manage_cwb_life_events.g_num_cwb_processes + 1;
           ben_manage_cwb_life_events.g_cwb_processes_rec(g_num_cwb_processes) := l_request_id;
           --
             --
             fnd_file.put_line(which => fnd_file.log,
                       buff  => 'Submitted the concurrent request id '||l_request_id||
                                  ' for the plan :'||substr(l_count.name,1,100) );
           --
         else
           if p_online_call_flag = 'N' then
             --
             ben_manage_life_events.cwb_process
             (Errbuf                     =>l_errbuf,
              retcode                    =>l_retcode,
              p_benefit_action_id        =>p_benefit_action_id ,
              p_effective_date           =>p_effective_date,
              p_mode                     =>p_mode,
              p_derivable_factors        =>p_derivable_factors,
              p_validate                 =>p_validate,
              p_person_id                =>p_person_id,
              p_person_type_id           =>p_person_type_id,
              p_pgm_id                   =>p_pgm_id,
              p_business_group_id        =>l_count.business_group_id,
              p_pl_id                    =>l_count.pl_id,
              p_popl_enrt_typ_cycl_id    =>p_popl_enrt_typ_cycl_id,
              p_lf_evt_ocrd_dt           =>p_lf_evt_ocrd_dt,
              p_no_programs              =>p_no_programs,
              p_no_plans                 =>p_no_plans,
              p_comp_selection_rule_id   =>p_comp_selection_rule_id,
              p_person_selection_rule_id =>p_person_selection_rule_id,
              p_ler_id                   =>p_ler_id,
              p_organization_id          =>p_organization_id,
              p_benfts_grp_id            =>l_benfts_grp_id,
              p_location_id              =>p_location_id,
              p_pstl_zip_rng_id          =>p_pstl_zip_rng_id,
              p_rptg_grp_id              =>p_rptg_grp_id,
              p_pl_typ_id                =>p_pl_typ_id,
              p_opt_id                   =>p_opt_id,
              p_eligy_prfl_id            =>p_eligy_prfl_id,
              p_vrbl_rt_prfl_id          =>p_vrbl_rt_prfl_id,
              p_legal_entity_id          =>p_legal_entity_id,
              p_payroll_id               =>p_payroll_id,
              p_commit_data              =>p_commit_data,
              p_audit_log_flag           =>l_audit_log_flag,
              p_lmt_prpnip_by_org_flag   =>p_lmt_prpnip_by_org_flag,
              p_cbr_tmprl_evt_flag       =>p_cbr_tmprl_evt_flag,
   	      p_cwb_person_type          => p_cwb_person_type);
           --
           elsif p_online_call_flag = 'Y'  then
            --
            -- In online mode only process the plans within the business group.
            --
            if l_count.business_group_id = p_business_group_id then
             --
             -- If person exists before lf_evt_ocrd_dt then
             --    To check this can we make use of ORIGINAL_DATE_OF_HIRE, ADJUSTED_SVC_DATE
             --    OR see the cursor get_per_info above.
             -- call the following procedure, otherwise
             -- * Person id must be passed,
             -- * Single person run should not refresh the plan design.
             -- * Clone all the data and clear the rates.
             -- * Check for started pil exists, data to clone exists otherwise do not run person.
             -- * min(per.esd) should be used for all the data determination like manager etc
             -- * Person should be marked as cloned
             -- * If manager is not found what to do?
             -- * If manager and Employee both joined after the lf_evt_ocrd_dt?
             -- * Check all the places in post processes where lf_evt_ocrd_dt is used, it
             -- * should overloaded with persons min(ESD).
             -- *
             if l_per_rec.hire_date is null then
                --
                open get_per_info (p_person_id , l_effective_date);
                fetch get_per_info into l_per_rec;
                hr_utility.set_location('hire dt = ' || l_per_rec.hire_date, 999);
                hr_utility.set_location('leod dt = ' || l_lf_evt_ocrd_dt, 999);
                close get_per_info;
                --
             end if;
             --
             if l_per_rec.hire_date > l_lf_evt_ocrd_dt or
                -- l_per_rec.actual_termination_date < l_lf_evt_ocrd_dt or   -- Changed for bug#7393142
                p_clone_all_data_flag = 'Y'
             then
                --
                hr_utility.set_location('Before call to p_single_per_clone_all_data', 999);
                -- Clone the data for current plan only.
                -- Group plan cloning should happen at the end of the loop.
                --
                l_USE_EFF_DT_FLAG := 'Y';
                p_single_per_clone_all_data(
                                   p_person_id
                                  ,l_count.business_group_id
                                  ,l_ler_id
                                  ,l_effective_date
                                  ,l_lf_evt_ocrd_dt
                                  ,l_count.pl_id
                                  );
                --
             else
                --
                -- If person is already processed for a plan do not process him.
                -- just process the remaining plans within this bg.
                --
                l_local_ler_id := null;
                open c_get_ler(l_count.business_group_id,
                               l_lf_evt_ocrd_dt ,
                               l_effective_date ,
                               l_count.pl_id);
                fetch c_get_ler into l_local_ler_id;
                close c_get_ler;
                --
                -- Find the per in ler id for local plan.
                -- If not found then run the process.
                --
                l_local_pil_id := null;
                open c_get_pil(p_person_id ,
                    l_count.pl_id ,
                    l_lf_evt_ocrd_dt ,
                    l_local_ler_id ,
                    l_count.business_group_id );
                fetch c_get_pil into l_local_pil_id;
                close c_get_pil;
                --
                if l_local_pil_id is null then
                   --
                   ben_on_line_lf_evt.p_manage_life_events
                   (p_person_id             => p_person_id
                   ,p_effective_date        => l_effective_date
                   ,p_business_group_id     => l_count.business_group_id
                   ,p_pgm_id                => null
                   ,p_pl_id                 => l_count.pl_id
                   ,p_mode                  => p_mode
                   ,p_lf_evt_ocrd_dt        => l_lf_evt_ocrd_dt
                   ,p_prog_count            => l_prog_count
                   ,p_plan_count            => l_plan_count
                   ,p_oipl_count            => l_oipl_count
                   ,p_person_count          => l_person_count
                   ,p_plan_nip_count        => l_plan_nip_count
                   ,p_oipl_nip_count        => l_oipl_nip_count
                   ,p_ler_id                => l_ler_id
                   ,p_errbuf                => l_errbuf
                   ,p_retcode               => l_retcode
                   );
                   --
                end if;
                --
             end if;
             --
            end if;
            --
           end if;
           --
         end if ;
         --
       end loop ; -- for each plan linked to group plan.
       --
       if p_trace_plans_flag = 'N'  and nvl(p_online_call_flag, 'N') = 'N' then
          --
          check_all_slaves_finished
            (p_benefit_action_id  => p_benefit_action_id
            ,p_business_group_id  => p_business_group_id
            ,p_slave_errored      => l_slave_errored
           );
          --
       end if;
    --
    end if; /* IF l_run_rollup_only = 'N' */
    --
    savepoint cwb_global_process;       /* Bug 4875181 */
    --
    begin
      --
      -- Populate group plan cache.
      --
      g_error_log_rec.calling_proc := 'get_group_plan_info';
      g_error_log_rec.step_number := 1;
      --
      ben_manage_cwb_life_events.get_group_plan_info(
        p_group_pl_id                    => l_pl_id
        ,p_lf_evt_ocrd_dt          => l_lf_evt_ocrd_dt
        ,p_pl_id                   => null
      );
      --
      --
      if g_cache_group_plan_rec.group_ler_id is not null then
        --
        --Populate Missing Group Plan Information
        --
        fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Started : Populating group plan data, ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
        hr_utility.set_location('global_process - before call to cwb_group_pil', 1234);
        if l_use_eff_dt_flag = 'N' then
           --
           g_error_log_rec.calling_proc := 'popu_cwb_group_pil_data';
           g_error_log_rec.step_number := 2;
           --
           ben_manage_cwb_life_events.popu_cwb_group_pil_data (
             p_group_per_in_ler_id     => -9999
             ,p_group_pl_id             => g_cache_group_plan_rec.group_pl_id
             ,p_group_lf_evt_ocrd_dt    => g_cache_group_plan_rec.group_lf_evt_ocrd_dt
             ,p_group_business_group_id => g_cache_group_plan_rec.group_business_group_id
             ,p_group_ler_id            => g_cache_group_plan_rec.group_ler_id );
        else
           --
           -- In case of single person run and clone all the data
           -- clone ben_cwb_person_group data out side of
           -- popu_cwb_group_pil_data for persons outside the group plan's
           -- business group. This is to avoid cloning of data for managers.
           --
           if ben_manage_cwb_life_events.g_cache_group_plan_rec.group_per_in_ler_id is null
           then
              --
              g_error_log_rec.calling_proc := 'p_single_per_clone_all_data';
              g_error_log_rec.step_number := 3;
              p_single_per_clone_all_data(
                                p_person_id
                               ,g_cache_group_plan_rec.group_business_group_id
                               ,g_cache_group_plan_rec.group_ler_id
                               ,l_effective_date
                               ,g_cache_group_plan_rec.group_lf_evt_ocrd_dt
                               ,g_cache_group_plan_rec.group_pl_id
                               ,'Y' -- for p_clone_only_cpg
                               );
              --
           end if;
           --
           g_error_log_rec.calling_proc := 'popu_cwb_group_pil_data';
           g_error_log_rec.step_number := 4;
           --
           ben_manage_cwb_life_events.popu_cwb_group_pil_data (
             p_group_per_in_ler_id     => -9999
             ,p_group_pl_id             => g_cache_group_plan_rec.group_pl_id
             ,p_group_lf_evt_ocrd_dt    => g_cache_group_plan_rec.group_lf_evt_ocrd_dt
             ,p_group_business_group_id => g_cache_group_plan_rec.group_business_group_id
             ,p_group_ler_id            => g_cache_group_plan_rec.group_ler_id
             ,p_use_eff_dt_flag         => l_use_eff_dt_flag
             ,p_effective_date          => l_effective_date
           );
        end if;
        --
        fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Completed : Populating group plan data, ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
        --
        --Populate Group Hierarchy table data
        --
        g_error_log_rec.calling_proc := 'popu_group_pil_heir';
        g_error_log_rec.step_number := 4;
           --
        ben_manage_cwb_life_events.popu_group_pil_heir(
          p_group_pl_id             => g_cache_group_plan_rec.group_pl_id
         ,p_group_lf_evt_ocrd_dt    => g_cache_group_plan_rec.group_lf_evt_ocrd_dt
         ,p_group_business_group_id => g_cache_group_plan_rec.group_business_group_id
         ,p_group_ler_id            => g_cache_group_plan_rec.group_ler_id  ) ;
        --
        fnd_file.put_line(which => fnd_file.log,
                    -- buff  => 'Completed : Populating heirarchy data, ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
		    buff  => 'Completed : Populating hierarchy data, ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
		    -- changed for bug: 5134561
        --
        -- Add del_all_cwb_pils here to handle if the elpros are not attached
        -- to group plan but attached to actual plan and track inelig flag
        -- on group plan set to N.
        --
        -- 5232223
        Open c_elpros_attchd_grp(g_cache_group_plan_rec.group_pl_id,
                                 g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
        fetch c_elpros_attchd_grp into l_dummy;
        if c_elpros_attchd_grp%FOUND then
          l_elpro_attcd_grp_pln := TRUE;
        else
          l_elpro_attcd_grp_pln := FALSE;
        end if;
        Close c_elpros_attchd_grp;
        --
        Open c_elpros_attchd_loc(g_cache_group_plan_rec.group_pl_id,
                                 g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
        fetch c_elpros_attchd_loc into l_dummy;
        if c_elpros_attchd_loc%FOUND then
          l_elpro_attcd_act_pln := TRUE;
        else
          l_elpro_attcd_act_pln := FALSE;
        end if;
        close c_elpros_attchd_loc;
        --
        hr_utility.set_location('trk_inelg ->'|| g_cache_group_plan_rec.trk_inelig_per_flag,99);
        --
        if   NOT l_elpro_attcd_grp_pln
         and l_elpro_attcd_act_pln
         and g_cache_group_plan_rec.trk_inelig_per_flag = 'N' then
            --
            del_all_cwb_pils(
               p_group_pl_id          => g_cache_group_plan_rec.group_pl_id,
               p_group_ler_id         => g_cache_group_plan_rec.group_ler_id,
               p_group_lf_evt_ocrd_dt => g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
            --
        end if;
        -- 5232223

        if g_cache_group_plan_rec.uses_bdgt_flag = 'Y' then
           --
           g_error_log_rec.calling_proc := 'auto_allocate_budgets';
           g_error_log_rec.step_number := 5;
           --
           ben_manage_cwb_life_events.auto_allocate_budgets (
            p_group_pl_id    => g_cache_group_plan_rec.group_pl_id
           ,p_lf_evt_ocrd_dt => g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
           --
        end if;
        --
        -- Populate ben_cwb_xchg table.
        --
        g_error_log_rec.calling_proc := 'insert_into_ben_cwb_xchg';
        g_error_log_rec.step_number := 6;
        --
        ben_cwb_xchg_pkg.insert_into_ben_cwb_xchg(
            p_group_pl_id    => g_cache_group_plan_rec.group_pl_id
           ,p_lf_evt_ocrd_dt => g_cache_group_plan_rec.group_lf_evt_ocrd_dt
           ,p_effective_date => null
           ,p_refresh_always => 'N');
        --
        -- Populate ben_cwb_summary table.
        --
        g_error_log_rec.calling_proc := 'refresh_summary_persons';
        g_error_log_rec.step_number := 7;
        --
        BEN_CWB_SUMMARY_PKG.refresh_summary_persons(
            p_group_pl_id    => g_cache_group_plan_rec.group_pl_id
           ,p_lf_evt_ocrd_dt => g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
        --
        fnd_file.put_line(which => fnd_file.log,
                    -- buff  => 'Completed : Populating heirarchy data, ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
		    buff  => 'Completed : Populating hierarchy data, ' || to_char(sysdate,'dd-mm-yyyy hh24:mi:ss'));
		    -- changed for bug: 5134561
        --
      end if;
      --
      --
      -- RECUR
      --
      -- Now try to log the information about the recursive heirarchy.
      --
      declare
        l_hrchy_counter number := 0;
        l_loop_counter  number;
      begin
        l_hrchy_counter := nvl(g_hrchy_tbl.LAST, 0);
        if l_hrchy_counter > 0 then
           --
           fnd_file.put_line(which => fnd_file.log,
                    buff  => 'A recursive relationship was detected in the manager hierarchy. '||
                             'You can correct the hierarchy data by updating the worksheet manager '||
                             'on the employee administration page for each person ID listed. '||
                             'You should also fix the problem at its HR source and refresh the '||
                             'summary using Refresh Job.  The list of person ID''s are reported below. ');
                             -- Text for BEN_94537_REC_REPORTING changed, hence this text is also changed.
                           /*
                            'Employee hierarchy has recursive reporting. You can correct the hierarchy data '||
                            'by using employee reassignment or correct the HR data. Then rerun the Single '||
                            'Person process and refresh the summary using Refresh Job. '||
                            'List of person id''s reported below.');
                            */
           l_loop_counter := least(l_hrchy_counter, 100);
           if l_hrchy_counter > 100 then
              --
              fnd_file.put_line(which => fnd_file.log,
                    buff  => 'Also query the ben_trasactions table to see complete list.');
              --
              for i in 1..l_hrchy_counter loop

                   INSERT INTO ben_transaction
                     (transaction_id
                     ,transaction_type
                     ,attribute1
                     ,ATTRIBUTE40)
                   VALUES (ben_transaction_s.NEXTVAL
                     ,'CWBRECURHIER'
                     ,to_char(fnd_global.conc_request_id)
                     ,g_hrchy_tbl(i).hrchy_cat_string);

              end loop;
           end if;
           --
           for i in 1..l_loop_counter loop
               fnd_file.put_line(which => fnd_file.log,
                    buff  => '  ' ||g_hrchy_tbl(i).hrchy_cat_string);
           end loop;
           --
        end if;
      exception when others then
           fnd_file.put_line(which => fnd_file.log,
                    buff  =>'A recursive relationship was detected in the manager hierarchy. '||
                             'You can correct the hierarchy data by updating the worksheet manager '||
                             'on the employee administration page for each person ID listed. '||
                             'You should also fix the problem at its HR source and refresh the '||
                             'summary using Refresh Job.  The list of person ID''s are reported below. ');
                             -- Text for BEN_94537_REC_REPORTING changed, hence this text is also changed.
                            /* 'Employee hierarchy has recursive reporting. You can correct the hierarchy data '||
                            'by using employee reassignment or correct the HR data. Then rerun the Single '||
                            'Person process and refresh the summary using Refresh Job. '||
                            'List of person id''s reported below.');
                            */

        null;
      end;
      -- RECUR
      --
    exception when others then
      --
      --
      -- Spawn the reports at the end.
      --
      if nvl(ben_manage_cwb_life_events.g_num_cwb_processes, 0) <> 0
      then
        --
         fnd_file.put_line(which => fnd_file.log,
                           buff  => 'An error occurred in the rollup routine. After fixing the ' ||
                                    'errors, please submit the process again with Run Rollup processes ' ||
                                    'only set to Yes.'
                           );
         --
         if l_supress_report  = 'Y'
         then
             --
             rollback to cwb_global_process;
             --
             for elenum in 1..ben_manage_cwb_life_events.g_num_cwb_processes
             loop
               --
               ben_batch_reporting.batch_reports
               (p_concurrent_request_id => ben_manage_cwb_life_events.g_cwb_processes_rec(elenum),
                p_mode                  => 'W',
                p_report_type           => 'ACTIVITY_SUMMARY');
               --
               ben_batch_reporting.batch_reports
                 (p_concurrent_request_id => ben_manage_cwb_life_events.g_cwb_processes_rec(elenum),
                  p_report_type           => 'ERROR_BY_PERSON');
               --
             end loop;
             --
             commit;         /* Bug 4875181 - This was required otherwise the error and summary report
                                              concurrent requests dont get committed
                              */
             --
         end if;
      end if ;
      --
      raise ;
      --
    end;
    --
    -- Spawn the reports at the end.
    --
    g_error_log_rec.calling_proc := 'Before Reports';
    g_error_log_rec.step_number := 8;
    --
    if nvl(ben_manage_cwb_life_events.g_num_cwb_processes, 0) <> 0
    then
    --
      if l_supress_report  = 'Y' then
         for elenum in 1..ben_manage_cwb_life_events.g_num_cwb_processes
         loop
           --
           ben_batch_reporting.batch_reports
           (p_concurrent_request_id => ben_manage_cwb_life_events.g_cwb_processes_rec(elenum),
            p_mode                  => 'W',
            p_report_type           => 'ACTIVITY_SUMMARY');
           --
           ben_batch_reporting.batch_reports
             (p_concurrent_request_id => ben_manage_cwb_life_events.g_cwb_processes_rec(elenum),
                 p_report_type           => 'ERROR_BY_PERSON');
           --
         end loop;
       end if;
    end if ;
    --
  exception when others then
    --
    if nvl(p_online_call_flag, 'N') = 'N'  then
      --
      -- Write into log only if not a online process.
      -- Bug 4636102. The fnd_message.get was killing
      -- the error even for online mode.
      --
      fnd_file.put_line(which => fnd_file.log,
                      buff  => 'Error occured after calling:  ' ||
                                g_error_log_rec.calling_proc);
      fnd_file.put_line(which => fnd_file.log,
                      buff  => '                Step Number:  ' ||
                                to_number(g_error_log_rec.step_number));
      fnd_file.put_line(which => fnd_file.log,
                      buff  => '                     Error :  ' ||
                                nvl(fnd_message.get,sqlerrm));
    end if;
    --
    fnd_message.raise_error;
    --
  end global_process;
  --
  -- Procedure to populate ben_cwb_person_rates, ben_cwb_person_groups.
  --
  procedure populate_cwb_rates(
           --
           -- Columns needed for ben_cwb_person_rates
           --
           p_person_id        in     number
          ,p_assignment_id    in     number   default null
          ,p_organization_id  in     number   default null
          ,p_pl_id            in     number
          ,p_oipl_id          in     number   default null
          ,p_opt_id           in     number   default null
          ,p_ler_id           in     number   default null
          ,p_business_group_id in    number   default null
          ,p_acty_base_rt_id   in    number   default null
          ,p_elig_flag        in     varchar2 default 'Y'
          ,p_inelig_rsn_cd    in     varchar2 default null
          --
          -- Columns needed by BEN_CWB_PERSON_GROUPS
          --
          ,p_due_dt           in     date     default null
          ,p_access_cd        in     varchar2 default null
          ,p_elig_per_elctbl_chc_id in number   default null
          ,p_no_person_rates  in     varchar2 default null
          ,p_no_person_groups in     varchar2 default null
          ,p_currency_det_cd  in     varchar2 default null
          ,p_element_det_rl   in     number   default null
          ,p_base_element_type_id in number   default null
       ) is
  --
  -- 9999 cache this data and use it.
  --
  cursor c_group_oipl(cv_lf_evt_ocrd_dt in date) is
    select group_oipl.oipl_id
    from ben_oipl_f oipl
        ,ben_oipl_f group_oipl
        ,ben_pl_f pl
        ,ben_opt_f opt
    where oipl.oipl_id = p_oipl_id
    and    oipl.opt_id = opt.opt_id
    and    opt.group_opt_id = group_oipl.opt_id
    and    group_oipl.pl_id = pl.group_pl_id
    and    pl.pl_id = oipl.pl_id
    and    cv_lf_evt_ocrd_dt between oipl.effective_start_date
                                 and oipl.effective_end_date
    and    cv_lf_evt_ocrd_dt between group_oipl.effective_start_date
                                 and group_oipl.effective_end_date
    and    cv_lf_evt_ocrd_dt between pl.effective_start_date
                                 and pl.effective_end_date
    and    cv_lf_evt_ocrd_dt between opt.effective_start_date
                                 and opt.effective_end_date;
  --
  cursor c_epe(cv_elig_per_elctbl_chc_id in number) is
    select elig_flag, inelig_rsn_cd
    from ben_elig_per_elctbl_chc
    where elig_per_elctbl_chc_id = cv_elig_per_elctbl_chc_id;
  --
  l_oipl_id         number;
  l_group_oipl_id   number;
  l_inelig_rsn_cd   varchar2(80);
  l_elig_flag       varchar2(80);
  l_element_type_id number;
  l_input_value_id  number;
  l_currency_cd     varchar2(80);
  l_package         varchar2(80) := g_package||'.populate_cwb_rates' ;
  --
 begin
  --
  if g_debug then
      hr_utility.set_location ('Entering  :' || l_package,10);
  end if;
  --
  if p_pl_id = g_cache_group_plan_rec.group_pl_id then
     --
     -- Populate BEN_CWB_PERSON_GROUPS
     -- Primary Key: GROUP_PER_IN_LER_ID, GROUP_PL_ID, GROUP_OIPL_ID
     --
     if g_debug then
        hr_utility.set_location ('Group rate  ' ,15);
     end if;
     --
     /* Bug 3510081
     if g_cwb_person_groups_rec.ws_bdgt_val is not null
        and g_cache_group_plan_rec.auto_distr_flag = 'Y'
     then
       g_cwb_person_groups_rec.ws_bdgt_iss_val :=
                               g_cwb_person_groups_rec.ws_bdgt_val;
       g_cwb_person_groups_rec.ws_bdgt_iss_date :=
                               g_cache_group_plan_rec.group_lf_evt_ocrd_dt;
     end if;
     */
     --
     -- Bug 3510081 : Populate dflt values irrespective of auto_distr_flag.
     --
     g_cwb_person_groups_rec.dflt_ws_bdgt_val :=
                               g_cwb_person_groups_rec.ws_bdgt_val;
     g_cwb_person_groups_rec.dflt_dist_bdgt_val :=
                               g_cwb_person_groups_rec.dist_bdgt_val;
     --
     --
     -- Find the group_oipl_id
     --
     open c_group_oipl(g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
     fetch c_group_oipl into l_group_oipl_id;
     close c_group_oipl;
     --
     insert into ben_cwb_person_groups
       (group_per_in_ler_id,
        group_pl_id        ,
        group_oipl_id      ,
        lf_evt_ocrd_dt     ,
        bdgt_pop_cd        ,
        due_dt             ,
        access_cd          ,
        approval_cd        ,
        approval_date      ,
        approval_comments  ,
        submit_cd          ,
        submit_date        ,
        submit_comments    ,
        dist_bdgt_val      ,
        ws_bdgt_val        ,
        -- Bug 3510081 New columns need to be populated.
        dflt_dist_bdgt_val      ,
        dflt_ws_bdgt_val        ,
        rsrv_val           ,
        dist_bdgt_mn_val   ,
        dist_bdgt_mx_val   ,
        dist_bdgt_incr_val ,
        ws_bdgt_mn_val     ,
        ws_bdgt_mx_val     ,
        ws_bdgt_incr_val   ,
        rsrv_mn_val        ,
        rsrv_mx_val        ,
        rsrv_incr_val      ,
        dist_bdgt_iss_val  ,
        ws_bdgt_iss_val    ,
        dist_bdgt_iss_date ,
        ws_bdgt_iss_date   ,
        ws_bdgt_val_last_upd_date ,
        dist_bdgt_val_last_upd_date  ,
        rsrv_val_last_upd_date       ,
        ws_bdgt_val_last_upd_by      ,
        dist_bdgt_val_last_upd_by    ,
        rsrv_val_last_upd_by         ,
        object_version_number        ,
        last_update_date         ,
        last_updated_by          ,
        last_update_login        ,
        created_by               ,
        creation_date
     ) values (
        g_cache_group_plan_rec.group_per_in_ler_id,
        g_cache_group_plan_rec.group_pl_id        ,
        nvl(l_group_oipl_id, -1) ,
        g_cache_group_plan_rec.group_lf_evt_ocrd_dt     ,
        null,  --  bdgt_pop_cd
        nvl(p_due_dt,g_cache_group_plan_rec.ws_upd_end_dt),  -- this can go as null
        g_cache_group_plan_rec.access_cd,
        null,  -- approval_cd
        null,  -- approval_date
        null,  -- approval_comments
        'NS',  -- submit_cd
        null,  -- submit_date
        null,  -- submit_comments
        --
        -- Bug 3510081 : No need to populate the budget values here.
        -- Need to verify whether other values need to be populated or not.
        --
        null, -- g_cwb_person_groups_rec.dist_bdgt_val      ,
        null, -- g_cwb_person_groups_rec.ws_bdgt_val        ,
        g_cwb_person_groups_rec.dflt_dist_bdgt_val      ,
        g_cwb_person_groups_rec.dflt_ws_bdgt_val        ,
        g_cwb_person_groups_rec.rsrv_val           ,
        g_cwb_person_groups_rec.dist_bdgt_mn_val   ,
        g_cwb_person_groups_rec.dist_bdgt_mx_val   ,
        g_cwb_person_groups_rec.dist_bdgt_incr_val ,
        g_cwb_person_groups_rec.ws_bdgt_mn_val     ,
        g_cwb_person_groups_rec.ws_bdgt_mx_val     ,
        g_cwb_person_groups_rec.ws_bdgt_incr_val   ,
        g_cwb_person_groups_rec.rsrv_mn_val        ,
        g_cwb_person_groups_rec.rsrv_mx_val        ,
        g_cwb_person_groups_rec.rsrv_incr_val      ,
        --
        -- Bug 3510081 : No need to populate the budget values here.
        -- Need to verify whether other values need to be populated or not.
        --
        null, -- g_cwb_person_groups_rec.dist_bdgt_iss_val  ,
        null, -- g_cwb_person_groups_rec.ws_bdgt_iss_val    ,
        null, -- g_cwb_person_groups_rec.dist_bdgt_iss_date ,
        null, -- g_cwb_person_groups_rec.ws_bdgt_iss_date   ,
        g_cwb_person_groups_rec.ws_bdgt_val_last_upd_date ,
        g_cwb_person_groups_rec.dist_bdgt_val_last_upd_date  ,
        g_cwb_person_groups_rec.rsrv_val_last_upd_date       ,
        g_cwb_person_groups_rec.ws_bdgt_val_last_upd_by      ,
        g_cwb_person_groups_rec.dist_bdgt_val_last_upd_by    ,
        g_cwb_person_groups_rec.rsrv_val_last_upd_by         ,
        1, -- object_version_number
        -- Check all the column values.
        g_cwb_person_groups_rec.last_update_date         ,
        g_cwb_person_groups_rec.last_updated_by          ,
        g_cwb_person_groups_rec.last_update_login        ,
        g_cwb_person_groups_rec.created_by               ,
        g_cwb_person_groups_rec.creation_date
     ) ;

  end if;
  --
  --  Populate
  --  BEN_CWB_PERSON_RATES
  --    Primary Key: PERSON_RATE_ID
  --
  if ((p_pl_id = g_cache_group_plan_rec.group_pl_id and
       g_cache_group_plan_rec.plans_wthn_group_pl = 1
      ) OR
      (p_pl_id <> g_cache_group_plan_rec.group_pl_id)
     ) -- and (nvl(p_no_person_rates, 'N') = 'N')
  then
    --
    if g_debug then
       hr_utility.set_location ('Person rate  ' ,15);
    end if;
    --
    -- Find the group_oipl_id
    --
    open c_group_oipl(g_cache_group_plan_rec.group_lf_evt_ocrd_dt);
    fetch c_group_oipl into l_group_oipl_id;
    close c_group_oipl;
    --
    -- get the elig_flag and inelg_rsn_cd
    --
    -- 9999 these columns can be put into epe cache later.
    open c_epe(p_elig_per_elctbl_chc_id);
    fetch c_epe into l_elig_flag, l_inelig_rsn_cd;
    close c_epe;
    --
    -- Multi currency support
    --
    determine_curr_code
      (p_element_det_rl           => p_element_det_rl,
       p_acty_base_rt_id          => p_acty_base_rt_id,
       p_currency_det_cd          => p_currency_det_cd,
       p_base_element_type_id     => p_base_element_type_id,
       p_effective_date           => g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
       p_assignment_id            => p_assignment_id,
       p_organization_id          => p_organization_id,
       p_business_group_id        => p_business_group_id,
       p_pl_id                    => p_pl_id,
       p_opt_id                   => p_opt_id,
       p_ler_id                   => p_ler_id,
       p_element_type_id          => l_element_type_id,
       p_input_value_id           => l_input_value_id,
       p_currency_cd              => l_currency_cd);
    --
    if g_debug then
    hr_utility.set_location ('Person rate GROUP_PER_IN_LER_ID ' || g_cache_group_plan_rec.group_per_in_ler_id,15);
    hr_utility.set_location ('Person rate PERSON_ID ' || p_person_id ,15);
    hr_utility.set_location ('Person rate PL_ID ' || p_pl_id,15);
    hr_utility.set_location ('Person rate GROUP_PL_ID ' || g_cache_group_plan_rec.group_pl_id,15);
    hr_utility.set_location ('Person rate LF_EVT_OCRD_DT ' || g_cache_group_plan_rec.group_lf_evt_ocrd_dt,15);
    end if;

    insert into ben_cwb_person_rates
     (person_rate_id                   ,
      group_per_in_ler_id              ,
      pl_id                            ,
      oipl_id                          ,
      group_pl_id                      ,
      group_oipl_id                    ,
      lf_evt_ocrd_dt                   ,
      person_id                        ,
      assignment_id                    ,
      elig_flag                        ,
      ws_val                           ,
      ws_mn_val                        ,
      ws_mx_val                        ,
      ws_incr_val                      ,
      elig_sal_val                     ,
      stat_sal_val                     ,
      oth_comp_val                     ,
      tot_comp_val                     ,
      misc1_val                        ,
      misc2_val                        ,
      misc3_val                        ,
      rec_val                          ,
      rec_mn_val                       ,
      rec_mx_val                       ,
      rec_incr_val                     ,
      ws_val_last_upd_date             ,
      ws_val_last_upd_by               ,
      pay_proposal_id                  ,
      element_entry_value_id           ,
      inelig_rsn_cd                    ,
      elig_ovrid_dt                    ,
      elig_ovrid_person_id             ,
      copy_dist_bdgt_val               ,
      copy_ws_bdgt_val                 ,
      copy_rsrv_val                    ,
      copy_dist_bdgt_mn_val            ,
      copy_dist_bdgt_mx_val            ,
      copy_dist_bdgt_incr_val          ,
      copy_ws_bdgt_mn_val              ,
      copy_ws_bdgt_mx_val              ,
      copy_ws_bdgt_incr_val            ,
      copy_rsrv_mn_val                 ,
      copy_rsrv_mx_val                 ,
      copy_rsrv_incr_val               ,
      copy_dist_bdgt_iss_val           ,
      copy_ws_bdgt_iss_val             ,
      copy_dist_bdgt_iss_date          ,
      copy_ws_bdgt_iss_date            ,
      COMP_POSTING_DATE                ,
      WS_RT_START_DATE                 ,
      currency                         ,
      object_version_number            ,
      last_update_date                 ,
      last_updated_by                  ,
      last_update_login                ,
      created_by                       ,
      creation_date
     ) values
     (ben_cwb_person_rates_s.nextval   ,
      nvl(g_cache_group_plan_rec.group_per_in_ler_id, -1)         ,
      p_pl_id                            ,
      nvl(p_oipl_id, -1),
      g_cache_group_plan_rec.group_pl_id                      ,
      nvl(l_group_oipl_id, -1), -- group_oipl_id                    ,
      g_cache_group_plan_rec.group_lf_evt_ocrd_dt                   ,
      p_person_id                        ,
      p_assignment_id                    ,
      l_elig_flag                        ,
      g_cwb_person_rates_rec.ws_val                           ,
      g_cwb_person_rates_rec.ws_mn_val                        ,
      g_cwb_person_rates_rec.ws_mx_val                        ,
      g_cwb_person_rates_rec.ws_incr_val                      ,
      g_cwb_person_rates_rec.elig_sal_val                     ,
      g_cwb_person_rates_rec.stat_sal_val                     ,
      g_cwb_person_rates_rec.oth_comp_val                     ,
      g_cwb_person_rates_rec.tot_comp_val                     ,
      g_cwb_person_rates_rec.misc1_val                        ,
      g_cwb_person_rates_rec.misc2_val                        ,
      g_cwb_person_rates_rec.misc3_val                        ,
      g_cwb_person_rates_rec.rec_val                          ,
      g_cwb_person_rates_rec.rec_mn_val                       ,
      g_cwb_person_rates_rec.rec_mx_val                       ,
      g_cwb_person_rates_rec.rec_incr_val                     ,
      g_cwb_person_rates_rec.ws_val_last_upd_date             ,
      g_cwb_person_rates_rec.ws_val_last_upd_by               ,
      g_cwb_person_rates_rec.pay_proposal_id                  ,
      g_cwb_person_rates_rec.element_entry_value_id           ,
      l_inelig_rsn_cd                    ,
      g_cwb_person_rates_rec.elig_ovrid_dt                    ,
      g_cwb_person_rates_rec.elig_ovrid_person_id             ,
      g_cwb_person_rates_rec.copy_dist_bdgt_val               ,
      g_cwb_person_rates_rec.copy_ws_bdgt_val                 ,
      g_cwb_person_rates_rec.copy_rsrv_val                    ,
      g_cwb_person_rates_rec.copy_dist_bdgt_mn_val            ,
      g_cwb_person_rates_rec.copy_dist_bdgt_mx_val            ,
      g_cwb_person_rates_rec.copy_dist_bdgt_incr_val          ,
      g_cwb_person_rates_rec.copy_ws_bdgt_mn_val              ,
      g_cwb_person_rates_rec.copy_ws_bdgt_mx_val              ,
      g_cwb_person_rates_rec.copy_ws_bdgt_incr_val            ,
      g_cwb_person_rates_rec.copy_rsrv_mn_val                 ,
      g_cwb_person_rates_rec.copy_rsrv_mx_val                 ,
      g_cwb_person_rates_rec.copy_rsrv_incr_val               ,
      g_cwb_person_rates_rec.copy_dist_bdgt_iss_val           ,
      g_cwb_person_rates_rec.copy_ws_bdgt_iss_val             ,
      g_cwb_person_rates_rec.copy_dist_bdgt_iss_date          ,
      g_cwb_person_rates_rec.copy_ws_bdgt_iss_date            ,
      g_cwb_person_rates_rec.COMP_POSTING_DATE,
      g_cwb_person_rates_rec.WS_RT_START_DATE,
      l_currency_cd                                           ,
      1, -- object_version_number            ,
      g_cwb_person_rates_rec.last_update_date                 ,
      g_cwb_person_rates_rec.last_updated_by                  ,
      g_cwb_person_rates_rec.last_update_login                ,
      g_cwb_person_rates_rec.created_by                       ,
      g_cwb_person_rates_rec.creation_date                  );
    --
   end if;
   --
  if g_debug then
      hr_utility.set_location ('Leaving  :' || l_package,10);
  end if;
  --
 end populate_cwb_rates;
 --
 procedure rebuild_heirarchy
          (p_group_per_in_ler_id in number ) is
    --
    l_package    varchar2(80) := g_package||'.rebuild_heirarchy' ;
    -- Bug 2574791
    cursor c_pil is
      select pil.group_pl_id,
             pil.lf_evt_ocrd_dt,
             pil.business_group_id,
             pil.ler_id
        from ben_per_in_ler pil
       where pil.per_in_ler_id = p_group_per_in_ler_id ;
    --
    l_ler_id  number ;
 begin
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location ('Entering  :' || l_package,10);
    end if;
    --
    -- Steps
    --
    -- 1. create pil,-1,-1 record for the p_per_in_ler_id.
    -- 2. create pil,-1,-1 records for
    --    empoyees whose mgr_pil is = to  per_in_ler_id.
    -- 3. Delete all records from hierarchy table of the managers of the
    --    p_per_in_ler_id and the employees reporting to this
    --    p_per_in_ler_id.
    -- 4. call the popu_pil_heir to rebuild the table.
    --
    -- 5. When the first direct reportee is added to a new Manager
    --    we need two insert a mgr_pil,0,0 with level 1
    --
   if p_group_per_in_ler_id is not null then
    --
    open c_pil;
    fetch c_pil into g_rebuild_pl_id,
                     g_rebuild_lf_evt_ocrd_dt,
                     g_rebuild_business_group_id,
                     l_ler_id ;
    close c_pil;

    if g_debug then
      hr_utility.set_location ('Before Step 1',20);
    end if;
    --
    -- Step 1
    begin
      --
      insert into ben_cwb_group_hrchy (
         emp_per_in_ler_id,
         mgr_per_in_ler_id,
         lvl_num  )
      values (
         p_group_per_in_ler_id,
         -1,
         -1 );
      --
    exception when no_data_found then
      --
      null;
      --
    when others then
      --
      null; -- raise ;
      --
    end;
    --
    if g_debug then
      hr_utility.set_location ('After Step 1',20);
      --
      hr_utility.set_location ('Before Step 2 ',20);
    end if;
    --
    --Step 2
    -- Don't insert for the pil,0,0 record since it is
    -- Already handled in Step 1 above.
    --
    declare

      cursor c_emp_repo is
        select emp_per_in_ler_id
          from ben_cwb_group_hrchy
         where mgr_per_in_ler_id = p_group_per_in_ler_id
           and lvl_num > 0 ;
      --
    begin
      --
      for r_emp_repo in c_emp_repo loop
        --
        begin

          insert into ben_cwb_group_hrchy (
           emp_per_in_ler_id,
           mgr_per_in_ler_id,
           lvl_num  )  values (r_emp_repo.emp_per_in_ler_id, -1, -1);
          --
        exception when others then
          null;
        end;
      end loop;
      --
    exception when no_data_found then
      --
      null;
      --
    when others then
    --
    raise ;
    --
    end;
    --
    if g_debug then
      hr_utility.set_location ('After Step 2 ',20);
      --
      hr_utility.set_location ('Before Step 3 ',20);
    end if;
    --
    begin
      --
      --First Delete the Manager's own Hierarchy
      --
      delete from ben_cwb_group_hrchy
      where emp_per_in_ler_id = p_group_per_in_ler_id
      and lvl_num >= 0;
      --
      -- Now delete the Employees reporting to this manager(if he is a manager).
      --
      delete from ben_cwb_group_hrchy
      where emp_per_in_ler_id in (
                select emp_per_in_ler_id
                from ben_cwb_group_hrchy
                where mgr_per_in_ler_id = p_group_per_in_ler_id )
      and lvl_num >= 0;
      --
    exception when others then
      --
      raise ;
      --
    end;
    --
    if g_debug then
      hr_utility.set_location ('After  Step 3 ',20);
      --
      hr_utility.set_location ('Before Calling popu_pel_heir',20);
    end if;
    --
    begin
      --
      ben_manage_cwb_life_events.popu_group_pil_heir(
                        g_rebuild_pl_id,
                        g_rebuild_lf_evt_ocrd_dt,
                        g_rebuild_business_group_id,
                        l_ler_id  ) ;
      --
    exception when others then
      --
      raise ;
      --
    end;
    --
    if g_debug then
      hr_utility.set_location ('Before Step 5',20);
    end if;
    --
    begin
      --
      insert into ben_cwb_group_hrchy(
       emp_per_in_ler_id,
       mgr_per_in_ler_id,
       lvl_num  )
      select
       distinct emp_per_in_ler_id,
       emp_per_in_ler_id,
       0
      from ben_cwb_group_hrchy cwb1
      where emp_per_in_ler_id =
                   ( select mgr_per_in_ler_id from ben_cwb_group_hrchy
                     where emp_per_in_ler_id = p_group_per_in_ler_id
                     and lvl_num = 1 )
      and not exists ( select null from ben_cwb_group_hrchy cwb2
                     where cwb1.emp_per_in_ler_id = cwb2.emp_per_in_ler_id
                     and lvl_num  = 0 ) ;
      --
    exception when no_data_found then
      --
      null;
      --
    when others then
      --
      raise ;
      --
    end;
    --
    /* PERF 4587770 can get rid of not exists by suppressing when others,
      -- move the sub query into main query.
      -- Waiting for GSI to validate. Once validated at gsi db, following code
      -- can replace above insert.
      --
      insert into ben_cwb_group_hrchy(
        emp_per_in_ler_id,
        mgr_per_in_ler_id,
        lvl_num  )
       select
       h.mgr_per_in_ler_id
       ,h.mgr_per_in_ler_id
       ,0
       from ben_cwb_group_hrchy h
       where h.emp_per_in_ler_id = p_group_per_in_ler_id
       and h.lvl_num = 1;
    --
    exception when others then
      --
      null ;
      --
    end;
    */
    --
    -- Bug 2574791
    g_rebuild_pl_id            := null;
    g_rebuild_lf_evt_ocrd_dt   := null;
    g_rebuild_business_group_id := null;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Afert Step 5',20);
    hr_utility.set_location ('After Calling popu_pil_heir',20);
    hr_utility.set_location ('Leaving : rebuild_heirarchy',30);
  end if;
  --
  --
end rebuild_heirarchy ;
--
procedure popu_missing_person_pil (
                        p_mode                in varchar2,
                        p_person_id           in number,
                        p_group_per_in_ler_id in number,
                        p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number,
                        p_use_eff_dt_flag      in varchar2 default 'N',
                        p_effective_date       in date default null) is
   --
   l_proc varchar2(72) := g_package||'.popu_missing_person_pil';
   --
   -- 9999 check whether person id is populated in ben_cwb_person_rates.
   --
   CURSOR c_person_rates
    (c_person_id                IN NUMBER
    ,c_group_lf_evt_ocrd_dt     IN DATE
    ,c_group_pl_id              IN NUMBER
    )
   is
    select  /*+ INDEX (CPR BEN_CWB_PERSON_RATES_FK3) */ cpr.rowid, cpr.*
    from ben_cwb_person_rates cpr
    where cpr.person_id = c_person_id
      and cpr.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
      and cpr.group_pl_id    = c_group_pl_id
      -- Bug 3517726 : Do not consider any data which is not deleted
      -- by backoout.
      and cpr.group_per_in_ler_id = -1
    for update of cpr.group_per_in_ler_id;
   --
   l_mnl_dt date;
   l_dtctd_dt   date;
   l_procd_dt   date;
   l_unprocd_dt date;
   l_voidd_dt   date;
   l_strtd_dt   date;
   l_effective_date   date;
   --
   l_ws_mgr_id                  number;
   l_assignment_id              number(15);
   l_curr_per_in_ler_id         number;
   l_ptnl_ler_for_per_id        number;
   l_object_version_number      NUMBER;
   i binary_integer := 1;
   l_copy_person_bdgt_count binary_integer;
   --
   cursor c_cpg(c_group_pl_id number, c_group_lf_evt_ocrd_dt date) is
     select cpg.*
     from ben_cwb_person_groups cpg
     where cpg.group_pl_id = c_group_pl_id
       and cpg.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
       and cpg.group_per_in_ler_id =
           (select cpg1.group_per_in_ler_id
            from ben_cwb_person_groups cpg1
            where cpg1.group_pl_id = c_group_pl_id
              and cpg1.lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt
              and rownum = 1);
   --
   l_copy_dist_bdgt_val         ben_cwb_person_groups.dist_bdgt_val%type;
   l_copy_dist_bdgt_mn_val      ben_cwb_person_groups.dist_bdgt_mn_val%type;
   l_copy_dist_bdgt_mx_val      ben_cwb_person_groups.dist_bdgt_mx_val%type;
   l_copy_dist_bdgt_incr_val    ben_cwb_person_groups.dist_bdgt_incr_val%type;
   l_copy_dist_bdgt_iss_val     ben_cwb_person_groups.dist_bdgt_iss_val%type;
   l_copy_dist_bdgt_iss_date    ben_cwb_person_groups.dist_bdgt_iss_date%type;
   l_copy_ws_bdgt_val           ben_cwb_person_groups.ws_bdgt_val%type;
   l_copy_ws_bdgt_mn_val        ben_cwb_person_groups.ws_bdgt_mn_val%type;
   l_copy_ws_bdgt_mx_val        ben_cwb_person_groups.ws_bdgt_mx_val%type;
   l_copy_ws_bdgt_incr_val      ben_cwb_person_groups.ws_bdgt_incr_val%type;
   l_copy_ws_bdgt_iss_val       ben_cwb_person_groups.ws_bdgt_iss_val%type;
   l_copy_ws_bdgt_iss_date      ben_cwb_person_groups.ws_bdgt_iss_date%type;
   l_copy_rsrv_val              ben_cwb_person_groups.rsrv_val%type;
   l_copy_rsrv_mn_val           ben_cwb_person_groups.rsrv_mn_val%type;
   l_copy_rsrv_mx_val           ben_cwb_person_groups.rsrv_mx_val%type;
   l_copy_rsrv_incr_val         ben_cwb_person_groups.rsrv_incr_val%type;
   --
  CURSOR c_pl_dsgn (c_group_pl_id NUMBER, c_group_lf_evt_ocrd_dt DATE)
   IS
      SELECT group_oipl_id
        FROM ben_cwb_pl_dsgn
       WHERE group_pl_id = c_group_pl_id
         AND pl_id = group_pl_id
         AND lf_evt_ocrd_dt = c_group_lf_evt_ocrd_dt;

  --
begin
  --
  if g_debug then
    hr_utility.set_location ('Entering : ' || l_proc,30);
  end if;
   --
   -- Create the potential and per in ler in group plan.
   --
   if p_use_eff_dt_flag = 'N' then
      l_effective_date := p_group_lf_evt_ocrd_dt;
   else
      l_effective_date := p_effective_date;
   end if;
   ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per_perf
           (p_validate                 => false,
            p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id,
            p_lf_evt_ocrd_dt           => p_group_lf_evt_ocrd_dt,
            p_ptnl_ler_for_per_stat_cd => 'PROCD' ,
                                          --l_ptnl_ler_for_per_stat_cd_use,
            p_ler_id                   => p_group_ler_id,
            p_person_id                => p_person_id,
            p_ntfn_dt                  => trunc(sysdate), -- l_ntfn_dt,
            p_procd_dt                 => trunc(sysdate),
            p_dtctd_dt                 => trunc(sysdate),
            p_business_group_id        => p_group_business_group_id,
            p_object_version_number    => l_object_version_number,
            p_effective_date           => p_group_lf_evt_ocrd_dt,
            p_program_application_id   => fnd_global.prog_appl_id,
            p_program_id               => fnd_global.conc_program_id,
            p_request_id               => fnd_global.conc_request_id,
            p_program_update_date      => trunc(sysdate));
   --
   -- Get the manager information.
   --
   ben_manage_cwb_life_events.get_cwb_manager_and_assignment
       (p_person_id                => p_person_id,
        p_hrchy_to_use_cd          => ben_manage_cwb_life_events.g_cache_group_plan_rec.hrchy_to_use_cd,
        p_pos_structure_version_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.pos_structure_version_id,
        p_effective_date           => l_effective_date, -- ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
        p_manager_id               => l_ws_mgr_id,
        p_assignment_id            => l_assignment_id ) ;
  --
  hr_utility.set_location('l_ws_mgr_id = ' || l_ws_mgr_id, 1234);
  hr_utility.set_location('l_assignment_id = ' || l_assignment_id, 1234);
  --
  -- Create the group person life event
  --
  hr_utility.set_location('group_pl_id = ' || ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id, 1234);
  ben_Person_Life_Event_api.create_Person_Life_Event_perf
    (p_validate                => false
    ,p_per_in_ler_id           => l_curr_per_in_ler_id
    ,p_ler_id                  => p_group_ler_id
    ,p_person_id               => p_person_id
    ,p_per_in_ler_stat_cd      => 'STRTD'
    ,p_ptnl_ler_for_per_id     => l_ptnl_ler_for_per_id -- 99999
    ,p_lf_evt_ocrd_dt          => p_group_lf_evt_ocrd_dt
    ,p_business_group_id       => p_group_business_group_id
    ,p_ntfn_dt                 => trunc(sysdate)
    ,p_group_pl_id             => p_group_pl_id
    ,p_ws_mgr_id               => l_ws_mgr_id
    ,p_assignment_id           => l_assignment_id
    ,p_object_version_number   => l_object_version_number
    ,p_effective_date          => l_effective_date -- p_group_lf_evt_ocrd_dt
    ,p_program_application_id  => fnd_global.prog_appl_id
    ,p_program_id              => fnd_global.conc_program_id
    ,p_request_id              => fnd_global.conc_request_id
    ,p_program_update_date     => sysdate
    ,p_procd_dt                => l_procd_dt
    ,p_strtd_dt                => l_strtd_dt
    ,p_voidd_dt                => l_voidd_dt);
  --
  -- Per in ler created is a group per in ler so populate other
  -- plan design tables.
  --
  hr_utility.set_location('Call ben_manage_cwb_life_events.popu_cwb_tables', 1234);
  if p_use_eff_dt_flag = 'Y' then
     --
     ben_manage_cwb_life_events.popu_cwb_tables(
            p_group_per_in_ler_id    =>  l_curr_per_in_ler_id,
            p_group_pl_id            =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id,
            p_group_lf_evt_ocrd_dt   =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
            p_group_business_group_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_business_group_id,
            p_group_ler_id           =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_ler_id,
            p_use_eff_dt_flag        =>  'Y',
            p_effective_date         =>  p_effective_date);
     --
  else
     --
     ben_manage_cwb_life_events.popu_cwb_tables(
            p_group_per_in_ler_id    =>  l_curr_per_in_ler_id,
            p_group_pl_id            =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_pl_id,
            p_group_lf_evt_ocrd_dt   =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
            p_group_business_group_id => ben_manage_cwb_life_events.g_cache_group_plan_rec.group_business_group_id,
            p_group_ler_id           =>  ben_manage_cwb_life_events.g_cache_group_plan_rec.group_ler_id);
  end if;
  --
  --
  -- Cache the cwb_person_data if not cached already
  --
  if nvl(g_cache_cpg_rec.count, 0) = 0 then
     --
     -- Cache the cwb_person_groups data.
     --
     hr_utility.set_location('popu_cwb_tables before for loop', 1234);
     i := 1;
     for l_cpg_rec in c_cpg(p_group_pl_id, p_group_lf_evt_ocrd_dt) loop
      --
      hr_utility.set_location('popu_cwb_tables for loop i = ' || to_char(i), 1234);
      g_cache_cpg_rec(i) := l_cpg_rec;
      i := i+1;
      --
    end loop;
  end if;

 /* 5124534 :
   if g_cache_cpg_rec.count is still zero means
   there is no record in ben_cwb_person_groups .
   populate group_pl_id,group_oipl_id,budget values
   into g_cache_cpg_rec

   */

IF NVL (g_cache_cpg_rec.COUNT, 0) = 0
   THEN
      hr_utility.set_location (' populate g_cache_cpg_rec', 1234);
      i := 1;

      FOR l_pl_dsgn IN c_pl_dsgn (g_cache_group_plan_rec.group_pl_id,
                                  g_cache_group_plan_rec.group_lf_evt_ocrd_dt
                                 )
      LOOP

         g_cache_cpg_rec (i).group_pl_id := g_cache_group_plan_rec.group_pl_id;
         g_cache_cpg_rec (i).group_oipl_id := NVL (l_pl_dsgn.group_oipl_id,
                                                   -1);
         g_cache_cpg_rec (i).lf_evt_ocrd_dt :=
                                   g_cache_group_plan_rec.group_lf_evt_ocrd_dt;
         g_cache_cpg_rec (i).due_dt := g_cache_group_plan_rec.ws_upd_end_dt;
         g_cache_cpg_rec (i).access_cd := g_cache_group_plan_rec.access_cd;

         i := i + 1;
      END LOOP;

   END IF;  /* 5124534 end */


  --
  -- Initialise the copy budget structures.
  --
  g_cache_copy_person_bdgt_tbl    :=  g_cache_copy_person_bdgt_tbl1;
  --
  -- Now update the group per in ler id on ben_cwb_person_rates
  --
  l_copy_person_bdgt_count := 0;
  for l_per_rt_rec in c_person_rates(p_person_id,
    p_group_lf_evt_ocrd_dt,
    p_group_pl_id
  ) loop
      --
      update ben_cwb_person_rates cpr
        set    cpr.group_per_in_ler_id = l_curr_per_in_ler_id
        where  cpr.rowid = l_per_rt_rec.rowid;
      --
      -- Write copy budget values into table structures
      --
      if l_per_rt_rec.copy_dist_bdgt_val is not null or
         l_per_rt_rec.copy_dist_bdgt_mn_val is not null or
         l_per_rt_rec.copy_dist_bdgt_mx_val is not null or
         l_per_rt_rec.copy_dist_bdgt_incr_val is not null or
         l_per_rt_rec.copy_dist_bdgt_iss_val is not null or
         l_per_rt_rec.copy_dist_bdgt_iss_date is not null or
         l_per_rt_rec.copy_ws_bdgt_val is not null or
         l_per_rt_rec.copy_ws_bdgt_mn_val is not null or
         l_per_rt_rec.copy_ws_bdgt_mx_val is not null or
         l_per_rt_rec.copy_ws_bdgt_incr_val is not null or
         l_per_rt_rec.copy_ws_bdgt_iss_val is not null or
         l_per_rt_rec.copy_ws_bdgt_iss_date is not null or
         l_per_rt_rec.copy_rsrv_val is not null or
         l_per_rt_rec.copy_rsrv_mn_val is not null or
         l_per_rt_rec.copy_rsrv_mx_val is not null or
         l_per_rt_rec.copy_rsrv_incr_val is not null
      then
         --
         l_copy_person_bdgt_count := l_copy_person_bdgt_count + 1;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_dist_bdgt_val :=
                          l_per_rt_rec.copy_dist_bdgt_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_dist_bdgt_mn_val :=
                          l_per_rt_rec.copy_dist_bdgt_mn_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_dist_bdgt_mx_val :=
                          l_per_rt_rec.copy_dist_bdgt_mx_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_dist_bdgt_incr_val :=
                          l_per_rt_rec.copy_dist_bdgt_incr_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_dist_bdgt_iss_val :=
                          l_per_rt_rec.copy_dist_bdgt_iss_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_dist_bdgt_iss_date :=
                          l_per_rt_rec.copy_dist_bdgt_iss_date;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_ws_bdgt_val :=
                          l_per_rt_rec.copy_ws_bdgt_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_ws_bdgt_mn_val :=
                          l_per_rt_rec.copy_ws_bdgt_mn_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_ws_bdgt_mx_val :=
                          l_per_rt_rec.copy_ws_bdgt_mx_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_ws_bdgt_incr_val :=
                          l_per_rt_rec.copy_ws_bdgt_incr_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_ws_bdgt_iss_val :=
                          l_per_rt_rec.copy_ws_bdgt_iss_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_ws_bdgt_iss_date :=
                          l_per_rt_rec.copy_ws_bdgt_iss_date;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_rsrv_val :=
                          l_per_rt_rec.copy_rsrv_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_rsrv_mn_val :=
                          l_per_rt_rec.copy_rsrv_mn_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_rsrv_mx_val :=
                          l_per_rt_rec.copy_rsrv_mx_val;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).copy_rsrv_incr_val :=
                          l_per_rt_rec.copy_rsrv_incr_val;
         --
         -- Added for bug 4258200
         --
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).group_pl_id :=
                          l_per_rt_rec.group_pl_id;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).group_oipl_id :=
                          l_per_rt_rec.group_oipl_id;
         g_cache_copy_person_bdgt_tbl(l_copy_person_bdgt_count).group_lf_evt_ocrd_dt :=
                          l_per_rt_rec.lf_evt_ocrd_dt;
         --
      end if;
      --
  end loop;
  --
  -- Create the ben_cwb_person_groups data.
  --
  if nvl(g_cache_cpg_rec.count, 0) > 0 then
     --
     for l_cpg_count in 1..g_cache_cpg_rec.count loop
         --
         -- update ben_cwb_person_groups with budget copy_ columns
         --
         if nvl(l_copy_person_bdgt_count, 0) > 0 then
           for l_bdgt_count in 1..l_copy_person_bdgt_count loop
             --
             if g_cache_cpg_rec(l_cpg_count).group_pl_id =
                    g_cache_copy_person_bdgt_tbl(l_bdgt_count).group_pl_id
                and nvl(g_cache_cpg_rec(l_cpg_count).group_oipl_id, -1) =
                    nvl(g_cache_copy_person_bdgt_tbl(l_bdgt_count).group_oipl_id, -1)
                and g_cache_cpg_rec(l_cpg_count).lf_evt_ocrd_dt =
                    g_cache_copy_person_bdgt_tbl(l_bdgt_count).group_lf_evt_ocrd_dt
             then
               --
               -- Assign budget data from cache structure to person group structure.
               --
               l_copy_dist_bdgt_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_dist_bdgt_val;
               l_copy_dist_bdgt_mn_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_dist_bdgt_mn_val;
               l_copy_dist_bdgt_mx_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_dist_bdgt_mx_val;
               l_copy_dist_bdgt_incr_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_dist_bdgt_incr_val;
               l_copy_dist_bdgt_iss_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_dist_bdgt_iss_val;
               l_copy_dist_bdgt_iss_date := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_dist_bdgt_iss_date;
               l_copy_ws_bdgt_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_ws_bdgt_val;
               l_copy_ws_bdgt_mn_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_ws_bdgt_mn_val;
               l_copy_ws_bdgt_mx_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_ws_bdgt_mx_val;
               l_copy_ws_bdgt_incr_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_ws_bdgt_incr_val;
               l_copy_ws_bdgt_iss_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_ws_bdgt_iss_val;
               l_copy_ws_bdgt_iss_date := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_ws_bdgt_iss_date;
               l_copy_rsrv_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_rsrv_val;
               l_copy_rsrv_mn_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_rsrv_mn_val;
               l_copy_rsrv_mx_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_rsrv_mx_val;
               l_copy_rsrv_incr_val := g_cache_copy_person_bdgt_tbl(l_bdgt_count).copy_rsrv_incr_val;
               --
             else
               --
               l_copy_dist_bdgt_val := g_cache_cpg_rec(l_cpg_count).dist_bdgt_val;
               l_copy_dist_bdgt_mn_val := g_cache_cpg_rec(l_cpg_count).dist_bdgt_mn_val;
               l_copy_dist_bdgt_mx_val := g_cache_cpg_rec(l_cpg_count).dist_bdgt_mx_val;
               l_copy_dist_bdgt_incr_val := g_cache_cpg_rec(l_cpg_count).dist_bdgt_incr_val;
               l_copy_dist_bdgt_iss_val := g_cache_cpg_rec(l_cpg_count).dist_bdgt_iss_val;
               l_copy_dist_bdgt_iss_date := g_cache_cpg_rec(l_cpg_count).dist_bdgt_iss_date;
               l_copy_ws_bdgt_val := g_cache_cpg_rec(l_cpg_count).ws_bdgt_val;
               l_copy_ws_bdgt_mn_val := g_cache_cpg_rec(l_cpg_count).ws_bdgt_mn_val;
               l_copy_ws_bdgt_mx_val := g_cache_cpg_rec(l_cpg_count).ws_bdgt_mx_val;
               l_copy_ws_bdgt_incr_val := g_cache_cpg_rec(l_cpg_count).ws_bdgt_incr_val;
               l_copy_ws_bdgt_iss_val := g_cache_cpg_rec(l_cpg_count).ws_bdgt_iss_val;
               l_copy_ws_bdgt_iss_date := g_cache_cpg_rec(l_cpg_count).ws_bdgt_iss_date;
               l_copy_rsrv_val := g_cache_cpg_rec(l_cpg_count).rsrv_val;
               l_copy_rsrv_mn_val := g_cache_cpg_rec(l_cpg_count).rsrv_mn_val;
               l_copy_rsrv_mx_val := g_cache_cpg_rec(l_cpg_count).rsrv_mx_val;
               l_copy_rsrv_incr_val := g_cache_cpg_rec(l_cpg_count).rsrv_incr_val;
               --
             end if;
             --
           end loop;
           --
         end if;
         --
         -- create row in ben_cwb_person_groups
         --
         hr_utility.set_location('Creating missing ben_cwb_person_groups', 1234);
         insert into ben_cwb_person_groups
               (group_per_in_ler_id,
                group_pl_id        ,
                group_oipl_id      ,
                lf_evt_ocrd_dt     ,
                bdgt_pop_cd        ,
                due_dt             ,
                access_cd          ,
                approval_cd        ,
                approval_date      ,
                approval_comments  ,
                submit_cd          ,
                submit_date        ,
                submit_comments    ,
                dist_bdgt_val      ,
                ws_bdgt_val        ,
                -- Bug 3510081 New columns need to be populated.
                dflt_dist_bdgt_val      ,
                dflt_ws_bdgt_val        ,
                rsrv_val           ,
                dist_bdgt_mn_val   ,
                dist_bdgt_mx_val   ,
                dist_bdgt_incr_val ,
                ws_bdgt_mn_val     ,
                ws_bdgt_mx_val     ,
                ws_bdgt_incr_val   ,
                rsrv_mn_val        ,
                rsrv_mx_val        ,
                rsrv_incr_val      ,
                dist_bdgt_iss_val  ,
                ws_bdgt_iss_val    ,
                dist_bdgt_iss_date ,
                ws_bdgt_iss_date   ,
                ws_bdgt_val_last_upd_date ,
                dist_bdgt_val_last_upd_date  ,
                rsrv_val_last_upd_date       ,
                ws_bdgt_val_last_upd_by      ,
                dist_bdgt_val_last_upd_by    ,
                rsrv_val_last_upd_by         ,
                object_version_number        ,
                last_update_date         ,
                last_updated_by          ,
                last_update_login        ,
                created_by               ,
                creation_date
             ) values (
                l_curr_per_in_ler_id,
                g_cache_cpg_rec(l_cpg_count).group_pl_id        ,
                nvl(g_cache_cpg_rec(l_cpg_count).group_oipl_id, -1) ,
                g_cache_cpg_rec(l_cpg_count).lf_evt_ocrd_dt     ,
                null,  --  bdgt_pop_cd
                g_cache_cpg_rec(l_cpg_count).due_dt,
                g_cache_cpg_rec(l_cpg_count).access_cd,
                null,  -- approval_cd
                null,  -- approval_date
                null,  -- approval_comments
                'NS',  -- submit_cd
                null,  -- submit_date
                null,  -- submit_comments
                /*
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_val,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_val,
                g_cache_cpg_rec(l_cpg_count).rsrv_val,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_mn_val,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_mx_val,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_incr_val,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_mn_val,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_mx_val,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_incr_val,
                g_cache_cpg_rec(l_cpg_count).rsrv_mn_val,
                g_cache_cpg_rec(l_cpg_count).rsrv_mx_val,
                g_cache_cpg_rec(l_cpg_count).rsrv_incr_val,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_iss_val,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_iss_val,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_iss_date,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_iss_date,
                */
                -- Bug 3510081 put null values.
                null, -- l_copy_dist_bdgt_val,
                null, -- l_copy_ws_bdgt_val,
                l_copy_dist_bdgt_val,
                l_copy_ws_bdgt_val,
                l_copy_rsrv_val,
                l_copy_dist_bdgt_mn_val,
                l_copy_dist_bdgt_mx_val,
                l_copy_dist_bdgt_incr_val,
                l_copy_ws_bdgt_mn_val,
                l_copy_ws_bdgt_mx_val,
                l_copy_ws_bdgt_incr_val,
                l_copy_rsrv_mn_val,
                l_copy_rsrv_mx_val,
                l_copy_rsrv_incr_val,
                --
                -- Bug 3510081 : No need to populate the budget values here.
                -- Need to verify whether other values need to be populated or not.
                --
                null, -- l_copy_dist_bdgt_iss_val,
                null, -- l_copy_ws_bdgt_iss_val,
                null, -- l_copy_dist_bdgt_iss_date,
                null, -- l_copy_ws_bdgt_iss_date,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_val_last_upd_date ,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_val_last_upd_date  ,
                g_cache_cpg_rec(l_cpg_count).rsrv_val_last_upd_date       ,
                g_cache_cpg_rec(l_cpg_count).ws_bdgt_val_last_upd_by      ,
                g_cache_cpg_rec(l_cpg_count).dist_bdgt_val_last_upd_by    ,
                g_cache_cpg_rec(l_cpg_count).rsrv_val_last_upd_by         ,
                1, -- object_version_number
                -- Check all the column values.
                g_cache_cpg_rec(l_cpg_count).last_update_date         ,
                g_cache_cpg_rec(l_cpg_count).last_updated_by          ,
                g_cache_cpg_rec(l_cpg_count).last_update_login        ,
                g_cache_cpg_rec(l_cpg_count).created_by               ,
                g_cache_cpg_rec(l_cpg_count).creation_date
         ) ;
      end loop;
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Leaving : ' || l_proc,30);
  end if;
end popu_missing_person_pil;
--
procedure popu_cwb_group_pil_data (
                        p_group_per_in_ler_id in number, --9999 We will remove it later
                        p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number,
                        p_use_eff_dt_flag      in     varchar2 default 'N',
                        p_effective_date       in date default null) is
   --
   cursor c_missing_group_pils is
     select person_id
     from   ben_per_in_ler all_pils
     where  group_pl_id = p_group_pl_id
       and  lf_evt_ocrd_dt = p_group_lf_evt_ocrd_dt
       and  per_in_ler_stat_cd = 'STRTD'
     union
     select ws_mgr_id
     from   ben_per_in_ler all_pils
     where  group_pl_id = p_group_pl_id
       and  lf_evt_ocrd_dt = p_group_lf_evt_ocrd_dt
       and  per_in_ler_stat_cd = 'STRTD'
       and  ws_mgr_id is not null
     minus
     select person_id
     from   ben_per_in_ler all_pils
     where  group_pl_id = p_group_pl_id
       and  lf_evt_ocrd_dt = p_group_lf_evt_ocrd_dt
       and  per_in_ler_stat_cd in ('STRTD', 'PROCD') -- GSI  If a person is already processed but his reportee
                                                     -- is processed then data should not be created for manager.
       and  ler_id = p_group_ler_id;
   --
   l_exit_loop boolean;
   --
   l_group_per_in_ler_id number null;
   cursor c_null_gpil_cpr(cv_group_pl_id in number,
                          cv_lf_evt_ocrd_dt in date) is
     select cpr.*, cpr.rowid
     from ben_cwb_person_rates cpr
     where GROUP_PER_IN_LER_ID = -1
       and GROUP_PL_ID = cv_group_pl_id
       and LF_EVT_OCRD_DT = cv_lf_evt_ocrd_dt;
      --
   cursor get_gpil_id (cv_person_id in number,
                       cv_lf_evt_ocrd_dt in date,
                       cv_group_ler_id in number) is
     select per_in_ler_id
     from ben_per_in_ler
     where person_id = cv_person_id
       and lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
       and ler_id = cv_group_ler_id
       and per_in_ler_stat_cd = 'STRTD';
       -- and ws_mgr_id is not null;
   --
begin
   --
  if g_debug then
   hr_utility.set_location('Entering popu_cwb_group_pil_data', 10);
   hr_utility.set_location('= ' ||p_group_per_in_ler_id , 1234);
   hr_utility.set_location('= ' ||p_group_pl_id    , 1234);
   hr_utility.set_location('= ' ||p_group_lf_evt_ocrd_dt , 1234);
   hr_utility.set_location('= ' ||p_group_business_group_id    , 1234);
   hr_utility.set_location('= ' ||p_group_ler_id         , 1234);
  end if;
   /*
      popu_missing_pil(p_mode, p_group_pl_business_group_id, p_group_pl_id,
                       p_group_ler_id, p_effective_date, p_lf_evt_ocrd_dt)
      Loop
        L_exit_loop = TRUE;
        For each person in( ((select person_id from ben_per_in_ler all_pils)
                              union
			      (select ws_mgr_id from ben_per_in_ler all_pils)
                            ) minus
                            (select person_id from ben_per_in_ler group_plan_pils)
                          )
        Loop
              popu_missing_person_pil(p_mode, p_person_id,
                                      p_group_pl_business_group_id,
                                      p_group_pl_id, p_effective_date,
                                      p_lf_evt_ocrd_dt);
              L_exit_loop = FALSE;
        end for loop;
        If L_exit_loop = TRUE then exit;
      End Loop;

      Logic for procedure which populate the missing data at person level:
      popu_missing_person_pil(p_mode, p_person_id, p_group_pl_business_group_id,
                              p_group_pl_id, p_group_ler_id , p_effective_date,
                              p_lf_evt_ocrd_dt)
      Also need to copy the budget rate from actual plan or option to group plan
      or option.
      If cached data for one group plan is not available,
           cache group plan per in ler data.

      Create potential, per in ler for the group_ler_id for the person.
      Insert row into ben_cwb_group_hrchy if row already not exists.

      Update the group_per_in_ler_id on ben_cwb_person_rates
      where group_per_in_ler_id is null and
            group_pl_id = p_group_pl_id and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt and
            assignment_id = p_assignment_id;

      For each of the cached group plan epe data
          Create elig_per_elctbl_chc
          For each rate attached to group plan epe
              If rate is a budget rate if one is defined at actual plan level then val, min, max have to
              be moved to cloned rate.
              Create enrt_rt if needed or populate the denormalised tables.


   */
   --
   --
   -- loop for each person to whom the group per in ler is missing.
   --
   loop
    --
    l_exit_loop := TRUE;
    --
    g_error_log_rec.calling_proc := 'popu_missing_person_pil';
    g_error_log_rec.step_number := 21;
    --
    for l_rec in c_missing_group_pils loop
        --
        -- Populate group pil and associated data for this person.
        --
        hr_utility.set_location(' popu_cwb_group_pil_data : per id = ' || l_rec.person_id, 10);
        if p_use_eff_dt_flag = 'N' then
         --
         popu_missing_person_pil(
          p_mode                        => 'ABCD',
          p_person_id                   => l_rec.person_id ,
          p_group_per_in_ler_id         => 9999, --9999IK Not required confirm Prasad
          p_group_pl_id                 => g_cache_group_plan_rec.group_pl_id,
          p_group_lf_evt_ocrd_dt        => g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
          p_group_business_group_id     => g_cache_group_plan_rec.group_business_group_id,
          p_group_ler_id                => g_cache_group_plan_rec.group_ler_id );
         --
        else
         --
         popu_missing_person_pil(
          p_mode                        => 'ABCD',
          p_person_id                   => l_rec.person_id ,
          p_group_per_in_ler_id         => 9999, --9999IK Not required confirm Prasad
          p_group_pl_id                 => g_cache_group_plan_rec.group_pl_id,
          p_group_lf_evt_ocrd_dt        => g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
          p_group_business_group_id     => g_cache_group_plan_rec.group_business_group_id,
          p_group_ler_id                => g_cache_group_plan_rec.group_ler_id ,
          p_use_eff_dt_flag             => p_use_eff_dt_flag,
          p_effective_date              => p_effective_date
         );
         --
        end if;
        --
        l_exit_loop := FALSE;
        --
    end loop;
    --
    if l_exit_loop = TRUE then
       exit;
    end if;
    --
  end loop;
  --
  -- Now populate the group per in ler id on ben_cwb_person_rates table
  -- if it's missing.
  --
  g_error_log_rec.calling_proc := 'ben_cwb_person_rates';
  g_error_log_rec.step_number := 22;
  --
  l_group_per_in_ler_id := null;
  for l_null_gpil_rec in c_null_gpil_cpr(g_cache_group_plan_rec.group_pl_id,
                                g_cache_group_plan_rec.group_lf_evt_ocrd_dt)
  loop
      --
      open get_gpil_id (l_null_gpil_rec.person_id,
                        g_cache_group_plan_rec.group_lf_evt_ocrd_dt,
                        g_cache_group_plan_rec.group_ler_id);
      fetch get_gpil_id into l_group_per_in_ler_id;
      close get_gpil_id;
      --
      update ben_cwb_person_rates
         set group_per_in_ler_id = l_group_per_in_ler_id
      where rowid = l_null_gpil_rec.rowid;
      --
  end loop;
  --
  if g_debug then
     hr_utility.set_location('Leaving popu_cwb_group_pil_data', 10);
  end if;
end popu_cwb_group_pil_data;
--
procedure global_online_process_w
  (
   p_effective_date           in     date
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  -- Business group passed must be person business group.
  ,p_business_group_id        in     number
  -- This is group plan id.
  ,p_pl_id                    in     number   default null
  ,p_lf_evt_ocrd_dt           in     date default null
  ,p_clone_all_data_flag      in     varchar2 default 'N'
  ,p_backout_and_process_flag in     varchar2 default 'N'
  ) is
    --
    l_proc           varchar2(72) := g_package||'global_online_process_w';
    --
    l_retcode                   number;
    l_errbuf                    varchar2(1000);
    l_encoded_message   varchar2(2000);
    l_app_short_name    varchar2(2000);
    l_message_name      varchar2(2000);
    l_effective_date    varchar2(30);
    l_lf_evt_ocrd_dt    varchar2(30);
    l_cache_group_plan_rec_temp g_cache_group_plan_type;
    --
  begin
    --
    hr_utility.set_location ('Entering '||l_proc,10);
    l_effective_date := to_char(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
    l_lf_evt_ocrd_dt := to_char(nvl(p_lf_evt_ocrd_dt,p_effective_date),'YYYY/MM/DD HH24:MI:SS');
    --
    fnd_msg_pub.initialize;
    --
    -- If backout is requested then first back out and call online.
    --
    if p_backout_and_process_flag = 'Y' then
       --
       hr_utility.set_location ('Before : p_backout_global_cwb_event ',10);
       ben_cwb_back_out_conc.p_backout_global_cwb_event(
         p_effective_date           => p_lf_evt_ocrd_dt
        ,p_validate                 => p_validate
        ,p_business_group_id        => p_business_group_id
        ,p_group_pl_id              => p_pl_id
        ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
        ,p_person_id                => p_person_id
       );
       --
    end if;
    --
    -- Initilise the globals as this process could be called from
    -- the sscwb pages for different person or plans or different dates.
    --
    g_trk_inelig_flag := null;
    g_options_exists  := null;
    g_cache_group_plan_rec := l_cache_group_plan_rec_temp;
    g_cache_cpg_rec.delete;
    g_cache_copy_person_bdgt_tbl    :=  g_cache_copy_person_bdgt_tbl1;
    ben_manage_cwb_life_events.g_cwb_person_groups_rec    := ben_manage_cwb_life_events.g_cwb_person_groups_rec_temp;
    ben_manage_cwb_life_events.g_cwb_person_rates_rec     := ben_manage_cwb_life_events.g_cwb_person_rates_rec_temp;
    --
    ben_manage_cwb_life_events.global_process
          (Errbuf                     =>l_errbuf,
           retcode                    =>l_retcode,
           p_effective_date           =>l_effective_date,
           p_validate                 =>p_validate,
           p_person_id                =>p_person_id,
           p_business_group_id        =>p_business_group_id,
           p_pl_id                    =>p_pl_id,
           p_lf_evt_ocrd_dt           =>l_lf_evt_ocrd_dt,
           p_trace_plans_flag         =>'Y',
           p_online_call_flag         =>'Y',
           p_clone_all_data_flag      => p_clone_all_data_flag);
    --
    -- If recursive hiearchy is found raise the error.
    --
    if nvl(g_hrchy_tbl.LAST, 0) > 0 then
       --
       fnd_message.set_name('BEN', 'BEN_94537_REC_REPORTING');
       fnd_message.set_token('TOKEN1', g_hrchy_tbl(1).hrchy_cat_string);
       fnd_message.raise_error;
       --
    end if;
    fnd_msg_pub.initialize;
    --
  exception when app_exception.application_exception then
    --
    ben_on_line_lf_evt.get_ser_message(
                    p_encoded_message => l_encoded_message,
                    p_app_short_name  => l_app_short_name,
                    p_message_name    => l_message_name);
    --
    if (l_message_name like '%BEN_91769_NOONE_TO_PROCESS%') then
      fnd_message.set_name('BEN', 'BEN_92540_NOONE_TO_PROCESS_CM');
    end if;
    --
    if (l_message_name = 'BEN_91664_BENMNGLE_NO_OBJECTS') then
      l_encoded_message := fnd_message.get_encoded;
    else
      fnd_msg_pub.add;
    end if;
    --
  when others then
    --
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
    --
  end global_online_process_w;
  --
  procedure sum_oipl_rates_and_upd_pl_rate (
            p_pl_id          in number,
            p_group_pl_id    in number,
            p_lf_evt_ocrd_dt in date,
            p_person_id      in number,
            p_assignment_id  in number
            ) is
    --
    cursor c_oipl_exists(cv_lf_evt_ocrd_dt in date,
                        cv_pl_id          in number) is
    select oipl.oipl_id
    from ben_oipl_f oipl
    where  oipl.pl_id = cv_pl_id
    and    oipl.OIPL_STAT_CD = 'A'
    and    cv_lf_evt_ocrd_dt between oipl.effective_start_date
                                 and oipl.effective_end_date
    and exists
          (select null
           from ben_acty_base_rt_f abr
           where abr.pl_id = cv_pl_id
             and cv_lf_evt_ocrd_dt between abr.effective_start_date
                                 and abr.effective_end_date
             and abr.acty_typ_cd = 'CWBWS' -- 9999
           );
    --
    cursor c_cpr(cv_group_pl_id in number,
                 cv_pl_id in number,
                 cv_lf_evt_ocrd_dt in date,
                 cv_person_id  in number) is
    select *
    from ben_cwb_person_rates
    where group_pl_id = cv_group_pl_id
      and pl_id = cv_pl_id
      and nvl(oipl_id, -1) = -1
      and person_id   = cv_person_id
      and lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt;
    --
   cursor c_cpr_oipl(cv_group_pl_id in number,
                 cv_pl_id in number,
                 cv_lf_evt_ocrd_dt in date,
                 cv_person_id  in number) is
    select sum(ws_val) ws_val, sum(nvl(ws_val, 0)) ws_val_0_if_null
    from ben_cwb_person_rates
    where group_pl_id = cv_group_pl_id
      and pl_id = cv_pl_id
      and nvl(oipl_id, -1) <> -1
      and person_id   = cv_person_id
      and lf_evt_ocrd_dt = cv_lf_evt_ocrd_dt
      and ws_val is not null;
    --
    l_oipl_ws_sum      number;
    l_ws_val_0_if_null number;
    l_oipl_id          number;
    --
   begin
     --
     if g_debug then
        hr_utility.set_location ('Entering :sum_oipl_rates_and_upd_pl_rate ' ,10);
     end if;
     --
     -- Fetch all ben_cwb_person_rates for the person
     -- for the plan, for lf_evt_ocrd_dt if there exists oipl for this plan
     --
     if g_options_exists is null then
        --
        open c_oipl_exists(p_lf_evt_ocrd_dt, p_pl_id);
        fetch c_oipl_exists into l_oipl_id;
        if c_oipl_exists%found then
           g_options_exists := true;
        else
           g_options_exists := false;
        end if;
        close c_oipl_exists;
        --
     end if;
     --
     if g_options_exists then
        --
        for l_cpr_rec in c_cpr(p_group_pl_id, p_pl_id, p_lf_evt_ocrd_dt,
                               p_person_id)
        loop
            --
            open c_cpr_oipl(p_group_pl_id, p_pl_id, p_lf_evt_ocrd_dt,
                               p_person_id);
            fetch c_cpr_oipl into l_oipl_ws_sum, l_ws_val_0_if_null;
            if c_cpr_oipl%found then
               --
               if (l_oipl_ws_sum is not null and l_ws_val_0_if_null is not null)
                 OR (l_oipl_ws_sum is null and l_ws_val_0_if_null <> 0)
               then
                   --
                   -- Update plan level cpr.
                   --
                   update ben_cwb_person_rates
                      set ws_val = l_oipl_ws_sum
                   where person_rate_id = l_cpr_rec.person_rate_id;
                   --
               end if;
            end if;
            close c_cpr_oipl;
            --
        end loop;
        --
     end if;
     if g_debug then
        hr_utility.set_location ('Leaving :sum_oipl_rates_and_upd_pl_rate ' ,10);
     end if;
     --
   end sum_oipl_rates_and_upd_pl_rate;
   --
  --
  -- Procedure to populate the auto allocation of budgets.
  --
  procedure auto_allocate_budgets (
            p_pl_id          in number default null,
            p_group_pl_id    in number,
            p_lf_evt_ocrd_dt in date,
            p_person_id      in number default null,
            p_assignment_id  in number default null
            ) is
   --
   cursor c_high_mgr_cpg(c_group_pl_id number, c_lf_evt_ocrd_dt date) is
   select cpg.rowid, cpg.*
   from ben_cwb_person_groups cpg
   where cpg.group_pl_id = c_group_pl_id
       and cpg.lf_evt_ocrd_dt = c_lf_evt_ocrd_dt
       and exists
           (select null
            from ben_cwb_person_rates cpr,
                 ben_cwb_group_hrchy cgh
            where cgh.emp_per_in_ler_id = cpr.GROUP_PER_IN_LER_ID
              and cpr.ELIG_FLAG = 'Y'
              and cgh.LVL_NUM > 1
              and cgh.mgr_per_in_ler_id = cpg.GROUP_PER_IN_LER_ID)
       and cpg.dist_bdgt_val_last_upd_date is null
       and cpg.ws_bdgt_val_last_upd_date is null
    for update;
   --
   cursor c_leaf_mgr_cpg(c_group_pl_id number, c_lf_evt_ocrd_dt date) is
   select cpg.rowid, cpg.*
   from ben_cwb_person_groups cpg
   where cpg.group_pl_id = c_group_pl_id
       and cpg.lf_evt_ocrd_dt = c_lf_evt_ocrd_dt
       and not exists
           (select null
            from ben_cwb_person_rates cpr1,
                 ben_cwb_group_hrchy cgh1
            where cgh1.emp_per_in_ler_id = cpr1.GROUP_PER_IN_LER_ID
              and cpr1.ELIG_FLAG = 'Y'
              and cgh1.LVL_NUM > 1
              and cgh1.mgr_per_in_ler_id = cpg.GROUP_PER_IN_LER_ID)
       and exists
           (select null
            from ben_cwb_person_rates cpr,
                 ben_cwb_group_hrchy cgh
            where cgh.emp_per_in_ler_id = cpr.GROUP_PER_IN_LER_ID
              and cpr.ELIG_FLAG = 'Y'
              and cgh.LVL_NUM = 1
              and cgh.mgr_per_in_ler_id = cpg.GROUP_PER_IN_LER_ID)
       and cpg.ws_bdgt_val_last_upd_date is null
       and cpg.dist_bdgt_val_last_upd_date is null
    for update ;
   --
   l_dflt_dist_bdgt_val number;
   l_dflt_ws_bdgt_val   number;
   l_iss_dt             date;
   l_pop_cd             varchar2(30);
   --
  begin
     if g_debug then
        hr_utility.set_location ('Entering :auto_allocate_budgets ' ,10);
     end if;
     --
     for l_high_mgr_cpg_rec in c_high_mgr_cpg(p_group_pl_id , p_lf_evt_ocrd_dt )
     loop
         --
         -- if auto alloc flag is Y update dist_bdgt_iss_val, ws_bdgt_iss_val
         -- dist_bdgt_iss_date, ws_bdgt_iss_date
         --
         --
         l_pop_cd   := null;
         --
         if g_cache_group_plan_rec.auto_distr_flag = 'Y' then
            --
            l_dflt_dist_bdgt_val := l_high_mgr_cpg_rec.dflt_dist_bdgt_val;
            l_dflt_ws_bdgt_val   := l_high_mgr_cpg_rec.dflt_ws_bdgt_val;
            --
            if nvl(l_high_mgr_cpg_rec.group_oipl_id , -1) =   -1 then
              l_iss_dt     := p_lf_evt_ocrd_dt;
              -- If components are configured then populate pop_cd at plan level.
              l_pop_cd   := 'D';
            else
              l_iss_dt := null;
            end if;
         else
            --
            l_dflt_dist_bdgt_val := null;
            l_dflt_ws_bdgt_val   := null;
            l_iss_dt     := null;
            --
         end if;
         --
         update ben_cwb_person_groups
         set dist_bdgt_val                = dflt_dist_bdgt_val,
             ws_bdgt_val                  = dflt_ws_bdgt_val,
             ws_bdgt_val_last_upd_date    = p_lf_evt_ocrd_dt,
             dist_bdgt_val_last_upd_date  = p_lf_evt_ocrd_dt,
             bdgt_pop_cd                  = l_pop_cd,
             dist_bdgt_iss_val            = l_dflt_dist_bdgt_val,
             ws_bdgt_iss_val              = l_dflt_ws_bdgt_val,
             dist_bdgt_iss_date           = l_iss_dt,
             ws_bdgt_iss_date             = l_iss_dt
         where rowid = l_high_mgr_cpg_rec.rowid;
         --
     end loop;
     --
     for l_leaf_mgr_cpg_rec in c_leaf_mgr_cpg(p_group_pl_id , p_lf_evt_ocrd_dt ) loop
         --
         --
         -- if auto alloc flag is Y update dist_bdgt_iss_val, ws_bdgt_iss_val
         -- dist_bdgt_iss_date, ws_bdgt_iss_date
         --
         -- If components are configured then populate pop_cd at plan level.
         -- Leaf managers do not need pop cd at all.
         --
         l_pop_cd   := null;
         --
         if g_cache_group_plan_rec.auto_distr_flag = 'Y' then
            --
            l_dflt_ws_bdgt_val   := l_leaf_mgr_cpg_rec.dflt_ws_bdgt_val;
            --
            if nvl(l_leaf_mgr_cpg_rec.group_oipl_id, -1) =  -1  then
              -- It's a plan
              l_iss_dt     := p_lf_evt_ocrd_dt;
            else
              l_iss_dt := null;
            end if;
         else
            --
            l_dflt_ws_bdgt_val   := null;
            l_iss_dt     := null;
            --
         end if;
         --
         update ben_cwb_person_groups
         set ws_bdgt_val                  = dflt_ws_bdgt_val,
             ws_bdgt_val_last_upd_date    = p_lf_evt_ocrd_dt,
             ws_bdgt_iss_val              = l_dflt_ws_bdgt_val,
             ws_bdgt_iss_date             = l_iss_dt,
             bdgt_pop_cd                  = l_pop_cd
         where rowid = l_leaf_mgr_cpg_rec.rowid;
         --
     end loop;
     --
     if g_debug then
        hr_utility.set_location ('Leaving :auto_allocate_budgets ' ,10);
     end if;
     --
  end auto_allocate_budgets;
  --
end BEN_MANAGE_CWB_LIFE_EVENTS;

/
