--------------------------------------------------------
--  DDL for Package Body GHR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_GENERAL" AS
/* $Header: ghgenral.pkb 120.4 2006/01/10 10:19:58 bgarg noship $ */
--
--
FUNCTION return_number(p_value varchar2) RETURN number is
BEGIN
  return(to_number(p_value)) ;
EXCEPTION
  when others then
    return(0);
end return_number;
FUNCTION return_rif_date(p_value varchar2) RETURN date is
BEGIN
  return(fnd_date.canonical_to_date(p_value)) ;
EXCEPTION
  when others then
    return(to_date('1901/01/01','yyyy/mm/dd'));
end return_rif_date;

--
-- ---------------------------------------------------------------------------
-- |---------------------------< get_remark_code >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve remark code from table ghr_remarks.
--
-- Prerequisites:
--   p_remark_id must be provided.
--
-- In Parameters:
--   p_remark_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
FUNCTION get_remark_code(p_remark_id IN ghr_remarks.code%type)
         Return VARCHAR2 AS

  rem_code  ghr_remarks.code%type;
  cursor c1 (p_remark_id Number) is
  select code from ghr_remarks where remark_id = p_remark_id;
BEGIN
  open c1(p_remark_id);
  fetch c1 into rem_code;
  close c1;
  Return(rem_code);
END get_remark_code;

Procedure get_poi_to_send_ntfn(
Itemtype in varchar2,
Itemkey  in varchar2,
actid    in number,
funcmode in varchar2,
result out NOCOPY varchar2
)
is

l_person_id number;
l_effective_date       date := sysdate;
l_groupbox_name        ghr_groupboxes.name%type;
l_personnel_office_id  ghr_pa_requests.personnel_office_id%type;
l_gbx_user_id          ghr_pois.person_id%type;
l_receiver_name        ghr_groupboxes.name%type;


cursor get_position_id is
  select asg.position_id
  from   per_all_assignments_f asg
  where  asg.person_id =  l_person_id
  and    l_effective_date between asg.effective_start_date and asg.effective_end_date
  and    asg.assignment_type <> 'B';

cursor get_user_name is
  select fnd.user_name
  from   fnd_user fnd
  where  l_gbx_user_id = fnd.employee_id;

l_position_id per_all_assignments_f.position_id%type;

begin

hr_utility.set_location('Entering' ,1);

if funcmode =  'RUN' then
  hr_utility.set_location('Run' ,1);
  l_person_id :=  wf_engine.GetItemAttrText(itemtype => Itemtype,
                                            itemkey  => Itemkey,
                                            aname    => 'PERSON_ID');
  hr_utility.set_location('l_person_id is  ' || l_person_id ,1);

  /*l_effective_date :=  wf_engine.GetItemAttrText(itemtype => Itemtype,
                                            itemkey  => Itemkey,
                                            aname    => 'EFFECTIVE_DATE');
   l_effective_date := nvl(l_effective_date,sysdate);
  */

   for get_pos_rec in get_position_id loop
     l_position_id := get_pos_rec.position_id;
   end loop;

   hr_utility.set_location('l_pos _id is  ' || l_position_id ,1);

   ghr_wf_wgi_pkg.get_emp_personnel_groupbox (
                             p_position_id  => l_position_id,
                             p_effective_date => l_effective_date,
                             p_groupbox_name  => l_groupbox_name,
                             p_personnel_office_id => l_personnel_office_id,
                             p_gbx_user_id         =>  l_gbx_user_id
                             );
   hr_utility.set_location('l_gbx_id is  ' || l_gbx_user_id ,1);

/* Assuming that either the groupbox or the approver name will be
   available for each POI. If values  exist for both then the notification will
   be sent to the groupbox
*/
   if l_groupbox_name is not null then
    l_receiver_name :=  l_groupbox_name;
   else
     for user_name_rec in get_user_name loop
       l_receiver_name := user_name_rec.user_name;
     end loop;
   end if;

   wf_engine.SetItemAttrText(itemtype => itemtype
                          ,itemkey => itemkey
                          ,aname  => 'RECEIVER_NAME'
                          ,avalue => l_receiver_name);


   result := 'COMPLETE:';

  end if;

end get_poi_to_send_ntfn;

    Procedure ghr_fehb_migrate(
        p_assignment_id           in per_assignments_f.assignment_id%type,
        p_business_group_id       in per_assignments_f.business_group_id%type,
        p_person_id               in per_assignments_f.person_id%type,
        p_effective_date          in Date    ,
        p_health_plan             in ben_pl_f.short_code%type,
        p_option_code             in ben_opt_f.short_code%type,
        p_element_entry_id        in pay_element_entries_f.element_entry_id%type,
        p_object_version_number   in pay_element_entries_f.object_version_number%type,
        p_temps_cost              in pay_element_entry_values_f.screen_entry_value%type)  is


      l_prog_count              number;
      l_plan_count              number;
      l_oipl_count              number;
      l_person_count            number;
      l_plan_nip_count          number;
      l_oipl_nip_count          number;

      l_pgm_id                ben_pgm_f.pgm_id%type;
      l_pl_id                 ben_pl_f.pl_id%type;
      l_opt_id                ben_opt_f.opt_id%type;
      l_pl_typ_id             ben_pl_typ_f.pl_typ_id%type;
      l_plip_id               ben_plip_f.plip_id%type;
      l_oipl_id               ben_oipl_f.oipl_id%type;
      l_ler_id                ben_ler_f.ler_id%type;
      l_ptip_id               ben_ptip_f.ptip_id%type;
      l_exists                boolean;
      l_ptnl_ler_for_per_id   number;
      l_ovn                   number;
      l_errbuf                varchar2(2000);
      l_retcode               number;
      l_elig_per_elctbl_chc_id number;
      l_prtt_enrt_rslt_id     number;
      l_enrt_bnft_id          number;
      l_prtt_rt_val_id        number;
      l_prtt_rt_val_id1       number;
      l_prtt_rt_val_id2       number;
      l_prtt_rt_val_id3       number;
      l_prtt_rt_val_id4       number;
      l_prtt_rt_val_id5       number;
      l_prtt_rt_val_id6       number;
      l_prtt_rt_val_id7       number;
      l_prtt_rt_val_id8       number;
      l_prtt_rt_val_id9       number;
      l_prtt_rt_val_id10      number;
      l_suspend_flag          varchar2(30);
      l_esd                   date;
      l_eed                   date;
      l_prtt_enrt_interim_id  number;
      L_boolean               boolean;
      l_per_in_ler_id         number;
      l_benefit_action_id     number;
      l_err_msg               varchar2(2000);
      Nothing_To_Do           Exception;
      Ben_Rec_Exists          Exception;

      l_eff_start_date        Date;
      l_eff_end_date          Date;
      l_del_warning           Boolean;
      l_object_version_number Number;
      l_input_val_id1         Number;
      l_input_val_id2         Number;
      l_input_val_id3         Number;
      l_input_val_id4         Number;

      l_name                  Varchar2(240);
      l_ssn                   Varchar2(30);

      -- Cursor to get the ler_id
      Cursor get_ler_id is
      select ler.ler_id
      from   ben_ler_f ler
      where  ler.business_group_id = p_business_group_id
      and    ler.name              = 'Added for Migration'
      and    p_effective_date between effective_start_date and effective_end_date;

      -- Cursor to get Pgm_id for the given Business Group
      Cursor get_pgm_id is
        select pgm.pgm_id
        from   ben_pgm_f pgm
        where  pgm.name = 'Federal Employees Health Benefits'
        and    pgm.business_group_id  = p_business_group_id
        and    p_effective_date between effective_start_date and effective_end_date;

      --Cursor to get the Plan Type Id for the given  Business_group_id
      Cursor get_pl_typ_id is
        select plt.pl_typ_id
        from ben_pl_typ_f plt
        where plt.name =  'Health Benefits'
        and   plt.business_group_id = p_business_group_id
        and    p_effective_date between effective_start_date and effective_end_date;


      -- Cursor to get the Ptip_id for the given Pgm and Plan Type.
       Cursor get_ptip_id is
         select ptip_id
         from   ben_ptip_f
         where  pl_typ_id = l_pl_typ_id
         and pgm_id = l_pgm_id
        and    p_effective_date between effective_start_date and effective_end_date;

      -- Cursor to get the Plan Id for the EE's Health Plan screen entry value
       Cursor get_pl_id is
         select pln.pl_id  pl_id
         from ben_pl_f pln
         where pln.short_code = p_health_plan
         and   pln.business_group_id = p_business_group_id
         and    p_effective_date between effective_start_date and effective_end_date
         and   pl_stat_cd = 'A';

       --Cursor to get the plan in Program Id for the given Pl_id
       Cursor get_plip_id is
         select plip.plip_id
         from   ben_plip_f plip
         where  plip.pl_id  =    l_pl_id
         and    plip.pgm_id = l_pgm_id
         and    plip.business_group_id = p_business_group_id
        and    p_effective_date between effective_start_date and effective_end_date;


       --Cursor to get the opt_id for the EE's Enrollment Screen Entry Value
       Cursor get_opt_id is
        Select opt_id
        from   ben_opt_f opt
        where  opt.short_code = p_option_code
        and opt.business_group_id = p_business_group_id
        and    p_effective_date between effective_start_date and effective_end_date;

       -- Cursor to get the option in plan Id

       Cursor get_oipl_id is
         select oipl_id
         from   ben_oipl_f
         where  pl_id =  l_pl_id
         and   opt_id = l_opt_id
         and business_group_id = p_business_group_id
        and    p_effective_date between effective_start_date and effective_end_date;

       -- Cursor to get the elig_chc_id for the plan, Option combination associated with the ler "added during migration" after benmngle is run

       Cursor get_elig_chc_id_opt is
         select elig_per_elctbl_chc_id,
                pil.per_in_ler_id
         from   ben_elig_per_ELCTBL_chc chc ,
                ben_per_in_ler pil
         where chc.pgm_id = l_pgm_id
         and   chc.pl_typ_id = l_pl_typ_id
         and   chc.pl_id = l_pl_id
         and   chc.plip_id = l_plip_id
         and   chc.ptip_id = l_ptip_id
         and   chc.oipl_id = l_oipl_id
         and   pil.per_in_ler_id = chc.per_in_ler_id
         and   pil.ler_id  = l_ler_id
         and   pil.person_id = p_person_id;

       Cursor get_elig_chc_id is
         select elig_per_elctbl_chc_id,
                pil.per_in_ler_id
         from   ben_elig_per_ELCTBL_chc chc ,
                ben_per_in_ler pil
         where chc.pgm_id = l_pgm_id
         and   chc.pl_typ_id = l_pl_typ_id
         and   chc.pl_id = l_pl_id
         and   chc.plip_id = l_plip_id
         and   chc.ptip_id = l_ptip_id
         and   pil.per_in_ler_id = chc.per_in_ler_id
         and   pil.ler_id  = l_ler_id
         and   pil.person_id = p_person_id;

      -- Cursor to check if Employee is currently enrolled in FEHB including
      -- enrollments made in his prior employment
      cursor c_emp_in_fehb is
        select 1
        from   ben_prtt_enrt_rslt_f prt
        where  prt.person_id = p_person_id
        and    pgm_id        = l_pgm_id;

     cursor c_get_ovn is
       select object_version_number
       from   pay_element_entries_f
       where  element_entry_id = p_element_entry_id
       and    effective_start_date < p_effective_date
       order by effective_start_date desc;

     cursor c_get_new_element_details is
     SELECT eef_new.element_entry_id,
            eef_new.object_version_number,
            eef_new.element_type_id
     FROM   pay_element_entries_f eef_new,
            pay_element_types_f elt_new
     WHERE  eef_new.assignment_id = p_assignment_id
     and    elt_new.element_type_id = eef_new.element_type_id
     AND    eef_new.effective_start_date BETWEEN elt_new.effective_start_date  AND elt_new.effective_end_date
     and    eef_new.effective_start_date = trunc(p_effective_date)
     and    eef_new.effective_end_date = hr_api.g_eot
     AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt_new.element_name,
                                                                     p_business_group_id,
                                                                     eef_new.effective_start_date))
                          IN  ('HEALTH BENEFITS PRE TAX'
                          );

    cursor c_get_input_value_ids(l_element_type_id in number) is
    select input_value_id
    from   pay_input_values_f
    where  element_type_id = l_element_type_id
    and    name = 'Temps Total Cost'
    and    trunc(p_effective_date) between effective_start_date and effective_end_date;

    Cursor c_get_ssn is
    select national_identifier
    from   per_all_people_f
    where  person_id = p_person_id
    and    trunc(p_effective_date) between effective_start_date and effective_end_date;
    Begin
        for ler_rec in get_ler_id loop
              l_ler_id := ler_rec.ler_id;
        end loop;
        If l_ler_id is null Then
              l_err_msg := 'No Life Events  defined in employee''s business group ';
              Raise Nothing_to_do;
        End If;

        --Get Pgm ID
        for pgm_rec in get_pgm_id loop
              l_pgm_id := pgm_rec.pgm_id;
        end loop;
        If l_pgm_id is null Then
              l_err_msg := 'Federal Employee Health Benefits program not defined in employee''s business group ' ;
              Raise Nothing_to_do;
        End If;

        --get Full Name
        l_name := ghr_pa_requests_pkg.get_full_name_unsecure(p_person_id,p_effective_date);

        --get SSN
        For get_ssn in c_get_ssn loop
            l_ssn := get_ssn.national_identifier;
            exit;
        End loop;

        --Check if record already exists in the Ben table for this person as
        l_exists := FALSE;
        for emp_fehb_rec in c_emp_in_fehb loop
          l_exists :=  TRUE;
          exit;
        end loop;
        If l_exists then
          Raise Ben_Rec_Exists;
        End If;

        for plt_rec in get_pl_typ_id loop
              l_pl_typ_id := plt_rec.pl_typ_id;
        end loop;

        for ptip_rec in get_ptip_id loop
              l_ptip_id :=  ptip_rec.ptip_id;
        end loop;

        --get pl_id,opt_id,opil_id,electible_choice_id

        for pl_rec in get_pl_id loop
            l_pl_id := pl_rec.pl_id;
        end loop;
        If l_pl_id is null Then
            l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : Health Plan  ' || p_health_plan  ||' is not valid for migration ';
            Raise Nothing_to_do;
        End If;

        If p_option_code is not null then
          for opt_rec in get_opt_id loop
              l_opt_id := opt_rec.opt_id;
          end loop;
          If l_opt_id is null Then
              --dbms_output.put_line ('NO option found ');
              l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : Enrollment Status ' || p_option_code  ||' is not valid for migration ';
              Raise Nothing_to_do;
          End If;
        end if;

        -- get plip_id
        for  plip_id_rec in get_plip_id loop
            l_plip_id := plip_id_rec.plip_id;
        end loop;
        --dbms_output.put_line('plip id'|| ' ' ||l_plip_id );

        -- get oipl_id
        if l_opt_id is not null then
            for oipl_id_rec in get_oipl_id loop
                l_oipl_id := oipl_id_rec.oipl_id;
            end loop;
            If l_oipl_id is null Then
                --dbms_output.put_line ('NO Option in Plan Found ');
                l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| '  : Plan/Option combination ' ||p_health_plan||'/'||p_option_code || ' is not defined in employee''s business group';
                Raise Nothing_to_do;
            End If;
        else
                l_oipl_id := null;
      end if;


      -- Create Potential Life Event

      ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
                (p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id
                ,p_lf_evt_ocrd_dt           => p_effective_date
                ,p_ptnl_ler_for_per_stat_cd => 'UNPROCD'
                ,p_ler_id                   => l_ler_id
                ,p_person_id                => p_person_id
                ,p_business_group_id        => p_business_group_id
                ,p_unprocd_dt               => p_effective_date
                ,p_object_version_number    => l_ovn
                ,p_effective_date           => p_effective_date
                );

      --dbms_output.put_line('PTNL L.E' || ' ' || l_ptnl_ler_for_per_id);
      --dbms_output.put_line('pgm_id is ' || ' ' || l_pgm_id);
      --dbms_output.put_line('pl_typ_id is ' || ' ' || l_pl_typ_id);
      --dbms_output.put_line('pl_id is ' || ' ' || l_pl_id);
      --dbms_output.put_line('plip_id is ' || ' ' || l_plip_id);
      --dbms_output.put_line('ptip_id is ' || ' ' || l_ptip_id);
      --dbms_output.put_line('oipl_id is ' || ' ' || l_oipl_id);
      --dbms_output.put_line('ler_id is ' || ' ' || l_ler_id);
      --dbms_output.put_line('person_id is ' || ' ' || p_person_id);
      -- Run Process Life Events for the EE
      --dbms_output.put_line('Before calling p_proc_lf_evts_from_benauthe 1');
      ben_on_line_lf_evt.p_evt_lf_evts_from_benauthe(
        p_person_id             => p_person_id
        ,p_effective_date        => p_effective_date
        ,p_business_group_id     => p_business_group_id
        ,p_pgm_id                => l_pgm_id
        ,p_pl_id                 => l_pl_id
        ,p_mode                  => 'L'
        ,p_popl_enrt_typ_cycl_id => null
        ,p_lf_evt_ocrd_dt        => p_effective_date
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
      --dbms_output.put_line('Before calling p_proc_lf_evts_from_benauthe 2');
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
      --dbms_output.put_line('Before opening cursor    '||l_oipl_id);
      If l_oipl_id is not null Then
        --dbms_output.put_line('1.here');
        open get_elig_chc_id_opt;
        fetch get_elig_chc_id_opt into l_elig_per_elctbl_chc_id,l_per_in_ler_id;
        If get_elig_chc_id_opt%NOTFOUND then
          l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : No electable choice found for this employee';
          l_err_msg := l_err_msg|| 'Please ensure that the employee is eligible for Federal Employee Health Benefits program and /or  the combination of the Plan / Option: '||p_health_plan||'/'||p_option_code;
          Raise Nothing_to_do;
        End If;
      Else
        --dbms_output.put_line('2.here');
        open get_elig_chc_id;
        fetch get_elig_chc_id into l_elig_per_elctbl_chc_id,l_per_in_ler_id;
        If get_elig_chc_id%NOTFOUND then
          l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : No electable choice found for this employee';
          l_err_msg := l_err_msg|| 'Please ensure that the employee is eligible for Federal Employee Health Benefits program and /or  the combination of the Plan / Option: '||p_health_plan||'/'||p_option_code;
          Raise Nothing_to_do;
        End If;
      End If;
        --l_elig_per_elctbl_chc_id := elig_rec.elig_per_elctbl_chc_id;
        --l_per_in_ler_id          := elig_rec.per_in_ler_id;
      --dbms_output.put_line('Electable choice id ' || l_elig_per_elctbl_chc_id);
      --dbms_output.put_line('PER in LER ID       ' || l_per_in_ler_id);
        ben_election_information.election_information
        (p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id      => l_prtt_enrt_rslt_id
        ,p_effective_date         => p_effective_date
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

        ben_proc_common_enrt_rslt.process_post_enrt_calls_w
         (p_validate               => 'N'
         ,p_person_id              => p_person_id
         ,p_per_in_ler_id          => l_per_in_ler_id
         ,p_pgm_id                 => l_pgm_id
         ,p_pl_id                  => l_pl_id
         ,p_flx_cr_flag            => 'N'
         ,p_enrt_mthd_cd           => 'E'
         ,p_proc_cd                => null
         ,p_cls_enrt_flag          => 'Y'
         ,p_business_group_id      => p_business_group_id
         ,p_effective_date         => p_effective_date);
      --
      If get_elig_chc_id_opt%ISOPEN Then
         close get_elig_chc_id_opt;
      End If;
      If get_elig_chc_id%ISOPEN Then
         close get_elig_chc_id;
      End If;
      --dbms_output.put_line('Enrollment Result id ' || l_prtt_enrt_rslt_id);

      -- if the new element for Health Benefits Pre tax is created then (if option is %P)
      -- 1) delete the element record of "Health Benefits' element
      -- 2) update value for Temps Total Cost in the new element
      If p_option_code like '%P' then
         -- get the version number of the previous record
         for get_ovn in c_get_ovn LOOP
             l_object_version_number := get_ovn.object_version_number;
             exit;
         End Loop;
         --if there was no previous record for the same element entry then pass ZAP else delete to API
         if l_object_version_number is null then
              l_object_version_number := p_object_version_number;
              py_element_entry_api.delete_element_entry(
                 p_datetrack_delete_mode         =>      hr_api.g_zap,
                 p_effective_date                =>      p_effective_date,
                 p_element_entry_id              =>      p_element_entry_id,
                 p_object_version_number         =>      l_object_version_number,
                 p_effective_start_date          =>      l_eff_start_date,
                 p_effective_end_date            =>      l_eff_end_date,
                 p_delete_warning                =>      l_del_warning);
          Else
              py_element_entry_api.delete_element_entry(
                 p_datetrack_delete_mode         =>      hr_api.g_delete,
                 p_effective_date                =>      (p_effective_date - 1),
                 p_element_entry_id              =>      p_element_entry_id,
                 p_object_version_number         =>      l_object_version_number,
                 p_effective_start_date          =>      l_eff_start_date,
                 p_effective_end_date            =>      l_eff_end_date,
                 p_delete_warning                =>      l_del_warning);
          End If;
          If p_temps_cost is not null then
             for get_new_element_details in c_get_new_element_details loop
                 --dbms_output.put_line ('element entry_id   ' ||get_new_element_details.element_entry_id);
                 --dbms_output.put_line ('object_version_number ' ||get_new_element_details.object_version_number);
                 --dbms_output.put_line ('element_type_id ' ||get_new_element_details.element_type_id);

                 for get_input_value_ids in c_get_input_value_ids(get_new_element_details.element_type_id) loop
                     l_input_val_id3 := get_input_value_ids.input_value_id;
                     exit;
                 end loop;
                 --dbms_output.put_line ('input_value_id ' ||l_input_val_id3);
                 py_element_entry_api.update_element_entry(
                     p_datetrack_update_mode     =>     hr_api.g_correction
                    ,p_effective_date            =>     p_effective_date
                    ,p_business_group_id         =>     p_business_group_id
                    ,p_element_entry_id          =>     get_new_element_details.element_entry_id
                    ,p_object_version_number     =>     get_new_element_details.object_version_number
                    ,p_input_value_id3           =>     l_input_val_id3
                    ,p_entry_value3              =>     p_temps_cost
                    ,p_effective_start_date      =>     l_eff_start_date
                    ,p_effective_end_date        =>     l_eff_end_date
                    ,p_update_warning            =>     l_del_warning
                    );
                 exit;
             end loop;
          End If;
      End If;
  Exception
    When Ben_Rec_Exists Then
         null;
    When Nothing_to_do Then
        --dbms_output.put_line('1.Script Failed. Contact Your System Administrator.! ');
        If get_elig_chc_id_opt%ISOPEN then
           close get_elig_chc_id_opt;
        End If;
        If get_elig_chc_id%ISOPEN Then
           close get_elig_chc_id;
        End If;
        rollback;
        ghr_mto_int.log_message(null,l_err_msg);
        /*ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  'FEHB_MIG-'||to_char(sysdate,'MM/DD/YYYY'),
             p_log_text                =>  l_err_msg,
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             ); */
        --dbms_output.put_line('Data Issue... Nothing_to_do! ');
   When others then
        --dbms_output.put_line('2.Script Failed. Contact Your System Administrator.! ');
        --dbms_output.put_line('Error   ' ||sqlerrm(sqlcode));
        If get_elig_chc_id_opt%ISOPEN then
           close get_elig_chc_id_opt;
        End If;
        If get_elig_chc_id%ISOPEN Then
           close get_elig_chc_id;
        End If;
        rollback;
        l_err_msg := 'Name :'|| l_name||' SSN :'||l_ssn;
        ghr_mto_int.log_message(null,l_err_msg||' '||sqlerrm(sqlcode));
        /*ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  'FEHB_MIG-'||to_char(sysdate,'MM/DD/YYYY'),
             p_log_text                =>  'PERSON ID:'||p_person_id || ' ' || sqlerrm(sqlcode),
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             ); */
    End ghr_fehb_migrate;

   /* This procedure is used to migrate existing employees on TSP elements into */
   /* Assumptions:                                                              */
   /* 1) IF value for both Rate and Amount input value exists, rate supercedes  */
   /* 2) Existing element start date would be used as Rate Start Date and       */
   /* 3) Coverage Start date                                                    */
   /* 4)                                                                        */
   /*                                                                           */
   Procedure ghr_tsp_migrate(
        p_assignment_id     in per_assignments_f.assignment_id%type,
        p_opt_name          in Varchar2,
        p_opt_val           in Number,
        p_effective_date    in Date,
        p_business_group_id in per_assignments_f.business_group_id%type,
        p_person_id         in per_assignments_f.person_id%type)  is

     l_prog_count              number;
     l_plan_count              number;
     l_oipl_count              number;
     l_person_count            number;
     l_plan_nip_count          number;
     l_oipl_nip_count          number;

     l_pgm_id                ben_pgm_f.pgm_id%type;
     l_pl_id                 ben_pl_f.pl_id%type;
     l_opt_id                ben_opt_f.opt_id%type;
     l_pl_typ_id             ben_pl_typ_f.pl_typ_id%type;
     l_plip_id               ben_plip_f.plip_id%type;
     l_oipl_id               ben_oipl_f.oipl_id%type;
     l_ler_id                ben_ler_f.ler_id%type;
     l_ptip_id               ben_ptip_f.ptip_id%type;
     l_assignment_id         per_all_assignments_f.assignment_id%type;
     l_exists                boolean;
     l_ovn                   number;
     l_errbuf                varchar2(2000);
     l_retcode               number;
     l_elig_per_elctbl_chc_id number;
     l_prtt_enrt_rslt_id     number;
     l_enrt_rt_id            number;
     l_enrt_bnft_id          number;
     l_opt_val               number;
     l_prtt_rt_val_id        number;
     l_prtt_rt_val_id1       number;
     l_prtt_rt_val_id2       number;
     l_prtt_rt_val_id3       number;
     l_prtt_rt_val_id4       number;
     l_prtt_rt_val_id5       number;
     l_prtt_rt_val_id6       number;
     l_prtt_rt_val_id7       number;
     l_prtt_rt_val_id8       number;
     l_prtt_rt_val_id9       number;
     l_prtt_rt_val_id10      number;
     l_suspend_flag          varchar2(30);
     l_esd                   date;
     l_eed                   date;
     l_effective_date        date;
     l_prtt_enrt_interim_id  number;
     L_boolean               boolean;
     l_per_in_ler_id         number;
     l_benefit_action_id     number;
     l_err_msg               varchar2(2000);
     Nothing_To_Do           Exception;
     Ben_Enrt_Exists         Exception;

      l_name                  Varchar2(240);
      l_ssn                   Varchar2(30);

     -- Cursor to get Pgm_id for the given Business Group
     Cursor c_get_pgm_id is
       select pgm.pgm_id
       from   ben_pgm_f pgm
       where  pgm.name = 'Federal Thrift Savings Plan (TSP)'
       and    pgm.business_group_id  = p_business_group_id;

     --Cursor to get the Plan Type Id for the given  Business_group_id
     Cursor c_get_pl_typ_id is
       select plt.pl_typ_id
       from   ben_pl_typ_f plt
       where  plt.name =  'Savings Plan'
       and    plt.business_group_id = p_business_group_id;

-- Cursor to get the Ptip_id for the given Pgm and Plan Type.
      Cursor c_get_ptip_id is
        select ptip_id
        from   ben_ptip_f
        where  pl_typ_id = l_pl_typ_id
        and    pgm_id = l_pgm_id;

     -- Cursor to get the Plan Id
     Cursor c_get_pl_id is
       select pln.pl_id  pl_id
       from   ben_pl_f pln
       where  pln.name = 'TSP'
       and    pln.business_group_id = p_business_group_id;

     --Cursor to get the plan in Program Id for the given Pl_id
     Cursor c_get_plip_id is
       select plip.plip_id
       from   ben_plip_f plip
       where  plip.pl_id  =    l_pl_id
       and    plip.pgm_id = l_pgm_id
       and    plip.business_group_id = p_business_group_id;

     --Cursor to get the opt_id for the EE's Enrollment Screen Entry Value
     Cursor c_get_opt_id is
      Select opt_id
      from   ben_opt_f opt
      where  name = p_opt_name
      and    opt.business_group_id = p_business_group_id;

     -- Cursor to get the option in plan Id
     Cursor c_get_oipl_id is
       select oipl_id
       from   ben_oipl_f
       where  pl_id =  l_pl_id
       and    opt_id = l_opt_id
       and    business_group_id = p_business_group_id;

-- Cursor to get the elig_chc_id for the plan, Option
     Cursor c_get_elig_chc_id_opt is
       select elig_per_elctbl_chc_id,
              pil.per_in_ler_id
       from   ben_elig_per_ELCTBL_chc chc ,
              ben_per_in_ler pil
       where chc.pgm_id = l_pgm_id
       and   chc.pl_typ_id = l_pl_typ_id
       and   chc.pl_id = l_pl_id
       and   chc.plip_id = l_plip_id
       and   chc.ptip_id = l_ptip_id
       and   chc.oipl_id = l_oipl_id
       and   pil.per_in_ler_id = chc.per_in_ler_id
       --and   pil.ler_id  = l_ler_id
       and   pil.person_id = p_person_id;

     Cursor  c_get_enrt_rt_id is
       select enrt_rt_id
       from   ben_enrt_rt
       where  elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id;


-- Cursor to check if Employee is currently enrolled in TSP
     cursor c_emp_in_tsp is
       select 1
       from   ben_prtt_enrt_rslt_f
       where  person_id = p_person_id
       and    pgm_id    = l_pgm_id;

    Cursor c_get_ssn is
    select national_identifier
    from   per_all_people_f
    where  person_id = p_person_id
    and    trunc(p_effective_date) between effective_start_date and effective_end_date;

BEGIN

    -- Get PGM ID
    for pgm_rec in c_get_pgm_id loop
        l_pgm_id := pgm_rec.pgm_id;
        exit;
    end loop;
    If l_pgm_id is null Then
       --dbms_output.put_line ('NO program found ');
       l_err_msg := 'Federal Thrift Savings Plan (TSP) program not defined in employee''s business group ' ;
       Raise Nothing_to_do;
    End If;

    --get Full Name
    l_name := ghr_pa_requests_pkg.get_full_name_unsecure(p_person_id,p_effective_date);
    --dbms_output.put_line ('Full Name        '||l_name);

    --get SSN
    For get_ssn in c_get_ssn loop
            l_ssn := get_ssn.national_identifier;
            exit;
    End loop;
    --dbms_output.put_line ('SSN              '||l_ssn);


    --Check if record already exists in the Ben table for this person
    l_exists := FALSE;
    for emp_tsp_rec in c_emp_in_tsp loop
      l_exists :=  TRUE;
      exit;
    end loop;
    If l_exists then
      --dbms_output.put_line('No Action' );
      Raise ben_enrt_exists;
    End If;

    For plt_rec in c_get_pl_typ_id loop
        l_pl_typ_id := plt_rec.pl_typ_id;
        exit;
    end loop;
    --dbms_output.put_line('pl_typ id'|| ' ' ||l_pl_typ_id );

    for ptip_rec in c_get_ptip_id loop
        l_ptip_id :=  ptip_rec.ptip_id;
        exit;
    end loop;
    --dbms_output.put_line('ptip id'|| ' ' ||l_ptip_id );

    --get pl_id,opt_id,opil_id,electible_choice_id

    for pl_rec in c_get_pl_id loop
        l_pl_id := pl_rec.pl_id;
        exit;
    end loop;
    --dbms_output.put_line(' l_plan_id ' || l_pl_id);
    If l_pl_id is null Then
       --dbms_output.put_line ('NO plan found ');
       l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : TSP Plan is not valid for migration ';
       Raise Nothing_to_do;
      End If;

    for opt_rec in c_get_opt_id loop
        l_opt_id := opt_rec.opt_id;
        exit;
    end loop;
    If l_opt_id is null Then
       --dbms_output.put_line ('NO option found ');
       l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : Option ' || p_opt_name  ||' is not valid for migration ';
       Raise Nothing_to_do;
    End If;
    --dbms_output.put_line('opt id'|| ' ' ||l_opt_id );

      -- get plip_id
    for  plip_id_rec in c_get_plip_id loop
        l_plip_id := plip_id_rec.plip_id;
        exit;
    end loop;
    --dbms_output.put_line('plip id'|| ' ' ||l_plip_id );

      -- get oipl_id
    for oipl_id_rec in c_get_oipl_id loop
        l_oipl_id := oipl_id_rec.oipl_id;
        exit;
    end loop;
    If l_oipl_id is null Then
       --dbms_output.put_line ('NO Option in Plan Found ');
        l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : Plan/Option combination TSP/' ||p_opt_name || ' is not defined in employee''s business group';
       Raise Nothing_to_do;
    End If;

    --dbms_output.put_line('l_oipl_id is ' || ' ' || l_oipl_id);
    --dbms_output.put_line('p_person_id is ' || ' ' || p_person_id);
    --dbms_output.put_line('p_effective_date is ' || ' ' || p_effective_date);

    if p_effective_date < to_date('07/01/2005','MM/DD/YYYY') then
       l_effective_date := to_date('07/01/2005','MM/DD/YYYY');
    else
       l_effective_date := p_effective_date;
    End If;

     ben_on_line_lf_evt.p_manage_life_events(
           p_person_id             => p_person_id
          ,p_effective_date        => l_effective_date
          ,p_business_group_id     => p_business_group_id
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

     --commit;
      --dbms_output.put_line('Before opening cursor    '||l_ler_id);
        --dbms_output.put_line('1.here');

      for get_elig_chc_id in c_get_elig_chc_id_opt loop
          l_elig_per_elctbl_chc_id := get_elig_chc_id.elig_per_elctbl_chc_id;
          l_per_in_ler_id := get_elig_chc_id.per_in_ler_id;
          exit;
      End Loop;
      If l_elig_per_elctbl_chc_id is null Then
          --dbms_output.put_line('No Electable choice id ');
          l_err_msg := 'Name : '|| l_name||' SSN : '||l_ssn|| '  : No electable choice found for this employee. Please ensure that the employee is eligible for  Federal Thrift Savings Plan (TSP) program';
          Raise Nothing_to_do;
      End If;

      --dbms_output.put_line('Electable choice id ' || l_elig_per_elctbl_chc_id);
      --dbms_output.put_line('PER in LER ID       ' || l_per_in_ler_id);
      --dbms_output.put_line('opt val      ' || p_opt_val);


      for get_enrt_rt_id in c_get_enrt_rt_id loop
          l_enrt_rt_id := get_enrt_rt_id.enrt_rt_id;
          exit;
      End Loop;
      If l_enrt_rt_id is null Then
          --dbms_output.put_line('No Electable rate id ');
          l_err_msg := 'Name:'|| l_name||' SSN:'||l_ssn|| '  :TSP value is outside IRS limits' ;
          Raise Nothing_to_do;
      End If;
      --dbms_output.put_line('enrt rate id ' || l_enrt_rt_id);

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

      --dbms_output.put_line('Enrollment Result id ' || l_prtt_enrt_rslt_id);
  Exception
    When ben_Enrt_Exists Then
       null;
    When Nothing_to_do Then
        rollback;
        ghr_mto_int.log_message(null,l_err_msg);
        /*
        ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  'TSP_MIG-'||to_char(sysdate,'MM/DD/YYYY'),
             p_log_text                =>  l_err_msg,
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             ); */
        --dbms_output.put_line('Data Issue... Nothing_to_do! ');
   When others then
        --dbms_output.put_line('Script Failed. Contact Your System Administrator.! ');
        rollback;
        l_err_msg := 'Name :'|| l_name||' SSN :'||l_ssn;
        ghr_mto_int.log_message(null,l_err_msg||' '||sqlerrm(sqlcode));
        /* ghr_wgi_pkg.create_ghr_errorlog
            (p_program_name            =>  'TSP_MIG-'||to_char(sysdate,'MM/DD/YYYY'),
             p_log_text                =>  'PERSON ID:'||p_person_id || ' ' || sqlerrm(sqlcode),
             p_message_name            =>  null,
             p_log_date                =>  sysdate
             ); */
   End  ghr_tsp_migrate;


   /* TSP Catch Up Migration Procedure */
   Procedure ghr_tsp_catchup_migrate(
        p_assignment_id     in per_assignments_f.assignment_id%type,
        p_opt_name          in Varchar2,
        p_opt_val           in Number,
        p_effective_date    in Date,
        p_business_group_id in per_assignments_f.business_group_id%type,
        p_person_id         in per_assignments_f.person_id%type)  is

     l_prog_count              number;
     l_plan_count              number;
     l_oipl_count              number;
     l_person_count            number;
     l_plan_nip_count          number;
     l_oipl_nip_count          number;

     l_pgm_id                ben_pgm_f.pgm_id%type;
     l_pl_id                 ben_pl_f.pl_id%type;
     l_opt_id                ben_opt_f.opt_id%type;
     l_pl_typ_id             ben_pl_typ_f.pl_typ_id%type;
     l_plip_id               ben_plip_f.plip_id%type;
     l_oipl_id               ben_oipl_f.oipl_id%type;
     l_ler_id                ben_ler_f.ler_id%type;
     l_ptip_id               ben_ptip_f.ptip_id%type;
     l_exists                boolean;
     l_ovn                   number;
     l_errbuf                varchar2(2000);
     l_retcode               number;
     l_elig_per_elctbl_chc_id number;
     l_prtt_enrt_rslt_id     number;
     l_enrt_rt_id            number;
     l_enrt_bnft_id          number;
     l_opt_val               number;
     l_prtt_rt_val_id        number;
     l_prtt_rt_val_id1       number;
     l_prtt_rt_val_id2       number;
     l_prtt_rt_val_id3       number;
     l_prtt_rt_val_id4       number;
     l_prtt_rt_val_id5       number;
     l_prtt_rt_val_id6       number;
     l_prtt_rt_val_id7       number;
     l_prtt_rt_val_id8       number;
     l_prtt_rt_val_id9       number;
     l_prtt_rt_val_id10      number;
     l_suspend_flag          varchar2(30);
     l_esd                   date;
     l_eed                   date;
     l_prtt_enrt_interim_id  number;
     L_boolean               boolean;
     l_per_in_ler_id         number;
     l_benefit_action_id     number;
     l_err_msg               varchar2(2000);
     Nothing_To_Do           Exception;
     Ben_Enrt_Exists         Exception;

     l_name                  Varchar2(240);
     l_ssn                   Varchar2(30);
     l_effective_date        date;

     -- Cursor to get Pgm_id for the given Business Group
     Cursor c_get_pgm_id is
       select pgm.pgm_id
       from   ben_pgm_f pgm
       where  pgm.name = 'Federal Thrift Savings Plan (TSP) Catch Up Contributions'
       and    pgm.business_group_id  = p_business_group_id;

     --Cursor to get the Plan Type Id for the given  Business_group_id
     Cursor c_get_pl_typ_id is
       select plt.pl_typ_id
       from   ben_pl_typ_f plt
       where  plt.name =  'Savings Plan'
       and    plt.business_group_id = p_business_group_id;

-- Cursor to get the Ptip_id for the given Pgm and Plan Type.
      Cursor c_get_ptip_id is
        select ptip_id
        from   ben_ptip_f
        where  pl_typ_id = l_pl_typ_id
        and    pgm_id = l_pgm_id;

     -- Cursor to get the Plan Id
     Cursor c_get_pl_id is
       select pln.pl_id  pl_id
       from   ben_pl_f pln
       where  pln.name = 'TSP Catch Up'
       and    pln.business_group_id = p_business_group_id;

     --Cursor to get the plan in Program Id for the given Pl_id
     Cursor c_get_plip_id is
       select plip.plip_id
       from   ben_plip_f plip
       where  plip.pl_id  =    l_pl_id
       and    plip.pgm_id = l_pgm_id
       and    plip.business_group_id = p_business_group_id;

     --Cursor to get the opt_id for the EE's Enrollment Screen Entry Value
     Cursor c_get_opt_id is
      Select opt_id
      from   ben_opt_f opt
      where  name = p_opt_name
      and    opt.business_group_id = p_business_group_id;

     -- Cursor to get the option in plan Id
     Cursor c_get_oipl_id is
       select oipl_id
       from   ben_oipl_f
       where  pl_id =  l_pl_id
       and    opt_id = l_opt_id
       and    business_group_id = p_business_group_id;

-- Cursor to get the elig_chc_id for the plan, Option
     Cursor c_get_elig_chc_id_opt is
       select elig_per_elctbl_chc_id,
              pil.per_in_ler_id
       from   ben_elig_per_ELCTBL_chc chc ,
              ben_per_in_ler pil
       where chc.pgm_id = l_pgm_id
       and   chc.pl_typ_id = l_pl_typ_id
       and   chc.pl_id = l_pl_id
       and   chc.plip_id = l_plip_id
       and   chc.ptip_id = l_ptip_id
       and   chc.oipl_id = l_oipl_id
       and   pil.per_in_ler_id = chc.per_in_ler_id
       and   pil.person_id = p_person_id;

     Cursor  c_get_enrt_rt_id is
       select enrt_rt_id
       from   ben_enrt_rt
       where  elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id;


-- Cursor to check if Employee is currently enrolled in TSP Catchup
     cursor c_emp_in_tsp is
       select 1
       from   ben_prtt_enrt_rslt_f
       where  person_id = p_person_id
       and    pgm_id    = l_pgm_id;

    Cursor c_get_ssn is
    select national_identifier
    from   per_all_people_f
    where  person_id = p_person_id
    and    trunc(p_effective_date) between effective_start_date and effective_end_date;

BEGIN
    --dbms_output.put_line('********** start ************** ' ||to_char(p_opt_val)||'   plan  ' ||p_opt_name);

    -- Get PGM ID
    for pgm_rec in c_get_pgm_id loop
        l_pgm_id := pgm_rec.pgm_id;
        exit;
    end loop;
    If l_pgm_id is null Then
       --dbms_output.put_line ('NO program found ');
       l_err_msg := 'Federal Thrift Savings Plan (TSP) Catch Up Contributions program not defined in employee''s business group ' ;
       Raise Nothing_to_do;
    End If;

    --get Full Name
    l_name := ghr_pa_requests_pkg.get_full_name_unsecure(p_person_id,p_effective_date);
    --dbms_output.put_line ('Full Name        '||l_name);

    --get SSN
    For get_ssn in c_get_ssn loop
            l_ssn := get_ssn.national_identifier;
            exit;
    End loop;
    --dbms_output.put_line ('SSN              '||l_ssn);

    --Check if record already exists in the Ben table for this person
    l_exists := FALSE;
    for emp_tsp_rec in c_emp_in_tsp loop
      l_exists :=  TRUE;
      exit;
    end loop;
    If l_exists then
      --dbms_output.put_line('No Action' );
      Raise ben_enrt_exists;
    End If;

    For plt_rec in c_get_pl_typ_id loop
        l_pl_typ_id := plt_rec.pl_typ_id;
        exit;
    end loop;
    --dbms_output.put_line('pl_typ id'|| ' ' ||l_pl_typ_id );

    for ptip_rec in c_get_ptip_id loop
        l_ptip_id :=  ptip_rec.ptip_id;
        exit;
    end loop;
    --dbms_output.put_line('ptip id'|| ' ' ||l_ptip_id );

    --get pl_id,opt_id,opil_id,electible_choice_id

    for pl_rec in c_get_pl_id loop
        l_pl_id := pl_rec.pl_id;
        exit;
    end loop;
    --dbms_output.put_line(' l_plan_id ' || l_pl_id);
    If l_pl_id is null Then
       --dbms_output.put_line ('NO plan found ');
       l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : TSP Catch Up Plan is not valid for migration ';
       Raise Nothing_to_do;
      End If;

    for opt_rec in c_get_opt_id loop
        l_opt_id := opt_rec.opt_id;
        exit;
    end loop;
    If l_opt_id is null Then
       --dbms_output.put_line ('NO option found ');
       l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : Option ' || p_opt_name  ||' is not valid for migration ';
       Raise Nothing_to_do;
    End If;
    --dbms_output.put_line('opt id'|| ' ' ||l_opt_id );

      -- get plip_id
    for  plip_id_rec in c_get_plip_id loop
        l_plip_id := plip_id_rec.plip_id;
        exit;
    end loop;
    --dbms_output.put_line('plip id'|| ' ' ||l_plip_id );

      -- get oipl_id
    for oipl_id_rec in c_get_oipl_id loop
        l_oipl_id := oipl_id_rec.oipl_id;
        exit;
    end loop;
    If l_oipl_id is null Then
       --dbms_output.put_line ('NO Option in Plan Found ');
        l_err_msg := 'Employee Name : '|| l_name||' SSN : '||l_ssn|| ' : Plan/Option combination TSP Catch Up/' ||p_opt_name || ' is not defined in employee''s business group';
       Raise Nothing_to_do;
    End If;

    --dbms_output.put_line('l_oipl_id is ' || ' ' || l_oipl_id);
    --dbms_output.put_line('p_effective_date is ' || ' ' || p_effective_date);

    if p_effective_date < to_date('07/01/2005','MM/DD/YYYY') then
       l_effective_date := to_date('07/01/2005','MM/DD/YYYY');
    else
       l_effective_date := p_effective_date;
    End If;

     ben_on_line_lf_evt.p_manage_life_events(
           p_person_id             => p_person_id
          ,p_effective_date        => l_effective_date
          ,p_business_group_id     => p_business_group_id
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


      --dbms_output.put_line('Before opening cursor    '||l_oipl_id);
        --dbms_output.put_line('1.here');

      for get_elig_chc_id in c_get_elig_chc_id_opt loop
          l_elig_per_elctbl_chc_id := get_elig_chc_id.elig_per_elctbl_chc_id;
          l_per_in_ler_id := get_elig_chc_id.per_in_ler_id;
          exit;
      End Loop;
      If l_elig_per_elctbl_chc_id is null Then
          --dbms_output.put_line('No Electable choice id ');
          l_err_msg := 'Name : '|| l_name||' SSN : '||l_ssn|| '  : No electable choice found for this employee.Please ensure that the employee is eligible for Federal Thrift Savings Plan (TSP) Catch Up Contributions program';
          Raise Nothing_to_do;
      End If;

      --dbms_output.put_line('Electable choice id ' || l_elig_per_elctbl_chc_id);
      --dbms_output.put_line('PER in LER ID       ' || l_per_in_ler_id);
      --dbms_output.put_line('opt val      ' || p_opt_val);

      for get_enrt_rt_id in c_get_enrt_rt_id loop
          l_enrt_rt_id := get_enrt_rt_id.enrt_rt_id;
          exit;
      End Loop;
      If l_enrt_rt_id is null Then
          --dbms_output.put_line('No Electable rate id ');
          l_err_msg := 'Name :'|| l_name||' SSN :'||l_ssn|| '  :TSP Catch Up value is outside IRS limits' ;
          Raise Nothing_to_do;
      End If;
      --dbms_output.put_line('enrt rate id ' || l_enrt_rt_id);
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
      --dbms_output.put_line('Enrollment Result id ' || l_prtt_enrt_rslt_id);
  Exception
    When ben_Enrt_Exists Then
       null;
    When Nothing_to_do Then
        rollback;
        ghr_mto_int.log_message(null,l_err_msg);
        --dbms_output.put_line('Data Issue... Nothing_to_do! ');
   When others then
        --dbms_output.put_line('Script Failed. Contact Your System Administrator.! ');
        rollback;
        l_err_msg := 'Name :'|| l_name||' SSN :'||l_ssn;
        ghr_mto_int.log_message(null,l_err_msg||' '||sqlerrm(sqlcode));
   End  ghr_tsp_catchup_migrate;

end ghr_general;

/
