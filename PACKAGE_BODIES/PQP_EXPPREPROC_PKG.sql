--------------------------------------------------------
--  DDL for Package Body PQP_EXPPREPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXPPREPROC_PKG" AS
/* $Header: pqexrppr.pkb 120.1 2006/03/03 15:57:24 sshetty noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--

--

*/
----------------------------------- range_cursor ----------------------------------
--
PROCEDURE range_cursor (pactid in number, sqlstr out nocopy varchar2) IS

  leg_param    pay_payroll_actions.legislative_parameters%TYPE ;
  l_consolidation_set_id NUMBER                                ;
  l_payroll_id NUMBER                                          ;
  l_tax_unit_id NUMBER                                         ;
  l_report_id   NUMBER;
  l_group_name  varchar2(30);
  l_start_date  VARCHAR2(15);   --DATE;
  l_temp_date   DATE;
--
BEGIN

   SELECT ppa.legislative_parameters                                                   ,
          pqp_exppreproc_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters) ,
          pqp_exppreproc_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters)  ,
          pqp_exppreproc_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters),
          pqp_exppreproc_pkg.get_parameter('TRANSFER_REPORT',ppa.legislative_parameters),
          pqp_exppreproc_pkg.get_parameter('TRANSFER_GROUP',ppa.legislative_parameters),
          pqp_exppreproc_pkg.get_parameter('TRANSFER_DATE',ppa.legislative_parameters)
     INTO leg_param,
          l_consolidation_set_id,
          l_payroll_id,
          l_tax_unit_id,
          l_report_id ,
          l_group_name,
          l_start_date
     FROM pay_payroll_actions ppa
    WHERE ppa.payroll_action_id = pactid;
l_temp_date:=to_date(l_start_date,'YYYY/MM/DD');

 pqp_expreplod_pkg.upd_payroll_actions (pactid ,
                                        l_payroll_id ,
                                        l_consolidation_set_id,
                                        l_temp_date  );

   sqlstr := 'select distinct asg.person_id
                from per_assignments_f      asg,
                     pay_assignment_actions act_run, /* run and quickpay assignment actions */
	             pay_payroll_actions    ppa_run, /* run and quickpay payroll actions */
                     pay_payroll_actions    ppa_gen  /* PYUGEN information */
               where ppa_gen.payroll_action_id    = :payroll_action_id
                 and     ppa_run.action_type         in (''R'',''Q'',''V'')
                 and ppa_run.action_status        = ''C''
                 and ppa_run.consolidation_set_id = nvl('''||l_consolidation_set_id||''',
                                                        ppa_run.consolidation_set_id)
                 and ppa_run.payroll_id           = nvl('''||l_payroll_id||''',
                                                        ppa_run.payroll_id)
                 and ppa_run.payroll_action_id    = act_run.payroll_action_id
                 and act_run.action_status        = ''C''
                 and asg.assignment_id            = act_run.assignment_id
                 and ppa_run.effective_date between  /* date join btwn run and asg */
                                                    asg.effective_start_date
                                                and asg.effective_end_date
		and  asg.business_group_id +0     = ppa_gen.business_group_id
		 order by asg.person_id';

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       sqlstr := NULL;
       raise;

END range_cursor;
---------------------------------- action_creation ----------------------------------
--
PROCEDURE action_creation(pactid in number   ,
                          stperson in number ,
                          endperson in number,
                          chunk in number) IS

  leg_param    pay_payroll_actions.legislative_parameters%TYPE;
  l_consolidation_set_id NUMBER;
  l_payroll_id           NUMBER;
  l_tax_unit_id          NUMBER;
  l_act_date             VARCHAR2(15);
  l_off_date             number;
  l_jd_cd                VARCHAR2(16);
--
--Added TRANSFER_DATE parameter by Gattu to Fix 3837327.999
 CURSOR c_parameters ( pactid number) is
   SELECT ppa.legislative_parameters,
          pqp_exppreproc_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pqp_exppreproc_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pqp_exppreproc_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters) ,
          pqp_exppreproc_pkg.get_parameter('TRANSFER_DATE',ppa.legislative_parameters),
           pqp_exppreproc_pkg.get_parameter('TRANSFER_JD',ppa.legislative_parameters)
     FROM pay_payroll_actions ppa
    WHERE ppa.payroll_action_id =pactid;


  CURSOR c_actions
      (
         pactid    NUMBER,
         stperson  NUMBER,
         endperson NUMBER,
	 off_date  NUMBER
      ) IS
               SELECT
                     MAX(act_run.assignment_action_id),
                     asg.assignment_id
                FROM per_assignments_f      asg,
	             pay_payroll_actions    ppa_run, /* run and quickpay payroll actions */
                     pay_assignment_actions act_run, /* run and quickpay assignment actions */
                     pay_payroll_actions    ppa_gen,  /* PYUGEN information */
                     per_time_periods       ptp
               WHERE ppa_gen.payroll_action_id    =   pactid
               --Added by Gattu
                AND ptp.payroll_id = nvl(l_payroll_id,
                                                        ppa_run.payroll_id)
                AND (ppa_run.effective_date BETWEEN ptp.start_date AND
                                                   ptp.end_date
                     OR ppa_run.effective_date = ptp.regular_payment_date )
           --     AND (DECODE (off_date ,1,ppa_run.effective_date,ppa_gen.effective_date
            --            )
                     AND    ptp.end_date
                 between  /* date join btwn run and pyugen ppa */
                                                    ppa_gen.start_date
                                               and ppa_gen.effective_date --)
                 AND ppa_run.action_type         in ('R','Q','V')
                 AND ppa_run.action_status        = 'C'
                 AND ppa_run.consolidation_set_id = l_consolidation_set_id
                 AND ppa_run.payroll_id           = nvl(l_payroll_id,
                                                        ppa_run.payroll_id)
                 AND ppa_run.payroll_action_id    = act_run.payroll_action_id
                 AND act_run.action_status        = 'C'
                 AND asg.assignment_id            = act_run.assignment_id
                 AND ppa_run.effective_date between  /* date join btwn run and asg */
                                                    asg.effective_start_date
                                                and asg.effective_end_date
		 AND asg.business_group_id      = ppa_gen.business_group_id
                   AND ( asg.soft_coding_keyflex_id IN
                 (SELECT hsck.soft_coding_keyflex_id
                           FROM hr_soft_coding_keyflex hsck
                           WHERE hsck.segment1 = TO_CHAR(l_tax_unit_id)
                            )
                           OR l_tax_unit_id IS NULL)
                 AND (l_jd_cd IS NULL OR
                       l_jd_cd in (select jurisdiction_code
                                   from pay_us_emp_state_tax_rules_f  puest
                                   WHERE puest.assignment_id=asg.assignment_id
                                    AND ppa_run.effective_date BETWEEN
                                     puest.effective_start_date AND
                                     puest.effective_end_date)
                                     )
                 AND asg.person_id          between  stperson and endperson
                 GROUP BY asg.assignment_id;


--
      lockingactid                  NUMBER;
      lockedactid                   NUMBER;
      assignid                      NUMBER;
      greid                         NUMBER;
      num                           NUMBER;
      action_type                   VARCHAR2(1);
      l_payments_bal                NUMBER;
--
   -- algorithm is quite similar to the other process cases,
   -- but we have to take into account assignments and
   -- personal payment methods.
   BEGIN

      --hr_utility.trace_on('Y','ORACLE');
      hr_utility.set_location('procpyr',1);

      OPEN c_parameters(pactid);
      FETCH c_parameters into leg_param,
                              l_consolidation_set_id,
                              l_payroll_id,
                              l_tax_unit_id ,
                              l_act_date,
                              l_jd_cd
                              ;
      CLOSE c_parameters;
      hr_utility.set_location('procpyr',1);

       l_off_date :=pqp_expreplod_pkg.get_offset_date
          ( l_payroll_id
          ,l_consolidation_set_id
          ,fnd_date.canonical_to_date(l_act_date));

     OPEN c_actions(pactid,stperson,endperson,l_off_date);
     num := 0;
      LOOP
         hr_utility.set_location('procpyr',2);
         fetch c_actions into lockedactid,assignid;
         if c_actions%found then num := num + 1; end if;
         exit when c_actions%notfound;

--


        	hr_utility.set_location('procpyr',3);
        	select pay_assignment_actions_s.nextval
        	into   lockingactid
        	from   dual;
--
        	-- insert the action record.
        	hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
--
         	-- insert an interlock to this action.
         	hr_nonrun_asact.insint(lockingactid,lockedactid);
--
      END LOOP;
      CLOSE c_actions;

end action_creation;
   ---------------------------------- sort_action ----------------------------------
PROCEDURE sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy    number        /* length of the sql string */
) IS

BEGIN

      sqlstr :=  'select paa1.rowid
                    from pay_assignment_actions paa1,   -- PYUGEN assignment action
                         pay_payroll_actions    ppa1    -- PYUGEN payroll action id
                   where ppa1.payroll_action_id = :pactid
                     and paa1.payroll_action_id = ppa1.payroll_action_id
                   order by paa1.assignment_action_id for update of paa1.assignment_id';

      len := length(sqlstr); -- return the length of the string.
-- Added by tmehra for nocopy changes Feb'03
-- Not storing the original value of sqlstr

EXCEPTION
    WHEN OTHERS THEN
       len := 0;
       sqlstr := NULL;
       raise;

   END sort_action;
------------------------------ get_parameter -------------------------------
FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
BEGIN
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
END get_parameter;


--This is called in deinitialize phase
procedure deinitialize (pactid in number)
  is
--
    l_remove_act     varchar2(10);
--
  begin
--
     select
            pay_core_utils.get_parameter('REMOVE_ACT',
                                         ppa.legislative_parameters)
       into l_remove_act
       from pay_payroll_actions ppa
      where ppa.payroll_action_id = pactid;

--
       if (l_remove_act is null or l_remove_act = 'Y') then
           pay_archive.remove_report_actions(pactid);
       end if;
--
end deinitialize;
END;

/
