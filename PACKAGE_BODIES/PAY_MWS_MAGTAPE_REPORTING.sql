--------------------------------------------------------
--  DDL for Package Body PAY_MWS_MAGTAPE_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MWS_MAGTAPE_REPORTING" as
/* $Header: pymwsrep.pkb 120.1 2005/10/05 03:51:18 sackumar noship $ */
 g_message_text varchar2(240);

 /* table Variables used for calculating the wages of the assignment */
 g_asg_tab		   numeric_data_table;
 g_asg_end_dt_tab	   character_data_table;
 g_tax_unit_id_tab	   numeric_data_table;
 g_wages_tab		   numeric_data_table;
 g_asg_wages_tab	   numeric_data_table;
 g_ctr			   number := 0;
 g_reg_earn_bal_id         pay_defined_balances.defined_balance_id%type;
 g_supp_earn_bal_id        pay_defined_balances.defined_balance_id%type;
 g_def_gre_bal_id          pay_defined_balances.defined_balance_id%type;
 g_sec_gre_bal_id          pay_defined_balances.defined_balance_id%type;
 g_dep_gre_bal_id          pay_defined_balances.defined_balance_id%type;
 g_supp_nwfit_bal_id       pay_defined_balances.defined_balance_id%type;

 /* added by skutteti for the pre tax enhancement */
 g_pre_tax_bal_id          pay_defined_balances.defined_balance_id%type;

procedure get_balance_id is
begin
   g_reg_earn_bal_id  := Pay_Mag_Utils.Bal_Db_Item(
			    'REGULAR_EARNINGS_PER_GRE_QTD');
   g_supp_earn_bal_id := Pay_Mag_Utils.Bal_Db_Item(
  	          'SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_QTD');
   --
   -- the following has been commented for the pre-tax enhancements
   -- by skutteti. Individual pre-tax balances has been replaced
   -- by one balance g_pre_tax_bal_id
   --
   --g_def_gre_bal_id   := Pay_Mag_Utils.Bal_Db_Item(
   --				    'DEF_COMP_401K_PER_GRE_QTD');
   --g_sec_gre_bal_id   := Pay_Mag_Utils.Bal_Db_Item(
   --				    'SECTION_125_PER_GRE_QTD');
   --g_dep_gre_bal_id   := Pay_Mag_Utils.Bal_Db_Item(
   --				    'DEPENDENT_CARE_PER_GRE_QTD');
   --
   g_pre_tax_bal_id   := Pay_Mag_Utils.Bal_Db_Item(
				    'PRE_TAX_DEDUCTIONS_PER_GRE_QTD');

   g_supp_nwfit_bal_id := Pay_Mag_Utils.Bal_Db_Item(
	          'SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_QTD');

end get_balance_id;

function get_wages(p_assignment_id		in number,
		    p_tax_unit_id		in number,
		    p_effective_end_date 	in date)
		    				return number is
 l_total_wages		number;
 l_reg_earn_wages       number;
 l_supp_earn_wages      number;
 l_def_gre_wages        number;
 l_sec_gre_wages        number;
 l_dep_gre_wages        number;
 l_supp_nwfit_wages     number;
 l_pre_gre_wages        number; /* skutteti */

begin
     pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);

     l_reg_earn_wages :=  pay_balance_pkg.get_value (g_reg_earn_bal_id,
 	     					     p_assignment_id,
  	     					     p_effective_end_date);

     l_supp_earn_wages :=  pay_balance_pkg.get_value (g_supp_earn_bal_id,
 	     					     p_assignment_id,
  	     					     p_effective_end_date);
     --
     --  Pre-tax enhancements by skutteti on 10-jul-1999
     --  Removed individual pre-tax categories and replaced by one generic
     --  Pre-tax deduction component.
     --
     -- l_def_gre_wages :=  pay_balance_pkg.get_value (g_def_gre_bal_id,
     --	     					     p_assignment_id,
     --  	     					     p_effective_end_date);
     --
     -- l_sec_gre_wages :=  pay_balance_pkg.get_value (g_sec_gre_bal_id,
     --  	     					     p_assignment_id,
     --  	     					     p_effective_end_date);
     --
     --
     -- l_dep_gre_wages :=  pay_balance_pkg.get_value (g_dep_gre_bal_id,
     -- 	     					     p_assignment_id,
     --  	     					     p_effective_end_date);
     --
     -- replace the above by the following
     --
     l_pre_gre_wages :=  pay_balance_pkg.get_value (g_pre_tax_bal_id,
 	     					     p_assignment_id,
  	     					     p_effective_end_date);

     l_supp_nwfit_wages :=  pay_balance_pkg.get_value (g_supp_nwfit_bal_id,
 	     					     p_assignment_id,
  	     					     p_effective_end_date);


     --
     -- commented the following and replaced with new code by skutteti
     --
     -- l_total_wages := (l_reg_earn_wages + l_supp_earn_wages -
     --		       l_def_gre_wages - l_sec_gre_wages - l_dep_gre_wages )
     --		       + l_supp_nwfit_wages;
     --
     l_total_wages := l_reg_Earn_wages + l_supp_earn_wages -
                      l_pre_gre_wages  + l_supp_nwfit_wages;


     return (round(l_total_wages));

end get_wages;



/* Name		:  Create_Assignment_Action
   Purpose	: Create an assignment action for each person to be
		  reported on within the magnetic tape report identified by
		  the parent payroll action.
*/

function Create_Assignment_Action ( p_payroll_action_id in number,
  				    p_assignment_id     in number,
				    p_tax_unit_id	in number,
				    p_asg_wages		in number,
				    p_asg_end_dt	in varchar)
						return  number is

    /* Cursor to fetch the newly created assignment_action_id. There could
    be several assignment actions for the same assignment and the only way
    to find the newly created one is to fetch the one that has not had the
    tax_unit_id updated yet. */

   CURSOR csr_assignment_action IS
     SELECT aa.assignment_action_id
     FROM   pay_assignment_actions aa
     WHERE  aa.payroll_action_id = p_payroll_action_id
     AND    aa.assignment_id     = p_assignment_id
     AND    aa.tax_unit_id   IS NULL;

   /* Local variables. */

   l_assignment_action_id pay_assignment_actions.assignment_action_id%type;
   l_serial_no		  varchar2(30);

begin

   hr_utility.set_location('pay_mag_utils.create_assignment_action',1);

   /* Create assignment action to identify a specific person's inclusion in the
    magnetic tape report identified by the parent payroll action. The
    assignment action has to be sequenced within the other assignment actions
    according to the date of the payroll action so that the derivation of
    any balances based on the assignment action is correct. */

   /* First Round up the wages to the nearest dollar and convert it to char
	so that it can be stored in the serial number coulmn of the
	PAY_ASSIGNMENT_ACTIONS table We will also store the effective end date
	of the assignment along with the wages for the assignment because we
	may have a person having 2 assignments for the same organization and
	and GRE with different effective start and end dates (falling within
	the same quarter e.g. one having start dt = 01-jan-1990
	end dt = 07-mar-1990 and another having start dt = 08-mar-1990
	end dt = 29-aug-1997. Now, the first record may have non zero wages
	but the second may not have non zero wages. So, in order to decide that
	which record to pick up we need to have the end date of the assignment
	taged to the wages so that we can specifically pick up the assignment
	corresponding to the wages stored in the pay_assignmnet_actions table.
	The first 20 positions will be for the wages and the last 10 positions
	for the assignment end date
 */

   l_serial_no := lpad((to_char(p_asg_wages)),20) || p_asg_end_dt;

   hrassact.inassact(p_payroll_action_id, p_assignment_id);


   /* Get the assignment_action_id of the newly created assignment action. */

   hr_utility.set_location('pay_mag_utils.create_assignment_action',2);

   open  csr_assignment_action;
   fetch csr_assignment_action INTO l_assignment_action_id;
   close csr_assignment_action;

   update pay_assignment_actions aa
   set    aa.tax_unit_id = p_tax_unit_id,
	  aa.serial_number = l_serial_no
   where  aa.assignment_action_id = l_assignment_action_id;

   hr_utility.set_location('pay_mag_utils.create_assignment_action',3);

   /*  Return id of new row. */

   return (l_assignment_action_id);

end Create_Assignment_Action;


procedure do_asg_break_processing(p_payroll_action_id	in number,
				  p_ctr			in out  nocopy number,
				  end_of_cursor		in boolean) is
   l_asg_action_id   pay_assignment_actions.assignment_action_id%type;
begin

   if (p_ctr = 4) then /* We have 3 records for the assg */

	/* Check if the assignment has remained in the same GRE */
	if ((g_tax_unit_id_tab(1) = g_tax_unit_id_tab(2)) and
	   (g_tax_unit_id_tab(1) = g_tax_unit_id_tab(3))) then
	   g_asg_wages_tab(3) := g_wages_tab(3) - g_wages_tab(2);
	   g_asg_wages_tab(2) := g_wages_tab(2) - g_wages_tab(1);
	   g_asg_wages_tab(1) := g_wages_tab(1);

	/* Assignment changed GRE in the 3rd month */
	elsif ((g_tax_unit_id_tab(1) = g_tax_unit_id_tab(2)) and
	   (g_tax_unit_id_tab(1) <> g_tax_unit_id_tab(3))) then
	   g_asg_wages_tab(3) := g_wages_tab(3);
	   g_asg_wages_tab(2) := g_wages_tab(2) - g_wages_tab(1);
	   g_asg_wages_tab(1) := g_wages_tab(1);

	/* Assignment changed GRE in the 2nd month but came back to the 1st
	   GRE in the 3rd month */
	elsif ((g_tax_unit_id_tab(1) <> g_tax_unit_id_tab(2)) and
	   (g_tax_unit_id_tab(1) = g_tax_unit_id_tab(3))) then
	   g_asg_wages_tab(3) := g_wages_tab(3) - g_wages_tab(1);
	   g_asg_wages_tab(2) := g_wages_tab(2);
	   g_asg_wages_tab(1) := g_wages_tab(1);

	/* Assignment changed GRE in all the months */
	else
	   g_asg_wages_tab(3) := g_wages_tab(3);
	   g_asg_wages_tab(2) := g_wages_tab(2);
	   g_asg_wages_tab(1) := g_wages_tab(1);
	end if;

    elsif (p_ctr = 3) then /* 2 records for the assignment */

        /* Check if the assignment has remained in the same GRE */
	if (g_tax_unit_id_tab(1) = g_tax_unit_id_tab(2)) then
	   g_asg_wages_tab(2) := g_wages_tab(2) - g_wages_tab(1);
	   g_asg_wages_tab(1) := g_wages_tab(1);

	/* Assignment has changed GREs */
	else
	   g_asg_wages_tab(1) := g_wages_tab(1);
	   g_asg_wages_tab(2) := g_wages_tab(2);
	end if;

    elsif (p_ctr = 2) then /* 1 records for the assignment */
	 /* There is only one GRE since there is only one record. */
	 g_asg_wages_tab(1) := g_wages_tab(1);
    end if;

    /* Create the assignment action for all the applicable records */
    for j in 1..p_ctr - 1 loop

        l_asg_action_id := Create_Assignment_Action
                                       (p_payroll_action_id,
                                        g_asg_tab(j),
                                        g_tax_unit_id_tab(j),
					g_asg_wages_tab(j),
					g_asg_end_dt_tab(j));

     end loop;

    /* Now is the time for initialization */
    if not end_of_cursor then
	g_asg_tab(1)   		:= g_asg_tab(p_ctr);
        g_asg_end_dt_tab(1) 	:= g_asg_end_dt_tab(p_ctr);
	g_wages_tab(1) 		:= g_wages_tab(p_ctr);
	g_tax_unit_id_tab(1) 	:= g_tax_unit_id_tab(p_ctr);
        p_ctr          		:= 1;
    end if;

    return;

end do_asg_break_processing;


/*
Name		: generate_people_list
Purpose		: Creates a payroll action and a list of assignment actions
		  detailing the date of the magnetic tape report along with
		  the list of people to report on.
Arguments	:
Notes		: The criteria for selecting the people cannot be done
		  simply using SQL.It is done by first using a PLSQL cursor
		  which makes an educated guess about the people to include NB.
 		  It will always include all the correct people even though
		  some may not be valid. The second step is to further check
		  each person found and apply further checks. If these are
  		  passed then they are added to the list (create an assignment
		  action) otherwise they are discarded.
*/

 function generate_people_list
 (
  p_report_type       varchar2,
  p_state             varchar2,
  p_trans_legal_co_id varchar2,
  p_business_group_id number,
  p_period_end        date,
  p_quarter_start     date,
  p_quarter_end       date
 ) return number is

   l_person_id              number;
   l_assignment_id          number;
   l_tax_unit_id            number;
   l_effective_start_date     date;
   l_effective_end_date     date;
   l_bus_group_id           number;
   l_state                  varchar2(30);
   l_end_date1              date;
   l_end_date2              date;
   l_end_date3              date;
   l_payroll_action_created boolean := false;
   l_payroll_action_id      pay_payroll_actions.payroll_action_id%type;
   l_assignment_action_id   pay_assignment_actions.assignment_action_id%type;


   /* Variable holding the balance to be tested. */
   l_defined_balance_id     pay_defined_balances.defined_balance_id%type;

   cnt 			    number;
   l_chunk_size             number;

   cursor c_people is
     select paf.person_id               person_id,
            paf.assignment_id           assignment_id,
            fnd_number.canonical_to_number(scl.segment1)     tax_unit_id,
            paf.effective_start_date      effective_start_date,
            paf.effective_end_date      effective_end_date
     from   per_assignments_f      	paf,
            hr_soft_coding_keyflex 	scl
     where  paf.business_group_id      = l_bus_group_id
       and  paf.assignment_type        = 'E'
       and  paf.primary_flag           = 'Y'
       and  paf.payroll_id               is not null
       and  paf.effective_start_date   <= l_end_date3
       and  (paf.effective_end_date    >= l_end_date1
             or paf.effective_end_date >= l_end_date2
	     or paf.effective_end_date >= l_end_date3)
       and  scl.soft_coding_keyflex_id  = paf.soft_coding_keyflex_id
       and exists ( select null
		            from hr_organization_information hoi2
		            where hoi2.organization_id = paf.organization_id
                    and  hoi2.org_information_context = 'CLASS'
                    and hoi2.org_information1 = 'HR_ESTAB'
                    and hoi2.org_information2 = 'Y')
       and exists(
		 select null
		 from hr_organization_information hoi
		 where hoi.organization_id = paf.organization_id
                 and  hoi.org_information_context =
			'Worksite Filing')
     group  by paf.person_id,
               paf.assignment_id,
               fnd_number.canonical_to_number(scl.segment1),
	       paf.effective_start_date,
	       paf.effective_end_date
     order  by 1, 2, 4 asc, 5, 3;

 begin

      /* Assign values to the variables used in the cursor for querying
	 purpose */
      l_bus_group_id		:= p_business_group_id;
      l_state                 	:= p_state;
      l_end_date1            	:= to_date('12-'|| to_char(p_quarter_start,
				   'MM-YYYY'), 'DD-MM-YYYY');
      l_end_date2            	:= to_date('12-'|| (to_char(
			           add_months(p_quarter_start,1), 'MM-YYYY')),
				   'DD-MM-YYYY');
      l_end_date3            	:= to_date('12-'|| to_char(p_quarter_end,
				   'MM-YYYY'), 'DD-MM-YYYY');

      /* Get the balance id for the Gross Quarterly wages of a person */
	l_defined_balance_id   := Pay_Mag_Utils.Bal_Db_Item(
				    'GROSS_EARNINGS_PER_GRE_QTD');

      /* Get the remaining balance ids */

      get_balance_id;

      /*  Get CHUNK_SIZE or default to 20 if CHUNK_SIZE does not exist */
      begin
     	select parameter_value
        into l_chunk_size
        from pay_action_parameters
        where parameter_name = 'CHUNK_SIZE';
      exception
         when no_data_found then
       	    l_chunk_size := 20;
      end;

      /* Initialize counter. */

      cnt := 0;

      /* Open the cursor and get the people */
      open c_people;

      /* Loop for all rows returned for SQL statement. */

      loop

          /* Commit if l_chunk_size number of assignments have been processed.*/

          if cnt = l_chunk_size then
             cnt := 0;
             commit;
	     hr_utility.trace('COMMITTED');
          end if;

          cnt := cnt + 1;
          hr_utility.trace('CNT:::: '||cnt||'CHUNK SIZE::: '||l_chunk_size);

          /* Fetch a row from the cursor. */

          fetch c_people into l_person_id,
                              l_assignment_id,
                              l_tax_unit_id,
                              l_effective_start_date,
                              l_effective_end_date;

          if c_people%NOTFOUND then
	     if (g_ctr = 0) then
		/* Nothing to do so get outof the loop */
   		close c_people;
		exit;
	     else
		/* I have atleast one assignment to process. So, I'll make
		   a dummy increment of the g_ctr variable by 1 and then call
		   the break routine. The increment is done to ensure
		   compatibility with the break routine */

		g_ctr := g_ctr + 1;
                do_asg_break_processing(l_payroll_action_id, g_ctr, TRUE);
   		close c_people;
		exit;
	      end if;
	   end if;

          /* Check to see that the gross quarterly balance is nonzero. */

           pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);

          if pay_balance_pkg.get_value
 	    (l_defined_balance_id,
 	     l_assignment_id,
  	     least(p_period_end,l_effective_end_date)) > 0 then

           if not l_payroll_action_created then

  	    /* Create payroll action for the magnetic tape report. */

          l_payroll_action_id := Pay_Mag_Utils.Create_Payroll_Action
                                      (p_report_type,
                                       p_state,
                                       p_trans_legal_co_id,
                                       p_business_group_id,
                                       p_period_end);

	     /* Set the flag to true to indicate that the payroll action id
		has been created */

  	     l_payroll_action_created := true;

           end if;

	  /* Adding code for the caluculation of wages of the assignments */

          if (l_end_date1 >= l_effective_start_date and
             l_end_date1 <= l_effective_end_date) OR
          (l_end_date2 >= l_effective_start_date and
             l_end_date2 <= l_effective_end_date) OR
          (l_end_date3 >= l_effective_start_date and
             l_end_date3 <= l_effective_end_date) then

	     g_ctr := g_ctr + 1;
	     g_asg_tab(g_ctr) := l_assignment_id;
             g_asg_end_dt_tab(g_ctr) := to_char(l_effective_end_date,
					      'DD-MM-YYYY');
	     g_wages_tab(g_ctr) := get_wages(l_assignment_id, l_tax_unit_id,
				      least(p_period_end,l_effective_end_date));
	     g_tax_unit_id_tab(g_ctr) := l_tax_unit_id;

          end if;

          /* If there is a break in the assignment number then call the
	     break processing routine to create the assignment action id
	     for the applicable assignments */

	  if (g_ctr > 1 and g_asg_tab(g_ctr) <> g_asg_tab(g_ctr - 1)) then

             do_asg_break_processing(l_payroll_action_id, g_ctr, FALSE);

	  end if;
        end if;
   end loop;
   commit;
   if c_people%ISOPEN then
	close c_people;
   end if;

   /* A payroll action has been created. So, update the status to created */

   if l_payroll_action_created then

     /* Update the population status of the payroll action to indicate that all
        the assignment actions have been created for it. */

     update pay_payroll_actions ppa
     set    ppa.action_population_status = 'C'
     where  ppa.payroll_action_id        = l_payroll_action_id;

     commit;

   end if;

   return (l_payroll_action_id);

 end generate_people_list;

/*
Name		: Run_Magtape
Purpose		: Submits the magnetic tape process to be run by the concurrent
 		  manager. We also define the name of the output and the format
 		  here.
Arguments       : p_effective_date    Effective Date of the report.
  		  p_report_type       Report Type for MWS.
  		  p_payroll_action_id Payroll Action Id assigned to the report.
  		  p_state             The Report Qualifier.
  		  p_reporting_year    The year for which the report is being
				      generated.
  		  p_reporting_quarter The quarter for which the report is being
				      generated.
  		  p_trans_legal_co_id The transmitter tax_unit_id.
		  p_quarter_start     The start of the quarter
		  p_quarter_end       The end of the quarter
		  p_business_group_id The business group
*/

 procedure Run_Magtape
 (
  p_effective_date     date,
  p_report_type        varchar2,
  p_payroll_action_id  varchar2,
  p_state              varchar2,
  p_reporting_year     varchar2,
  p_reporting_quarter  varchar2,
  p_trans_legal_co_id  varchar2,
  p_quarter_start      date,
  p_quarter_end	       date,
  p_business_group_id  varchar2
 ) is

   l_format            	varchar2(30);
   l_magfilename       	varchar2(15);  /* Magnetic File Name */
   l_repfilename       	varchar2(15);  /* Report File Name */
   l_request_id        	number;	     /* Request Id */
   l_tape_creation_date varchar2(6);
   l_month1		varchar2(10);
   l_month2		varchar2(10);
   l_month3		varchar2(10);

 begin

   /* Get the sysdate and assign it as the tape creation date */
   select (to_char(sysdate,'YYMMDD'))
   into l_tape_creation_date
   from sys.dual;

   /* Get the format to be used to produce the report. */

   l_format := Pay_Mag_Utils.Lookup_Format(p_effective_date,
		             p_report_type,
		             p_state);

   /* Assign the name of the output filename */

   l_magfilename := p_state || p_report_type || '_' ||
	 		substr(to_char(p_effective_date,'YY'),1,2);
   l_repfilename := l_magfilename;

   /* Form the end date of the 1st, 2nd and 3rd month for the quarter */

   l_month1  := to_char(to_date('12-'|| to_char(p_quarter_start,
		   'MM-YYYY'), 'DD-MM-YYYY'),'DD-MM-YYYY');
   l_month2  := to_char(to_date('12-'|| (to_char(
		   add_months(p_quarter_start,1), 'MM-YYYY')), 'DD-MM-YYYY'),
		   'DD-MM-YYYY');
   l_month3  := to_char(to_date('12-'|| to_char(p_quarter_end,
			'MM-YYYY'), 'DD-MM-YYYY'),'DD-MM-YYYY');

   /* Start the generic magnetic tape process using the concurrent manager NB.
      the process is registered with SRS. This process is run as a sub request
      of the process running this PLSQL. This should result in the PLSQL
      process being paused while the magnetic tape process runs.
   */

   l_request_id :=
     fnd_request.submit_request
       ('PAY',
       program     => 'PYUMAG',
       description => null,
       start_time  => null,
       sub_request => FALSE,     -- TRUE
       argument1   => 'pay_magtape_generic.new_formula',
       argument2   => l_magfilename,
       argument3   => l_repfilename,
       argument4   => to_char(p_effective_date,'DD-MON-YYYY'),
       argument5   =>          'MAGTAPE_REPORT_ID=' || l_format,
       argument6   => 'TRANSFER_PAYROLL_ACTION_ID=' || p_payroll_action_id,
       argument7   =>             'TRANSFER_STATE=' || p_state,
       argument8   =>    'TRANSFER_REPORTING_YEAR=' || p_reporting_year,
       argument9   => 'TRANSFER_REPORTING_QUARTER=' || p_reporting_quarter,
       argument10  => 'TRANSFER_TRANS_LEGAL_CO_ID=' || p_trans_legal_co_id,
       argument11  => 'TRANSFER_FILE_NAME=' 	    || l_magfilename,
       argument12  => 'TRANSFER_CREATION_DATE='	    || l_tape_creation_date,
       argument13  => 'TRANSFER_MONTH1='	    || l_month1,
       argument14  => 'TRANSFER_MONTH2='	    || l_month2,
       argument15  => 'TRANSFER_MONTH3='	    || l_month3,
       argument16  => 'TRANSFER_BUSINESS_GROUP='    || p_business_group_id);

   /* Detect if the request was really submitted. If it has not then handle
      the error. */

   if l_request_id = 0 then

     g_message_text := 'Failed to submit concurrent request';
     raise hr_utility.hr_error;
   end if;

   /* Request has been accepted so update payroll action with the
      request details.  */

   update pay_payroll_actions ppa
   set    ppa.request_id        = l_request_id
   where  ppa.payroll_action_id = p_payroll_action_id;

  /* Issue a commit to synchronise the concurrent manager. */

   commit;

 end Run_Magtape;


/*
Name		: get_reporting_dates
Purpose		: This procedure will return the quarter start date and the
		  quarter end date of the report
Arguments	: p_quarter		It will be 03 for 1st quarter, 06 for
					2nd quarter, 09 for the 3rd quarter and
					12 for the 4th quarter. thus it is
					essentially the last month number for a
 					given quarter.
		  p_year		The year of reporting.
		  p_effective_date 	The effective date of the report.
		  p_quarter_start  	The start date of the quarter
		  p_quarter_end    	The end date of the quarter.
		  p_reporting_quarter   Will be set to 1 for the first quarter,
					2 for the 2nd quarter, 3 for the 3rd
					quarter and 4 for the 4th quarter.
		  p_reporting_year	Will be same as p_year
*/

 procedure get_reporting_dates
 (
  p_quarter   	    	varchar2,
  p_year       	    	varchar2,
  p_effective_date    	in out nocopy varchar2,
  p_quarter_start   	in out nocopy date,
  p_quarter_end     	in out nocopy date,
  p_reporting_quarter 	in out nocopy varchar2,
  p_reporting_year    	in out nocopy varchar2
 ) is

 begin

  /* It is a Federal report which will be sent to the BLS quarterly. If the
     report is being generated for the third quarter of 1997 then we'll get
      p_quarter		  ->	09
      p_year		  ->	1997
      Hence, the values of the p_quarter_start, p_quarter_end,
      p_reporting_quarter and p_reporting_year will be as follows :
      p_quarter_start     01-07-1997
      p_quarter_end       31-09-1997
      p_reporting_quarter 3
      p_reporting_year    1997
      p_reporting_quarter 3
      p_effective_date    31-09-1997
   Note : The effective date of a report is essentially the last date of the
	  reporting period, for the report. If the report is being generated
          for the 3rd quarter then the last date of the reporting period i.e.
          the reporting quarter is 31-SEP-1997. So, this will be the effective
	  date. For a yearly report the effective date would be 31-DEC-1997 for
          the report of 1997.
  */

     p_quarter_end       := last_day(to_date(p_quarter || p_year,'MMYYYY'));
     p_quarter_start     := add_months(p_quarter_end, -3) + 1;
     p_reporting_year    := p_year;
     p_reporting_quarter := to_char(fnd_number.canonical_to_number(p_quarter)/3);
     p_effective_date    := p_quarter_end;

 end get_reporting_dates;

/*
Name		: redo
Purpose		: Calls the procedure Run_Magtape directly from SRS. This
		  procedure handles the error buffer and return code interface
		  with SRS.
  		  We are going to derive all the  parameters from the vi
Arguments	: errbuf		To store the message for SRS
		  retcode		Return code to SRS
		  p_payroll_action_id	The Payroll Action Id
Notes		:
*/

 procedure redo
 (
  errbuf               out nocopy varchar2,
  retcode              out nocopy number,
  p_payroll_action_id  in varchar2
 ) is

    l_effective_date     date;
    l_report_type        varchar2(10);
    l_state              varchar2(10);
    l_reporting_year     varchar2(10);
    l_reporting_quarter  varchar2(10);
    l_trans_legal_co_id  varchar2(10);
    l_quarter     	varchar2(10);
    l_period_end     	varchar2(10);
    l_quarter_start    	varchar2(10);
    l_quarter_end    	varchar2(10);
    l_report_quarter   	varchar2(10);
    l_report_year   	varchar2(10);
    l_business_group_id varchar2(15);
   begin

     /*  Derive the rest of the parameters from the payroll_action_id  */

     select PA.effective_date,
	    ltrim(substr(PA.legislative_parameters, 11,5)),
	    ltrim(substr(PA.legislative_parameters, 17,5)),
	    to_char(PA.effective_date,'YYYY'),
            to_char(fnd_number.canonical_to_number(to_char(PA.effective_date,'MM'))/3),
	    ltrim(substr(PA.legislative_parameters, 23,5)) ,
	    to_char(business_group_id)
 	  into  l_effective_date,
           l_report_type,
           l_state,
           l_reporting_year,
           l_reporting_quarter,
           l_trans_legal_co_id,
	   l_business_group_id
     from pay_payroll_actions PA
     where PA.payroll_action_id = p_payroll_action_id;


   update pay_payroll_actions pa
   set    PA.action_status     = 'M'
   where  PA.payroll_action_id = p_payroll_action_id;

   update pay_assignment_actions AA
   set    AA.action_status     = 'M'
   where  AA.payroll_action_id = p_payroll_action_id;

   commit;

   /* Derive the start and end dates of the period being reported on. */

   l_quarter := to_char((fnd_number.canonical_to_number(l_reporting_quarter) * 3),'00');
   get_reporting_dates( l_quarter,
             		l_reporting_year,
             		l_period_end,
	     		l_quarter_start,
	     		l_quarter_end,
             		l_report_quarter,
             		l_report_year);

   /* Start the generic magnetic tape process. */

   Run_Magtape(l_effective_date,
               l_report_type,
               p_payroll_action_id,
 	       l_state,
 	       l_reporting_year,
	       l_reporting_quarter,
 	       l_trans_legal_co_id,
	       l_quarter_start,
	       l_quarter_end,
	       l_business_group_id);

   update pay_assignment_actions AA
   set    AA.action_status     = 'C'
   where  AA.payroll_action_id = p_payroll_action_id;

   commit;

   /* Set up success return code. */

   retcode := 0;

 /* Traps all exceptions raised within the procedure, extracts the message
    text associated with the exception and sets this up for SRS to read. */

 exception
   when hr_utility.hr_error then

     /*  If a payroll action exists then error it. */
     if p_payroll_action_id is not null then
       Pay_Mag_Utils.Error_Payroll_Action(p_payroll_action_id);
     end if;

     /* Set up error message and error return code. */
    if g_message_text is not null
    then
	errbuf := g_message_text;
    else
     errbuf  := hr_utility.get_message;
    end if;
    retcode := 2;

   when others then
     /*  If a payroll action exists then error it. */
     if p_payroll_action_id is not null then
       Pay_Mag_Utils.Error_Payroll_Action(p_payroll_action_id);
     end if;

     /* Set up error message and error return code. */
     errbuf  := sqlerrm;
     retcode := 2;

end redo;


/*
Name		: run
Purpose		: This is the main procedure responsible for generating the
	 	  list of assignment actions and then submitting the request to
 		  produce the magnetic tape report.
Arguments	: errbuf		Error message string passed back to SRS.
  		: retcode		Error code passed back to SRS ie.
                                		0 - Success
                                		1 - Warning
                                		2 - Error
		  p_business_group_id 	Business group the user is running
					under when the report is generated.
  		  p_report_type         'MWSMR'
  		  p_state               'FED'
  		  p_quarter             Identifies the quarter being reported
                                        eg. 03 is the 1st quarter.
  		  p_year                Identifies the year being reported on.
  		  p_trans_legal_co_id   Identifies the Transmitter Tax Unit.

Notes		: This procedure is invoked from the SRS screens.
*/

 procedure run
 (
  errbuf                out nocopy varchar2,
  retcode               out nocopy number,
  p_business_group_id   in number,
  p_report_type		in varchar2,
  p_quarter		in varchar2,
  p_year                in varchar2,
  p_trans_legal_co_id   in number
 ) is
   --

   c_period_end        		date;
   c_quarter_start     		date;
   c_quarter_end       		date;
   c_reporting_year    		varchar2(4);
   c_reporting_quarter 		varchar2(4);
   l_payroll_action_id 		pay_payroll_actions.payroll_action_id%type;
   l_trans_legal_co_id 		number;
   l_request_id        		number;
   l_format	       		varchar2(30);
   l_report_type       		varchar2(5);
   l_state             		varchar2(5);
   l_context			varchar2(240);
   l_legislative_code		varchar2(4);
   l_err_code			number(5);
   l_err_text			varchar2(240);

 begin

   g_ctr := 0;
   /* Assign the Report Type and the Report Qualifier */
   l_report_type := p_report_type;
   l_state	 := 'FED';

   /* Check if the environment for the report has been properly set */

   /* First check for the context of Multiple Worksite Reporting */

   l_context := 'Multiple Worksite Reporting';
   l_legislative_code := 'US';
   l_err_code := 0;
   l_err_text := null;
   pay_us_validate_info.validate(p_business_group_id, l_context,
				  l_legislative_code, l_err_code, l_err_text);
   if l_err_code <> 0
   then
     	/* Set up error message and error return code. */
     	errbuf  := l_err_text;
     	retcode := l_err_code;
        g_message_text := l_err_text;
        hr_utility.raise_error;
   end if;

   /* Now its time to check for the context of Worksite Filing */

   l_context := 'Worksite Filing';
   l_legislative_code := 'US';
   l_err_code := 0;
   l_err_text := null;
   pay_us_validate_info .validate(p_business_group_id, l_context,
				  l_legislative_code, l_err_code, l_err_text);
   if l_err_code <> 0
   then
     	/* Set up error message and error return code. */
     	errbuf  := l_err_text;
     	retcode := l_err_code;
        g_message_text := l_err_text;
        hr_utility.raise_error;
   end if;

   /* Derive the start and end dates of the period being reported on. */

   get_reporting_dates( p_quarter,
             		p_year,
             		c_period_end,
	     		c_quarter_start,
	     		c_quarter_end,
             		c_reporting_quarter,
             		c_reporting_year);

   /* Check for the uniqueness of the report */

   Pay_Mag_Utils.Check_Report_Unique(p_business_group_id,
                       c_period_end,
                       l_report_type,
                       l_state);

   /* Get the format to be used to produce the report. */

   l_format := Pay_Mag_Utils.Lookup_Format(c_period_end,
		             l_report_type,
		             l_state);

   /*  See if a transmitter legal company was specified NB. it is not
       possible to pass NULL parameters to the process so a value has to be
      set ie. '-1'. */

   l_trans_legal_co_id := nvl(p_trans_legal_co_id, -1);

   /* Generate payroll action and assignment actions for all the people to be
      reported on NB. The list of people is dependent on the report being
      run. If there are no people to report on then there is no need to
      submit the process to produce the report. The variable
      l_payroll_action_id holds the ID of the created payroll action. */

   l_payroll_action_id := generate_people_list(l_report_type,
                                               l_state,
                                               l_trans_legal_co_id,
                                               p_business_group_id,
                                               c_period_end,
                                               c_quarter_start,
                                               c_quarter_end);

   /*  A payroll action has been created which means that at least one
       assignment action has been created so the magnetic tape report has to
       be run. Since we are not going to do any archiving for MWS, the call to
       the archiver has been removed */

   if l_payroll_action_id is not null then

     /* Start the generic magnetic tape process. */

     Run_Magtape(c_period_end,
                 l_report_type,
 	         l_payroll_action_id,
 	         l_state,
 	         c_reporting_year,
	         c_reporting_quarter,
 	         l_trans_legal_co_id,
 	         c_quarter_start,
 	         c_quarter_end,
		 p_business_group_id);

   else

   /* A payroll action has not been created so there are no people to report
      on. Set up message explaining why report was not produced. */

     g_message_text := 'There are no employees that match ' ||
		       'the criteria for the report';
     hr_utility.raise_error;

   end if;

   /* Process completed successfully. Update the status of the payroll and
      assignments actions. */

   Pay_Mag_Utils.Update_Action_Status(l_payroll_action_id);

   /* Set up success return code. */

   retcode := 0;

  /* Trap all exceptions raised within the procedure, extract the message
     text associated with the exception and set this up for SRS to read. */

 exception
   when hr_utility.hr_error then
     /* If a payroll action exists then error it. */
     if l_payroll_action_id is not null then
       Pay_Mag_Utils.Error_Payroll_Action(l_payroll_action_id);
     end if;

     /* Set up error message and error return code. */
     if g_message_text is not null
     then
     	errbuf  := g_message_text;
     else
	errbuf := hr_utility.get_message;
     end if;
     retcode := 2;

   when others then

     /* If a payroll action exists then error it. */
     if l_payroll_action_id is not null then
       Pay_Mag_Utils.Error_Payroll_Action(l_payroll_action_id);
     end if;

     /* Set up error message and error return code. */
     errbuf  := sqlerrm;
     retcode := sqlcode;

 end run;

end pay_mws_magtape_reporting;

/
