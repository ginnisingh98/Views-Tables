--------------------------------------------------------
--  DDL for Package Body PAY_SG_CPFLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_CPFLINE" as
/* $Header: pysgcpfl.pkb 120.0.12010000.2 2008/11/26 03:19:55 jalin ship $ */
      g_debug   boolean;
      --
      l_package  VARCHAR2(100);
      l_proc_name VARCHAR2(100) ;

      ----------------------------------------------------------------------
      -- Record with payroll action details populated in Initialization_code
      ----------------------------------------------------------------------
      type t_pact IS RECORD(
            report_type             pay_payroll_actions.report_type%TYPE,
            report_qualifier        pay_payroll_actions.report_qualifier%TYPE,
            report_category         pay_payroll_actions.report_category%TYPE,
            business_group_id       number,
            effective_date          date,
            month_date              varchar2(11),
            legal_entity_id         number ,
            Start_date              date ,
            End_date                date
	    );
      --
      g_pact                  t_pact;
      -----------------------------------------------------
      -- record type to hold archival information
      -----------------------------------------------------
      rec_action_info    pay_action_information%rowtype ;
      -----------------------------------------------------
      -- Table to store Defined Balance details
      -----------------------------------------------------
      type t_def_bal_id   is table of pay_defined_balances.defined_balance_id%type ;
      type t_def_bal_name is table of pay_balance_types.balance_name%type ;
      --
      g_def_bal_id        t_def_bal_id ;
      g_def_bal_name      t_def_bal_name ;
      ----------------------------------------------------------------
      -- Function Returns Defined Balance id
      ----------------------------------------------------------------
      function get_def_bal_id
          ( p_def_bal_name in pay_balance_types.balance_name%type ) return number
      is
      begin
          for i in 1..g_def_bal_name.count
          loop
                if g_def_bal_name(i) =p_def_bal_name then
                      return g_def_bal_id(i) ;
                end if ;
          end loop ;
          -- if reached here
          raise_application_error(-20001 , ' Program Error : Defined Balance not found ')   ;
      end get_def_bal_id  ;
      --------------------------------------------------------------------
      -- These are PUBLIC procedures are required by the Archive process.
      -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
      -- the archive process knows what code to execute for each step of
      -- the archive.
      --------------------------------------------------------------------
      procedure range_code
          ( p_payroll_action_id  in   pay_payroll_actions.payroll_action_id%type,
            p_sql                out  nocopy varchar2)
      is
          c_range_cursor  constant varchar2(3000) :=
                                   ' select   distinct pap.person_id
                                       from   pay_payroll_actions    ppa,
                                              per_people_f           pap
                                      where   ppa.payroll_action_id = :payroll_action_id
                                        and   pap.business_group_id = ppa.business_group_id
                                      order by pap.person_id ' ;
      begin
          p_sql := c_range_cursor ;
      end range_code ;
      ------------------------------------------------------------
      -- Assignment Action Code
      ------------------------------------------------------------
      procedure assignment_action_code
          ( p_payroll_action_id  in  pay_payroll_actions.payroll_action_id%type,
            p_start_person_id    in  per_all_people_f.person_id%type,
            p_end_person_id      in  per_all_people_f.person_id%type,
            p_chunk              in  number )
      is

          l_next_action_id  pay_assignment_actions.assignment_action_id%type;
          --
          ------------------------------------------------------------------------
          --Bug#3833818 Added payroll_id join to improve performance of the query.
          ------------------------------------------------------------------------
          cursor  c_assact
          is
          select  distinct paa.assignment_id
          from    pay_payroll_actions     xppa,
	          pay_payroll_actions     rppa,
		  pay_assignment_actions  rpac,
	          per_assignments_f       paa
           where  xppa.payroll_action_id = p_payroll_action_id
             and  paa.person_id          between p_start_person_id
                                             and p_end_person_id
             and  rppa.business_group_id = g_pact.business_group_id
             and  rppa.payroll_id in     ( select payroll_id
     		                           from pay_payrolls_f
                                           where business_group_id = g_pact.business_group_id )
             and  rppa.effective_date    between g_pact.start_date
                                             and g_pact.end_date
             and  rppa.action_type       in ('R','Q')
             and  rpac.action_status     = 'C'
             and  rppa.payroll_action_id = rpac.payroll_action_id
             and  rpac.tax_unit_id       = g_pact.legal_entity_id
             and  rpac.assignment_id     = paa.assignment_id
             and  rppa.effective_date    between paa.effective_start_date
                                             and paa.effective_end_date ;
           --
          cursor  next_action_id
              is
          select  pay_assignment_actions_s.nextval
            from  dual;
          --
      begin
          l_package  := ' pay_sg_cpfline.';
          l_proc_name  := l_package || 'assignment_action_code';
          pay_sg_cpfline.initialization_code(p_payroll_action_id) ;
	  --
          if g_debug then
               hr_utility.set_location(l_proc_name || ' Start of assignment_action_code',30);
          end if;
          --
          for i in c_assact
          loop
                open next_action_id;
                fetch next_action_id into l_next_action_id;
                close next_action_id;
                --
		if g_debug then
                     hr_utility.set_location(l_proc_name|| ' Before calling hr_nonrun_asact.insact',30);
                end if;
                --
                hr_nonrun_asact.insact( l_next_action_id,
                                        i.assignment_id,
                                        p_payroll_action_id,
                                        p_chunk,
                                        g_pact.legal_entity_id  );
                --
                if  g_debug then
                      hr_utility.set_location(l_proc_name||' After calling hr_nonrun_asact.insact',30);
                end if;
                --
          end loop;
          --
          if  g_debug then
                 hr_utility.set_location(l_proc_name|| ' End of assignment_action_code',30);
          end if;
      exception
          when others then
                if  g_debug then
                       hr_utility.set_location(l_proc_name||' Error raised in assignment_action_code procedure',30);
                end if;
                raise;
      end assignment_action_code ;
      ------------------------------------------------------------
      -- Assignment Action Code
      ------------------------------------------------------------
      procedure initialization_code
          ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
      is

      begin
           l_package  := ' pay_sg_cpfline.';
           l_proc_name  := l_package || 'initialization_code';
           g_debug := hr_utility.debug_enabled;
           --
           if  g_debug then
                  hr_utility.set_location(l_proc_name||' Start of initialization_code',20);
           end if;
           --
           if g_pact.report_type is null then
                  select  ppa.report_type,
                          ppa.report_qualifier,
                          ppa.report_category,
                          ppa.business_group_id,
                          ppa.effective_date,
                          to_number(pay_core_utils.get_parameter('MONTH',ppa.legislative_parameters)) month_date,
                          to_number(pay_core_utils.get_parameter('LEGAL_ENTITY_ID',ppa.legislative_parameters)) legal_entity_id,
                          to_date(pay_core_utils.get_parameter('MONTH',ppa.legislative_parameters)||'01','YYYYMMDD'),
                          last_day(to_date(pay_core_utils.get_parameter('MONTH',ppa.legislative_parameters)|| '01','YYYYMMDD'))
                    into  g_pact
                    from  pay_payroll_actions           ppa
                   where  ppa.payroll_action_id = p_payroll_action_id;
           end if ;
           --
           if  g_debug then
                   hr_utility.set_location(l_proc_name||' End of initialization_code',20);
           end if;
      exception
           when others then
                  if g_debug then
                         hr_utility.set_location(l_proc_name||' Error in initialization code ',20);
                  end if;
                  raise;
      end initialization_code;
      ------------------------------------------------------------
      -- Archive Code
      ------------------------------------------------------------
      procedure archive_code
           ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
             p_effective_date        in date)
      is
           --
           l_assignment_id     per_all_assignments_f.assignment_id%type;
           l_payroll_id        pay_payroll_actions.payroll_action_id%type ;
	   --------------------------
	   -- Tables for pay_balance_pkg
	   --------------------------
           g_balance_value_tab     pay_balance_pkg.t_balance_value_tab;
           g_context_tab           pay_balance_pkg.t_context_tab;
           g_detailed_bal_out_tab  pay_balance_pkg.t_detailed_bal_out_tab;
	   --
           l_asg_act_id            pay_assignment_actions.assignment_action_id%type;
           l_action_info_id        pay_action_information.action_information_id%type;
           l_ovn                   pay_action_information.object_version_number%type;
           l_person_id             per_all_people_f.person_id%type;
	   l_fwl_amt               number;
	   l_spl_amt               number; /* Bug: 3595103 */

           l_1984_frozen_earnings number; /*Bug 3501915 */

           ---------------------------------------------------------------------------
	   -- Employee Details cursor
           -- Bug# 4226037  Included period_of_service_id join to fetch  correct
           -- actual_termination_date of an assignment.
           ---------------------------------------------------------------------------
           cursor csr_employee_details
	          ( p_assignment_action_id in pay_assignment_actions.assignment_action_id%type )
               is
           select  substr(pap.per_information1,1,22),
                   substr(pap.employee_number,1,15),
                   fnd_date.date_to_canonical(pps.actual_termination_date),
                   decode(g_pact.month_date,to_char(pap.start_date,'YYYYMM'),'NEW','EE') emp_status,
                   rpac.assignment_action_id,
                   fnd_date.date_to_canonical(rppa.effective_date),
                   pap.per_information6,
                   substr(hou.name,1,80),
                   nvl(pap.per_information14,pap.national_identifier),
                   fnd_date.date_to_canonical(pps.date_start),
                   pap.person_id,
                   fnd_date.date_to_canonical(paa.effective_start_date)
             from  pay_assignment_actions  pac,
                   pay_payroll_actions     rppa,
                   pay_assignment_actions  rpac,
                   per_assignments_f       paa,
                   per_people_f            pap,
                   per_periods_of_service  pps,
                   hr_organization_units   hou
             where  pac.assignment_action_id  = p_assignment_action_id
               and  pac.assignment_id         = rpac.assignment_id
               and  rpac.payroll_action_id    = rppa.payroll_action_id
               and  rppa.action_type          in ('R','Q')
               and  rpac.action_status        = 'C'
               and  rppa.effective_date       between g_pact.start_date
                                                  and g_pact.end_date
               and  pac.assignment_id         = paa.assignment_id
               and  rppa.effective_date       between paa.effective_start_date
                                                  and paa.effective_end_date
               and  paa.person_id             = pap.person_id
               and  rppa.effective_date       between pap.effective_start_date
                                                  and pap.effective_end_date
               and  pap.person_id             = pps.person_id
               and  paa.period_of_service_id  = pps.period_of_service_id
               and  paa.organization_id       = hou.organization_id
             order by rppa.action_sequence desc;

     begin
             l_package   := ' pay_sg_cpfline.';
             l_proc_name := l_package || 'archive_code';
             l_1984_frozen_earnings := 0;

             ---------------------------------
	     -- Initializing rec_action_info
             ---------------------------------
             rec_action_info := null ;
             --------------------------------
	     -- Populating rec_action_info with Employee Details
             --------------------------------
             if  g_debug then
                     hr_utility.set_location(l_proc_name||' Start of archive_code',40);
             end if;
             --
             open  csr_employee_details( p_assignment_action_id ) ;
            fetch  csr_employee_details
             into  rec_action_info.action_information17,    -- Legal Name
                   rec_action_info.action_information18,    -- Employee Number
                   rec_action_info.action_information19,    -- Termination Date
                   rec_action_info.action_information2 ,    -- Employee Status (EE/NEW)
                   l_asg_act_id ,
                   rec_action_info.action_information20,    -- Employee payroll run date
		   rec_action_info.action_information21,    -- Permit Type
		   rec_action_info.action_information22,    -- Department
		   rec_action_info.action_information1,     -- CPF Number
		   rec_action_info.action_information3,     -- Hire Date
		   l_person_id ,
		   rec_action_info.action_information23;    -- Assignment Effective Start Date
            close  csr_employee_details;
             -------------------------------------------------------
             -- Do a batch balance retrieval for better performance
             -------------------------------------------------------
             g_balance_value_tab.delete;
             g_context_tab.delete;
             g_detailed_bal_out_tab.delete;
             --------------------------------------------------------------------------
	     -- Populating g_balance_value_tab with defined balance ids and tax unit id
             --------------------------------------------------------------------------
             g_balance_value_tab(1).defined_balance_id  := get_def_bal_id('Voluntary CPF Liability');
             g_balance_value_tab(2).defined_balance_id  := get_def_bal_id('Voluntary CPF Withheld');
             g_balance_value_tab(3).defined_balance_id  := get_def_bal_id('CPF Liability');
             g_balance_value_tab(4).defined_balance_id  := get_def_bal_id('CPF Withheld');
             g_balance_value_tab(5).defined_balance_id  := get_def_bal_id('MBMF Withheld');
             g_balance_value_tab(6).defined_balance_id  := get_def_bal_id('SINDA Withheld');
             g_balance_value_tab(7).defined_balance_id  := get_def_bal_id('CDAC Withheld');
             g_balance_value_tab(8).defined_balance_id  := get_def_bal_id('ECF Withheld');
             g_balance_value_tab(9).defined_balance_id  := get_def_bal_id('CPF Ordinary Earnings Eligible Comp');
             g_balance_value_tab(10).defined_balance_id := get_def_bal_id('CPF Additional Earnings Eligible Comp');
             g_balance_value_tab(11).defined_balance_id := get_def_bal_id('Community Chest Withheld');
             g_balance_value_tab(12).defined_balance_id := get_def_bal_id('SDL Liability');
             g_balance_value_tab(13).defined_balance_id := get_def_bal_id('FWL Liability');
	     g_balance_value_tab(14).defined_balance_id := get_def_bal_id('S Pass Liability');
	     /* Bug# 3501915 */
	     g_balance_value_tab(15).defined_balance_id := get_def_bal_id('CPF Elig Comp 1984 Frozen Salary and Other Earnings');
             --
             for counter in 1..g_balance_value_tab.count  loop
                   g_context_tab(counter).tax_unit_id := g_pact.legal_entity_id;
             end loop;
             -----------------------------------------
             -- Batch Balance Retrival
             -----------------------------------------
             pay_balance_pkg.get_value( l_asg_act_id ,
                                        g_balance_value_tab,
                                        g_context_tab,
                                        false,
                                        false,
                                        g_detailed_bal_out_tab );
             ----------------------------------------------------------------------
             -- Populating record rec_action_info with Balance Values
             ----------------------------------------------------------------------
             rec_action_info.action_information4   := g_detailed_bal_out_tab(1).balance_value;   -- Voluntary CPF Liability
             rec_action_info.action_information5   := g_detailed_bal_out_tab(2).balance_value;   -- Voluntary CPF Withheld
             rec_action_info.action_information6   := g_detailed_bal_out_tab(3).balance_value;   -- CPF Liability
             rec_action_info.action_information7   := g_detailed_bal_out_tab(4).balance_value;   -- CPF Withheld
             rec_action_info.action_information8   := g_detailed_bal_out_tab(5).balance_value;   -- MBMF Withheld
             rec_action_info.action_information9   := g_detailed_bal_out_tab(6).balance_value;   -- SINDA Withheld
             rec_action_info.action_information10  := g_detailed_bal_out_tab(7).balance_value;   -- CDAC Withheld
             rec_action_info.action_information11  := g_detailed_bal_out_tab(8).balance_value;   -- ECF Withheld
             rec_action_info.action_information12  := g_detailed_bal_out_tab(9).balance_value;   -- CPF Ordinary Earnings Eligible Comp

             ------------------------------------------------------------------------
	     -- Bug 3501915 - IF CPF Elig 1984 CPF Earnings exists and current month ordinary earnings are
	     -- greater than zero then report frozen earnings in magtape file
             -------------------------------------------------------------------------
	     l_1984_frozen_earnings                := g_detailed_bal_out_tab(15).balance_value;  -- CPF Elig Comp 1984 Frozen Salary and Other Earnings
             if l_1984_frozen_earnings > 0 and (rec_action_info.action_information12) > 0 then
                  rec_action_info.action_information12  := l_1984_frozen_earnings;
             end if;

             rec_action_info.action_information13  := g_detailed_bal_out_tab(10).balance_value;  -- CPF Additional Earnings Eligible Comp
             rec_action_info.action_information14  := g_detailed_bal_out_tab(11).balance_value;  -- Community Chest Withheld
             rec_action_info.action_information15  := g_detailed_bal_out_tab(12).balance_value;  -- SDL Eligible Comp
	     /* Bug 3595103 - Archived sum of S Pass Liability, FWL Liability in pai.action_information16 */
	     l_fwl_amt :=  g_detailed_bal_out_tab(13).balance_value; -- FWL Liability
	     l_spl_amt :=  g_detailed_bal_out_tab(14).balance_value; -- S Pass Liability
             rec_action_info.action_information16  := l_fwl_amt + l_spl_amt  ;

             ------------------------------------------------
             -- Insert data into pay_action_information
             ------------------------------------------------
             if  g_debug then
                     hr_utility.set_location(l_proc_name||' Before Insert into pay_action_information',40);
             end if;
             insert into pay_action_information (
                         action_information_id,
                         action_context_id,
                         action_context_type,
			 effective_date,
			 source_id,
                         tax_unit_id,
                         action_information_category,
                         action_information1,
                         action_information2,
                         action_information3,
                         action_information4,
                         action_information5,
                         action_information6,
                         action_information7,
                         action_information8,
                         action_information9,
                         action_information10,
                         action_information11,
                         action_information12,
                         action_information13,
                         action_information14,
                         action_information15,
                         action_information16,
                         action_information17,
                         action_information18,
                         action_information19,
                         action_information20,
                         action_information21,
                         action_information22,
                         action_information23)
             values (
                         pay_action_information_s.nextval,
                         p_assignment_action_id,
			 'AAC',
                         fnd_date.canonical_to_date(rec_action_info.action_information20),
                         l_person_id,
			 g_pact.legal_entity_id,
			 'SG CPF DETAILS',
			 rec_action_info.action_information1,
			 rec_action_info.action_information2,
			 rec_action_info.action_information3,
			 rec_action_info.action_information4,
			 rec_action_info.action_information5,
			 rec_action_info.action_information6,
			 rec_action_info.action_information7,
			 rec_action_info.action_information8,
			 rec_action_info.action_information9,
			 rec_action_info.action_information10,
			 rec_action_info.action_information11,
			 rec_action_info.action_information12,
			 rec_action_info.action_information13,
			 rec_action_info.action_information14,
			 rec_action_info.action_information15,
			 rec_action_info.action_information16,
			 rec_action_info.action_information17,
			 rec_action_info.action_information18,
			 rec_action_info.action_information19,
			 rec_action_info.action_information20,
			 rec_action_info.action_information21,
			 rec_action_info.action_information22,
                         rec_action_info.action_information23 ) ;
             if  g_debug then
                     hr_utility.set_location(l_proc_name||' After Insert into pay_action_information',40);
             end if;
	     --
             if  g_debug then
                     hr_utility.set_location(l_proc_name||' End of archive_code',40);
             end if;
      end archive_code ;
      ---------------------------------
      -- Deinitialization_code
      -- Removes data from pay_action_information
      -- table based on parameter value
      -- Bug: 3619297 - Added check on action_context_type
      ---------------------------------
      procedure deinit_code
             ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
      is
             retain_archive_flag char(1) ;
      begin
               retain_archive_flag  := 'N' ;
             select  pay_core_utils.get_parameter('RETAIN_ARCHIVE_DATA',ppa.legislative_parameters)
               into  retain_archive_flag
               from  pay_payroll_actions ppa
              where  ppa.payroll_action_id = p_payroll_action_id ;
             --
             if retain_archive_flag = 'N' then
                  delete  from pay_action_information
	           where  action_context_id in ( select  assignment_action_id
	                                           from  pay_assignment_actions
                                                  where  payroll_action_id =  p_payroll_action_id )
                     and  action_information_category = 'SG CPF DETAILS'
                     and  action_context_type = 'AAC';
             end if ;
             --
      end deinit_code ;

    ---------------------------------------------------------------------------
    -- Bug 7532687 The function to check if the CPF CSN is invalid
    ---------------------------------------------------------------------------
    function check_cpf_number (p_er_cpf_number in varchar2,
                     p_er_cpf_category in varchar2,
                     p_er_payer_id     in varchar2) return char is

      l_return        varchar2(1);
      l_cpf_num_uen   varchar2(10);
      l_cpf_num_pc    varchar2(3);
      l_cpf_num_pc_s  varchar2(2);
      l_cpf_category  varchar2(20);
      l_payer_id_type varchar2(1);
      l_year          number;
    begin

      if g_debug then
          hr_utility.set_location('pay_sg_cpfline: Start of check_cpf_number',10);
      end if;

      l_cpf_num_uen  := substr(p_er_cpf_number,1,10);
      l_cpf_num_pc   := substr(p_er_cpf_number,11,3);
      l_cpf_num_pc_s := substr(p_er_cpf_number,14,2);
      l_cpf_category    := p_er_cpf_category;
      l_payer_id_type   := p_er_payer_id;

      l_return := 'Z';

      if length(p_er_cpf_number) = 15 then
        if l_payer_id_type = 'U' then
          if (substr(l_cpf_num_uen, 1, 1) = 'S' or
                substr(l_cpf_num_uen, 1, 1) = 'T') then
             if pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 2, 2)) and
                 not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 4, 2)) and
                  pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 6,4)) and
                   not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen,10,1)) then
               null;
             else
               l_return := 'N';
             end if;
          else
            l_return := 'N';
          end if;
        elsif l_payer_id_type = '7' then
          if pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen,1,8)) and
            not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen,9,1)) and
              substr(l_cpf_num_uen,10,1) = ' '  then
            null;
          else
            l_return := 'N';
          end if;
        elsif l_payer_id_type = '8' then
            l_year := to_number(substr(l_cpf_num_uen, 1, 4));
            if ((l_year >= 1900 and l_year < 4712) and
                 pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 5, 5)) and
                not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 10, 1))) or
              (substr(l_cpf_num_uen, 1, 1) = 'F' and
                 pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 2, 8)) and
                not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_uen, 10, 1))) then
              null;
            else
              l_return := 'N';
            end if;
        else
          l_return := 'N';
        end if;
      else
        l_return := 'N';
      end if;

      if l_return <> 'N' then
        if l_cpf_category = 'A' then
          if l_cpf_num_pc = 'PTE' or l_cpf_num_pc = 'AMS' or
              l_cpf_num_pc = 'VCT' or l_cpf_num_pc = 'VSE' or
                l_cpf_num_pc = ' MSE' then
            null;
          else
            l_return := 'N';
          end if;
        else
          if not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_pc,1,1)) and
              not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_pc,2,1)) and
                not pay_sg_iras_archive.check_is_number(substr(l_cpf_num_pc,3,1)) then
            null;
          else
            l_return := 'N';
          end if;
        end if;
      end if;

      if l_return <> 'N' then
        if pay_sg_iras_archive.check_is_number(substr(l_cpf_num_pc_s,1,1)) and
            pay_sg_iras_archive.check_is_number(substr(l_cpf_num_pc_s,2,1)) then
          null;
        else
          l_return := 'N';
        end if;
      end if;

      if g_debug then
          hr_utility.set_location('pay_sg_cpfline: End of check_cpf_number',20);
      end if;

      return l_return;
   end check_cpf_number;



begin
     -------------------------------------------
     -- package body level code
     -- Populates defined Balance ids
     -- Bug 3595103 - Added new balance S Pass Liability
     -------------------------------------------
     select pdb.defined_balance_id,pbt.balance_name
       bulk collect into   g_def_bal_id , g_def_bal_name
      from   pay_balance_types pbt,
             pay_defined_balances pdb,
             pay_balance_dimensions pbd
     where   pbt.legislation_code = 'SG'
       and   pbd.legislation_code = pbt.legislation_code
       and   pdb.legislation_code = pbt.legislation_code
       and   pbt.balance_type_id = pdb.balance_type_id
       and   pbd.balance_dimension_id = pdb.balance_dimension_id
       and   pbd.dimension_name = '_ASG_LE_MONTH'
       and   pbt.balance_name in ('CDAC Withheld',
                                  'CPF Additional Earnings Eligible Comp',
                                  'CPF Liability',
                                  'CPF Ordinary Earnings Eligible Comp',
                                  'CPF Withheld',
                                  'Community Chest Withheld',
                                  'ECF Withheld',
                                  'FWL Liability',
				  'S Pass Liability',
                                  'MBMF Withheld',
                                  'SDL Liability',
                                  'SINDA Withheld',
                                  'Voluntary CPF Liability',
                                  'Voluntary CPF Withheld',
				  'CPF Elig Comp 1984 Frozen Salary and Other Earnings') /*Bug 3501915 */
      order by 2 ;

end pay_sg_cpfline;

/
