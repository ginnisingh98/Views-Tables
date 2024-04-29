--------------------------------------------------------
--  DDL for Package Body PAY_US_W2C_REPORTING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2C_REPORTING_UTILS" AS
 /* $Header: payusw2creputils.pkb 120.0.12010000.2 2008/11/07 10:33:12 asgugupt ship $ */
/*
 =========================================================================+
             Copyright (c) 1993 Oracle Corporation
                Redwood Shores, California, USA
                     All rights reserved.
 +=========================================================================+
  Name
    pay_us_w2c_reporting_utils

  File Name
    payusw2creputils.pkb

  Purpose
    The purpose of this package is to support the generation of magnetic
    tape in MMREF - 2 Format. This magnetic tapes are for US legilsative
    requirements.

  Notes
    The generation of each Federal W-2c magnetic tape report is a two stage
    process i.e.

    1. Check if the "Employee W-2c Report" is not run for a
       "W-2c Pre-Process". If not, then error out without processing further.

    2. Create a payroll action for the report. Identify all the assignments
       to be reported and record an assignment action against the payroll
       action for each one of them.

    3. Run the generic magnetic tape process which will drive off the data
       created in stage two. This will result in the production of a
       structured ascii file which can be transferred to magnetic tape and
       sent to the relevant authority.

  History
   Date     Author    Verion  Bug           Details
 -------------------------------------------------------------------------
  22-OCT-03 ppanda    115.0                 Created
  02-DEC-03 ppanda    115.3   3284445       Value reported for Originally reported
                                            using wrong employee
                              3275145       Federal W-2c Mag is not logging any message
                                            when no W-2c paper is picked up by process.

  11-DEC-03 ppanda    115.4   3313954       Originally reported value is not correct
                                            when W-2c mag is run after first correction
                                            reported in W-2c mag or Paper
  31-dec-03 jgoswami  115.6                 commented show_error for gscc failure.
  14-MAR-2005 sackumar  115.9  4222032	    Change in the Range Cursor removing redundant
					    use of bind Variable (:payroll_action_id)
   29-MAR-2005 sackumar 115.10 4222032	    Removing GSCC Errors
   07-Nov-2008 asgugupt 115.11 7504239      Have put Order by in action creation
                                            and distinct clause in cursor
                                            c_w2c_paper_not_locked
   =========================================================================
*/

  /******************************************************************
   ** Package Local Variables
   ******************************************************************/

  gv_package varchar2(50) := 'pay_us_w2c_reporting_utils';

  ---------------------------------------------------------------------------
  --   Name       : bal_db_item
  --   Purpose    : Given the name of a balance DB item as would be seen in a
  --                fast formula it returns the defined_balance_id of the
  --                  balance it represents.
  --   Arguments
  --       INPUT  : p_db_item_name
  --      returns : l_defined_balance_id
  --
  --   Notes
  --           A defined_balance_id is required by the PLSQL balance function.
  -----------------------------------------------------------------------------
  FUNCTION bal_db_item ( p_db_item_name IN VARCHAR2
                     ) RETURN NUMBER IS
  -- Get the defined_balance_id for the specified balance DB item.
	  CURSOR csr_defined_balance IS
	  SELECT TO_NUMBER(UE.creator_id)
	    FROM ff_database_items DI,
	         ff_user_entities UE
	   WHERE DI.user_name = p_db_item_name
	     AND UE.user_entity_id = DI.user_entity_id
	     AND UE.creator_type = 'B'
             AND UE.legislation_code = 'US';
	l_defined_balance_id  pay_defined_balances.defined_balance_id%TYPE;
  BEGIN
	hr_utility.set_location
	           (gv_package || '.bal_db_item - opening cursor', 10);
        -- Open the cursor
	OPEN csr_defined_balance;
        -- Fetch the value
	FETCH  csr_defined_balance
	 INTO  l_defined_balance_id;
 	IF csr_defined_balance%NOTFOUND THEN
       CLOSE csr_defined_balance;
	   hr_utility.set_location
          (gv_package || '.bal_db_item - no rows found ', 20);
	   hr_utility.raise_error;
	ELSE
		hr_utility.set_location
		(gv_package || '.bal_db_item - Row fetched from cursor', 30);
		CLOSE csr_defined_balance;
	END IF;
        /* Return the value to the call */
	RETURN (l_defined_balance_id);
  END bal_db_item;


  /*******************************************************************
  ** Procedure return the values for the Payroll Action of
  ** the "Mark Paper W-2c and Exclude From Future Tapes" process.
  ** This is used in Range Code and Action Creation.
  ******************************************************************/

  PROCEDURE get_payroll_action_info
  (
        p_payroll_action_id     in      number,
        p_start_date            in out  nocopy date,
        p_end_date              in out  nocopy date,
        p_report_type           in out  nocopy varchar2,
        p_report_qualifier      in out  nocopy varchar2,
        p_business_group_id     in out  nocopy number
  )
  IS
  cursor c_payroll_action(cp_payroll_action_id in number) is
      select ppa.start_date
            ,ppa.effective_date
            ,ppa.report_type
            ,ppa.report_qualifier
            ,ppa.business_group_id
       from pay_payroll_actions ppa
      where payroll_action_id = cp_payroll_action_id;

    ld_start_date           date;
    ld_end_date             date;
    lv_report_type          varchar2(50);
    lv_report_qualifier     varchar2(50);
    ln_business_group_id    number;

  BEGIN
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 10);

    open c_payroll_action(p_payroll_action_id);
    fetch c_payroll_action into
            ld_start_date,
            ld_end_date,
            lv_report_type,
            lv_report_qualifier,
            ln_business_group_id;
    if c_payroll_action%notfound then
       hr_utility.set_location( gv_package || '.get_payroll_action_info',20);
       hr_utility.trace('Payroll Action '||to_char(p_payroll_action_id)||' Not found');
       hr_utility.raise_error;
    end if;
    close c_payroll_action;
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 30);
    p_start_date           := ld_start_date;
    p_end_date             := ld_end_date;
    p_report_type          := lv_report_type;
    p_report_qualifier     := lv_report_qualifier;
    p_business_group_id    := ln_business_group_id;
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 40);
  END get_payroll_action_info;

  -------------------------------------------------------------------------
  --  Name     :  get_balance_value
  --
  --  Purpose
  --  Get the value of the specified balance item
  --  Arguments
  --  p_balance_name 		Name of the balnce
  --  p_tax_unit_id			GRE name for the context
  --  p_state_code			State for context
  --  p_assignment_id		Assignment for whom the balance is to be
  --                            retrieved
  --  p_effective_date      effective_date
  --
  --  Note
  --  This procedure set is a wrapper for setting the GRE/Jurisdiction context
  --  needed by the pay_balance_pkg.get_value to get the actual balance
  -------------------------------------------------------------------------
  FUNCTION get_balance_value (p_balance_name	VARCHAR2,
                              p_tax_unit_id		NUMBER,
                              p_state_abbrev	VARCHAR2,
                              p_assignment_id	NUMBER,
                              p_effective_date	DATE
                          	 ) RETURN NUMBER IS
  l_jurisdiction_code		VARCHAR2(20);
  BEGIN
    hr_utility.set_location(gv_package || '.get_balance_value', 10);
		pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
	IF p_state_abbrev <> 'FED' THEN
       SELECT jurisdiction_code
         INTO l_jurisdiction_code
         FROM pay_state_rules
        WHERE state_code = p_state_abbrev;
       hr_utility.set_location(gv_package || '.get_balance_value', 20);
	   pay_balance_pkg.set_context('JURISDICTION_CODE', l_jurisdiction_code);
	END IF;
	hr_utility.trace('Balance Name  : '||p_balance_name);
	hr_utility.trace('Context');
	hr_utility.trace('  Tax Unit Id : '|| p_tax_unit_id);
	hr_utility.trace('  Jurisdiction: '|| l_jurisdiction_code);
	hr_utility.set_location('pay_us_mmref_reporting.get_balance_value', 30);
	RETURN pay_balance_pkg.get_value(bal_db_item(p_balance_name),
                                     p_assignment_id,
                                     p_effective_date);
  END get_balance_value;

  --------------------------------------------------------------------------
  --Name
  --    preprocess_check
  -- Purpose
  --  This function checks whether W-2c paper genrated and waiting for W-2c mag
  --  to pick up for processing. If it doesn't find even a single W-2c paper
  --  assignment action, it logs a message for user
  -- Arguments
  --  p_pactid		   payroll_action_id for the report
  --  p_year_start	   start date of the period for which the report
  --			   has been requested
  --  p_year_end	   end date of the period
  --  p_business_group_id  business group for which the report is being run
  --
  --Notes
  --
  --
  --
  -----------------------------------------------------------------------------
  FUNCTION preprocess_check
  (
           p_pactid 			IN NUMBER,
           p_year_start		    IN DATE,
           p_year_end			IN DATE,
           p_business_group_id	IN NUMBER
  )
  RETURN BOOLEAN IS
  lb_return_value          BOOLEAN := TRUE;
  ln_count_of_w2c_paper    number := 0;
  lv_message_text          varchar2(200) := '';
  lv_message_preprocess    varchar2(200) := '';

  CURSOR c_w2c_paper_exist (cpn_business_group_id number,
                            cpd_start_date        date,
                            cpd_end_date          date)
  IS
         select paa.assignment_action_id
           from pay_assignment_actions paa,
                per_all_assignments_f  paf,
                pay_payroll_actions    ppa
          where ppa.business_group_id = cpn_business_group_id
            and ppa.effective_date between cpd_start_date and cpd_end_date
            and ppa.action_type          = 'X'
            and ppa.report_type          = 'W-2C PAPER'
            and ppa.action_status        = 'C'
            and ppa.payroll_action_id    = paa.payroll_action_id
            and paf.assignment_id        = paa.assignment_id
            and paf.effective_start_date <= ppa.effective_date
            and paf.effective_end_date   >= ppa.start_date
            and paf.assignment_type      = 'E'
            and not exists
               (select 'x'
                  from pay_Action_interlocks     pai,
                       pay_assignment_actions    paa1,
                       pay_payroll_actions       ppa1
                 where pai.locked_action_id      = paa.assignment_action_id
                   and paa1.assignment_action_id = pai.locking_action_id
                   and ppa1.payroll_action_id    = paa1.payroll_action_id
                   and ppa1.effective_date between cpd_start_date and cpd_end_date
                   and ppa1.action_type          = 'X'
                   and ppa1.report_type          = 'MARK_W2C_PAPER'
                   and ppa1.action_status        = 'C')
                   and not exists
                      (select 'x'
                         from pay_Action_interlocks     pai,
                              pay_assignment_actions    paa1,
                              pay_payroll_actions       ppa1
                        where pai.locked_action_id      = paa.assignment_action_id
                          and paa1.assignment_action_id = pai.locking_action_id
                          and ppa1.payroll_action_id    = paa1.payroll_action_id
                          and ppa1.effective_date between cpd_start_date and cpd_end_date
                          and ppa1.action_type          = 'X'
                          and ppa1.report_type          = 'W2C'
                          and ppa1.report_qualifier     = 'FED'
                          and ppa1.action_status        = 'C');
  BEGIN
     hr_utility.set_location(gv_package || '.preprocess_check', 10);
     lv_message_preprocess := 'Pre-Process check';
  --
  -- Determine whether any W-2c paper assignment action exist for W-2c mag
  -- pick up. If not log a message for user
  --
     OPEN  c_w2c_paper_exist(p_business_group_id,
                             p_year_start,
                             p_year_end);
     FETCH c_w2c_paper_exist INTO ln_count_of_w2c_paper;
     if c_w2c_paper_exist%ROWCOUNT = 0  or c_w2c_paper_exist%NOTFOUND
     then
        hr_utility.set_location(gv_package || '.preprocess_check', 20);
        /* message to user -- unable to find any W-2c Paper report for
                              genrating W-2c Mag */
        lv_message_text := 'No W-2c paper printed for processing W-2c Mag Tape';
        pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
        pay_core_utils.push_token('record_name',lv_message_preprocess);
        pay_core_utils.push_token('description',lv_message_text);
        lb_return_value := FALSE;
        CLOSE c_w2c_paper_exist;
        hr_utility.set_location(gv_package || '.preprocess_check', 30);
     else
        CLOSE c_w2c_paper_exist;
        lb_return_value := TRUE;
        hr_utility.set_location(gv_package || '.preprocess_check', 30);
     end if;
     hr_utility.set_location(gv_package || '.preprocess_check', 40);
     return lb_return_value;
  END preprocess_check;
  -- End of Function Preprocess_Check

  /*****************************************************************************
   Name      : get_eoy_action_info
   Purpose   : This returns the Payroll Action level
               information for  YREND Archiver.
   Arguments : p_w2c_eff_date      - End date of W2C Mag Process
               p_w2c_tax_unit_id   - Tax Unit Id
               p_payroll_action_id - Payroll_Action_id of EOY

  ******************************************************************************/
  PROCEDURE get_eoy_action_info(p_eoy_effective_date in         date
                               ,p_eoy_tax_unit_id    in         number
                               ,p_assignment_id      in         number
                               ,p_eoy_pactid         out nocopy number
                               ,p_eoy_asg_actid      out nocopy number
                               )
  IS
    CURSOR get_eoy_info(cp_w2c_eff_date     in date
                       ,cp_w2c_tax_unit_id  in number
                       ,cp_assignment_id    in number) is
    select ppa.payroll_action_id,
           paa.assignment_action_id
      from pay_assignment_actions paa,
           pay_payroll_actions    ppa
     where ppa.payroll_action_id = paa.payroll_action_id
       and ppa.report_type = 'YREND'
       and ppa.effective_date =  cp_w2c_eff_date
       and paa.assignment_id  =  cp_assignment_id
       and pay_us_get_item_data_pkg.GET_CPROG_PARAMETER_VALUE(
                    ppa.payroll_action_id,
                    'TRANSFER_GRE') = cp_w2c_tax_unit_id;
   ln_eoy_pactid    number :=0;
   ln_eoy_asg_actid number :=0;
   BEGIN
     hr_utility.set_location(gv_package || '.get_eoy_action_info', 10);
     hr_utility.trace('Effective Date '||to_char(p_eoy_effective_date,'dd-mon-yyyy') );
     hr_utility.trace('Tax Unit Id    '||to_char(p_eoy_tax_unit_id));
     hr_utility.trace('Entered get_eoy_action_info');
     open get_eoy_info(p_eoy_effective_date
                      ,p_eoy_tax_unit_id
                      ,p_assignment_id
                      );
     hr_utility.set_location(gv_package || '.get_eoy_action_info', 20);
     hr_utility.trace('Opened get_eoy_info');

     fetch get_eoy_info into ln_eoy_pactid,
                             ln_eoy_asg_actid;
     hr_utility.trace('Fetched get_eoy_info ');
     close get_eoy_info;

     hr_utility.trace('Closed get_eoy_info ');
     p_eoy_pactid    := ln_eoy_pactid;
     p_eoy_asg_actid := ln_eoy_asg_actid;
     hr_utility.trace('ln_eoy_pactid    = ' || to_char(ln_eoy_pactid));
     hr_utility.trace('ln_eoy_asg_actid = ' || to_char(ln_eoy_asg_actid));
     hr_utility.set_location(gv_package || '.get_eoy_action_info', 30);
     hr_utility.trace('Leaving get_eoy_action_info');
  EXCEPTION
    when others then
       hr_utility.trace('Error in ' || gv_package || '.get_eoy_action_info' ||
                         to_char(sqlcode) || '-' || sqlerrm);
       hr_utility.set_location(gv_package || '.get_eoy_action_info', 40);
       raise hr_utility.hr_error;
  END get_eoy_action_info;

  /******************************************************************
  ** Range Code to pick all the distinct assignment_ids
  ** that need to be marked as submitted to governement.
  *******************************************************************/
  PROCEDURE w2c_mag_range_cursor( p_payroll_action_id in         number
                                  ,p_sqlstr            out nocopy varchar2)
  IS

    ld_start_date           date;
    ld_end_date             date;
    lv_report_type          varchar2(30);
    lv_report_qualifier     varchar2(30);
    ln_business_group_id    number;
    lv_sql_string           varchar2(10000);
  BEGIN
    hr_utility.set_location(gv_package || '.w2c_mag_range_cursor', 10);
    get_payroll_action_info (  p_payroll_action_id
                              ,ld_start_date
                              ,ld_end_date
                              ,lv_report_type
                              ,lv_report_qualifier
                              ,ln_business_group_id
                            );
    hr_utility.trace('ld_start_date        = ' || ld_start_date);
    hr_utility.trace('ld_end_date          = ' || ld_end_date);
    hr_utility.trace('lv_report_type       = ' || lv_report_type);
    hr_utility.trace('lv_report_qualifier  = ' || lv_report_qualifier);
    hr_utility.trace('ln_business_group_id = ' || ln_business_group_id);

    hr_utility.set_location(gv_package || '.w2c_mag_range_cursor', 20);

    if preprocess_check ( p_payroll_action_id
                         ,ld_start_date
                         ,ld_end_date
                         ,ln_business_group_id
                        )
    then
       hr_utility.trace('W-2c Assignment picked up for processing W-2c Mag' );
    else
       hr_utility.trace('No W-2c Assignment picked up for processing W-2c Mag');
    end if;
--{

       hr_utility.set_location(gv_package || '.w2c_mag_range_cursor', 30);
       if (lv_report_type = 'W2C' and lv_report_qualifier = 'FED') then
          hr_utility.set_location(gv_package || '.w2c_mag_range_cursor', 40);
          lv_sql_string :=
                  'select distinct paf.person_id
                     from pay_assignment_actions paa,
                          per_all_assignments_f  paf,
                          pay_payroll_actions    ppa
                    where ppa.business_group_id = '|| ln_business_group_id || '
                      and ppa.effective_date between to_date(''' ||
                          to_char(ld_start_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                          and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                      and ppa.action_type = ''X''
                      and ppa.report_type = ''W-2C PAPER''
                      and ppa.action_status = ''C''
                      and ppa.payroll_action_id = paa.payroll_action_id
                      and paf.assignment_id     = paa.assignment_id
                      and paf.effective_start_date <= ppa.effective_date
                      and paf.effective_end_date >= ppa.start_date
                      and paf.assignment_type = ''E''
                      and :payroll_action_id is not null
                      and not exists
                         (select ''x'' from pay_Action_interlocks     pai,
                                            pay_assignment_actions    paa1,
                                            pay_payroll_actions       ppa1
                           where pai.locked_action_id      = paa.assignment_action_id
                             and paa1.assignment_action_id = pai.locking_action_id
                             and ppa1.payroll_action_id    = paa1.payroll_action_id
                             and ppa1.effective_date between to_date(''' ||
                                 to_char(ld_start_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                                 and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                             and ppa1.action_type          = ''X''
                             and ppa1.report_type          = ''MARK_W2C_PAPER''
                             and ppa1.action_status        = ''C'')
                      and not exists
                         (select ''x'' from pay_Action_interlocks     pai,
                                          pay_assignment_actions    paa1,
                                          pay_payroll_actions       ppa1
                           where pai.locked_action_id      = paa.assignment_action_id
                             and paa1.assignment_action_id = pai.locking_action_id
                             and ppa1.payroll_action_id    = paa1.payroll_action_id
                             and ppa1.effective_date between to_date(''' ||
                                 to_char(ld_start_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                                 and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                             and ppa1.action_type          = ''X''
                             and ppa1.report_type          = ''W2C''
                             and ppa1.report_qualifier     = ''FED''
                             and ppa1.action_status        = ''C'')
                               order by paf.person_id';
          p_sqlstr := lv_sql_string;
          hr_utility.set_location(gv_package || '.w2c_mag_range_cursor', 50);
          --hr_utility.trace('p_sqlstr = ' ||p_sqlstr);
          hr_utility.trace('length of p_sqlstr <' || to_char(length(p_sqlstr))||'>' );
          hr_utility.trace('Procedure w2c_mag_range_cursor completed successfully');
       else
          hr_utility.trace('Procedure w2c_mag_range_cursor Unsucessful ... ');
       end if;
--}

  end w2c_mag_range_cursor;

  /*******************************************************************
  ** Action Creation Code to create assignment actions for all the
  ** the assignment_ids that are corrected and not yet reported to
  ** governement
  *******************************************************************/
  PROCEDURE w2c_mag_action_creation( p_payroll_action_id    in number
                                     ,p_start_person_id      in number
                                     ,p_end_person_id        in number
                                     ,p_chunk                in number)
  IS
-- This cursor would be used to determine whether a future correction is already
-- reported to govt
   cursor w2c_future_correction_reported(cp_business_group_id    in number
                                        ,cp_start_date           in date
                                        ,cp_end_date             in date
                                        ,cp_start_person_id      in number
                                        ,cp_end_person_id        in number
                                        )
   IS
   select distinct paa.assignment_id,
                   paf.person_id
     from pay_assignment_actions paa,
          per_all_assignments_f  paf,
          pay_payroll_actions    ppa
    where ppa.business_group_id     = cp_business_group_id
      and ppa.effective_date  between cp_start_date and cp_end_date
      and ppa.action_type           = 'X'
      and ppa.report_type           = 'W-2C PAPER'
      and ppa.action_status         = 'C'
      and ppa.payroll_action_id     = paa.payroll_action_id
      and paf.assignment_id         = paa.assignment_id
      and paf.effective_start_date <= ppa.effective_date
      and paf.effective_end_date   >= ppa.start_date
      and paf.assignment_type       = 'E'
      and paf.person_id       between cp_start_person_id
                              and     cp_end_person_id
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date       between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'MARK_W2C_PAPER'
                       and ppa1.report_category      = 'RT'
                       and ppa1.action_status        = 'C')
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date       between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'W2C'
                       and ppa1.report_qualifier     = 'FED'
                       and ppa1.report_category      = 'RM'
                       and ppa1.action_status        = 'C'
          )
      and exists
          (select 'x'
             from pay_Action_interlocks     pai,
                  pay_assignment_actions    paa1,
                  pay_assignment_actions    paa2,
                  pay_payroll_actions       ppa1,
                  pay_payroll_actions       ppa2
           where paa2.assignment_Action_id  = pai.locked_action_id
             and paa1.assignment_action_id  = pai.locking_action_id
             and ppa1.payroll_action_id     = paa1.payroll_action_id
             and ppa1.effective_date  between cp_start_date and cp_end_date
             and ppa1.action_type           = 'X'
             and ppa1.report_type           = 'W2C'
             and ppa1.report_qualifier      = 'FED'
             and ppa1.report_category       = 'RM'
             and ppa1.action_status         = 'C'
             and paa2.assignment_id         = paa.assignment_id
             and ppa2.action_type           = 'X'
             and ppa2.report_type           = 'W-2C PAPER'
             and ppa2.action_status         = 'C'
             and ppa2.payroll_action_id     = paa2.payroll_action_id
             and paa2.assignment_Action_id  > paa.assignment_Action_id
             and ppa2.effective_date  between cp_start_date and cp_end_date
          );

   cursor get_w2c_mag_assignments (cp_business_group_id    in number
                                  ,cp_start_date           in date
                                  ,cp_end_date             in date
                                  ,cp_start_person_id      in number
                                  ,cp_end_person_id        in number)
   IS
   select paa.assignment_id,
          paa.tax_unit_id,
          paf.person_id,
          paa.assignment_Action_id,    -- Maximum Assignment Action_ID
          to_number(substr(paa.serial_number,1,15))  w2c_pp_asg_actid,
          to_number(substr(paa.serial_number,16,30)) w2c_pp_locked_actid
     from pay_assignment_actions paa,
          per_all_assignments_f  paf,
          pay_payroll_actions    ppa
    where ppa.business_group_id = cp_business_group_id
      and ppa.effective_date    between cp_start_date and cp_end_date
      and ppa.action_type       = 'X'
      and ppa.report_type       = 'W-2C PAPER'
      and ppa.action_status     = 'C'
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and paf.effective_start_date <= ppa.effective_date
      and paf.effective_end_date   >= ppa.start_date
      and paf.assignment_type = 'E'
      and paf.person_id     between cp_start_person_id
                                and cp_end_person_id
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date       between cp_start_date
                                                     and     cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'MARK_W2C_PAPER'
                       and ppa1.report_category      = 'RT'
                       and ppa1.action_status        = 'C')
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date  between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'W2C'
                       and ppa1.report_qualifier     = 'FED'
                       and ppa1.report_category      = 'RM'
                       and ppa1.action_status        = 'C'
          )
       and paa.assignment_Action_id =
               ( SELECT max(paa1.assignment_action_id)
                   FROM pay_payroll_actions      ppa1,
                        pay_assignment_actions   paa1
                  WHERE ppa1.payroll_action_id   = paa1.payroll_Action_id
                    and ppa1.report_type         = 'W-2C PAPER'
                    and ppa1.action_status       = 'C'
                    and ppa1.effective_date      between cp_start_date and cp_end_date
                    and paa1.assignment_id       = paa.assignment_id
                    and ppa1.business_group_id   = cp_business_group_id
                );


--
-- This cursor will fetch all W-2c paper action that are not locked by Fed W-2c
-- process
-- Input
--      cpn_max_asgn_action_id  - LAst W-2c Paper action Id
--
  CURSOR c_w2c_paper_not_locked (cpn_business_group_id  number,
                                 cpd_start_date         date,
                                 cpd_end_date           date,
                                 cpn_assignment_id      number,
                                 cpn_max_asgn_action_id number)
  IS
--bug 7504239
         select distinct paa.assignment_action_id
--bug 7504239
           from pay_assignment_actions paa,
                per_all_assignments_f  paf,
                pay_payroll_actions    ppa
          where ppa.business_group_id = cpn_business_group_id
            and ppa.effective_date between cpd_start_date and cpd_end_date
            and ppa.action_type          = 'X'
            and ppa.report_type          = 'W-2C PAPER'
            and ppa.action_status        = 'C'
            and ppa.payroll_action_id    = paa.payroll_action_id
            and paf.assignment_id        = paa.assignment_id
            and paa.assignment_id        = cpn_assignment_id
            and paa.assignment_action_id <> cpn_max_asgn_action_id
            and paf.effective_start_date <= ppa.effective_date
            and paf.effective_end_date   >= ppa.start_date
            and paf.assignment_type      = 'E'
            and not exists
               (select 'x'
                  from pay_Action_interlocks     pai,
                       pay_assignment_actions    paa1,
                       pay_payroll_actions       ppa1
                 where pai.locked_action_id      = paa.assignment_action_id
                   and paa1.assignment_action_id = pai.locking_action_id
                   and ppa1.payroll_action_id    = paa1.payroll_action_id
                   and ppa1.effective_date between cpd_start_date and cpd_end_date
                   and ppa1.action_type          = 'X'
                   and ppa1.report_type          = 'MARK_W2C_PAPER'
                   and ppa1.action_status        = 'C')
                   and not exists
                      (select 'x'
                         from pay_Action_interlocks     pai,
                              pay_assignment_actions    paa1,
                              pay_payroll_actions       ppa1
                        where pai.locked_action_id      = paa.assignment_action_id
                          and paa1.assignment_action_id = pai.locking_action_id
                          and ppa1.payroll_action_id    = paa1.payroll_action_id
                          and ppa1.effective_date between cpd_start_date and cpd_end_date
                          and ppa1.action_type          = 'X'
                          and ppa1.report_type          = 'W2C'
                          and ppa1.report_qualifier     = 'FED'
                          and ppa1.action_status        = 'C');




-- Fetch Last W-2c Paper Action that is already reported to Govt
-- If this fetches one record that would be considered as Originally reported
--     Action and W-2c Pre-process associated with this action would be
--     considered as original archived value
--
-- If this cursor fetches multiple record action which is greated among would
--     would be considered as last reported Action
--
-- If no-record found from this cursor, Federal W-2 Mag would be considered
--     as last reported W-2 and YE archived value would be considered as
--     originally reported archived value
--
-- Arguments
--     W-2c Paper Assignment Action Id selected by Range Cursor
--
   cursor get_last_reported_action (cp_business_group_id    in number
                                   ,cp_start_date           in date
                                   ,cp_end_date             in date
                                   ,cp_person_id            in number
                                   ,cp_w2c_paper_action_id  in number)
   IS
   select --paa.assignment_id,
          --paa.tax_unit_id,
          --paf.person_id,
          --ppa.report_type,
          paa.assignment_Action_id,
          ppa.payroll_action_id,
          to_number(substr(paa.serial_number,1,15))  w2c_pp_asg_actid
     from pay_assignment_actions   paa,
          per_all_assignments_f    paf,
          pay_payroll_actions      ppa
    where ppa.business_group_id    = cp_business_group_id
      and ppa.effective_date       between cp_start_date and cp_end_date
      and ppa.action_type          = 'X'
      and ppa.report_type          = 'W-2C PAPER'
      and ppa.action_status        = 'C'
      and ppa.payroll_action_id    = paa.payroll_action_id
      and paf.assignment_id        = paa.assignment_id
      and paf.effective_start_date <= ppa.effective_date
      and paf.effective_end_date   >= ppa.start_date
      and paf.assignment_type      = 'E'
      and paf.person_id            = cp_person_id
      and paa.assignment_Action_id < cp_w2c_paper_action_id
      and exists ((select 'x'
                    from pay_Action_interlocks     pai,
                         pay_assignment_actions    paa1,
                         pay_payroll_actions       ppa1
                   where pai.locked_action_id      = paa.assignment_action_id
                     and paa1.assignment_action_id = pai.locking_action_id
                     and ppa1.payroll_action_id    = paa1.payroll_action_id
                     and ppa1.effective_date       between cp_start_date
                                                   and cp_end_date
                     and ppa1.action_type          = 'X'
                     and ppa1.report_type          = 'MARK_W2C_PAPER'
                     and ppa1.report_category      = 'RT'
                     and ppa1.action_status        = 'C')
                  UNION ALL
                   (select 'x'
                    from pay_Action_interlocks     pai,
                         pay_assignment_actions    paa1,
                         pay_payroll_actions       ppa1
                   where pai.locked_action_id      = paa.assignment_action_id
                     and paa1.assignment_action_id = pai.locking_action_id
                     and ppa1.payroll_action_id    = paa1.payroll_action_id
                     and ppa1.effective_date       between cp_start_date
                                                   and cp_end_date
                     and ppa1.action_type          = 'X'
                     and ppa1.report_type          = 'W2C'
                     and ppa1.report_qualifier     = 'FED'
                     and ppa1.report_category      = 'RM'
                     and ppa1.action_status        = 'C'))
      order by paa.assignment_action_id DESC;

--
-- Fetch The W-2c Pre-Process Action ID which archived the changes reported
-- on W-2c Paper Report
--
  CURSOR get_interlocked_action(cp_locking_action in number)
  is
    select ppa.report_type                 locked_report_type,
           ppa.payroll_action_id           locked_paction_id,
           paa.assignment_action_id        locked_action_id,
           paa.serial_number               serial_number
     from pay_payroll_actions ppa,
          pay_assignment_actions paa,
          pay_action_interlocks pai
    where pai.locking_action_id    = cp_locking_action
      and paa.assignment_action_id = pai.locked_action_id
      and ppa.payroll_action_id    = paa.payroll_action_id;
--
-- This cursor would be used to fetch the person details
-- for loging WARNING/ERROR messages
--
  CURSOR get_warning_dtls_for_ee(cp_person_id in number)
  is
    select substr(full_name,1,48), employee_number
      from per_all_people_f
     where person_id = cp_person_id
     order by effective_end_date desc;

    ld_start_date           DATE;
    ld_end_date             DATE;
    lv_report_type          VARCHAR2(30);
    lv_report_qualifier     VARCHAR2(30);
    ln_business_group_id    NUMBER;

    /* Assignment Record Local Variables */
    ln_assignment_id        number;
    ln_emp_tax_unit_id      number;
    ln_person_id            number;
    ln_assignment_action_id number;
    ln_w2c_pp_asg_actid     number;
    ln_w2c_pp_locked_actid  number;

    lv_national_identifier  per_all_people_f.national_identifier%type;
    lv_message              varchar2(50):= null;
    lv_full_name            per_all_people_f.full_name%type;
    lv_name                 varchar2(50);
    lv_record_name          varchar2(50);
    ln_prev_person_id       number;

   PROCEDURE action_creation (lp_person_id            IN number,
                              lp_assignment_id        IN number,
                              lp_assignment_action_id IN number,
                              lp_tax_unit_id          IN number,
                              lp_start_date           IN date,
                              lp_effective_date       IN date,
                              lp_business_group_id    IN number,
                              lp_w2c_pp_asg_action_id IN number,
                              lp_w2c_pp_locked_actid  IN number
                             )
   IS

   ln_w2c_asg_action           NUMBER := 0;
   ln_corrected_asg_action     NUMBER := 0;
   ln_orig_reported_asg_action NUMBER := 0;

   lv_ilocked_report_type      VARCHAR2(30);
   ln_ilocked_action_id        NUMBER;
   ln_ilocked_paction_id       NUMBER;
   ln_ilocked_serial_number    VARCHAR2(30);
   ln_eoy_payroll_action_id    NUMBER;
   ln_eoy_assignment_action_id NUMBER;

   ln_last_w2cp_pactid         NUMBER;
   ln_last_w2cp_asg_actid      NUMBER;
   ln_last_w2cpp_asg_action_id NUMBER;

   ln_serial_number            pay_assignment_actions.serial_number%TYPE;
   ln_notlocked_asgn_actid     number;

   BEGIN
     hr_utility.set_location(gv_package || '.action_creation', 10);
     -- Corrected Assignment Action would be the W-2c Pre-Process Action_ID
     --
     if lp_w2c_pp_asg_action_id > 0 then
        hr_utility.set_location(gv_package || '.action_creation', 20);
        ln_corrected_asg_action := lp_w2c_pp_asg_action_id;
     end if;
     hr_utility.set_location(gv_package || '.action_creation', 30);
     --
     --  Determine the EOY Action_ID
     --
     get_eoy_action_info(lp_effective_date
                        ,lp_tax_unit_id
                        ,lp_assignment_id
                        ,ln_eoy_payroll_action_id
                        ,ln_eoy_assignment_action_id);
     hr_utility.set_location(gv_package || '.action_creation', 40);
     -- Ideally if one correction made to W-2c and Previously reported archived
     --   values will be from YE archive. Check whether W-2c Pre-process locks
     --   the YE Pre-process. If yes then previously reported values can be
     --   derived from YE pre-process

     if lp_w2c_pp_locked_actid = ln_eoy_assignment_action_id
     then
         hr_utility.set_location(gv_package || '.action_creation', 50);
         ln_orig_reported_asg_action := lp_w2c_pp_locked_actid;
     else
     --{
         hr_utility.set_location(gv_package || '.action_creation', 60);
     -- This indicates there is multiple W-2c or a Mark W-2c  paper process ran
     --  or a Federal W-2c Magnetic Process ran and reported for a set of W-2c.
     -- Determine the last W-2c paper reported
        OPEN get_last_reported_action(lp_business_group_id
                                     ,lp_start_date
                                     ,lp_effective_date
                                     ,lp_person_id
                                     ,lp_assignment_action_id);
--                                     ,ln_corrected_asg_action);
         hr_utility.set_location(gv_package || '.action_creation', 70);
        LOOP
          FETCH get_last_reported_action INTO ln_last_w2cp_pactid,
                                              ln_last_w2cp_asg_actid,
                                              ln_last_w2cpp_asg_action_id;

          hr_utility.set_location(gv_package || '.action_creation', 80);
          if get_last_reported_action%ROWCOUNT = 0 then
             hr_utility.set_location(gv_package || '.action_creation', 90);
             hr_utility.trace('There is No other W-2c submitted to govt');
             -- This condition will hold good if multiple W-2c paper printed
             --   for employee but not reported to Govt. For this scenario
             --   YE Pre-process would be considered as previously reported
             --   action.
             ln_orig_reported_asg_action := ln_eoy_assignment_action_id;
             exit;
          end if;
          EXIT WHEN get_last_reported_action%NOTFOUND;
          if ln_last_w2cp_asg_actid IS NOT NULL then
             hr_utility.set_location(gv_package || '.action_creation', 100);
             -- This scenario would exist if a W-2 correction is reported
             --   either in paper form or in Magnetic Media
             ln_orig_reported_asg_action := ln_last_w2cpp_asg_action_id;
             exit;
          end if;
        END LOOP;
        CLOSE get_last_reported_action;
     --}
     end if;
     --
     hr_utility.set_location(gv_package || '.action_creation', 110);
     hr_utility.trace('Corrected Assignment_Action_ID '||
                         to_char(ln_corrected_asg_action));
     hr_utility.trace('Originally Reported Assignment_Action_ID '||
                         to_char(ln_orig_reported_asg_action));

     /* Create an assignment action for this person */
     select pay_assignment_actions_s.nextval
       into ln_w2c_asg_action
       from dual;
     hr_utility.set_location(gv_package || '.action_creation', 120);
     hr_utility.trace('New w2c Action = ' || to_char(ln_w2c_asg_action));

     /* Insert into pay_assignment_actions. */
     hr_utility.trace('Creating Assignment Action');

     hr_nonrun_asact.insact(ln_w2c_asg_action
                           ,lp_assignment_id
                           ,p_payroll_action_id
                           ,p_chunk
                           ,lp_tax_unit_id);

       /* Update the serial number column with the person id
          so that the W2C report will not have
          to do an additional checking against the assignment
          table */

     hr_utility.set_location(gv_package || '.action_creation', 130);
     hr_utility.trace('updating asg action');
     /*************************************************************
      ** Update the serial number column with the assignment action
      ** of the last two archive processes
      *************************************************************/
     ln_serial_number := lpad(ln_corrected_asg_action,15,0)||
                                  lpad(ln_orig_reported_asg_action,15,0);
     update pay_assignment_actions aa
        set aa.serial_number = ln_serial_number
      where aa.assignment_action_id = ln_w2c_asg_action;
     hr_utility.set_location(gv_package || '.action_creation', 140);

     /* Interlock the w2c report action with current w2c Mag action */
     hr_utility.trace('Locking Action = ' || ln_w2c_asg_action);
     hr_utility.trace('Locked Action = '  || lp_assignment_action_id);
     hr_nonrun_asact.insint(ln_w2c_asg_action
                           ,lp_assignment_action_id);
     /*
        Lock all other W-2c paper action that are not yet locked by Fed W-2c
        mag action. This scenario could exist when there are multiple W-2c paper
        for which there would be one W-2c Mag action.
     */
     OPEN c_w2c_paper_not_locked(lp_business_group_id
                                ,lp_start_date
                                ,lp_effective_date
                                ,lp_assignment_id
                                ,lp_assignment_action_id
                                );
     hr_utility.set_location(gv_package || '.action_creation', 150);
     LOOP
        FETCH c_w2c_paper_not_locked INTO ln_notlocked_asgn_actid;

        hr_utility.set_location(gv_package || '.action_creation', 160);
        EXIT WHEN c_w2c_paper_not_locked%NOTFOUND;
        if c_w2c_paper_not_locked%ROWCOUNT = 0 then
             exit;
        else
             hr_utility.trace('Locking Action = ' || ln_w2c_asg_action);
             hr_utility.trace('Locked Action = '  || ln_notlocked_asgn_actid);
             hr_nonrun_asact.insint(ln_w2c_asg_action
                                   ,ln_notlocked_asgn_actid);
        end if;
     END LOOP;
     CLOSE c_w2c_paper_not_locked;
     hr_utility.set_location(gv_package || '.action_creation', 170);
  end action_creation; -- End of Local function Action_Creation
--
-- Action Creation Main Logic
--
  begin
--{
     hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 10);
     hr_utility.trace('Entered Mark_W2c_action_creation ');
     hr_utility.trace('p_payroll_action_id   = '|| to_char(p_payroll_action_id));
     hr_utility.trace('p_start_person_id     = '|| to_char(p_start_person_id));
     hr_utility.trace('p_end_person_id       = '|| to_char(p_end_person_id));
     hr_utility.trace('p_chunk               = '|| to_char(p_chunk));

     hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 20);
     get_payroll_action_info(p_payroll_action_id
                            ,ld_start_date
                            ,ld_end_date
                            ,lv_report_type
                            ,lv_report_qualifier
                            ,ln_business_group_id);

     hr_utility.trace('ld_start_date        = ' || ld_start_date);
     hr_utility.trace('ld_end_date          = ' || ld_end_date);
     hr_utility.trace('lv_report_type       = ' || lv_report_type);
     hr_utility.trace('lv_report_qualifier  = ' || lv_report_qualifier);
     hr_utility.trace('ln_business_group_id = ' || ln_business_group_id);

     hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 22);
     open w2c_future_correction_reported(ln_business_group_id
                                        ,ld_start_date
                                        ,ld_end_date
                                        ,p_start_person_id
                                        ,p_end_person_id
                                        );
     loop
--{
       hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 23);
       fetch w2c_future_correction_reported into ln_assignment_id,
                                                 ln_person_id;
       if w2c_future_correction_reported%ROWCOUNT = 0  then
          hr_utility.set_location(gv_package ||'.w2c_mag_action_creation', 24);
          hr_utility.trace('No Person found for whose future correction is already reported');
       end if;
       EXIT WHEN w2c_future_correction_reported%NOTFOUND;
--
--     If an employees future correction is already reported log a Warning to alert
--     that Federal W-2c Magnetic Media will not create action for this employee
--
       if ln_person_id is not null then
          hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 25);
          open get_warning_dtls_for_ee(ln_person_id);
          fetch get_warning_dtls_for_ee into lv_full_name
                                            ,lv_national_identifier;
          close get_warning_dtls_for_ee;
          hr_utility.trace('WARNING: Employee '||lv_full_name ||' Reported Future corrections');
          hr_utility.trace('         SSN = '||lv_national_identifier);
          /* message to user -- This employees future correction is already Reported
                                 genrating W-2c Mag */
          lv_record_name := 'Action_Creation';
          lv_message     := 'Future Correction reported for this employee';
          lv_name := lv_full_name || ', SSN '||lv_national_identifier;
          /* push message into pay_message_lines */
          pay_core_utils.push_message(801,'PAY_INVALID_EE_FORMAT','P');
          pay_core_utils.push_token('record_name',   lv_record_name);
          pay_core_utils.push_token('name_or_number',lv_name);
          pay_core_utils.push_token('description',   lv_message);
       end if;
       hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 27);
--}
     end loop;
     close w2c_future_correction_reported;
--
--   Fetch Employees for creating Action for Federal W-2c Magnetic Media
--
     open get_w2c_mag_assignments (ln_business_group_id
                                  ,ld_start_date
                                  ,ld_end_date
                                  ,p_start_person_id
                                  ,p_end_person_id
                                  );
     hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 30);
     loop
--{
        hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 40);
        fetch get_w2c_mag_assignments into ln_assignment_id,
                                           ln_emp_tax_unit_id,
                                           ln_person_id,
                                           ln_assignment_action_id,
                                           ln_w2c_pp_asg_actid,
                                           ln_w2c_pp_locked_actid;

        hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 50);

        if get_w2c_mag_assignments%ROWCOUNT = 0  then
           hr_utility.set_location(gv_package ||'.w2c_mag_action_creation', 60);
           hr_utility.trace('No Person found for reporting in this chunk');
        end if;

        EXIT WHEN get_w2c_mag_assignments%NOTFOUND;

        hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 70);
        hr_utility.trace('ln_assignment_id        =' ||ln_assignment_id);
        hr_utility.trace('ln_emp_tax_unit_id      =' ||ln_emp_tax_unit_id);
        hr_utility.trace('ln_person_id            =' ||ln_person_id);
        hr_utility.trace('ln_assignment_action_id =' ||ln_assignment_action_id);
        hr_utility.trace('Corrected assignment_action_id =' ||ln_w2c_pp_asg_actid);
        hr_utility.trace('action locked by Corrected assignment_action_id =' ||ln_w2c_pp_locked_actid);

        if ln_person_id is not null then
           hr_utility.set_location(gv_package ||'.w2c_mag_action_creation', 80);
           -- This check is performed to ignore duplicate assignment when a
           -- person is having an update on assignment during the tax year.
           -- multiple assignment dur to update on assignment was causing
           -- duplicate RCW record.
           if (nvl(ln_prev_person_id,0) <> ln_person_id) then
              action_creation(ln_person_id,
                              ln_assignment_id,
                              ln_assignment_action_id,
                              ln_emp_tax_unit_id,
                              ld_start_date,
                              ld_end_date,
                              ln_business_group_id,
                              ln_w2c_pp_asg_actid,
                              ln_w2c_pp_locked_actid
                             );
              hr_utility.set_location(gv_package ||'.w2c_mag_action_creation', 90);
           end if;
           ln_prev_person_id := ln_person_id;
        end if;
        hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 100);
--}
     end loop;
     close get_w2c_mag_assignments;
     hr_utility.trace('Action Creation for W2c_Magnetic_Media completed Successfully');
     hr_utility.set_location(gv_package || '.w2c_mag_action_creation', 110);
--}
  end w2c_mag_action_creation;
-- End of Procedure mar_w2c_action_creation
--
--Begin
--hr_utility.trace_on(null,'W2CMAG');
end pay_us_w2c_reporting_utils;

/
