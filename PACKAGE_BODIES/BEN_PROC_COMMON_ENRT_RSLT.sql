--------------------------------------------------------
--  DDL for Package Body BEN_PROC_COMMON_ENRT_RSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROC_COMMON_ENRT_RSLT" as
/* $Header: benprcme.pkb 120.11.12010000.5 2009/11/19 19:42:47 stee ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
    Common Enrollment Results Process
Purpose
    This process closes all the post enrollment RCOs to calculate rates,
        writes element entries, compute total flex credits, allocate excess
        flex credits, compute imputed income and closes the enrollment.
History

Version Date        Author         Comments
-------+-----------+--------------+----------------------------------------
110.0   02-JUN-1998 stee           Created
110.1   18-JUN-1998 maagrawa       Two new parameters added
                                   p_pgm_id and p_pl_id
115.3   22-SEP-1998 GPERRY         Added logic for 'Automatic' enrollment.
                                   Added close statements for cursors.
                    STEE           Update Pil elctbl chc popl with elcn_made_dt
                                   ,auto_asnd_dt and dflt_asnd_dt instead of
                                   per_in_ler_f. Add call to generate
                                   communications.
115.4   10-DEC-1998 bbulusu        added per_in_ler_id to the process_post_res
                   ults procedure.
115.5   11-DEC-1998 stee           Fix to select per_in_ler from table instead
                                   of view.
115.6   01-JAN-1999 stee           Added new parameters, pgm_id, pl_id and
                                   ler_id to ben_generate_communications.
115.7   13-JAN-1999 stee           Added new parameter to call to
                                   ben_det_imputed_income.
115.8   10-FEB-1999 yrathman       Added set_elcn_made_or_asnd_dt procedure,
                                   moved coded from process_post_enrollment
115.9   22-FEB-1999 stee           Move generate communications to run
                                   before close enrollment bug#1918.
115.10  09-APR-1999 mhoyes         Un-datetrack of per_in_ler_f changes.
115.11  21-jun-1999 jcarpent       Added uneai to close single enrollment.
115.12  02-JUL-1999 stee           Update COBRA information.
115.13  02-OCT-1999 stee           Changed update_cobra_info to a new
                                   procedure ben_cobra_requirements.
                                   update_prtt_cobra_info.
115.14  01-MAR-2000 stee           Remove update_prtt_cobra_info.  Cobra
                                   qualified beneficiary are now written
                                   during benmngle.  COBRA eligibility is
                                   evaluated during close enrollment.
115.15  11-APR-2000 gperry         Added extra param for fido ctrl m call.
115.16  31-Jul-2000 pzclark        Added a wrapper to procedure
                                   process_post_enrollment to allow self
                                   service java code to call using varchar2
                                   'TRUE' or 'FALSE' instead of booleans.
115.17  15-Aug-2000 maagrawa       Added procedure process_post_enrt_calls_w
                                   (wrapper for self-service).
115.18  05-sep-2000 pbodla          Bug 5422 : Allow different enrollment periods
                                    for programs for a scheduled  enrollment.
                                    p_popl_enrt_typ_cycl_id is removed.
115.19  06-Sep-2000 maagrawa        Backported to 115.17. Added exception
                                    handling for self-service wrapper.
115.20  06-Sep-2000 maagrawa        Leapfrog. 115.18  +115.19 changes.
115.21  14-Sep-2000 pzclark        Backported to 115.19. Added when others
                                    exception to process_post_enrollment_w
                                    procedure.
115.22  14-Sep-2000 pzclark        Leapfrog 115.21. Added when others
                                    exception to process_post_enrollment_w
                                    procedure to version 115.20
115.23  14-Sep-2000 pzclark        Backported to 115.21, added EXIT to end of
                                    Package
115.24  14-Sep-2000 pzclark        Leapfrog 115.23. Back to version 115.22
115.25  12-Mar-2001 ikasire        bug 1644520 fixed the problem in election
                                   made date
115.26  13-Mar-2001 ikasire        bug 1644520 fixed the problem in election
                                   made date. taking max of pen.effective_start_date
                                   for the pil,pgm and plan - added a cursor
115.28  13-Mar-2001 ikasire        to correct the version numbers read 25 as 26
                                   26 as 27
115.29  17-May-2001 maagrawa       Added parameter self_service_flag to
                                   process_post_results for performance.
115.30  18-dec-2001 tjesumic       cwb changes
115.31  19-dec-2001 tjesumic       cwb changes
115.32  20-dec-2001 ikasire        added dbdrv lines
115.33  02-jan-2002 tjesumic       2170324 paramter for proc_cd2 to proc_cd5 added
115.34  06-nov-2002 shdas          bug fix 2656718 -- added fnd_msg_pub.initialize
                                   enrollment selection page was showing some cached
                                   message from fnd table
115.35  13-aug-2003 kmahendr       Added codes for coverage calculation for ERL
115.36  22-aug-2003 kmahendr       Multi_row edit proc called after election_info.
115.37  02-sep-2003 kmahendr       Bug#3120675 - warnings handled
115.38  02-sep-2003 kmahendr       Message nos changed
115.39  23-jul-2004 kmahendr       Bug#3772143 - added parameter - p_include_erl to multi_rows_edit
115.40  28-jul-2004 kmahendr       Bug#3772143 - Multi_rows_edit called outside the loop
115.41  11-oct-2004 kmahendr       Bug#3944970 - added parameter to process_post_results
                                   and imputed_income call is not made for ICD enrollments
115.42  03-Dec-2004 ikasire        Bug 3988565 Changed effective_date data type to Date
115.43  15-Mar-2005 ikasire        overloaded process_post_enrt_calls_w with a new
                                   parameter p_self_service_flag to avoid conversion issues
115.44  17-may-05   ssarkar       Bug: 4362939 : modified process_post_results -- 'l_call_multi_rows' set outside the coverage amount chk.
115.45  26-May-05   vborkar        Bug 4387247 : In wrapper method exception
                                   handlers changes made to avoid null errors
                                   on SS pages
115.46  01-Jun-05   vborkar        Bug 4387247 : Modifications to take care of
                                   application exceptions.
115.47  06-Jun-05   ikasire        Bug 4414127
115.48  17-Jun-05   vborkar        Bug 4436578 : In SS wrapper app exception handler
                                   added generic(default) exception handler code.
115.49  02-Nov-05   ikasire        BUG 4709601 we don't need to multi_rows_edit for
                                   CFW process
115.50  11-Nov-05   ikasire        BUG 4718599 fixed ERL cursor to return the correct
                                   number of records.
115.51  26-Oct-06   bmanyam        5621577 When CVG is ERL and Rates are
                                   Enter Value At Enrollment, fetch rates again
                                   during re-enrollment in process_post_results
115.53  09-Nov-06   rtagarra       Added condition while calling close_single_enrollment so that fix 5529696 wont be
				   overriden by 5527233.
115.54  16-Nov-06   vvprabhu       Bug 5664300 - parameter p_called_from_ss added
115.55                             to process_post_results

155.56  31-Aug-07   rtagarra       Bug 5997904 : Life Event will be closed when user makes election when
					     the code is 'ELCNSMADE'
115.57  19-Oct-08   sagnanas       7447088 - Added enrt_mthd_cd 'D' in cursor c_enrt_rslt
115.58  28-Oct-08   sagnanas       7510533 - Commented pen.per_in_ler_id in cursor c_enrt_rslt
115.59  29-Sep-09   stee           8930024 - Fix c_enrt_rslt to exclude enrt_mthd_cd = 'D'
                                             if called from automatic enrollment.
115.60  27-Oct-09   stee           9026755 - Change fix for bug 7510533.  Check the
                                             electable flag instead.
*/
------------------------------------------------------------------------------
  g_debug boolean := hr_utility.debug_enabled;
  g_package varchar2(80):='ben_proc_common_enrt_rslt.';
--
-- ---------------------------------------------------------------------------
-- This procedure was later added to update elctn made dt or assigned dt on pil_popl  (yrathman)
-- ---------------------------------------------------------------------------
--
procedure set_elcn_made_or_asnd_dt
    (p_per_in_ler_id     in number   default null
    ,p_pgm_id            in number
    ,p_pl_id             in number
    ,p_enrt_mthd_cd      in varchar2
    ,p_business_group_id in number
    ,p_effective_date    in date
    ,p_validate          in boolean  default false) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    ben_pil_elctbl_chc_popl.object_version_number%TYPE;
  l_pil_elctbl_chc_popl_id   ben_pil_elctbl_chc_popl.pil_elctbl_chc_popl_id%TYPE;
  l_proc                     varchar2(72) := g_package||'set_elcn_made_or_asnd_dt';
  --
  cursor c_pgm_popl is
    select pel.pil_elctbl_chc_popl_id
          ,pel.object_version_number
          ,pel.elcns_made_dt
    from   ben_pil_elctbl_chc_popl pel
    where  pel.per_in_ler_id = p_per_in_ler_id
    and    pel.pgm_id = p_pgm_id;
  --
  cursor c_pl_popl is
    select pel.pil_elctbl_chc_popl_id
          ,pel.object_version_number
          ,pel.elcns_made_dt
    from   ben_pil_elctbl_chc_popl pel
    where  pel.per_in_ler_id = p_per_in_ler_id
    and    pel.pl_id  = p_pl_id;
  --
  --  Added the cursor to fix bug 1644520
  --Bug 4414127
  cursor c_pgm_elcns_made_dt is
    select max(pen.EFFECTIVE_START_DATE) elcns_made_dt
    from ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = p_per_in_ler_id
    and   pen.pgm_id = p_pgm_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.enrt_cvg_thru_dt = hr_api.g_eot ;
  --Bug 4414127
  cursor c_pl_elcns_made_dt is
    select max(pen.EFFECTIVE_START_DATE) elcns_made_dt
    from ben_prtt_enrt_rslt_f pen
    where pen.per_in_ler_id = p_per_in_ler_id
    and   pen.pl_id = p_pl_id
    and pen.prtt_enrt_rslt_stat_cd is null
    and pen.enrt_cvg_thru_dt = hr_api.g_eot ;
  --
  l_old_elcns_made_dt       date default null;
  l_new_elcns_made_dt       date default null;
  --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    --  Get the pil_elctbl_chc_popl object_version_number
    --
    if p_pgm_id is not null then
      open c_pgm_popl;
      fetch c_pgm_popl into l_pil_elctbl_chc_popl_id
                           ,l_object_version_number
                           ,l_old_elcns_made_dt ;
      --
      if c_pgm_popl%notfound then
        --
        close c_pgm_popl;
        fnd_message.set_name('BEN','BEN_91916_ENRT_TABLE_NOT_FOUND');
        fnd_message.set_token('TABLE','PIL_ELCTBL_CHC_POPL');
        fnd_message.raise_error;
        --
      end if;
      --
      close c_pgm_popl;
    else
      open c_pl_popl;
      fetch c_pl_popl into l_pil_elctbl_chc_popl_id
                          ,l_object_version_number
                          ,l_old_elcns_made_dt ;
      --
      if c_pl_popl%notfound then
        --
        close c_pl_popl;
        fnd_message.set_name('BEN','BEN_91916_ENRT_TABLE_NOT_FOUND');
        fnd_message.set_token('TABLE','PIL_ELCTBL_CHC_POPL');
        fnd_message.raise_error;
        --
      end if;
      --
      close c_pl_popl;
    end if;
    --
    --  If enrollment method code is explicit, update the election made date.
    --
    hr_utility.set_location('enrt mthd cd'||p_enrt_mthd_cd||l_proc, 5);
    if p_enrt_mthd_cd = 'E' then
      --
      hr_utility.set_location(l_proc, 10);
      --
      --  Update election made date on pil_elctbl_chc_popl.
      -- Bug 1644520 added the if condition to take the only first election
      -- made date
      --
      if p_pgm_id is not null then
        open c_pgm_elcns_made_dt ;
        fetch c_pgm_elcns_made_dt into l_new_elcns_made_dt ;
        close c_pgm_elcns_made_dt ;
      else
        open c_pl_elcns_made_dt ;
        fetch c_pl_elcns_made_dt into l_new_elcns_made_dt ;
        close c_pl_elcns_made_dt ;
      end if;
      --
      -- Update only if the old value is null or if the value needs to be
      -- changed.
      --
      if l_old_elcns_made_dt is null or
         l_old_elcns_made_dt <> l_new_elcns_made_dt then
      --
        ben_Pil_Elctbl_chc_Popl_api.update_Pil_Elctbl_chc_Popl
          (p_validate               => p_validate
           ,p_pil_elctbl_chc_popl_id => l_pil_elctbl_chc_popl_id
           ,p_elcns_made_dt          => nvl(l_new_elcns_made_dt ,p_effective_date)
           ,p_object_version_number  => l_object_version_number
           ,p_effective_date         => p_effective_date
           ,p_business_group_id      => p_business_group_id
           );
      --
      end if;
      --
      -- If enrollment method code is default, update the default
      -- enrollment date
      --
    elsif p_enrt_mthd_cd = 'D' then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --
      --  Update default assigned date on pil_elctbl_chc_popl.
      --
      ben_Pil_Elctbl_chc_Popl_api.update_Pil_Elctbl_chc_Popl
        (p_validate               => p_validate
        ,p_pil_elctbl_chc_popl_id => l_pil_elctbl_chc_popl_id
        ,p_dflt_asnd_dt           => p_effective_date
        ,p_object_version_number  => l_object_version_number
        ,p_effective_date         => p_effective_date
        ,p_business_group_id      => p_business_group_id
        );
          --
      --
    elsif p_enrt_mthd_cd = 'A' then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --  Update automatic enrollment assigned date on pil_elctbl_chc_popl.
      --
      ben_Pil_Elctbl_chc_Popl_api.update_Pil_Elctbl_chc_Popl
        (p_validate               => p_validate
        ,p_pil_elctbl_chc_popl_id => l_pil_elctbl_chc_popl_id
        ,p_auto_asnd_dt           => p_effective_date
        ,p_object_version_number  => l_object_version_number
        ,p_effective_date         => p_effective_date
        ,p_business_group_id      => p_business_group_id
        );
      --
    end if;
    --
    hr_utility.set_location(l_proc, 25);
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    --
  end set_elcn_made_or_asnd_dt;
  --
  -- ------------------------------------------------------------------------------
  procedure process_post_results
    (p_flx_cr_flag       in varchar2 default 'N'
    ,p_person_id         in number
    ,p_enrt_mthd_cd      in varchar2
    ,p_effective_date    in date
    ,p_business_group_id in number
    ,p_validate          in boolean  default false
    ,p_per_in_ler_id     in number
    ,p_self_service_flag in boolean  default false
    ,p_pgm_id            in number
    ,p_pl_id             in number
    ,p_called_frm_ss     in boolean  default false
    )
  is
    --
    l_proc    varchar2(72) := g_package||'process_post_results';
    --
    l_dummy_set ben_det_enrt_rates.PRVRtVal_tab;
    --
    cursor c_per_in_ler
    is
    select per_in_ler_id
      from ben_per_in_ler
      where person_id = p_person_id
      and per_in_ler_stat_cd = 'STRTD'
      and business_group_id  = p_business_group_id;
  --
  l_per_in_ler_id number;
  --
  cursor c_lf_evt_ocrd_dt is
    select lf_evt_ocrd_dt
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = l_per_in_ler_id;
  --
  l_lf_evt_ocrd_dt  date;
  /* cursor to pick results with coverage calculation method ERL */
  --
  --BUG 4718599 Modifed the cursor to join epe to enb and check for per in ler
  --otherwise if there were multiple updates to the enrollment results in the
  --previous life event, you will end up getting multiple records returned by the
  --cursor and get into APP-BEN-91711 issue.
  --
   cursor c_enrt_rslt
    (c_person_id      in     number
    ,c_enrt_mthd_cd   in     varchar2
    ,c_per_in_ler_id  in     number
    ,c_effective_date in     date
    )
  is
    select pen.*,
           enb.elig_per_elctbl_chc_id,
           enb.enrt_bnft_id
    from ben_prtt_enrt_rslt_f pen,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe
    where pen.person_id          = c_person_id
    and ( pen.enrt_mthd_cd         = c_enrt_mthd_cd
          or pen.enrt_mthd_cd         = 'O'
	   or (pen.enrt_mthd_cd         = 'D' --7447088
               and c_enrt_mthd_cd <> 'A')) -- 8930024
    and pen.prtt_enrt_rslt_stat_cd is null
    /* 9026755 */
    and ((pen.per_in_ler_id        = c_per_in_ler_id
         and epe.elctbl_flag = 'Y')
         or (pen.per_in_ler_id <> c_per_in_ler_id
             and epe.elctbl_flag = 'N'))
   /* end 9026755 */
    and enrt_cvg_thru_dt = hr_api.g_eot
    and pen.comp_lvl_cd <> 'PLANIMP'
    and pen.prtt_enrt_rslt_id = enb.prtt_enrt_rslt_id
    and enb.cvg_mlt_cd = 'ERL'
    and c_effective_date
      between pen.effective_start_date and pen.effective_end_date
    and pen.effective_end_date = hr_api.g_eot
    and enb.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
    and epe.per_in_ler_id = c_per_in_ler_id
    ;
    --
    -- 5621577 Fetch the Rates for the current Enrollment
    --         which are enter value at enrollment
    --
    CURSOR c_prv_rt(c_prtt_enrt_rslt_id number,
                    c_per_in_ler_id number) is
    select ecr.enrt_rt_id,
           prv.rt_val,
           prv.ann_rt_val,
           prv.prtt_rt_val_id
      from ben_prtt_rt_val prv,
           ben_elig_per_elctbl_chc epe,
           ben_enrt_bnft enb,
           ben_enrt_rt ecr
     where prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and prv.prtt_rt_val_stat_cd is null
       and ecr.entr_val_at_enrt_flag = 'Y'
       and ecr.prtt_rt_val_id = prv.prtt_rt_val_id
       and epe.per_in_ler_id = c_per_in_ler_id
       and epe.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
       and epe.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ecr.enrt_bnft_id(+) = enb.enrt_bnft_id
       and NVL(ecr.elig_per_elctbl_chc_id, epe.elig_per_elctbl_chc_id) = epe.elig_per_elctbl_chc_id
       ;
       --
    type g_rt_rec is record
    (enrt_rt_id      ben_enrt_rt.enrt_rt_id%type,
     rt_val          ben_enrt_rt.dflt_val%type,
     ann_val         ben_enrt_rt.ann_val%type,
     prtt_rt_val_id  ben_enrt_rt.prtt_rt_val_id%type
     );
    --
    type g_rt_table is table of g_rt_rec index by binary_integer;
    l_rt_table g_rt_table;
    l_count number;
    --
  CURSOR c_interim (c_interim_pen     IN NUMBER
                    ,c_person_id      in     number
                   ,c_per_in_ler_id   in     number
                   ,c_effective_date  in     date)
   IS
      SELECT 'Y' interim_flag,
             prtt_enrt_rslt_id suspended_pen_id,
             object_version_number suspended_ovn
        FROM ben_prtt_enrt_rslt_f pen
       WHERE pen.rplcs_sspndd_rslt_id = c_interim_pen
         AND pen.person_id          = c_person_id
         AND pen.prtt_enrt_rslt_stat_cd IS NULL
         AND pen.per_in_ler_id = c_per_in_ler_id
         AND pen.enrt_cvg_thru_dt = hr_api.g_eot
         AND c_effective_date BETWEEN pen.effective_start_date
                                  AND pen.effective_end_date
         AND pen.effective_end_date = hr_api.g_eot;
   --
   l_interim varchar2(30) ;
   l_suspended_pen_id number;
   l_suspended_ovn number;
   --
    cursor c_pl (p_pl_id number) is
      select name,
             SUBJ_TO_IMPTD_INCM_TYP_CD
      from ben_pl_f pln
      where pln.pl_id = p_pl_id
      and p_effective_date between pln.effective_start_date
          and pln.effective_end_date;
    --
    l_pln_name      varchar2(300);
    l_enb_valrow                 ben_determine_coverage.ENBValType;
    l_enrt_rslt    c_enrt_rslt%rowtype;
    l_dummy_char   varchar2(1);
    l_dummy_number number;
    l_dummy_date   date;
    l_dummy_bool   boolean;
    l_ctfn_actn_warning boolean;
    l_DPNT_ACTN_WARNING boolean;
    l_BNF_ACTN_WARNING  boolean;
    l_call_multi_rows   boolean;
    l_SUBJ_TO_IMPTD_INCM_TYP_CD varchar2(300);
    l_call_imputed      boolean;
    l_datetrack_mode         varchar2(30);
    --
  begin
    --
    g_debug := hr_utility.debug_enabled;
    --
    if (g_debug) then
        hr_utility.set_location('Entering:'||l_proc, 5);
    end if;
    --
    -- Check to see if the per in ler id is being passed in. If not then
    -- fetch it.
    --
    if p_per_in_ler_id is null
    then
      open c_per_in_ler;
      fetch c_per_in_ler into l_per_in_ler_id;
      --
      if c_per_in_ler%notfound
      then
        close c_per_in_ler;
        fnd_message.set_name('BEN', 'BEN_91272_PER_IN_LER_MISSING');
        fnd_message.raise_error;
      end if;
      --
      close c_per_in_ler;
      --
    else
      l_per_in_ler_id := p_per_in_ler_id;

    end if;
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- process post enrollment rule for coverages
    --
    --
    open c_enrt_rslt
        (c_person_id       => p_person_id
         ,c_enrt_mthd_cd   => p_enrt_mthd_cd
         ,c_per_in_ler_id  => p_per_in_ler_id
         ,c_effective_date => p_effective_date
         )
          ;
    loop
      fetch c_enrt_rslt into l_enrt_rslt;
      if c_enrt_rslt%notfound then
         exit;
      end if;
      --
      open c_lf_evt_ocrd_dt;
      fetch c_lf_evt_ocrd_dt into l_lf_evt_ocrd_dt;
      close c_lf_evt_ocrd_dt;
      --
      ben_determine_coverage.main
            (p_elig_per_elctbl_chc_id => l_enrt_rslt.elig_per_elctbl_chc_id
            ,p_effective_date         => p_effective_date
            ,p_lf_evt_ocrd_dt         => l_lf_evt_ocrd_dt
            ,p_perform_rounding_flg   => true
            --
            ,p_enb_valrow             => l_enb_valrow
            ,p_calculate_only_mode    => TRUE
            );
      --
      -- call election information
      if nvl(l_enb_valrow.val,0) <> nvl(l_enrt_rslt.bnft_amt,0) then
        --
        l_interim := NULL;
        l_suspended_pen_id := NULL;
        --
        open c_interim
           (c_interim_pen     => l_enrt_rslt.prtt_enrt_rslt_id
           ,c_person_id       => p_person_id
           ,c_per_in_ler_id   => p_per_in_ler_id
           ,c_effective_date  => p_effective_date
           );
        --
        fetch c_interim into l_interim,
                             l_suspended_pen_id,
                             l_suspended_ovn;
        close c_interim;
        --
        hr_utility.set_location('l_interim '|| l_interim, 10);
        --
        IF l_interim = 'Y' THEN
          --
          ben_sspndd_enrollment.g_interim_flag := 'Y';
          ben_sspndd_enrollment.g_use_new_result:=true;
          hr_utility.set_location('Before ERL Interim call',20);
          --
        END IF;
        --
        --
        if (g_debug) then
             hr_utility.set_location('Fetch entr_val_at_enrt rates for ERL enrollments ', 15);
        end if;
        -- 5621577 Fetch and populate existing rate values.
        for l_count in 1..10 loop
            -- Initialise array to null
            l_rt_table(l_count).enrt_rt_id := null;
            l_rt_table(l_count).rt_val := null;
            l_rt_table(l_count).ann_val := null;
            l_rt_table(l_count).prtt_rt_val_id := null;
            --
        end loop;
        --
        l_count:= 0;
        --
        for l_rec in c_prv_rt(l_enrt_rslt.prtt_enrt_rslt_id, l_per_in_ler_id) loop
            --
            l_count := l_count+1;
            l_rt_table(l_count).enrt_rt_id := l_rec.enrt_rt_id;
            l_rt_table(l_count).rt_val := l_rec.rt_val;
            l_rt_table(l_count).ann_val := l_rec.ann_rt_val;
            l_rt_table(l_count).prtt_rt_val_id := l_rec.prtt_rt_val_id;
            --
            if (g_debug) then
                hr_utility.set_location('Rate l_count '|| l_count, 15);
                hr_utility.set_location('l_rec.enrt_rt_id '|| l_rec.enrt_rt_id, 15);
                hr_utility.set_location('l_rec.rt_val '|| l_rec.rt_val, 15);
                hr_utility.set_location('l_rec.ann_val '|| l_rec.ann_rt_val, 15);
                hr_utility.set_location('l_rec.prtt_rt_val_id '|| l_rec.prtt_rt_val_id, 15);
            end if;
            --
        end loop;
                --
        ben_election_information.election_information
               (p_elig_per_elctbl_chc_id => l_enrt_rslt.elig_per_elctbl_chc_id,
                p_prtt_enrt_rslt_id      => l_enrt_rslt.prtt_enrt_rslt_id,
                p_effective_date         => p_effective_date,
                p_enrt_mthd_cd           => l_enrt_rslt.enrt_mthd_cd,
                p_enrt_bnft_id           => l_enrt_rslt.enrt_bnft_id,
                p_bnft_val               => l_enb_valrow.val,
/* 5621577 - Added the below parameters */
                p_enrt_rt_id1            => l_rt_table(1).enrt_rt_id,
                p_rt_val1                => l_rt_table(1).rt_val,
                p_ann_rt_val1            => l_rt_table(1).ann_val,
                p_prtt_rt_val_id1        => l_rt_table(1).prtt_rt_val_id,

                p_enrt_rt_id2            => l_rt_table(2).enrt_rt_id,
                p_rt_val2                => l_rt_table(2).rt_val,
                p_ann_rt_val2            => l_rt_table(2).ann_val,
                p_prtt_rt_val_id2        => l_rt_table(2).prtt_rt_val_id,

                p_enrt_rt_id3            => l_rt_table(3).enrt_rt_id,
                p_rt_val3                => l_rt_table(3).rt_val,
                p_ann_rt_val3            => l_rt_table(3).ann_val,
                p_prtt_rt_val_id3        => l_rt_table(3).prtt_rt_val_id,

                p_enrt_rt_id4            => l_rt_table(4).enrt_rt_id,
                p_rt_val4                => l_rt_table(4).rt_val,
                p_ann_rt_val4            => l_rt_table(4).ann_val,
                p_prtt_rt_val_id4        => l_rt_table(4).prtt_rt_val_id,

                p_enrt_rt_id5            => l_rt_table(5).enrt_rt_id,
                p_rt_val5                => l_rt_table(5).rt_val,
                p_ann_rt_val5            => l_rt_table(5).ann_val,
                p_prtt_rt_val_id5        => l_rt_table(5).prtt_rt_val_id,

                p_enrt_rt_id6            => l_rt_table(6).enrt_rt_id,
                p_rt_val6                => l_rt_table(6).rt_val,
                p_ann_rt_val6            => l_rt_table(6).ann_val,
                p_prtt_rt_val_id6        => l_rt_table(6).prtt_rt_val_id,

                p_enrt_rt_id7            => l_rt_table(7).enrt_rt_id,
                p_rt_val7                => l_rt_table(7).rt_val,
                p_ann_rt_val7            => l_rt_table(7).ann_val,
                p_prtt_rt_val_id7        => l_rt_table(7).prtt_rt_val_id,

                p_enrt_rt_id8            => l_rt_table(8).enrt_rt_id,
                p_rt_val8                => l_rt_table(8).rt_val,
                p_ann_rt_val8            => l_rt_table(8).ann_val,
                p_prtt_rt_val_id8        => l_rt_table(8).prtt_rt_val_id,

                p_enrt_rt_id9            => l_rt_table(9).enrt_rt_id,
                p_rt_val9                => l_rt_table(9).rt_val,
                p_ann_rt_val9            => l_rt_table(9).ann_val,
                p_prtt_rt_val_id9        => l_rt_table(9).prtt_rt_val_id,

                p_enrt_rt_id10            => l_rt_table(10).enrt_rt_id,
                p_rt_val10                => l_rt_table(10).rt_val,
                p_ann_rt_val10            => l_rt_table(10).ann_val,
                p_prtt_rt_val_id10        => l_rt_table(10).prtt_rt_val_id,

/*  5621577 Commented the below parameters
                p_prtt_rt_val_id2        => l_dummy_number,
                p_prtt_rt_val_id3        => l_dummy_number,
                p_prtt_rt_val_id4        => l_dummy_number,
                p_prtt_rt_val_id5        => l_dummy_number,
                p_prtt_rt_val_id6        => l_dummy_number,
                p_prtt_rt_val_id7        => l_dummy_number,
                p_prtt_rt_val_id8        => l_dummy_number,
                p_prtt_rt_val_id9        => l_dummy_number,
                p_prtt_rt_val_id10       => l_dummy_number,
*/
                p_pen_attribute_category =>  l_enrt_rslt.pen_attribute_category,
                p_pen_attribute1         =>  l_enrt_rslt.pen_attribute1,
                p_pen_attribute2         =>  l_enrt_rslt.pen_attribute2,
                p_pen_attribute3         =>  l_enrt_rslt.pen_attribute3,
                p_pen_attribute4         =>  l_enrt_rslt.pen_attribute4,
                p_pen_attribute5         =>  l_enrt_rslt.pen_attribute5,
                p_pen_attribute6         =>  l_enrt_rslt.pen_attribute6,
                p_pen_attribute7         =>  l_enrt_rslt.pen_attribute7,
                p_pen_attribute8         =>  l_enrt_rslt.pen_attribute8,
                p_pen_attribute9         =>  l_enrt_rslt.pen_attribute9,
                p_pen_attribute10        =>  l_enrt_rslt.pen_attribute10,
                p_pen_attribute11        =>  l_enrt_rslt.pen_attribute11,
                p_pen_attribute12        =>  l_enrt_rslt.pen_attribute12,
                p_pen_attribute13        =>  l_enrt_rslt.pen_attribute13,
                p_pen_attribute14        =>  l_enrt_rslt.pen_attribute14,
                p_pen_attribute15        =>  l_enrt_rslt.pen_attribute15,
                p_pen_attribute16        =>  l_enrt_rslt.pen_attribute16,
                p_pen_attribute17        =>  l_enrt_rslt.pen_attribute17,
                p_pen_attribute18        =>  l_enrt_rslt.pen_attribute18,
                p_pen_attribute19        =>  l_enrt_rslt.pen_attribute19,
                p_pen_attribute20        =>  l_enrt_rslt.pen_attribute20,
                p_pen_attribute21        =>  l_enrt_rslt.pen_attribute21,
                p_pen_attribute22        =>  l_enrt_rslt.pen_attribute22,
                p_pen_attribute23        =>  l_enrt_rslt.pen_attribute23,
                p_pen_attribute24        =>  l_enrt_rslt.pen_attribute24,
                p_pen_attribute25        =>  l_enrt_rslt.pen_attribute25,
                p_pen_attribute26        =>  l_enrt_rslt.pen_attribute26,
                p_pen_attribute27        =>  l_enrt_rslt.pen_attribute27,
                p_pen_attribute28        =>  l_enrt_rslt.pen_attribute28,
                p_pen_attribute29        =>  l_enrt_rslt.pen_attribute29,
                p_pen_attribute30        =>  l_enrt_rslt.pen_attribute30,
                p_datetrack_mode         => hr_api.g_update,
                p_suspend_flag           => l_dummy_char,
                p_effective_start_date   => l_dummy_date,
                p_effective_end_date     => l_dummy_date,
                p_object_version_number  => l_enrt_rslt.object_version_number,
                p_prtt_enrt_interim_id   => l_dummy_number,
                p_business_group_id      => p_business_group_id,
                p_dpnt_actn_warning      => l_DPNT_ACTN_WARNING,
                p_bnf_actn_warning       => l_BNF_ACTN_WARNING,
                p_ctfn_actn_warning      => l_ctfn_actn_warning);
         --
        -- l_call_multi_rows  := true; --commented bug 4362939
         if l_ctfn_actn_warning then
            --
            open c_pl (l_enrt_rslt.pl_id);
            fetch c_pl into l_pln_name, l_SUBJ_TO_IMPTD_INCM_TYP_CD;
            close c_pl;
            --
            ben_warnings.load_warning
             (p_application_short_name  => 'BEN',
              p_message_name            => 'BEN_93582_RQD_CTFN_MISSING',
              p_parma     => l_pln_name);
            --
            l_ctfn_actn_warning := false;
         end if;
         --
         if l_DPNT_ACTN_WARNING then
            --
            open c_pl (l_enrt_rslt.pl_id);
            fetch c_pl into l_pln_name, l_SUBJ_TO_IMPTD_INCM_TYP_CD;
            close c_pl;
            --
            ben_warnings.load_warning
             (p_application_short_name  => 'BEN',
              p_message_name            => 'BEN_93583_DPNT_ERR',
              p_parma     => l_pln_name);
            --
            l_DPNT_ACTN_WARNING := false;
         end if;
         --
         if l_BNF_ACTN_WARNING then
            --
            open c_pl (l_enrt_rslt.pl_id);
            fetch c_pl into l_pln_name,l_SUBJ_TO_IMPTD_INCM_TYP_CD;
            close c_pl;
            --
            ben_warnings.load_warning
             (p_application_short_name  => 'BEN',
              p_message_name            => 'BEN_93584_BNF_ERR',
              p_parma     => l_pln_name);
            --
            l_BNF_ACTN_WARNING := false;
         end if;
         --
         --ERL for Interim Handling
         IF l_interim = 'Y' THEN
           --
           ben_sspndd_enrollment.g_interim_flag := 'N';
           ben_sspndd_enrollment.g_use_new_result:=false;
           --
           -- Now update the suspended enrollment with newly cteated interim id.
           --
           hr_utility.set_location('After ERL Interim call ELINF',20);
           --
           ben_prtt_enrt_result_api.get_ben_pen_upd_dt_mode
                     (p_effective_date         => p_effective_date
                     ,p_base_key_value         => l_suspended_pen_id
                     ,P_desired_datetrack_mode => hr_api.g_correction
                     ,P_datetrack_allow        => l_datetrack_mode
                     );
           --
           hr_utility.set_location('After ERL Interim call BEPENDT',20);
           hr_utility.set_location('l_datetrack_mode '||l_datetrack_mode,10);
           --
           ben_prtt_enrt_result_api.update_prtt_enrt_result
              (p_validate                 => FALSE,
               p_prtt_enrt_rslt_id        => l_suspended_pen_id,
               p_effective_start_date     => l_dummy_date,
               p_effective_end_date       => l_dummy_date,
               p_business_group_id        => p_business_group_id,
               p_RPLCS_SSPNDD_RSLT_ID     => l_enrt_rslt.prtt_enrt_rslt_id,
               p_object_version_number    => l_suspended_ovn,
               p_effective_date           => p_effective_date,
               p_datetrack_mode           => l_datetrack_mode,
               p_multi_row_validate       => FALSE,
               p_program_application_id   => fnd_global.prog_appl_id,
               p_program_id               => fnd_global.conc_program_id,
               p_request_id               => fnd_global.conc_request_id,
               p_program_update_date      => sysdate);
               --
            hr_utility.set_location('After ERL Interim BEPENUPD call',30);
         END IF;
         --
      end if; --call election information
      --
      l_call_multi_rows  := true; -- bug 4362939

    end loop;
    close c_enrt_rslt;
    --BUG 4709601 we don't need to call this in carry forward action items process
    if l_call_multi_rows and nvl(ben_sspndd_enrollment.g_cfw_flag,'Y') = 'N' then

         ben_prtt_enrt_result_api.multi_rows_edit(
                     p_person_id   => p_person_id
                    ,p_effective_date =>p_effective_date
                    ,p_business_group_id =>p_business_group_id
                    ,p_pgm_id => l_enrt_rslt.pgm_id
                    ,p_per_in_ler_id   =>p_per_in_ler_id
                    ,p_include_erl     => 'Y'
		    ,p_called_frm_ss   => p_called_frm_ss
                    );
    end if;

    --
    -- Determine enrollment rates and writes element entries.
    --
    ben_det_enrt_rates.p_det_enrt_rates
      (p_person_id         => p_person_id
      ,p_per_in_ler_id     => l_per_in_ler_id
      ,p_enrt_mthd_cd      => p_enrt_mthd_cd
      ,p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_validate          => p_validate
      ,p_self_service_flag => p_self_service_flag
      --
      ,p_prv_rtval_set     => l_dummy_set
      );
     --
     --  Determine imputed income
     --
     hr_utility.set_location(l_proc, 15);
     --
     l_call_imputed := true;
     --
     if p_pl_id is not null and p_pgm_id is null then
       --
        hr_utility.set_location('PL id '||p_pl_id,16);
       open c_pl(p_pl_id);
       fetch c_pl into l_pln_name, l_SUBJ_TO_IMPTD_INCM_TYP_CD;
       if c_pl%found and l_SUBJ_TO_IMPTD_INCM_TYP_CD is null then
          l_call_imputed := false;
       end if;
       close c_pl;
       --
     end if;
     --
     if l_call_imputed then
       --
       ben_det_imputed_income.p_comp_imputed_income
         (p_person_id        => p_person_id
         ,p_enrt_mthd_cd         => p_enrt_mthd_cd
         ,p_per_in_ler_id        => l_per_in_ler_id
         ,p_effective_date       => p_effective_date
         ,p_business_group_id    => p_business_group_id
         ,p_ctrlm_fido_call      => false
         ,p_validate             => p_validate);
       --
     end if;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 20);
     --
  end process_post_results;
  --
  -- ------------------------------------------------------------------------------
  --    process_post_enrollment
  -- -----------------------------------------------------------------------------
  procedure process_post_enrollment
    (p_per_in_ler_id     in number   default null
    ,p_pgm_id            in number
    ,p_pl_id             in number
    ,p_enrt_mthd_cd      in varchar2
    ,p_cls_enrt_flag     in boolean  default true
    ,p_proc_cd           in varchar2 default null
    ,p_proc_cd2          in varchar2 default  null
    ,p_proc_cd3          in varchar2 default  null
    ,p_proc_cd4          in varchar2 default  null
    ,p_proc_cd5          in varchar2 default  null
    ,p_person_id         in number
    ,p_business_group_id in number
    ,p_effective_date    in date
    ,p_validate          in boolean  default false) is
  --
  -- Declare cursors and local variables
  --
  l_asnd_lf_evt_dt           ben_enrt_perd.asnd_lf_evt_dt%TYPE;
--  l_ler_id                   ben_per_in_ler.ler_id%TYPE;
  l_exists                   varchar2(1);
  l_proc                     varchar2(72) := g_package||'process_post_enrollment';
  --
  -- PB : 5422 :
  -- Get the asnd_lf_evt_dt
  --
  cursor c_pil_elctbl_chc_popl is
    select enp.asnd_lf_evt_dt
    from   ben_pil_elctbl_chc_popl pel,
           ben_enrt_perd enp
    where  pel.per_in_ler_id = p_per_in_ler_id
    and    nvl(pel.pgm_id,-1) = nvl(p_pgm_id,-1)
    and    nvl(pel.pl_id,-1)  = nvl(p_pl_id,-1)
    and    pel.enrt_perd_id = enp.enrt_perd_id;
  --
  l_global_pil_rec ben_global_enrt.g_global_pil_rec_type;
  --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    set_elcn_made_or_asnd_dt
        (p_per_in_ler_id     => p_per_in_ler_id
        ,p_pgm_id            => p_pgm_id
        ,p_pl_id             => p_pl_id
        ,p_enrt_mthd_cd      => p_enrt_mthd_cd
        ,p_business_group_id => p_business_group_id
        ,p_effective_date    => p_effective_date
        ,p_validate          => p_validate
       );
    --
    hr_utility.set_location(p_proc_cd, 25);
    hr_utility.set_location(p_proc_cd2, 25);
    --
    --  Write communication.
    --
    hr_utility.set_location(l_proc, 26);
    --
    if p_proc_cd is not null then
      --
      open c_pil_elctbl_chc_popl;
      fetch c_pil_elctbl_chc_popl into l_asnd_lf_evt_dt;
      close c_pil_elctbl_chc_popl;
      --
      ben_global_enrt.get_pil
       (p_per_in_ler_id          => p_per_in_ler_id
       ,p_global_pil_rec         => l_global_pil_rec);
      --
      ben_generate_communications.main
      (p_person_id             => p_person_id
      ,p_ler_id                => l_global_pil_rec.ler_id
      -- CWB Changes.
      ,p_per_in_ler_id         => p_per_in_ler_id
      ,p_pgm_id                => p_pgm_id
      ,p_pl_id                 => p_pl_id
      -- PB : 5422 :
      ,p_asnd_lf_evt_dt        => l_asnd_lf_evt_dt
      -- ,p_enrt_perd_id       => l_enrt_perd_id
      ,p_enrt_mthd_cd          => p_enrt_mthd_cd
      ,p_business_group_id     => p_business_group_id
      ,p_proc_cd1              => p_proc_cd
      ,p_proc_cd2              => p_proc_cd2
      ,p_proc_cd3              => p_proc_cd3
      ,p_proc_cd4              => p_proc_cd4
      ,p_proc_cd5              => p_proc_cd5
      ,p_effective_date        => p_effective_date);
    end if;
    --
    hr_utility.set_location(l_proc, 27);
    --
    --  Close enrollment i.e. update the per_in_ler to processed.
    --
    if p_cls_enrt_flag then
     --
--     if p_enrt_mthd_cd = 'A' then   --Bug 5529696
     --
      ben_close_enrollment.close_single_enrollment
        (p_per_in_ler_id        => p_per_in_ler_id
        ,p_effective_date       => p_effective_date
        ,p_business_group_id    => p_business_group_id
        ,p_validate             => p_validate
        ,p_close_uneai_flag     => 'Y'
        ,p_uneai_effective_date => p_effective_date
	,p_close_cd             => 'FORCE'
      );
 -- Bug 5997904
/*      else
     ben_close_enrollment.close_single_enrollment
        (p_per_in_ler_id        => p_per_in_ler_id
        ,p_effective_date       => p_effective_date
        ,p_business_group_id    => p_business_group_id
        ,p_validate             => p_validate
        ,p_close_uneai_flag     => 'Y'
        ,p_uneai_effective_date => p_effective_date
      );
    end if;*/
 -- Bug 5997904
    --
   end if;
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    --
  end process_post_enrollment;
  --
  --
  -- ------------------------------------------------------------------------------
  --    process_post_enrollment_w
  -- -----------------------------------------------------------------------------
  procedure process_post_enrollment_w
    (p_per_in_ler_id     in number
    ,p_pgm_id            in number
    ,p_pl_id             in number
    ,p_enrt_mthd_cd      in varchar2
    ,p_cls_enrt_flag     in varchar2
    ,p_proc_cd           in varchar2
    ,p_person_id         in number
    ,p_business_group_id in number
    ,p_effective_date    in date
    ,p_validate          in varchar2) is
  --
  -- Declare local variables
  --
  l_proc   varchar2(72) := g_package||'process_post_enrollment - wrapper';
  l_validate       BOOLEAN;
  l_cls_enrt_flag  BOOLEAN;
  --
  begin
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    if upper(p_validate) = 'TRUE'
    then
      l_validate := TRUE;
    else
      l_validate := FALSE;
    end if;

    if upper(p_cls_enrt_flag) = 'TRUE'
    then
      l_cls_enrt_flag := TRUE;
    else
      l_cls_enrt_flag := FALSE;
    end if;
    --
    hr_utility.set_location('Entering:'||l_proc, 20);
    --
    process_post_enrollment(
     p_per_in_ler_id     => p_per_in_ler_id
    ,p_pgm_id            => p_pgm_id
    ,p_pl_id             => p_pl_id
    ,p_enrt_mthd_cd      => p_enrt_mthd_cd
    ,p_cls_enrt_flag     => l_cls_enrt_flag
    ,p_proc_cd           => p_proc_cd
    ,p_person_id         => p_person_id
    ,p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    ,p_validate          => l_validate
    );
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    --
  exception
  --
  when others then
    fnd_msg_pub.add;
  --
  end process_post_enrollment_w;


procedure process_post_enrt_calls_w
  (p_validate               in varchar2 default 'N'
  ,p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number default null
  ,p_flx_cr_flag            in varchar2 default 'N'
  ,p_enrt_mthd_cd           in varchar2
  ,p_proc_cd                in varchar2 default null
  ,p_cls_enrt_flag          in varchar2 default 'N'
  ,p_business_group_id      in number
  ,p_effective_date         in date)
is
  --
  l_validate              boolean := false;
  l_effective_date        date    := trunc(sysdate);
  l_cls_enrt_flag         boolean := false;
  --
begin
  --
  fnd_msg_pub.initialize;
  if p_validate = 'Y' then
    l_validate := true;
  end if;
  --
  if p_cls_enrt_flag = 'Y' then
    l_cls_enrt_flag := true;
  end if;
  --
  if p_effective_date is not null then
    -- l_effective_date := to_date(p_effective_date, 'YYYY/MM/DD');
    l_effective_date := p_effective_date ;
  end if;
  --
  ben_proc_common_enrt_rslt.set_elcn_made_or_asnd_dt
      (p_validate              => l_validate
      ,p_per_in_ler_id         => p_per_in_ler_id
      ,p_pgm_id                => p_pgm_id
      ,p_pl_id                 => p_pl_id
      ,p_enrt_mthd_cd          => p_enrt_mthd_cd
      ,p_business_group_id     => p_business_group_id
      ,p_effective_date        => l_effective_date);
  --
  ben_prtt_enrt_result_api.multi_rows_edit
      (p_person_id            => p_person_id
      ,p_per_in_ler_id        => p_per_in_ler_id
      ,p_pgm_id               => p_pgm_id
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => l_effective_date);
  --
  ben_proc_common_enrt_rslt.process_post_results
      (p_validate             => l_validate
      ,p_person_id            => p_person_id
      ,p_per_in_ler_id        => p_per_in_ler_id
      ,p_flx_cr_flag          => p_flx_cr_flag
      ,p_enrt_mthd_cd         => p_enrt_mthd_cd
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => l_effective_date
      ,p_self_service_flag    => true
      ,p_pl_id                => p_pl_id);
  --
  ben_proc_common_enrt_rslt.process_post_enrollment
      (p_validate             => l_validate
      ,p_person_id            => p_person_id
      ,p_per_in_ler_id        => p_per_in_ler_id
      ,p_pgm_id               => p_pgm_id
      ,p_pl_id                => p_pl_id
      ,p_enrt_mthd_cd         => p_enrt_mthd_cd
      ,p_cls_enrt_flag        => l_cls_enrt_flag
      ,p_proc_cd              => p_proc_cd
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => l_effective_date);
  --
exception
  --
  when app_exception.application_exception then	--Bug 4387247
    fnd_msg_pub.add;
    ben_det_enrt_rates.clear_globals; --Bug 4436578
  when others then
    --Bug 4387247
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
    ben_det_enrt_rates.clear_globals;
  --
end process_post_enrt_calls_w;


procedure process_post_enrt_calls_w
  (p_validate               in varchar2 default 'N'
  ,p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number default null
  ,p_flx_cr_flag            in varchar2 default 'N'
  ,p_enrt_mthd_cd           in varchar2
  ,p_proc_cd                in varchar2 default null
  ,p_cls_enrt_flag          in varchar2 default 'N'
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_self_service_flag      in varchar2 )
is
  --
  l_validate              boolean := false;
  l_effective_date        date    := trunc(sysdate);
  l_cls_enrt_flag         boolean := false;
  l_self_service_flag     boolean := false;
  --
begin
  --
  fnd_msg_pub.initialize;
  if p_validate = 'Y' then
    l_validate := true;
  end if;
  --
  if p_cls_enrt_flag = 'Y' then
    l_cls_enrt_flag := true;
  end if;
  --
  if p_self_service_flag = 'Y' then
    l_self_service_flag := true;
  end if;
  --
  if p_effective_date is not null then
    -- l_effective_date := to_date(p_effective_date, 'YYYY/MM/DD');
    l_effective_date := p_effective_date ;
  end if;
  --
  ben_proc_common_enrt_rslt.set_elcn_made_or_asnd_dt
      (p_validate              => l_validate
      ,p_per_in_ler_id         => p_per_in_ler_id
      ,p_pgm_id                => p_pgm_id
      ,p_pl_id                 => p_pl_id
      ,p_enrt_mthd_cd          => p_enrt_mthd_cd
      ,p_business_group_id     => p_business_group_id
      ,p_effective_date        => l_effective_date);
  --
  ben_prtt_enrt_result_api.multi_rows_edit
      (p_person_id            => p_person_id
      ,p_per_in_ler_id        => p_per_in_ler_id
      ,p_pgm_id               => p_pgm_id
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => l_effective_date);
  --
  ben_proc_common_enrt_rslt.process_post_results
      (p_validate             => l_validate
      ,p_person_id            => p_person_id
      ,p_per_in_ler_id        => p_per_in_ler_id
      ,p_flx_cr_flag          => p_flx_cr_flag
      ,p_enrt_mthd_cd         => p_enrt_mthd_cd
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => l_effective_date
      ,p_self_service_flag    => l_self_service_flag
      ,p_pl_id                => p_pl_id);
  --
  ben_proc_common_enrt_rslt.process_post_enrollment
      (p_validate             => l_validate
      ,p_person_id            => p_person_id
      ,p_per_in_ler_id        => p_per_in_ler_id
      ,p_pgm_id               => p_pgm_id
      ,p_pl_id                => p_pl_id
      ,p_enrt_mthd_cd         => p_enrt_mthd_cd
      ,p_cls_enrt_flag        => l_cls_enrt_flag
      ,p_proc_cd              => p_proc_cd
      ,p_business_group_id    => p_business_group_id
      ,p_effective_date       => l_effective_date);
  --
exception
  --
  when others then
    fnd_msg_pub.add;
    ben_det_enrt_rates.clear_globals;
  --
end process_post_enrt_calls_w;

  end ben_proc_common_enrt_rslt;

/
