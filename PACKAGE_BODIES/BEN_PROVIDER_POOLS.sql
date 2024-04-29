--------------------------------------------------------
--  DDL for Package Body BEN_PROVIDER_POOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROVIDER_POOLS" as
/* $Header: benpstcr.pkb 120.16.12010000.7 2010/02/19 10:28:44 sallumwa ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Benefit provider pools
Purpose
        This package is used to create benefit provided ledger entries as well
        as flex credit enrolment results.
History
  Date       Who       Version  What?
  ----        ---      -------  -----
  07 Jun 98  jcarpent  110.0    Created
  18 jun 98  jcarpent  110.1    Added lots more functionality
  22 jun 98  jcarpent  115.3    Added proper messages
  30 jun 98  jcarpent  115.4    Restructured accumulate pools
              Update cash entry not just ins
  06 jul 98  jcarpent  115.5    When update result pass ovn
  27 jul 98  jcarpent  115.6    Fix messages take out nocopy message.get
  30 jul 98  jcarpent  115.7    removed use of the global g_credit_pool
              for most stuff.
  22 SEP 98  GPERRY    115.8    Corrected error messages
  13 OCT 98  jcarpent  115.9    Added excess credit processing
  16 OCT 98  jcarpent  115.10   Changed total_pools to allow non-flex
              calls to pass through with no error.
  02 NOV 98  jcarpent  115.11   Fixed accum pools for chc not providing
                                credits
  10 NOV 98  jcarpent  115.12   Added bg_id to delete_bpl call
  04 DEC 98  jcarpent  115.13   Check max elctn val on enrt_rt
                                Added code comments
                                Use pool_rlovr_rqmt_f.prtt_elig_rlovr_rl
                                Use pool.auto_alct_excs_flag
  23 DEC 98  jcarpent  115.14   Subtract forfeitures from
                                total flex credits.
  29 JAN 99  shdas     115.15   added codes for comp objs.
  17 MAR 99  shdas     115.17   modified create_rollover_enrollment.
  16 APR 99  shdas     115.18   changed ben_per_in_ler_f to ben_per_in_ler.
  29 APR 99  shdas     115.19   added parameters to genutils.formula.
  29 Apr 99  lmcdonal  115.20   prtt_enrt_rslt now has stat cd.
  04 May 99  shdas     115.21   added jurisdiction code.
  27 May 99  maagrawa  115.22   Added new procedures to re-calculate
                    flex credits when choice may not be present.
  25-Jun-99  jcarpent  115.23   Added per_in_ler_id to bpl.
  09-Jul-99  jcarpent  115.24   Added checks for backed out nocopy pil
  20-JUL-99  Gperry    115.25   genutils -> benutils package
                                rename.
  12-AUG-99  maagrawa  115.26   Corrected cursor c_cash_abr
                                to fetch values into correct
                                variables.
  07-Sep-99  shdas     115.27   Added codes for cmbn_ptip_opt.
                                fixed call to pay_mag_util (TGUY)
                                added bnft_val to election_information
  21-Sep-99  lmcdonal  115.28   Added rlovr_val_rl and
                                dflt_excs_trtmt_rl calls.
  23-Sep-99  cparmar   115.29   added item pil_flex.ler_id in total_pools
                                for the group by clause
  21-Oct-99  lmcdonal  115.30   ledger did not always have
                                per-in-ler-id filled in
  12-Nov-99  lmcdonal  115.31   Calls to create_Benefit_Prvdd_Ledger
                                must pass in person id and enrt_mthd_cd.
                                Added enrt_mthd_cd to create_debit_ledger_entry,
                                recompute_flex_credits

  17-Nov-99  pbodla    115.32   added acty_base_rt_id parameter to formula call
                                when  prtt_elig_rlovr_rl is evaluated.
                                Also added to run_rule procedure.
  18-Nov-99  pbodla    115.33 - added elig_per_elctbl_chc_id parameter
                                to run_rule, formula calls.
                              - elig_per_elctbl_chc_id selected in cursor
                                c_cash_abr
                              - Added cursor c_epe
  18-Jan-00 shdas      115.34 - changed c-ledger cursor in
                                cleanup_invalid_ledger_entries.
  25-Jan-00 maagrawa   115.35 -Added parameter p_per_in_ler_id to procedures
                               create_credit_ledger_entry,
                               create_debit_ledger_entry,
                               cleanup_invalid_ledger_entries,
                               create_flex_credit_enrolment, total_pools,
                               create_rollover_enrollment.
                              -Fixed procedures to not look at 'STRTD'
                               per_in_ler. (Bug 1148445)
  29-Jan-00 shdas      115.36  modified remove_bnft_prvdd_ldgr(bug 4493)
  28-Feb-00 maagrawa   115.37  Pass p_source to delete_enrollment.
  28-Feb-00 shdas      115.38  Added get_dt_upd_mode(4785).
  03-Mar-00 maagrawa   115.39  Get the acty_base_rt_id for the pool in
                               procedure distribute_credits (c_cash_abr) using
                               the ledger row.
  09-Mar-00 lmcdonal   115.40  Support for oiplip flex credit rates.
  05-Apr-00 mmogel     115.41  Added tokens to messages to make them more
                               meaningful to the user
  15-Aug-00 maagrawa   115.42  Removed the unions from the c_choice cursor in
                               accumulate_pools procedure.
  28-Sep-00 stee       115.43  UK Select changes. Net credits are processed
                               through payroll.
  09-Oct-00 stee       115.44  UK Select changes. When a person is found
                               ineligible for a comp object, the net credits
                               are re-calculated.
  12-Oct-00 maagrawa   115.45  Added p_old_rlovr_amt to
                               create_rollover_enrollment.
                               Pass the bnft_id and bnft_val, if
                               benefit record exists for rollover plan.
  17-Oct-00 stee       115.46  Change c_prv2 to get acty_typ_cd from
                               ben_prtt_rt_val. Fix total_credits in
                               recompute_flex_credits to check for null
                               forfeited amount.
  18-Oct-00 stee       115.47  Added total pool restriction edit for rollover
                               amount at the plan level.
  16-Jan-01 mhoyes     115.48 - Added calculate only mode parameter to
                                create_debit_ledger_entry for EFC.
  13-Feb-00 pbodla     115.50 - Put the version 115.48 with changes in 115.49
  30-Mar-01 kmahendr   115.51 - Bug#1708166 - when comp.object is replaced in the
                                subsequent life event, the flex credit entry for
                                the deenrolled comp.object is not being deleted
                                from ben_bnft_prvdd_ldgr_f with the result the
                                used value is wrongly shown - added codes to
                                cleanup_invalid_ledger_entries
  09-Apr-01 pbodla     115.52 - Bug 1711831 - While getting the activity base rate
                                for the provided credits choice row for the pool
                                we are working with cursor c_cash_abr is not
                                getting the row if the person was deenrolled from
                                comp object in the benmngle run. But the ledger
                                row is still sitting. To avoid activity base rate
                                row not found error use the cursor c_get_pool_abr.
  12-Apr-1 ikasire     115.53   bug 1285336 changed the cursor
                                c_cmbn_ptip_opt_enrollment
  01-May-01 kmahendr   115.54   Bug#1750825-Added edit to cleanup credit ledger entries
                                if the comp. object is deenrolled in the subsequent life
                                event.
                                Added Get_DT_Upd_Mode calls before update_ledger_api to
                                fix error 07211-future dated rows exist.
  02-May-01 kmahendr   115.55   Leap frog version of 115.52 and changes in version
                                115.54 included
  02-May-01 kmahendr   115.56   Version 115.54 brought in as version 115.55 was leap frog
  17-May-01 maagrawa   115.57   Modified call to ben_global_enrt procedures.
  10-Jul-01 mhoyes     115.58 - Converted compute_excess, create_credit_ledger_entry and
                                create_debit_ledger_entry for EFC.
  27-aug-01 tilak      115.59   bug:1949361 jurisdiction code is
                                              derived inside benutils.formula.
  23-Oct-01 kmahendr   115.60   bug#2065445-cursor c_bnft_prvdd_ldgr and c_bnft_prvdd_ldgr_2
                                modified to select row based on p_effective_date
  26-Oct-01 kmahendr   115.61   bug#2077743-in cursor c_prv order by rt_strt_dt desc added to
                                fetch the last rate row.
  30-Oct-01 pbodla     115.62   bug#1931485-modified cusor c_rollovers to outerjoin
                                to ben_oipl_f table.
  02-Nov-01 kmahendr   115.63   cursors in person_enrolled_in_choice modified to look for
                                effective_end_date = eot
  09-Jan-02 kmahendr   115.64   Added a cursor c_enrt_rt to get the acty_base_rt_id for
                                getting the ledger entries thro cursor c_bnft_prvdd_ldgr_2
                                in cleanup_invalid ledger entries - Bug#2171014
  25-Jan-02 pbodla     115.65   Bug 2185478 Added procedure to validate the
                                rollover value entered by the user on flex
                                enrollment form and show proper message immediately
  25-Jan-02 stee       115.66   Check if a person is enrolled in the comp
                                object prior to deleting the ledger for a
                                roll over enrollment.  Bug 2119974.
  28-Jan-02 pbodla     115.67   Added dbdrv lines for GSCC compliance.
  07-Feb-02 ikasire    115.68   2199238 rollover records not appearing in the
                                flex enrollment form fixed.
  11-Feb-02 kmahendr   115.69   Bug#2210322-Ledger rows for used_val need not be updated
                                in the same life event. Changed cursor in create_debit_ledger
                                procedure.
  15-Feb-02 iaksire    115.70   Bug 2185478 added the union to the cursor in default_rollover
                                to handle the cases of enrt_bnft records
  06-Mar-02 kmahendr   115.71   Bug#2254326 - Modified cursor c_flx_credit_plan to pick up
                                the one not deenrolled.
  11-mar-02  tjesumic  115.72   bug#2251057 auto_alct_exces_flag control moved just for
                                Rollover
  13 MAR 02  tjesumic  115.73   bug#2251057  automatic rollover is executed for default
                                enrollment cursor c_get_mthd added
  15 May 02  ikasire   115.74   Bug 2200139 create_credit_ledger_entry always recomputes the
                                provided value from the enrt_rt record if the rate is changed
                                on bpp record. Now this will not happen if the enrollment
                                method code is 'O' (for Override Enrollment)
  23 May 02  kmahendr  115.75   Added a parameter to ben_determine_acty_base_rt
  39 May-02  ikasire   115.76   Bug 2386000 Added cursors to pass lee_rsn_id to rate_and
                                _coverage_dates call
  08-Jun-02  pabodla   115.31   - Do not select the contingent worker
                                  assignment when assignment data is
                                  fetched.
  08 Aug 02  kmahendr  115.78   -Bug#2382651 - added additional parameter to total_pools
                                 and create_flex_credit_enrollment and made changes to
                                 work for Multiple flex programs.
  14 Aug 02  kmahendr  115.79  - Bug#2441871 - In Update_rate procedure the ler_id is
                                 fetched from per_in_ler and create_prtt_rt api is called
                                 only if enrt rt id is not null
  11-Oct-02  vsethi    115.80    Rates Sequence no enhancements. Modified to cater
                                 to new column ord_num on ben_acty_base_rt_f
  06-Nov-02  ikasire   115.81    Bug 2645993 Fixed the case where Used amount is more than
                                 the provided amount.
  11-Nov-02  lakrish   115.82    Bug 2645624 Changed create_flex_credit_enrolment to allow
                                 non-flex calls to pass through with no error.
  02-dec-02  hnarayan  115.83    Bug fix 2689926 - fixed c_choice cursor in accumulate_pools
  				 procedure to pick up the correct benefit pool row from EPE
  30-Dec-02  mmudigon  115.84    NOCOPY
  13-Feb-03  kmahendr  115.85    Added a parameter to call -acty_base_rt.main
  01-May-03  pbodla    115.86    Removed where clause of c_choice as part of
                                 2917128 as provided ledger entries are not
                                 getting created properly.
  13-May-03  rpgupta   115.87    Bug 2988218 - Even When the flex shell plan is invalid,
  				 processing completes fine. If p_rt_val is null, we need
  				 the error to be displayed. So changed the expression.
  				 Also do this check only if it is called form a flex pgm,
  				 so that a call from non flex does'nt error.
  13-May-03  rpgupta   115.88    Added COBRAFLX to chk the program type
  21-Aug-03  kmahendr  115.89    Bug#2736036 - for net credit method,deduction rate is updated to
                                 zero if contribution is positive and vice versa.
  19-Mar-04  ikasire   115.90    Added formula rate_periodization_rl
  16-Apr-04  kmahendr  115.91    Added codes in total_pools and cleanup_invalid_ledger to
                                 handle situations when benefit pool already enrolled
                                 becomes inactive
  02-Jun-04  nhunur    115.92    changed c_prv to prevent MJC
  31-Aug-04  ikasire   115.93    Bug 3864152 fixed the nvl condition
  22-Mar-05  abparekh  115.94    Bug 4251187 : Pass proper per_in_ler_id to update of BPL
                                               in procedure distribute_credits
  29-Apr-05  kmahendr  115.95    Bug#4340736 - ledger entry for forfeiture is written wrongly
                                 Code added in total_pools
  03-May-05  mmudigon  115.96    Bug 4320660. Order by clause for cursors
                                 c_prv2 and c_prv_child
  07-Jul-05  kmahendr  115.97    Bug#4473573 - added net_Credits_method condition
                                 before resetting distributed value to 0 in
                                 total_credits.
  09-Aug-05  swjain    115.98    Bug#4538041 - Modified c_pgm_enrollment cursor in
                                 procedure person_enrolled_in_choice to exclude enrollments in
				 Flex Credit Plans
  26-Sep-05  swjain    115.100   Bug 4613270 - Modified cursor c_cash_abr in procedure
                                 distribute_credits to fetch the acty_base_rt_id corresponding
				 to the provided(FLXCR) row only
  04-Nov-05  swjain    115.101   Bug No 4714939 - Updated the cursor c_cash_rcvd to fetch any
                                 cash row for the pool instead of a particular acty_base_rt_id
  25-Dec-05  rbingi    115.102   Bug No 4964766 -  Modified cursor c_rlovr_chc to
                                  rollover to the plan within the flex program
                                  Modified c_oipl_enrolment to check pen's pgm_id also
  06-Feb-05  rbingi    115.103   Contd: 4964766 - pgm_id condition added in
                                  cursor c_plan_enrolment also.
  13-Mar-05  rbingi    115.104   Contd: 4964766 - passing pen_id null to elinf when
                                  created in prev LE and coverage starting in future.
  06-Apr-06  kmahendr  115.105   Bug#5136668 - modified cursor c_prv in compute_rollover
  27-Apr-06  rbingi    115.106   Bug 5185351: deleting ledger entries for suspended
                                  enrollements in cleanup_invalid_ledger_entries
  06-Jun-06  rbingi    115.107   Bug 5257226: Updating rate even when created in past pil
                                  in case of updated ledger.
  22-Aug-06  abparekh  115.108   Bug 5447507 : Fixed distribute_credits to query FLXCR ABR
                                 from EPE, if not found through BPL
  04-Sep-06  abparekh  115.109   Bug 5344961 : Fixed cursor C_BPL in procedure DELETE_ALL_LEDGERS
  06-Sep-06  abparekh  115.110   Bug 5500864 : In procedure cleanup_invalid_ledger_entries delete BPL
                                               in DELETE mode instead of ZAP mode to retain history
                                               of ledger entries
  02-NOV-06  ssarkar   115.111   bug 5608160 : calculation of l_new_prtt_rt_val is
                                 modified based entr_val_enrt_flag
  07-Nov-06  nhunur    115.112   cleanup_invalid_ledger_entries changed to pass correct dates for
                                 delete BPL
  22-Feb-08  rtagarra  115.113   Bug 6834215 : Closed the cursor c_choice.
  02-Jul-08  sallumwa  115.114   Bug 7118730 : Re-calculate the ledger if used amt is more than
                                 provided amount.
  22-Oct-08  sallumwa  115.115   Bug 7363185 : Update the ledger even though there is no change
                                 in the rollover amount.
  25-Sep-09  sallumwa  115.116   Bug 8504085 : If the person is de-enrolled from the comp object,
                                 check if there is any ledger entry corresponding to only that
				 comp object and delete the corresponding ledger entry.
  05-Nov-09  sallumwa  115.117   Bug 8601352 : Modified the cursors in the procedure
                                 recompute_flex_credits so that for the old prv records,the rate
				 end date doesn't change based on the new rate end date.
  19-Feb-10  sallumwa  115.118   Bug 9388229 : If Provided value is more than Used value and
                                 Cash received is still -ve,then reset it to zero.
*/
--------------------------------------------------------------------------------
g_package varchar2(80):='ben_provider_pools';

--------------------------------------------------------------------------------
--                      run_rule
--------------------------------------------------------------------------------
procedure run_rule
         (p_effective_date     in date
         ,p_person_id          in number
         ,p_dflt_excs_trtmt_rl in number default null
         ,p_rlovr_val_rl       in number default null
         ,p_business_group_id  in number
         ,p_ler_id             in number
         ,p_bnft_prvdr_pool_id in number
         ,p_acty_base_rt_id    in number default null
         ,p_elig_per_elctbl_chc_id    in number default null
         ,p_dflt_excs_trtmt_cd out nocopy varchar2
         ,p_mx_val             out nocopy number) is

  l_proc varchar2(72) := g_package||'.run_rule';

  cursor c_pool_rule_info is
    select
        bpp.pgm_id,
        ptip.pl_typ_id,
        nvl(plip.pl_id, plip2.pl_id) pl_id,
        oipl.opt_id
    from   ben_bnft_prvdr_pool_f bpp, ben_ptip_f ptip, ben_plip_f plip,
           ben_oipl_f oipl, ben_oiplip_f oiplip, ben_plip_f plip2
    where  p_effective_date between
             bpp.effective_start_date and
             bpp.effective_end_date and
           bpp.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
           bpp.business_group_id=p_business_group_id
      and  bpp.ptip_id = ptip.ptip_id(+)
      and  bpp.plip_id = plip.plip_id(+)
      and  bpp.oiplip_id = oiplip.oiplip_id(+)
      and  oiplip.oipl_id = oipl.oipl_id(+)
      and  oiplip.plip_id = plip2.plip_id(+)
      and  p_effective_date between
             ptip.effective_start_date and
             ptip.effective_end_date
      and  p_effective_date between
             plip.effective_start_date and
             plip.effective_end_date
      and  p_effective_date between
             oiplip.effective_start_date and
             oiplip.effective_end_date
      and  p_effective_date between
             oipl.effective_start_date and
             oipl.effective_end_date
      and  p_effective_date between
             plip2.effective_start_date and
             plip2.effective_end_date
    ;
    l_pool_rule_info c_pool_rule_info%rowtype;

  cursor c_person_rule_info is
    select asg.assignment_id,
        asg.organization_id,
        loc.region_2
    from  per_all_assignments_f asg,
          hr_locations_all loc
    where
        asg.person_id = p_person_id and
        asg.assignment_type <> 'C'and
        asg.primary_flag='Y' and
        asg.location_id = loc.location_id(+) and
        p_effective_date between
        asg.effective_start_date and asg.effective_end_date
    ;
    l_person_rule_info c_person_rule_info%rowtype;

  l_outputs           ff_exec.outputs_t;
  l_jurisdiction_code varchar2(30);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open c_pool_rule_info;
  fetch c_pool_rule_info into l_pool_rule_info;
  if c_pool_rule_info%NOTFOUND or c_pool_rule_info%NOTFOUND is null then
     close c_pool_rule_info;
     fnd_message.set_name('BEN','BEN_91724_NO_FLX_CR_RT_FOUND');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
     hr_utility.set_location(l_proc,82);
     fnd_message.raise_error;
  end if;
  close c_pool_rule_info;

  open c_person_rule_info;
  fetch c_person_rule_info into l_person_rule_info;
  if c_person_rule_info%NOTFOUND or c_person_rule_info%NOTFOUND is null then
     close c_person_rule_info;
     fnd_message.set_name('BEN','BEN_91708_PERSON_NOT_FOUND');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('ID', p_person_id);
     hr_utility.set_location(l_proc,82);
     fnd_message.raise_error;
  end if;
  close c_person_rule_info;

--  if l_person_rule_info.region_2 is not null then
--    l_jurisdiction_code :=
--       pay_mag_utils.lookup_jurisdiction_code
--         (p_state => l_person_rule_info.region_2);
--  end if;

  if  p_dflt_excs_trtmt_rl is not null then
      l_outputs := benutils.formula
            (p_formula_id           => p_dflt_excs_trtmt_rl,
             p_assignment_id        => l_person_rule_info.assignment_id,
             p_organization_id      => l_person_rule_info.organization_id,
             p_business_group_id    => p_business_group_id,
             p_effective_date       => p_effective_date,
             p_opt_id               => l_pool_rule_info.opt_id,
             p_pl_id                => l_pool_rule_info.pl_id,
             p_pgm_id               => l_pool_rule_info.pgm_id,
             p_ler_id               => p_ler_id,
             p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
             p_pl_typ_id            => l_pool_rule_info.pl_typ_id,
             p_jurisdiction_code    => l_jurisdiction_code);

        p_dflt_excs_trtmt_cd := l_outputs(l_outputs.first).value;
        p_mx_val := null;
  elsif p_rlovr_val_rl  is not null then
        l_outputs := benutils.formula
            (p_formula_id           => p_rlovr_val_rl,
             p_assignment_id        => l_person_rule_info.assignment_id,
             p_organization_id      => l_person_rule_info.organization_id,
             p_business_group_id    => p_business_group_id,
             p_effective_date       => p_effective_date,
             p_opt_id               => l_pool_rule_info.opt_id,
             p_pl_id                => l_pool_rule_info.pl_id,
             p_pgm_id               => l_pool_rule_info.pgm_id,
             p_ler_id               => p_ler_id,
             p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
             p_pl_typ_id            => l_pool_rule_info.pl_typ_id,
             p_jurisdiction_code    => l_jurisdiction_code);
        p_dflt_excs_trtmt_cd := null;
        p_mx_val := l_outputs(l_outputs.first).value;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 999);

end run_rule;
--------------------------------------------------------------------------------
-- This procedure returns the update mode appropriate
-- for the given table and effective_date and key.
--
Procedure Get_DT_Upd_Mode
          (p_effective_date        in  date,
           p_base_table_name       in  varchar2,
           p_base_key_column       in  varchar2,
           p_base_key_value        in  number,
           p_mode                  out nocopy varchar2
           ) is
  --
  l_correction             boolean := TRUE;
  l_update                 boolean := FALSE;
  l_update_override        boolean := FALSE;
  l_update_change_insert   boolean := FALSE;
  --
begin
hr_utility.set_location(' Entering: Get_DT_Upd_Mode' , 10);
  --
  -- Get the appropriate update mode.
  --
  DT_Api.Find_DT_Upd_Modes(p_effective_date => p_effective_date,
                    p_base_table_name       => p_base_table_name,
                    p_base_key_column       => p_base_key_column,
                    p_base_key_value        => p_base_key_value,
                    p_correction            => l_correction,
                    p_update                => l_update,
                    p_update_override       => l_update_override,
                    p_update_change_insert  => l_update_change_insert);
  --
  if l_update_override or l_update_change_insert then
     p_mode := 'UPDATE_OVERRIDE';
  elsif l_update then
     p_mode := 'UPDATE';
  elsif l_correction then
     p_mode := 'CORRECTION';
  end if;
  --
  hr_utility.set_location(' Leaving: Get_DT_Upd_Mode' , 10);
end;

--------------------------------------------------------------------------------
--                            accumulate_pools
--------------------------------------------------------------------------------
procedure accumulate_pools(
        p_validate                        in boolean default false,
        p_person_id                       in number,
        p_elig_per_elctbl_chc_id          in number,
        p_enrt_mthd_cd                    in varchar2,
        p_effective_date                  in date,
        p_business_group_id               in number
) is
  --
  l_proc varchar2(72) := g_package||'.accumulate_pools';
  --
  -- cursor c_choice
  -- epe1 is the choice which is being enrolled in
  -- epe is the choice which provides credits for epe1.
  -- epe is at the level of epe1 (same row) or above.
  --
  -- do combinations using unions.
  --

  -- bug fix 2689926 - The cursor c_choice can return multple choice rows which
  -- have benefit pool id as not null. This can occur when multiple credits and benefit pools are
  -- defined for comp objects. For eg: one at program level and one in plan or option in plan level.
  -- then when the enrollment (epe row) is for Plan or option in plan the corresponding benefit pool
  -- if present should be considered for creating the ledger entry as well as updating the prtt rate
  -- value of the shell plan prtt_enrt_rslt row.
  --

  cursor c_choice is
    select      epe.bnft_prvdr_pool_id,
                epe.elig_per_elctbl_chc_id,
                epe.prtt_enrt_rslt_id,
                epe.pgm_id,
                epe.ptip_id,
                epe.plip_id,
                epe.pl_id,
                epe.oipl_id,
                epe.oiplip_id,
                epe.cmbn_plip_id,
                epe.cmbn_ptip_id,
                epe.cmbn_ptip_opt_id,
                epe.business_group_id,
                epe.per_in_ler_id
    from        ben_elig_per_elctbl_chc epe1,
                ben_elig_per_elctbl_chc epe
    where       epe1.elig_per_elctbl_chc_id=p_elig_per_elctbl_chc_id and
                epe1.business_group_id=p_business_group_id and
                epe1.pgm_id = epe.pgm_id and -- start fix 2689926
/* Removed where clause as part of 2917128
*/
                epe1.per_in_ler_id = epe.per_in_ler_id and
                epe.bnft_prvdr_pool_id is not null and
                epe.business_group_id=p_business_group_id
	order by
                epe.pgm_id,
                epe.ptip_id,
                epe.plip_id,
                epe.pl_id,
                epe.oipl_id,
                epe.oiplip_id,
                epe.cmbn_plip_id,
                epe.cmbn_ptip_id,
                epe.cmbn_ptip_opt_id ;


  l_epe                        ben_epe_shd.g_rec_type;
  --
  l_bnft_prvdd_ldgr_id         number;
  l_prtt_enrt_rslt_id          number;
  l_prtt_rt_val_id             number;
  l_acty_ref_perd_cd           varchar2(30);
  l_acty_base_rt_id            number;
  l_rt_strt_dt                 date;
  l_rt_val                     number;
  l_element_type_id            number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location(' p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,12);
  --
  open c_choice;
  loop
    --
    fetch c_choice into
        l_epe.bnft_prvdr_pool_id,
        l_epe.elig_per_elctbl_chc_id,
        l_epe.prtt_enrt_rslt_id,
        l_epe.pgm_id,
        l_epe.ptip_id,
        l_epe.plip_id,
        l_epe.pl_id,
        l_epe.oipl_id,
        l_epe.oiplip_id,
        l_epe.cmbn_plip_id,
        l_epe.cmbn_ptip_id,
        l_epe.cmbn_ptip_opt_id,
        l_epe.business_group_id,
        l_epe.per_in_ler_id
    ;
    exit when c_choice%notfound;
    --
    accumulate_pools_for_choice(
        p_person_id                        => p_person_id,
        p_epe_rec                          => l_epe,
        p_enrt_mthd_cd                     => p_enrt_mthd_cd,
        p_effective_date                   => p_effective_date
    );
    --
  end loop;
  close c_choice;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
end accumulate_pools;
--------------------------------------------------------------------------------
--                            accumulate_pools_for_choice
--------------------------------------------------------------------------------
procedure accumulate_pools_for_choice(
        p_validate                      in boolean default false,
        p_person_id                     in number,
        p_epe_rec                       in ben_epe_shd.g_rec_type,
        p_enrt_mthd_cd                  in varchar2,
        p_effective_date                in date
) is
  --
  l_proc                varchar2(72) := g_package||'.accumulate_pools_for_choice';
  l_person_enrolled     boolean;
  l_bnft_prvdd_ldgr_id  number;
  l_enrt_rt_rec         ben_ecr_shd.g_rec_type;
  --
  l_dummy_number        number;
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- determine if the person is enrolled in the comp object or a component of it.
  --
  l_person_enrolled:=person_enrolled_in_choice(
        p_person_id                        => p_person_id,
        p_epe_rec                          => p_epe_rec,
        p_effective_date                   => p_effective_date
  );
  --
  -- If enrolled do the credit stuff
  --
  if (l_person_enrolled and
        p_epe_rec.bnft_prvdr_pool_id is not null) then
    hr_utility.set_location(l_proc, 20);
    create_credit_ledger_entry
      (p_person_id          => p_person_id
      ,p_epe_rec            => p_epe_rec
      ,p_bnft_prvdd_ldgr_id => l_bnft_prvdd_ldgr_id
      ,p_enrt_mthd_cd       => p_enrt_mthd_cd
      ,p_effective_date     => p_effective_date
      --
      ,p_bpl_prvdd_val      => l_dummy_number
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
end accumulate_pools_for_choice;
--------------------------------------------------------------------------------
--                            person_enrolled_in_choice
--------------------------------------------------------------------------------
function person_enrolled_in_choice(
        p_person_id                        number,
        p_epe_rec                          ben_epe_shd.g_rec_type,
        p_old_result_id                    number default hr_api.g_number,
        p_effective_date                   date) return boolean is

  l_proc varchar2(72) := g_package||'.person_enrolled_in_choice';

  cursor c_pgm_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 per.pgm_id=p_epe_rec.pgm_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.prtt_enrt_rslt_stat_cd is null and
        	 -- Bug 4538041
		 per.COMP_LVL_CD <> 'PLANFC' and
		 -- End Bug 4538041
                 per.sspndd_flag='N';

  cursor c_ptip_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per,
                 ben_pl_f pl,
                 ben_ptip_f pt
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 per.pl_id=pl.pl_id and
                 pl.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 pl.pl_typ_id=pt.pl_typ_id and
                 pt.business_group_id=p_epe_rec.business_group_id and
                 pt.pgm_id=p_epe_rec.pgm_id and
                 p_epe_rec.ptip_id=pt.ptip_id;

  cursor c_cmbn_ptip_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per,
                 ben_pl_f pl,
                 ben_ptip_f pt
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 per.pl_id=pl.pl_id and
                 pl.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 pl.pl_typ_id=pt.pl_typ_id and
                 pt.business_group_id=p_epe_rec.business_group_id and
                 pt.pgm_id=p_epe_rec.pgm_id and
                 p_epe_rec.cmbn_ptip_id=pt.cmbn_ptip_id;

  cursor c_cmbn_plip_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per,
                 ben_pl_f pl,
                 ben_plip_f cpp
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 per.pl_id=pl.pl_id and
                 pl.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 cpp.pl_id=pl.pl_id and
                 cpp.business_group_id=p_epe_rec.business_group_id and
                 cpp.pgm_id=p_epe_rec.pgm_id and
                 p_epe_rec.cmbn_plip_id=cpp.cmbn_plip_id;
/* bug 1285336
  cursor c_cmbn_ptip_opt_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per,
                 ben_pl_f pl,
                 ben_ptip_f pt,
                 ben_oipl_f oipl,
                 ben_opt_f opt
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.pl_id=pl.pl_id and
                 pl.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 pl.pl_typ_id=pt.pl_typ_id and
                 pt.business_group_id=p_epe_rec.business_group_id and
                 pt.pgm_id=p_epe_rec.pgm_id and
                 p_epe_rec.cmbn_ptip_opt_id=opt.cmbn_ptip_opt_id and
                 p_effective_date between
                   opt.effective_start_date and opt.effective_end_date and
                 opt.business_group_id=p_epe_rec.business_group_id and
                 oipl.opt_id=opt.opt_id and
                 oipl.oipl_id=per.oipl_id and
                 p_effective_date between
                   oipl.effective_start_date and oipl.effective_end_date and
                 oipl.business_group_id=p_epe_rec.business_group_id
                ;
*/
  cursor c_cmbn_ptip_opt_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per,
                 ben_pl_f pl,
                 ben_optip_f otp,
                 ben_oipl_f oipl
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 per.pl_id=pl.pl_id and
                 pl.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 pl.pl_typ_id=otp.pl_typ_id and
                 otp.business_group_id=p_epe_rec.business_group_id and
                 otp.pgm_id=p_epe_rec.pgm_id and
                 p_epe_rec.cmbn_ptip_opt_id=otp.cmbn_ptip_opt_id and
                 p_effective_date between
                   otp.effective_start_date and otp.effective_end_date and
                 oipl.opt_id=otp.opt_id and
                 oipl.oipl_id=per.oipl_id and
                 p_effective_date between
                   oipl.effective_start_date and oipl.effective_end_date and
                 oipl.business_group_id=p_epe_rec.business_group_id
                ;

  cursor c_plan_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 p_epe_rec.pl_id=per.pl_id and
                 p_epe_rec.pgm_id = per.pgm_id; -- Added : 4964766

  cursor c_oipl_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 p_epe_rec.oipl_id=per.oipl_id and
                 p_epe_rec.pgm_id = per.pgm_id;  -- Added : 4964766

  cursor c_oiplip_enrolment is
          select 'x'
          from   ben_prtt_enrt_rslt_f per,ben_oiplip_f oiplip,ben_plip_f cpp
          where  per.person_id=p_person_id and
                 per.business_group_id=p_epe_rec.business_group_id and
                 per.prtt_enrt_rslt_id<>p_old_result_id and
                 per.sspndd_flag='N' and
                 per.prtt_enrt_rslt_stat_cd is null and
                 p_effective_date between
                   per.effective_start_date and per.effective_end_date and
                 (enrt_cvg_thru_dt is null or
                  enrt_cvg_thru_dt=hr_api.g_eot) and
                 per.effective_end_date = hr_api.g_eot and
                 cpp.pgm_id = p_epe_rec.pgm_id and
                 per.pl_id = cpp.pl_id and
                 cpp.plip_id = oiplip.plip_id and
                 per.oipl_id = oiplip.oipl_id and
                 p_epe_rec.oiplip_id=oiplip.oiplip_id and
                 p_effective_date between
                   cpp.effective_start_date and cpp.effective_end_date and
                 cpp.business_group_id=p_epe_rec.business_group_id and
                 p_effective_date between
                   oiplip.effective_start_date and oiplip.effective_end_date and
                 oiplip.business_group_id=p_epe_rec.business_group_id;

  l_enrolled varchar2(1);

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_epe_rec.cmbn_ptip_id is not null then
    hr_utility.set_location(l_proc, 170);
    open c_cmbn_ptip_enrolment;
    fetch c_cmbn_ptip_enrolment into l_enrolled;
    if c_cmbn_ptip_enrolment%notfound then
      close c_cmbn_ptip_enrolment;
      hr_utility.set_location(l_proc, 180);
      return false;
    else
      close c_cmbn_ptip_enrolment;
      hr_utility.set_location(l_proc, 190);
      return true;
    end if;

  elsif p_epe_rec.cmbn_plip_id is not null then
    hr_utility.set_location(l_proc, 240);
    open c_cmbn_plip_enrolment;
    fetch c_cmbn_plip_enrolment into l_enrolled;
    if c_cmbn_plip_enrolment%notfound then
      close c_cmbn_plip_enrolment;
      hr_utility.set_location(l_proc, 250);
      return false;
    else
      close c_cmbn_plip_enrolment;
      hr_utility.set_location(l_proc, 260);
      return true;
    end if;

  elsif p_epe_rec.cmbn_ptip_opt_id is not null then
    hr_utility.set_location(l_proc, 200);
    open c_cmbn_ptip_opt_enrolment;
    fetch c_cmbn_ptip_opt_enrolment into l_enrolled;
    if c_cmbn_ptip_opt_enrolment%notfound then
      close c_cmbn_ptip_opt_enrolment;
      hr_utility.set_location(l_proc, 210);
      return false;
    else
      close c_cmbn_ptip_opt_enrolment;
      hr_utility.set_location(l_proc, 220);
      return true;
    end if;
    hr_utility.set_location(l_proc, 230);

  elsif p_epe_rec.oiplip_id is not null then
    hr_utility.set_location(l_proc, 201);
    open c_oiplip_enrolment;
    fetch c_oiplip_enrolment into l_enrolled;
    if c_oiplip_enrolment%notfound then
      close c_oiplip_enrolment;
      hr_utility.set_location(l_proc, 301);
      return false;
    else
      close c_oiplip_enrolment;
      hr_utility.set_location(l_proc, 401);
      return true;
    end if;
    hr_utility.set_location(l_proc, 501);

  elsif p_epe_rec.oipl_id is not null then
    hr_utility.set_location(l_proc, 20);
    open c_oipl_enrolment;
    fetch c_oipl_enrolment into l_enrolled;
    if c_oipl_enrolment%notfound then
      close c_oipl_enrolment;
      hr_utility.set_location(l_proc, 30);
      return false;
    else
      close c_oipl_enrolment;
      hr_utility.set_location(l_proc, 40);
      return true;
    end if;
    hr_utility.set_location(l_proc, 50);

  elsif p_epe_rec.pl_id is not null then
    hr_utility.set_location(l_proc, 60);
    open c_plan_enrolment;
    fetch c_plan_enrolment into l_enrolled;
    if c_plan_enrolment%notfound then
      close c_plan_enrolment;
      hr_utility.set_location(l_proc, 70);
      return false;
    else
      close c_plan_enrolment;
      return true;
    end if;
    hr_utility.set_location(l_proc, 80);

  elsif p_epe_rec.ptip_id is not null then
    hr_utility.set_location(l_proc, 90);
    open c_ptip_enrolment;
    fetch c_ptip_enrolment into l_enrolled;
    if c_ptip_enrolment%notfound then
      close c_ptip_enrolment;
      hr_utility.set_location(l_proc, 100);
      return false;
    else
      close c_ptip_enrolment;
      hr_utility.set_location(l_proc, 110);
      return true;
    end if;
    hr_utility.set_location(l_proc, 120);

  elsif p_epe_rec.pgm_id is not null then
    hr_utility.set_location(l_proc, 130);
    open c_pgm_enrolment;
    fetch c_pgm_enrolment into l_enrolled;
    if c_pgm_enrolment%notfound then
      close c_pgm_enrolment;
      hr_utility.set_location(l_proc, 140);
      return false;
    else
      close c_pgm_enrolment;
      hr_utility.set_location(l_proc, 150);
      return true;
    end if;
    hr_utility.set_location(l_proc, 160);

  else
    hr_utility.set_location(l_proc, 270);
    return false;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
end person_enrolled_in_choice;
--------------------------------------------------------------------------------
--                            create_credit_ledger_entry
--------------------------------------------------------------------------------
-- OVER LOADED PROCEDURE!!
--
procedure create_credit_ledger_entry(
    p_validate          in boolean default false,
    p_person_id         in number,
    p_elig_per_elctbl_chc_id    in number,
        p_per_in_ler_id                 in number,
    p_business_group_id     in number,
    p_bnft_prvdr_pool_id        in number,
    p_enrt_mthd_cd          in varchar2,
    p_effective_date        in date
)
is
  l_proc varchar2(72) := g_package||'.create_credit_ledger_entry';
  l_epe_rec ben_epe_shd.g_rec_type;
  l_bnft_prvdd_ldgr_id number;
  l_dummy_number       number;
  l_pgm_id             number;
  --
  cursor c_bnft_pool is
    select bpp.pgm_id
    from   ben_bnft_prvdr_pool_f bpp
    where  bpp.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
    and    p_effective_date between bpp.effective_start_date
           and bpp.effective_end_date;
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location(' p_elig_per_elctbl_chc_id '||p_elig_per_elctbl_chc_id,13);
   --
   open c_bnft_pool;
   fetch c_bnft_pool into l_pgm_id;
   close c_bnft_pool;
   --


  l_epe_rec.per_in_ler_id          := p_per_in_ler_id;
  l_epe_rec.elig_per_elctbl_chc_id := p_elig_per_elctbl_chc_id;
  l_epe_rec.business_group_id      := p_business_group_id;
  l_epe_rec.bnft_prvdr_pool_id     := p_bnft_prvdr_pool_id;
  l_epe_rec.pgm_id                 := l_pgm_id;

  create_credit_ledger_entry
    (p_person_id          => p_person_id

    ,p_epe_rec            => l_epe_rec
    ,p_bnft_prvdd_ldgr_id => l_bnft_prvdd_ldgr_id
    ,p_enrt_mthd_cd       => p_enrt_mthd_cd
    ,p_effective_date     => p_effective_date
    --
    ,p_bpl_prvdd_val      => l_dummy_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --

end create_credit_ledger_entry;
--------------------------------------------------------------------------------
--                            create_credit_ledger_entry
--------------------------------------------------------------------------------
-- OVER LOADED PROCEDURE!!
--
procedure create_credit_ledger_entry
  (p_validate            in     boolean default null
  ,p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_epe_rec             in     ben_epe_shd.g_rec_type
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date  in     date
  --
  ,p_bnft_prvdd_ldgr_id     out nocopy number -- to pass back created id
  ,p_bpl_prvdd_val          out nocopy number
  )
is
  l_proc varchar2(72) := g_package||'.create_credit_ledger_entry';
  l_enrt_rt_id            number;
  l_val                   number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_object_version_number number;
  l_bnft_prvdd_ldgr_id    number;
  l_acty_base_rt_id       number;
  l_datetrack_mode        varchar2(30);
  l_prtt_enrt_rslt_id     number;
  l_prtt_rt_val_id        number;
  l_prvdd_val             number;

 /*
  cursor c_enrt_rt is
    select
          decode(enb.enrt_bnft_id,null,
           ecr2.enrt_rt_id,ecr1.enrt_rt_id) enrt_rt_id,
          decode(enb.enrt_bnft_id,null,
           ecr2.acty_base_rt_id,ecr1.acty_base_rt_id) acty_base_rt_id,
          decode(enb.enrt_bnft_id,null,
           nvl(ecr2.dflt_val,ecr2.val),nvl(ecr1.dflt_val,ecr1.val)) val
    from   ben_enrt_rt ecr1,
           ben_enrt_rt ecr2,
           ben_enrt_bnft enb
   where  ((ecr1.elig_per_elctbl_chc_id=p_epe_rec.elig_per_elctbl_chc_id
    and (ecr1.enrt_bnft_id = enb.enrt_bnft_id
    or ecr1.enrt_bnft_id is null)
    and ecr2.enrt_rt_id = ecr1.enrt_rt_id)
   or
     (ecr2.enrt_bnft_id = enb.enrt_bnft_id and
      ecr2.enrt_rt_id = ecr1.enrt_rt_id and
      enb.elig_per_elctbl_chc_id = p_epe_rec.elig_per_elctbl_chc_id))
   and
     (ecr1.business_group_id=p_epe_rec.business_group_id or
     ecr2.business_group_id=p_epe_rec.business_group_id)
   and
     --(ecr1.decr_bnft_prvdr_pool_id is null or
      --ecr2.decr_bnft_prvdr_pool_id is null)
     (ecr1.rt_usg_cd = 'FLXCR' or
      ecr2.rt_usg_cd = 'FLXCR')
    ;
 */

  cursor c_enrt_rt
    (c_epe_id in number
    )
  is
    select ecr.enrt_rt_id,
           ecr.acty_base_rt_id,
           nvl(ecr.dflt_val, ecr.val) val
    from   ben_enrt_rt ecr
    where  ecr.elig_per_elctbl_chc_id = c_epe_id
    and    ecr.rt_usg_cd = 'FLXCR';

  cursor c_old_ledger is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.prvdd_val,
           bpl.object_version_number,
           bpl.effective_start_date
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler pil
    where  bpl.bnft_prvdr_pool_id=p_epe_rec.bnft_prvdr_pool_id
      and  bpl.business_group_id=p_epe_rec.business_group_id
      and  bpl.acty_base_rt_id = l_acty_base_rt_id
      and  bpl.prtt_enrt_rslt_id=g_credit_pool_result_id
      and  bpl.prvdd_val is not null
      and  p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    ;

begin
  hr_utility.set_location('Entering:'|| l_proc, 15);
  --
  -- Get the flex credit result id and it's per-in-ler.   Both are needed
  -- for when we create ledger rows.
  --
  if not p_calculate_only_mode then
    --
    create_flex_credit_enrolment
      (p_person_id             => p_person_id
      ,p_enrt_mthd_cd          => p_enrt_mthd_cd
      ,p_business_group_id     => p_epe_rec.business_group_id
      ,p_effective_date        => p_effective_date
      ,p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id
      ,p_prtt_rt_val_id        => l_prtt_rt_val_id
      ,p_per_in_ler_id         => p_epe_rec.per_in_ler_id
      ,p_rt_val                => null
      ,p_pgm_id                => p_epe_rec.pgm_id
      );
    --
  end if;
  hr_utility.set_location(l_proc, 40);

  hr_utility.set_location(l_proc, 50);

  hr_utility.set_location('starting create', 10);
  hr_utility.set_location('business_group_id='||to_char(p_epe_rec.business_group_id), 10);
  open c_enrt_rt
    (c_epe_id => p_epe_rec.elig_per_elctbl_chc_id
    );
  fetch c_enrt_rt into
    l_enrt_rt_id,
    l_acty_base_rt_id,
    l_val
  ;
  if c_enrt_rt%notfound
  then
    -- error
    hr_utility.set_location('BEN_91724_NO_FLX_CR_RT_FOUND', 51);
    fnd_message.set_name('BEN','BEN_91724_NO_FLX_CR_RT_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    hr_utility.set_location(' choice_id='''||to_char(p_epe_rec.elig_per_elctbl_chc_id),51);
    hr_utility.set_location(' rslt_id='''||to_char(g_credit_pool_result_id),51);
    close c_enrt_rt;
    fnd_message.raise_error;
  elsif not p_calculate_only_mode
  then
    hr_utility.set_location(l_proc, 20);
    if l_acty_base_rt_id is null then
      hr_utility.set_location('BEN_91725_NO_FLX_CR_ABR_FOUND', 52);
      fnd_message.set_name('BEN','BEN_91725_NO_FLX_CR_ABR_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      hr_utility.set_location(' enrt_rt_id='''||to_char(l_enrt_rt_id),52);
      close c_enrt_rt;
      fnd_message.raise_error;
    end if;

    hr_utility.set_location(' choice_id='||to_char(p_epe_rec.elig_per_elctbl_chc_id),51);
    hr_utility.set_location('looking for POOL p_epe_rec.bnft_prvdr_pool_id'||
             TO_CHAR(p_epe_rec.bnft_prvdr_pool_id),60);
    hr_utility.set_location(' l_acty_base_rt_id'||to_char(l_acty_base_rt_id),60);
    hr_utility.set_location(' g_credit_pool_result_id'||
          to_char(g_credit_pool_result_id), 60);

    -- if a row is already there update it
    open c_old_ledger;
    fetch c_old_ledger into
      l_bnft_prvdd_ldgr_id,
      l_prvdd_val,
      l_object_version_number,
      l_effective_start_date
    ;
    hr_utility.set_location(l_proc, 60);
    if c_old_ledger%notfound then
      hr_utility.set_location('val is'||to_char(l_val),12);
      ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
           p_bnft_prvdd_ldgr_id            => l_bnft_prvdd_ldgr_id
          ,p_effective_start_date          => l_effective_start_date
          ,p_effective_end_date            => l_effective_end_date
          ,p_prtt_ro_of_unusd_amt_flag     => 'N'
          ,p_frftd_val                     => null
          ,p_prvdd_val                     => l_val
          ,p_used_val                      => null
          ,p_bnft_prvdr_pool_id            => p_epe_rec.bnft_prvdr_pool_id
          ,p_acty_base_rt_id               => l_acty_base_rt_id
          ,p_person_id                     => p_person_id
          ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
          ,p_per_in_ler_id                 => p_epe_rec.per_in_ler_id
          ,p_prtt_enrt_rslt_id             => g_credit_pool_result_id
          ,p_business_group_id             => p_epe_rec.business_group_id
          ,p_object_version_number         => l_object_version_number
          ,p_cash_recd_val                 => null
          ,p_effective_date                => p_effective_date
       );
      hr_utility.set_location('CREATED LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),60);
      -- Bug 2200139 Override if user changes the provided value from the
      -- Override Enrollment form don't reset it again to the enrt_rt value
      --
    elsif l_val<>l_prvdd_val and nvl(p_enrt_mthd_cd,'E') <> 'O' then
      /*
      if l_effective_start_date=p_effective_date then
        l_datetrack_mode:=hr_api.g_correction;
      else
        l_datetrack_mode:=hr_api.g_update;
      end if;
      */
      Get_DT_Upd_Mode
         (p_effective_date        => p_effective_date,
          p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
          p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
          p_base_key_value        => l_bnft_prvdd_ldgr_id,
          p_mode                  => l_datetrack_mode);
      hr_utility.set_location('UPDATING LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),70);
      ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
             p_bnft_prvdd_ldgr_id         => l_bnft_prvdd_ldgr_id
          ,p_effective_start_date         => l_effective_start_date
          ,p_effective_end_date           => l_effective_end_date
          ,p_prtt_ro_of_unusd_amt_flag    => 'N'
          ,p_frftd_val                    => null
          ,p_prvdd_val                    => l_val
          ,p_used_val                     => null
          ,p_bnft_prvdr_pool_id           => p_epe_rec.bnft_prvdr_pool_id
          ,p_acty_base_rt_id              => l_acty_base_rt_id
          ,p_per_in_ler_id                => p_epe_rec.per_in_ler_id
          ,p_prtt_enrt_rslt_id            => g_credit_pool_result_id
          ,p_business_group_id            => p_epe_rec.business_group_id
          ,p_object_version_number        => l_object_version_number
          ,p_cash_recd_val                => null
          ,p_effective_date               => p_effective_date
        ,p_datetrack_mode                 => l_datetrack_mode
       );
      hr_utility.set_location('UPDATED LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),80);
    end if;
    p_bnft_prvdd_ldgr_id:=l_bnft_prvdd_ldgr_id;
    close c_old_ledger;
  end if;
  close c_enrt_rt;
  --
  p_bpl_prvdd_val := l_val;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 998);

end create_credit_ledger_entry;
--------------------------------------------------------------------------------
--                            create_debit_ledger_entry
--------------------------------------------------------------------------------
-- OVER LOADED PROCEDURE!!
--
procedure create_debit_ledger_entry
  (p_validate           in     boolean default false
  ,p_calculate_only_mode        in     boolean default false
  ,p_person_id          in     number
  ,p_per_in_ler_id              in     number
  ,p_elig_per_elctbl_chc_id in     number
  ,p_prtt_enrt_rslt_id      in     number
  ,p_decr_bnft_prvdr_pool_id    in     number
  ,p_acty_base_rt_id        in     number
  ,p_prtt_rt_val_id     in     number
  ,p_enrt_mthd_cd               in     varchar2
  ,p_val                        in     number
  ,p_bnft_prvdd_ldgr_id     in out nocopy number
  ,p_business_group_id      in     number
  ,p_effective_date     in     date
  --
  ,p_bpl_used_val                  out nocopy number
  )
is

  l_proc                 varchar2(72) := g_package||'.create_debit_ledger_entry';
  l_epe_rec              ben_epe_shd.g_rec_type;
  l_ecr_rec              ben_ecr_shd.g_rec_type;
  l_prtt_enrt_rslt_id    number;
  l_prtt_rt_val_id       number;
  l_pgm_id               number;
  --
  --bug#2382651
  cursor c_epe is
    select pgm_id
    from ben_elig_per_elctbl_chc epe
    where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
 --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open c_epe;
  fetch c_epe into l_pgm_id;
  close c_epe;
  -- Check for calculate only mode
  --
  if not p_calculate_only_mode then
    --
    -- Get the flex credit result id and it's per-in-ler.   Both are needed
    -- for when we create ledger rows.
    --
    create_flex_credit_enrolment
      (p_person_id                => p_person_id
      ,p_enrt_mthd_cd             => p_enrt_mthd_cd
      ,p_business_group_id        => p_business_group_id
      ,p_effective_date           => p_effective_date
      ,p_prtt_enrt_rslt_id        => l_prtt_enrt_rslt_id
      ,p_prtt_rt_val_id           => l_prtt_rt_val_id
      ,p_per_in_ler_id            => p_per_in_ler_id
      ,p_rt_val                   => null
      ,p_pgm_id                   => l_pgm_id
      );
    --
  end if;
  hr_utility.set_location(l_proc, 40);
  --
  l_epe_rec.elig_per_elctbl_chc_id:= p_elig_per_elctbl_chc_id;
  l_epe_rec.prtt_enrt_rslt_id     := p_prtt_enrt_rslt_id;
  l_epe_rec.business_group_id     := p_business_group_id;
  l_epe_rec.per_in_ler_id         := p_per_in_ler_id;

  l_ecr_rec.decr_bnft_prvdr_pool_id := p_decr_bnft_prvdr_pool_id;
  l_ecr_rec.acty_base_rt_id         := p_acty_base_rt_id;
  l_ecr_rec.prtt_rt_val_id          := p_prtt_rt_val_id;
  l_ecr_rec.val                     := p_val;

  create_debit_ledger_entry
    (p_validate             => p_validate
    ,p_calculate_only_mode  => p_calculate_only_mode
    ,p_person_id            => p_person_id
    ,p_enrt_mthd_cd         => p_enrt_mthd_cd
    ,p_epe_rec              => l_epe_rec
    ,p_enrt_rt_rec          => l_ecr_rec
    ,p_bnft_prvdd_ldgr_id   => p_bnft_prvdd_ldgr_id
    ,p_business_group_id    => p_business_group_id
    ,p_effective_date       => p_effective_date
    --
    ,p_bpl_used_val         => p_bpl_used_val
    );
  hr_utility.set_location('Leaving:'|| l_proc, 999);

end create_debit_ledger_entry;
--------------------------------------------------------------------------------
--                            create_debit_ledger_entry
--------------------------------------------------------------------------------
-- OVER LOADED PROCEDURE!!
--
procedure create_debit_ledger_entry
  (p_validate            in     boolean default false
  ,p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_epe_rec             in     ben_epe_shd.g_rec_type
  ,p_enrt_rt_rec         in     ben_ecr_shd.g_rec_type
  ,p_bnft_prvdd_ldgr_id  in     out nocopy number  -- to pass back created id
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  --
  ,p_bpl_used_val           out nocopy number
  )
is

  l_effective_start_date date;
  l_effective_end_date date;
  l_object_version_number number;
  l_val number;
  l_datetrack_mode varchar2(30);

  l_proc varchar2(72) := g_package||'.create_debit_ledger_entry';
  l_per_in_ler_id   number;
  l_used_val        number := 0;

  cursor c_old_ledger is
    select      bpl.bnft_prvdd_ldgr_id,
                bpl.per_in_ler_id,
                bpl.used_val,
                bpl.object_version_number,
                bpl.effective_start_date
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_per_in_ler pil
    where       bpl.bnft_prvdr_pool_id=p_enrt_rt_rec.decr_bnft_prvdr_pool_id
        and     bpl.business_group_id=p_epe_rec.business_group_id
        and     bpl.acty_base_rt_id=p_enrt_rt_rec.acty_base_rt_id
        and     bpl.prtt_enrt_rslt_id=g_credit_pool_result_id
        and     bpl.used_val is not null
        and     p_effective_date between
                  bpl.effective_start_date and bpl.effective_end_date
        and pil.per_in_ler_id=bpl.per_in_ler_id
        and pil.business_group_id=bpl.business_group_id
        and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') ;

  cursor c_prtt_rt_val
    (c_prtt_rt_val_id in number
    )
  is
    select rt_val
    from   ben_prtt_rt_val
    where  prtt_rt_val_id=p_enrt_rt_rec.prtt_rt_val_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 15);

  -- see if a prtt_enrt_rt exists, is so use it's val
  if p_enrt_rt_rec.prtt_rt_val_id is null then
    l_val:=p_enrt_rt_rec.val;
  else
    -- get the value to use from prtt_rt_val
    open c_prtt_rt_val
      (c_prtt_rt_val_id => p_enrt_rt_rec.prtt_rt_val_id
      );
    fetch c_prtt_rt_val into l_val;
    if c_prtt_rt_val%notfound then
       l_val:=p_enrt_rt_rec.val;
    end if;
    close c_prtt_rt_val;
  end if;
  -- if a row is already there update it
  open c_old_ledger;
  fetch c_old_ledger into
    p_bnft_prvdd_ldgr_id,
    l_per_in_ler_id,
    l_used_val,
    l_object_version_number,
    l_effective_start_date;
  --
  -- Check for calculate only mode
  --
  if not p_calculate_only_mode then
    --
    if c_old_ledger%notfound then
       ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
             p_bnft_prvdd_ldgr_id           => p_bnft_prvdd_ldgr_id
            ,p_effective_start_date         => l_effective_start_date
            ,p_effective_end_date           => l_effective_end_date
            ,p_prtt_ro_of_unusd_amt_flag    => 'N'
            ,p_frftd_val                    => null
            ,p_prvdd_val                    => null
            ,p_used_val                     => l_val
            ,p_bnft_prvdr_pool_id           => p_enrt_rt_rec.decr_bnft_prvdr_pool_id
            ,p_acty_base_rt_id              => p_enrt_rt_rec.acty_base_rt_id
            ,p_per_in_ler_id                => p_epe_rec.per_in_ler_id
            ,p_enrt_mthd_cd                 => p_enrt_mthd_cd
            ,p_person_id                    => p_person_id
            ,p_prtt_enrt_rslt_id            => g_credit_pool_result_id
            ,p_business_group_id            => p_epe_rec.business_group_id
            ,p_object_version_number        => l_object_version_number
            ,p_cash_recd_val                => null
            ,p_effective_date               => p_effective_date
        );
        hr_utility.set_location('CREATED LEDGER ID='||to_char(p_bnft_prvdd_ldgr_id),41);
    else
        /*if l_effective_start_date=p_effective_date then
          l_datetrack_mode:=hr_api.g_correction;
        else
          l_datetrack_mode:=hr_api.g_update;
        end if;*/
        Get_DT_Upd_Mode
         (p_effective_date        => p_effective_date,
          p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
          p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
          p_base_key_value        => p_bnft_prvdd_ldgr_id,
          p_mode                  => l_datetrack_mode);
       -- bug#2210322 - if there is no update on result row then no need to update ledger row
       -- or condition to take care of unrestricted life event
       if l_per_in_ler_id <> p_epe_rec.per_in_ler_id or
           l_used_val <> l_val then

           hr_utility.set_location('UPDATING LEDGER ID='||to_char(p_bnft_prvdd_ldgr_id),51);

           ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                p_bnft_prvdd_ldgr_id           => p_bnft_prvdd_ldgr_id
               ,p_effective_start_date         => l_effective_start_date
               ,p_effective_end_date           => l_effective_end_date
  --
  -- Bug 2199238 rollover plan not displayed because of this
  --             ,p_prtt_ro_of_unusd_amt_flag    => 'N'
               ,p_frftd_val                    => null
               ,p_prvdd_val                    => null
               ,p_used_val                     => l_val
               ,p_bnft_prvdr_pool_id           => p_enrt_rt_rec.decr_bnft_prvdr_pool_id
               ,p_acty_base_rt_id              => p_enrt_rt_rec.acty_base_rt_id
               ,p_per_in_ler_id                => p_epe_rec.per_in_ler_id
               ,p_prtt_enrt_rslt_id            => g_credit_pool_result_id
               ,p_business_group_id            => p_epe_rec.business_group_id
               ,p_object_version_number        => l_object_version_number
               ,p_cash_recd_val                => null
               ,p_effective_date               => p_effective_date
               ,p_datetrack_mode               => l_datetrack_mode
              );
             hr_utility.set_location('UPDATED LEDGER ID='||to_char(p_bnft_prvdd_ldgr_id),55);
        end if;
    end if;
    close c_old_ledger;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 998);
  --
  -- Set OUT parameters
  --
  p_bpl_used_val := l_val;
  --
end create_debit_ledger_entry;
--------------------------------------------------------------------------------
--                      cleanup_invalid_ledger_entries
--------------------------------------------------------------------------------
-- OVER LOADED PROCEDURE!!
--
procedure cleanup_invalid_ledger_entries(  -- so few args because uses global table
        p_validate              in boolean default false,
        p_person_id             in number,
        p_prtt_enrt_rslt_id     in number,
        p_effective_date        in date,
        p_business_group_id     in number
) is
  l_proc varchar2(72) := g_package||'.cleanup_invalid_ledger_entries';
  l_epe ben_epe_shd.g_rec_type;
  l_rt_usg_cd        varchar2(30);
  l_bnft_prvdd_ldgr_id number;
  l_ldgr_id number;
  l_per_in_ler_id number;
  l_person_enrolled boolean;
  l_effective_start_date date;
  l_effective_end_date date;
  l_object_version_number number;
  l_prtt_enrt_rslt_id  number;
  l_acty_base_rt_id  number;
  l_prtt_ro_of_unusd_amt_flag  ben_bnft_prvdd_ldgr_f.prtt_ro_of_unusd_amt_flag%type;
  l_delete_bpl boolean default true;
  l_exists varchar2(1);
  --
  -- this cursor needs some explaination
  --   It get the set of choices which have ledger entries - (for entire person)
  --   The first half of the query gets the choices and the abr to join to ledger
  --   The second half makes sure the ledger belongs to the correct person
  --   This is weird because the result id on the ledger is not the one which caused
  --   the ledger entry to be written.  jcarpent

  cursor c_ledger is
    select distinct
                epe.bnft_prvdr_pool_id,
                epe.elig_per_elctbl_chc_id,
                epe.prtt_enrt_rslt_id,
                epe.pgm_id,
                epe.ptip_id,
                epe.plip_id,
                epe.pl_id,
                epe.oipl_id,
                epe.cmbn_ptip_id,
                epe.cmbn_plip_id,
                epe.cmbn_ptip_opt_id,
                epe.business_group_id,
                pil.per_in_ler_id,
                bpl.bnft_prvdd_ldgr_id,
                bpl.object_version_number,
                decode(enb.enrt_bnft_id, null,
                ecr2.rt_usg_cd,ecr1.rt_usg_cd) rt_usg_cd
    from        ben_elig_per_elctbl_chc epe,
                ben_per_in_ler pil,
                ben_enrt_rt ecr1,
                ben_enrt_rt ecr2,
                ben_enrt_bnft enb,
                ben_bnft_prvdd_ldgr_f bpl,
                ben_elig_per_elctbl_chc epe_flex,
                ben_per_in_ler pil_flex
    where       pil.person_id=p_person_id and
                pil.business_group_id=p_business_group_id and
                pil.per_in_ler_stat_cd='STRTD' and
                pil.per_in_ler_id=epe.per_in_ler_id and
                bpl.per_in_ler_id = pil.per_in_ler_id and
                epe.business_group_id=p_business_group_id and
                --epe.bnft_prvdr_pool_id is not null and
                epe.elig_per_elctbl_chc_id=ecr2.elig_per_elctbl_chc_id(+) and
                (ecr1.acty_base_rt_id=bpl.acty_base_rt_id
                 or ecr2.acty_base_rt_id=bpl.acty_base_rt_id) and
                epe.elig_per_elctbl_chc_id=enb.elig_per_elctbl_chc_id(+) and
                enb.enrt_bnft_id = ecr1.enrt_bnft_id(+) and
                bpl.business_group_id=p_business_group_id and
                p_effective_date between
                  bpl.effective_start_date and bpl.effective_end_date
                --and bpl.prvdd_val is null and
                and bpl.prtt_enrt_rslt_id=epe_flex.prtt_enrt_rslt_id and
                epe_flex.business_group_id=p_business_group_id and
                epe_flex.per_in_ler_id=pil_flex.per_in_ler_id and
                pil_flex.business_group_id=p_business_group_id and
                pil_flex.person_id=p_person_id --and
    ;

    cursor c_rslt_exist is
    select pen.prtt_enrt_rslt_id
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id <> p_prtt_enrt_rslt_id
    and pen.comp_lvl_cd <> 'PLANFC'
    and pen.person_id = p_person_id
    and p_effective_date between
    pen.effective_start_date and pen.effective_end_date;

    cursor c_ldgr_exist(l_ldgr_id number,l_per_in_ler_id number) is
    select 'x'
    from ben_bnft_prvdd_ldgr_f bpl,
         ben_per_in_ler        pil
    where bpl.bnft_prvdd_ldgr_id = l_ldgr_id
    and bpl.per_in_ler_id = l_per_in_ler_id
    -- UK change : Bug 1634870
    and bpl.per_in_ler_id = pil.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and p_effective_date between
    bpl.effective_start_date and bpl.effective_end_date;
    --
    --Bug#1708166 - the cursor above deletes entries related to deenrolled
    -- comp.object only if the comp.object is deleted in the same life event.
    -- In other words, in the subsequent life event, if the comp.object
    -- is replaced , the related ledger entry is not being deleted.
    -- The following cursors accomplish the task
    --
    cursor c_rslt is
       select enrt_cvg_strt_dt,
              enrt_cvg_thru_dt,
              prtt_enrt_rslt_stat_cd,
              sspndd_flag
       from   ben_prtt_enrt_rslt_f
       where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and    p_effective_date between effective_start_date
              and effective_end_date;
    --
    cursor c_acty_base_rt is
       select distinct acty_base_rt_id
       from ben_prtt_rt_val
       where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
    --
    ---------------Bug 8504085
    ----------Get the flex credit epe ID against the comp object
    cursor c_get_credit_ledger_epe(p_pil_id number,p_oipl_id number) is
       SELECT *
         FROM ben_elig_per_elctbl_chc epe
        WHERE epe.per_in_ler_id = p_pil_id
          AND epe.business_group_id = p_business_group_id
          AND epe.bnft_prvdr_pool_id is not null
          AND epe.oipl_id = p_oipl_id
          AND comp_lvl_cd = 'OIPLIP';

    l_get_credit_ledger_epe   c_get_credit_ledger_epe%rowtype;
    cursor c_acty_base_rt1(p_epe_id number) is
       SELECT acty_base_rt_id
         FROM ben_enrt_rt
        WHERE rt_usg_cd = 'FLXCR'
          AND business_group_id = p_business_group_id
          AND elig_per_elctbl_chc_id = p_epe_id;

    l_acty_base_rt1   c_acty_base_rt1%rowtype;
    ---------------Bug 8504085
    cursor c_flx_credit_plan is
       select prtt_enrt_rslt_id
       from ben_prtt_enrt_rslt_f
       where person_id = p_person_id
       and   comp_lvl_cd = 'PLANFC'
       and   prtt_enrt_rslt_stat_cd is null
       -- added effective_end_date line Bug# 2254326
       and   effective_end_date = hr_api.g_eot
       and   p_effective_date between enrt_cvg_strt_dt
             and enrt_cvg_thru_dt;
    --
    cursor c_bnft_prvdd_ldgr is
       select bpl.bnft_prvdd_ldgr_id,
              bpl.prtt_ro_of_unusd_amt_flag,
              bpl.object_version_number,
              bpl.effective_start_date
       from   ben_bnft_prvdd_ldgr_f bpl,
              ben_per_in_ler pil
       where  bpl.acty_base_rt_id = l_acty_base_rt_id
       and    bpl.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
    --   and    bpl.effective_end_date = hr_api.g_eot
       and    p_effective_date between bpl.effective_start_date
              and bpl.effective_end_date
       and    bpl.per_in_ler_id = pil.per_in_ler_id
       and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
    --
    -- Bug#1750825
    cursor c_choice is
    select      epe.bnft_prvdr_pool_id,
                epe.elig_per_elctbl_chc_id,
                epe.prtt_enrt_rslt_id,
                epe.pgm_id,
                epe.ptip_id,
                epe.plip_id,
                epe.pl_id,
                epe.oipl_id,
                epe.oiplip_id,
                epe.cmbn_plip_id,
                epe.cmbn_ptip_id,
                epe.cmbn_ptip_opt_id,
                epe.business_group_id,
                epe.per_in_ler_id
    from        ben_elig_per_elctbl_chc epe1,
                ben_elig_per_elctbl_chc epe,
                ben_per_in_ler pil
    where       epe1.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
                epe1.business_group_id=p_business_group_id and
                epe1.pgm_id = epe.pgm_id and
                epe1.per_in_ler_id = epe.per_in_ler_id and
                epe.bnft_prvdr_pool_id is not null and
                epe.business_group_id=p_business_group_id and
                epe1.per_in_ler_id = pil.per_in_ler_id and
                pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
    --
     cursor c_bnft_prvdd_ldgr_2 (p_acty_base_rt_id number) is
       select bpl.bnft_prvdd_ldgr_id,
              bpl.object_version_number,
              effective_start_date
       from   ben_bnft_prvdd_ldgr_f bpl,
              ben_per_in_ler pil
       where  bpl.bnft_prvdr_pool_id = l_epe.bnft_prvdr_pool_id
       and    bpl.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
       and    bpl.acty_base_rt_id   = p_acty_base_rt_id
       --and    bpl.effective_end_date = hr_api.g_eot
       and    p_effective_date between bpl.effective_start_date
              and bpl.effective_end_date
       and    bpl.per_in_ler_id = pil.per_in_ler_id
       and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');

    --
    --    Bug#2171014
    --
    cursor c_enrt_rt
    (c_epe_id in number
    )
      is
    select ecr.enrt_rt_id,
           ecr.acty_base_rt_id,
           nvl(ecr.dflt_val, ecr.val) val
    from   ben_enrt_rt ecr
    where  ecr.elig_per_elctbl_chc_id = c_epe_id
    and    ecr.rt_usg_cd = 'FLXCR';
    --
    cursor c_person_enrolled is
       select null
       from ben_elig_per_elctbl_chc epe
           ,ben_prtt_enrt_rslt_f pen
           ,ben_enrt_rt ecr
           ,ben_enrt_bnft enb
       where epe.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
       and   pen.person_id = p_person_id
       and   pen.prtt_enrt_rslt_stat_cd is null
       and   epe.business_group_id = pen.business_group_id
       and   pen.sspndd_flag = 'N'
       and   pen.enrt_cvg_thru_dt = hr_api.g_eot
       and   pen.effective_end_date = hr_api.g_eot
       and   epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
       and   enb.enrt_bnft_id = ecr.enrt_bnft_id
       and   ecr.acty_base_rt_id = l_acty_base_rt_id;
    --
    l_enrt_rt    c_enrt_rt%rowtype;

    l_ldgr_exist  varchar2(1);
    l_rslt_id number;
    l_rslt    c_rslt%rowtype;
    l_purge   varchar2(1) := 'N';
    -- Bug 5500864
    l_bpl_esd        date;
    l_datetrack_mode varchar2(30);
    l_effective_date date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open c_ledger;

  loop
    fetch c_ledger into
        l_epe.bnft_prvdr_pool_id,
        l_epe.elig_per_elctbl_chc_id,
        l_epe.prtt_enrt_rslt_id,
        l_epe.pgm_id,
        l_epe.ptip_id,
        l_epe.plip_id,
        l_epe.pl_id,
        l_epe.oipl_id,
        l_epe.cmbn_ptip_id,
        l_epe.cmbn_plip_id,
        l_epe.cmbn_ptip_opt_id,
        l_epe.business_group_id,
        l_per_in_ler_id,
        l_bnft_prvdd_ldgr_id,
        l_object_version_number,
        l_rt_usg_cd
    ;
    hr_utility.set_location(l_proc, 20);

    exit when c_ledger%notfound;

    hr_utility.set_location('ldgr is '||l_bnft_prvdd_ldgr_id, 30);
    hr_utility.set_location('Pool is '||l_epe.bnft_prvdr_pool_id, 30);
    hr_utility.set_location('PGM is '||l_epe.pgm_id, 30);
    hr_utility.set_location('PLIP is '||l_epe.plip_id, 30);
    hr_utility.set_location('PL is '||l_epe.pl_id, 30);
    hr_utility.set_location('OIPL is '||l_epe.oipl_id, 30);
    hr_utility.set_location('PTIP is '||l_epe.ptip_id, 30);


    l_person_enrolled:=person_enrolled_in_choice(
        p_person_id        => p_person_id,
        p_epe_rec          => l_epe,
        p_old_result_id    => p_prtt_enrt_rslt_id,
        p_effective_date   => p_effective_date    );

    hr_utility.set_location(l_proc, 40);
    --
    -- if the person is not enrolled or
    -- rt_usg_cd<>'FLXCR' and not directly enrolled
    -- then remove the ledger entry
    --
    hr_utility.set_location('Checking ledger='||to_char(l_bnft_prvdd_ldgr_id), 45);
    if (not l_person_enrolled) then
        open c_ldgr_exist(l_bnft_prvdd_ldgr_id,l_per_in_ler_id);
        fetch c_ldgr_exist into l_ldgr_exist;
        if c_ldgr_exist%notfound then
            close c_ldgr_exist;
        else

        --nvl(l_rt_usg_cd,hr_api.g_varchar2)<>'FLXCR') then
      hr_utility.set_location('Deleting ledger='||to_char(l_bnft_prvdd_ldgr_id), 50);
      ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
        p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id,
        p_effective_start_date    => l_effective_start_date,
        p_effective_end_date      => l_effective_end_date,
        p_object_version_number   => l_object_version_number,
        p_effective_date          => p_effective_date,
        p_datetrack_mode          => hr_api.g_zap,
        p_business_group_id       => p_business_group_id
      );
      close c_ldgr_exist;
      end if;
      --check if there are any ledger entry only corresponding to this Activity base rt ID,Bug 8504085
      if l_epe.oipl_id is not null then
        hr_utility.set_location('oipl ID not null ,l_epe.oipl_id : '||l_epe.oipl_id, 50);
	 open c_get_credit_ledger_epe(l_per_in_ler_id,l_epe.oipl_id);
	 fetch c_get_credit_ledger_epe into l_get_credit_ledger_epe;
	 if c_get_credit_ledger_epe%found then
	 open c_acty_base_rt1(l_get_credit_ledger_epe.elig_per_elctbl_chc_id);
	 fetch c_acty_base_rt1 into l_acty_base_rt_id;
	 if c_acty_base_rt1%found then
	     hr_utility.set_location('l_acty_base_rt_id1 : '|| l_acty_base_rt_id, 50);
	    open c_flx_credit_plan;
	    fetch c_flx_credit_plan into l_prtt_enrt_rslt_id;
	    close c_flx_credit_plan;
           if l_prtt_enrt_rslt_id is not null then
	    open c_bnft_prvdd_ldgr;
          fetch c_bnft_prvdd_ldgr into l_bnft_prvdd_ldgr_id,
                                       l_prtt_ro_of_unusd_amt_flag,
                                       l_object_version_number,
                                       l_bpl_esd;
          hr_utility.set_location('ldgr id is'||l_bnft_prvdd_ldgr_id, 51);
          if c_bnft_prvdd_ldgr%found then
              if p_effective_date = l_bpl_esd
              then
                l_datetrack_mode := hr_api.g_zap;
		l_effective_date := l_bpl_esd ;
              else
                l_datetrack_mode := hr_api.g_delete;
		l_effective_date := p_effective_date - 1 ;
              end if;
              --
              ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id,
                p_effective_start_date    => l_effective_start_date,
                p_effective_end_date      => l_effective_end_date,
                p_object_version_number   => l_object_version_number,
                p_effective_date          => l_effective_date,
                p_datetrack_mode          => l_datetrack_mode,
                p_business_group_id       => p_business_group_id
               );
            end if;
           close c_bnft_prvdd_ldgr;
	   end if;
	 end if;
	 close c_acty_base_rt1;	 end if;
	 close c_get_credit_ledger_epe;
      end if;
    end if;
    l_prtt_enrt_rslt_id := null;
    l_acty_base_rt_id := null;
    l_bnft_prvdd_ldgr_id := null;
    l_prtt_ro_of_unusd_amt_flag := null;
    l_object_version_number := null;
    l_bpl_esd := null;
    l_datetrack_mode := null;
    l_effective_date := null;
    hr_utility.set_location(l_proc, 70);
  end loop;
  --
-- bug # 1708166
  --
    open c_rslt;
    fetch c_rslt into l_rslt;
    close c_rslt;
    hr_utility.set_location('Thru dt ' ||l_rslt.enrt_cvg_thru_dt, 70);
    hr_utility.set_location('stat Cd '||l_rslt.prtt_enrt_rslt_stat_cd, 70);
    hr_utility.set_location('sspndd  '||l_rslt.sspndd_flag, 70);
    if l_rslt.enrt_cvg_thru_dt <>hr_api.g_eot or
        l_rslt.prtt_enrt_rslt_stat_cd in ('VOIDD','BCKDT') or
        nvl(l_rslt.sspndd_flag,'N') = 'Y' then -- Bug 5185351
       l_purge := 'Y';
    end if;
    --
    --
    open c_flx_credit_plan;
    fetch c_flx_credit_plan into l_prtt_enrt_rslt_id;
    close c_flx_credit_plan;
    --
    if l_purge = 'Y' then
      if l_prtt_enrt_rslt_id is not null then
        open c_acty_base_rt;
        loop
          fetch c_acty_base_rt into l_acty_base_rt_id;
          exit when c_acty_base_rt%notfound;
          open c_bnft_prvdd_ldgr;
          fetch c_bnft_prvdd_ldgr into l_bnft_prvdd_ldgr_id,
                                       l_prtt_ro_of_unusd_amt_flag,
                                       l_object_version_number,
                                       l_bpl_esd;
          hr_utility.set_location('ldgr id is'||l_bnft_prvdd_ldgr_id, 51);
          if c_bnft_prvdd_ldgr%found then
            --
            -- Delete only if there are no current enrollment in
            -- this comp object for the person.  For an FSA plan, when
            -- a person rolls over excess credits, it is a comp object
            -- change as the benefit amount changes.  The original enrollment
            -- is voided and a new enrollment result is created.  In
            -- this case, we do not want to delete the ledger as the
            -- person is still enrolled in the fsa plan. Bug 2119974.
            --
            if l_prtt_ro_of_unusd_amt_flag = 'Y' then
              open c_person_enrolled;
              fetch c_person_enrolled into l_exists;
              if c_person_enrolled%found then
                hr_utility.set_location('person_enrolled ', 51);
                l_delete_bpl := false;
              else
                l_delete_bpl := true;
              end if;
              close c_person_enrolled;
            end if;
            --
            if l_delete_bpl then
              --
              -- Bug 5500864
              -- We dont want to purge the BPL entries. This prevents the reinstatement in case
              -- the life event that deletes these entries is voided subsequently
              -- Following call is delete of USED_VAL BPL entries.
              --
              if p_effective_date = l_bpl_esd
              then
                l_datetrack_mode := hr_api.g_zap;
		l_effective_date := l_bpl_esd ;
              else
                l_datetrack_mode := hr_api.g_delete;
		l_effective_date := p_effective_date - 1 ;
              end if;
              --
              ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id,
                p_effective_start_date    => l_effective_start_date,
                p_effective_end_date      => l_effective_end_date,
                p_object_version_number   => l_object_version_number,
                p_effective_date          => l_effective_date,
                p_datetrack_mode          => l_datetrack_mode,
                p_business_group_id       => p_business_group_id
               );
            end if;
          end if;
          close c_bnft_prvdd_ldgr;
        end loop;
        close c_acty_base_rt;
       --
      end if;
    end if;
    -- Bug#1750825

    if l_prtt_enrt_rslt_id is not null then
        open c_choice;
        loop
        --
        fetch c_choice into
              l_epe.bnft_prvdr_pool_id,
              l_epe.elig_per_elctbl_chc_id,
              l_epe.prtt_enrt_rslt_id,
              l_epe.pgm_id,
              l_epe.ptip_id,
              l_epe.plip_id,
              l_epe.pl_id,
              l_epe.oipl_id,
              l_epe.oiplip_id,
              l_epe.cmbn_plip_id,
              l_epe.cmbn_ptip_id,
              l_epe.cmbn_ptip_opt_id,
              l_epe.business_group_id,
              l_epe.per_in_ler_id
          ;
        exit when c_choice%notfound;
        l_person_enrolled:=person_enrolled_in_choice(
         p_person_id                        => p_person_id,
         p_epe_rec                          => l_epe,
         p_old_result_id                    => p_prtt_enrt_rslt_id,
         p_effective_date                   => p_effective_date
          );
        if (not l_person_enrolled) then
           --
           open c_enrt_rt (l_epe.elig_per_elctbl_chc_id);
           fetch c_enrt_rt into l_enrt_rt;
           /*  bug#3365290
           if c_enrt_rt%notfound
                then
    -- error
               hr_utility.set_location('BEN_91724_NO_FLX_CR_RT_FOUND', 51);
               fnd_message.set_name('BEN','BEN_91724_NO_FLX_CR_RT_FOUND');
               fnd_message.set_token('PROC',l_proc);
               close c_enrt_rt;
               fnd_message.raise_error;
           end if;
           close c_enrt_rt;
           if l_enrt_rt.acty_base_rt_id is null then
              hr_utility.set_location('BEN_91725_NO_FLX_CR_ABR_FOUND', 52);
              fnd_message.set_name('BEN','BEN_91725_NO_FLX_CR_ABR_FOUND');
              fnd_message.set_token('PROC',l_proc);
              fnd_message.raise_error;
           end if;
           --
           */
           close c_enrt_rt;
            --

           open c_bnft_prvdd_ldgr_2 (l_enrt_rt.acty_base_rt_id);
           fetch c_bnft_prvdd_ldgr_2 into l_bnft_prvdd_ldgr_id,l_object_version_number,l_bpl_esd;
           hr_utility.set_location('ldgr id provided is'||l_bnft_prvdd_ldgr_id, 52);
           if c_bnft_prvdd_ldgr_2%found then
              --
              -- Bug 5500864
              if p_effective_date = l_bpl_esd
              then
                l_datetrack_mode := hr_api.g_zap;
		l_effective_date := l_bpl_esd ;
              else
                l_datetrack_mode := hr_api.g_delete;
		l_effective_date := p_effective_date - 1 ;
              end if;
              --
              ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
                p_bnft_prvdd_ldgr_id      => l_bnft_prvdd_ldgr_id,
                p_effective_start_date    => l_effective_start_date,
                p_effective_end_date      => l_effective_end_date,
                p_object_version_number   => l_object_version_number,
                p_effective_date          => l_effective_date,
                p_datetrack_mode          => l_datetrack_mode,
                p_business_group_id       => p_business_group_id
               );
           end if;
           close c_bnft_prvdd_ldgr_2;
        end if;
      end loop;
      --
      close c_choice; -- Bug 6834215
    end if;
  close c_ledger;
  --

  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
end cleanup_invalid_ledger_entries;
--------------------------------------------------------------------------------
--                      cleanup_invalid_ledger_entries
--------------------------------------------------------------------------------
-- OVER LOADED PROCEDURE!!
--
procedure cleanup_invalid_ledger_entries(  -- so few args because uses global table
        p_validate             in boolean default false,
        p_person_id            in number,
        p_per_in_ler_id        in number,
        p_effective_date       in date,
        p_business_group_id    in number
) is
  l_proc varchar2(72) := g_package||'.cleanup_invalid_ledger_entries';
  l_epe ben_epe_shd.g_rec_type;
  l_rt_usg_cd        varchar2(30);
  l_bnft_prvdd_ldgr_id number;
  l_person_enrolled boolean;
  l_effective_start_date date;
  l_effective_end_date date;
  l_object_version_number number;
  --
  -- this cursor needs some explaination
  --   It get the set of choices which have ledger entries - (for entire person)
  --   The first half of the query gets the choices and the abr to join to ledger
  --   The second half makes sure the ledger belongs to the correct person
  --   This is weird because the result id on the ledger is not the one which caused
  --   the ledger entry to be written.  jcarpent
  --
  cursor c_ledger is
    select distinct
                epe.bnft_prvdr_pool_id,
                epe.elig_per_elctbl_chc_id,
                epe.prtt_enrt_rslt_id,
                epe.pgm_id,
                epe.ptip_id,
                epe.plip_id,
                epe.pl_id,
                epe.oipl_id,
                epe.cmbn_ptip_id,
                epe.cmbn_ptip_opt_id,
                epe.business_group_id,
                bpl.bnft_prvdd_ldgr_id,
                bpl.object_version_number,
                decode(enb.enrt_bnft_id,null,
                ecr2.rt_usg_cd,ecr1.rt_usg_cd) rt_usg_cd
    from        ben_elig_per_elctbl_chc epe,
                ben_per_in_ler pil,
                ben_enrt_rt ecr1,
                ben_enrt_rt ecr2,
                ben_enrt_bnft enb,
                ben_bnft_prvdd_ldgr_f bpl,
                ben_elig_per_elctbl_chc epe_flex,
                ben_per_in_ler pil_flex,
                ben_per_in_ler pil_flex1
    where       pil.per_in_ler_id = p_per_in_ler_id and
                pil.business_group_id=p_business_group_id and
                epe.bnft_prvdr_pool_id is not null and
                pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil.per_in_ler_id=epe.per_in_ler_id and
                epe.business_group_id=p_business_group_id and
                epe.elig_per_elctbl_chc_id=ecr2.elig_per_elctbl_chc_id(+) and
                (ecr1.acty_base_rt_id=bpl.acty_base_rt_id
                 or ecr2.acty_base_rt_id=bpl.acty_base_rt_id) and
                epe.elig_per_elctbl_chc_id=enb.elig_per_elctbl_chc_id(+) and
                enb.enrt_bnft_id = ecr1.enrt_bnft_id(+) and
                bpl.business_group_id=p_business_group_id and
                p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date and
--              bpl.cash_recd_val is null and
                bpl.prtt_enrt_rslt_id=epe_flex.prtt_enrt_rslt_id and
                epe_flex.business_group_id=p_business_group_id and
                epe_flex.per_in_ler_id=pil_flex.per_in_ler_id and
                pil_flex.business_group_id=p_business_group_id and
                -- Bug 1634870
                pil_flex1.per_in_ler_id=bpl.per_in_ler_id and
                pil_flex1.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex1.business_group_id=p_business_group_id and
                pil_flex.person_id=p_person_id
    ;

begin

  hr_utility.set_location('Entering:'|| l_proc, 15);

  open c_ledger;

  loop
    fetch c_ledger into
        l_epe.bnft_prvdr_pool_id,
        l_epe.elig_per_elctbl_chc_id,
        l_epe.prtt_enrt_rslt_id,
        l_epe.pgm_id,
        l_epe.ptip_id,
        l_epe.plip_id,
        l_epe.pl_id,
        l_epe.oipl_id,
        l_epe.cmbn_ptip_id,
        l_epe.cmbn_ptip_opt_id,
        l_epe.business_group_id,
        l_bnft_prvdd_ldgr_id,
        l_object_version_number,
        l_rt_usg_cd
    ;
    hr_utility.set_location(l_proc, 20);

    exit when c_ledger%notfound;

    hr_utility.set_location(l_proc, 30);

    l_person_enrolled:=person_enrolled_in_choice(
        p_person_id                     => p_person_id,
        p_epe_rec                       => l_epe,
        p_effective_date                => p_effective_date
    );
    hr_utility.set_location(l_proc, 40);
    --
    -- if the person is not enrolled or
    -- rt_usg_cd<>'FLXCR' and not directly enrolled
    -- then remove the ledger entry
    --
    if ((not l_person_enrolled) or
        (nvl(l_rt_usg_cd,hr_api.g_varchar2)<>'FLXCR' and
         l_epe.prtt_enrt_rslt_id is null)) then
      hr_utility.set_location('Deleting ledger='||to_char(l_bnft_prvdd_ldgr_id), 50);
      ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
        p_bnft_prvdd_ldgr_id            => l_bnft_prvdd_ldgr_id,
        p_effective_start_date          => l_effective_start_date,
        p_effective_end_date            => l_effective_end_date,
        p_object_version_number         => l_object_version_number,
        p_effective_date                => p_effective_date,
        p_datetrack_mode                => hr_api.g_zap,
        p_business_group_id             => p_business_group_id
      );
      hr_utility.set_location(l_proc, 60);
    end if;
    hr_utility.set_location(l_proc, 70);
  end loop;
  close c_ledger;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 998);
  --
end cleanup_invalid_ledger_entries;
--------------------------------------------------------------------------------
--                      create_flex_credit_enrolment
--------------------------------------------------------------------------------
procedure create_flex_credit_enrolment
  (p_validate           in     boolean default false
  ,p_person_id          in     number
  ,p_enrt_mthd_cd               in     varchar2
  ,p_business_group_id          in     number
  ,p_effective_date             in     date
  ,p_prtt_enrt_rslt_id             out nocopy number
  ,p_prtt_rt_val_id                out nocopy number
  ,p_per_in_ler_id              in     number
  ,p_rt_val                     in     number
  ,p_net_credit_val             in     number default null
  ,p_pgm_id                     in     number default null
  )
is
  l_proc varchar2(72) := g_package||'.create_flex_credit_enrolment';
  l_acty_typ_cd            ben_acty_base_rt_f.acty_typ_cd%type;
  l_prnt_prtt_rt_val_id    ben_prtt_rt_val.prtt_rt_val_id%type;
  l_prnt_enrt_rt_id        ben_enrt_rt.enrt_rt_id%type;
  l_prnt_acty_base_rt_id   ben_acty_base_rt_f.acty_base_rt_id%type;
  l_child_prtt_rt_val_id   ben_prtt_rt_val.prtt_rt_val_id%type;
  l_child_enrt_rt_id       ben_enrt_rt.enrt_rt_id%type;
  l_child_acty_base_rt_id  ben_acty_base_rt_f.acty_base_rt_id%type;
  l_prnt_rt_val            number := 0;
  l_child_rt_val           number := 0;
  l_dummy_num              number;
  l_dummy_varchar2         varchar2(80);
  l_dummy_date             date;
  l_prtt_rt_val_id number;
  l_suspend_flag varchar2(30);
  l_prtt_enrt_interim_id number;
  l_dpnt_actn_warning boolean;
  l_bnf_actn_warning  boolean;
  l_ctfn_actn_warning boolean;
  l_effective_start_date date;
  l_effective_end_date date;
  l_good_prtt_rt_val_id number;
  l_enrt_rt_id number;

  cursor c_flex_credit_choice is
            select      elig_per_elctbl_chc_id,
                        epe.prtt_enrt_rslt_id,
                        per.object_version_number,
                        pil.per_in_ler_id,
                        epe.pgm_id,
                        epe.pl_id,
                        per.enrt_cvg_strt_dt,
                        per.per_in_ler_id chc_pen_id
            from        ben_elig_per_elctbl_chc epe,
                        ben_per_in_ler pil,
                        ben_prtt_enrt_rslt_f per
            where       epe.comp_lvl_cd = 'PLANFC' and
                        epe.per_in_ler_id = p_per_in_ler_id and
                        per.prtt_enrt_rslt_stat_cd is null and
                        epe.business_group_id=p_business_group_id and
                        epe.per_in_ler_id=pil.per_in_ler_id and
                        pil.business_group_id=p_business_group_id and
                        pil.person_id=p_person_id and
                        pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                        per.prtt_enrt_rslt_id(+)=epe.prtt_enrt_rslt_id and
                        (p_pgm_id is null or p_pgm_id = epe.pgm_id) and
                        p_effective_date between per.effective_start_date(+) and
                                        per.effective_end_date(+) ;
  l_flex_credit_choice c_flex_credit_choice%rowtype;
  --
  cursor c_enrt_rt_flex is
    select       ecr.prtt_rt_val_id,
                 ecr.enrt_rt_id
    from         ben_enrt_rt ecr,
                 ben_acty_base_rt_f abr
    where        ecr.elig_per_elctbl_chc_id=
                           l_flex_credit_choice.elig_per_elctbl_chc_id
    and          ecr.business_group_id=p_business_group_id
    and          ecr.acty_typ_cd not in ('NCRDSTR','NCRUDED')
    and          abr.parnt_acty_base_rt_id is null
    and          ecr.acty_base_rt_id = abr.acty_base_rt_id
    and          ecr.business_group_id = abr.business_group_id
    and          p_effective_date between abr.effective_start_date
                 and abr.effective_end_date;
  --
  cursor c_net_credits_rate(p_acty_typ_cd in varchar2) is
    select  ecr.prtt_rt_val_id
           ,ecr.enrt_rt_id
           ,ecr.acty_base_rt_id
    from  ben_enrt_rt ecr
    where ecr.elig_per_elctbl_chc_id=
            l_flex_credit_choice.elig_per_elctbl_chc_id
    and   ecr.acty_typ_cd = p_acty_typ_cd
    and   ecr.business_group_id=p_business_group_id;
  --
  cursor c_net_credits_child(p_acty_base_rt_id in number) is
    select ecr.prtt_rt_val_id
          ,ecr.enrt_rt_id
          ,ecr.acty_base_rt_id
    from  ben_enrt_rt ecr
         ,ben_acty_base_rt_f abr
    where ecr.elig_per_elctbl_chc_id=
            l_flex_credit_choice.elig_per_elctbl_chc_id
    and   ecr.acty_base_rt_id = abr.acty_base_rt_id
    and   abr.parnt_acty_base_rt_id = p_acty_base_rt_id
    and   ecr.business_group_id=p_business_group_id
    and   abr.business_group_id = ecr.business_group_id
    and   p_effective_date between
          abr.effective_start_date and abr.effective_end_date;
  -- bug 2988218
  cursor c_pgm_type is
    select pgm_typ_cd
    from ben_pgm_f
    where pgm_id = p_pgm_id
    and business_group_id = p_business_group_id
    and p_effective_date between
        effective_start_date and effective_end_date;

    l_pgm_type  varchar2(30);
  -- end 2988218
  l_net_credits_rate       c_net_credits_rate%rowtype;
  l_net_credits_child      c_net_credits_child%rowtype;
  l_acty_typ_cd2          varchar2(300);
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- 2988218 chk if its a flex pgm
  open c_pgm_type;
  fetch c_pgm_type into l_pgm_type;
  close c_pgm_type;

  if (l_pgm_type in ( 'FLEX', 'FPC', 'COBRAFLX') ) then
  -- end 2988218

    -- find the choice to use
    open c_flex_credit_choice;
    fetch c_flex_credit_choice into l_flex_credit_choice;
    --
    if (c_flex_credit_choice%notfound and
        nvl(p_rt_val,hr_api.g_number) <> hr_api.g_number ) then  --Bug 3864152
        hr_utility.set_location('BEN_91726_NO_FLX_CR_CHOICE', 20);
        fnd_message.set_name('BEN','BEN_91726_NO_FLX_CR_CHOICE');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID', to_char(p_person_id));
        fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
        fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
        fnd_message.set_token('BG_ID',to_char(p_business_group_id));
        close c_flex_credit_choice;
        fnd_message.raise_error;
    else
    --
    if l_flex_credit_choice.enrt_cvg_strt_dt > p_effective_date
     and l_flex_credit_choice.chc_pen_id <> p_per_in_ler_id then
      -- Choice created by prevoius LE, coverage starting in future,
      -- hav to back it out and create new one. Bug 4964766
      l_flex_credit_choice.prtt_enrt_rslt_id := null;
      --
    end if;
    --
      p_prtt_enrt_rslt_id := l_flex_credit_choice.prtt_enrt_rslt_id;
    --
    end if;
    close c_flex_credit_choice;
    --
  end if;  -- pgm_type is flx or fpc
  -- if a rt_val is passed in then a prv will be created also
  if p_rt_val is not null then
     open c_enrt_rt_flex;
     fetch c_enrt_rt_flex into
        l_good_prtt_rt_val_id,
        l_enrt_rt_id
      ;
     close c_enrt_rt_flex;
  end if;
    --
  if p_net_credit_val is not null then
    --
    if p_net_credit_val > 0 then
      --
      --  Get the enrollment rate with an activity type code of net credit
      --  distribution(NCRDSTR) and associated child rate.
      --
      l_acty_typ_cd := 'NCRDSTR';
      l_acty_typ_cd2 := 'NCRUDED';
    else
      l_acty_typ_cd := 'NCRUDED';
      l_acty_typ_cd2 := 'NCRDSTR';
    end if;
    hr_utility.set_location('l_acty_typ_cd:'|| l_acty_typ_cd, 10);
    --
    open c_net_credits_rate(l_acty_typ_cd);
    fetch c_net_credits_rate into l_prnt_prtt_rt_val_id
                                 ,l_prnt_enrt_rt_id
                                 ,l_prnt_acty_base_rt_id;
    if c_net_credits_rate%notfound then
      hr_utility.set_location('not found:'|| l_acty_typ_cd, 10);
      close c_net_credits_rate;
      fnd_message.set_name('BEN','BEN_92622_NET_CRED_RT_NOT_FND');
      fnd_message.raise_error;
    else
      close c_net_credits_rate;
    end if;
    --
    --  Child rate.
    --
    open c_net_credits_child(l_prnt_acty_base_rt_id);
    fetch c_net_credits_child into l_child_prtt_rt_val_id
                                  ,l_child_enrt_rt_id
                                  ,l_child_acty_base_rt_id;
    --
    if c_net_credits_child%notfound then
      close c_net_credits_child;
      fnd_message.set_name('BEN','BEN_92623_NET_CRE_CHLD_NOT_FND');
      fnd_message.raise_error;
    else
      close c_net_credits_child;
    end if;
    --
    --bug#2736036 - to pick the other rates
    open c_net_credits_rate(l_acty_typ_cd2);
    fetch c_net_credits_rate into l_net_credits_rate;
    close c_net_credits_rate;
    --
    --  Child rate.
    --
    open c_net_credits_child(l_net_credits_rate.acty_base_rt_id);
    fetch c_net_credits_child into l_net_credits_child;
    close c_net_credits_child;
    --
    -- bug#2736036
    if p_net_credit_val <> 0 then
      --
      -- Get the calculated value for the child rate.
      --
      l_prnt_rt_val := abs(p_net_credit_val);
      --
      hr_utility.set_location('l_prnt_rt_val:'|| l_prnt_rt_val, 10);
      hr_utility.set_location('l_child_rt_val:'|| l_child_rt_val, 10);
      ben_determine_activity_base_rt.main
        (p_person_id                   => p_person_id
        ,p_elig_per_elctbl_chc_id      => l_flex_credit_choice.elig_per_elctbl_chc_id
        ,p_acty_base_rt_id             => l_child_acty_base_rt_id
        ,p_effective_date              => p_effective_date
        ,p_per_in_ler_id               => p_per_in_ler_id
        ,p_calc_only_rt_val_flag       => true
        ,p_pgm_id                      => l_flex_credit_choice.pgm_id
        ,p_pl_id                       => l_flex_credit_choice.pl_id
        ,p_business_group_id           => p_business_group_id
        ,p_cal_val                     => l_prnt_rt_val
        ,p_val                         => l_child_rt_val
        ,p_mn_elcn_val                 => l_dummy_num
        ,p_mx_elcn_val                 => l_dummy_num
        ,p_ann_val                     => l_dummy_num
        ,p_ann_mn_elcn_val             => l_dummy_num
        ,p_ann_mx_elcn_val             => l_dummy_num
        ,p_cmcd_val                    => l_dummy_num
        ,p_cmcd_mn_elcn_val            => l_dummy_num
        ,p_cmcd_mx_elcn_val            => l_dummy_num
        ,p_cmcd_acty_ref_perd_cd       => l_dummy_varchar2
        ,p_incrmt_elcn_val             => l_dummy_num
        ,p_dflt_val                    => l_dummy_num
        ,p_tx_typ_cd                   => l_dummy_varchar2
        ,p_acty_typ_cd                 => l_dummy_varchar2
        ,p_nnmntry_uom                 => l_dummy_varchar2
        ,p_entr_val_at_enrt_flag       => l_dummy_varchar2
        ,p_dsply_on_enrt_flag          => l_dummy_varchar2
        ,p_use_to_calc_net_flx_cr_flag => l_dummy_varchar2
        ,p_rt_usg_cd                   => l_dummy_varchar2
        ,p_bnft_prvdr_pool_id          => l_dummy_num
        ,p_actl_prem_id                => l_dummy_num
        ,p_cvg_calc_amt_mthd_id        => l_dummy_num
        ,p_bnft_rt_typ_cd              => l_dummy_varchar2
        ,p_rt_typ_cd                   => l_dummy_varchar2
        ,p_rt_mlt_cd                   => l_dummy_varchar2
        ,p_comp_lvl_fctr_id            => l_dummy_num
        ,p_entr_ann_val_flag           => l_dummy_varchar2
        ,p_ptd_comp_lvl_fctr_id        => l_dummy_num
        ,p_clm_comp_lvl_fctr_id        => l_dummy_num
        ,p_ann_dflt_val                => l_dummy_num
        ,p_rt_strt_dt                  => l_dummy_date
        ,p_rt_strt_dt_cd               => l_dummy_varchar2
        ,p_rt_strt_dt_rl               => l_dummy_num
        ,p_prtt_rt_val_id              => l_dummy_num
        ,p_dsply_mn_elcn_val           => l_dummy_num
        ,p_dsply_mx_elcn_val           => l_dummy_num
        ,p_pp_in_yr_used_num           => l_dummy_num
        ,p_ordr_num                    => l_dummy_num
        ,p_iss_val                     => l_dummy_num
        );
        hr_utility.set_location(l_proc, 70);
        hr_utility.set_location('l_child_rt_val:'|| l_child_rt_val, 10);
    end if;
  end if;
  --
  -- call election_information api to create prtt enrt result
  --
  -- do if
  -- new record
  --   rt_val<>0 or rt_val is null
  -- change
  --   rt_val specified
  --
  if (l_flex_credit_choice.prtt_enrt_rslt_id is null and
      (p_rt_val<>0 or
       (p_rt_val is null and
        p_net_credit_val is null))) then
  begin
    hr_utility.set_location(l_proc, 70);
    if l_flex_credit_choice.elig_per_elctbl_chc_id is not null then --Bug 2645624
      ben_election_information.election_information(
        p_elig_per_elctbl_chc_id   => l_flex_credit_choice.elig_per_elctbl_chc_id,
        p_prtt_enrt_rslt_id        => l_flex_credit_choice.prtt_enrt_rslt_id,
        p_effective_date           => p_effective_date,
        p_effective_start_date     => l_effective_start_date,
        p_effective_end_date       => l_effective_end_date,
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_enrt_bnft_id             => null,
        p_bnft_val                 => null,
        p_datetrack_mode           => hr_api.g_insert,
        p_suspend_flag             => l_suspend_flag,
        p_object_version_number    => l_flex_credit_choice.object_version_number,
        p_prtt_enrt_interim_id     => l_prtt_enrt_interim_id,
        p_rt_val1                  => p_rt_val,
        p_enrt_rt_id1              => l_enrt_rt_id,
        p_prtt_rt_val_id1          => l_good_prtt_rt_val_id,
        p_prtt_rt_val_id2          => l_prtt_rt_val_id,
        p_prtt_rt_val_id3          => l_prtt_rt_val_id,
        p_prtt_rt_val_id4          => l_prtt_rt_val_id,
        p_prtt_rt_val_id5          => l_prtt_rt_val_id,
        p_prtt_rt_val_id6          => l_prtt_rt_val_id,
        p_prtt_rt_val_id7          => l_prtt_rt_val_id,
        p_prtt_rt_val_id8          => l_prtt_rt_val_id,
        p_prtt_rt_val_id9          => l_prtt_rt_val_id,
        p_prtt_rt_val_id10         => l_prtt_rt_val_id,
        p_business_group_id        => p_business_group_id,
        p_dpnt_actn_warning        => l_dpnt_actn_warning,
        p_bnf_actn_warning         => l_bnf_actn_warning,
        p_ctfn_actn_warning        => l_ctfn_actn_warning
      );
    p_prtt_enrt_rslt_id:=l_flex_credit_choice.prtt_enrt_rslt_id;
    end if;
  end;
  elsif (l_flex_credit_choice.prtt_enrt_rslt_id is not null and
         (p_rt_val is not null
       or p_net_credit_val is not null)) then
    hr_utility.set_location(l_proc, 80);
    if p_rt_val is not null and l_flex_credit_choice.elig_per_elctbl_chc_id is not null then --Bug 2645624
      ben_election_information.election_information(
        p_elig_per_elctbl_chc_id   => l_flex_credit_choice.elig_per_elctbl_chc_id,
        p_prtt_enrt_rslt_id        => l_flex_credit_choice.prtt_enrt_rslt_id,
        p_effective_date           => p_effective_date,
        p_effective_start_date     => l_effective_start_date,
        p_effective_end_date       => l_effective_end_date,
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_enrt_bnft_id             => null,
        p_bnft_val                 => null,
        p_datetrack_mode           => hr_api.g_correction,
        p_suspend_flag             => l_suspend_flag,
        p_object_version_number    => l_flex_credit_choice.object_version_number,
        p_prtt_enrt_interim_id     => l_prtt_enrt_interim_id,
        p_rt_val1                  => p_rt_val,
        p_enrt_rt_id1              => l_enrt_rt_id,
        p_prtt_rt_val_id1          => l_good_prtt_rt_val_id,
        p_prtt_rt_val_id2          => l_prtt_rt_val_id,
        p_prtt_rt_val_id3          => l_prtt_rt_val_id,
        p_prtt_rt_val_id4          => l_prtt_rt_val_id,
        p_prtt_rt_val_id5          => l_prtt_rt_val_id,
        p_prtt_rt_val_id6          => l_prtt_rt_val_id,
        p_prtt_rt_val_id7          => l_prtt_rt_val_id,
        p_prtt_rt_val_id8          => l_prtt_rt_val_id,
        p_prtt_rt_val_id9          => l_prtt_rt_val_id,
        p_prtt_rt_val_id10         => l_prtt_rt_val_id,
        p_business_group_id        => p_business_group_id,
        p_dpnt_actn_warning        => l_dpnt_actn_warning,
        p_bnf_actn_warning         => l_bnf_actn_warning,
        p_ctfn_actn_warning        => l_ctfn_actn_warning
        );
    end if;
    --
    if (p_net_credit_val is not null and
         (p_net_credit_val <> 0 or
          (p_net_credit_val = 0
           and l_prnt_prtt_rt_val_id is not null))) then
      --
      if l_flex_credit_choice.elig_per_elctbl_chc_id is not null then --Bug 2645624
        ben_election_information.election_information(
          p_elig_per_elctbl_chc_id   => l_flex_credit_choice.elig_per_elctbl_chc_id,
          p_prtt_enrt_rslt_id        => l_flex_credit_choice.prtt_enrt_rslt_id,
          p_effective_date           => p_effective_date,
          p_effective_start_date     => l_effective_start_date,
          p_effective_end_date       => l_effective_end_date,
          p_enrt_mthd_cd             => p_enrt_mthd_cd,
          p_enrt_bnft_id             => null,
          p_bnft_val                 => null,
          p_datetrack_mode           => hr_api.g_correction,
          p_suspend_flag             => l_suspend_flag,
          p_object_version_number    => l_flex_credit_choice.object_version_number,
          p_prtt_enrt_interim_id     => l_prtt_enrt_interim_id,
          p_rt_val1                  => l_prnt_rt_val,
          p_enrt_rt_id1              => l_prnt_enrt_rt_id,
          p_prtt_rt_val_id1          => l_prnt_prtt_rt_val_id,
          p_rt_val2                  => l_child_rt_val,
          p_enrt_rt_id2              => l_child_enrt_rt_id,
          p_prtt_rt_val_id2          => l_child_prtt_rt_val_id,
          p_rt_val3                  => 0,
          p_enrt_rt_id3              => l_net_credits_rate.enrt_rt_id,
          p_prtt_rt_val_id3          => l_net_credits_rate.prtt_rt_val_id,
          p_rt_val4                  => 0,
          p_enrt_rt_id4              => l_net_credits_child.enrt_rt_id,
          p_prtt_rt_val_id4          => l_net_credits_child.prtt_rt_val_id,
          p_prtt_rt_val_id5          => l_prtt_rt_val_id,
          p_prtt_rt_val_id6          => l_prtt_rt_val_id,
          p_prtt_rt_val_id7          => l_prtt_rt_val_id,
          p_prtt_rt_val_id8          => l_prtt_rt_val_id,
          p_prtt_rt_val_id9          => l_prtt_rt_val_id,
          p_prtt_rt_val_id10         => l_prtt_rt_val_id,
          p_business_group_id        => p_business_group_id,
          p_dpnt_actn_warning        => l_dpnt_actn_warning,
          p_bnf_actn_warning         => l_bnf_actn_warning,
          p_ctfn_actn_warning        => l_ctfn_actn_warning
          );
        p_prtt_enrt_rslt_id:=l_flex_credit_choice.prtt_enrt_rslt_id;
      end if;
    end if;
   end if;
    -- store the created id in the global
    g_credit_pool_result_id:=l_flex_credit_choice.prtt_enrt_rslt_id;
    g_credit_pool_person_id:=p_person_id;

  hr_utility.set_location(' Leaving:'||l_proc, 999);

end create_flex_credit_enrolment;
--
--------------------------------------------------------------------------------
--                      remove_bnft_prvdd_ldgr
--------------------------------------------------------------------------------
procedure remove_bnft_prvdd_ldgr(
        p_prtt_enrt_rslt_id        in number,
        p_effective_date           in date,
        p_business_group_id        in number,
        p_validate                 in boolean,
        p_datetrack_mode           in varchar2
) is

  l_proc varchar2(72) := g_package||'.remove_bnft_prvdd_ldgr';
  l_person_id number;

  cursor c_result is
    select person_id
    from   ben_prtt_enrt_rslt_f res
    where  res.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
           --res.prtt_enrt_rslt_stat_cd is null and
           p_effective_date between
             res.effective_start_date and res.effective_end_date and
           p_business_group_id=res.business_group_id ;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --  get the flex result from the ledger row(s)
  --  so don't have to do it first.
  --
  --  remove all debit ledger entries for this result
  --  remove all credit ledger entries for this result where
  --  the comp object is the last one which justifies the credit.
  --
  open c_result;
  fetch c_result into
        l_person_id
  ;
  close c_result;

  cleanup_invalid_ledger_entries(
        p_person_id                        => l_person_id,
        p_prtt_enrt_rslt_id                => p_prtt_enrt_rslt_id,
        p_effective_date                   => p_effective_date,
        p_business_group_id                => p_business_group_id

  );
  --
  --  Don't update the flex credit row if necessary done in total_pools
  --
  hr_utility.set_location('Leaving:'||l_proc, 999);
  --
end remove_bnft_prvdd_ldgr;
--------------------------------------------------------------------------------
--                      forfeit_credits
--------------------------------------------------------------------------------
procedure forfeit_credits
  (p_calculate_only_mode in     boolean default false
  ,p_validate            in     boolean default false
  ,p_prtt_enrt_rslt_id   in     number
  ,p_bnft_prvdr_pool_id  in     number
  ,p_acty_base_rt_id     in     number
  ,p_person_id           in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_per_in_ler_id       in     number
  ,p_prvdd_val           in     number
  ,p_rlld_up_val         in     number
  ,p_used_val            in     number
  ,p_rollover_val        in     number
  ,p_cash_val            in     number
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  ,p_frftd_val              out nocopy number
  )
is
  l_proc varchar2(72) := g_package||'.forfeit_credits';
  l_balance number;
  l_bnft_prvdd_ldgr_id number;
  l_effective_start_date date;
  l_effective_end_date date;
  l_object_version_number number;
  l_datetrack_mode varchar2(30);
  l_frftd_val number;
  l_cash_recd_val number;
  l_balance_for_cr number;
  --
  cursor c_forfeit is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.frftd_val,
           bpl.object_version_number,
           bpl.effective_start_date
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler pil
    where  bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id
      and  bpl.business_group_id=p_business_group_id
      and  bpl.acty_base_rt_id = p_acty_base_rt_id
      and  bpl.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
      and  bpl.frftd_val is not null
      and  p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
      and pil.per_in_ler_id=bpl.per_in_ler_id
      and pil.business_group_id=bpl.business_group_id
      and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  -- Bug 2645993
  --
  cursor c_cash_rcvd is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.cash_recd_val,
           bpl.object_version_number,
           bpl.effective_start_date
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler pil
    where  bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id
      and  bpl.business_group_id=p_business_group_id
      -- and  bpl.acty_base_rt_id = p_acty_base_rt_id      /* Bug No 4714939 */
      and  bpl.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
      and  bpl.cash_recd_val is not null
      and  p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
      and pil.per_in_ler_id=bpl.per_in_ler_id
      and pil.business_group_id=bpl.business_group_id
      and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_balance:=nvl(p_prvdd_val,0)
        +nvl(p_rlld_up_val,0)
        -nvl(p_used_val,0)
        -nvl(p_rollover_val,0)
        -nvl(p_cash_val,0);
  --
  l_balance_for_cr := l_balance ;
  --
  hr_utility.set_location('balance='||to_char(l_balance),15);
  open c_forfeit;
  fetch c_forfeit into
        l_bnft_prvdd_ldgr_id,
        l_frftd_val,
        l_object_version_number,
        l_effective_start_date;
  if c_forfeit%found then
    if l_balance<0 then
      hr_utility.set_location(l_proc, 16);
      l_balance:=0;
    end if;
  end if;
  --
  p_frftd_val:=l_balance;
  --
  hr_utility.set_location('frftd_val='||to_char(l_frftd_val),17);
  hr_utility.set_location('l_balance='||to_char(l_balance),17);
  --
  if l_frftd_val<>l_balance then
    hr_utility.set_location(l_proc, 18);
    --
    -- update ledger row
    --
    /*
    if l_effective_start_date=p_effective_date then
      l_datetrack_mode:=hr_api.g_correction;
    else
      l_datetrack_mode:=hr_api.g_update;
    end if;
    */
    Get_DT_Upd_Mode
       (p_effective_date        => p_effective_date,
        p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
        p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
        p_base_key_value        => l_bnft_prvdd_ldgr_id,
        p_mode                  => l_datetrack_mode);
    hr_utility.set_location('UPDATING LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),20);
    ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date         => l_effective_start_date
                  ,p_effective_end_date           => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag    => 'N'
                  ,p_frftd_val                    => l_balance
                  ,p_prvdd_val                    => null
                  ,p_used_val                     => null
                  ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id              => p_acty_base_rt_id
                  ,p_per_in_ler_id                => p_per_in_ler_id
                  ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
                  ,p_business_group_id            => p_business_group_id
                  ,p_object_version_number        => l_object_version_number
                  ,p_cash_recd_val                => null
                  ,p_effective_date               => p_effective_date
                  ,p_datetrack_mode               => l_datetrack_mode
    );
    hr_utility.set_location('UPDATED LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),30);
  else
    if l_balance>0 and l_frftd_val is null then
      --
      -- create a forfeit row
      --
      hr_utility.set_location('result_id='||to_char(p_prtt_enrt_rslt_id),35);
      ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id          => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date        => l_effective_start_date
                  ,p_effective_end_date          => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag   => 'N'
                  ,p_frftd_val                   => l_balance
                  ,p_prvdd_val                   => null
                  ,p_used_val                    => null
                  ,p_bnft_prvdr_pool_id          => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id             => p_acty_base_rt_id
                  ,p_person_id                   => p_person_id
                  ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
                  ,p_per_in_ler_id               => p_per_in_ler_id
                  ,p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id
                  ,p_business_group_id           => p_business_group_id
                  ,p_object_version_number       => l_object_version_number
                  ,p_cash_recd_val               => null
                  ,p_effective_date              => p_effective_date
      );
    end if ;
  end if;
    --
  -- Bug 2645993
  hr_utility.set_location('CREATED LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),40);
  if l_balance_for_cr < 0 then
      --
      hr_utility.set_location('More Used than Provided case '||l_balance_for_cr ,30);
      open c_cash_rcvd;
      fetch c_cash_rcvd into
        l_bnft_prvdd_ldgr_id,
        l_cash_recd_val,
        l_object_version_number,
        l_effective_start_date;
      --
      -- When Used Value is more than the forefeited value
      hr_utility.set_location(' l_cash_recd_val '||l_cash_recd_val,31);
      if l_cash_recd_val is not null then
        --
        --if l_cash_recd_val > 0 then
        --  l_balance := l_cash_recd_val + l_balance ;
        --end if;
        --
        Get_DT_Upd_Mode
        (p_effective_date        => p_effective_date,
         p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
         p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
         p_base_key_value        => l_bnft_prvdd_ldgr_id,
         p_mode                  => l_datetrack_mode);
        hr_utility.set_location('l_cash_recd_val is not null '||to_char(l_bnft_prvdd_ldgr_id),20);
        ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date         => l_effective_start_date
                  ,p_effective_end_date           => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag    => 'N'
                  ,p_frftd_val                    => null -- l_balance
                  ,p_prvdd_val                    => null
                  ,p_used_val                     => null
                  ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id              => p_acty_base_rt_id
                  ,p_per_in_ler_id                => p_per_in_ler_id
                  ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
                  ,p_business_group_id            => p_business_group_id
                  ,p_object_version_number        => l_object_version_number
                  ,p_cash_recd_val                => l_balance_for_cr
                  ,p_effective_date               => p_effective_date
                  ,p_datetrack_mode               => l_datetrack_mode
        );
      --
      else
        hr_utility.set_location('CR NULL ='||to_char(p_prtt_enrt_rslt_id),35);
        ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id          => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date        => l_effective_start_date
                  ,p_effective_end_date          => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag   => 'N'
                  ,p_frftd_val                   => null -- l_balance
                  ,p_prvdd_val                   => null
                  ,p_used_val                    => null
                  ,p_bnft_prvdr_pool_id          => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id             => p_acty_base_rt_id
                  ,p_person_id                   => p_person_id
                  ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
                  ,p_per_in_ler_id               => p_per_in_ler_id
                  ,p_prtt_enrt_rslt_id           => p_prtt_enrt_rslt_id
                  ,p_business_group_id           => p_business_group_id
                  ,p_object_version_number       => l_object_version_number
                  ,p_cash_recd_val               => l_balance_for_cr -- null
                  ,p_effective_date              => p_effective_date
        );
        --
      end if;
      close c_cash_rcvd;
      p_frftd_val := 0 ;
      --
      --Bug 9388229
  ----If Provided is more than used value and cash received value is still -ve,then rest it to zero.
  else
    if l_balance_for_cr >= 0 then
       hr_utility.set_location('Provided more than used case' ,30.1);
      open c_cash_rcvd;
      fetch c_cash_rcvd into
        l_bnft_prvdd_ldgr_id,
        l_cash_recd_val,
        l_object_version_number,
        l_effective_start_date;
      --
      -- When provided is more than used and cash received value is found then reset it.
      hr_utility.set_location(' l_cash_recd_val '||l_cash_recd_val,31.1);
      if l_cash_recd_val is not null and l_cash_recd_val < 0 then
        --
        Get_DT_Upd_Mode
        (p_effective_date        => p_effective_date,
         p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
         p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
         p_base_key_value        => l_bnft_prvdd_ldgr_id,
         p_mode                  => l_datetrack_mode);
        hr_utility.set_location('l_cash_recd_val is not null '||to_char(l_bnft_prvdd_ldgr_id),20.1);
        ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date         => l_effective_start_date
                  ,p_effective_end_date           => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag    => 'N'
                  ,p_frftd_val                    => null -- l_balance
                  ,p_prvdd_val                    => null
                  ,p_used_val                     => null
                  ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id              => p_acty_base_rt_id
                  ,p_per_in_ler_id                => p_per_in_ler_id
                  ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
                  ,p_business_group_id            => p_business_group_id
                  ,p_object_version_number        => l_object_version_number
                  ,p_cash_recd_val                => 0
                  ,p_effective_date               => p_effective_date
                  ,p_datetrack_mode               => l_datetrack_mode
        );
	end if;
      close c_cash_rcvd;
     end if;
     --Bug 9388229
  end if;
  close c_forfeit;
  -- p_frftd_val:=l_balance;
  hr_utility.set_location('Leaving:'||l_proc||' p_frftd_val '||p_frftd_val , 999);

end forfeit_credits;
--------------------------------------------------------------------------------
--                      distribute_credits
--------------------------------------------------------------------------------
procedure distribute_credits
  (p_calculate_only_mode  in     boolean default false
  ,p_validate             in     boolean default false
  ,p_prtt_enrt_rslt_id    in     number
  ,p_bnft_prvdr_pool_id   in     number
  ,p_acty_base_rt_id      in     number
  ,p_per_in_ler_id        in     number
  ,p_dflt_excs_trtmt_cd   in     varchar2
  ,p_prvdd_val            in     number
  ,p_rlld_up_val          in     number
  ,p_used_val             in     number
  ,p_rollover_val         in     number
  ,p_cash_recd_total      in     number
  ,p_val_rndg_cd          in     varchar2
  ,p_val_rndg_rl          in     number
  ,p_pct_rndg_cd          in     varchar2
  ,p_pct_rndg_rl          in     number
  ,p_mn_dstrbl_val        in     number
  ,p_mn_dstrbl_pct_num    in     number
  ,p_mx_dstrbl_val        in     number
  ,p_mx_pct               in     number
  ,p_person_id            in     number
  ,p_enrt_mthd_cd         in     varchar2
  ,p_effective_date       in     date
  ,p_business_group_id    in     number
  ,p_process_enrt_flag    in     varchar2 default 'Y'
  --
  ,p_dstrbtd_val             out nocopy number
  ,p_bpl_cash_recd_val       out nocopy number
  ,p_bnft_prvdd_ldgr_id      out nocopy number
  )
is

  l_proc varchar2(72) := g_package||'.distribute_credits';
  l_balance               number;
  l_mn_dstrbl_val         number;
  l_mx_dstrbl_val         number;
  l_cash_val              number;
  L_ACTY_BASE_RT_ID       number;
  l_bnft_prvdd_ldgr_id    number;
  l_prtt_rt_val_id        number;
  l_old_cash_val          number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_datetrack_mode        varchar2(30);
  l_prtt_enrt_rslt_id     number;
  l_object_version_number number;
  l_pgm_id                number;

  cursor c_cash_abr is
    select      bpl.acty_base_rt_id
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_per_in_ler pil,
                ben_acty_base_rt_f abr          -- Bug 4613270
    where       bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id
        and     bpl.business_group_id=p_business_group_id
        and     bpl.prtt_enrt_rslt_id=g_credit_pool_result_id
        and     p_effective_date between
                  bpl.effective_start_date and bpl.effective_end_date
        and pil.per_in_ler_id=bpl.per_in_ler_id
        and pil.business_group_id=bpl.business_group_id
        and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        /* Bug 4613270 */
        and bpl.acty_base_rt_id = abr.acty_base_rt_id
        and abr.rt_usg_cd = 'FLXCR' and p_effective_date between
            abr.effective_start_date and abr.effective_end_date;
  --
  -- Bug 5447507
  CURSOR c_cash_abr_from_epe
  IS
     SELECT ecr.acty_base_rt_id
       FROM ben_per_in_ler pil,
            ben_elig_per_elctbl_chc epe,
            ben_enrt_rt ecr
      WHERE pil.person_id = p_person_id
        AND pil.business_group_id = p_business_group_id
        AND pil.per_in_ler_stat_cd NOT IN ('VOIDD', 'BCKDT')
        AND epe.per_in_ler_id = pil.per_in_ler_id
        AND epe.business_group_id = p_business_group_id
        AND epe.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
        AND ecr.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
        AND ecr.rt_usg_cd = 'FLXCR'
        AND ecr.business_group_id = p_business_group_id
   ORDER BY pil.per_in_ler_stat_Cd desc;
  -- Bug 5447507
  --
  cursor c_old_ledger
    (c_bnft_prvdr_pool_id in number
    ,c_prtt_enrt_rslt_id  in number
    ,c_effective_date     in date
    )
  is
    select bpl.bnft_prvdd_ldgr_id,
           bpl.cash_recd_val,
           bpl.object_version_number,
           bpl.effective_start_date
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler pil
    where  bpl.bnft_prvdr_pool_id = c_bnft_prvdr_pool_id
      and  bpl.prtt_enrt_rslt_id  = c_prtt_enrt_rslt_id
      and  bpl.cash_recd_val is not null
      and  c_effective_date
        between bpl.effective_start_date and bpl.effective_end_date
      and  pil.per_in_ler_id = bpl.per_in_ler_id
      and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
  --
  cursor c_bnft_pool is
    select bpp.pgm_id
    from   ben_bnft_prvdr_pool_f bpp
    where  bpp.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
    and    p_effective_date between bpp.effective_start_date
           and bpp.effective_end_date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_prvdd_val:'||to_char(p_prvdd_val)||
     'p_rlld_up_val:'||to_char(p_rlld_up_val),11);
  hr_utility.set_location('p_used_val:'||to_char(p_used_val),12);
  hr_utility.set_location('p_rollover_val:'||to_char(p_rollover_val),13);
  --
  -- balance used depends on dflt_excs_trtmt_cd
  --
  if p_dflt_excs_trtmt_cd in ('DSTRBT_ALL','DSTRBT_RLOVR_FRFT') then
    hr_utility.set_location(l_proc,20 );
    l_balance:=p_prvdd_val+p_rlld_up_val-p_used_val;
  elsif p_dflt_excs_trtmt_cd = 'RLOVR_DSTRBT_FRFT' then
    hr_utility.set_location(l_proc,30 );
    l_balance:=p_prvdd_val+p_rlld_up_val-p_used_val-p_rollover_val;
  else
    hr_utility.set_location(l_proc,40 );
    fnd_message.set_name('BEN','BEN_DFLT_TRTMT_NOT_HNDLD');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('DFLT_EXCS_TRTMT_CD',p_dflt_excs_trtmt_cd);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,50 );
  --
  -- balance is rounded
  --
  l_acty_base_rt_id := p_acty_base_rt_id;
  --
  hr_utility.set_location('['||p_val_rndg_cd||']',55);
  if p_val_rndg_cd is not null then
    l_balance:=benutils.do_rounding(
        p_rounding_cd    => p_val_rndg_cd,
        p_rounding_rl    => p_val_rndg_rl,
        p_value          => l_balance,
        p_effective_date => p_effective_date);
  end if;
  hr_utility.set_location(l_proc,60 );
  --
  -- if the rounded balance is less than the minimum val or pct, then nothing to do
  --
  -- do min val first
  --
  if p_mn_dstrbl_val is not null then
     if p_mn_dstrbl_val > l_balance then
       hr_utility.set_location('Leaving with zero distributed:'||l_proc,97);
       p_dstrbtd_val:=0;
       return;
     end if;
  end if;
  hr_utility.set_location(l_proc,80 );
  --
  -- do min pct second
  --
  if p_mn_dstrbl_pct_num is not null then
    hr_utility.set_location(l_proc,90 );
    l_mn_dstrbl_val:=(p_mn_dstrbl_pct_num/100)*(p_prvdd_val+p_rlld_up_val-p_used_val);
    if p_pct_rndg_cd is not null then
      l_mn_dstrbl_val:=benutils.do_rounding(
        p_rounding_cd    => p_pct_rndg_cd,
        p_rounding_rl    => p_pct_rndg_rl,
        p_value          => l_mn_dstrbl_val,
        p_effective_date => p_effective_date);
    end if;
    if l_mn_dstrbl_val > l_balance then
      hr_utility.set_location(l_proc,100 );
      p_dstrbtd_val:=0;
      return;
    end if;
    hr_utility.set_location(l_proc,110 );
  end if;
  hr_utility.set_location(l_proc,120 );
  --
  -- if the rounded balance is more than the maximum val or pct, then reduce it to the maximum
  --
  l_cash_val:=l_balance;
  --
  -- do max val next
  --
  if p_mx_dstrbl_val is not null then
     if p_mx_dstrbl_val < l_cash_val then
       hr_utility.set_location(l_proc,130 );
       l_cash_val:=p_mx_dstrbl_val;
     end if;
  end if;
  hr_utility.set_location(l_proc,140 );
  --
  -- do max pct second
  --
  if p_mx_pct is not null then
    hr_utility.set_location(l_proc,150 );
    l_mx_dstrbl_val:=(p_mx_pct/100)*(p_prvdd_val+p_rlld_up_val-p_used_val);
    if p_pct_rndg_cd is not null then
      l_mx_dstrbl_val:=benutils.do_rounding(
        p_rounding_cd    => p_pct_rndg_cd,
        p_rounding_rl    => p_pct_rndg_rl,
        p_value          => l_mx_dstrbl_val,
        p_effective_date => p_effective_date);
    end if;
    if l_mx_dstrbl_val < l_cash_val then
      hr_utility.set_location(l_proc,160 );
      l_cash_val:=l_mx_dstrbl_val;
    end if;
    hr_utility.set_location(l_proc,170 );
  end if;
  hr_utility.set_location(l_proc,180 );
  --
  -- create the cash ledger entry
  --
  p_dstrbtd_val:=l_cash_val;
  --
  if l_cash_val<>p_cash_recd_total
    and not p_calculate_only_mode
  then
  hr_utility.set_location(l_proc,190 );
  hr_utility.set_location('ACE l_cash_val = ' || l_cash_val, 9999);
  hr_utility.set_location('ACE p_cash_recd_total = ' || p_cash_recd_total, 9999);
    --
    -- get cash abr
    --
    open c_cash_abr;
    fetch c_cash_abr into l_acty_base_rt_id;
    if c_cash_abr%notfound
    then
      close c_cash_abr;
      --
      -- Bug 5447507
      -- Case : User does not enrol into a plan that provides with flex credits. So we dont have
      -- BPL row for PRVDD_VAL. But user enrols into a plan which has deductible rates. So we have
      -- BPL row with USED_VAL. So if user does not enrol into plan with flex credits or decides
      -- to enrol later, then it should not stop us from creating CASH_VAL (which would be negative in
      -- such a case). So here ACTY_BASE_RT_ID from EPE->ECR table rather than BPL table.
      --
      open c_cash_abr_from_epe;
        fetch c_cash_abr_from_epe into l_acty_base_rt_id;
        if c_cash_abr_from_epe%notfound
        then
          close c_cash_abr_from_epe;
          -- Bug 5447507
          --
          hr_utility.set_location(l_proc,200 );
          fnd_message.set_name('BEN','BEN_91724_NO_FLX_CR_RT_FOUND');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('PERSON_ID',to_char(p_person_id));
          hr_utility.set_location('BEN_91724_NO_FLX_CR_RT_FOUND', 220);
          hr_utility.set_location('pool_id='||to_char(p_bnft_prvdr_pool_id), 230);
          fnd_message.raise_error;
          --
        end if;
        --
      close c_cash_abr_from_epe;
      --
    else
      hr_utility.set_location(l_proc,205 );
      close c_cash_abr;
    end if;
    hr_utility.set_location('ACE l_acty_base_rt_id = ' || l_acty_base_rt_id, 99);
    hr_utility.set_location(l_proc,210 );
    --
    hr_utility.set_location(l_proc, 220);
    --
    if p_process_enrt_flag = 'Y'
      and not p_calculate_only_mode
    then
       --
       -- check if g_credit_pool_result_id is set
       --
       if (g_credit_pool_result_id is null or
           g_credit_pool_person_id is null or
           g_credit_pool_person_id<>p_person_id) then
         hr_utility.set_location(l_proc, 250);
         --
         open c_bnft_pool;
         fetch c_bnft_pool into l_pgm_id;
         close c_bnft_pool;
         --
         create_flex_credit_enrolment(
           p_person_id           => p_person_id,
           p_enrt_mthd_cd        => p_enrt_mthd_cd,
           p_business_group_id   => p_business_group_id,
           p_effective_date      => p_effective_date,
           p_prtt_enrt_rslt_id   => l_prtt_enrt_rslt_id,
           p_prtt_rt_val_id      => l_prtt_rt_val_id,
           p_per_in_ler_id       => p_per_in_ler_id,
           p_rt_val              => null,
           p_pgm_id              => l_pgm_id
         );
         hr_utility.set_location(l_proc, 260);
       end if;
       --
    end if;
    hr_utility.set_location(l_proc,270 );
    --
    open c_old_ledger
      (c_bnft_prvdr_pool_id => p_bnft_prvdr_pool_id
      ,c_prtt_enrt_rslt_id  => g_credit_pool_result_id
      ,c_effective_date     => p_effective_date
      );
    fetch c_old_ledger into l_bnft_prvdd_ldgr_id,
                            l_old_cash_val,
                            l_object_version_number,
                            l_effective_start_date;
    --
    -- insert cash row
    --
    hr_utility.set_location(l_proc, 280);
    if c_old_ledger%notfound
      and not p_calculate_only_mode
    then
      hr_utility.set_location('insert cash row', 290);
      ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id         => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date       => l_effective_start_date
                  ,p_effective_end_date         => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag  => 'N'
                  ,p_frftd_val                  => null
                  ,p_prvdd_val                  => null
                  ,p_used_val                   => null
                  ,p_bnft_prvdr_pool_id         => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id            => l_acty_base_rt_id
                  ,p_person_id                  => p_person_id
                  ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
                  ,p_per_in_ler_id              => p_per_in_ler_id
                  ,p_prtt_enrt_rslt_id          => g_credit_pool_result_id
                  ,p_business_group_id          => p_business_group_id
                  ,p_object_version_number      => l_object_version_number
                  ,p_cash_recd_val              => l_cash_val
                  ,p_effective_date             => p_effective_date
      );
      hr_utility.set_location('CREATED CASH LDGR ID='||to_char(l_bnft_prvdd_ldgr_id),300);
    elsif l_old_cash_val<>l_cash_val
      and not p_calculate_only_mode
    then
      hr_utility.set_location(l_proc, 310);
     /* if l_effective_start_date=p_effective_date then
        hr_utility.set_location(l_proc,320 );
        l_datetrack_mode:=hr_api.g_correction;
      else
        hr_utility.set_location(l_proc,330 );
        l_datetrack_mode:=hr_api.g_update;
      end if; */
      Get_DT_Upd_Mode
         (p_effective_date        => p_effective_date,
          p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
          p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
          p_base_key_value        => l_bnft_prvdd_ldgr_id,
          p_mode                  => l_datetrack_mode);
      hr_utility.set_location('UPDATING LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),340);
      ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                   p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
                  ,p_effective_start_date         => l_effective_start_date
                  ,p_effective_end_date           => l_effective_end_date
                  ,p_prtt_ro_of_unusd_amt_flag    => 'N'
                  ,p_frftd_val                    => null
                  ,p_prvdd_val                    => null
                  ,p_used_val                     => null
                  ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
                  ,p_acty_base_rt_id              => l_acty_base_rt_id
                  ,p_per_in_ler_id                => nvl(p_per_in_ler_id, hr_api.g_number)   /* Bug 4251187 */
                  ,p_prtt_enrt_rslt_id            => g_credit_pool_result_id
                  ,p_business_group_id            => p_business_group_id
                  ,p_object_version_number        => l_object_version_number
                  ,p_cash_recd_val                => l_cash_val
                  ,p_effective_date               => p_effective_date
                  ,p_datetrack_mode               => l_datetrack_mode
      );
      hr_utility.set_location('UPDATED LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),350);
    end if;
    hr_utility.set_location(l_proc,360 );
    close c_old_ledger;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 999);
  --
  -- Set out param
  --
  p_bpl_cash_recd_val  := l_cash_val;
  p_bnft_prvdd_ldgr_id := l_bnft_prvdd_ldgr_id;
  --
end distribute_credits;
--------------------------------------------------------------------------------
--                      default_rollovers
--------------------------------------------------------------------------------
procedure default_rollovers
  (p_calculate_only_mode  in     boolean default false
  ,p_bnft_prvdr_pool_id   in     number
  ,p_person_id            in     number
  ,p_enrt_mthd_cd         in     varchar2
  ,p_effective_date       in     date
  ,p_datetrack_mode       in     varchar2
  ,p_business_group_id    in     number
  ,p_pct_rndg_cd          in     varchar2
  ,p_pct_rndg_rl          in     number
  ,p_dflt_excs_trtmt_cd   in     varchar2
  ,p_rollover_val            out nocopy number
  ,p_per_in_ler_id        in     number
  -- Bug 2185478
  ,p_acty_base_rt_id      in     number default null
  )
is
  l_proc varchar2(72) := g_package||'.default_rollovers';

  l_datetrack_mode        varchar2(30);
  l_effective_end_date    date;
  l_object_version_number number;
  l_effective_start_date  date;
  l_prvdd_val           number;
  l_recd_val            number;
  l_used_val            number;
  l_acty_base_rt_id     number;
  l_balance             number;
  l_mn_dstrbl_pct_num   number;
  l_mx_dstrbl_pct_num   number;
  l_old_rlovr_val       number;
  l_cash_val            number;
  l_bnft_prvdd_ldgr_id  number;
  l_rld_ovr_val         number;
  l_rollover_diff_total number;
  l_qualify_flag        varchar2(30);
  l_outputs             ff_exec.outputs_t;
  l_jurisdiction_code   varchar2(30);
  l_dummy               varchar2(80);
  --
  -- Query will get the rollover information and
  --   the elctbl_chc, enrollment rate
  --   If the person is enrolled will get the result and prv.
  --
  cursor c_rollovers is
    select
        prr.mn_rlovr_pct_num,
        prr.mn_rlovr_val,
        prr.mx_rchd_dflt_ordr_num,
        prr.mx_rlovr_pct_num,
        prr.mx_rlovr_val,
        prr.pct_rlovr_incrmt_num,
        prr.pct_rndg_cd,
        prr.pct_rndg_rl,
        prr.rlovr_val_incrmt_num,
        prr.rlovr_val_rl,
        prr.val_rndg_cd,
        prr.val_rndg_rl,
        prr.acty_base_rt_id,
        epe.elig_per_elctbl_chc_id,
        ecr.enrt_rt_id,
        ecr.mn_elcn_val,
        ecr.mx_elcn_val,
        prv.rt_val,
        prv.prtt_rt_val_id,
        rslt.prtt_enrt_rslt_id,
        prr.prtt_elig_rlovr_rl,
        asg.assignment_id,
        asg.organization_id,
        loc.region_2,
        oipl.opt_id,
        epe.pl_id,
        epe.pgm_id,
        pil.ler_id,
        epe.pl_typ_id,
        epe.per_in_ler_id
    from
        ben_bnft_pool_rlovr_rqmt_f prr,
        ben_per_in_ler pil,
        ben_elig_per_elctbl_chc epe,
        ben_enrt_rt ecr,
        ben_prtt_rt_val prv,
        ben_prtt_enrt_rslt_f rslt,
        per_all_assignments_f asg,
        hr_locations_all loc,
        ben_oipl_f oipl
    where
        prr.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
        prr.business_group_id=p_business_group_id and
        p_effective_date between
                prr.effective_start_date and prr.effective_end_date and
        pil.per_in_ler_id=p_per_in_ler_id and
        pil.business_group_id=p_business_group_id and
        pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
        epe.per_in_ler_id=pil.per_in_ler_id and
        epe.elctbl_flag='Y' and
        epe.business_group_id=p_business_group_id and
        ecr.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id and
        -- Added for bug 2185478
        (p_acty_base_rt_id is null or
         prr.acty_base_rt_id = p_acty_base_rt_id) and
        ecr.acty_base_rt_id=prr.acty_base_rt_id and
        ecr.business_group_id=p_business_group_id and
        prv.prtt_rt_val_id(+)=ecr.prtt_rt_val_id and
        prv.business_group_id(+)=p_business_group_id and
        rslt.prtt_enrt_rslt_id(+)=epe.prtt_enrt_rslt_id and
        p_effective_date between
                rslt.effective_start_date(+) and rslt.effective_end_date(+) and
        rslt.business_group_id(+)=p_business_group_id and
        asg.person_id=pil.person_id and
        asg.assignment_type <> 'C'and
        asg.primary_flag='Y' and
        asg.location_id = loc.location_id(+) and
        p_effective_date between
          asg.effective_start_date and asg.effective_end_date and
        oipl.oipl_id(+)=epe.oipl_id and
        p_effective_date between
          oipl.effective_start_date(+) and oipl.effective_end_date(+) and
        oipl.business_group_id(+)=p_business_group_id
    --Bug 2185478 added the union to handle the cases of enrt_bnft
    union
    select
        prr.mn_rlovr_pct_num,
        prr.mn_rlovr_val,
        prr.mx_rchd_dflt_ordr_num,
        prr.mx_rlovr_pct_num,
        prr.mx_rlovr_val,
        prr.pct_rlovr_incrmt_num,
        prr.pct_rndg_cd,
        prr.pct_rndg_rl,
        prr.rlovr_val_incrmt_num,
        prr.rlovr_val_rl,
        prr.val_rndg_cd,
        prr.val_rndg_rl,
        prr.acty_base_rt_id,
        epe.elig_per_elctbl_chc_id,
        ecr.enrt_rt_id,
        ecr.mn_elcn_val,
        ecr.mx_elcn_val,
        prv.rt_val,
        prv.prtt_rt_val_id,
        rslt.prtt_enrt_rslt_id,
        prr.prtt_elig_rlovr_rl,
        asg.assignment_id,
        asg.organization_id,
        loc.region_2,
        oipl.opt_id,
        epe.pl_id,
        epe.pgm_id,
        pil.ler_id,
        epe.pl_typ_id,
        epe.per_in_ler_id
    from
        ben_bnft_pool_rlovr_rqmt_f prr,
        ben_per_in_ler pil,
        ben_elig_per_elctbl_chc epe,
        ben_enrt_bnft enb,
        ben_enrt_rt ecr,
        ben_prtt_rt_val prv,
        ben_prtt_enrt_rslt_f rslt,
        per_all_assignments_f asg,
        hr_locations_all loc,
        ben_oipl_f oipl
    where
        prr.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
        prr.business_group_id=p_business_group_id and
        p_effective_date between
                prr.effective_start_date and prr.effective_end_date and
        pil.per_in_ler_id=p_per_in_ler_id and
        pil.business_group_id=p_business_group_id and
        pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
        epe.per_in_ler_id=pil.per_in_ler_id and
        epe.elctbl_flag='Y' and
        epe.business_group_id=p_business_group_id and
        enb.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id and
        enb.enrt_bnft_id = ecr.enrt_bnft_id  and
        -- Added for bug 2185478
        (p_acty_base_rt_id is null or
         prr.acty_base_rt_id = p_acty_base_rt_id) and
        ecr.acty_base_rt_id=prr.acty_base_rt_id and
        ecr.business_group_id=p_business_group_id and
        prv.prtt_rt_val_id(+)=ecr.prtt_rt_val_id and
        prv.business_group_id(+)=p_business_group_id and
        rslt.prtt_enrt_rslt_id(+)=epe.prtt_enrt_rslt_id and
        p_effective_date between
                rslt.effective_start_date(+) and rslt.effective_end_date(+) and
        rslt.business_group_id(+)=p_business_group_id and
        asg.person_id=pil.person_id and
        asg.assignment_type <> 'C'and
        asg.primary_flag='Y' and
        asg.location_id = loc.location_id(+) and
        p_effective_date between
          asg.effective_start_date and asg.effective_end_date and
        oipl.oipl_id(+)=epe.oipl_id and
        p_effective_date between
          oipl.effective_start_date(+) and oipl.effective_end_date(+) and
        oipl.business_group_id(+)=p_business_group_id
    order by mx_rchd_dflt_ordr_num
    ;

  cursor c_ledger_totals is
    select
                nvl(sum(prvdd_val),0),
                nvl(sum(decode(prtt_ro_of_unusd_amt_flag,'N',used_val,0)),0),-- non rollovers
                nvl(sum(cash_recd_val),0),
                nvl(sum(decode(prtt_ro_of_unusd_amt_flag,'Y',used_val,0)),0) -- rollovers
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_elig_per_elctbl_chc epe_flex,
                ben_per_in_ler pil_flex,
                ben_per_in_ler pil_flex1
    where       p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date and
                bpl.business_group_id=p_business_group_id and
                bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
                bpl.prtt_enrt_rslt_id=epe_flex.prtt_enrt_rslt_id and
                -- exclude the rollover for this abr
                (bpl.acty_base_rt_id<>l_acty_base_rt_id or
                -- but include the used amounts for this abr
                prtt_ro_of_unusd_amt_flag='N') and
                epe_flex.business_group_id=p_business_group_id and
                epe_flex.per_in_ler_id=pil_flex.per_in_ler_id and
                pil_flex.business_group_id=p_business_group_id and
                pil_flex.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex.per_in_ler_id=p_per_in_ler_id and
                -- Bug 1634870
                pil_flex1.per_in_ler_id=bpl.per_in_ler_id and
                pil_flex1.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex1.business_group_id=p_business_group_id
    group by    bpl.bnft_prvdr_pool_id
    ;

  cursor c_ledger_totals_this_rollover is
    select
                nvl(sum(prvdd_val),0),
                nvl(sum(decode(prtt_ro_of_unusd_amt_flag,'N',used_val,0)),0),-- non rollovers
                nvl(sum(cash_recd_val),0),
                nvl(sum(decode(prtt_ro_of_unusd_amt_flag,'Y',used_val,0)),0) -- rollovers
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_elig_per_elctbl_chc epe_flex,
                ben_per_in_ler pil_flex,
                ben_per_in_ler pil_flex1
    where       p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date and
                bpl.business_group_id=p_business_group_id and
                bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
                bpl.prtt_enrt_rslt_id=epe_flex.prtt_enrt_rslt_id and
                bpl.acty_base_rt_id=l_acty_base_rt_id and  -- this is the difference
--              bpl.prtt_ro_of_unusd_amt_flag='Y' and -- and this is the rollover
                epe_flex.business_group_id=p_business_group_id and
                epe_flex.per_in_ler_id=pil_flex.per_in_ler_id and
                pil_flex.business_group_id=p_business_group_id and
                pil_flex.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex.per_in_ler_id=p_per_in_ler_id and
                -- Bug 1634870
                pil_flex1.per_in_ler_id=bpl.per_in_ler_id and
                pil_flex1.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex1.business_group_id=p_business_group_id
    group by    bpl.bnft_prvdr_pool_id
    ;

  cursor c_old_ledger is
    select
                bnft_prvdd_ldgr_id,
                bpl.used_val,
                bpl.object_version_number,
                bpl.effective_start_date
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_elig_per_elctbl_chc epe_flex,
                ben_per_in_ler pil_flex,
                ben_per_in_ler pil_flex1
    where       p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date and
                bpl.business_group_id=p_business_group_id and
                bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
                bpl.prtt_enrt_rslt_id=epe_flex.prtt_enrt_rslt_id and
                --bpl.used_val<>0 and   -----For the Bug 7118730
                bpl.prtt_ro_of_unusd_amt_flag='Y' and
                epe_flex.business_group_id=p_business_group_id and
                epe_flex.per_in_ler_id=pil_flex.per_in_ler_id and
                pil_flex.business_group_id=p_business_group_id and
                pil_flex.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                -- Bug 1634870
                pil_flex1.per_in_ler_id=bpl.per_in_ler_id and
                pil_flex1.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex1.business_group_id=p_business_group_id and
                pil_flex.per_in_ler_id=p_per_in_ler_id ;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_rollover_diff_total:=0;
  for l_rollover in c_rollovers loop
    --
    -- If rule exists run if and see if qualifies for rollover
    --
    if l_rollover.prtt_elig_rlovr_rl is not null then
      --
      -- execute rule
      --
  --    if l_rollover.region_2 is not null then

  --      l_jurisdiction_code :=
  --          pay_mag_utils.lookup_jurisdiction_code
  --           (p_state => l_rollover.region_2);

  --  end if;

      l_outputs := benutils.formula
            (p_formula_id           => l_rollover.prtt_elig_rlovr_rl,
             p_assignment_id        => l_rollover.assignment_id,
             p_organization_id        => l_rollover.organization_id,
             p_business_group_id    => p_business_group_id,
             p_effective_date       => p_effective_date,
             p_opt_id               => l_rollover.opt_id,
             p_pl_id                => l_rollover.pl_id,
             p_pgm_id               => l_rollover.pgm_id,
             p_ler_id               => l_rollover.ler_id,
             p_pl_typ_id            => l_rollover.pl_typ_id,
             p_acty_base_rt_id      => l_rollover.acty_base_rt_id,
             p_elig_per_elctbl_chc_id      => l_rollover.elig_per_elctbl_chc_id,
             p_jurisdiction_code    => l_jurisdiction_code);

      l_qualify_flag := l_outputs(l_outputs.first).value;
    else
      l_qualify_flag:='Y';
    end if;
    if l_qualify_flag='Y' then
      --
      -- Process this rollover
      --
      hr_utility.set_location(l_proc, 20);
      l_acty_base_rt_id:=l_rollover.acty_base_rt_id;
      --
      -- Get the ledger totals with exclusions (see cursor)
      --
      open c_ledger_totals;
      fetch c_ledger_totals into
          l_prvdd_val,
          l_used_val,
          l_recd_val,
          l_rld_ovr_val;
      close c_ledger_totals;
      --
      -- depending on the excess treatment code compute the balance
      --
      if p_dflt_excs_trtmt_cd in ('DSTRBT_ALL','DSTRBT_RLOVR_FRFT') then
        hr_utility.set_location(l_proc, 30);
        l_balance:=l_prvdd_val-l_used_val-l_recd_val-l_rld_ovr_val;
      else
        hr_utility.set_location(l_proc, 40);
        l_balance:=l_prvdd_val-l_used_val-l_rld_ovr_val;
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- round the balance
      --
      if l_rollover.val_rndg_cd is not null then
        l_balance:=benutils.do_rounding(
          p_rounding_cd    => l_rollover.val_rndg_cd,
          p_rounding_rl    => l_rollover.val_rndg_rl,
          p_value          => l_balance,
          p_effective_date => p_effective_date);
      end if;
      --
      -- Bug 2185478 : Globals used for validating the rollover amounts
      --
      if p_acty_base_rt_id is not null then
         --
         g_balance      := l_balance;
         g_mx_rlovr_val := l_rollover.mx_rlovr_val;
         g_mx_elcn_val  := l_rollover.mx_elcn_val;
         --
      end if;
      --
      -- set value to less than the maximums
      -- do this before minimums since if any max is less than any minimum should skip it.
      --
      -- set balance to max pct if defined and > balance
      --
      if l_rollover.mx_rlovr_pct_num is not null then
        l_mx_dstrbl_pct_num:=(l_prvdd_val-l_used_val)*l_rollover.mx_rlovr_pct_num/100;
        if p_pct_rndg_cd is not null then
          l_mx_dstrbl_pct_num:=benutils.do_rounding(
            p_rounding_cd    => p_pct_rndg_cd,
            p_rounding_rl    => p_pct_rndg_rl,
            p_value          => l_mx_dstrbl_pct_num,
            p_effective_date => p_effective_date);
        end if;
        if l_balance > l_mx_dstrbl_pct_num then
          --
          -- Bug 2185478
          --
          if p_acty_base_rt_id is not null then
             --
             g_mx_dstrbl_pct_num  := l_mx_dstrbl_pct_num;
             --
          end if;
          l_balance:=l_mx_dstrbl_pct_num;
          --
        end if;
      end if;
      --
      -- Set balance to max amount if defined and < balance
      --
      if l_rollover.mx_rlovr_val is not null and
         l_balance > l_rollover.mx_rlovr_val then
        l_balance:=l_rollover.mx_rlovr_val;
      end if;
      --
      -- Set balance to max elcn val if defined and < balance
      --
      if l_rollover.mx_elcn_val is not null and
         l_balance > l_rollover.mx_elcn_val then
        l_balance:=l_rollover.mx_elcn_val;
      end if;

      -- Check the rlover rule - this is a max val rule.
      if l_rollover.rlovr_val_rl is not null then
          run_rule
            (p_effective_date     => p_effective_date
            ,p_person_id          => p_person_id
            ,p_rlovr_val_rl       => l_rollover.rlovr_val_rl
            ,p_business_group_id  => p_business_group_id
            ,p_ler_id             => l_rollover.ler_id
            ,p_bnft_prvdr_pool_id => p_bnft_prvdr_pool_id
            ,p_dflt_excs_trtmt_cd => l_dummy  -- output
            ,p_acty_base_rt_id    => l_acty_base_rt_id
            ,p_elig_per_elctbl_chc_id      => l_rollover.elig_per_elctbl_chc_id
            ,p_mx_val             => l_rollover.mx_rlovr_val); -- output
         --
         -- Bug 2185478
         --
         if p_acty_base_rt_id is not null then
             --
             g_mx_rlovr_rl_val := l_rollover.mx_rlovr_val;
             --
         end if;
         --
         if l_rollover.mx_rlovr_val is not null and
            l_balance > l_rollover.mx_rlovr_val then
            l_balance:=l_rollover.mx_rlovr_val;
         end if;
      end if;
      --
      -- compute the min pct value
      --
      l_mn_dstrbl_pct_num:=(l_prvdd_val-l_used_val)*l_rollover.mn_rlovr_pct_num/100;
      if p_pct_rndg_cd is not null then
        l_mn_dstrbl_pct_num:=benutils.do_rounding(
          p_rounding_cd    => p_pct_rndg_cd,
          p_rounding_rl    => p_pct_rndg_rl,
          p_value          => l_mn_dstrbl_pct_num,
          p_effective_date => p_effective_date);
      end if;
      --
      -- Bug 2185478
      --
      if p_acty_base_rt_id is not null then
         --
         g_mn_dstrbl_pct_num := l_mn_dstrbl_pct_num;
         g_mn_elcn_val       := l_rollover.mn_elcn_val;
         g_mn_rlovr_val      := l_rollover.mn_rlovr_val;
         --
      end if;
      --
      --
      -- if less than mimimums cannot rollover, skip it.
      --
      if not p_calculate_only_mode then
        --
        if (l_balance < l_rollover.mn_elcn_val or -- should this include the current elections?
            l_balance < l_rollover.mn_rlovr_val or
            l_balance < l_mn_dstrbl_pct_num or
            l_balance <=0 )
        then
          hr_utility.set_location('Balance less than minimum or zero',60);
	  hr_utility.set_location('l_balance : '||l_balance,60);

	  --Bug 7118730
	  open c_old_ledger;
          fetch c_old_ledger into
            l_bnft_prvdd_ldgr_id,
            l_old_rlovr_val,
            l_object_version_number,
            l_effective_start_date
          ;
          if c_old_ledger%found then
	  Get_DT_Upd_Mode
                  (p_effective_date        => p_effective_date,
                   p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
                   p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
                   p_base_key_value        => l_bnft_prvdd_ldgr_id,
                   p_mode                  => l_datetrack_mode);
	  l_balance := 0;
          ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                       p_bnft_prvdd_ldgr_id         => l_bnft_prvdd_ldgr_id
                      ,p_effective_start_date       => l_effective_start_date
                      ,p_effective_end_date         => l_effective_end_date
                      ,p_prtt_ro_of_unusd_amt_flag  => 'Y'
                      ,p_frftd_val                  => null
                      ,p_prvdd_val                  => null
                      ,p_used_val                   => l_balance
                      ,p_bnft_prvdr_pool_id         => p_bnft_prvdr_pool_id
                      ,p_acty_base_rt_id            => l_acty_base_rt_id
                      ,p_per_in_ler_id              => p_per_in_ler_id
                      ,p_prtt_enrt_rslt_id          => g_credit_pool_result_id
                      ,p_business_group_id          => p_business_group_id
                      ,p_object_version_number      => l_object_version_number
                      ,p_cash_recd_val              => 0
                      ,p_effective_date             => p_effective_date
                      ,p_datetrack_mode             => l_datetrack_mode
            );
	    end if;
	    close c_old_ledger;
          --
          --
          -- nothing to do
          --
        else
          hr_utility.set_location(l_proc, 70);
          --
          -- Find out amount of rollover
          --
          open c_old_ledger;
          fetch c_old_ledger into
            l_bnft_prvdd_ldgr_id,
            l_old_rlovr_val,
            l_object_version_number,
            l_effective_start_date
          ;
          --
          -- perform rollover
          --
          hr_utility.set_location(l_proc, 80);
          if c_old_ledger%notfound then
            hr_utility.set_location(l_proc, 90);
            l_rollover_diff_total:=l_rollover_diff_total+l_balance;
            ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
                       p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
                      ,p_effective_start_date         => l_effective_start_date
                      ,p_effective_end_date           => l_effective_end_date
                      ,p_prtt_ro_of_unusd_amt_flag    => 'Y'
                      ,p_frftd_val                    => null
                      ,p_prvdd_val                    => null
                      ,p_used_val                     => l_balance
                      ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
                      ,p_acty_base_rt_id              => l_acty_base_rt_id
                      ,p_per_in_ler_id                => p_per_in_ler_id
                      ,p_person_id                    => p_person_id
                      ,p_enrt_mthd_cd                 => p_enrt_mthd_cd
                      ,p_prtt_enrt_rslt_id            => g_credit_pool_result_id
                      ,p_business_group_id            => p_business_group_id
                      ,p_object_version_number        => l_object_version_number
                      ,p_cash_recd_val                => null
                      ,p_effective_date               => p_effective_date
            );
            hr_utility.set_location('CREATED LDGR ID='||to_char(l_bnft_prvdd_ldgr_id),100);
          else --if l_old_rlovr_val<>l_balance then-------Bug 	7363185
            hr_utility.set_location(l_proc, 110);
            /*
            if l_effective_start_date=p_effective_date then
              l_datetrack_mode:=hr_api.g_correction;
            else
              l_datetrack_mode:=hr_api.g_update;
            end if;
            */
            Get_DT_Upd_Mode
                  (p_effective_date        => p_effective_date,
                   p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
                   p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
                   p_base_key_value        => l_bnft_prvdd_ldgr_id,
                   p_mode                  => l_datetrack_mode);
            hr_utility.set_location('UPDATING LDGR ID='||to_char(l_bnft_prvdd_ldgr_id),120);
            l_rollover_diff_total:=l_rollover_diff_total+l_balance-l_old_rlovr_val;
            ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                       p_bnft_prvdd_ldgr_id         => l_bnft_prvdd_ldgr_id
                      ,p_effective_start_date       => l_effective_start_date
                      ,p_effective_end_date         => l_effective_end_date
                      ,p_prtt_ro_of_unusd_amt_flag  => 'Y'
                      ,p_frftd_val                  => null
                      ,p_prvdd_val                  => null
                      ,p_used_val                   => l_balance
                      ,p_bnft_prvdr_pool_id         => p_bnft_prvdr_pool_id
                      ,p_acty_base_rt_id            => l_acty_base_rt_id
                      ,p_per_in_ler_id              => p_per_in_ler_id
                      ,p_prtt_enrt_rslt_id          => g_credit_pool_result_id
                      ,p_business_group_id          => p_business_group_id
                      ,p_object_version_number      => l_object_version_number
                      ,p_cash_recd_val              => 0
                      ,p_effective_date             => p_effective_date
                      ,p_datetrack_mode             => l_datetrack_mode
            );
            hr_utility.set_location('UPDATED LEDGER (ID='||to_char(l_bnft_prvdd_ldgr_id),130);
          end if;
          close c_old_ledger;
        end if;
      end if;
    end if; -- rule returned 'Y'
    hr_utility.set_location(l_proc, 140);
  end loop;
  if l_rollover_diff_total is null then
     p_rollover_val := 0;
  else   p_rollover_val:=l_rollover_diff_total;
  end if;
  hr_utility.set_location('We rolled over $'||to_char(l_rollover_diff_total), 998);
  hr_utility.set_location('Leaving:'||l_proc, 999);
end default_rollovers;
--
-- Bug 2185478 Added procedure to validate the rollover value entered by the user on
-- flex enrollment form and show proper message immediately
--------------------------------------------------------------------------------
--                      validate_rollover_val
--------------------------------------------------------------------------------
procedure validate_rollover_val
  (p_calculate_only_mode  in     boolean default false
  ,p_bnft_prvdr_pool_id   in     number
  ,p_person_id            in     number
  ,p_per_in_ler_id        in     number
  ,p_acty_base_rt_id      in     number default null
  ,p_enrt_mthd_cd         in     varchar2
  ,p_effective_date       in     date
  ,p_datetrack_mode       in     varchar2
  ,p_business_group_id    in     number
  ,p_pct_rndg_cd          in     varchar2
  ,p_pct_rndg_rl          in     number
  ,p_dflt_excs_trtmt_cd   in     varchar2
  ,p_new_rollover_val     in     number
  ,p_rollover_val            out nocopy number
  )
is
  --
  l_proc varchar2(72) := g_package||'.validate_rollover_val';
  --
  cursor c_pool_info is
    select bpp.*
    from   ben_bnft_prvdr_pool_f bpp
    where  p_effective_date between
             bpp.effective_start_date and
             bpp.effective_end_date and
           bpp.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
           bpp.business_group_id=p_business_group_id
    ;
  l_pool_info    c_pool_info%rowtype;
  l_rollover_val number;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Initialise globals.
  --
  g_balance           := null;
  g_mx_dstrbl_pct_num := null;
  g_mx_rlovr_val      := null;
  g_mx_elcn_val       := null;
  g_mx_rlovr_rl_val   := null;
  g_mn_dstrbl_pct_num := null;
  g_mn_rlovr_val      := null;
  g_mn_elcn_val       := null;
  --
  open c_pool_info;
  fetch c_pool_info into l_pool_info;
  if c_pool_info%notfound then
      --
      -- error
      --
      close c_pool_info;
      fnd_message.set_name('BEN','BEN_92538_POOL_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
      fnd_message.set_token('BNFT_PRVDR_POOL_ID',
                          to_char(p_bnft_prvdr_pool_id));
      hr_utility.set_location(l_proc,20);
      fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30 );
  if l_pool_info.dflt_excs_trtmt_cd in ('DSTRBT_RLOVR_FRFT','RLOVR_DSTRBT_FRFT') then
   --
   default_rollovers(
     p_calculate_only_mode     => true,
     p_bnft_prvdr_pool_id      => p_bnft_prvdr_pool_id,
     p_person_id               => p_person_id,
     p_acty_base_rt_id         => p_acty_base_rt_id,
     p_effective_date          => p_effective_date,
     p_datetrack_mode          => p_datetrack_mode,
     p_business_group_id       => p_business_group_id,
     p_pct_rndg_cd             => l_pool_info.pct_rndg_cd,
     p_pct_rndg_rl             => l_pool_info.pct_rndg_rl,
     p_dflt_excs_trtmt_cd      => l_pool_info.dflt_excs_trtmt_cd,
     p_rollover_val            => l_rollover_val, -- returns the rollover change
     p_per_in_ler_id           => p_per_in_ler_id,
     p_enrt_mthd_cd            => p_enrt_mthd_cd);
   --
  end if;
  --
  hr_utility.set_location( 'g_rollover_val = ' || g_balance, 30);
  hr_utility.set_location( 'g_mx_dstrbl_pct_num = ' || g_mx_dstrbl_pct_num, 30);
  hr_utility.set_location( 'g_mx_rlovr_val = ' || g_mx_rlovr_val, 30);
  hr_utility.set_location( 'g_mx_elcn_val = ' || g_mx_elcn_val, 30);
  hr_utility.set_location( 'g_mn_dstrbl_pct_num = ' || g_mn_dstrbl_pct_num, 30);
  hr_utility.set_location( 'g_mn_rlovr_val = ' || g_mn_rlovr_val, 30);
  hr_utility.set_location( 'g_mn_elcn_val = ' || g_mn_elcn_val, 30);
  hr_utility.set_location( 'g_mx_rlovr_rl_val = ' || g_mx_rlovr_rl_val, 30);
  hr_utility.set_location( 'l_rollover_val = ' || g_balance, 30);
  hr_utility.set_location( 'p_new_rollover_val = ' || p_new_rollover_val, 30);
  --
  -- Raise errors if entered rollover value exceeds any limits set
  --
  if p_new_rollover_val /* g_balance */ > g_mx_dstrbl_pct_num then
     --
     fnd_message.set_name('BEN','BEN_92960_RLOVR_VAL_GT_MXDPN');
     hr_utility.set_location(l_proc,40);
     fnd_message.raise_error;
     --
  end if;
  --
  if p_new_rollover_val /* g_balance */ > g_mx_rlovr_val then
     --
     fnd_message.set_name('BEN','BEN_92961_RLOVR_VAL_GT_MXRV');
     hr_utility.set_location(l_proc,41);
     fnd_message.raise_error;
     --
  end if;
  if p_new_rollover_val /* g_balance */ > g_mx_elcn_val then
     --
     fnd_message.set_name('BEN','BEN_92962_RLOVR_VAL_GT_MXEV');
     hr_utility.set_location(l_proc,42);
     fnd_message.raise_error;
     --
  end if;
  --
  if p_new_rollover_val /* g_balance */ > g_mx_rlovr_rl_val then
     --
     fnd_message.set_name('BEN','BEN_92963_RLOVR_VAL_GT_MXRRV');
     hr_utility.set_location(l_proc,43);
     fnd_message.raise_error;
     --
  end if;
  --
  --
  if p_new_rollover_val /* g_balance */ < g_mn_dstrbl_pct_num then
     --
     fnd_message.set_name('BEN','BEN_92964_RLOVR_VAL_GT_MNDPN');
     hr_utility.set_location(l_proc,44);
     fnd_message.raise_error;
     --
  end if;
  --
  if p_new_rollover_val /* g_balance */ < g_mn_rlovr_val then
     --
     fnd_message.set_name('BEN','BEN_92965_RLOVR_VAL_GT_MNRV');
     hr_utility.set_location(l_proc,45);
     fnd_message.raise_error;
     --
  end if;
  if p_new_rollover_val /* g_balance */ < g_mn_elcn_val then
     --
     fnd_message.set_name('BEN','BEN_92966_RLOVR_VAL_GT_MNEV');
     hr_utility.set_location(l_proc,46);
     fnd_message.raise_error;
     --
  end if;
  --
  -- Reset globals
  --
  g_balance           := null;
  g_mx_dstrbl_pct_num := null;
  g_mx_rlovr_val      := null;
  g_mx_rlovr_rl_val   := null;
  g_mx_elcn_val       := null;
  g_mn_dstrbl_pct_num := null;
  g_mn_rlovr_val      := null;
  g_mn_elcn_val       := null;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
end validate_rollover_val;
--------------------------------------------------------------------------------
--                      create_rollover_enrollment
--------------------------------------------------------------------------------
procedure create_rollover_enrollment(
        p_bnft_prvdr_pool_id in number,
        p_person_id in number,
        p_per_in_ler_id in number,
        p_effective_date in date,
        p_datetrack_mode in varchar2,
        p_acty_base_rt_id in number,
        p_rlovr_amt in number,
        p_old_rlovr_amt in number,
        p_business_group_id in number,
        p_enrt_mthd_cd in varchar2) is
  l_proc varchar2(72) := g_package||'.create_rollover_enrollment';

l_new_prtt_rt_val        number := 0;
l_new_ann_val            number := 0;
l_old_prtt_rt_val_amt    number := 0;
l_good_prtt_rt_val_id    number := null;
l_datetrack_mode         varchar2(30);
l_effective_start_date   date;
l_effective_end_date     date;
l_suspend_flag           varchar2(30);
l_object_version_number  number;
l_prtt_enrt_interim_id   number;
l_prtt_rt_val_id         number;
l_dpnt_actn_warning      boolean;
l_bnf_actn_warning       boolean;
l_ctfn_actn_warning      boolean;
l_global_asg_rec ben_global_enrt.g_global_asg_rec_type;


-- query to get old prtt_rt_val amount
  cursor c_old_prtt_rt_val(v_enrt_rt_id number) is
    select
        prv.rt_val,
        prv.prtt_rt_val_id
    from ben_prtt_rt_val prv,
         ben_enrt_rt ecr
    where ecr.enrt_rt_id = v_enrt_rt_id and
          prv.prtt_rt_val_id=ecr.prtt_rt_val_id and
          prv.prtt_rt_val_stat_cd is null and
	  prv.per_in_ler_id = p_per_in_ler_id and
          ecr.business_group_id=p_business_group_id;

  cursor c_rlovr_chc is
    select decode(enb.enrt_bnft_id,
                    null, ecr2.enrt_rt_id,
                          ecr1.enrt_rt_id) enrt_rt_id,
           decode(enb.enrt_bnft_id,
                    null, ecr2.rt_mlt_cd,
                          ecr1.rt_mlt_cd) rt_mlt_cd,
	   decode(enb.enrt_bnft_id,
                    null, ecr2.entr_val_at_enrt_flag,
                          ecr1.entr_val_at_enrt_flag) entr_val_at_enrt_flag, --bug 5608160
           enb.enrt_bnft_id,
           nvl(enb.val, enb.dflt_val) bnft_val,
           epe.elig_per_elctbl_chc_id,
           pel.acty_ref_perd_cd,
           pen.prtt_enrt_rslt_id,
           pen.bnft_amt,
           pen.object_version_number
    from   ben_per_in_ler pil,
           ben_elig_per_elctbl_chc epe,
           ben_pil_elctbl_chc_popl pel,
           ben_enrt_rt ecr1,
           ben_enrt_rt ecr2,
           ben_enrt_bnft enb,
           ben_prtt_enrt_rslt_f pen,
           ben_bnft_prvdr_pool_f bpp -- join to get only current pgm_id - rgajula
    where  pil.per_in_ler_id=p_per_in_ler_id and
           pil.business_group_id=p_business_group_id and
           pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
           pil.per_in_ler_id=epe.per_in_ler_id and
           pil.per_in_ler_id = pel.per_in_ler_id and
           pel.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id and
           epe.business_group_id=p_business_group_id and
           epe.elig_per_elctbl_chc_id=ecr2.elig_per_elctbl_chc_id(+) and
	       bpp.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id and                                  --
	       bpp.business_group_id = p_business_group_id and                                    --
	       p_effective_date between bpp.effective_start_date and bpp.effective_end_date and   --
	       bpp.pgm_id = epe.pgm_id and                                                        --
           (p_acty_base_rt_id is null or
            ecr1.acty_base_rt_id = p_acty_base_rt_id or
            ecr2.acty_base_rt_id = p_acty_base_rt_id) and
           pen.prtt_enrt_rslt_id(+)=epe.prtt_enrt_rslt_id and
           epe.elig_per_elctbl_chc_id=enb.elig_per_elctbl_chc_id(+) and
           enb.enrt_bnft_id = ecr1.enrt_bnft_id(+) and
           pen.prtt_enrt_rslt_stat_cd is null  and
           p_effective_date between
           pen.effective_start_date(+) and pen.effective_end_date(+) and
           pen.business_group_id(+)=p_business_group_id ;
 --
 l_rlovr_chc c_rlovr_chc%rowtype;
 --GEVITY
 cursor c_abr(cv_acty_base_rt_id number)
 is select rate_periodization_rl
      from ben_acty_base_rt_f abr
     where abr.acty_base_rt_id = cv_acty_base_rt_id
       and p_effective_date between abr.effective_start_date
                                and abr.effective_end_date ;
 --
 l_rate_periodization_rl NUMBER;
 --
 l_dfnd_dummy number;
 l_ann_dummy  number;
 l_cmcd_dummy number;
 l_assignment_id                 per_all_assignments_f.assignment_id%type;
 l_payroll_id                    per_all_assignments_f.payroll_id%type;
 l_organization_id               per_all_assignments_f.organization_id%type;
 --END GEVITY
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('crdt_pool_rslt_id='||to_char(g_credit_pool_result_id),10);
  --
  -- Get choice id of what you are trying to roll into
  open c_rlovr_chc;
  fetch c_rlovr_chc into l_rlovr_chc;
  if c_rlovr_chc%notfound then
    hr_utility.set_location('BEN_91457_ELCTBL_CHC_NOT_FOUND ACTY_id:'||
       to_char(p_acty_base_rt_id), 20); hr_utility.set_location('p_person_id:'||to_char(p_person_id), 20);
    hr_utility.set_location('p_business_group_id:'||to_char(p_business_group_id), 20);
    close c_rlovr_chc;
    fnd_message.set_name('BEN','BEN_91457_ELCTBL_CHC_NOT_FOUND');
    fnd_message.set_token('ID', 'NA');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.raise_error;
  end if;
  close c_rlovr_chc;

  --
  -- get old prtt_rt_val
  --
  if l_rlovr_chc.enrt_rt_id is not null then
    open c_old_prtt_rt_val(l_rlovr_chc.enrt_rt_id);
    fetch c_old_prtt_rt_val into
      l_old_prtt_rt_val_amt,
      l_good_prtt_rt_val_id;

    close c_old_prtt_rt_val;
  end if;
  --
  -- compute the new prtt_rt_val
  -- start bug 5608160
  hr_utility.set_location('Entering: SSARKAR ', 10);

if nvl(l_rlovr_chc.entr_val_at_enrt_flag,'N') = 'N' then
     l_new_prtt_rt_val:=l_old_prtt_rt_val_amt+p_rlovr_amt;
else
     l_new_prtt_rt_val:=l_old_prtt_rt_val_amt-p_old_rlovr_amt+p_rlovr_amt;
end if ;

-- end bug 5608160

 hr_utility.set_location('l_new_prtt_rt_val='||l_new_prtt_rt_val,10);
 hr_utility.set_location('l_old_prtt_rt_val_amt='||l_old_prtt_rt_val_amt,10);
 hr_utility.set_location('p_old_rlovr_amt='||p_old_rlovr_amt,10);
 hr_utility.set_location('p_rlovr_amt='||p_rlovr_amt,10);
  --
  -- create the result
  --
    hr_utility.set_location('enrt_rt_id='||to_char(l_rlovr_chc.enrt_rt_id),40);
    hr_utility.set_location('choice_id='||to_char(l_rlovr_chc.elig_per_elctbl_chc_id),50);
    hr_utility.set_location('result_id='||to_char(l_rlovr_chc.prtt_enrt_rslt_id),60);
    --
    -- Calculate the annual value.
    --
   if l_new_prtt_rt_val > 0 and l_rlovr_chc.enrt_rt_id is not null then
     --
     /*
     ben_global_enrt.get_asg  -- assignment
       (p_person_id              => p_person_id
       ,p_effective_date         => p_effective_date
       ,p_global_asg_rec         => l_global_asg_rec);
     */ --GEVITY
     ben_element_entry.get_abr_assignment
      (p_person_id       => p_person_id
      ,p_effective_date  => p_effective_date
      ,p_acty_base_rt_id => p_acty_base_rt_id
      ,p_organization_id => l_organization_id
      ,p_payroll_id      => l_payroll_id
      ,p_assignment_id   => l_assignment_id
      );
     --
     open c_abr(p_acty_base_rt_id) ;
       fetch c_abr into l_rate_periodization_rl ;
     close c_abr;
     --
     IF l_rate_periodization_rl IS NOT NULL THEN
       --
       l_dfnd_dummy := l_new_prtt_rt_val;
       --
       ben_distribute_rates.periodize_with_rule
                  (p_formula_id             => l_rate_periodization_rl
                  ,p_effective_date         => p_effective_date
                  ,p_assignment_id          => l_assignment_id
                  ,p_convert_from_val       => l_dfnd_dummy
                  ,p_convert_from           => 'DEFINED'
                  ,p_elig_per_elctbl_chc_id => l_rlovr_chc.elig_per_elctbl_chc_id
                  ,p_acty_base_rt_id        => p_acty_base_rt_id
                  ,p_business_group_id      => p_business_group_id
                  ,p_enrt_rt_id             => l_rlovr_chc.enrt_rt_id
                  ,p_ann_val                => l_new_ann_val
                  ,p_cmcd_val               => l_cmcd_dummy
                  ,p_val                    => l_cmcd_dummy
       );
       --
     ELSE
       --
       l_new_ann_val := ben_distribute_rates.period_to_annual
                    (p_amount                  => l_new_prtt_rt_val,
                     p_enrt_rt_id              => l_rlovr_chc.enrt_rt_id,
                     p_acty_ref_perd_cd        => l_rlovr_chc.acty_ref_perd_cd,
                     p_business_group_id       => p_business_group_id,
                     p_effective_date          => p_effective_date,
                     p_complete_year_flag      => 'Y',
                     p_payroll_id              => l_global_asg_rec.payroll_id);
     END IF; --GEVITY
     --
     if l_rlovr_chc.rt_mlt_cd = 'SAREC' then
       l_rlovr_chc.bnft_val := l_new_ann_val;
     end if;
     --
   end if;
    --
    -- call election_information api to create prtt enrt result
    --
      --
      if l_rlovr_chc.prtt_enrt_rslt_id is not null then
        l_datetrack_mode:=hr_api.g_correction;
      else
        l_datetrack_mode:=hr_api.g_insert;
      end if;
      --
      hr_utility.set_location(l_proc, 70);
      ben_election_information.election_information(
        p_elig_per_elctbl_chc_id   => l_rlovr_chc.elig_per_elctbl_chc_id,
        p_prtt_enrt_rslt_id        => l_rlovr_chc.prtt_enrt_rslt_id,
        p_effective_date           => p_effective_date,
        p_effective_start_date     => l_effective_start_date,
        p_effective_end_date       => l_effective_end_date,
        p_enrt_mthd_cd             => p_enrt_mthd_cd,
        p_enrt_bnft_id             => l_rlovr_chc.enrt_bnft_id,
        p_bnft_val                 => l_rlovr_chc.bnft_val,
        p_datetrack_mode           => l_datetrack_mode,
        p_suspend_flag             => l_suspend_flag,
        p_object_version_number    => l_rlovr_chc.object_version_number,
        p_prtt_enrt_interim_id     => l_prtt_enrt_interim_id,
        p_rt_val1                  => l_new_prtt_rt_val,
        p_ann_rt_val1              => l_new_ann_val,
        p_enrt_rt_id1              => l_rlovr_chc.enrt_rt_id,
        p_prtt_rt_val_id1          => l_good_prtt_rt_val_id,
        p_prtt_rt_val_id2          => l_prtt_rt_val_id,
        p_prtt_rt_val_id3          => l_prtt_rt_val_id,
        p_prtt_rt_val_id4          => l_prtt_rt_val_id,
        p_prtt_rt_val_id5          => l_prtt_rt_val_id,
        p_prtt_rt_val_id6          => l_prtt_rt_val_id,
        p_prtt_rt_val_id7          => l_prtt_rt_val_id,
        p_prtt_rt_val_id8          => l_prtt_rt_val_id,
        p_prtt_rt_val_id9          => l_prtt_rt_val_id,
        p_prtt_rt_val_id10         => l_prtt_rt_val_id,
        p_business_group_id        => p_business_group_id,
        p_dpnt_actn_warning        => l_dpnt_actn_warning,
        p_bnf_actn_warning         => l_bnf_actn_warning,
        p_ctfn_actn_warning        => l_ctfn_actn_warning
      );
  hr_utility.set_location('Leaving:'||l_proc, 999);
end create_rollover_enrollment;
--------------------------------------------------------------------------------
--                      total_pools
--------------------------------------------------------------------------------
procedure total_pools(
        p_validate             in boolean default false,
        p_prtt_enrt_rslt_id    in out nocopy number,
        p_prtt_rt_val_id       in out nocopy number,
        p_acty_ref_perd_cd     out nocopy varchar2,
        p_acty_base_rt_id      out nocopy number,
        p_rt_strt_dt           out nocopy date,
        p_rt_val               out nocopy number,
        p_element_type_id      out nocopy number,
        p_person_id            in number,
        p_per_in_ler_id        in number,
        p_enrt_mthd_cd         in varchar2,
        p_effective_date       in date,
        p_business_group_id    in number,
        p_pgm_id               in number default null
) is

  l_proc varchar2(72) := g_package||'.total_pools';
  l_new_cash              number;
  l_bnft_prvdd_ldgr_id    number;
  l_elig_per_elctbl_chc_id    number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_total_credits         number;
  l_def_exc_amount        number;
  l_def_exc_amt           number;
  l_deficit_limit         number;
  l_object_version_number number;
  l_acty_base_rt_id       number;
  l_cash_val              number;
  l_compensation_value    number;
  l_datetrack_mode        varchar2(30);
  l_rollover_val          number := 0 ;
  l_dstrbtd_val           number;
  l_dummy                 number;
  l_uses_net_crs_mthd     boolean := false;
  l_dummy_number          number;
  l_redis_credits         boolean := false;

  cursor c_ledger_totals is
    select        bpl.bnft_prvdr_pool_id,
                nvl(sum(prvdd_val),0) prvdd_total,
                nvl(sum(used_val),0) used_total, -- include rollovers
                nvl(sum(frftd_val),0) frftd_total,
                nvl(sum(cash_recd_val),0) cash_recd_total,
                pil_flex.ler_id
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_elig_per_elctbl_chc epe_flex,
                ben_per_in_ler pil_flex,
                ben_per_in_ler pil_flex1
    where       p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date and
                bpl.business_group_id=p_business_group_id and
                bpl.bnft_prvdr_pool_id is not null and
                bpl.prtt_enrt_rslt_id=epe_flex.prtt_enrt_rslt_id and
                epe_flex.business_group_id=p_business_group_id and
                epe_flex.per_in_ler_id=pil_flex.per_in_ler_id and
                pil_flex.business_group_id=p_business_group_id and
                pil_flex.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex.per_in_ler_id=p_per_in_ler_id and
                -- Bug 1634870
                pil_flex1.per_in_ler_id=bpl.per_in_ler_id and
                pil_flex1.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                pil_flex1.business_group_id=p_business_group_id
                and epe_flex.pgm_id = p_pgm_id
    group by    bpl.bnft_prvdr_pool_id, pil_flex.ler_id
    ;
  l_ledger_totals c_ledger_totals%rowtype;

  cursor c_pool_info is
    select bpp.*
    from   ben_bnft_prvdr_pool_f bpp
    where  p_effective_date between
             bpp.effective_start_date and
             bpp.effective_end_date and
           bpp.bnft_prvdr_pool_id=l_ledger_totals.bnft_prvdr_pool_id and
           bpp.business_group_id=p_business_group_id
    ;
  l_pool_info c_pool_info%rowtype;

  -- for the provided credits choice row for the pool we are working with,
  -- get the acty-base-rt-id from the enrt-rt FLXCR row.
  cursor c_cash_abr is
    select      ecr.acty_base_rt_id,
                epe.elig_per_elctbl_chc_id
    from        ben_per_in_ler pil,
                ben_elig_per_elctbl_chc epe,
                ben_enrt_rt ecr
    where       pil.per_in_ler_id=p_per_in_ler_id and
                pil.business_group_id=p_business_group_id and
                pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT') and
                epe.per_in_ler_id=pil.per_in_ler_id and
                epe.business_group_id=p_business_group_id and
                epe.bnft_prvdr_pool_id=l_ledger_totals.bnft_prvdr_pool_id and
                ecr.elig_per_elctbl_chc_id=epe.elig_per_elctbl_chc_id and
                ecr.rt_usg_cd='FLXCR' and
                ecr.business_group_id=p_business_group_id;
  --
  -- Bug 1711831
  --
  cursor c_get_pool_abr is
    select abr.acty_base_rt_id
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_acty_base_rt_f abr
    where  bpl.bnft_prvdr_pool_id = l_ledger_totals.bnft_prvdr_pool_id and
           abr.rt_usg_cd = 'FLXCR' and
           bpl.business_group_id = abr.business_group_id and
           bpl.business_group_id = p_business_group_id and
           bpl.acty_base_rt_id   = abr.acty_base_rt_id and
           p_effective_date between abr.effective_start_date and
                                    abr.effective_end_date ;
  --
  cursor c_element_details is
    select      prv.acty_ref_perd_cd,
                ecr.acty_base_rt_id,
                prv.rt_strt_dt,
                prv.rt_val,
                abr.element_type_id
    from        ben_prtt_rt_val prv,
                ben_enrt_rt ecr,
                ben_acty_base_rt_f abr,
                ben_prtt_enrt_rslt_f res
    where       prv.prtt_rt_val_id=p_prtt_rt_val_id and
                prv.business_group_id=p_business_group_id and
                ecr.prtt_rt_val_id=prv.prtt_rt_val_id and
                ecr.business_group_id=p_business_group_id and
                abr.acty_base_rt_id=ecr.acty_base_rt_id and
                abr.business_group_id=p_business_group_id and
                p_effective_date between
                        abr.effective_start_date and abr.effective_end_date and
                res.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
                res.business_group_id=p_business_group_id and
                p_effective_date between
                        res.effective_start_date and res.effective_end_date
    ;
  cursor c_old_ledger is
    select      bpl.bnft_prvdd_ldgr_id,
                bpl.cash_recd_val,
                bpl.object_version_number,
                bpl.effective_start_date
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_per_in_ler pil
    where       bpl.bnft_prvdr_pool_id=l_ledger_totals.bnft_prvdr_pool_id
        and     bpl.business_group_id=p_business_group_id
        and     bpl.acty_base_rt_id = l_acty_base_rt_id
        and     bpl.prtt_enrt_rslt_id=g_credit_pool_result_id
        and     bpl.cash_recd_val is not null
        and     p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date
        and pil.per_in_ler_id=bpl.per_in_ler_id
        and pil.business_group_id=bpl.business_group_id
        and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') ;
  --
  cursor c_get_mx_pct_roll_num is
    select bpr.mx_pct_ttl_crs_cn_roll_num
          ,bpr.acty_base_rt_id
    from   ben_bnft_pool_rlovr_rqmt_f bpr
    where  p_effective_date between
             bpr.effective_start_date and
             bpr.effective_end_date
    and    bpr.bnft_prvdr_pool_id=l_ledger_totals.bnft_prvdr_pool_id
    and    bpr.business_group_id=p_business_group_id
    and    bpr.mx_pct_ttl_crs_cn_roll_num is not null
    ;
  --
  cursor c_get_ldgr(p_acty_base_rt_id in number) is
    select bpl.used_val
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_per_in_ler pil
    where  p_effective_date between
             bpl.effective_start_date and
             bpl.effective_end_date
    and    bpl.acty_base_rt_id = p_acty_base_rt_id
    -- UK change : Bug 1634870
    and    bpl.per_in_ler_id = pil.per_in_ler_id
    and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and    bpl.bnft_prvdr_pool_id=l_ledger_totals.bnft_prvdr_pool_id
    and    bpl.business_group_id=p_business_group_id
    and    bpl.prtt_ro_of_unusd_amt_flag = 'Y';
  -- cursor to fin is that an defult enrollemt
  -- chne any of the current result has default enrollment
  cursor c_get_mthd is
    select 'x' from
    ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = p_per_in_ler_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and pen.enrt_mthd_cd   = 'D'
      and  p_effective_date between
           pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
      and  pen.effective_end_date = hr_api.g_eot ;

   l_default_enrt_flag varchar2(1) := 'N' ;
   l_dummy_var         varchar2(1) ;
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Get the flex credit result id and it's per-in-ler.   Both are needed
  -- for when we create ledger rows.
  create_flex_credit_enrolment(
        p_person_id             => p_person_id,
        p_enrt_mthd_cd          => p_enrt_mthd_cd,
        p_business_group_id     => p_business_group_id,
        p_effective_date        => p_effective_date,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_prtt_rt_val_id        => p_prtt_rt_val_id,
        p_per_in_ler_id         => p_per_in_ler_id,
        p_rt_val                => null,
        p_pgm_id                => p_pgm_id
      );
  l_total_credits:=0;
  l_def_exc_amount := 0;
  l_def_exc_amt := 0;

  ---decide whether it is default enrollment
  open c_get_mthd ;
  fetch c_get_mthd into l_dummy_var ;
  if c_get_mthd%found then
    l_default_enrt_flag := 'Y' ;
  else
    l_default_enrt_flag := 'N' ;
  end if ;
  close c_get_mthd ;

  open c_ledger_totals;
  hr_utility.set_location(l_proc, 20);

  loop
    hr_utility.set_location(l_proc, 25);
    --
    fetch c_ledger_totals into l_ledger_totals;
    hr_utility.set_location(l_proc, 30);
    --
    exit when c_ledger_totals%notfound;
    hr_utility.set_location(l_proc, 55);
    hr_utility.set_location( 'prvdd_total = ' || l_ledger_totals.prvdd_total ||
                             'used_total = ' || l_ledger_totals.used_total ||
                             'frftd_total = ' || l_ledger_totals.frftd_total ||
                             'cash_recd_total = ' || l_ledger_totals.cash_recd_total, 55);
    --
    -- Total up credits provided
    --
    l_total_credits:=l_total_credits+l_ledger_totals.prvdd_total;
    hr_utility.set_location( 'l_total_credits = ' || l_total_credits, 55);
    --
    -- get the generic ABR to use for cash and forfeitures.
    --
    l_acty_base_rt_id := null;
    open c_cash_abr;
    fetch c_cash_abr into  l_acty_base_rt_id, l_elig_per_elctbl_chc_id;
    if c_cash_abr%notfound then
        -- bug#3365290
       if l_ledger_totals.prvdd_total = 0 and
          l_ledger_totals.used_total = 0   and
          l_ledger_totals.cash_recd_total = 0  and
          l_ledger_totals.frftd_total = 0 then
         --
         null;
       else
         -- Bug : 1711831
         open c_get_pool_abr;
         fetch c_get_pool_abr into l_acty_base_rt_id;
         if c_get_pool_abr%notfound then
            close c_cash_abr;
            close c_get_pool_abr;
            hr_utility.set_location(l_proc,15);
            fnd_message.set_name('BEN','BEN_91725_NO_FLX_CR_ABR_FOUND');
            fnd_message.set_token('PROC',l_proc);
            fnd_message.set_token('PERSON_ID',to_char(p_person_id));
            fnd_message.raise_error;
         end if;
         close c_get_pool_abr;
         -- Bug : 1711831
       end if;
       --bug#3365290
    end if;
    close c_cash_abr;
    -- bug#3365290
    l_pool_info := null;
    if l_ledger_totals.prvdd_total = 0 and
       l_ledger_totals.used_total = 0   and
       l_ledger_totals.cash_recd_total = 0  and
       l_ledger_totals.frftd_total = 0 then
       --
       null;
    else
      --
      open c_pool_info;
      hr_utility.set_location(l_proc, 60);
      fetch c_pool_info into l_pool_info;
      if c_pool_info%notfound then
        --
        -- error
        --
        close c_pool_info;
        fnd_message.set_name('BEN','BEN_92538_POOL_NOT_FOUND');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('ACTY_BASE_RT_ID',to_char(l_acty_base_rt_id));
        fnd_message.set_token('BNFT_PRVDR_POOL_ID',
                          to_char(l_ledger_totals.bnft_prvdr_pool_id));
        hr_utility.set_location(l_proc,70);
        fnd_message.raise_error;
      end if;
      close c_pool_info;
    --
    end if;
    --
    --  If using the net credits method i.e. only the net credits are
    --  processed through payroll.
    --
    if l_pool_info.uses_net_crs_mthd_flag = 'Y' then
      --
      -- Check if there is a deficit amount.
      --
      l_def_exc_amt :=
        l_ledger_totals.prvdd_total - l_ledger_totals.used_total;
      hr_utility.set_location('l_def_exc_amt: '||l_def_exc_amt,70);
      --
      if l_def_exc_amt <> 0 then
        if l_def_exc_amt < 0 then
          --
          --  Check if the amounts does not exceed limits defined.
          --
          --  Cannot exceed the maximum percent of the total credits.
          --
          if l_pool_info.mx_dfcit_pct_pool_crs_num is not null then
            l_deficit_limit :=
              l_pool_info.mx_dfcit_pct_pool_crs_num/100 * l_ledger_totals.prvdd_total;
            hr_utility.set_location('l_deficit_limit: '||l_deficit_limit,70);
            if abs(l_def_exc_amt) > l_deficit_limit then
              fnd_message.set_name('BEN', 'BEN_92620_EXCEED_TOT_DFCIT_PCT');
              fnd_message.raise_error;
            end if;
          end if;
          --
          --  Cannot exceed the maximum percent of compensation.
          --
          if l_pool_info.mx_dfcit_pct_comp_num is not null then
            --
            --  Get the compensation factor.
            --
            ben_derive_factors.determine_compensation
              (p_comp_lvl_fctr_id     => l_pool_info.comp_lvl_fctr_id
              ,p_person_id            => p_person_id
              ,p_per_in_ler_id        => p_per_in_ler_id
              ,p_pgm_id               => l_pool_info.pgm_id
              ,p_business_group_id    => p_business_group_id
              ,p_perform_rounding_flg => true
              ,p_effective_date       => p_effective_date
              ,p_value                => l_compensation_value
              );
            --
            l_deficit_limit :=
              l_pool_info.mx_dfcit_pct_comp_num/100 * l_compensation_value;
            hr_utility.set_location('l_deficit_limit_c: '||l_deficit_limit,70);
            if abs(l_def_exc_amt) > l_deficit_limit then
              fnd_message.set_name('BEN', 'BEN_92621_DFCIT_EXC_COMP_PCT');
              fnd_message.raise_error;
            end if;
          end if;
        end if;
      end if;
    end if;

    hr_utility.set_location(' auto_alct_excs_flag ' || l_pool_info.auto_alct_excs_flag , 998 );
    --if l_pool_info.auto_alct_excs_flag='Y' then
      -- to avoid bleeding of the output parameter l_dstrbtd_val it is initialised
      l_dstrbtd_val := 0;

      hr_utility.set_location(l_proc,80 );
      --
      -- get the dflt trtmt cd by executing the rule if necessary
      if l_pool_info.dflt_excs_trtmt_rl is not null then
         run_rule
            (p_effective_date     => p_effective_date
            ,p_person_id          => p_person_id
            ,p_dflt_excs_trtmt_rl => l_pool_info.dflt_excs_trtmt_rl
            ,p_business_group_id  => p_business_group_id
            ,p_acty_base_rt_id    => l_acty_base_rt_id
            ,p_elig_per_elctbl_chc_id    => l_elig_per_elctbl_chc_id
            ,p_ler_id             => l_ledger_totals.ler_id
            ,p_bnft_prvdr_pool_id => l_ledger_totals.bnft_prvdr_pool_id
            ,p_dflt_excs_trtmt_cd => l_pool_info.dflt_excs_trtmt_cd  -- output
            ,p_mx_val             => l_dummy); -- output
      end if;

      -- execute the appropriate sequence based on the dflt_excs_trtmt_cd
      --
      if l_pool_info.dflt_excs_trtmt_cd in ('DSTRBT_ALL','DSTRBT_RLOVR_FRFT') then
        hr_utility.set_location(l_proc,90 );
        distribute_credits
          (p_validate            => p_validate
          ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
          ,p_bnft_prvdr_pool_id  => l_ledger_totals.bnft_prvdr_pool_id
          ,p_acty_base_rt_id     => l_acty_base_rt_id
          ,p_per_in_ler_id       => p_per_in_ler_id
          ,p_dflt_excs_trtmt_cd  => l_pool_info.dflt_excs_trtmt_cd
          ,p_prvdd_val           => l_ledger_totals.prvdd_total
          ,p_rlld_up_val         => 0
          ,p_used_val            => l_ledger_totals.used_total
          ,p_rollover_val        => 0
          ,p_cash_recd_total     => l_ledger_totals.cash_recd_total
          ,p_val_rndg_cd         => l_pool_info.val_rndg_cd
          ,p_val_rndg_rl         => l_pool_info.val_rndg_rl
          ,p_pct_rndg_cd         => l_pool_info.pct_rndg_cd
          ,p_pct_rndg_rl         => l_pool_info.pct_rndg_rl
          ,p_mn_dstrbl_val       => l_pool_info.mn_dstrbl_val
          ,p_mn_dstrbl_pct_num   => l_pool_info.mn_dstrbl_pct_num
          ,p_mx_dstrbl_val       => l_pool_info.mx_dstrbl_val
          ,p_mx_pct              => l_pool_info.mx_dstrbl_pct_num
          ,p_person_id           => p_person_id
          ,p_enrt_mthd_cd        => p_enrt_mthd_cd
          ,p_effective_date      => p_effective_date
          ,p_business_group_id   => p_business_group_id
          ,p_dstrbtd_val         => l_dstrbtd_val
          ,p_bpl_cash_recd_val   => l_dummy_number
          ,p_bnft_prvdd_ldgr_id  => l_dummy_number
          );
          hr_utility.set_location( 'l_dstrbtd_val = ' || l_dstrbtd_val, 90);
      end if;

      if l_pool_info.dflt_excs_trtmt_cd in ('DSTRBT_RLOVR_FRFT','RLOVR_DSTRBT_FRFT') then
        hr_utility.set_location(l_proc,100 );
        if l_pool_info.auto_alct_excs_flag='Y' or l_default_enrt_flag = 'Y'  then
           default_rollovers(
             p_bnft_prvdr_pool_id      => l_ledger_totals.bnft_prvdr_pool_id,
             p_person_id               => p_person_id,
             p_effective_date          => p_effective_date,
             p_datetrack_mode          => l_datetrack_mode,
             p_business_group_id       => p_business_group_id,
             p_pct_rndg_cd             => l_pool_info.pct_rndg_cd,
             p_pct_rndg_rl             => l_pool_info.pct_rndg_rl,
             p_dflt_excs_trtmt_cd      => l_pool_info.dflt_excs_trtmt_cd,
             p_rollover_val            => l_rollover_val, -- returns the rollover change
             p_per_in_ler_id           => p_per_in_ler_id,
             p_enrt_mthd_cd            => p_enrt_mthd_cd);
             hr_utility.set_location( 'l_rollover_val = ' || l_rollover_val, 100);
         end if;
      end if ;

      if l_pool_info.dflt_excs_trtmt_cd ='RLOVR_DSTRBT_FRFT' then
        hr_utility.set_location(l_proc,90 );
	------Bug 7118730,set this flag to recalculate the ledger,
	     -----if used amount is more than provided amt.
        if l_ledger_totals.used_total > l_ledger_totals.prvdd_total
	        and l_rollover_val = 0 then
	    l_redis_credits := true;
            hr_utility.set_location('re-distribute the credits',90 );
        end if;

	------Bug 7118730

        distribute_credits
          (p_validate            => p_validate
          ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
          ,p_bnft_prvdr_pool_id  => l_ledger_totals.bnft_prvdr_pool_id
          ,p_acty_base_rt_id     => l_acty_base_rt_id
          ,p_dflt_excs_trtmt_cd  => l_pool_info.dflt_excs_trtmt_cd
          ,p_prvdd_val           => l_ledger_totals.prvdd_total
          ,p_rlld_up_val         => 0
          ,p_used_val            => l_ledger_totals.used_total
          ,p_rollover_val        => l_rollover_val
          ,p_cash_recd_total     => l_ledger_totals.cash_recd_total
          ,p_val_rndg_cd         => l_pool_info.val_rndg_cd
          ,p_val_rndg_rl         => l_pool_info.val_rndg_rl
          ,p_pct_rndg_cd         => l_pool_info.pct_rndg_cd
          ,p_pct_rndg_rl         => l_pool_info.pct_rndg_rl
          ,p_mn_dstrbl_val       => l_pool_info.mn_dstrbl_val
          ,p_mn_dstrbl_pct_num   => l_pool_info.mn_dstrbl_pct_num
          ,p_mx_dstrbl_val       => l_pool_info.mx_dstrbl_val
          ,p_mx_pct              => l_pool_info.mx_dstrbl_pct_num
          ,p_person_id           => p_person_id
          ,p_enrt_mthd_cd        => p_enrt_mthd_cd
          ,p_effective_date      => p_effective_date
          ,p_business_group_id   => p_business_group_id
          ,p_dstrbtd_val         => l_dstrbtd_val
          ,p_per_in_ler_id       => p_per_in_ler_id
          ,p_bpl_cash_recd_val   => l_dummy_number
          ,p_bnft_prvdd_ldgr_id  => l_dummy_number
          );
          hr_utility.set_location( 'l_dstrbtd_val = ' || l_dstrbtd_val, 101);
      end if;
      --
      if l_acty_base_rt_id is not null and l_pool_info.dflt_excs_trtmt_cd is not null then
        -- Bug#4473573 - added net credit method condition
        if l_dstrbtd_val < 0  and l_pool_info.uses_net_crs_mthd_flag <>'Y' then
            -- if it is negative, it gets added because of minus operator
           l_dstrbtd_val := 0;
        end if;
        forfeit_credits(
            p_validate            => p_validate,
            p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id,
            p_bnft_prvdr_pool_id  => l_ledger_totals.bnft_prvdr_pool_id,
            p_acty_base_rt_id     => l_acty_base_rt_id,
            p_prvdd_val           => l_ledger_totals.prvdd_total,
            p_rlld_up_val         => 0,
            p_used_val            => l_ledger_totals.used_total,
            p_rollover_val        => l_rollover_val,
            p_cash_val            => l_dstrbtd_val,
            p_effective_date      => p_effective_date,
            p_business_group_id   => p_business_group_id,
            p_frftd_val           => l_ledger_totals.frftd_total,
            p_per_in_ler_id       => p_per_in_ler_id,
            p_person_id           => p_person_id,
            p_enrt_mthd_cd         => p_enrt_mthd_cd
          );
       end if;
      hr_utility.set_location( 'l_dstrbtd_val = ' || l_dstrbtd_val, 102);
      hr_utility.set_location( 'l_rollover_val = ' || l_rollover_val, 102);
      hr_utility.set_location( 'frftd_total = ' || l_ledger_totals.frftd_total, 102);
      --
      -- If some are forfeited subtract from credit total
      --
      l_total_credits:=l_total_credits-l_ledger_totals.frftd_total;
      --
      hr_utility.set_location(l_proc,110 );
    --end if; -- if auto_alct_excs_flag='Y'
    --close c_pool_info;
    --
    if l_pool_info.uses_net_crs_mthd_flag = 'Y' then
      --
      l_uses_net_crs_mthd := true;
      --
      -- Check if there is a deficit amount.
      --
      if l_pool_info.auto_alct_excs_flag = 'Y' then
        l_def_exc_amount := l_def_exc_amount + nvl(l_dstrbtd_val,0);
      else
        l_def_exc_amount := l_def_exc_amount +
          (l_ledger_totals.prvdd_total - l_ledger_totals.used_total);
      end if;
      hr_utility.set_location('l_def_exc_amount: '||l_def_exc_amount,110 );
    end if;
    --
    --  Check if there is a total pool restriction.
    --
    for l_bpr_rec in c_get_mx_pct_roll_num loop
      for l_bpl_rec in c_get_ldgr(l_bpr_rec.acty_base_rt_id) loop
         if l_bpl_rec.used_val > ((l_bpr_rec.mx_pct_ttl_crs_cn_roll_num/100)
                         * l_ledger_totals.prvdd_total) then
          fnd_message.set_name('BEN', 'BEN_92636_TOT_POOL_PCT_EXCD');
          fnd_message.raise_error;
        end if;
      end loop;
    end loop;
    --
  end loop;
  close c_ledger_totals;
  hr_utility.set_location(l_proc,120 );

  ------Bug 7118730,recalculate the ledger and distribute the credits.
  if l_redis_credits then
  open c_ledger_totals;
    --
    fetch c_ledger_totals into l_ledger_totals;
    if c_ledger_totals%found then
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_location(l_proc, 55);
    hr_utility.set_location( 'prvdd_total = ' || l_ledger_totals.prvdd_total ||
                             'used_total = ' || l_ledger_totals.used_total ||
                             'frftd_total = ' || l_ledger_totals.frftd_total ||
                             'cash_recd_total = ' || l_ledger_totals.cash_recd_total, 55);
  if l_pool_info.dflt_excs_trtmt_cd ='RLOVR_DSTRBT_FRFT' then
        hr_utility.set_location(l_proc,90 );
        distribute_credits
          (p_validate            => p_validate
          ,p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
          ,p_bnft_prvdr_pool_id  => l_ledger_totals.bnft_prvdr_pool_id
          ,p_acty_base_rt_id     => l_acty_base_rt_id
          ,p_dflt_excs_trtmt_cd  => l_pool_info.dflt_excs_trtmt_cd
          ,p_prvdd_val           => l_ledger_totals.prvdd_total
          ,p_rlld_up_val         => 0
          ,p_used_val            => l_ledger_totals.used_total
          ,p_rollover_val        => l_rollover_val
          ,p_cash_recd_total     => l_ledger_totals.cash_recd_total
          ,p_val_rndg_cd         => l_pool_info.val_rndg_cd
          ,p_val_rndg_rl         => l_pool_info.val_rndg_rl
          ,p_pct_rndg_cd         => l_pool_info.pct_rndg_cd
          ,p_pct_rndg_rl         => l_pool_info.pct_rndg_rl
          ,p_mn_dstrbl_val       => l_pool_info.mn_dstrbl_val
          ,p_mn_dstrbl_pct_num   => l_pool_info.mn_dstrbl_pct_num
          ,p_mx_dstrbl_val       => l_pool_info.mx_dstrbl_val
          ,p_mx_pct              => l_pool_info.mx_dstrbl_pct_num
          ,p_person_id           => p_person_id
          ,p_enrt_mthd_cd        => p_enrt_mthd_cd
          ,p_effective_date      => p_effective_date
          ,p_business_group_id   => p_business_group_id
          ,p_dstrbtd_val         => l_dstrbtd_val
          ,p_per_in_ler_id       => p_per_in_ler_id
          ,p_bpl_cash_recd_val   => l_dummy_number
          ,p_bnft_prvdd_ldgr_id  => l_dummy_number
          );
          hr_utility.set_location( 'l_dstrbtd_val = ' || l_dstrbtd_val, 101);
      end if;
      --
      if l_acty_base_rt_id is not null and l_pool_info.dflt_excs_trtmt_cd is not null then
        -- Bug#4473573 - added net credit method condition
        if l_dstrbtd_val < 0  and l_pool_info.uses_net_crs_mthd_flag <>'Y' then
            -- if it is negative, it gets added because of minus operator
           l_dstrbtd_val := 0;
        end if;
        forfeit_credits(
            p_validate            => p_validate,
            p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id,
            p_bnft_prvdr_pool_id  => l_ledger_totals.bnft_prvdr_pool_id,
            p_acty_base_rt_id     => l_acty_base_rt_id,
            p_prvdd_val           => l_ledger_totals.prvdd_total,
            p_rlld_up_val         => 0,
            p_used_val            => l_ledger_totals.used_total,
            p_rollover_val        => l_rollover_val,
            p_cash_val            => l_dstrbtd_val,
            p_effective_date      => p_effective_date,
            p_business_group_id   => p_business_group_id,
            p_frftd_val           => l_ledger_totals.frftd_total,
            p_per_in_ler_id       => p_per_in_ler_id,
            p_person_id           => p_person_id,
            p_enrt_mthd_cd         => p_enrt_mthd_cd
          );
       end if;
      hr_utility.set_location( 'l_dstrbtd_val = ' || l_dstrbtd_val, 102);
      hr_utility.set_location( 'l_rollover_val = ' || l_rollover_val, 102);
      hr_utility.set_location( 'frftd_total = ' || l_ledger_totals.frftd_total, 102);
      hr_utility.set_location( 'Re-distributed credits', 102);
  end if;
  close c_ledger_totals;
   end if;
  ------Bug 7118730
  --
  -- create/update the result row and create prv
  --
  if p_prtt_enrt_rslt_id is not null then
    --
    --  If one of the pools is using the net credit method.
    --
    if l_uses_net_crs_mthd then
      --
      --  Write an enrollment result for the excess/deficit amount.
      --
      hr_utility.set_location('l_def_exc_amount'||l_def_exc_amount,110 );
      hr_utility.set_location('prvdd_total'||l_ledger_totals.prvdd_total,110 );
      hr_utility.set_location('used_total'||l_ledger_totals.used_total,110 );
      create_flex_credit_enrolment
       (p_person_id             => p_person_id,
        p_enrt_mthd_cd          => p_enrt_mthd_cd,
        p_business_group_id     => p_business_group_id,
        p_effective_date        => p_effective_date,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_prtt_rt_val_id        => p_prtt_rt_val_id,
        p_per_in_ler_id         => p_per_in_ler_id,
        p_rt_val                => null,
        p_net_credit_val        => l_def_exc_amount,
        p_pgm_id                => p_pgm_id
       );
    end if;
    --
    hr_utility.set_location('calling create_flex,total_credits='||to_char(l_total_credits),130);
    create_flex_credit_enrolment(
        p_person_id             => p_person_id,
        p_enrt_mthd_cd          => p_enrt_mthd_cd,
        p_business_group_id     => p_business_group_id,
        p_effective_date        => p_effective_date,
        p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
        p_prtt_rt_val_id        => p_prtt_rt_val_id,
        p_per_in_ler_id         => p_per_in_ler_id,
        p_rt_val                => l_total_credits,
        p_pgm_id                => p_pgm_id
    );
    hr_utility.set_location(l_proc, 140);
    open c_element_details;
    fetch c_element_details into
        p_acty_ref_perd_cd,
        p_acty_base_rt_id,
        p_rt_strt_dt,
        p_rt_val,
        p_element_type_id
    ;
    close c_element_details;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 999);
  --
end total_pools;
--
--------------------------------------------------------------------------------
--                      update_rate
--------------------------------------------------------------------------------
procedure update_rate(p_prtt_rt_val_id      in out nocopy number,
                      p_val                 in  number,
                      p_prtt_enrt_rslt_id   in  number,
                      p_ended_per_in_ler_id in  number,
                      p_effective_date      in  date,
                      p_business_group_id   in  number) is
   --
   cursor c_prv is
      select prv.*
      from   ben_prtt_rt_val prv
      where  prv.prtt_rt_val_id = p_prtt_rt_val_id
      and    prv.prtt_rt_val_stat_cd is null;
   --
   l_prv_rec     c_prv%rowtype;
   --
   cursor c_pen is
      select pen.pgm_id,
             pen.pl_id,
             pen.oipl_id,
             pen.person_id,
             pen.ler_id
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    pen.business_group_id  = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    p_effective_date between
             pen.effective_start_date and pen.effective_end_date;
   --
   l_pen_rec  c_pen%rowtype;
   --
   cursor c_abr is
      select abr.input_value_id,
             abr.element_type_id
      from   ben_acty_base_rt_f abr
      where  abr.acty_base_rt_id = l_prv_rec.acty_base_rt_id
      and    abr.business_group_id  = p_business_group_id
      and    p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
   --
   l_abr_rec   c_abr%rowtype;
   --
   cursor c_ecr is
      select nvl(ecr1.enrt_rt_id, ecr2.enrt_rt_id) enrt_rt_id
      from   ben_enrt_rt ecr1,
             ben_enrt_rt ecr2,
             ben_elig_per_elctbl_chc epe,
             ben_enrt_bnft           enb
      where  epe.per_in_ler_id = p_ended_per_in_ler_id
      and    ecr1.prtt_rt_val_id(+) = p_prtt_rt_val_id
      and    ecr2.prtt_rt_val_id(+) = p_prtt_rt_val_id
      and    epe.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
      and    epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id (+)
      and    enb.enrt_bnft_id = ecr2.enrt_bnft_id(+);
   --
   -- Bug 2386000
   CURSOR c_lee_rsn_for_plan (c_ler_id number, c_pl_id number ) IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pl_id                 = c_pl_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
   --
   CURSOR c_lee_rsn_for_program (c_ler_id number, c_pgm_id number )IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pgm_id                = c_pgm_id
      AND      petc.enrt_typ_cycl_cd      = 'L'
      AND      petc.business_group_id     = p_business_group_id
      AND      p_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
   --
   cursor c_pil is
     select ler_id
     from ben_per_in_ler pil
     where pil.per_in_ler_id = p_ended_per_in_ler_id;
   --
   l_lee_rsn_id                number := null ;
   --
   l_enrt_cvg_strt_dt          date;
   l_enrt_cvg_strt_dt_cd       varchar2(30);
   l_enrt_cvg_strt_dt_rl       number;
   l_rt_strt_dt                date;
   l_rt_strt_dt_cd             varchar2(30);
   l_rt_strt_dt_rl             number;
   l_enrt_cvg_end_dt           date;
   l_enrt_cvg_end_dt_cd        varchar2(30);
   l_enrt_cvg_end_dt_rl        number;
   l_rt_end_dt                 date;
   l_rt_end_dt_cd              varchar2(30);
   l_rt_end_dt_rl              number;
   l_enrt_rt_id                number;
   l_ler_id                    number;
   --
  l_proc varchar2(80) := g_package||'.update_rate';
   --
begin
   --
   hr_utility.set_location('Entering '||l_proc,5);
   --
   open  c_prv;
   fetch c_prv into l_prv_rec;
   close c_prv;
   --
   open  c_pen;
   fetch c_pen into l_pen_rec;
   close c_pen;
   --
   open  c_abr;
   fetch c_abr into l_abr_rec;
   close c_abr;
   --
   open  c_ecr;
   fetch c_ecr into l_enrt_rt_id;
   close c_ecr;
   --
   --  during ineligible process the ler_id is not updated on Shell plan if the update
   --  rate is called before shell plan deenrollment and therefore it is
   --  better to take the ler_id from ending per_in_ler_id so that the rate end date
   --  is calculated correctly
   open c_pil;
   fetch c_pil into l_ler_id;
   close c_pil;
   --
   open c_lee_rsn_for_plan(l_ler_id, l_pen_rec.pl_id );
   fetch c_lee_rsn_for_plan into l_lee_rsn_id ;
   close c_lee_rsn_for_plan ;
   --
   if l_lee_rsn_id is null and l_pen_rec.pgm_id is not null then
     open c_lee_rsn_for_program(l_ler_id, l_pen_rec.pgm_id);
     fetch c_lee_rsn_for_program into l_lee_rsn_id ;
     close c_lee_rsn_for_program ;
   end if;
   --
   hr_utility.set_location(l_proc,10);
   --
   ben_determine_date.rate_and_coverage_dates(
         p_which_dates_cd          => 'R',
         p_pgm_id                  => l_pen_rec.pgm_id,
         p_pl_id                   => l_pen_rec.pl_id,
         p_oipl_id                 => l_pen_rec.oipl_id,
         p_per_in_ler_id           => p_ended_per_in_ler_id,
         p_lee_rsn_id              => l_lee_rsn_id,
         p_person_id               => l_pen_rec.person_id,
         p_business_group_id       => p_business_group_id,
         p_enrt_cvg_strt_dt        => l_enrt_cvg_strt_dt,
         p_enrt_cvg_strt_dt_cd     => l_enrt_cvg_strt_dt_cd,
         p_enrt_cvg_strt_dt_rl     => l_enrt_cvg_strt_dt_rl,
         p_rt_strt_dt              => l_rt_strt_dt,
         p_rt_strt_dt_cd           => l_rt_strt_dt_cd,
         p_rt_strt_dt_rl           => l_rt_strt_dt_rl,
         p_enrt_cvg_end_dt         => l_enrt_cvg_end_dt,
         p_enrt_cvg_end_dt_cd      => l_enrt_cvg_end_dt_cd,
         p_enrt_cvg_end_dt_rl      => l_enrt_cvg_end_dt_rl,
         p_rt_end_dt               => l_rt_end_dt,
         p_rt_end_dt_cd            => l_rt_end_dt_cd,
         p_rt_end_dt_rl            => l_rt_end_dt_rl,
         p_effective_date          => p_effective_date
          );
   --
   hr_utility.set_location(l_proc,15);
   --
   if l_prv_rec.rt_strt_dt >= l_rt_strt_dt then
      --
      ben_prtt_rt_val_api.delete_prtt_rt_val(
          p_prtt_rt_val_id                => p_prtt_rt_val_id
         ,p_enrt_rt_id                    => l_enrt_rt_id
         ,p_person_id                     => l_pen_rec.person_id
         ,p_business_group_id             => p_business_group_id
         ,p_object_version_number         => l_prv_rec.object_version_number
         ,p_effective_date                => p_effective_date
       );
      --
   else
      --
      ben_prtt_rt_val_api.update_prtt_rt_val(
          p_prtt_rt_val_id                => p_prtt_rt_val_id
         ,p_rt_end_dt                     => l_rt_end_dt
         ,p_ended_per_in_ler_id           => p_ended_per_in_ler_id
         ,p_acty_base_rt_id               => l_prv_rec.acty_base_rt_id
         ,p_input_value_id                => l_abr_rec.input_value_id
         ,p_element_type_id               => l_abr_rec.element_type_id
         ,p_person_id                     => l_pen_rec.person_id
         ,p_business_group_id             => p_business_group_id
         ,p_object_version_number         => l_prv_rec.object_version_number
         ,p_effective_date                => p_effective_date
   );
   end if;
   --
   hr_utility.set_location(l_proc,20);
   --
   -- Bug#2441871
   if l_enrt_rt_id is not null then
     --
       ben_prtt_rt_val_api.create_prtt_rt_val(
          p_prtt_rt_val_id                 => p_prtt_rt_val_id
         ,p_enrt_rt_id                     => l_enrt_rt_id
         ,p_per_in_ler_id                  => p_ended_per_in_ler_id
         ,p_rt_typ_cd                      => l_prv_rec.rt_typ_cd
         ,p_tx_typ_cd                      => l_prv_rec.tx_typ_cd
         ,p_acty_typ_cd                    => l_prv_rec.acty_typ_cd
         ,p_mlt_cd                         => l_prv_rec.mlt_cd
         ,p_acty_ref_perd_cd               => l_prv_rec.acty_ref_perd_cd
         ,p_rt_val                         => p_val
         ,p_rt_strt_dt                     => l_rt_strt_dt
         ,p_rt_end_dt                      => hr_api.g_eot
         ,p_ann_rt_val                     => null
         ,p_bnft_rt_typ_cd                 => l_prv_rec.bnft_rt_typ_cd
         ,p_cmcd_ref_perd_cd               => l_prv_rec.cmcd_ref_perd_cd
         ,p_cmcd_rt_val                    => p_val
         ,p_dsply_on_enrt_flag             => l_prv_rec.dsply_on_enrt_flag
         ,p_elctns_made_dt                 => p_effective_date
         ,p_cvg_amt_calc_mthd_id           => l_prv_rec.cvg_amt_calc_mthd_id
         ,p_actl_prem_id                   => l_prv_rec.actl_prem_id
         ,p_comp_lvl_fctr_id               => l_prv_rec.comp_lvl_fctr_id
         ,p_prtt_enrt_rslt_id              => p_prtt_enrt_rslt_id
         ,p_business_group_id              => p_business_group_id
         ,p_object_version_number          => l_prv_rec.object_version_number
         ,p_effective_date                 => p_effective_date
         ,p_acty_base_rt_id                => l_prv_rec.acty_base_rt_id
         ,p_input_value_id                 => l_abr_rec.input_value_id
         ,p_element_type_id                => l_abr_rec.element_type_id
         ,p_person_id                      => l_pen_rec.person_id
         ,p_ordr_num               => l_prv_rec.ordr_num
           );
      --
   End if;
   --
   hr_utility.set_location('Leaving '||l_proc,5);
   --
end update_rate;
--
--------------------------------------------------------------------------------
--                      delete_all_ledgers
--------------------------------------------------------------------------------
procedure delete_all_ledgers(p_bnft_prvdr_pool_id in number,
                             p_flex_rslt_id       in number,
                             p_person_id          in number,
                             p_per_in_ler_id      in number,
                             p_effective_date     in date,
                             p_business_group_id  in number) is
   --
   -- All ledgers for the pool.
   --
   cursor c_bpl is
      select bpl.bnft_prvdd_ldgr_id,
             bpl.object_version_number,
             bpl.effective_start_date,
             bpl.acty_base_rt_id,
             bpl.prtt_ro_of_unusd_amt_flag,
             bpl.used_val
      from   ben_bnft_prvdd_ldgr_f bpl,
             ben_per_in_ler pil
      where  bpl.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
      and    bpl.prtt_enrt_rslt_id = p_flex_rslt_id
      and    bpl.business_group_id  = p_business_group_id
      and    p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
order by prtt_ro_of_unusd_amt_flag
/* Bug 5344961 - Added the above order by clause. This is because if a ROLLOVER (prtt_ro_of_unusd_amt_flag=Y)
BPL row is picked up earlier, we will delete the corresponding enrollment. This in a typical scenario (see bug)
will delete all provided BPL rows in that program. So if cursor C_BPL then tries to delete such BPL row
we will get an error. This typical scenario is when the rollover plan is same as the plan that has
used flex credits */
;
   --
   -- Result record for rollover ledgers.
   --
   cursor c_pen(v_acty_base_rt_id in number) is
      select pen.prtt_enrt_rslt_id,
             pen.object_version_number,
             pen.effective_start_date,
             abr.entr_val_at_enrt_flag,
             prv.prtt_rt_val_id,
             prv.rt_val
      from   ben_prtt_enrt_rslt_f pen,
             ben_prtt_rt_val      prv,
             ben_acty_base_rt_f   abr
      where  prv.acty_base_rt_id = v_acty_base_rt_id
      and    prv.business_group_id  = p_business_group_id
      and    prv.prtt_rt_val_stat_cd is null
      and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and    pen.person_id = p_person_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    pen.enrt_cvg_thru_dt = hr_api.g_eot
      and    p_effective_date between
             pen.effective_start_date and pen.effective_end_date
      and    prv.acty_base_rt_id = abr.acty_base_rt_id
      and    p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
   --
   l_effective_start_date     date;
   l_effective_end_date       date;
   l_effective_date           date;
   l_datetrack_mode           varchar2(30);
   l_prtt_enrt_rslt_id        number;
   l_pen_object_version_number number;
   l_pen_effective_start_date  date;
   l_entr_val_at_enrt_flag     varchar2(30);
   l_prtt_rt_val_id            number;
   l_rt_val                    number;
   --
  l_proc varchar2(80) := g_package||'.delete_all_ledgers';
   --
begin
   --
   hr_utility.set_location('Enetering '||l_proc, 5);
   for l_bpl_rec in c_bpl loop
      --
      hr_utility.set_location(l_proc,10);
      if p_effective_date = l_bpl_rec.effective_start_date then
         --
         l_datetrack_mode := hr_api.g_zap;
         l_effective_date := p_effective_date;
         --
      else
         --
         l_datetrack_mode := hr_api.g_delete;
         l_effective_date := p_effective_date -1;
         --
      end if;
      --
      ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
           p_validate              => false,
           p_bnft_prvdd_ldgr_id    => l_bpl_rec.bnft_prvdd_ldgr_id,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_object_version_number => l_bpl_rec.object_version_number,
           p_effective_date        => l_effective_date,
           p_datetrack_mode        => l_datetrack_mode,
           p_business_group_id     => p_business_group_id,
           p_process_enrt_flag => 'N');
      --
      -- Check whether rollovers are attached.
      --
      hr_utility.set_location(l_proc,15);
      if l_bpl_rec.prtt_ro_of_unusd_amt_flag = 'Y' then
         --
         hr_utility.set_location(l_proc,20);
         open  c_pen(l_bpl_rec.acty_base_rt_id);
         fetch c_pen into l_prtt_enrt_rslt_id,
                          l_pen_object_version_number,
                          l_pen_effective_start_date,
                          l_entr_val_at_enrt_flag,
                          l_prtt_rt_val_id,
                          l_rt_val;
         close c_pen;
         --
         -- If enter value at enrollment, we need to keep the
         -- enrollment. Just reduce the rate by the rollover amount.
         --
         if l_entr_val_at_enrt_flag = 'Y' then
            --
            update_rate(p_prtt_rt_val_id    => l_prtt_rt_val_id,
                        p_val        => (l_rt_val-l_bpl_rec.used_val),
                        p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id,
                        p_ended_per_in_ler_id => p_per_in_ler_id,
                        p_effective_date => p_effective_date,
                        p_business_group_id => p_business_group_id);
            --
         elsif l_prtt_enrt_rslt_id is  not null then
            --
            -- If enter value at enrollment flag is off, delete the
            -- enrollment.
            --
            if p_effective_date = l_pen_effective_start_date then
               --
               l_datetrack_mode := hr_api.g_zap;
               --
            else
               --
               l_datetrack_mode := hr_api.g_delete;
               --
            end if;
            --
            ben_prtt_enrt_result_api.delete_enrollment(
                              p_prtt_enrt_rslt_id  => l_prtt_enrt_rslt_id,
                              p_per_in_ler_id      => p_per_in_ler_id,
                              p_object_version_number => l_pen_object_version_number,
                              p_effective_start_date => l_effective_start_date,
                              p_effective_end_date   => l_effective_end_date,
                              p_effective_date       => p_effective_date,
                              p_business_group_id    => p_business_group_id,
                              p_datetrack_mode       => l_datetrack_mode,
                              p_source               => 'benpstcr');
            --
         end if;
         --
      end if;
      --
   end loop;
   --
   hr_utility.set_location('Leaving '||l_proc,5);
   --
end delete_all_ledgers;
--
--------------------------------------------------------------------------------
--                      compute_rollovers
--------------------------------------------------------------------------------
procedure compute_rollovers
  (p_calculate_only_mode in     boolean default false
  ,p_bnft_prvdr_pool_id  in     number
  ,p_flex_rslt_id        in     number
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  ,p_pct_rndg_cd         in     varchar2
  ,p_pct_rndg_rl         in     number
  ,p_dflt_excs_trtmt_cd  in     varchar2
  ,p_rollover_val           out nocopy number
  )
is
  l_datetrack_mode varchar2(30);
  l_effective_end_date date;
  l_object_version_number number;
  l_effective_start_date date;
  l_prvdd_val number;
  l_recd_val number;
  l_used_val number;
  l_acty_base_rt_id number;
  l_balance number;
  l_mn_dstrbl_pct_num number;
  l_mx_dstrbl_pct_num number;
  l_old_rlovr_val number;
  l_cash_val number;
  l_bnft_prvdd_ldgr_id number;
  l_rld_ovr_val number;
  l_rollover_diff_total number;
  l_prtt_enrt_rslt_id   number;
  l_prtt_rt_val_id      number;
  l_rt_val              number;
  l_qualify_flag varchar2(30);
  l_outputs     ff_exec.outputs_t;
  --
  -- Query will get the rollover and enrollment information
  --
  cursor c_rollovers is
    select
        prr.mn_rlovr_pct_num,
        prr.mn_rlovr_val,
        prr.mx_rchd_dflt_ordr_num,
        prr.mx_rlovr_pct_num,
        prr.mx_rlovr_val,
        prr.pct_rlovr_incrmt_num,
        prr.pct_rndg_cd,
        prr.pct_rndg_rl,
        prr.rlovr_val_incrmt_num,
        prr.rlovr_val_rl,
        prr.val_rndg_cd,
        prr.val_rndg_rl,
        prr.acty_base_rt_id,
        rslt.prtt_enrt_rslt_id,
        prv.rt_val,
        prv.prtt_rt_val_id,
        prr.prtt_elig_rlovr_rl,
        asg.assignment_id,
        asg.organization_id,
        loc.region_2,
        oipl.opt_id,
        rslt.pl_id,
        rslt.pgm_id,
        rslt.ler_id,
        rslt.pl_typ_id
    from
        ben_bnft_pool_rlovr_rqmt_f prr,
        ben_prtt_rt_val prv,
        ben_prtt_enrt_rslt_f rslt,
        per_all_assignments_f asg,
        hr_locations_all loc,
        ben_oipl_f oipl
    where
        prr.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
        prr.business_group_id=p_business_group_id and
        p_effective_date between
        prr.effective_start_date and prr.effective_end_date and
        prv.acty_base_rt_id = prr.acty_base_rt_id and
        prv.prtt_enrt_rslt_id = rslt.prtt_enrt_rslt_id  and
        rslt.person_id=p_person_id and
        rslt.business_group_id=p_business_group_id and
        rslt.prtt_enrt_rslt_stat_cd is null and
        rslt.enrt_cvg_thru_dt = hr_api.g_eot and
        prv.business_group_id =p_business_group_id and
        prv.prtt_rt_val_stat_cd is null and
        p_effective_date between
        rslt.effective_start_date and rslt.effective_end_date and
        asg.person_id=rslt.person_id and
        asg.assignment_type <> 'C'and
        asg.primary_flag='Y' and
        asg.location_id = loc.location_id(+) and
        p_effective_date between
        asg.effective_start_date and asg.effective_end_date and
        oipl.oipl_id(+)=rslt.oipl_id and
        p_effective_date between
        oipl.effective_start_date(+) and oipl.effective_end_date(+) and
        oipl.business_group_id(+)=p_business_group_id
    order by prr.mx_rchd_dflt_ordr_num
    ;
  --
  -- Ledger totals for the pool.
  --
  cursor c_ledger_totals is
    select
                nvl(sum(bpl.prvdd_val),0),
                nvl(sum(decode(bpl.prtt_ro_of_unusd_amt_flag,
                               'N',bpl.used_val,
                                0)),0),-- non rollovers
                nvl(sum(bpl.cash_recd_val),0),
                nvl(sum(decode(bpl.prtt_ro_of_unusd_amt_flag,
                               'Y',bpl.used_val,
                                0)),0) -- rollovers
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_per_in_ler pil
    where       p_effective_date between
                        bpl.effective_start_date and bpl.effective_end_date and
                bpl.business_group_id=p_business_group_id and
                bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
                bpl.prtt_enrt_rslt_id = p_flex_rslt_id and
                -- exclude the rollover for this abr
                (bpl.acty_base_rt_id<>l_acty_base_rt_id or
                -- but include the used amounts for this abr
                bpl.prtt_ro_of_unusd_amt_flag='N')
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     group by bpl.bnft_prvdr_pool_id;
  --
  -- get the ledger details for rollover.
  --
  cursor c_old_ledger is
    select
                bnft_prvdd_ldgr_id,
                bpl.used_val,
                bpl.object_version_number,
                bpl.effective_start_date
    from        ben_bnft_prvdd_ldgr_f bpl,
                ben_per_in_ler pil
    where       p_effective_date between
                bpl.effective_start_date and bpl.effective_end_date and
                bpl.business_group_id=p_business_group_id and
                bpl.bnft_prvdr_pool_id=p_bnft_prvdr_pool_id and
                bpl.prtt_enrt_rslt_id = p_flex_rslt_id and
                bpl.acty_base_rt_id = l_acty_base_rt_id and
                bpl.prtt_ro_of_unusd_amt_flag = 'Y'
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
;
  --
  -- Rate record to update, if the rollover amount has changed.
  --
  cursor c_prv (c_per_in_ler_id number) is -- 5257226: added parameter
     select prv.prtt_rt_val_id,
            prv.rt_val,
            prv.rt_strt_dt
     from   ben_prtt_rt_val prv -- ,ben_prtt_enrt_rslt_f pen
     where  prv.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
     and    prv.acty_base_rt_id = l_acty_base_rt_id
     and    prv.prtt_rt_val_stat_cd is null
     and    prv.business_group_id  = p_business_group_id
     and    (prv.per_in_ler_id = c_per_in_ler_id  or c_per_in_ler_id = -1 ) -- bug#5136668 -only for that lf event
     order by prv.rt_strt_dt desc;
  --
  cursor c_epe is
     select elig_per_elctbl_chc_id
     from ben_elig_per_elctbl_chc
     where prtt_enrt_rslt_id = l_prtt_enrt_rslt_id;
  --
  l_elig_per_elctbl_chc_id number;
  l_proc                 varchar2(80) := g_package||'.compute_rollovers';
  l_jurisdiction_code    varchar2(30);
  l_dummy                varchar2(80);
  l_rt_strt_dt           date;
   --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Running total for the rollover.
  --
  l_rollover_diff_total:=0;
  --
  for l_rollover in c_rollovers loop
    --
    l_prtt_enrt_rslt_id := l_rollover.prtt_enrt_rslt_id;
    --
    -- If rule exists run if and see if qualifies for rollover
    --
    if l_rollover.prtt_elig_rlovr_rl is not null then
      --
      -- execute rule
      --
      -- Get the l_elig_per_elctbl_chc_id associated with the result
      -- to be passed to formula as context.
      --
      open c_epe;
      fetch c_epe into l_elig_per_elctbl_chc_id;
      close c_epe;

  --    if l_rollover.region_2 is not null then
  --          pay_mag_utils.lookup_jurisdiction_code
  --           (p_state => l_rollover.region_2);
  --    end if;

      l_outputs := benutils.formula
            (p_formula_id           => l_rollover.prtt_elig_rlovr_rl,
             p_assignment_id        => l_rollover.assignment_id,
             p_organization_id      => l_rollover.organization_id,
             p_business_group_id    => p_business_group_id,
             p_effective_date       => p_effective_date,
             p_opt_id               => l_rollover.opt_id,
             p_pl_id                => l_rollover.pl_id,
             p_pgm_id               => l_rollover.pgm_id,
             p_ler_id               => l_rollover.ler_id,
             p_pl_typ_id            => l_rollover.pl_typ_id,
             p_elig_per_elctbl_chc_id            => l_elig_per_elctbl_chc_id,
             p_jurisdiction_code    => l_jurisdiction_code);

      l_qualify_flag := l_outputs(l_outputs.first).value;
    else
      l_qualify_flag:='Y';
    end if;
    --
    if l_qualify_flag='Y' then
      --
      -- Process this rollover
      --
      hr_utility.set_location(l_proc, 20);
      l_acty_base_rt_id:=l_rollover.acty_base_rt_id;
      --
      -- Get the ledger totals with exclusions (see cursor)
      --
      open c_ledger_totals;
      fetch c_ledger_totals into
          l_prvdd_val,
          l_used_val,
          l_recd_val,
          l_rld_ovr_val;
      close c_ledger_totals;
      --
      -- depending on the excess treatment code compute the balance
      --
      if p_dflt_excs_trtmt_cd in ('DSTRBT_ALL','DSTRBT_RLOVR_FRFT') then
        hr_utility.set_location(l_proc, 30);
        l_balance:=l_prvdd_val-l_used_val-l_recd_val-l_rld_ovr_val;
      else
        hr_utility.set_location(l_proc, 40);
        l_balance:=l_prvdd_val-l_used_val-l_rld_ovr_val;
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- round the balance
      --
      if l_rollover.val_rndg_cd is not null then
        l_balance:=benutils.do_rounding(
          p_rounding_cd    => l_rollover.val_rndg_cd,
          p_rounding_rl    => l_rollover.val_rndg_rl,
          p_value          => l_balance,
          p_effective_date => p_effective_date);
      end if;
      --
      -- set value to less than the maximums
      -- do this before minimums since if any max is less than any minimum should skip it.
      --
      -- set balance to max pct if defined and < balance
      --
      if l_rollover.mx_rlovr_pct_num is not null then
        l_mx_dstrbl_pct_num:=(l_prvdd_val-l_used_val)*l_rollover.mx_rlovr_pct_num/100;
        if p_pct_rndg_cd is not null then
          l_mx_dstrbl_pct_num:=benutils.do_rounding(
            p_rounding_cd    => p_pct_rndg_cd,
            p_rounding_rl    => p_pct_rndg_rl,
            p_value          => l_mx_dstrbl_pct_num,
            p_effective_date => p_effective_date);
        end if;
        if l_balance > l_mx_dstrbl_pct_num then
          l_balance:=l_mx_dstrbl_pct_num;
        end if;
      end if;
      --
      -- Set balance to max amount if define and > balance
      --
      if l_rollover.mx_rlovr_val is not null and
         l_balance > l_rollover.mx_rlovr_val then
        l_balance:=l_rollover.mx_rlovr_val;
      end if;
            -- Check the rlover rule - this is a max val rule.
      if l_rollover.rlovr_val_rl is not null then
          run_rule
            (p_effective_date     => p_effective_date
            ,p_person_id          => p_person_id
            ,p_rlovr_val_rl       => l_rollover.rlovr_val_rl
            ,p_business_group_id  => p_business_group_id
            ,p_ler_id             => l_rollover.ler_id
            ,p_bnft_prvdr_pool_id => p_bnft_prvdr_pool_id
            ,p_dflt_excs_trtmt_cd => l_dummy  -- output
            ,p_elig_per_elctbl_chc_id            => l_elig_per_elctbl_chc_id
            ,p_mx_val             => l_rollover.mx_rlovr_val); -- output

         if l_rollover.mx_rlovr_val is not null and
            l_balance > l_rollover.mx_rlovr_val then
            l_balance:=l_rollover.mx_rlovr_val;
         end if;
      end if;

      --
      -- compute the min pct value
      --
      l_mn_dstrbl_pct_num:=(l_prvdd_val-l_used_val)*l_rollover.mn_rlovr_pct_num/100;
      if p_pct_rndg_cd is not null then
        l_mn_dstrbl_pct_num:=benutils.do_rounding(
          p_rounding_cd    => p_pct_rndg_cd,
          p_rounding_rl    => p_pct_rndg_rl,
          p_value          => l_mn_dstrbl_pct_num,
          p_effective_date => p_effective_date);
      end if;
      --
      -- if less than mimimums cannot rollover, skip it.
      --
      if (l_balance < l_rollover.mn_rlovr_val or
          l_balance < l_mn_dstrbl_pct_num or
          l_balance <=0 ) then
        hr_utility.set_location('Balance less than minimum or zero',60);
        --
        -- nothing to do
        --
        null;
        --
      else
        hr_utility.set_location(l_proc, 70);
        --
        open c_old_ledger;
        fetch c_old_ledger into
          l_bnft_prvdd_ldgr_id,
          l_old_rlovr_val,
          l_object_version_number,
          l_effective_start_date
        ;
        --
        -- perform rollover
        --
        hr_utility.set_location(l_proc, 80);
        if c_old_ledger%notfound
          and not p_calculate_only_mode
        then
          hr_utility.set_location(l_proc, 90);
          --
          -- Check the rollover plan is already enrolled.
          -- If not, no rollovers to be attached to this plan.
          --
          open  c_prv( p_per_in_ler_id );
          fetch c_prv into l_prtt_rt_val_id,
                           l_rt_val,l_rt_strt_dt;
          --
          if c_prv%found then
             --
             l_rollover_diff_total:=l_rollover_diff_total+l_balance;
             ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger (
                        p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
                       ,p_effective_start_date         => l_effective_start_date
                       ,p_effective_end_date           => l_effective_end_date
                       ,p_prtt_ro_of_unusd_amt_flag    => 'Y'
                       ,p_frftd_val                    => null
                       ,p_prvdd_val                    => null
                       ,p_used_val                     => l_balance
                       ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
                       ,p_acty_base_rt_id              => l_acty_base_rt_id
                       ,p_per_in_ler_id                => p_per_in_ler_id
                       ,p_person_id                    => p_person_id
                       ,p_enrt_mthd_cd                 => p_enrt_mthd_cd
                       ,p_prtt_enrt_rslt_id            => p_flex_rslt_id
                       ,p_business_group_id            => p_business_group_id
                       ,p_object_version_number        => l_object_version_number
                       ,p_cash_recd_val                => null
                       ,p_effective_date               => p_effective_date
                       ,p_process_enrt_flag            => 'N'
             );
             hr_utility.set_location('CREATED LDGR ID='||to_char(l_bnft_prvdd_ldgr_id),100);
             --
             -- Update the rollover plan rate to reflect rollovers.
             --
             update_rate(p_prtt_rt_val_id   => l_prtt_rt_val_id,
                         p_val      => (l_rt_val + l_balance),
                         p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id,
                         p_ended_per_in_ler_id => p_per_in_ler_id,
                         p_effective_date  => p_effective_date,
                         p_business_group_id => p_business_group_id);
             --
          end if;
          --
          close c_prv;
          --
        elsif l_old_rlovr_val<>l_balance
          and not p_calculate_only_mode
        then
          --
          -- Update the ledger if the amount differs.
          --
          hr_utility.set_location(l_proc, 110);
          /*
          if l_effective_start_date=p_effective_date then
            l_datetrack_mode:=hr_api.g_correction;
          else
            l_datetrack_mode:=hr_api.g_update;
          end if;
          */
          Get_DT_Upd_Mode
                 (p_effective_date        => p_effective_date,
                  p_base_table_name       => 'BEN_BNFT_PRVDD_LDGR_F',
                  p_base_key_column       => 'BNFT_PRVDD_LDGR_ID',
                  p_base_key_value        => l_bnft_prvdd_ldgr_id,
                  p_mode                  => l_datetrack_mode);
          hr_utility.set_location('UPDATING LEDGER ID='||to_char(l_bnft_prvdd_ldgr_id),120);
          l_rollover_diff_total:=l_rollover_diff_total+l_balance-l_old_rlovr_val;
          ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
                     p_bnft_prvdd_ldgr_id         => l_bnft_prvdd_ldgr_id
                    ,p_effective_start_date       => l_effective_start_date
                    ,p_effective_end_date         => l_effective_end_date
                    ,p_prtt_ro_of_unusd_amt_flag  => 'Y'
                    ,p_frftd_val                  => null
                    ,p_prvdd_val                  => null
                    ,p_used_val                   => l_balance
                    ,p_bnft_prvdr_pool_id         => p_bnft_prvdr_pool_id
                    ,p_acty_base_rt_id            => l_acty_base_rt_id
                    ,p_per_in_ler_id              => p_per_in_ler_id
                    ,p_prtt_enrt_rslt_id          => p_flex_rslt_id
                    ,p_business_group_id          => p_business_group_id
                    ,p_object_version_number      => l_object_version_number
                    ,p_cash_recd_val              => 0
                    ,p_effective_date             => p_effective_date
                    ,p_datetrack_mode             => l_datetrack_mode
                    ,p_process_enrt_flag          => 'N'
          );
          hr_utility.set_location('UPDATED LEDGER ID='||To_char(l_bnft_prvdd_ldgr_id),130);
          --
          open  c_prv(-1);
          fetch c_prv into l_prtt_rt_val_id,
                           l_rt_val, l_rt_strt_dt;
          close c_prv;
          --
          -- Update the rollover plan rate to reflect rollovers.
          --
          update_rate(p_prtt_rt_val_id => l_prtt_rt_val_id,
                      p_val     => (l_rt_val-l_old_rlovr_val+l_balance),
                      p_ended_per_in_ler_id => p_per_in_ler_id,
                      p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id,
                      p_business_group_id  => p_business_group_id,
                      p_effective_date    => p_effective_date);
          --
        end if;
        close c_old_ledger;
      end if;
    end if; -- rule returned 'Y'
    hr_utility.set_location(l_proc, 140);
  end loop;
  --
  p_rollover_val:=l_rollover_diff_total;
  hr_utility.set_location('Leaving:'||l_proc, 999);
  --
end compute_rollovers;
--
--------------------------------------------------------------------------------
--                      compute_excess
--------------------------------------------------------------------------------
procedure compute_excess
  (p_calculate_only_mode in     boolean default false
  ,p_bnft_prvdr_pool_id  in     number
  ,p_flex_rslt_id        in     number
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  --
  ,p_frftd_val              out nocopy number
  ,p_def_exc_amount         out nocopy number
  ,p_bpl_cash_recd_val      out nocopy number
  )
is
   --
   -- Get totals for a pool.
   --
   cursor c_totals
     (c_bnft_prvdr_pool_id number
     ,c_prtt_enrt_rslt_id  number
     ,c_effective_date     date
     )
   is
      select nvl(sum(bpl.prvdd_val),0) tot_prvdd,
             nvl(sum(bpl.used_val),0) tot_used,
             nvl(sum(frftd_val),0) tot_frftd,
             nvl(sum(cash_recd_val),0) tot_cash,
             pil.ler_id
      from   ben_bnft_prvdd_ldgr_f bpl,
             ben_per_in_ler pil
      where  bpl.bnft_prvdr_pool_id = c_bnft_prvdr_pool_id
      and    bpl.prtt_enrt_rslt_id  = c_prtt_enrt_rslt_id
      and    c_effective_date
        between bpl.effective_start_date and bpl.effective_end_date
      and pil.per_in_ler_id=bpl.per_in_ler_id
      and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      group by pil.ler_id;
   --
   l_totals c_totals%rowtype;
   --
   -- Get the acty_base_rt_id to be used when fetching/creating
   -- excess amounts ledger.(Credit Ledger)
   --
   cursor c_bpl is
      select bpl.acty_base_rt_id
      from   ben_bnft_prvdd_ldgr_f bpl,
             ben_per_in_ler pil
      where  bpl.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
      and    bpl.prtt_enrt_rslt_id  = p_flex_rslt_id
      and    bpl.prvdd_val is not null
      and    bpl.business_group_id  = p_business_group_id
      and    p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
;
   --
   -- Get the pool (limits and rounding) details.
   --
   cursor c_pool is
      select bpp.pct_rndg_cd,
             bpp.pct_rndg_rl,
             bpp.dflt_excs_trtmt_cd,
             bpp.dflt_excs_trtmt_rl,
             bpp.mn_dstrbl_pct_num,
             bpp.mn_dstrbl_val,
             bpp.mx_dstrbl_pct_num,
             bpp.mx_dstrbl_val,
             bpp.rlovr_rstrcn_cd,
             bpp.val_rndg_cd,
             bpp.val_rndg_rl,
             bpp.auto_alct_excs_flag,
             bpp.uses_net_crs_mthd_flag
      from   ben_bnft_prvdr_pool_f bpp
      where  bpp.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
      and    bpp.business_group_id  = p_business_group_id
      and    p_effective_date between
             bpp.effective_start_date and bpp.effective_end_date;
   l_pool_rec    c_pool%rowtype;
   --
   l_rollover_val           number;
   l_dstrbtd_val            number;
   l_acty_base_rt_id        number;
   l_dummy                  number;
   l_def_exc_amount         number := 0;
   l_acty_base_rt_id2       number;
   l_rt_val                 number;
   --
   l_proc varchar2(80) := g_package||'.compute_excess';
   --
   l_dummy_number           number;
   --
begin
   --
   hr_utility.set_location('Entering '||l_proc,5);
   --
   -- Get all the totals for the pool.
   --
   p_frftd_val := 0;
   --
   open c_totals
     (c_bnft_prvdr_pool_id => p_bnft_prvdr_pool_id
     ,c_prtt_enrt_rslt_id  => p_flex_rslt_id
     ,c_effective_date     => p_effective_date
     );
   fetch c_totals into l_totals;
   close c_totals;
   --
   -- Get the activiity base rt id to be used.
   --
   open c_bpl;
   fetch c_bpl into l_acty_base_rt_id;
   close c_bpl;
   --
   -- Get all the pool details.
   --
   open c_pool;
   fetch c_pool into l_pool_rec;
   close c_pool;
   --
   -- If auto allocate flag is ON, then do the allocation.
   --
   hr_utility.set_location(l_proc,10);
   --
   if l_pool_rec.auto_alct_excs_flag = 'Y' then
      --
      g_credit_pool_result_id := p_flex_rslt_id;
      --
      hr_utility.set_location(l_proc,15);
      -- get the dflt trtmt cd by executing the rule if necessary
      if l_pool_rec.dflt_excs_trtmt_rl is not null then
         run_rule
            (p_effective_date     => p_effective_date
            ,p_person_id          => p_person_id
            ,p_dflt_excs_trtmt_rl => l_pool_rec.dflt_excs_trtmt_rl
            ,p_business_group_id  => p_business_group_id
            ,p_ler_id             => l_totals.ler_id
            ,p_bnft_prvdr_pool_id => p_bnft_prvdr_pool_id
            ,p_dflt_excs_trtmt_cd => l_pool_rec.dflt_excs_trtmt_cd  -- output
            ,p_mx_val             => l_dummy); -- output
      end if;
      --
      if l_pool_rec.dflt_excs_trtmt_cd in ('DSTRBT_ALL','DSTRBT_RLOVR_FRFT') then
         --
         -- Distribute the cash.
         --
         hr_utility.set_location(l_proc,20);
         --
         distribute_credits
           (p_calculate_only_mode => p_calculate_only_mode
           ,p_per_in_ler_id       => p_per_in_ler_id
           ,p_prtt_enrt_rslt_id   => p_flex_rslt_id
           ,p_bnft_prvdr_pool_id  => p_bnft_prvdr_pool_id
           ,p_acty_base_rt_id     => l_acty_base_rt_id
           ,p_dflt_excs_trtmt_cd  => l_pool_rec.dflt_excs_trtmt_cd
           ,p_prvdd_val           => l_totals.tot_prvdd
           ,p_rlld_up_val         => 0
           ,p_used_val            => l_totals.tot_used
           ,p_rollover_val        => 0
           ,p_cash_recd_total     => l_totals.tot_cash
           ,p_val_rndg_cd         => l_pool_rec.val_rndg_cd
           ,p_val_rndg_rl         => l_pool_rec.val_rndg_rl
           ,p_pct_rndg_cd         => l_pool_rec.pct_rndg_cd
           ,p_pct_rndg_rl         => l_pool_rec.pct_rndg_rl
           ,p_mn_dstrbl_val       => l_pool_rec.mn_dstrbl_val
           ,p_mn_dstrbl_pct_num   => l_pool_rec.mn_dstrbl_pct_num
           ,p_mx_dstrbl_val       => l_pool_rec.mx_dstrbl_val
           ,p_mx_pct              => l_pool_rec.mx_dstrbl_pct_num
           ,p_person_id           => p_person_id
           ,p_enrt_mthd_cd        => null
           ,p_effective_date      => p_effective_date
           ,p_business_group_id   => p_business_group_id
           ,p_process_enrt_flag   => 'N'
           ,p_dstrbtd_val         => l_dstrbtd_val
           ,p_bpl_cash_recd_val   => p_bpl_cash_recd_val
           ,p_bnft_prvdd_ldgr_id  => l_dummy_number
           );
         --
      end if;
      --
      if l_pool_rec.dflt_excs_trtmt_cd in ('DSTRBT_RLOVR_FRFT',
                                           'RLOVR_DSTRBT_FRFT') then
         --
         -- Rollover the excess, if anything left.
         --
         hr_utility.set_location(l_proc,25);
         compute_rollovers
           (p_calculate_only_mode => p_calculate_only_mode
           ,p_bnft_prvdr_pool_id  => p_bnft_prvdr_pool_id
           ,p_person_id           => p_person_id
           ,p_enrt_mthd_cd        => p_enrt_mthd_cd
           ,p_flex_rslt_id        => p_flex_rslt_id
           ,p_per_in_ler_id       => p_per_in_ler_id
           ,p_effective_date      => p_effective_date
           ,p_business_group_id   => p_business_group_id
           ,p_pct_rndg_cd         => l_pool_rec.pct_rndg_cd
           ,p_pct_rndg_rl         => l_pool_rec.pct_rndg_rl
           ,p_dflt_excs_trtmt_cd  => l_pool_rec.dflt_excs_trtmt_cd
           ,p_rollover_val        => l_rollover_val
           );
         --
      end if;
      --
      if l_pool_rec.dflt_excs_trtmt_cd ='RLOVR_DSTRBT_FRFT' then
        hr_utility.set_location(l_proc,90 );
        --
        -- Distribute as cash, if anything still left.
        --
        hr_utility.set_location(l_proc,30);
        distribute_credits
          (p_calculate_only_mode => p_calculate_only_mode
          ,p_per_in_ler_id       => p_per_in_ler_id
          ,p_prtt_enrt_rslt_id   => p_flex_rslt_id
          ,p_bnft_prvdr_pool_id  => p_bnft_prvdr_pool_id
          ,p_acty_base_rt_id     => l_acty_base_rt_id
          ,p_dflt_excs_trtmt_cd  => l_pool_rec.dflt_excs_trtmt_cd
          ,p_prvdd_val           => l_totals.tot_prvdd
          ,p_rlld_up_val         => 0
          ,p_used_val            => l_totals.tot_used
          ,p_rollover_val        => l_rollover_val
          ,p_cash_recd_total     => l_totals.tot_cash
          ,p_val_rndg_cd         => l_pool_rec.val_rndg_cd
          ,p_val_rndg_rl         => l_pool_rec.val_rndg_rl
          ,p_pct_rndg_cd         => l_pool_rec.pct_rndg_cd
          ,p_pct_rndg_rl         => l_pool_rec.pct_rndg_rl
          ,p_mn_dstrbl_val       => l_pool_rec.mn_dstrbl_val
          ,p_mn_dstrbl_pct_num   => l_pool_rec.mn_dstrbl_pct_num
          ,p_mx_dstrbl_val       => l_pool_rec.mx_dstrbl_val
          ,p_mx_pct              => l_pool_rec.mx_dstrbl_pct_num
          ,p_person_id           => p_person_id
          ,p_enrt_mthd_cd        => null
          ,p_effective_date      => p_effective_date
          ,p_business_group_id   => p_business_group_id
          ,p_process_enrt_flag   => 'N'
          ,p_dstrbtd_val         => l_dstrbtd_val
          ,p_bpl_cash_recd_val   => p_bpl_cash_recd_val
          ,p_bnft_prvdd_ldgr_id  => l_dummy_number
          );
         --
      end if;
      --
      -- All possible rollovers and cash distribution done. If anything is
      -- still left, it has to be forfeited.
      --
      hr_utility.set_location(l_proc,35);
      forfeit_credits
        (p_calculate_only_mode => p_calculate_only_mode
        ,p_prtt_enrt_rslt_id   => p_flex_rslt_id
        ,p_bnft_prvdr_pool_id  => p_bnft_prvdr_pool_id
        ,p_acty_base_rt_id     => l_acty_base_rt_id
        ,p_prvdd_val           => l_totals.tot_prvdd
        ,p_rlld_up_val         => 0
        ,p_used_val            => l_totals.tot_used
        ,p_rollover_val        => l_rollover_val
        ,p_cash_val            => l_dstrbtd_val
        ,p_effective_date      => p_effective_date
        ,p_business_group_id   => p_business_group_id
        ,p_frftd_val           => p_frftd_val
        ,p_per_in_ler_id       => p_per_in_ler_id
        ,p_person_id           => p_person_id
        ,p_enrt_mthd_cd        => p_enrt_mthd_cd
        );

   end if;
   --
   if l_pool_rec.uses_net_crs_mthd_flag = 'Y' then
     --
     -- Check if there is a deficit amount.
     --
     if l_pool_rec.auto_alct_excs_flag = 'Y' then
       l_def_exc_amount := l_def_exc_amount + nvl(l_dstrbtd_val,0);
     else
       l_def_exc_amount := l_def_exc_amount +
                            (l_totals.tot_prvdd - l_totals.tot_used);
     end if;
   end if; -- end net credit method.
   --
   p_def_exc_amount := l_def_exc_amount;
   --
   hr_utility.set_location('Leaving '||l_proc,999);

end compute_excess;
--
--------------------------------------------------------------------------------
--                      update_net_credit_rate
--------------------------------------------------------------------------------
procedure update_net_credit_rate
            (p_prtt_rt_val_id       in number
            ,p_flex_rslt_id         in number
            ,p_acty_base_rt_id      in number
            ,p_per_in_ler_id        in number
            ,p_def_exc_amount       in number
            ,p_effective_date       in date
            ,p_business_group_id    in number
            ) is
   --
   cursor c_prv_child is
      select prv.prtt_rt_val_id,
             prv.rt_val,
             prv.rt_strt_dt,
             prv.acty_base_rt_id
      from   ben_prtt_rt_val prv
            ,ben_acty_base_rt_f abr
      where  prv.prtt_enrt_rslt_id = p_flex_rslt_id
      and    prv.business_group_id  = p_business_group_id
      and    prv.prtt_rt_val_stat_cd is null
      and    abr.acty_base_rt_id = prv.acty_base_rt_id
      and    p_effective_date
             between abr.effective_start_date and
             abr.effective_end_date
      and    abr.business_group_id = prv.business_group_id
      and    abr.parnt_acty_base_rt_id = p_acty_base_rt_id
   order by prv.rt_strt_dt desc;
   l_prv_child_rec    c_prv_child%rowtype;
   --
   cursor c_pen is
      select pen.*
      from   ben_prtt_enrt_rslt_f pen
      where  pen.prtt_enrt_rslt_id = p_flex_rslt_id
      and    pen.business_group_id  = p_business_group_id
      and    p_effective_date
             between pen.effective_start_date and
             pen.effective_end_date
      and    pen.prtt_enrt_rslt_stat_cd is null;
   l_pen_rec    c_pen%rowtype;
   --
   cursor c_abr is
      select abr.*
      from   ben_acty_base_rt_f abr
      where  abr.acty_base_rt_id = p_acty_base_rt_id
      and    abr.business_group_id  = p_business_group_id
      and    p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
   --
   l_abr_rec    c_abr%rowtype;
   --
   cursor c_abr_child is
      select abr.*
      from   ben_acty_base_rt_f abr
      where  abr.parnt_acty_base_rt_id = p_acty_base_rt_id
      and    abr.business_group_id  = p_business_group_id
      and    p_effective_date between
             abr.effective_start_date and abr.effective_end_date;
   --
   l_abr_child_rec    c_abr_child%rowtype;
   --
   cursor c_get_acty_ref_perd_cd is
      select  acty_ref_perd_cd
             ,cmcd_ref_perd_cd
      from   ben_prtt_rt_val prv
      where  prv.prtt_enrt_rslt_id = p_flex_rslt_id
      and    prv.prtt_rt_val_stat_cd is null
      and    prv.business_group_id = p_business_group_id;
   --
   --Bug 2386000
   --
   CURSOR c_lee_rsn_for_plan (c_ler_id number, c_pl_id number ) IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pl_id                 = c_pl_id
      AND      petc.enrt_typ_cycl_cd = 'L'                        -- life event
      AND      petc.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
   --
   CURSOR c_lee_rsn_for_program (c_ler_id number, c_pgm_id number )IS
      SELECT   leer.lee_rsn_id
      FROM     ben_lee_rsn_f leer,
               ben_popl_enrt_typ_cycl_f petc
      WHERE    leer.ler_id            = c_ler_id
      AND      leer.business_group_id = p_business_group_id
      AND      p_effective_date BETWEEN leer.effective_start_date
                   AND leer.effective_end_date
      AND      leer.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
      AND      petc.pgm_id                = c_pgm_id
      AND      petc.enrt_typ_cycl_cd      = 'L'
      AND      petc.business_group_id     = p_business_group_id
      AND      p_effective_date BETWEEN petc.effective_start_date
                   AND petc.effective_end_date;
   --
   l_lee_rsn_id                number := null ;
   --
   l_child_rt_val              ben_prtt_rt_val.rt_val%type;
   l_prtt_rt_val_id            ben_prtt_rt_val.prtt_rt_val_id%type;
   l_object_version_number     ben_prtt_rt_val.object_version_number%type;
   l_cmcd_ref_perd_cd          ben_prtt_rt_val.cmcd_ref_perd_cd%type;
   l_acty_ref_perd_cd          ben_prtt_rt_val.acty_ref_perd_cd%type;
   l_dummy_num                 number;
   l_dummy_varchar2            varchar2(80);
   l_dummy_date                date;
   l_enrt_cvg_strt_dt          date;
   l_enrt_cvg_strt_dt_cd       varchar2(30);
   l_enrt_cvg_strt_dt_rl       number;
   l_rt_strt_dt                date;
   l_rt_strt_dt_cd             varchar2(30);
   l_rt_strt_dt_rl             number;
   l_enrt_cvg_end_dt           date;
   l_enrt_cvg_end_dt_cd        varchar2(30);
   l_enrt_cvg_end_dt_rl        number;
   l_rt_end_dt                 date;
   l_rt_end_dt_cd              varchar2(30);
   l_rt_end_dt_rl              number;
   l_enrt_rt_id                number;

   --
   l_proc varchar2(80) := g_package||'.update_net_credit_rate';
   --
begin
  --
  hr_utility.set_location('Entering '||l_proc,5);
  open c_pen;
  fetch c_pen into l_pen_rec;
  close c_pen;
  --
  if p_prtt_rt_val_id is not null then
    --
    l_prtt_rt_val_id := p_prtt_rt_val_id;
    --
    hr_utility.set_location('update_net_credit amt '||p_def_exc_amount,5);
    update_rate
      (p_prtt_rt_val_id       => l_prtt_rt_val_id
      ,p_val                  => p_def_exc_amount
      ,p_prtt_enrt_rslt_id    => p_flex_rslt_id
      ,p_ended_per_in_ler_id  => p_per_in_ler_id
      ,p_effective_date       => p_effective_date
      ,p_business_group_id    => p_business_group_id
      );
    --
    --  Update the associated child rate.
    --
    open c_prv_child;
    fetch c_prv_child into l_prv_child_rec;
    close c_prv_child;
    if p_def_exc_amount <> 0 then
      --
      --  Calculate the child rate.
      --
      ben_determine_activity_base_rt.main
        (p_person_id                   => l_pen_rec.person_id
        ,p_elig_per_elctbl_chc_id      => null
        ,p_acty_base_rt_id             => l_prv_child_rec.acty_base_rt_id
        ,p_effective_date              => p_effective_date
        ,p_per_in_ler_id               => p_per_in_ler_id
        ,p_calc_only_rt_val_flag       => true
        ,p_pgm_id                      => l_pen_rec.pgm_id
        ,p_pl_id                       => l_pen_rec.pl_id
        ,p_business_group_id           => p_business_group_id
        ,p_cal_val                     => p_def_exc_amount
        ,p_val                         => l_child_rt_val
        ,p_mn_elcn_val                 => l_dummy_num
        ,p_mx_elcn_val                 => l_dummy_num
        ,p_ann_val                     => l_dummy_num
        ,p_ann_mn_elcn_val             => l_dummy_num
        ,p_ann_mx_elcn_val             => l_dummy_num
        ,p_cmcd_val                    => l_dummy_num
        ,p_cmcd_mn_elcn_val            => l_dummy_num
        ,p_cmcd_mx_elcn_val            => l_dummy_num
        ,p_cmcd_acty_ref_perd_cd       => l_dummy_varchar2
        ,p_incrmt_elcn_val             => l_dummy_num
        ,p_dflt_val                    => l_dummy_num
        ,p_tx_typ_cd                   => l_dummy_varchar2
        ,p_acty_typ_cd                 => l_dummy_varchar2
        ,p_nnmntry_uom                 => l_dummy_varchar2
        ,p_entr_val_at_enrt_flag       => l_dummy_varchar2
        ,p_dsply_on_enrt_flag          => l_dummy_varchar2
        ,p_use_to_calc_net_flx_cr_flag => l_dummy_varchar2
        ,p_rt_usg_cd                   => l_dummy_varchar2
        ,p_bnft_prvdr_pool_id          => l_dummy_num
        ,p_actl_prem_id                => l_dummy_num
        ,p_cvg_calc_amt_mthd_id        => l_dummy_num
        ,p_bnft_rt_typ_cd              => l_dummy_varchar2
        ,p_rt_typ_cd                   => l_dummy_varchar2
        ,p_rt_mlt_cd                   => l_dummy_varchar2
        ,p_comp_lvl_fctr_id            => l_dummy_num
        ,p_entr_ann_val_flag           => l_dummy_varchar2
        ,p_ptd_comp_lvl_fctr_id        => l_dummy_num
        ,p_clm_comp_lvl_fctr_id        => l_dummy_num
        ,p_ann_dflt_val                => l_dummy_num
        ,p_rt_strt_dt                  => l_dummy_date
        ,p_rt_strt_dt_cd               => l_dummy_varchar2
        ,p_rt_strt_dt_rl               => l_dummy_num
        ,p_prtt_rt_val_id              => l_dummy_num
        ,p_dsply_mn_elcn_val           => l_dummy_num
        ,p_dsply_mx_elcn_val           => l_dummy_num
        ,p_pp_in_yr_used_num           => l_dummy_num
        ,p_ordr_num                    => l_dummy_num
        ,p_iss_val                     => l_dummy_num
        );
    else
      l_child_rt_val := 0;
    end if;
    --
    --  Update the child rate.
    --
    update_rate
     (p_prtt_rt_val_id       => l_prv_child_rec.prtt_rt_val_id
     ,p_val                  => l_child_rt_val
     ,p_prtt_enrt_rslt_id    => p_flex_rslt_id
     ,p_ended_per_in_ler_id  => p_per_in_ler_id
     ,p_effective_date       => p_effective_date
     ,p_business_group_id    => p_business_group_id
     );
  else
    --
    --  Create the prtt_rt_val.
    --Bug 2386000
    open c_lee_rsn_for_plan(l_pen_rec.ler_id, l_pen_rec.pl_id );
    fetch c_lee_rsn_for_plan into l_lee_rsn_id ;
    close c_lee_rsn_for_plan ;
    --
    if l_lee_rsn_id is null and l_pen_rec.pgm_id is not null then
      open c_lee_rsn_for_program(l_pen_rec.ler_id, l_pen_rec.pgm_id);
      fetch c_lee_rsn_for_program into l_lee_rsn_id ;
      close c_lee_rsn_for_program ;
    end if;
    --
    ben_determine_date.rate_and_coverage_dates(
         p_which_dates_cd          => 'R',
         p_pgm_id                  => l_pen_rec.pgm_id,
         p_pl_id                   => l_pen_rec.pl_id,
         p_oipl_id                 => l_pen_rec.oipl_id,
         p_lee_rsn_id              => l_lee_rsn_id,
         p_per_in_ler_id           => p_per_in_ler_id,
         p_person_id               => l_pen_rec.person_id,
         p_business_group_id       => p_business_group_id,
         p_enrt_cvg_strt_dt        => l_enrt_cvg_strt_dt,
         p_enrt_cvg_strt_dt_cd     => l_enrt_cvg_strt_dt_cd,
         p_enrt_cvg_strt_dt_rl     => l_enrt_cvg_strt_dt_rl,
         p_rt_strt_dt              => l_rt_strt_dt,
         p_rt_strt_dt_cd           => l_rt_strt_dt_cd,
         p_rt_strt_dt_rl           => l_rt_strt_dt_rl,
         p_enrt_cvg_end_dt         => l_enrt_cvg_end_dt,
         p_enrt_cvg_end_dt_cd      => l_enrt_cvg_end_dt_cd,
         p_enrt_cvg_end_dt_rl      => l_enrt_cvg_end_dt_rl,
         p_rt_end_dt               => l_rt_end_dt,
         p_rt_end_dt_cd            => l_rt_end_dt_cd,
         p_rt_end_dt_rl            => l_rt_end_dt_rl,
         p_effective_date          => p_effective_date
         );
    --
    open c_abr;
    fetch c_abr into l_abr_rec;
    close c_abr;
    --
    open c_get_acty_ref_perd_cd;
    fetch c_get_acty_ref_perd_cd into l_acty_ref_perd_cd
                                     ,l_cmcd_ref_perd_cd;
    close c_get_acty_ref_perd_cd;

    ben_prtt_rt_val_api.create_prtt_rt_val
      (p_prtt_rt_val_id         => l_prtt_rt_val_id
      ,p_per_in_ler_id          => p_per_in_ler_id
      ,p_rt_typ_cd              => l_abr_rec.rt_typ_cd
      ,p_tx_typ_cd              => l_abr_rec.tx_typ_cd
      ,p_acty_typ_cd            => l_abr_rec.acty_typ_cd
      ,p_mlt_cd                 => l_abr_rec.rt_mlt_cd
      ,p_acty_ref_perd_cd       => l_acty_ref_perd_cd
      ,p_rt_val                 => p_def_exc_amount
      ,p_rt_strt_dt             => l_rt_strt_dt
      ,p_rt_end_dt              => hr_api.g_eot
      ,p_ann_rt_val             => null
      ,p_bnft_rt_typ_cd         => l_abr_rec.bnft_rt_typ_cd
      ,p_cmcd_ref_perd_cd       => l_cmcd_ref_perd_cd
      ,p_cmcd_rt_val            => p_def_exc_amount
      ,p_dsply_on_enrt_flag     => l_abr_rec.dsply_on_enrt_flag
      ,p_elctns_made_dt         => p_effective_date
      ,p_cvg_amt_calc_mthd_id   => null
      ,p_actl_prem_id           => null
      ,p_comp_lvl_fctr_id       => l_abr_rec.comp_lvl_fctr_id
      ,p_prtt_enrt_rslt_id      => p_flex_rslt_id
      ,p_business_group_id      => p_business_group_id
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => p_effective_date
      ,p_acty_base_rt_id        => p_acty_base_rt_id
      ,p_input_value_id         => l_abr_rec.input_value_id
      ,p_element_type_id        => l_abr_rec.element_type_id
      ,p_person_id              => l_pen_rec.person_id
      ,p_ordr_num       => l_abr_rec.ordr_num
      );
    --
    --   Create the child rate.
    --
    open c_abr_child;
    fetch c_abr_child into l_abr_child_rec;
    close c_abr_child;
    --
    --  Calculate the child rate.
    --
    ben_determine_activity_base_rt.main
      (p_person_id                   => l_pen_rec.person_id
      ,p_elig_per_elctbl_chc_id      => null
      ,p_acty_base_rt_id             => l_abr_child_rec.acty_base_rt_id
      ,p_effective_date              => p_effective_date
      ,p_per_in_ler_id               => p_per_in_ler_id
      ,p_calc_only_rt_val_flag       => true
      ,p_pgm_id                      => l_pen_rec.pgm_id
      ,p_pl_id                       => l_pen_rec.pl_id
      ,p_business_group_id           => p_business_group_id
      ,p_cal_val                     => p_def_exc_amount
      ,p_val                         => l_child_rt_val
      ,p_mn_elcn_val                 => l_dummy_num
      ,p_mx_elcn_val                 => l_dummy_num
      ,p_ann_val                     => l_dummy_num
      ,p_ann_mn_elcn_val             => l_dummy_num
      ,p_ann_mx_elcn_val             => l_dummy_num
      ,p_cmcd_val                    => l_dummy_num
      ,p_cmcd_mn_elcn_val            => l_dummy_num
      ,p_cmcd_mx_elcn_val            => l_dummy_num
      ,p_cmcd_acty_ref_perd_cd       => l_dummy_varchar2
      ,p_incrmt_elcn_val             => l_dummy_num
      ,p_dflt_val                    => l_dummy_num
      ,p_tx_typ_cd                   => l_dummy_varchar2
      ,p_acty_typ_cd                 => l_dummy_varchar2
      ,p_nnmntry_uom                 => l_dummy_varchar2
      ,p_entr_val_at_enrt_flag       => l_dummy_varchar2
      ,p_dsply_on_enrt_flag          => l_dummy_varchar2
      ,p_use_to_calc_net_flx_cr_flag => l_dummy_varchar2
      ,p_rt_usg_cd                   => l_dummy_varchar2
      ,p_bnft_prvdr_pool_id          => l_dummy_num
      ,p_actl_prem_id                => l_dummy_num
      ,p_cvg_calc_amt_mthd_id        => l_dummy_num
      ,p_bnft_rt_typ_cd              => l_dummy_varchar2
      ,p_rt_typ_cd                   => l_dummy_varchar2
      ,p_rt_mlt_cd                   => l_dummy_varchar2
      ,p_comp_lvl_fctr_id            => l_dummy_num
      ,p_entr_ann_val_flag           => l_dummy_varchar2
      ,p_ptd_comp_lvl_fctr_id        => l_dummy_num
      ,p_clm_comp_lvl_fctr_id        => l_dummy_num
      ,p_ann_dflt_val                => l_dummy_num
      ,p_rt_strt_dt                  => l_dummy_date
      ,p_rt_strt_dt_cd               => l_dummy_varchar2
      ,p_rt_strt_dt_rl               => l_dummy_num
      ,p_prtt_rt_val_id              => l_dummy_num
      ,p_dsply_mn_elcn_val           => l_dummy_num
      ,p_dsply_mx_elcn_val           => l_dummy_num
      ,p_pp_in_yr_used_num           => l_dummy_num
      ,p_ordr_num                    => l_dummy_num
        ,p_iss_val                     => l_dummy_num
      );
    --
    ben_prtt_rt_val_api.create_prtt_rt_val
      (p_prtt_rt_val_id         => l_prtt_rt_val_id
      ,p_per_in_ler_id          => p_per_in_ler_id
      ,p_rt_typ_cd              => l_abr_rec.rt_typ_cd
      ,p_tx_typ_cd              => l_abr_rec.tx_typ_cd
      ,p_acty_typ_cd            => l_abr_rec.acty_typ_cd
      ,p_mlt_cd                 => l_abr_rec.rt_mlt_cd
      ,p_acty_ref_perd_cd       => l_acty_ref_perd_cd
      ,p_rt_val                 => l_child_rt_val
      ,p_rt_strt_dt             => l_rt_strt_dt
      ,p_rt_end_dt              => hr_api.g_eot
      ,p_ann_rt_val             => null
      ,p_bnft_rt_typ_cd         => l_abr_rec.bnft_rt_typ_cd
      ,p_cmcd_ref_perd_cd       => l_cmcd_ref_perd_cd
      ,p_cmcd_rt_val            => l_child_rt_val
      ,p_dsply_on_enrt_flag     => l_abr_rec.dsply_on_enrt_flag
      ,p_elctns_made_dt         => p_effective_date
      ,p_cvg_amt_calc_mthd_id   => null
      ,p_actl_prem_id           => null
      ,p_comp_lvl_fctr_id       => l_abr_rec.comp_lvl_fctr_id
      ,p_prtt_enrt_rslt_id      => p_flex_rslt_id
      ,p_business_group_id      => p_business_group_id
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => p_effective_date
      ,p_acty_base_rt_id        => p_acty_base_rt_id
      ,p_input_value_id         => l_abr_rec.input_value_id
      ,p_element_type_id        => l_abr_rec.element_type_id
      ,p_person_id              => l_pen_rec.person_id
      ,p_ordr_num       => l_abr_rec.ordr_num
      );
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,999);
  --
end update_net_credit_rate;
--------------------------------------------------------------------------------
--                      recompute_flex_credits
--------------------------------------------------------------------------------
 procedure recompute_flex_credits(
              p_person_id            in number,
              p_enrt_mthd_cd         in varchar2,
              p_prtt_enrt_rslt_id    in number,
              p_per_in_ler_id        in number,
              p_pgm_id               in number,
              p_business_group_id    in number,
              p_effective_date       in date) is
   --
   l_debit_ledger_deleted    boolean := false;
   l_credit_ledger_deleted   boolean := false;
   l_recompute_excess        boolean := false;
   l_person_enrolled         boolean := false;
   l_total_credits           number  := 0;
   l_debit_pool_id           number;
   l_flex_rslt_id            number  := null;
   l_effective_start_date    date;
   l_effective_end_date      date;
   l_effective_date          date;
   l_datetrack_mode          varchar2(30);
   l_flex_pgm                varchar2(30);
   l_frftd_val               number;
   l_prtt_rt_val_id          number;
   l_acty_base_rt_id         number;
   l_rt_val                  number;
   l_uses_net_crs_mthd       boolean := false;
   l_prv_exists              boolean := false;
   l_def_exc_amount          number := 0;
   l_epe_rec                 ben_epe_shd.g_rec_type;
   l_dummy_number            number;
   l_rt_strt_dt              date;
   --
   cursor c_pgm is
      select 'Y'
      from   ben_pgm_f pgm
      where  pgm.pgm_id = p_pgm_id
      and    pgm.business_group_id = p_business_group_id
      and    pgm.pgm_typ_cd in ('FLEX','FPC')
      and    p_effective_date between
             pgm.effective_start_date and pgm.effective_end_date;
   --
   -- Cursor to fetch the debit ledger.
   --
   cursor c_dbt_bpl is
      select bpl.bnft_prvdd_ldgr_id,
             bpl.object_version_number,
             bpl.effective_start_date,
             bpl.bnft_prvdr_pool_id,
             bpl.prtt_enrt_rslt_id
      from   ben_prtt_enrt_rslt_f   enrt_pen,
             ben_prtt_rt_val        enrt_prv,
             ben_bnft_prvdd_ldgr_f  bpl,
             ben_per_in_ler pil,
             ben_prtt_enrt_rslt_f   flex_pen
      where  enrt_pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and    enrt_pen.prtt_enrt_rslt_stat_cd is null
      and    enrt_pen.enrt_cvg_thru_dt = hr_api.g_eot
      and    p_effective_date between
             enrt_pen.effective_start_date and enrt_pen.effective_end_date
      and    enrt_pen.prtt_enrt_rslt_id = enrt_prv.prtt_enrt_rslt_id
      and    enrt_prv.prtt_rt_val_stat_cd is null
      and    enrt_prv.acty_base_rt_id = bpl.acty_base_rt_id
      and    bpl.used_val is not null
      and    p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
      and    bpl.prtt_enrt_rslt_id = flex_pen.prtt_enrt_rslt_id
      and    flex_pen.person_id = p_person_id
      and    flex_pen.prtt_enrt_rslt_stat_cd is null
      and    flex_pen.enrt_cvg_thru_dt = hr_api.g_eot
      and    p_effective_date between
             flex_pen.effective_start_date and flex_pen.effective_end_date
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
order by bpl.bnft_prvdd_ldgr_id, bpl.effective_start_date -- rajkiran
;
   --
   l_dbt_bpl_rec    c_dbt_bpl%rowtype;
   --
   -- Cursor to fetch all pools for the person and program
   --
   cursor c_crdt_bpp is
      select bpp.pgm_id,
             bpp.plip_id,
             bpp.ptip_id,
             bpp.cmbn_ptip_id,
             bpp.cmbn_plip_id,
             bpp.cmbn_ptip_opt_id,
             bpp.business_group_id,
             bpp.bnft_prvdr_pool_id,
             bpl.prvdd_val,
             bpl.prtt_enrt_rslt_id,
             bpp.uses_net_crs_mthd_flag
      from   ben_prtt_enrt_rslt_f   flex_pen,
             ben_bnft_prvdd_ldgr_f  bpl,
             ben_per_in_ler pil,
             ben_bnft_prvdr_pool_f  bpp
      where  flex_pen.person_id = p_person_id
      and    flex_pen.pgm_id    = p_pgm_id
      and    flex_pen.prtt_enrt_rslt_stat_cd is null
      and    flex_pen.enrt_cvg_thru_dt = hr_api.g_eot
      and    p_effective_date between
             flex_pen.effective_start_date and flex_pen.effective_end_date
      and    flex_pen.prtt_enrt_rslt_id = bpl.prtt_enrt_rslt_id
      and    bpl.prvdd_val is not null
      and    p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
      and    bpl.bnft_prvdr_pool_id = bpp.bnft_prvdr_pool_id
      and    p_effective_date between
             bpp.effective_start_date and bpp.effective_end_date
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
;
   --
   -- Cursor to get forfeited amount for a pool.
   --
   cursor c_frftd_bpl(v_pool_id in number) is
      select bpl.frftd_val
      from   ben_bnft_prvdd_ldgr_f bpl,
             ben_per_in_ler pil
      where  bpl.bnft_prvdr_pool_id = v_pool_id
      and    bpl.prtt_enrt_rslt_id = l_flex_rslt_id
      and    bpl.business_group_id  = p_business_group_id
      and    bpl.frftd_val is not null
      and    p_effective_date between
             bpl.effective_start_date and bpl.effective_end_date
and pil.per_in_ler_id=bpl.per_in_ler_id
and pil.business_group_id=bpl.business_group_id
and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
;
   --
   l_frftd_bpl_rec         c_frftd_bpl%rowtype;
   --
   cursor c_prv is
      select prv.prtt_rt_val_id,
             prv.rt_val,
             prv.rt_strt_dt
      from   ben_prtt_rt_val prv
            ,ben_acty_base_rt_f abr
      where  prv.prtt_enrt_rslt_id = l_flex_rslt_id
      and    prv.business_group_id  = p_business_group_id
      and    prv.prtt_rt_val_stat_cd is null
      and    prv.rt_end_dt >= p_effective_date  --------Bug 8601352
      and    abr.acty_base_rt_id = prv.acty_base_rt_id
      and    p_effective_date
             between abr.effective_start_date and
             abr.effective_end_date
      and    abr.business_group_id = prv.business_group_id
      and    abr.acty_typ_cd not in ('NCRDSTR','NCRUDED')
      and    abr.parnt_acty_base_rt_id is null
      order by 3 desc;
   --
   cursor c_prv2 is
      select prv.prtt_rt_val_id,
             prv.rt_val,
             prv.rt_strt_dt,
             prv.acty_typ_cd,
             prv.acty_base_rt_id
      from   ben_prtt_rt_val prv
      where  prv.prtt_enrt_rslt_id = l_flex_rslt_id
      and    prv.business_group_id  = p_business_group_id
      and    prv.prtt_rt_val_stat_cd is null
      and    prv.acty_typ_cd in ('NCRDSTR','NCRUDED')
      and    prv.rt_end_dt >= p_effective_date  --------Bug 8601352
      order by 3 desc;
   --
   cursor c_abr(p_acty_typ_cd in varchar2) is
      select abr.acty_base_rt_id
      from   ben_acty_base_rt_f abr
            ,ben_prtt_enrt_rslt_f pen
      where  abr.pl_id = pen.pl_id
      and    pen.prtt_enrt_rslt_id = l_flex_rslt_id
      and    abr.business_group_id  = p_business_group_id
      and    pen.business_group_id  = abr.business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    p_effective_date
             between pen.effective_start_date and
             pen.effective_end_date
      and    abr.acty_typ_cd = p_acty_typ_cd;
    --
   cursor c_bpl_esd( p_bpl_id number ) is
      select bnft_prvdd_ldgr_id,
             effective_start_date,
             effective_end_date,
             object_version_number
      from ben_bnft_prvdd_ldgr_f bpl
      where bnft_prvdd_ldgr_id = p_bpl_id
      --and effective_start_date < p_eff_dt
      order by effective_start_date;
   --
   l_bpl_esd_rec c_bpl_esd%ROWTYPE; -- rajkiran
   l_ovn number;                            -- rajkiran
   l_count number := 0;
   l_proc varchar2(80) := g_package||'.recompute_flex_credits';
   --
begin
   --
   hr_utility.set_location('Entering '||l_proc,5);
   --
   if p_pgm_id is null or
      p_person_id is null or
      p_prtt_enrt_rslt_id is null then
      --
      return;
      --
   end if;
   --
   hr_utility.set_location(l_proc, 10);
   --
   open  c_pgm;
   fetch c_pgm into l_flex_pgm;
   --
   if c_pgm%notfound then
      --
      close c_pgm;
      return;
      --
   else
      --
      close c_pgm;
      --
   end if;
   --
   -- Delete the debit ledger, if found.
   --
   open  c_dbt_bpl;
   fetch c_dbt_bpl into l_dbt_bpl_rec;
   --
   if c_dbt_bpl%found then
      --
      l_debit_ledger_deleted := true;
      l_recompute_excess     := true;
      l_debit_pool_id        := l_dbt_bpl_rec.bnft_prvdr_pool_id;
      l_flex_rslt_id         := l_dbt_bpl_rec.prtt_enrt_rslt_id;
      --
/*      if l_dbt_bpl_rec.effective_start_date = p_effective_date then
         --
         l_datetrack_mode := hr_api.g_zap;
         l_effective_date := p_effective_date;
         --
      else
         --
         l_datetrack_mode := hr_api.g_delete;
         l_effective_date := p_effective_date -1;
         --
      end if;*/
       Open c_bpl_esd(l_dbt_bpl_rec.bnft_prvdd_ldgr_id);
       loop
        fetch c_bpl_esd into l_bpl_esd_rec;
        exit when c_bpl_esd%notfound;
         if l_bpl_esd_rec.effective_start_date = p_effective_date and
            l_count = 1 then
            --
            l_ovn := l_bpl_esd_rec.object_version_number;
            l_datetrack_mode := hr_api.g_zap;
            l_effective_date := p_effective_date;
            exit;
            --
         elsif (p_effective_date-1) between l_bpl_esd_rec.effective_start_date
                                    and l_bpl_esd_rec.effective_end_date then
            --
            l_ovn := l_bpl_esd_rec.object_version_number;
            l_datetrack_mode := hr_api.g_delete;
            l_effective_date := p_effective_date - 1;
            exit;
            --
         end if;
       end loop;
       close c_bpl_esd;
         --
         --
      ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger(
           p_validate              => false,
           p_bnft_prvdd_ldgr_id    => l_dbt_bpl_rec.bnft_prvdd_ldgr_id,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_object_version_number => l_ovn, --l_dbt_bpl_rec.object_version_number,
           p_effective_date        => l_effective_date,
           p_datetrack_mode        => l_datetrack_mode,
           p_business_group_id     => p_business_group_id,
           p_process_enrt_flag     => 'N');
      --
      hr_utility.set_location(l_proc,15);
      --
   end if;
   --
   close c_dbt_bpl;
   --
   hr_utility.set_location(l_proc,20);
   --
   -- Loop through all the pools for the program, to compute the total
   -- credits available after the de-enrollment.
   --
   l_total_credits := 0;
   --
   for l_crdt_bpp_rec in c_crdt_bpp loop
      --
      --  Set a flag for net credit method processing.
      --
      if l_crdt_bpp_rec.uses_net_crs_mthd_flag = 'Y' then
        l_uses_net_crs_mthd := true;
      end if;
      --
      hr_utility.set_location(l_proc,25);
      --
      l_flex_rslt_id          := l_crdt_bpp_rec.prtt_enrt_rslt_id;
      --
      l_epe_rec.pgm_id            := l_crdt_bpp_rec.pgm_id;
      l_epe_rec.plip_id           := l_crdt_bpp_rec.plip_id;
      l_epe_rec.ptip_id           := l_crdt_bpp_rec.ptip_id;
      l_epe_rec.cmbn_ptip_id      := l_crdt_bpp_rec.cmbn_ptip_id;
      l_epe_rec.cmbn_plip_id      := l_crdt_bpp_rec.cmbn_plip_id;
      l_epe_rec.cmbn_ptip_opt_id  := l_crdt_bpp_rec.cmbn_ptip_opt_id;
      l_epe_rec.business_group_id := l_crdt_bpp_rec.business_group_id;
      --
      -- Check whether the person is still eligible for the pool.
      --
      l_person_enrolled := person_enrolled_in_choice(
                              p_person_id         => p_person_id,
                              p_epe_rec           => l_epe_rec,
                              p_old_result_id     => p_prtt_enrt_rslt_id,
                              p_effective_date    => p_effective_date);
      --
      if l_person_enrolled then
         --
         hr_utility.set_location(l_proc,30);
         --
         l_total_credits := l_total_credits + l_crdt_bpp_rec.prvdd_val;
         --
         if l_crdt_bpp_rec.bnft_prvdr_pool_id <> l_debit_pool_id then
            --
            -- Reduce the forfeited credits, to calculate total credits,
            -- Only when the pool is not the same as deleted debit's pool,
            -- as the forfeited credits will be re-computed in that case.
            --
            open  c_frftd_bpl(l_crdt_bpp_rec.bnft_prvdr_pool_id);
            fetch c_frftd_bpl into l_frftd_bpl_rec;
            close c_frftd_bpl;
            --
            l_total_credits := l_total_credits
                               - nvl(l_frftd_bpl_rec.frftd_val,0);
            --
         end if;
         --
      else
         --
         -- Person is not eligible for the pool, so we need to delete
         -- all ledgers for the pool.
         --
         hr_utility.set_location(l_proc,35);
         --
         l_credit_ledger_deleted := true;
         --
         if l_crdt_bpp_rec.bnft_prvdr_pool_id = l_debit_pool_id then
            --
            -- All ledgers for this pool will get deleted, so no need
            -- to re-compute excess allocations.
            --
            l_recompute_excess := false;
            --
         end if;
         --
         delete_all_ledgers(
                   p_bnft_prvdr_pool_id => l_crdt_bpp_rec.bnft_prvdr_pool_id,
                   p_person_id          => p_person_id,
                   p_per_in_ler_id      => p_per_in_ler_id,
                   p_flex_rslt_id       => l_flex_rslt_id,
                   p_effective_date     => p_effective_date,
                   p_business_group_id  => p_business_group_id);
         --
      end if;
      --
   end loop;
   --
   hr_utility.set_location(l_proc,40);
   --
   if not(l_credit_ledger_deleted) and not(l_debit_ledger_deleted) then
      --
      -- No ledger deletion took place, it means everything is in order.
      --
      hr_utility.set_location(l_proc,45);
      return;
      --
   elsif l_recompute_excess then
      --
      -- Re-compute the excess amounts as a debit ledger is deleted,
      -- so we have more excess amount available.
      --
      hr_utility.set_location(l_proc,50);
      compute_excess
        (p_bnft_prvdr_pool_id  => l_debit_pool_id
        ,p_flex_rslt_id        => l_flex_rslt_id
        ,p_effective_date      => p_effective_date
        ,p_per_in_ler_id       => p_per_in_ler_id
        ,p_person_id           => p_person_id
        ,p_enrt_mthd_cd        => p_enrt_mthd_cd
        ,p_business_group_id   => p_business_group_id
        --
        ,p_frftd_val           => l_frftd_val
        ,p_def_exc_amount      => l_def_exc_amount
        ,p_bpl_cash_recd_val   => l_dummy_number
        );
      hr_utility.set_location('l_def_exc_amount:1 '||l_def_exc_amount ,50);
      --
      -- Reduce forfeited credits for the pool from which the
      -- debit ledger was deleted.
      --
      l_total_credits := l_total_credits - l_frftd_val;
      --
   end if;
   --
   if l_uses_net_crs_mthd then
     --
     --  Get the participant rt val to determine if the person
     --  previously has a net credit or debit amount.
     --
     for l_prv_rec in c_prv2 loop
       l_prv_exists := true;
       --
       --   Check if the amount has changed.
       --
       if l_prv_rec.acty_typ_cd = 'NCRDSTR' then
         if l_def_exc_amount >= 0 then
           if nvl(l_prv_rec.rt_val,0) <> l_def_exc_amount then
             --
             update_net_credit_rate
               (p_prtt_rt_val_id    => l_prv_rec.prtt_rt_val_id
               ,p_flex_rslt_id      => l_flex_rslt_id
               ,p_acty_base_rt_id   => l_prv_rec.acty_base_rt_id
               ,p_per_in_ler_id     => p_per_in_ler_id
               ,p_def_exc_amount    => l_def_exc_amount
               ,p_effective_date    => p_effective_date
               ,p_business_group_id => p_business_group_id
               );
           end if;
         else
           --
           --  Update the credit distribution rate to zero and write a
           --  deduction rate.
           --
           if nvl(l_prv_rec.rt_val,0) <> 0 then
             update_net_credit_rate
               (p_prtt_rt_val_id    => l_prv_rec.prtt_rt_val_id
               ,p_flex_rslt_id      => l_flex_rslt_id
               ,p_acty_base_rt_id   => l_prv_rec.acty_base_rt_id
               ,p_per_in_ler_id     => p_per_in_ler_id
               ,p_def_exc_amount    => 0
               ,p_effective_date    => p_effective_date
               ,p_business_group_id => p_business_group_id
               );
           end if;
         end if;
       elsif l_prv_rec.acty_typ_cd = 'NCRUDED' then
         --
         if l_def_exc_amount < 0 then
           if nvl(l_prv_rec.rt_val,0) <> abs(l_def_exc_amount) then
             update_net_credit_rate
               (p_prtt_rt_val_id    => l_prv_rec.prtt_rt_val_id
               ,p_flex_rslt_id      => l_flex_rslt_id
               ,p_acty_base_rt_id   => l_prv_rec.acty_base_rt_id
               ,p_per_in_ler_id     => p_per_in_ler_id
               ,p_def_exc_amount    => abs(l_def_exc_amount)
               ,p_effective_date    => p_effective_date
               ,p_business_group_id => p_business_group_id
               );
           end if;
         else
           --
           --  Update the Net deduction rate to zero and write a new
           --  distribution rate.
           --
           if nvl(l_prv_rec.rt_val,0) <> 0 then
             update_net_credit_rate
               (p_prtt_rt_val_id    => l_prv_rec.prtt_rt_val_id
               ,p_flex_rslt_id      => l_flex_rslt_id
               ,p_acty_base_rt_id   => l_prv_rec.acty_base_rt_id
               ,p_per_in_ler_id     => p_per_in_ler_id
               ,p_def_exc_amount    => 0
               ,p_effective_date    => p_effective_date
               ,p_business_group_id => p_business_group_id
               );
           end if;
         end if;
       end if;
     end loop;
       --
     if l_prv_exists = false then
       if l_def_exc_amount < 0 then
         --
         open c_abr('NCRUDED');
         fetch c_abr into l_acty_base_rt_id;
         close c_abr;
         --
         update_net_credit_rate
           (p_prtt_rt_val_id    => null
           ,p_flex_rslt_id      => l_flex_rslt_id
           ,p_acty_base_rt_id   => l_acty_base_rt_id
           ,p_per_in_ler_id     => p_per_in_ler_id
           ,p_def_exc_amount    => abs(l_def_exc_amount)
           ,p_effective_date    => p_effective_date
           ,p_business_group_id => p_business_group_id
          );
       elsif l_def_exc_amount > 0 then
         --
         open c_abr('NCRDSTR');
         fetch c_abr into l_acty_base_rt_id;
         close c_abr;
         --
         update_net_credit_rate
           (p_prtt_rt_val_id    => null
           ,p_flex_rslt_id      => l_flex_rslt_id
           ,p_acty_base_rt_id   => l_acty_base_rt_id
           ,p_per_in_ler_id     => p_per_in_ler_id
           ,p_def_exc_amount    => l_def_exc_amount
           ,p_effective_date    => p_effective_date
           ,p_business_group_id => p_business_group_id
          );
       end if;
     end if;
   end if; -- l_uses_net_crs_mthd.
   --
   open  c_prv;
   fetch c_prv into l_prtt_rt_val_id,
                    l_rt_val, l_rt_strt_dt;
   --
   -- Update the flex credit rate with the total credits,
   -- if the value has changed.
   --
   hr_utility.set_location ('Total Credits'||l_total_credits,111);
   hr_utility.set_location ('Rate Value '||l_rt_val,111);
   if c_prv%found and l_total_credits <> l_rt_val then
      --
      hr_utility.set_location(l_proc,55);
      update_rate(p_prtt_rt_val_id      => l_prtt_rt_val_id,
                  p_val                 => l_total_credits,
                  p_prtt_enrt_rslt_id   => l_flex_rslt_id,
                  p_ended_per_in_ler_id => p_per_in_ler_id,
                  p_effective_date      => p_effective_date,
                  p_business_group_id   => p_business_group_id);
      --
   end if;

   close c_prv;

   hr_utility.set_location('Leaving '||l_proc,999);

end recompute_flex_credits;
--
--
end ben_provider_pools;

/
