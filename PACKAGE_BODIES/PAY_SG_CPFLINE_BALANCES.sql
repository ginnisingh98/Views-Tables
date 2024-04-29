--------------------------------------------------------
--  DDL for Package Body PAY_SG_CPFLINE_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_CPFLINE_BALANCES" as
/* $Header: pysgcpfb.pkb 120.0.12000000.4 2007/03/23 09:42:56 snimmala noship $ */
      g_debug   boolean;
      --
      l_package  VARCHAR2(100);
      l_proc_name VARCHAR2(100) ;
      ------------------------------------------------------
      -- Record Used in function dup_bal_value
      -- This is used to store the balance value once for all
      -- the balances and then returned for subsequent columns
      -- in the existing /new employees cursor
      -- Bug No:3298317 Added column permit_type
      ------------------------------------------------------
      TYPE t_cpf_balances IS RECORD
         ( assact_id         pay_assignment_actions.assignment_action_id%type
          ,vol_cpf_liab      number     -- action_information4
          ,cpf_liab          number     -- action_information6
          ,vol_cpf_wheld     number     -- action_information5
          ,cpf_wheld         number     -- action_information7
          ,mbmf_wheld        number     -- action_information8
          ,sinda_wheld       number     -- action_information9
          ,cdac_wheld        number     -- action_information10
          ,ecf_wheld         number     -- action_information11
          ,cpf_ord_earn      number     -- action_information12
          ,cpf_addl_earn     number     -- action_information13
	  ,permit_type       per_people_f.per_information6%type  -- action_information21
         ) ;

      g_cpf_balances       t_cpf_balances ;
      ----------------------------------------------------------------------------
      -- Global Variables used to retain balance values in multiple function calls
      -- Used in function balance_amount
      ----------------------------------------------------------------------------
      g_cpf_with_bal_value         number;
      g_cpf_liab_bal_value         number;
      g_vol_cpf_with_bal_value     number;
      g_vol_cpf_liab_bal_value     number;
      g_comm_chest_with_bal_value  number;
      g_sdl_liab_bal_value         number;
      g_mbmf_with_bal_value        number;
      g_fwl_liab_bal_value         number;
      g_sinda_with_bal_value       number;
      g_cdac_with_bal_value        number;
      g_ecf_with_bal_value         number;

      fwl_reporting     varchar2(1);
      -------------------------------------------------------------
      --Bug# 3501950
      -- This function is called from company_identification cursor
      -------------------------------------------------------------
      function get_cpf_interest
           (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
           return varchar2
      is
           l_cpf_interest varchar2(100);
      begin
           select nvl(pay_core_utils.get_parameter('CPF_INTEREST',legislative_parameters),0)
                  into l_cpf_interest
           from pay_payroll_actions
           where payroll_action_id = c_payroll_action_id;
           return l_cpf_interest;
      end get_cpf_interest;
      -------------------------------------------------------------
      --Bug# 3501950
      -- This function is called from company_identification cursor
      -------------------------------------------------------------
      function get_fwl_interest
           (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
           return varchar2
      is
           l_fwl_interest varchar2(100);
      begin
           select nvl(pay_core_utils.get_parameter('FWL_INTEREST',legislative_parameters),0)
                  into l_fwl_interest
           from pay_payroll_actions
           where payroll_action_id = c_payroll_action_id;
           return l_fwl_interest;
      end get_fwl_interest;
      -----------------------------------------------
      -- Function balance_amount
      -- Returns Balance amount. called from stat_type_amount
      -----------------------------------------------
      function balance_amount
           ( p_payroll_action_id in  number,
             p_balance_name      in  varchar2 ) return number
      is
           l_balance_amount  number;
           /* Bug: 3595103  Modified cursor for permit type 'SP' */
           /* Bug: 5937727  Modified the cursor to exclude negative values from summation */
           cursor  balance_amount
               is
           select  to_char(sum(decode( pai.action_information1,null,0,(decode(pai.action_information21,'WP',0,'EP',0,'SP',0,
                               decode(sign(to_number(pai.action_information7)),1,to_number(pai.action_information7),0))) )),'99999999'),
                   to_char(sum(decode( pai.action_information1,null,0,(decode(pai.action_information21,'WP',0,'EP',0,'SP',0,
                               decode(sign(to_number(pai.action_information6)),1,to_number(pai.action_information6),0))) )),'99999999'),
                   to_char(sum(decode( pai.action_information1,null,0,(decode(pai.action_information21,'WP',0,'EP',0,'SP',0,
                               decode(sign(to_number(pai.action_information5)),1,to_number(pai.action_information5),0))) )),'99999999'),
                   to_char(sum(decode( pai.action_information1,null,0,(decode(pai.action_information21,'WP',0,'EP',0,'SP',0,
                               decode(to_number(sign(pai.action_information4)),1,to_number(pai.action_information4),0))) )),'99999999'),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information14)),1,to_number(pai.action_information14),0)),'999999.99'),0),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information15)),1,to_number(pai.action_information15),0)),'999999.99'),0),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information8)),1,to_number(pai.action_information8),0)),'999999.99'),0),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information16)),1,to_number(pai.action_information16),0)),'999999.99'),0),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information9)),1,to_number(pai.action_information9),0)),'999999.99'),0),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information10)),1,to_number(pai.action_information10),0)),'999999.99'),0),
                   nvl(to_char(sum(decode(sign(to_number(pai.action_information11)),1,to_number(pai.action_information11),0)),'999999.99'),0)
             from  pay_payroll_actions    ppa,
                   pay_assignment_actions paa,
                   pay_action_information pai
            where  ppa.payroll_action_id    = p_payroll_action_id
              and  ppa.payroll_action_id    = paa.payroll_action_id
              and  paa.assignment_action_id = pai.action_context_id
              and  pai.action_information_category = 'SG CPF DETAILS'
              and  pai.action_context_type         = 'AAC' ;

            cursor fwl_amount_reporting
                is
            select  nvl(hoi.org_information20,'Y')
              from  hr_organization_information hoi,
                    pay_payroll_actions ppa
             where  ppa.payroll_action_id = p_payroll_action_id
               and  hoi.organization_id =
                    to_number(pay_core_utils.get_parameter('LEGAL_ENTITY_ID',
                    ppa.legislative_parameters))
               and  hoi.org_information_context = 'SG_LEGAL_ENTITY';
      begin
           l_package  := ' pay_sg_cpfline.';
            l_proc_name  := l_package || 'balance_amount';
           if  g_debug then
                hr_utility.set_location(l_proc_name || ' Start of balance_amount',60);
           end if;
           --
           if g_cpf_with_bal_value is null then
                  open balance_amount ;
                  fetch balance_amount into   g_cpf_with_bal_value,
	                                      g_cpf_liab_bal_value,
                                              g_vol_cpf_with_bal_value,
                                              g_vol_cpf_liab_bal_value,
                                              g_comm_chest_with_bal_value,
                                              g_sdl_liab_bal_value,
                                              g_mbmf_with_bal_value,
                                              g_fwl_liab_bal_value,
                                              g_sinda_with_bal_value,
                                              g_cdac_with_bal_value,
                                              g_ecf_with_bal_value ;
                  close balance_amount;
           end if;
           --
           if  g_debug then
                hr_utility.set_location(l_proc_name || ' End of balance_amount',60);
           end if;
           --
           if p_balance_name = 'CPF Withheld' then
                return g_cpf_with_bal_value;
           elsif  p_balance_name = 'CPF Liability' then
                return g_cpf_liab_bal_value;
           elsif  p_balance_name = 'Voluntary CPF Withheld' then
                return g_vol_cpf_with_bal_value;
           elsif  p_balance_name = 'Voluntary CPF Liability' then
                return g_vol_cpf_liab_bal_value;
           elsif  p_balance_name = 'Community Chest Withheld' then
                return g_comm_chest_with_bal_value ;
           elsif  p_balance_name = 'SDL Liability' then
                return g_sdl_liab_bal_value ;
           elsif  p_balance_name = 'MBMF Withheld' then
                return g_mbmf_with_bal_value ;
           elsif  p_balance_name = 'FWL Liability' then
                return g_fwl_liab_bal_value ;
           elsif  p_balance_name = 'SINDA Withheld' then
                return g_sinda_with_bal_value ;
           elsif  p_balance_name = 'CDAC Withheld' then
                return g_cdac_with_bal_value ;
           elsif  p_balance_name = 'ECF Withheld' then
                return g_ecf_with_bal_value ;
           elsif  p_balance_name = 'Balance Total' then
	         if fwl_reporting is null then
                       fwl_reporting := 'Y';
                       OPEN  fwl_amount_reporting;
                       FETCH fwl_amount_reporting into fwl_reporting;
                       CLOSE fwl_amount_reporting;
                 end if;
                ------------------------------------------------------------------------
                --Bug# 4287277 - g_fwl_liab_bal_value value is not included in the Balance Total value if CPF Reporting option is set to No.
                ------------------------------------------------------------------------
                if fwl_reporting = 'N' then
		       return g_cpf_with_bal_value + g_cpf_liab_bal_value + g_vol_cpf_with_bal_value + g_vol_cpf_liab_bal_value +
		       g_comm_chest_with_bal_value + trunc(g_sdl_liab_bal_value) + g_mbmf_with_bal_value +
		       g_sinda_with_bal_value + g_cdac_with_bal_value + g_ecf_with_bal_value ;
                else
                       return g_cpf_with_bal_value + g_cpf_liab_bal_value + g_vol_cpf_with_bal_value + g_vol_cpf_liab_bal_value +
		       g_comm_chest_with_bal_value + trunc(g_sdl_liab_bal_value) + g_mbmf_with_bal_value +
		       g_fwl_liab_bal_value + g_sinda_with_bal_value + g_cdac_with_bal_value + g_ecf_with_bal_value ;
                end if;

           end if;
           --
      end balance_amount;
      ---------------------------------------------
      -- Function stat_type_amount
      -- Returns Balance Amount.
      -- Called from Comapny_Identification cursor
      ---------------------------------------------
      function stat_type_amount
           ( p_payroll_action_id in  number,
             p_stat_type         in  varchar2 ) return number
      is

           l_stat_type_total  number;
      begin
           l_package  := ' pay_sg_cpfline.';
           l_proc_name := l_package || 'stat type count';
           g_debug := hr_utility.debug_enabled;
           --
           if  g_debug then
                hr_utility.set_location(l_proc_name || ' Start of stat_type_amount',50);
           end if;
	   --
           if p_stat_type = 'AV1' then
                  l_stat_type_total :=   balance_amount ( p_payroll_action_id , 'CPF Withheld')+
		                         balance_amount ( p_payroll_action_id , 'CPF Liability') +
                                         balance_amount ( p_payroll_action_id , 'Voluntary CPF Withheld') +
                                         balance_amount ( p_payroll_action_id , 'Voluntary CPF Liability') ;
           elsif p_stat_type = 'AV3' then
                  l_stat_type_total :=  balance_amount ( p_payroll_action_id, 'Community Chest Withheld');
           elsif p_stat_type = 'AV4' then
                  l_stat_type_total := trunc( balance_amount ( p_payroll_action_id, 'SDL Liability'));
           elsif p_stat_type = 'AV5' then
                  l_stat_type_total := balance_amount ( p_payroll_action_id, 'MBMF Withheld');
           elsif p_stat_type = 'AV7' then
                  l_stat_type_total := balance_amount ( p_payroll_action_id, 'FWL Liability');
           elsif p_stat_type = 'AVA' then
                  l_stat_type_total := balance_amount ( p_payroll_action_id, 'SINDA Withheld');
           elsif p_stat_type = 'AVE' then
                  l_stat_type_total := balance_amount ( p_payroll_action_id, 'CDAC Withheld');
           elsif p_stat_type = 'AVG' then
                  l_stat_type_total := balance_amount ( p_payroll_action_id, 'ECF Withheld');
           elsif p_stat_type = 'TOT' then
                  l_stat_type_total := balance_amount ( p_payroll_action_id, 'Balance Total');
           end if;
           --
           if  g_debug then
                hr_utility.set_location(l_proc_name || ' End of stat_type_amount',50);
           end if;
           --
           return l_stat_type_total;
      end stat_type_amount;
      -----------------------------------------------
      -- Function stat_type_count
      -- Returns person count contributing to different Balances.
      -- called from company_identification cursor
      -----------------------------------------------
      function stat_type_count
           ( p_payroll_action_id  in number,
             p_stat_type          in varchar2 ) return number
      is
           --
           l_count  number;
           --
      begin
           l_package  := ' pay_sg_cpfline.';
           l_proc_name  := l_package || 'stat type count';
           if  g_debug then
                hr_utility.set_location(l_proc_name || ' Start of stat_type_count',70);
           end if;
           ----------------------------------------------------------------------------------------------
	   -- Bug: 3298317 - Employee Count calculated based on distinct CPF number - action_information1
	   ----------------------------------------------------------------------------------------------
           if p_stat_type = 'MUS' then
                 select  count( distinct nvl(pai.action_information1,pai.source_id) )
                   into  l_count
                   from  pay_payroll_actions    ppa,
                         pay_assignment_actions paa,
                         pay_action_information pai
                  where  ppa.payroll_action_id           = p_payroll_action_id
                    and  ppa.payroll_action_id           = paa.payroll_action_id
                    and  paa.assignment_action_id        = pai.action_context_id
                    and  pai.action_information_category = 'SG CPF DETAILS'
                    and  pai.action_context_type         = 'AAC'
                    and  to_number(pai.action_information8) > 0;
           elsif p_stat_type = 'SHA' then
                 select  count( distinct nvl(pai.action_information1,pai.source_id) )
                   into  l_count
                   from  pay_payroll_actions    ppa,
                         pay_assignment_actions paa,
                         pay_action_information pai
                  where  ppa.payroll_action_id           = p_payroll_action_id
                    and  ppa.payroll_action_id           = paa.payroll_action_id
                    and  paa.assignment_action_id        = pai.action_context_id
                    and  pai.action_information_category = 'SG CPF DETAILS'
                    and  pai.action_context_type         = 'AAC'
                    and  to_number(pai.action_information14) > 0;
           elsif p_stat_type = 'SIN' then
                 select  count( distinct nvl(pai.action_information1,pai.source_id) )
                   into  l_count
                   from  pay_payroll_actions    ppa,
                         pay_assignment_actions paa,
                         pay_action_information pai
                  where  ppa.payroll_action_id           = p_payroll_action_id
                    and  ppa.payroll_action_id           = paa.payroll_action_id
                    and  paa.assignment_action_id        = pai.action_context_id
                    and  pai.action_information_category = 'SG CPF DETAILS'
                    and  pai.action_context_type         = 'AAC'
                    and  to_number(pai.action_information9) > 0;
           elsif p_stat_type = 'CDA' then
                 select  count( distinct nvl(pai.action_information1,pai.source_id) )
                   into  l_count
                   from  pay_payroll_actions    ppa,
                         pay_assignment_actions paa,
                         pay_action_information pai
                  where  ppa.payroll_action_id           = p_payroll_action_id
                    and  ppa.payroll_action_id           = paa.payroll_action_id
                    and  paa.assignment_action_id        = pai.action_context_id
                    and  pai.action_information_category = 'SG CPF DETAILS'
                    and  pai.action_context_type         = 'AAC'
                    and  to_number(pai.action_information10) > 0;
           elsif p_stat_type = 'ECF' then
                 select  count( distinct nvl(pai.action_information1,pai.source_id) )
                   into  l_count
                   from  pay_payroll_actions    ppa,
                         pay_assignment_actions paa,
                         pay_action_information pai
                  where  ppa.payroll_action_id           = p_payroll_action_id
                    and  ppa.payroll_action_id           = paa.payroll_action_id
                    and  paa.assignment_action_id        = pai.action_context_id
                    and  pai.action_information_category = 'SG CPF DETAILS'
                    and  pai.action_context_type         = 'AAC'
                    and  to_number(pai.action_information11) > 0;
           end if;
           --
           if  g_debug then
                hr_utility.set_location(l_proc_name || ' End of stat_type_count',70);
           end if;
           --
           return l_count;
  end stat_type_count;
  --
  function get_balance_value
            (  p_employee_type        in  varchar2,
               p_assignment_id        in  per_all_assignments_f.assignment_id%type,
               p_cpf_acc_number       in  varchar2,
               p_department           in  varchar2,
               p_assignment_action_id in  varchar2,
               p_tax_unit_id          in  varchar2,
               p_balance_name         in  varchar2,
	       p_balance_value        in  varchar2,
	       p_payroll_action_id    in  number,
	       p_permit_type          per_people_f.per_information6%type) return varchar2
  is
      ----------------------------------------------------------------
      -- For existing employees
      -- NOTE: order by statement for above query should not be changed
      ----------------------------------------------------------------

      l_sort      pay_action_information.action_information21%type;

      ----------------------------------------------------------------
      -- Bug No:3298317 Added new column permit_type(action_information21) in select clause.
      -- Bug No:4226037 Added new column action_information19(termination date) in select clause
      ----------------------------------------------------------------
      cursor c_existing_employees  (   p_payroll_action_id  in  number  )
      is
      select  nvl(pai.action_information1,pai.source_id) cpf_acc_number,
              pai.action_information17,
              pai.action_information18,
              pai.action_information21,
	      pai.action_information22,
              paa.assignment_id,
              paa.assignment_action_id,
              pai.tax_unit_id,
              fnd_date.canonical_to_date(pai.action_information20),
              pai.action_information19
        from  pay_payroll_actions      ppa
              , pay_assignment_actions paa
              , pay_action_information pai
       where  ppa.payroll_action_id           = p_payroll_action_id
         and  ppa.payroll_action_id           = paa.payroll_action_id
         and  paa.assignment_action_id        = pai.action_context_id
         and  pai.action_information_category = 'SG CPF DETAILS'
         and  pai.action_context_type         = 'AAC'
         and  pai.action_information2         = 'EE'
         and  exists ( select  1
		         from  pay_action_information pai_dup,
		               pay_assignment_actions paa_dup
                        where  pai.action_information_category =  pai_dup.action_information_category
		          and  pai.rowid                       <> pai_dup.rowid
		          and  paa_dup.payroll_action_id       =  ppa.payroll_action_id
		          and  paa_dup.assignment_action_id    =  pai_dup.action_context_id
	                  and  pai.action_information1         =  pai_dup.action_information1  )
       order by cpf_acc_number,pai.action_information3 desc,pai.action_information23 desc;
     ------------------------------------------------------------------------------
     -- for new employees
     -- Bug:3010644. Modified paa.effective_start_date join and added date track
     -- check on ppa.effective_date and per_all_assignments_f
     -- NOTE: order by statement for above query should not be changed
     -- Bug No:3298317 Added new column permit_type(action_information21) in select clause.
     -- Bug No:4226037 Added new column action_information19(termination date) in select clause
     ------------------------------------------------------------------------------
     cursor c_new_employees ( p_payroll_action_id  in  varchar2 )
     is
      select  nvl(pai.action_information1,pai.source_id) cpf_acc_number,
 	      pai.action_information17,
              pai.action_information18,
              pai.action_information21,
	      pai.action_information22,
              paa.assignment_id,
              paa.assignment_action_id,
              pai.tax_unit_id,
              fnd_date.canonical_to_date(pai.action_information20),
              pai.action_information19
        from  pay_payroll_actions      ppa
              , pay_assignment_actions paa
              , pay_action_information pai
       where  ppa.payroll_action_id           = p_payroll_action_id
         and  ppa.payroll_action_id           = paa.payroll_action_id
         and  paa.assignment_action_id        = pai.action_context_id
         and  pai.action_information_category = 'SG CPF DETAILS'
         and  pai.action_context_type         = 'AAC'
         and  pai.action_information2         = 'NEW'
         and  exists ( select  1
		         from  pay_action_information pai_dup,
		               pay_assignment_actions paa_dup
                        where  pai.action_information_category =  pai_dup.action_information_category
		          and  pai.rowid                       <> pai_dup.rowid
		          and  paa_dup.payroll_action_id       =  ppa.payroll_action_id
		          and  paa_dup.assignment_action_id    =  pai_dup.action_context_id
	                  and  pai.action_information1         =  pai_dup.action_information1  )
       order by cpf_acc_number,pai.action_information3 desc,pai.action_information23 desc;
       --
       l_date            date;
       l_counter         number;
       l_mon_counter     number;
       l_found           boolean;
       update_status     boolean;
       asg_is_duplicate  number;
       bal_value         varchar2(20);
       mf_tot_bal        varchar2(20);
       ctl_tot_bal       varchar2(20);
       ctl_bal_value     varchar2(20);
       mf_employee_info  varchar2(200);
       ctl_employee_info varchar2(200);
       tot_bal           varchar2(100);
       l_wp              char(1);
       l_sg              char(1);
       --
       function dup_bal_value ( c_assignment_action_id  in  number) return number
       is

	    l_permit_type pay_action_information.action_information21%type;

	    /* Bug: 3595103  Modified cursor for permit type 'SP' */
	    cursor   get_balances is
            select   nvl(decode( action_information1,null,0,(decode(action_information21,'WP',0,(decode(action_information21,'EP',0,(decode(action_information21,'SP',0,to_number(action_information4) ))))))),0),
                     nvl(decode( action_information1,null,0,(decode(action_information21,'WP',0,(decode(action_information21,'EP',0,(decode(action_information21,'SP',0,to_number(action_information6) ))))))),0),
                     nvl(decode( action_information1,null,0,(decode(action_information21,'WP',0,(decode(action_information21,'EP',0,(decode(action_information21,'SP',0,to_number(action_information5) ))))))),0),
                     nvl(decode( action_information1,null,0,(decode(action_information21,'WP',0,(decode(action_information21,'EP',0,(decode(action_information21,'SP',0,to_number(action_information7) ))))))),0),
                     nvl(to_number(action_information8),0),
                     nvl(to_number(action_information9),0),
                     nvl(to_number(action_information10),0),
                     nvl(to_number(action_information11),0),
                     nvl(to_number(action_information12),0),
                     nvl(to_number(action_information13),0)
             from   pay_action_information
            where   action_context_id           = c_assignment_action_id
              and   action_information_category = 'SG CPF DETAILS'
              and   action_context_type = 'AAC';


       begin
             l_package  := ' pay_sg_cpfline.';
             l_proc_name  := l_package || 'get_balance_value';
            if ( c_assignment_action_id <> g_cpf_balances.assact_id)  or ( g_cpf_balances.assact_id is NULL )  then
                    open  get_balances;
                   fetch  get_balances
                    into   g_cpf_balances.vol_cpf_liab      -- action_information4
                          ,g_cpf_balances.cpf_liab          -- action_information6
                          ,g_cpf_balances.vol_cpf_wheld     -- action_information5
                          ,g_cpf_balances.cpf_wheld         -- action_information7
                          ,g_cpf_balances.mbmf_wheld        -- action_information8
                          ,g_cpf_balances.sinda_wheld       -- action_information9
                          ,g_cpf_balances.cdac_wheld        -- action_information10
                          ,g_cpf_balances.ecf_wheld         -- action_information11
                          ,g_cpf_balances.cpf_ord_earn      -- action_information12
                          ,g_cpf_balances.cpf_addl_earn     -- action_information13
			  ;
                   --
                   g_cpf_balances.assact_id := c_assignment_action_id ;
                   --
                   close get_balances ;
            end if;
            --
            if p_balance_name = 'Voluntary CPF Liability' then
	          return g_cpf_balances.vol_cpf_liab ;
           elsif p_balance_name = 'CPF Liability' then
	       	  return g_cpf_balances.cpf_liab ;
           elsif p_balance_name = 'Voluntary CPF Withheld' then
        	  return g_cpf_balances.vol_cpf_wheld ;
	   elsif p_balance_name = 'CPF Withheld' then
     		  return g_cpf_balances.cpf_wheld;
	    elsif p_balance_name = 'MBMF Withheld' then
                   return g_cpf_balances.mbmf_wheld ;
            elsif p_balance_name = 'SINDA Withheld' then
                   return g_cpf_balances.sinda_wheld ;
            elsif p_balance_name = 'CDAC Withheld' then
                   return g_cpf_balances.cdac_wheld ;
            elsif p_balance_name = 'ECF Withheld' then
                   return g_cpf_balances.ecf_wheld ;
            elsif p_balance_name = 'CPF Ordinary Earnings Eligible Comp' then
                   return g_cpf_balances.cpf_ord_earn ;
            elsif p_balance_name = 'CPF Additional Earnings Eligible Comp' then
                   return g_cpf_balances.cpf_addl_earn ;
            else
                   raise_application_error(-20001, 'Program Error : Invalid Balance') ;
            end if ;
       end;
  begin
     --
       l_counter                       := 1;
       l_mon_counter                   := 1;
       l_found                         := false;
       update_status                   := false;
       asg_is_duplicate                := 0;
       bal_value                       := 0;
       mf_tot_bal                      := 0;
       ctl_tot_bal                     := 0;
       ctl_bal_value                   := 0;
       mf_employee_info                := 'X';
       ctl_employee_info               := 'X';
       tot_bal                         := '0#0';
       l_wp                            :='N';
       l_sg                            :='N';

     if  g_debug then
            hr_utility.set_location(l_proc_name || ' Start of get_balance_value',80);
     end if;
     --
     if  p_employee_type = 'NEW' and  global_exist_emp = true then
         t_dup_emp_rec.delete;
         global_exist_emp := false;
     end if;
     ---------------------------------------------------------------------------------
     -- This function is called for every emplyee and all the balances through
     -- the cursor existing_employees (identified by 'EE') and  new employees
     -- (identified by 'New'. When this function is called for the first time a
     -- global pl/sql table is populated by opening cursor c_existing_employee
     -- for existing employees and with c_new_employees for new employees.
     -- The pl/sql table table will store employee level details for all the employees
     ---------------------------------------------------------------------------------
     if  t_dup_emp_rec.count = 0 then
         if p_employee_type = 'EE' then
             open c_existing_employees( p_payroll_action_id );
	     --
             loop
                fetch  c_existing_employees
	         into  t_dup_emp_rec(l_counter).cpf_acc_number,
		       t_dup_emp_rec(l_counter).legal_name,
                       t_dup_emp_rec(l_counter).employee_number,
                       t_dup_emp_rec(l_counter).permit_type,
		       t_dup_emp_rec(l_counter).department,
                       t_dup_emp_rec(l_counter).assignment_id,
                       t_dup_emp_rec(l_counter).assignment_action_id,
                       t_dup_emp_rec(l_counter).tax_unit_id,
                       t_dup_emp_rec(l_counter).effective_date,
                       t_dup_emp_rec(l_counter).termination_date;
                exit when c_existing_employees%NOTFOUND;
		------------------------------------------------------------
		-- the record is not considered for magtape
                ------------------------------------------------------------
                t_dup_emp_rec(l_counter).cl_record_status:='U';
                t_dup_emp_rec(l_counter).mf_record_status:='U';
                l_counter :=  l_counter + 1;
             end loop;
	     --
             close c_existing_employees;
         else
	     -------------------------------------------------------
             -- if p_employee_type = NEW
             -------------------------------------------------------
             open c_new_employees( p_payroll_action_id );
	     --
             loop
                fetch  c_new_employees
		 into  t_dup_emp_rec(l_counter).cpf_acc_number,
                       t_dup_emp_rec(l_counter).legal_name,
                       t_dup_emp_rec(l_counter).employee_number,
                       t_dup_emp_rec(l_counter).permit_type,
		       t_dup_emp_rec(l_counter).department,
                       t_dup_emp_rec(l_counter).assignment_id,
                       t_dup_emp_rec(l_counter).assignment_action_id,
                       t_dup_emp_rec(l_counter).tax_unit_id,
                       t_dup_emp_rec(l_counter).effective_date,
                       t_dup_emp_rec(l_counter).termination_date;
                exit when c_new_employees%NOTFOUND;
		-----------------------------------------------------------
		-- the record is not considered for magtape
		-----------------------------------------------------------
                t_dup_emp_rec(l_counter).cl_record_status:='U';
                t_dup_emp_rec(l_counter).mf_record_status:='U';
                l_counter :=  l_counter + 1;
             end loop;
             close c_new_employees;
         end if;
     end if;
     -----------------------------------------------------------------------------------------------------------------
     -- 1)
     -- Legal name ,employee number and emp termination date are also derived in this function though they are
     -- not balances. if balance_name passed is other then above names then find out the defined balance id wrt
     -- balance names passed to the function from the pl/sql table populated above
     --
     -- 2)
     -- The function is called for all the balances (10 balances and 3 non balances (legal name, emp number, term date)
     -- for a selected assignment .
     -- The global global_bal_count is incremented for every function call. Once the last function call is made,
     -- the employee should be marked as processed for the cpf line.
     --
     -- if update_status = TRUE then update assignment status to processed (M)
     -----------------------------------------------------------------------------------------------------------------
     if global_bal_count = 12 then
          update_status := TRUE;   -- update assignment status to processed (M)
	  global_bal_count := 0;
     else
          global_bal_count := global_bal_count + 1;
     end if;
     -----------------------------------------------------------------------------------------------------------------
     -- Records in the pl/sql table t_dup_emp_rec are sorted by the cpf account number. Once all the records are
     -- fetched for a particular cpf account number passed to the function, there  is no need to search further in the
     -- table. the l_found variable is used to handle this
     -----------------------------------------------------------------------------------------------------------------
     l_found := FALSE; -- initialzed to false.

     ------------------------------------------------------------------------------------------------------
     -- 1) find out the matching records in the pl/sql table,for the cpf account number passed
     -- 2)
     --   2.1) For Magtape:
     --        if the record status of a record in the pl/sql table is unprocessed ('U') Then
     --        for balance names 'Legal name','Employee Number' and 'Emp Termination date' find out the values.
     --        A check is made so that the latest employee's data is only retrieved and if this function is called
     --        next time the values should not be overriden. Records are stored in the pl/sql table such that the
     --        first record for a CPF Account Number is the latest record
     --        for actual balances , find out the balance value for all the assignments related to the Cpf account number passed.
     --        sum up these values.If there is  only one assignment for a cpf account number then, return the balance values
     --        Once last balance is retrieved, mark all the assignments for the cpf account number as prcoessed in the
     --        'Magtape' status='M'
     --   2.2) For Control  listing:
     --        All the steps for 2.1 hold good for control listing also, but therte is an additional check for the department.
     --        Here we find all the assignments which are under the CPF Account number and the Department passed as parameter.
     --        Once all the relevent records are fetched the , mark all the assignments as processed in the control listing
     --        status = 'C'
     ------------------------------------------------------------------------------------------------------
     l_wp:='N';
     l_sg:='N';
     if t_dup_emp_rec.count > 0 then
            --
           -----------------------------------------------------------------------------
            -- Bug No:3298317 Added to skip the Employees of permit type 'WP' or 'EP'
            --                and who are rehired with permit type 'SG' or 'PR'.
	    -- Bug: 3595103  Modified cursor for permit type 'SP'
            -------------------------------------------------------------------------

           if p_permit_type='WP' OR p_permit_type='EP' OR p_permit_type='SP' then
               for l_dup_counter in t_dup_emp_rec.first..t_dup_emp_rec.last
               loop
                   if p_assignment_action_id=t_dup_emp_rec(l_dup_counter).assignment_action_id and
		     (t_dup_emp_rec(l_dup_counter).permit_type='WP' or
		      t_dup_emp_rec(l_dup_counter).permit_type='SP' or
		      t_dup_emp_rec(l_dup_counter).permit_type='EP') then
                         l_wp:='Y';
                   end if;
                   --
                   if t_dup_emp_rec(l_dup_counter).cpf_acc_number = p_cpf_acc_number and (t_dup_emp_rec(l_dup_counter).permit_type='SG' or t_dup_emp_rec(l_dup_counter).permit_type='PR') then
                         l_sg:='Y' ;
                   end if;
               end loop;
           end if;
           -------------------------------------------------------------------------------------------

               for l_dup_counter in t_dup_emp_rec.first..t_dup_emp_rec.last
                 loop

              --
              -----------------------------------------------------------------------------
              -- Bug No:3298317 Added to skip the Employees of permit type 'WP' or 'EP' or 'SP'
              --                and who are rehired with permit type 'SG' or 'PR'.
              -------------------------------------------------------------------------
                  if  l_wp= 'Y' and l_sg= 'Y' then
                    exit;
                  end if;
               ------------------------------------------------------------------------------

		  if (t_dup_emp_rec(l_dup_counter).cpf_acc_number <> p_cpf_acc_number) and l_found = true then
                      exit;
                  elsif (t_dup_emp_rec(l_dup_counter).cpf_acc_number = p_cpf_acc_number) then
                      ------------------------------------------------------
                      -- Magtape File
                      -------------------------------------------------------
                      if t_dup_emp_rec(l_dup_counter).mf_record_status = 'U' then
                            if ( p_balance_name in ('Legal_Name','Employee_Number','Emp_Term_Date'))  then
                                    if (mf_employee_info = 'X' ) then   -- only latest information should be written
                                           if p_balance_name ='Legal_Name'  Then
                                                mf_employee_info := t_dup_emp_rec(l_dup_counter).Legal_name;
                                                /* Bug#4226037  p_balance_value is replaced with t_dup_emp_rec(l_dup_counter).Legal_name */
                                           elsif p_balance_name = 'Employee_Number' Then
                                                mf_employee_info := t_dup_emp_rec(l_dup_counter).employee_number ;
                                                /* Bug#4226037  p_balance_value is replaced with t_dup_emp_rec(l_dup_counter).employee_number */
                                           elsif p_balance_name = 'Emp_Term_Date' Then
                                                if t_dup_emp_rec(l_dup_counter).termination_date is not null then
                                                      mf_employee_info := t_dup_emp_rec(l_dup_counter).termination_date;
                                                -----------------------------------------------------------------------------------------------
                                                -- Bug#4226037  p_balance_value is replaced with t_dup_emp_rec(l_dup_counter).termination_date.
                                                -- Included else clause to return default date if the latest assignment is not terminated.
                                                -----------------------------------------------------------------------------------------------
                                                else
                                                      l_date := to_date('01/01/1900','dd/mm/yyyy');
                                                      mf_employee_info := to_char(l_date,'dd/mm/yyyy');
                                                end if;
                                           end if;
                                    end if;
                                    --
                                    if update_status=true then
                                           t_dup_emp_rec(l_dup_counter).mf_record_status := 'M';
                                    end if;
                            else
                                    bal_value := dup_bal_value ( t_dup_emp_rec(l_dup_counter).assignment_action_id );
                                    --
                                    mf_tot_bal := mf_tot_bal + bal_value;
                                    l_found := true;
				    ----------------------------------------------------
                                    -- the record is considered for magtape, so next time if the current
				    -- assignment id is passed
                                    -- through the main cursor, it should be ignored
                                    ----------------------------------------------------
                                    if update_status=true then
                                           t_dup_emp_rec(l_dup_counter).mf_record_status := 'M';
                                    end if;
                                    --
                                    if  g_debug then
                                           hr_utility.set_location(l_proc_name || ' MF Section',80);
                                           hr_utility.set_location(l_proc_name || ' p_balance_name '||p_balance_name,80);
                                           hr_utility.set_location(l_proc_name || ' Employee '||t_dup_emp_rec(l_counter).cpf_acc_number,80);
                                           hr_utility.set_location(l_proc_name || ' balance_value '||mf_tot_bal,80);
                                           hr_utility.set_location(l_proc_name || ' Asact id '||to_char(t_dup_emp_rec(l_counter).assignment_action_id),80);
                                    end if;
                            end if;
                      end if;
                      ------------------------------------------------------
                      -- Control listing Section
                      ------------------------------------------------------
                      if t_dup_emp_rec(l_dup_counter).department = p_department then
                            if t_dup_emp_rec(l_dup_counter).cl_record_status = 'U' then
                                    if( p_balance_name in ('Legal_Name','Employee_Number','Emp_Term_Date'))  then
                                           if (ctl_employee_info = 'X') then
                                                if p_balance_name ='Legal_Name' Then
                                                      ctl_employee_info := t_dup_emp_rec(l_dup_counter).Legal_name;
                                                      /* Bug#4226037  p_balance_value is replaced with t_dup_emp_rec(l_dup_counter).Legal_name */
                                                elsif p_balance_name = 'Employee_Number' Then
                                                      ctl_employee_info := t_dup_emp_rec(l_dup_counter).employee_number;
                                                      /* Bug#4226037  p_balance_value is replaced with t_dup_emp_rec(l_dup_counter).employee_number */
                                                elsif p_balance_name = 'Emp_Term_Date' Then
                                                      ctl_employee_info := t_dup_emp_rec(l_dup_counter).termination_date;
                                                      /* Bug#4226037  p_balance_value is replaced with t_dup_emp_rec(l_dup_counter).termination_date */
                                                end if;
                                           end if;
					   --
                                           if update_status=true then
                                                t_dup_emp_rec(l_dup_counter).cl_record_status := 'C';
                                           end if;
                                    else
                                           ctl_bal_value := dup_bal_value ( t_dup_emp_rec(l_dup_counter).assignment_action_id );
                                           --
                                           ctl_tot_bal := ctl_tot_bal + ctl_bal_value;
                                           l_found := true;
					   --
                                           if update_status=true then
							t_dup_emp_rec(l_dup_counter).cl_record_status := 'C';
                                           end if;
					   --
                                           if  g_debug then
                                                hr_utility.set_location(l_proc_name || ' CTL Section',80);
                                                hr_utility.set_location(l_proc_name || ' p_balance_name '||p_balance_name,80);
                                                hr_utility.set_location(l_proc_name || ' Employee '||t_dup_emp_rec(l_counter).cpf_acc_number,80);
                                                hr_utility.set_location(l_proc_name || ' balance_value '||ctl_tot_bal,80);
                                                hr_utility.set_location(l_proc_name || ' Asact id '||to_char(t_dup_emp_rec(l_counter).assignment_action_id),80);
                                           end if;
                                           --
                                    end if;
                            end if;
                      end if;
                  end if;
            end loop;
     end if;
     ---------------------------------------------------------------------------------
     --  return concatenated values, which will be considered in the magatape formula
     --  If employee is not terminated, return default date
     ---------------------------------------------------------------------------------
     if p_balance_name in ('Legal_Name','Employee_Number') then
           return mf_employee_info||'#'||ctl_employee_info;
     elsif p_balance_name = 'Emp_Term_Date' then
           ---------------------------------
           -- If employee is not terminated, return default date
	   ---------------------------------
           if mf_employee_info = 'X' then
                l_date:= to_date('01/01/1900','dd/mm/yyyy');
                mf_employee_info:= to_char(l_date,'dd/mm/yyyy');
	   else
	        l_date:= fnd_date.canonical_to_date(mf_employee_info);
                mf_employee_info:= to_char(l_date,'dd/mm/yyyy');
           end if;
	   --
           return mf_employee_info;
     else
           tot_bal := mf_tot_bal||'#'||ctl_tot_bal;
           --
           return tot_bal ;
     end if;
     --
     if  g_debug then
            hr_utility.set_location(l_proc_name || ' End of get_balance_value',80);
     end if;
  -- hr_utility.trace_off;
  end get_balance_value;

end pay_sg_cpfline_balances;

/
