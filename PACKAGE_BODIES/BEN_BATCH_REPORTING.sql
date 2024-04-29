--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_REPORTING" as
/* $Header: benrepor.pkb 120.1 2007/05/04 11:09:59 nhunur noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Batch Reporting
Purpose
	This package is used to perform reporting for batch processes.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07 Oct 98        G Perry    115.0      Created.
        16 Oct 98        I Harding  115.1      Uncommented exit
        20 Dec 98        G Perry    115.2      Changed reporting to drive off
                                               new reporting tables.
        02 Mar 99        G Perry    115.3      Added error message check for
                                               when concurrent requests are
                                               being spawned.
        14 Nov 99        G Perry    115.4      Added parameter to
                                               run certain activity report
                                               based on mode. Also added
                                               temporal events procedure.
        11 Apr 00        G Perry    115.5      Added application id join
                                               to sort FIDO dup row issues.
        12 May 00        jcarpent   115.2      Changed parameters to
                                               summary (127645/4424)
        24 Jul 00        C Daniels  115.8      OraBug 5413. Changed the lookup
                                               type associated with the
                                               derivable factors flag from
                                               'YES_NO' to 'BEN_DTCT_TMPRL_
                                               LER_TYP' in cursor c_benefit_
                                               actions of the standard_header
                                               procedure.
       15 Sep 00        C Daniels   115.9      Bug 1405067. Modified cursor
                                               c_rate_prem_cvg_change in
                                               both versions of overloaded
                                               procedure activity_summary_
                                               by_action to be based on
                                               table ben_batch_ler_info only.
       11 Jan 02        Pbodla      115.10     CWB Change : Extend the C mode
                                               to W (Comp Workbench mode)
                                               in procedure batch_reports
       11 Jan 02        Pbodla      115.11     Added Commit at the end
       28 Jan 02        mhoyes      115.12   - Excluded batch reporting
                                               for collective agreement A mode.
       18 Mar 02        hnarayan    115.14     bug 1560336 - changed standard_header procedure
       18 Jun 02        ikasire     115.15     bug 2394141 NLS Changes
       18 Jun 02        ikasire     115.16     bug 2394141 Replaced nvl with decode and
                                               source_lang with language
       17 Jul 02        mmudigon    115.17     ABSENCES : Added absences mode
       05 Sep 02        vsethi      115.18     Bug 2547948, truncating the value returned by
       					                   fnd_message.get to 80. The returned value cannot
       					                   be greater than 80 unless it's changed for translation
       30 Oct 02        bmanyam     115.19     Bug 2243050: Added check in queries to restrict
                                               persons errored in procedures
                                               activity_summary_by_action and
                                               temporal_life_events
       30 Oct 02        bmanyam     115.20     -- do --
       27 Dec 02        rpillay     115.22     NOCOPY changes
       14 Feb 03        tmathers    115.23     MLS Changes
       15-May-03        rpgupta     115.24     bug 2950460
       					                   change the lookup type for some
       					                   reports as cursor does'nt fetch any rows
       29-May-03        ikasire     115.25     Bug 2945455 added 'P' mode for
                                               submit
       30-Jun-03        vsethi      115.26     Changed reference for table ben_rptg_grp
			                            MLS compliant view ben_rptg_grp_v

       18-Aug-03        rpgupta     115.27     Included mode 'G' for 'BENACTIV'
       02-jun-04        nhunur      115.28     3662774 - Added cursor c0 in temporal_life_events
                                               for performance.
	15 Jun 04        hmani      115.30      Added six more params
	                                       to temporal_life_events - Bug 3690166
       19-Nov-04        abparekh    115.31     Bug 3517604 Modified cursor c_benefit_actions to take
                                               outer join for lookup_type BEN_DTCT_TMPRL_LER_TYP
       15-apr-05        nhunur      115.32     Performance changes to use benefit_action_id instead of request_id
*/
-----------------------------------------------------------------------
g_package varchar2(30) := 'ben_batch_reporting.';
-----------------------------------------------------------------------
procedure standard_header
          (p_concurrent_request_id      in  number,
           p_concurrent_program_name    out nocopy varchar2,
           p_process_date               out nocopy date,
           p_mode                       out nocopy varchar2,
           p_derivable_factors          out nocopy varchar2,
           p_validate                   out nocopy varchar2,
           p_person                     out nocopy varchar2,
           p_person_type                out nocopy varchar2,
           p_program                    out nocopy varchar2,
           p_business_group             out nocopy varchar2,
           p_plan                       out nocopy varchar2,
           p_popl_enrt_typ_cycl         out nocopy varchar2,
           p_plans_not_in_programs      out nocopy varchar2,
           p_just_programs              out nocopy varchar2,
           p_comp_object_selection_rule out nocopy varchar2,
           p_person_selection_rule      out nocopy varchar2,
           p_life_event_reason          out nocopy varchar2,
           p_organization               out nocopy varchar2,
           p_postal_zip_range           out nocopy varchar2,
           p_reporting_group            out nocopy varchar2,
           p_plan_type                  out nocopy varchar2,
           p_option                     out nocopy varchar2,
           p_eligibility_profile        out nocopy varchar2,
           p_variable_rate_profile      out nocopy varchar2,
           p_legal_entity               out nocopy varchar2,
           p_payroll                    out nocopy varchar2,
           p_status                     out nocopy varchar2) is
  --
  l_proc                    varchar2(80) := g_package||'.standard_header';
  l_all                     varchar2(80);
  l_none                    varchar2(80);
  -- bug 1560336
  l_mode_cd_lookup_type	    hr_lookups.lookup_type%type := 'BEN_BENMNGLE_MD';
  l_drvbl_fctrs_lookup_type hr_lookups.lookup_type%type := 'BEN_DTCT_TMPRL_LER_TYP';
  l_conc_pgm_name	    fnd_concurrent_programs.concurrent_program_name%type ;
  --
  cursor c_benefit_actions is
    select bft.process_date,
           hr.meaning,
           hr1.meaning,
           hr2.meaning,
           /* Default null return columns using local variables
              declared above */
           nvl(ppf.full_name,l_all),
           nvl(ppt.user_person_type,l_all),
           nvl(pgm.name,l_all),
           pbg.name,
           nvl(pln.name,l_all),
           decode(hr5.meaning,
                  null,
                  l_all,
                  hr5.meaning||
                  ' '||
                  pln2.name||
                  ' '||
                  pgm2.name||
                  ' '||
                  epo.strt_dt||
                  ' '||
                  epo.end_dt),
           hr3.meaning,
           hr4.meaning,
           nvl(ff.formula_name,l_none),
           nvl(ff2.formula_name,l_none),
           nvl(ler.name,l_all),
           nvl(org.name,l_all),
           decode(rzr.from_value||'-'||rzr.to_value,
                  '-',
                  l_all,
                  rzr.from_value||'-'||rzr.to_value),
           nvl(bnr.name,l_all),
           nvl(ptp.name,l_all),
           nvl(opt.name,l_all),
           nvl(elp.name,l_all),
           nvl(vpf.name,l_all),
           nvl(org2.name,l_all),
           nvl(pay.payroll_name,l_all),
           conc.user_concurrent_program_name,
           fnd1.meaning
    from   ben_benefit_actions bft,
           hr_lookups hr,
           hr_lookups hr1,
           hr_lookups hr2,
           hr_lookups hr3,
           hr_lookups hr4,
           hr_lookups hr5,
           fnd_lookups fnd1,
           per_people_f ppf,
           per_person_types ppt,
           ben_pgm_f pgm,
           per_business_groups pbg,
           ben_pl_f pln,
           ff_formulas_f ff,
           ff_formulas_f ff2,
           ben_ler_f ler,
           hr_all_organization_units_vl org,
           ben_rptg_grp_v bnr,
           ben_pl_typ_f ptp,
           ben_opt_f opt,
           ben_eligy_prfl_f elp,
           ben_vrbl_rt_prfl_f vpf,
           pay_payrolls_f pay,
           ben_pstl_zip_rng_f rzr,
           hr_all_organization_units_tl org2,
           ben_popl_enrt_typ_cycl_f pop,
           ben_enrt_perd epo,
           ben_pl_f pln2,
           ben_pgm_f pgm2,
           fnd_concurrent_requests fnd,
           fnd_concurrent_programs_tl conc
    where  fnd.request_id = p_concurrent_request_id
    and    conc.concurrent_program_id = fnd.concurrent_program_id
    and    conc.application_id = 805
    and    userenv('LANG') = conc.language  --Bug 2394141
    and    bft.request_id = fnd.request_id
    and    hr.lookup_code = bft.mode_cd
    -- bug fix 1560336
    -- and    hr.lookup_type = 'BEN_BENMNGLE_MD'
    and    hr.lookup_type = l_mode_cd_lookup_type
    and    hr1.lookup_code (+)= bft.derivable_factors_flag -- Bug 3517604 Added outer join
    -- bug fix 1560336
    -- and    hr1.lookup_type = 'BEN_DTCT_TMPRL_LER_TYP'
    and    hr1.lookup_type (+)= l_drvbl_fctrs_lookup_type --  Bug 3517604 Added outer join
    and    hr2.lookup_code = bft.validate_flag
    and    hr2.lookup_type = 'YES_NO'
    and    hr3.lookup_code = bft.no_programs_flag
    and    hr3.lookup_type = 'YES_NO'
    and    hr4.lookup_code = bft.no_plans_flag
    and    hr4.lookup_type = 'YES_NO'
    and    hr5.lookup_code(+) = pop.enrt_typ_cycl_cd
    and    hr5.lookup_type(+) = 'BEN_ENRT_TYP_CYCL'
    and    fnd.status_code = fnd1.lookup_code
    and    fnd1.lookup_type = 'CP_STATUS_CODE'
    and    pop.popl_enrt_typ_cycl_id(+) = epo.popl_enrt_typ_cycl_id
    and    bft.process_date
           between nvl(pop.effective_start_date,bft.process_date)
           and     nvl(pop.effective_end_date,bft.process_date)
    and    epo.enrt_perd_id(+) = bft.popl_enrt_typ_cycl_id
    and    pln2.pl_id(+) = pop.pl_id
    and    bft.process_date
           between nvl(pln2.effective_start_date,bft.process_date)
           and     nvl(pln2.effective_end_date,bft.process_date)
    and    pgm2.pgm_id(+) = pop.pgm_id
    and    bft.process_date
           between nvl(pgm2.effective_start_date,bft.process_date)
           and     nvl(pgm2.effective_end_date,bft.process_date)
    and    ppf.person_id(+) = bft.person_id
    and    bft.process_date
           between nvl(ppf.effective_start_date,bft.process_date)
           and     nvl(ppf.effective_end_date,bft.process_date)
    and    pay.payroll_id(+) = bft.payroll_id
    and    bft.process_date
           between nvl(pay.effective_start_date,bft.process_date)
           and     nvl(pay.effective_end_date,bft.process_date)
    and    ppt.person_type_id(+) = bft.person_type_id
    and    pgm.pgm_id(+) = bft.pgm_id
    and    bft.process_date
           between nvl(pgm.effective_start_date,bft.process_date)
           and     nvl(pgm.effective_end_date,bft.process_date)
    and    pbg.business_group_id = bft.business_group_id
    and    org2.organization_id(+) = bft.legal_entity_id
    and    decode(org2.language,null,'1',org2.language)
                  = decode(org2.language,null,'1',userenv('LANG'))
    and    pln.pl_id(+) = bft.pl_id
    and    bft.process_date
           between nvl(pln.effective_start_date,bft.process_date)
           and     nvl(pln.effective_end_date,bft.process_date)
    and    ler.ler_id(+) = bft.ler_id
    and    bft.process_date
           between nvl(ler.effective_start_date,bft.process_date)
           and     nvl(ler.effective_end_date,bft.process_date)
    and    rzr.pstl_zip_rng_id(+) = bft.pstl_zip_rng_id
    and    bft.process_date
           between nvl(rzr.effective_start_date,bft.process_date)
           and     nvl(rzr.effective_end_date,bft.process_date)
    and    ptp.pl_typ_id(+) = bft.pl_typ_id
    and    bft.process_date
           between nvl(ptp.effective_start_date,bft.process_date)
           and     nvl(ptp.effective_end_date,bft.process_date)
    and    opt.opt_id(+) = bft.opt_id
    and    bft.process_date
           between nvl(opt.effective_start_date,bft.process_date)
           and     nvl(opt.effective_end_date,bft.process_date)
    and    ff.formula_id(+) = bft.comp_selection_rl
    and    bft.process_date
           between nvl(ff.effective_start_date,bft.process_date)
           and     nvl(ff.effective_end_date,bft.process_date)
    and    ff2.formula_id(+) = bft.person_selection_rl
    and    bft.process_date
           between nvl(ff2.effective_start_date,bft.process_date)
           and     nvl(ff2.effective_end_date,bft.process_date)
    and    bnr.rptg_grp_id(+) = bft.rptg_grp_id
    and    elp.eligy_prfl_id(+) = bft.eligy_prfl_id
    and    bft.process_date
           between nvl(elp.effective_start_date,bft.process_date)
           and     nvl(elp.effective_end_date,bft.process_date)
    and    vpf.vrbl_rt_prfl_id(+) = bft.vrbl_rt_prfl_id
    and    bft.process_date
           between nvl(vpf.effective_start_date,bft.process_date)
           and     nvl(vpf.effective_end_date,bft.process_date)
    and    org.organization_id(+) = bft.organization_id
    and    bft.process_date
           between nvl(org.date_from,bft.process_date)
           and     nvl(org.date_to,bft.process_date);
  --
  -- bug fix 1560336
  cursor c_conc_pgm_name is
    select conc.concurrent_program_name
    from   fnd_concurrent_requests fnd,
           fnd_concurrent_programs conc
    where  fnd.request_id = p_concurrent_request_id
    and    conc.concurrent_program_id = fnd.concurrent_program_id
    and    conc.application_id = 805;
  -- end fix 1560336

begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Default return values for nulls
  --
  fnd_message.set_name('BEN','BEN_91792_ALL_PROMPT');
  l_all := substrb(fnd_message.get,1,80);              -- Bug 2547948
  fnd_message.set_name('BEN','BEN_91793_NONE_PROMPT');
  l_none := substrb(fnd_message.get,1,80);	       -- Bug 2547948
  --
  -- bug fix 1560336
  open c_conc_pgm_name;
    --
    fetch c_conc_pgm_name into l_conc_pgm_name;
    if c_conc_pgm_name%FOUND then
      --
      if (l_conc_pgm_name = 'BENCLENR') then
        l_mode_cd_lookup_type := 'BEN_BENCLENR_MD' ;
        l_drvbl_fctrs_lookup_type := 'YES_NO' ;
      elsif (l_conc_pgm_name = 'BENDSGEL') then
        l_mode_cd_lookup_type := 'BEN_BENMNGLE_MD' ;
        l_drvbl_fctrs_lookup_type := 'YES_NO' ;
      /* bug 2950460 */
      elsif (l_conc_pgm_name in ('BENBOCON', 'BENFRCON', 'BENPRCON', 'BENEADEB')) then
        l_drvbl_fctrs_lookup_type := 'YES_NO';

      /* end 2950460 */
      end if ;
    end if ;
    --
  close c_conc_pgm_name;
  -- end fix 1560336
  --
  -- Get parameter information from batch process run
  --
  open c_benefit_actions;
    --
    fetch c_benefit_actions into p_process_date,
                                 p_mode,
                                 p_derivable_factors,
                                 p_validate,
                                 p_person,
                                 p_person_type,
                                 p_program,
                                 p_business_group,
                                 p_plan,
                                 p_popl_enrt_typ_cycl,
                                 p_plans_not_in_programs,
                                 p_just_programs,
                                 p_comp_object_selection_rule,
                                 p_person_selection_rule,
                                 p_life_event_reason,
                                 p_organization,
                                 p_postal_zip_range,
                                 p_reporting_group,
                                 p_plan_type,
                                 p_option,
                                 p_eligibility_profile,
                                 p_variable_rate_profile,
                                 p_legal_entity,
                                 p_payroll,
                                 p_concurrent_program_name,
                                 p_status;
    --
  close c_benefit_actions;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end standard_header;
-----------------------------------------------------------------------
procedure temporal_life_events
          (p_concurrent_request_id      in  number,
           p_age_changed                out nocopy varchar2,
           p_los_changed                out nocopy varchar2,
           p_comb_age_los_changed       out nocopy varchar2,
           p_pft_changed                out nocopy varchar2,
           p_comp_lvl_changed           out nocopy varchar2,
           p_hrs_wkd_changed            out nocopy varchar2,
	   p_loss_of_eligibility        out nocopy varchar2,
	   p_late_payment               out nocopy varchar2,
	   p_max_enrollment_rchd        out nocopy varchar2,
	   p_period_enroll_changed      out nocopy varchar2,
	   p_voulntary_end_cvg          out nocopy varchar2,
	   p_waiting_satisfied          out nocopy varchar2,
           p_persons_no_potential       out nocopy varchar2,
           p_persons_with_potential     out nocopy varchar2,
           p_number_of_events_created   out nocopy varchar2) is
  --
  l_proc                    varchar2(80) := g_package||'.temporal_life_events';

  --
  cursor c0 is
    select benefit_action_id
     from  ben_benefit_actions bft
    where  bft.request_id = p_concurrent_request_id ;
  --
  l_c0                      c0%rowtype;
  --
/* cursor c1 is
    select count(*) amount,ler.typ_cd
    from   ben_batch_ler_info bli,
           ben_benefit_actions bft,
           ben_ler_f ler,
           ben_person_actions bpa
    where  bft.benefit_action_id = bli.benefit_action_id
    and    bft.benefit_action_id = l_c0.benefit_action_id
    and    bpa.benefit_action_id = bft.benefit_action_id
    and    ler.ler_id = bli.ler_id
    and    bft.process_date between ler.effective_start_date and ler.effective_end_date
    and    bli.tmprl_flag = 'Y'
    and    bpa.benefit_action_id = bli.benefit_action_id
    and    bpa.person_id = bli.person_id
    and    bpa.action_status_cd  <> 'E'
    group  by ler.typ_cd;
*/
  cursor c1 is
    SELECT /*+ BEN_BATCH_REPORTING.temporal_life_events.c1 */
           COUNT(*) AMOUNT,LER.TYP_CD
    FROM BEN_BATCH_LER_INFO BLI,
         BEN_BENEFIT_ACTIONS BFT,
         BEN_LER_F LER
    WHERE BFT.BENEFIT_ACTION_ID = BLI.BENEFIT_ACTION_ID
    AND BLI.BENEFIT_ACTION_ID = l_c0.benefit_action_id
    AND LER.LER_ID = BLI.LER_ID
    AND BFT.PROCESS_DATE BETWEEN LER.EFFECTIVE_START_DATE AND LER.EFFECTIVE_END_DATE
    AND BLI.TMPRL_FLAG = 'Y'
    and BLI.PERSON_ID in
      (select BPA.PERSON_ID
       from BEN_PERSON_ACTIONS BPA
       where BPA.ACTION_STATUS_CD in ('P','U')
       AND BPA.BENEFIT_ACTION_ID = l_c0.benefit_action_id
      )
    GROUP BY LER.TYP_CD;

  --
  cursor c2 is
    select count(*)
    from   ben_person_actions pac,
           ben_benefit_actions bft
    where  bft.benefit_action_id = pac.benefit_action_id
/*    and    bft.request_id = p_concurrent_request_id */
    and    bft.benefit_action_id = l_c0.benefit_action_id
    and    pac.action_status_cd = 'P'
    and    exists (select null
                   from   ben_batch_ler_info bli
                   where  bli.benefit_action_id = bft.benefit_action_id
                   and    bli.person_id = pac.person_id
                   and    bli.tmprl_flag = 'Y');
  --
  cursor c3 is
    select count(*)
    from   ben_person_actions pac,
           ben_benefit_actions bft
    where  bft.benefit_action_id = pac.benefit_action_id
/*   and    bft.request_id = p_concurrent_request_id */
    and    bft.benefit_action_id = l_c0.benefit_action_id
    and    pac.action_status_cd = 'P'
    and    not exists (select null
                       from   ben_batch_ler_info bli
                       where  bli.benefit_action_id = bft.benefit_action_id
                       and    bli.person_id = pac.person_id
                       and    bli.tmprl_flag = 'Y');
  --
  l_age_changed          number := 0;
  l_los_changed          number := 0;
  l_comb_age_los_changed number := 0;
  l_pft_changed          number := 0;
  l_comp_lvl_changed     number := 0;
  l_hrs_wkd_changed      number := 0;

        l_loss_of_eligibility   number := 0;
	l_late_payment          number := 0;
	l_max_enrollment_rchd   number := 0;
	l_period_enroll_changed number := 0;
	l_voulntary_end_cvg     number := 0;
	l_waiting_satisfied     number := 0;

  l_c1                   c1%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  open c0;
  fetch c0 into l_c0 ;
  close c0 ;
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_c1;
      exit when c1%notfound;
      --
      if l_c1.typ_cd = 'DRVDAGE' then
        --
        l_age_changed := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDLOS' then
        --
        l_los_changed := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDCAL' then
        --
        l_comb_age_los_changed := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDHRW' then
        --
        l_hrs_wkd_changed := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDTPF' then
        --
        l_pft_changed := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDCMP' then
        --
        l_comp_lvl_changed := l_c1.amount;
        --
   -- Added another six codes for bug 3690166
      elsif l_c1.typ_cd = 'DRVDLSELG' then
        --
        l_loss_of_eligibility := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDNLP' then
        --
        l_late_payment := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDPOEELG' then
        --
        l_max_enrollment_rchd := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDPOERT' then
        --
        l_period_enroll_changed := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDVEC' then
        --
        l_voulntary_end_cvg := l_c1.amount;
        --
      elsif l_c1.typ_cd = 'DRVDWTGSTF' then
        --
        l_waiting_satisfied := l_c1.amount;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  open c2;
    --
    fetch c2 into p_persons_with_potential;
    --
  close c2;
  --
  open c3;
    --
    fetch c3 into p_persons_no_potential;
    --
  close c3;
  --
  p_age_changed          := l_age_changed;
  p_los_changed          := l_los_changed;
  p_comb_age_los_changed := l_comb_age_los_changed;
  p_pft_changed          := l_pft_changed;
  p_comp_lvl_changed     := l_comp_lvl_changed;
  p_hrs_wkd_changed      := l_hrs_wkd_changed;

-- Added for bug 3690166
  p_loss_of_eligibility     := l_loss_of_eligibility;
  p_late_payment            := l_late_payment          ;
  p_max_enrollment_rchd     := l_max_enrollment_rchd   ;
  p_period_enroll_changed   := l_period_enroll_changed ;
  p_voulntary_end_cvg       := l_voulntary_end_cvg     ;
  p_waiting_satisfied       := l_waiting_satisfied   ;

  p_number_of_events_created := l_age_changed +
                                l_los_changed +
                                l_comb_age_los_changed +
                                l_pft_changed +
                                l_comp_lvl_changed +
                                l_hrs_wkd_changed +
                                l_loss_of_eligibility +
                                l_late_payment +
                                l_max_enrollment_rchd +
                                l_period_enroll_changed +
                                l_voulntary_end_cvg +
                                l_waiting_satisfied ;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end temporal_life_events;
-----------------------------------------------------------------------
procedure process_information
          (p_concurrent_request_id      in  number,
           p_start_date                 out nocopy varchar2,
           p_end_date                   out nocopy varchar2,
           p_start_time                 out nocopy varchar2,
           p_end_time                   out nocopy varchar2,
           p_elapsed_time               out nocopy varchar2,
           p_persons_selected           out nocopy varchar2,
           p_persons_processed          out nocopy varchar2,
           p_persons_unprocessed        out nocopy varchar2,
           p_persons_processed_succ     out nocopy varchar2,
           p_persons_errored            out nocopy varchar2
      ) is
  --
  l_proc                    varchar2(80) := g_package||'.process_information';
  --
  cursor c_proc_info is
    select bpi.strt_dt,
           bpi.end_dt,
           bpi.strt_tm,
           bpi.end_tm,
           bpi.elpsd_tm,
           bpi.per_slctd,
           bpi.per_proc,
           bpi.per_unproc,
           bpi.per_proc_succ,
           bpi.per_err
    from   ben_batch_proc_info bpi,
           ben_benefit_actions bft
    where  bft.benefit_action_id = bpi.benefit_action_id
    and    bft.request_id = p_concurrent_request_id;
  --
  l_proc_info c_proc_info%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Get execution control data
  --
  open c_proc_info;
    --
    fetch c_proc_info into p_start_date,
                           p_end_date,
                           p_start_time,
                           p_end_time,
                           p_elapsed_time,
                           p_persons_selected,
                           p_persons_processed,
                           p_persons_unprocessed,
                           p_persons_processed_succ,
                           p_persons_errored;
  close c_proc_info;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end process_information;
-----------------------------------------------------------------------
procedure activity_summary_by_action
          (p_concurrent_request_id      in  number,
           p_without_active_life_event  out nocopy varchar2,
           p_with_active_life_event     out nocopy varchar2,
           p_no_life_event_created      out nocopy varchar2,
           p_life_event_open_and_closed out nocopy varchar2,
           p_life_event_created         out nocopy varchar2,
           p_life_event_still_active    out nocopy varchar2,
           p_life_event_closed          out nocopy varchar2,
           p_life_event_replaced        out nocopy varchar2,
           p_life_event_dsgn_only       out nocopy varchar2,
           p_life_event_choices         out nocopy varchar2,
           p_life_event_no_effect       out nocopy varchar2,
           p_life_event_rt_pr_chg       out nocopy varchar2) is
  --
  l_proc       varchar2(80) := g_package||'.activity_summary_by_action';
  --
   cursor c0 is
    select benefit_action_id
     from  ben_benefit_actions bft
    where  bft.request_id = p_concurrent_request_id ;
  --
  l_c0   c0%rowtype;
  --
  cursor c_ler_info is
    select replcd_flag,
           crtd_flag,
           not_crtd_flag,
           stl_actv_flag,
           clsd_flag,
           open_and_clsd_flag,
           bli.benefit_action_id,
           bli.person_id
    from   ben_batch_ler_info bli,
           ben_benefit_actions bft,
           ben_person_actions bpa
    where  bft.benefit_action_id = bli.benefit_action_id
    and    bli.tmprl_flag = 'N'
    and    bft.benefit_action_id = l_c0.benefit_action_id
    and    bpa.benefit_action_id = bft.benefit_action_id
    and    bpa.person_id = bli.person_id
    and    bpa.action_status_cd  <> 'E';

  l_ler_info                   c_ler_info%rowtype;

/* Convert to using count */
  cursor c_choices is
    select null
    from   ben_batch_elctbl_chc_info epe,
           ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe1
    where  epe.benefit_action_id = l_ler_info.benefit_action_id
    and    epe.person_id= l_ler_info.person_id
    and    pil.person_id=epe.person_id
    and    epe1.per_in_ler_id=pil.per_in_ler_id
    and    epe1.elctbl_flag='Y'
    and    rownum=1;
  cursor c_rate_prem_cvg_change is
  select   NULL
    from   ben_batch_ler_info bli
    where  bli.benefit_action_id = l_ler_info.benefit_action_id
    and    bli.person_id = l_ler_info.person_id
    and    exists (
             select null
             from   ben_prtt_enrt_rslt_f pen
             where  pen.per_in_ler_id=bli.per_in_ler_id
             and    rownum=1
             union
             select null
             from   ben_prtt_rt_val prv
             where  prv.per_in_ler_id=bli.per_in_ler_id
             and    rownum=1
             union
             select null
             from   ben_prtt_prem_f ppe
             where  ppe.per_in_ler_id=bli.per_in_ler_id
             and    rownum=1
           )
    and    rownum=1;
  --
  l_without_active_life_event  number :=0;
  l_with_active_life_event     number :=0;
  l_no_life_event_created      number :=0;
  l_life_event_open_and_closed number :=0;
  l_life_event_created         number :=0;
  l_life_event_still_active    number :=0;
  l_life_event_closed          number :=0;
  l_life_event_replaced        number :=0;
  --
  l_life_event_dsgn_only       number :=0;
  l_life_event_choices         number :=0;
  l_life_event_no_effect       number :=0;
  l_life_event_rt_pr_chg       number :=0;
  l_dummy                      varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  open c0 ;
  fetch c0 into l_c0;
  close c0;
  -- Get execution control data
  --
  open c_ler_info;
    --
    loop
      --
      fetch c_ler_info into l_ler_info;
      exit when c_ler_info%notfound;
      --
      if l_ler_info.replcd_flag = 'Y' then
        --
        l_with_active_life_event := l_with_active_life_event+1;
        l_life_event_replaced := l_life_event_replaced+1;
        --
      elsif l_ler_info.crtd_flag = 'Y' then
        --
        l_without_active_life_event := l_without_active_life_event+1;
        l_life_event_created        := l_life_event_created+1;
        --
        -- Count choices
        --
        open c_choices;
        fetch c_choices into l_dummy;
        if c_choices%found then
          l_life_event_choices:=l_life_event_choices+1;
        else
          --
          -- ben_batch_dpnt_info
          --
          -- Sum for person all choices
          --
          l_life_event_dsgn_only:=l_life_event_dsgn_only+1;
        end if;
        close c_choices;
        --
      elsif l_ler_info.not_crtd_flag = 'Y' then
        --
        l_without_active_life_event := l_without_active_life_event+1;
        l_no_life_event_created := l_no_life_event_created+1;
        --
      elsif l_ler_info.open_and_clsd_flag = 'Y' then
        --
        l_life_event_open_and_closed := l_life_event_open_and_closed+1;
        l_without_active_life_event := l_without_active_life_event+1;
        open c_rate_prem_cvg_change;
        fetch c_rate_prem_cvg_change into l_dummy;
        if c_rate_prem_cvg_change%found then
          l_life_event_rt_pr_chg:=l_life_event_rt_pr_chg+1;
        else
          l_life_event_no_effect:=l_life_event_no_effect+1;
        end if;
        close c_rate_prem_cvg_change;
        --
      elsif l_ler_info.stl_actv_flag = 'Y' then
        --
        l_life_event_still_active := l_life_event_still_active+1;
        l_with_active_life_event := l_with_active_life_event+1;
        --
      elsif l_ler_info.clsd_flag = 'Y' then
        --
        l_life_event_closed := l_life_event_closed+1;
        l_with_active_life_event := l_with_active_life_event+1;
        --
      end if;
      --
    end loop;
    --
  close c_ler_info;
  --
  p_without_active_life_event  := l_without_active_life_event;
  p_with_active_life_event     := l_with_active_life_event;
  p_no_life_event_created      := l_no_life_event_created;
  p_life_event_open_and_closed := l_life_event_open_and_closed;
  p_life_event_created         := l_life_event_created;
  p_life_event_still_active    := l_life_event_still_active;
  p_life_event_closed          := l_life_event_closed;
  p_life_event_replaced        := l_life_event_replaced;
  --
  p_life_event_dsgn_only       := l_life_event_dsgn_only;
  p_life_event_choices         := l_life_event_choices;
  p_life_event_no_effect       := l_life_event_no_effect;
  p_life_event_rt_pr_chg       := l_life_event_rt_pr_chg;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end activity_summary_by_action;
-----------------------------------------------------------------------
-- Procedure activity_summary_by_action is overloaded as two more parameters for life
-- event collapsed and life event collision added

procedure activity_summary_by_action
          (p_concurrent_request_id      in  number,
           p_without_active_life_event  out nocopy varchar2,
           p_with_active_life_event     out nocopy varchar2,
           p_no_life_event_created      out nocopy varchar2,
           p_life_event_open_and_closed out nocopy varchar2,
           p_life_event_created         out nocopy varchar2,
           p_life_event_still_active    out nocopy varchar2,
           p_life_event_closed          out nocopy varchar2,
           p_life_event_replaced        out nocopy varchar2,
           p_life_event_dsgn_only       out nocopy varchar2,
           p_life_event_choices         out nocopy varchar2,
           p_life_event_no_effect       out nocopy varchar2,
           p_life_event_rt_pr_chg       out nocopy varchar2,
    	      p_life_event_collapsed       out nocopy varchar2,
	      p_life_event_collision       out nocopy varchar2) is
  --
  l_proc       varchar2(80) := g_package||'.activity_summary_by_action';
  --
  --
  cursor c_ler_info is
    select replcd_flag,
           crtd_flag,
           not_crtd_flag,
           stl_actv_flag,
           clsd_flag,
           open_and_clsd_flag,
           clpsd_flag,
           clsn_flag,
           bli.benefit_action_id,
           bli.person_id
    from   ben_batch_ler_info bli,
           ben_benefit_actions bft,
/* Bug 2243050: Check whether the person has errored out nocopy */
           ben_person_actions bpa
/* Bug 2243050: Check whether the person has errored out nocopy */
    where  bft.benefit_action_id = bli.benefit_action_id
    and    bli.tmprl_flag = 'N'
    and    bft.request_id = p_concurrent_request_id
/* Bug 2243050: Check whether the person has errored out nocopy */
    and    bpa.benefit_action_id = bli.benefit_action_id
	and    bpa.person_id = bli.person_id
	and    bpa.action_status_cd  <> 'E';
/* Bug 2243050: Check whether the person has errored out nocopy */

  l_ler_info                   c_ler_info%rowtype;
  --
  cursor c_choices is
    select null
    from   ben_batch_elctbl_chc_info epe,
           ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe1
    where  epe.benefit_action_id = l_ler_info.benefit_action_id
    and    epe.person_id= l_ler_info.person_id
    and    pil.person_id=epe.person_id
    and    epe1.per_in_ler_id=pil.per_in_ler_id
    and    epe1.elctbl_flag='Y'
    and    rownum=1;
  cursor c_rate_prem_cvg_change is
  select   NULL
    from   ben_batch_ler_info bli
    where  bli.benefit_action_id = l_ler_info.benefit_action_id
    and    bli.person_id = l_ler_info.person_id
    and    exists (
             select null
             from   ben_prtt_enrt_rslt_f pen
             where  pen.per_in_ler_id=bli.per_in_ler_id
             and    rownum=1
             union
             select null
             from   ben_prtt_rt_val prv
             where  prv.per_in_ler_id=bli.per_in_ler_id
             and    rownum=1
             union
             select null
             from   ben_prtt_prem_f ppe
             where  ppe.per_in_ler_id=bli.per_in_ler_id
             and    rownum=1
           )
    and    rownum=1;
  --
  l_without_active_life_event  number :=0;
  l_with_active_life_event     number :=0;
  l_no_life_event_created      number :=0;
  l_life_event_open_and_closed number :=0;
  l_life_event_created         number :=0;
  l_life_event_still_active    number :=0;
  l_life_event_closed          number :=0;
  l_life_event_replaced        number :=0;
  --
  l_life_event_dsgn_only       number :=0;
  l_life_event_choices         number :=0;
  l_life_event_no_effect       number :=0;
  l_life_event_rt_pr_chg       number :=0;
  l_dummy                      varchar2(30);
  l_life_event_collapsed       number :=0;
  l_life_event_collision       number :=0;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Get execution control data
  --
  open c_ler_info;
    --
    loop
      --
      fetch c_ler_info into l_ler_info;
      exit when c_ler_info%notfound;
      --
      if l_ler_info.replcd_flag = 'Y' then
        --
        l_with_active_life_event := l_with_active_life_event+1;
        l_life_event_replaced := l_life_event_replaced+1;
        --
      elsif l_ler_info.crtd_flag = 'Y' then
        --
        l_without_active_life_event := l_without_active_life_event+1;
        l_life_event_created        := l_life_event_created+1;
        --
        -- Count choices
        --
        open c_choices;
        fetch c_choices into l_dummy;
        if c_choices%found then
          l_life_event_choices:=l_life_event_choices+1;
        else
          --
          --
          l_life_event_dsgn_only:=l_life_event_dsgn_only+1;
        end if;
        close c_choices;
        --
      elsif l_ler_info.not_crtd_flag = 'Y' then
        --
        l_without_active_life_event := l_without_active_life_event+1;
        l_no_life_event_created := l_no_life_event_created+1;
        --
      elsif l_ler_info.open_and_clsd_flag = 'Y' then
        --
        l_life_event_open_and_closed := l_life_event_open_and_closed+1;
        l_without_active_life_event := l_without_active_life_event+1;
        open c_rate_prem_cvg_change;
        fetch c_rate_prem_cvg_change into l_dummy;
        if c_rate_prem_cvg_change%found then
          l_life_event_rt_pr_chg:=l_life_event_rt_pr_chg+1;
        else
          l_life_event_no_effect:=l_life_event_no_effect+1;
        end if;
        close c_rate_prem_cvg_change;
        --
      elsif l_ler_info.clpsd_flag    = 'Y' then
        --
        l_life_event_collapsed   := l_life_event_collapsed +1;
        l_with_active_life_event := l_with_active_life_event+1;
        --
      elsif l_ler_info.clsn_flag  = 'Y' then
        --
        l_life_event_collision := l_life_event_collision +1;
        l_with_active_life_event := l_with_active_life_event+1;
        --
      elsif l_ler_info.stl_actv_flag = 'Y' then
        --
        l_life_event_still_active := l_life_event_still_active+1;
        l_with_active_life_event := l_with_active_life_event+1;
        --
      elsif l_ler_info.clsd_flag = 'Y' then
        --
        l_life_event_closed := l_life_event_closed+1;
        l_with_active_life_event := l_with_active_life_event+1;
        --
      end if;
      --
    end loop;
    --
  close c_ler_info;
  --
  p_without_active_life_event  := l_without_active_life_event;
  p_with_active_life_event     := l_with_active_life_event;
  p_no_life_event_created      := l_no_life_event_created;
  p_life_event_open_and_closed := l_life_event_open_and_closed;
  p_life_event_created         := l_life_event_created;
  p_life_event_still_active    := l_life_event_still_active;
  p_life_event_closed          := l_life_event_closed;
  p_life_event_replaced        := l_life_event_replaced;
  --
  p_life_event_dsgn_only       := l_life_event_dsgn_only;
  p_life_event_choices         := l_life_event_choices;
  p_life_event_no_effect       := l_life_event_no_effect;
  p_life_event_rt_pr_chg       := l_life_event_rt_pr_chg;
  p_life_event_collapsed       := l_life_event_collapsed;
  p_life_event_collision       := l_life_event_collision;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --

end activity_summary_by_action;
-------------------------------------------------------------------------------------------
procedure batch_reports
          (p_concurrent_request_id      in  number,
           p_mode                       in  varchar2 default 'S',
           p_report_type                in  varchar2) is
  --
  l_proc         varchar2(80) := g_package||'.batch_reports';
  l_program_name varchar2(30);
  l_retcode      number;
  l_errbuf       varchar2(2000);
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Reports are not relevant in collective agreement mode
  --
  if p_mode = 'A'
  then
    --
    return;
    --
  end if;
  --
  -- This report runs a concurrent request to submit a reportwriter action.
  -- The procedure is used as an easy way to call batch reports from
  -- batch processes.
  --
  if p_report_type = 'GENERIC_LOG' then
    --
    l_program_name := 'BENGELOG';
    --
  elsif p_report_type = 'ACTIVITY_SUMMARY' then
    --
    if p_mode in ('L','M') then
      --
      l_program_name := 'BENACTIV';
      --
    elsif p_mode = 'S' then
      --
      l_program_name := 'BENACTIV';
      --
    --
    -- CWB Change : Extend the C mode to W (Comp Workbench mode)
    --
    elsif p_mode in ('C', 'W') then
      --
      l_program_name := 'BENACTIV';
      --
    elsif p_mode = 'T' then
      --
      l_program_name := 'BENACTIV';
      --
    --
    -- Bug 2945455 -- Personal Action Changes
    --
    elsif p_mode = 'P' then
      --
      l_program_name := 'BENACTIV';
      --
    -- 2940151
    elsif p_mode = 'G' then
      --
      l_program_name := 'BENACTIV';
      --

    end if;
    --
  elsif p_report_type = 'ERROR_BY_ERROR_TYPE' then
    --
    l_program_name := 'BENERRTY';
    --
  elsif p_report_type = 'ERROR_BY_PERSON' then
    --
    l_program_name := 'BENERRPE';
    --
  end if;
  --
  submit_request(errbuf                  => l_errbuf,
                 retcode                 => l_retcode,
                 p_program_name          => l_program_name,
                 p_concurrent_request_id => p_concurrent_request_id);
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end batch_reports;
-----------------------------------------------------------------------
procedure submit_request(errbuf                  out nocopy varchar2,
                         retcode                 out nocopy number,
                         p_program_name          in  varchar2,
                         p_concurrent_request_id in  number) is
  --
  l_proc       varchar2(80) := g_package||'.submit_request';
  l_request_id number;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  l_request_id := fnd_request.submit_request
        (application => 'BEN',
         program     => p_program_name,
         description => NULL,
         sub_request => FALSE,
         argument1   => p_concurrent_request_id);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('BEN','BEN_92110_CONC_REQUEST');
    fnd_message.set_token('NAME',p_program_name);
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end submit_request;
-----------------------------------------------------------------------
procedure event_summary(
  p_concurrent_request_id in number,
  p_life_event_totals     out nocopy ben_batch_reporting.le_total
) is
  --
  cursor c_ler_detail_info is
    select replcd_flag,
           crtd_flag,
           not_crtd_flag,
           stl_actv_flag,
           clsd_flag,
           open_and_clsd_flag,
           ler.name
    from   ben_batch_ler_info bli,
           ben_benefit_actions bft,
           ben_ler_f ler
    where  bft.benefit_action_id = bli.benefit_action_id
    and    bft.request_id = p_concurrent_request_id
    and    bli.ler_id=ler.ler_id
    and    trunc(sysdate) between
             ler.effective_start_date and ler.effective_end_date
  ;
  --
  l_life_event_totals ben_batch_reporting.le_total;
  l_number_rows number:=0;
  l_new_closed_cd varchar2(1);
  l_found boolean;
  --
begin
  for l_row in c_ler_detail_info loop
    if l_row.crtd_flag='Y' then
      l_new_closed_cd:='C';
    elsif l_row.open_and_clsd_flag='Y' then
      l_new_closed_cd:='N';
    else
      l_new_closed_cd:=null;
    end if;
    if l_new_closed_cd is not null then
      if l_number_rows=0 then
        l_number_rows:=l_number_rows+1;
        l_life_event_totals(l_number_rows).ler_name:=l_row.name;
        l_life_event_totals(l_number_rows).total:=1;
        l_life_event_totals(l_number_rows).new_closed_cd:=l_new_closed_cd;
      else
        l_found:=false;
        for i in 1..l_number_rows loop
          if l_life_event_totals(i).ler_name=l_row.name and
             l_life_event_totals(i).new_closed_cd=l_new_closed_cd then
            l_life_event_totals(i).total:=l_life_event_totals(i).total+1;
            l_found:=true;
            exit;
          end if;
        end loop;
        if not l_found then
          l_number_rows:=l_number_rows+1;
          l_life_event_totals(l_number_rows).ler_name:=l_row.name;
          l_life_event_totals(l_number_rows).total:=1;
          l_life_event_totals(l_number_rows).new_closed_cd:=l_new_closed_cd;
        end if;
      end if;
    end if;
  end loop;
  p_life_event_totals:=l_life_event_totals;
end event_summary;
-----------------------------------------------------------------------
end ben_batch_reporting;

/
