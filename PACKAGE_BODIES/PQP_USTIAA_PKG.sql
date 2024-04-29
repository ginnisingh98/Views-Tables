--------------------------------------------------------
--  DDL for Package Body PQP_USTIAA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_USTIAA_PKG" AS
/* $Header: pqustiaa.pkb 120.8.12000000.1 2007/01/16 04:38:42 appldev noship $ */

g_proc_name  VARCHAR2(50) := 'pqp_ustiaa_pkg.';

-- ---------------------------------------------------------------------
-- |------------------------< range_cursor >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE range_cursor
          (pactid IN         NUMBER
          ,sqlstr OUT NOCOPY VARCHAR2) IS
  leg_param              pay_payroll_actions.legislative_parameters%TYPE ;
  l_consolidation_set_id NUMBER;
  l_payroll_id           NUMBER;
  l_tax_unit_id          NUMBER;
  l_proc_name            VARCHAR2(150) := g_proc_name ||'range_cursor';
  l_consolidation_set_text VARCHAR2(100);
  l_payroll_text VARCHAR2(100);
  l_tax_unit_text VARCHAR2(100);

BEGIN
   hr_utility.set_location('Entering : '||l_proc_name, 10);
   SELECT ppa.legislative_parameters,
          pqp_ustiaa_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
     INTO leg_param,
          l_consolidation_set_id,
          l_payroll_id,
          l_tax_unit_id
     FROM pay_payroll_actions ppa
    WHERE ppa.payroll_action_id = pactid;
   hr_utility.set_location('..Parameters are :'||leg_param,15);

    -- For Bug 5636004 Performance Improvement.

    IF l_consolidation_set_id is not null THEN
       l_consolidation_set_text := 'and ppa_run.consolidation_set_id = ' || to_char(l_consolidation_set_id) ;
    ELSE
       l_consolidation_set_text := NULL;
    END IF;

    IF l_payroll_id is not null THEN
       l_payroll_text := 'and ppa_run.payroll_id = ' || to_char(l_payroll_id) ;
    ELSE
       l_payroll_text := null;
    END IF;

    IF l_tax_unit_id is not null THEN
       l_tax_unit_text := 'and act_run.tax_unit_id = ' || to_char(l_tax_unit_id) ;
    ELSE
        l_tax_unit_text := NULL;
    END IF;


   sqlstr := 'select distinct asg.person_id
                from per_assignments_f      asg,
                     pay_assignment_actions act_run,
                     pay_payroll_actions    ppa_run,
                     pay_payroll_actions    ppa_gen
               where ppa_gen.payroll_action_id    = :payroll_action_id
                 and ppa_run.action_type          in (''R'',''Q'',''V'',''B'')
                 and ppa_run.action_status        = ''C''
                 '||l_consolidation_set_text||'
                 '||l_payroll_text||'
                 and ppa_run.payroll_action_id    = act_run.payroll_action_id
                 '||l_tax_unit_text||'

                 and asg.assignment_id            = act_run.assignment_id
                 and ppa_run.effective_date between asg.effective_start_date
                                                and asg.effective_end_date
		         and  asg.business_group_id       = ppa_gen.business_group_id
		         order by asg.person_id';
    hr_utility.set_location('Leaving : '||l_proc_name, 90);
EXCEPTION
    WHEN OTHERS THEN
     sqlstr := NULL;
     hr_utility.set_location('..Error in '||l_proc_name||' : '||SQLERRM,150);
     hr_utility.set_location('Leaving : '||l_proc_name, 150);
     RAISE;
END range_cursor;

-- ---------------------------------------------------------------------
-- |-----------------------< action_creation >--------------------------|
-- ---------------------------------------------------------------------
PROCEDURE action_creation
           (pactid      IN NUMBER,
            stperson    IN NUMBER ,
            endperson   IN NUMBER,
            chunk       IN NUMBER) IS

  leg_param    pay_payroll_actions.legislative_parameters%TYPE;
  l_consolidation_set_id NUMBER;
  l_payroll_id           NUMBER;
  l_tax_unit_id          NUMBER;
  l_proc_name            VARCHAR2(150) := g_proc_name ||'action_creation';

  CURSOR c_parameters (pactid NUMBER) IS
   SELECT ppa.legislative_parameters,
          pqp_ustiaa_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
     FROM pay_payroll_actions ppa
    WHERE ppa.payroll_action_id = pactid;

  CURSOR c_actions (pactid    NUMBER,
                    stperson  NUMBER,
                    endperson NUMBER ) IS
     SELECT
            ppa_run.action_type         ,
            act_run.assignment_action_id,
            asg.assignment_id           ,
            act_run.tax_unit_id
       FROM per_assignments_f      asg,
            pay_payroll_actions    ppa_run,
            pay_assignment_actions act_run,
            pay_payroll_actions    ppa_gen
      WHERE
            ppa_gen.payroll_action_id    =   pactid
        AND ppa_run.effective_date BETWEEN ppa_gen.start_date
                                       AND ppa_gen.effective_date
        AND ppa_run.action_type         IN ('R','Q','V','B')
        AND ppa_run.action_status        = 'C'
        AND ppa_run.consolidation_set_id = NVL(l_consolidation_set_id,
                                               ppa_run.consolidation_set_id)
        AND ppa_run.payroll_id           = NVL(l_payroll_id,
                                               ppa_run.payroll_id)
        AND ppa_run.payroll_action_id    = act_run.payroll_action_id
        AND act_run.action_status        = 'C'
        AND act_run.tax_unit_id          = NVL(l_tax_unit_id,
                                               act_run.tax_unit_id)
        AND asg.assignment_id            = act_run.assignment_id
        AND ppa_run.effective_date BETWEEN asg.effective_start_date
                                       AND asg.effective_end_date
        AND asg.business_group_id        = ppa_gen.business_group_id
        AND asg.person_id BETWEEN stperson
                              AND endperson
        order by asg.assignment_id, act_run.assignment_action_id
        FOR UPDATE OF asg.assignment_id;

  CURSOR c_defbal IS
     SELECT TO_NUMBER(ue.creator_id) creator_id,
            di.user_name
       FROM ff_user_entities ue,
            ff_database_items di
      WHERE di.user_name IN ( 'GROSS_EARNINGS_ASG_GRE_RUN',
                              'PAYMENTS_ASG_GRE_RUN' )
        AND ue.user_entity_id             = di.user_entity_id
        AND ue.creator_type               = 'B'
        AND NVL(ue.legislation_code,'US') = 'US';

   l_defbal c_defbal%ROWTYPE;
   no_userid                     EXCEPTION;
   lockingactid                  NUMBER;
   lockedactid                   NUMBER;
   assignid                      NUMBER;
   greid                         NUMBER;
   num                           NUMBER;
   action_type                   VARCHAR2(1);
   l_payments_bal                NUMBER;
   l_gross_defined_balance_id    NUMBER;
   l_payments_defined_balance_id NUMBER;
 BEGIN
      hr_utility.set_location('Entering : '||l_proc_name, 10);
      OPEN c_parameters(pactid);
      FETCH c_parameters INTO leg_param,
                              l_consolidation_set_id,
                              l_payroll_id,
                              l_tax_unit_id;
      CLOSE c_parameters;
      hr_utility.set_location('..Parameters are :'||leg_param, 15);
      BEGIN
        OPEN c_defbal;
        LOOP
          FETCH c_defbal INTO l_defbal;
          EXIT WHEN c_defbal%NOTFOUND;
          IF l_defbal.user_name= 'GROSS_EARNINGS_ASG_GRE_RUN' THEN
              l_gross_defined_balance_id:=l_defbal.creator_id;
          ELSIF l_defbal.user_name= 'PAYMENTS_ASG_GRE_RUN' THEN
                 l_payments_defined_balance_id:=l_defbal.creator_id;
          END IF;
        END LOOP;
        CLOSE  c_defbal;

        IF l_gross_defined_balance_id    IS NULL OR
           l_payments_defined_balance_id IS NULL THEN
           RAISE no_userid;
        END IF;
      EXCEPTION WHEN no_userid THEN
           hr_utility.trace('Error getting defined balance id');
           RAISE;
      END;
      --
      -- Open the Assignment Action Creation Cursor
      --
     hr_utility.set_location('..Opening the Assignment Action Creation Cursor', 20);
     OPEN c_actions(pactid,stperson,endperson);
     num := 0;
     LOOP
         FETCH c_actions INTO action_type,lockedactid,assignid,greid;
         IF c_actions%FOUND THEN
            num := num + 1;
         END IF;
         EXIT WHEN c_actions%NOTFOUND;

        	SELECT pay_assignment_actions_s.nextval
        	INTO   lockingactid
        	FROM   dual;
         -- Insert a record into pay_assignment_actions and pay_action_interlocks
        	hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);
         hr_nonrun_asact.insint(lockingactid,lockedactid);

         /* The following code is commented bug 4343076
         pay_balance_pkg.set_context('TAX_UNIT_ID',greid);
         l_payments_bal := NVL(pay_balance_pkg.get_value
                                (p_defined_balance_id   => l_gross_defined_balance_id,
                                 p_assignment_action_id => lockedactid),0);

         IF l_payments_bal = 0       AND
            action_type IN ('R','Q') THEN
            l_payments_bal := NVL(pay_balance_pkg.get_value
                                    (p_defined_balance_id   => l_payments_defined_balance_id,
                                     p_assignment_action_id => lockedactid),0);
         END IF;
         IF l_payments_bal = 0       AND
            action_type IN ('R','Q') THEN
            NULL;
         ELSE
            NULL;
         END IF;
         */

     END LOOP;
     CLOSE c_actions;
     hr_utility.set_location('Leaving : '||l_proc_name, 90);
EXCEPTION
    WHEN OTHERS THEN
     hr_utility.set_location('..Error in '||l_proc_name||' : '||SQLERRM,150);
     hr_utility.set_location('Leaving : '||l_proc_name, 150);
     RAISE;
END action_creation;

-- ---------------------------------------------------------------------
-- |-------------------------< sort_action >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE sort_action
          (payactid   IN            VARCHAR2,
           sqlstr     IN OUT NOCOPY VARCHAR2,
           len        OUT NOCOPY    NUMBER
           ) IS
  l_proc_name            VARCHAR2(150) := g_proc_name ||'sort_action';
BEGIN
  hr_utility.set_location('Entering : '||l_proc_name, 10);
  sqlstr :=  'select paa1.rowid
                from pay_assignment_actions paa1,
                     pay_payroll_actions    ppa1
               where ppa1.payroll_action_id = :pactid
                 and paa1.payroll_action_id = ppa1.payroll_action_id
               order by paa1.assignment_id,paa1.assignment_action_id
                 for update of paa1.assignment_id';

   len := LENGTH(sqlstr);
   hr_utility.set_location('Leaving : '||l_proc_name, 90);
EXCEPTION
    WHEN OTHERS THEN
     sqlstr := NULL;
     len    := NULL;
     hr_utility.set_location('..Error in '||l_proc_name||' : '||SQLERRM,150);
     hr_utility.set_location('Leaving : '||l_proc_name, 150);
     RAISE;
END sort_action;

-- ---------------------------------------------------------------------
-- |------------------------< get_parameter >---------------------------|
-- ---------------------------------------------------------------------
FUNCTION get_parameter
         (name           IN VARCHAR2,
          parameter_list    VARCHAR2
          ) RETURN VARCHAR2 IS
  start_ptr   NUMBER;
  end_ptr     NUMBER;
  token_val   pay_payroll_actions.legislative_parameters%TYPE;
  par_value   pay_payroll_actions.legislative_parameters%TYPE;

BEGIN
     token_val := name||'=';
     start_ptr := INSTR(parameter_list, token_val) + LENGTH(token_val);
     end_ptr := INSTR(parameter_list, ' ',start_ptr);
     IF end_ptr = 0 THEN
        end_ptr := LENGTH(parameter_list)+1;
     END IF;
     IF INSTR(parameter_list, token_val) = 0 THEN
       par_value := NULL;
     ELSE
       par_value := SUBSTR(parameter_list, start_ptr, end_ptr - start_ptr);
     END IF;
     RETURN par_value;
END get_parameter;

-- -------------------------------------------------------------------------------------
-- |-----------------------< action_creation_ops >--------------------------|
-- -------------------------------------------------------------------------------------
PROCEDURE action_creation_ops
           (pactid        IN NUMBER,
            stperson    IN NUMBER ,
            endperson  IN NUMBER,
            chunk        IN NUMBER) IS

  leg_param    pay_payroll_actions.legislative_parameters%TYPE;
  l_consolidation_set_id	NUMBER;
  l_payroll_id			NUMBER;
  l_tax_unit_id			NUMBER;
  l_proc_name			VARCHAR2(150) := g_proc_name ||'action_creation_ops';

  CURSOR c_parameters (pactid NUMBER) IS
   SELECT ppa.legislative_parameters,
          pqp_ustiaa_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
     FROM pay_payroll_actions ppa
    WHERE ppa.payroll_action_id = pactid;

  CURSOR c_actions_ops (pactid    NUMBER,
                    stperson  NUMBER,
                    endperson NUMBER ) IS
     SELECT
            max(act_run.assignment_action_id),
            asg.assignment_id
       FROM per_assignments_f      asg,
            pay_payroll_actions    ppa_run,
            pay_assignment_actions act_run,
            pay_payroll_actions    ppa_gen
      WHERE
            ppa_gen.payroll_action_id    =   pactid
        AND ppa_run.effective_date BETWEEN ppa_gen.start_date
                                       AND ppa_gen.effective_date
        AND ppa_run.action_type         IN ('R','Q','V','B')
        AND ppa_run.action_status        = 'C'
        AND ppa_run.consolidation_set_id = NVL(l_consolidation_set_id,
                                               ppa_run.consolidation_set_id)
        AND ppa_run.payroll_id           = NVL(l_payroll_id,
                                               ppa_run.payroll_id)
        AND ppa_run.payroll_action_id    = act_run.payroll_action_id
        AND act_run.action_status        = 'C'
        AND act_run.tax_unit_id          = NVL(l_tax_unit_id,
                                               act_run.tax_unit_id)
        AND asg.assignment_id            = act_run.assignment_id
        AND ppa_run.effective_date BETWEEN asg.effective_start_date
                                       AND asg.effective_end_date
        AND asg.business_group_id        = ppa_gen.business_group_id
        AND asg.person_id BETWEEN stperson
                              AND endperson
	AND EXISTS (
		 select NULL
		   FROM	pay_run_results rr,
			pay_element_types_f e,
			pay_element_type_extra_info ei
		  WHERE rr.assignment_action_id = act_run.assignment_action_id
		    AND rr.element_type_id = e.element_type_id
		    AND e.element_type_id = ei.element_type_id
		    AND ei.information_type = 'US_TIAA_CREF_CONT_TYPES'
		    AND ppa_run.effective_date BETWEEN e.effective_start_date AND e.effective_end_date
		)
	group by asg.assignment_id;

  CURSOR c_defbal IS
     SELECT TO_NUMBER(ue.creator_id) creator_id,
            di.user_name
       FROM ff_user_entities ue,
            ff_database_items di
      WHERE di.user_name IN ( 'GROSS_EARNINGS_ASG_GRE_RUN',
                              'PAYMENTS_ASG_GRE_RUN' )
        AND ue.user_entity_id             = di.user_entity_id
        AND ue.creator_type               = 'B'
        AND NVL(ue.legislation_code,'US') = 'US';

   l_defbal c_defbal%ROWTYPE;
   no_userid                     EXCEPTION;
   lockingactid                  NUMBER;
   lockedactid                   NUMBER;
   assignid			      NUMBER;
   greid                            NUMBER;
   num                             NUMBER;
   action_type                   VARCHAR2(1);
   l_payments_bal                NUMBER;
   l_gross_defined_balance_id    NUMBER;
   l_payments_defined_balance_id NUMBER;
 BEGIN
      hr_utility.set_location('Entering : '||l_proc_name, 10);

      OPEN c_parameters(pactid);
      FETCH c_parameters INTO leg_param,
                              l_consolidation_set_id,
                              l_payroll_id,
                              l_tax_unit_id;
      CLOSE c_parameters;
      hr_utility.set_location('..Parameters are :'||leg_param, 15);
      BEGIN
        OPEN c_defbal;
        LOOP
          FETCH c_defbal INTO l_defbal;
          EXIT WHEN c_defbal%NOTFOUND;
          IF l_defbal.user_name= 'GROSS_EARNINGS_ASG_GRE_RUN' THEN
              l_gross_defined_balance_id:=l_defbal.creator_id;
          ELSIF l_defbal.user_name= 'PAYMENTS_ASG_GRE_RUN' THEN
                 l_payments_defined_balance_id:=l_defbal.creator_id;
          END IF;
        END LOOP;
        CLOSE  c_defbal;

        IF l_gross_defined_balance_id    IS NULL OR
           l_payments_defined_balance_id IS NULL THEN
           RAISE no_userid;
        END IF;
      EXCEPTION WHEN no_userid THEN
           hr_utility.trace('Error getting defined balance id');
           RAISE;
      END;
      --
      -- Open the Assignment Action Creation Cursor
      --
     hr_utility.set_location('..Opening the Assignment Action Creation Cursor', 20);
     OPEN c_actions_ops(pactid,stperson,endperson);
     LOOP
         FETCH c_actions_ops INTO lockedactid,assignid;
         IF c_actions_ops%FOUND THEN

	      SELECT pay_assignment_actions_s.nextval
              INTO   lockingactid
              FROM   dual;
         -- Insert a record into pay_temp_object_actions
              hr_nonrun_asact.insact(lockingactid =>lockingactid,
        		        object_id   =>assignid,
        		        pactid      =>pactid,
        		        chunk       =>chunk );
	 END IF;

	 EXIT WHEN c_actions_ops%NOTFOUND;

     END LOOP;
     CLOSE c_actions_ops;
     hr_utility.set_location('Leaving : '||l_proc_name, 90);
     -- hr_utility.trace_on(null, 'TIAA');
EXCEPTION
    WHEN OTHERS THEN
     hr_utility.set_location('..Error in '||l_proc_name||' : '||SQLERRM,150);
     hr_utility.set_location('Leaving : '||l_proc_name, 150);
     RAISE;
END action_creation_ops;

-- ----------------------------------------------------------------------------
-- |------------------------< get_amount >----------------------------|
-- ---------------------------------------------------------------------------
FUNCTION get_amount(p_bal_type_id IN NUMBER,
                                p_assactid    IN NUMBER)
			        RETURN NUMBER IS

   CURSOR csr_def_bal_id IS
     SELECT db.defined_balance_id
       FROM pay_defined_balances db,
            pay_balance_dimensions bd
      WHERE bd.dimension_name      IN ('Assignment-Level Current Run' ,'Assignment Default Run')
        AND bd.balance_dimension_id =  db.balance_dimension_id
	AND db.balance_type_id      = p_bal_type_id;

l_def_bal_id number;
l_value number;
l_proc_name varchar2(50) := 'pqp_ustiaa_pkg.get_amount';

BEGIN

hr_utility.set_location('Entering : '||l_proc_name, 10);

OPEN csr_def_bal_id;
fetch csr_def_bal_id INTO l_def_bal_id;
CLOSE csr_def_bal_id;

--hr_utility.set_location('l_def_bal_id : '||l_def_bal_id, 12);-
--hr_utility.set_location('p_bal_type_id : '||p_bal_type_id, 14);
--hr_utility.set_location('p_assactid : '||p_assactid, 16);

IF l_def_bal_id is not null THEN
l_value := pay_balance_pkg.get_value
             (p_defined_balance_id   => l_def_bal_id,
              p_assignment_action_id => p_assactid );
END IF;

RETURN(l_value);

hr_utility.set_location('Leaving : '||l_proc_name, 20);

END get_amount;

-- ------------------------------------------------------------------------------
-- |------------------------< get_plan_no >----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION get_plan_no(p_asg_id IN NUMBER,
		     p_date   IN DATE,
		     p_tax_unit_id IN NUMBER)
		     RETURN VARCHAR2 IS

  CURSOR csr_asg_plan_no IS
  SELECT paei.aei_information2,
         pasg.payroll_id
    FROM per_assignment_extra_info paei ,
         per_assignments_f pasg
   WHERE pasg.assignment_id       = p_asg_id
     AND pasg.assignment_id       = paei.assignment_id(+)
     AND paei.information_type(+) =   'PQP_US_TIAA_CREF_CODES'
     AND p_date           BETWEEN pasg.effective_start_date
                              AND pasg.effective_end_date;

 CURSOR csr_pay_plan_no (p_payroll_id number) IS
  SELECT prl.prl_information14
    FROM pay_payrolls_f prl
   WHERE prl.payroll_id = p_payroll_id
     AND prl.prl_information_category = 'US'
     AND p_date           BETWEEN prl.effective_start_date
                              AND prl.effective_end_date;

   CURSOR  csr_org_plan_no IS
    SELECT org_information2
      FROM hr_organization_information
     WHERE org_information_context   = 'PQP_US_TIAA_CREF_CODES'
       AND organization_id           = p_tax_unit_id;

l_payroll_id	NUMBER;
l_plan_no		VARCHAR2(6);

BEGIN

OPEN csr_asg_plan_no;
fetch csr_asg_plan_no
 INTO l_plan_no,
      l_payroll_id;
CLOSE csr_asg_plan_no;

IF l_plan_no is not null THEN
	RETURN l_plan_no;
ELSE
    OPEN  csr_pay_plan_no(l_payroll_id);
    fetch csr_pay_plan_no INTO  l_plan_no;
    CLOSE csr_pay_plan_no;
END IF;

IF l_plan_no is not null THEN
	RETURN l_plan_no;
ELSE
    OPEN  csr_org_plan_no;
    FETCH csr_org_plan_no INTO  l_plan_no;
    CLOSE csr_org_plan_no;
END IF;

RETURN l_plan_no;

END get_plan_no;

-- -------------------------------------------------------------------------------------
-- |--------------------< chk_cont_type_override >-----------------------|
-- ------------------------------------------------------------------------------------
PROCEDURE chk_cont_type_override(p_asg_id        IN NUMBER,
				 p_ele_entry_id  IN NUMBER,
				 p_source        IN out nocopy VARCHAR2,
				 p_sub_plan      IN out nocopy VARCHAR2) IS

CURSOR csr_asg_info IS
select pei.aei_information1,pei.aei_information2
  from per_assignment_extra_info pei
 where pei.assignment_id = p_asg_id
   and pei.aei_information_category = 'PAY_US_TIAA_CREF_CONT_TYPE'
   and pei.aei_information3 = p_ele_entry_id;

l_proc_name varchar2(50) := 'pqp_ustiaa_pkg.chk_cont_type_override';
l_sub_plan          varchar2(5);
l_source            varchar2(2);
BEGIN
      hr_utility.set_location('Entering : '||l_proc_name, 10);

      OPEN csr_asg_info;
      FETCH csr_asg_info INTO l_source, l_sub_plan;
      IF csr_asg_info%found THEN
	  if l_source is not null then
		p_source := l_source;
	  end if;
	  if l_sub_plan is not null then
		p_sub_plan := l_sub_plan;
	  end if;
      END IF;
      CLOSE csr_asg_info;

      hr_utility.set_location('Leaving : '||l_proc_name, 20);

END chk_cont_type_override;

-- -------------------------------------------------------------------
-- |--------------------< chk_pri_bal >-----------------------|
-- -------------------------------------------------------------------
FUNCTION chk_pri_bal(p_asgact_id NUMBER,
		     p_date DATE)  RETURN boolean IS

Cursor csr_chk_dup_bal_types is
SELECT count(*)
  FROM pay_run_results rr,
       pay_element_types_f e,
       pay_element_type_extra_info ei
 WHERE rr.assignment_action_id = p_asgact_id
   AND rr.element_type_id = e.element_type_id
   AND e.element_type_id = ei.element_type_id
   AND ei.information_type = 'US_TIAA_CREF_CONT_TYPES'
   AND p_date BETWEEN e.effective_start_date AND e.effective_end_date
   AND rr.entry_type not in ('A','R')
   and rr.rowid > (SELECT min(rr1.rowid)
		   FROM pay_run_results rr1,
	 	        pay_element_types_f e1,
		        pay_element_type_extra_info ei1
		  WHERE rr1.assignment_action_id = rr.assignment_action_id
 		    AND rr1.element_type_id = e1.element_type_id
  		    AND e1.element_type_id = ei1.element_type_id
		    AND ei1.information_type = 'US_TIAA_CREF_CONT_TYPES'
		    AND e1.element_information10 = e.element_information10
		    AND p_date BETWEEN e1.effective_start_date AND e1.effective_end_date
		    AND rr1.entry_type not in ('A','R'));

l_cnt number := 0;

BEGIN

OPEN csr_chk_dup_bal_types;
FETCH csr_chk_dup_bal_types INTO l_cnt;
CLOSE csr_chk_dup_bal_types;

IF l_cnt > 0 THEN
	RETURN TRUE;
ELSE
	RETURN FALSE;
END IF;

END chk_pri_bal;

-- ---------------------------------------------------------------------
-- |-------------------------< load_xml >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE LOAD_XML (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS

    l_proc_name     varchar2(100) := 'pqp_ustiaa_pkg.load_xml';
    l_data          varchar2(500);
BEGIN

    hr_utility.set_location('Entering : '||l_proc_name, 10);

    IF p_node_type = 'CS' THEN
        pay_core_files.write_to_magtape_lob('<'||p_node||'>');
    ELSIF p_node_type = 'CE' THEN
        pay_core_files.write_to_magtape_lob('</'||p_node||'>');
    ELSIF p_node_type = 'D' THEN
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        pay_core_files.write_to_magtape_lob('<'||p_node||'>'||l_data||'</'||p_node||'>');
    END IF;

    hr_utility.set_location('Leaving : '||l_proc_name, 20);

END LOAD_XML;

-- ---------------------------------------------------------------------
-- |-----------------------< generate_header >--------------------------|
-- --------------------------------------------------------------------
PROCEDURE generate_header_xml is
l_proc_name varchar2(50) := 'pqp_ustiaa_pkg.generate_header_xml';

CURSOR csr_rpt_data(pactid number) IS
select ppa.start_date,
ppa.effective_date,
bg.name
from per_business_groups bg,
pay_payroll_actions ppa
where ppa.payroll_action_id = pactid
and ppa.business_group_id = bg.business_group_id;

l_payroll_action_id number;
l_start_date date;
l_end_date date;
l_bg_name per_business_groups.name%TYPE;

BEGIN
      hr_utility.set_location('Entering : '||l_proc_name, 10);

        l_payroll_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
	IF (l_payroll_action_id is null) THEN
		    l_payroll_action_id := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
	END IF;
       -- hr_utility.set_location('l_payroll_action_id : '||l_payroll_action_id, 15);

	OPEN csr_rpt_data(l_payroll_action_id);
	FETCH csr_rpt_data INTO
		l_start_date,
		l_end_date,
		l_bg_name;
	CLOSE csr_rpt_data;

      load_xml('CS','US_TIAA_CREF','');
      load_xml('D','BG_NAME',l_bg_name);
      load_xml('D','RPT_START_DATE',l_start_date);
      load_xml('D','RPT_END_DATE',l_end_date);

      -- hr_utility.set_location('l_bg_name : '||l_bg_name, 15);

      hr_utility.set_location('Leaving : '||l_proc_name, 20);


END generate_header_xml;

-- ---------------------------------------------------------------------
-- |-----------------------< generate_footer >--------------------------|
-- --------------------------------------------------------------------
PROCEDURE generate_footer_xml is
l_proc_name varchar2(50) := 'pqp_ustiaa_pkg.generate_footer_xml';
BEGIN

      hr_utility.set_location('Entering : '||l_proc_name, 10);

      load_xml('CE','US_TIAA_CREF','');

      hr_utility.set_location('Leaving : '||l_proc_name, 20);

END generate_footer_xml;

-- ---------------------------------------------------------------------
-- |------------------------< generate_record >-------------------------|
-- ---------------------------------------------------------------------
PROCEDURE generate_record IS
l_proc_name		VARCHAR2 (100) := 'pqp_ustiaa_pkg.generate_record';
l_last_name		per_all_people_f.last_name%TYPE;
l_first_name		per_all_people_f.first_name%TYPE;
l_middle_name		per_all_people_f.middle_names%TYPE;
l_ssn			per_all_people_f.national_identifier%TYPE;
l_gender		per_all_people_f.sex%TYPE;
l_gender1		per_all_people_f.sex%TYPE;
l_dob			per_all_people_f.date_of_birth%TYPE;
l_asg_id		per_all_assignments_f.assignment_id%TYPE;
l_asg_no		per_all_assignments_f.assignment_number%TYPE;
l_addr1			per_addresses.address_line1%TYPE;
l_addr2			per_addresses.address_line2%TYPE;
l_addr3			per_addresses.address_line3%TYPE;
l_country		per_addresses.country%TYPE;
l_city			per_addresses.town_or_city%TYPE;
l_state			per_addresses.region_2%TYPE;
l_state1		per_addresses.region_2%TYPE;
l_postal_code		per_addresses.postal_code%TYPE;
l_postal_code1		per_addresses.postal_code%TYPE;
l_plan_no		varchar2(6);
l_plan_no1		varchar2(6);
l_pay_date		date;
l_tax_unit_id		number;
l_payroll_id		number;
l_sub_plan		varchar2(5);
l_source		varchar2(2);
l_mode			varchar2(3);
l_pay_freq		varchar2(1);
l_amount		number;
l_period_type		varchar2(30);
l_fmt_amount		varchar2(30);
l_assignment_action_id	number;
l_locked_act_id		number;
l_err_msg		varchar2(1000);
l_err			boolean := FALSE;
leg_param		pay_payroll_actions.legislative_parameters%TYPE;
l_consolidation_set_id	NUMBER;

CURSOR csr_per_detail (p_asg_id number,
		       p_date date) IS
select papf.last_name last_name,
       papf.first_name first_name,
       papf.middle_names middle_name,
       papf.national_identifier ssn,
       papf.sex gender,
       papf.date_of_birth dob,
       padd.address_line1 addr1,
       padd.address_line2 addr2,
       padd.address_line3 addr3,
       padd.country country,
       padd.town_or_city city,
       padd.region_2 state,
       padd.postal_code postal_code,
       paf.assignment_number
from per_all_assignments_f paf
   , per_all_people_f papf
   , per_addresses padd
where paf.assignment_id = p_asg_id
and paf.person_id = papf.person_id
and padd.person_id = papf.person_id
and padd.primary_flag = 'Y'
and p_date between paf.effective_start_date and paf.effective_end_date
and p_date between papf.effective_start_date and papf.effective_end_date
and p_date between padd.date_from and nvl(padd.date_to,p_date);

CURSOR csr_get_asg_actions(p_assactid number) IS
select paa.assignment_id asg_id,
          paa.assignment_action_id act_id,
	  ppa_run.effective_date pay_date,
	  paa.tax_unit_id tax_unit_id
from pay_payroll_actions ppa_gen,
pay_assignment_actions paa,
pay_payroll_actions ppa_run,
pay_temp_object_actions poa
where poa.object_action_id = p_assactid
and poa.payroll_action_id = ppa_gen.payroll_action_id
and poa.object_id = paa.assignment_id
and paa.payroll_action_id = ppa_run.payroll_action_id
and (paa.source_action_id is not null
	or (paa.source_action_id is null and ppa_run.action_type in ('B','V')))
and ppa_run.effective_date between ppa_gen.start_date and ppa_gen.effective_date
and ppa_run.action_type in ('R','Q','B','V')
and ppa_run.action_status = 'C'
AND ppa_run.consolidation_set_id = NVL(l_consolidation_set_id,
                                       ppa_run.consolidation_set_id)
AND ppa_run.payroll_id           = NVL(l_payroll_id,
                                       ppa_run.payroll_id)
AND paa.tax_unit_id          = NVL(l_tax_unit_id,
                                       paa.tax_unit_id)
AND EXISTS (
		select NULL
		from pay_element_entries_f ee,
		pay_element_types_f e,
		pay_element_type_extra_info ei
		where ee.assignment_id = paa.assignment_id
		and ee.element_type_id = e.element_type_id
		and ei.element_type_id = e.element_type_id
		and ei.information_type = 'US_TIAA_CREF_CONT_TYPES'
		and ppa_run.effective_date between e.effective_start_date and e.effective_end_date
		and ppa_run.effective_date between ee.effective_start_date and ee.effective_end_date
		);

CURSOR csr_get_ele_entries(p_asgact_id NUMBER,
			   p_date   DATE) IS
SELECT rr.element_entry_id ele_entry_id,
       ei.eei_information1 cont_source,
       ei.eei_information2 cont_sub_plan,
       ei.eei_information3 plan_no,
       e.element_information10 bal_type_id,
       e.element_name
  FROM pay_run_results rr,
       pay_element_types_f e,
       pay_element_type_extra_info ei
 WHERE rr.assignment_action_id = p_asgact_id
   AND rr.element_type_id = e.element_type_id
   AND e.element_type_id = ei.element_type_id
   AND ei.information_type = 'US_TIAA_CREF_CONT_TYPES'
   AND p_date BETWEEN e.effective_start_date AND e.effective_end_date
   AND rr.entry_type not in ('A','R');

   CURSOR  csr_payroll_details(p_asg_id number,
			       p_date   date) IS
   SELECT  prl.prl_information4,
                 prl.period_type
     FROM  per_all_assignments_f paf,
	         pay_payrolls_f prl
    WHERE  paf.assignment_id = p_asg_id
      AND  prl.payroll_id               = paf.payroll_id
      AND  prl.prl_information_category = 'US'
      AND  p_date BETWEEN paf.effective_start_date
                                AND  paf.effective_end_date
      AND  p_date BETWEEN prl.effective_start_date
                                AND  prl.effective_end_date;

  CURSOR c_parameters (asg_actid NUMBER) IS
   SELECT ppa.legislative_parameters,
          pqp_ustiaa_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
          pqp_ustiaa_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters)
     FROM pay_payroll_actions ppa,
     pay_temp_object_actions poa
    WHERE poa.object_action_id = asg_actid
    and ppa.payroll_action_id = poa.payroll_action_id;

Begin

l_assignment_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');
l_err :=  FALSE;
l_err_msg := '';

      OPEN c_parameters(l_assignment_action_id);
      FETCH c_parameters INTO leg_param,
                              l_consolidation_set_id,
                              l_payroll_id,
                              l_tax_unit_id;
      CLOSE c_parameters;

/* Validations */
FOR a IN csr_get_asg_actions(l_assignment_action_id) LOOP

	OPEN csr_per_detail(a.asg_id, a.pay_date);
	FETCH csr_per_detail INTO
	    l_last_name,
	    l_first_name,
	    l_middle_name,
	    l_ssn,
	    l_gender,
	    l_dob,
	    l_addr1,
	    l_addr2,
	    l_addr3,
	    l_country,
	    l_city,
	    l_state,
	    l_postal_code,
	    l_asg_no;
	CLOSE csr_per_detail;

	OPEN csr_payroll_details(a.asg_id, a.pay_date);
	FETCH csr_payroll_details INTO
		 l_mode,
		 l_period_type;
	CLOSE csr_payroll_details;

	l_plan_no1 := get_plan_no(a.asg_id,a.pay_date,a.tax_unit_id);

	IF l_mode is null THEN
	   l_err := TRUE;
	   l_err_msg := ' Mode is Null';
	END IF;

	/* Check for uniqueness of Primary Balance for element entries */
	IF chk_pri_bal(a.act_id,a.pay_date) THEN
		l_err := TRUE;
		l_err_msg := l_err_msg || ' Primary Balance is not unique across element entries';
	END IF;

	FOR i IN csr_get_ele_entries(a.act_id, a.pay_date) loop

		  IF(i.bal_type_id is not null) THEN
		     l_amount := get_amount(i.bal_type_id,a.act_id);
		  ELSE
		     l_err := TRUE;
		     l_err_msg := l_err_msg || ' Primary Balance required for Element '||i.element_name;
		  END IF;

		  l_source := i.cont_source;
		  l_sub_plan := i.cont_sub_plan;

		  IF (i.plan_no is not null) THEN
			l_plan_no := i.plan_no;
		  ELSE
			l_plan_no := l_plan_no1;
		  END IF;

		  /* Use Overides for source and sub plan if present at Asg level*/
		  chk_cont_type_override(a.asg_id, i.ele_entry_id, l_source, l_sub_plan);

  		  IF l_plan_no is null THEN
			l_err := TRUE;
			l_err_msg := l_err_msg || ' Plan Number is Null.';
		  END IF;

		  IF l_source is null THEN
		     l_err := TRUE;
		     l_err_msg := l_err_msg || ' Contribution Source is Null for Element'||i.element_name;
		  END IF;

		  IF l_sub_plan is null THEN
		     l_err := TRUE;
		     l_err_msg := l_err_msg || ' Contribution Sub Plan is Null for Element'||i.element_name;
		  END IF;
	END LOOP; -- for ele entries

END LOOP; -- for asg actions


/* Generate XML */
IF l_err THEN

     load_xml('CS','INVALID_DATA','');
     load_xml('D','EMP_NAME',l_last_name||','||l_first_name||' '||substr(l_middle_name,1,1));
     load_xml('D','ASG_NO',l_asg_no);
     load_xml('D','ERROR_TEXT',l_err_msg);
     load_xml('CE','INVALID_DATA','');

ELSE

	FOR a IN csr_get_asg_actions(l_assignment_action_id) LOOP

		/* Get Person Details*/
		OPEN csr_per_detail(a.asg_id, a.pay_date);
		FETCH csr_per_detail INTO
		    l_last_name,
		    l_first_name,
		    l_middle_name,
		    l_ssn,
		    l_gender,
		    l_dob,
		    l_addr1,
		    l_addr2,
		    l_addr3,
		    l_country,
		    l_city,
		    l_state,
		    l_postal_code,
		    l_asg_no;
		CLOSE csr_per_detail;

		/* Get Payroll Details*/
		OPEN csr_payroll_details(a.asg_id, a.pay_date);
		   FETCH csr_payroll_details INTO
			 l_mode,
			 l_period_type;
		CLOSE csr_payroll_details;

		/* Get Payroll Details*/
		l_plan_no1 := get_plan_no(a.asg_id,a.pay_date,a.tax_unit_id);


		FOR i IN csr_get_ele_entries(a.act_id, a.pay_date) loop

			  IF(i.bal_type_id is not null) THEN
			     l_amount := get_amount(i.bal_type_id,a.act_id);
			  END IF;

			  l_source := i.cont_source;
			  l_sub_plan := i.cont_sub_plan;

			  IF (i.plan_no is not null) THEN
				l_plan_no := i.plan_no;
			  ELSE
				l_plan_no := l_plan_no1;
			  END IF;

			  /* Use Overides for source and sub plan if present at Asg level*/
			  chk_cont_type_override(a.asg_id, i.ele_entry_id, l_source, l_sub_plan);

			  IF l_amount <> 0 THEN

				l_pay_freq :=
				CASE when l_period_type = 'Year'			then '1'
					  when l_period_type = 'Semi-Year'		then '2'
					  when l_period_type = 'Quarter'		then '3'
					  when l_period_type = 'Calendar Month'		then '4'
					  when l_period_type = 'Lunar Month'		then '4'
					  when l_period_type = 'Semi-Month'		then '5'
					  when l_period_type = 'Bi-Month'		then '5'
					  when l_period_type = 'Bi-Week'		then '6'
					  when l_period_type = 'Week'			then '7'
				END;

				IF l_amount > 0 THEN
					l_fmt_amount := round(l_amount*100,0);
				ELSE
					l_fmt_amount := substr(round(l_amount*(-100),0),1,length(round(l_amount*(-100),0))-1)
						|| translate(substr(round(l_amount*(-100),0),-1,1),'0123456789','}JKLMNOPQR');
				END IF;

				load_xml('CS','G_EMPLOYEE_DATA','');
				load_xml('D','PLAN_NO',l_plan_no);
				load_xml('D','MODE',l_mode);
				load_xml('D','SSN',l_ssn);
				load_xml('D','EMP_NAME',l_last_name||','||l_first_name||' '||substr(l_middle_name,1,1));
				load_xml('D','GENDER',l_gender);
				load_xml('D','DOB',replace(substr(nvl(fnd_date.date_to_canonical(l_dob),'0'),1,10),'/','-'));
				load_xml('D','ADD_LINE1',l_addr1);
				load_xml('D','ADD_LINE2',l_addr2);
				load_xml('D','ADD_LINE3',l_addr3);
				load_xml('D','CITY',l_city);
				load_xml('D','STATE',l_state);
				load_xml('D','COUNTRY',l_country);
				load_xml('D','ZIP',l_postal_code);
				load_xml('D','PAYROLL_FREQ',l_pay_freq);
				load_xml('D','PERIOD_TYPE',l_period_type);
				load_xml('D','PAYROLL_DATE',to_char(replace(substr(nvl(fnd_date.date_to_canonical(a.pay_date),'0'),1,10),'/','-')));
				load_xml('D','SOURCE',l_source);
				load_xml('D','AMOUNT',round(l_amount,2));
				load_xml('D','FMT_AMOUNT',l_fmt_amount);
				load_xml('D','SUB_PLAN',l_sub_plan);
				load_xml('CE','G_EMPLOYEE_DATA','');

			  END IF;

		END LOOP; -- for ele entries

	END LOOP; -- for asg actions

END IF;

END generate_record;

END PQP_UStiaa_pkg;

/
