--------------------------------------------------------
--  DDL for Package Body PAY_NEGBAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NEGBAL_PKG" as
/* $Header: pynegbal.pkb 115.9 2003/02/07 11:55:58 dsaxby ship $ */
--
 /* Name    : bal_db_item
  Purpose   : Given the name of a balance DB item as would be seen in a fast formula
              it returns the defined_balance_id of the balance it represents.
  Arguments :
  Notes     : A defined balance_id is required by the PLSQL balance function.
 */

 function bal_db_item
 (
  p_db_item_name varchar2
 ) return number is

 /* Get the defined_balance_id for the specified balance DB item. */

   cursor csr_defined_balance is
     select to_number(UE.creator_id)
     from  ff_user_entities  UE,
           ff_database_items DI
     where  DI.user_name            = p_db_item_name
       and  UE.user_entity_id       = DI.user_entity_id
       and  Ue.creator_type         = 'B';

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;

 begin

   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     raise hr_utility.hr_error;
   else
     close csr_defined_balance;
   end if;

   return (l_defined_balance_id);

 end bal_db_item;
--
  -- Name
  --   check_residence_state
  -- Purpose
  --  This checks that the state of residence for the given assignment id
  --  is the same as that passed in. Used
  --  in this package to determine if a person has lived in the state of
  --  MA. Such people need to be reported on SQWL for MA.
  -- Arguments
  --  Assignment Id
  --  Period Start Date
  --  Period End Date
  --  State
--
 FUNCTION check_residence_state (
   p_assignment_id NUMBER,
   p_period_start  DATE,
   p_period_end   DATE,
   p_state        VARCHAR2,
   p_effective_end_date DATE
 ) RETURN BOOLEAN IS

 l_resides_true      VARCHAR2(1);
 BEGIN

   BEGIN
   SELECT '1'
   INTO l_resides_true
   FROM dual
   WHERE EXISTS (
      SELECT '1'
      FROM per_assignments_f paf,
        per_addresses pad
      WHERE paf.assignment_id = p_assignment_id AND
        paf.person_id = pad.person_id AND
        pad.date_from <= p_period_end AND
        NVL(pad.date_to ,p_period_end) >= p_period_start AND
        pad.region_2 = p_state AND
        pad.primary_flag = 'Y');
    EXCEPTION when no_data_found then
      l_resides_true := '0';
    END;

   hr_utility.trace('l_resides_true =' || l_resides_true);

   IF (l_resides_true = '1' AND
         pay_balance_pkg.get_value(bal_db_item('GROSS_EARNINGS_PER_GRE_QTD'),
         p_assignment_id, least(p_period_end, p_effective_end_date)) > 0) THEN

      hr_utility.trace('Returning TRUE from check_residence_state');

      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END; -- check_residence_state
--
FUNCTION report_person_on_tape (
        p_assignment_id NUMBER,
        p_period_start  DATE,
        p_period_end    DATE,
        p_state                 VARCHAR2,
        p_effective_end_date DATE,
        p_1099R_ind    VARCHAR2
 ) RETURN BOOLEAN IS
 l_ret_value          BOOLEAN := FALSE;
 l_resides_in_state   BOOLEAN;
 BEGIN
     IF (p_state = 'MA' OR p_state = 'CA') THEN
            l_resides_in_state := check_residence_state(p_assignment_id,
                                                        p_period_start,
                                                        p_period_end,
                                                        p_state,
                                                        p_effective_end_date);
         l_ret_value := TRUE;
        IF (p_state = 'CA') THEN
           IF (p_1099R_ind = 'Y') THEN
               l_ret_value := (pay_balance_pkg.get_value(
                               bal_db_item('SIT_WITHHELD_PER_JD_GRE_QTD') ,
                                           p_assignment_id,
                                           least(p_period_end, p_effective_end_date)) > 0 );
                                l_resides_in_state := l_ret_value;
                                hr_utility.trace('1099R_ind is Y');
           ELSE
               l_ret_value := l_resides_in_state;
           END IF;
        END IF;
                l_ret_value := l_resides_in_state AND  l_ret_value;
     END IF;
        return l_ret_value;
 END; --report_person_on_tape
--
----------------------------------- range_cursor ----------------------------------
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_state      pay_us_states.state_abbrev%type;
--
begin
   select legislative_parameters,
          pay_negbal_pkg.get_parameter('TRANSFER_STATE',
              ppa.legislative_parameters)
     into leg_param,
          l_state
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;


/* Negative Balance Code */
   sqlstr :=  'SELECT distinct ASG.person_id
          FROM   per_assignments_f           ASG,
                 hr_organization_units       HOU,
                 pay_payrolls_f              PPY,
                 pay_state_rules             SR,
                 hr_organization_information HOI,
                 pay_us_asg_reporting        puar,
                 pay_payroll_actions         PPA
          WHERE  PPA.payroll_action_id       = :payroll_action_id
            AND  SR.state_code               = '''||l_state||'''
            AND  substr(SR.jurisdiction_code,1,2) = substr(puar.jurisdiction_code,1,2)
            AND  ASG.assignment_id           = puar.assignment_id
            AND  puar.tax_unit_id            = HOU.organization_id
            AND  ASG.business_group_id + 0   = PPA.business_group_id
            AND  ASG.assignment_type         = ''E''
            AND  ASG.effective_start_date    <= PPA.effective_date
            AND  ASG.effective_end_date      >= PPA.start_date
            AND ((not exists (
                         select ''x'' from hr_organization_information hoi2
                         where HOI2.ORG_INFORMATION_CONTEXT = ''1099R Magnetic Report Rules''
                         and   HOI2.org_information2 is not null
                         and HOI2.organization_id = hou.organization_id))
                   or ( '''||l_state||''' =  ''CA'')
                 )
                           AND  HOI.organization_id = puar.tax_unit_id
                           AND  HOI.ORG_INFORMATION_CONTEXT = ''State Tax Rules''
                           AND  HOI.ORG_INFORMATION1 = '''||l_state||'''
            AND  PPY.payroll_id              = ASG.payroll_id
          ORDER  BY ASG.person_id';

end range_cursor;
---------------------------------- action_creation ----------------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

      l_state       pay_us_states.state_abbrev%type;
      greid         number;
      lockedactid   number;
      lockingactid  number;
      assignid      number;
      num           number;
      prevperid     number;
      prevgreid     number;
      effdt         date;
      transmitter_code varchar2(240);
      jd_code       varchar2(12);
      personid      number;
      l_qtr_start   date;
      l_qtr_end     date;
      l_year_start  date;
      l_year_end    date;
      l_period_start date;
      l_period_end  date;
      l_defined_balance_id number;
      l_value number :=0;
      l_sui_exempt number;

  CURSOR c_actions
      ( pactid    number,
        stperson  number,
        endperson number ) is
     SELECT paa.assignment_action_id    locked_action_id,
            asg.assignment_id           assignment_id,
            asg.person_id               person_id,
            paa.tax_unit_id             tax_unit_id,
            ppa.effective_date          effective_end_date,
            sr.jurisdiction_code        jurisdiction_code
      FROM  hr_organization_information hoi,
            pay_payroll_actions         ppa,
            pay_assignment_actions      paa,
            pay_state_rules             sr,
            per_assignments_f           asg,
            pay_payroll_actions         ppa_arch
     WHERE  ppa_arch.payroll_action_id  = pactid
       AND  asg.person_id between         stperson and endperson
       AND  asg.business_group_id + 0   = ppa_arch.business_group_id
       AND  asg.assignment_type         = 'E'
       AND  asg.effective_start_date    <= l_period_end
       AND  asg.effective_end_date      >= l_period_start
       AND  paa.assignment_id           = asg.assignment_id
       AND  (paa.action_sequence,asg.person_id,paa.tax_unit_id)
                                    in (select max(paa1.action_sequence),paf1.person_id, paa1.tax_unit_id
                                             from pay_action_classifications pac,
                                                  pay_payroll_actions        ppa1,
                                                  pay_assignment_actions     paa1,
                                                  per_assignments_f          paf1
                                            where paf1.person_id          = asg.person_id
                                              AND paf1.business_group_id + 0   = ppa_arch.business_group_id
                                              AND paf1.assignment_type         = 'E'
                                              AND paf1.effective_start_date    <= l_period_end
                                              AND paf1.effective_end_date      >= l_period_start
                                              and paa1.assignment_id           = paf1.assignment_id
                                              and paa1.tax_unit_id             = paa.tax_unit_id
                                              and ppa1.payroll_action_id       = paa1.payroll_action_id
                                              and ppa1.action_type             = pac.action_type
                                              and pac.classification_name      = 'SEQUENCED'
                                              and ppa1.effective_date     between
                                                                          l_period_start
                                                                          and l_period_end
                                              group by paf1.person_id, paa1.tax_unit_id)
       AND  ppa.payroll_action_id        = paa.payroll_action_id
       AND  ppa.effective_date            between l_period_start
                                              and l_period_end
       AND  ppa.action_type               in ('R','Q','V','B','I')
       AND  ppa.effective_date            between asg.effective_start_date
                                              and asg.effective_end_date
       AND  SR.state_code               = l_state
       AND  hoi.organization_id         = paa.tax_unit_id
       AND  hoi.org_information_context = 'State Tax Rules'
       AND  hoi.org_information1        = l_state
       AND  EXISTS                        (select '' from pay_us_asg_reporting puar
                                            where asg.assignment_id = puar.assignment_id
                                              and paa.tax_unit_id   = puar.tax_unit_id
                                              and substr(SR.jurisdiction_code  ,1,2) =
                                                  substr(puar.jurisdiction_code,1,2));
-- Commented to improve the performance
--     ORDER  BY paa.tax_unit_id,asg.person_id,asg.assignment_id
--               for update of asg.assignment_id;

     CURSOR c_transmitter  is
          SELECT decode(l_state,'CA',null,hoi2.org_information2)
            FROM hr_organization_information hoi2
           WHERE hoi2.organization_id         = greid
             AND hoi2.org_information_context = '1099R Magnetic Report Rules';

--
--
   begin
      -- hr_utility.trace_on('Y','ORACLE');
      hr_utility.set_location('pay_negbal_pkg.procngb',1);
      select pay_negbal_pkg.get_parameter('TRANSFER_STATE',
             ppa.legislative_parameters) state_abbrev,
             ppa.start_date,
             ppa.effective_date,
             trunc(ppa.effective_date, 'Y'),
             add_months(trunc(ppa.effective_date, 'Y'),12) - 1
     into l_state,
          l_qtr_start,
          l_qtr_end,
          l_year_start,
          l_year_end
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

     /*  New York state settings NB. the difference is that the criteria for
         selecting people in the 4th quarter is different to that used for the
         first 3 quarters of the tax year. */

         if     l_state = 'NY' and  to_char(l_qtr_end,'MM')= '12' then
         	/* Period is the last quarter of the year.*/
         	l_period_start         := l_year_start;
         	l_period_end           := l_year_end;
         	l_defined_balance_id   := bal_db_item('SIT_GROSS_PER_JD_GRE_YTD');
         else
         	/* Period is one of the first 3 quarters of tax year. */
         	l_period_start         := l_qtr_start;
         	l_period_end           := l_qtr_end;
         	l_defined_balance_id   := bal_db_item('SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD');
         end if;

      open c_actions(pactid,stperson,endperson);
      num := 0;
      prevperid := -1;
      prevgreid := -1;
      l_value   := 0;
      loop
         hr_utility.set_location('pay_negbal_pkg.procngb',2);
         fetch c_actions into lockedactid,assignid,personid,
                              greid,effdt,jd_code;
         if c_actions%found then num := num + 1; end if;
         exit when c_actions%notfound;
--
         begin
           open c_transmitter;
                fetch c_transmitter into transmitter_code;
                if c_transmitter%notfound then
                   transmitter_code := 'N' ;
                end if;
           close c_transmitter;
         exception
           when others then
                hr_utility.set_location('pay_negbal_pkg.procngb',22);
                raise;
         end;
        -- we need to insert one action for each of the
        -- assignments that we return from the cursor.
	if personid = prevperid and greid =  prevgreid then
           null;
        else
          hr_utility.set_location('pay_negbal_pkg.procngb',3);
          -- set up contexts required to test the balance.
             pay_balance_pkg.set_context('TAX_UNIT_ID',greid);
             pay_balance_pkg.set_context('JURISDICTION_CODE',jd_code);

          select count(*)
            into l_sui_exempt
            from pay_us_emp_state_tax_rules_f ptax,
                 pay_us_states pst
           where ptax.assignment_id = assignid
             and ptax.effective_start_date <= l_qtr_end
             and ptax.effective_end_date >= l_qtr_start
             and pst.state_code = ptax.state_code
             and pst.state_abbrev = l_state
             and ptax.sui_exempt = 'Y'
             and not exists ( select 'x'
                                from pay_us_emp_state_tax_rules_f ptax,
                                     pay_us_states pst
                               where ptax.assignment_id = assignid
                                 and ptax.effective_start_date <= l_qtr_end
                                 and ptax.effective_end_date >= l_qtr_start
                                 and pst.state_code = ptax.state_code
                                 and pst.state_abbrev = l_state
                                 and ptax.sui_exempt = 'N') ;
          hr_utility.set_location('pay_negbal_pkg.procngb',4);
          if l_sui_exempt = 0 then
            hr_utility.set_location('pay_negbal_pkg.procngb',5);
            if nvl(transmitter_code,'N') <> 'Y' then
              hr_utility.set_location('pay_negbal_pkg.procngb',6);
              l_value := pay_balance_pkg.get_value(p_defined_balance_id   => l_defined_balance_id,
                                                   p_assignment_action_id => lockedactid);
            else
             l_value := 0;
            end if;
          end if;

          if ((l_value > 0 ) OR
               report_person_on_tape(assignid,l_period_start,l_period_end,
                                     l_state, effdt,transmitter_code)) then

                hr_utility.set_location('pay_negbal_pkg.procngb',7);
	  	select pay_assignment_actions_s.nextval
	  	into   lockingactid
	  	from   dual;
          	-- insert the action record.
                   hr_utility.set_location('pay_negbal_pkg.procngb',8);
          	   hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
                   hr_utility.set_location('pay_negbal_pkg.procngb',9);
          	-- insert an interlock to this action
            -- Bug fix 1850043
     	  	-- hr_nonrun_asact.insint(lockingactid,lockedactid);
                   hr_utility.set_location('pay_negbal_pkg.procngb',10);
          end if;
	end if;
	prevperid := personid;
        prevgreid := greid;
--
      end loop;
      hr_utility.set_location('pay_negbal_pkg.procngb',11);
      close c_actions;
end action_creation;
   ---------------------------------- sort_action ----------------------------------
procedure sort_action
(
   payactid   in            varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out           number        /* length of the sql string */
) is
 begin

      hr_utility.set_location('pay_negbal_pkg.sort_action',1);
      sqlstr :=  'select paa.rowid
                  from pay_payroll_actions    ppa,
                       pay_assignment_actions paa,
                       per_all_assignments_f paf,   -- #1894165
                       hr_organization_units hou,
                       hr_organization_units hou1
                  where ppa.payroll_action_id = :pactid
                  and   paa.payroll_action_id = ppa.payroll_action_id
                  and   paf.assignment_id = paa.assignment_id
                  and   paf.business_group_id + 0   = ppa.business_group_id
                  and   paf.assignment_type         = ''E''
                  and   paf.effective_start_date  = (select max(paf1.effective_start_date)
                                                     from per_all_assignments_f paf1   --# 1894165
                                                     where paf1.assignment_id = paf.assignment_id
                                                       and paf1.business_group_id + 0   = ppa.business_group_id
                                                       and paf1.assignment_type         = ''E''
                                                       and paf1.effective_start_date <= ppa.effective_date
                                                       and paf1.effective_end_date >=
                                                       decode(pay_negbal_pkg.get_parameter
                                                              (''TRANSFER_STATE'',ppa.legislative_parameters),
                                                               ''NY'',
                                                                decode(to_char(ppa.effective_date,''Q''),
                                                                4, trunc(ppa.start_date, ''Y''), ppa.start_date
                                                                      )
                                                               , ppa.start_date
                                                             )
                                                    )
                  and   paa.tax_unit_id   = hou.organization_id
                  and   hou1.organization_id = nvl(paf.organization_id,paf.business_group_id)  -- # 1894165
                  order by hou.name,hou1.name,paf.assignment_number
		  for update of paf.assignment_id';

      len := length(sqlstr); -- return the length of the string.
      hr_utility.set_location('pay_negbal_pkg.sort_action',2);
   end sort_action;
--
------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;

end pay_negbal_pkg;


/
