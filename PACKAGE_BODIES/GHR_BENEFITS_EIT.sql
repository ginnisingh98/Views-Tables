--------------------------------------------------------
--  DDL for Package Body GHR_BENEFITS_EIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_BENEFITS_EIT" AS
/* $Header: ghbenenr.pkb 120.0.12010000.4 2008/10/17 11:02:33 vmididho ship $ */
PROCEDURE ghr_benefits_fehb
(errbuf                  OUT NOCOPY      VARCHAR2,
retcode                 OUT NOCOPY      NUMBER,
p_person_id per_all_people_f.person_id%type,
p_effective_date VARCHAR2,
p_business_group_id per_all_people_f.business_group_id%type,
p_pl_code ben_pl_f.short_code%type,
p_opt_code ben_opt_f.short_code%type,
p_pre_tax varchar2,
p_assignment_id per_all_assignments_f.assignment_id%type,
p_temps_total_cost varchar2,
p_temp_appt varchar2 default 'N')
IS
-- Cursor to get Program
 CURSOR c_get_pgm_id(c_prog_name ben_pgm_f.name%type, c_business_group_id ben_pgm_f.business_group_id%type,
			c_effective_date ben_pgm_f.effective_start_date%type) is
    SELECT pgm.pgm_id
    FROM   ben_pgm_f pgm
    WHERE  pgm.name = c_prog_name
    AND    pgm.business_group_id  = c_business_group_id
    AND    c_effective_date between effective_start_date and effective_end_date;

 CURSOR c_emp_in_ben(c_person_id ben_prtt_enrt_rslt_f.person_id%type, c_pgm_id ben_prtt_enrt_rslt_f.pgm_id%type,
		     c_effective_date ben_pgm_f.effective_start_date%type) is
    SELECT 1
    FROM   ben_prtt_enrt_rslt_f
    WHERE  person_id = c_person_id
    AND    pgm_id    = c_pgm_id
    AND    prtt_enrt_rslt_stat_cd IS NULL
    AND    c_effective_date between effective_start_date and effective_end_date;

  --Cursor to get the Plan Type Id for the given  Business_group_id
 CURSOR c_get_pl_typ_id(c_plan_type ben_pl_typ_f.name%type, c_business_group_id ben_pgm_f.business_group_id%type,
			c_effective_date ben_pgm_f.effective_start_date%type) is
SELECT plt.pl_typ_id
FROM   ben_pl_typ_f plt
WHERE  plt.name =  c_plan_type -- 'Savings Plan'
AND    plt.business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

CURSOR  get_ptip_id(c_plan_type_id ben_ptip_f.pl_typ_id%type, c_pgm_id ben_ptip_f.pgm_id%type,
	c_effective_date ben_pgm_f.effective_start_date%type) is
 SELECT ptip_id
 FROM   ben_ptip_f
 WHERE  pl_typ_id = c_plan_type_id
 AND    pgm_id = c_pgm_id
 AND    c_effective_date between effective_start_date and effective_end_date;

CURSOR get_pl_id(c_health_plan ben_pl_f.short_code%type, c_business_group_id ben_pgm_f.business_group_id%type,
		c_effective_date ben_pgm_f.effective_start_date%type) is
 SELECT pln.pl_id  pl_id
 FROM   ben_pl_f pln
 WHERE  pln.short_code = c_health_plan
 AND    pln.business_group_id = c_business_group_id
 AND    c_effective_date between effective_start_date and effective_end_date
 AND    pl_stat_cd = 'A';

--Cursor to get the opt_id for the EE's Enrollment Screen Entry Value
CURSOR get_opt_id(c_option_code ben_opt_f.short_code%type,  c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type) is
SELECT opt_id
FROM   ben_opt_f opt
WHERE  opt.short_code = c_option_code
AND    opt.business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

--Cursor to get the plan in Program Id for the given Pl_id
CURSOR get_plip_id(c_plan_id ben_plip_f.pl_id%type, c_pgm_id ben_plip_f.pgm_id%type, c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type) is
SELECT plip.plip_id
FROM   ben_plip_f plip
WHERE  plip.pl_id  =    c_plan_id
AND    plip.pgm_id = c_pgm_id
AND    plip.business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

 -- Cursor to get the option in plan Id

CURSOR get_oipl_id(c_pl_id ben_pl_f.pl_id%type, c_opt_id ben_opt_f.opt_id%type, c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type)  is
SELECT oipl_id
FROM   ben_oipl_f
WHERE  pl_id =  c_pl_id
AND    opt_id = c_opt_id
AND    business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

Cursor get_ler_id(c_life_event ben_ler_f.name%type, c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type) is
select ler.ler_id
from   ben_ler_f ler
where  ler.business_group_id = c_business_group_id
and    ler.name              = c_life_event
and    c_effective_date between effective_start_date and effective_end_date;

CURSOR get_elig_chc_id_opt(c_pgm_id ben_pgm_f.pgm_id%type, c_pl_typ_id ben_pl_typ_f.pl_typ_id%type,
			c_pl_id ben_pl_f.pl_id%type, c_plip_id ben_plip_f.plip_id%type,
			c_ptip_id ben_ptip_f.ptip_id%type, c_oipl_id ben_oipl_f.oipl_id%type,
			c_ler_id ben_ler_f.ler_id%type, c_person_id per_all_people_f.person_id%type) IS
SELECT elig_per_elctbl_chc_id,
	pil.per_in_ler_id,
	prtt_enrt_rslt_id
FROM   ben_elig_per_ELCTBL_chc chc ,
	ben_per_in_ler pil
WHERE chc.pgm_id = c_pgm_id
AND   chc.pl_typ_id = c_pl_typ_id
AND   chc.pl_id = c_pl_id
AND   chc.plip_id = c_plip_id
AND   chc.ptip_id = c_ptip_id
AND   chc.oipl_id = c_oipl_id
AND   pil.per_in_ler_id = chc.per_in_ler_id
AND   pil.ler_id  = c_ler_id
AND   pil.person_id = c_person_id
AND   PER_IN_LER_STAT_CD NOT IN ('BCKDT','PROCD');

       Cursor get_elig_chc_id(c_pgm_id ben_pgm_f.pgm_id%type, c_pl_typ_id ben_pl_typ_f.pl_typ_id%type,
			c_pl_id ben_pl_f.pl_id%type, c_plip_id ben_plip_f.plip_id%type,
			c_ptip_id ben_ptip_f.ptip_id%type,
			c_ler_id ben_ler_f.ler_id%type, c_person_id per_all_people_f.person_id%type) is
         select elig_per_elctbl_chc_id,
                pil.per_in_ler_id,
		prtt_enrt_rslt_id
         from   ben_elig_per_ELCTBL_chc chc ,
                ben_per_in_ler pil
         where chc.pgm_id = c_pgm_id
         and   chc.pl_typ_id = c_pl_typ_id
         and   chc.pl_id = c_pl_id
         and   chc.plip_id = c_plip_id
         and   chc.ptip_id = c_ptip_id
         and   pil.per_in_ler_id = chc.per_in_ler_id
         and   pil.ler_id  = c_ler_id
         and   pil.person_id = c_person_id
	 AND   PER_IN_LER_STAT_CD NOT IN ('BCKDT','PROCD');

Nothing_to_do EXCEPTION;
ben_enrt_exists EXCEPTION;

 l_exists BOOLEAN;
 l_person_id per_all_people_f.person_id%type ;
 l_effective_date date;
 l_warning boolean;
 l_business_group_id per_all_people_f.business_group_id%type;
 l_pl_code ben_pl_f.short_code%type ;
 l_opt_code ben_opt_f.short_code%type;
 l_pgm_id ben_pgm_f.pgm_id%type;
 l_err_msg varchar2(2000);
 l_pl_typ_id ben_pl_typ_f.pl_typ_id%type;
 l_ptip_id ben_ptip_f.ptip_id%type;
 l_pl_id ben_pl_f.pl_id%type;
 l_opt_id ben_opt_f.opt_id%type;
 l_plip_id ben_plip_f.plip_id%type;
 l_oipl_id ben_oipl_f.oipl_id%type;
 l_ler_id ben_ler_f.ler_id%type;
 l_ptnl_ler_for_per_id NUMBER;
 l_elig_per_elctbl_chc_id NUMBER;
 l_prtt_enrt_rslt_id number;
 l_per_in_ler_id NUMBER;
 l_ovn NUMBER;
 l_prog_count NUMBER;
 l_plan_count  NUMBER;
 l_oipl_count  NUMBER;
 l_person_count  NUMBER;
 l_plan_nip_count  NUMBER;
 l_oipl_nip_count  NUMBER;
 l_benefit_action_id NUMBER;
 l_errbuf varchar2(2000);
 l_retcode NUMBER;
l_enrt_bnft_id    NUMBER;
l_prtt_rt_val_id1  NUMBER;
l_prtt_rt_val_id2  NUMBER;
l_prtt_rt_val_id3  NUMBER;
l_prtt_rt_val_id4  NUMBER;
l_prtt_rt_val_id5  NUMBER;
l_prtt_rt_val_id6  NUMBER;
l_prtt_rt_val_id7  NUMBER;
l_prtt_rt_val_id8  NUMBER;
l_prtt_rt_val_id9  NUMBER;
l_prtt_rt_val_id10 NUMBER;
l_commit           NUMBER;
l_suspend_flag     varchar2(10);
l_esd  date;
l_eed  date;
l_prtt_enrt_interim_id number;
l_Boolean     BOOLEAN;
l_ses_exist BOOLEAN;
l_life_event VARCHAR2(100);
l_cvrg_st_dt  date;

cursor c_session(c_session_id fnd_sessions.session_id%type) IS
SELECT 1 FROM fnd_sessions
where session_id = c_session_id;

cursor c_get_ler_id is
select ler_id from ben_ptnl_ler_for_per
where business_group_id = p_business_group_id
and person_id = p_person_id
and ptnl_ler_for_per_stat_cd ='UNPROCD'
and ler_id not in (select ler_id from ben_ler_f where name
= 'Unrestricted' and business_group_id = p_business_group_id)
and LF_EVT_OCRD_DT  = l_effective_date;

cursor c_get_cvg_st_dt
    is
    select enrt_cvg_strt_dt
    from   ben_prtt_enrt_rslt_f
    where  prtt_enrt_rslt_id = l_prtt_enrt_rslt_id;



cursor c_get_unproc_lf_evt
    is
    select le.name
    from   ben_ptnl_ler_for_per ptnl,
           ben_ler_f le
    where  ptnl.business_group_id = p_business_group_id
    and    ptnl.person_id = p_person_id
    and    ptnl_ler_for_per_stat_cd ='UNPROCD'
    and    le.name <> 'Unrestricted'
    and    ptnl.ler_id = le.ler_id
    and    lf_evt_ocrd_dt < l_effective_date
    order by ptnl_ler_for_per_id;

cursor get_cur_enr(p_asg_id in NUMBER,
                      p_business_group_id in NUMBER,
		      p_effective_date in DATE)
    is
SELECT ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id, 'Enrollment', eef.effective_start_date) enrollment,
           eef.element_entry_id ,
	   eef.object_version_number
    FROM   pay_element_entries_f eef,
           pay_element_types_f elt
    WHERE  assignment_id = p_asg_id
    AND    elt.element_type_id = eef.element_type_id
    AND    eef.effective_start_date BETWEEN elt.effective_start_date  AND
           elt.effective_end_date
    AND    p_effective_date between eef.effective_start_date and eef.effective_end_date
    AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                                                                   p_business_group_id,
                                                                   p_effective_date))
              IN  ('HEALTH BENEFITS');

cursor c_get_cur_lf_evt(p_effective_date in date,
                        p_business_group_id in number,
			p_person_id in number)
    is
    select per_in_ler_id
    from   ben_per_in_ler pil,ben_ler_f lf
    where  pil.person_id = p_person_id
    and    pil.business_group_id = p_business_group_id
    and    pil.PER_IN_LER_STAT_CD in ('STRTD')
    and    lf.ler_id = pil.ler_id
    and    name <> 'Unrestricted'
    and    lf_evt_ocrd_dt <> p_effective_date
    and    p_effective_date between lf.effective_start_date and lf.effective_end_date;

cursor c_chk_asg_exists(p_effective_date in date)
    is
    select 1
    from   per_all_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    p_effective_date between asg.effective_start_date
                            and     asg.effective_end_date;


   l_object_version_number    pay_element_entries_f.object_version_number%type;
    l_effective_start_date     date;
    l_effective_end_date       date;
    l_exp_date                 date;
    l_delete_warning           boolean;
BEGIN

 l_person_id := p_person_id;
 l_effective_date := fnd_date.canonical_to_date(p_effective_date);
 l_business_group_id := p_business_group_id;
 l_pl_code := p_pl_code;
 l_opt_code := p_opt_code;

 dt_fndate.change_ses_date (p_ses_date      => TRUNC (SYSDATE),
                            p_commit        => l_commit
                           );

  -- Get Program ID
  FOR pgm_rec in c_get_pgm_id('Federal Employees Health Benefits', l_business_group_id, l_effective_date) LOOP -- Eff date and BG ID
      l_pgm_id := pgm_rec.pgm_id;
      EXIT;
  END LOOP;

  hr_utility.set_location('Program ID ' || l_pgm_id,1234);
  If l_pgm_id is null Then
     -- Raise Error message
     hr_utility.set_message_token('PROGRAM','Federal Employee Health Benefits program');
     hr_utility.set_message(8301,'GHR_38966_BEN_PRG_INVALID');
     hr_utility.raise_error;
  End If;

     -- Check if Person is already enrolled
    /*   l_exists := FALSE;
      for emp_ben_rec in c_emp_in_ben(l_person_id, l_pgm_id, l_effective_date) LOOP  -- Enter person id here...
        l_exists :=  TRUE;
         exit;
      end loop;

      If l_exists then
         Raise ben_enrt_exists;
       End If;    */

   For lf_evt_rec in c_get_cur_lf_evt(p_effective_date    => l_effective_date,
                                      p_business_group_id => l_business_group_id,
                     	              p_person_id         => l_person_id)
   Loop
      ben_close_enrollment.close_single_enrollment
                       (p_per_in_ler_id        => lf_evt_rec.per_in_ler_id
                       ,p_effective_date       => l_effective_date-1
                       ,p_business_group_id    => l_business_group_id
                       ,p_close_cd             => 'FORCE'
                       ,p_validate             => FALSE
                       ,p_close_uneai_flag     => NULL
                       ,p_uneai_effective_date => NULL);


    End Loop;


    hr_utility.set_location('person_id is ' || p_person_id,1235);
    hr_utility.set_location('l_effective_date is ' || p_effective_date,1236);
    hr_utility.set_location('business_group_id is ' || p_business_group_id,1237);

    --Check if person is having more than one life event
    -- in unprocessed status. If any other life event
    -- which is unprocessed need to be processed or voided
    -- for processing the current life event
    --   Unprocessed Life Event Exists
    For unproc_lf_evt in c_get_unproc_lf_evt
    Loop
      hr_utility.set_message(8301,'GHR_38519_UNPRC_LF_EVT');
      hr_utility.raise_error;
    End Loop;

    For ler_rec in c_get_ler_id loop
       l_ler_id := ler_rec.ler_id;
    End Loop;

   /* If l_ler_id is null then
       hr_utility.set_message(8301,'GHR_38520_NO_LFEVT_EXISTS');
       hr_utility.raise_error;
    End If;    */
IF l_ler_id is not null THEN
    hr_utility.set_location('Life event ID ' || l_ler_id,1234);

-- Calling BENMNGLE

ben_on_line_lf_evt.p_evt_lf_evts_from_benauthe(
        p_person_id             =>  l_person_id
       ,p_effective_date        => l_effective_date
       ,p_business_group_id     => l_business_group_id
       ,p_pgm_id                => l_pgm_id
 --    ,p_pl_id                 => l_pl_id -- No need. Commented by Venkat
       ,p_mode                  => 'L'
       ,p_popl_enrt_typ_cycl_id => null
       ,p_lf_evt_ocrd_dt        => l_effective_date
       ,p_prog_count            =>  l_prog_count
       ,p_plan_count            =>  l_plan_count
       ,p_oipl_count            =>  l_oipl_count
       ,p_person_count          =>  l_person_count
       ,p_plan_nip_count        =>  l_plan_nip_count
       ,p_oipl_nip_count        =>  l_oipl_nip_count
       ,p_ler_id                =>  l_ler_id
       ,p_errbuf                =>  l_errbuf
       ,p_retcode               =>  l_retcode);
      --

ben_on_line_lf_evt.p_proc_lf_evts_from_benauthe(
        p_person_id              => l_person_id
        ,p_effective_date        => l_effective_date
        ,p_business_group_id     => l_business_group_id
        ,p_mode                  => 'L'
        ,p_ler_id                => l_ler_id
        ,p_person_count          => l_person_count
        ,p_benefit_action_id     => l_benefit_action_id
        ,p_errbuf                => l_errbuf
        ,p_retcode               => l_retcode);

IF p_opt_code is not null and p_pl_code is not null THEN
  -- Get Plan type
  For plt_rec in c_get_pl_typ_id('Health Benefits', l_business_group_id, l_effective_date)
  Loop
     l_pl_typ_id := plt_rec.pl_typ_id;
     exit;
 End Loop;
 hr_utility.set_location('Plan type ID ' || l_pl_typ_id,1234);

 -- Get Plan type in Program ID
 For ptip_rec in get_ptip_id(l_pl_typ_id,l_pgm_id,l_effective_date)  loop
     l_ptip_id :=  ptip_rec.ptip_id;
 End Loop;
 hr_utility.set_location('Plan type in Prog ID ' || l_ptip_id,1234);

     -- Get Plan ID
 For pl_rec in get_pl_id(l_pl_code, l_business_group_id, l_effective_date)  loop
     l_pl_id := pl_rec.pl_id;
 End Loop;

 hr_utility.set_location('Plan ID ' || l_pl_id,1234);

 IF l_pl_id IS NULL THEN
    hr_utility.set_message_token('PLAN','Federal Employee Health Benefits plan ' || l_pl_code);
    hr_utility.set_message(8301,'GHR_38967_BEN_PLAN_INVALID');
    hr_utility.raise_error;
END IF;


-- Get Options ID
IF p_opt_code IS NOT NULL THEN

   If NVL(p_opt_code,hr_api.g_varchar2) NOT IN ('W','X','Y','Z')  then
      IF p_pre_tax = 'Y' THEN
 	l_opt_code := l_opt_code || 'A';
      ELSE
	l_opt_code := l_opt_code || 'P';
      END IF;
    END IF;

    For opt_rec in get_opt_id(l_opt_code, l_business_group_id, l_effective_date)
    Loop
	l_opt_id := opt_rec.opt_id;
    End Loop;

    hr_utility.set_location('Option ID ' || l_opt_id,1234);
    If l_opt_id IS NULL then
       hr_utility.set_location ('NO option found ',1234);
       hr_utility.set_message_token('OPTION','FEHB Option ' || l_opt_code);
       hr_utility.set_message(8301,'GHR_38967_BEN_PLAN_INVALID');
       hr_utility.raise_error;
    END IF;
  END IF;

  -- Get Plan in Program ID
  FOR  plip_id_rec in get_plip_id(l_pl_id, l_pgm_id, l_business_group_id, l_effective_date)  loop
       l_plip_id := plip_id_rec.plip_id;
  END LOOP;

  hr_utility.set_location('Plan in prog ID ' || l_plip_id,1234);
  -- get oipl_id
  IF l_opt_id IS NOT NULL THEN
     FOR oipl_id_rec in get_oipl_id(l_pl_id,l_opt_id ,l_business_group_id ,l_effective_date ) loop
         l_oipl_id := oipl_id_rec.oipl_id;
     END LOOP;
     IF l_oipl_id IS NULL THEN
        hr_utility.set_message_token('PROGRAM ','FEHB');
	hr_utility.set_message_token('PLAN_OPTION', l_pl_code || '/' || l_opt_code);
	hr_utility.set_message(8301,'GHR_38969_BEN_PLAN_OPT_INVALID');
	hr_utility.raise_error;
     END IF;
   ELSE
     l_oipl_id := null;
   END IF;

   hr_utility.set_location('Option in plan ID ' || l_oipl_id,1234);

   -- Create Potential Life event
   -- No need for this now... Need
/*

		IF p_temp_appt = 'Y' THEN
			l_life_event := 'Continued Coverage';
		ELSE
			l_life_event := 'Initial Opportunity to Enroll';
		END IF;

       for ler_rec in get_ler_id(l_life_event,l_business_group_id, l_effective_date) loop
              l_ler_id := ler_rec.ler_id;
        end loop;
*/

	--hr_utility.trace_off;

	hr_utility.set_location('l_ler_id ' || l_ler_id,1235);
	hr_utility.set_location('l_pgm_id ' || l_pgm_id,1235);
	hr_utility.set_location('l_pl_typ_id ' || l_pl_typ_id,1235);
	hr_utility.set_location('l_pl_id ' || l_pl_id,1235);
	hr_utility.set_location('l_plip_id ' || l_plip_id,1235);
	hr_utility.set_location('l_ptip_id ' || l_ptip_id,1235);
	hr_utility.set_location('l_oipl_id ' || l_oipl_id,1235);
	hr_utility.set_location('l_person_id ' || l_person_id,1235);
  If l_oipl_id is not null Then
     open get_elig_chc_id_opt(l_pgm_id , l_pl_typ_id , l_pl_id , l_plip_id ,
  		              l_ptip_id , l_oipl_id , l_ler_id , l_person_id) ;
     fetch get_elig_chc_id_opt into l_elig_per_elctbl_chc_id,l_per_in_ler_id,l_prtt_enrt_rslt_id;
     If get_elig_chc_id_opt%NOTFOUND then
        hr_utility.set_message_token('PLAN_OPT', l_pl_code || '/' || l_opt_code);
	hr_utility.set_message(8301,'GHR_38970_BEN_PLAN_INELIG');
	hr_utility.raise_error;
     End If;
  Else
     open get_elig_chc_id(l_pgm_id , l_pl_typ_id , l_pl_id , l_plip_id ,
  		          l_ptip_id , l_ler_id , l_person_id) ;
     fetch get_elig_chc_id into l_elig_per_elctbl_chc_id,l_per_in_ler_id,l_prtt_enrt_rslt_id;
     If get_elig_chc_id%NOTFOUND then
	hr_utility.set_message_token('PLAN_OPT', l_pl_code);
	hr_utility.set_message(8301,'GHR_38970_BEN_PLAN_INELIG');
	hr_utility.raise_error;
     End If;
  End If;


  -- Enrolling a person
  ben_election_information.election_information
        (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
        ,p_effective_date         => l_effective_date
        ,p_enrt_mthd_cd           => 'E'
        ,p_enrt_bnft_id           => l_enrt_bnft_id
        ,p_prtt_rt_val_id1        => l_prtt_rt_val_id1
        ,p_prtt_rt_val_id2        => l_prtt_rt_val_id2
        ,p_prtt_rt_val_id3        => l_prtt_rt_val_id3
        ,p_prtt_rt_val_id4        => l_prtt_rt_val_id4
        ,p_prtt_rt_val_id5        => l_prtt_rt_val_id5
        ,p_prtt_rt_val_id6        => l_prtt_rt_val_id6
        ,p_prtt_rt_val_id7        => l_prtt_rt_val_id7
        ,p_prtt_rt_val_id8        => l_prtt_rt_val_id8
        ,p_prtt_rt_val_id9        => l_prtt_rt_val_id9
        ,p_prtt_rt_val_id10       => l_prtt_rt_val_id10
        ,p_enrt_cvg_strt_dt       => l_effective_date
--        ,p_enrt_cvg_thru_dt       => NULL
        ,p_datetrack_mode         => 'INSERT'
        ,p_suspend_flag           => l_suspend_flag
        ,p_effective_start_date   => l_esd
        ,p_effective_end_date     => l_eed
        ,p_object_version_number  => l_ovn
        ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
        ,p_business_group_id      => l_business_group_id
        ,p_dpnt_actn_warning      => l_Boolean
        ,p_bnf_actn_warning       => l_Boolean
        ,p_ctfn_actn_warning      => l_Boolean
        );

   ben_proc_common_enrt_rslt.process_post_enrt_calls_w
			(p_validate               => 'N'
			,p_person_id              => l_person_id
			,p_per_in_ler_id          => l_per_in_ler_id
			,p_pgm_id                 => l_pgm_id
			,p_pl_id                  => l_pl_id
			,p_flx_cr_flag            => 'N'
			,p_enrt_mthd_cd           => 'E'
			,p_proc_cd                => null
		-- changed to N as it should not be closed immediately after enrollment
			,p_cls_enrt_flag          => 'N'
			,p_business_group_id      => l_business_group_id
			,p_effective_date         => l_effective_date);

   hr_utility.set_location('p_assignment_id'||p_assignment_id,1000);
   hr_utility.set_location('l_business_group_id'||l_business_group_id,1001);
   hr_utility.set_location('l_effective_date'||l_effective_date,1002);

   for cur_cvrg_st_dt in c_get_cvg_st_dt
   loop
       l_cvrg_st_dt :=  cur_cvrg_st_dt.enrt_cvg_strt_dt;
   end loop;

   for chk_asg_rec in  c_chk_asg_exists(p_effective_date => l_cvrg_st_dt)
   loop
      IF p_pre_tax = 'N' THEN
         ghr_element_api.process_sf52_element
		 (p_assignment_id        =>    p_assignment_id
		 ,p_element_name         =>    'Health Benefits Pre tax'
		 ,p_input_value_name3    =>    'Temps Total Cost'
		 ,p_value3               =>    p_temps_total_cost
		 ,p_effective_date       =>    l_cvrg_st_dt
		 ,p_process_warning      =>    l_warning
		 );
      ELSE
         ghr_element_api.process_sf52_element
		(p_assignment_id        =>    p_assignment_id
		,p_element_name         =>    'Health Benefits'
		,p_input_value_name3    =>    'Temps Total Cost'
		,p_value3               =>    p_temps_total_cost
		,p_effective_date       =>    l_cvrg_st_dt
		,p_process_warning      =>    l_warning
		);
       END IF;
   end loop;
END IF;
END IF;

EXCEPTION
WHEN ben_enrt_exists THEN
  errbuf := 'Enrollment already exists';
  retcode := 2;
WHEN Nothing_to_do THEN
  errbuf := l_err_msg;
  hr_utility.set_location('Error tsp: ' || l_err_msg,1234);
  retcode := 2;
WHEN OTHERS THEN
  errbuf := 'Err' || sqlcode || ' : ' || sqlerrm;
  hr_utility.set_location('Error tsp: ' || sqlerrm,1234);
  retcode := 2;
  hr_utility.raise_error;
END ghr_benefits_fehb;


PROCEDURE ghr_benefits_tsp
(errbuf                  OUT NOCOPY      VARCHAR2,
retcode                 OUT NOCOPY      NUMBER,
p_person_id per_all_people_f.person_id%type,
p_effective_date VARCHAR2,
p_business_group_id per_all_people_f.business_group_id%type,
p_tsp_status varchar2,
p_opt_name ben_opt_f.name%type,
p_opt_val number
)

IS
-- Cursor to get Program
 CURSOR c_get_pgm_id(c_prog_name ben_pgm_f.name%type, c_business_group_id ben_pgm_f.business_group_id%type,
			c_effective_date ben_pgm_f.effective_start_date%type) is
    SELECT pgm.pgm_id
    FROM   ben_pgm_f pgm
    WHERE  pgm.name = c_prog_name
    AND    pgm.business_group_id  = c_business_group_id
    AND    c_effective_date between effective_start_date and effective_end_date;

 CURSOR c_emp_in_ben(c_person_id ben_prtt_enrt_rslt_f.person_id%type, c_pgm_id ben_prtt_enrt_rslt_f.pgm_id%type,
		     c_effective_date ben_pgm_f.effective_start_date%type) is
    SELECT 1
    FROM   ben_prtt_enrt_rslt_f
    WHERE  person_id = c_person_id
    AND    pgm_id    = c_pgm_id
    AND    c_effective_date between effective_start_date and effective_end_date;

  --Cursor to get the Plan Type Id for the given  Business_group_id
 CURSOR c_get_pl_typ_id(c_plan_type ben_pl_typ_f.name%type, c_business_group_id ben_pgm_f.business_group_id%type,
			c_effective_date ben_pgm_f.effective_start_date%type) is
SELECT plt.pl_typ_id
FROM   ben_pl_typ_f plt
WHERE  plt.name =  c_plan_type -- 'Savings Plan'
AND    plt.business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

CURSOR  get_ptip_id(c_plan_type_id ben_ptip_f.pl_typ_id%type, c_pgm_id ben_ptip_f.pgm_id%type,
	c_effective_date ben_pgm_f.effective_start_date%type) is
 SELECT ptip_id
 FROM   ben_ptip_f
 WHERE  pl_typ_id = c_plan_type_id
 AND    pgm_id = c_pgm_id
 AND    c_effective_date between effective_start_date and effective_end_date;

CURSOR get_pl_id(c_pl_name ben_pl_f.name%type, c_business_group_id ben_pgm_f.business_group_id%type,
		c_effective_date ben_pgm_f.effective_start_date%type) is
 SELECT pln.pl_id  pl_id
 FROM   ben_pl_f pln
 WHERE  pln.name = c_pl_name
 AND    pln.business_group_id = c_business_group_id
 AND    c_effective_date between effective_start_date and effective_end_date;

--Cursor to get the opt_id for the EE's Enrollment Screen Entry Value
CURSOR get_opt_id(c_opt_name ben_opt_f.name%type,  c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type) is
SELECT opt_id
FROM   ben_opt_f opt
WHERE  opt.name = c_opt_name
AND    opt.business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

--Cursor to get the plan in Program Id for the given Pl_id
CURSOR get_plip_id(c_plan_id ben_plip_f.pl_id%type, c_pgm_id ben_plip_f.pgm_id%type, c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type) is
SELECT plip.plip_id
FROM   ben_plip_f plip
WHERE  plip.pl_id  =    c_plan_id
AND    plip.pgm_id = c_pgm_id
AND    plip.business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

 -- Cursor to get the option in plan Id

CURSOR get_oipl_id(c_pl_id ben_pl_f.pl_id%type, c_opt_id ben_opt_f.opt_id%type, c_business_group_id ben_pgm_f.business_group_id%type,
		  c_effective_date ben_pgm_f.effective_start_date%type)  is
SELECT oipl_id
FROM   ben_oipl_f
WHERE  pl_id =  c_pl_id
AND    opt_id = c_opt_id
AND    business_group_id = c_business_group_id
AND    c_effective_date between effective_start_date and effective_end_date;

CURSOR get_elig_chc_id_opt(c_pgm_id ben_pgm_f.pgm_id%type, c_pl_typ_id ben_pl_typ_f.pl_typ_id%type,
			c_pl_id ben_pl_f.pl_id%type, c_plip_id ben_plip_f.plip_id%type,
			c_ptip_id ben_ptip_f.ptip_id%type, c_oipl_id ben_oipl_f.oipl_id%type,
			c_person_id per_all_people_f.person_id%type) IS
SELECT elig_per_elctbl_chc_id,
	pil.per_in_ler_id
FROM   ben_elig_per_ELCTBL_chc chc ,
	ben_per_in_ler pil
WHERE chc.pgm_id = c_pgm_id
AND   chc.pl_typ_id = c_pl_typ_id
AND   chc.pl_id = c_pl_id
AND   chc.plip_id = c_plip_id
AND   chc.ptip_id = c_ptip_id
AND   chc.oipl_id = c_oipl_id
AND   pil.per_in_ler_id = chc.per_in_ler_id
--AND   pil.ler_id  = c_ler_id
AND   pil.person_id = c_person_id;

CURSOR  c_get_enrt_rt_id(c_elig_per_elctbl_chc_id  ben_enrt_rt.elig_per_elctbl_chc_id%type) is
SELECT enrt_rt_id
FROM   ben_enrt_rt
WHERE  elig_per_elctbl_chc_id = c_elig_per_elctbl_chc_id;

Nothing_to_do EXCEPTION;
ben_enrt_exists EXCEPTION;

 l_exists BOOLEAN;
 l_person_id per_all_people_f.person_id%type ;
 l_effective_date date;
 l_business_group_id per_all_people_f.business_group_id%type;
 l_pl_code ben_pl_f.short_code%type ;
 l_opt_name ben_opt_f.name%type;
 l_pgm_id ben_pgm_f.pgm_id%type;
 l_err_msg varchar2(2000);
 l_pl_typ_id ben_pl_typ_f.pl_typ_id%type;
 l_ptip_id ben_ptip_f.ptip_id%type;
 l_pl_id ben_pl_f.pl_id%type;
 l_opt_id ben_opt_f.opt_id%type;
 l_plip_id ben_plip_f.plip_id%type;
 l_oipl_id ben_oipl_f.oipl_id%type;
 l_ler_id ben_ler_f.ler_id%type;
 l_ptnl_ler_for_per_id NUMBER;
 l_elig_per_elctbl_chc_id NUMBER;
 l_prtt_enrt_rslt_id number;
 l_per_in_ler_id NUMBER;
 l_ovn NUMBER;
 l_prog_count NUMBER;
 l_plan_count  NUMBER;
 l_oipl_count  NUMBER;
 l_person_count  NUMBER;
 l_plan_nip_count  NUMBER;
 l_oipl_nip_count  NUMBER;
 l_benefit_action_id NUMBER;
 l_errbuf varchar2(2000);
 l_retcode NUMBER;
l_enrt_bnft_id    NUMBER;
l_prtt_rt_val_id1  NUMBER;
l_prtt_rt_val_id2  NUMBER;
l_prtt_rt_val_id3  NUMBER;
l_prtt_rt_val_id4  NUMBER;
l_prtt_rt_val_id5  NUMBER;
l_prtt_rt_val_id6  NUMBER;
l_prtt_rt_val_id7  NUMBER;
l_prtt_rt_val_id8  NUMBER;
l_prtt_rt_val_id9  NUMBER;
l_prtt_rt_val_id10 NUMBER;
l_commit           NUMBER;
l_suspend_flag     varchar2(10);
l_esd  date;
l_eed  date;
l_prtt_enrt_interim_id number;
l_Boolean     BOOLEAN;
l_ses_exist BOOLEAN;
l_enrt_rt_id ben_enrt_rt.enrt_rt_id%type;

cursor c_session(c_session_id fnd_sessions.session_id%type) IS
SELECT 1 FROM fnd_sessions
where session_id = c_session_id;

BEGIN

 l_person_id := p_person_id;
 l_effective_date := fnd_date.canonical_to_date(p_effective_date);
 l_business_group_id := p_business_group_id;
 l_opt_name := p_opt_name;

--	hr_utility.trace_on(null,'sundar');

 dt_fndate.change_ses_date (p_ses_date      => TRUNC (SYSDATE),
                            p_commit        => l_commit
                           );

 if l_effective_date < to_date('07/01/2005','MM/DD/YYYY') then
    l_effective_date := to_date('07/01/2005','MM/DD/YYYY');
 End If;

  -- Get Program ID
 FOR pgm_rec in c_get_pgm_id('Federal Thrift Savings Plan (TSP)', l_business_group_id, l_effective_date) LOOP -- Eff date and BG ID
     l_pgm_id := pgm_rec.pgm_id;
     EXIT;
 END LOOP;

 hr_utility.set_location('Program ID ' || l_pgm_id,1234);

 If l_pgm_id is null Then
   -- Raise Error message
    hr_utility.set_message_token('PROGRAM','Federal Thrift Savings Plan (TSP) program');
    hr_utility.set_message(8301,'GHR_38966_BEN_PRG_INVALID');
    hr_utility.raise_error;
 End If;

  -- Check if Person is already enrolled
  /*  l_exists := FALSE;
    FOR emp_ben_rec in c_emp_in_ben(l_person_id, l_pgm_id, l_effective_date) LOOP
      l_exists :=  TRUE;
      exit;
    END LOOP;

    IF l_exists THEN
      Raise ben_enrt_exists;
    END IF;  */

 -- Get Plan type
 FOR plt_rec in c_get_pl_typ_id('Savings Plan', l_business_group_id, l_effective_date) loop
     l_pl_typ_id := plt_rec.pl_typ_id;
     EXIT;
 END LOOP;
 hr_utility.set_location('Plan type ID ' || l_pl_typ_id,1234);

 -- Get Plan type in Program ID
 FOR ptip_rec in get_ptip_id(l_pl_typ_id,l_pgm_id,l_effective_date)  loop
     l_ptip_id :=  ptip_rec.ptip_id;
 END LOOP;
 hr_utility.set_location('Plan type in Prog ID ' || l_ptip_id,1234);

 -- Get Plan ID
 FOR pl_rec in get_pl_id('TSP', l_business_group_id, l_effective_date)  loop
     l_pl_id := pl_rec.pl_id;
 END LOOP;
 hr_utility.set_location('Plan ID ' || l_pl_id,1234);

 IF l_pl_id IS NULL THEN
    hr_utility.set_message_token('PLAN','Federal Thrift Savings Plan (TSP)');
    hr_utility.set_message(8301,'GHR_38967_BEN_PLAN_INVALID');
    hr_utility.raise_error;
 END IF;

 ben_on_line_lf_evt.p_manage_life_events(
           p_person_id             => l_person_id
          ,p_effective_date        => l_effective_date
          ,p_business_group_id     => l_business_group_id
          ,p_pgm_id                => l_pgm_id
          ,p_pl_id                 => l_pl_id
          ,p_mode                  => 'U'  -- Unrestricted
          ,p_prog_count            => l_prog_count
          ,p_plan_count            => l_plan_count
          ,p_oipl_count            => l_oipl_count
          ,p_person_count          => l_person_count
          ,p_plan_nip_count        => l_plan_nip_count
          ,p_oipl_nip_count        => l_oipl_nip_count
          ,p_ler_id                => l_ler_id
          ,p_errbuf                => l_errbuf
          ,p_retcode               => l_retcode);

If p_tsp_status is not null then
     IF p_tsp_status IN ('S','T') THEN
        l_opt_name := 'Terminate Contributions';
     END IF;

     -- Get Options ID
     FOR opt_rec in get_opt_id(l_opt_name, l_business_group_id, l_effective_date)  loop
	 l_opt_id := opt_rec.opt_id;
     END LOOP;

     hr_utility.set_location('Option ID ' || l_opt_id,1234);
     IF l_opt_id IS NULL THEN
       	 hr_utility.set_location ('NO option found ',1234);
	 hr_utility.set_message_token('OPTION','TSP Option ' || l_opt_name);
         hr_utility.set_message(8301,'GHR_38967_BEN_PLAN_INVALID');
	 hr_utility.raise_error;
     End If;

     -- Get Plan in Program ID
     FOR  plip_id_rec in get_plip_id(l_pl_id, l_pgm_id, l_business_group_id, l_effective_date)  loop
          l_plip_id := plip_id_rec.plip_id;
     END LOOP;

     hr_utility.set_location('Plan in prog ID ' || l_plip_id,1234);
    -- get oipl_id
     FOR oipl_id_rec in get_oipl_id(l_pl_id,l_opt_id ,l_business_group_id ,l_effective_date ) loop
	l_oipl_id := oipl_id_rec.oipl_id;
     END LOOP;
     IF l_oipl_id IS NULL THEN
	     hr_utility.set_message_token('PROGRAM ','TSP');
	     hr_utility.set_message_token('PLAN_OPTION', 'TSP' || '/' || l_opt_name);
	     hr_utility.set_message(8301,'GHR_38969_BEN_PLAN_OPT_INVALID');
	     hr_utility.raise_error;
     END IF;

     hr_utility.set_location('Option in plan ID ' || l_oipl_id,1234);

	/*(c_pgm_id ben_pgm_f.pgm_id%type, c_pl_typ_id ben_pl_typ_f.pl_typ_id%type,
			c_pl_id ben_pl_f.pl_id%type, c_plip_id ben_plip_f.plip_id%type,
			c_ptip_id ben_ptip_f.ptip_id%type, c_oipl_id ben_oipl_f.oipl_id%type,
			c_person_id per_all_people_f.person_id%type) */
      hr_utility.set_location('p_manage_life_events done' ,1234);
      for get_elig_chc_id in get_elig_chc_id_opt(l_pgm_id , l_pl_typ_id , l_pl_id , l_plip_id ,
	               		                 l_ptip_id , l_oipl_id , l_person_id)  loop
          l_elig_per_elctbl_chc_id := get_elig_chc_id.elig_per_elctbl_chc_id;
          l_per_in_ler_id := get_elig_chc_id.per_in_ler_id;
          exit;
      End Loop;
      hr_utility.set_location('l_elig_per_elctbl_chc_id ' || l_elig_per_elctbl_chc_id ,1234);

      If l_elig_per_elctbl_chc_id is null Then
 	 hr_utility.set_message(8301,'GHR_38971_BEN_TSP_INELIG');
	 hr_utility.raise_error;
      End If;

      for get_enrt_rt_id in c_get_enrt_rt_id(l_elig_per_elctbl_chc_id) loop
          l_enrt_rt_id := get_enrt_rt_id.enrt_rt_id;
          exit;
      End Loop;

      -- Enrolling a person
      ben_election_information.election_information
        (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
        ,p_effective_date         => l_effective_date
        ,p_enrt_mthd_cd           => 'E'
        ,p_enrt_bnft_id           => l_enrt_bnft_id
        ,p_enrt_rt_id1            => l_enrt_rt_id
        ,p_rt_val1                => p_opt_val
        ,p_rt_strt_dt1            => l_effective_date
        ,p_rt_end_dt1             => hr_api.g_eot
        ,p_prtt_rt_val_id1        => l_prtt_rt_val_id1
        ,p_prtt_rt_val_id2        => l_prtt_rt_val_id2
        ,p_prtt_rt_val_id3        => l_prtt_rt_val_id3
        ,p_prtt_rt_val_id4        => l_prtt_rt_val_id4
        ,p_prtt_rt_val_id5        => l_prtt_rt_val_id5
        ,p_prtt_rt_val_id6        => l_prtt_rt_val_id6
        ,p_prtt_rt_val_id7        => l_prtt_rt_val_id7
        ,p_prtt_rt_val_id8        => l_prtt_rt_val_id8
        ,p_prtt_rt_val_id9        => l_prtt_rt_val_id9
        ,p_prtt_rt_val_id10       => l_prtt_rt_val_id10
        ,p_enrt_cvg_strt_dt       => l_effective_date
--        ,p_enrt_cvg_thru_dt       => hr_api.g_eot
        ,p_datetrack_mode         => 'INSERT'
        ,p_suspend_flag           => l_suspend_flag
        ,p_effective_start_date   => l_esd
        ,p_effective_end_date     => l_eed
        ,p_object_version_number  => l_ovn
        ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
        ,p_business_group_id      => l_business_group_id
        ,p_dpnt_actn_warning      => l_Boolean
        ,p_bnf_actn_warning       => l_Boolean
        ,p_ctfn_actn_warning      => l_Boolean
        );

  END IF;

 --  hr_utility.trace_off;
EXCEPTION
WHEN ben_enrt_exists THEN
  null;
WHEN Nothing_to_do THEN
  hr_utility.set_location('Error tsp: ' || l_err_msg,1234);
  rollback;
WHEN OTHERS THEN
  errbuf := 'Err' || sqlcode || ' : ' || sqlerrm;
  hr_utility.set_location('Error tsp: ' || sqlerrm,1234);
  retcode := 2;
  hr_utility.raise_error;
END ghr_benefits_tsp;


END ghr_benefits_eit;

/
