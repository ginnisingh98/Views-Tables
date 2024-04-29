--------------------------------------------------------
--  DDL for Package Body PER_POSITION_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POSITION_MAPPING" 
-- $Header: perpomap.pkb 115.4 99/10/18 20:40:31 porting shi $
IS
  function get_position_id
   ( p_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_id number(15) ;
     cursor c1 is select position_id from hr_all_positions_f
                  where name = p_name
                  and effective_end_date = to_date('31124712','ddmmyyyy');
   BEGIN
       open c1 ;
       fetch c1 into l_position_id ;
       close c1;
       return l_position_id ;
   END;

  function get_position_definition_id
   ( p_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_definition_id number(15) ;
     cursor c1 is select position_definition_id from hr_all_positions_f
                  where name = p_name
                  and effective_end_date = to_date('31124712','ddmmyyyy');
   BEGIN
       open c1 ;
       fetch c1 into l_position_definition_id ;
       close c1;
       return l_position_definition_id ;
   END;

   function get_prior_position_id
   ( p_prior_position_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_id number(15) ;
   BEGIN
       l_position_id := get_position_id(p_prior_position_name,p_effective_date);
       return l_position_id ;
   END;

   function get_supervisor_position_id
   ( p_supervisor_position_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_id number(15) ;
   BEGIN
       l_position_id := get_position_id(p_supervisor_position_name,p_effective_date);
       return l_position_id ;
   END;

   function get_successor_position_id
   ( p_successor_position_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_id number(15) ;
   BEGIN
       l_position_id := get_position_id(p_successor_position_name,p_effective_date);
       return l_position_id ;
   END;

   function get_relief_position_id
   ( p_relief_position_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_id number(15) ;
   BEGIN
       l_position_id := get_position_id(p_relief_position_name,p_effective_date);
       return l_position_id ;
   END;

   function get_pay_freq_payroll_id (
            p_pay_freq_payroll_name varchar2
          , p_business_group_id     number )
   return number is
      cursor csr_lookup is
         select    payroll_id
         from      pay_all_payrolls_f pay, fnd_sessions f
         where     payroll_name      = p_pay_freq_payroll_name
         and       f.effective_date between
                   pay.effective_start_date and pay.effective_end_date
         and       f.session_id         = userenv ('sessionid')
         and       pay.business_group_id = p_business_group_id ;
     v_payroll_id          number(15) := null;
   begin
     if p_pay_freq_payroll_name is not null then
        open csr_lookup;
        fetch csr_lookup into v_payroll_id;
        close csr_lookup;
     end if;
     return v_payroll_id;
   end get_pay_freq_payroll_id;

   function get_entry_step_id (
         p_spinal_point      varchar2
       , p_effective_date    date
       , p_business_group_id number)
   return number is
    cursor csr_step is
      select sps.step_id
   	  from	per_spinal_point_steps_f sps, per_spinal_points psp
      where p_effective_date between sps.effective_start_date
          and sps.effective_end_date
          and sps.business_group_id = psp.business_group_id
          and psp.business_group_id = p_business_group_id
          and sps.spinal_point_id = psp.spinal_point_id
          and psp.spinal_point = p_spinal_point ;
       v_step_id          number(15) := null;
   begin
     if p_spinal_point is not null and p_effective_date is not null then
        open csr_step;
        fetch csr_step into v_step_id;
        close csr_step;
     end if;
     return v_step_id;
   end get_entry_step_id;

   function get_availability_status_id (
            p_shared_type_name      varchar2
           ,p_system_type_cd        varchar2
           ,p_business_group_id     number )
     return number is
      cursor csr_lookup is
         select    shared_type_id
         from      per_shared_types_vl
         where     shared_type_name = p_shared_type_name
	 and lookup_type = 'POSITION_AVAILABILITY_STATUS'
         and system_type_cd = p_system_type_cd
         and nvl(business_group_id,p_business_group_id) = p_business_group_id;
       v_shared_type_id    number(15) := null;
    begin
      if p_shared_type_name is not null then
         open csr_lookup;
         fetch csr_lookup into v_shared_type_id;
         close csr_lookup;
      end if;
      return v_shared_type_id;
    end get_availability_status_id;

  function get_position_ovn
   ( p_name IN varchar2,
     p_effective_date IN date )
   return number
   is
     l_position_ovn number(15) ;
     cursor c1 is select object_version_number from hr_all_positions_f
                  where name = p_name
                  and effective_end_date = to_date('31124712','ddmmyyyy');
   BEGIN
       open c1 ;
       fetch c1 into l_position_ovn ;
       close c1;
       return l_position_ovn ;
   END;

END;

/
