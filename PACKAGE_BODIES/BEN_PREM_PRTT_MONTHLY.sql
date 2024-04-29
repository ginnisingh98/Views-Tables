--------------------------------------------------------
--  DDL for Package Body BEN_PREM_PRTT_MONTHLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PREM_PRTT_MONTHLY" as
/* $Header: benprprm.pkb 120.2.12010000.4 2009/01/13 08:57:58 pvelvano ship $ */
/*
================================================================================
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
================================================================================

Name
	Premium Participant Monthly
Purpose
	This package is used to calculate participant monthly premiums.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        02 Jun 99        lmcdonal   115.0      Created.
        06 Jul 99        lmcdonal   115.1      Added cost-allocation writing.
                                               Added reporting.
        09 Jul 99        jcarpent   115.2      Added checks for backed out nocopy pil
        19 Jul 99        lmcdonal   115.3      Task 418.  Check upper and lower
                                               limits on partial month values.
                                               Execute rules. genutils to benutils.
        27 Jul 99        lmcdonal   115.4      Allow prtl_mo_rt_prtn_val from and
                                               to dy_mo_num's to be null.
        05 Aug 99        lmcdonal   115.5      Allow strt_r_stp_cd to be ETHR.
        06 Aug 99        lmcdonal   115.6      Better set locations.
        19 Aug 99        lmcdonal   115.7      Add premium_warning.
        01 Oct 99        jcarpent   115.8      Changed compute_partial_mo to
                                               call benelmen.prorate_amount
        03 Nov 99        lmcdonal   115.9      region_2 was defined as number,
                                               should be char.
        08 Nov 99        lmcdonal   115.10      cleanup some comments.
        15 Feb 00        lmcdonal   115.11     clear out nocopy l_opt if not loaded
                                               from cursor.
        08 May 00        lmcdonal   115.12     Bug 1277372, don't create monthly
                                               premium record for prior months
                                               if result was not created this
                                               month.
        23 Jun 00        jcarpent   115.13     Bug 5322, back out nocopy of prev fix
                                               to version from 115.11 since
                                               115.12 did not fix bug 5127/
                                               1277372 anyway, and messed up
                                               prior functionality.
        25 Jul 00        pbodla     115.14   - Bug 5127 When premium process
                                               is rerun,If manual adjustement flag
                                               is Y, Do not revert back to the
                                               standard premium value
        27-aug-01        tilak      115.15     bug:1949361 jurisdiction code is
                                               derived inside benutils.formula.
        31-aug-01        tilak      115.16    1970990, update_prtt_prem_by_mo is
                                              called only when there is a changes
                                              in uom or val
        04-aug-01        tilak      115.17    cost_allocation_keyflex_id added in
                                              the condition to call update_prtt_prem_by_mo
        13-mar-02        ikasire    115.18    UTF8 changes
        14-mar-02        ikasire    115.19    GSCC errors
        08-Jun-02        pabodla    115.20    Do not select the contingent worker
                                              assignment when assignment data is
                                              fetched.
        30-Dec-02        mmudigon   115.21    NOCOPY
        21-feb-03        vsethi     115.22    Bug 2784213. Premium records should be
        				      created with effective date of end of
        				      every month and not process date
        30-Jan-04        ikasire    115.23    Bug3379060 Proration doesnot work if
                                              the coverage starts on first on a
                                              Month
        12-Jul-04        tjesumic   115.24    NONE code calcualtion is changed
                                              if the start and end mont is not partial , partiam_mo is not
                                              called. bug 3742713
        07-Sep-04        tjesumic   115.25    charges created when credit and debit exisit for a month
                                              and credit is no more valid# 3879156
        07-Sep-04        tjesumic   115.26    # 3879156
        08-Sep-04        tjesumic   115.27    # 3666347 where to end the calucaltion logic changed
        14-Sep-04        tjesumic   115.28    # 3666347 the lookback period added to end the calcualtion
        14-Sep-04        tjesumic   115.29    # 3666347 where to end the calucaltion validated the premium start date
                                              instead of effective end date. OSB may not have date tracked result but prem
        22-Mar-05        tjesumic   115.30    # 4222031 Whne a plan start and end on the same month and wash rule is
                                              defined , the end date is used for premium computation
        21-jun-2005      tjesumic   115.31    round of the date to chnged to trunc to find the first date of the month
        20-Dec-05        abparekh   115.32    Bug 4892354 : In procedure compute_prem get valid update modes before
                                                            updating PRM record
        22-Feb-08        rtagarra   115.33    Bug 6840074
	20-Oct-08        sallumwa   115.34    Bug 7414822 : Do not write into ben_reporting table when the coverage for
	                                      the same is end-dated.
        13-Jan-09        pvelvano   115.35    Bug 7676969 : Premium Calculation Summary Report is summing the previous
	                                      enrollments amounts for COBRA Participant.

*/
--------------------------------------------------------------------------------
g_package             varchar2(80) := 'ben_prem_prtt_monthly';
-- ----------------------------------------------------------------------------
-- |------------------------< get_rule_data >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used to get data needed when calling fast formula.
procedure get_rule_data(p_person_id in number
                         ,p_business_group_id in number
                         ,p_effective_date    in date
                         ,p_assignment_id     out nocopy number
                         ,p_location_id       out nocopy number
                         ,p_organization_id   out nocopy number
                         ,p_region_2          out nocopy varchar2
                         ,p_jurisdiction      out nocopy varchar2)is
  l_package               varchar2(80) := g_package||'.get_rule_data';

  cursor csr_asg is
    select asg.assignment_id, asg.organization_id, loc.region_2, asg.location_id
      from hr_locations_all loc, per_assignments_f asg
      where asg.person_id = p_person_id
      and   asg.primary_flag = 'Y'
      and   asg.assignment_type <> 'C'
      and   loc.location_id(+) = asg.location_id
      and   asg.business_group_id+0 = p_business_group_id
      and   p_effective_date between
            asg.effective_start_date and asg.effective_end_date
      order by 1;

  l_jurisdiction PAY_CA_EMP_PROV_TAX_INFO_F.JURISDICTION_CODE%type := null;

begin
  hr_utility.set_location ('Entering '||l_package,10);
  open csr_asg;
  fetch csr_asg into p_assignment_id, p_organization_id,
        p_region_2, p_location_id;
  if csr_asg%NOTFOUND or csr_asg%NOTFOUND is null then
     p_assignment_id := null;
     p_organization_id := null;
     p_region_2 := null;
  end if;
  close csr_asg;
  --if p_region_2 is not null then
  --   p_jurisdiction := pay_mag_utils.lookup_jurisdiction_code
  --                             (p_state => p_region_2);
  --else
     p_jurisdiction := null;
  --end if;
  hr_utility.set_location ('Leaving '||l_package,99);
end get_rule_data;

-- ----------------------------------------------------------------------------
-- |------------------------< determine_costing >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used to compute and write costing info from actl_prem to
-- cost_allocation_keyflex.
procedure determine_costing
                   (p_actl_prem_id        in number
                   ,p_effective_date      in date
                   ,p_business_group_id   in number
                   ,p_person_id           in number
                   ,p_cak_id              out nocopy number) is
  --
  l_package               varchar2(80) := g_package||'.determine_costing';
  l_error_text            varchar2(200) := null;
  --

  cursor csr_cost_id is
    select pbg.cost_allocation_structure
      from per_business_groups pbg
      where pbg.business_group_id+0 = p_business_group_id;
  l_cost_id               fnd_id_flex_segments.id_flex_num%TYPE;

  cursor csr_apr_cak is
    select segment1, segment2, segment3, segment4, segment5, segment6,
           segment7, segment8, segment9, segment10, segment11, segment12,
           segment13, segment14, segment15, segment16, segment17, segment18,
           segment19, segment20, segment21, segment22, segment23, segment24,
           segment25, segment26, segment27, segment28, segment29, segment30
      from pay_cost_allocation_keyflex cak, ben_actl_prem_f apr
      where apr.actl_prem_id = p_actl_prem_id
      and   apr.cost_allocation_keyflex_id = cak.cost_allocation_keyflex_id
      and   apr.business_group_id+0 = p_business_group_id
      and   p_effective_date between
            nvl(cak.start_date_active, p_effective_date)
            and nvl(cak.end_date_active, p_effective_date)
      and   cak.enabled_flag = 'Y'
      and   p_effective_date between
            apr.effective_start_date and apr.effective_end_date;
  --l_apr_cak c_apr_cak%rowtype;
  l_apr_cak           g_apr_cak_table;

  /* type g_apr_cak_rec is record
  (segment varchar2(60));

  type g_apr_cak_table is table of g_apr_cak_rec
  index by binary_integer;
  */

  cursor csr_cbs is
    select cbs.sgmt_num, cbs.sgmt_cstg_mthd_cd, cbs.sgmt_cstg_mthd_rl
      from ben_prem_cstg_by_sgmt_f cbs
      where cbs.actl_prem_id = p_actl_prem_id
      and   cbs.business_group_id+0 = p_business_group_id
      and   p_effective_date between
            cbs.effective_start_date and cbs.effective_end_date
      order by 1;
  --l_cbs c_cbs%rowtype;

  cursor csr_asg is
    select asg.assignment_id, asg.organization_id, loc.region_2, asg.location_id
      from hr_locations_all loc, per_assignments_f asg
      where asg.person_id = p_person_id
      and   asg.assignment_type <> 'C'
      and   asg.primary_flag = 'Y'
      and   loc.location_id(+) = asg.location_id
      and   asg.business_group_id+0 = p_business_group_id
      and   p_effective_date between
            asg.effective_start_date and asg.effective_end_date
      order by 1;
  l_asg csr_asg%rowtype;

  l_effective_date       date;
  l_session_id           number;
  l_segments             pay_cost_allocation_keyflex.concatenated_segments%TYPE;
  l_cnt                  number;
  l_cnt2                 number;
  l_outputs              ff_exec.outputs_t;

begin
  hr_utility.set_location ('Entering '||l_package,10);
  l_effective_date := trunc(p_effective_date);
  --
  --
  -- Look for cost allocation definition
  open csr_cost_id;
  fetch csr_cost_id into l_cost_id;
  if csr_cost_id%FOUND then
  hr_utility.set_location(l_package, 27);

    -- get the actl-prem cost-allocation info to copy to the prtt-prem cost-allocation.
    open csr_apr_cak;
    fetch csr_apr_cak into l_apr_cak(1).sgmt, l_apr_cak(2).sgmt,
        l_apr_cak(3).sgmt, l_apr_cak(4).sgmt,
        l_apr_cak(5).sgmt, l_apr_cak(6).sgmt, l_apr_cak(7).sgmt,
        l_apr_cak(8).sgmt, l_apr_cak(9).sgmt,
        l_apr_cak(10).sgmt, l_apr_cak(11).sgmt, l_apr_cak(12).sgmt,
        l_apr_cak(13).sgmt, l_apr_cak(14).sgmt,
        l_apr_cak(15).sgmt, l_apr_cak(16).sgmt, l_apr_cak(17).sgmt,
        l_apr_cak(18).sgmt, l_apr_cak(19).sgmt,
        l_apr_cak(20).sgmt, l_apr_cak(21).sgmt, l_apr_cak(22).sgmt,
        l_apr_cak(23).sgmt, l_apr_cak(24).sgmt,
        l_apr_cak(25).sgmt, l_apr_cak(26).sgmt, l_apr_cak(27).sgmt,
        l_apr_cak(28).sgmt, l_apr_cak(29).sgmt,
        l_apr_cak(30).sgmt;
    if csr_apr_cak%FOUND then
      hr_utility.set_location(l_package, 29);

      -- check for overrides to the actl-prem cost-allocation info, stored in
      -- prem-cstg-by-sgmt.
      open csr_asg;
      fetch csr_asg into l_asg;
      if csr_asg%FOUND  then
         -- if we find an assignment we can override the values in the actl-prem
         -- cost allocation.  if not, use all the values from actl-prem.
         l_cnt := 1;
         for l_cbs in csr_cbs loop
           if l_cbs.sgmt_num > 30 or l_cbs.sgmt_num < 1 or l_cbs.sgmt_num is null then
             fnd_message.set_name('BEN', 'BEN_92247_INVALID_SGMT_NUM');
             fnd_message.raise_error;
           end if;
           for crt in l_cnt..30 loop
             if l_cbs.sgmt_num = crt then
                if l_cbs.sgmt_cstg_mthd_cd = 'UOFA' then
                   -- use org from assignment
                   l_apr_cak(crt).sgmt := l_asg.organization_id;
                elsif l_cbs.sgmt_cstg_mthd_cd = 'ULFA' then
                   -- use loc from assignment
                   l_apr_cak(crt).sgmt := l_asg.location_id;
                elsif l_cbs.sgmt_cstg_mthd_cd = 'UCCFA' then
                   -- use cost center from assignment  ??
                   l_apr_cak(crt).sgmt := null;  --l_asg.location_id;
                elsif l_cbs.sgmt_cstg_mthd_cd = 'RL' then
                   -- use rule  ??
                   /* l_outputs := benutils.formula
                  (p_formula_id        => l_cbs.sgmt_cstg_mthd_rl,
                   p_effective_date    => p_effective_date,
                   p_business_group_id => p_business_group_id,
                   p_assignment_id     => l_asg.assignment_id,
                   p_organization_id   => l_asg.organization_id,
                   p_pgm_id	    => l_epe.pgm_id,
                   p_pl_id		    => l_epe.pl_id,
                   p_pl_typ_id	    => l_epe.pl_typ_id,
                   p_opt_id	    => l_opt.opt_id,
                   p_ler_id	    => l_epe.ler_id,
                   p_jurisdiction_code => pay_mag_utils.lookup_jurisdiction_code
                               (p_state => l_state.region_2)
                      );
                   p_val := l_outputs(l_outputs.first).value;
                   */
                   null;
                end if;
                l_cnt2 := crt + 1;
                exit;
             end if;
           end loop;
           l_cnt := l_cnt2;
         end loop;
      end if;
      close csr_asg;

      hr_utility.set_location(l_package, 31);

      hr_kflex_utility.ins_or_sel_keyflex_comb
            (p_appl_short_name        => 'PAY'
            ,p_flex_code              => 'COST'
            ,p_flex_num               => l_cost_id
            ,p_segment1               => l_apr_cak(1).sgmt
            ,p_segment2               => l_apr_cak(2).sgmt
            ,p_segment3               => l_apr_cak(3).sgmt
            ,p_segment4               => l_apr_cak(4).sgmt
            ,p_segment5               => l_apr_cak(5).sgmt
            ,p_segment6               => l_apr_cak(6).sgmt
            ,p_segment7               => l_apr_cak(7).sgmt
            ,p_segment8               => l_apr_cak(8).sgmt
            ,p_segment9               => l_apr_cak(9).sgmt
            ,p_segment10              => l_apr_cak(10).sgmt
            ,p_segment11              => l_apr_cak(11).sgmt
            ,p_segment12              => l_apr_cak(12).sgmt
            ,p_segment13              => l_apr_cak(13).sgmt
            ,p_segment14              => l_apr_cak(14).sgmt
            ,p_segment15              => l_apr_cak(15).sgmt
            ,p_segment16              => l_apr_cak(16).sgmt
            ,p_segment17              => l_apr_cak(17).sgmt
            ,p_segment18              => l_apr_cak(18).sgmt
            ,p_segment19              => l_apr_cak(19).sgmt
            ,p_segment20              => l_apr_cak(20).sgmt
            ,p_segment21              => l_apr_cak(21).sgmt
            ,p_segment22              => l_apr_cak(22).sgmt
            ,p_segment23              => l_apr_cak(23).sgmt
            ,p_segment24              => l_apr_cak(24).sgmt
            ,p_segment25              => l_apr_cak(25).sgmt
            ,p_segment26              => l_apr_cak(26).sgmt
            ,p_segment27              => l_apr_cak(27).sgmt
            ,p_segment28              => l_apr_cak(28).sgmt
            ,p_segment29              => l_apr_cak(29).sgmt
            ,p_segment30              => l_apr_cak(30).sgmt
            ,p_concat_segments_in     => null
            ,p_ccid                   => p_cak_id  -- out
            ,p_concat_segments_out    => l_segments  -- out
             );

      hr_utility.set_location(l_package, 35);
    end if;
    close csr_apr_cak;

  end if;
  close csr_cost_id;

  hr_utility.set_location ('Leaving '||l_package,99);
exception
  when others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package,999);
    hr_utility.set_location('Error:'||l_error_text,999);
    fnd_message.raise_error;
end determine_costing;

-- ----------------------------------------------------------------------------
-- |------------------------< premium_warning >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used to create warning messages for premiums.
procedure premium_warning
          (p_person_id            in number default null
          ,p_prtt_enrt_rslt_id    in number
          ,p_effective_start_date in date
          ,p_effective_date       in date
          ,p_warning              in varchar2)is
  l_package               varchar2(80) := g_package||'.premium_warning';

  cursor c_person (p_person_id number) is
  select full_name from per_people_f
  where person_id = p_person_id
     and p_effective_date between effective_start_date
	 and effective_end_date;
  l_full_name per_all_people_f.full_name%TYPE := ''; -- UTF8 varchar2(240) := '';

  cursor c_premium (p_prtt_enrt_rslt_id number,
        p_effective_start_date date, p_effective_date date) is
  select distinct 'Y'
  from ben_prtt_prem_by_mo_f prm, ben_prtt_prem_f ppe
  where ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and ppe.prtt_prem_id = prm.prtt_prem_id
    -- any premiums between esd of result and date we are voided it
    and to_date(to_char(prm.mo_num)||'-'||to_char(prm.yr_num), 'mm-yyyy')
        between p_effective_start_date and p_effective_date
    and p_effective_date between ppe.effective_start_date
    and ppe.effective_end_date
    and p_effective_date between prm.effective_start_date
    and prm.effective_end_date;
 l_premiums_exist varchar2(1) := 'N';
 l_message        fnd_new_messages.message_name%type := 'BEN_92320_INVALID_WARNING';
begin
  hr_utility.set_location ('Entering '||l_package,10);

     -- write warning messages if a premium exists during the time that
     -- the result was created thru to the time that we are doing something
     -- in correction mode.
     open c_premium(p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
          p_effective_start_date =>
          to_date(to_char(p_effective_start_date, 'mm-yyyy'), 'mm-yyyy'),
          p_effective_date => p_effective_date);
     fetch c_premium into l_premiums_exist;
     if c_premium%FOUND then
        if p_person_id is not null then
           open c_person(p_person_id => p_person_id);
           fetch c_person into l_full_name;
           close c_person;
        end if;

        if p_warning = 'VOID' then
           l_message := 'BEN_92316_VOID_CORR_OLD';
        elsif p_warning = 'SUSPEND' then
           l_message := 'BEN_92315_SUS_CORR_OLD';
        elsif p_warning = 'UNSUSPEND' then
           l_message := 'BEN_92314_UNSUS_CORR_OLD';
        end if;

        ben_warnings.load_warning
           (p_application_short_name  => 'BEN',
            p_message_name            => l_message,
            p_parma     => l_full_name,
            p_person_id => p_person_id);

     end if;
     close c_premium;

  hr_utility.set_location ('Leaving '||l_package,99);
end premium_warning;

-- ----------------------------------------------------------------------------
-- |------------------------< compute_partial_mo >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used to compute partial month premiums.  it's called internally
-- and from benprprc.pkb
procedure compute_partial_mo
                   (p_business_group_id   in number
                   ,p_effective_date      in date
                   ,p_actl_prem_id        in number
                   ,p_person_id           in number
                   ,p_enrt_cvg_strt_dt    in date
                   ,p_enrt_cvg_thru_dt    in date
                   ,p_prtl_mo_det_mthd_cd in varchar2 default null
                   ,p_prtl_mo_det_mthd_rl in number   default null
                   ,p_wsh_rl_dy_mo_num    in number   default null
                   ,p_rndg_cd             in varchar2 default null
                   ,p_rndg_rl             in number   default null
                   ,p_lwr_lmt_calc_rl     in number   default null
                   ,p_lwr_lmt_val         in number   default null
                   ,p_upr_lmt_calc_rl     in number   default null
                   ,p_upr_lmt_val         in number   default null
                   ,p_pgm_id              in number   default null
                   ,p_pl_typ_id           in number   default null
                   ,p_pl_id               in number   default null
                   ,p_opt_id              in number   default null
                   ,p_val                 in out nocopy number) is
  --
  l_package              varchar2(80) := g_package||'.compute_partial_mo';
  l_error_text           varchar2(200) := null;
  --
  l_val                  number;

  -- Rules variables:
  l_outputs              ff_exec.outputs_t;
  l_prtl_mo_det_mthd_cd  varchar2(30);
  l_jurisdiction         PAY_CA_EMP_PROV_TAX_INFO_F.JURISDICTION_CODE%type :=
                         null;
  l_assignment_id        number;
  l_location_id          number;
  l_organization_id      number;
  l_region_2             hr_locations_all.region_2%TYPE; -- UTF8 varchar2(70);
  l_start_or_stop_cd     varchar2(30);
  l_start_or_stop_date   date;
  l_prorate_flag         varchar2(30);
  --
begin
  hr_utility.set_location ('Entering '||l_package,10);
  -- load the full premium into a local.  This may change to a pro-rated
  -- or zero value.
  get_rule_data(p_person_id => p_person_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               ,p_assignment_id     => l_assignment_id
               ,p_location_id       => l_location_id
               ,p_organization_id   => l_organization_id
               ,p_region_2          => l_region_2
               ,p_jurisdiction      => l_jurisdiction);
  l_val := p_val;
  hr_utility.set_location ('Proration code to use: '||
                           p_prtl_mo_det_mthd_cd,20);
  if p_enrt_cvg_strt_dt is not null then
    hr_utility.set_location ('coverage started this month '||
                             l_package,14);
    l_start_or_stop_cd:='STRT';
    l_start_or_stop_date:=p_enrt_cvg_strt_dt;
  elsif p_enrt_cvg_thru_dt is not null then
    -- coverage ended this month....
    hr_utility.set_location ('coverage ended this month '||
                             l_package,20);
    l_start_or_stop_cd:='STP';
    l_start_or_stop_date:=p_enrt_cvg_thru_dt;
  end if;
  if l_start_or_stop_cd is not null then
    l_prtl_mo_det_mthd_cd:=p_prtl_mo_det_mthd_cd;
    l_val:=ben_element_entry.prorate_amount(
       p_amt                  =>l_val
      ,p_actl_prem_id         =>p_actl_prem_id
      ,p_person_id            =>p_person_id
      ,p_rndg_cd              =>p_rndg_cd
      ,p_rndg_rl              =>p_rndg_rl
      ,p_pgm_id               =>p_pgm_id
      ,p_pl_typ_id            =>p_pl_typ_id
      ,p_pl_id                =>p_pl_id
      ,p_opt_id               =>p_opt_id
      ,p_ler_id               =>null
      ,p_prorate_flag         =>l_prorate_flag
      ,p_effective_date       =>p_effective_date
      ,p_start_or_stop_cd     =>l_start_or_stop_cd
      ,p_start_or_stop_date   =>l_start_or_stop_date
      ,p_business_group_id    =>p_business_group_id
      ,p_assignment_id        =>l_assignment_id
      ,p_organization_id      =>l_organization_id
      ,p_jurisdiction_code    =>l_jurisdiction
      ,p_wsh_rl_dy_mo_num     =>p_wsh_rl_dy_mo_num
      ,p_prtl_mo_det_mthd_cd  =>l_prtl_mo_det_mthd_cd
      ,p_prtl_mo_det_mthd_rl  =>p_prtl_mo_det_mthd_rl
    );
    hr_utility.set_location ('Proration code used: '||
                             l_prtl_mo_det_mthd_cd,20);
  end if;
  --
  -- Since we are changing the value of the premium,
  -- re-check the upper and lower limits.
  --
  if l_val <> p_val then
    hr_utility.set_location('Variable Limits Checking'||l_package,68);
    -- get data needed for rules, if we didn't already get it.
    if p_lwr_lmt_calc_rl is not null or p_upr_lmt_calc_rl is not null then
      null;
    else
      l_assignment_id := null;
      l_organization_id := null;
      l_region_2 := null;
      l_jurisdiction := null;
    end if;
    benutils.limit_checks
              (p_upr_lmt_val        => p_upr_lmt_val,
               p_lwr_lmt_val        => p_lwr_lmt_val,
               p_upr_lmt_calc_rl    => p_upr_lmt_calc_rl,
               p_lwr_lmt_calc_rl    => p_lwr_lmt_calc_rl,
               p_effective_date     => p_effective_date,
               p_business_group_id  => p_business_group_id,
               p_assignment_id      => l_assignment_id,
               p_organization_id    => l_organization_id,
               p_pgm_id	            => p_pgm_id,
               p_pl_id		      => p_pl_id,
               p_pl_typ_id	      => p_pl_typ_id,
               p_opt_id	            => p_opt_id,
               p_ler_id	            => null,  -- we aren't dealing with a ler.
               p_state              => l_region_2,
               p_val                => l_val);

  end if;
  p_val := l_val;
  hr_utility.set_location ('Leaving '||l_package,99);
exception
  when others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package,999);
    hr_utility.set_location('Error:'||l_error_text,999);
    fnd_message.raise_error;
end compute_partial_mo;
-- ----------------------------------------------------------------------------
-- |------------------------------< compute_prem >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used internally to compute and write premium records.
procedure compute_prem
                   (p_validate            in varchar2 default 'N'
                   ,p_person_id           in number
                   ,p_business_group_id   in number
                   ,p_effective_date      in date
                   ,p_first_day_of_month  in date
                   ,p_last_day_of_month   in date
                   ,p_enrt_cvg_strt_dt    in date
                   ,p_enrt_cvg_thru_dt    in date
                   ,p_prtl_mo_det_mthd_cd in varchar2 default null
                   ,p_prtl_mo_det_mthd_rl in number   default null
                   ,p_wsh_rl_dy_mo_num    in number   default null
                   ,p_rndg_cd             in varchar2 default null
                   ,p_rndg_rl             in number   default null
                   ,p_lwr_lmt_calc_rl     in number   default null
                   ,p_lwr_lmt_val         in number   default null
                   ,p_upr_lmt_calc_rl     in number   default null
                   ,p_upr_lmt_val         in number   default null
                   ,p_pgm_id              in number   default null
                   ,p_pl_typ_id           in number   default null
                   ,p_pl_id               in number   default null
                   ,p_opt_id              in number   default null
                   ,p_val                 in number
                   ,p_actl_prem_id        in number
                   ,p_prtt_prem_id        in number
                   ,p_mo_num              in number
                   ,p_uom                 in varchar2
                   ,p_yr_num              in number
                   ,p_stop_looking        out nocopy varchar2
                   ,p_out_val             out nocopy number) is
  --
  l_package               varchar2(80) := g_package||'.compute_prem';
  l_error_text            varchar2(200) := null;
  --

  cursor c_prm (p_prtt_prem_id number) is
    select prm.prtt_prem_by_mo_id, prm.object_version_number,
           prm.mnl_adj_flag,prm.uom,prm.val,prm.cr_val,prm.cost_allocation_keyflex_id
           , effective_start_date
    from ben_prtt_prem_by_mo_f prm
    where  prm.mo_num = p_mo_num
    and    prm.yr_num = p_yr_num
    and    prm.prtt_prem_id = p_prtt_prem_id
    -- order by make sure all the time cursor hit the first row
    order by prm.effective_start_date ;
    --and    p_effective_date between prm.effective_start_date and prm.effective_end_date; -- bug 2784213
  l_prm c_prm%rowtype;


   cursor c_prm_ovn (p_prtt_prem_id number,p_effective_dt date) is
    select prm.prtt_prem_by_mo_id, prm.object_version_number,
           prm.mnl_adj_flag,prm.uom,prm.val,prm.cr_val,prm.cost_allocation_keyflex_id
    from ben_prtt_prem_by_mo_f prm
    where  prm.mo_num = p_mo_num
    and    prm.yr_num = p_yr_num
    and    prm.prtt_prem_id = p_prtt_prem_id
    and    p_effective_dt  between prm.effective_start_date and prm.effective_end_date;



--l_prtt_prem_by_mo_id   number;
l_effective_start_date date;
l_effective_end_date   date;
l_cak                  number;
l_ovn                  number;
l_val                  number;
l_val_net              number;

l_effective_date_mo date;
l_last_effective_dt date;
--
-- Bug 4892354
l_prm_update_mode                     varchar2(60);
l_correction_mode                     boolean;
l_update_mode                         boolean;
l_update_override_mode                boolean;
l_update_change_insert_mode           boolean;
-- Bug 4892354
--

begin
  hr_utility.set_location ('Entering '||l_package,10);

  -- This procedure is first called with the effective date (or effective-date plus one
  -- month)  as the processing month.
  -- Then, if the main procedure determines that prior month premiums may be due,
  -- this procedure is called with each prior month as the processing month
  -- p_last_day_of_month is always the last day of the processing month
  -- p_first_day_of_month is always the first day of the processing month
  hr_utility.set_location ('Actl Prem:'||to_char(p_actl_prem_id),10);
  hr_utility.set_location ('first date '||
             to_char(p_first_day_of_month,'dd-mon-yyyy'),10);
  hr_utility.set_location ('last date '||
             to_char(p_last_day_of_month,'dd-mon-yyyy'),10);
  hr_utility.set_location ('p_enrt_cvg_strt_dt '||p_enrt_cvg_strt_dt,10);
  hr_utility.set_location ('p_enrt_cvg_thru_dt :'|| p_enrt_cvg_thru_dt, 10) ;

  -- load the full premium into a local.  This may change to a pro-rated
  -- or zero value.
  l_val := p_val;
  p_stop_looking := 'N';
  l_last_effective_dt  := last_day(p_effective_date) ;

         -- does coverage begin or end within the month (ie do we need to prorate)
         -- and is there a proration code (wash, rule, prtval etc).  All and None
         -- mean don't do proration.
         -- If cvg begins and ends in month, the start date check overrides
         -- the end date check.
         -- BUG3379060 if p_enrt_cvg_strt_dt between (p_first_day_of_month + 1)
         ---  BUG3379060 revetred for 3742713  if p_enrt_cvg_strt_dt between (p_first_day_of_month
         if ((p_enrt_cvg_strt_dt between (p_first_day_of_month + 1)
             and p_last_day_of_month
            )
            or
             (p_enrt_cvg_strt_dt between p_first_day_of_month
                and p_last_day_of_month
              and  p_prtl_mo_det_mthd_cd in ('PRTVAL','WASHRULE','RL')
             )
            )
            --- if the month starts and ends on the same month use the end calcualtion
            and  not ( p_prtl_mo_det_mthd_cd = 'WASHRULE' and  p_enrt_cvg_thru_dt between (p_first_day_of_month-1)
                 and p_last_day_of_month)
            then
            -- coverage started during this month....
            -- no need to continue to look back thru months
            p_stop_looking := 'Y';
            hr_utility.set_location ('coverage started this month ' || p_stop_looking ,14);
            -- compute partial month premium
            compute_partial_mo
                   (p_business_group_id   => p_business_group_id
                   ,p_effective_date      => p_effective_date
                   ,p_actl_prem_id        => p_actl_prem_id
                   ,p_person_id           => p_person_id
                   ,p_enrt_cvg_strt_dt    => p_enrt_cvg_strt_dt
                   ,p_enrt_cvg_thru_dt    => null
                   ,p_prtl_mo_det_mthd_cd => p_prtl_mo_det_mthd_cd
                   ,p_prtl_mo_det_mthd_rl => p_prtl_mo_det_mthd_rl
                   ,p_wsh_rl_dy_mo_num    => p_wsh_rl_dy_mo_num
                   ,p_rndg_cd             => p_rndg_cd
                   ,p_rndg_rl             => p_rndg_rl
                   ,p_lwr_lmt_calc_rl     => p_lwr_lmt_calc_rl
                   ,p_lwr_lmt_val         => p_lwr_lmt_val
                   ,p_upr_lmt_calc_rl     => p_upr_lmt_calc_rl
                   ,p_upr_lmt_val         => p_upr_lmt_val
                   ,p_pgm_id              => p_pgm_id
                   ,p_pl_typ_id           => p_pl_typ_id
                   ,p_pl_id               => p_pl_id
                   ,p_opt_id              => p_opt_id
                   ,p_val                 => l_val);
         elsif ( p_enrt_cvg_thru_dt between p_first_day_of_month
                 and (p_last_day_of_month - 1)
               )
             or
               (p_enrt_cvg_thru_dt between p_first_day_of_month
                 and p_last_day_of_month
                and   p_prtl_mo_det_mthd_cd in ('PRTVAL','WASHRULE','RL')
               )  then

             -- BUG3379060   and (p_last_day_of_month - 1) then
             -- BUG3379060 revetred for 3742713   and p_last_day_of_month  then
             -- coverage ended this month....
            hr_utility.set_location ('coverage ended this month ',20);
            -- compute partial month premium
            compute_partial_mo
                   (p_business_group_id   => p_business_group_id
                   ,p_effective_date      => p_effective_date
                   ,p_actl_prem_id        => p_actl_prem_id
                   ,p_person_id           => p_person_id
                   ,p_enrt_cvg_strt_dt    => null
                   ,p_enrt_cvg_thru_dt    => p_enrt_cvg_thru_dt
                   ,p_prtl_mo_det_mthd_cd => p_prtl_mo_det_mthd_cd
                   ,p_prtl_mo_det_mthd_rl => p_prtl_mo_det_mthd_rl
                   ,p_wsh_rl_dy_mo_num    => p_wsh_rl_dy_mo_num
                   ,p_rndg_cd             => p_rndg_cd
                   ,p_rndg_rl             => p_rndg_rl
                   ,p_lwr_lmt_calc_rl     => p_lwr_lmt_calc_rl
                   ,p_lwr_lmt_val         => p_lwr_lmt_val
                   ,p_upr_lmt_calc_rl     => p_upr_lmt_calc_rl
                   ,p_upr_lmt_val         => p_upr_lmt_val
                   ,p_pgm_id              => p_pgm_id
                   ,p_pl_typ_id           => p_pl_typ_id
                   ,p_pl_id               => p_pl_id
                   ,p_opt_id              => p_opt_id
                   ,p_val                 => l_val);
         else
           -- using a full month value, round per rounding rule in actl_prem
           if p_rndg_cd is not null  and l_val <>0  then
              l_val := benutils.do_rounding
                    (p_rounding_cd    => p_rndg_cd
                    ,p_rounding_rl    => p_rndg_rl
                    ,p_value          => l_val
                    ,p_effective_date => p_effective_date);
           end if;

         end if;
         if p_enrt_cvg_strt_dt = p_first_day_of_month then
            -- coverage started the first day of this month....
            -- no need to continue to look back thru months
            p_stop_looking := 'Y';
            hr_utility.set_location ('coverage started this month ' || p_stop_looking ,15);
         end if;

           hr_utility.set_location ('write costing ',30);
           -- first insert into cost allocation keyflex
           determine_costing (p_actl_prem_id        => p_actl_prem_id
                             ,p_person_id           => p_person_id
                             ,p_effective_date      => p_effective_date
                             ,p_business_group_id   => p_business_group_id
                             ,p_cak_id              => l_cak);
           hr_utility.set_location ('write premium. Actl Prem:'||
           to_char(p_actl_prem_id)||' val:'||to_char(l_val),31);
           open c_prm(p_prtt_prem_id      => p_prtt_prem_id);
           fetch c_prm into l_prm;
           if c_prm%notfound or c_prm%notfound is null then
              --
              l_effective_date_mo := last_day(to_date(p_yr_num||lpad(p_mo_num,2,0),'YYYYMM')); -- bug 2784213
              hr_utility.set_location ('l_effective_date_mo :'|| l_effective_date_mo, 10) ;
              --
              ben_prtt_prem_by_mo_api.create_prtt_prem_by_mo
               (p_prtt_prem_by_mo_id      => l_prm.prtt_prem_by_mo_id
               ,p_effective_start_date    => l_effective_start_date
               ,p_effective_end_date      => l_effective_end_date
               ,p_mnl_adj_flag            => 'N'
               ,p_mo_num                  => p_mo_num
               ,p_yr_num                  => p_yr_num
               ,p_antcpd_prtt_cntr_uom    => null
               ,p_antcpd_prtt_cntr_val    => null
               ,p_val                     => l_val
               ,p_cr_val                  => null
               ,p_cr_mnl_adj_flag         => 'N'
               ,p_alctd_val_flag          => 'N'
               ,p_uom                     => p_uom
               ,p_prtt_prem_id            => p_prtt_prem_id
               ,p_cost_allocation_keyflex_id => l_cak
               ,p_business_group_id       => p_business_group_id
               ,p_object_version_number   => l_prm.object_version_number
               ,p_request_id              => fnd_global.conc_request_id
               ,p_program_application_id  => fnd_global.prog_appl_id
               ,p_program_id              => fnd_global.conc_program_id
               ,p_program_update_date     => sysdate
               ,p_effective_date          => l_effective_date_mo);
            else
              --
              -- Bug 5127 : When premium process is rerun,
              -- Do not revert back to the standard premium value,
              -- If manual adjustement flag is Y.
              --
              if l_prm.mnl_adj_flag = 'N' then

                 -- get the right  value
                 /* Bug 4892354 : commented as all reqd data is available from c_prm => l_prm
                 open c_prm_ovn (p_prtt_prem_id,l_last_effective_dt) ;
                 fetch c_prm_ovn into l_prm ;
                 close c_prm_ovn ;
                 */
                 if l_prm.cr_val  >  0 and  l_val  >  0  then
                    hr_utility.set_location ('update  the  premium:'|| l_prm.prtt_prem_by_mo_id, 10) ;
                    --
                    -- Bug 4892354 : Get Valid Update Modes
                    --
                    dt_api.Find_DT_Upd_Modes
                      (p_effective_date       => l_prm.effective_start_date,
                       p_base_table_name      => 'BEN_PRTT_PREM_BY_MO_F',
                       p_base_key_column      => 'PRTT_PREM_BY_MO_ID',
                       p_base_key_value       => l_prm.prtt_prem_by_mo_id,
                       p_correction           => l_correction_mode,
                       p_update               => l_update_mode,
                       p_update_override      => l_update_override_mode,
                       p_update_change_insert => l_update_change_insert_mode);
                    --
                    if l_update_change_insert_mode
                    then
                      l_prm_update_mode := hr_api.g_update_change_insert;
                    elsif l_update_override_mode
                    then
                      l_prm_update_mode := hr_api.g_update_override;
                    elsif l_update_mode
                    then
                      l_prm_update_mode := hr_api.g_update;
                    else
                      l_prm_update_mode := hr_api.g_correction;
                    end if;
                    --
                    --
                    ben_prtt_prem_by_mo_api.update_prtt_prem_by_mo
                       (p_prtt_prem_by_mo_id      => l_prm.prtt_prem_by_mo_id
                       ,p_effective_start_date    => l_effective_start_date
                       ,p_effective_end_date      => l_effective_end_date
                       ,p_mnl_adj_flag            => 'N'
                       ,p_val                     => l_val
                       ,p_cr_val                  => null
                       ,p_alctd_val_flag          => 'N'
                       ,p_uom                     => p_uom
                       ,p_prtt_prem_id            => p_prtt_prem_id
                       ,p_cost_allocation_keyflex_id => l_cak
                       ,p_object_version_number   => l_prm.object_version_number
                       ,p_request_id              => fnd_global.conc_request_id
                       ,p_program_application_id  => fnd_global.prog_appl_id
                       ,p_program_id              => fnd_global.conc_program_id
                       ,p_program_update_date     => sysdate
                       ,p_effective_date          => l_prm.effective_start_date
                       ,p_datetrack_mode          => l_prm_update_mode);



                 --update only any changes happens for the row
                 -- every time updating the row the update date changes
                 -- this trouble the exract to get the record updated on
                 -- certain period of time
                 --whne the cvg ended dont update the premium create credit

                 elsif (l_prm.val > 0  and  p_enrt_cvg_thru_dt > p_last_day_of_month )
                     and ( l_prm.uom <> p_uom or  l_prm.val <> l_val or
                         nvl(l_prm.cost_allocation_keyflex_id,-1)  <> nvl(l_cak,-1) ) then
                    --
                    hr_utility.set_location ('correct the  premium:'|| l_prm.prtt_prem_by_mo_id, 10) ;
                    --
                    -- Bug 4892354 : Get Valid Update Modes
                    --
                    dt_api.Find_DT_Upd_Modes
                      (p_effective_date       => l_prm.effective_start_date,
                       p_base_table_name      => 'BEN_PRTT_PREM_BY_MO_F',
                       p_base_key_column      => 'PRTT_PREM_BY_MO_ID',
                       p_base_key_value       => l_prm.prtt_prem_by_mo_id,
                       p_correction           => l_correction_mode,
                       p_update               => l_update_mode,
                       p_update_override      => l_update_override_mode,
                       p_update_change_insert => l_update_change_insert_mode);
                    --
                    if l_update_change_insert_mode
                    then
                      l_prm_update_mode := hr_api.g_update_change_insert;
                    elsif l_update_override_mode
                    then
                      l_prm_update_mode := hr_api.g_update_override;
                    elsif l_correction_mode
                    then
                      l_prm_update_mode := hr_api.g_correction;
                    else
                      l_prm_update_mode := hr_api.g_update;
                    end if;
                    --
                    --
                    ben_prtt_prem_by_mo_api.update_prtt_prem_by_mo
                       (p_prtt_prem_by_mo_id      => l_prm.prtt_prem_by_mo_id
                       ,p_effective_start_date    => l_effective_start_date
                       ,p_effective_end_date      => l_effective_end_date
                       ,p_mnl_adj_flag            => 'N'
                       ,p_val                     => l_val
                       ,p_alctd_val_flag          => 'N'
                       ,p_uom                     => p_uom
                       ,p_prtt_prem_id            => p_prtt_prem_id
                       ,p_cost_allocation_keyflex_id => l_cak
                       ,p_object_version_number   => l_prm.object_version_number
                       ,p_request_id              => fnd_global.conc_request_id
                       ,p_program_application_id  => fnd_global.prog_appl_id
                       ,p_program_id              => fnd_global.conc_program_id
                       ,p_program_update_date     => sysdate
                       ,p_effective_date          => l_prm.effective_start_date
                       ,p_datetrack_mode          => l_prm_update_mode);
                 else
                    -- if  monthly  chg found  without any change dont go further
                    p_stop_looking := 'Y';
                    hr_utility.set_location (' monthly  chg found ' || p_stop_looking ,14);
                 end if ;
                 --
              else
                 -- if manually adjusted flag found  dont go further to generate the premium
                 p_stop_looking := 'Y';
                 hr_utility.set_location (' manually adjusted flag found ' || p_stop_looking ,14);
              end if;
              --
            end if;
  p_out_val := l_val;
  hr_utility.set_location ('Leaving '||l_package,99);
exception
  when others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package,999);
    hr_utility.set_location('Error:'||l_error_text,999);
    fnd_message.raise_error;
end compute_prem;
-- ----------------------------------------------------------------------------
-- |------------------------------< main >------------------------------------|
-- ----------------------------------------------------------------------------
-- This is the procedure to call to determine all the 'ENRT' type premiums for
-- the month.
procedure main
  (p_validate                 in varchar2 default 'N'
  ,p_person_id                in number default null
  ,p_person_action_id         in number default null
  ,p_comp_selection_rl        in number default null
  ,p_pgm_id                   in number default null
  ,p_pl_typ_id                in number default null
  ,p_pl_id                    in number default null
  ,p_object_version_number    in out nocopy number
  ,p_business_group_id        in number
  ,p_mo_num                   in number
  ,p_yr_num                   in number
  ,p_first_day_of_month       in date
  ,p_effective_date           in date) is
  --
  l_package               varchar2(80) := g_package||'.main';
  l_error_text            varchar2(200) := null;
  --
  cursor c_results is
    select pen.person_id, pen.pl_id, pen.oipl_id, pen.effective_start_date,
           pen.effective_end_date, pen.enrt_cvg_strt_dt, pen.enrt_cvg_thru_dt,
           pen.pgm_id, pen.pl_typ_id, pen.ler_id, pen.prtt_enrt_rslt_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_stat_cd is null
    and    pen.sspndd_flag = 'N'
    and    pen.comp_lvl_cd not in ('PLANFC', 'PLANIMP')  -- not a dummy plan
           -- cvg starts sometime before end of next month
    and    pen.enrt_cvg_strt_dt <= add_months(p_effective_date,1)
    and    pen.person_id = p_person_id
           -- check criteria user entered on the submit form:
    and    (pen.pl_id = p_pl_id  or p_pl_id is null)
    and    (pen.pl_typ_id = p_pl_typ_id or p_pl_typ_id is null)
    and    (pen.pgm_id = p_pgm_id or p_pgm_id is null)
    and    pen.business_group_id+0 = p_business_group_id
    and    p_effective_date between
           pen.effective_start_date and pen.effective_end_date
    and    pen.enrt_cvg_thru_dt >= pen.effective_start_date;  -- Added condition for Bug 7676969
--l_results  c_results%rowtype;

  -- There is an assumption that if the actl_prem is 'enrt' then there should
  -- already be a row in prtt_prem written by the enrollment process.
  cursor c_prems(p_prtt_enrt_rslt_id number) is
    select ppe.std_prem_val, ppe.std_prem_uom, apr.prtl_mo_det_mthd_cd,
           apr.prtl_mo_det_mthd_rl, apr.wsh_rl_dy_mo_num, apr.actl_prem_id,
           ppe.prtt_prem_id, apr.rndg_cd, apr.rndg_rl, apr.prsptv_r_rtsptv_cd,
           apr.lwr_lmt_calc_rl, apr.lwr_lmt_val,
           apr.upr_lmt_calc_rl, apr.upr_lmt_val,
           apr.cr_lkbk_val,apr.cr_lkbk_crnt_py_only_flag,
           ppe.effective_start_date
    from   ben_actl_prem_f apr,
           ben_per_in_ler pil,
           ben_prtt_prem_f ppe
    where  apr.prem_asnmt_cd = 'ENRT'  -- PROC are dealt with in benprplo.pkb
    and    apr.business_group_id+0 = p_business_group_id
    and    ppe.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    p_effective_date between
           apr.effective_start_date and apr.effective_end_date
    and    ppe.actl_prem_id = apr.actl_prem_id
    and    p_effective_date between
           ppe.effective_start_date and ppe.effective_end_date
and pil.per_in_ler_id=ppe.per_in_ler_id
and pil.business_group_id+0=ppe.business_group_id+0
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
;
  -- l_prems c_prems%rowtype;

  cursor c_old_result (p_prtt_enrt_rslt_id number,
                       p_effective_start_date date) is
    select  pen.effective_start_date,
           pen.effective_end_date,  pen.prtt_enrt_rslt_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.effective_start_date < p_effective_start_date;
  l_old_result  c_old_result%rowtype;

  l_months_to_subtract  number;
  l_first_day_of_month date;
  l_last_day_of_month  date;
  l_stop_looking       varchar2(1);
  l_current_month      varchar2(1);
  l_mo_num             number;
  l_yr_num             number;
  l_val                number;
  l_look_back_dt       date  ;

  -- Concurrent Code Begin
  cursor c_opt(l_oipl_id  number) is
	select opt_id from ben_oipl_f oipl
	where oipl.oipl_id = l_oipl_id
        and p_effective_date between
            oipl.effective_start_date and oipl.effective_end_date;
  l_opt c_opt%rowtype;

    -------Bug 	7414822
  cursor c_ler_typ_cd(p_ler_id number) is
   SELECT typ_cd
  FROM ben_ler_f
 WHERE ler_id = p_ler_id
  AND business_group_id = p_business_group_id;

  l_ler_typ_cd varchar2(100);

  cursor c_check_mo_prem(p_var VARCHAR2,l_pen_id number,p_ler_typ_cd varchar2,p_ler_id number) IS
   SELECT 'Y'
  FROM ben_prtt_enrt_rslt_f pen
 WHERE pen.prtt_enrt_rslt_id = l_pen_id
   AND pen.business_group_id = p_business_group_id
   AND ((p_ler_typ_cd <> 'SCHEDDO'
   and  p_effective_date BETWEEN pen.effective_start_date
          AND Decode(p_var,'RETRO',pen.effective_end_date,Add_Months(last_day(pen.effective_end_date),1))
   AND pen.effective_start_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt)
     or (p_ler_typ_cd = 'SCHEDDO'
     and p_effective_date BETWEEN pen.enrt_cvg_strt_dt
          AND Decode(p_var,'RETRO',pen.enrt_cvg_thru_dt,Add_Months(last_day(pen.enrt_cvg_thru_dt),1))
	  and pen.enrt_cvg_thru_dt >= pen.effective_start_date))
  and pen.ler_id = p_ler_id;

   l_check_mo_prem   varchar2(10) := 'N';
  -----Bug 7414822

  l_actn                 varchar2(80);
  l_rule_ret             varchar2(30);
  l_person_ended         varchar2(30):='N';
  -- Concurrent Code End
begin
  -- p_effective_date is always the last day of the month this is being run
  hr_utility.set_location ('Entering '||l_package,10);
  hr_utility.set_location ('For person:'||to_char(p_person_id),20);

  -- Concurrent Code Begin
  l_actn := 'Initializing...';
  Savepoint process_premium_savepoint;
  --
  -- Cache person data and write personal data into cache.
  --
  l_actn := 'Calling ben_batch_utils.person_header...';
  ben_batch_utils.person_header
    (p_person_id           => p_person_id
    ,p_business_group_id   => p_business_group_id
    ,p_effective_date      => p_effective_date
    );
  --
  l_actn := 'Calling ben_batch_utils.ini(COMP_OBJ)...';
  ben_batch_utils.ini('COMP_OBJ');
  -- Concurrent Code End

  for l_results in c_results loop
    -- Concurrent Code Begin
    -- Check if the comp object rule requirements are satisfied
    -- Note: several args already checked in the cursor here and in 'process' proc
    --
    if l_results.oipl_id is not null then
         open c_opt(l_results.oipl_id);
         fetch c_opt into l_opt;
         close c_opt;
    else l_opt := null;
    end if;

    hr_utility.set_location ('Result id  '||l_results.prtt_enrt_rslt_id,10);

    l_rule_ret:='Y';
    if p_comp_selection_rl is not null then
      hr_utility.set_location('found a rule',12);
      l_rule_ret:=ben_maintain_designee_elig.comp_selection_rule(
                p_person_id                => p_person_id
               ,p_business_group_id        => p_business_group_id
               ,p_pgm_id                   => l_results.pgm_id
               ,p_pl_id                    => l_results.pl_id
               ,p_pl_typ_id                => l_results.pl_typ_id
               ,p_opt_id                   => l_opt.opt_id
               ,p_oipl_id                  => l_results.oipl_id
               ,p_ler_id                   => l_results.ler_id
               ,p_comp_selection_rule_id   => p_comp_selection_rl
               ,p_effective_date           => p_effective_date
      );
    end if;
    hr_utility.set_location(l_package,13);
    if l_rule_ret='Y' then
       -- Concurrent Code End
      for l_prems in c_prems(p_prtt_enrt_rslt_id => l_results.prtt_enrt_rslt_id) loop
        if  l_prems.prsptv_r_rtsptv_cd = 'PRO' or
           (l_prems.prsptv_r_rtsptv_cd = 'RETRO' and
           l_results.enrt_cvg_strt_dt <= p_effective_date) then
          -- if the premium is retrospective, then we do not want to look at results
          -- whose coverage starts next month.  skip this premium and go to next one.

          if l_prems.prsptv_r_rtsptv_cd = 'RETRO' then
             -- start with efective date month
             l_first_day_of_month :=p_first_day_of_month;
             l_last_day_of_month := p_effective_date;
             l_mo_num := p_mo_num;
             l_yr_num := p_yr_num;
          else -- l_prem.prsptv_r_rtsptv_cd = 'PRO'
             -- start with next months premium and work backwards thru time.
             l_first_day_of_month := add_months(p_first_day_of_month,1);
             l_last_day_of_month := add_months(p_effective_date,1);
             l_mo_num := to_char(l_last_day_of_month,'MM');
             l_yr_num := to_char(l_last_day_of_month,'YYYY');
          end if;
          -- Decide the lookback period
          l_look_back_dt  := null  ;
          if nvl(l_prems.cr_lkbk_crnt_py_only_flag,'N')  = 'Y'  then
             l_look_back_dt := l_last_day_of_month ;
          else
            if l_prems.cr_lkbk_val is not null then
               l_look_back_dt :=  add_months( l_last_day_of_month , (l_prems.cr_lkbk_val * -1)) ;
            end if ;
          end if ;
          hr_utility.set_location('look back date ' || l_look_back_dt , 56 ) ;
          --
          l_current_month := 'Y';
          loop
            l_stop_looking := 'N';
             hr_utility.set_location(l_package,133);
            if l_results.enrt_cvg_thru_dt >= l_first_day_of_month then
               -- they have coverage during the month we are processing.
               -- If they don't this if stmt will ensure we don't write
               -- a premium for them.
               compute_prem(p_validate        => p_validate
                   ,p_person_id           => l_results.person_id
                   ,p_business_group_id   => p_business_group_id
                   ,p_effective_date      => p_effective_date
                   ,p_first_day_of_month  => l_first_day_of_month
                   ,p_last_day_of_month   => l_last_day_of_month
                   ,p_enrt_cvg_strt_dt    => l_results.enrt_cvg_strt_dt
                   ,p_enrt_cvg_thru_dt    => l_results.enrt_cvg_thru_dt
                   ,p_prtl_mo_det_mthd_cd => l_prems.prtl_mo_det_mthd_cd
                   ,p_prtl_mo_det_mthd_rl => l_prems.prtl_mo_det_mthd_rl
                   ,p_wsh_rl_dy_mo_num    => l_prems.wsh_rl_dy_mo_num
                   ,p_rndg_cd             => l_prems.rndg_cd
                   ,p_rndg_rl             => l_prems.rndg_rl
                   ,p_lwr_lmt_calc_rl     => l_prems.lwr_lmt_calc_rl
                   ,p_lwr_lmt_val         => l_prems.lwr_lmt_val
                   ,p_upr_lmt_calc_rl     => l_prems.upr_lmt_calc_rl
                   ,p_upr_lmt_val         => l_prems.upr_lmt_val
                   ,p_pgm_id              => l_results.pgm_id
                   ,p_pl_typ_id           => l_results.pl_typ_id
                   ,p_pl_id               => l_results.pl_id
                   ,p_opt_id              => l_opt.opt_id
                   ,p_val                 => l_prems.std_prem_val
                   ,p_actl_prem_id        => l_prems.actl_prem_id
                   ,p_prtt_prem_id        => l_prems.prtt_prem_id
                   ,p_mo_num              => l_mo_num
                   ,p_uom                 => l_prems.std_prem_uom
                   ,p_yr_num              => l_yr_num
                   ,p_stop_looking        => l_stop_looking
                   ,p_out_val             => l_val);

               -- write info to reporting table
               if l_current_month = 'Y' then
                  -- if we are processing this month for retrospective or next
                  -- month for prospective, the report considers this 'current month'.
                  g_rec.rep_typ_cd            := 'PRCURMOP';
                  l_current_month := 'N';
               else
                  -- otherwise, it's a retroactive premium.  That's different
                  -- than retrospective premium type.
                  g_rec.rep_typ_cd            := 'PRRETROP';
               end if;
               -------------Bug 7414822
		l_check_mo_prem := 'N';
		---get the ler_typ_code
               open c_ler_typ_cd(l_results.ler_id);
	       fetch c_ler_typ_cd into l_ler_typ_cd;
	       close c_ler_typ_cd;
	       open c_check_mo_prem(l_prems.prsptv_r_rtsptv_cd,l_results.prtt_enrt_rslt_id,l_ler_typ_cd,l_results.ler_id);
	       fetch c_check_mo_prem into l_check_mo_prem;
	       if c_check_mo_prem%found then
	       -------------Bug 7414822
               g_rec.person_id             := l_results.person_id;
               g_rec.pgm_id                := l_results.pgm_id;
               g_rec.pl_id                 := l_results.pl_id;
               g_rec.oipl_id               := l_results.oipl_id;
               g_rec.pl_typ_id             := l_results.pl_typ_id;
               g_rec.actl_prem_id          := l_prems.actl_prem_id;
               g_rec.val                   := l_val;
               g_rec.mo_num                := l_mo_num;
               g_rec.yr_num                := l_yr_num;

               benutils.write(p_rec => g_rec);
	       -------------Bug 7414822
	       end if;
	       close c_check_mo_prem;
               -------------Bug 7414822
            end if;
               --
               -- If l_stop_looking is Y, the proc determined that the cvg started
               -- in the month we are processing, there is no need to continue to
               -- look back for other month's premiums.
               -- We also don't look back if the result was created prior to this
               -- month (because prior runs would have created the premiums).
            hr_utility.set_location('l_stop_looking = ' || l_stop_looking, 999);
            hr_utility.set_location('l_results.effective_start_date = ' || l_results.effective_start_date, 999);
            hr_utility.set_location('l_first_day_of_month = ' || l_first_day_of_month, 999);

            if l_stop_looking = 'N' then
               -- For results that were created for the first time
               -- this month, we want to look back thru prior months to
               -- create additional premiums.  Results that were created
               -- prior to this month (and perhaps are just being date-
               -- tracked updated this month) would have had those premiums
               -- already created by a prior month run of this job.

               -- the following cursor has 2 issues -- tilak
               -- 1) if the premium is not executed every month and result is date tracked
               --    the process does not generate the premium for previous months
               --    this is not a serious issue, cause the assumption is ct runs the process
               --    every month
               -- 2) if a LE created 2 months  back and covered in new premium option.plan
               --     wich generated the 1 month credit entry for the original premium plan
               --     now the LE is backed out and the original plan continues .
               --     in this case the process should generate 2 months premium charges
               --     for the orignal plan

               --     so the logic changed to generate the premium till it find the previous
               --     monthly charges without any changes or till it find the entry which manually adjusted

               --     or the premium effective start date is higher then the month start date
               --     we dont generate premium for the previous results rows cause there may be changes of
               --     premium and assume the premium generated before the LE executed or
               --     the process is executed again withn the period of the process

               --open c_old_result(p_prtt_enrt_rslt_id =>
               --     l_results.prtt_enrt_rslt_id,
               --     p_effective_start_date => l_results.effective_start_date);
               --fetch c_old_result into l_old_result;
               --if c_old_result%notfound or c_old_result%notfound is null then
                hr_utility.set_location ('Look for prior months ',50);
                l_first_day_of_month := add_months(l_first_day_of_month, -1);
                l_last_day_of_month :=  add_months(l_last_day_of_month, -1);
                l_mo_num := to_char(l_last_day_of_month,'MM');
                l_yr_num := to_char(l_last_day_of_month,'YYYY');
                --else
                --   close c_old_result;
                --   exit;
                --end if;
                --close c_old_result;
                -- for OSP the the result will be the same so we hve to validate the
                -- condition with premium row

                hr_utility.set_location ('l_first_day_of_month '|| l_first_day_of_month ||
                                         ' l_prem.effective_start_date '||trunc(l_prems.effective_start_date,'MM') ,50);

                --if trunc(l_first_day_of_month) < trunc(round(l_results.effective_start_date,'MM')) then
                if trunc(l_first_day_of_month) < trunc(l_prems.effective_start_date,'MM') then

                      hr_utility.set_location ( ' exit calcualtion '  ,50);
                    exit ;
                end if ;


                -- if the month end date is below than look back date dont
                -- calcualte

                 if l_look_back_dt is not null and l_look_back_dt > l_last_day_of_month then
                    hr_utility.set_location ( ' exit look back  ' || l_look_back_dt ,50);
                    exit ;
                 end if ;

              else
                 exit;
              end if;
          end loop;  -- calling compute_prem
        end if;    -- if retro and cvg earlier than next month
      end loop;  -- premiums
    end if;    -- comp object rule passed
  end loop;     -- results
  -- Concurrent Code Begin
  hr_utility.set_location(l_package,110);
  l_actn := 'Calling Ben_batch_utils.write_comp...';
  Ben_batch_utils.write_comp(p_business_group_id => p_business_group_id
                            ,p_effective_date    => p_effective_date
                            );
  l_actn := 'About to optionally rollback...';
  If (p_validate = 'Y') then
    Rollback to process_premium_savepoint;
  End if;
  --
  --
  --
  If p_person_action_id is not null then
    --
    l_actn := 'Calling ben_person_actions_api.update_person_actions...';
    --
    ben_person_actions_api.update_person_actions
      (p_person_action_id      => p_person_action_id
      ,p_action_status_cd      => 'P'
      ,p_object_version_number => p_object_version_number
      ,p_effective_date        => p_effective_date
      );
  End if;
  commit;
  hr_utility.set_location ('Leaving '||l_package,99);
Exception
  When others then
    l_error_text := sqlerrm;
    hr_utility.set_location ('Fail in '||l_package,998);
    hr_utility.set_location (' with error '||l_error_text,999);
    rollback to process_premium_savepoint;
    ben_batch_utils.write_error_rec;
    ben_batch_utils.rpt_error(p_proc       => l_package
                             ,p_last_actn  => l_actn
                             ,p_rpt_flag   => TRUE);
    Ben_batch_utils.write_comp(p_business_group_id => p_business_group_id
                              ,p_effective_date    => p_effective_date
                              );
    If p_person_action_id is not null then
      ben_person_actions_api.update_person_actions
        (p_person_action_id      => p_person_action_id
        ,p_action_status_cd      => 'E'
        ,p_object_version_number => p_object_version_number
        ,p_effective_date        => p_effective_date
        );
    End if;
    commit;
    raise ben_batch_utils.g_record_error;
  -- Concurrent Code End
end main;
end ben_prem_prtt_monthly;

/
