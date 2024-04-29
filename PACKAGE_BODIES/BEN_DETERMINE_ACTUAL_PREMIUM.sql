--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ACTUAL_PREMIUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ACTUAL_PREMIUM" as
/* $Header: benacprm.pkb 120.5.12010000.3 2009/12/14 12:19:14 sallumwa ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                      Copyright (c) 1997 Oracle Corporation                   |
|                         Redwood Shores, California, USA                      |
|                                All rights reserved.                          |
+==============================================================================+
Name:
    Determine Actual Premiums

Purpose:
      This program determines the actual premium used for rates calculations.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        20 Apr 97        Ty Hayden  110.0      Created.
        16 Jun 98        T Guy      110.1      Removed other exception.
        25 Jun 98        T Guy      110.2      Replaced all occurrences of
                                               'PER10' with 'PERTEN'
        11 Aug 98        Ty Hayden  110.3      Added mlt cd NSVU
        08 Oct 98        T Guy      115.3      Fixed call to determine varibable
                                               rates. added message numbers and
                                               debugging messages.
        22 Oct 98        T Guy      115.4      removed show errors statement.
        25 Oct 98        T Guy      115.4      added mlt_cd = RL
        18 Jan 99        G Perry    115.6      LED V ED
        09 Mar 99        G Perry    115.7      IS to AS.
        07 Apr 99        mhoyes     115.8      Un-datetrack of per_in_ler_f changes.
                                               - Removed DT restriction from
                                               - main/c_epe
        04 May 99        shdas      115.9      Added contexts to rule calls.
        27 may 99        maagrawa   115.10     Modified the procedure to call without
                                               the chc_id and pass the reqd.
                                               values as parameters.
        25 Jun 99        T Guy      115.11     changed to be called directly from
                                               benmngle and added total premium
                                               logic
        2 Jul 99        lmcdonal    115.12     Made use of genutils procs rt_typ_
                                               calc and limit_checks.
        6 Jul 99         T Guy      115.13     Fixed writing of null val in
                                               enrt_prem should have been zero.
        6 Jul 99         T Guy      115.14     Fixed erroring when actual prem
                                               was not found.
        6 Jul 99         T Guy      115.15     Fixed edit check for null pl or
                                               oipl id's.
        7 Jul 99         T Guy      115.16     Fixed rate calc only edit to exit
                                               before writing to enrt_prem.
        16 Jul 99        lmcdonal   115.17     limit_checks parms changed.
        20 Jul 99        T Guy      115.18     Fixed logic errors for writing
                                               to enrt_prem.
        20 Jul 99        T Guy      115.19     took out nocopy show errors
        20 Jul 99        T Guy      115.20     genutils -> benutils
        07 Sep 99        T Guy      115.21     fixed call to
                                               pay_mag_utils.lookup_jurisdiction_code
        16 Sep 99        G Perry    115.22     Fixed c_epe cursor to not error
                                               when automatic enrollments have
                                               closed the active life event,
                                               instead now returns to calling
                                               function.
        29-Oct-99        lmcdonal   115.23     Needed to init l_coverage_value
                                               for each epe selected.
        15-Nov-99        mhoyes     115.24   - Added trace messages for profiing.
        18-Nov-99        pbodla     115.25   - Added elig_per_elctbl_chc_id as
                                               parameter while evaluating val_calc_rl
                                               and passed to limit_checks.
        17-Jan-00        tguy       115.26     Added check for rounding when vrbl
                                               rt trtmt cd = rplc do not round at
                                               value at this level
        02 Feb 00        lmcdonal   115.27     Break the computation of premium
                                               into a separate procedure so that
                                               it can be called independently.
                                               Bug 1166174.
        04-Apr-00        mmogel     115.28     Added tokes to messages to make
                                               them more meaningful to the user
        03-May-00        mhoyes     115.29     Removed request_id join from c_epe.
        08-Aug-00        pbodla     115.30   - Bug 4948(WWW Bug 1259220)
                                               When l_vr_trtmt_cd is null rounding
                                               is not applied. So nvl applied
                                               around l_vr_trtmt_cd.
        07-Nov-00        mhoyes     115.31   - Added electable choice context
                                               global.
                                             - Bulk inserted ben_enrt_prem.
        22-Nov-00        mhoyes     115.32   - Changed bulk bind composite data
                                               structure to a varray. This avoids
                                               random composite error on 8.1.6.2.
        05-Jan-01        kmahendr   115.33   - Added per_in_ler_id parameter to perpil_cache
                                               call
        15 mar 01        tilak      115.34     g_computed_prem_val is added
                                               This is used to store the value of the
                                               computed premium, whic can be used for
                                               calcualtion mode only to get the ammount
                                               In this mode ele_chc_id,benefit is not inserted
                                               so the global_variable to get the value
                                               bug :bug :1676551
         21-mar-2001    tilak        115.35   ultmt_upr_lmt,ultmt_lwr_lmt is validated
         02-apr-2001    tilak        115.36   ultmt_upr_lmt_calc_rl,ultmt_lwr_lmt_calc_rl is validated
         27-aug-2001    tilak        115.37   bug:1949361 jurisdiction code is
                                              derived inside benutils.formula.
         27-Sep-2001    kmahendr     115.38   Bug#1981673-Added parameter ann_mn_elcn_val and
                                              ann_mx_elcn_val to ben_determine_variable_rates
                                              call
         08-Jun-2002    pabodla    115.39     Do not select the contingent worker
                                              assignment when assignment data is
                                              fetched.
         14-Jun-2002    pabodla    115.41     Added dbdrv command
         02-Aug-2004    tjesumic   115.44     fonm, determination of fonm_flag changed from global varaible to epe dt
         08-Sep-2004    tjesumic   115.45     fonm, global fonm_cvg_strt_dt reintialized from epe dt
         08-Sep-2004    tjesumic   115.46     fonm, global fonm_cvg_strt_dt reintialized from epe dt
         08-Sep-2004    tjesumic   115.47     fonm, caching clearence
         15-Nov-2004    kmahendr   115.48     Unrest. enh changes
         30-dec-2004    nhunur     115.49     4031733 - No need to open cursor c_state.
         9-Jun-2005    nhunur      115.50     4383988 - do fnd_number.canonical_to_number() to the
                                               FF output before assigning to a number variable.
         03-Oct-05     ssarkar     115.51     4644867 - Added order by clause to cursoe c_asg to Query 'E' assignment first
	                                               and then others .
         10-Mar-06      swjain     115.52     In cursor c_asg, added condition to fetch active assignments only
         10-Mar-06      swjain     115.53     Updated cursor c_asg
         10-Aug-07      bmanyam    115.54     6330056 : Store all the premiums evaluated into
                                              global pl/sql tbl
	 11-Feb-2009    velvanop   115.55     Bug 7414757: Added parameter p_entr_val_at_enrt_flag.
	                                      VAPRO rates which are 'Enter value at Enrollment', Form field
					      should allow the user to enter a value during enrollment.
	 14-Dec-2009    sallumwa   115.56     Bug 9135034 : Get the FONM coverage date if the current LE is an
	                                      FONM Event.
  */
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_determine_actual_premium';

procedure calc_fonm_dates( p_effective_date    in date
                          ,p_business_group_id in number
                          ,p_per_in_ler_id     in number
                          ,p_person_id         in number
                          ,p_inst_set          in ben_epe_cache.g_pilepe_inst_row
                          ,p_calc_type         in varchar2
                          ,p_cvg_strt_dt       out nocopy date
                          ,p_rt_strt_dt        out nocopy date )
                         is

  l_package               varchar2(80) := g_package||'.calc_fonm_dates';

  l_enrt_cvg_strt_dt   date ;
  l_rt_strt_dt         date ;
  l_dummy_d            date ;
  l_dummy_v            varchar2(30);
  l_dummy_n            number;
Begin

 hr_utility.set_location ('Entering ' ||l_package,10);

       ben_determine_date.rate_and_coverage_dates
                          (p_which_dates_cd         => nvl(p_calc_type,'B')
                          ,p_date_mandatory_flag    => 'N'
                          ,p_compute_dates_flag     => 'Y'
                          ,p_elig_per_elctbl_chc_id => p_inst_set.elig_per_elctbl_chc_id
                          ,p_business_group_id      => p_business_group_id
                          ,P_PER_IN_LER_ID          => p_per_in_ler_id
                          ,P_PERSON_ID              => p_person_id
                          ,P_PGM_ID                 => p_inst_set.pgm_id
                          ,P_PL_ID                  => p_inst_set.pl_id
                          ,P_OIPL_ID                => p_inst_set.oipl_id
                          ,P_LEE_RSN_ID             => p_inst_set.lee_rsn_id
                          ,P_ENRT_PERD_ID           => p_inst_set.enrt_perd_id
                          ,p_enrt_cvg_strt_dt       => l_enrt_cvg_strt_dt
                          ,p_enrt_cvg_strt_dt_cd    => l_dummy_v
                          ,p_enrt_cvg_strt_dt_rl    => l_dummy_n
                          ,p_rt_strt_dt             => l_rt_strt_dt
                          ,p_rt_strt_dt_cd          => l_dummy_v
                          ,p_rt_strt_dt_rl          => l_dummy_n
                          ,p_enrt_cvg_end_dt        => l_dummy_d
                          ,p_enrt_cvg_end_dt_cd     => l_dummy_v
                          ,p_enrt_cvg_end_dt_rl     => l_dummy_n
                          ,p_rt_end_dt              => l_dummy_d
                          ,p_rt_end_dt_cd           => l_dummy_v
                          ,p_rt_end_dt_rl           => l_dummy_n
                          ,p_effective_date         => p_effective_date
                          ,p_lf_evt_ocrd_dt         => p_effective_date)
                          ;

  p_cvg_strt_dt       := l_enrt_cvg_strt_dt ;
  p_rt_strt_dt        := l_rt_strt_dt ;

 hr_utility.set_location ('Leaving ' ||l_package,10);

End  calc_fonm_dates ;


--------------------------------------------------------------------------------
--  COMPUTE_PREMIUM
--------------------------------------------------------------------------------
procedure  compute_premium
      (p_person_id              in number,
       p_lf_evt_ocrd_dt         IN date,
       p_effective_date         IN date,
       p_business_group_id      in number,
       p_per_in_ler_id          in number,
       p_ler_id                 in number,
       p_actl_prem_id           in number,
       p_perform_rounding_flg   IN boolean default true,
       p_calc_only_rt_val_flag  in boolean default false,
       p_pgm_id                 in number,
       p_pl_typ_id              in number,
       p_pl_id                  in number,
       p_oipl_id                in number,
       p_opt_id                 in number,
       p_elig_per_elctbl_chc_id in number,
       p_enrt_bnft_id           in number,
       p_bnft_amt               in number,
       p_prem_val               in number,
       p_mlt_cd                 in varchar2,
       p_bnft_rt_typ_cd         in varchar2,
       p_val_calc_rl            in number,
       p_rndg_cd                in varchar2,
       p_rndg_rl                in number,
       p_upr_lmt_val            in number,
       p_lwr_lmt_val            in number,
       p_upr_lmt_calc_rl        in number,
       p_lwr_lmt_calc_rl        in number,
       p_fonm_cvg_strt_dt       in date default null ,
       p_fonm_rt_strt_dt        in date default null ,
       p_computed_val          out nocopy number) IS

  l_package               varchar2(80) := g_package||'.compute_premium';
 -- fonm new p_date param added
  Cursor c_state (p_date date) is
    select region_2
    from   hr_locations_all loc,per_all_assignments_f asg
    where  loc.location_id = asg.location_id
      and  asg.person_id = p_person_id
      and  asg.assignment_type <> 'C'
      and  asg.primary_flag = 'Y'
      and  p_date between
           asg.effective_start_date and asg.effective_end_date;

  l_state c_state%rowtype;
  --
  -- fonm new p_date param added
  cursor c_asg(p_date date) is
    select asg.assignment_id,asg.organization_id,loc.region_2
    from   per_all_assignments_f asg,hr_locations_all loc, per_assignment_status_types ast
    where  asg.person_id = p_person_id
    and    asg.assignment_type <> 'C'
    and    asg.primary_flag = 'Y'
    and    asg.location_id  = loc.location_id(+)
    and    asg.assignment_status_type_id = ast.assignment_status_type_id(+)
    and    ast.per_system_status(+) = 'ACTIVE_ASSIGN'
    --and    nvl(p_lf_evt_ocrd_dt,p_effective_date)
    and    p_date
           between asg.effective_start_date
           and     asg.effective_end_date
    order by assignment_type desc, effective_start_date desc; -- BUG 4644867
  l_asg c_asg%rowtype;

  --------------Bug 9135034
   cursor c_epe is
      select epe.fonm_cvg_strt_dt
      from ben_elig_per_elctbl_chc epe
      where epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id ;
  l_fonm_cvg_strt_dt1  date;
  ---------------Bug 9135034
  l_jurisdiction_code     varchar2(30);
  l_outputs               ff_exec.outputs_t;
  l_variable_val          number;
  l_vr_trtmt_cd           varchar(30);
  l_dummy_number          number;
  l_dummy_char            varchar(30);
  l_ultmt_upr_lmt         number ;
  l_ultmt_lwr_lmt         number ;
  l_ultmt_upr_lmt_calc_rl number ;
  l_ultmt_lwr_lmt_calc_rl number ;
  l_vr_ann_mn_elcn_val       number;
  l_vr_ann_mx_elcn_val       number;
  l_entr_val_at_enrt_flag  varchar2(10);  -- Bug 7414757

  -- bof  FONM
  l_fonm_date date ;
  --eof  FONM
begin
  hr_utility.set_location ('Entering ' ||l_package,10);
  hr_utility.set_location ('l_apr.mlt_cd -> '||p_mlt_cd,10);
  --
  -- get values for rules and limit checking
  --bof FONM
  l_fonm_date := nvl(p_lf_evt_ocrd_dt,p_effective_date ) ;
  -------Bug 9135034
  open c_epe;
  fetch c_epe into l_fonm_cvg_strt_dt1;
  close c_epe;
  hr_utility.set_location ('l_fonm_cvg_strt_dt1 -> '|| l_fonm_cvg_strt_dt1,10);
  if l_fonm_cvg_strt_dt1 is not null then
     ben_manage_life_events.fonm  := 'Y';
     ben_manage_life_events.g_fonm_cvg_strt_dt := l_fonm_cvg_strt_dt1;
     ben_manage_life_events.g_fonm_rt_strt_dt := p_fonm_rt_strt_dt;
  end if;
  hr_utility.set_location ('ben_manage_life_events.fonm -> '||ben_manage_life_events.fonm,10);
  ------Bug 9135034
  if  ben_manage_life_events.fonm = 'Y' then
      l_fonm_date := nvl(p_fonm_cvg_strt_dt, l_fonm_date ) ;
  end if ;
  --eof FONM
/* -- 4031733 - cursor used to populate l_state.region_2
   -- param for benutils.limit_checks which is not used down the line
   --
  open c_state (l_fonm_date);
    fetch c_state into l_state;
  close c_state;
*/
  open c_asg (l_fonm_date);
    fetch c_asg into l_asg;
  close c_asg;

  --if l_asg.region_2 is not null then

  --  l_jurisdiction_code :=
  --     pay_mag_utils.lookup_jurisdiction_code
  --       (p_state => l_asg.region_2);

  --end if;

           --
           -- Flat-Fixed
           --
           if p_mlt_cd = 'FLFX' then
             hr_utility.set_location ('in flfx',20);
             p_computed_val := p_prem_val;
           --
           -- Multiple of Coverage
           --
           elsif p_mlt_cd = 'CVG' then
             hr_utility.set_location ('in cvg',30);
             if p_bnft_amt is null then
                if p_enrt_bnft_id is null then
                  hr_utility.set_location ('BEN_91579_BENACPRM_INPT_EB',40);
                  fnd_message.set_name('BEN','BEN_91579_BENACPRM_INPT_EB');
                  fnd_message.set_token('PROC',l_package);
                  fnd_message.set_token('PERSON_ID',to_char(p_person_id));
                  fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
                  fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
                  fnd_message.set_token('PL_ID',to_char(p_pl_id));
                  fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
                  fnd_message.set_token('LF_EVT_OCRD_DT',
                                         to_char(p_lf_evt_ocrd_dt));
                  fnd_message.set_token('MLT_CD',p_mlt_cd);
                  fnd_message.raise_error;
                end if;
             end if;

             if p_bnft_amt is NULL then
             --
             -- Means that cvg to be selected upon enrt
             --
               p_computed_val := 0;
             --
             -- if coverage value is not null then process as defined
             --
             else
                benutils.rt_typ_calc
                   (p_rt_typ_cd      => p_bnft_rt_typ_cd
                   ,p_val            => p_prem_val
                   ,p_val_2          => p_bnft_amt
                   ,p_calculated_val => p_computed_val);
             end if;
           --
           -- Rule
           --
           elsif p_mlt_cd = 'RL' then
             --
             -- Call formula initialise routine
             hr_utility.set_location ('in rl',10);

             l_outputs := benutils.formula
               (p_formula_id       => p_val_calc_rl,
                p_effective_date   => nvl(p_lf_evt_ocrd_dt,p_effective_date),
                p_business_group_id=> p_business_group_id,
                p_assignment_id    => l_asg.assignment_id,
                p_organization_id  => l_asg.organization_id,
                p_pgm_id           => p_pgm_id,
                p_pl_id            => p_pl_id,
                p_pl_typ_id        => p_pl_typ_id,
                p_opt_id           => p_opt_id,
                p_ler_id           => p_ler_id,
                p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                p_jurisdiction_code=> l_jurisdiction_code,
                --- Bof  FONM
                p_param1             => 'RT_STRT_DT',
                p_param1_value       => fnd_date.date_to_canonical(p_fonm_rt_strt_dt), -- null is passed, 4 future
                p_param2             => 'CVG_STRT_DT',
                p_param2_value       => fnd_date.date_to_canonical(p_fonm_cvg_strt_dt)
                --- Eof FONM
                );
             --
             p_computed_val := fnd_number.canonical_to_number(l_outputs(l_outputs.first).value);

           elsif p_mlt_cd = 'NSVU' then
             -- Do nothing for NO STANDARD VALUE USED
             -- Value used comes from Variable rates below.
             hr_utility.set_location ('in nsvu',10);
             null;
           else
             hr_utility.set_location ('BEN_91584_BENACPRM_MLT_CD',50);
             fnd_message.set_name('BEN','BEN_91584_BENACPRM_MLT_CD');
             fnd_message.set_token('PROC',l_package);
             fnd_message.set_token('PERSON_ID',to_char(p_person_id));
             fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
             fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
             fnd_message.set_token('PL_ID',to_char(p_pl_id));
             fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
             fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
             fnd_message.set_token('MLT_CD',p_mlt_cd);
             fnd_message.raise_error;
           end if;
           --
           ----bug : 143393 Limit validation applied to premium
           ----      before calc VAPRP, after vapro and premium
           ----      ultimate value of vapro will be applied
           ----      the same apply to rounding

           -- perform appropriate rounding based on the source table.
           -- rounding_cd or rule cannot both be null, perform_rounding_flag
           -- must be true....
           --
           -- Bug 4948(WWW Bug 1259220)
           -- When l_vr_trtmt_cd is null rounding is not applied.
           -- So nvl applied around l_vr_trtmt_cd.
           --
           if (p_rndg_cd is not null or
              p_rndg_rl is not null) and
              p_perform_rounding_flg = true and
              p_computed_val is not null and
              nvl(l_vr_trtmt_cd, 'XXXX') <> 'RPLC' then
             hr_utility.set_location ('rounding ',70);
             p_computed_val := benutils.do_rounding
                (p_rounding_cd     => p_rndg_cd,
                 p_rounding_rl     => p_rndg_rl,
                 p_value           => p_computed_val,
                 --- fonm
                 p_effective_date  => l_fonm_date  ) ;  --- nvl(p_lf_evt_ocrd_dt,p_effective_date));
           end if;
           --
           -- check upr/lwr limit
           --
           hr_utility.set_location('check the limit of prm ',20);
           benutils.limit_checks
                    (p_upr_lmt_val       => p_upr_lmt_val,
                     p_lwr_lmt_val       => p_lwr_lmt_val,
                     p_upr_lmt_calc_rl   => p_upr_lmt_calc_rl,
                     p_lwr_lmt_calc_rl   => p_lwr_lmt_calc_rl,
                     -- fonm
                     p_effective_date    => l_fonm_date , -- nvl(p_lf_evt_ocrd_dt,p_effective_date),
                     p_business_group_id => p_business_group_id,
                     p_assignment_id     => l_asg.assignment_id,
                     p_organization_id   => l_asg.organization_id,
                     p_pgm_id            => p_pgm_id,
                     p_pl_id             => p_pl_id,
                     p_pl_typ_id         => p_pl_typ_id,
                     p_opt_id            => p_opt_id,
                     p_ler_id            => p_ler_id,
                     p_state             => l_state.region_2,
                     p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                     p_val               => p_computed_val);


           ------------------------------------------
           -- variable rates
           ------------------------------------------
           --
           ben_determine_variable_rates.main
             (p_person_id              => p_person_id,
              p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
              p_enrt_bnft_id           => p_enrt_bnft_id,
              p_actl_prem_id           => p_actl_prem_id,
              --
              p_effective_date         => l_fonm_date , ---p_effective_date,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_calc_only_rt_val_flag  => p_calc_only_rt_val_flag,
              p_pgm_id                 => p_pgm_id,
              p_pl_id                  => p_pl_id,
              p_oipl_id                => p_oipl_id,
              p_pl_typ_id              => p_pl_typ_id,
              p_per_in_ler_id          => p_per_in_ler_id,
              p_ler_id                 => p_ler_id,
              p_business_group_id      => p_business_group_id,
              p_bnft_amt               => p_bnft_amt,
	      p_entr_val_at_enrt_flag  => l_entr_val_at_enrt_flag, -- Bug 7414757
              p_val                    => l_variable_val,
              p_mn_elcn_val            => l_dummy_number,
              p_mx_elcn_val            => l_dummy_number,
              p_incrmnt_elcn_val       => l_dummy_number,
              p_dflt_elcn_val          => l_dummy_number,   -- do not apply to premiums
              p_tx_typ_cd              => l_dummy_char,
              p_acty_typ_cd            => l_dummy_char,
              p_vrbl_rt_trtmt_cd       => l_vr_trtmt_cd,
              p_ann_mn_elcn_val        => l_vr_ann_mn_elcn_val,
              p_ann_mx_elcn_val        => l_vr_ann_mx_elcn_val,
              p_ultmt_upr_lmt          => l_ultmt_upr_lmt,
              p_ultmt_lwr_lmt          => l_ultmt_lwr_lmt,
              p_ultmt_upr_lmt_calc_rl  => l_ultmt_upr_lmt_calc_rl,
              p_ultmt_lwr_lmt_calc_rl  => l_ultmt_lwr_lmt_calc_rl);
           --
           hr_utility.set_location ('after variable rates',60);
           hr_utility.set_location ('l_vr_trtmt_cd -> '||l_vr_trtmt_cd,60);
           hr_utility.set_location ('l_vr_val -> '||l_variable_val,60);
           hr_utility.set_location ('l_val -> '||p_computed_val,60);

           if p_computed_val is null then
             l_vr_trtmt_cd := 'RPLC';
           end if;

           if l_variable_val is not null then
             --
             -- Replace
             if l_vr_trtmt_cd = 'RPLC' then
               p_computed_val := l_variable_val;

               -- Multiply By
             elsif l_vr_trtmt_cd = 'MB' then
               p_computed_val := p_computed_val * l_variable_val;

               -- Subtract From
             elsif l_vr_trtmt_cd = 'SF' then
               p_computed_val := p_computed_val - l_variable_val;

               -- Add To
             elsif l_vr_trtmt_cd = 'ADDTO' then
               p_computed_val := p_computed_val + l_variable_val;
             else -- Replace
               p_computed_val := l_variable_val;
             end if;

             if l_ultmt_upr_lmt is not null or l_ultmt_lwr_lmt is not null
               OR  l_ultmt_upr_lmt_calc_rl is not null or l_ultmt_lwr_lmt_calc_rl is not null then
                --- if ultmate limit defined in VAPRO chek the limit
                hr_utility.set_location('calling limit for ultmt of prem',393);
                hr_utility.set_location('upper '|| l_ultmt_upr_lmt ||' Lower' || l_ultmt_lwr_lmt,393);
                hr_utility.set_location('ammount '|| p_computed_val ,393);
                benutils.limit_checks
                    (p_upr_lmt_val       => l_ultmt_upr_lmt,
                     p_lwr_lmt_val       => l_ultmt_lwr_lmt,
                     p_upr_lmt_calc_rl   => l_ultmt_upr_lmt_calc_rl,
                     p_lwr_lmt_calc_rl   => l_ultmt_lwr_lmt_calc_rl,
                     --- fonm
                     p_effective_date    => l_fonm_date ,  --- nvl(p_lf_evt_ocrd_dt,p_effective_date),
                     p_business_group_id => p_business_group_id,
                     p_assignment_id     => l_asg.assignment_id,
                     p_organization_id   => l_asg.organization_id,
                     p_pgm_id            => p_pgm_id,
                     p_pl_id             => p_pl_id,
                     p_pl_typ_id         => p_pl_typ_id,
                     p_opt_id            => p_opt_id,
                     p_ler_id            => p_ler_id,
                     p_state             => l_state.region_2,
                     p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                     p_val               => p_computed_val);
                     hr_utility.set_location('ammount '|| p_computed_val ,393);

             end if ;
           end if;
           --
          /*
           -- perform appropriate rounding based on the source table.
           -- rounding_cd or rule cannot both be null, perform_rounding_flag
           -- must be true....
           --
           -- Bug 4948(WWW Bug 1259220)
           -- When l_vr_trtmt_cd is null rounding is not applied.
           -- So nvl applied around l_vr_trtmt_cd.
           --
           if (p_rndg_cd is not null or
              p_rndg_rl is not null) and
              p_perform_rounding_flg = true and
              p_computed_val is not null and
              nvl(l_vr_trtmt_cd, 'XXXX') <> 'RPLC' then
             hr_utility.set_location ('rounding ',70);
             p_computed_val := benutils.do_rounding
                (p_rounding_cd     => p_rndg_cd,
                 p_rounding_rl     => p_rndg_rl,
                 p_value           => p_computed_val,
                 -- fonm
                 p_effective_date  => l_fonm_date) ;  --- nvl(p_lf_evt_ocrd_dt,p_effective_date));
           end if;
           --
           -- check upr/lwr limit
           --
           benutils.limit_checks
                    (p_upr_lmt_val       => p_upr_lmt_val,
                     p_lwr_lmt_val       => p_lwr_lmt_val,
                     p_upr_lmt_calc_rl   => p_upr_lmt_calc_rl,
                     p_lwr_lmt_calc_rl   => p_lwr_lmt_calc_rl,
                    -- fonm
                     p_effective_date    => l_fonm_date  ,  --  nvl(p_lf_evt_ocrd_dt,p_effective_date),
                     p_business_group_id => p_business_group_id,
                     p_assignment_id     => l_asg.assignment_id,
                     p_organization_id   => l_asg.organization_id,
                     p_pgm_id            => p_pgm_id,
                     p_pl_id             => p_pl_id,
                     p_pl_typ_id         => p_pl_typ_id,
                     p_opt_id            => p_opt_id,
                     p_ler_id            => p_ler_id,
                     p_state             => l_state.region_2,
                     p_elig_per_elctbl_chc_id => p_elig_per_elctbl_chc_id,
                     p_val               => p_computed_val);
             */

  hr_utility.set_location ('Leaving '||l_package,99);

end compute_premium;
--------------------------------------------------------------------------------
--  MAIN
--------------------------------------------------------------------------------
PROCEDURE main
     ( p_person_id              in number,
       p_effective_date         IN date,
       p_lf_evt_ocrd_dt         IN date,
       p_perform_rounding_flg   IN boolean default true,
       p_calc_only_rt_val_flag  in boolean default false,
       p_pgm_id                 in number  default null,
       p_pl_id                  in number  default null,
       p_oipl_id                in number  default null,
       p_pl_typ_id              in number  default null,
       p_per_in_ler_id          in number  default null,
       p_ler_id                 in number  default null,
       p_bnft_amt               in number  default null,
       p_business_group_id      in number  default null,
       p_mode                   in varchar2
     ) IS
  --
  l_package                   varchar2(80) := g_package||'.main';
  --
  l_currepe_set               ben_epe_cache.g_pilepe_inst_tbl;
  --
  l_val_va                    benutils.g_number_table := benutils.g_number_table();
  l_uom_va                    benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_elig_per_elctbl_chc_id_va benutils.g_number_table := benutils.g_number_table();
  l_enrt_bnft_id_va           benutils.g_number_table := benutils.g_number_table();
  l_actl_prem_id_va           benutils.g_number_table := benutils.g_number_table();
  l_business_group_id_va      benutils.g_number_table := benutils.g_number_table();
  --
  l_epr_attribute_category_va benutils.g_v2_30_table := benutils.g_v2_30_table();
  l_epr_attribute1_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute2_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute3_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute4_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute5_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute6_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute7_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute8_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute9_va         benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute10_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute11_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute12_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute13_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute14_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute15_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute16_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute17_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute18_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute19_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute20_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute21_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute22_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute23_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute24_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute25_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute26_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute27_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute28_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute29_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_epr_attribute30_va        benutils.g_v2_150_table := benutils.g_v2_150_table();
  --
  l_object_version_number_va  benutils.g_number_table := benutils.g_number_table();
  --
  l_request_id_va             benutils.g_number_table := benutils.g_number_table();
  l_program_application_id_va benutils.g_number_table := benutils.g_number_table();
  l_program_id_va             benutils.g_number_table := benutils.g_number_table();
  l_program_update_date_va    benutils.g_date_table := benutils.g_date_table();
  --
  l_val                       number;
  l_enrt_prem_id              number;
  l_object_version_number     number;
  l_ap_found                  boolean := true;
  --
  -- fonm new parameter of date
  cursor c_apr_pl(p_pl_id in number,p_date date) is
    select apr.actl_prem_id,
           apr.mlt_cd,
           apr.val,
           apr.rndg_cd,
           apr.rndg_rl,
           apr.rt_typ_cd,
           apr.bnft_rt_typ_cd,
           apr.comp_lvl_fctr_id,
           apr.prem_asnmt_cd,
           apr.val_calc_rl,
           apr.upr_lmt_val,
           apr.upr_lmt_calc_rl,
           apr.lwr_lmt_val,
           apr.lwr_lmt_calc_rl,
           apr.uom
    from   ben_actl_prem_f apr
    where  apr.pl_id = p_pl_id
    and    apr.prem_asnmt_cd = 'ENRT'  --  PROC are dealt with in benprplc.pkb
    and    p_date
           between apr.effective_start_date
           and     apr.effective_end_date;
  -- Fonm  new parameter of date
  cursor c_apr_oipl(p_oipl_id in number,p_date date) is
    select apr.actl_prem_id,
           apr.mlt_cd,
           apr.val,
           apr.rndg_cd,
           apr.rndg_rl,
           apr.rt_typ_cd,
           apr.bnft_rt_typ_cd,
           apr.comp_lvl_fctr_id,
           apr.prem_asnmt_cd,
           apr.val_calc_rl,
           apr.upr_lmt_val,
           apr.upr_lmt_calc_rl,
           apr.lwr_lmt_val,
           apr.lwr_lmt_calc_rl,
           apr.uom
    from   ben_actl_prem_f apr
    where  apr.oipl_id = p_oipl_id
    and    apr.prem_asnmt_cd = 'ENRT'  --  PROC are dealt with in benprplc.pkb
    and    p_date
           between apr.effective_start_date
           and     apr.effective_end_date;
  --
  l_apr c_apr_pl%rowtype;
  -- fonm p_date parameter added
  cursor c_opt(p_oipl_id in number, p_date date) is
    select oipl.opt_id
    from   ben_oipl_f oipl
    where  oipl.oipl_id = p_oipl_id
      --and  p_effective_date between
        and  p_date  between
             oipl.effective_start_date and oipl.effective_end_date;

  l_opt        c_opt%rowtype;
  l_epr_elenum pls_integer;
  -- Bof FONM
  l_fonm_date   date  ;
  l_fonm_flag   varchar2(1) :=   ben_manage_life_events.fonm ;
  l_fonm_cvg_strt_dt date ;
  l_fonm_rt_strt_dt  date ;
  l_dummy_d     date ;
  l_fonm_per_rec       per_all_people_f%rowtype;
  l_fonm_ass_rec       per_all_assignments_f%rowtype;
  l_comp_prem_idx       number;

  -- Eof FONM

BEGIN
  --
  hr_utility.set_location ('Entering '||l_package,10);
  hr_utility.set_location ('p_person_id         :  '||p_person_id        ,10);
  hr_utility.set_location ('p_effective_date    :  '||p_effective_date   ,10);
  hr_utility.set_location ('p_lf_evt_ocrd_dt    :  '||p_lf_evt_ocrd_dt   ,10);
  hr_utility.set_location ('p_pgm_id            :  '||p_pgm_id           ,10);
  hr_utility.set_location ('p_pl_id             :  '||p_pl_id            ,10);
  hr_utility.set_location ('p_oipl_id           :  '||p_oipl_id          ,10);
  hr_utility.set_location ('p_pl_typ_id         :  '||p_pl_typ_id        ,10);
  hr_utility.set_location ('p_per_in_ler_id     :  '||p_per_in_ler_id    ,10);
  hr_utility.set_location ('p_bnft_amt          :  '||p_bnft_amt         ,10);
  hr_utility.set_location ('p_business_group_id :  '||p_business_group_id,10);
  -- since the premium called out side of compobject loop
  -- global variable can not be used to determine the fonm mode
  -- use the epe fonmv cvg date used for the purpose



  -- Edit to ensure that the input p_person_id has a value
  --
  If (p_person_id is null) then
    hr_utility.set_location ('BEN_91574_BENACPRM_INPT_PRSN',20);
    fnd_message.set_name('BEN','BEN_91574_BENACPRM_INPT_PRSN');
    fnd_message.set_token('PROC',l_package);
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.raise_error;
  end if;
  --
  -- Edit to insure that the input p_effective_date has a value
  --
  If (p_effective_date is null) then
    hr_utility.set_location ('BEN_91575_BENACPRM_INPT_EFFDT',30);
    fnd_message.set_name('BEN','BEN_91575_BENACPRM_INPT_EFFDT');
    fnd_message.set_token('PROC',l_package);
    fnd_message.set_token('PERSON_ID',to_char(p_person_id));
    fnd_message.set_token('PGM_ID',to_char(p_pgm_id));
    fnd_message.set_token('PL_TYP_ID',to_char(p_pl_typ_id));
    fnd_message.set_token('PL_ID',to_char(p_pl_id));
    fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
    fnd_message.set_token('LF_EVT_OCRD_DT',to_char(p_lf_evt_ocrd_dt));
    fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
    fnd_message.raise_error;
  end if;

  if p_calc_only_rt_val_flag then
    --
    l_currepe_set(0).pl_id             := p_pl_id;
    l_currepe_set(0).oipl_id           := p_oipl_id;
    l_currepe_set(0).pgm_id            := p_pgm_id;
    l_currepe_set(0).pl_typ_id         := p_pl_typ_id;
    l_currepe_set(0).per_in_ler_id     := p_per_in_ler_id;
    l_currepe_set(0).ler_id            := p_ler_id;
    l_currepe_set(0).business_group_id := p_business_group_id;
    l_currepe_set(0).val               := p_bnft_amt;
    --
  else
    --
    --  unrestricted enhancement- added per_in_ler_id parameter
    ben_epe_cache.get_perpilepe_list
      (p_person_id => p_person_id
      ,p_per_in_ler_id =>p_per_in_ler_id
      --
      ,p_inst_set  => l_currepe_set
      );
    --
  end if;
  --
  -- Clear epe context row
  --
  ben_epe_cache.init_context_pileperow;
  --
  -- 6330056: Reset global values before calculation.
  g_computed_prem_tbl.delete;
  l_comp_prem_idx := 0;
  --
  --  loop through all choices for this person
  --
  if l_currepe_set.count > 0 then
     --
     l_epr_elenum := 1;
     --
    for epe_elenum in l_currepe_set.first..l_currepe_set.last loop
      hr_utility.set_location (' St EPE CORVF loop ',40);
      --
      -- Set the electable choice context variable
      --
      ben_epe_cache.g_currepe_row := l_currepe_set(epe_elenum);
      --
      hr_utility.set_location ('loop choices -> '||l_currepe_set(epe_elenum).elig_per_elctbl_chc_id,50);

      -- BOF FONM
      l_fonm_cvg_strt_dt := null ;
      l_fonm_rt_strt_dt  := null ;

      if l_currepe_set(epe_elenum).fonm_cvg_strt_dt is not null then
         l_FONM_flag := 'Y' ;
      else
          l_FONM_flag := 'N' ;
          l_FONM_date         :=  nvl(p_lf_evt_ocrd_dt, p_effective_date) ;
          ben_manage_life_events.g_fonm_cvg_strt_dt := null ;
          ben_manage_life_events.fonm := 'N'  ;
      end if ;
      hr_utility.set_location ('premium fonm  -> '||l_FONM_flag,50);

      if l_FONM_flag = 'Y' then

         if l_currepe_set(epe_elenum).fonm_cvg_strt_dt is not null then
            l_FONM_date  :=  l_currepe_set(epe_elenum).fonm_cvg_strt_dt ;
            l_fonm_cvg_strt_dt:=  l_currepe_set(epe_elenum).fonm_cvg_strt_dt ;
            ben_manage_life_events.g_fonm_cvg_strt_dt := l_fonm_cvg_strt_dt ;
            ben_manage_life_events.fonm := 'Y'  ;
         end if ;

         /*  -- for future
         --- calcualte the rate start date
         if l_fonm_rt_strt_dt is null then
             -- Calcaulte the coverage start date
            calc_fonm_dates(p_effective_date   => nvl(p_lf_evt_ocrd_dt, p_effective_date)
                          ,p_business_group_id => p_business_group_id
                          ,p_per_in_ler_id     => p_per_in_ler_id
                          ,p_person_id         => p_person_id
                          ,p_inst_set          => ben_epe_cache.g_currepe_row
                          ,p_calc_type         => 'R'
                          ,p_cvg_strt_dt       => l_dummy_d
                          ,p_rt_strt_dt        => l_fonm_rt_strt_dt ) ;
         end if ;
         */

      end if ;
      hr_utility.set_location ('g_fonm_cvg_strt_dt  '||ben_manage_life_events.g_fonm_cvg_strt_dt,50);
      -- EOF FONM

      -- l_enrt_bnft_id := l_currepe_set(epe_elenum).enrt_bnft_id;
      -- l_coverage_value := null;

      if l_currepe_set(epe_elenum).oipl_id is not NULL then
        hr_utility.set_location ('getting apr_oipl -> '||l_currepe_set(epe_elenum).oipl_id,60);
        -- FONM  l_fonm_date send as param
        open c_apr_oipl(l_currepe_set(epe_elenum).oipl_id,l_FONM_date);
        fetch c_apr_oipl into l_apr;
        if c_apr_oipl%notfound then
          --
          -- no actual premiums for this oipl
          --
          hr_utility.set_location ('apr_oipl -> '||l_currepe_set(epe_elenum).oipl_id||' <- not found',70);
          close c_apr_oipl;
          l_ap_found := false;
        else
          -- FONM  l_fonm_date send as param
          open c_opt(l_currepe_set(epe_elenum).oipl_id,l_FONM_date);
            fetch c_opt into l_opt;
          close c_opt;
        end if;
      elsif l_currepe_set(epe_elenum).pl_id is not NULL then
        hr_utility.set_location ('getting apr_pl -> '||l_currepe_set(epe_elenum).pl_id,80);
         -- FONM  l_fonm_date send as param
        open c_apr_pl(l_currepe_set(epe_elenum).pl_id,l_FONM_date);
        fetch c_apr_pl into l_apr;
        if c_apr_pl%notfound then
          --
          -- no actual premiums for this pl
          --
          hr_utility.set_location ('apr_pl -> '||l_currepe_set(epe_elenum).pl_id||' <- not found',90);
          close c_apr_pl;
          l_ap_found := false;
        end if;
      else
        l_ap_found := false;
      end if;
      --
      --  loop through all actl prem for this elctbl_chc
      --
      hr_utility.set_location ('FONM CVG DATE  -> '||l_fonm_date ,90);
      hr_utility.set_location ('FONM Rate DATE  ->'||l_fonm_rt_strt_dt ,90);
      if l_ap_found then


          -- fonm caching validation for premium
          -- fonm  check the caching for person level  and asg level
          ben_person_object.get_object(p_person_id => p_person_id,
                                   p_rec       => l_fonm_per_rec);
          if not nvl(l_fonm_cvg_strt_dt,l_FONM_date )  between l_fonm_per_rec.effective_start_date
                and l_fonm_per_rec.effective_end_date then

             hr_utility.set_location('cache clearence   ' || l_package  ,10);
             ben_use_cvg_rt_date.fonm_clear_down_cache;
          else
             ben_person_object.get_object(p_person_id => p_person_id,
                                        p_rec       => l_fonm_ass_rec);
             if  not nvl(l_fonm_cvg_strt_dt,l_FONM_date )  between l_fonm_ass_rec.effective_start_date
                     and l_fonm_ass_rec.effective_end_date then
                 hr_utility.set_location('cache clearence   ' || l_package  ,10);
                 ben_use_cvg_rt_date.fonm_clear_down_cache;
             end if ;
          end if ;
            --
        --
        loop
          hr_utility.set_location (l_package||' St EPE AP loop ',100);
          if l_currepe_set(epe_elenum).oipl_id is not null then
             exit when c_apr_oipl%notfound;
          elsif l_currepe_set(epe_elenum).pl_id is not null then
             exit when c_apr_pl%notfound;
          end if;
          --hr_utility.set_location ('l_apr.actl_prem_id->'||l_apr.actl_prem_id,110);
          --  hr_utility.set_location ('l_apr.prem_asnmt_cd -> '||l_apr.prem_asnmt_cd,110);
          --  hr_utility.set_location ('l_apr.mlt_cd -> '||l_apr.mlt_cd,110);

    --    if l_apr.prem_asnmt_cd = 'ENRT' then
            compute_premium
             (p_person_id              => p_person_id,
              p_lf_evt_ocrd_dt         => p_lf_evt_ocrd_dt,
              p_effective_date         => p_effective_date,
              p_business_group_id      => l_currepe_set(epe_elenum).business_group_id,
              p_per_in_ler_id          => l_currepe_set(epe_elenum).per_in_ler_id,
              p_ler_id                 => l_currepe_set(epe_elenum).ler_id,
              p_actl_prem_id           => l_apr.actl_prem_id,
              p_perform_rounding_flg   => p_perform_rounding_flg,
              p_calc_only_rt_val_flag  => p_calc_only_rt_val_flag,
              p_pgm_id                 => l_currepe_set(epe_elenum).pgm_id,
              p_pl_typ_id              => l_currepe_set(epe_elenum).pl_typ_id,
              p_pl_id                  => l_currepe_set(epe_elenum).pl_id,
              p_oipl_id                => l_currepe_set(epe_elenum).oipl_id,
              p_opt_id                 => l_opt.opt_id,
              p_elig_per_elctbl_chc_id => l_currepe_set(epe_elenum).elig_per_elctbl_chc_id,
              p_enrt_bnft_id           => l_currepe_set(epe_elenum).enrt_bnft_id,
              p_bnft_amt               => l_currepe_set(epe_elenum).val,
              p_prem_val               => l_apr.val,
              p_mlt_cd                 => l_apr.mlt_cd,
              p_bnft_rt_typ_cd         => l_apr.bnft_rt_typ_cd,
              p_val_calc_rl            => l_apr.val_calc_rl,
              p_rndg_cd                => l_apr.rndg_cd,
              p_rndg_rl                => l_apr.rndg_rl,
              p_upr_lmt_val            => l_apr.upr_lmt_val,
              p_lwr_lmt_val            => l_apr.lwr_lmt_val,
              p_upr_lmt_calc_rl        => l_apr.upr_lmt_calc_rl,
              p_lwr_lmt_calc_rl        => l_apr.lwr_lmt_calc_rl,
              p_fonm_cvg_strt_dt       => l_fonm_cvg_strt_dt,
              p_fonm_rt_strt_dt        => l_fonm_rt_strt_dt,
              p_computed_val           => l_val); -- ouput

           --bug :1676551 assigning the valu to global variable
           g_computed_prem_val         := l_val ;
           --
           -- 6330056 : Store all the premiums evaluated into
           -- global pl/sql tbl
           l_comp_prem_idx := l_comp_prem_idx + 1;
           g_computed_prem_tbl(l_comp_prem_idx).actl_prem_id := l_apr.actl_prem_id;
           g_computed_prem_tbl(l_comp_prem_idx).val := l_val;
           --
           hr_utility.set_location ('Premium Count ' || l_comp_prem_idx,120);
           hr_utility.set_location ('actl_prem_id  ' || l_apr.actl_prem_id,120);
           hr_utility.set_location ('Premium Value ' || l_val,120);
           --
           -- write enrt_prem record
           --
           hr_utility.set_location ('writing enrt_prem ',120);
           --
           -- Add enrt prem row to the varray
           --
           l_val_va.extend(1);
           l_val_va(l_epr_elenum) := nvl(l_val,0);
           l_uom_va.extend(1);
           l_uom_va(l_epr_elenum) := l_apr.uom;
           l_elig_per_elctbl_chc_id_va.extend(1);
           l_elig_per_elctbl_chc_id_va(l_epr_elenum) := l_currepe_set(epe_elenum).elig_per_elctbl_chc_id;
           l_enrt_bnft_id_va.extend(1);
           l_enrt_bnft_id_va(l_epr_elenum) := l_currepe_set(epe_elenum).enrt_bnft_id;
           l_actl_prem_id_va.extend(1);
           l_actl_prem_id_va(l_epr_elenum) := l_apr.actl_prem_id;
           l_business_group_id_va.extend(1);
           l_business_group_id_va(l_epr_elenum) := l_currepe_set(epe_elenum).business_group_id;
           --
           l_epr_attribute_category_va.extend(1);
           l_epr_attribute_category_va(l_epr_elenum) := null;
   	   l_epr_attribute1_va.extend(1);
   	   l_epr_attribute1_va(l_epr_elenum) := null;
   	   l_epr_attribute2_va.extend(1);
   	   l_epr_attribute2_va(l_epr_elenum) := null;
   	   l_epr_attribute3_va.extend(1);
   	   l_epr_attribute3_va(l_epr_elenum) := null;
   	   l_epr_attribute4_va.extend(1);
   	   l_epr_attribute4_va(l_epr_elenum) := null;
   	   l_epr_attribute5_va.extend(1);
   	   l_epr_attribute5_va(l_epr_elenum) := null;
   	   l_epr_attribute6_va.extend(1);
   	   l_epr_attribute6_va(l_epr_elenum) := null;
   	   l_epr_attribute7_va.extend(1);
   	   l_epr_attribute7_va(l_epr_elenum) := null;
   	   l_epr_attribute8_va.extend(1);
   	   l_epr_attribute8_va(l_epr_elenum) := null;
   	   l_epr_attribute9_va.extend(1);
   	   l_epr_attribute9_va(l_epr_elenum) := null;
   	   l_epr_attribute10_va.extend(1);
   	   l_epr_attribute10_va(l_epr_elenum) := null;
   	   l_epr_attribute11_va.extend(1);
   	   l_epr_attribute11_va(l_epr_elenum) := null;
   	   l_epr_attribute12_va.extend(1);
   	   l_epr_attribute12_va(l_epr_elenum) := null;
   	   l_epr_attribute13_va.extend(1);
   	   l_epr_attribute13_va(l_epr_elenum) := null;
   	   l_epr_attribute14_va.extend(1);
   	   l_epr_attribute14_va(l_epr_elenum) := null;
   	   l_epr_attribute15_va.extend(1);
   	   l_epr_attribute15_va(l_epr_elenum) := null;
   	   l_epr_attribute16_va.extend(1);
   	   l_epr_attribute16_va(l_epr_elenum) := null;
   	   l_epr_attribute17_va.extend(1);
   	   l_epr_attribute17_va(l_epr_elenum) := null;
   	   l_epr_attribute18_va.extend(1);
   	   l_epr_attribute18_va(l_epr_elenum) := null;
   	   l_epr_attribute19_va.extend(1);
   	   l_epr_attribute19_va(l_epr_elenum) := null;
   	   l_epr_attribute20_va.extend(1);
   	   l_epr_attribute20_va(l_epr_elenum) := null;
   	   l_epr_attribute21_va.extend(1);
   	   l_epr_attribute21_va(l_epr_elenum) := null;
   	   l_epr_attribute22_va.extend(1);
   	   l_epr_attribute22_va(l_epr_elenum) := null;
   	   l_epr_attribute23_va.extend(1);
   	   l_epr_attribute23_va(l_epr_elenum) := null;
   	   l_epr_attribute24_va.extend(1);
   	   l_epr_attribute24_va(l_epr_elenum) := null;
   	   l_epr_attribute25_va.extend(1);
   	   l_epr_attribute25_va(l_epr_elenum) := null;
   	   l_epr_attribute26_va.extend(1);
   	   l_epr_attribute26_va(l_epr_elenum) := null;
   	   l_epr_attribute27_va.extend(1);
   	   l_epr_attribute27_va(l_epr_elenum) := null;
   	   l_epr_attribute28_va.extend(1);
   	   l_epr_attribute28_va(l_epr_elenum) := null;
   	   l_epr_attribute29_va.extend(1);
   	   l_epr_attribute29_va(l_epr_elenum) := null;
   	   l_epr_attribute30_va.extend(1);
   	   l_epr_attribute30_va(l_epr_elenum) := null;
           --
           l_object_version_number_va.extend(1);
           l_object_version_number_va(l_epr_elenum) := 1;
           --
           l_request_id_va.extend(1);
           l_request_id_va(l_epr_elenum) := fnd_global.conc_request_id;
           l_program_application_id_va.extend(1);
           l_program_application_id_va(l_epr_elenum) := fnd_global.prog_appl_id;
           l_program_id_va.extend(1);
           l_program_id_va(l_epr_elenum) := fnd_global.conc_program_id;
           l_program_update_date_va.extend(1);
           l_program_update_date_va(l_epr_elenum) := sysdate;
           --
           l_epr_elenum := l_epr_elenum+1;

   --     end if;
          hr_utility.set_location ('get next pl or oipl and loop back',130);
          if l_currepe_set(epe_elenum).oipl_id is not null then
            hr_utility.set_location ('next c_apr_oipl for oipl_id -> '||l_currepe_set(epe_elenum).oipl_id,130);
            fetch c_apr_oipl into l_apr;
          else
            hr_utility.set_location ('next c_apr_pl for pl_id -> '||l_currepe_set(epe_elenum).pl_id,130);
            fetch c_apr_pl into l_apr;
          end if;
          hr_utility.set_location ('AFTER FETCH',140);

        end loop;

      end if;
      if l_currepe_set(epe_elenum).oipl_id is not null and l_ap_found then
        close c_apr_oipl;
      elsif l_currepe_set(epe_elenum).pl_id is not null and l_ap_found then
        close c_apr_pl;
      end if;
      l_ap_found := true;
    end loop;
  end if;
  --
  if l_elig_per_elctbl_chc_id_va.count > 0 then
    --
    if p_mode in ('U','R') then
        --
        FOR i IN l_elig_per_elctbl_chc_id_va.FIRST .. l_elig_per_elctbl_chc_id_va.LAST loop
          --
          hr_utility.set_location(l_elig_per_elctbl_chc_id_va(i)||' '||l_enrt_bnft_id_va(i)||'actual'||l_actl_prem_id_va(i),111);
          l_enrt_prem_id := null;
          l_enrt_prem_id := ben_manage_unres_life_events.epr_exists
                        (l_elig_per_elctbl_chc_id_va(i),
                         l_enrt_bnft_id_va(i),
                         l_actl_prem_id_va(i));
         --
          if l_enrt_prem_id is  not null then
           --
            ben_manage_unres_life_events.update_enrt_prem
             ( p_enrt_prem_id                  => l_enrt_prem_id
              ,p_val                           => l_val_va(i)
              ,p_uom                           => l_uom_va(i)
              ,p_elig_per_elctbl_chc_id        => l_elig_per_elctbl_chc_id_va(i)
              ,p_enrt_bnft_id                  => l_enrt_bnft_id_va(i)
              ,p_actl_prem_id                  => l_actl_prem_id_va(i)
              ,p_business_group_id             => p_business_group_id
              ,p_object_version_number         => l_object_version_number
              ,p_request_id                    => l_request_id_va(i)
              ,p_program_application_id        => l_program_application_id_va(i)
              ,p_program_id                    => l_program_id_va(i)
              ,p_program_update_date           => l_program_update_date_va(i)
              );
          else
            --
            INSERT INTO ben_enrt_prem
              (enrt_prem_id,
               val,
               uom,
               elig_per_elctbl_chc_id,
               enrt_bnft_id,
               actl_prem_id,
               business_group_id,
               epr_attribute_category,
               epr_attribute1,
               epr_attribute2,
               epr_attribute3,
               epr_attribute4,
               epr_attribute5,
               epr_attribute6,
               epr_attribute7,
               epr_attribute8,
               epr_attribute9,
               epr_attribute10,
               epr_attribute11,
               epr_attribute12,
               epr_attribute13,
               epr_attribute14,
               epr_attribute15,
               epr_attribute16,
               epr_attribute17,
               epr_attribute18,
               epr_attribute19,
               epr_attribute20,
               epr_attribute21,
               epr_attribute22,
               epr_attribute23,
               epr_attribute24,
               epr_attribute25,
               epr_attribute26,
               epr_attribute27,
               epr_attribute28,
               epr_attribute29,
               epr_attribute30,
               object_version_number,
               request_id,
               program_application_id,
               program_id,
               program_update_date
              )
          VALUES
            (ben_enrt_prem_s.nextval,
             l_val_va(i),
             l_uom_va(i),
             l_elig_per_elctbl_chc_id_va(i),
             l_enrt_bnft_id_va(i),
             l_actl_prem_id_va(i),
             l_business_group_id_va(i),
             l_epr_attribute_category_va(i),
             l_epr_attribute1_va(i),
             l_epr_attribute2_va(i),
             l_epr_attribute3_va(i),
             l_epr_attribute4_va(i),
             l_epr_attribute5_va(i),
             l_epr_attribute6_va(i),
             l_epr_attribute7_va(i),
             l_epr_attribute8_va(i),
             l_epr_attribute9_va(i),
             l_epr_attribute10_va(i),
             l_epr_attribute11_va(i),
             l_epr_attribute12_va(i),
             l_epr_attribute13_va(i),
             l_epr_attribute14_va(i),
             l_epr_attribute15_va(i),
             l_epr_attribute16_va(i),
             l_epr_attribute17_va(i),
             l_epr_attribute18_va(i),
             l_epr_attribute19_va(i),
             l_epr_attribute20_va(i),
             l_epr_attribute21_va(i),
             l_epr_attribute22_va(i),
             l_epr_attribute23_va(i),
             l_epr_attribute24_va(i),
             l_epr_attribute25_va(i),
             l_epr_attribute26_va(i),
             l_epr_attribute27_va(i),
             l_epr_attribute28_va(i),
             l_epr_attribute29_va(i),
             l_epr_attribute30_va(i),
             l_object_version_number_va(i),
             l_request_id_va(i),
             l_program_application_id_va(i),
             l_program_id_va(i),
             l_program_update_date_va(i)
            );
          end if;
         end loop;
         --
    else
      --
      FORALL i IN l_elig_per_elctbl_chc_id_va.FIRST .. l_elig_per_elctbl_chc_id_va.LAST
        INSERT INTO ben_enrt_prem
        (enrt_prem_id,
         val,
         uom,
         elig_per_elctbl_chc_id,
         enrt_bnft_id,
         actl_prem_id,
         business_group_id,
         epr_attribute_category,
         epr_attribute1,
         epr_attribute2,
         epr_attribute3,
         epr_attribute4,
         epr_attribute5,
         epr_attribute6,
         epr_attribute7,
         epr_attribute8,
         epr_attribute9,
         epr_attribute10,
         epr_attribute11,
         epr_attribute12,
         epr_attribute13,
         epr_attribute14,
         epr_attribute15,
         epr_attribute16,
         epr_attribute17,
         epr_attribute18,
         epr_attribute19,
         epr_attribute20,
         epr_attribute21,
         epr_attribute22,
         epr_attribute23,
         epr_attribute24,
         epr_attribute25,
         epr_attribute26,
         epr_attribute27,
         epr_attribute28,
         epr_attribute29,
         epr_attribute30,
         object_version_number,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
    VALUES
      (ben_enrt_prem_s.nextval,
       l_val_va(i),
       l_uom_va(i),
       l_elig_per_elctbl_chc_id_va(i),
       l_enrt_bnft_id_va(i),
       l_actl_prem_id_va(i),
       l_business_group_id_va(i),
       l_epr_attribute_category_va(i),
       l_epr_attribute1_va(i),
       l_epr_attribute2_va(i),
       l_epr_attribute3_va(i),
       l_epr_attribute4_va(i),
       l_epr_attribute5_va(i),
       l_epr_attribute6_va(i),
       l_epr_attribute7_va(i),
       l_epr_attribute8_va(i),
       l_epr_attribute9_va(i),
       l_epr_attribute10_va(i),
       l_epr_attribute11_va(i),
       l_epr_attribute12_va(i),
       l_epr_attribute13_va(i),
       l_epr_attribute14_va(i),
       l_epr_attribute15_va(i),
       l_epr_attribute16_va(i),
       l_epr_attribute17_va(i),
       l_epr_attribute18_va(i),
       l_epr_attribute19_va(i),
       l_epr_attribute20_va(i),
       l_epr_attribute21_va(i),
       l_epr_attribute22_va(i),
       l_epr_attribute23_va(i),
       l_epr_attribute24_va(i),
       l_epr_attribute25_va(i),
       l_epr_attribute26_va(i),
       l_epr_attribute27_va(i),
       l_epr_attribute28_va(i),
       l_epr_attribute29_va(i),
       l_epr_attribute30_va(i),
       l_object_version_number_va(i),
       l_request_id_va(i),
       l_program_application_id_va(i),
       l_program_id_va(i),
       l_program_update_date_va(i)
      );
      --
    end if;
    --
  end if;
  --
  -- Clear epe context row
  --
  ben_epe_cache.init_context_pileperow;
  --
  hr_utility.set_location ('Leaving '||l_package,99);
end main;
end ben_determine_actual_premium;

/
