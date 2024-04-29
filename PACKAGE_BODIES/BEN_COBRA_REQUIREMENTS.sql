--------------------------------------------------------
--  DDL for Package Body BEN_COBRA_REQUIREMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COBRA_REQUIREMENTS" as
/* $Header: bencobra.pkb 120.5.12010000.5 2009/02/20 10:43:13 pvelvano ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1999 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name:
    Determine COBRA requirements
Purpose
        This package contains all the COBRA procedures that are
        required by other processes to determine COBRA start and end
        dates, qualified beneficiary status
History

Version Date        Author         Comments
-------+-----------+--------------+----------------------------------------
115.0   17-SEP-1999 stee           Created
115.1   04-OCT-1999 stee           Added pgm_typ_cd check to
                                   end_prtt_cobra_eligibility.
115.2   04-OCT-1999 stee           Fixed end_prtt_cobra_eligibility
                                   to get the life event ocrd date
                                   before checking if the person
                                   is a quald bnf.
115.3   05-OCT-1999 stee           For disability event, only extend the
                                   eligibility end date if the calculated
                                   date is great than the dependent
                                   eligibility end date.
115.4   07-JAN-2000 pbodla       - regn_id is added as context to mx_poe_rl
115.5   12-JAN-2000 stee         - Fix update_cobra_info to write a qualified
                                   beneficiary row when a dependent is
                                   designated.
115.6   17-JAN-2000 stee         - When checking for max cvg thru dt, limit it
                                   to the COBRA program.
                                   WWBUG# 1166171
115.7   30-JAN-2000 stee         - If a person is does not need the
                                   extension in a disability event as he/she
                                   already has 36 months, update the
                                   eligibility end date on pil_elctbl_chc_popl
                                   in case they are allowed to make elections.
                                   WWBUG# 11772229.
115.7   06-FEB-2000 stee         - Check for backed out nocopy events.WWBUG#1178633.
115.8   01-MAR-2000 stee         - COBRA by plan type.
115.10  06-MAR-2000 stee         - Fix disability at time of life event dates.
115.11  30-MAR-2000 stee         - Fix disability within 60 days of the life
                                   event. Change update_dpnt_cobra_info to
                                   not error out nocopy if the elig dates are null
                                   as the dates are null for an open enrollment
                                   event. WWBUG#: 1249902, 1147607, 1252082.
115.12  31-MAR-2000 stee         - Fix to extend cobra eligibility end date
                                   if it is greater than the current
                                   eligibility end date.
                                   Write cbr_per_in_ler for all qualified
                                   beneficiary eligible for the disability
                                   extension.
115.13  04-APR-2000 mmogel       - Added tokens to messages to make them
                                   more meaningful to the user
115.14  06-APR-2000 stee         - When checking for min dates use null
                                   instead of %notfound. Bug# 4956
115.15  28-APR-2000 stee         - Update cobra ineligibility status when
                                   prtt is no longer eligible or has waived
                                   coverage.  Also fix chk_enrld_or_cvrd
                                   cursor to outer join to oipl table
                                   if plan has no option.
115.16  17-May-2000 stee         - Add pl_typ_id to the where clause when
                                   selecting enrollment coverage end date
                                   in determine_cobra_elig_dates for cobra
                                   by plan type.
115.17  11-OCT-2000 rchase       - added parameter pl typ id for
                                   calls to formula as contexts.
115.18  20-OCT-2000 stee         - When checking if a person is a cobra
                                   qualified beneficiary, use elig_end_dt >
                                   lf_evt_ocrd_dt as cobra start date can
                                   be after the lf evt ocrd dt. WWBUG#1469388.
115.19  26-Oct-2000 rchase       - fix wwbug 1480395 fetch pgm_id, if
                                   necessary for formula context.  Ensure the
                                   proper rule is passed to the formula call
                                   when determining mx poe date.
115.20  21-Mar-2001 ikasire        bug 1566944 added ptip parameter and
                                   edited c_get_max_poe cursor to see for
                                   pgm_id or ptip_id
115.21  20-Aug-2001 stee           Bug 1348235: Fix duplicate qual bnf row
                                   when a dependent is added after the initial
                                   qualifying event.
115.22  29-Aug-2001 pbodla         bug:1949361 jurisdiction code is
                                   derived inside benutils.formula
115.23  30-NOV-2001 stee           Back out nocopy changes made in version 115.20.
                                   The c_get_max_poe cursor may retrieve
                                   the wrong period of enrollment if COBRA
                                   by plan type is implemented. Also, for
                                   subsequent events, it is not finding the
                                   current qualified beneficiary row so a
                                   duplicate one is created.
115.24  22-JAN-2002 stee           If a person is no longer disabled, reduce
                                   the max period of enrollment if applicable.
                                   Bug# 2068332.
115.25  01-FEB-2002 stee           Added dbdrv lines.
115.26  21-MAY-2002 stee           Fix the cobra eligibility end date.
                                   Bug# 2355218.
115.27  08-Jun-2002 pabodla     - Do not select the contingent worker
                                  assignment when assignment data is
                                  fetched.
115.28  12-Aug-2002 stee          Check if electable choices exist before
                                  ending COBRA eligibility. Bug 1794808.
115.29  11-Sep-2002 stee          Close c_get_ler_type cursor.
115.30  04-Nov-2002 stee          For COBRA by plan type, check for enrollment
                                  in the COBRA program instead of plan type
                                  to determine eligibility. Bug 2626516.
115.31  23-DEC-2002 lakrish       NOCOPY changes.
115.32  14-MAR-2003 stee          When determining the enrollment coverage
                                  start date for cobra eligibility start date,
                                  use electable choices instead of enrollment
                                  results. Bug 2821672 and 2815797.
115.33  13-Oct-2003 rpillay       Bug 3097501 - Added procedures
                                  allocate_payment, do_rounding and
                                  get_amount_due
115.34  15-Oct-2003 rpillay       Bug 3097501 - Added date check in
                                  c_rates cursor (allocate_payment)
115.35  15-Oct-2003 rpillay       Bug 3097501 - Changes to c_prev_pymts_latest
                                  cursor (allocate_payment)
115.36  20-Oct-2003 rpillay       Bug 3097501 - Changes to allocate_payments to
                                  adjust payments against past and future rates
115.37  22-Oct-2003 rpillay       Bug 3097501 - Changes to handle FSA balance
                                  calculations when no change in amount
115.38  24-Oct-2003 rpillay       Bug 3097501 - Changes to get_amount_due -
                                  Using Rates in place of element balance
                                  for FSA
115.39  18-Nov-2003 rpillay       Bug 3097501 - Changes for not doing automatic
                                  adjustments for plan year and element
                                  changes
115.40  24-Nov-2003 rpillay       Added nocopy to p_excess_amount
115.41  19-Dec-2003 rpillay       Changes to ignore excess payments in
                                  allocate_payments
115.42  22-Dec-2003 rpillay       Changes to c_pen in allocate_payments to
                                  check for coverage start and thru dates
115.43  05-Jan-2004 rpillay       Bug 3338978 - added check for month_strt_dt
                                  < rt_strt_dt in allocate_payments
115.44  13-Jan-2004 stee          Remove ptip_id from the where clause in
                                  c_get_enrt_cvg_thru_dt and
                                  c_get_dpnt_cvg_thru_dt in the
                                  get_max_cvg_thru_dt function.  The eligibility
                                  end date is the coverage end date of the
                                  program. Bug 3368053.
115.45  15-Jan-2004 rpillay       Moved code to fetch costing data to
                                  get_costing_details procedure.
                                  Pass cost_allocation_keyflex_id as NULL
                                  while making payment adjustments to ensure
                                  that costed values get assigned using the
                                  Costing Hierarchy.
115.46  27-Sep-2004 tjesumic       new param p_cvrd_today added in chk_enrld_or_cvrd # 	3843549
                                  coerage validation changes as per the param
115.47  04-jan-2005 ssarkar       Bug#	3630753 : commented fnd_message.set_token('PROC',l_proc).
115.48  08-Sep-2005 stee          If eligibility period end date is 01/01/0001, then
                                  set the quald_bnf_flag = 'N' and leave the eligibility
                                  period end date as is.  Bug 4486609.
115.49  28-dec-2005 stee          Only terminate cobra eligibility in chk_cobra_eligibility
                                  if the person was previously enrolled in COBRA
                                  benefits.  Bug 4338471.
115.50  15-Feb-2005 bmanyam       4881917 PERF Fix: XBuild1 Drop
115.51  30-Jun-2006 swjain        5331889 Added person_id param to benutils.formula call in
115.52  08-Nov-2006 stee          When creating quald_bnf for a dependent, get
                                  the cvrd_emp_person_id with a person type
                                  usage of 'PRTN'.
115.53  22-Feb-2008 rtagarra      Bug 6840074
115.55  30-May-2008 velvanop      Bug 7116537- Commented the p_effective_date condition of cursor c_get_enrt_cvg_thru_dt in
                                  get_max_cvg_thru_dt function.
115.56  20-Feb-2009 velvanop      Bug 8211414- Modified cursor c_get_quald_bnf. To determine QB, flag 'quald_bnf_flag' should be 'Y' .
                                  Even though QB records exists, new QB records will be created for a LE only if the flag is set to 'N'.
*/
--------------------------------------------------------------------------------
  g_package varchar2(80):='ben_cobra_requirements.';
--
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_lf_evt_ocrd_dt >----------------------------
-- ----------------------------------------------------------------------------
--
function get_lf_evt_ocrd_dt
           (p_per_in_ler_id     in number
           ,p_business_group_id in number) return date is
  --
  l_proc                varchar2(80) := g_package||'.get_lf_evt_ocrd_dt';
  l_lf_evt_ocrd_dt      date;
  l_exists              varchar2(1);
  --
  cursor c_get_lf_evt_ocrd_dt
  is
    select pil.lf_evt_ocrd_dt
    from ben_per_in_ler pil
    where pil.per_in_ler_id = p_per_in_ler_id
    and pil.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  open c_get_lf_evt_ocrd_dt;
  fetch c_get_lf_evt_ocrd_dt into l_lf_evt_ocrd_dt;
  close c_get_lf_evt_ocrd_dt;
  --
  return l_lf_evt_ocrd_dt;
  --
end get_lf_evt_ocrd_dt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_init_evt >----------------------------------
-- ----------------------------------------------------------------------------
--
function chk_init_evt
           (p_per_in_ler_id     in number
           ,p_business_group_id in number) return boolean is
  --
  l_proc                varchar2(80) := g_package||'.chk_init_evt';
  l_init_evt            boolean := false;
  l_exists              varchar2(1);
  --
  cursor c_chk_init_evt
  is
    select null
    from   ben_cbr_per_in_ler crp
    where  crp.per_in_ler_id = p_per_in_ler_id
    and    crp.business_group_id = p_business_group_id
    and    crp.init_evt_flag = 'Y';
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  open c_chk_init_evt;
  fetch c_chk_init_evt into l_exists;
  if c_chk_init_evt%found then
    l_init_evt := true;
  end if;
  close c_chk_init_evt;
  --
  return l_init_evt;
  --
end chk_init_evt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_dsbld>-------------------------------------
-- ----------------------------------------------------------------------------
--
function chk_dsbld
           (p_person_id         in number
           ,p_lf_evt_ocrd_dt    in date default null
           ,p_effective_date    in date
           ,p_business_group_id in number) return boolean is
  --
  l_proc                      varchar2(80) := g_package||'.chk_dsbld';
  l_dsbld                     boolean := false;
  l_registered_disabled_flag  per_all_people_f.registered_disabled_flag%type;
  l_new_val                   ben_per_info_chg_cs_ler_f.new_val%type;
  --
  cursor c_chk_dsbld
  is
    select per.registered_disabled_flag
    from   per_all_people_f per
    where  per.person_id = p_person_id
    and    nvl(p_lf_evt_ocrd_dt,p_effective_date) between
           per.effective_start_date and per.effective_end_date
    and    per.business_group_id = p_business_group_id;
  --
  cursor c_chk_dsblty_criteria
  is
    select psl.new_val
    from ben_per_info_chg_cs_ler_f psl
    where psl.source_table = 'PER_ALL_PEOPLE_F'
    and psl.source_column = 'REGISTERED_DISABLED_FLAG'
    and nvl(p_lf_evt_ocrd_dt, p_effective_date)
    between psl.effective_start_date and psl.effective_end_date
    and psl.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  open c_chk_dsbld;
  fetch c_chk_dsbld into l_registered_disabled_flag;
  if c_chk_dsbld%found then
    close c_chk_dsbld;
    --
    --  If person is disabled, check it meets the criteria
    --  for the disability event.
    --
    if l_registered_disabled_flag is not null then
      open c_chk_dsblty_criteria;
      fetch c_chk_dsblty_criteria into l_new_val;
      if c_chk_dsblty_criteria%found then
        if l_new_val = 'OABANY' then
          l_dsbld := true;
        elsif l_new_val = l_registered_disabled_flag then
          l_dsbld := true;
        end if;
      end if;
      close c_chk_dsblty_criteria;
    end if;
    --
  else
    close c_chk_dsbld;
  end if;
  --
  return l_dsbld;
  --
end chk_dsbld;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_dsblty_elig_perd_end_dt>--------------------
-- ----------------------------------------------------------------------------
--
function get_dsblty_elig_perd_end_dt
           (p_person_id             in number
           ,p_pl_typ_id             in number default null
           ,p_lf_evt_ocrd_dt        in date   default null
           ,p_cbr_elig_perd_strt_dt in date
           ,p_pgm_id                in number default null
           ,p_ptip_id               in number default null
           ,p_effective_date        in date
           ,p_business_group_id     in number) return date is
  --
  l_proc                      varchar2(80) := g_package||'.get_dsblty_elig_perd_end_dt';
  l_dsblty_ler_id             ben_per_in_ler.ler_id%type;
  l_dsblty_elig_perd_end_dt   date default null;
  --
  cursor c_get_dsblty_ler
  is
  select ler.ler_id
  from ben_ler_f ler
  where ler.typ_cd = 'DSBLTY'
  and ler.business_group_id = p_business_group_id
  and ler.qualg_evt_flag = 'Y'
  and p_lf_evt_ocrd_dt
  between ler.effective_start_date
  and ler.effective_end_date;

  --
  cursor c_get_dsblty_max_poe is
    select peo.*
    from ben_elig_to_prte_rsn_f peo
    where peo.ler_id = l_dsblty_ler_id
    and peo.business_group_id = p_business_group_id
    and nvl(p_lf_evt_ocrd_dt, p_effective_date)
    between peo.effective_start_date and peo.effective_end_date
    and nvl(peo.pgm_id,-1) = nvl(p_pgm_id,-1)
    and nvl(peo.ptip_id,-1) = nvl(p_ptip_id,-1)
    and (peo.mx_poe_val is not null or
         peo.mx_poe_rl is not null);
  --
  l_poe_rec            c_get_dsblty_max_poe%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  open c_get_dsblty_ler;
  fetch c_get_dsblty_ler into l_dsblty_ler_id;
  if c_get_dsblty_ler%found then
    hr_utility.set_location('Found disability event' , 10);
    close c_get_dsblty_ler;
    --
    --  Get disability period of enrollment.
    --
    open c_get_dsblty_max_poe;
    fetch c_get_dsblty_max_poe into l_poe_rec;
    if c_get_dsblty_max_poe%found then
      close c_get_dsblty_max_poe;
      l_dsblty_elig_perd_end_dt
        := get_cbr_elig_end_dt
             (p_cbr_elig_perd_strt_dt  => p_cbr_elig_perd_strt_dt
             ,p_person_id              => p_person_id
             ,p_pl_typ_id              => p_pl_typ_id
             ,p_mx_poe_uom             => l_poe_rec.mx_poe_uom
             ,p_mx_poe_val             => l_poe_rec.mx_poe_val
             ,p_mx_poe_rl              => l_poe_rec.mx_poe_rl
             ,p_pgm_id                 => p_pgm_id
             ,p_effective_date         => p_lf_evt_ocrd_dt
             ,p_business_group_id      => p_business_group_id
             ,p_ler_id                 => l_dsblty_ler_id
             );
    else
      close c_get_dsblty_max_poe;
    end if;
  else
    close c_get_dsblty_ler;
  end if;
  --
  return l_dsblty_elig_perd_end_dt;
  --
end get_dsblty_elig_perd_end_dt;
--
-- ----------------------------------------------------------------------------
-- |Determine Cobra eligibility start and end dates.
-- ----------------------------------------------------------------------------
--
procedure determine_cobra_elig_dates
  (p_pgm_id                  in     number default null
  ,p_ptip_id                 in     number default null
  ,p_pl_typ_id               in     number default null
  ,p_person_id               in     number
  ,p_per_in_ler_id           in     number
  ,p_lf_evt_ocrd_dt          in     date
  ,p_business_group_id       in     number
  ,p_effective_date          in     date
  ,p_validate                in     boolean  default false
  ,p_cbr_elig_perd_strt_dt      out nocopy date
  ,p_cbr_elig_perd_end_dt       out nocopy date
  ,p_old_cbr_elig_perd_end_dt   out nocopy date
  ,p_cbr_quald_bnf_id           out nocopy number
  ,p_cqb_object_version_number  out nocopy number
  ,p_cvrd_emp_person_id         out nocopy number
  ,p_dsbld_apls                 out nocopy boolean
  ,p_update                     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_det_end_date            boolean := false;
  l_enrt_cvg_strt_dt        ben_elig_per_elctbl_chc.enrt_cvg_strt_dt%type;
  l_dsblty_elig_perd_end_dt date;
  l_cbr_elig_perd_end_dt    date;
  l_eligible                boolean := false;
  l_exists                  varchar2(1);
  l_typ_cd                  ben_ler_f.typ_cd%type;
  l_jurisdiction_code       varchar2(30);
  l_outputs                 ff_exec.outputs_t;
  l_proc varchar2(72)       := g_package||'determine_cobra_elig_dates';
  --
  cursor c_get_max_poe is
    select peo.*
          ,ler.typ_cd
          ,pil.lf_evt_ocrd_dt
    from ben_elig_to_prte_rsn_f peo
        ,ben_per_in_ler pil
        ,ben_ler_f ler
    where pil.ler_id = peo.ler_id
    and pil.per_in_ler_id = p_per_in_ler_id
    and pil.business_group_id = p_business_group_id
    and peo.business_group_id = pil.business_group_id
    and nvl(p_lf_evt_ocrd_dt, p_effective_date)
    between peo.effective_start_date and peo.effective_end_date
    and nvl(peo.pgm_id,-1) = nvl(p_pgm_id,-1)
    and nvl(peo.ptip_id,-1) = nvl(p_ptip_id,-1)
    and (peo.mx_poe_val is not null or
         peo.mx_poe_rl is not null)
    and pil.ler_id = ler.ler_id
    and nvl(p_lf_evt_ocrd_dt, p_effective_date)
    between ler.effective_start_date and ler.effective_end_date
    and ler.business_group_id = pil.business_group_id
    and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT');
  --
  cursor c_get_quald_bnf is
    select cqb.*
    from ben_cbr_quald_bnf cqb
        ,ben_cbr_per_in_ler crp
        ,ben_per_in_ler pil
    where cqb.quald_bnf_person_id = p_person_id
    and   cqb.business_group_id = p_business_group_id
    and   cqb.cbr_elig_perd_end_dt >= p_lf_evt_ocrd_dt
    and   cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
    and   crp.init_evt_flag = 'Y'
    and   cqb.quald_bnf_flag = 'Y' -- Bug 8211414
    and   cqb.pgm_id = nvl(p_pgm_id, cqb.pgm_id)
    and   nvl(cqb.ptip_id,-1) = nvl(p_ptip_id, -1)
    and   crp.per_in_ler_id = pil.per_in_ler_id
    and   crp.business_group_id = cqb.business_group_id
    and   crp.business_group_id = pil.business_group_id
    and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_enrt_cvg_strt_dt is
    select min(epe.enrt_cvg_strt_dt)
    from ben_elig_per_elctbl_chc epe
    where epe.per_in_ler_id = p_per_in_ler_id
    and   epe.ptip_id = nvl(p_ptip_id, epe.ptip_id)
    and   epe.pgm_id  = nvl(p_pgm_id, epe.pgm_id)
    and   epe.enrt_cvg_strt_dt is not null
    and   epe.elctbl_flag = 'Y'
    and epe.business_group_id = p_business_group_id;
  --
  cursor c_regn is
    select reg.regn_id
    from ben_regn_f reg
    where p_effective_date between
          reg.effective_start_date and reg.effective_end_date
    and reg.business_group_id = p_business_group_id
    and reg.sttry_citn_name = 'COBRA';
  --
  l_regn_id number;
  --
  cursor c_state is
  select loc.region_2,asg.assignment_id,asg.organization_id
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id(+) = asg.location_id
  and asg.person_id = p_person_id
  and asg.assignment_type <> 'C'
  and asg.primary_flag = 'Y'
       and p_effective_date
       between asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id=p_business_group_id;
  --
  -- RCHASE wwbug 1480395 fetch pgm_id, if necessary for formula context
  cursor c_pgm_ptip is
  select pgm_id
    from ben_ptip_f
   where ptip_id = p_ptip_id
     and p_effective_date between effective_start_date
         and effective_end_date;
  --
  cursor c_get_enddsblty_ler is
  select null
    from ben_ler_f ler
        ,ben_per_in_ler pil
   where ler.ler_id = pil.ler_id
     and pil.per_in_ler_id = p_per_in_ler_id
     and ler.typ_cd = 'ENDDSBLTY'
     and p_effective_date between
         ler.effective_start_date and ler.effective_end_date;
  --
  cursor c_get_prvs_elig_end_dt(p_cbr_quald_bnf_id in number) is
  select crp.prvs_elig_perd_end_dt
    from ben_ler_f ler
        ,ben_per_in_ler pil
        ,ben_cbr_per_in_ler crp
   where ler.ler_id = pil.ler_id
     and pil.per_in_ler_id = crp.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and pil.business_group_id = p_business_group_id
     and pil.business_group_id = ler.business_group_id
     and crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
     and crp.business_group_id = ler.business_group_id
     and ler.typ_cd = 'DSBLTY'
     and crp.cnt_num = (select max(crp2.cnt_num)
                        from ben_cbr_per_in_ler crp2
                            ,ben_per_in_ler pil2
                            ,ben_ler_f ler2
                        where crp2.cbr_quald_bnf_id = p_cbr_quald_bnf_id
                        and   crp2.business_group_id = pil2.business_group_id
                        and   crp2.business_group_id = ler2.business_group_id
                        and   crp2.business_group_id = p_business_group_id
                        and   crp2.per_in_ler_id = pil2.per_in_ler_id
                        and   pil2.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                        and   pil2.ler_id = ler2.ler_id
                        and   ler2.qualg_evt_flag = 'Y')
     and p_effective_date between
         ler.effective_start_date and ler.effective_end_date;
  --
  cursor c_get_init_ler(p_cbr_quald_bnf_id in number) is
  select peo.*
        ,pil.lf_evt_ocrd_dt
    from ben_ler_f ler
        ,ben_per_in_ler pil
        ,ben_cbr_per_in_ler crp
        ,ben_elig_to_prte_rsn_f peo
   where ler.ler_id = pil.ler_id
     and pil.per_in_ler_id = crp.per_in_ler_id
     and crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
     and pil.business_group_id = p_business_group_id
     and crp.business_group_id = pil.business_group_id
     and ler.business_group_id = pil.business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and crp.init_evt_flag = 'Y'
     and pil.lf_evt_ocrd_dt
     between peo.effective_start_date and peo.effective_end_date
     and nvl(peo.pgm_id,-1) = nvl(p_pgm_id,-1)
     and nvl(peo.ptip_id,-1) = nvl(p_ptip_id,-1)
     and (peo.mx_poe_val is not null or
          peo.mx_poe_rl is not null)
     and pil.lf_evt_ocrd_dt
         between ler.effective_start_date and ler.effective_end_date;
  --
  l_pgm_id              number:=p_pgm_id;
  -- RCHASE end
  l_cqb_rec             c_get_quald_bnf%rowtype;
  l_poe_rec             c_get_max_poe%rowtype;
  l_poe2_rec            c_get_init_ler%rowtype;
  l_state_rec           c_state%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_pgm_id:'|| p_pgm_id, 10);
  hr_utility.set_location('p_ptip_id:'|| p_ptip_id, 10);
  p_dsbld_apls        := false;
  p_update            := true;
  --
  --  Check if a maximum period of enrollment exists for the life event.
  --  If there is no maximum period of enrollment, set the cobra eligibility
  --  start and end dates to null.
  --
  open c_get_max_poe;
  fetch c_get_max_poe into l_poe_rec;
  if c_get_max_poe%found then
    close c_get_max_poe;

    --
    --  Check if a qualified beneficiary exist for the person.
    --
    open c_get_quald_bnf;
    fetch c_get_quald_bnf into l_cqb_rec;
    --
    if c_get_quald_bnf%notfound then
      close c_get_quald_bnf;
      --
      --  Check if the max period of enrollment is relevant for the person.
      --  i.e. do they have to be a dependent or spouse.
      --
      l_eligible := check_max_poe_eligibility
                      (p_person_id          => p_person_id
                      ,p_mx_poe_apls_cd     => l_poe_rec.mx_poe_apls_cd
                      ,p_lf_evt_ocrd_dt     => p_lf_evt_ocrd_dt
                      ,p_business_group_id  => p_business_group_id
                     );
      if l_eligible then
        --
        --  Calculate start and end dates.
        --
        hr_utility.set_location('mx_poe_det_dt_cd:'|| l_poe_rec.mx_poe_det_dt_cd, 10);
        if (l_poe_rec.mx_poe_det_dt_cd = 'CBRQED'
            or l_poe_rec.mx_poe_det_dt_cd is null) then
          --
        hr_utility.set_location('p_lf_evt_ocrd_dt:'|| p_lf_evt_ocrd_dt, 10);
          p_cbr_elig_perd_strt_dt := p_lf_evt_ocrd_dt;
          --
        elsif l_poe_rec.mx_poe_det_dt_cd = 'ECSD' then
          --
          open c_get_enrt_cvg_strt_dt;
          fetch c_get_enrt_cvg_strt_dt into l_enrt_cvg_strt_dt;
          if l_enrt_cvg_strt_dt is null then
            close c_get_enrt_cvg_strt_dt;
            --
            hr_utility.set_location('Person ID:'|| p_person_id, 10);
            hr_utility.set_location('per_in_ler :'|| p_per_in_ler_id, 10);
            hr_utility.set_location('business_group_id :'|| p_business_group_id, 10);
            --
            --  Problem with eligibility setup. The person has to be
            --  previously enrolled to be eligible for the COBRA program.
            --
            fnd_message.set_name('BEN','BEN_92426_CVG_THRU_DT_NOT_FND');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('PERSON_ID',to_char(p_person_id));
            fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
            fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
            fnd_message.set_token('BG_ID',to_char(p_business_group_id));
            fnd_message.raise_error;
          else
            close c_get_enrt_cvg_strt_dt;
            p_cbr_elig_perd_strt_dt := l_enrt_cvg_strt_dt;
            hr_utility.set_location('l_enrt_cvg_strt_dt prtn:'|| l_enrt_cvg_strt_dt, 10);
          end if;
        elsif l_poe_rec.mx_poe_det_dt_cd = 'RL' then
          --
          -- Get the location info for rule context.
          --
          open c_state;
          fetch c_state into l_state_rec;
          close c_state;
          /*
          if l_state_rec.region_2 is not null then
            l_jurisdiction_code :=
              pay_mag_utils.lookup_jurisdiction_code
               (p_state => l_state_rec.region_2);
          end if;
          */
          --
          open c_regn;
          fetch c_regn into l_regn_id;
          close c_regn;
          --
          -- RCHASE wwbug 1480395 fetch pgm_id, if necessary for formula context
          if l_pgm_id is null then
             open c_pgm_ptip;
             fetch c_pgm_ptip into l_pgm_id;
             close c_pgm_ptip;
          end if;
          --
          l_outputs :=
            benutils.formula
              -- RCHASE wwbug 1480395 pass mx_poe_det_dt_rl
              (p_formula_id        => l_poe_rec.mx_poe_det_dt_rl, --l_poe_rec.mx_poe_rl,
               p_effective_date    => p_lf_evt_ocrd_dt,
               p_assignment_id     => l_state_rec.assignment_id,
               p_organization_id   => l_state_rec.organization_id,
               p_business_group_id => p_business_group_id,
               p_pgm_id            => l_pgm_id,--p_pgm_id,
               p_ler_id            => l_poe_rec.ler_id,
               p_regn_id           => l_regn_id,
               p_jurisdiction_code => l_jurisdiction_code,
	       p_param1            => 'BEN_IV_PERSON_ID',       -- Bug 5331889
               p_param1_value      => to_char(p_person_id));
          --
          -- RCHASE end
          p_cbr_elig_perd_strt_dt :=
            fnd_date.canonical_to_date(l_outputs(l_outputs.first).value);
          --
        end if;
        --
        --  Calculate the COBRA end date.
        --
        p_cbr_elig_perd_end_dt
          := get_cbr_elig_end_dt
               (p_cbr_elig_perd_strt_dt  => p_cbr_elig_perd_strt_dt
               ,p_person_id              => p_person_id
               ,p_pl_typ_id         => p_pl_typ_id
               ,p_mx_poe_uom             => l_poe_rec.mx_poe_uom
               ,p_mx_poe_val             => l_poe_rec.mx_poe_val
               ,p_mx_poe_rl              => l_poe_rec.mx_poe_rl
               ,p_pgm_id                 => p_pgm_id
               ,p_effective_date         => p_lf_evt_ocrd_dt
               ,p_business_group_id      => p_business_group_id
               ,p_ler_id                 => l_poe_rec.ler_id
               );
        --
        --  If person is disabled at the time of the qualifying event,
        --  extend the eligibility end date if the disability extension
        --  date is greater than the eligibility end date for the event.
        --  For example:  If life event is termination i.e. 18 months,
        --  extend the cobra eligibility end date since disability is
        --  typically 29 months.  If life event is divorce i.e. 36 months
        --  there is no change to the cobra eligibility end date.
        --
        if chk_dsbld(p_person_id         => p_person_id
                    ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                    ,p_effective_date    => p_effective_date
                    ,p_business_group_id => p_business_group_id) then
          --
          --  Get disability eligibility end date.
          --
          l_dsblty_elig_perd_end_dt
            := get_dsblty_elig_perd_end_dt
                 (p_person_id             => p_person_id
                 ,p_pl_typ_id         => p_pl_typ_id
                 ,p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt
                 ,p_cbr_elig_perd_strt_dt => p_cbr_elig_perd_strt_dt
                 ,p_pgm_id                => p_pgm_id
                 ,p_ptip_id               => p_ptip_id
                 ,p_effective_date        => p_effective_date
                 ,p_business_group_id     => p_business_group_id);
          --
          if l_dsblty_elig_perd_end_dt > p_cbr_elig_perd_end_dt then
            p_cbr_elig_perd_end_dt := l_dsblty_elig_perd_end_dt;
            --
            p_dsbld_apls := true;
          end if;
        end if;
      else
        p_cbr_elig_perd_strt_dt     := null;
        p_cbr_elig_perd_end_dt      := null;
      end if;
      --
      p_old_cbr_elig_perd_end_dt  := null;
      p_cbr_quald_bnf_id          := null;
      p_cqb_object_version_number := null;
      p_cvrd_emp_person_id        := null;
    else
      close c_get_quald_bnf;
      p_cbr_elig_perd_strt_dt     := l_cqb_rec.cbr_elig_perd_strt_dt;
      p_cbr_elig_perd_end_dt      := l_cqb_rec.cbr_elig_perd_end_dt;
      p_old_cbr_elig_perd_end_dt  := l_cqb_rec.cbr_elig_perd_end_dt;
      p_cbr_quald_bnf_id          := l_cqb_rec.cbr_quald_bnf_id;
      p_cqb_object_version_number := l_cqb_rec.object_version_number;
      p_cvrd_emp_person_id        := l_cqb_rec.cvrd_emp_person_id;
      --
      --  If it is not a disability event or the person was disabled after 60
      --  days then calculate the dates.
      --
      if (l_poe_rec.typ_cd <> 'DSBLTY' or
         (l_poe_rec.typ_cd = 'DSBLTY' and
          (p_lf_evt_ocrd_dt - l_cqb_rec.cbr_elig_perd_strt_dt) <= 60)) then
        --
        --  If person is a COBRA beneficiary, then check if the max poe
        --  only applies to dependents of the covered employee.
        --
        --
        --  Check if the max period of enrollment is relevant for the person.
        --  i.e. do they have to be a dependent or spouse.
        --
        l_eligible := check_max_poe_eligibility
                        (p_person_id           => p_person_id
                        ,p_mx_poe_apls_cd      => l_poe_rec.mx_poe_apls_cd
                        ,p_cvrd_emp_person_id  => l_cqb_rec.cvrd_emp_person_id
                        ,p_quald_bnf_person_id => l_cqb_rec.quald_bnf_person_id
                        ,p_cbr_quald_bnf_id    => l_cqb_rec.cbr_quald_bnf_id
                        ,p_lf_evt_ocrd_dt      => p_lf_evt_ocrd_dt
                        ,p_business_group_id   => p_business_group_id
                        );
        if l_eligible then
          --
          --  Redetermine COBRA end date.
          --
          p_cbr_elig_perd_end_dt
            := get_cbr_elig_end_dt
                 (p_cbr_elig_perd_strt_dt  => p_cbr_elig_perd_strt_dt
                 ,p_person_id              => p_person_id
                 ,p_pl_typ_id         => p_pl_typ_id
                 ,p_mx_poe_uom             => l_poe_rec.mx_poe_uom
                 ,p_mx_poe_val             => l_poe_rec.mx_poe_val
                 ,p_mx_poe_rl              => l_poe_rec.mx_poe_rl
                 ,p_pgm_id                 => p_pgm_id
                 ,p_effective_date         => p_lf_evt_ocrd_dt
                 ,p_business_group_id      => p_business_group_id
                 ,p_ler_id                 => l_poe_rec.ler_id
                 );
          --
          --  If it is the initial event, check if person was disable
          --  at the time of the qualifying event.
          --
          if chk_init_evt(p_per_in_ler_id => p_per_in_ler_id
                     ,p_business_group_id => p_business_group_id) then
            --
            if chk_dsbld(p_person_id         => p_person_id
                        ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                        ,p_effective_date    => p_effective_date
                        ,p_business_group_id => p_business_group_id) then
              --
              --  Get disability eligibility end date.
              --
              l_dsblty_elig_perd_end_dt
                := get_dsblty_elig_perd_end_dt
                     (p_person_id             => p_person_id
                     ,p_pl_typ_id         => p_pl_typ_id
                     ,p_lf_evt_ocrd_dt        => p_lf_evt_ocrd_dt
                     ,p_cbr_elig_perd_strt_dt => p_lf_evt_ocrd_dt
                     ,p_pgm_id                => p_pgm_id
                     ,p_ptip_id               => p_ptip_id
                     ,p_effective_date        => p_effective_date
                     ,p_business_group_id     => p_business_group_id);
              --
              if l_dsblty_elig_perd_end_dt > p_cbr_elig_perd_end_dt then
                p_cbr_elig_perd_end_dt := l_dsblty_elig_perd_end_dt;
                --
                p_dsbld_apls := true;
              end if;
            end if;
          else -- not initial event.
            --
            -- If the calculated date is greater that the current
            -- eligibility end date.
            --
            if p_cbr_elig_perd_end_dt <> l_cqb_rec.cbr_elig_perd_end_dt then
              --
              --   Check if life event type is disability.  If it is check
              --   if the life event ocurred date is within the first 60 days
              --   of the initial qualifying event. If it is within the first
              --   60 days, then extend the COBRA start and end for all person
              --   with the same covered employee id.
            --
              if l_poe_rec.typ_cd = 'DSBLTY'then
                if p_cbr_elig_perd_end_dt > l_cqb_rec.cbr_elig_perd_end_dt then
                  p_dsbld_apls := true;
                else
                  --
                  --  Person's current eligibility date is greater than the
                  --  disability extension date.
                  --
                  p_cbr_elig_perd_end_dt := l_cqb_rec.cbr_elig_perd_end_dt;
                end if;
              end if;
                --
            end if;
          end if;
        else
          p_update := false;
        end if;
      else
        p_update := false;
      end if;
    end if;
  else
    close c_get_max_poe;
    --
    p_cbr_elig_perd_strt_dt     := null;
    p_cbr_elig_perd_end_dt      := null;
    p_old_cbr_elig_perd_end_dt  := null;
    p_cbr_quald_bnf_id          := null;
    p_cqb_object_version_number := null;
    p_cvrd_emp_person_id        := null;
    --
    --  If it is an end of disability event and a qualified beneficiary row
    --  exists, re-instate the previous cobra eligibility end date
    --  (the event prior to disability or the initial qualifying event)
    --  as the person is no longer eligible for the COBRA extension.
    --  If the life event occurred date is greater that the previous cobra
    --  eligibility date, then set the eligibility end date to the life event
    --  occurred date.
    --
    open c_get_enddsblty_ler;
    fetch c_get_enddsblty_ler into l_exists;
    if c_get_enddsblty_ler%found  then
      --
      -- Get the qualified beneficiary row.
      --
      open c_get_quald_bnf;
      fetch c_get_quald_bnf into l_cqb_rec;
      if c_get_quald_bnf%found then
        p_cbr_elig_perd_strt_dt     := l_cqb_rec.cbr_elig_perd_strt_dt;
        p_cbr_elig_perd_end_dt      := l_cqb_rec.cbr_elig_perd_end_dt;
        p_old_cbr_elig_perd_end_dt  := l_cqb_rec.cbr_elig_perd_end_dt;
        p_cbr_quald_bnf_id          := l_cqb_rec.cbr_quald_bnf_id;
        p_cqb_object_version_number := l_cqb_rec.object_version_number;
        p_cvrd_emp_person_id        := l_cqb_rec.cvrd_emp_person_id;
        --
        --  The last qualifying event has to be a disability event
        --  or the person was disabled at the time of the initial
        --  qualifying event.
        --
        open c_get_prvs_elig_end_dt(l_cqb_rec.cbr_quald_bnf_id);
        fetch c_get_prvs_elig_end_dt into l_cbr_elig_perd_end_dt;
        if c_get_prvs_elig_end_dt%found then
          if p_lf_evt_ocrd_dt > l_cbr_elig_perd_end_dt then
            p_cbr_elig_perd_end_dt := p_lf_evt_ocrd_dt;
          else
            p_cbr_elig_perd_end_dt := l_cbr_elig_perd_end_dt;
          end if;
        else
          open c_get_init_ler(l_cqb_rec.cbr_quald_bnf_id);
          fetch c_get_init_ler into l_poe2_rec;
          if c_get_init_ler%found then
            --
            --  Check if person was disabled at the time of
            --  the initial qualifying event.
            --
            if chk_dsbld
               (p_person_id         => p_person_id
               ,p_lf_evt_ocrd_dt    => l_poe2_rec.lf_evt_ocrd_dt
               ,p_effective_date    => p_effective_date
               ,p_business_group_id => p_business_group_id) then
              --
              -- Calculate the initial qualifying event eligibility
              -- end date.
              --
              p_cbr_elig_perd_end_dt
                := get_cbr_elig_end_dt
                     (p_cbr_elig_perd_strt_dt => l_cqb_rec.cbr_elig_perd_strt_dt
                     ,p_person_id             => p_person_id
                     ,p_pl_typ_id             => p_pl_typ_id
                     ,p_mx_poe_uom            => l_poe2_rec.mx_poe_uom
                     ,p_mx_poe_val            => l_poe2_rec.mx_poe_val
                     ,p_mx_poe_rl             => l_poe2_rec.mx_poe_rl
                     ,p_pgm_id                => p_pgm_id
                     ,p_effective_date        => l_poe2_rec.lf_evt_ocrd_dt
                     ,p_business_group_id     => p_business_group_id
                     ,p_ler_id                => l_poe2_rec.ler_id
                     );
              if p_lf_evt_ocrd_dt > p_cbr_elig_perd_end_dt then
                p_cbr_elig_perd_end_dt := p_lf_evt_ocrd_dt;
              end if;
            else
              p_cbr_elig_perd_strt_dt     := null;
              p_cbr_elig_perd_end_dt      := null;
              p_old_cbr_elig_perd_end_dt  := null;
              p_cbr_quald_bnf_id          := null;
              p_cqb_object_version_number := null;
              p_cvrd_emp_person_id        := null;
              --
              --  Person was not disabled at the time of the qualifying
              --  event so the end of disabity event is not valid.
              --
              fnd_message.set_name('BEN','BEN_92970_CBR_PER_NOT_DSBLD');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.set_token('PERSON_ID',to_char(p_person_id));
              fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
              fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
              if fnd_global.conc_request_id <> -1 then
                benutils.write(fnd_message.get);
              end if;
            end if;
            --
          else
            p_cbr_elig_perd_strt_dt     := null;
            p_cbr_elig_perd_end_dt      := null;
            p_old_cbr_elig_perd_end_dt  := null;
            p_cbr_quald_bnf_id          := null;
            p_cqb_object_version_number := null;
            p_cvrd_emp_person_id        := null;
            fnd_message.set_name('BEN','BEN_92970_CBR_PER_NOT_DSBLD');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('PERSON_ID',to_char(p_person_id));
            fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
            fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
            if fnd_global.conc_request_id <> -1 then
              benutils.write(fnd_message.get);
            end if;
          end if;
          close c_get_init_ler;
          --
        end if;
        --
        close c_get_prvs_elig_end_dt;
        --
      end if;
      close c_get_quald_bnf;
      --
    end if;
    close c_get_enddsblty_ler;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end determine_cobra_elig_dates;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_cbr_elig_end_dt >-- ------------------------
-- ----------------------------------------------------------------------------
--
function get_cbr_elig_end_dt
           (p_cbr_elig_perd_strt_dt  in date
           ,p_person_id              in number
           ,p_pl_typ_id              in number default null
           ,p_mx_poe_uom             in varchar2
           ,p_mx_poe_val             in number
           ,p_mx_poe_rl              in number
           ,p_pgm_id                 in number
           ,p_effective_date         in date
           ,p_business_group_id      in number
           ,p_ler_id                 in number) return date is
  --
  l_proc                varchar2(80) := g_package||'.get_cbr_elig_end_dt';
  l_outputs             ff_exec.outputs_t;
  l_return_date         date;
  l_jurisdiction_code   varchar2(30);
  --
  cursor c_state is
  select loc.region_2,asg.assignment_id,asg.organization_id
  from hr_locations_all loc,per_all_assignments_f asg
  where loc.location_id(+) = asg.location_id
  and asg.assignment_type <> 'C'
  and asg.person_id = p_person_id
  and asg.primary_flag = 'Y'
       and p_effective_date
       between asg.effective_start_date and asg.effective_end_date
       and asg.business_group_id=p_business_group_id;
  --
  l_state_rec           c_state%rowtype;
  --
  cursor c_regn is
    select reg.regn_id
    from ben_regn_f reg
    where p_effective_date between
          reg.effective_start_date and reg.effective_end_date
    and reg.business_group_id = p_business_group_id
    and reg.sttry_citn_name = 'COBRA';
  --
  l_regn_id number;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  if p_mx_poe_rl is not null then
    --
    -- Get the location info for rule context.
    --
    open c_state;
    fetch c_state into l_state_rec;
    close c_state;
    /*
    if l_state_rec.region_2 is not null then
      l_jurisdiction_code :=
             pay_mag_utils.lookup_jurisdiction_code
               (p_state => l_state_rec.region_2);
     end if;
    */
     --
     open c_regn;
     fetch c_regn into l_regn_id;
     close c_regn;
     --
     l_outputs :=
       benutils.formula
         (p_formula_id       => p_mx_poe_rl,
         p_effective_date    => p_effective_date,
         p_assignment_id     => l_state_rec.assignment_id,
         p_organization_id   => l_state_rec.organization_id,
         p_business_group_id => p_business_group_id,
         p_pgm_id            => p_pgm_id,
         p_pl_typ_id         => p_pl_typ_id,
         p_ler_id            => p_ler_id,
         p_regn_id           => l_regn_id,
         p_jurisdiction_code => l_jurisdiction_code,
         p_param1            => 'BEN_IV_PERSON_ID',       -- Bug 5331889
         p_param1_value      => to_char(p_person_id));
        --
      l_return_date
        := fnd_date.canonical_to_date(l_outputs(l_outputs.first).value);
   else
     --
     hr_utility.set_location('p_cbr_elig_perd_strt_dt : ' || p_cbr_elig_perd_strt_dt, 10);
     hr_utility.set_location('p_mx_poe_uom : ' || p_mx_poe_uom, 10);
     hr_utility.set_location('p_mx_poe_val : ' || p_mx_poe_val, 10);
     l_return_date := benutils.derive_date
                        (p_date   => p_cbr_elig_perd_strt_dt
                        ,p_uom    => p_mx_poe_uom
                        ,p_min    => null
                        ,p_max    => p_mx_poe_val
                        ,p_value  => null
                        ) - 1;
   end if;
       --
  hr_utility.set_location('l_return_date : ' || l_return_date, 10);
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  return l_return_date;
end get_cbr_elig_end_dt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_pgm_typ >-----------------------------------
-- ----------------------------------------------------------------------------
--
function chk_pgm_typ
           (p_pgm_id            in number
           ,p_effective_date    in date
           ,p_business_group_id in number) return boolean is
  --
  l_proc                varchar2(80) := g_package||'.chk_pgm_typ';
  l_exists              varchar2(1);
  l_update              boolean := false;
  --
  cursor c_chk_pgm_typ is
  select null
  from ben_pgm_f pgm
  where pgm.pgm_id = p_pgm_id
  and pgm.pgm_typ_cd like 'COBRA%'
  and p_effective_date
  between pgm.effective_start_date and pgm.effective_end_date
  and pgm.business_group_id=p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  open c_chk_pgm_typ;
  fetch c_chk_pgm_typ into l_exists;
  if c_chk_pgm_typ%found then
    l_update := true;
  end if;
  close c_chk_pgm_typ;
  --
  return l_update;
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
end chk_pgm_typ;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_enrld_or_cvrd >-----------------------------
-- ----------------------------------------------------------------------------
--
function chk_enrld_or_cvrd
           (p_pgm_id            in number default null
           ,p_ptip_id           in number default null
           ,p_person_id         in number
           ,p_effective_date    in date
           ,p_business_group_id in number
           ,p_cvrd_today        in varchar2 default null)
           return boolean is

  --
  l_proc                varchar2(80) := g_package||'.chk_enrld_or_cvrd';
  l_exists              varchar2(1);
  l_enrld_or_cvrd       boolean := false;
  --
  cursor c_chk_enrld is
    select null
    from   ben_prtt_enrt_rslt_f pen
          ,ben_pl_f             pln
          ,ben_oipl_f           cop
          ,ben_opt_f            opt
    where pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.pgm_id = nvl(p_pgm_id, pen.pgm_id)
    -- and pen.ptip_id = nvl(p_ptip_id, pen.ptip_id)
    and pen.sspndd_flag = 'N'
    ---
   and
   ( (
      nvl(p_cvrd_today,'N') = 'N'
      and pen.enrt_cvg_thru_dt = hr_api.g_eot
      and pen.effective_end_date = hr_api.g_eot
      and p_effective_date between pen.effective_start_date
                             and pen.effective_end_date
     ) OR
     (
      nvl(p_cvrd_today,'N') = 'Y'
      AND  pen.effective_end_date = hr_api.g_eot
      AND  p_effective_date BETWEEN pen.enrt_cvg_strt_dt
           AND pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_strt_dt < pen.effective_end_date
     )
    )
    and pen.business_group_id = p_business_group_id
    and pen.pl_id = pln.pl_id
    and pln.invk_dcln_prtn_pl_flag = 'N'
    and p_effective_date between pln.effective_start_date
                             and pln.effective_end_date
    and pln.business_group_id = pen.business_group_id
    and pen.oipl_id = cop.oipl_id (+)
    and pen.business_group_id = cop.business_group_id (+)
    and p_effective_date between
        cop.effective_start_date (+)
        and cop.effective_end_date (+)
    and cop.opt_id = opt.opt_id (+)
    and nvl(opt.invk_wv_opt_flag,'N') = 'N'
    and cop.business_group_id = opt.business_group_id (+)
    and p_effective_date between
        opt.effective_start_date (+)
        and opt.effective_end_date (+);
  --
  cursor c_chk_cvrd is
    select null
    from   ben_prtt_enrt_rslt_f pen
          ,ben_elig_cvrd_dpnt_f pdp
    where pdp.dpnt_person_id = p_person_id
    and pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.pgm_id = nvl(p_pgm_id, pen.pgm_id)
    -- and pen.ptip_id = nvl(p_ptip_id, pen.ptip_id)
    and pen.sspndd_flag = 'N'
      ---
    and
    ( (
       nvl(p_cvrd_today,'N') = 'N'
       and pdp.cvg_thru_dt = hr_api.g_eot
       and pdp.cvg_thru_dt <= pdp.effective_end_date
       and p_effective_date between pdp.effective_start_date
                  and pdp.effective_end_date
      ) OR
      (
        nvl(p_cvrd_today,'N') = 'Y'
        AND  pdp.effective_end_date = hr_api.g_eot
        AND  p_effective_date BETWEEN pdp.cvg_strt_dt
             AND pdp.cvg_thru_dt
        AND  pdp.cvg_strt_dt < pdp.effective_end_date
     )
    )
    --and pen.effective_end_date = hr_api.g_eot
    and p_effective_date between pen.effective_start_date
        and pen.effective_end_date
    and pen.business_group_id = p_business_group_id
    and pdp.business_group_id = pen.business_group_id;

  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  --  Check if enrolled.
  --
  open c_chk_enrld;
  fetch c_chk_enrld into l_exists;
  if c_chk_enrld%found then
    l_enrld_or_cvrd := true;
    hr_utility.set_location('Enrolled', 10);
  else
    --
    --  Check if covered.
    --
    open c_chk_cvrd;
    fetch c_chk_cvrd into l_exists;
    if c_chk_cvrd%found then
      l_enrld_or_cvrd:= true;
    end if;
    close c_chk_cvrd;
  end if;
  close c_chk_enrld;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  return l_enrld_or_cvrd;
  --
end chk_enrld_or_cvrd;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_max_cvg_thru_dt >------------------------------
-- ----------------------------------------------------------------------------
--
function get_max_cvg_thru_dt
           (p_person_id         in number
           ,p_lf_evt_ocrd_dt    in date
           ,p_pgm_id            in number default null
           ,p_ptip_id           in number default null
           ,p_per_in_ler_id     in number
           ,p_effective_date    in date
           ,p_business_group_id in number) return date is
  --
  l_proc                varchar2(80) := g_package||'.get_max_enrt_cvg_thru_dt';
  l_exists              varchar2(1);
  l_cvg_thru_dt         ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%type;
  l_enrt_cvg_thru_dt    ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%type;
  l_dpnt_cvg_thru_dt    ben_elig_cvrd_dpnt_f.cvg_thru_dt%type;
  --
  cursor c_get_enrt_cvg_thru_dt is
    select max(pen.enrt_cvg_thru_dt)
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id = p_person_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.sspndd_flag = 'N'
    and pen.pgm_id = nvl(p_pgm_id,pen.pgm_id)
    --
    -- Bug 3368053:  Remove ptip_id
    -- and pen.ptip_id = nvl(p_ptip_id,pen.ptip_id)
    and pen.prtt_enrt_rslt_stat_cd is null
    and nvl(pen.per_in_ler_id,-1) = nvl(p_per_in_ler_id, -1)
    and pen.enrt_cvg_thru_dt <> hr_api.g_eot
    and pen.effective_end_date = hr_api.g_eot
    -- Bug 7116537, Commented the condition p_effective_date between effective_start_date and effective_end_date
    /*and p_effective_date between
        pen.effective_start_date and pen.effective_end_date*/
    and pen.business_group_id = p_business_group_id;
  --
  cursor c_get_dpnt_cvg_thru_dt is
    select max(pdp.cvg_thru_dt)
    from   ben_elig_cvrd_dpnt_f pdp
          ,ben_prtt_enrt_rslt_f pen
    where pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pdp.dpnt_person_id = p_person_id
    and pen.pgm_id = p_pgm_id
    --
    -- Bug 3368053:  Remove ptip_id
    -- and pen.ptip_id = nvl(p_ptip_id,pen.ptip_id)
    and p_effective_date between pen.effective_start_date
                             and pen.effective_end_date
    and pen.business_group_id = p_business_group_id
    and pdp.cvg_thru_dt <> hr_api.g_eot
    and p_lf_evt_ocrd_dt >= pdp.cvg_strt_dt
    and pdp.effective_end_date = hr_api.g_eot
    and p_effective_date between pdp.effective_start_date
                             and pdp.effective_end_date
    and pdp.business_group_id = pen.business_group_id
    group by pdp.dpnt_person_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  hr_utility.set_location('p_pgm_id : ' || p_pgm_id, 10);
  hr_utility.set_location('p_ptip_id : ' || p_ptip_id, 10);
  hr_utility.set_location('p_person_id : ' || p_person_id, 10);
  --
  open c_get_enrt_cvg_thru_dt;
  fetch c_get_enrt_cvg_thru_dt into l_enrt_cvg_thru_dt;
  close c_get_enrt_cvg_thru_dt;
  --
  --  Check if person is a covered dependent.
  --
  open c_get_dpnt_cvg_thru_dt;
  fetch c_get_dpnt_cvg_thru_dt into l_dpnt_cvg_thru_dt;
  close c_get_dpnt_cvg_thru_dt;
  --
  l_cvg_thru_dt := greatest(nvl(l_enrt_cvg_thru_dt, hr_api.g_sot)
                           ,nvl(l_dpnt_cvg_thru_dt,hr_api.g_sot));
  return l_cvg_thru_dt;
  --
end get_max_cvg_thru_dt;
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_cobra_elig_info  >----------------------------
-- ----------------------------------------------------------------------------
--
procedure update_cobra_elig_info
           (p_person_id         in number
           ,p_per_in_ler_id     in number
           ,p_lf_evt_ocrd_dt    in date
           ,p_effective_date    in date
           ,p_business_group_id in number
           ,p_validate          in boolean default false) is
  --
  l_proc                       varchar2(80) := g_package||
                                                 '.update_cobra_elig_info';
  l_ptip_id                    ben_ptip_f.ptip_id%type;
  l_pgm_id                     ben_pgm_f.pgm_id%type;
  l_cbr_elig_perd_strt_dt      ben_cbr_quald_bnf.cbr_elig_perd_strt_dt%type;
  l_cbr_elig_perd_end_dt       ben_cbr_quald_bnf.cbr_elig_perd_end_dt%type;
  l_old_cbr_elig_perd_end_dt   ben_cbr_quald_bnf.cbr_elig_perd_end_dt%type;
  l_cbr_quald_bnf_id           ben_cbr_quald_bnf.cbr_quald_bnf_id%type;
  l_cqb_object_version_number  ben_cbr_quald_bnf.object_version_number%type;
  l_cvrd_emp_person_id         ben_cbr_quald_bnf.cvrd_emp_person_id%type;
  l_dsbld_apls                 boolean;
  l_update                     boolean;
  --
  cursor c_get_epe is
    select epe.*, pgm.poe_lvl_cd
    from ben_elig_per_elctbl_chc epe
        ,ben_pgm_f pgm
    where epe.per_in_ler_id = p_per_in_ler_id
    and   epe.business_group_id = p_business_group_id
    and   epe.pgm_id = pgm.pgm_id
    and nvl(p_lf_evt_ocrd_dt, p_effective_date)
    between pgm.effective_start_date and pgm.effective_end_date
    and pgm.business_group_id = p_business_group_id
    and pgm.pgm_typ_cd like 'COBRA%'
    order by epe.pgm_id, epe.ptip_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  for  l_epe_rec in c_get_epe loop
     --
     --   A person can only be eligible in one COBRA program.
     --
    if (l_epe_rec.poe_lvl_cd = 'PGM' or
       l_epe_rec.poe_lvl_cd is null) then
      --
      if nvl(l_pgm_id,-1) <> l_epe_rec.pgm_id then
        --
        -- Determine cobra eligibility start and end dates.
        --
        determine_cobra_elig_dates
          (p_pgm_id                    => l_epe_rec.pgm_id
          ,p_pl_typ_id                 => l_epe_rec.pl_typ_id
          ,p_person_id                 => p_person_id
          ,p_per_in_ler_id             => p_per_in_ler_id
          ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_validate                  => p_validate
          ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
          ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
          ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
          ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
          ,p_cqb_object_version_number => l_cqb_object_version_number
          ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
          ,p_dsbld_apls                => l_dsbld_apls
          ,p_update                    => l_update
          );
        --
        --  Only update the cobra information if the eligibility start
        --  and end dates are not null
        --
        if (l_cbr_elig_perd_strt_dt is not null and
            l_cbr_elig_perd_end_dt is not null and
            l_update)
        then
          update_cobra_info
            (p_per_in_ler_id              => p_per_in_ler_id
            ,p_person_id                  => p_person_id
            ,p_cbr_quald_bnf_id           => l_cbr_quald_bnf_id
            ,p_cqb_object_version_number  => l_cqb_object_version_number
            ,p_cbr_elig_perd_strt_dt      => l_cbr_elig_perd_strt_dt
            ,p_old_cbr_elig_perd_end_dt   => l_old_cbr_elig_perd_end_dt
            ,p_cbr_elig_perd_end_dt       => l_cbr_elig_perd_end_dt
            ,p_dsbld_apls                 => l_dsbld_apls
            ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
            ,p_cvrd_emp_person_id         => l_cvrd_emp_person_id
            ,p_business_group_id          => p_business_group_id
            ,p_effective_date             => p_effective_date
            ,p_pgm_id                     => l_epe_rec.pgm_id
            ,p_validate                   => p_validate
            );
        else
          --
          fnd_message.set_name('BEN','BEN_92428_CBR_DATES_NOT_FOUND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('PERSON_ID',to_char(p_person_id));
          fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
          fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
          if fnd_global.conc_request_id <> -1 then
            benutils.write(fnd_message.get);
          end if;
          --
        end if;
          l_pgm_id := l_epe_rec.pgm_id;
        --
      end if;
      --
    elsif l_epe_rec.poe_lvl_cd = 'PTIP' then
      --
      hr_utility.set_location('poe_lvl_cd : ' || l_epe_rec.poe_lvl_cd, 10);
      hr_utility.set_location('l_ptip_id : ' || l_ptip_id, 10);
      hr_utility.set_location('l_epe_rec.ptip_id : ' || l_epe_rec.ptip_id, 10);
      --
      if nvl(l_ptip_id,-1) <> l_epe_rec.ptip_id then
        --
        -- Determine cobra eligibility start and end dates.
        --
        determine_cobra_elig_dates
          (p_ptip_id                   => l_epe_rec.ptip_id
          ,p_pl_typ_id                 => l_epe_rec.pl_typ_id
          ,p_person_id                 => p_person_id
          ,p_per_in_ler_id             => p_per_in_ler_id
          ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_validate                  => p_validate
          ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
          ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
          ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
          ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
          ,p_cqb_object_version_number => l_cqb_object_version_number
          ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
          ,p_dsbld_apls                => l_dsbld_apls
          ,p_update                    => l_update
          );
          --
          --  Only update the cobra information if the eligibility start
          --  and end dates are not null.
          --
        if (l_cbr_elig_perd_strt_dt is not null and
            l_cbr_elig_perd_end_dt is not null and
            l_update)
        then
          --
          update_cobra_info
            (p_per_in_ler_id              => p_per_in_ler_id
            ,p_person_id                  => p_person_id
            ,p_cbr_quald_bnf_id           => l_cbr_quald_bnf_id
            ,p_cqb_object_version_number  => l_cqb_object_version_number
            ,p_cbr_elig_perd_strt_dt      => l_cbr_elig_perd_strt_dt
            ,p_old_cbr_elig_perd_end_dt   => l_old_cbr_elig_perd_end_dt
            ,p_cbr_elig_perd_end_dt       => l_cbr_elig_perd_end_dt
            ,p_dsbld_apls                 => l_dsbld_apls
            ,p_lf_evt_ocrd_dt             => p_lf_evt_ocrd_dt
            ,p_cvrd_emp_person_id         => l_cvrd_emp_person_id
            ,p_business_group_id          => p_business_group_id
            ,p_effective_date             => p_effective_date
            ,p_pgm_id                     => l_epe_rec.pgm_id
            ,p_pl_typ_id                  => l_epe_rec.pl_typ_id
            ,p_ptip_id                    => l_epe_rec.ptip_id
            ,p_validate                   => p_validate
            );
          --
        else
          --
          fnd_message.set_name('BEN','BEN_92428_CBR_DATES_NOT_FOUND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('PERSON_ID',to_char(p_person_id));
          fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
          fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
          --
          if fnd_global.conc_request_id <> -1 then
            benutils.write(fnd_message.get);
          end if;
        end if;
        --
        l_ptip_id := l_epe_rec.ptip_id;
        --
      end if;
    --
    end if;
  end loop;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  --
end update_cobra_elig_info;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_max_poe_eligibility >---------------------
-- ---------------------------------------------------------------------------
--
function check_max_poe_eligibility
           (p_person_id           in number
           ,p_mx_poe_apls_cd      in varchar2
           ,p_cvrd_emp_person_id  in number default null
           ,p_quald_bnf_person_id in number default null
           ,p_cbr_quald_bnf_id    in number default null
           ,p_lf_evt_ocrd_dt      in date
           ,p_business_group_id   in number) return boolean is
  --
  --
  l_effective_date   per_person_type_usages_f.effective_start_date%type;
  l_eligible         boolean := false;
  l_exists           varchar2(1);
  l_proc             varchar2(80) := g_package||'.check_max_poe_eligibility';
  --
  cursor c_chk_cvrd_emp is
    select null
    from  per_person_type_usages_f ptu
         ,per_person_types pet
    where ptu.person_type_id = pet.person_type_id
    and ptu.person_id = p_person_id
    and l_effective_date between
        ptu.effective_start_date and ptu.effective_end_date
    and pet.system_person_type = 'PRTN';
  --
  cursor c_get_contact_type is
  select null
  from per_contact_relationships ctr
  where ctr.person_id = p_person_id
  and ctr.contact_type = 'S'
  and p_lf_evt_ocrd_dt
  between nvl(ctr.date_start,hr_api.g_sot) and
  nvl(ctr.date_end,hr_api.g_eot)
  and ctr.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  l_effective_date := p_lf_evt_ocrd_dt - 1;
  --
  --  only applies to dependents of the covered employee.
  --
  if p_mx_poe_apls_cd = 'ACDPNT' then
  hr_utility.set_location('ACDPNT : ' || l_proc, 10);
    --
    --  If qualified beneficiary exists,
    --
    hr_utility.set_location('p_cbr_quald_bnf_id : ' || p_cbr_quald_bnf_id, 10);
    hr_utility.set_location('p_cvrd_emp_person_id : ' || p_cvrd_emp_person_id, 10);
    hr_utility.set_location('p_quald_bnf_person_id : ' || p_quald_bnf_person_id, 10);
    if p_cbr_quald_bnf_id is not null then
      --
      --  Check if the person is a covered dependent.
      --
      if p_cvrd_emp_person_id <> p_quald_bnf_person_id then
        l_eligible := true;
      end if;
    else
      --
      -- check if person is the covered employee.
      --
      open c_chk_cvrd_emp;
      fetch c_chk_cvrd_emp into l_exists;
      if c_chk_cvrd_emp%notfound then
        --
        -- Person is a covered dependent.
        --
        l_eligible := true;
      end if;
      close c_chk_cvrd_emp;
    end if;
  elsif p_mx_poe_apls_cd = 'CSPS' then
    --
    --  if max poe only applies to spouse, check if person is
    --  a spouse.
    --
    if p_cbr_quald_bnf_id is not null then
      if p_cvrd_emp_person_id <> p_quald_bnf_person_id then
        --
        open c_get_contact_type;
        fetch c_get_contact_type into l_exists;
        if c_get_contact_type%found then
          l_eligible := true;
        end if;
        close c_get_contact_type;
      end if;
    else
      --
      -- check if person is the covered employee.
      --
      open c_chk_cvrd_emp;
      fetch c_chk_cvrd_emp into l_exists;
      if c_chk_cvrd_emp%notfound then
        --
        --  Check if person is a spouse.
        --
        open c_get_contact_type;
        fetch c_get_contact_type into l_exists;
        if c_get_contact_type%found then
          l_eligible := true;
        end if;
        close c_get_contact_type;
      end if;
      close c_chk_cvrd_emp;
    end if;
  else
    l_eligible := true;
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  return l_eligible;
end check_max_poe_eligibility;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_dpnt_cobra_info >-----------------------------
-- ----------------------------------------------------------------------------
--
procedure update_dpnt_cobra_info
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_prtt_enrt_rslt_id         in number
           ,p_validate                  in boolean  default false)   is
  --
  l_effective_date            ben_per_in_ler.lf_evt_ocrd_dt%type;
  l_quald_bnf_flag            ben_cbr_quald_bnf.quald_bnf_flag%type;
  l_cvrd_emp_person_id        ben_cbr_quald_bnf.cvrd_emp_person_id%type;
  l_dsbld_apls                boolean;
  l_update                    boolean;
  l_cbr_elig_perd_strt_dt     ben_cbr_quald_bnf.cbr_elig_perd_strt_dt%type;
  l_cbr_elig_perd_end_dt      ben_cbr_quald_bnf.cbr_elig_perd_end_dt%type;
  l_lf_evt_ocrd_dt            ben_per_in_ler.lf_evt_ocrd_dt%type;
  l_old_cbr_elig_perd_end_dt  ben_cbr_quald_bnf.cbr_elig_perd_end_dt%type;
  l_cbr_quald_bnf_id          ben_cbr_quald_bnf.cbr_quald_bnf_id%type;
  l_cqb_object_version_number ben_cbr_quald_bnf.object_version_number%type;

  l_per_in_ler_id          ben_per_in_ler.per_in_ler_id%type;
  l_exists                 varchar2(1);
  l_init_evt               boolean := false;
  l_pgm_id                 ben_pgm_f.pgm_id%type;
  l_ptip_id                ben_ptip_f.ptip_id%type;
  l_pl_typ_id              ben_pl_typ_f.pl_typ_id%type;
  l_cqb_ptip_id            ben_ptip_f.ptip_id%type;
  l_poe_lvl_cd             ben_pgm_f.poe_lvl_cd%type;
  l_enrld_person_id        ben_prtt_enrt_rslt_f.person_id%type;
  l_proc                   varchar2(80) := g_package||'.update_dpnt_cobra_info';
  --
  cursor c_get_cbr_quald_bnf
  is
    select cqb.*
    from   ben_cbr_quald_bnf cqb
          ,ben_cbr_per_in_ler crp
          ,ben_per_in_ler pil
    where  cqb.quald_bnf_person_id = p_person_id
    and    nvl(cqb.cbr_elig_perd_end_dt,l_lf_evt_ocrd_dt) >= l_lf_evt_ocrd_dt
    and    cqb.pgm_id = l_pgm_id
    and    nvl(cqb.ptip_id,l_ptip_id) = l_ptip_id
    and    crp.cbr_quald_bnf_id = cqb.cbr_quald_bnf_id
    and    cqb.business_group_id = p_business_group_id
    and    crp.per_in_ler_id = pil.per_in_ler_id
    and    crp.business_group_id = cqb.business_group_id
    and    pil.business_group_id = crp.business_group_id
    and    crp.init_evt_flag = 'Y'
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_pgm_id
  is
    select  pen.*
    from   ben_prtt_enrt_rslt_f pen
    where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    p_effective_date
    between pen.effective_start_date and pen.effective_end_date
    and    pen.business_group_id = p_business_group_id;
  --
  cursor c_get_cvrd_emp_person_id
  is
    select cqb.cvrd_emp_person_id
    from ben_cbr_quald_bnf cqb
        ,ben_cbr_per_in_ler crp
        ,ben_per_in_ler pil
    where cqb.quald_bnf_person_id = l_enrld_person_id
    and cqb.cbr_elig_perd_end_dt > l_lf_evt_ocrd_dt
    and crp.cbr_quald_bnf_id = cqb.cbr_quald_bnf_id
    and cqb.business_group_id = p_business_group_id
    and crp.per_in_ler_id = pil.per_in_ler_id
    and crp.business_group_id = cqb.business_group_id
    and pil.business_group_id = crp.business_group_id
    and crp.init_evt_flag = 'Y'
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_poe_lvl_cd
  is
    select  pgm.poe_lvl_cd
    from   ben_pgm_f pgm
    where  pgm.pgm_id = l_pgm_id
    and    p_effective_date
    between pgm.effective_start_date and pgm.effective_end_date
    and    pgm.business_group_id = p_business_group_id;
  --
  l_cqb_rec      c_get_cbr_quald_bnf%rowtype;
  l_pen_rec      c_get_pgm_id%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  hr_utility.set_location('p_prtt_enrt_rslt_id : ' || p_prtt_enrt_rslt_id, 10);
  --
  --  Get program id and enrolled person_id from enrollment result.
  --
  open c_get_pgm_id;
  fetch c_get_pgm_id into l_pen_rec;
  close c_get_pgm_id;
  --
  l_ptip_id := l_pen_rec.ptip_id;
  l_pgm_id := l_pen_rec.pgm_id;
  l_enrld_person_id := l_pen_rec.person_id;
  --
  hr_utility.set_location('pgm_id : ' || l_pen_rec.pgm_id, 10);
  hr_utility.set_location('ptip_id : ' || l_pen_rec.ptip_id, 10);
  --
  if chk_pgm_typ(p_pgm_id            => l_pgm_id
                ,p_effective_date    => p_effective_date
                ,p_business_group_id => p_business_group_id
                ) = false then
    hr_utility.set_location('Leaving - Not found : ' || l_proc, 10);
    return;
  end if;
  --
  --  Get the life event occurred date.
  --
  l_lf_evt_ocrd_dt := get_lf_evt_ocrd_dt
                        (p_per_in_ler_id     => p_per_in_ler_id
                        ,p_business_group_id => p_business_group_id
                        );
  --
  --
  --  Check if person is a qualified beneficiary.
  --
  open c_get_cbr_quald_bnf;
  fetch c_get_cbr_quald_bnf into l_cqb_rec;
  if c_get_cbr_quald_bnf%notfound then
    close c_get_cbr_quald_bnf;
    --
    open c_get_poe_lvl_cd;
    fetch c_get_poe_lvl_cd into l_poe_lvl_cd;
    close c_get_poe_lvl_cd;
    --
    --   Check if event is the initial qualifying event. If it is
    --   not the initial qualifying event, set the quald_bnf_flag = No
    --   Person cannot be a qualified beneficiary unless it is the
    --   initial qualifying event. This is a dependent that is
    --   designated after the initial qualifying event event, during
    --   open enrollment, marriage or a gain of dependent event.
    --
    if (chk_init_evt(p_per_in_ler_id     => p_per_in_ler_id
                    ,p_business_group_id => p_business_group_id)) = false
    then
      l_quald_bnf_flag := 'N';
      l_cbr_elig_perd_strt_dt := null;
      l_cbr_elig_perd_end_dt := null;
      --
      if (l_poe_lvl_cd = 'PGM' or
         l_poe_lvl_cd is null) then
        l_cqb_ptip_id := null;
        l_pl_typ_id   := null;
      elsif l_poe_lvl_cd = 'PTIP' then
        l_cqb_ptip_id := l_ptip_id;
        l_pl_typ_id  := l_pen_rec.pl_typ_id;
      end if;
      --
    else
      hr_utility.set_location('Initial qualifying event', 10);
      l_quald_bnf_flag := 'Y';
      --
      --  Normally, a cobra qualified beneficiary row would exist
      --  if benmngle was run for the related life event. In the event
      --  that the related life event is run after the covered employee
      --  can make elections(per fidelity), we can go ahead a create
      --  a qualified beneficiary here and when benmngle processes
      --  the related life event, it would simply just update the row.
      --
      if (l_poe_lvl_cd = 'PGM' or
         l_poe_lvl_cd is null) then
        --
        determine_cobra_elig_dates
          (p_pgm_id                    => l_pgm_id
          ,p_pl_typ_id                 => l_pen_rec.pl_typ_id
          ,p_person_id                 => p_person_id
          ,p_per_in_ler_id             => p_per_in_ler_id
          ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_validate                  => p_validate
          ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
          ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
          ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
          ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
          ,p_cqb_object_version_number => l_cqb_object_version_number
          ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
          ,p_dsbld_apls                => l_dsbld_apls
          ,p_update                    => l_update
          );
         --
         hr_utility.set_location('l_cbr_elig_perd_strt_dt '||l_cbr_elig_perd_strt_dt, 10);
         hr_utility.set_location('l_cbr_elig_perd_end_dt '||l_cbr_elig_perd_end_dt, 10);
         hr_utility.set_location('l_old_cbr_elig_perd_end_dt '||l_old_cbr_elig_perd_end_dt, 10);
         l_cqb_ptip_id := null;
         l_pl_typ_id   := null;
         --
      elsif l_poe_lvl_cd = 'PTIP' then
        l_cqb_ptip_id := l_ptip_id;
        l_pl_typ_id  := l_pen_rec.pl_typ_id;
        --
        -- Determine cobra eligibility start and end dates.
        --
        determine_cobra_elig_dates
          (p_ptip_id                   => l_ptip_id
          ,p_pl_typ_id                 => l_pl_typ_id
          ,p_person_id                 => p_person_id
          ,p_per_in_ler_id             => p_per_in_ler_id
          ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_validate                  => p_validate
          ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
          ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
          ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
          ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
          ,p_cqb_object_version_number => l_cqb_object_version_number
          ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
          ,p_dsbld_apls                => l_dsbld_apls
          ,p_update                    => l_update
          );
      end if;
    end if;
    --
    --  Get the cvrd employee person id.
    --
    open c_get_cvrd_emp_person_id;
    fetch c_get_cvrd_emp_person_id into l_cvrd_emp_person_id;
    if c_get_cvrd_emp_person_id%notfound then
      --
      close c_get_cvrd_emp_person_id;
      --
      fnd_message.set_name('BEN','BEN_92429_CVRD_EMP_NOT_FOUND');
      --fnd_message.set_token('PROC',l_proc);
      fnd_message.raise_error;
    else
      close c_get_cvrd_emp_person_id;
    end if;
    --
    update_cobra_info
     (p_per_in_ler_id             => p_per_in_ler_id
     ,p_person_id                 => p_person_id
     ,p_cbr_quald_bnf_id          => l_cqb_rec.cbr_quald_bnf_id
     ,p_cqb_object_version_number => l_cqb_rec.object_version_number
     ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
     ,p_old_cbr_elig_perd_end_dt  => l_cqb_rec.cbr_elig_perd_end_dt
     ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
     ,p_dsbld_apls                => l_dsbld_apls
     ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
     ,p_quald_bnf_flag            => l_quald_bnf_flag
     ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
     ,p_business_group_id         => p_business_group_id
     ,p_pgm_id                    => l_pgm_id
     ,p_ptip_id                   => l_cqb_ptip_id
     ,p_pl_typ_id                 => l_pl_typ_id
     ,p_effective_date            => p_effective_date
     ,p_validate                  => p_validate
     );
  else -- quald bnf found.
    --
    hr_utility.set_location('Quald bnf exists', 10);
    --
    close c_get_cbr_quald_bnf;
    --
    if l_cqb_rec.quald_bnf_flag = 'Y' then
      --
      --  Get cobra eligibility dates.  Check if we need to update the
      --  eligibility end dates.
      --
      open c_get_poe_lvl_cd;
      fetch c_get_poe_lvl_cd into l_poe_lvl_cd;
      close c_get_poe_lvl_cd;
      --
      hr_utility.set_location('POE LVL '||l_poe_lvl_cd, 10);
      if (l_poe_lvl_cd = 'PGM' or
        l_poe_lvl_cd is null) then
        --
        determine_cobra_elig_dates
          (p_pgm_id                    => l_pgm_id
          ,p_pl_typ_id                 => l_pen_rec.pl_typ_id
          ,p_person_id                 => p_person_id
          ,p_per_in_ler_id             => p_per_in_ler_id
          ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_validate                  => p_validate
          ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
          ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
          ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
          ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
          ,p_cqb_object_version_number => l_cqb_object_version_number
          ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
          ,p_dsbld_apls                => l_dsbld_apls
          ,p_update                    => l_update
          );
         --
         hr_utility.set_location('elig_strt_dt '||l_cbr_elig_perd_strt_dt, 10);
         hr_utility.set_location('elig_end_dt '||l_cbr_elig_perd_end_dt, 10);
         hr_utility.set_location('old_elig_end_dt '||l_old_cbr_elig_perd_end_dt, 10);
         l_cqb_ptip_id := null;
         l_pl_typ_id   := null;
         --
      elsif l_poe_lvl_cd = 'PTIP' then
        l_cqb_ptip_id := l_ptip_id;
        l_pl_typ_id  := l_pen_rec.pl_typ_id;
        --
        -- Determine cobra eligibility start and end dates.
        --
        determine_cobra_elig_dates
          (p_ptip_id                   => l_ptip_id
          ,p_pl_typ_id                 => l_pl_typ_id
          ,p_person_id                 => p_person_id
          ,p_per_in_ler_id             => p_per_in_ler_id
          ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
          ,p_business_group_id         => p_business_group_id
          ,p_effective_date            => p_effective_date
          ,p_validate                  => p_validate
          ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
          ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
          ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
          ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
          ,p_cqb_object_version_number => l_cqb_object_version_number
          ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
          ,p_dsbld_apls                => l_dsbld_apls
          ,p_update                    => l_update
          );
         hr_utility.set_location('l_cbr_elig_perd_strt_dt '||l_cbr_elig_perd_strt_dt, 10);
         hr_utility.set_location('l_cbr_elig_perd_end_dt '||l_cbr_elig_perd_end_dt, 10);
         hr_utility.set_location('l_old_cbr_elig_perd_end_dt '||l_old_cbr_elig_perd_end_dt, 10);
      end if;
      --
      update_cobra_info
       (p_per_in_ler_id             => p_per_in_ler_id
       ,p_person_id                 => p_person_id
       ,p_cbr_quald_bnf_id          => l_cqb_rec.cbr_quald_bnf_id
       ,p_cqb_object_version_number => l_cqb_object_version_number
       ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
       ,p_old_cbr_elig_perd_end_dt  => l_cqb_rec.cbr_elig_perd_end_dt
       ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
       ,p_dsbld_apls                => l_dsbld_apls
       ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
       ,p_cvrd_emp_person_id        => l_cqb_rec.cvrd_emp_person_id
       ,p_business_group_id         => p_business_group_id
       ,p_effective_date            => p_effective_date
       ,p_validate                  => p_validate
       );
    else -- if qual bnf flag = 'N'
      --
      hr_utility.set_location('quald_bnf_flag N', 10);
      --
      --  If it is the initial event, person is now a qualified beneficiary.
      --
      if (chk_init_evt(p_per_in_ler_id     => p_per_in_ler_id
                    ,p_business_group_id => p_business_group_id))
      then
        --
        open c_get_poe_lvl_cd;
        fetch c_get_poe_lvl_cd into l_poe_lvl_cd;
        close c_get_poe_lvl_cd;
        --
        if (l_poe_lvl_cd = 'PGM' or
           l_poe_lvl_cd is null) then
           --
           determine_cobra_elig_dates
             (p_pgm_id                    => l_pgm_id
             ,p_pl_typ_id                 => l_pen_rec.pl_typ_id
             ,p_person_id                 => p_person_id
             ,p_per_in_ler_id             => p_per_in_ler_id
             ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
             ,p_business_group_id         => p_business_group_id
             ,p_effective_date            => p_effective_date
             ,p_validate                  => p_validate
             ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
             ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
             ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
             ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
             ,p_cqb_object_version_number => l_cqb_object_version_number
             ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
             ,p_dsbld_apls                => l_dsbld_apls
             ,p_update                    => l_update
             );
           l_cqb_ptip_id := null;
           l_pl_typ_id   := null;
           --
        elsif l_poe_lvl_cd = 'PTIP' then
          l_cqb_ptip_id := l_ptip_id;
          l_pl_typ_id  := l_pen_rec.pl_typ_id;
          --
          -- Determine cobra eligibility start and end dates.
          --
          determine_cobra_elig_dates
            (p_ptip_id                   => l_ptip_id
            ,p_pl_typ_id                 => l_pl_typ_id
            ,p_person_id                 => p_person_id
            ,p_per_in_ler_id             => p_per_in_ler_id
            ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
            ,p_business_group_id         => p_business_group_id
            ,p_effective_date            => p_effective_date
            ,p_validate                  => p_validate
            ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
            ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
            ,p_old_cbr_elig_perd_end_dt  => l_old_cbr_elig_perd_end_dt
            ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
            ,p_cqb_object_version_number => l_cqb_object_version_number
            ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
            ,p_dsbld_apls                => l_dsbld_apls
            ,p_update                    => l_update
            );
        end if;
        --
        --  Get the cvrd employee person id.
        --
        open c_get_cvrd_emp_person_id;
        fetch c_get_cvrd_emp_person_id into l_cvrd_emp_person_id;
        if c_get_cvrd_emp_person_id%notfound then
          --
          close c_get_cvrd_emp_person_id;
          --
          fnd_message.set_name('BEN','BEN_92429_CVRD_EMP_NOT_FOUND');
          --fnd_message.set_token('PROC',l_proc);
          fnd_message.raise_error;
        else
          close c_get_cvrd_emp_person_id;
        end if;
        --
        update_cobra_info
         (p_per_in_ler_id             => p_per_in_ler_id
         ,p_person_id                 => p_person_id
         ,p_cbr_quald_bnf_id          => null
         ,p_cqb_object_version_number => null
         ,p_cbr_elig_perd_strt_dt     => l_cbr_elig_perd_strt_dt
         ,p_old_cbr_elig_perd_end_dt  => l_cqb_rec.cbr_elig_perd_end_dt
         ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
         ,p_dsbld_apls                => l_dsbld_apls
         ,p_lf_evt_ocrd_dt            => l_lf_evt_ocrd_dt
         ,p_quald_bnf_flag            => 'Y'
         ,p_cvrd_emp_person_id        => l_cvrd_emp_person_id
         ,p_business_group_id         => p_business_group_id
         ,p_pgm_id                    => l_pgm_id
         ,p_ptip_id                   => l_cqb_ptip_id
         ,p_pl_typ_id                 => l_pl_typ_id
         ,p_effective_date            => p_effective_date
         ,p_validate                  => p_validate
         );
      end if; -- End check initial event.
    end if;
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end update_dpnt_cobra_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cobra_eligibility >-------------------------
-- ----------------------------------------------------------------------------
--
procedure chk_cobra_eligibility
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_pgm_id                    in number
           ,p_lf_evt_ocrd_dt            in date
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_validate                  in boolean default false)   is
  --
  l_effective_date            ben_per_in_ler.lf_evt_ocrd_dt%type;
  l_update                    boolean := false;
  l_cbr_elig_perd_strt_dt     ben_cbr_quald_bnf.cbr_elig_perd_strt_dt%type;
  l_cqb_object_version_number ben_cbr_quald_bnf.object_version_number%type;
  l_crp_object_version_number ben_cbr_quald_bnf.object_version_number%type;
  l_quald_bnf_flag            ben_cbr_quald_bnf.quald_bnf_flag%type;
  l_cbr_quald_bnf_id          ben_cbr_quald_bnf.cbr_quald_bnf_id%type;
  l_quald_bnf_person_id       ben_cbr_quald_bnf.quald_bnf_person_id%type;
  l_cbr_elig_perd_end_dt      ben_cbr_quald_bnf.cbr_elig_perd_end_dt%type;
  l_enrld                     boolean := false;
  l_exists                    varchar2(1);
  l_pgm_id                    ben_pgm_f.pgm_id%type;
  l_proc                      varchar2(80) := g_package||'.chk_cobra_eligibility';
  --
  cursor c_get_cbr_quald_bnf(p_quald_bnf_person_id in number)
  is
    select cqb.*
    from   ben_cbr_quald_bnf cqb
          ,ben_cbr_per_in_ler crp
          ,ben_per_in_ler pil
    where cqb.quald_bnf_person_id = p_quald_bnf_person_id
    and   cqb.quald_bnf_flag = 'Y'
    and   cqb.cbr_elig_perd_end_dt >= p_lf_evt_ocrd_dt
    and   cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
    and   cqb.business_group_id = p_business_group_id
    and   crp.per_in_ler_id = pil.per_in_ler_id
    and   crp.business_group_id = cqb.business_group_id
    and   pil.business_group_id = crp.business_group_id
    and   crp.init_evt_flag = 'Y'
    and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_cvrd_dpnt
  is
    select distinct pdp.dpnt_person_id
    from   ben_elig_cvrd_dpnt_f pdp
    where  pdp.per_in_ler_id = p_per_in_ler_id
    and    p_lf_evt_ocrd_dt
    between pdp.effective_start_date and pdp.effective_end_date
    and     pdp.cvg_thru_dt <> hr_api.g_eot
    and pdp.business_group_id = p_business_group_id;
  --
  cursor c_chk_init_evt is
    select crp.*
    from ben_cbr_per_in_ler crp
    where  crp.per_in_ler_id = p_per_in_ler_id
    and  crp.init_evt_flag = 'Y'
    and crp.business_group_id = p_business_group_id;
  --
  l_cqb_rec      c_get_cbr_quald_bnf%rowtype;
  l_crp_rec      c_chk_init_evt%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  --  Only update COBRA information if person is enrolling
  --  in a COBRA program.
  --
  if chk_pgm_typ(p_pgm_id            => p_pgm_id
                ,p_effective_date    => p_effective_date
                ,p_business_group_id => p_business_group_id
                )  = false then
     hr_utility.set_location('Leaving : ' || l_proc, 15);
     return;
   end if;
  --
  --  If it is the initial event, the Loss of Eligibility temporal
  --  event will set the qualified beneficiary flag to 'N' if the
  --  person waives coverage or does not elect during the enrollment
  --  period so we do not need to do anything here.
  --
  open c_chk_init_evt;
  fetch c_chk_init_evt into l_crp_rec;
  if c_chk_init_evt%notfound then
    close c_chk_init_evt;
    --
    --  Check if person is enrolled or covered in the pgm or plan type.
    --
    for l_cqb_rec in c_get_cbr_quald_bnf(p_person_id) loop
      --
      --  If person is no longer enrolled or covered in the COBRA program
      --  or plan type in program,then set the cobra eligibility end date
      --  to the maximum coverage end date of the enrollment results.
      --
      if (chk_enrld_or_cvrd
           (p_pgm_id            => l_cqb_rec.pgm_id
           ,p_ptip_id           => l_cqb_rec.ptip_id
           ,p_person_id         => p_person_id
           ,p_effective_date    => p_effective_date
           ,p_business_group_id => p_business_group_id))  = false then
        --
        --  The maximum enrollment coverage end date is the
        --  cobra eligibility end date for the person.
        --
        l_cbr_elig_perd_end_dt
          := get_max_cvg_thru_dt
               (p_person_id         => p_person_id
               ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
               ,p_pgm_id            => l_cqb_rec.pgm_id
               ,p_ptip_id           => l_cqb_rec.ptip_id
               ,p_per_in_ler_id     => p_per_in_ler_id
               ,p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               );
        --
        --  Only set the COBRA eligibility end date if the person
        --  was previously covered.
        --
        if l_cbr_elig_perd_end_dt <> hr_api.g_sot then
        --
          update_cobra_info
            (p_per_in_ler_id             => p_per_in_ler_id
            ,p_person_id                 => l_cqb_rec.quald_bnf_person_id
            ,p_cbr_quald_bnf_id          => l_cqb_rec.cbr_quald_bnf_id
            ,p_cqb_object_version_number => l_cqb_rec.object_version_number
            ,p_cbr_elig_perd_strt_dt     => l_cqb_rec.cbr_elig_perd_strt_dt
            ,p_old_cbr_elig_perd_end_dt  => l_cqb_rec.cbr_elig_perd_end_dt
            ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
            ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
            ,p_cvrd_emp_person_id        => l_cqb_rec.cvrd_emp_person_id
            ,p_cbr_inelg_rsn_cd          => 'VEC' -- Voluntary end of coverage.
            ,p_business_group_id         => p_business_group_id
            ,p_effective_date            => p_effective_date
            ,p_validate                  => p_validate
            );
        end if;
      end if; -- end enrld in pgm or ptip.
    end loop;
    --
    --   Also check if covered dependents are still covered.
    --
    --  Get all covered dependent.
    --
    for l_pdp_rec in c_get_cvrd_dpnt  loop
      --
      --  Get the cobra qualified beneficiary row for the dependent
      --
      for l_cqb_rec in c_get_cbr_quald_bnf(l_pdp_rec.dpnt_person_id) loop
        --
        --  If person is no longer enrolled or covered in the COBRA program
        --  or plan type in program,then set the cobra eligibility end date
        --  to the maximum coverage end date of the enrollment results.
        --
        if (chk_enrld_or_cvrd
             (p_pgm_id            => l_cqb_rec.pgm_id
             ,p_ptip_id           => l_cqb_rec.ptip_id
             ,p_person_id         => l_cqb_rec.quald_bnf_person_id
             ,p_effective_date    => p_effective_date
             ,p_business_group_id => p_business_group_id))  = false then
            --
            --  The maximum enrollment coverage end date is the
            --  cobra eligibility end date for the person.
            --
          l_cbr_elig_perd_end_dt
            := get_max_cvg_thru_dt
                 (p_person_id         => l_cqb_rec.quald_bnf_person_id
                 ,p_lf_evt_ocrd_dt    => p_lf_evt_ocrd_dt
                 ,p_pgm_id            => l_cqb_rec.pgm_id
                 ,p_ptip_id           => l_cqb_rec.ptip_id
                 ,p_per_in_ler_id     => p_per_in_ler_id
                 ,p_business_group_id => p_business_group_id
                 ,p_effective_date    => p_effective_date
                 );
          --
          if l_cbr_elig_perd_end_dt <> hr_api.g_sot then
            update_cobra_info
              (p_per_in_ler_id             => p_per_in_ler_id
              ,p_person_id                 => l_cqb_rec.quald_bnf_person_id
              ,p_cbr_quald_bnf_id          => l_cqb_rec.cbr_quald_bnf_id
              ,p_cqb_object_version_number => l_cqb_rec.object_version_number
              ,p_cbr_elig_perd_strt_dt     => l_cqb_rec.cbr_elig_perd_strt_dt
              ,p_old_cbr_elig_perd_end_dt  => l_cqb_rec.cbr_elig_perd_end_dt
              ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
              ,p_lf_evt_ocrd_dt            => p_lf_evt_ocrd_dt
              ,p_cvrd_emp_person_id        => l_cqb_rec.cvrd_emp_person_id
              ,p_business_group_id         => p_business_group_id
              ,p_effective_date            => p_effective_date
              ,p_validate                  => p_validate
              );
          end if;
        end if; -- end enrld in pgm or ptip.
      end loop;
    end loop;
  else
    close c_chk_init_evt;
  end if;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end chk_cobra_eligibility;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cobra_info >-----------------------------
-- ----------------------------------------------------------------------------
--
procedure update_cobra_info
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_cbr_quald_bnf_id          in number default null
           ,p_cqb_object_version_number in number default null
           ,p_cbr_elig_perd_strt_dt     in date default null
           ,p_old_cbr_elig_perd_end_dt  in date default null
           ,p_cbr_elig_perd_end_dt      in date
           ,p_dsbld_apls                in boolean default false
           ,p_lf_evt_ocrd_dt            in date
           ,p_quald_bnf_flag            in varchar2 default 'Y'
           ,p_cvrd_emp_person_id        in number default null
           ,p_cbr_inelg_rsn_cd          in varchar2 default hr_api.g_varchar2
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_pgm_id                    in number default null
           ,p_ptip_id                   in number default null
           ,p_pl_typ_id                 in number default null
           ,p_validate                  in boolean  default false)   is
  --
  l_effective_date            ben_per_in_ler.lf_evt_ocrd_dt%type;
  l_proc                      varchar2(80) := g_package||'.update_cobra_info';
  l_exists                    varchar2(1);
  l_init_evt                  boolean := false;
  l_cvrd_emp_person_id        ben_cbr_quald_bnf.cvrd_emp_person_id%type;
  l_dsbld_apls                boolean;
  l_update                    boolean;
  l_cbr_quald_bnf_id          ben_cbr_quald_bnf.cbr_quald_bnf_id%type;
  l_quald_bnf_flag            ben_cbr_quald_bnf.quald_bnf_flag%type;
  l_cvrd_emp_end_date         date;
  l_cbr_elig_perd_end_dt      date;
  l_cnt_num                   ben_cbr_per_in_ler.cnt_num%type;
  l_cbr_per_in_ler_id         ben_cbr_per_in_ler.cbr_per_in_ler_id%type;
  l_crp_object_version_number ben_cbr_per_in_ler.object_version_number%type;
  l_cqb_object_version_number ben_cbr_per_in_ler.object_version_number%type;
  l_object_version_number     ben_cbr_quald_bnf.object_version_number%type;
  --
  cursor c_chk_cvrd_emp is
    select null
    from  per_person_type_usages_f ptu
         ,per_person_types pet
    where ptu.person_type_id = pet.person_type_id
    and ptu.person_id = p_person_id
    and l_effective_date between
        ptu.effective_start_date and ptu.effective_end_date
    and pet.system_person_type = 'PRTN';
  --
  cursor c_get_cvrd_emp is
    select ctr.person_id
    from  per_contact_relationships ctr
         ,per_person_type_usages_f ptu
         ,per_person_types pet
    where ctr.contact_person_id = p_person_id
    and p_lf_evt_ocrd_dt
    between nvl(ctr.date_start,hr_api.g_sot) and
    nvl(ctr.date_end,hr_api.g_eot)
    and ctr.business_group_id = p_business_group_id
    and ctr.person_id = ptu.person_id
    and ptu.person_type_id = pet.person_type_id
    and l_effective_date between
        ptu.effective_start_date and ptu.effective_end_date
    and pet.system_person_type = 'PRTN';
  --
  cursor c_get_qualg_evt is
    select null
    from ben_ler_f ler
        ,ben_per_in_ler pil
    where ler.ler_id = pil.ler_id
    and   pil.per_in_ler_id = p_per_in_ler_id
    and   p_effective_date between
          ler.effective_start_date and ler.effective_end_date
    and   pil.business_group_id = p_business_group_id
    and   pil.business_group_id = ler.business_group_id
    and   ler.qualg_evt_flag = 'Y';
  --
  cursor c_check_cbr_per_in_ler is
    select crp.*
    from   ben_cbr_per_in_ler crp
    where  (crp.per_in_ler_id = p_per_in_ler_id
            or (crp.per_in_ler_id
                 in (select distinct crp2.per_in_ler_id
                     from ben_cbr_per_in_ler crp2
                         ,ben_cbr_quald_bnf cqb
                         ,ben_per_in_ler pil
                     where cqb.cvrd_emp_person_id = p_cvrd_emp_person_id
                     and cqb.cbr_quald_bnf_id = crp2.cbr_quald_bnf_id
                     and crp2.per_in_ler_id = pil.per_in_ler_id
                     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                     and pil.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
                     and cqb.business_group_id = p_business_group_id
                     and crp2.business_group_id = cqb.business_group_id
                     and pil.business_group_id = crp2.business_group_id)))
    and    crp.business_group_id = p_business_group_id
    and    crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id;
  --
  cursor c_get_cnt_num(p_cbr_quald_bnf_id in number) is
    select max(crp.cnt_num)
    from   ben_cbr_per_in_ler crp
          ,ben_per_in_ler pil
    where  crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
    and    crp.business_group_id = p_business_group_id
    and    crp.per_in_ler_id = pil.per_in_ler_id
    and    crp.business_group_id = pil.business_group_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
 cursor c_get_all_quald_dpnts is
  select cqb.*
  from ben_cbr_quald_bnf cqb
      ,ben_cbr_per_in_ler crp
      ,ben_per_in_ler pil
  where cqb.cvrd_emp_person_id = l_cvrd_emp_person_id
  and   cqb.quald_bnf_person_id <> p_person_id
  and   cqb.quald_bnf_flag = 'Y'
  and   cqb.cbr_elig_perd_end_dt >= p_lf_evt_ocrd_dt
  and   cqb.business_group_id = p_business_group_id
  and   crp.business_group_id = cqb.business_group_id
  and   cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
  and   crp.per_in_ler_id = pil.per_in_ler_id
  and   cqb.pgm_id = nvl(p_pgm_id, cqb.pgm_id)
  and   nvl(cqb.ptip_id,-1) = nvl(p_ptip_id, -1)
  and   crp.business_group_id = pil.business_group_id
  and   crp.init_evt_flag = 'Y'
  and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
 cursor c_get_cvrd_emp_end_date  is
  select cbr_elig_perd_end_dt
  from ben_cbr_quald_bnf cqb
  where cqb.cvrd_emp_person_id = l_cvrd_emp_person_id
  and   cqb.quald_bnf_person_id  = cqb.cvrd_emp_person_id
  and   cqb.cbr_elig_perd_end_dt >= p_lf_evt_ocrd_dt
  and   cqb.business_group_id = p_business_group_id
  and   cqb.pgm_id = nvl(p_pgm_id, cqb.pgm_id)
  and   nvl(cqb.ptip_id,-1) = nvl(p_ptip_id, -1);
  --
  cursor c_get_cvrd_emp_pil(p_cvrd_emp_person_id in number) is
  select crp.*
  from ben_cbr_quald_bnf cqb
      ,ben_cbr_per_in_ler crp
      ,ben_per_in_ler pil
  where cqb.cvrd_emp_person_id = p_cvrd_emp_person_id
  and   cqb.quald_bnf_person_id = cqb.cvrd_emp_person_id
  and   cqb.pgm_id = nvl(p_pgm_id, cqb.pgm_id)
  and   nvl(cqb.ptip_id,-1) = nvl(p_ptip_id, -1)
  and   cqb.cbr_elig_perd_end_dt >= p_lf_evt_ocrd_dt
  and   cqb.cbr_quald_bnf_id = crp.cbr_quald_bnf_id
  and   cqb.business_group_id = p_business_group_id
  and   crp.init_evt_flag = 'Y'
  and   crp.business_group_id = cqb.business_group_id
  and   crp.per_in_ler_id = pil.per_in_ler_id
  and   crp.business_group_id = pil.business_group_id
  and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

  l_crp_rec    c_check_cbr_per_in_ler%rowtype;
  l_crp2_rec   c_get_cvrd_emp_pil%rowtype;
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  l_cbr_elig_perd_end_dt := p_cbr_elig_perd_end_dt;
  --
  if p_cbr_quald_bnf_id is null then
    --
    hr_utility.set_location('New Event : ' || l_proc, 10);
    --
    --  New qualifying event.
    --
    if p_cvrd_emp_person_id is null then
      l_effective_date := p_lf_evt_ocrd_dt -1;
      --
      --  Get covered employee id.
      --
      open c_chk_cvrd_emp;
      fetch c_chk_cvrd_emp into l_exists;
      if c_chk_cvrd_emp%found then
        l_cvrd_emp_person_id := p_person_id;
      else
        --
        -- Person is a dependent. Get covered employee id
        --
        open c_get_cvrd_emp;
        fetch c_get_cvrd_emp into l_cvrd_emp_person_id;
        close c_get_cvrd_emp;
      end if;
        --
      close c_chk_cvrd_emp;
    else
      l_cvrd_emp_person_id := p_cvrd_emp_person_id;
    end if;
    --
    if p_quald_bnf_flag = 'Y' then
      if p_person_id <> l_cvrd_emp_person_id then
        --
        --  If disability extension applies, check if the covered
        --  employee cobra eligibility end date is greater than the
        --  dependent end date.  If it is, set the cobra eligibility
        --  end date to equal the dependent end date.
        --
        open c_get_cvrd_emp_end_date;
        fetch c_get_cvrd_emp_end_date into l_cvrd_emp_end_date;
        close c_get_cvrd_emp_end_date;
        if l_cvrd_emp_end_date > p_cbr_elig_perd_end_dt then
          l_cbr_elig_perd_end_dt := l_cvrd_emp_end_date;
        end if;
      end if;
    end if;
    --
    -- Write cobra qualified beneficiary row.
    --
    hr_utility.set_location('Inserting quald bnf: ' || l_proc, 10);
    hr_utility.set_location('l_cbr_elig_perd_end_dt: ' || l_cbr_elig_perd_end_dt, 10);
    --
    ben_cbr_quald_bnf_api.create_cbr_quald_bnf
      (p_validate               => p_validate
      ,p_cbr_quald_bnf_id       => l_cbr_quald_bnf_id
      ,p_quald_bnf_flag         => p_quald_bnf_flag
      ,p_cbr_elig_perd_strt_dt  => p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt   => l_cbr_elig_perd_end_dt
      ,p_quald_bnf_person_id    => p_person_id
      ,p_cvrd_emp_person_id     => l_cvrd_emp_person_id
      ,p_pgm_id                 => p_pgm_id
      ,p_ptip_id                => p_ptip_id
      ,p_pl_typ_id              => p_pl_typ_id
      ,p_business_group_id      => p_business_group_id
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => p_effective_date
      );
    --
    if p_quald_bnf_flag = 'Y' then
      --
      --  Write COBRA per in ler row.
      --
      ben_cbr_per_in_ler_api.create_cbr_per_in_ler
        (p_validate               => p_validate
        ,p_cbr_per_in_ler_id      => l_cbr_per_in_ler_id
        ,p_init_evt_flag          => 'Y'
        ,p_cnt_num                => 1
        ,p_per_in_ler_id          => p_per_in_ler_id
        ,p_cbr_quald_bnf_id       => l_cbr_quald_bnf_id
        ,p_prvs_elig_perd_end_dt  => null
        ,p_business_group_id      => p_business_group_id
        ,p_object_version_number  => l_object_version_number
        ,p_effective_date         => p_effective_date
        );
      --
      if p_dsbld_apls then
        for l_dpnt_rec in c_get_all_quald_dpnts loop
          if l_cbr_elig_perd_end_dt > l_dpnt_rec.cbr_elig_perd_end_dt
          then
            --
            l_object_version_number := l_dpnt_rec.object_version_number;
            --
            ben_cbr_quald_bnf_api.update_cbr_quald_bnf
              (p_validate              => p_validate
              ,p_cbr_quald_bnf_id      => l_dpnt_rec.cbr_quald_bnf_id
              ,p_cbr_elig_perd_end_dt  => l_cbr_elig_perd_end_dt
              ,p_business_group_id     => p_business_group_id
              ,p_object_version_number => l_object_version_number
              ,p_effective_date        => p_effective_date
            );
          end if;
        end loop;
      end if;
      --
    else -- If person is not a qualified beneficiary.
      --
      hr_utility.set_location('Not a qualified beneficiary: '||l_cvrd_emp_person_id, 10);
      --
      --  Create a COBRA per in ler id using the covered employee initial
      --  life events. This is needed since the form now has to check
      --  if the per_in_ler is backed out before it displays the qualified
      --  beneficiary row.
      --
      open c_get_cvrd_emp_pil(l_cvrd_emp_person_id);
      fetch c_get_cvrd_emp_pil into l_crp2_rec;
      if c_get_cvrd_emp_pil%found then
        close c_get_cvrd_emp_pil;
        --
        ben_cbr_per_in_ler_api.create_cbr_per_in_ler
          (p_validate               => p_validate
          ,p_cbr_per_in_ler_id      => l_cbr_per_in_ler_id
          ,p_init_evt_flag          => 'Y'
          ,p_cnt_num                => 1
          ,p_per_in_ler_id          => l_crp2_rec.per_in_ler_id
          ,p_cbr_quald_bnf_id       => l_cbr_quald_bnf_id
          ,p_prvs_elig_perd_end_dt  => null
          ,p_business_group_id      => p_business_group_id
          ,p_object_version_number  => l_object_version_number
          ,p_effective_date         => p_effective_date
          );
      else
        hr_utility.set_location('Did not find covered employee: '||l_cvrd_emp_person_id, 10);
        hr_utility.set_location('ptip_id : '||p_ptip_id, 10);
        hr_utility.set_location('pgm_id : '||p_pgm_id, 10);
        close c_get_cvrd_emp_pil;
      end if;
      --
    end if;
  else  -- Qualified beneficiary found.
    l_cvrd_emp_person_id := p_cvrd_emp_person_id;
    --
    -- Only update the COBRA qualified beneficiary end date if it has
    -- changed.
    --
    if p_quald_bnf_flag = 'Y' then
      --
      l_init_evt := chk_init_evt(p_per_in_ler_id     => p_per_in_ler_id
                                 ,p_business_group_id => p_business_group_id
                                 );
      if l_init_evt then
        --
        --  The qualified beneficiary row for each dependent is written at
        --  the time of the qualifying event.  If the dependent is designated,
        --   the disability date calculated is not overridden.
        --
        if p_person_id <> l_cvrd_emp_person_id then
          --
          --  If disability extension applies, check if the covered
          --  employee cobra eligibility end date is greater than the
          --  dependent end date.  If it is, set the cobra eligibility
          --  end date to equal the dependent end date.
          --
          open c_get_cvrd_emp_end_date;
          fetch c_get_cvrd_emp_end_date into l_cvrd_emp_end_date;
          close c_get_cvrd_emp_end_date;
          if l_cvrd_emp_end_date > l_cbr_elig_perd_end_dt then
            l_cbr_elig_perd_end_dt := l_cvrd_emp_end_date;
          end if;
        end if;
      end if;
        --
      l_object_version_number := p_cqb_object_version_number;
        --
      if l_cbr_elig_perd_end_dt is not null then
        --
        if p_old_cbr_elig_perd_end_dt <> l_cbr_elig_perd_end_dt then
          --
        hr_utility.set_location('l_cbr_elig_perd_end_dt update: '||l_cbr_elig_perd_end_dt, 10);
          --
          --
          --  If the cobra eligibility start date is the start of time (01/01/0001), set the
          --  qualified beneficiary flag to 'N' instead of updating the eligiblity end date.
          --  Bug 4486609
          --
          if l_cbr_elig_perd_end_dt = hr_api.g_sot then
            l_quald_bnf_flag := 'N';
            l_cbr_elig_perd_end_dt := p_old_cbr_elig_perd_end_dt;
          else
            l_quald_bnf_flag := p_quald_bnf_flag;
          end if;
          --
          ben_cbr_quald_bnf_api.update_cbr_quald_bnf
            (p_validate              => p_validate
            ,p_cbr_quald_bnf_id      => p_cbr_quald_bnf_id
            ,p_quald_bnf_flag        => l_quald_bnf_flag
            ,p_cbr_elig_perd_end_dt  => l_cbr_elig_perd_end_dt
            ,p_cbr_inelg_rsn_cd      => p_cbr_inelg_rsn_cd
            ,p_business_group_id     => p_business_group_id
            ,p_object_version_number => l_object_version_number
            ,p_effective_date        => p_effective_date
          );
        --
          if p_dsbld_apls = true then
            hr_utility.set_location('Disabled: ' || l_cbr_elig_perd_end_dt, 10);
            for l_dpnt_rec in c_get_all_quald_dpnts loop
              if l_cbr_elig_perd_end_dt > l_dpnt_rec.cbr_elig_perd_end_dt
              then
            hr_utility.set_location('Dpnt dsbld : ' || l_cbr_elig_perd_end_dt, 10);
                --
                l_object_version_number := l_dpnt_rec.object_version_number;
                --
                ben_cbr_quald_bnf_api.update_cbr_quald_bnf
                  (p_validate              => p_validate
                  ,p_cbr_quald_bnf_id      => l_dpnt_rec.cbr_quald_bnf_id
                  ,p_cbr_elig_perd_end_dt  => l_cbr_elig_perd_end_dt
                  ,p_business_group_id     => p_business_group_id
                  ,p_object_version_number => l_object_version_number
                  ,p_effective_date        => p_effective_date
                  );
                --
                --  If it is not the initial event, also write a cobra
                --  per_in_ler.
                --
                if l_init_evt = false then
                  --
                  --  Get the last count number from last event.
                  --
                  open c_get_cnt_num(l_dpnt_rec.cbr_quald_bnf_id);
                  fetch c_get_cnt_num into l_cnt_num;
                  close c_get_cnt_num;
                  --
                  hr_utility.set_location('l_cnt_num : ' || l_cnt_num, 10);
                  ben_cbr_per_in_ler_api.create_cbr_per_in_ler
                   (p_validate               => p_validate
                   ,p_cbr_per_in_ler_id      => l_cbr_per_in_ler_id
                   ,p_init_evt_flag          => 'N'
                   ,p_cnt_num                => l_cnt_num + 1
                   ,p_per_in_ler_id          => p_per_in_ler_id
                   ,p_cbr_quald_bnf_id       => l_dpnt_rec.cbr_quald_bnf_id
                   ,p_prvs_elig_perd_end_dt  => l_dpnt_rec.cbr_elig_perd_end_dt
                   ,p_business_group_id      => p_business_group_id
                   ,p_object_version_number  => l_object_version_number
                   ,p_effective_date         => p_effective_date
                   );
                end if;
              end if;
            end loop;
          end if;
        end if;
        --
        --  If person is a qualified beneficiary, check if it is a new
        --  qualifying life event or an event where there is a change in
        --  the cobra eligibility end date.  If it is write a new cobra
        --  per in ler for the person.
        --
        --  Check if the cobra per_in_ler exist for the person.
        --
        open c_check_cbr_per_in_ler;
        fetch c_check_cbr_per_in_ler into l_crp_rec;
        if c_check_cbr_per_in_ler%notfound then
          close c_check_cbr_per_in_ler;
          --
          --  Check if it is a cobra qualifying event.
          --
       --   open c_get_qualg_evt;
       --   fetch c_get_qualg_evt into l_exists;
       --   if (c_get_qualg_evt%found or
            if (p_old_cbr_elig_perd_end_dt <> p_cbr_elig_perd_end_dt) then
       --     close c_get_qualg_evt;
            --
            --  Get the last count number from last event.
            --
            open c_get_cnt_num(p_cbr_quald_bnf_id);
            fetch c_get_cnt_num into l_cnt_num;
            close c_get_cnt_num;
            --
            hr_utility.set_location('l_cnt_num : ' || l_cnt_num, 10);
            ben_cbr_per_in_ler_api.create_cbr_per_in_ler
              (p_validate               => p_validate
              ,p_cbr_per_in_ler_id      => l_cbr_per_in_ler_id
              ,p_init_evt_flag          => 'N'
              ,p_cnt_num                => l_cnt_num + 1
              ,p_per_in_ler_id          => p_per_in_ler_id
              ,p_cbr_quald_bnf_id       => p_cbr_quald_bnf_id
              ,p_prvs_elig_perd_end_dt  => p_old_cbr_elig_perd_end_dt
              ,p_business_group_id      => p_business_group_id
              ,p_object_version_number  => l_object_version_number
              ,p_effective_date         => p_effective_date
              );
      /*    else
            close c_get_qualg_evt; */
          end if;
        else
          close c_check_cbr_per_in_ler;
        end if;
        --
      end if; -- end date is not null
    end if; -- qual_bnf flag = 'Y'
  end if;
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end update_cobra_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< end_prtt_cobra_eligibility >-------------------------
-- ----------------------------------------------------------------------------
--
procedure end_prtt_cobra_eligibility
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_validate                  in boolean  default false)   is
  --
  l_update                    boolean := false;
  l_lf_evt_ocrd_dt            ben_per_in_ler.lf_evt_ocrd_dt%type;
  l_typ_cd                    ben_ler_f.typ_cd%type;
  l_cbr_inelg_rsn_cd          ben_cbr_quald_bnf.cbr_inelg_rsn_cd%type;
  l_effective_date            date;
  l_dpnt_cvg_thru_dt          ben_elig_cvrd_dpnt_f.cvg_thru_dt%type;
  l_cbr_quald_bnf_id          ben_cbr_quald_bnf.cbr_quald_bnf_id%type;
  l_cbr_per_in_ler_id         ben_cbr_per_in_ler.cbr_per_in_ler_id%type;
  l_cqb_object_version_number ben_cbr_quald_bnf.object_version_number%type;
  l_cqb_quald_bnf_flag        ben_cbr_quald_bnf.quald_bnf_flag%type;
  l_crp_object_version_number ben_cbr_quald_bnf.object_version_number%type;
  l_cbr_elig_perd_end_dt      ben_pil_elctbl_chc_popl.cbr_elig_perd_end_dt%type;
  l_exists                    varchar2(1);
  l_proc                      varchar2(80) := g_package||'.end_prtt_cobra_eligibility';
  --
  cursor c_get_cbr_quald_bnf
  is
    select cqb.*
    from   ben_cbr_quald_bnf cqb
          ,ben_cbr_per_in_ler crp
          ,ben_per_in_ler pil
    where  cqb.quald_bnf_person_id = p_person_id
    and    cqb.quald_bnf_flag = 'Y'
    and    cqb.cbr_elig_perd_end_dt >= l_effective_date
    and    crp.cbr_quald_bnf_id = cqb.cbr_quald_bnf_id
    and    cqb.business_group_id = p_business_group_id
    and    crp.init_evt_flag = 'Y'
    and    crp.per_in_ler_id = pil.per_in_ler_id
    and    crp.business_group_id = cqb.business_group_id
    and    pil.business_group_id = crp.business_group_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_cnt_num is
    select max(crp.cnt_num)
    from   ben_cbr_per_in_ler crp
          ,ben_per_in_ler pil
    where  crp.cbr_quald_bnf_id = l_cbr_quald_bnf_id
    and    crp.business_group_id = p_business_group_id
    and    crp.per_in_ler_id = pil.per_in_ler_id
    and    crp.business_group_id = pil.business_group_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_get_ler_type is
    select ler.typ_cd
    from   ben_ler_f ler
          ,ben_per_in_ler pil
    where  ler.ler_id = pil.ler_id
    and    pil.per_in_ler_id = p_per_in_ler_id
    and    ler.business_group_id  = p_business_group_id
    and    ler.business_group_id = pil.business_group_id
    and    p_effective_date
    between ler.effective_start_date and
            ler.effective_end_date;
  --
  cursor c_chk_elctbl_chc(p_pgm_id in number
                         ,p_ptip_id in number
                         ) is
    select null
    from   ben_elig_per_elctbl_chc chc
    where  chc.pgm_id = p_pgm_id
    and    chc.ptip_id = nvl(p_ptip_id, chc.ptip_id)
    and    chc.elctbl_flag = 'Y'
    and    chc.per_in_ler_id = p_per_in_ler_id
    and    chc.business_group_id = p_business_group_id;
  --
  l_cqb_rec      c_get_cbr_quald_bnf%rowtype;
  --
begin
  g_cobra_enrollment_change := FALSE;
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  --  Get life event occurred date.
  --
  l_lf_evt_ocrd_dt := get_lf_evt_ocrd_dt
                        (p_per_in_ler_id     => p_per_in_ler_id
                        ,p_business_group_id => p_business_group_id
                        );
  --
  l_effective_date := (nvl(l_lf_evt_ocrd_dt,p_effective_date)) + 1;
  --
  for l_cqb_rec in c_get_cbr_quald_bnf loop
    l_cbr_quald_bnf_id := l_cqb_rec.cbr_quald_bnf_id;
    l_cqb_object_version_number := l_cqb_rec.object_version_number;
    l_cqb_quald_bnf_flag := l_cqb_rec.quald_bnf_flag;
    hr_utility.set_location('l_effective_date: ' || l_effective_date, 10);
    hr_utility.set_location('cqb_ptip_id: ' || l_cqb_rec.ptip_id, 10);
    hr_utility.set_location('cqb_pgm_id: ' || l_cqb_rec.pgm_id, 10);
    --
    --  If life event occurred date + 1 = to the cobra eligibility
    --  end date, we are processing a loss of eligibility event
    --  or the max period of enrollment is reached so the COBRA
    --  eligibility end date is correct. No need to proceed.
    --
    if l_cqb_rec.cbr_elig_perd_strt_dt = l_effective_date then
      return;
    end if;
    --
    --  If person is not enrolled or covered in the COBRA
    --  program then update his/her cobra eligibility end date.
    --
    if (chk_enrld_or_cvrd
          (p_pgm_id            => l_cqb_rec.pgm_id
          ,p_ptip_id           => l_cqb_rec.ptip_id
          ,p_person_id         => p_person_id
          ,p_effective_date    => p_effective_date
          ,p_business_group_id => p_business_group_id))  = false then
        hr_utility.set_location('Not enrolled: ', 10);
      --
      --  if person is not enroll then check if the person has no electable choices
      --   a COBRA program.
      --
      open c_chk_elctbl_chc(l_cqb_rec.pgm_id
                           ,l_cqb_rec.ptip_id
                           );
      fetch c_chk_elctbl_chc into l_exists;
      if c_chk_elctbl_chc%notfound then
        close c_chk_elctbl_chc;
        --
        hr_utility.set_location('No choices found: ', 10);
        --
        l_cbr_elig_perd_end_dt := get_max_cvg_thru_dt
                                    (p_person_id         => p_person_id
                                    ,p_lf_evt_ocrd_dt    => l_effective_date
                                    ,p_pgm_id            => l_cqb_rec.pgm_id
                                    ,p_ptip_id           => l_cqb_rec.ptip_id
                                    ,p_per_in_ler_id     => p_per_in_ler_id
                                    ,p_effective_date    => p_effective_date
                                    ,p_business_group_id => p_business_group_id
                                    );
        hr_utility.set_location('l_cbr_elig_perd_end_dt : ' || l_cbr_elig_perd_end_dt, 10);

        --
        --  Write a cobra per_in_ler row for the person if the cobra eligibility
        --  period end date is not equal to the cobra eligibility end date
        --  on the qualified beneficiary row.
        --
        if l_cqb_rec.cbr_elig_perd_end_dt <> l_cbr_elig_perd_end_dt then
          if l_cbr_elig_perd_end_dt = hr_api.g_sot then
            l_cqb_quald_bnf_flag := 'N';
            l_cbr_elig_perd_end_dt := l_cqb_rec.cbr_elig_perd_end_dt;
          end if;
          --
          --  If life event is not a cobra temporal event, set the ineligibility
          --  reason to PLE i.e. preceding life event e.g. rehire so a max period
          --  of enrollment event is not triggered.
          --
          open c_get_ler_type;
          fetch c_get_ler_type into l_typ_cd;
          if c_get_ler_type%found then
            if l_typ_cd not in
              ('DRVDLSELG', 'DRVDNLP','DRVDPOEELG',
               'DRVDPOERT','DRVDVEC') then
              l_cbr_inelg_rsn_cd := 'PLE';
            else
              l_cbr_inelg_rsn_cd := hr_api.g_varchar2;
            end if;
            hr_utility.set_location('l_ler_typ: '||l_typ_cd, 10);
          end if;
          close c_get_ler_type;
          --
          end_cobra_eligibility
            (p_per_in_ler_id             => p_per_in_ler_id
            ,p_cbr_quald_bnf_id          => l_cbr_quald_bnf_id
            ,p_cqb_object_version_number => l_cqb_object_version_number
            ,p_quald_bnf_flag            => l_cqb_quald_bnf_flag
            ,p_old_cbr_elig_perd_end_dt  => l_cqb_rec.cbr_elig_perd_end_dt
            ,p_cbr_elig_perd_end_dt      => l_cbr_elig_perd_end_dt
            ,p_cbr_inelg_rsn_cd          => l_cbr_inelg_rsn_cd
            ,p_business_group_id         => p_business_group_id
            ,p_effective_date            => p_effective_date
            );
        end if;
        --
      else
        hr_utility.set_location('Choices found: ', 10);
        close c_chk_elctbl_chc;
      end if;
    end if;
  end loop;
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end end_prtt_cobra_eligibility;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< end_cobra_eligibility >-------------------------
-- ----------------------------------------------------------------------------
--
procedure end_cobra_eligibility
           (p_per_in_ler_id             in number
           ,p_cbr_quald_bnf_id          in number
           ,p_cqb_object_version_number in number
           ,p_quald_bnf_flag            in varchar2 default 'Y'
           ,p_old_cbr_elig_perd_end_dt  in date
           ,p_cbr_elig_perd_end_dt      in date
           ,p_cbr_inelg_rsn_cd          in varchar2 default hr_api.g_varchar2
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_validate                  in boolean  default false)   is
  --
  l_effective_date            ben_per_in_ler.lf_evt_ocrd_dt%type;
  l_cqb_object_version_number ben_cbr_quald_bnf.object_version_number%type;
  l_crp_object_version_number ben_cbr_per_in_ler.object_version_number%type;
  l_cbr_per_in_ler_id         ben_cbr_per_in_ler.cbr_per_in_ler_id%type;
  l_cnt_num                   ben_cbr_per_in_ler.cnt_num%type;
  l_exists                    varchar2(1);
  l_proc                      varchar2(80) := g_package||'.end_cobra_eligibility';
  --
  cursor c_get_cnt_num is
    select max(crp.cnt_num)
    from   ben_cbr_per_in_ler crp
          ,ben_per_in_ler pil
    where  crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
    and    crp.business_group_id = p_business_group_id
    and    crp.per_in_ler_id = pil.per_in_ler_id
    and    crp.business_group_id = pil.business_group_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

  --
  cursor c_chk_cbr_per_in_ler is
    select null
    from   ben_cbr_per_in_ler crp
    where  crp.cbr_quald_bnf_id = p_cbr_quald_bnf_id
    and    crp.per_in_ler_id = p_per_in_ler_id;
  --
begin
  --
  hr_utility.set_location('Entering : ' || l_proc, 10);
  --
  --  If cobra per in ler exists, update the row.
  --
  open c_chk_cbr_per_in_ler;
  fetch c_chk_cbr_per_in_ler into l_exists;
  if c_chk_cbr_per_in_ler%notfound then
    close c_chk_cbr_per_in_ler;
    --
    --
    --  Get the last count number from last event.
    --
    open c_get_cnt_num;
    fetch c_get_cnt_num into l_cnt_num;
    close c_get_cnt_num;
    --
    ben_cbr_per_in_ler_api.create_cbr_per_in_ler
      (p_validate               => p_validate
      ,p_cbr_per_in_ler_id      => l_cbr_per_in_ler_id
      ,p_init_evt_flag          => 'N'
      ,p_cnt_num                => l_cnt_num + 1
      ,p_per_in_ler_id          => p_per_in_ler_id
      ,p_cbr_quald_bnf_id       => p_cbr_quald_bnf_id
      ,p_prvs_elig_perd_end_dt  => p_old_cbr_elig_perd_end_dt
      ,p_business_group_id      => p_business_group_id
      ,p_object_version_number  => l_crp_object_version_number
      ,p_effective_date         => p_effective_date
      );
  else
    close c_chk_cbr_per_in_ler;
  end if;
    --
  l_cqb_object_version_number := p_cqb_object_version_number;
  --
 hr_utility.set_location('p_cbr_elig_perd_end_dt'||p_cbr_elig_perd_end_dt, 20);
 hr_utility.set_location('p_quald_bnf_flag'||p_quald_bnf_flag, 30);
  ben_cbr_quald_bnf_api.update_cbr_quald_bnf
    (p_validate              => p_validate
    ,p_cbr_quald_bnf_id      => p_cbr_quald_bnf_id
    ,p_quald_bnf_flag        => p_quald_bnf_flag
    ,p_cbr_elig_perd_end_dt  => p_cbr_elig_perd_end_dt
    ,p_cbr_inelg_rsn_cd      => p_cbr_inelg_rsn_cd
    ,p_business_group_id     => p_business_group_id
    ,p_object_version_number => l_cqb_object_version_number
    ,p_effective_date        => p_effective_date
    );
  --
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end end_cobra_eligibility;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< do_rounding >-----------------------------------
-- ----------------------------------------------------------------------------
--
function do_rounding(p_rndg_cd        varchar2,
                       p_rndg_rl        number,
                       p_amount         number,
                       p_effective_date date
                       )
return number is
    l_return_amt number;
begin
  if (p_rndg_cd is not null or
      p_rndg_rl is not null) and
      p_amount is not null then
    --
    l_return_amt := benutils.do_rounding
      (p_rounding_cd    => p_rndg_cd,
       p_rounding_rl    => p_rndg_rl,
       p_value          => p_amount,
       p_effective_date => p_effective_date);
    --
  elsif p_amount<>0 and
        p_amount is not null then
    --
    -- for now later do based on currency precision.
    --
    l_return_amt:=round(p_amount,2);
  else
    l_return_amt:=nvl(p_amount,0);
  end if;

  return l_return_amt;

end do_rounding;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< compute_period_rate >---------------------------
-- ----------------------------------------------------------------------------
--
function compute_period_rate(p_rt_strt_dt       date
                            ,p_rt_end_dt        date
                            ,p_ann_rt_val       number
                            ,p_rate_ytd         number
                            ,p_rndg_cd          number
                            ,p_rndg_rl          number
                            ,p_plan_year_end_dt date)
return number is
  l_return_amt           number;
  l_balance              number;
  l_per_month_amt        number;
  l_first_pp_adjustment  number;
  l_months_remaining     number;
  l_notional_months      number;

  l_proc                   varchar2(80) := g_package||'.compute_period_rate';
begin

  hr_utility.set_location('Entering : ' || l_proc, 10);

  l_balance :=  p_ann_rt_val - p_rate_ytd;

  l_notional_months :=  MONTHS_BETWEEN(LAST_DAY(p_plan_year_end_dt),
                                       ADD_MONTHS(LAST_DAY(p_rt_strt_dt),-1));

  l_per_month_amt := l_balance/l_notional_months;

  l_months_remaining := TRUNC(MONTHS_BETWEEN( LEAST(LAST_DAY(p_plan_year_end_dt),p_rt_end_dt),
                              ADD_MONTHS(LAST_DAY(p_rt_strt_dt),-1)));

  l_per_month_amt := do_rounding(p_rndg_cd        => p_rndg_cd,
                                 p_rndg_rl        => p_rndg_rl,
                                 p_amount         => l_per_month_amt,
                                 p_effective_date => p_rt_strt_dt
                                 );

  l_first_pp_adjustment:= l_balance - (l_per_month_amt * l_notional_months);

  l_return_amt := l_first_pp_adjustment + (l_months_remaining * l_per_month_amt);

  hr_utility.set_location('l_return_amt'|| l_return_amt, 10);
  hr_utility.set_location('Leaving : ' || l_proc, 10);

 return l_return_amt;

end compute_period_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_amount_due >--------------------------------
-- ----------------------------------------------------------------------------
--
procedure get_amount_due
            (p_person_id              in number
            ,p_business_group_id      in number
            ,p_assignment_id          in number
            ,p_payroll_id             in number
            ,p_organization_id        in number
            ,p_effective_date         in date
            ,p_prtt_enrt_rslt_id      in number
            ,p_acty_base_rt_id        in number
            ,p_ann_rt_val             in number
            ,p_mlt_cd                 in varchar2
            ,p_rt_strt_dt             in date
            ,p_rt_end_dt              in date
            ,p_first_month_amt        out nocopy number
            ,p_per_month_amt          out nocopy number
            ,p_last_month_amt         out nocopy number
  )
is

  cursor c_current_result_info (c_prtt_enrt_rslt_id  in number) is
      select pen.prtt_enrt_rslt_id,
           pen.pl_id,
           opt.opt_id,
           pen.pgm_id,
           pen.ler_id,
           pen.pl_typ_id,
           pen.person_id,
           pen.effective_start_date,
           pen.effective_end_date
     from  ben_prtt_enrt_rslt_f pen,
           ben_oipl_f opt
     where pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and   opt.oipl_id(+)=pen.oipl_id
     and   pen.prtt_enrt_rslt_stat_cd is null
     and   pen.enrt_cvg_strt_dt between opt.effective_start_date(+)
     and   opt.effective_end_date(+)
     order by pen.effective_start_date desc;

  cursor get_abr_info (c_acty_base_rt_id in number
                        ,c_effective_date  in date) is
      select abr.prtl_mo_det_mthd_cd,
         abr.prtl_mo_det_mthd_rl,
         abr.wsh_rl_dy_mo_num,
         abr.prtl_mo_eff_dt_det_cd,
         abr.prtl_mo_eff_dt_det_rl,
         abr.rndg_cd,
         abr.rndg_rl,
         abr.ele_rqd_flag,
         abr.one_ann_pymt_cd,
         abr.entr_ann_val_flag,
         abr.use_calc_acty_bs_rt_flag,
         abr.acty_typ_cd,
         abr.input_va_calc_rl,
         abr.rt_typ_cd,
         abr.element_type_id,
         abr.input_value_id,
         abr.ele_entry_val_cd,
         abr.rt_mlt_cd,
         abr.parnt_chld_cd,
         abr.rcrrg_cd,
         abr.name
  from  ben_acty_base_rt_f abr
  where abr.acty_base_rt_id=c_acty_base_rt_id
  and   c_effective_date between abr.effective_start_date
  and   abr.effective_end_date;

  -- Parent rate information
  cursor c_abr2
  (c_effective_date in date,
   c_acty_base_rt_id in number
  )
  is
  select abr2.rt_mlt_cd,
         abr2.entr_ann_val_flag
  from   ben_acty_base_rt_f abr,
         ben_acty_base_rt_f abr2
  where  abr.acty_base_rt_id = c_acty_base_rt_id
  and    abr2.acty_base_rt_id = abr.parnt_acty_base_rt_id
  and    abr2.parnt_chld_cd = 'PARNT'
  and    c_effective_date
         between abr.effective_start_date
         and     abr.effective_end_date
  and    c_effective_date
         between abr2.effective_start_date
         and  abr2.effective_end_date;

  cursor c_plan_year_end_for_pen
  (c_prtt_enrt_rslt_id    in     number
  ,c_rate_start_or_end_dt in     date
  ,c_effective_date       in     date
  )
  is
  select distinct
         yp.start_date,yp.end_date
  from   ben_prtt_enrt_rslt_f pen,
         ben_popl_yr_perd pyp,
         ben_yr_perd yp
  where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
  and    c_effective_date <= pen.effective_end_date
  and    pyp.pl_id=pen.pl_id
  and    yp.yr_perd_id=pyp.yr_perd_id
  and    pen.prtt_enrt_rslt_stat_cd is null
  and    c_rate_start_or_end_dt
  between yp.start_date and yp.end_date;
  --

  CURSOR c_rates(c_person_id         in number
                ,c_pgm_id            in number
                ,c_acty_base_rt_id   in number
                ,c_business_group_id in number
                ,c_cur_rt_strt_dt    in date
                ,c_plan_year_strt_dt in date) is
  SELECT prv.rt_strt_dt
        ,prv.rt_end_dt
        ,prv.ann_rt_val
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val prv
      WHERE    pen.person_id = c_person_id
      AND      pen.pgm_id = c_pgm_id
      AND      pen.business_group_id = c_business_group_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      pen.business_group_id = prv.business_group_id
      AND      prv.prtt_rt_val_stat_cd IS NULL
      AND      prv.acty_base_rt_id = c_acty_base_rt_id
      AND      prv.rt_strt_dt < c_cur_rt_strt_dt
      AND      prv.rt_end_dt  >= c_plan_year_strt_dt
  ORDER BY     prv.rt_strt_dt;

  l_mlt_cd                 ben_prtt_rt_val.mlt_cd%type;

  l_per_month_amt          number;
  l_prorated_first_mth_amt number;
  l_prorated_last_mth_amt  number;
  l_result_rec             c_current_result_info%rowtype;
  l_proration_flag         varchar2(30):='N';
  l_jurisdiction_code      varchar2(30);
  l_get_abr_info           get_abr_info%rowtype;

  l_prnt_abr               c_abr2%rowtype ;
  l_months_remaining       number;
  l_total_months           number := 12;
  l_plan_year_end_dt       date;
  l_plan_year_strt_dt      date;
  l_prnt_ann_rt            varchar2(30);
  l_first_pp_adjustment    number;
  l_balance                number;

  l_first_rate             boolean;
  l_rt_strt_dt             date;
  l_rt_end_dt              date;
  l_ann_rt_val             number;
  l_rate_ytd               number;
  l_proc                   varchar2(80) := g_package||'.get_amount_due';
begin

  hr_utility.set_location('Entering : ' || l_proc, 10);

  open c_current_result_info(c_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id);
  fetch c_current_result_info into l_result_rec;
  close c_current_result_info;

  open get_abr_info (c_acty_base_rt_id => p_acty_base_rt_id
                    ,c_effective_date  => p_effective_date);
  fetch get_abr_info into l_get_abr_info;
  close get_abr_info;

  l_mlt_cd := nvl(p_mlt_cd,l_get_abr_info.rt_mlt_cd);

  if l_get_abr_info.parnt_chld_cd = 'CHLD' then
   --
     open c_abr2 (p_effective_date, p_acty_base_rt_id);
     fetch c_abr2 into l_prnt_abr;
     if c_abr2%found then
     --
       if l_prnt_abr.rt_mlt_cd = 'SAREC' or
         l_prnt_abr.entr_ann_val_flag = 'Y' then
         l_prnt_ann_rt := 'Y';
       end if ;
       --
      end if;
      close c_abr2 ;
  end if;

  open c_plan_year_end_for_pen
      (c_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id
      ,c_rate_start_or_end_dt => p_rt_strt_dt
      ,c_effective_date       => p_effective_date
       );
  fetch  c_plan_year_end_for_pen into l_plan_year_strt_dt, l_plan_year_end_dt;
  close c_plan_year_end_for_pen;

  l_months_remaining := MONTHS_BETWEEN(LAST_DAY(l_plan_year_end_dt)
                             ,ADD_MONTHS(LAST_DAY(p_rt_strt_dt),-1));

  hr_utility.set_location('l_months_remaining  '   || l_months_remaining, 10);

  if l_get_abr_info.entr_ann_val_flag='Y' or
     l_prnt_ann_rt = 'Y' or
     l_mlt_cd = 'SAREC' then

     l_first_rate := true;
     l_rate_ytd := 0;
     for r_rates in c_rates(c_person_id         => p_person_id
                           ,c_pgm_id            => l_result_rec.pgm_id
                           ,c_acty_base_rt_id   => p_acty_base_rt_id
                           ,c_business_group_id => p_business_group_id
                           ,c_cur_rt_strt_dt    => p_rt_strt_dt
                           ,c_plan_year_strt_dt => l_plan_year_strt_dt)
     loop
       if l_first_rate = true then
         l_rt_strt_dt := GREATEST(r_rates.rt_strt_dt,l_plan_year_strt_dt);
         l_rt_end_dt := r_rates.rt_end_dt;
         l_ann_rt_val := r_rates.ann_rt_val;

         l_first_rate := false;
       end if;

       if l_ann_rt_val <> r_rates.ann_rt_val then -- Change in Amount

         l_rate_ytd := l_rate_ytd + compute_period_rate(
                                       p_rt_strt_dt => l_rt_strt_dt
                                      ,p_rt_end_dt  => l_rt_end_dt
                                      ,p_ann_rt_val => l_ann_rt_val
                                      ,p_rate_ytd   => l_rate_ytd
                                      ,p_rndg_cd    => l_get_abr_info.rndg_cd
                                      ,p_rndg_rl    => l_get_abr_info.rndg_rl
                                      ,p_plan_year_end_dt => l_plan_year_end_dt);

         hr_utility.set_location('l_rate_ytd '|| l_rate_ytd, 10);

         l_rt_strt_dt := r_rates.rt_strt_dt;
         l_rt_end_dt  := r_rates.rt_end_dt;
         l_ann_rt_val := r_rates.ann_rt_val;

       else
         l_rt_end_dt := r_rates.rt_end_dt;
       end if;
     end loop;

     if  l_ann_rt_val is not null then
       l_rate_ytd := l_rate_ytd + compute_period_rate(
                                      p_rt_strt_dt => l_rt_strt_dt
                                     ,p_rt_end_dt  => l_rt_end_dt
                                     ,p_ann_rt_val => l_ann_rt_val
                                     ,p_rate_ytd   => l_rate_ytd
                                     ,p_rndg_cd    => l_get_abr_info.rndg_cd
                                     ,p_rndg_rl    => l_get_abr_info.rndg_rl
                                     ,p_plan_year_end_dt => l_plan_year_end_dt);

       hr_utility.set_location('l_rate_ytd '|| l_rate_ytd, 20);
     end if;

     l_balance := p_ann_rt_val - l_rate_ytd;

     if l_months_remaining > 0 then
        l_per_month_amt := l_balance/l_months_remaining;
     else
        l_per_month_amt := 0;
     end if;

     -- Round the per month amount
     l_per_month_amt := do_rounding(p_rndg_cd        => l_get_abr_info.rndg_cd,
                                    p_rndg_rl        => l_get_abr_info.rndg_rl,
                                    p_amount         => l_per_month_amt,
                                    p_effective_date => p_effective_date
                                    );

     l_first_pp_adjustment:= l_balance - (l_per_month_amt * l_months_remaining);
     --
     -- Proration is currently ignored for SAREC and Enter_Ann_Val_Flay = 'Y' cases
     --
     if ((l_ann_rt_val is null) OR (p_ann_rt_val <> l_ann_rt_val)) then
       -- Do adjustment for rounding only if Rate has changed
       l_prorated_first_mth_amt := l_per_month_amt + l_first_pp_adjustment;
     else
       l_prorated_first_mth_amt := l_per_month_amt;
     end if;

     -- If Rate has ended in the middle of a month, then exclude that month
     if p_rt_end_dt = LAST_DAY(p_rt_end_dt) then
       l_prorated_last_mth_amt := l_per_month_amt;
     else
       l_prorated_last_mth_amt := 0;
     end if;

  else   -- Not SAREC or Enter_Ann_Val_Flay = 'Y'

     l_per_month_amt := p_ann_rt_val/l_total_months;

     l_prorated_first_mth_amt := ben_element_entry.prorate_amount
                              (p_amt                  => l_per_month_amt
                              ,p_acty_base_rt_id      => p_acty_base_rt_id
                              ,p_actl_prem_id         => NULL
                              ,p_cvg_amt_calc_mthd_id => NULL
                              ,p_person_id            => p_person_id
                              ,p_rndg_cd              => l_get_abr_info.rndg_cd
                              ,p_rndg_rl              => l_get_abr_info.rndg_rl
                              ,p_pgm_id               => l_result_rec.pgm_id
                              ,p_pl_typ_id            => l_result_rec.pl_typ_id
                              ,p_pl_id                => l_result_rec.pl_id
                              ,p_opt_id               => l_result_rec.opt_id
                              ,p_ler_id               => l_result_rec.ler_id
                              ,p_prorate_flag         => l_proration_flag
                              ,p_effective_date       => p_rt_strt_dt
                              ,p_start_or_stop_cd     => 'STRT'
                              ,p_start_or_stop_date   => p_rt_strt_dt
                              ,p_business_group_id    => p_business_group_id
                              ,p_assignment_id        => p_assignment_id
                              ,p_organization_id      => p_organization_id
                              ,p_jurisdiction_code    => l_jurisdiction_code
                              ,p_wsh_rl_dy_mo_num     => l_get_abr_info.wsh_rl_dy_mo_num
                              ,p_prtl_mo_det_mthd_cd  => l_get_abr_info.prtl_mo_det_mthd_cd
                              ,p_prtl_mo_det_mthd_rl  => l_get_abr_info.prtl_mo_det_mthd_rl);

     l_prorated_last_mth_amt := ben_element_entry.prorate_amount
                              (p_amt                  => l_per_month_amt
                              ,p_acty_base_rt_id      => p_acty_base_rt_id
                              ,p_actl_prem_id         => NULL
                              ,p_cvg_amt_calc_mthd_id => NULL
                              ,p_person_id            => p_person_id
                              ,p_rndg_cd              => l_get_abr_info.rndg_cd
                              ,p_rndg_rl              => l_get_abr_info.rndg_rl
                              ,p_pgm_id               => l_result_rec.pgm_id
                              ,p_pl_typ_id            => l_result_rec.pl_typ_id
                              ,p_pl_id                => l_result_rec.pl_id
                              ,p_opt_id               => l_result_rec.opt_id
                              ,p_ler_id               => l_result_rec.ler_id
                              ,p_prorate_flag         => l_proration_flag
                              ,p_effective_date       => p_rt_end_dt
                              ,p_start_or_stop_cd     => 'STP'
                              ,p_start_or_stop_date   => p_rt_end_dt
                              ,p_business_group_id    => p_business_group_id
                              ,p_assignment_id        => p_assignment_id
                              ,p_organization_id      => p_organization_id
                              ,p_jurisdiction_code    => l_jurisdiction_code
                              ,p_wsh_rl_dy_mo_num     => l_get_abr_info.wsh_rl_dy_mo_num
                              ,p_prtl_mo_det_mthd_cd  => l_get_abr_info.prtl_mo_det_mthd_cd
                              ,p_prtl_mo_det_mthd_rl  => l_get_abr_info.prtl_mo_det_mthd_rl);


     l_per_month_amt := do_rounding(p_rndg_cd        => l_get_abr_info.rndg_cd,
                                    p_rndg_rl        => l_get_abr_info.rndg_rl,
                                    p_amount         => l_per_month_amt,
                                    p_effective_date => p_effective_date
                                    );

     l_prorated_first_mth_amt := do_rounding(p_rndg_cd        => l_get_abr_info.rndg_cd,
                                             p_rndg_rl        => l_get_abr_info.rndg_rl,
                                             p_amount         => l_prorated_first_mth_amt,
                                             p_effective_date => p_effective_date
                                             );

     l_prorated_last_mth_amt := do_rounding(p_rndg_cd    => l_get_abr_info.rndg_cd,
                                        p_rndg_rl        => l_get_abr_info.rndg_rl,
                                        p_amount         => l_prorated_last_mth_amt,
                                        p_effective_date => p_effective_date
                                        );

     l_first_pp_adjustment := (((p_ann_rt_val * l_months_remaining)/l_total_months) -
                                (l_months_remaining * l_per_month_amt));


     l_first_pp_adjustment := do_rounding(p_rndg_cd        => l_get_abr_info.rndg_cd,
                                          p_rndg_rl        => l_get_abr_info.rndg_rl,
                                          p_amount         => l_first_pp_adjustment,
                                          p_effective_date => p_effective_date
                                          );

     l_prorated_first_mth_amt := l_prorated_first_mth_amt +  l_first_pp_adjustment;

   end if;

   -- Set out variables
   p_per_month_amt := l_per_month_amt;
   p_first_month_amt := l_prorated_first_mth_amt;
   p_last_month_amt := l_prorated_last_mth_amt;

   hr_utility.set_location('p_per_month_amt  '   || p_per_month_amt, 10);
   hr_utility.set_location('p_first_month_amt  ' || p_first_month_amt, 10);
   hr_utility.set_location('p_last_month_amt  '  || p_last_month_amt, 10);

   hr_utility.set_location('Leaving : ' || l_proc, 10);

end get_amount_due;
--
procedure get_due_and_payment_amt(p_person_id         in number
                                 ,p_effective_date    in date
                                 ,p_acty_base_rt_id   in number
                                 ,p_business_group_id in number
                                 ,p_prtt_enrt_rslt_id in number
                                 ,p_rt_strt_dt        in date
                                 ,p_rt_end_dt         in date
                                 ,p_ann_rt_val        in number
                                 ,p_mlt_cd            in varchar2
                                 ,p_amt_due           out nocopy number
                                 ,p_prev_pymts        out nocopy number)
is

  cursor c_prev_pymts
                       (c_assignment_id     number
                       ,c_acty_base_rt_id   number
                       ,c_business_group_id number
                       ,c_effective_date    date
                       ,c_strt_dt           date
                       ,c_end_dt            date) is
      SELECT   NVL(sum(a.result_value),0) result_value
      FROM     pay_run_result_values a
              ,pay_element_types_f b
              ,pay_assignment_actions d
              ,pay_payroll_actions e
              ,pay_run_results h
              ,ben_acty_base_rt_f i
              ,pay_input_values_f j
      WHERE    d.assignment_id        = c_assignment_id
      AND      d.payroll_action_id    = e.payroll_action_id
      AND      i.input_value_id       = j.input_value_id
      AND      i.element_type_id      = b.element_type_id
      AND      i.acty_base_rt_id      = c_acty_base_rt_id
      AND      c_effective_date BETWEEN i.effective_start_date
               AND i.effective_end_date
      AND      i.business_group_id    = c_business_group_id
      AND      b.element_type_id      = h.element_type_id
      AND      d.assignment_action_id = h.assignment_action_id
      AND      e.date_earned BETWEEN c_strt_dt AND c_end_dt
      AND      a.input_value_id       = j.input_value_id
      AND      a.run_result_id        = h.run_result_id
      AND      j.element_type_id      = b.element_type_id
      AND      c_effective_date BETWEEN b.effective_start_date
                   AND b.effective_end_date
      AND      c_effective_date BETWEEN j.effective_start_date
                   AND j.effective_end_date;

  l_organization_id number;
  l_payroll_id      number;
  l_assignment_id   number;

  l_first_month_amt number;
  l_per_month_amt   number;
  l_last_month_amt  number;

  l_amt_due          number;
  l_prev_mth_end_dt  date;
  l_first_mth_end_dt date;
  l_months_between   number;

  l_prev_pymts       number;
  l_proc             varchar2(80) := g_package||'.get_due_and_payment_amt';

begin

    hr_utility.set_location('Entering : ' || l_proc, 10);

    ben_element_entry.get_abr_assignment
           (p_person_id       => p_person_id
           ,p_effective_date  => p_effective_date
           ,p_acty_base_rt_id => p_acty_base_rt_id
           ,p_organization_id => l_organization_id
           ,p_payroll_id      => l_payroll_id
           ,p_assignment_id   => l_assignment_id);

    get_amount_due
            (p_person_id         => p_person_id
            ,p_business_group_id => p_business_group_id
            ,p_assignment_id     => l_assignment_id
            ,p_payroll_id        => l_payroll_id
            ,p_organization_id   => l_organization_id
            ,p_effective_date    => p_effective_date
            ,p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
            ,p_acty_base_rt_id   => p_acty_base_rt_id
            ,p_ann_rt_val        => p_ann_rt_val
            ,p_mlt_cd            => p_mlt_cd
            ,p_rt_strt_dt        => p_rt_strt_dt
            ,p_rt_end_dt         => p_rt_end_dt
            ,p_first_month_amt   => l_first_month_amt
            ,p_per_month_amt     => l_per_month_amt
            ,p_last_month_amt    => l_last_month_amt);


    open c_prev_pymts(c_assignment_id     => l_assignment_id
                     ,c_acty_base_rt_id   => p_acty_base_rt_id
                     ,c_business_group_id => p_business_group_id
                     ,c_effective_date    => p_effective_date
                     ,c_strt_dt           => p_rt_strt_dt
                     ,c_end_dt            => p_rt_end_dt);

    fetch c_prev_pymts into l_prev_pymts;
    if c_prev_pymts%notfound then
      l_prev_pymts := 0;
    end if;
    close c_prev_pymts;

    l_amt_due := l_first_month_amt + l_last_month_amt;

    l_first_mth_end_dt :=  LAST_DAY(p_rt_strt_dt);

    l_prev_mth_end_dt := LAST_DAY(ADD_MONTHS(p_rt_end_dt,-1));
    l_months_between := MONTHS_BETWEEN(l_prev_mth_end_dt,l_first_mth_end_dt);

    l_amt_due := l_amt_due + (l_months_between * l_per_month_amt);

    -- Set Out variables
    p_amt_due := l_amt_due;
    p_prev_pymts := l_prev_pymts;

    hr_utility.set_location('Leaving : ' || l_proc, 10);

end get_due_and_payment_amt;
--
function get_comp_object_name(p_pl_id          in number
                             ,p_oipl_id        in number
                             ,p_effective_date in date)
return varchar2
is

  cursor c_pln_name(c_pl_id          in number
                   ,c_effective_date in date  )
  is
  select pln.name
  from ben_pl_f pln
  where pln.pl_id = c_pl_id
  and   c_effective_date between pln.effective_start_date
  and   pln.effective_end_date;

  cursor c_opt_name(c_oipl_id        in number
                   ,c_effective_date in date  )
  is
  select opt.name
  from  ben_oipl_f cop,
        ben_opt_f opt
  where cop.oipl_id = c_oipl_id
  and   cop.opt_id = opt.opt_id
  and   c_effective_date between cop.effective_start_date
  and   cop.effective_end_date
  and   c_effective_date between opt.effective_start_date
  and   opt.effective_end_date;

  l_pln_name ben_pl_f.name%type;
  l_opt_name ben_opt_f.name%type;
  l_comp_object_name varchar2(500);

begin
  open c_pln_name(p_pl_id,p_effective_date);
  fetch c_pln_name into l_pln_name;
  close c_pln_name;

  if p_oipl_id is not null then
    open c_opt_name(p_oipl_id,p_effective_date);
    fetch c_opt_name into l_opt_name;
    close c_opt_name;
  end if;

  l_comp_object_name := l_pln_name;
  if l_opt_name is not null then
    l_comp_object_name := l_comp_object_name ||' - '||l_opt_name;
  end if;

  return l_comp_object_name;

end get_comp_object_name;
--
procedure get_unpaid_rate(p_person_id            in number
                         ,p_pgm_id               in number
                         ,p_pl_typ_id            in number
                         ,p_business_group_id    in number
                         ,p_effective_date       in date
                         ,p_element_type_id      in number
                         ,p_input_value_id       in number
                         ,p_mode                 in varchar2
                         ,p_prev_rt_strt_dt      in date
                         ,p_rt_strt_dt           out nocopy date
                         ,p_elm_chg_warning      out nocopy varchar2)

is

  CURSOR c_rates(c_person_id   in number
                ,c_pgm_id      in number
                ,c_pl_typ_id   in number
                ,c_business_group_id in number
                ,c_effective_date in date
                ,c_element_type_id in number
                ,c_input_value_id  in number) is
  SELECT pen.pl_id
        ,prv.element_entry_value_id
        ,prv.acty_base_rt_id
        ,prv.rt_strt_dt
        ,prv.rt_end_dt
        ,prv.ann_rt_val
        ,pen.prtt_enrt_rslt_id
        ,prv.mlt_cd
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val prv
              ,ben_acty_base_rt_f abr
      WHERE    pen.person_id = c_person_id
      AND      pen.pgm_id = c_pgm_id
      AND      pen.pl_typ_id = c_pl_typ_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.business_group_id = c_business_group_id
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      prv.business_group_id = pen.business_group_id
      AND      prv.prtt_rt_val_stat_cd IS NULL
      AND      prv.acty_typ_cd LIKE 'PBC%'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      c_effective_date BETWEEN prv.rt_strt_dt and
               prv.rt_end_dt
      AND      prv.acty_base_rt_id = abr.acty_base_rt_id
      AND      abr.element_type_id +0 = c_element_type_id -- PERF FIX. Added +0
      AND      abr.input_value_id  +0= c_input_value_id -- PERF FIX. Added +0
      AND      c_effective_date BETWEEN abr.effective_start_date
               and abr.effective_end_date;


     CURSOR c_rates_other(c_person_id   in number
                         ,c_pgm_id      in number
                         ,c_pl_typ_id   in number
                         ,c_business_group_id in number
                         ,c_effective_date in date
                         ,c_element_type_id in number
                         ,c_input_value_id  in number) is
      SELECT pen.pl_id
            ,pen.oipl_id
            ,prv.element_entry_value_id
            ,prv.acty_base_rt_id
            ,prv.rt_strt_dt
            ,prv.rt_end_dt
            ,prv.ann_rt_val
            ,pen.prtt_enrt_rslt_id
            ,prv.mlt_cd
            ,abr.name
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val prv
              ,ben_acty_base_rt_f abr
      WHERE    pen.person_id = c_person_id
      AND      pen.pgm_id = c_pgm_id
      AND      pen.pl_typ_id = c_pl_typ_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.business_group_id = c_business_group_id
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      prv.business_group_id = pen.business_group_id
      AND      prv.prtt_rt_val_stat_cd IS NULL
      AND      prv.acty_typ_cd LIKE 'PBC%'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      c_effective_date BETWEEN prv.rt_strt_dt and
               prv.rt_end_dt
      AND      prv.acty_base_rt_id = abr.acty_base_rt_id
      AND      ((abr.element_type_id <> c_element_type_id) OR (abr.input_value_id <> c_input_value_id))
      AND      c_effective_date BETWEEN abr.effective_start_date
               and abr.effective_end_date
      ORDER    by pen.pl_id,pen.oipl_id;

     l_rates c_rates%rowtype;

     l_amt_due          number;
     l_rt_strt_dt       date;
     l_prev_pymts       number;
     l_warning          varchar2(2000);
     l_comp_object_name varchar2(500);
     l_pl_id            number;
     l_oipl_id          number;
     l_proc             varchar2(80) := g_package||'.get_unpaid_rate';

begin

  hr_utility.set_location('Entering : ' || l_proc, 10);

  open c_rates(c_person_id         => p_person_id
              ,c_pgm_id            => p_pgm_id
              ,c_pl_typ_id         => p_pl_typ_id
              ,c_business_group_id => p_business_group_id
              ,c_effective_date    => p_effective_date
              ,c_element_type_id   => p_element_type_id
              ,c_input_value_id    => p_input_value_id);
  fetch c_rates into l_rates;
  if c_rates%notfound then
    close c_rates;

    l_pl_id := null;
    l_oipl_id := null;
    for r_rates_other in c_rates_other
                          (c_person_id         => p_person_id
                          ,c_pgm_id            => p_pgm_id
                          ,c_pl_typ_id         => p_pl_typ_id
                          ,c_business_group_id => p_business_group_id
                          ,c_effective_date    => p_effective_date
                          ,c_element_type_id   => p_element_type_id
                          ,c_input_value_id    => p_input_value_id)
    loop

      get_due_and_payment_amt(p_person_id              => p_person_id
                             ,p_effective_date         => p_effective_date
                             ,p_acty_base_rt_id        => r_rates_other.acty_base_rt_id
                             ,p_business_group_id      => p_business_group_id
                             ,p_prtt_enrt_rslt_id      => r_rates_other.prtt_enrt_rslt_id
                             ,p_rt_strt_dt             => r_rates_other.rt_strt_dt
                             ,p_rt_end_dt              => r_rates_other.rt_end_dt
                             ,p_ann_rt_val             => r_rates_other.ann_rt_val
                             ,p_mlt_cd                 => r_rates_other.mlt_cd
                             ,p_amt_due                => l_amt_due
                             ,p_prev_pymts             => l_prev_pymts);


      if l_prev_pymts < l_amt_due then

        if l_pl_id is null or
           ((l_pl_id <> r_rates_other.pl_id) or
            (NVL(l_oipl_id,hr_api.g_number) <> NVL(r_rates_other.oipl_id,hr_api.g_number))
           ) then


          l_pl_id := r_rates_other.pl_id;
          l_oipl_id := r_rates_other.oipl_id;

          l_comp_object_name := get_comp_object_name
                              (p_pl_id       => r_rates_other.pl_id
                              ,p_oipl_id     => r_rates_other.oipl_id
                              ,p_effective_date => r_rates_other.rt_strt_dt);

          if l_warning is null then
            l_warning := l_warning || l_comp_object_name;
          else
            l_warning := l_warning || ', ' || l_comp_object_name;
          end if;
        end if;

      end if;
    end loop;

    if p_mode = 'PAST' then
      l_rt_strt_dt := p_prev_rt_strt_dt;
    elsif p_mode = 'FUTURE' then
      l_rt_strt_dt := NULL;
    end if;

  else
    close c_rates;

    get_due_and_payment_amt
      (p_person_id              => p_person_id
      ,p_effective_date         => p_effective_date
      ,p_acty_base_rt_id        => l_rates.acty_base_rt_id
      ,p_business_group_id      => p_business_group_id
      ,p_prtt_enrt_rslt_id      => l_rates.prtt_enrt_rslt_id
      ,p_rt_strt_dt             => l_rates.rt_strt_dt
      ,p_rt_end_dt              => l_rates.rt_end_dt
      ,p_ann_rt_val             => l_rates.ann_rt_val
      ,p_mlt_cd                 => l_rates.mlt_cd
      ,p_amt_due                => l_amt_due
      ,p_prev_pymts             => l_prev_pymts);

    if l_prev_pymts = 0 then -- No payments

      if p_mode = 'PAST' then

          get_unpaid_rate
            (p_person_id          => p_person_id
            ,p_pgm_id             => p_pgm_id
            ,p_pl_typ_id          => p_pl_typ_id
            ,p_business_group_id  => p_business_group_id
            ,p_effective_date     => (l_rates.rt_strt_dt - 1)
            ,p_element_type_id    => p_element_type_id
            ,p_input_value_id     => p_input_value_id
            ,p_mode               => p_mode
            ,p_prev_rt_strt_dt    => l_rates.rt_strt_dt
            ,p_rt_strt_dt         => l_rt_strt_dt
            ,p_elm_chg_warning    => l_warning);

      elsif p_mode = 'FUTURE' then
        l_rt_strt_dt := l_rates.rt_strt_dt;
      end if;

    elsif l_prev_pymts < l_amt_due then  -- Incomplete payments
      l_rt_strt_dt := l_rates.rt_strt_dt;

    else -- Full payment

      if p_mode = 'PAST' then
        l_rt_strt_dt := p_prev_rt_strt_dt;

      elsif p_mode = 'FUTURE' then
        get_unpaid_rate
          (p_person_id          => p_person_id
          ,p_pgm_id             => p_pgm_id
          ,p_pl_typ_id          => p_pl_typ_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => (l_rates.rt_end_dt + 1)
          ,p_element_type_id    => p_element_type_id
          ,p_input_value_id     => p_input_value_id
          ,p_mode               => p_mode
          ,p_prev_rt_strt_dt    => l_rates.rt_strt_dt
          ,p_rt_strt_dt         => l_rt_strt_dt
          ,p_elm_chg_warning    => l_warning);
      end if;

    end if;

  end if;

  -- Set Out variables
  p_rt_strt_dt := l_rt_strt_dt;
  p_elm_chg_warning := l_warning;

  hr_utility.set_location('p_rt_strt_dt ' ||p_rt_strt_dt, 10);
  hr_utility.set_location('Leaving : ' || l_proc, 10);
end get_unpaid_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_costing_details >---------------------------
-- ----------------------------------------------------------------------------
--
procedure get_costing_details(p_person_id         in number
                             ,p_business_group_id in number
                             ,p_assignment_id     in number
                             ,p_organization_id   in number
                             ,p_payroll_id        in number
                             ,p_rt_strt_dt        in date
                             ,p_acty_base_rt_id   in number
                             ,p_cos_set_id        out nocopy number
                             ,p_cost_alloc_kf_id  out nocopy number
                             ,p_costable_type     out nocopy varchar2
                             ,p_el_link           out nocopy number
                             ,p_input_value_id    out nocopy number
                             ,p_bal_adj_cost_flag out nocopy varchar2) is

  cursor get_payroll(c_payroll_id in number
                    ,c_effective_date in date
                   ) is
  select pr.consolidation_set_id
  from   pay_all_payrolls_f pr
  where  pr.payroll_id = c_payroll_id
  and    c_effective_date between pr.effective_start_date
         and pr.effective_end_date;

  --  Balance_adj_cost_flag is now set based on the
  --  element's costable_type
  /*
  cursor input_val(c_acty_base_rt_id   in number
                    ,c_business_group_id in number
                    ,c_effective_date    in date
                    )  is
  select entries.balance_adj_cost_flag
  from   ben_acty_base_rt_f abr,
         pay_element_entry_values_f ee_values,
         pay_element_entries_f entries
  where  abr.acty_base_rt_id = c_acty_base_rt_id
  and    c_effective_date between abr.effective_start_date
  and abr.effective_end_date
  and    abr.business_group_id = c_business_group_id
  and    abr.input_value_id = ee_values.input_value_id
  and    c_effective_date between ee_values.effective_start_date
  and ee_values.effective_end_date
  and    ee_values.element_entry_id = entries.element_entry_id
  and    c_effective_date between entries.effective_start_date
  and entries.effective_end_date;
  */

  cursor get_el_link(c_acty_base_rt_id   in number
                    ,c_business_group_id in number
                    ,c_effective_date    in date
                    )  is
  select elk.costable_type,
         link_inp_val.element_link_id,
         abr.input_value_id
  from   ben_acty_base_rt_f abr,
         pay_input_values_f inp_val,
         pay_element_links_f elk,
         pay_link_input_values_f link_inp_val
  where  acty_base_rt_id = c_acty_base_rt_id
  and    abr.input_value_id = inp_val.input_value_id
  and    c_effective_date between abr.effective_start_date
  and abr.effective_end_date
  and    abr.business_group_id = c_business_group_id
  and    c_effective_date between inp_val.effective_start_date
  and inp_val.effective_end_date
  and    inp_val.business_group_id = c_business_group_id
  and    link_inp_val.input_value_id = inp_val.input_value_id
  and    elk.element_link_id = link_inp_val.element_link_id
  and    c_effective_date between elk.effective_start_date
  and elk.effective_end_date
  and    c_effective_date between link_inp_val.effective_start_date
  and link_inp_val.effective_end_date;

  l_cos_set_id            number;
  l_cost_alloc_kf_id      number;
  l_el_link               number;
  l_input_value_id        number;
  l_bal_adj_cost_flag     varchar2(30);
  l_costable_type         pay_element_links_f.costable_type%TYPE;

begin

  open get_payroll(c_payroll_id     => p_payroll_id
                  ,c_effective_date => p_rt_strt_dt);
  fetch get_payroll into l_cos_set_id;
  close get_payroll;

  open get_el_link(c_acty_base_rt_id   => p_acty_base_rt_id
                  ,c_business_group_id => p_business_group_id
                  ,c_effective_date    => p_rt_strt_dt);
  fetch get_el_link into l_costable_type,l_el_link, l_input_value_id;
  close get_el_link;

  --
  -- Pass cost_allocation_keyflex_id as NULL to pay_balance_adjustment_api
  -- This will ensure that costed values are assigned to the
  -- appropriate levels using the Costing Hierarchy
  --
  l_cost_alloc_kf_id := NULL;

  -- Set bal_adj_cost_flag based on the element's costable_type
  if l_costable_type = 'N' then
    l_bal_adj_cost_flag := 'N';
  else
    l_bal_adj_cost_flag := 'Y';
  end if;

 -- Set out variables

 p_cos_set_id        := l_cos_set_id;
 p_cost_alloc_kf_id  := l_cost_alloc_kf_id;
 p_costable_type     := l_costable_type;
 p_el_link           := l_el_link;
 p_input_value_id    := l_input_value_id;
 p_bal_adj_cost_flag := l_bal_adj_cost_flag;

end get_costing_details;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< allocate_payment >------------------------------
-- ----------------------------------------------------------------------------
--
procedure allocate_payment(p_effective_date    in date
                          ,p_amount_paid       in number
                          ,p_acty_base_rt_id   in number
                          ,p_prtt_enrt_rslt_id in number
                          ,p_business_group_id in number
                          ,p_person_id         in number
                          ,p_rt_strt_dt        in date
                          ,p_month_strt_dt     in date
                          ,p_warning           out nocopy boolean
                          ,p_excess_amount     out nocopy number) is
  --

    CURSOR c_pen(c_prtt_enrt_rslt_id number
                ,c_effective_date    date
                ,c_acty_base_rt_id   number) IS
      SELECT   pen.pgm_id
              ,pen.pl_typ_id
              ,abr.element_type_id
              ,abr.input_value_id
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val      prv
              ,ben_acty_base_rt_f   abr
      WHERE    pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
      AND      c_effective_date BETWEEN pen.enrt_cvg_strt_dt
               AND pen.enrt_cvg_thru_dt
      AND      pen.enrt_cvg_thru_dt <= pen.effective_end_date
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      prv.acty_base_rt_id = c_acty_base_rt_id
      AND      c_effective_date BETWEEN prv.rt_strt_dt and
               prv.rt_end_dt
      AND      prv.acty_base_rt_id = abr.acty_base_rt_id
      AND      c_effective_date BETWEEN abr.effective_start_date
               and abr.effective_end_date;

    CURSOR c_get_cbr_due_day(c_pl_id           number
                             ,c_effective_date date) IS
      SELECT   NVL(pln.cobra_pymt_due_dy_num,1)
      FROM     ben_pl_f pln
      WHERE    pln.pl_id = c_pl_id
      AND      c_effective_date BETWEEN pln.effective_start_date
                   AND pln.effective_end_date;

    cursor c_prev_pymts
                       (c_assignment_id     number
                       ,c_acty_base_rt_id   number
                       ,c_business_group_id number
                       ,c_effective_date    date
                       ,c_strt_dt           date
                       ,c_end_dt            date) is
    SELECT   NVL(sum(a.result_value),0) result_value
    FROM     pay_run_result_values a
            ,pay_element_types_f b
            ,pay_assignment_actions d
            ,pay_payroll_actions e
            ,pay_run_results h
            ,ben_acty_base_rt_f i
            ,pay_input_values_f j
      WHERE    d.assignment_id        = c_assignment_id
      AND      d.payroll_action_id    = e.payroll_action_id
      AND      i.input_value_id       = j.input_value_id
      AND      i.element_type_id      = b.element_type_id
      AND      i.acty_base_rt_id      = c_acty_base_rt_id
      AND      c_effective_date BETWEEN i.effective_start_date
               AND i.effective_end_date
      AND      i.business_group_id    = c_business_group_id
      AND      b.element_type_id      = h.element_type_id
      AND      d.assignment_action_id = h.assignment_action_id
      AND      e.date_earned BETWEEN c_strt_dt AND c_end_dt
      AND      a.input_value_id       = j.input_value_id
      AND      a.run_result_id        = h.run_result_id
      AND      j.element_type_id      = b.element_type_id
      AND      c_effective_date BETWEEN b.effective_start_date
                   AND b.effective_end_date
      AND      c_effective_date BETWEEN j.effective_start_date
                   AND j.effective_end_date;

     cursor c_prev_pymts_all
                       (c_assignment_id     number
                       ,c_acty_base_rt_id   number
                       ,c_business_group_id number
                       ,c_effective_date    date
                       ,c_strt_dt           date
                       ,c_end_dt            date) is
      SELECT   NVL(sum(a.result_value),0) result_value
              ,LAST_DAY(e.date_earned)    month_end_dt
      FROM     pay_run_result_values a
              ,pay_element_types_f b
              ,pay_assignment_actions d
              ,pay_payroll_actions e
              ,pay_run_results h
              ,ben_acty_base_rt_f i
              ,pay_input_values_f j
      WHERE    d.assignment_id        = c_assignment_id
      AND      d.payroll_action_id    = e.payroll_action_id
      AND      i.input_value_id       = j.input_value_id
      AND      i.element_type_id      = b.element_type_id
      AND      i.acty_base_rt_id      = c_acty_base_rt_id
      AND      c_effective_date BETWEEN i.effective_start_date
               AND i.effective_end_date
      AND      i.business_group_id    = c_business_group_id
      AND      b.element_type_id      = h.element_type_id
      AND      d.assignment_action_id = h.assignment_action_id
      AND      e.date_earned BETWEEN c_strt_dt AND c_end_dt
      AND      a.input_value_id       = j.input_value_id
      AND      a.run_result_id        = h.run_result_id
      AND      j.element_type_id      = b.element_type_id
      AND      c_effective_date BETWEEN b.effective_start_date
                   AND b.effective_end_date
      AND      c_effective_date BETWEEN j.effective_start_date
                   AND j.effective_end_date
      group by LAST_DAY(e.date_earned)
      order by LAST_DAY(e.date_earned) desc;

     cursor c_prev_pymts_latest
                       (c_assignment_id     number
                       ,c_acty_base_rt_id   number
                       ,c_business_group_id number
                       ,c_effective_date    date
                       ,c_per_month_amt     number
                       ,c_rt_strt_dt        date
                       ,c_rt_end_dt         date) is
      SELECT   NVL(sum(a.result_value),0) result_value
              ,LAST_DAY(e.date_earned)    month_end_dt
      FROM     pay_run_result_values a
              ,pay_element_types_f b
              ,pay_assignment_actions d
              ,pay_payroll_actions e
              ,pay_run_results h
              ,ben_acty_base_rt_f i
              ,pay_input_values_f j
      WHERE    d.assignment_id        = c_assignment_id
      AND      d.payroll_action_id    = e.payroll_action_id
      AND      i.input_value_id       = j.input_value_id
      AND      i.element_type_id      = b.element_type_id
      AND      i.acty_base_rt_id      = c_acty_base_rt_id
      AND      c_effective_date BETWEEN i.effective_start_date
               AND i.effective_end_date
      AND      i.business_group_id    = c_business_group_id
      AND      b.element_type_id      = h.element_type_id
      AND      d.assignment_action_id = h.assignment_action_id
      AND      a.input_value_id       = j.input_value_id
      AND      a.run_result_id        = h.run_result_id
      AND      j.element_type_id      = b.element_type_id
      AND      c_effective_date BETWEEN b.effective_start_date
                   AND b.effective_end_date
      AND      c_effective_date BETWEEN j.effective_start_date
                   AND j.effective_end_date
      AND      e.date_earned between c_rt_strt_dt and c_rt_end_dt
      group by LAST_DAY(e.date_earned)
      having NVL(sum(a.result_value),0) = c_per_month_amt
      order by LAST_DAY(e.date_earned) desc;


    CURSOR c_rates(c_person_id   in number
                  ,c_pgm_id      in number
                  ,c_pl_typ_id   in number
                  ,c_business_group_id in number
                  ,c_effective_date in date
                  ,c_element_type_id in number
                  ,c_input_value_id  in number) is
      SELECT pen.pl_id
        ,prv.element_entry_value_id
        ,prv.acty_base_rt_id
        ,prv.rt_strt_dt
        ,prv.rt_end_dt
        ,prv.ann_rt_val
        ,pen.prtt_enrt_rslt_id
        ,prv.mlt_cd
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val prv
              ,ben_acty_base_rt_f abr
      WHERE    pen.person_id = c_person_id
      AND      pen.pgm_id = c_pgm_id
      AND      pen.pl_typ_id = c_pl_typ_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.business_group_id = c_business_group_id
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      prv.business_group_id = pen.business_group_id
      AND      prv.prtt_rt_val_stat_cd IS NULL
      AND      prv.acty_typ_cd LIKE 'PBC%'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      prv.rt_strt_dt >= c_effective_date
      AND      prv.acty_base_rt_id = abr.acty_base_rt_id
      AND      abr.element_type_id +0= c_element_type_id -- PERF FIX. Added +0
      AND      abr.input_value_id  +0= c_input_value_id -- PERF FIX. Added +0
      AND      c_effective_date BETWEEN abr.effective_start_date
               and abr.effective_end_date
      ORDER BY prv.rt_strt_dt;

    CURSOR c_rates_desc(c_person_id   in number
                  ,c_pgm_id      in number
                  ,c_pl_typ_id   in number
                  ,c_business_group_id in number
                  ,c_element_type_id in number
                  ,c_input_value_id  in number) is
      SELECT pen.pl_id
        ,prv.element_entry_value_id
        ,prv.acty_base_rt_id
        ,prv.rt_strt_dt
        ,prv.rt_end_dt
        ,prv.ann_rt_val
        ,pen.prtt_enrt_rslt_id
        ,prv.mlt_cd
      FROM     ben_prtt_enrt_rslt_f pen
              ,ben_prtt_rt_val prv
              ,ben_acty_base_rt_f abr
      WHERE    pen.person_id = c_person_id
      AND      pen.pgm_id = c_pgm_id
      AND      pen.pl_typ_id = c_pl_typ_id
      AND      pen.prtt_enrt_rslt_stat_cd IS NULL
      AND      pen.sspndd_flag = 'N'
      AND      pen.business_group_id = c_business_group_id
      AND      pen.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
      AND      prv.business_group_id = pen.business_group_id
      AND      prv.prtt_rt_val_stat_cd IS NULL
      AND      prv.acty_typ_cd LIKE 'PBC%'
      AND      pen.effective_end_date = hr_api.g_eot
      AND      prv.acty_base_rt_id = abr.acty_base_rt_id
      AND      abr.element_type_id = c_element_type_id
      AND      abr.input_value_id  = c_input_value_id
      AND      prv.rt_strt_dt BETWEEN abr.effective_start_date
               and abr.effective_end_date
      ORDER BY prv.rt_strt_dt desc;

    cursor c_plan_year_end_for_pen
     (c_prtt_enrt_rslt_id    in     number
     ,c_effective_date       in     date
     )
     is
     select distinct
            yp.start_date,yp.end_date
     from   ben_prtt_enrt_rslt_f pen,
            ben_popl_yr_perd pyp,
            ben_yr_perd yp
     where  pen.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    c_effective_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
     and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
     and    pyp.pl_id=pen.pl_id
     and    yp.yr_perd_id=pyp.yr_perd_id
     and    c_effective_date between yp.start_date and yp.end_date;

    l_plan_year_strt_dt       date;
    l_plan_year_end_dt        date;

    l_ee_id                 number;
    l_effective_start_date  date;
    l_effective_end_date    date;
    l_ovn                   number;
    l_warning               boolean;

    l_amount_paid_bal       number;
    l_pl_id                 ben_pl_f.pl_id%type;
    l_cbr_due_day           ben_pl_f.cobra_pymt_due_dy_num%type;

    l_amount_due            number;

    l_prev_pymts            number;
    l_net_amount_due        number;
    l_pymt_adj_amount       number;
    l_pymt_dt               date;

    l_rt_strt_dt             ben_prtt_rt_val.rt_strt_dt%type;
    l_rt_end_dt              ben_prtt_rt_val.rt_end_dt%type;
    l_ann_rt_val             ben_prtt_rt_val.ann_rt_val%type;
    l_mlt_cd                 ben_prtt_rt_val.mlt_cd%type;

    l_last_month_amt         number;
    l_first_month_amt        number;
    l_per_month_amt          number;

    l_month_strt_dt          date;
    l_month_end_dt           date;
    l_last_full_pymt         number;
    l_last_mth_end_dt        date;

    l_cos_set_id            number;
    l_cost_alloc_kf_id      number;
    l_el_link               number;
    l_input_value_id        number;
    l_bal_adj_cost_flag     varchar2(30);
    l_costable_type         pay_element_links_f.costable_type%TYPE;

    l_organization_id       number;
    l_payroll_id            number;
    l_assignment_id         number;
    l_pen                   c_pen%rowtype;
    l_month_last_day        date;

    l_proc                  varchar2(80) := g_package||'.allocate_payment';
  begin

    hr_utility.set_location('Entering : ' || l_proc, 10);

    l_amount_paid_bal := ABS(p_amount_paid);

    open c_pen(p_prtt_enrt_rslt_id,p_effective_date,p_acty_base_rt_id);
    fetch c_pen into l_pen;
    close c_pen;

    open c_plan_year_end_for_pen
     (c_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id
     ,c_effective_date       => p_effective_date
      );
    fetch  c_plan_year_end_for_pen into l_plan_year_strt_dt, l_plan_year_end_dt;
    close c_plan_year_end_for_pen;

    if p_amount_paid > 0 then --Amount paid is positive

      -- Find the latest month for which full payment was made

      for r_rates in c_rates(c_person_id         => p_person_id
                            ,c_pgm_id            => l_pen.pgm_id
                            ,c_pl_typ_id         => l_pen.pl_typ_id
                            ,c_business_group_id => p_business_group_id
                            ,c_effective_date    => p_rt_strt_dt
                            ,c_element_type_id   => l_pen.element_type_id
                            ,c_input_value_id    => l_pen.input_value_id) loop

        open c_get_cbr_due_day(r_rates.pl_id,r_rates.rt_strt_dt);
        fetch c_get_cbr_due_day into l_cbr_due_day;
        close c_get_cbr_due_day;

        ben_element_entry.get_abr_assignment
           (p_person_id       => p_person_id
           ,p_effective_date  => r_rates.rt_strt_dt
           ,p_acty_base_rt_id => r_rates.acty_base_rt_id
           ,p_organization_id => l_organization_id
           ,p_payroll_id      => l_payroll_id
           ,p_assignment_id   => l_assignment_id);


       get_costing_details(p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_assignment_id     => l_assignment_id
                          ,p_organization_id   => l_organization_id
                          ,p_payroll_id        => l_payroll_id
                          ,p_rt_strt_dt        => r_rates.rt_strt_dt
                          ,p_acty_base_rt_id   => r_rates.acty_base_rt_id
                          ,p_cos_set_id        => l_cos_set_id
                          ,p_cost_alloc_kf_id  => l_cost_alloc_kf_id
                          ,p_costable_type     => l_costable_type
                          ,p_el_link           => l_el_link
                          ,p_input_value_id    => l_input_value_id
                          ,p_bal_adj_cost_flag => l_bal_adj_cost_flag);

        get_amount_due
            (p_person_id         => p_person_id
            ,p_business_group_id => p_business_group_id
            ,p_assignment_id     => l_assignment_id
            ,p_payroll_id        => l_payroll_id
            ,p_organization_id   => l_organization_id
            ,p_effective_date    => r_rates.rt_strt_dt
            ,p_prtt_enrt_rslt_id => r_rates.prtt_enrt_rslt_id
            ,p_acty_base_rt_id   => r_rates.acty_base_rt_id
            ,p_ann_rt_val        => r_rates.ann_rt_val
            ,p_mlt_cd            => r_rates.mlt_cd
            ,p_rt_strt_dt        => r_rates.rt_strt_dt
            ,p_rt_end_dt         => r_rates.rt_end_dt
            ,p_first_month_amt   => l_first_month_amt
            ,p_per_month_amt     => l_per_month_amt
            ,p_last_month_amt    => l_last_month_amt);


        l_month_strt_dt := p_month_strt_dt;

        -- Bug 3338978: If p_month_strt_dt is before
        -- Rate Start Date, start allocating payments based on
        -- Rate Start Date
        --
        if (l_month_strt_dt  < r_rates.rt_strt_dt) then
            l_month_strt_dt := r_rates.rt_strt_dt;
        end if;

        if l_per_month_amt > 0 then
         while (l_month_strt_dt <= r_rates.rt_end_dt
                and l_amount_paid_bal > 0
                and LAST_DAY(l_month_strt_dt) <= l_plan_year_end_dt
                and l_month_strt_dt >= l_plan_year_strt_dt)
         loop

          l_month_end_dt := LAST_DAY(l_month_strt_dt);

          if (l_month_end_dt > r_rates.rt_end_dt) then
            l_month_end_dt := r_rates.rt_end_dt;
          end if;

          open c_prev_pymts(c_assignment_id     => l_assignment_id
                            ,c_acty_base_rt_id   => r_rates.acty_base_rt_id
                            ,c_business_group_id => p_business_group_id
                            ,c_effective_date    => r_rates.rt_strt_dt
                            ,c_strt_dt           => l_month_strt_dt
                            ,c_end_dt            => l_month_end_dt);

          fetch c_prev_pymts into l_prev_pymts;
          if c_prev_pymts%notfound then
            l_prev_pymts := 0;
          end if;
          close c_prev_pymts;

          --
          -- For first month, compare previous payments with
          -- amount due (l_first_mth_amt)
          -- For other months, compare previous payments with
          -- amount due (l_per_month_amt)
          -- For last month, compare previous payments with
          -- amount due (l_last_mth_amt)

          if (l_month_strt_dt = r_rates.rt_strt_dt) then -- First month
            -- For first month, get prorated value

            l_amount_due := l_first_month_amt;

          elsif (l_month_end_dt = r_rates.rt_end_dt) then -- Last month
            -- For last month, get prorated value

            l_amount_due := l_last_month_amt;
          else
            l_amount_due := l_per_month_amt;
          end if;

          l_net_amount_due := l_amount_due - l_prev_pymts;

          -- determine the payment adjustment amount
          -- if the net_amount_due is negative (excess payment
          -- made) then no payment adjustment is to be created

          if l_net_amount_due > 0 then
            if l_amount_paid_bal <= l_net_amount_due then
              l_pymt_adj_amount := l_amount_paid_bal;
            else
              l_pymt_adj_amount := l_net_amount_due;
            end if;
          else
             l_pymt_adj_amount := 0;
          end if;

          -- If the Effective Date falls in the Month
          -- for which the payment is being made, then
          -- Payment Date is set as Effective Date

          -- If the Effective Date falls outside the Month
          -- for which the payment is being made, then
          -- Payment Date is set to the Cobra Payment Day
          -- for that month

          if p_effective_date between l_month_strt_dt
             and l_month_end_dt then
             l_pymt_dt := p_effective_date;
          else
            l_pymt_dt := LAST_DAY(ADD_MONTHS(l_month_strt_dt,-1)) + l_cbr_due_day ;
            -- Bug 3208938
            -- If COBRA due day falls outside the month, use last day of month

            l_month_last_day := LAST_DAY(l_month_strt_dt);

            if l_pymt_dt > l_month_last_day then
              l_pymt_dt := l_month_last_day;
            end if;

           -- Bug 3208938
          end if;

          l_pymt_dt := GREATEST(r_rates.rt_strt_dt,l_pymt_dt);

          l_pymt_dt := LEAST(r_rates.rt_end_dt,l_pymt_dt);
          if l_pymt_adj_amount > 0 then

           pay_balance_adjustment_api.create_adjustment
           (p_validate                   => false,
           p_effective_date             => l_pymt_dt,
           p_assignment_id              => l_assignment_id,
           p_consolidation_set_id       => l_cos_set_id,
           p_element_link_id            => l_el_link,
           p_input_value_id1            => l_input_value_id,
           p_input_value_id2            => NULL,
           p_input_value_id3            => NULL,
           p_input_value_id4            => NULL,
           p_input_value_id5            => NULL,
           p_input_value_id6            => NULL,
           p_input_value_id7            => NULL,
           p_input_value_id8            => NULL,
           p_input_value_id9            => NULL,
           p_input_value_id10           => NULL,
           p_input_value_id11           => NULL,
           p_input_value_id12           => NULL,
           p_input_value_id13           => NULL,
           p_input_value_id14           => NULL,
           p_input_value_id15           => NULL,
           p_entry_value1               => l_pymt_adj_amount,
           p_entry_value2               => NULL,
           p_entry_value3               => NULL,
           p_entry_value4               => NULL,
           p_entry_value5               => NULL,
           p_entry_value6               => NULL,
           p_entry_value7               => NULL,
           p_entry_value8               => NULL,
           p_entry_value9               => NULL,
           p_entry_value10              => NULL,
           p_entry_value11              => NULL,
           p_entry_value12              => NULL,
           p_entry_value13              => NULL,
           p_entry_value14              => NULL,
           p_entry_value15              => NULL,
           p_balance_adj_cost_flag      => l_bal_adj_cost_flag,
           p_cost_allocation_keyflex_id => l_cost_alloc_kf_id,
           p_attribute_category         => NULL,
           p_attribute1                 => NULL,
           p_attribute2                 => NULL,
           p_attribute3                 => NULL,
           p_attribute4                 => NULL,
           p_attribute5                 => NULL,
           p_attribute6                 => NULL,
           p_attribute7                 => NULL,
           p_attribute8                 => NULL,
           p_attribute9                 => NULL,
           p_attribute10                => NULL,
           p_attribute11                => NULL,
           p_attribute12                => NULL,
           p_attribute13                => NULL,
           p_attribute14                => NULL,
           p_attribute15                => NULL,
           p_attribute16                => NULL,
           p_attribute17                => NULL,
           p_attribute18                => NULL,
           p_attribute19                => NULL,
           p_attribute20                => NULL,
           p_element_entry_id           => l_ee_id,
           p_effective_start_date       => l_effective_start_date,
           p_effective_end_date         => l_effective_end_date,
           p_object_version_number      => l_ovn,
           p_create_warning             => l_warning
          );

          if l_warning then
            p_warning := l_warning;
            return;
          end if;

        end if;

        l_amount_paid_bal := l_amount_paid_bal - l_pymt_adj_amount;
        l_month_strt_dt := l_month_end_dt + 1;

       end loop;
      end if;  --l_per_month_amt > 0

      if l_amount_paid_bal <= 0 then
        exit;
      end if;

     end loop;

    else  --Payment reversal

      for r_rates in c_rates_desc(c_person_id         => p_person_id
                                 ,c_pgm_id            => l_pen.pgm_id
                                 ,c_pl_typ_id         => l_pen.pl_typ_id
                                 ,c_business_group_id => p_business_group_id
                                 ,c_element_type_id   => l_pen.element_type_id
                                 ,c_input_value_id    => l_pen.input_value_id)
      loop

        open c_get_cbr_due_day(r_rates.pl_id,r_rates.rt_strt_dt);
        fetch c_get_cbr_due_day into l_cbr_due_day;
        close c_get_cbr_due_day;

        ben_element_entry.get_abr_assignment
           (p_person_id       => p_person_id
           ,p_effective_date  => r_rates.rt_strt_dt
           ,p_acty_base_rt_id => r_rates.acty_base_rt_id
           ,p_organization_id => l_organization_id
           ,p_payroll_id      => l_payroll_id
           ,p_assignment_id   => l_assignment_id);


        get_costing_details(p_person_id        => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_assignment_id     => l_assignment_id
                          ,p_organization_id   => l_organization_id
                          ,p_payroll_id        => l_payroll_id
                          ,p_rt_strt_dt        => r_rates.rt_strt_dt
                          ,p_acty_base_rt_id   => r_rates.acty_base_rt_id
                          ,p_cos_set_id        => l_cos_set_id
                          ,p_cost_alloc_kf_id  => l_cost_alloc_kf_id
                          ,p_costable_type     => l_costable_type
                          ,p_el_link           => l_el_link
                          ,p_input_value_id    => l_input_value_id
                          ,p_bal_adj_cost_flag => l_bal_adj_cost_flag);

        for r_prev_pymts in c_prev_pymts_all(c_assignment_id   => l_assignment_id
                                          ,c_acty_base_rt_id   => r_rates.acty_base_rt_id
                                          ,c_business_group_id => p_business_group_id
                                          ,c_effective_date    => r_rates.rt_strt_dt
                                          ,c_strt_dt           => r_rates.rt_strt_dt
                                          ,c_end_dt            => r_rates.rt_end_dt)
        loop

         l_month_strt_dt := ADD_MONTHS(r_prev_pymts.month_end_dt,-1) + 1;

         if ((r_prev_pymts.month_end_dt <= l_plan_year_end_dt)
             and (l_month_strt_dt >= l_plan_year_strt_dt))
          then

          if l_amount_paid_bal <= r_prev_pymts.result_value then
            l_pymt_adj_amount := l_amount_paid_bal;
          else
            l_pymt_adj_amount := r_prev_pymts.result_value;
          end if;


          -- If the Effective Date falls in the Month
          -- for which the payment reversal is being made, then
          -- Payment Date is set as Effective Date

          -- If the Effective Date falls outside the Month
          -- for which the payment reversal is being made, then
          -- Payment Date is set to the Cobra Payment Day
          -- for that month

          if p_effective_date between l_month_strt_dt
            and r_prev_pymts.month_end_dt then
            l_pymt_dt := p_effective_date;
          else
            l_pymt_dt := l_month_strt_dt + (l_cbr_due_day -1);

            -- Bug 3208938
            -- If COBRA due day falls outside the month, use last day of month

            l_month_last_day := LAST_DAY(l_month_strt_dt);

            if l_pymt_dt > l_month_last_day then
              l_pymt_dt := l_month_last_day;
            end if;

           -- Bug 3208938
          end if;

          l_pymt_dt := GREATEST(r_rates.rt_strt_dt,l_pymt_dt);

          l_pymt_dt := LEAST(r_rates.rt_end_dt,l_pymt_dt);

          if l_pymt_adj_amount > 0 then

            pay_balance_adjustment_api.create_adjustment
            (p_validate                   => false,
             p_effective_date             => l_pymt_dt,
             p_assignment_id              => l_assignment_id,
             p_consolidation_set_id       => l_cos_set_id,
             p_element_link_id            => l_el_link,
             p_input_value_id1            => l_input_value_id,
             p_input_value_id2            => NULL,
             p_input_value_id3            => NULL,
             p_input_value_id4            => NULL,
             p_input_value_id5            => NULL,
             p_input_value_id6            => NULL,
             p_input_value_id7            => NULL,
             p_input_value_id8            => NULL,
             p_input_value_id9            => NULL,
             p_input_value_id10           => NULL,
             p_input_value_id11           => NULL,
             p_input_value_id12           => NULL,
             p_input_value_id13           => NULL,
             p_input_value_id14           => NULL,
             p_input_value_id15           => NULL,
             p_entry_value1               => -(l_pymt_adj_amount),
             p_entry_value2               => NULL,
             p_entry_value3               => NULL,
             p_entry_value4               => NULL,
             p_entry_value5               => NULL,
             p_entry_value6               => NULL,
             p_entry_value7               => NULL,
             p_entry_value8               => NULL,
             p_entry_value9               => NULL,
             p_entry_value10              => NULL,
             p_entry_value11              => NULL,
             p_entry_value12              => NULL,
             p_entry_value13              => NULL,
             p_entry_value14              => NULL,
             p_entry_value15              => NULL,
             p_balance_adj_cost_flag      => l_bal_adj_cost_flag,
             p_cost_allocation_keyflex_id => l_cost_alloc_kf_id,
             p_attribute_category         => NULL,
             p_attribute1                 => NULL,
             p_attribute2                 => NULL,
             p_attribute3                 => NULL,
             p_attribute4                 => NULL,
             p_attribute5                 => NULL,
             p_attribute6                 => NULL,
             p_attribute7                 => NULL,
             p_attribute8                 => NULL,
             p_attribute9                 => NULL,
             p_attribute10                => NULL,
             p_attribute11                => NULL,
             p_attribute12                => NULL,
             p_attribute13                => NULL,
             p_attribute14                => NULL,
             p_attribute15                => NULL,
             p_attribute16                => NULL,
             p_attribute17                => NULL,
             p_attribute18                => NULL,
             p_attribute19                => NULL,
             p_attribute20                => NULL,
             p_element_entry_id           => l_ee_id,
             p_effective_start_date       => l_effective_start_date,
             p_effective_end_date         => l_effective_end_date,
             p_object_version_number      => l_ovn,
             p_create_warning             => l_warning
            );

            if l_warning then
              p_warning := l_warning;
              return;
            end if;

          end if;

          l_amount_paid_bal := l_amount_paid_bal - l_pymt_adj_amount;

          if l_amount_paid_bal <= 0 then
            exit;
          end if;

         end if;

        end loop;

        if l_amount_paid_bal <= 0 then
          exit;
        end if;
      end loop;

    end if;

    if p_amount_paid >= 0 then -- Positive payment
      p_excess_amount := l_amount_paid_bal;

    elsif  p_amount_paid < 0 then
      p_excess_amount := - l_amount_paid_bal;
    end if;

    hr_utility.set_location('Leaving : ' || l_proc, 10);
  end allocate_payment;

END ben_cobra_requirements;

/
