--------------------------------------------------------
--  DDL for Package Body BEN_NEWLY_INELIGIBLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_NEWLY_INELIGIBLE" as
/* $Header: beninelg.pkb 120.6.12010000.7 2009/11/02 11:27:43 sallumwa ship $ */
-----------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
	Manage Newly Ineligible Persons
Purpose
      This package is used to find out whether the person is covered under the
      Program/Plan or OIPL for which he is newly ineligible. And if covered,
      it calls the deenrollment API to deenroll the person.

History
	Date             Who           Version    What?
	----             ---           -------    -----
	  28 May 98       J Mohapatra   110.0      Created.
        07 Jun 98       J Mohapatra   110.1      added 'ben_' to package Name.
        24 Oct 98       G Perry       115.3      Corrected Query removed
                                                  dbms_output.put_line calls.
        05 Nov 98       G Perry       115.4      Added lee_rsn_id, made
                                                  cursors more performant.
        01 Feb 99       Y Rathman     115.5      Made modification to allow
                                                  flag enrollments as no longer
                                                  eligible
        28 Apr 99       lmcdonal       115.6      prtt_enrt_rslt now has stat_cd
        25 May 99       lmcdonal       115.7      To de-enroll from a comp object
                                                  when running in scheduled mode,
                                                  we should not look for a lee_rsn
                                                  to pass to delete enrt, but instead
                                                  pass the enrt_perd_id from the
                                                  benmngle parm list.
        27 May 99       maagrawa       115.8      Added calls to imputed income
                                                  and flex credits recomputing
                                                  procedures when de-enrollment
                                                  takes place.
        03 Jun 99       Tmathers       115.9      Backport of 115.7 with
                                                  cacheing changes.
        03 Jun 99       Tmathers       115.10     leapfrog of 115.8 with
                                                  cacheing changes.
        24 Jun 99       maagrawa       115.11     subj_to_imput_inc_flag changed
                                                  to subj_to_imptd_incm_typ_cd.
        20-JUL-99       Gperry         115.12     genutils -> benutils package
                                                  rename.
        04-OCT-99       Stee           115.13     If terminating all
                                                  coverage for COBRA,
                                                  also end date Qualified bnf.
        29-Oct-99       maagrawa       115.14     Call the delete_enrollment
                                                  process with parameter
                                                  p_source => 'beninelg'.
        12-Nov-99       lmcdonal       115.15     Pass enrt_mthd_cd to
                                                  recompute_flex_credits.
        31-Jan-00       jcarpent       115.16     Use dt mode globals.
        09-Feb-00       jcarpent       115.17     Don't call multi_rows_edit.
        11-Feb-00       jcarpent       115.18     Accept p_pgm_id for plips.
        04-Mar-00       stee           115.19     Add ptip_id to
                                                  end_prtt_cobra_eligibility.
        16-Mar-00       jcarpent       115.20     Fixed lee_rsn logic to use
                                                  plan level then pgm level.
                                                  Also removed oipl query.
                                                  Also query into pen loop
                                                  since could be different
        29-Mar-00       jcarpent       115.21     Reset l_lee_rsn_id for each
                                                  plan so if not at pgm level
                                                  will use each plan.
        11-Apr-00       gperry         115.22     Added extra param for fido
                                                  ctrl m call.
        24-jun-00       jcarpent       115.23     Pass lee_rsn_id to
                                                  ben_determine_date. (5182,
                                                  1304658,1311768)
        19-Jul-00       jcarpent       115.24     5241, 1343362.  Process
                                                  comp objects in order.
        05-Sep-00       pbodla         115.25     - Bug 5422 : Allow different enrollment
                                                  periods for programs for a scheduled
                                                  enrollment. p_popl_enrt_typ_cycl_id
                                                  is removed.
        08-Nov-00       vputtiga       115.26     - Bug Fix 1485814. Set global g_enrollment_change
                                                  to TRUE after each call to delete_enrollment
        05-Jan-01       kmahendr       115.27     - Check for type of life event to get the correct
                                                    life event
        21-Feb-01       ikasire        115.28     remove the special treatment given
                                                  to the 'W' (1 prior) cases, as we need to
                                                  call delete_enrollment for these
                                                  cases also. Right now when a person
                                                  becomes ineligibile for a life event under
                                                  process, benmngle is closing the life event
       09-May-01        kmahendr       115.29     Bug#1646404 - ENrollment result rows end dated
                                                  with min(lf_evt_ocrd_dt,enrl_perd_strt_dt) -1
       06-Jun-01        kmahendr       115.30     Bug#1819106 - l_effective date is assigned the
                                                  value even if enrollment period start dt cd is
                                                  null
       22-Jun-01        bwharton       115.31     Bug 1646404.  Sometimes the effective date
                                                  is computed to be before the esd of the pen.
                                                  Move it ahead to the processed date of
                                                  the previous pil if greater.
       15-Jul-01        kmahendr       115.32     Bug#1871614- in selection mode the effective
                                                  date is passed as one day less than benmngle
						  run date and there is no lfevt_ocrd date which
	                                          caused coverage to end 2 days before eff.date
       04-Sep-01        kmahendr       115.33     Bug#1950044-Cursors for fetching enrt_rlst
                                                  modified so that if effective_start_date is
                                                  after lf_event_ocrd_dt of subsequent lf event
                                                  the results are pulled-similar to condition in
                                                  bendenrr
       19-dec-01        pbodla         115.34     CWB Changes : fetch procd_dt's
                                                  of relevant per in ler's
       26-dec-01        kmahendr       115.35     In unrestricted mode, effective_date is passed
                                                  for delete_enrollment
       07-Jan-02        Rpillay        115.36     Added dbdrv and checkfile commands.
       19-MAy-02        ikasire        115.37     Bug 2200139 Override Enrollment issues.
                                                  We may have the enrollments started in future
                                                  for Override Case.
       23-May-02        ikasire        115.38     Bug 2200139 More Override changes
       11-Jul-02	kmahendr       115.39     ABSENCES - Effective date is not
                                                  computed for absence life
                                                  event as start and end can occur on the same day
       15-Jul-02	pbodla         115.40     ABSENCES - fixed cursor which
                                                  fetches the typ_cd
       07-Aug-02        tjesumic       115.41     If  the Ineligibility level  define in program
                                                  all the plan in the pgm became ineligble so
                                                  There is no need to call the inputed income
                                                  calcualtion
       14-Aug-02        stee           115.43     COBRA: Set a global variable if
                                                  enrollment in COBRA is terminated.
                                                  Bug 1794808.
       19-Aug-02        mmudigon       115.44     call ben_comp_object only if pgm_id is not null
       12-Sep-02        kmahendr       115.45     Bug#2508822 - Effective date is not changed
                                                  if coverage start date is same as effective
                                                  date
       19-Nov-02        kmahendr       115.46     Bug#2641545 - effective date is changed based
                                                  on effective start date of pen row.
       11-Dec-02        tjesumic       115.47     lf_evt_ocrd_dt from the table ben_benefit_actions
                                                  coverted into date format 'DD/MM/RRR'. the system errors
                                                  because the date is stored in YYYY/MM/DD format
                                                  This is fixed by removing the format mask in the to_date
                                                  this will conver the string to char in the same format
                                                  bug # 2688628
      16-Sep-03        kmahendr        115.48     GSP changes
      19-Sep-03        rpillay         115.49     GSCC warning fix
      25-Nov-03        kmahendr        115.50     Bug#3279350- added cursors to find the deenrolled
                                                  results after the event date and reopen the result
      02-jun-04        nhunur          115.51     corrected join betweeen pil and ler to avoid MJC
      05-Jul-04        bmanyam         115.52     Bug# 3507652 - The fix 115.50 (3279350) needs to
                                                  run for the unrestricted le also. Enabled this.
      15-Sep-04        pbodla          115.52     iRec : avoid using the iRec life events
                                                  in cursor c_procd_dt_pil and
                                                  Modified query in c_pen_max_esd to join
                                                  between pil and pen.
      02-dec-04        ikasire         115.54     Bug 4046914
      03-dec-04        ikasire/bala    115.55     Bug 4031416 need to call backout proces
      23-dec-04        tjesumic        115.56     p_prt_enrt_rslt_id is passed to backout_future_coverage
      07-Feb-05        tjesumic        115.57     call for backout_future_cvg is removed. future result is
                                                  taken care in delete_enrollment # 4118315
      18-Apr-05        tjesumic        115.58     GHR enhancement to add number of days in enrt perd codeds
      30-Jun-05        kmahendr        115.59     Bug#4463829 - added person_id parameter to
                                                  ben_determine_date calls
      07-Oct-05        ssarkar         115.60    Bug 4645272 : when Open/Administartive runs in Life event mode,
                                                    populate enrt_perd_id and not lee_rsn_id
      06-Jun-06        rbingi          115.61    Bug 5257226: passing effective_date to delete_enrollment as
                                                   delete_enrollment will end-date enrollment 1 day prior.
      16-Nov-06        abparekh        115.62    Bug 5642702 : Defined and initialized global
                                                               variable G_DENROLING_FROM_PGM
      05-Apr-07        rtagarra        115.63    Bug 6000303 : Defer Deenrollment ENH.Added
							       Procedure defer_delete_enrollment.
      16-May-07        rtagarra        115.64       -- DO --
      17-Nov-07        rtagarra        115.65    Bug 6634074 :
      25-Mar-08        sallumwa        115.67    Bug 6881745 : Modified cursor c_epo_plip_defer in Procedure
                                                 defer_delete_enrollment,to pick-up ineligible rows with respect
						 to p_effective_date.
      24-Jun-08        sallumwa        115.68    Bug 7181958 : Modified cursor c_epo_plip_defer in Procedure
                                                 defer_delete_enrollment,to pick-up ineligible rows with respect
						 to latest Life event.Reverted back the changes of 6881745.
      21-Aug-08        sallumwa        115.69    Bug 7301670 : Modified cursor c_epo_plip_defer in Procedure
                                                 defer_delete_enrollment,to pick-up ineligible rows with respect
						 Active Program and not Cobra pgm when person has dual
						 program eligibility.
      22-Aug-08        sallumwa        115.70    Bug 7342283 : Modified cursor c_pep_pgm_defer in Procedure
                                                 defer_delete_enrollment,to pick-up ineligible rows with respect
						 Active Program and not Cobra pgm when person has dual
						 program eligibility(for plip with no options).
      02-Nov-09        sallumwa        115.71    Bug 9030738 : Modified the procedure main so that the election is
                                                 de-enrolled based on the enrollment period start date.
*/
-----------------------------------------------------------------------
procedure defer_delete_enrollment
		( p_per_in_ler_id	     in number
		 ,p_person_id		     in number
		 ,p_business_group_id        in number
		 ,p_effective_date           in date
		) is
  --
  l_proc              varchar2(80) :=  g_package|| '.defer_delete_enrollment';
  --
cursor c_pel_pgm_id is
  --
  select  pel.*
   from   ben_pil_elctbl_chc_popl pel
   where  pel.per_in_ler_id = p_per_in_ler_id
    and   pel.defer_deenrol_flag = 'Y'
    and   pel.deenrol_made_dt is null
    and   pel.pil_elctbl_popl_stat_cd not in ('VOIDD','BCKDT');
  --
l_pel_pgm_id c_pel_pgm_id%ROWTYPE;
  --
cursor c_pep_pgm_defer(p_pgm_id number) is
    --
     select pen.*
     from   ben_prtt_enrt_rslt_f pen
	   ,ben_elig_per_f pep
     where  pen.pgm_id = p_pgm_id
     ---Bug 7342283
      and   pen.pgm_id = pep.pgm_id
      ----Bug 7342283
      and   pen.pl_id =  pep.pl_id
      and   pep.elig_flag = 'N'
      and   pep.per_in_ler_id = p_per_in_ler_id
      and   pen.prtt_enrt_rslt_stat_cd is null
      and   pen.effective_end_date = hr_api.g_eot
      and   pen.enrt_cvg_thru_dt   = hr_api.g_eot
      and   pen.oipl_id is null
      and   pen.person_id = p_person_id;
  --
  l_pep_pgm_defer c_pep_pgm_defer%ROWTYPE;
  --
cursor c_pep_pl_defer(p_pl_id number) is
    --
     select pen.*
     from   ben_prtt_enrt_rslt_f pen
	   ,ben_elig_per_f pep
     where  pen.pl_id = p_pl_id
      and   pep.pl_id = pen.pl_id
      and   pep.elig_flag = 'N'
      and   pen.pgm_id is null
      and   pen.oipl_id is null
      and   pep.per_in_ler_id = p_per_in_ler_id
      and   pen.prtt_enrt_rslt_stat_cd is null
      and   pen.effective_end_date = hr_api.g_eot
      and   pen.enrt_cvg_thru_dt   = hr_api.g_eot
      and   pen.person_id = p_person_id;
  --
  l_pep_pl_defer c_pep_pl_defer%ROWTYPE;
  --
  cursor c_epo_plip_defer(p_pgm_id number) is
    --
     select pen.*
     from   ben_elig_per_opt_f epo
	   ,ben_prtt_enrt_rslt_f pen
	   ,ben_oipl_f oipl
	   ,ben_elig_per_f pep
     where  pen.pgm_id = p_pgm_id
     ---Bug 7301670
      and   pen.pgm_id = pep.pgm_id
      ----Bug 7301670
      and   pep.pl_id = pen.pl_id
      and   pen.oipl_id = oipl.oipl_id
      and   oipl.opt_id = epo.opt_id
      and   epo.elig_per_id = pep.elig_per_id
      and   pep.per_in_ler_id = p_per_in_ler_id
      and   epo.elig_flag = 'N'
      --Bug : 6881745
     /*  AND   p_effective_date
              BETWEEN epo.effective_start_date AND epo.effective_end_date */
      --Bug : 7181958
      and   epo.effective_end_date = hr_api.g_eot
      --Bug : 6881745
      and   pen.effective_end_date = hr_api.g_eot
      and   pen.enrt_cvg_thru_dt   = hr_api.g_eot
      and   pen.prtt_enrt_rslt_stat_cd is null
      and   pen.person_id = p_person_id;
   --
 l_epo_plip_defer c_epo_plip_defer%ROWTYPE;
   --
  cursor c_epo_plnip_defer(p_pl_id number) is
    --
     select pen.*
     from   ben_elig_per_opt_f epo
	   ,ben_prtt_enrt_rslt_f pen
	   ,ben_oipl_f oipl
	   ,ben_elig_per_f pep
     where  pen.pl_id = p_pl_id
      and   pep.pl_id = pen.pl_id
      and   pen.oipl_id = oipl.oipl_id
      and   pep.pgm_id is null
      and   epo.elig_per_id = pep.elig_per_id
      and   pep.per_in_ler_id = p_per_in_ler_id
      and   oipl.opt_id = epo.opt_id
      and   epo.elig_flag = 'N'
      and   pen.effective_end_date = hr_api.g_eot
      and   pen.enrt_cvg_thru_dt   = hr_api.g_eot
      and   pen.prtt_enrt_rslt_stat_cd is null
      and   pen.person_id = p_person_id;
     --
 l_epo_plnip_defer c_epo_plnip_defer%ROWTYPE;
     --
   l_effective_start_date date;
   l_effective_end_date   date;
   l_effective_date       date;
     --
begin
 --
  hr_utility.set_location ('Entering '|| l_proc|| p_effective_date,10);
 --
 l_effective_date := p_effective_date;
 --
  open c_pel_pgm_id;
   loop
    fetch c_pel_pgm_id into l_pel_pgm_id;
    exit when c_pel_pgm_id%NOTFOUND;
 --
  if l_pel_pgm_id.pgm_id is not null then
   --
    hr_utility.set_location('PGM'|| l_pel_pgm_id.pgm_id,24);
   --
   open c_pep_pgm_defer(l_pel_pgm_id.pgm_id);
     loop
      fetch c_pep_pgm_defer into l_pep_pgm_defer;
      exit when c_pep_pgm_defer%NOTFOUND;
     --
       if c_pep_pgm_defer%found then
      --
        hr_utility.set_location ('PEN'|| l_pep_pgm_defer.prtt_enrt_rslt_id,46000);
      --
        if l_effective_date <= l_pep_pgm_defer.effective_start_date then
             l_effective_date := l_pep_pgm_defer.effective_start_date + 1;
        --
       end if;
       --
    ben_PRTT_ENRT_RESULT_api.delete_enrollment(
             p_validate              => false,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_prtt_enrt_rslt_id     => l_pep_pgm_defer.prtt_enrt_rslt_id,
             p_effective_start_date  => l_effective_start_date,
             p_effective_end_date    => l_effective_end_date,
             p_object_version_number => l_pep_pgm_defer.object_version_number,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => l_effective_date,
             p_datetrack_mode        => 'DELETE',
	     p_source		     => 'beninelg',
             p_multi_row_validate    => FALSE);
       --
       end if;
    --
    end loop;
    --
    close c_pep_pgm_defer;
   --
   open c_epo_plip_defer(l_pel_pgm_id.pgm_id);
    loop
     fetch c_epo_plip_defer into l_epo_plip_defer;
     exit when c_epo_plip_defer%NOTFOUND;
    --
     hr_utility.set_location ('EPO PEN '|| l_epo_plip_defer.prtt_enrt_rslt_id||'DATE'||l_effective_date,10007);
    --
     if c_epo_plip_defer%found then
    --
       if l_effective_date <= l_epo_plip_defer.effective_start_date then
            l_effective_date := l_epo_plip_defer.effective_start_date + 1;
        --
      end if;
       --
    ben_PRTT_ENRT_RESULT_api.delete_enrollment(
             p_validate              => FALSE,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_prtt_enrt_rslt_id     => l_epo_plip_defer.prtt_enrt_rslt_id,
             p_effective_start_date  => l_effective_start_date,
             p_effective_end_date    => l_effective_end_date,
             p_object_version_number => l_epo_plip_defer.object_version_number,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => l_effective_date,
             p_datetrack_mode        => 'DELETE',
	     p_source		     => 'beninelg',
             p_multi_row_validate    => FALSE);
    --
  end if;
  --
  end loop;
  --
 close c_epo_plip_defer;
  --
      ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
              (p_validate                   => FALSE
	      ,p_pil_elctbl_chc_popl_id     => l_pel_pgm_id.pil_elctbl_chc_popl_id
              ,p_object_version_number      => l_pel_pgm_id.object_version_number
              ,p_effective_date             => p_effective_date
	      ,p_defer_deenrol_flag	    => 'Y'
	      ,p_deenrol_made_dt            => p_effective_date
	      );
 --
elsif l_pel_pgm_id.pl_id is not null then
--
  open c_pep_pl_defer(l_pel_pgm_id.pl_id);
    loop
     fetch c_pep_pl_defer into l_pep_pl_defer;
     exit when c_pep_pl_defer%NOTFOUND;
     --
     if c_pep_pl_defer%found then
      --
      hr_utility.set_location ('PEN'|| l_pep_pl_defer.prtt_enrt_rslt_id,46000);
      --
      if l_effective_date <= l_pep_pl_defer.effective_start_date then
            l_effective_date := l_pep_pl_defer.effective_start_date + 1;
        --
     end if;
      --
      ben_PRTT_ENRT_RESULT_api.delete_enrollment(
             p_validate              => false,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_prtt_enrt_rslt_id     => l_pep_pl_defer.prtt_enrt_rslt_id,
             p_effective_start_date  => l_effective_start_date,
             p_effective_end_date    => l_effective_end_date,
             p_object_version_number => l_pep_pl_defer.object_version_number,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => l_effective_date,
             p_datetrack_mode        => 'DELETE',
	     p_source		     => 'beninelg',
             p_multi_row_validate    => FALSE);
       --
    end if;
    --
   end loop;
    --
  close c_pep_pl_defer;
   --
  open c_epo_plnip_defer(l_pel_pgm_id.pl_id);
   loop
   fetch c_epo_plnip_defer into l_epo_plnip_defer;
   exit when c_epo_plnip_defer%NOTFOUND;
   --
   hr_utility.set_location ('EPO PEN '|| l_epo_plip_defer.prtt_enrt_rslt_id,10007);
   --
     if l_effective_date <= l_epo_plnip_defer.effective_start_date then
            l_effective_date := l_epo_plnip_defer.effective_start_date + 1;
        --
    end if;
      --
  ben_PRTT_ENRT_RESULT_api.delete_enrollment(
             p_validate              => FALSE,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_prtt_enrt_rslt_id     => l_epo_plnip_defer.prtt_enrt_rslt_id,
             p_effective_start_date  => l_effective_start_date,
             p_effective_end_date    => l_effective_end_date,
             p_object_version_number => l_epo_plnip_defer.object_version_number,
             p_business_group_id     => p_business_group_id,
             p_effective_date        => l_effective_date,
             p_datetrack_mode        => 'DELETE',
     	     p_source		     => 'beninelg',
             p_multi_row_validate    => FALSE);
    --
   end loop;
  --
 close c_epo_plnip_defer;
  --
  ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
              (p_validate                   => FALSE
	      ,p_pil_elctbl_chc_popl_id     => l_pel_pgm_id.pil_elctbl_chc_popl_id
              ,p_object_version_number      => l_pel_pgm_id.object_version_number
              ,p_effective_date             => p_effective_date
	      ,p_defer_deenrol_flag	    => 'Y'
	      ,p_deenrol_made_dt            => p_effective_date
	      );

  end if;
  --
 end loop;
 --
close c_pel_pgm_id;
 --
  hr_utility.set_location ('Leaving'||l_proc,10);
 --
  end defer_delete_enrollment;
--
--
procedure main(p_person_id                in number,
	       p_pgm_id                   in number default null,
	       p_pl_id                    in number default null,
	       p_oipl_id                  in number default null,
	       p_business_group_id        in number,
	       p_ler_id                   in number,
	       p_effective_date           in date) is
  --
  l_proc              varchar2(80) :=  g_package|| '.main';
  l_level             varchar2(30);
  l_eff_strt          date;
  l_eff_end           date;
  l_per_in_ler_id     number := null;
  l_lee_rsn_id        number := null;
  --
  l_enrt_cvg_end_dt_cd  varchar2(30);
  l_ovn               number;
  l_dummy_dt          date;
  l_dummy_num         number;
  l_dummy_varchar     varchar2(30);
  l_oipl_rec ben_oipl_f%rowtype; -- TM added for backport of 115.6
  l_pgm_rec  ben_pgm_f%rowtype;

  l_effective_date     date;
  l_effective_date_1   date := p_effective_date - 1;
  -- Bug 2200139 added effective_start_date, enrt_mthd_cd for Override Case
  cursor c_pen_pl is
    select pen.prtt_enrt_rslt_id, pgm_id, pl_id, oipl_id,  pen.object_version_number,ptip_id,
           pen.effective_start_date,pen.enrt_mthd_cd,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen
    where  p_pl_id = pen.pl_id
    and    nvl(pen.pgm_id,-1)=nvl(p_pgm_id,-1)
    and    pen.person_id = p_person_id
    and    pen.business_group_id+0 = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.enrt_cvg_thru_dt = hr_api.g_eot   -- 9999
    and    l_effective_date_1 <= pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_strt_dt < pen.effective_end_date
    order  by effective_start_date desc;
 /*
    and    pen.enrt_cvg_thru_dt > p_effective_date
    and    p_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date;
*/
  --  -- Bug 2200139 added effective_start_date, enrt_mthd_cd for Override Case
  cursor c_pen_pgm is
    select pen.prtt_enrt_rslt_id, pgm_id, pl_id, oipl_id, pen.object_version_number,ptip_id,
           pen.effective_start_date,pen.enrt_mthd_cd,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen
    where  p_pgm_id = pen.pgm_id
    and    pen.person_id = p_person_id
    and    pen.business_group_id+0 = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.enrt_cvg_thru_dt = hr_api.g_eot -- 9999
    and    l_effective_date_1 <= pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_strt_dt < pen.effective_end_date
    order  by effective_start_date desc;
/*
    and    pen.enrt_cvg_thru_dt > p_effective_date
    and    p_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date;
*/
  --   -- Bug 2200139 added effective_start_date, enrt_mthd_cd for Override Case
  cursor c_pen_oipl is
    select pen.prtt_enrt_rslt_id, pgm_id, pl_id, oipl_id, pen.object_version_number,
           pen.effective_start_date,pen.enrt_mthd_cd,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen
    where  p_oipl_id = pen.oipl_id
    and    nvl(pen.pgm_id,-1)=nvl(p_pgm_id,-1)
    and    pen.person_id = p_person_id
    and    pen.business_group_id+0 = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.enrt_cvg_thru_dt = hr_api.g_eot -- 9999
    and    l_effective_date_1 <= pen.enrt_cvg_thru_dt
    and    pen.enrt_cvg_strt_dt < pen.effective_end_date
    order  by effective_start_date desc;
/*
    and    pen.enrt_cvg_thru_dt > p_effective_date
    and    p_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date;
*/
  --
  cursor c_lee_rsn_pl(p_pl_id number) is
    select lee.lee_rsn_id,
           lee.enrt_perd_strt_dt_cd,
           lee.enrt_perd_strt_dt_rl,
           lee.enrt_perd_strt_days
    from   ben_lee_rsn_f lee,
           ben_popl_enrt_typ_cycl_f pop
    where  pop.pl_id = p_pl_id
    and    pop.business_group_id +0 = p_business_group_id
    and    p_effective_date
           between pop.effective_start_date
           and     pop.effective_end_date
    and    pop.popl_enrt_typ_cycl_id = lee.popl_enrt_typ_cycl_id
    and    lee.business_group_id +0 = pop.business_group_id
    and    lee.ler_id = p_ler_id
    and    p_effective_date
           between lee.effective_start_date
           and     lee.effective_end_date;
  --
  -- PB :5422
  --
  CURSOR c_sched_enrol_period_for_plan(p_pl_id number,
                                       p_lf_evt_ocrd_dt date) IS
    SELECT   enrtp.enrt_perd_id,
             enrtp.strt_dt
    FROM     ben_popl_enrt_typ_cycl_f petc,
             ben_enrt_perd enrtp
    WHERE    petc.pl_id = p_pl_id
    AND      petc.business_group_id = p_business_group_id
    AND      p_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                                  AND petc.effective_end_date
    AND      petc.enrt_typ_cycl_cd <> 'L'
    AND      enrtp.business_group_id = p_business_group_id
    AND      enrtp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
    /* PB :5422 AND      enrtp.strt_dt=enrtp1.strt_dt
    AND      enrtp1.popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id
    AND      enrtp1.business_group_id     = p_business_group_id */
    AND      enrtp.popl_enrt_typ_cycl_id  = petc.popl_enrt_typ_cycl_id;
  --
  -- This cursor gets the enrolment period for scheduled
  -- elections for program level
  --
  CURSOR c_sched_enrol_period_for_pgm(p_pgm_id number,
                                      p_lf_evt_ocrd_dt date) IS
    SELECT   enrtp.enrt_perd_id,
             enrtp.strt_dt
    FROM     ben_popl_enrt_typ_cycl_f petc,
             ben_enrt_perd enrtp
    WHERE    petc.pgm_id = p_pgm_id
    AND      petc.business_group_id = p_business_group_id
    AND      p_lf_evt_ocrd_dt BETWEEN petc.effective_start_date
                 AND petc.effective_end_date
    AND      petc.enrt_typ_cycl_cd <> 'L'
    AND      enrtp.business_group_id = p_business_group_id
    AND      enrtp.asnd_lf_evt_dt  = p_lf_evt_ocrd_dt
    /* PB :5422 AND      enrtp1.business_group_id = p_business_group_id
    AND      enrtp.strt_dt= enrtp1.strt_dt
    AND      enrtp1.enrt_perd_id = p_popl_enrt_typ_cycl_id */
    AND      enrtp.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id;
  --
  cursor c_lee_rsn_pgm(p_pgm_id number) is
    select lee.lee_rsn_id,
           lee.enrt_perd_strt_dt_cd,
           lee.enrt_perd_strt_dt_rl,
           lee.enrt_perd_strt_days
    from   ben_lee_rsn_f lee,
           ben_popl_enrt_typ_cycl_f pop
    where  pop.pgm_id = p_pgm_id
    and    pop.business_group_id +0 = p_business_group_id
    and    p_effective_date
           between pop.effective_start_date
           and     pop.effective_end_date
    and    pop.popl_enrt_typ_cycl_id = lee.popl_enrt_typ_cycl_id
    and    lee.business_group_id +0 = pop.business_group_id
    and    lee.ler_id = p_ler_id
    and    p_effective_date
           between lee.effective_start_date
           and     lee.effective_end_date;
  --
  cursor c_imptd(v_pl_id in number) is
     select 'Y'
     from    ben_pl_f pl
     where   pl.pl_id = v_pl_id
     and     pl.business_group_id + 0 = p_business_group_id
     and     p_effective_date between
             pl.effective_start_date and pl.effective_end_date
     and     pl.subj_to_imptd_incm_typ_cd = 'PRTT';
  --
  -- CWB Changes.
  --
  cursor c_per_in_ler is
     select pil.lf_evt_ocrd_dt, ler.typ_cd
     from   ben_per_in_ler pil,
            ben_ler_f ler
     where  pil.per_in_ler_id = l_per_in_ler_id
       and  pil.ler_id = ler.ler_id
       and  p_effective_date between ler.effective_start_date and
                                     ler.effective_end_date;
  --
  --  22-Jun-01        bwharton       115.31
  --
  -- CWB Changes.
  --
  cursor c_procd_dt_pil is
     select pil.procd_dt
     from   ben_per_in_ler pil,
            ben_ler_f ler
     where  pil.person_id = p_person_id
     and    pil.per_in_ler_id <> l_per_in_ler_id
     and    pil.per_in_ler_stat_cd = 'PROCD'
     and    pil.ler_id = ler.ler_id
     and    p_effective_date between
            ler.effective_start_date and ler.effective_end_date
     and    ler.typ_cd not in ('COMP','GSP', 'IREC')
     order by lf_evt_ocrd_dt desc;

  cursor c_procd_dt_pil_cwb is
     select pil.procd_dt
     from   ben_per_in_ler pil,
            ben_ler_f ler
     where  pil.person_id = p_person_id
     and    pil.per_in_ler_id <> l_per_in_ler_id
     and    pil.per_in_ler_stat_cd = 'PROCD'
     and    pil.ler_id = ler.ler_id
     and    p_effective_date between
            ler.effective_start_date and ler.effective_end_date
     and    ler.ler_id =  p_ler_id
     and    ler.typ_cd = 'COMP'
     order by lf_evt_ocrd_dt desc;
  --
  --Bug#3279350

  cursor c_pen_pl_2 is
    select pen.prtt_enrt_rslt_id, pgm_id, pl_id, oipl_id,  pen.object_version_number,ptip_id,
           pen.effective_start_date,pen.enrt_mthd_cd,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen
    where  p_pl_id = pen.pl_id
    and    nvl(pen.pgm_id,-1)=nvl(p_pgm_id,-1)
    and    pen.person_id = p_person_id
    and    pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.enrt_cvg_thru_dt <> hr_api.g_eot
    and    l_effective_date_1 < pen.enrt_cvg_thru_dt;
  --
  cursor c_pen_pgm_2 is
    select pen.prtt_enrt_rslt_id, pgm_id, pl_id, oipl_id, pen.object_version_number,ptip_id,
           pen.effective_start_date,pen.enrt_mthd_cd,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen
    where  p_pgm_id = pen.pgm_id
    and    pen.person_id = p_person_id
    and    pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.enrt_cvg_thru_dt <> hr_api.g_eot
    and    l_effective_date_1 < pen.enrt_cvg_thru_dt;
  --
  cursor c_pen_oipl_2 is
    select pen.prtt_enrt_rslt_id, pgm_id, pl_id, oipl_id, pen.object_version_number,
           pen.effective_start_date,pen.enrt_mthd_cd,
           pen.enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f pen
    where  p_oipl_id = pen.oipl_id
    and    nvl(pen.pgm_id,-1)=nvl(p_pgm_id,-1)
    and    pen.person_id = p_person_id
    and    pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.enrt_cvg_thru_dt <> hr_api.g_eot
    and    pen.effective_end_date = hr_api.g_eot
    and    l_effective_date_1 < pen.enrt_cvg_thru_dt;
  --
  cursor c_pen_max_esd (v_prtt_enrt_rslt_id in number) is
    select pen.effective_end_date,pen.object_version_number
    from   ben_prtt_enrt_rslt_f pen,
           ben_per_in_ler pil
    where  prtt_enrt_rslt_id       =  v_prtt_enrt_rslt_id
    and    pen.business_group_id   =  p_business_group_id
    and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
    and    pen.per_in_ler_id       =  pil.per_in_ler_id
    and    pen.effective_end_date <> hr_api.g_eot
    order by pen.effective_end_date desc;
  --
  l_correction           boolean;
  l_update               boolean;
  l_update_override      boolean;
  l_update_change_insert boolean;
  l_imptd_incm_chg       boolean := false;
  l_imptd_incm_flag      varchar2(30);
  l_inelig_lvl_in_pgm    varchar2(30):= 'N' ;
  l_datetrack_mode       varchar2(30);
  l_env_rec              ben_env_object.g_global_env_rec_type;
  l_benmngle_parm_rec    benutils.g_batch_param_rec;
  l_param_lf_evt_ocrd_dt date;
  l_enrt_perd_id         number;
  l_LF_EVT_OCRD_DT       date;
  l_typ_cd               varchar2(30);
  l_ENRT_PERD_STRT_DT    date;
  l_procd_dt             date;    --  22-Jun-01        bwharton       115.31
  l_enrt_perd_strt_dt_cd  varchar2(100);
  l_enrt_perd_strt_dt_rl  varchar2(100);
  l_enrt_perd_strt_days   number ;
  l_enrt_strt_dt          date;
  l_pen_max_esd           c_pen_max_esd%rowtype;
  l_effective_start_date  date;
  l_effective_end_date    date;


  --
begin
  --
  hr_utility.set_location ('Entering '||l_proc,10);
  hr_utility.set_location ('p_ler_id '||p_ler_id,10);
  hr_utility.set_location ('p_pgm_id '||p_pgm_id,10);
  hr_utility.set_location ('p_pl_id '||p_pl_id,10);
  hr_utility.set_location ('p_oipl_id '||p_oipl_id,10);
  --
  -- Bug 5642702
  -- If person is de-enroling at Program level then set variable G_DENROLING_FROM_PGM
  -- so that we can obviate calls that create/update records in BEN_BNFT_PRVDD_LDGR_F table
  -- See bebplapi.pkb for use of this variable
  --
  if p_oipl_id is null and p_pl_id is null and p_pgm_id is not null
  then
    --
    g_denroling_from_pgm := 'Y';
    --
  else
    --
    g_denroling_from_pgm := 'N';
    --
  end if;
  --
  hr_utility.set_location ('g_denroling_from_pgm = ' || g_denroling_from_pgm, 15);
  --
  --
  -- Bug#3279350 - undelete the prtt_enrt_rslt deenrolled in the future for OSB
  -- Bug# 3507652 - Added "p_ler_id = ben_manage_life_events.g_ler_id" to delete future end-dated enrollments
  --                when running in 'Unrestricted Mode' as well.
  if ((p_ler_id is null) or (p_ler_id = ben_manage_life_events.g_ler_id)) then
    --
    hr_utility.set_location ('undelete prtt_enrt_rslts',10);
    if p_oipl_id is not null then
       for l_pen in c_pen_oipl_2 loop
         -- call undelete
         open c_pen_max_esd(l_pen.prtt_enrt_rslt_id);
         fetch c_pen_max_esd into l_pen_max_esd;
         if c_pen_max_esd%found then
           ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => l_pen.prtt_enrt_rslt_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_pen_max_esd.object_version_number,
               p_effective_date          => l_pen_max_esd.effective_end_date,
               p_datetrack_mode          => hr_api.g_future_change,
               p_multi_row_validate      => FALSE);
         end if;
         close c_pen_max_esd;

       end loop;
    elsif p_pl_id is not null then
       for l_pen in c_pen_pl_2 loop
        -- call undelete
         open c_pen_max_esd(l_pen.prtt_enrt_rslt_id);
         fetch c_pen_max_esd into l_pen_max_esd;
         if c_pen_max_esd%found then
           ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => l_pen.prtt_enrt_rslt_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_pen_max_esd.object_version_number,
               p_effective_date          => l_pen_max_esd.effective_end_date,
               p_datetrack_mode          => hr_api.g_future_change,
               p_multi_row_validate      => FALSE);
         end if;
         close c_pen_max_esd;
         --
       end loop;
    elsif p_pgm_id is not null then
       for l_pen in c_pen_pgm_2 loop
         --
         open c_pen_max_esd(l_pen.prtt_enrt_rslt_id);
         fetch c_pen_max_esd into l_pen_max_esd;
         if c_pen_max_esd%found then
           ben_prtt_enrt_result_api.delete_prtt_enrt_result
              (p_validate                => false,
               p_prtt_enrt_rslt_id       => l_pen.prtt_enrt_rslt_id,
               p_effective_start_date    => l_effective_start_date,
               p_effective_end_date      => l_effective_end_date,
               p_object_version_number   => l_pen_max_esd.object_version_number,
               p_effective_date          => l_pen_max_esd.effective_end_date,
               p_datetrack_mode          => hr_api.g_future_change,
               p_multi_row_validate      => FALSE);
         end if;
         close c_pen_max_esd;
         --
       end loop;
    end if;
    --
  end if;
  -- Attempt to get the active per in ler id for the person
  --
  if p_ler_id is not null then
    --
    -- check whether ler_id is of type unrestricted
    if p_ler_id = ben_manage_life_events.g_ler_id then
    --
      l_per_in_ler_id := benutils.get_per_in_ler_id
                          (p_person_id         => p_person_id,
                           p_business_group_id => p_business_group_id,
                           p_ler_id            => p_ler_id,
                           p_lf_event_mode     => 'U',
                           p_effective_date    => p_effective_date);
    else
    --
      l_per_in_ler_id := benutils.get_per_in_ler_id
                          (p_person_id         => p_person_id,
                           p_business_group_id => p_business_group_id,
                           p_ler_id            => p_ler_id,
                           p_effective_date    => p_effective_date);
  hr_utility.set_location('l_typ_cd ='||l_typ_cd,10.5);
    --
    end if;
    --
    hr_utility.set_location('l_per_in_ler_id '||l_per_in_ler_id,10);
    --
  end if;
  --
  open c_per_in_ler;
  fetch c_per_in_ler into l_lf_evt_ocrd_dt, l_typ_cd;
  close c_per_in_ler;
  hr_utility.set_location('l_typ_cd ='||l_typ_cd,11.5);
  -- Get enrt_perd_id from benmngle's parm list, if it exists.
  -- Enrt_perd_id is in benmngle's popl_enrt_typ_cycl_id field.
  ben_env_object.get(p_rec => l_env_rec);
  benutils.get_batch_parameters(p_benefit_action_id => l_env_rec.benefit_action_id
                                ,p_rec => l_benmngle_parm_rec);
  --
  --


  if l_benmngle_parm_rec.lf_evt_ocrd_dt is not null then

/*     l_param_lf_evt_ocrd_dt :=
           to_date(l_benmngle_parm_rec.lf_evt_ocrd_dt,'YYYY/MM/DD HH24:MI:SS');
      hr_utility.set_location('l_per_in_ler_id '||l_per_in_ler_id,11);
     l_param_lf_evt_ocrd_dt :=
           to_date(to_char(trunc(l_param_lf_evt_ocrd_dt),'DD/MM/RRRR'),'DD/MM/RRRR');
      l_param_lf_evt_ocrd_dt := to_date(l_benmngle_parm_rec.lf_evt_ocrd_dt);
*/
    --BUG 4046914
    l_param_lf_evt_ocrd_dt :=
       fnd_date.canonical_to_date(fnd_date.date_to_canonical(l_benmngle_parm_rec.lf_evt_ocrd_dt));


  end if;
  --
      hr_utility.set_location('l_per_in_ler_id '||l_per_in_ler_id,12);
  if p_oipl_id is not null then
    -- PB : 5422 :
    -- if l_benmngle_parm_rec.popl_enrt_typ_cycl_id is null then
    if l_param_lf_evt_ocrd_dt is null then
      --
      -- TM added for backport of 115.6
      --
      ben_comp_object.get_object(p_oipl_id => p_oipl_id,
                                 p_rec     => l_oipl_rec);
      --
    end if;

    for l_pen in c_pen_oipl loop
      --
      -- PB : 5422 :
      -- if l_benmngle_parm_rec.popl_enrt_typ_cycl_id is null then
      --
      l_enrt_perd_id := null;

      -- bug : 4645272 : when Open/Administartive runs in Life event mode, populate enrt_perd_id
      if l_param_lf_evt_ocrd_dt is null and l_typ_cd not in ('SCHEDDO','SCHEDDA') then
        l_lee_rsn_id:=null;

        open c_lee_rsn_pl(l_pen.pl_id);
        fetch c_lee_rsn_pl into l_lee_rsn_id,l_enrt_perd_strt_dt_cd,l_enrt_perd_strt_dt_rl, l_enrt_perd_strt_days;
        close c_lee_rsn_pl;
        if l_lee_rsn_id is null then
          open c_lee_rsn_pgm(l_pen.pgm_id);
          fetch c_lee_rsn_pgm into l_lee_rsn_id,l_enrt_perd_strt_dt_cd,l_enrt_perd_strt_dt_rl, l_enrt_perd_strt_days;
          close c_lee_rsn_pgm;
        end if;
        if l_enrt_perd_strt_dt_cd is not null then
            ben_determine_date.main(
               p_date_cd           => l_enrt_perd_strt_dt_cd,
               p_person_id         => p_person_id,
               p_per_in_ler_id     => l_per_in_ler_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_oipl_id           => p_oipl_id,
               p_business_group_id => p_business_group_id,
               p_formula_id        => l_enrt_perd_strt_dt_rl,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt,
               p_returned_date     => l_enrt_perd_strt_dt);

              if l_enrt_perd_strt_dt_cd in  ( 'NUMDOE', 'NUMDON','NUMDOEN') then
                 l_enrt_perd_strt_dt := l_enrt_perd_strt_dt + nvl(l_enrt_perd_strt_days,0) ;
              end if ;
        end if;
        --
        l_effective_date := least(nvl(l_lf_evt_ocrd_dt,p_effective_date), nvl(l_ENRT_PERD_STRT_DT,p_effective_date));-- 5257226 - 1;
         -- Enrollments were getting end-dated 2 days prior if passed eff_dt-1, passing the eff_dt now.

        hr_utility.set_location('l_effective_date '||l_effective_date,10);
      else
        --

        -- PB : 5422 :
        --
        OPEN c_sched_enrol_period_for_plan(l_pen.pl_id,
                                           nvl(l_param_lf_evt_ocrd_dt,l_lf_evt_ocrd_dt));  --bug 4645272
        FETCH c_sched_enrol_period_for_plan INTO l_enrt_perd_id,l_enrt_strt_dt;
        --
        IF c_sched_enrol_period_for_plan%NOTFOUND THEN
          --
          OPEN c_sched_enrol_period_for_pgm(l_pen.pgm_id,
                                            nvl(l_param_lf_evt_ocrd_dt,l_lf_evt_ocrd_dt));  --bug 4645272
          FETCH c_sched_enrol_period_for_pgm INTO l_enrt_perd_id,l_enrt_strt_dt;
          CLOSE c_sched_enrol_period_for_pgm;
          --
        END IF;
        CLOSE c_sched_enrol_period_for_plan;
        l_effective_date := least(nvl(l_lf_evt_ocrd_dt,p_effective_date), nvl(l_ENRT_STRT_DT,p_effective_date)); -- 5257226 - 1;
        --
      end if;
      --
      open  c_imptd(l_pen.pl_id);
      fetch c_imptd into l_imptd_incm_flag;
      if c_imptd%found then
         --
         l_imptd_incm_chg := true;
         --
      end if;
      close c_imptd;
      --
    /*
      ben_provider_pools.recompute_flex_credits(
         p_prtt_enrt_rslt_id   => l_pen.prtt_enrt_rslt_id,
         p_pgm_id              => l_pen.pgm_id,
         p_per_in_ler_id       => l_per_in_ler_id,
         p_person_id           => p_person_id,
         p_enrt_mthd_cd        => 'E',
         p_business_group_id   => p_business_group_id,
         p_effective_date      => p_effective_date);
      --
      ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd      => 'C',
             p_date_mandatory_flag => 'N',
             p_compute_dates_flag  => 'N',
             p_per_in_ler_id       => l_per_in_ler_id,
             p_person_id           => p_person_id,
             p_pgm_id              => l_pen.pgm_id,
             p_pl_id               => l_pen.pl_id,
             p_oipl_id             => l_pen.oipl_id,
             p_business_group_id   => p_business_group_id,
             p_enrt_cvg_strt_dt    => l_dummy_dt,
             p_enrt_cvg_strt_dt_cd => l_dummy_varchar,
             p_enrt_cvg_strt_dt_rl => l_dummy_num,
             p_rt_strt_dt          => l_dummy_dt,
             p_rt_strt_dt_cd       => l_dummy_varchar,
             p_rt_strt_dt_rl       => l_dummy_num,
             p_enrt_cvg_end_dt     => l_dummy_dt,
             p_enrt_cvg_end_dt_cd  => l_enrt_cvg_end_dt_cd,
             p_enrt_cvg_end_dt_rl  => l_dummy_num,
             p_rt_end_dt           => l_dummy_dt,
             p_rt_end_dt_cd        => l_dummy_varchar,
             p_rt_end_dt_rl        => l_dummy_num,
             p_effective_date      => p_effective_date,
             p_lf_evt_ocrd_dt      => null,
             p_lee_rsn_id          => l_lee_rsn_id
            );
       --
       if substr(nvl(l_enrt_cvg_end_dt_cd, '-1'), 1, 1) = 'W' then
         --
         l_ovn := l_pen.object_version_number;
         --
         dt_api.find_dt_upd_modes
          (p_effective_date       => p_effective_date,
           p_base_table_name      => 'BEN_PRTT_ENRT_RSLT_F',
           p_base_key_column      => 'prtt_enrt_rslt_id',
           p_base_key_value       => l_pen.prtt_enrt_rslt_id,
           p_correction           => l_correction,
           p_update               => l_update,
           p_update_override      => l_update_override,
           p_update_change_insert => l_update_change_insert);
        --
        if l_update_override then
          --
          l_datetrack_mode := hr_api.g_update_override;
          --
        elsif l_update then
          --
          l_datetrack_mode := hr_api.g_update;
          --
        else
          --
          l_datetrack_mode := hr_api.g_correction;
          --
        end if;
        --
         ben_prtt_enrt_result_api.update_PRTT_ENRT_RESULT
            (p_validate              => false
            ,p_prtt_enrt_rslt_id     => l_pen.prtt_enrt_rslt_id
            ,p_effective_start_date  => l_eff_strt
            ,p_effective_end_date    => l_eff_end
            ,p_ler_id                => p_ler_id
            ,p_no_lngr_elig_flag     => 'Y'
            ,p_object_version_number => l_ovn
            ,p_per_in_ler_id         => l_per_in_ler_id
            ,p_effective_date        => p_effective_date
            ,p_datetrack_mode        => l_datetrack_mode
            ,p_multi_row_validate    => false
            );
      --
      else
      --
*/
      --
      --  22-Jun-01        bwharton       115.31
      l_procd_dt := l_effective_date;
      --
      -- CWB changes : First determine the typ_cd of current per in ler
      -- and look for only COMP typ per in ler's if current per in ler is
      -- Comp type.
      --
      if l_typ_cd = 'COMP' then
         --
         for procd_dt_rec in c_procd_dt_pil_cwb loop
             l_procd_dt := procd_dt_rec.procd_dt;
             exit;
         end loop;
         --
      else
         --
         for procd_dt_rec in c_procd_dt_pil loop
             l_procd_dt := procd_dt_rec.procd_dt;
             exit;
         end loop;
         --
      end if;
      -- Bug 2200139 for Override Case look at the pen esd also
      hr_utility.set_location('Effective Date'||l_effective_date,111);
      hr_utility.set_location('l_typ_cd ='||l_typ_cd,111);
      if l_pen.enrt_mthd_cd = 'O' then
        l_effective_date := greatest(l_effective_date,
                                     greatest(l_procd_dt,l_pen.effective_start_date + 1));
      else
        l_effective_date := greatest (l_effective_date, l_procd_dt);
      end if;
      --  if benmngle is in selection mode, no need to compute the effective date
      if l_benmngle_parm_rec.mode_cd = 'S'  or l_benmngle_parm_rec.mode_cd = 'U' or
           l_typ_cd = 'ABS' or l_typ_cd = 'GSP' or
            l_effective_date < l_pen.enrt_cvg_strt_dt then
      hr_utility.set_location('l_typ_cd ='||l_typ_cd,123);
         l_effective_date := p_effective_date;
      end if;
      -- Bug#2641545 - not to lose the per in ler of enrollment the result record should be
      -- datetrack updated with per in ler of ineligible life event
      if l_effective_date <= l_pen.effective_start_date and p_ler_id is not null then
         l_effective_date := l_pen.effective_start_date + 1;
      --bug#3279350
      elsif l_effective_date < l_pen.effective_start_date then
         l_effective_date := l_pen.effective_start_date;
      end if;

      hr_utility.set_location('Effective Date'||l_effective_date,111);
      --
      ben_provider_pools.recompute_flex_credits(
         p_prtt_enrt_rslt_id   => l_pen.prtt_enrt_rslt_id,
         p_pgm_id              => l_pen.pgm_id,
         p_per_in_ler_id       => l_per_in_ler_id,
         p_person_id           => p_person_id,
         p_enrt_mthd_cd        => 'E',
         p_business_group_id   => p_business_group_id,
         p_effective_date      => l_effective_date);
      --
      hr_utility.set_location(' BKKKK DELETING THE FUTURE CVG OIPL ',10);

      --
      /*
       if (l_per_in_ler_id IS NOT NULL) then

          ben_election_information.backout_future_coverage
                             (p_per_in_ler_id           => l_per_in_ler_id,
                              p_business_group_id       => p_business_group_id,
                              p_person_id               => p_person_id,
                              p_pgm_id                  => NVL(l_pen.pgm_id,p_pgm_id),
                              p_pl_id                   => p_pl_id,
                              p_lf_evt_ocrd_dt          => l_lf_evt_ocrd_dt,
                              p_effective_date          => p_effective_date,
                              p_prtt_enrt_rslt_id       => l_dummy_num   ) ;
       end if;
       */
       --

      ben_prtt_enrt_result_api.delete_enrollment
        (p_validate              => false ,
         p_prtt_enrt_rslt_id     => l_pen.prtt_enrt_rslt_id,
         p_per_in_ler_id         => l_per_in_ler_id,
         p_lee_rsn_id            => l_lee_rsn_id,
         -- PB : 5422
         p_enrt_perd_id          => l_enrt_perd_id, --  l_benmngle_parm_rec.popl_enrt_typ_cycl_id,
         p_business_group_id     => p_business_group_id ,
         p_effective_start_date  => l_eff_strt,
         p_effective_end_date    => l_eff_end,
         p_object_version_number => l_pen.object_version_number,
         p_effective_date        => l_effective_date,
         p_datetrack_mode        => 'DELETE',
         p_multi_row_validate    => false,
         p_source                => 'beninelg');
      --
      ben_prtt_enrt_result_api.g_enrollment_change := TRUE;
      --
--      end if;
      --
    end loop;
    --
  elsif p_pl_id is not null then
    for l_pen in c_pen_pl loop
      --
      -- PB : 5422
      l_enrt_perd_id := null; --bug 4645272
      -- bug : 4645272 : when Open/Administartive runs in Life event mode, populate enrt_perd_id
      if l_param_lf_evt_ocrd_dt is null and l_typ_cd not in ('SCHEDDO','SCHEDDA') then
      -- if l_benmngle_parm_rec.popl_enrt_typ_cycl_id is null then
        l_lee_rsn_id:=null;
        open c_lee_rsn_pl(l_pen.pl_id);
        fetch c_lee_rsn_pl into l_lee_rsn_id,l_enrt_perd_strt_dt_cd,l_enrt_perd_strt_dt_rl,l_enrt_perd_strt_days;
        close c_lee_rsn_pl;
        if l_lee_rsn_id is null then
          open c_lee_rsn_pgm(l_pen.pgm_id);
          fetch c_lee_rsn_pgm into l_lee_rsn_id,l_enrt_perd_strt_dt_cd,l_enrt_perd_strt_dt_rl,l_enrt_perd_strt_days;
          close c_lee_rsn_pgm;
        end if;
         if l_enrt_perd_strt_dt_cd is not null then
            ben_determine_date.main(
               p_date_cd           => l_enrt_perd_strt_dt_cd,
               p_person_id         => p_person_id,
               p_per_in_ler_id     => l_per_in_ler_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_oipl_id           => p_oipl_id,
               p_business_group_id => p_business_group_id,
               p_formula_id        => l_enrt_perd_strt_dt_rl,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt,
               p_returned_date     => l_enrt_perd_strt_dt);

              if l_enrt_perd_strt_dt_cd in  ( 'NUMDOE', 'NUMDON','NUMDOEN') then
                 l_enrt_perd_strt_dt := l_enrt_perd_strt_dt + nvl(l_enrt_perd_strt_days,0) ;
              end if ;

        end if;
        l_effective_date := least(nvl(l_lf_evt_ocrd_dt,p_effective_date), nvl(l_ENRT_PERD_STRT_DT,p_effective_date)); -- 5257226 - 1;

      else
        --
        -- PB : 5422 :
        --
        OPEN c_sched_enrol_period_for_plan(l_pen.pl_id,
                                           nvl(l_param_lf_evt_ocrd_dt,l_lf_evt_ocrd_dt)); --bug 4645272
        FETCH c_sched_enrol_period_for_plan INTO l_enrt_perd_id,l_enrt_strt_dt;
        --
        IF c_sched_enrol_period_for_plan%NOTFOUND THEN
          --
          OPEN c_sched_enrol_period_for_pgm(l_pen.pgm_id,
                                            nvl(l_param_lf_evt_ocrd_dt,l_lf_evt_ocrd_dt)); --bug 4645272
          FETCH c_sched_enrol_period_for_pgm INTO l_enrt_perd_id,l_enrt_strt_dt;
          CLOSE c_sched_enrol_period_for_pgm;
          --
        END IF;
        CLOSE c_sched_enrol_period_for_plan;
        l_effective_date := least(nvl(l_lf_evt_ocrd_dt,p_effective_date), nvl(l_ENRT_STRT_DT,p_effective_date)); -- 5257226 - 1;
        --
      end if;
      --
      open  c_imptd(l_pen.pl_id);
      fetch c_imptd into l_imptd_incm_flag;
      if c_imptd%found then
         --
         l_imptd_incm_chg := true;
         --
      end if;
      close c_imptd;
      --
/*
      ben_provider_pools.recompute_flex_credits(
         p_prtt_enrt_rslt_id   => l_pen.prtt_enrt_rslt_id,
         p_pgm_id              => l_pen.pgm_id,
         p_per_in_ler_id       => l_per_in_ler_id,
         p_person_id           => p_person_id,
         p_enrt_mthd_cd        => 'E',
         p_business_group_id   => p_business_group_id,
         p_effective_date      => p_effective_date);
      --
      ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd      => 'C',
             p_date_mandatory_flag => 'N',
             p_compute_dates_flag  => 'N',
             p_per_in_ler_id       => l_per_in_ler_id,
             p_person_id           => p_person_id,
             p_pgm_id              => l_pen.pgm_id,
             p_pl_id               => l_pen.pl_id,
             p_oipl_id             => l_pen.oipl_id,
             p_business_group_id   => p_business_group_id,
             p_enrt_cvg_strt_dt    => l_dummy_dt,
             p_enrt_cvg_strt_dt_cd => l_dummy_varchar,
             p_enrt_cvg_strt_dt_rl => l_dummy_num,
             p_rt_strt_dt          => l_dummy_dt,
             p_rt_strt_dt_cd       => l_dummy_varchar,
             p_rt_strt_dt_rl       => l_dummy_num,
             p_enrt_cvg_end_dt     => l_dummy_dt,
             p_enrt_cvg_end_dt_cd  => l_enrt_cvg_end_dt_cd,
             p_enrt_cvg_end_dt_rl  => l_dummy_num,
             p_rt_end_dt           => l_dummy_dt,
             p_rt_end_dt_cd        => l_dummy_varchar,
             p_rt_end_dt_rl        => l_dummy_num,
             p_effective_date      => p_effective_date,
             p_lf_evt_ocrd_dt      => null,
             p_lee_rsn_id          => l_lee_rsn_id
            );
       --
       hr_utility.set_location('Beninelg: cvg_end_dt_cd='||l_enrt_cvg_end_dt_cd,1067);
       if substr(nvl(l_enrt_cvg_end_dt_cd, '-1'), 1, 1) = 'W' then
         --
         l_ovn := l_pen.object_version_number;
         --
         hr_utility.set_location('Before updating enrt result ',10);
         hr_utility.set_location('p_effective_date '||p_effective_date,10);
         --
         dt_api.find_dt_upd_modes
          (p_effective_date       => p_effective_date,
           p_base_table_name      => 'BEN_PRTT_ENRT_RSLT_F',
           p_base_key_column      => 'prtt_enrt_rslt_id',
           p_base_key_value       => l_pen.prtt_enrt_rslt_id,
           p_correction           => l_correction,
           p_update               => l_update,
           p_update_override      => l_update_override,
           p_update_change_insert => l_update_change_insert);
         --
         if l_update_override then
           --
           l_datetrack_mode := hr_api.g_update_override;
           --
         elsif l_update then
           --
           l_datetrack_mode := hr_api.g_update;
           --
         else
           --
           l_datetrack_mode := hr_api.g_correction;
           --
         end if;
         --
         ben_prtt_enrt_result_api.update_PRTT_ENRT_RESULT
            (p_validate              => false
            ,p_prtt_enrt_rslt_id     => l_pen.prtt_enrt_rslt_id
            ,p_effective_start_date  => l_eff_strt
            ,p_effective_end_date    => l_eff_end
            ,p_ler_id                => p_ler_id
            ,p_no_lngr_elig_flag     => 'Y'
            ,p_object_version_number => l_ovn
            ,p_per_in_ler_id         => l_per_in_ler_id
            ,p_effective_date        => p_effective_date
            ,p_datetrack_mode        => l_datetrack_mode
            ,p_multi_row_validate    => false
            );
      --
      else
*/
        --
        --
        --  22-Jun-01        bwharton       115.31
        l_procd_dt := l_effective_date;
        --
        -- CWB changes : First determine the typ_cd of current per in ler
        -- and look for only COMP typ per in ler's if current per in ler is
        -- Comp type.
        --
        if l_typ_cd = 'COMP' then
           --
           for procd_dt_rec in c_procd_dt_pil_cwb loop
               l_procd_dt := procd_dt_rec.procd_dt;
               exit;
           end loop;
           --
        else
           --
           for procd_dt_rec in c_procd_dt_pil loop
               l_procd_dt := procd_dt_rec.procd_dt;
               exit;
           end loop;
           --
        end if;
      --
      -- Bug 2200139 for Override Case look at the pen esd also
      if l_pen.enrt_mthd_cd = 'O' then
        l_effective_date := greatest(l_effective_date,
                                     greatest(l_procd_dt,l_pen.effective_start_date + 1));
      else
        l_effective_date := greatest (l_effective_date, l_procd_dt);
      end if;
      --  if benmngle is in selection mode, no need to compute the effective date
      --  for absence life event also the effective date is not computed
        if l_benmngle_parm_rec.mode_cd = 'S' or l_benmngle_parm_rec.mode_cd = 'U' or
             l_typ_cd = 'ABS' or l_typ_cd = 'GSP' /*or
             l_effective_date < l_pen.enrt_cvg_strt_dt */ then  --Commented the condition for the bug 9030738
           l_effective_date := p_effective_date;
        end if;
      --
      --bug#3279350
      if l_effective_date <= l_pen.effective_start_date and p_ler_id is not null then
         l_effective_date := l_pen.effective_start_date + 1;
      elsif l_effective_date < l_pen.effective_start_date then
         l_effective_date := l_pen.effective_start_date;
      end if;
      --
      ben_provider_pools.recompute_flex_credits(
         p_prtt_enrt_rslt_id   => l_pen.prtt_enrt_rslt_id,
         p_pgm_id              => l_pen.pgm_id,
         p_per_in_ler_id       => l_per_in_ler_id,
         p_person_id           => p_person_id,
         p_enrt_mthd_cd        => 'E',
         p_business_group_id   => p_business_group_id,
         p_effective_date      => l_effective_date);
      --
      hr_utility.set_location('Effective Date'||l_effective_date,112);
      hr_utility.set_location(' BKKKK DELETING THE FUTURE CVG PLN ',10);
       --
      /*
       if (l_per_in_ler_id IS NOT NULL) then
          ben_election_information.backout_future_coverage
                             (p_per_in_ler_id       => l_per_in_ler_id,
                              p_business_group_id       => p_business_group_id,
                              p_person_id               => p_person_id,
                              p_pgm_id                  => NVL(l_pen.pgm_id,p_pgm_id),
                              p_pl_id                   => p_pl_id,
                              p_lf_evt_ocrd_dt          => l_lf_evt_ocrd_dt,
                              p_effective_date          => p_effective_date ,
                              p_prtt_enrt_rslt_id       => l_dummy_num ) ;
       end if;
      */
       --

        ben_prtt_enrt_result_api.delete_enrollment
        (p_validate              => false ,
         p_prtt_enrt_rslt_id     => l_pen.prtt_enrt_rslt_id,
         p_per_in_ler_id         => l_per_in_ler_id,
         p_lee_rsn_id            => l_lee_rsn_id,
         -- PB : 5422
         p_enrt_perd_id          => l_enrt_perd_id, -- l_benmngle_parm_rec.popl_enrt_typ_cycl_id ,
         p_business_group_id     => p_business_group_id ,
         p_effective_start_date  => l_eff_strt,
         p_effective_end_date    => l_eff_end,
         p_object_version_number => l_pen.object_version_number,
         p_effective_date        => l_effective_date,
         p_datetrack_mode        => 'DELETE',
         p_multi_row_validate    => false,
         p_source                => 'beninelg');
         --
         ben_prtt_enrt_result_api.g_enrollment_change := TRUE;
         --
         --  Check if we should terminate COBRA eligibility.
         --
         hr_utility.set_location('l_pen.pgm_id: '||l_pen.pgm_id,10);
         hr_utility.set_location('l_pen.ptip_id: '||l_pen.ptip_id,10);
         --
         if l_pen.pgm_id is not null
         then
             ben_comp_object.get_object(p_pgm_id => l_pen.pgm_id,
                                        p_rec    => l_pgm_rec);
               hr_utility.set_location('pgm_typ: '||l_pgm_rec.pgm_typ_cd,10);
             if l_pgm_rec.pgm_typ_cd like 'COBRA%' then
               hr_utility.set_location('pgm_typ: '||l_pgm_rec.pgm_typ_cd,10);
               ben_cobra_requirements.g_cobra_enrollment_change := TRUE;
             end if;
         end if;
      --
 --     end if;
      --
    end loop;
    --
  elsif p_pgm_id is not null then
    for l_pen in c_pen_pgm loop
      --
      l_enrt_perd_id:= null;  ---- bug : 4645272
      -- PB : 5422
      -- bug : 4645272 : when Open/Administartive runs in Life event mode, populate enrt_perd_id

      if l_param_lf_evt_ocrd_dt is null and l_typ_cd not in ('SCHEDDO','SCHEDDA') then

      -- if l_benmngle_parm_rec.popl_enrt_typ_cycl_id is null then
        l_lee_rsn_id:=null;

       open c_lee_rsn_pl(l_pen.pl_id);
        fetch c_lee_rsn_pl into l_lee_rsn_id,l_enrt_perd_strt_dt_cd,l_enrt_perd_strt_dt_rl,l_enrt_perd_strt_days;
        close c_lee_rsn_pl;
        if l_lee_rsn_id is null then
          open c_lee_rsn_pgm(l_pen.pgm_id);
          fetch c_lee_rsn_pgm into l_lee_rsn_id,l_enrt_perd_strt_dt_cd,l_enrt_perd_strt_dt_rl,l_enrt_perd_strt_days;
          close c_lee_rsn_pgm;
        end if;
         if l_enrt_perd_strt_dt_cd is not null then
            ben_determine_date.main(
               p_date_cd           => l_enrt_perd_strt_dt_cd,
               p_person_id         => p_person_id,
               p_per_in_ler_id     => l_per_in_ler_id,
               p_pgm_id            => p_pgm_id,
               p_pl_id             => p_pl_id,
               p_oipl_id           => p_oipl_id,
               p_business_group_id => p_business_group_id,
               p_formula_id        => l_enrt_perd_strt_dt_rl,
               p_effective_date    => p_effective_date,
               p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt,
               p_returned_date     => l_enrt_perd_strt_dt);

               if l_enrt_perd_strt_dt_cd in  ( 'NUMDOE', 'NUMDON','NUMDOEN') then
                 l_enrt_perd_strt_dt := l_enrt_perd_strt_dt + nvl(l_enrt_perd_strt_days,0) ;
              end if ;
        end if;
        l_effective_date := least(nvl(l_lf_evt_ocrd_dt,p_effective_date), nvl(l_ENRT_PERD_STRT_DT,p_effective_date)); -- 5257226 - 1;

      else
        --
        -- PB : 5422 :
	--
        OPEN c_sched_enrol_period_for_pgm(l_pen.pgm_id,
                                          nvl(l_param_lf_evt_ocrd_dt,l_lf_evt_ocrd_dt)); --bug 4645272

        FETCH c_sched_enrol_period_for_pgm INTO l_enrt_perd_id,l_enrt_strt_dt;
        CLOSE c_sched_enrol_period_for_pgm;
        --
        l_effective_date := least(nvl(l_lf_evt_ocrd_dt,p_effective_date), nvl(l_ENRT_STRT_DT,p_effective_date)); --5257226 - 1;
      end if;
      --
      open  c_imptd(l_pen.pl_id);
      fetch c_imptd into l_imptd_incm_flag;
      if c_imptd%found then
         --
         l_imptd_incm_chg := true;
         l_inelig_lvl_in_pgm := 'Y' ;
           --
      end if;
      close c_imptd;
      --
      -- MOVED to pass this date to ben_provider_pools.recompute_flex_credits aslo
      --  22-Jun-01        bwharton       115.31
      --
      l_procd_dt := l_effective_date;
      --
      -- CWB changes : First determine the typ_cd of current per in ler
      -- and look for only COMP typ per in ler's if current per in ler is
      -- Comp type.
      --
      if l_typ_cd = 'COMP' then
         --
         for procd_dt_rec in c_procd_dt_pil_cwb loop
             l_procd_dt := procd_dt_rec.procd_dt;
             exit;
         end loop;
         --
      else
         --
         for procd_dt_rec in c_procd_dt_pil loop
             l_procd_dt := procd_dt_rec.procd_dt;
             exit;
         end loop;
         --
      end if;
      -- Bug 2200139 for Override Case look at the pen esd also
      if l_pen.enrt_mthd_cd = 'O' then
        l_effective_date := greatest(l_effective_date,
                                     greatest(l_procd_dt,l_pen.effective_start_date + 1));
      else
        l_effective_date := greatest (l_effective_date, l_procd_dt);
      end if;

      --  if benmngle is in selection mode, no need to compute the effective date
      if l_benmngle_parm_rec.mode_cd = 'S' or l_benmngle_parm_rec.mode_cd = 'U' or
            l_typ_cd = 'ABS' or l_typ_cd = 'GSP' or
            l_effective_date < l_pen.enrt_cvg_strt_dt then
         l_effective_date := p_effective_date;
      end if;
      --
      --bug#3279350
      if l_effective_date <= l_pen.effective_start_date and p_ler_id is not null then
         l_effective_date := l_pen.effective_start_date + 1;
      elsif l_effective_date < l_pen.effective_start_date then
         l_effective_date := l_pen.effective_start_date;
      end if;
      --
      ben_provider_pools.recompute_flex_credits(
         p_prtt_enrt_rslt_id   => l_pen.prtt_enrt_rslt_id,
         p_pgm_id              => l_pen.pgm_id,
         p_per_in_ler_id       => l_per_in_ler_id,
         p_person_id           => p_person_id,
         p_enrt_mthd_cd        => 'E',
         p_business_group_id   => p_business_group_id,
         p_effective_date      => l_effective_date ); -- p_effective_date);
      --
    /*
      ben_determine_date.rate_and_coverage_dates
            (p_which_dates_cd      => 'C',
             p_date_mandatory_flag => 'N',
             p_compute_dates_flag  => 'N',
             p_per_in_ler_id       => l_per_in_ler_id,
             p_person_id           => p_person_id,
             p_pgm_id              => l_pen.pgm_id,
             p_pl_id               => l_pen.pl_id,
             p_oipl_id             => l_pen.oipl_id,
             p_business_group_id   => p_business_group_id,
             p_enrt_cvg_strt_dt    => l_dummy_dt,
             p_enrt_cvg_strt_dt_cd => l_dummy_varchar,
             p_enrt_cvg_strt_dt_rl => l_dummy_num,
             p_rt_strt_dt          => l_dummy_dt,
             p_rt_strt_dt_cd       => l_dummy_varchar,
             p_rt_strt_dt_rl       => l_dummy_num,
             p_enrt_cvg_end_dt     => l_dummy_dt,
             p_enrt_cvg_end_dt_cd  => l_enrt_cvg_end_dt_cd,
             p_enrt_cvg_end_dt_rl  => l_dummy_num,
             p_rt_end_dt           => l_dummy_dt,
             p_rt_end_dt_cd        => l_dummy_varchar,
             p_rt_end_dt_rl        => l_dummy_num,
             p_effective_date      => p_effective_date,
             p_lf_evt_ocrd_dt      => null,
             p_lee_rsn_id          => l_lee_rsn_id
            );
       --
       hr_utility.set_location('Before updating enrt result ',10);
       hr_utility.set_location('p_effective_date '||p_effective_date,10);
       --
       if substr(nvl(l_enrt_cvg_end_dt_cd, '-1'), 1, 1) = 'W' then
         --
         l_ovn := l_pen.object_version_number;
         --
         dt_api.find_dt_upd_modes
          (p_effective_date       => p_effective_date,
           p_base_table_name      => 'BEN_PRTT_ENRT_RSLT_F',
           p_base_key_column      => 'prtt_enrt_rslt_id',
           p_base_key_value       => l_pen.prtt_enrt_rslt_id,
           p_correction           => l_correction,
           p_update               => l_update,
           p_update_override      => l_update_override,
           p_update_change_insert => l_update_change_insert);
         --
         if l_update_override then
           --
           l_datetrack_mode := hr_api.g_update_override;
           --
         elsif l_update then
           --
           l_datetrack_mode := hr_api.g_update;
           --
         else
           --
           l_datetrack_mode := hr_api.g_correction;
           --
         end if;
         --
hr_utility.set_location('pen_id='||l_pen.prtt_enrt_rslt_id,1963);
         ben_prtt_enrt_result_api.update_PRTT_ENRT_RESULT
            (p_validate              => false
            ,p_prtt_enrt_rslt_id     => l_pen.prtt_enrt_rslt_id
            ,p_effective_start_date  => l_eff_strt
            ,p_effective_end_date    => l_eff_end
            ,p_ler_id                => p_ler_id
            ,p_no_lngr_elig_flag     => 'Y'
            ,p_object_version_number => l_ovn
            ,p_per_in_ler_id         => l_per_in_ler_id
            ,p_effective_date        => p_effective_date
            ,p_datetrack_mode        => l_datetrack_mode
            ,p_multi_row_validate    => false
            );
      --
      else
      --
*/
      --
/* Moved to up use this for ben_provider_pools.recompute_flex_credits also
      --  22-Jun-01        bwharton       115.31
      l_procd_dt := l_effective_date;
      --
      -- CWB changes : First determine the typ_cd of current per in ler
      -- and look for only COMP typ per in ler's if current per in ler is
      -- Comp type.
      --
      if l_typ_cd = 'COMP' then
         --
         for procd_dt_rec in c_procd_dt_pil_cwb loop
             l_procd_dt := procd_dt_rec.procd_dt;
             exit;
         end loop;
         --
      else
         --
         for procd_dt_rec in c_procd_dt_pil loop
             l_procd_dt := procd_dt_rec.procd_dt;
             exit;
         end loop;
         --
      end if;
      --
      -- Bug 2200139 for Override Case look at the pen esd also
      if l_pen.enrt_mthd_cd = 'O' then
        l_effective_date := greatest(l_effective_date,
                                     greatest(l_procd_dt,l_pen.effective_start_date + 1 ));
      else
        l_effective_date := greatest (l_effective_date, l_procd_dt);
      end if;

      --  if benmngle is in selection mode, no need to compute the effective date
      if l_benmngle_parm_rec.mode_cd = 'S' or l_benmngle_parm_rec.mode_cd = 'U' or
           l_typ_cd = 'ABS' or l_typ_cd = 'GSP' or
            l_effective_date < l_pen.enrt_cvg_strt_dt then
         l_effective_date := p_effective_date;
      end if;
 */


      hr_utility.set_location('Effective Date'||l_effective_date,113);
      --
      hr_utility.set_location(' BKKKK DELETING THE FUTURE CVG PGM ',10);
      --
      /*
       if (l_per_in_ler_id IS NOT NULL) then
          ben_election_information.backout_future_coverage
                             (p_per_in_ler_id       => l_per_in_ler_id,
                              p_business_group_id       => p_business_group_id,
                              p_person_id               => p_person_id,
                              p_pgm_id                  => p_pgm_id,
                              p_pl_id                   => p_pl_id,
                              p_lf_evt_ocrd_dt          => l_lf_evt_ocrd_dt,
                              p_effective_date          => p_effective_date ,
                              p_prtt_enrt_rslt_id       => l_dummy_num ) ;
       end if;
       */
       --

      ben_prtt_enrt_result_api.delete_enrollment
        (p_validate              => false ,
         p_prtt_enrt_rslt_id     => l_pen.prtt_enrt_rslt_id,
         p_per_in_ler_id         => l_per_in_ler_id,
         p_lee_rsn_id            => l_lee_rsn_id,
         -- PB : 5422
         p_enrt_perd_id          => l_enrt_perd_id, -- l_benmngle_parm_rec.popl_enrt_typ_cycl_id
         p_business_group_id     => p_business_group_id ,
         p_effective_start_date  => l_eff_strt,
         p_effective_end_date    => l_eff_end,
         p_object_version_number => l_pen.object_version_number,
         p_effective_date        => l_effective_date,
         p_datetrack_mode        => 'DELETE',
         p_multi_row_validate    => FALSE,
         p_source                => 'beninelg');
         --
         ben_prtt_enrt_result_api.g_enrollment_change := TRUE;
         --
      --
      --  Check if we should terminate COBRA eligibility.
      --
      hr_utility.set_location('p_pgm_id: '||p_pgm_id,10);
      hr_utility.set_location('l_pen.ptip_id: '||l_pen.ptip_id,10);
      --
      ben_comp_object.get_object(p_pgm_id => p_pgm_id,
                                 p_rec    => l_pgm_rec);
           hr_utility.set_location('pgm_typ: '||l_pgm_rec.pgm_typ_cd,10);
      if l_pgm_rec.pgm_typ_cd like 'COBRA%' then
        hr_utility.set_location('pgm_typ: '||l_pgm_rec.pgm_typ_cd,20);
        ben_cobra_requirements.g_cobra_enrollment_change := TRUE;
      end if;
      --
 --     end if;
      --
    end loop;
    --
  end if;
  --
  if l_imptd_incm_chg then
     --
     if l_inelig_lvl_in_pgm <> 'Y' then
         ben_det_imputed_income.p_comp_imputed_income(
            p_person_id         => p_person_id,
            p_enrt_mthd_cd      => 'E',
            p_business_group_id => p_business_group_id,
            p_per_in_ler_id     => l_per_in_ler_id,
            p_effective_date    => p_effective_date,
            p_ctrlm_fido_call   => false,
            p_validate          => false,
            p_no_choice_flag    => true);
      end if ;
     --
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
end main;
--
end ben_newly_ineligible;

/
