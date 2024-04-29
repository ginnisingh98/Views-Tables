--------------------------------------------------------
--  DDL for Package Body PAY_SG_AWCAP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_AWCAP_ARCHIVE" as
/* $Header: pysgawcp.pkb 120.0.12010000.7 2009/03/20 07:46:37 lnagaraj ship $ */
      -------------------------------------------------------------------
      -- Package Level Global Variables
      -------------------------------------------------------------------
      l_package varchar2(100) ;
      g_debug   boolean;
      ----------------------------------------------------------------------
      -- Record with payroll action details populated in Initialization_code
      ----------------------------------------------------------------------
      type t_pact is record (
            report_type             pay_payroll_actions.report_type%TYPE,
            report_qualifier        pay_payroll_actions.report_qualifier%TYPE,
            report_category         pay_payroll_actions.report_category%TYPE,
            business_group_id       number,
            effective_date          date,
            retain_archive_data     char(1),
            person_id               per_people_f.person_id%type,
            basis_year              varchar2(4),
            legal_entity_id         number ,
            Start_date              date ,
            End_date                date );
      --
      g_pact                  t_pact;
      --
      ----------------------------------------------------------------------
      --Table to store employee details
      ----------------------------------------------------------------------
      type emp_details_store_rec is record (
            employee_name     per_all_people_f.per_information1%type ,
            employee_number   per_all_people_f.employee_number%type ,
            cpf_number        per_all_people_f.per_information14%type,
            person_id         per_all_people_f.person_id%type,
            telephone_number  per_addresses.telephone_number_1%type) ;
      --
      emp_details_rec emp_details_store_rec;
      --
      -----------------------------------------------------
      -- Table to store Defined Balance details
      -----------------------------------------------------
      type t_def_bal_tbl is table of pay_defined_balances.defined_balance_id%type;
      g_ytd_def_bal_tbl      t_def_bal_tbl;
      g_mtd_def_bal_tbl      t_def_bal_tbl;
      --
      type t_bal_name_tbl is table of pay_balance_types.balance_name%type;
      g_bal_name_tbl         t_bal_name_tbl;
      -------------------------------------------------------------------
      -- YTD balances Archival Variables
      -------------------------------------------------------------------
      type ytd_balance_store_rec is record ( balance_name   varchar2(60),
                                             balance_value  number );
      type ytd_balance_tab is table of ytd_balance_store_rec index by binary_integer;
      ytd_balance_rec  ytd_balance_tab;
      -------------------------------------------------------------------
      -- MTD balances Archival Variables
      -------------------------------------------------------------------
      type mtd_balance_store_rec is record (  date_earned    varchar2(20),
                                              balance_value  number );
      type mtd_balance_tab is table of mtd_balance_store_rec index by binary_integer;
      mtd_balance_rec  mtd_balance_tab;
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
         l_proc_name varchar2(100);
         c_range_cursor  constant varchar2(3000) :=
                                   ' select   distinct pap.person_id
                                       from   pay_payroll_actions    ppa,
                                              per_people_f           pap
                                      where   ppa.payroll_action_id = :payroll_action_id
                                        and   pap.business_group_id = ppa.business_group_id
                                      order by pap.person_id ' ;
      begin
           l_proc_name := l_package || 'range_code';
           if  g_debug then
                  hr_utility.set_location(l_proc_name||' Start of procedure',10);
           end if;
           p_sql := c_range_cursor ;
           if  g_debug then
                  hr_utility.set_location(l_proc_name||' End of procedure',20);
           end if;
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
          l_proc_name varchar2(100) ;
          l_next_action_id  pay_assignment_actions.assignment_action_id%type;
          --
	  cursor  c_assact
              is
          select  max(paa.assignment_id)  assignment_id
            from  pay_payroll_actions     rppa,
		  pay_assignment_actions  rpac,
		  per_assignments_f       paa
          where  paa.person_id          between p_start_person_id
                                             and p_end_person_id
             and  rppa.business_group_id = g_pact.business_group_id
             and  rppa.effective_date    between g_pact.start_date
                                             and g_pact.end_date
             and  rppa.action_type       in ('R','B','I','Q','V')
             and  rpac.action_status     = 'C'
             and  rppa.payroll_action_id = rpac.payroll_action_id
             and  rpac.tax_unit_id       = g_pact.legal_entity_id
             and  rpac.assignment_id     = paa.assignment_id
             and  rppa.effective_date    between paa.effective_start_date
                                             and paa.effective_end_date
             and  paa.person_id + 0      = nvl(g_pact.person_id,paa.person_id)
	     group by paa.person_id;
            --
          cursor  next_action_id
              is
          select  pay_assignment_actions_s.nextval
            from  dual;
           --
      begin
          l_proc_name   := l_package || 'assignment_action_code';
          pay_sg_awcap_archive.initialization_code(p_payroll_action_id) ;
          --
          if g_debug then
               hr_utility.set_location(l_proc_name || ' Start of assignment_action_code',30);
          end if;
          --
          for i in c_assact
          loop
                open   next_action_id;
                fetch  next_action_id into l_next_action_id;
                close  next_action_id;
                --
		if g_debug then
                     hr_utility.set_location(l_proc_name|| ' Before calling hr_nonrun_asact.insact',10);
                end if;
                --
                hr_nonrun_asact.insact( l_next_action_id,
                                        i.assignment_id,
                                        p_payroll_action_id,
                                        p_chunk,
                                        g_pact.legal_entity_id);
                --
                if  g_debug then
                      hr_utility.set_location(l_proc_name||' After calling hr_nonrun_asact.insact',20);
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
                       hr_utility.set_location(l_proc_name||' Error raised in assignment_action_code procedure',40);
                end if;
                raise;
      end assignment_action_code ;
      --
      ------------------------------------------------------------
      -- Initialization Code
      ------------------------------------------------------------
      --
      procedure initialization_code
          ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
      is
          l_proc_name varchar2(100) ;
      begin
           l_proc_name  := l_package || 'initialization_code';

           g_debug := hr_utility.debug_enabled;
           --
           if  g_debug then
                  hr_utility.set_location(l_proc_name||' Start of procedure',10);
           end if;
           --
           if g_pact.report_type is null then
                  select  ppa.report_type,
                          ppa.report_qualifier,
                          ppa.report_category,
                          ppa.business_group_id,
                          ppa.effective_date,
                          pay_core_utils.get_parameter('RETAIN_ARCHIVE_DATA',legislative_parameters),
  		          pay_core_utils.get_parameter('PERSON_ID',legislative_parameters),
                          to_number(pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters)),
			  to_number(pay_core_utils.get_parameter('LEGAL_ENTITY_ID',ppa.legislative_parameters)) legal_entity_id,
                          to_date('01-01-'||pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY'),
                          to_date('31-12-'|| pay_core_utils.get_parameter('BASIS_YEAR',legislative_parameters),'DD-MM-YYYY')
                          into  g_pact
                    from  pay_payroll_actions ppa
                   where  ppa.payroll_action_id = p_payroll_action_id;
           end if ;
           --
           if  g_debug then
                  hr_utility.set_location(l_proc_name||' End of procedure',20);
           end if;
      exception
           when others then
                 if  g_debug then
                      hr_utility.set_location(l_proc_name||' Error in procedure',100);
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

           l_proc_name             varchar2(100) ;
	   --
           l_assignment_id         per_all_assignments_f.assignment_id%type;
           l_payroll_id            pay_payroll_actions.payroll_action_id%type ;
           --------------------------
	   -- Tables for pay_balance_pkg
	   --------------------------
           g_balance_value_tab     pay_balance_pkg.t_balance_value_tab;
           g_context_tab           pay_balance_pkg.t_context_tab;
           g_detailed_bal_out_tab  pay_balance_pkg.t_detailed_bal_out_tab;
	   --
           l_asg_act_id            pay_assignment_actions.assignment_action_id%type;
           l_person_id             per_all_people_f.person_id%type;
           l_cpf_tot_earn_cap_amt  ff_globals_f.global_value%type;
           l_aw_toward_cap         number;
           l_aw_cap_recalculated   number;
           l_master_block          char(1);
           l_over_paid_flag        char(1);
           l_date_earned           date;
           --
           cursor  c_get_details
            is
           select  pac.assignment_id,
                   pps.person_id,
                   pps.final_process_date
           from    pay_assignment_actions pac,
	           per_assignments_f      paa,
	           per_periods_of_service pps
           where   pac.assignment_action_id = p_assignment_action_id
             and   paa.assignment_id        = pac.assignment_id
  	     and   pps.person_id            = paa.person_id
   	   order by pps.date_start desc;
           --
           cursor c_employee_details
	           (c_person_id   per_people_f.person_id%type)
               is
           select  substr(pap.per_information1,1,50)  legal_name,                 --Legal Name
                   pap.employee_number                employee_number,            --Employee Number
                   nvl(pap.per_information14,pap.national_identifier) cpf_number, --CPF Number/National Identifier
                   pap.person_id                      person_id,                  --Person ID
                   nvl(addr.telephone_number_1,nvl(addr.telephone_number_2,addr.telephone_number_3)) telephone_number
             from  per_people_f            pap,
                   per_addresses           addr
            where  pap.person_id              = c_person_id
              and  addr.person_id          (+)= pap.person_id
              and  addr.primary_flag       (+)= 'Y'
              and  pap.effective_start_date = (
                       select  max(people1.effective_start_date)
                       from    per_people_f people1
                       where   people1.person_id = pap.person_id);
            --
           cursor  month_year_action_sequence ( c_person_id          per_all_people_f.person_id%type,
                                                c_business_group_id  hr_organization_units.business_group_id%type,
                                                c_legal_entity_id    pay_assignment_actions.tax_unit_id%type,
                                                c_basis_year         varchar2 )
           is
           select  /*+ ORDERED USE_NL(pacmax) */
                   max(pacmax.action_sequence) act_seq,
                   to_char(ppamax.effective_date,'MM')
             from  per_assignments_f paamax,
                   pay_assignment_actions pacmax,
                   pay_payroll_actions ppamax
            where  ppamax.business_group_id   = c_business_group_id
              and  pacmax.tax_unit_id         = c_legal_entity_id
              and  paamax.person_id           = c_person_id
              and  paamax.assignment_id       = pacmax.assignment_id
              and  ppamax.payroll_action_id   = pacmax.payroll_action_id
              and  ppamax.effective_date between g_pact.start_date
                                             and g_pact.end_date
              and  ppamax.action_type in ('R','B','I','Q','V')
            group by  to_char(ppamax.effective_date,'MM')
            order by  to_char(ppamax.effective_date,'MM') desc;
            --
   	   cursor  month_year_action ( c_person_id          per_all_people_f.person_id%type,
                                       c_business_group_id  hr_organization_units.business_group_id%type,
                                       c_legal_entity_id    pay_assignment_actions.tax_unit_id%type,
                                       c_basis_year         varchar2,
                                       c_action_sequence    pay_assignment_actions.action_sequence%type )
           is
           select  /*+ ORDERED USE_NL(pac) */
                   pac.assignment_action_id assact_id,
                   decode(ppa.action_type,'V',ppa.effective_date,ppa.date_earned) date_earned,
                   pac.tax_unit_id tax_uid
             from  per_assignments_f paa,
                   pay_assignment_actions pac,
		   pay_payroll_actions ppa
            where  ppa.business_group_id = c_business_group_id
              and  pac.tax_unit_id       = c_legal_entity_id
              and  paa.person_id         = c_person_id
              and  paa.assignment_id     = pac.assignment_id
              and  ppa.effective_date    between g_pact.start_date
                                         and g_pact.end_date
              and  ppa.payroll_action_id = pac.payroll_action_id
              and  pac.action_sequence   = c_action_sequence;
            --
           cursor c_globals
           is
           select  global_value
             from  ff_globals_f
            where  global_name = 'CPF_TOT_EARN_CAP_AMT'
              and  g_pact.end_date between effective_start_date and effective_end_date ;
            --
           month_year_action_sequence_rec  month_year_action_sequence%rowtype;
           month_year_action_rec           month_year_action%rowtype;
           --
   begin
         l_proc_name              := l_package || 'archive_code';

         l_aw_toward_cap          := 0;
         l_aw_cap_recalculated    := 0;
         l_master_block           := 'Y';
         l_over_paid_flag         := 'N';

         if  g_debug then
                hr_utility.set_location(l_proc_name||' Start of archive_code',10);
         end if;
         open   c_get_details ;
         fetch  c_get_details  into l_assignment_id,l_person_id,l_date_earned;
         close  c_get_details ;
         ---------------------------------------------------------------------------------------
         --Storing minimum of final process date and end of the basis year .
         ---------------------------------------------------------------------------------------
         l_date_earned := least(nvl(l_date_earned,to_date('31-12-4712','dd-mm-yyyy')),g_pact.end_date);
         --
         --------------------------------------------------------
         -- Fetch the value for the global 'CPF_TOT_EARN_CAP_AMT'
         --------------------------------------------------------
         open   c_globals;
         fetch  c_globals into l_cpf_tot_earn_cap_amt ;
         close  c_globals;
         --
         open month_year_action_sequence( l_person_id,
                                          g_pact.business_group_id,
                                          g_pact.legal_entity_id,
                                          g_pact.basis_year );
         loop
               fetch month_year_action_sequence into month_year_action_sequence_rec;
               exit when month_year_action_sequence%notfound;
               --
               open month_year_action( l_person_id,
                                       g_pact.business_group_id,
                                       g_pact.legal_entity_id,
                                       g_pact.basis_year,
                                       month_year_action_sequence_rec.act_seq );
               --
               fetch month_year_action into month_year_action_rec;
               if month_year_action%found then
               --
                        if l_master_block = 'Y' then

                             ----------------------------------------------------
	                     -- Populating emp_details_rec with Employee Details
                             -----------------------------------------------------

                             open   c_employee_details(l_person_id);
                             fetch  c_employee_details into emp_details_rec;
                             close  c_employee_details;
                             --
                             --------------------------------------------------------------------------
                             -- Populating g_balance_value_tab with defined balance ids and
                             -- g_context_tab with tax unit id.
                             --------------------------------------------------------------------------
                             --
                             for counter in 1..g_ytd_def_bal_tbl.count
                             loop
                                   g_balance_value_tab(counter).defined_balance_id := g_ytd_def_bal_tbl(counter);
                                   g_context_tab(counter).tax_unit_id              := g_pact.legal_entity_id;
                             end loop;
                             --
                             -----------------------------------------
                             -- Batch Balance Retrival
                             -----------------------------------------
                             --
                             pay_balance_pkg.get_value ( month_year_action_rec.assact_id,
                                                         g_balance_value_tab,
                                                         g_context_tab,
                                                         false,
                                                         false,
                                                         g_detailed_bal_out_tab );
                             --
                             --------------------------------------------------------------------------
                             -- Populating record ytd_balance_rec with Balance Values and Balance Name.
                             --------------------------------------------------------------------------
                             --
                             for counter in 1..g_detailed_bal_out_tab.count
                             loop
                                   ytd_balance_rec(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0);
                                   ytd_balance_rec(counter).balance_name  := g_bal_name_tbl(counter);
                             --------------------------------------------------------------------------------
                             -- Storing balance 'CPF Additional Earnings Toward Cap' in to local variable.
                             --------------------------------------------------------------------------------
                                   if g_bal_name_tbl(counter) = 'CPF Additional Earnings Toward Cap' then
                                         l_aw_toward_cap := nvl(g_detailed_bal_out_tab(counter).balance_value,0);
                                   end if;
                             end loop;
                             --
                             -----------------------------------------------------------------------------------
                             -- Additional Wages Cap is recalculated based on current year Ordinary Earnings.
                             -----------------------------------------------------------------------------------
                             --
                             l_aw_cap_recalculated := nvl(l_cpf_tot_earn_cap_amt,0) - nvl(get_cur_year_ord_ytd(l_person_id,l_assignment_id,l_date_earned),0);
                             --
                             ------------------------------------------------
                             -- Insert data into pay_action_information
                             ------------------------------------------------
                             --
                             insert into pay_action_information (
                                         action_information_id,
                                         action_context_id,
                                         action_context_type,
                                         tax_unit_id,
                                         assignment_id,
                                         action_information_category,
                                         action_information1,
                                         action_information2,
                                         action_information3,
                                         action_information4,
                                         action_information5,
                                         action_information6,  -- Additional Earnings
                                         action_information7,  -- CPF Additional Earnings Toward Cap
                                         action_information8)  -- Additional Wages Cap Recalculated
                             values (    pay_action_information_s.nextval,
                                         p_assignment_action_id,
                                         'AAC',
                                         g_pact.legal_entity_id,
                                         l_assignment_id,
                                         'SG AWCAP DETAILS',
                                         'HEADER',
                                         emp_details_rec.employee_number,
                                         emp_details_rec.employee_name,
                                         emp_details_rec.cpf_number,
                                         emp_details_rec.telephone_number,
                                         ytd_balance_rec(1).balance_value,
                                         ytd_balance_rec(2).balance_value,
                                         l_aw_cap_recalculated  ) ;
                             --
                             if nvl(l_aw_cap_recalculated,0) >= nvl(l_aw_toward_cap,0) then
                                   l_over_paid_flag := 'N';
                                   l_master_block   := 'N';
                             else
                                   l_over_paid_flag := 'Y';
                                   l_master_block   := 'N';
                             end if;
                        end if;
                        --
                        ------------------------------------------------------------------------------
                        --
                        if l_over_paid_flag = 'Y' then
                             --------------------------------------------------------------------------
                             -- Populating g_balance_value_tab with defined balance ids and
                             -- g_context_tab with tax unit id.
                             --------------------------------------------------------------------------
                             for counter in 1..g_mtd_def_bal_tbl.count
                             loop
                                    g_balance_value_tab(counter).defined_balance_id := g_mtd_def_bal_tbl(counter);
                                    g_context_tab(counter).tax_unit_id              := g_pact.legal_entity_id;

                             end loop;
                             --
                             -----------------------------------------
                             -- Batch Balance Retrival
                             -----------------------------------------
                             --
                             pay_balance_pkg.get_value  (  month_year_action_rec.assact_id,
                                                           g_balance_value_tab,
                                                           g_context_tab,
                                                           false,
                                                           false,
                                                           g_detailed_bal_out_tab );
                             --
                             --------------------------------------------------------------------------
                             -- Populating record mtd_balance_rec with Balance Values and Date Earned.
                             --------------------------------------------------------------------------
                             --
                             for counter in 1..g_detailed_bal_out_tab.count
                             loop
                                    mtd_balance_rec(counter).balance_value := nvl(g_detailed_bal_out_tab(counter).balance_value,0);
                                    mtd_balance_rec(counter).date_earned   := month_year_action_rec.date_earned;

                             end loop;
                             --
                             ------------------------------------------------
                             -- Insert data into pay_action_information
                             ------------------------------------------------
                             --
                             insert into pay_action_information (
                                         action_information_id,
                                         action_context_id,
                                         action_context_type,
                                         tax_unit_id,
                                         assignment_id,
                                         effective_date,
                                         action_information_category,
                                         action_information1,
                                         action_information2,    -- Additional Earnings
                                         action_information3,    -- EE CPF AE
                                         action_information4,    -- EE CPF OE
                                         action_information5,    -- EE VOL CPF AE
                                         action_information6,    -- EE VOL CPF OE
                                         action_information7,    -- ER CPF AE
                                         action_information8,    -- ER CPF OE
                                         action_information9,    -- ER VOL CPF AE
                                         action_information10,   -- ER VOL CPF OE
                                         action_information11  ) -- Ordinary Earnings
                             values (
                                         pay_action_information_s.nextval,
                                         p_assignment_action_id,
                                         'AAC',
                                         g_pact.legal_entity_id,
                                         l_assignment_id,
                                         mtd_balance_rec(10).date_earned ,
                                         'SG AWCAP DETAILS',
                                         'DETAIL',
                                         mtd_balance_rec(1).balance_value,
                                         mtd_balance_rec(2).balance_value,
                                         mtd_balance_rec(3).balance_value,
                                         mtd_balance_rec(4).balance_value,
                                         mtd_balance_rec(5).balance_value,
                                         mtd_balance_rec(6).balance_value,
                                         mtd_balance_rec(7).balance_value,
                                         mtd_balance_rec(8).balance_value,
                                         mtd_balance_rec(9).balance_value,
                                         mtd_balance_rec(10).balance_value  ) ;
                        end if;
               end if;
               close month_year_action;
         end loop;
         close month_year_action_sequence;
         --
         if  g_debug then
               hr_utility.set_location(l_proc_name||' End of archive_code',20);
         end if;
   exception
        when others then
           if  g_debug then
                 hr_utility.set_location(l_proc_name||' Error raised in procedure',100);
           end if;
           raise;
   end archive_code ;
   ----------------------------------------------------------------------------------
   --Function calculates current year Ordinary Earnings with monthly ceiling of 5,500
   ---------------------------------------------------------------------------------
   function get_cur_year_ord_ytd (p_person_id in per_all_people_f.person_id%type,
                                  p_assignment_id  in per_all_assignments_f.assignment_id%type,
                                  p_date_earned in date) return number
   is
           l_proc_name  varchar2(100);
           --
           cursor c_month_year_action_sequence ( c_date_earned   date)
           is
           select  /*+ ORDERED USE_NL(paa) */
                   max(paa.action_sequence),
                   to_number(to_char(ppa.effective_date,'MM'))
           from    per_assignments_f paaf,
                   pay_assignment_actions paa,
                   pay_payroll_actions ppa
           where   paaf.person_id        = p_person_id
              and  paa.assignment_id     = paaf.assignment_id
              and  ppa.payroll_action_id = paa.payroll_action_id
              and  ppa.action_type       in ('R','Q','B','V','I')
              and  ppa.date_earned       between trunc(c_date_earned,'Y')
                                            and last_day(c_date_earned)
           group by  to_number(to_char(ppa.effective_date,'MM'))
           order by  to_number(to_char(ppa.effective_date,'MM')) desc;
           --
           cursor c_month_year_action ( c_date_earned     date,
                                        c_action_sequence number )
           is
           select /*+ ORDERED USE_NL(paa) */
                   paa.assignment_action_id,
                   ppa.effective_date
            from   per_assignments_f paaf,
                   pay_assignment_actions paa,
                   pay_payroll_actions ppa
            where  paaf.person_id        = p_person_id
              and  paa.assignment_id     = paaf.assignment_id
              and  ppa.payroll_action_id = paa.payroll_action_id
              and  paa.action_sequence   = c_action_sequence
              and  ppa.date_earned       between trunc(c_date_earned,'Y')
                                         and last_day(c_date_earned);
            --
            cursor c_defined_bal_id ( p_balance_name   in varchar2,
                                      p_dimension_name in varchar2 )
            is
            select pdb.defined_balance_id
            from   pay_defined_balances pdb,
                   pay_balance_types pbt,
                   pay_balance_dimensions pbd
            where  pbt.balance_name         = p_balance_name
              and  pbd.dimension_name       = p_dimension_name
              and  pbt.balance_type_id      = pdb.balance_type_id
              and  pdb.balance_dimension_id = pbd.balance_dimension_id
              and  pdb.legislation_code     = 'SG';
            --
            cursor c_globals(c_date_earned date)
            is
            select global_value
            from   ff_globals_f
            where  global_name = 'CPF_ORD_MONTH_CAP_AMT'
              and  c_date_earned between effective_start_date and effective_end_date;
            --
            g_balance_value_tab      pay_balance_pkg.t_balance_value_tab;
            g_context_tab            pay_balance_pkg.t_context_tab;
            g_detailed_bal_out_tab   pay_balance_pkg.t_detailed_bal_out_tab;
            --
            l_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
            l_action_sequence        pay_assignment_actions.action_sequence%TYPE;
            l_month                  number;
            l_effective_date         date;
            l_tax_unit_id            pay_assignment_actions.tax_unit_id%TYPE;
            l_defined_bal_id         number;
            l_cur_ord_ytd            number;
            l_ord_mon_cap_amt        number;
            l_retro_exist            boolean := FALSE ;
            l_retro_ele              number;
            l_final_process_date     date;
   begin
         l_proc_name   := l_package || 'get_cur_year_ord_ytd';
         l_cur_ord_ytd := 0;
         --
         if  g_debug then
               hr_utility.set_location(l_proc_name||' start of procedure',10);
         end if;

         open  c_globals(p_date_earned);
         fetch c_globals into l_ord_mon_cap_amt;
         close c_globals ;
         --
         open  c_defined_bal_id('CPF Ordinary Earnings Eligible Comp','_PER_LE_MONTH');
         fetch c_defined_bal_id into g_balance_value_tab(1).defined_balance_id;
         close c_defined_bal_id;
         --
         open  c_defined_bal_id('Ordinary Earnings ineligible for CPF','_PER_LE_MONTH');
         fetch c_defined_bal_id into g_balance_value_tab(2).defined_balance_id;
         close c_defined_bal_id;
         --
         open  c_defined_bal_id('Retro Ord Retro Period','_ASG_PTD');
         fetch c_defined_bal_id into g_balance_value_tab(3).defined_balance_id;
         close c_defined_bal_id;
         --
	 -- Start of Bug 7661439
         --
         open  c_defined_bal_id('Ordinary Earnings Ineligible For CPF Calc','_PER_LE_MONTH');
         fetch c_defined_bal_id into g_balance_value_tab(4).defined_balance_id;
         close c_defined_bal_id;
         --
	 -- End of Bug 7661439
         --
         open c_month_year_action_sequence( p_date_earned );
         loop
              fetch c_month_year_action_sequence into l_action_sequence,l_month;
              exit  when c_month_year_action_sequence%NOTFOUND;
              --
              open c_month_year_action( p_date_earned, l_action_sequence );
              fetch c_month_year_action into l_assignment_action_id,l_effective_date;
              --
              if c_month_year_action%FOUND then
               --
                   g_context_tab.delete;
                   g_detailed_bal_out_tab.delete;
                   --
                   g_context_tab(1).tax_unit_id := g_pact.legal_entity_id;
                   g_context_tab(2).tax_unit_id := g_pact.legal_entity_id;
                   g_context_tab(3).tax_unit_id := g_pact.legal_entity_id;
                   g_context_tab(4).tax_unit_id := g_pact.legal_entity_id;         -- Bug 7661439
                   --
                   pay_balance_pkg.get_value ( l_assignment_action_id,
                                               g_balance_value_tab,
                                               g_context_tab,
                                               false,
                                               false,
                                               g_detailed_bal_out_tab );
                   --
                   if l_retro_exist
                       or nvl(g_detailed_bal_out_tab(3).balance_value,0)<>0 then /* Bug 6815874 */
                         l_retro_ele   := pay_sg_deductions.get_retro_earnings( p_assignment_id , l_effective_date ); /* Bug 6815874 */
                         if l_retro_ele = 0 then /* Bug 6815874 */
                             l_retro_exist := FALSE;
                         end if;
                         l_cur_ord_ytd := l_cur_ord_ytd + least( (nvl( g_detailed_bal_out_tab(1).balance_value,0 )
                                                                - nvl( g_detailed_bal_out_tab(2).balance_value,0 )
                                                                - nvl( g_detailed_bal_out_tab(3).balance_value,0 )
                                                                - nvl( g_detailed_bal_out_tab(4).balance_value,0 )    -- Bug 7661439
                                                                + nvl(l_retro_ele,0)),l_ord_mon_cap_amt );
                   else
                         l_cur_ord_ytd := l_cur_ord_ytd + least( (nvl( g_detailed_bal_out_tab(1).balance_value,0 )
                                                                - nvl( g_detailed_bal_out_tab(2).balance_value,0 )
                                                                - nvl( g_detailed_bal_out_tab(4).balance_value,0 )    -- Bug 7661439
                                                                - nvl( g_detailed_bal_out_tab(3).balance_value,0 )),l_ord_mon_cap_amt );
                   end if;
                   --
                   if nvl( g_detailed_bal_out_tab(3).balance_value,0 ) <> 0 then
                         l_retro_exist := TRUE;
                   end if;
                   --
              end if;
              --
              close c_month_year_action;
         end loop;
         --
         close c_month_year_action_sequence;
         --
         if  g_debug then
              hr_utility.set_location(l_proc_name||' End of procedure',20);
         end if;
         return l_cur_ord_ytd;
         --
   exception
        when others then
           if  g_debug then
                 hr_utility.set_location(l_proc_name||' Error raised in procedure',100);
           end if;
           raise;

 end get_cur_year_ord_ytd;
   --
   procedure deinit_code
             ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type )
   is
               retain_archive_flag char(1);
               l_rep_req_id  number;

   begin
         retain_archive_flag  := 'N' ;
         l_rep_req_id         :=  0;
         if g_debug then
             hr_utility.set_location('Start of denit_code',10);
         end if;
         ------------------------------------------------
         -- Call to AW CPF Capping Recalculation Report
         ------------------------------------------------
         l_rep_req_id := FND_REQUEST.SUBMIT_REQUEST (
 	                     APPLICATION          =>   'PAY',
                             PROGRAM              =>   'PAYSGCPF',
                             ARGUMENT1            =>   'P_BASIS_YEAR=' || g_pact.basis_year,
                             ARGUMENT2            =>   'P_BUSINESS_GROUP_ID='|| g_pact.business_group_id,
                             ARGUMENT3            =>   'P_LEGAL_ENTITY=' || g_pact.legal_entity_id,
                             ARGUMENT4            =>   'P_PAYROLL_ACTION_ID=' || p_payroll_action_id,
                             ARGUMENT5            =>   'P_PERSON_ID=' || g_pact.person_id  ,
                             ARGUMENT6            =>   'P_RETAIN_ARCHIVE_DATA='|| g_pact.retain_archive_data);
         --
         if g_debug then
              hr_utility.set_location('End of denit_code',20);
         end if;
   end deinit_code ;
begin

         l_package  := 'pay_sg_awcap_archive-';
         -------------------------------------------
         -- package body level code
         -- Populates defined Balance ids
         -------------------------------------------

         select pdb.defined_balance_id def_bal_id,
                pbt.balance_name
         bulk collect into
                g_ytd_def_bal_tbl,
                g_bal_name_tbl
         from   pay_balance_types pbt,
                pay_defined_balances pdb,
                pay_balance_dimensions pbd
         where  pbt.legislation_code = 'SG'
           and  pbd.legislation_code = pbt.legislation_code
           and  pdb.legislation_code = pbt.legislation_code
           and  pbt.balance_name in ( 'Additional Earnings',
                                      'CPF Additional Earnings Toward Cap' )
           and  pbt.balance_type_id  = pdb.balance_type_id
           and  pbd.balance_dimension_id = pdb.balance_dimension_id
           and  pbd.dimension_name   = '_PER_LE_YTD'
           order by pbt.balance_name;
         --
         select pdb.defined_balance_id def_bal_id
         bulk collect into
                g_mtd_def_bal_tbl
         from   pay_balance_types pbt,
                pay_defined_balances pdb,
                pay_balance_dimensions pbd
         where  pbt.legislation_code = 'SG'
           and  pbd.legislation_code = pbt.legislation_code
           and  pdb.legislation_code = pbt.legislation_code
           and  pbt.balance_name in ('Employee CPF Contributions Additional Earnings',
                                     'Employee CPF Contributions Ordinary Earnings',
                                     'Employer CPF Contributions Additional Earnings',
                                     'Employer CPF Contributions Ordinary Earnings',
                                     'Employee Vol CPF Contributions Additional Earnings',
                                     'Employee Vol CPF Contributions Ordinary Earnings' ,
                                     'Employer Vol CPF Contributions Additional Earnings',
                                     'Employer Vol CPF Contributions Ordinary Earnings',
	 	                     'Additional Earnings',
                                     'Ordinary Earnings')
           and  pbt.balance_type_id = pdb.balance_type_id
           and  pbd.balance_dimension_id = pdb.balance_dimension_id
           and  pbd.dimension_name = '_PER_LE_MONTH'
           order by pbt.balance_name;
            --
 exception
     when others then
          raise;
end pay_sg_awcap_archive;

/
