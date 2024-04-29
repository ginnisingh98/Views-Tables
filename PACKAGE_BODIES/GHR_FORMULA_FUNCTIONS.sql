--------------------------------------------------------
--  DDL for Package Body GHR_FORMULA_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_FORMULA_FUNCTIONS" AS
  /* $Header: ghforfun.pkb 120.7.12010000.5 2009/07/07 06:48:15 utokachi ship $ */

  --
  -- Package Variables
  --
  g_package  varchar2(100) := 'ghr_formula_functions.';
  g_old_tsp_status   Varchar2(1);
  g_new_tsp_status   Varchar2(1);
  --
  --
  --


  FUNCTION get_plan_eligibility(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pl_id              in number
                               )
           RETURN varchar2 is

    Cursor c_get_primary_address(l_person_id in Number)  is
      select style,region_2
      from   per_addresses_v
      where  person_id = l_person_id
      and    primary_flag = 'Y';

   Cursor c_check_if_nationwide_plan(l_plan_code in varchar2) is
      select distinct 'N'
      from   ghr_plan_service_areas_f
      where  plan_short_code = l_plan_code
      and    p_effective_date between effective_start_date and effective_end_date;

   Cursor c_get_plan_duty_station(l_plan_code in varchar2
                                ,l_ds_code in Varchar2) Is
      select 'Y'
      from   ghr_plan_service_areas_f
      where  plan_short_code = l_plan_code
      and    ds_state_code   = l_ds_code
      and    p_effective_date between effective_start_date and effective_end_date;

   Cursor c_get_plan_state(l_plan_code in varchar2,l_state_code in Varchar2) Is
      select 'Y'
      from   ghr_plan_service_areas_f
      where  plan_short_code  = l_plan_code
      and    state_short_name = l_state_code
      and    p_effective_date between effective_start_date and effective_end_date;
-------------------------------------------------------------------------------
--
-- Cursor modified for Payroll Integration
--
   Cursor c_get_elements
   is
       select element_name
       from   pay_element_types_f elt
       where  element_type_id in
           (select element_type_id
            from   pay_element_links_f
            where  element_link_id in
                (select element_link_id
                 from   pay_element_entries_f
                 where  assignment_id = p_asg_id
                 and    p_effective_date between effective_start_date and effective_end_date)
           and p_effective_date between effective_start_date and effective_end_date)
       and upper(element_name) =
      upper(pqp_fedhr_uspay_int_utils.return_new_element_name
         ('Health Benefits Pre tax',p_business_group_id,p_effective_date,NULL))
       and p_effective_date between effective_start_date and effective_end_date
       and (elt.business_group_id is null or elt.business_group_id= p_business_group_id );
--
-- Added business_group_id stripping for Payroll Integration
--
-------------------------------------------------------------------------------
--
-- Cursor modified for Payroll Integration
--
   Cursor c_get_elements_health
   is
       select element_name
       from   pay_element_types_f elt
       where  element_type_id in
           (select element_type_id
            from   pay_element_links_f
            where  element_link_id in
                (select element_link_id
                 from   pay_element_entries_f
                 where  assignment_id = p_asg_id
                 and    p_effective_date between effective_start_date and effective_end_date)
           and p_effective_date between effective_start_date and effective_end_date)
       and upper(element_name) =
                        upper(pqp_fedhr_uspay_int_utils.return_new_element_name
                         ('Health Benefits',p_business_group_id,p_effective_date,NULL))
       and p_effective_date between effective_start_date and effective_end_date
       and (elt.business_group_id is null or elt.business_group_id= p_business_group_id);
--
-- Added business_group_id stripping for Payroll Integration
--
  l_procedure_name                  varchar2(100);
  v_location_id                     number;
  v_element_name                    varchar2(240);
  v_element_name_health             varchar2(240);
  v_duty_station_code               varchar2(9);
  v_duty_station_desc               varchar2(126);
  v_locality_pay_area               varchar2(100);
  v_locality_pay_area_percentage    number;
  v_ds_state_code                   varchar2(2);
  v_plan_short_code                 varchar2(30);
  v_eligible                        varchar2(1);
  v_person_id                       number;
  v_address_style                   varchar2(30);
  v_region_2                        varchar2(120);
  v_cnt                             number;
  v_exists                          varchar2(1);
  nationwide_plan                   varchar2(1);

  BEGIN
     l_procedure_name :=  g_package || 'get_plan_eligibility';
    --hr_utility.set_location('Entering:'|| l_procedure_name, 10);
    --hr_utility.trace_on(1,'BG');

    /* Get person id and location id */

    -- change this to cursor
    select asg.person_id,
           asg.location_id
     into  v_person_id,
           v_location_id
     from  per_all_people_f per,
           per_assignments_f asg
   where   asg.assignment_id = p_asg_id
     and   asg.business_group_id = p_business_group_id
     and   p_effective_date between asg.effective_start_date and asg.effective_end_date
     and   per.person_id = asg.person_id
     and   per.business_group_id = p_business_group_id
     and   p_effective_date between per.effective_start_date and per.effective_end_date;

    hr_utility.set_location(l_procedure_name,20);
    hr_utility.trace('v_person id   =  ' ||v_person_id   );
    hr_utility.trace('v_location id =  ' ||v_location_id );

    /* get plan short code */
    select short_code into v_plan_short_code
    from   ben_pl_f
    where  pl_id = p_pl_id
    and    p_effective_date between effective_start_date and effective_end_date;

    hr_utility.set_location(l_procedure_name,30);
    hr_utility.trace('v_plan_short_code =  ' || v_plan_short_code);


    -- with june 2005 deliverable, there would be only plan Decline Coverage wuth short code ZZ
    --If v_plan_short_code in ('DCA','DCP') Then
    If v_plan_short_code in ('ZZ') Then
       /* Decline Coverage */
       hr_utility.set_location(l_procedure_name,40);
       v_eligible := 'Y';
    Else
       hr_utility.set_location(l_procedure_name,50);
       /* Check If nation wide plan */
       Open c_check_if_nationwide_plan(v_plan_short_code);
       Fetch c_check_if_nationwide_plan into nationwide_plan;
       If c_check_if_nationwide_plan%NOTFOUND Then
          nationwide_plan := 'Y';
       End If;
       if nationwide_plan = 'Y' Then
          v_eligible := 'Y';
       ElsE
          hr_utility.set_location(l_procedure_name,60);
          /* get duty station code */
          ghr_per_sum.get_duty_station_details
                    (v_location_id,
                     p_effective_date,
                     v_duty_station_code,
                     v_duty_station_desc ,
                     v_locality_pay_area,
                     v_locality_pay_area_percentage
                    );

          hr_utility.set_location(l_procedure_name,70);
          hr_utility.trace('v_duty_station_code =  ' || v_duty_station_code);

          v_ds_state_code := substr(v_duty_station_code,1,2);

          IF substr(v_ds_state_code,1,1) between 'A' and 'Z'  and
               substr(v_ds_state_code,2,1) <> 'Q' Then   /* Foreign Duty Station */
                hr_utility.set_location(l_procedure_name,80);
                v_eligible := 'N';
          ELSE
             hr_utility.set_location(l_procedure_name,90);

             Open c_get_plan_duty_station(v_plan_short_code,v_ds_state_code);
             Fetch c_get_plan_duty_station into v_exists;
             if c_get_plan_duty_station%NOTFOUND Then
                v_exists := 'N';
             End If;
             If v_exists = 'Y' Then
                v_eligible := 'Y';
             ELSE
               hr_utility.set_location(l_procedure_name,100);
              /* Check for address style and value for region2 (state code)*/
              /* of primary address */
                 Open c_get_primary_address(v_person_id);
                 Fetch c_get_primary_address into v_address_style,v_region_2;
                 If c_get_primary_address%NOTFOUND then
                    v_eligible := 'N';
                 Else
                    hr_utility.set_location(l_procedure_name,110);
                    hr_utility.trace('v_address_style =  ' || v_address_style);
                     --Bug# 4725292 Included US_GLB_FED
                    IF v_address_style in ('US','US_GLB','US_GLB_FED') Then    /* US STYLE ADDRESS*/
                        hr_utility.set_location(l_procedure_name,120);
                        IF v_region_2 is null Then
                           v_eligible := 'N';
                        ELSE
                           hr_utility.set_location(l_procedure_name,130);
                           Open c_get_plan_state(v_plan_short_code,v_region_2);
                           Fetch c_get_plan_state into v_exists;
                           If c_get_plan_state%NOTFOUND then
                                  v_eligible := 'N';
                           Else
                                  v_eligible := 'Y';
                           End If;
                        End If;
                    Else
                        v_eligible := 'N';
                    End If;
                 End If;
             End If;
         End If;
       End If;
    End If;
  If c_check_if_nationwide_plan%ISOPEN then
     Close c_check_if_nationwide_plan;
  End If;
  If c_get_primary_address%ISOPEN then
     Close c_get_primary_address;
  End If;
  If c_get_plan_duty_station%ISOPEN then
     Close c_get_plan_duty_station;
  End If;
  If c_get_plan_state%ISOPEN then
     Close c_get_plan_state;
  End If;
  hr_utility.trace('v_eligible =  ' || v_eligible);
  hr_utility.set_location(' Leaving:'||l_procedure_name, 1000);
  Return v_eligible;
Exception
  when others then
     hr_utility.set_location(' Leaving:'||l_procedure_name, 110);
     If c_check_if_nationwide_plan%ISOPEN then
         Close c_check_if_nationwide_plan;
     End If;
     if c_get_primary_address%ISOPEN Then
        CLOSE c_get_primary_address;
     End If;
     if c_get_plan_duty_station%ISOPEn Then
     hr_utility.set_location(' Leaving:'||l_procedure_name, 120);
        CLOSE c_get_plan_duty_station;
     End If;
     if c_get_plan_state%ISOPEN Then
        hr_utility.set_location(' Leaving:'||l_procedure_name, 130);
        CLOSE c_get_plan_state;
     End If;
     if c_get_elements%ISOPEN Then
        hr_utility.set_location(' Leaving:'||l_procedure_name, 140);
        CLOSE c_get_elements;
     End If;

     Return 'N';

End get_plan_eligibility;


Function get_plan_short_code (  p_business_group_id in Number
                               ,p_effective_date    in Date
                               ,p_pl_id             in Number)
            RETURN varchar2  is

  v_pln_short_code   ben_pl_f.short_code%type;
  l_procedure_name   varchar2(100);

  Cursor C1 is
    select short_code from ben_pl_f
    where  pl_id = p_pl_id
    and    p_effective_date between effective_start_date and effective_end_date;
Begin
   l_procedure_name   :=  g_package || 'get_plan_short_code';
   hr_utility.set_location('Entering:'|| l_procedure_name, 10);
   for i in c1 loop
       v_pln_short_code := i.short_code;
   End Loop;
   hr_utility.trace('v_pln_short_code =  ' || v_pln_short_code);
   /*If v_pln_short_code in ('DCA','DCP')  then -- Decline Coverage
       v_pln_short_code := null;
   End If;  */
   hr_utility.set_location('Leaving:'|| l_procedure_name, 20);
   Return v_pln_short_code;
Exception
  when others then
     hr_utility.set_location(' Leaving:'||l_procedure_name, 30);
     hr_utility.trace('Error '  || sqlerrm(sqlcode));
End get_plan_short_code;


   FUNCTION get_option_short_code(
                                   p_business_group_id in number
                                  ,p_effective_date    in date
                                  ,p_opt_id            in number)
            RETURN varchar2  is

  v_opt_short_code   ben_opt_f.short_code%type;
  l_procedure_name   varchar2(100);

  Cursor C1 is
    select short_code from ben_opt_f
    where  opt_id = p_opt_id
    and    p_effective_date between effective_start_date and effective_end_date;
Begin
   l_procedure_name   :=  g_package || '.get_option_short_code';
   hr_utility.set_location('Entering:'|| l_procedure_name, 10);
   hr_utility.trace('p_opt_id =  ' || p_opt_id);
   hr_utility.trace('p_effective_date =  ' || p_effective_date);
   If p_opt_id = -1 Then /* Decline Coverage */
      v_opt_short_code := 'Y';
   Else
     for i in c1 loop
        v_opt_short_code := i.short_code;
     End Loop;
   End If;
   hr_utility.trace('v_opt_short_code =  ' || v_opt_short_code);
   hr_utility.set_location('Leaving:'|| l_procedure_name, 20);
   Return substr(v_opt_short_code,1,1);
Exception
  when others then
     hr_utility.set_location(' Leaving:'||l_procedure_name, 30);
     hr_utility.trace('Error '  || sqlerrm(sqlcode));
End get_option_short_code;

function chk_person_type(
                    p_business_group_id in Number,p_assignment_id in number
                    )
            RETURN varchar2  is
  l_procedure_name   varchar2(100);
  l_person_type per_person_types.system_person_type%type;
  l_person_id  per_people_f.person_id%type;
  l_session_date fnd_sessions.effective_date%type;
  cursor c_get_session_date is
    select trunc(effective_date) session_date
      from fnd_sessions
      where session_id = (select userenv('sessionid') from dual);
  cursor c_per_id is
    select person_id from
    per_assignments_f
    where assignment_id     = p_assignment_id
    and business_group_id   = p_business_group_id
    and primary_flag        = 'Y'
    and assignment_type    <> 'B'
    and l_session_date
    between effective_start_date
    and effective_end_date;
  cursor get_person_type is
    SELECT pty.system_person_type
    FROM per_people_f ppf, per_person_types pty
    WHERE  ppf.person_id = l_person_id
    AND    l_session_date
    BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND    ppf.person_type_id = pty.person_type_id
    AND    pty.business_group_id = p_business_group_id
    AND    pty.active_flag = 'Y';
Begin
   l_procedure_name   :=  g_package || '.chk_person_type';
   hr_utility.set_location('Entering:'|| l_procedure_name, 10);
   -- Get Session Date
     l_session_date := trunc(sysdate);
   for ses_rec in c_get_session_date loop
     l_session_date := ses_rec.session_date;
   end loop;
   hr_utility.set_location('Entering:'|| l_procedure_name, 11);
     hr_utility.set_location('p_assignment_id    '||p_assignment_id,11);
     hr_utility.set_location('p_bg_id       '||p_business_group_id,11);
   -- Get Person id for given assignment id and BG id
   for c_per_rec in c_per_id loop
    l_person_id := c_per_rec.person_id;
    exit;
   end loop;
   hr_utility.set_location('l_person_id '||l_person_id,12);
   -- Find whether the person is a employee or not
   IF l_person_id is not null then
     FOR c_person_type in get_person_type loop
     l_person_type := c_person_type.system_person_type;
     END LOOP;
     hr_utility.set_location('l_person_type '||l_person_type,15);
     IF l_person_type = 'EMP' then
       return 'Y';
     ELSE
       return 'N';
     END IF;
   END IF;
   return 'N';
   hr_utility.set_location('Leaving:'|| l_procedure_name, 20);
Exception
  when others then
     hr_utility.set_location(' Leaving:'||l_procedure_name, 30);
     hr_utility.trace('Error '  || sqlerrm(sqlcode));
End chk_person_type;

   function get_retirement_plan( p_business_group_id in Number
                                ,p_asg_id            in Number
                                ,p_effective_date    in Date )
            RETURN VARCHAR2   Is

  l_proc_name                 varchar2(100);
  v_retirement_plan           VARCHAR2(50);
  l_multi_error_flag          Boolean;

  Begin
    l_proc_name  :=  g_package || '.get_retirement_plan';
    hr_utility.set_location('Entering    ' ||l_proc_name,10);
    hr_utility.trace('p_asg_id   =  ' ||p_asg_id   );

       -- Get Retirement Plan
    ghr_api.retrieve_element_entry_value
               (p_element_name          => 'Retirement Plan'
               ,p_input_value_name      => 'Plan'
               ,p_assignment_id         => p_asg_id
               ,p_effective_date        => p_effective_date
               ,p_value                 => v_retirement_plan
               ,p_multiple_error_flag   => l_multi_error_flag);

    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('v_retirement_plan   =  ' ||v_retirement_plan );


    hr_utility.set_location('Leaving    ' ||l_proc_name,100);
    Return  v_retirement_plan;
  Exception
    when others then
     hr_utility.set_location(' Leaving:'||l_proc_name, 110);
     Return null;
  End get_retirement_plan;

   function get_employee_tsp_eligibility( p_business_group_id in Number
                                         ,p_asg_id            in Number
                                         ,p_effective_date    in Date )
            RETURN VARCHAR2   Is

  l_proc_name                varchar2(100);
  v_eligible                 varchar2(1);
  v_retirement_plan          pay_element_entry_values_f.screen_entry_value%type;
  v_effective_start_date     pay_element_entry_values_f.effective_start_date%type;
  v_per_system_status        per_assignment_status_types.per_system_status%type;
  v_annuitant_indicator      varchar2(50);
  v_asg_ei_data              per_assignment_extra_info%rowtype;

  Begin
    l_proc_name   :=  g_package || '.get_employee_tsp_eligibility';
    hr_utility.set_location('Entering    ' ||l_proc_name,10);
    hr_utility.trace('p_asg_id   =  ' ||p_asg_id   );

    v_retirement_plan := ghr_formula_functions.get_retirement_plan( p_business_group_id
                                                                   ,p_asg_id
                                                                   ,p_effective_date);
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('v_retirement_plan   =  ' ||v_retirement_plan);

    v_eligible := 'N';
    If v_retirement_plan is null Then
       v_eligible := 'N';
    Elsif v_retirement_plan in ('C','E','G','K','L','M','N','P','R','T','1','3','6','D','F','H','W') Then
       v_eligible := 'Y';
    Elsif v_retirement_plan in ('2','4','5') then
       ghr_history_fetch.fetch_asgei(p_assignment_id    =>  p_asg_id,
                                     p_information_type => 'GHR_US_ASG_SF52',
                                     p_date_effective   =>  p_effective_date,
                                     p_asg_ei_data      =>  v_asg_ei_data);
       v_annuitant_indicator   :=  v_asg_ei_data.aei_information5;
       hr_utility.trace('v_annuitant_indicator   =  ' ||v_annuitant_indicator);
       If v_annuitant_indicator not in ('2','3','9') then
          v_eligible := 'Y';
       Else
          v_eligible := 'N';
       End If;
    Else
       v_eligible := 'N';
    End If;
    hr_utility.set_location('Leaving    ' ||l_proc_name,100);
    hr_utility.trace('v_eligible   =  ' ||v_eligible   );
    Return  v_eligible;
  Exception
    when others then
     hr_utility.set_location(' Leaving:'||l_proc_name, 110);
     hr_utility.trace('Error:    ' ||sqlerrm(sqlcode));
     Return 'N';
  End get_employee_tsp_eligibility;

  function check_if_emp_csrs(  p_business_group_id in Number
                              ,p_asg_id            in Number
                              ,p_effective_date    in Date )
            RETURN VARCHAR2 is

  l_proc_name                varchar2(100);
  v_eligible                 varchar2(1);
  v_effective_start_date     pay_element_entry_values_f.effective_start_date%type;
  v_retirement_plan          pay_element_entry_values_f.screen_entry_value%type;
  Begin
    l_proc_name  :=  g_package || '.check_if_emp_csrs';
    hr_utility.set_location('Entering   '||l_proc_name,10);
    hr_utility.trace('p_asg_id   =  ' ||p_asg_id   );
    v_retirement_plan := ghr_formula_functions.get_retirement_plan( p_business_group_id
                                                                   ,p_asg_id
                                                                   ,p_effective_date);
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('ret plan   =  ' ||v_retirement_plan);

    If v_retirement_plan in ('1','3','6','C','E','F','G','H','R','T','W') Then
       v_eligible := 'Y';
    ElsIf v_retirement_plan in ('2','4','5') then
       v_eligible := 'Y';
    Else
       v_eligible := 'N';
    End If;
    hr_utility.set_location('Leaving   '||l_proc_name,10);
    hr_utility.trace('v_eligible   =  ' ||v_eligible   );
    Return v_eligible;
  Exception
    when others then
     hr_utility.set_location('Exception Leaving:'||l_proc_name, 110);
     Return 'N';
  End check_if_emp_csrs;
 ---------------

  Function get_emp_annual_salary(p_assignment_id    in Number,
                                 p_effective_date   in Date
                                )
      return Number is

      l_proc_name                     varchar2(100);

  Begin
       l_proc_name   :=  g_package|| 'get_emp_annual_salary';
       hr_utility.set_location('Entering  '||l_proc_name,10);
       hr_utility.set_location('Leaving  '||l_proc_name,10);

      return 1;
   Exception
     When Others Then
      hr_utility.set_location('Exception Leaving   ' ||l_proc_name,200);
      hr_utility.trace('Error '  || sqlerrm(sqlcode));
   End get_emp_annual_salary;

  -- Function to validate tsp amount as entered by the user
  FUNCTION ghr_tsp_amount_validation(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pgm_id             in number
                                ,p_pl_id              in number
                               )
     Return Varchar2 is


     l_proc_name              varchar2(100);
     l_result                 Varchar2(1);
     l_person_id              per_all_people_f.person_id%type;
     l_tsp_amount             Number;
     l_prtt_enrt_rslt_id      ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type;
     l_payroll_id             pay_payrolls_f.payroll_id%type;
     l_enrt_cvg_strt_dt       Date;
     l_effective_date         Date;

     Cursor c_get_person_id is
     Select person_id,payroll_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_get_prtt_enrt_rslt_id is
     select enrt_cvg_strt_dt,rt_val
     from   ben_prtt_enrt_rslt_f perf , ben_prtt_rt_val prv
     where  perf.person_id = l_person_id
     and    perf.pgm_id    = p_pgm_id
     and    perf.pl_id     = p_pl_id
     and    perf.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
     and    trunc(l_effective_date) between perf.effective_start_date and perf.effective_end_date
     and    perf.enrt_cvg_thru_dt = hr_api.g_eot
     and    prv.rt_end_dt = hr_api.g_eot
     and    perf.prtt_enrt_rslt_stat_cd is null;

  Begin
    l_proc_name   :=  g_package|| 'ghr_tsp_amount_validation';
    l_result      := 'Y';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);

    -- get person_id
    For get_person_id in c_get_person_id  loop
        l_person_id := get_person_id.person_id;
        l_payroll_id := get_person_id.payroll_id;
        Exit;
    End Loop;
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('l_person_id   =  ' ||l_person_id );
    hr_utility.trace('p_pgm_id   =  ' ||p_pgm_id );
    hr_utility.trace('p_pl_id   =  ' ||p_pl_id );
    hr_utility.trace('p_effective_date   =  ' ||p_effective_date );
    --dbms_output.put_line('per id   ' ||l_person_id||'  pl id:' ||p_pl_id||' pgmid:'||p_pgm_id);

    ghr_history_api.get_session_date(l_effective_date);
    hr_utility.trace('l_effective_date   =  ' ||l_effective_date );
    --Get Prtt Enrt Rslt id
    For get_prtt_enrt_rslt_id in c_get_prtt_enrt_rslt_id loop
        l_enrt_cvg_strt_dt   := get_prtt_enrt_rslt_id.enrt_cvg_strt_dt;
        l_tsp_amount         := get_prtt_enrt_rslt_id.rt_val;
        exit;
    End loop;
    hr_utility.set_location(l_proc_name,30);
    hr_utility.trace('l_enrt_cvg_strt_dt   =  ' ||l_enrt_cvg_strt_dt);
    hr_utility.trace('l_tsp_amount   =  ' ||l_tsp_amount );
    --dbms_output.put_line('AMOUNT   ' ||l_tsp_amount);

    l_tsp_amount  := nvl(l_tsp_amount,0);

    hr_utility.trace('l_tsp_amount    ' ||l_tsp_amount );
    If l_tsp_amount = 0 Then
          l_result := 'N';
    Elsif l_tsp_amount > 0 Then
       If l_enrt_cvg_strt_dt  between to_date('01/12/2004','dd/mm/yyyy')
                                     and to_date('30/11/2005','dd/mm/yyyy') Then
              If l_tsp_amount <= 14000 Then
                 l_result := 'Y';
              Else
                 l_result := 'N';
              End If;
       Elsif l_enrt_cvg_strt_dt  between to_date('01/12/2005','dd/mm/yyyy')
                                     and to_date('30/11/2006','dd/mm/yyyy') Then
              If l_tsp_amount <= 15000 Then
                 l_result := 'Y';
              Else
                 l_result := 'N';
              End If;
       Else
          l_result := 'Y';
      End If;
    End If;
    hr_utility.set_location('Leaving    '||l_proc_name,80);
    hr_utility.trace('l_result    ' ||l_result );
    return l_result;
  Exception
    When others  Then
      hr_utility.set_location('Exception Leaving   ' ||l_proc_name,200);
      hr_utility.trace('Error '  || sqlerrm(sqlcode));
      Return 'N';
  End ghr_tsp_amount_validation;



  -- Function to validate tsp percentage contributions as entered by the user
  FUNCTION ghr_tsp_percentage_validation(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pgm_id             in number
                                ,p_pl_id              in number
                               )
     Return Varchar2 is

     l_proc_name              varchar2(100);
     l_result                 Varchar2(1);
     l_person_id              per_all_people_f.person_id%type;
     l_tsp_percentage         Number;
     l_enrt_cvg_strt_dt       Date;
     l_emp_csrs               Varchar2(1);
     Nothing_to_do            Exception;
     l_effective_date         Date;

     Cursor c_get_person_id is
     Select person_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_get_tsp_percentage is
     select rt_val,enrt_cvg_strt_dt
     from   ben_prtt_rt_val , ben_prtt_enrt_rslt_f
     where  ben_prtt_rt_val.prtt_enrt_rslt_id = ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id
     and    ben_prtt_enrt_rslt_f.person_id = l_person_id
     and    ben_prtt_enrt_rslt_f.pgm_id    = p_pgm_id
     and    ben_prtt_enrt_rslt_f.pl_id     = p_pl_id
     and    trunc(l_effective_date) between ben_prtt_enrt_rslt_f.effective_start_date
                                    and ben_prtt_enrt_rslt_f.effective_end_date
     and    ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt = hr_api.g_eot
     and    ben_prtt_rt_val.rt_end_dt = hr_api.g_eot
     and    ben_prtt_enrt_rslt_f.prtt_enrt_rslt_stat_cd is null;

  Begin
     l_proc_name   :=  g_package|| 'ghr_tsp_percentage_validation';
     l_result      := 'Y';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);

    -- get person_id
    For get_person_id in c_get_person_id  loop
        l_person_id := get_person_id.person_id;
        Exit;
    End Loop;
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('l_person_id   =  ' ||l_person_id );
    hr_utility.trace('p_pgm_id   =  ' ||p_pgm_id );
    hr_utility.trace('p_pl_id   =  ' ||p_pl_id );
    hr_utility.trace('p_effective_date   =  ' ||p_effective_date );
    --dbms_output.put_line('per id   ' ||l_person_id||'  pl id:' ||p_pl_id||' pgmid:'||p_ pgm_id);

    ghr_history_api.get_session_date(l_effective_date);
    hr_utility.trace('l_effective_date   =  ' ||l_effective_date );

    -- Get TSP Percentage entered by user.
    For get_tsp_percentage in c_get_tsp_percentage loop
        l_tsp_percentage      := get_tsp_percentage.rt_val;
        l_enrt_cvg_strt_dt    := get_tsp_percentage.enrt_cvg_strt_dt;
        exit;
    End loop;
    hr_utility.set_location(l_proc_name,30);
    hr_utility.trace('l_enrt_cvg_strt_dt   =  ' ||l_enrt_cvg_strt_dt);
    hr_utility.trace('l_tsp_percentage   =  ' ||l_tsp_percentage );
    --dbms_output.put_line('amount  ' ||l_tsp_percentage);
    --dbms_output.put_line ('enrt cvg start date   ' ||l_enrt_cvg_strt_dt);

    l_tsp_percentage := nvl(l_tsp_percentage,0);
    hr_utility.trace('l_tsp_percentage   =  ' ||l_tsp_percentage );
    If nvl(l_tsp_percentage,0) = 0 Then
       hr_utility.set_location(l_proc_name,50);
       l_result := 'N';
    Else
       hr_utility.set_location(l_proc_name,60);
       -- Check retirement Plan for an employee
       l_emp_csrs := check_if_emp_csrs( p_business_group_id,p_asg_id,l_enrt_cvg_strt_dt );
       hr_utility.set_location(l_proc_name,70);
       hr_utility.trace('l_emp_csrs   =  ' ||l_emp_csrs );

       If l_emp_csrs = 'N' Then
          If l_enrt_cvg_strt_dt  between to_date('01/12/2004','dd/mm/yyyy')
                                     and to_date('30/11/2005','dd/mm/yyyy') Then
              If l_tsp_percentage <= 15 Then
                 l_result := 'Y';
              Else
                 l_result := 'N';
              End If;
          Else
              l_result := 'Y';
           End If;
       ElsIf l_emp_csrs = 'Y' Then
           If l_enrt_cvg_strt_dt  between to_date('01/12/2004','dd/mm/yyyy')
                                     and to_date('30/11/2005','dd/mm/yyyy') Then
              If l_tsp_percentage <= 10 Then
                 l_result := 'Y';
              Else
                 l_result := 'N';
              End If;
           Else
              l_result := 'Y';
           End If;
       End If;
    End If;
    hr_utility.set_location('Leaving   ' ||l_proc_name,100);
    hr_utility.trace('l_result   =  ' ||l_result);    return l_result;
  Exception
    When Nothing_to_do Then
      hr_utility.set_location('Exception (NTD) Leaving   ' ||l_proc_name,200);
      Return l_result;
    When Others Then
      hr_utility.set_location('Exception Leaving   ' ||l_proc_name,210);
      hr_utility.trace('Error '  || sqlerrm(sqlcode));
      Return 'N';
  End ghr_tsp_percentage_validation;



  Function tsp_open_season_effective_dt (p_business_group_id in Number
                                        ,p_asg_id            in Number
                                        ,p_effective_date    in Date
                                        ,p_pgm_id            in Number)
     Return date  is

     l_proc_name             varchar2(100);
  Begin
    l_proc_name   :=  g_package|| 'tsp_open_season_effective_date';
    hr_utility.set_location('Entering    '||l_proc_name,10);
    --dbms_output.put_line(' In procedure    ' ||p_effective_date);
    hr_utility.set_location('Leaving    '||l_proc_name,100);
    Return p_effective_date;
  Exception
    When Others Then
        hr_utility.set_location('Exception  Leaving   '||l_proc_name,210);
        hr_utility.trace('Error '  || sqlerrm(sqlcode));
        Return p_effective_date;
  End tsp_open_season_effective_dt;

  Function get_emp_elig_date (p_business_group_id in Number
                             ,p_effective_date    in Date
                             ,p_asg_id            in Number
                             ,p_pgm_id            in Number
                             ,p_opt_id            in Number)
     Return Varchar2  is

     l_proc_name          varchar2(100);
  Begin
     l_proc_name  :=  g_package|| 'get_emp_elig_date';
     hr_utility.set_location('Entering   '||l_proc_name,10);
    Return p_effective_date;
  Exception
     When Others Then
        hr_utility.set_location('Exception  Leaving   '||l_proc_name,200);
        hr_utility.trace('Error '  || sqlerrm(sqlcode));
        return null;
  End get_emp_elig_date;

  Function get_tsp_status_date (p_asg_id            in Number
                               ,p_effective_date    in Date)
     Return Date  is

     l_proc_name              varchar2(100);
     l_tsp_curr_status_date   varchar2(50);
     l_multi_error_flag       Boolean;
     l_effective_date         Date;
     l_pay_start_date         Date;
     l_pay_end_date           Date;
     l_tsp_status_date        date;

     Cursor c_pay_period is
     select start_date,end_date
     from   per_time_periods
     where  payroll_id in
           (select payroll_id
            from   per_assignments_f
            where  assignment_id = p_asg_id
            and    trunc(p_effective_date) between effective_start_date and effective_end_date)
     and    p_effective_date between start_date and end_date;

  Begin
     l_proc_name :=  g_package|| 'get_tsp_status_date';
     hr_utility.set_location('Entering   '||l_proc_name,10);
     hr_utility.trace('p_effective_date   =  ' ||p_effective_date   );
     for pay_period in c_pay_period loop
              l_pay_start_date := pay_period.start_date;
              l_pay_end_date := pay_period.end_date;
              exit;
     end loop;
     if p_effective_date > l_pay_start_date then
              l_effective_date := l_pay_end_date + 1;
     else
              l_effective_date := l_pay_start_date;
     End If;
     hr_utility.trace('l_effective_date    ' ||l_effective_date );
     hr_utility.trace('old_status     ' ||g_old_tsp_status );
     hr_utility.trace('new_status     ' ||g_new_tsp_status );
     if g_old_tsp_status = g_new_tsp_status then
         ghr_api.retrieve_element_entry_value
                      (p_element_name          => 'TSP'
                      ,p_input_value_name      => 'Status Date'
                      ,p_assignment_id         => p_asg_id
                      ,p_effective_date        => p_effective_date - 1
                      ,p_value                 => l_tsp_curr_status_date
                      ,p_multiple_error_flag   => l_multi_error_flag);
         hr_utility.trace('l_tsp_curr_status_date    ' ||l_tsp_curr_status_date );
         l_tsp_status_date :=  to_date(l_tsp_curr_status_date,'yyyy/mm/dd hh24:mi:ss');
    else
      l_tsp_status_date:= p_effective_date;
    end if;
    hr_utility.trace('l_tsp_status_date   =  ' ||l_tsp_status_date   );
    return l_tsp_status_date;
  End get_tsp_status_date;

  Function get_tsp_status (p_business_group_id in Number
                          ,p_effective_date    in Date
                          ,p_opt_id            in Number
                          ,p_asg_id            in Number)
     Return Varchar2  is

     l_proc_name                varchar2(100);
     l_tsp_status               Varchar2(60);
     l_opt_name                 ben_opt_f.name%type;
     l_emp_csrs                 varchar2(1);
     l_tsp_curr_status          varchar2(1);
     l_val                      Varchar2(50);
     l_exists                   Varchar2(1);
     l_multi_error_flag         Boolean;
     l_pay_start_date           Date;
     l_pay_end_date             Date;
     l_effective_date           Date;
     l_tsp_curr_agency_date     Date;
     l_tsp_curr_status_date     Varchar2(50);
     l_dt                       Varchar2(50);

     Cursor c_get_tsp_option is
     Select name from ben_opt_f
     where  opt_id = p_opt_id
     and    business_group_id = p_business_group_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_pay_period is
     select start_date,end_date
     from   per_time_periods
     where  payroll_id in
           (select payroll_id
            from   per_assignments_f
            where  assignment_id = p_asg_id
            and    trunc(p_effective_date) between effective_start_date and effective_end_date)
     and    p_effective_date between start_date and end_date;


  Begin
     l_proc_name :=  g_package|| 'get_tsp_status';
     hr_utility.set_location('Entering   '||l_proc_name,10);
     For get_tsp_option in c_get_tsp_option Loop
            l_opt_name := get_tsp_option.name;
            exit;
     End Loop;
     hr_utility.trace('l_opt_name   =  ' ||l_opt_name   );
     -- Check retirement Plan for an employee
     l_emp_csrs := check_if_emp_csrs( p_business_group_id,p_asg_id,p_effective_date );
     hr_utility.trace('l_emp_csrs    ' ||l_emp_csrs );

     for pay_period in c_pay_period loop
              l_pay_start_date := pay_period.start_date;
              l_pay_end_date := pay_period.end_date;
              exit;
     end loop;
     if p_effective_date > l_pay_start_date then
              l_effective_date := l_pay_end_date + 1;
     else
              l_effective_date := l_pay_start_date;
     End If;
     hr_utility.trace('l_effective_date    ' ||l_effective_date );

     ghr_api.retrieve_element_entry_value
                      (p_element_name          => 'TSP'
                      ,p_input_value_name      => 'Status'
                      ,p_assignment_id         => p_asg_id
                      ,p_effective_date        => l_effective_date - 1
                      ,p_value                 => l_tsp_curr_status
                      ,p_multiple_error_flag   => l_multi_error_flag);
     hr_utility.trace('l_tsp_curr_status    ' ||l_tsp_curr_status );


     If l_emp_csrs = 'Y' then   -- Processing for CSRS employees (only status valid are E,Y and T)
          hr_utility.set_location('Entering Processing for CSRS   '||l_proc_name,20);
          If (l_opt_name in ('Amount', 'Percentage')) then
                l_tsp_status := 'Y';
          Elsif l_opt_name = 'Terminate Contributions' then
                if l_tsp_curr_status = 'Y' then
                   l_tsp_status := 'T';
                Else
                   l_tsp_status := l_tsp_curr_status;
                End If;
          End if;
    Else    --Processing for FERS Employee

          hr_utility.set_location('Entering Processing for FERS   '||l_proc_name,30);
          hr_utility.trace('l_effective_date    ' ||l_effective_date );
        --get Agency Contribution Date
          l_tsp_curr_agency_date := get_agency_contrib_date(p_asg_id,l_effective_date);
          hr_utility.trace('l_tsp_curr_agency_date    ' ||l_tsp_curr_agency_date );
          hr_utility.trace('l_effective_date    ' ||l_effective_date );
         --Begin Bug# 8622486
	 /* If l_tsp_curr_agency_date > l_effective_date then  --Valid status are (I,W,S)
             hr_utility.set_location('Entering Processing for FERS   '||l_proc_name,70);
              If l_opt_name in ('Amount','Percentage') Then
                 l_tsp_status := 'W';
              Elsif l_opt_name = 'Terminate Contributions' Then
                 if l_tsp_curr_status in ('W','Y') then
                    l_tsp_status := 'S';
                 else
                   l_tsp_status := l_tsp_curr_status;
                End If;
              End If;
          Else*/  --Valid New Status are Y and T
	  --End Bug# 8622486
             hr_utility.set_location('Entering Processing for FERS   '||l_proc_name,80);
              If l_opt_name in ('Amount','Percentage') Then
                 l_tsp_status := 'Y';
              Elsif l_opt_name = 'Terminate Contributions' Then
                 if l_tsp_curr_status in ('W','Y') then
                    l_tsp_status := 'T';
                 else
                   l_tsp_status := l_tsp_curr_status;
                End If;
              End If;
          --End If;--Bug# 8622486
    End If;

     hr_utility.trace('l_tsp_status   =  ' ||l_tsp_status   );
     /* Assign the values for old and new status to global variables */
     g_old_tsp_status := l_tsp_curr_status;
     g_new_tsp_status := l_tsp_status;
     hr_utility.set_location('Leaving      '||l_proc_name,100);
     Return l_tsp_status;
  Exception
     When Others Then
        hr_utility.set_location('Exception  Leaving   '||l_proc_name,200);
        hr_utility.trace('Error '  || sqlerrm(sqlcode));
        return null;
  End get_tsp_status;


  Function fn_effective_date (p_effective_date in Date)
  Return Date is
  Begin
    return p_effective_date;
  End fn_effective_date;

 Function tsp_plan_electble( p_business_group_id in Number
                             ,p_asg_id            in Number
                             ,p_pgm_id            in Number
                             ,p_pl_id             in Number
                             ,p_ler_id            in Number
                             ,p_effective_date    in Date
                             ,p_opt_id            in Number)
            RETURN VARCHAR2   Is

      l_proc_name          varchar2(100);
      l_eligible           Varchar2(1);
      l_emp_dt             Varchar2(50);
      l_exists             Varchar2(1);
      l_emp_csrs           Varchar2(1);
      l_multi_error_flag   Boolean;
      l_effective_date     Date;
      l_pay_start_date     Date;
      l_pay_end_date       Date;
      l_agency_dt          Varchar2(50);
      l_opt_name           ben_opt_f.name%type;

     Cursor c_pay_period is
     select start_date,end_date
     from   per_time_periods
     where  payroll_id in
           (select payroll_id
            from   per_assignments_f
            where  assignment_id = p_asg_id
            and    trunc(p_effective_date) between effective_start_date and effective_end_date)
     and    p_effective_date between start_date and end_date;

     Cursor c_get_option_name is
     select name
     from   ben_opt_f
     where  opt_id = p_opt_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;
  Begin

     l_proc_name :=  g_package|| 'tsp_plan_electble';
     hr_utility.set_location('Entering   '||l_proc_name,10);
     for pay_period in c_pay_period loop
              l_pay_start_date := pay_period.start_date;
              l_pay_end_date := pay_period.end_date;
              exit;
     end loop;
     if p_effective_date > l_pay_start_date then
              l_effective_date := l_pay_end_date + 1;
     else
              l_effective_date := l_pay_start_date;
     End If;
     hr_utility.trace('l_effective_date    ' ||l_effective_date );

         -- Check retirement Plan for an employee
         -- if retirement plan is any of FERS plan and Agency Contribution date is not entered
         -- then employee cannot make elections.
     --Bug# 8622486 Removed Agency Contrib Date condition
     /*l_emp_csrs := check_if_emp_csrs( p_business_group_id,p_asg_id,l_effective_date );
     hr_utility.trace('l_emp_csrs    ' ||l_emp_csrs );
     if l_emp_csrs = 'N' Then
           hr_utility.set_location('Entering   '||l_proc_name,20);
           l_agency_dt := get_agency_contrib_date(p_asg_id,l_effective_date);
           hr_utility.trace('l_agency_dt   =  ' ||l_agency_dt   );
           if l_agency_dt is null Then
                 l_eligible := 'N';
           else
                 l_eligible := 'Y';
           End If;
     Else*/
     --Bug# 8622486
           hr_utility.set_location('Entering   '||l_proc_name,30);
           l_eligible := 'Y';
     --End If; --Bug# 8622486
     if  l_eligible = 'Y' and p_opt_id <> -1 Then
          -- Get Emp Contrib Elig Date
           hr_utility.set_location('Entering   '||l_proc_name,40);
         --Get employee contribution date. If not null and greater then effective date
         -- then employee cannot make elections.
         l_emp_dt := get_emp_contrib_date(p_asg_id,l_effective_date);
         hr_utility.trace('l_emp_dt   =  ' ||l_emp_dt   );
         If l_emp_dt is null then
              l_eligible := 'Y';
         ElsIf l_emp_dt is not null Then
              -- if there is any value entered for employee contributuion eligibility date
              If l_emp_dt > l_effective_date then
                 hr_utility.set_location('Entering   '||l_proc_name,50);
                 for get_option_name in c_get_option_name loop
                     l_opt_name := get_option_name.name;
                     exit;
                 End Loop;
                 hr_utility.trace('l_opt_name   =  ' ||l_opt_name   );
                 If l_opt_name = 'Terminate Contributions' then
                    hr_utility.set_location('Entering   '||l_proc_name,60);
                    l_eligible := 'Y';
                 Else
                    l_eligible := 'N';
                 End If;
              Else
                    l_eligible := 'Y';
              End If;
         End If;
     End If;
     hr_utility.trace('l_eligible   =  ' ||l_eligible   );
     hr_utility.set_location('Leaving   '||l_proc_name,100);
     return l_eligible;
  End tsp_plan_electble;

  ------- TSP Catch Up Contributions --------------------
  function get_emp_tsp_catchup_elig( p_business_group_id in Number
                                   ,p_asg_id            in Number
                                   ,p_pgm_id            in Number
                                   ,p_effective_date    in Date )
            RETURN VARCHAR2   Is

      l_proc_name             varchar2(100);
      l_eligible              varchar2(1);
      l_ee_50                 varchar2(1);
      l_person_id             per_all_people_f.person_id%type;
      l_payroll_id            per_all_assignments_f.payroll_id%type;
      l_pgm_year_end_dt       Date;
      --l_date_of_birth         Date;
      l_tspc_rate_start_dt    Date;
      l_tsp_pgm_id            ben_pgm_f.pgm_id%type;
      l_pl_id                 ben_pl_f.pl_id%type;
      l_oipl_id               ben_oipl_f.oipl_id%type;
      l_opt_name              ben_opt_f.name%type;


      l_db_last_pay_end_date       Date;
      l_db_last_check_date         Date;
      l_db_current_check_date      Date;
      l_db_current_pay_end_date    Date;
      l_db_current_pay_start_date  Date;
      l_db_next_pay_start_date     Date;

      l_agency_last_check_date     Date;
      l_agency_current_check_date  Date;

      l_last_check_date            Date;
      l_current_check_date         Date;

     -- Get person id
     Cursor c_get_person_id is
     Select person_id,payroll_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     -- get end date and check date of last pay period of current year that has pay date in this year.
     Cursor c_get_db_last_pay_period_dtls is
     select end_date,regular_payment_date
     from   per_time_periods
     where  payroll_id = l_payroll_id
     and    to_char(p_effective_date,'YYYY') = to_char(regular_payment_date,'YYYY')
     order by start_date desc;
/*
     -- get date of birth of an employee
     Cursor c_get_dob is
     Select date_of_birth
     from   per_all_people_f
     where  person_id = l_person_id
     and    trunc(l_current_check_date) between effective_start_date and effective_end_date;

     Cursor c_get_pgm_yr is
     select yrp.start_date,
            yrp.end_date
       from ben_yr_perd yrp,
            ben_popl_yr_perd cpy
      where cpy.pgm_id = p_pgm_id
        and cpy.yr_perd_id = yrp.yr_perd_id
        and l_current_check_date between yrp.start_date and yrp.end_date;
*/
    -- Cursor to get program id for TSP
    Cursor c_get_tsp_pgm_id is
    select pgm_id
    from   ben_pgm_f
    where  name = 'Federal Thrift Savings Plan (TSP)'
    and    business_group_id = p_business_group_id
    and    trunc(p_effective_date) between effective_start_date and effective_end_date;


   -- Cursor to check if employee currently enrolled in TSP Catch Up
     Cursor c_chk_enrolled_in_tspc is
     select rt_strt_dt
     from   ben_prtt_enrt_rslt_f perf, ben_prtt_rt_val prv
     where  perf.person_id = l_person_id
     and    perf.pgm_id    = p_pgm_id
     and    perf.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
     and    trunc(p_effective_date) between perf.effective_start_date and perf.effective_end_date
     and    perf.enrt_cvg_thru_dt = hr_api.g_eot
     and    prv.rt_end_dt = hr_api.g_eot
     and    perf.prtt_enrt_rslt_stat_cd is null;

   -- Cursor to check if employee currently enrolled in TSP
     Cursor c_chk_enrolled_in_tsp is
     select pl_id,oipl_id
     from   ben_prtt_enrt_rslt_f perf
     where  person_id = l_person_id
     and    pgm_id    = l_tsp_pgm_id
     --and    pl_id     = l_pl_id
     and    trunc(l_db_next_pay_start_date) between effective_start_date and effective_end_date
     and    enrt_cvg_thru_dt = hr_api.g_eot
     and    prtt_enrt_rslt_stat_cd is null;

     Cursor c_get_opt_name is
     select name from ben_opt_f
     where  opt_id in (select opt_id from ben_oipl_f
                       where  oipl_id = l_oipl_id
                       and    p_effective_date between effective_start_date and
effective_end_date)
     and    p_effective_date between effective_start_date and effective_end_date;

    Cursor c_get_db_curr_pay_period_dtls is
     select start_date,end_date,regular_payment_date
     from   per_time_periods
     where  payroll_id = l_payroll_id
     and p_effective_date between start_date and end_date
     --and    end_date = trunc(p_effective_date)
     order by start_date ;

    Cursor c_get_db_next_pay_period_dtls is
     select start_date,end_date,regular_payment_date
     from   per_time_periods
     where  payroll_id = l_payroll_id
     and    start_date >= trunc(p_effective_date)
     order by start_date ;

  Begin
    l_proc_name  :=  g_package || '.get_emp_tsp_catch_up_elig';
    hr_utility.set_location('Entering    ' ||l_proc_name,10);
    hr_utility.trace('p_asg_id   =  ' ||p_asg_id   );
    -- get_person_id
    For get_person_id in c_get_person_id  loop
        l_person_id := get_person_id.person_id;
        l_payroll_id:= get_person_id.payroll_id;
        Exit;
    End Loop;
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('l_person_id   =  ' ||l_person_id );
    --dbms_output.put_line('l_person_id   =  ' ||l_person_id );

    -- get last check date and pay period end date of the current year
    For get_db_last_pay_period_dtls in c_get_db_last_pay_period_dtls Loop
        l_db_last_pay_end_date   := get_db_last_pay_period_dtls.end_date;
        l_db_last_check_date     := get_db_last_pay_period_dtls.regular_payment_date;
        exit;
    End loop;
    hr_utility.set_location(l_proc_name,30);

    -- Get agency last check date of year
    l_agency_last_check_date := ghr_agency_general.get_agency_last_check_date(l_person_id,
                                                                              p_asg_id,
                                                                              p_effective_date,
                                                                              l_payroll_id);
    l_last_check_date := nvl(l_agency_last_check_date,l_db_last_check_date);

    -- get current pay period start date and check date
    for get_db_curr_pay_period_dtls in c_get_db_curr_pay_period_dtls loop
        l_db_current_check_date     := get_db_curr_pay_period_dtls.regular_payment_date;
        l_db_current_pay_start_date := get_db_curr_pay_period_dtls.start_date;
        l_db_current_pay_end_date   := get_db_curr_pay_period_dtls.end_date;
        exit;
    End Loop;

    -- get agency check date for current pay period
    l_agency_current_check_date := ghr_agency_general.get_agency_check_date(l_person_id,
                                                                            p_asg_id,
                                                                            l_db_current_pay_end_date,
                                                                            l_payroll_id);
    l_current_check_date := nvl(l_agency_current_check_date,l_db_current_check_date);

    /* ******************************************************************************/
    /* If the last check date and current check date are equal and effectiev date is*/
    /* current pay period end date then de-enroll                                   */
    /*The person is de-enrolled only if there are no future dated enrollment        */
    /********************************************************************************/
    if (l_current_check_date = l_last_check_date ) and (p_effective_date = l_db_current_pay_end_date) Then
       for chk_enrolled_in_tspc in c_chk_enrolled_in_tspc loop
           l_tspc_rate_start_dt  := chk_enrolled_in_tspc.rt_strt_dt;
           exit;
       end loop;
       hr_utility.set_location(l_proc_name,50);
       hr_utility.trace('l_tspc_rate_start_dt   =  ' ||l_tspc_rate_start_dt );
       --dbms_output.put_line('l_tspc_rate_start_dt   =  ' ||l_tspc_rate_start_dt );

       --Bug # 3188550
       if l_tspc_rate_start_dt is null Then
             hr_utility.set_location(l_proc_name,60);
             l_eligible := 'N';
       elsif l_tspc_rate_start_dt < p_effective_date then
             hr_utility.set_location(l_proc_name,63);
             l_eligible := 'N';
       elsif l_tspc_rate_start_dt >= p_effective_date then
             hr_utility.set_location(l_proc_name,65);
             l_eligible := 'Y';
       end If;
    Else     -- if the not the last day of last pay period of year
       /* ************************************************************************* */
       /* To check if employee is 50 years or would be 50 years in the year of      */
       /* enrollment. the eligibility for age needs to be checked against check     */
       /* date  of the pay period in which elections would be effective             */
       /* ************************************************************************* */
       hr_utility.set_location(l_proc_name,70);
       --dbms_output.put_line('checking eligibility') ;

       -- get next pay period start date
       for get_db_next_pay_period_dtls in c_get_db_next_pay_period_dtls loop
           l_db_next_pay_start_date := get_db_next_pay_period_dtls.start_date;
           exit;
       End Loop;

       l_ee_50 := ghr_formula_functions.chk_if_ee_is_50 (l_person_id,
                                                         p_asg_id,
                                                         p_effective_date,
                                                         l_db_next_pay_start_date);
       if l_ee_50 = 'N' then
       /*
       -- 50 years condition
        for get_dob in c_get_dob loop
            l_date_of_birth := get_dob.date_of_birth;
            exit;
        End Loop;
        hr_utility.trace('l_date_of_birth   =  ' ||l_date_of_birth );
        --dbms_output.put_line('l_date_of_birth   =  ' ||l_date_of_birth );
        for get_pgm_yr in c_get_pgm_yr loop
            l_pgm_year_end_dt  := get_pgm_yr.end_date;
            exit;
        End Loop;
        if add_months(l_date_of_birth,600) > l_pgm_year_end_dt then
        */
           l_eligible := 'N';
           --dbms_output.put_line('age not 50');
        else
           /* ***********************************************************************/
           /* To check if employee is currently contributing to TSP and is enrolled */
           /* in either Amount or Percentage option.                                */
           /*************************************************************************/
           hr_utility.set_location(l_proc_name,90);
           for get_tsp_pgm_id in c_get_tsp_pgm_id Loop
               l_tsp_pgm_id := get_tsp_pgm_id.pgm_id;
               exit;
           End Loop;

           for chk_enrolled_in_tsp in c_chk_enrolled_in_tsp loop
               l_pl_id := chk_enrolled_in_tsp.pl_id;
               l_oipl_id := chk_enrolled_in_tsp.oipl_id;
               exit;
           end loop;

           hr_utility.trace('l_pl_id      =  ' ||l_pl_id );
           hr_utility.trace('l_oipl_id      =  ' ||l_oipl_id );
           --dbms_output.put_line('l_pl_id '||l_pl_id);

/*Bug#5533819
           If l_pl_id is null or l_oipl_id is null then
              l_eligible := 'N';
           Else
*/
              for get_opt_name in c_get_opt_name loop
                  l_opt_name := get_opt_name.name;
                  exit;
              End loop;
              hr_utility.trace('l_opt_name   =  ' ||l_opt_name );
              --dbms_output.put_line('l_opt_name   =  ' ||l_opt_name );
              If l_opt_name = 'Terminate Contributions' Then
                 l_eligible := 'N';
              Else
                 l_eligible := 'Y';
              End If;
  --        End If;
        End If;
     End If;
     hr_utility.trace('l_eligible   =  ' ||l_eligible   );
     hr_utility.set_location('Leaving    ' ||l_proc_name,100);
     Return l_eligible;
End get_emp_tsp_catchup_elig;


   FUNCTION get_fehb_pgm_eligibility( p_business_group_id in Number
                                     ,p_asg_id            in Number
                                     ,p_effective_date    in Date )

            RETURN VARCHAR2  is

 cursor get_current_enrollment is
     SELECT ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id, 'Enrollment', eef.effective_start_date) enrollment
     FROM   pay_element_entries_f eef,
            pay_element_types_f elt
     WHERE  assignment_id = p_asg_id
     AND    elt.element_type_id = eef.element_type_id
     AND    eef.effective_start_date BETWEEN elt.effective_start_date  AND
            elt.effective_end_date
     and    p_effective_date between eef.effective_start_date and eef.effective_end_date
     AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                                                               p_business_group_id,
                                                               p_effective_date))
                          IN  ('HEALTH BENEFITS','HEALTH BENEFITS PRE TAX')  ;
     v_curr_enrollment      varchar2(10);
     v_eligible             varchar2(1);
     l_proc_name            VARCHAR2(100);

 Begin
     l_proc_name :=  g_package || '.get_fehb_pgm_eligibility';
     hr_utility.set_location('Entering   ' ||l_proc_name,10);
     hr_utility.trace('Assignment id   =  ' ||p_asg_id   );
     hr_utility.trace('Effective Date  =  ' ||p_effective_date   );
     v_eligible := 'N';
     Open get_current_enrollment;
     Fetch get_current_enrollment into v_curr_enrollment;
     hr_utility.trace('Current Enrollment status   =  ' ||v_curr_enrollment   );
     if v_curr_enrollment in ('Z', 'W') Then
        v_eligible := 'N';
     Else
        v_eligible := 'Y';
     End If;
     Close get_current_enrollment;
     hr_utility.trace('Eligible for FEHB   =  ' ||v_eligible   );
     hr_utility.set_location('Leaving   ' ||l_proc_name,10);
     Return v_eligible;
 End get_fehb_pgm_eligibility;


   FUNCTION get_temps_total_cost( p_business_group_id in Number
                                 ,p_asg_id            in Number
                                 ,p_effective_date    in Date )
            RETURN VARCHAR2  IS

      l_procedure_name            VARCHAR2(100);
      v_temps_total_cost          VARCHAR2(50);


     cursor c_get_current_temps_total_cost is
     SELECT ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id,
                                                           'Temps Total Cost',
                                                           p_effective_date - 1) temps_cost
     FROM   pay_element_entries_f eef,
            pay_element_types_f elt
     WHERE  assignment_id = p_asg_id
     AND    elt.element_type_id = eef.element_type_id
     AND    eef.effective_start_date BETWEEN elt.effective_start_date  AND
            elt.effective_end_date
     and    (p_effective_date - 1) between eef.effective_start_date
                                   and eef.effective_end_date
     AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                                                               p_business_group_id,
                                                               p_effective_date))
                          IN  ('HEALTH BENEFITS','HEALTH BENEFITS PRE TAX')  ;
    Begin
     l_procedure_name  :=  g_package || '.get_temps_total_cost';
     hr_utility.set_location('Entering   ' ||l_procedure_name,10);
     hr_utility.trace('Assignment id   =  ' ||p_asg_id||'BG   '||p_business_group_id   );
     hr_utility.trace('Effective Date  =  ' ||p_effective_date   );
     v_temps_total_cost := '';
     Open c_get_current_temps_total_cost;
     Fetch c_get_current_temps_total_cost into v_temps_total_cost;
     hr_utility.trace('Current Temps Total Cost =  ' ||v_temps_total_cost   );
     Close c_get_current_temps_total_cost;
     hr_utility.set_location('Leaving   ' ||l_procedure_name,100);
     Return v_temps_total_cost;
    End get_temps_total_cost;



  Function fehb_plan_electable( p_business_group_id in Number
                              ,p_asg_id            in Number
                              ,p_pgm_id            in Number
                              ,p_pl_id             in Number
                              ,p_ler_id            in Number
                              ,p_effective_date    in Date
                              ,p_opt_id            in Number)
            RETURN VARCHAR2  Is

      l_proc_name            VARCHAR2(100);
      v_eligible             VARCHAR2(1);
      v_ler_name             ben_ler_f.name%type;
      v_opt_name             ben_opt_f.name%type;
      v_pl_name              ben_pl_f.name%type;
      v_person_id            per_all_people_f.person_id%type;
      v_coe_date             Date;

     Cursor c_get_person_id is
     Select person_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_get_ler_name is
     select name
     from   ben_ler_f
     where  ler_id = p_ler_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_get_option_name is
     select name
     from   ben_opt_f
     where  opt_id = p_opt_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_get_plan_name is
     select name
     from   ben_pl_f
     where  pl_id = p_pl_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;


  Begin
    l_proc_name  :=  g_package || 'fehb_plan_electable';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);
    --Get Child Order equity date Processing
    v_coe_date := get_coe_date(p_asg_id,p_effective_date);
    hr_utility.set_location('v_coe_date   ' ||v_coe_date,20);
    if v_coe_date is null then
          v_eligible := 'Y';
    Elsif p_opt_id = -1 then
          for get_plan_name in c_get_plan_name loop
              v_pl_name := get_plan_name.name;
              exit;
          end loop;
          if v_pl_name = 'Decline Coverage' Then
              v_eligible := 'N';
          Else
              v_eligible := 'Y';
          End If;
    Else
         for get_option_name in c_get_option_name loop
             v_opt_name := get_option_name.name;
             exit;
         End Loop;
         If v_opt_name like '%Family%' then
             v_eligible := 'Y';
         Else
             v_eligible := 'N';
         End If;
    End If;
    -- end Child Order Equity Date Processing

    /*
    v_eligible   := 'N';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);
    -- get person_id
    For get_person_id in c_get_person_id  loop
        v_person_id := get_person_id.person_id;
        Exit;
    End Loop;
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('v_person_id   =  ' ||v_person_id );
    For get_ler_name in c_get_ler_name loop
        v_ler_name := get_ler_name.name;
        exit;
    End loop;
    hr_utility.set_location(l_proc_name,30);
    hr_utility.trace('v_ler_name   =  ' ||v_ler_name );

    if upper(v_ler_name) in ('Initial Opportunity to Enroll'
                            ,'Open'
                            ,'Change in Family Status'
                            ,'Change in Employment Status Affecting Entitlement to Coverage'
                            ,'Transfer from a post of duty within US to post of duty outside US or vice versa'
                            ,'Employee/Family member loses coverage under FEHB or another group plan'
                            ,'Loss of coverage under a non-Federal health plan-moves out of commuting area'
                            ,'Employee/Family member loses coverage due to discontinuance of an FEHB plan'
                            ) then
       --Get Child Order equity date Processing
              v_coe_date := get_coe_date(p_asg_id,p_effective_date);
              if v_coe_date is null then
                 v_eligible := 'Y';
              Elsif p_opt_id = -1 then
                 for get_plan_name in c_get_plan_name loop
                     v_pl_name := get_plan_name.name;
                     exit;
                 end loop;
                 if v_pl_name = 'Decline Coverage' Then
                     v_eligible := 'N';
                 Else
                     v_eligible := 'Y';
                 End If;
              Else
                 for get_option_name in c_get_option_name loop
                     v_opt_name := get_option_name.name;
                     exit;
                 End Loop;
                 If v_opt_name like '%Family%' then
                    v_eligible := 'Y';
                 Else
                    v_eligible := 'N';
                 End If;
              End If;
       -- end Child Order Equity Date Processing
    Else
        v_eligible := 'Y';
    End If;
    */
    --v_eligible   := 'Y';
    hr_utility.trace('Eligible =  ' ||v_eligible   );
    hr_utility.set_location('Leaving   ' ||l_proc_name,100);
    Return v_eligible;
  End fehb_plan_electable;

  Function get_agency_contrib_date (p_asg_id        in Number
                                   ,p_effective_date   in Date)
           Return Date is

      l_proc_name            VARCHAR2(100);
      v_agency_date          Date;
      v_person_id            per_all_people_f.person_id%type;

     Cursor c_get_person_id is
     Select person_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

    cursor c_get_agency_date is
    select to_date(pei_information14,'yyyy/mm/dd hh24:mi:ss') agency_date
    from   ghr_people_extra_info_h_v
    where  pa_history_id =
           (select ghr_ss_views_pkg.get_people_ei_id_ason_date(v_person_id,
                                                              'GHR_US_PER_BENEFIT_INFO',
                                                               p_effective_date) from dual);
 Begin
    l_proc_name  :=  g_package || '.get_agency_contrib_date';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);
    for get_person_id in c_get_person_id loop
       v_person_id := get_person_id.person_id;
       exit;
    end loop;
    hr_utility.trace('v_person_id =  ' ||v_person_id   );
    for get_agency_date in c_get_agency_date loop
        v_agency_date := get_agency_date.agency_date;
        exit;
    End loop;
    hr_utility.trace('v_agency_date =  ' ||v_agency_date   );
    hr_utility.set_location('Leaving   ' ||l_proc_name,100);
    return v_agency_date;
 End get_agency_contrib_date;

  Function get_emp_contrib_date (p_asg_id        in Number
                                ,p_effective_date   in Date)
           Return Date is

      l_proc_name            VARCHAR2(100);
      v_emp_date             Date;
      v_person_id            per_all_people_f.person_id%type;

     Cursor c_get_person_id is
     Select person_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

    cursor c_get_emp_date is
    select to_date(pei_information15,'yyyy/mm/dd hh24:mi:ss') emp_date
    from   ghr_people_extra_info_h_v
    where  pa_history_id =
           (select ghr_ss_views_pkg.get_people_ei_id_ason_date(v_person_id,
                                                              'GHR_US_PER_BENEFIT_INFO',
                                                               p_effective_date) from dual);
 Begin
    l_proc_name  :=  g_package || 'get_emp_contrib_date';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);
    for get_person_id in c_get_person_id loop
       v_person_id := get_person_id.person_id;
       exit;
    end loop;
    hr_utility.trace('v_person_id =  ' ||v_person_id   );
    for get_emp_date in c_get_emp_date loop
        v_emp_date := get_emp_date.emp_date;
        exit;
    End loop;
    hr_utility.trace('v_emp_date =  ' ||v_emp_date   );
    hr_utility.set_location('Leaving   ' ||l_proc_name,100);
    return v_emp_date;
 End get_emp_contrib_date;

  -- FUnction to get Child Order Equity Date
  Function get_coe_date (p_asg_id        in Number
                        ,p_effective_date   in Date)
           Return Date is

      l_proc_name            VARCHAR2(100);
      v_coe_date             Date;
      v_person_id            per_all_people_f.person_id%type;

     Cursor c_get_person_id is
     Select person_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

    cursor c_get_coe_date is
    select to_date(pei_information10,'yyyy/mm/dd hh24:mi:ss') coe_date
    from   ghr_people_extra_info_h_v
    where  pa_history_id =
           (select ghr_ss_views_pkg.get_people_ei_id_ason_date(v_person_id,
                                                              'GHR_US_PER_BENEFIT_INFO',
                                                               p_effective_date) from dual);
 Begin
    l_proc_name  :=  g_package || 'get_coe_date';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);
    for get_person_id in c_get_person_id loop
       v_person_id := get_person_id.person_id;
       exit;
    end loop;
    hr_utility.trace('v_person_id =  ' ||v_person_id   );
    for get_coe_date in c_get_coe_date loop
        v_coe_date := get_coe_date.coe_date;
        exit;
    End loop;
    hr_utility.trace('v_coe_date =  ' ||v_coe_date   );
    hr_utility.set_location('Leaving   ' ||l_proc_name,100);
    return v_coe_date;
 End get_coe_date;

  Function tsp_cvg_and_rate_start_date (p_business_group_id in Number
                                       ,p_asg_id            in Number
                                       ,p_effective_date    in Date)
     Return date  is

     l_proc_name             varchar2(100);
     v_latest_hire_date      Date;
     v_cvg_rate_date         Date;
     v_hire_date             Date;
     v_person_id             per_all_people_f.person_id%type;
     v_payroll_id            per_all_assignments_f.payroll_id%type;
     v_noa_family_code       ghr_pa_requests.noa_family_code%type;
     v_first_noa_code        ghr_pa_requests.first_noa_code%type;
     v_rehire                Varchar2(1);

     -- get person id
     Cursor c_get_person_id is
     Select person_id,payroll_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     -- get hire date
     Cursor c_get_hire_date  is
     select decode(PER.CURRENT_EMPLOYEE_FLAG,'Y',PPS.DATE_START,null) hire_date
     from per_all_people_f per, per_periods_of_service pps
     where per.person_id = v_person_id
     and   per.person_id = pps.person_id
     and   PER.EMPLOYEE_NUMBER IS NOT NULL
     and   PPS.DATE_START = (SELECT MAX(PPS1.DATE_START)
                             FROM   PER_PERIODS_OF_SERVICE PPS1
                             WHERE  PPS1.PERSON_ID = PER.PERSON_ID
                               AND  PPS1.DATE_START <=  PER.EFFECTIVE_END_DATE) ;

    --check if this person exists in database
    Cursor c_chk_if_rehire is
    select 'Y'
    from   per_all_assignments_f
    where  person_id = v_person_id
    and    (p_effective_date - 30) between effective_start_date and effective_end_date
    and assignment_type <> 'B';
/*

AND ((PER.EMPLOYEE_NUMBER IS NULL) OR
            (PER.EMPLOYEE_NUMBER IS NOT NULL AND PPS.DATE_START = (SELECT MAX(PPS1.DATE_START)
             FROM PER_PERIODS_OF_SERVICE PPS1
             WHERE PPS1.PERSON_ID = PER.PERSON_ID
             AND PPS1.DATE_START <= PER.EFFECTIVE_END_DATE))) AND ((PER.NPW_NUMBER IS NULL) OR
               (PER.NPW_NUMBER IS NOT NULL AND PPP.DATE_START =
                 (SELECT MAX(PPP1.DATE_START) FROM PER_PERIODS_OF_PLACEMENT PPP1
                    WHERE PPP1.PERSON_ID = PER.PERSON_ID AND PPP1.DATE_START <= PER.EFFECTIVE_END_DATE)))
*/
     -- get latest rehire or transfer date
     Cursor c_get_latest_hire_noac is
     select noa_family_code,first_noa_code
     from   ghr_pa_requests
     where  person_id = v_person_id
     and    noa_family_code in ('APP','CONV_APP')
     and    nvl(effective_date,hr_api.g_date) = trunc(p_effective_date);

     -- get coverage and rate start date
     Cursor c_get_dates is
     select start_date
     from   per_time_periods
     where  payroll_id  = v_payroll_id
     and    start_date >= trunc(p_effective_date)
     order by start_date ;

  Begin
    l_proc_name  :=  g_package|| 'tsp_cvg_and_start_date';
    hr_utility.set_location('Entering    '||l_proc_name,10);
    --dbms_output.put_line(' In procedure    ' ||p_effective_date);
    For get_person_id in c_get_person_id loop
        v_person_id := get_person_id.person_id;
        v_payroll_id := get_person_id.payroll_id;
        exit;
    End Loop;
    hr_utility.set_location('v_person_id    '||v_person_id,20);
    --get hire_date
    for get_hire_date in c_get_hire_date LOOP
        v_hire_date := get_hire_date.hire_date;
        exit;
    end loop;
    If v_hire_date <> p_effective_date then
         for get_dates in c_get_dates loop
             v_cvg_rate_date := get_dates.start_date;
             exit;
         end loop;
    Else
      -- get latest NOAC for the hire action
        for get_latest_hire_noac in c_get_latest_hire_noac loop
            v_noa_family_code := get_latest_hire_noac.noa_family_code;
            v_first_noa_code  := get_latest_hire_noac.first_noa_code;
            exit;
        End loop;
        if v_first_noa_code like '1%' and v_first_noa_code not in ('140','141','143','130','132','145','147') Then
            for get_dates in c_get_dates loop
                  v_cvg_rate_date := get_dates.start_date;
                  exit;
            end loop;
        elsif v_first_noa_code in ('130','132','145','147')  or v_noa_family_code = 'CONV_APP' Then
            v_cvg_rate_date := p_effective_date;
        elsif v_first_noa_code in ('140','141','143') then
           v_rehire := 'N';
           for chk_if_rehire in c_chk_if_rehire Loop
               v_rehire := 'Y';
               exit;
           End Loop;
           If v_rehire = 'Y' Then
              v_cvg_rate_date := p_effective_date;
           else
              for get_dates in c_get_dates loop
                  v_cvg_rate_date := get_dates.start_date;
                  exit;
              end loop;
            End If;
        End If;

    End If;
    hr_utility.set_location('v_cvg_rate_date    '||v_cvg_rate_date,60);
    hr_utility.set_location('Leaving    '||l_proc_name,100);
    Return v_cvg_rate_date;
  Exception
    When Others Then
        hr_utility.set_location('Exception  Leaving   '||l_proc_name,210);
        hr_utility.trace('Error '  || sqlerrm(sqlcode));
        Return p_effective_date;
  End tsp_cvg_and_rate_start_date;

   FUNCTION ghr_tsp_cu_amount_validation(
                                 p_business_group_id  in number
                                ,p_asg_id             in number
                                ,p_effective_date     in date
                                ,p_pgm_id             in number
                                ,p_pl_id              in number
                               )
           RETURN varchar2 is

     l_proc_name              varchar2(100);
     l_result                 Varchar2(1);
     l_person_id              per_all_people_f.person_id%type;
     l_tsp_cu_amount          Number;
     l_prtt_enrt_rslt_id      ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type;
     l_payroll_id             pay_payrolls_f.payroll_id%type;
     l_rt_strt_dt             Date;
     l_effective_date         Date;
     l_agency_check_date      date;
     l_db_check_date          Date;
     l_check_date             date;
     l_end_date               date;

     Cursor c_get_person_id is
     Select person_id,payroll_id
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    trunc(p_effective_date) between effective_start_date and effective_end_date;

     Cursor c_get_prtt_enrt_rslt_id is
     select rt_strt_dt,rt_val
     from   ben_prtt_enrt_rslt_f perf , ben_prtt_rt_val prv
     where  perf.person_id = l_person_id
     and    perf.pgm_id    = p_pgm_id
     and    perf.pl_id     = p_pl_id
     and    perf.prtt_enrt_rslt_id = prv.prtt_enrt_rslt_id
     and    trunc(l_effective_date) between perf.effective_start_date and perf.effective_end_date
     and    perf.enrt_cvg_thru_dt = hr_api.g_eot
     and    prv.rt_end_dt = hr_api.g_eot
     and    perf.prtt_enrt_rslt_stat_cd is null;

     -- get check__date maianitained in system for the rate start date
     Cursor c_get_db_check_date is
     select regular_payment_date,end_date
     from   per_time_periods
     where  payroll_id  = l_payroll_id
     and    start_date >= trunc(l_rt_strt_dt)
     order by start_date ;
   Begin
    l_proc_name   :=  g_package|| 'ghr_tsp_cu_amount_validation';
    l_result      := 'Y';
    hr_utility.set_location('Entering   ' ||l_proc_name,10);

    -- get person_id
    For get_person_id in c_get_person_id  loop
        l_person_id := get_person_id.person_id;
        l_payroll_id := get_person_id.payroll_id;
        Exit;
    End Loop;
    hr_utility.set_location(l_proc_name,20);
    hr_utility.trace('l_person_id   =  ' ||l_person_id );
    hr_utility.trace('p_pgm_id   =  ' ||p_pgm_id );
    hr_utility.trace('p_pl_id   =  ' ||p_pl_id );
    hr_utility.trace('p_effective_date   =  ' ||p_effective_date );
    --dbms_output.put_line('per id   ' ||l_person_id||'  pl id:' ||p_pl_id||' pgmid:'||p_pgm_id);

    ghr_history_api.get_session_date(l_effective_date);
    hr_utility.trace('l_effective_date   =  ' ||l_effective_date );
    --Get Prtt Enrt Rslt id
    For get_prtt_enrt_rslt_id in c_get_prtt_enrt_rslt_id loop
        l_rt_strt_dt    := get_prtt_enrt_rslt_id.rt_strt_dt;
        l_tsp_cu_amount := get_prtt_enrt_rslt_id.rt_val;
        exit;
    End loop;
    hr_utility.set_location(l_proc_name,30);
    hr_utility.trace('l_rt_strt_dt   =  ' ||l_rt_strt_dt);
    hr_utility.trace('l_tsp_cu_amount   =  ' ||l_tsp_cu_amount );
    --dbms_output.put_line('AMOUNT   ' ||l_tsp_cu_amount);

    hr_utility.trace('l_rt_strt_dt   =  ' ||l_rt_strt_dt);
    -- get check date (for rt_strt_dt)
    for get_db_check_date in c_get_db_check_date loop
        l_db_check_date := get_db_check_date.regular_payment_date;
        l_end_date := get_db_check_date.end_date;
        exit;
    End Loop;

    --get agency_check_date
    l_agency_check_date := ghr_agency_general.get_agency_check_date(l_person_id
                                                                   ,p_asg_id
                                                                   ,l_end_date
                                                                   ,l_payroll_id);

   -- if agnecy check date is returned then we use that else use the date maintained in system
    l_check_date := nvl(l_agency_check_date,l_db_check_date);
    hr_utility.trace('l_check_date   =  ' ||l_check_date);

    l_tsp_cu_amount  := nvl(l_tsp_cu_amount,0);

    hr_utility.trace('l_tsp_cu_amount    ' ||l_tsp_cu_amount );
    If l_tsp_cu_amount = 0 Then
          l_result := 'N';
    Elsif l_tsp_cu_amount > 0 Then
       If l_check_date  between to_date('01/01/2005','dd/mm/yyyy')
                                     and to_date('31/12/2005','dd/mm/yyyy') Then
              If l_tsp_cu_amount <= 4000 Then
                 l_result := 'Y';
              Else
                 l_result := 'N';
              End If;
       Elsif l_check_date  between to_date('01/01/2006','dd/mm/yyyy')
                                     and to_date('31/12/2006','dd/mm/yyyy') Then
              If l_tsp_cu_amount <= 5000 Then
                 l_result := 'Y';
              Else
                 l_result := 'N';
              End If;
       Else
          l_result := 'Y';
      End If;
    End If;
    hr_utility.set_location('Leaving    '||l_proc_name,80);
    hr_utility.trace('l_result    ' ||l_result );
    return l_result;
  Exception
    When others  Then
      hr_utility.set_location('Exception Leaving   ' ||l_proc_name,200);
      hr_utility.trace('Error '  || sqlerrm(sqlcode));
      Return 'N';
   End ghr_tsp_cu_amount_validation;

   -- Parameter p_payroll_period_start_date addded. This date must be the start date
   -- of the payroll period in which election occurs.
   function chk_if_ee_is_50 (p_person_id  in Number,
                             p_asg_id in Number,
                             p_effective_date in date,
                             p_payroll_period_start_date in date)
   return varchar2 is
      l_proc_name                  varchar2(100);
      l_date_of_birth              date;
      l_payroll_id                 Number;
      l_db_current_check_date      Date;
      l_db_current_pay_end_date    Date;
      l_agency_current_check_date  Date;
      l_current_check_date         Date;

     Cursor c_get_payroll_id is
     select payroll_id
     from   per_assignments_f
     where  assignment_id = p_asg_id
     and    p_effective_date between effective_start_date and effective_end_date;

     Cursor c_get_db_curr_pay_period_dtls is
     select start_date,end_date,regular_payment_date
     from   per_time_periods
     where  payroll_id = l_payroll_id
     and    start_date = trunc(p_payroll_period_start_date)
     order by start_date ;

     Cursor c_get_dob is
     Select date_of_birth
     from   per_all_people_f
     where  person_id = p_person_id
     and    trunc(l_current_check_date) between effective_start_date and effective_end_date;

   Begin
       l_proc_name   :=  g_package|| 'chk_if_ee_is_50';
       hr_utility.set_location('Entering    ' ||l_proc_name,10);
       -- Get Payroll Id
       for get_payroll_id in c_get_payroll_id loop
            l_payroll_id := get_payroll_id.payroll_id;
            exit;
       End Loop;
       hr_utility.set_location(l_proc_name,20);

       -- get current pay period end date and check date
       -- get check date for the effective date
       for get_db_curr_pay_period_dtls in c_get_db_curr_pay_period_dtls loop
           l_db_current_check_date     := get_db_curr_pay_period_dtls.regular_payment_date;
           l_db_current_pay_end_date   := get_db_curr_pay_period_dtls.end_date;
           exit;
       End Loop;
       hr_utility.set_location(l_proc_name,30);

       -- get agency check date for current pay period
       l_agency_current_check_date := ghr_agency_general.get_agency_check_date(p_person_id,
                                                                               p_asg_id,
                                                                               l_db_current_pay_end_date,
                                                                               l_payroll_id);
       l_current_check_date := nvl(l_agency_current_check_date,l_db_current_check_date);
       hr_utility.set_location(l_proc_name,40);

       for get_dob in c_get_dob loop
            l_date_of_birth := get_dob.date_of_birth;
            exit;
       End Loop;

       --check if employee would be 50 in that calendar year
       If add_months (l_date_of_birth,600) >
                  to_date('31/12/'||to_char(l_current_check_date,'YYYY'),'DD/MM/YYYY') Then
           return 'N';
       Else
           return 'Y';
       End If;
       hr_utility.set_location('Leaving    '||l_proc_name,100);
   Exception
       When Others Then
           Return 'N';
   End chk_if_ee_is_50;
End;

/
