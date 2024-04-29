--------------------------------------------------------
--  DDL for Package Body GHR_TSP_PLAN_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_TSP_PLAN_DESIGN" AS
/* $Header: ghtsppd.pkb 120.2 2006/10/24 18:25:08 bgarg noship $ */

--
-- Package Variables
--
   g_package varchar2(100) := 'ghr_tsp_plan_design.';

  Procedure create_tsp_program_and_plans (p_target_business_group_id in Number) is
--
      l_proc                        Varchar2(100);
      p_validate                    Number := 0;
      p_copy_entity_txn_id          Number;
      p_effective_date              Date;
      p_prefix_suffix_cd            Varchar2(2);
      p_prefix_suffix_text          Varchar2(2);
      p_reuse_object_flag           Varchar2(1);
      p_transaction_category_id     Number(15);
      l_effective_start_date        Date;
      l_effective_end_date          Date;
      Nothing_To_Do                 Exception;

--
      Cursor get_txn_category_id is
                   select transaction_category_id
                   from   pqh_transaction_categories
                   where  short_name = 'BEN_PDCPWZ';
      Cursor get_copy_txn_id is
                   select copy_entity_txn_id
                   from   pqh_copy_entity_txns
                   where  transaction_category_id = p_transaction_category_id
                   and    context_business_group_id = 0
                   and    display_name = 'GHR_TSP_SEED_PROGRAM_DESIGN';
     Cursor update_program_status is
         select * from ben_pgm_f
         where  name = 'Federal Thrift Savings Plan (TSP)'
         and    business_group_id = p_target_business_group_id;
--
 Begin
  l_proc := g_package||'create_tsp_program_and_plans';

   hr_utility.set_location('Entering:'|| g_package||l_proc, 5);

   Open get_txn_category_id;
   Fetch get_txn_category_id into p_transaction_category_id;
   hr_utility.trace('Transaction Category Id  :'|| p_transaction_category_id);
   hr_utility.set_location('Opening cursor get_copy_txn_id      '||l_proc, 10);
   --dbms_output.put_line('txn category id   '||p_transaction_category_id);

   Open get_copy_txn_id;
   fetch get_copy_txn_id into p_copy_entity_txn_id;
   If get_copy_txn_id%notfound  then
      Raise Nothing_to_do;
   End If;
   hr_utility.trace('Copy entity Txn. Id  :'|| p_copy_entity_txn_id);
   --dbms_output.put_line('copy_entity_txn_id  :'||p_copy_entity_txn_id );


   --   Set the variables
   p_effective_date            := to_date('12/31/2005','MM/DD//YYYY');
   p_prefix_suffix_cd          := null;
   p_prefix_suffix_text        := null;
   p_reuse_object_flag         := 'Y';

   BEN_PD_COPY_TO_BEN_five.g_ghr_mode := 'TRUE';

   --dbms_output.put_line('now calling..........');
   BEN_PD_COPY_TO_BEN_TWO.create_stg_to_ben_rows(p_validate,
                                                 p_copy_entity_txn_id,
                                                 p_effective_date,
                                                 p_prefix_suffix_text,
                                                 p_reuse_object_flag,
                                                 p_target_business_group_id,
                                                 p_prefix_suffix_cd);
   For i in update_program_status Loop
       ben_Program_api.update_program(
                p_pgm_id                   => i.pgm_id
                ,p_effective_start_date    => l_effective_start_date
                ,p_effective_end_date      => l_effective_end_date
                ,p_pgm_stat_cd             => 'A'
                ,p_object_version_number   => i.object_version_number
                ,p_effective_date          => i.effective_start_date
                ,p_datetrack_mode          => 'CORRECTION'
       );
   End Loop;

  If get_txn_category_id%ISOPEN then
     CLOSE get_txn_category_id;
  End If;
  If get_copy_txn_id%ISOPEN then
     CLOSE get_copy_txn_id;
  End If;
  hr_utility.set_location('Leaving  :'|| g_package||l_proc, 50);

  Exception
     When Nothing_to_do Then
       If get_txn_category_id%ISOPEN then
           CLOSE get_txn_category_id;
       End If;
       If get_copy_txn_id%ISOPEN then
           CLOSE get_copy_txn_id;
       End If;
       null;
     When others then
       If get_txn_category_id%ISOPEN then
           CLOSE get_txn_category_id;
       End If;
       If get_copy_txn_id%ISOPEN then
           CLOSE get_copy_txn_id;
       End If;
       hr_utility.set_location('Leaving  :'|| g_package||l_proc, 70);
       Raise;
  End create_tsp_program_and_plans;



  Procedure populate_tsp_plan_design (p_errbuf     OUT NOCOPY VARCHAR2,
                                      p_retcode    OUT NOCOPY NUMBER,
                                      p_target_business_group_id in Number) is

      Cursor check_pgm_exists is
             select 'Y' from ben_pgm_f
             where  name = 'Federal Thrift Savings Plan (TSP)'
             and    business_group_id = p_target_business_group_id;

      l_proc           varchar2(100);
      p_exists         Varchar2(1);
      l_err_msg        Varchar2(2000);
      Nothing_To_Do    Exception;


  Begin
      l_proc  := 'Populate_tsp_plan_design.';
      p_exists:= 'N';
      hr_utility.set_location('entering  :'|| g_package||l_proc, 10);
      hr_utility.trace('Business Group Id   ' ||p_target_business_group_id);
      Open check_pgm_exists;
      Fetch check_pgm_exists into p_exists;
      If check_pgm_exists%NOTFOUND Then
         p_exists := 'N';
      End If;
      If p_exists = 'Y' then
         Raise nothing_to_do;
      End If;

      savepoint  create_tsp_plan_design;
        --dbms_output.put_line('now starting plan design  ' ||p_target_business_group_id);
      create_tsp_program_and_plans(p_target_business_group_id);
      hr_utility.trace('After create_program_and_plans....');
      commit;
      If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
      End If;
      hr_utility.set_location('Leaving  :'|| g_package||l_proc, 50);
  Exception
     When Nothing_to_do Then
        If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
        End If;
        null;
     When others then
        If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
        End If;
       hr_utility.set_location('Leaving  :'|| g_package||l_proc, 60);
       hr_utility.trace('Error  ' ||sqlerrm(sqlcode));
       l_err_msg := substr(p_target_business_group_id||':'||nvl(fnd_message.get,sqlerrm),1,1999) ;
       rollback to create_tsp_plan_design;
       ghr_wgi_pkg.create_ghr_errorlog
          (p_program_name            =>  l_proc,
           p_log_text                =>  l_err_msg,
           p_message_name            =>  null,
           p_log_date                =>  sysdate
           );
       commit;
  End populate_tsp_plan_design;


  procedure tsp_continue_coverage (
                  p_person_id             in per_all_people_f.person_id%type,
                  p_business_group_id     in per_business_groups.business_group_id%type,
                  p_ler_id                in ben_ler_f.ler_id%type,
                  p_pgm_id                in ben_pgm_f.pgm_id%type,
                  p_effective_date        in Date ) is

   Nothing_To_Do             Exception;
   l_err_msg                 varchar2(2000);
   l_per_in_ler_id           number;
   l_exists                  boolean;
   l_elig_per_elctbl_chc_id number;
   l_term_ler_id             ben_ler_f.ler_id%type;
   l_rt_val                  number;
   l_enrt_rt_id              number;
   l_asg_id                  number;
   l_proc                    varchar2(100);

   /* output Vars needed for procedure election_information */
   l_esd                     date;
   l_eed                     date;
   l_prtt_enrt_interim_id    number;
   L_boolean                 boolean;

   l_suspend_flag            varchar2(30);
   l_ovn                     number;
   l_prtt_rt_val_id1         number;
   l_prtt_rt_val_id2         number;
   l_prtt_rt_val_id3         number;
   l_prtt_rt_val_id4         number;
   l_prtt_rt_val_id5         number;
   l_prtt_rt_val_id6         number;
   l_prtt_rt_val_id7         number;
   l_prtt_rt_val_id8         number;
   l_prtt_rt_val_id9         number;
   l_prtt_rt_val_id10        number;
   l_prtt_enrt_rslt_id       number;

   l_enrt_bnft_id            number;
   l_prtt_rt_val_id          number;

   /* output Vars needed for procedure p_evt_lf_evts_from benauthe */
   l_prog_count              number;
   l_plan_count              number;
   l_oipl_count              number;
   l_person_count            number;
   l_plan_nip_count          number;
   l_oipl_nip_count          number;
   l_ler_id                  number;
   l_retcode                 number;
   l_errbuf                  varchar2(2000);

   /* output Vars needed for procedure p_proc_lf_evts_from benauthe */
   l_benefit_action_id       number;

   -- to get old Employee contribution eligibility date
   l_element_name            Varchar2(50);
   l_input_value_name        Varchar2(50);

   --Out vars.
   l_effective_start_date    Date;
   l_effective_end_date      Date;
   l_elig_dt                 Date;
   l_element_entry_id        Number;
   l_object_version_number   Number;
   l_process_warning         Boolean;
   --
   l_val                     Varchar2(50);
   l_multi_error_flag        Boolean;
   l_old_asg_id              Number;
   l_new_asg_id              Number;




   -- Cursor to get Pgm_id for the given Business Group
   Cursor c_get_pgm_id is
     select pgm.pgm_id
     from   ben_pgm_f pgm
     where  pgm.name = 'Federal Thrift Savings Plan (TSP)'
     and    pgm.business_group_id  = p_business_group_id;

   -- Cursor to get ler id for "Termination of Appointment"
   Cursor c_get_ler_id is
      select ler_id
      from   ben_ler_f
      where  name = 'Termination of Appointment'
      and    business_group_id = p_business_group_id
      and    trunc(p_effective_date) between effective_start_date and effective_end_date;


-- Cursor to check if Employee has any open Benefits record for TSP
  Cursor c_emp_in_tsp is
    select 1
    from   ben_prtt_enrt_rslt_f
    where  person_id = p_person_id
    and    business_group_id  = p_business_group_id
    and    pgm_id = p_pgm_id
    and    enrt_cvg_thru_dt = hr_api.g_eot
    and    trunc(p_effective_date) between effective_start_date and effective_end_date
    and    prtt_enrt_rslt_stat_cd is null;

  -- Cursor to get last TSP benefit record for the person
  Cursor c_get_ee_last_tsp_enrt_rec is
    select pl_id,pl_typ_id,ptip_id,prtt_enrt_rslt_id,oipl_id
    from   ben_prtt_enrt_rslt_f
    where  person_id = p_person_id
    and    business_group_id  = p_business_group_id
    and    pgm_id = p_pgm_id
    and    ler_id = l_term_ler_id
    order by prtt_enrt_rslt_id desc;

  get_ee_last_tsp_enrt_rec      c_get_ee_last_tsp_enrt_rec%rowtype;

  Cursor c_get_prtt_rt_val is
  select rt_val
  from   ben_prtt_rt_val
  where  prtt_enrt_rslt_id = get_ee_last_tsp_enrt_rec.prtt_enrt_rslt_id
  order by prtt_rt_val_id desc;

  Cursor c_get_elig_chc_id is
    select elig_per_elctbl_chc_id,
           pil.per_in_ler_id
    from   ben_elig_per_ELCTBL_chc chc ,
           ben_per_in_ler pil
    where chc.pgm_id = p_pgm_id
    and   chc.pl_typ_id = get_ee_last_tsp_enrt_rec.pl_typ_id
    and   chc.pl_id = get_ee_last_tsp_enrt_rec.pl_id
    and   chc.oipl_id = get_ee_last_tsp_enrt_rec.oipl_id
    --and   chc.plip_id = l_plip_id
    and   chc.ptip_id = get_ee_last_tsp_enrt_rec.ptip_id
    and   pil.per_in_ler_id = chc.per_in_ler_id
    and   pil.ler_id  = p_ler_id
    and   pil.person_id = p_person_id;

  Cursor  c_get_enrt_rt_id is
    select enrt_rt_id
    from   ben_enrt_rt
    where  elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id;

  Cursor c_get_prev_asg_id is
     select assignment_id
     from   per_all_assignments_f
     where  person_id = p_person_id
     and    trunc (p_effective_date - 1) between effective_start_date and effective_end_date
     and    assignment_type = 'E';

BEGIN
  --dbms_output.put_line(' start ' ||p_effective_date);
  l_proc   := 'TSP Cont. Coverage';
  l_element_name  := 'TSP';
  l_input_value_name := 'Emp Contrib Elig Date';
  hr_utility.set_location('entering  :'|| g_package||l_proc, 10);
  hr_utility.trace('Person Id   ' ||p_person_id);
  l_err_msg := null;

  --Check if any current open record exists in the Ben table for this person and program
  hr_utility.set_location(l_proc, 20);
  l_exists := FALSE;
  for emp_in_tsp in c_emp_in_tsp loop
      --dbms_output.put_line('Data exists in Ben Table' );
      l_exists :=  TRUE;
      exit;
  end loop;
  If l_exists then
      --dbms_output.put_line('No Action' );
      l_err_msg := 'Person Id ' ||p_person_id ||' has open Benefits Enrollment record';
      Raise Nothing_to_do;
  End If;

  -- Get Ler Id  for 'Termination of Appointment' life event
  hr_utility.set_location(l_proc, 30);
  For get_ler_id in c_get_ler_id loop
      l_term_ler_id := get_ler_id.ler_id;
      Exit;
  End loop;

  hr_utility.set_location(l_proc, 40);
  open c_get_ee_last_tsp_enrt_rec;
  fetch c_get_ee_last_tsp_enrt_rec into get_ee_last_tsp_enrt_rec;
  --dbms_output.put_line('Plan id :' ||get_ee_last_tsp_enrt_rec.pl_id||'...pl_typ_id: '||get_ee_last_tsp_enrt_rec.pl_typ_id);
  If get_ee_last_tsp_enrt_rec.pl_id is null Then
     --dbms_output.put_line(' Person was not enrolled in TSP before');
     l_err_msg := 'Person Id ' ||p_person_id ||' : No previous TSP record to Copy';
     Raise Nothing_to_do;
  End If;

  If c_get_ee_last_tsp_enrt_rec%ISOPEN then Close c_get_ee_last_tsp_enrt_rec; End If;

  For get_prtt_rt_val in c_get_prtt_rt_val Loop
      l_rt_val   := get_prtt_rt_val.rt_val;
      exit;
  End Loop;

  hr_utility.set_location(l_proc, 50);
  --dbms_output.put_line('Rate Value :'  ||l_rt_val);

      -- Run Process Life Events for the EE
      --dbms_output.put_line('Before calling p_proc_lf_evts_from_benauthe 1');
      ben_on_line_lf_evt.p_evt_lf_evts_from_benauthe(
         p_person_id             => p_person_id
        ,p_effective_date        => p_effective_date
        ,p_business_group_id     => p_business_group_id
        ,p_pgm_id                => p_pgm_id
        ,p_pl_id                 => null
        ,p_mode                  => 'L'
        ,p_popl_enrt_typ_cycl_id => null
        ,p_lf_evt_ocrd_dt        => p_effective_date
        ,p_prog_count            => l_prog_count
        ,p_plan_count            => l_plan_count
        ,p_oipl_count            => l_oipl_count
        ,p_person_count          => l_person_count
        ,p_plan_nip_count        => l_plan_nip_count
        ,p_oipl_nip_count        => l_oipl_nip_count
        ,p_ler_id                => l_ler_id
        ,p_errbuf                => l_errbuf
        ,p_retcode               => l_retcode);
      --
      --dbms_output.put_line('Before calling p_proc_lf_evts_from_benauthe 2');
      hr_utility.set_location(l_proc, 60);
      ben_on_line_lf_evt.p_proc_lf_evts_from_benauthe(
        p_person_id              => p_person_id
        ,p_effective_date        => p_effective_date
        ,p_business_group_id     => p_business_group_id
        ,p_mode                  => 'L'
        ,p_ler_id                => l_ler_id
        ,p_person_count          => l_person_count
        ,p_benefit_action_id     => l_benefit_action_id
        ,p_errbuf                => l_errbuf
        ,p_retcode               => l_retcode);
      --
      --dbms_output.put_line('After calling p_proc_lf_evts_from_benauthe 2');
  hr_utility.set_location(l_proc, 70);
        open c_get_elig_chc_id;
        fetch c_get_elig_chc_id into l_elig_per_elctbl_chc_id,l_per_in_ler_id;
        If c_get_elig_chc_id%NOTFOUND then
          l_err_msg := 'Person_ID  '|| p_person_id||':No Electable Choice found for this person' ;
          --dbms_output.put_line('NO Electable choice id ');
          Raise Nothing_to_do;
        End If;
      --dbms_output.put_line('Electable choice id ' || l_elig_per_elctbl_chc_id);
      --dbms_output.put_line('PER in LER ID       ' || l_per_in_ler_id);


      hr_utility.set_location(l_proc, 80);
        open c_get_enrt_rt_id;
        fetch c_get_enrt_rt_id into l_enrt_rt_id;
        If c_get_enrt_rt_id%NOTFOUND then
          l_err_msg := 'Person_ID  '|| p_person_id||':No Electable Rate found for this person' ;
          --dbms_output.put_line('NO Electable enrollment Rate   id ');
          Raise Nothing_to_do;
        End If;
      --dbms_output.put_line('Electable rate id ' || l_enrt_rt_id||':'||p_effective_date);

      hr_utility.set_location(l_proc, 90);
        ben_election_information.election_information
        (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
        ,p_effective_date         => p_effective_date
        ,p_enrt_mthd_cd           => 'E'
        ,p_enrt_bnft_id           => l_enrt_bnft_id
        ,p_enrt_rt_id1            => l_enrt_rt_id
        ,p_rt_val1                => l_rt_val
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
        ,p_enrt_cvg_strt_dt       => p_effective_date
        ,p_enrt_cvg_thru_dt       => hr_api.g_eot
        ,p_datetrack_mode         => 'INSERT'
        ,p_suspend_flag           => l_suspend_flag
        ,p_effective_start_date   => l_esd
        ,p_effective_end_date     => l_eed
        ,p_object_version_number  => l_ovn
        ,p_prtt_enrt_interim_id   => l_prtt_enrt_interim_id
        ,p_business_group_id      => p_business_group_id
        ,p_dpnt_actn_warning      => l_Boolean
        ,p_bnf_actn_warning       => l_Boolean
        ,p_ctfn_actn_warning      => l_Boolean
        );
        --dbms_output.put_line('NOw calling ben-proc_common_enrt_rslt.post_enrt');
        hr_utility.set_location(l_proc, 100);
        ben_proc_common_enrt_rslt.process_post_enrt_calls_w
         (p_validate               => 'N'
         ,p_person_id              => p_person_id
         ,p_per_in_ler_id          => l_per_in_ler_id
         ,p_pgm_id                 => p_pgm_id
         ,p_pl_id                  => get_ee_last_tsp_enrt_rec.pl_id
         ,p_flx_cr_flag            => 'N'
         ,p_enrt_mthd_cd           => 'E'
         ,p_proc_cd                => null
         ,p_cls_enrt_flag          => 'Y'
         ,p_business_group_id      => p_business_group_id
         ,p_effective_date         => to_char(p_effective_date,'YYYY/MM/DD'));
      --
      If c_get_elig_chc_id%ISOPEN Then
         close c_get_elig_chc_id;
      End If;
      --dbms_output.put_line('Enrollment Result id ' || l_prtt_enrt_rslt_id);
    --End if;
/*
    -- Read value for input value "Emp Contrib Elig Date" for the previous assignment
    -- and update new element with the date (if it not null)

       for get_prev_asg_id in c_get_prev_asg_id loop
           l_old_asg_id  := get_prev_asg_id.assignment_id;
           exit;
       End Loop;
       ghr_api.retrieve_element_entry_value
               (p_element_name          => l_element_name
               ,p_input_value_name      => l_input_value_name
               ,p_assignment_id         => l_old_asg_id
               ,p_effective_date        => p_effective_date
               ,p_value                 => l_val
               ,p_multiple_error_flag   => l_multi_error_flag);
        If l_val is not null Then
             l_elig_dt    := to_date(substr(l_val,1,10),'yyyy/mm/dd');
             ghr_element_api.process_sf52_element
                  (p_assignment_id        =>   l_new_asg_id
                  ,p_element_name         =>   l_element_name
                  ,p_input_value_name1    =>   l_input_value_name
                  ,p_value1               =>   l_elig_dt
                  ,p_effective_date      =>    p_effective_date
                  ,p_process_warning      =>   l_process_warning
             );

     End If;
   */
  hr_utility.set_location(l_proc, 200);
  hr_utility.set_location('leaving  :'|| g_package||l_proc, 210);
  Exception
    When Nothing_to_do Then
        hr_utility.set_location('Exception' ||l_proc, 300);
        If c_get_elig_chc_id%ISOPEN Then
           close c_get_elig_chc_id;
        End If;
        rollback;
        ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  l_proc||'-'||to_char(sysdate,'DD-MON-YYYY'),
             p_log_text                =>  l_err_msg,
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             );
        --dbms_output.put_line('Data Issue... Nothing_to_do! ');
   When others then
        hr_utility.set_location('Exception' ||l_proc, 310);
        --dbms_output.put_line('Script Failed. Contact Your System Administrator.! ');
        If c_get_elig_chc_id%ISOPEN then
           close c_get_elig_chc_id;
        End If;
        rollback;
        ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  l_proc||'-'||to_char(sysdate,'DD-MON-YYYY'),
             p_log_text                =>  'PERSON ID:'||p_person_id || ' ' || sqlerrm(sqlcode),
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             );
   End tsp_continue_coverage;


   Procedure tsp_continue_coverage_cp(p_errbuf              OUT NOCOPY VARCHAR2,
                                      p_retcode             OUT NOCOPY NUMBER) is

   l_pgm_id                  ben_pgm_f.pgm_id%type;
   l_err_msg                 varchar2(2000);
   l_business_group_id       number;
   l_ler_id                  ben_ler_f.ler_id%type;
   l_person_id               Number;
   l_effective_date          Date;
   l_proc                    Varchar2(100) ;

   Nothing_to_do             Exception;


   -- Cursor to get Pgm_id for the given Business Group
   Cursor c_get_pgm_id is
     select pgm.pgm_id
     from   ben_pgm_f pgm
     where  pgm.name = 'Federal Thrift Savings Plan (TSP)'
     and    pgm.business_group_id  = l_business_group_id;

   -- Cursor to get potential records
   Cursor c_get_ptnl_emps is
      select person_id,business_group_id,ler_id,lf_evt_ocrd_dt
      from   ben_ptnl_ler_for_per
      where  ler_id in (select ler_id from ben_ler_f where name = 'TSP Continuation of Coverage'
                        and sysdate between effective_start_date and effective_end_date)
      and    ptnl_ler_for_per_stat_cd = 'UNPROCD'
      and    lf_evt_ocrd_dt <= sysdate;

BEGIN
  --dbms_output.put_line(' start ' );
  l_proc  := 'TSP_Cont_Cvg_CP';
  hr_utility.set_location('Entering' ||l_proc, 100);
  l_err_msg := null;

  -- get all potential employees
  for get_ptnl_emps in c_get_ptnl_emps Loop
     Begin
        hr_utility.set_location(l_proc, 110);
        l_person_id := get_ptnl_emps.person_id;
        l_business_group_id := get_ptnl_emps.business_group_id;
        l_ler_id := get_ptnl_emps.ler_id;
        l_effective_date := get_ptnl_emps.lf_evt_ocrd_dt;
        hr_utility.trace('Person id   ' ||l_person_id||'     BG ID :  '||l_business_group_id);
        hr_utility.trace('ler id   ' ||l_ler_id||'     EFf DT :  '||l_effective_date);

       -- Get Program Id
        for pgm_rec in c_get_pgm_id loop
            l_pgm_id := pgm_rec.pgm_id;
            --dbms_output.put_line('pgm id'|| ' ' ||l_pgm_id );
        end loop;
        If l_pgm_id is null Then
           --dbms_output.put_line ('NO program found ');
           l_err_msg := ':No Program defined in this BG ' ||l_business_group_id;
           Raise Nothing_to_do;
        End If;

        --call tsp_contine_coverage procedure
        tsp_continue_coverage(l_person_id,
                              l_business_group_id,
                              l_ler_id,
                              l_pgm_id,
                              l_effective_date);

  exception
    When Nothing_to_do Then
        --rollback;
        ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  l_proc||'-'||to_char(sysdate,'DD-MON-YYYY'),
             p_log_text                =>  l_err_msg,
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             );
     when others then
        null;
  end;
  End Loop;

  End tsp_continue_coverage_cp;


  Procedure get_recs_for_tsp_migration(p_errbuf     OUT NOCOPY Varchar2
                                      ,p_retcode    OUT NOCOPY Number
                                      ,p_business_group_id in Number)  is


    Cursor c_emp_tsp(c_business_group_id in number, c_element_name in pay_element_types_f.element_name%type)  is
    select
           e.assignment_id            assignment_id,
           decode(name,'Rate','Percentage',
                       'Status','Terminate Contributions',
                        name) Name,
           decode (screen_entry_value,'T',0,'S',0,screen_entry_value) screen_entry_value,
           e.effective_start_date,
           g.person_id
           from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f,
           per_all_assignments_f      g
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    g.business_group_id    = c_business_group_id
    and    e.effective_end_date   = hr_api.g_eot
    --and    trunc(sysdate) between e.effective_start_date and e.effective_End_date
    and    trunc(e.effective_start_date) between f.effective_start_date and f.effective_End_date
    and    g.assignment_id =  e.assignment_id
    and    trunc(e.effective_start_date) between g.effective_start_date and g.effective_end_date
    --and    a.element_name         = 'TSP'
    and    a.element_name   = c_element_name
    and    ( (b.name    in ('Rate','Amount') and (ghr_general.return_number(screen_entry_value) > 0))
             or (b.name = 'Status' and screen_entry_value in ('T','S')))
    order by 1, 2 desc ;

	l_element_name pay_element_types_f.element_name%type;

  BEGIN
   -- 11.5.10 Performance Changes
        l_element_name := NVL(UPPER(pqp_fedhr_uspay_int_utils.return_new_element_name ('TSP',p_business_group_id,sysdate,NULL)),'$Sys_Def$');

       -- set program name
          ghr_mto_int.set_log_program_name('GHR_TSP_MIGRATION');
      for emp_rec in c_emp_tsp(p_business_group_id,l_element_name) loop
        ghr_general.ghr_tsp_migrate(emp_rec.assignment_id,
                                    emp_rec.name,
                                    emp_rec.screen_entry_value,
                                    emp_rec.effective_start_date,
                                    p_business_group_id,
                                    emp_rec.person_id);
        commit;
      end loop;
  End get_recs_for_tsp_migration;
end ghr_tsp_plan_design;

/
