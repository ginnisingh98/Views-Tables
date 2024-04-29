--------------------------------------------------------
--  DDL for Package Body PAY_KW_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_ARCHIVE" AS
			/* $Header: pykwparc.pkb 120.6.12010000.1 2008/07/27 23:07:35 appldev ship $ */

			g_debug   boolean   :=  hr_utility.debug_enabled;

			TYPE element_rec IS RECORD (
			     classification_name VARCHAR2(60)
			    ,element_name        VARCHAR2(60)
			    ,element_type_id     NUMBER
			    ,element_type        VARCHAR2(1)
			    ,input_value_id      NUMBER
			    ,input_value         VARCHAR2(60)
			    ,uom                 VARCHAR2(1)
			    ,archive_flag        VARCHAR2(1));

			TYPE balance_rec IS RECORD (
			     balance_name         VARCHAR2(60),
			     defined_balance_id   NUMBER,
			     balance_type_id      NUMBER,
			     uom                  VARCHAR2(20));

			TYPE lock_rec IS RECORD (
			     archive_assact_id    NUMBER);


			TYPE element_table   IS TABLE OF  element_rec   INDEX BY BINARY_INTEGER;
			TYPE balance_table   IS TABLE OF  balance_rec   INDEX BY BINARY_INTEGER;
			TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;

			g_element_table                   element_table;
			g_user_balance_table              balance_table;
			g_lock_table   		          lock_table;

			g_index             NUMBER := -1;
			g_index_assact      NUMBER := -1;
			g_index_bal	    NUMBER := -1;

			g_package           VARCHAR2(33) := '  PAY_KW_ARCHIVE.';
			g_payroll_action_id	NUMBER;
			g_arc_payroll_action_id NUMBER;
			g_business_group_id NUMBER;
			g_format_mask VARCHAR2(50);

			g_err_num NUMBER;
			g_errm VARCHAR2(150);


			/* GET PARAMETER */
			FUNCTION GET_PARAMETER(
				 p_parameter_string IN VARCHAR2
				,p_token            IN VARCHAR2
				,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
			IS

			  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
			  l_start_pos  NUMBER;
			  l_delimiter  VARCHAR2(1):=' ';
			  l_proc VARCHAR2(40):= g_package||' get parameter ';

			BEGIN
			--

			IF g_debug THEN
			    hr_utility.set_location(' Entering Function GET_PARAMETER',10);
			END IF;

			l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
			--
			  IF l_start_pos = 0 THEN
			    l_delimiter := '|';
			    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
			  END IF;

			  IF l_start_pos <> 0 THEN
			    l_start_pos := l_start_pos + length(p_token||'=');
			    l_parameter := substr(p_parameter_string,
						  l_start_pos,
						  instr(p_parameter_string||' ',
						  l_delimiter,l_start_pos)
						  - l_start_pos);
			    IF p_segment_number IS NOT NULL THEN
			      l_parameter := ':'||l_parameter||':';
			      l_parameter := substr(l_parameter,
						    instr(l_parameter,':',1,p_segment_number)+1,
						    instr(l_parameter,':',1,p_segment_number+1) -1
						    - instr(l_parameter,':',1,p_segment_number));
			    END IF;
			  END IF;
			  --
			  RETURN l_parameter;

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
			END IF;

			END;

			/* GET ALL PARAMETERS */
			PROCEDURE GET_ALL_PARAMETERS(
			       p_payroll_action_id                    IN   NUMBER
			      ,p_business_group_id                    OUT  NOCOPY NUMBER
			      ,p_start_date                           OUT  NOCOPY VARCHAR2
			      ,p_end_date                             OUT  NOCOPY VARCHAR2
			      ,p_effective_date                       OUT  NOCOPY DATE
			      ,p_payroll_id                           OUT  NOCOPY VARCHAR2
			      ,p_consolidation_set                    OUT  NOCOPY VARCHAR2) IS
			--
			CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS

			SELECT PAY_KW_ARCHIVE.GET_PARAMETER(legislative_parameters,'PAYROLL_ID')
			      ,PAY_KW_ARCHIVE.GET_PARAMETER(legislative_parameters,'CONSOLIDATION_SET_ID')
			      ,PAY_KW_ARCHIVE.GET_PARAMETER(legislative_parameters,'START_DATE')
			      ,PAY_KW_ARCHIVE.GET_PARAMETER(legislative_parameters,'END_DATE')
			      ,effective_date
			      ,business_group_id
			FROM  pay_payroll_actions
			WHERE payroll_action_id = p_payroll_action_id;
			l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
			--
			BEGIN
			OPEN csr_parameter_info (p_payroll_action_id);
			FETCH csr_parameter_info INTO p_payroll_id
							     ,p_consolidation_set
							     ,p_start_date
							     ,p_end_date
							     ,p_effective_date
							     ,p_business_group_id;
			CLOSE csr_parameter_info;
			--

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
			END IF;
			END GET_ALL_PARAMETERS;



			/* RANGE CODE */
			PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
					     ,p_sql    OUT   NOCOPY VARCHAR2)
			IS

			----------------------------------------------------
			--MESSAGES
			----------------------------------------------------

			CURSOR csr_get_message(p_bus_grp_id NUMBER) IS
			SELECT org_information6 message
			FROM   hr_organization_information
			WHERE  organization_id = p_bus_grp_id
			AND    org_information_context = 'Business Group:Payslip Info'
			AND    org_information1 = 'MESG';

			----------------------------------------------------
			--TIME PERIOD
			----------------------------------------------------

			/* Cursor to retrieve Time Period Information */
			CURSOR csr_time_periods(p_run_payact_id NUMBER
					       ,p_payroll_id NUMBER) IS
			SELECT ptp.end_date              end_date,
			       ptp.start_date            start_date,
			       ppa.effective_date        pay_date,
			       ptp.period_name           period_name,
			       ppf.payroll_name          payroll_name
			FROM   per_time_periods    ptp
			      ,pay_payroll_actions ppa
			      ,pay_payrolls_f  ppf
			WHERE  ptp.payroll_id           = ppa.payroll_id
			AND    ppa.payroll_action_id    = p_run_payact_id
			AND    ppa.payroll_id           = ppf.payroll_id
			AND    ppf.payroll_id           = NVL(p_payroll_id , ppf.payroll_id)
			AND    ppa.date_earned BETWEEN ptp.start_date
						   AND ptp.end_date
			AND    ppa.date_earned BETWEEN ppf.effective_start_date
						   AND ppf.effective_end_date;

			-----------------------------------------------------------------
			-- BALANCES
			-----------------------------------------------------------------
			/* Cursor to retrieve Other Balances Information */
			CURSOR csr_get_balance(p_bus_grp_id NUMBER) IS
			SELECT org_information1 balance_type_id
			      ,org_information2 balance_dim_id
			      ,org_information3 narrative
			FROM   hr_organization_information
			WHERE  organization_id = p_bus_grp_id
			AND    org_information_context = 'KW_PAYSLIP_BALANCES';


			/* Cursor to fetch defined balance id */
			CURSOR csr_def_balance(bal_type_id NUMBER, bal_dim_id NUMBER) IS
			SELECT defined_balance_id
			FROM   pay_defined_balances
			WHERE  balance_type_id = bal_type_id
			AND    balance_dimension_id = bal_dim_id;

			--------------------------------------------------------------
			-- Additional Element
			--------------------------------------------------------------
			/* Cursor to retrieve Additional Element Information */
			CURSOR csr_get_element(p_bus_grp_id NUMBER, p_date_earned DATE) IS
			SELECT hoi.org_information1 element_type_id
			      ,hoi.org_information2 input_value_id
			      ,hoi.org_information3 element_narrative
			      ,pec.classification_name
			      ,piv.uom
			FROM   hr_organization_information hoi
			      ,pay_element_classifications pec
			      ,pay_element_types_f  pet
			      ,pay_input_values_f piv
			WHERE  hoi.organization_id = p_bus_grp_id
			AND    hoi.org_information_context = 'KW_PAYSLIP_ELEMENTS'
			AND    hoi.org_information1 = pet.element_type_id
			AND    pec.classification_id = pet.classification_id
			AND    piv.input_value_id = hoi.org_information2
			AND    p_date_earned BETWEEN piv.effective_start_date
						 AND piv.effective_end_date;


			rec_time_periods csr_time_periods%ROWTYPE;

			rec_get_balance csr_get_balance%ROWTYPE;
			rec_get_message csr_get_message%ROWTYPE;
			rec_get_element csr_get_element%ROWTYPE;
			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_business_group_id NUMBER;
			l_start_date VARCHAR2(30);
			l_end_date VARCHAR2(30);
			l_effective_date DATE;
			l_consolidation_set NUMBER;
			l_defined_balance_id NUMBER := 0;
			l_count NUMBER := 0;
			l_prev_prepay		NUMBER := 0;
			l_canonical_start_date	DATE;
			l_canonical_end_date    DATE;
			l_payroll_id		NUMBER;
			l_prepay_action_id	NUMBER;
			l_actid			NUMBER;
			l_assignment_id NUMBER;
			l_action_sequence NUMBER;
			l_assact_id     NUMBER;
			l_pact_id NUMBER;
			l_flag NUMBER := 0;
			l_element_context VARCHAR2(5);

			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
			END IF;

			PAY_KW_ARCHIVE.GET_ALL_PARAMETERS(p_payroll_action_id
					,l_business_group_id
					,l_start_date
					,l_end_date
					,l_effective_date
					,l_payroll_id
					,l_consolidation_set);


			l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
			l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');

			----------------------------------------------------
			--ARCHIVE MESSAGES
			----------------------------------------------------

			OPEN csr_get_message(l_business_group_id);
				LOOP
				FETCH csr_get_message INTO rec_get_message;
				EXIT WHEN csr_get_message%NOTFOUND;

				pay_action_information_api.create_action_information (
						  p_action_information_id        => l_action_info_id
						 ,p_action_context_id            => p_payroll_action_id
						 ,p_action_context_type          => 'PA'
						 ,p_object_version_number        => l_ovn
						 ,p_effective_date               => l_effective_date
						 ,p_source_id                    => NULL
						 ,p_source_text                  => NULL
						 ,p_action_information_category  => 'EMPLOYEE OTHER INFORMATION'
						 ,p_action_information1          => l_business_group_id
						 ,p_action_information2          => 'MESG' -- Message Context
						 ,p_action_information3          => NULL
						 ,p_action_information4          => NULL
						 ,p_action_information5          => NULL
						 ,p_action_information6          => rec_get_message.message);
				END LOOP;
			     CLOSE csr_get_message;


			-------------------------------------------------------------------------------------
			-- Initialize Balance Definitions
			-------------------------------------------------------------------------------------

			OPEN csr_get_balance(l_business_group_id);
			LOOP
			FETCH csr_get_balance INTO rec_get_balance;
			EXIT WHEN csr_get_balance%NOTFOUND;

			OPEN csr_def_balance(rec_get_balance.balance_type_id,rec_get_balance.balance_dim_id);
			FETCH csr_def_balance INTO l_defined_balance_id;
			CLOSE csr_def_balance;

			BEGIN


			SELECT 1 INTO l_flag
			FROM   pay_action_information
			WHERE  action_information_category = 'EMEA BALANCE DEFINITION'
			AND    action_context_id           = p_payroll_action_id
			AND    action_information2         = l_defined_balance_id
			AND    action_information6         = 'OBAL'
			AND    action_information4         = rec_get_balance.narrative;

			EXCEPTION WHEN NO_DATA_FOUND THEN
			pay_action_information_api.create_action_information (
						p_action_information_id        => l_action_info_id
						,p_action_context_id            => p_payroll_action_id
						,p_action_context_type          => 'PA'
						,p_object_version_number        => l_ovn
						,p_effective_date               => l_effective_date
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'EMEA BALANCE DEFINITION'
						,p_action_information1          => NULL
						,p_action_information2          => l_defined_balance_id
						,p_action_information4          => rec_get_balance.narrative
						,p_action_information6          => 'OBAL');
			WHEN OTHERS THEN
			NULL;
			END;

			END LOOP;
			CLOSE csr_get_balance;

			-----------------------------------------------------------------------------
			--Initialize Element Definitions
			-----------------------------------------------------------------------------
			g_business_group_id := l_business_group_id;


				ARCHIVE_ELEMENT_INFO(p_payroll_action_id  => p_payroll_action_id
						    ,p_effective_date    => l_effective_date
						    ,p_date_earned       => l_canonical_end_date
						    ,p_pre_payact_id     => NULL);

			-----------------------------------------------------------------------------
			--Archive Additional Element Definitions
			-----------------------------------------------------------------------------

			l_element_context := 'F';

			OPEN csr_get_element(l_business_group_id,l_canonical_end_date);
			LOOP
			FETCH csr_get_element INTO rec_get_element;
			EXIT WHEN csr_get_element%NOTFOUND;



				BEGIN

				SELECT 1 INTO l_flag
				FROM   pay_action_information
				WHERE  action_context_id = p_payroll_action_id
				AND    action_information_category = 'EMEA ELEMENT DEFINITION'
				AND    action_information2 = rec_get_element.element_type_id
				AND    action_information3 = rec_get_element.input_value_id
				AND    action_information5 = l_element_context;


				EXCEPTION WHEN NO_DATA_FOUND THEN

				pay_action_information_api.create_action_information (
							p_action_information_id        => l_action_info_id
							,p_action_context_id            => p_payroll_action_id
							,p_action_context_type          => 'PA'
							,p_object_version_number        => l_ovn
							,p_effective_date               => l_effective_date
							,p_source_id                    => NULL
							,p_source_text                  => NULL
							,p_action_information_category  => 'EMEA ELEMENT DEFINITION'
							,p_action_information1          => NULL
							,p_action_information2          => rec_get_element.element_type_id
							,p_action_information3          => rec_get_element.input_value_id
							,p_action_information4          => rec_get_element.element_narrative
							,p_action_information5          => l_element_context
							,p_action_information6          => rec_get_element.uom
							,p_action_information7          => l_element_context);
				WHEN OTHERS THEN
					NULL;
				END;
			    END LOOP;
			    CLOSE csr_get_element;



			p_sql := 'SELECT DISTINCT person_id
				FROM  per_people_f ppf
				     ,pay_payroll_actions ppa
				WHERE ppa.payroll_action_id = :payroll_action_id
				AND   ppa.business_group_id = ppf.business_group_id
				ORDER BY ppf.person_id';

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
			END IF;

			EXCEPTION
			WHEN OTHERS THEN
			-- Return cursor that selects no rows
			p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';

			END RANGE_CODE;


			/* ASSIGNMENT ACTION CODE */
			PROCEDURE ASSIGNMENT_ACTION_CODE
			(p_payroll_action_id     IN NUMBER
			,p_start_person          IN NUMBER
			,p_end_person            IN NUMBER
			,p_chunk                 IN NUMBER)
			IS

			CURSOR csr_prepaid_assignments(p_payroll_action_id          	NUMBER,
						       p_start_person      	NUMBER,
						       p_end_person         NUMBER,
						       p_payroll_id       	NUMBER,
						       p_consolidation_id 	NUMBER,
						       l_canonical_start_date	DATE,
						       l_canonical_end_date	DATE)
			IS
			SELECT act.assignment_id            assignment_id,
			       act.assignment_action_id     run_action_id,
			       act1.assignment_action_id    prepaid_action_id
			FROM   pay_payroll_actions          ppa,
			       pay_payroll_actions          appa,
			       pay_payroll_actions          appa2,
			       pay_assignment_actions       act,
			       pay_assignment_actions       act1,
			       pay_action_interlocks        pai,
			       per_all_assignments_f        as1
			WHERE  ppa.payroll_action_id        = p_payroll_action_id
			AND    appa.consolidation_set_id    = p_consolidation_id
			AND    appa.effective_date          BETWEEN l_canonical_start_date
							    AND     l_canonical_end_date
			AND    as1.person_id                BETWEEN p_start_person
							    AND     p_end_person
			AND    appa.action_type             IN ('R','Q')
			       -- Payroll Run or Quickpay Run
			AND    act.payroll_action_id        = appa.payroll_action_id
			AND    act.source_action_id         IS NULL -- Master Action
			AND    as1.assignment_id            = act.assignment_id
			AND    ppa.effective_date           BETWEEN as1.effective_start_date
							    AND     as1.effective_end_date
			AND    act.action_status            = 'C'  -- Completed
			AND    act.assignment_action_id     = pai.locked_action_id
			AND    act1.assignment_action_id    = pai.locking_action_id
			AND    act1.action_status           = 'C' -- Completed
			AND    act1.payroll_action_id       = appa2.payroll_action_id
			AND    appa2.action_type            IN ('P','U')
			AND    appa2.effective_date          BETWEEN l_canonical_start_date
								 AND l_canonical_end_date
			       -- Prepayments or Quickpay Prepayments
			AND    (as1.payroll_id = p_payroll_id OR p_payroll_id IS NULL)
			AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
					   FROM   pay_action_interlocks      pai1,
						  pay_assignment_actions     act2,
						  pay_payroll_actions        appa3
					   WHERE  pai1.locked_action_id    = act.assignment_action_id
					   AND    act2.assignment_action_id= pai1.locking_action_id
					   AND    act2.payroll_action_id   = appa3.payroll_action_id
					   AND    appa3.action_type        = 'X'
					   AND    appa3.action_status      = 'C'
					   AND    appa3.report_type        = 'KW_ARCHIVE')
			AND  NOT EXISTS (  SELECT /*+ ORDERED */ NULL
					   FROM   pay_action_interlocks      pai1,
						     pay_assignment_actions     act2,
						     pay_payroll_actions        appa3
					      WHERE  pai1.locked_action_id    = act.assignment_action_id
					      AND    act2.assignment_action_id= pai1.locking_action_id
					      AND    act2.payroll_action_id   = appa3.payroll_action_id
					      AND    appa3.action_type        = 'V'
					      AND    appa3.action_status      = 'C')
			ORDER BY act.assignment_id;




			l_count NUMBER := 0;
			l_prev_prepay		NUMBER := 0;
			l_business_group_id	NUMBER;
			l_start_date            VARCHAR2(20);
			l_end_date              VARCHAR2(20);
			l_canonical_start_date	DATE;
			l_canonical_end_date    DATE;
			l_effective_date	DATE;
			l_payroll_id		NUMBER;
			l_consolidation_set	NUMBER;
			l_prepay_action_id	NUMBER;
			l_actid			NUMBER;
			l_assignment_id NUMBER;
			l_action_sequence NUMBER;
			l_assact_id     NUMBER;
			l_pact_id NUMBER;
			l_flag NUMBER := 0;
			l_defined_balance_id NUMBER :=0;
			l_action_info_id NUMBER;
			l_ovn NUMBER;


			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
			END IF;

			     PAY_KW_ARCHIVE.GET_ALL_PARAMETERS(p_payroll_action_id
					,l_business_group_id
					,l_start_date
					,l_end_date
					,l_effective_date
					,l_payroll_id
					,l_consolidation_set);


			  l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
			  l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');

			  l_prepay_action_id := 0;

			  FOR rec_prepaid_assignments IN csr_prepaid_assignments(p_payroll_action_id
								,p_start_person
								,p_end_person
								,l_payroll_id
								,l_consolidation_set
								,l_canonical_start_date
								,l_canonical_end_date) LOOP

			    IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id THEN
				SELECT pay_assignment_actions_s.NEXTVAL
				INTO   l_actid
				FROM   dual;
				  --
				g_index_assact := g_index_assact + 1;
				g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */



			      -- Create the archive assignment action
				    hr_nonrun_asact.insact(l_actid
							  ,rec_prepaid_assignments.assignment_id
							  ,p_payroll_action_id
							  ,p_chunk
							  ,NULL);

				-- Create archive to prepayment assignment action interlock
				--
				hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);


			    END IF;
			    -- create archive to master assignment action interlock

			     hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
			     l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;

			END LOOP;





			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
			END IF;
			END ASSIGNMENT_ACTION_CODE;


			/* INITIALIZATION CODE */
			PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
			IS

			CURSOR csr_prepay_id IS
			SELECT distinct prepay_payact.payroll_action_id    prepay_payact_id
			      ,run_payact.date_earned date_earned
			FROM   pay_action_interlocks  archive_intlck
			      ,pay_assignment_actions prepay_assact
			      ,pay_payroll_actions    prepay_payact
			      ,pay_action_interlocks  prepay_intlck
			      ,pay_assignment_actions run_assact
			      ,pay_payroll_actions    run_payact
			      ,pay_assignment_actions archive_assact
			WHERE  archive_intlck.locking_action_id = archive_assact.assignment_action_id
			and    archive_assact.payroll_action_id = p_payroll_action_id
			AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
			AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
			AND    prepay_payact.action_type IN ('U','P')
			AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
			AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
			AND    run_payact.payroll_action_id = run_assact.payroll_action_id
			AND    run_payact.action_type IN ('Q', 'R')
			ORDER BY prepay_payact.payroll_action_id;

			/* Cursor to retrieve Run Assignment Action Ids */
			CURSOR csr_runact_id IS
			SELECT distinct prepay_payact.payroll_action_id    prepay_payact_id
			      ,run_payact.date_earned date_earned
			      ,run_payact.payroll_action_id run_payact_id
			FROM   pay_action_interlocks  archive_intlck
			      ,pay_assignment_actions prepay_assact
			      ,pay_payroll_actions    prepay_payact
			      ,pay_action_interlocks  prepay_intlck
			      ,pay_assignment_actions run_assact
			      ,pay_payroll_actions    run_payact
			      ,pay_assignment_actions archive_assact
			WHERE  archive_intlck.locking_action_id = archive_assact.assignment_action_id
			and    archive_assact.payroll_action_id = p_payroll_action_id
			AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
			AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
			AND    prepay_payact.action_type IN ('U','P')
			AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
			AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
			AND    run_payact.payroll_action_id = run_assact.payroll_action_id
			AND    run_payact.action_type IN ('Q', 'R')
			ORDER BY prepay_payact.payroll_action_id;

			rec_prepay_id csr_prepay_id%ROWTYPE;
			rec_runact_id csr_runact_id%ROWTYPE;

			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_count NUMBER := 0;
			l_business_group_id	NUMBER;
			l_start_date        VARCHAR2(20);
			l_end_date          VARCHAR2(20);
			l_effective_date	DATE;
			l_payroll_id		NUMBER;
			l_consolidation_set	NUMBER;
			l_prev_prepay		NUMBER := 0;


			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
			END IF;

			/*fnd_file.put_line(fnd_file.log,'In INIT_CODE 0');*/

			GET_ALL_PARAMETERS(p_payroll_action_id
							 ,l_business_group_id
							 ,l_start_date
							 ,l_end_date
							 ,l_effective_date
							 ,l_payroll_id
							 ,l_consolidation_set);

			g_arc_payroll_action_id := p_payroll_action_id;

			g_business_group_id := l_business_group_id;

			/* Archive Element Details */

			OPEN csr_prepay_id;
			LOOP
				FETCH csr_prepay_id INTO rec_prepay_id;
				EXIT WHEN csr_prepay_id%NOTFOUND;

			---------------------------------------------------------
			--Initialize Global tables once every prepayment payroll
			--action id and once every thread
			---------------------------------------------------------

			IF (rec_prepay_id.prepay_payact_id <> l_prev_prepay) THEN

				ARCHIVE_ADD_ELEMENT(p_archive_assact_id     => NULL,
						    p_assignment_action_id  => NULL,
						    p_assignment_id         => NULL,
						    p_payroll_action_id     => p_payroll_action_id,
						    p_date_earned           => rec_prepay_id.date_earned,
						    p_effective_date        => l_effective_date,
						    p_pre_payact_id         => rec_prepay_id.prepay_payact_id,
						    p_archive_flag          => 'N');


			END IF;

			l_prev_prepay := rec_prepay_id.prepay_payact_id;

			END LOOP;

			CLOSE csr_prepay_id;


			/* Initialize Global tables for Balances */
			ARCHIVE_OTH_BALANCE(p_archive_assact_id     => NULL,
					    p_assignment_action_id  => NULL,
					    p_assignment_id         => NULL,
					    p_payroll_action_id     => p_payroll_action_id,
					    p_record_count          => NULL,
					    p_pre_payact_id         => NULL, --rec_prepay_id.prepay_payact_id,
					    p_effective_date        => l_effective_date,
					    p_date_earned           => NULL,
					    p_archive_flag          => 'N');

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
			END IF;

			EXCEPTION WHEN OTHERS THEN
			g_err_num := SQLCODE;

			IF g_debug THEN
			     hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',180);
			END IF;

			END INITIALIZATION_CODE;

			PROCEDURE SETUP_ELEMENT_DEFINITIONS( p_classification_name IN VARCHAR2
							    ,p_element_name        IN VARCHAR2
							    ,p_element_type_id     IN NUMBER
							    ,p_element_type        IN VARCHAR2
							    ,p_input_value_id      IN NUMBER
							    ,p_input_value         IN VARCHAR2
							    ,p_uom                 IN VARCHAR2
							    ,p_archive_flag        IN VARCHAR2)
			IS

			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure SETUP_ELEMENT_DEFINITIONS',100);
			END IF;

			    g_index := g_index + 1;

			    /* Initialize global tables that hold Additional Element details */
			    g_element_table(g_index).classification_name := p_classification_name;
			    g_element_table(g_index).element_name        := p_element_name;
			    g_element_table(g_index).input_value         := p_input_value;
			    g_element_table(g_index).element_type_id     := p_element_type_id;
			    g_element_table(g_index).element_type        := p_element_type;
			    g_element_table(g_index).input_value_id      := p_input_value_id;
			    g_element_table(g_index).uom                 := p_uom;
			    g_element_table(g_index).archive_flag        := p_archive_flag;

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure SETUP_ELEMENT_DEFINITIONS',110);
			END IF;

			END SETUP_ELEMENT_DEFINITIONS;

			PROCEDURE SETUP_BALANCE_DEFINITIONS(p_balance_name         IN VARCHAR2
							   ,p_defined_balance_id   IN NUMBER
							   ,p_balance_type_id      IN NUMBER
							   ,p_uom                  IN VARCHAR2)

			IS
			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure SETUP_BALANCE_DEFINITIONS',120);
			END IF;

			    g_index_bal := g_index_bal + 1;
			    /* Initialize global tables that hold Other Balances details */
			    g_user_balance_table(g_index_bal).balance_name         := p_balance_name;
			    g_user_balance_table(g_index_bal).defined_balance_id   := p_defined_balance_id;
			    g_user_balance_table(g_index_bal).balance_type_id      := p_balance_type_id;
			    g_user_balance_table(g_index_bal).uom                  := p_uom;

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure SETUP_BALANCE_DEFINITIONS',130);
			END IF;

			END SETUP_BALANCE_DEFINITIONS;

			/* GET COUNTRY NAME FROM CODE */
			FUNCTION GET_COUNTRY_NAME(p_territory_code VARCHAR2)
			RETURN VARCHAR2
			IS

			CURSOR csr_get_territory_name(p_territory_code VARCHAR2) Is
			SELECT territory_short_name
			FROM   fnd_territories_vl
			WHERE  territory_code = p_territory_code;

			l_country fnd_territories_vl.territory_short_name%TYPE;
			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Function GET_COUNTRY_NAME',140);
			END IF;

			    OPEN csr_get_territory_name(p_territory_code);
				 FETCH csr_get_territory_name into l_country;
			    CLOSE csr_get_territory_name;

			    RETURN l_country;

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Function GET_COUNTRY_NAME',150);
			END IF;

			END GET_COUNTRY_NAME;

			/* EMPLOYEE DETAILS REGION */
			PROCEDURE ARCHIVE_EMPLOYEE_DETAILS (p_archive_assact_id        	IN NUMBER
							   ,p_assignment_id            	IN NUMBER
							   ,p_assignment_action_id      IN NUMBER
							   ,p_payroll_action_id         IN NUMBER
							   ,p_time_period_id            IN NUMBER
							   ,p_date_earned              	IN DATE
							   ,p_pay_date_earned           IN DATE
							   ,p_effective_date            IN DATE) IS

			/* Cursor to retrieve person details about Employee */
			CURSOR csr_person_details(p_assignment_id NUMBER) IS
			SELECT ppf.person_id person_id,
			       ppf.full_name full_name,
			       ppf.national_identifier civ_ident,
			       ppf.nationality nationality,
			       pps.date_start start_date,
			       ppf.employee_number emp_num,
			       ppf.first_name first_name,
			       ppf.last_name last_name,
			       ppf.per_information1 father_name,
			       ppf.per_information2 g_father_name,
			       ppf.per_information3 alt_first,
			       ppf.per_information4 alt_father,
			       ppf.per_information5 alt_gfather,
			       ppf.per_information6 alt_last,
			       ppf.title title,
			       paf.location_id loc_id,
			       paf.organization_id org_id,
			       paf.job_id job_id,
			       paf.position_id pos_id,
			       paf.grade_id grade_id,
			       ppg.group_name group_name,
			       paf.business_group_id bus_grp_id
			FROM   per_assignments_f paf,
			       per_all_people_f ppf,
			       per_periods_of_service pps,
			       pay_people_groups ppg
			WHERE  paf.person_id = ppf.person_id
			AND    paf.assignment_id = p_assignment_id
			AND    pps.person_id = ppf.person_id
			AND    paf.people_group_id = ppg.people_group_id(+)
			AND    p_date_earned BETWEEN paf.effective_start_date
						 AND paf.effective_end_date
			AND    p_date_earned BETWEEN ppf.effective_start_date
						 AND ppf.effective_end_date;


			/* Cursor to retrieve primary address of Employee */
			CURSOR csr_primary_address(p_person_id NUMBER) IS
			SELECT pa.person_id person_id,
			       pa.style style,
			       pa.address_type ad_type,
			       pa.country country,
			       pa.region_1 R1,
			       pa.region_2 R2,
			       pa.region_3 R3,
			       pa.town_or_city city,
			       pa.address_line1 AL1,
			       pa.address_line2 AL2,
			       pa.address_line3 AL3,
			       pa.postal_code postal_code
			FROM   per_addresses pa
			WHERE  pa.primary_flag = 'Y'
			AND    pa.person_id = p_person_id
			AND    p_effective_date BETWEEN pa.date_from
						    AND NVL(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'));

			/* Cursor to retrieve Employer's Address */
			CURSOR csr_employer_address(p_assignment_id NUMBER) IS
			SELECT  paa.person_id person_id
			       ,hscl.segment1 org_id
			       ,hla.style style
			       ,hla.country country
			       ,hla.region_1 R1
			       ,hla.region_2 R2
			       ,hla.region_3 R3
			       ,hla.town_or_city city
			       ,hla.address_line_1 AL1
			       ,hla.address_line_2 AL2
			       ,hla.address_line_3 AL3
			       ,hla.postal_code postal_code
			FROM    hr_locations_all hla
				,hr_organization_units hou
				,per_all_assignments_f paa
				,hr_soft_coding_keyflex hscl
			WHERE	hscl.segment1 = hou.organization_id
			AND     hscl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
			AND	hou.location_id = hla.location_id
			AND	paa.assignment_id = p_assignment_id
			AND	paa.business_group_id = hou.business_group_id
			AND     p_date_earned BETWEEN paa.effective_start_date
						  AND paa.effective_end_date;

			CURSOR csr_organization_address(p_organization_id NUMBER) IS
			SELECT hla.style style
			      ,hla.address_line_1 AL1
			      ,hla.address_line_2 AL2
			      ,hla.address_line_3 AL3
			      ,hla.town_or_city   city
			      ,hla.region_1       R1
			      ,hla.region_2       R2
			      ,hla.region_3       R3
			      ,hla.country        country
			      ,hla.postal_code    postal_code
			FROM   hr_locations_all hla,
			       hr_organization_units hoa
			WHERE  hla.location_id = hoa.location_id
			AND    hoa.organization_id = p_organization_id
			AND    p_effective_date BETWEEN hoa.date_from
						    AND NVL(hoa.date_to,to_date('31-12-4712','DD-MM-YYYY'));


			/* Cursor to retrieve top most organization in the hierarchy */
			CURSOR csr_top_org(p_org_structure_version_id NUMBER) IS
			SELECT DISTINCT pose.organization_id_parent
			FROM            per_org_structure_elements pose
			WHERE           pose.org_structure_version_id = p_org_structure_version_id
			AND             pose.organization_id_parent NOT IN (SELECT pose1.organization_id_child
									    FROM   per_org_structure_elements pose1
									    WHERE  pose1.org_structure_version_id = p_org_structure_version_id);

			/* Cursor to retrieve Business Group Id */
			CURSOR csr_bus_grp_id(p_organization_id NUMBER) IS
			SELECT business_group_id
			FROM   hr_organization_units
			WHERE  organization_id = p_organization_id;

			/* Cursor to retrieve Currency */
			CURSOR csr_currency(p_bg_id NUMBER) IS
			SELECT org_information10
			FROM   hr_organization_information
			WHERE  organization_id = p_bg_id
			AND    org_information_context = 'Business Group Information';

			/* Cursor to retrieve Organization Structure Version Id */
			CURSOR csr_org_structure(p_bg_id NUMBER) IS
			SELECT org_information1
			FROM   hr_organization_information
			WHERE  organization_id = p_bg_id
			AND    org_information_context = 'KW_HR_BG_INFO';

			/* Cursor to retrieve Grade of Employee */
			CURSOR csr_grade(p_grade_id NUMBER) IS
			SELECT pg.name
			FROM   per_grades pg
			WHERE  pg.grade_id = p_grade_id;

			/* Cursor to retrieve Position of Employee */
			CURSOR csr_position(p_position_id NUMBER) IS
			SELECT pap.name
			FROM   per_all_positions pap
			WHERE  pap.position_id = p_position_id;

			/* Cursor to pick up Payroll Location */
			CURSOR csr_pay_location(p_location_id NUMBER) IS
			SELECT location_code location
			FROM hr_locations_all
			WHERE location_id = p_location_id;

			/* Cursor to pick up Job */
			CURSOR csr_job(p_job_id NUMBER) IS
			SELECT name
			FROM per_jobs
			WHERE job_id = p_job_id;

			rec_person_details csr_person_details%ROWTYPE;
			rec_primary_address csr_primary_address%ROWTYPE;
			rec_employer_address csr_employer_address%ROWTYPE;
			rec_org_address csr_organization_address%ROWTYPE;
			l_nationality per_all_people_f.nationality%TYPE;
			l_position per_all_positions.name%TYPE;
			l_grade per_grades.name%TYPE;
			l_job   per_jobs.name%TYPE;
			l_currency hr_organization_information.org_information10%TYPE;
			l_organization hr_organization_units.name%TYPE;
			l_pay_location hr_locations_all.address_line_1%TYPE;
			l_city VARCHAR2(80);
			l_country VARCHAR2(80);
			l_emp_city VARCHAR2(80);
			l_emp_country VARCHAR2(80);
			l_org_city VARCHAR2(80);
			l_org_country VARCHAR2(80);
			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_person_id NUMBER;
			l_bg_id NUMBER;
			l_employer_name hr_organization_units.name%TYPE;
			l_org_struct_ver_id hr_organization_information.org_information1%TYPE;
			l_top_org_id  per_org_structure_elements.organization_id_parent%TYPE;
			l_cost_center pay_cost_allocations_v.concatenated_segments%TYPE;
			l_defined_balance_id NUMBER;
			l_balance_value NUMBER;
			l_defined_balance_id_ded NUMBER;
			l_balance_value_ded NUMBER;
			l_formatted_value VARCHAR2(50) := NULL;
			l_formatted_value_ded VARCHAR2(50) := NULL;
			l_org_exists NUMBER :=0;


			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure ARCHIVE_EMPLOYEE_DETAILS',160);
			END IF;
			/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS');*/

			       /* PERSON AND ADDRESS DETAILS */
			       OPEN csr_person_details(p_assignment_id);
				FETCH csr_person_details INTO rec_person_details;
			       CLOSE csr_person_details;

			       OPEN csr_primary_address(rec_person_details.person_id);
				FETCH csr_primary_address INTO rec_primary_address;
			       CLOSE csr_primary_address;

			       OPEN csr_employer_address(p_assignment_id);
				FETCH csr_employer_address INTO rec_employer_address;
			       CLOSE csr_employer_address;

			       OPEN csr_organization_address(rec_person_details.org_id);
				FETCH csr_organization_address INTO rec_org_address;
			       CLOSE csr_organization_address;

			 /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 2');*/

			       /* GRADE AND POSITION */
			       IF(rec_person_details.pos_id IS NOT NULL) THEN
				OPEN csr_position(rec_person_details.pos_id);
				    FETCH csr_position INTO l_position;
				CLOSE csr_position;
			       END IF;

			       IF(rec_person_details.grade_id IS NOT NULL) THEN
				OPEN csr_grade(rec_person_details.grade_id);
				    FETCH csr_grade INTO l_grade;
				CLOSE csr_grade;

			       END IF;

			       /* JOB */
			        IF(rec_person_details.job_id IS NOT NULL) THEN
				OPEN csr_job(rec_person_details.job_id);
				    FETCH csr_job INTO l_job;
				CLOSE csr_job;
			       END IF;

			  /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 3');*/
			       /* CURRENCY */
			       OPEN csr_bus_grp_id(rec_person_details.org_id);
				FETCH csr_bus_grp_id INTO l_bg_id;
			       CLOSE csr_bus_grp_id;

			       OPEN csr_currency(l_bg_id);
				FETCH csr_currency INTO l_currency;
			       CLOSE csr_currency;

			       g_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);

			       /*NATIONALITY*/
			       l_nationality := hr_general.decode_lookup('NATIONALITY',rec_person_details.nationality);

				/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 4');*/

				l_org_struct_ver_id := NULL;
				OPEN csr_org_structure(l_bg_id);
				 FETCH csr_org_structure INTO l_org_struct_ver_id;
				CLOSE csr_org_structure;

				l_top_org_id := NULL;
				OPEN csr_top_org(l_org_struct_ver_id);
				 FETCH csr_top_org INTO l_top_org_id;
				CLOSE csr_top_org;

			       IF(rec_person_details.loc_id IS NOT NULL) THEN
				l_pay_location := NULL;
				OPEN csr_pay_location(rec_person_details.loc_id);
				 FETCH csr_pay_location INTO l_pay_location;
				CLOSE csr_pay_location;

			       ELSE l_pay_location := NULL;
			       END IF;


			       IF(rec_person_details.org_id IS NOT NULL) THEN
					SELECT name INTO l_organization
					FROM hr_organization_units
					WHERE organization_id = rec_person_details.org_id;
				ELSE l_organization := NULL;
			       END IF;


			       IF(rec_employer_address.org_id IS NOT NULL) THEN
					SELECT name INTO l_employer_name
					FROM hr_organization_units
					WHERE organization_id = rec_employer_address.org_id;
				ELSE l_employer_name := NULL;
			       END IF;

			       /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 5');*/

				/* COUNTRY */
				l_country:=PAY_KW_ARCHIVE.get_country_name(rec_primary_address.country);

				l_emp_country:=PAY_KW_ARCHIVE.get_country_name(rec_employer_address.country);

				l_org_country:=PAY_KW_ARCHIVE.get_country_name(rec_org_address.country);

				/* Total Earnings YTD */
				l_defined_balance_id := PAY_KW_ARCHIVE.GET_DEFINED_BALANCE_ID('TOTAL_EARNINGS_ASG_YTD');
				l_balance_value := pay_balance_pkg.get_value(l_defined_balance_id, p_assignment_action_id);

				l_formatted_value := to_char(l_balance_value, g_format_mask);

				/* Total Deductions YTD */
				l_defined_balance_id_ded := PAY_KW_ARCHIVE.GET_DEFINED_BALANCE_ID('TOTAL_DEDUCTIONS_ASG_YTD');
				l_balance_value_ded := pay_balance_pkg.get_value(l_defined_balance_id_ded, p_assignment_action_id);

				l_formatted_value_ded := to_char(l_balance_value_ded, g_format_mask);

				/* INSERT PERSON DETAILS */
				pay_action_information_api.create_action_information (
					  p_action_information_id        => l_action_info_id
					 ,p_action_context_id            => p_archive_assact_id
					 ,p_action_context_type          => 'AAP'
					 ,p_object_version_number        => l_ovn
					 ,p_effective_date               => p_effective_date
					 ,p_source_id                    => NULL
					 ,p_source_text                  => NULL
					 ,p_action_information_category  => 'EMPLOYEE DETAILS'
					 ,p_action_information1          => rec_person_details.full_name
					 ,p_action_information2          => rec_person_details.org_id
					 ,p_action_information4          => rec_person_details.civ_ident
					 ,p_action_information7          => l_grade
					 ,p_action_information8          => l_employer_name
					 ,p_action_information9          => l_nationality
					 ,p_action_information10         => rec_person_details.emp_num
					 ,p_action_information12         => fnd_date.date_to_canonical(rec_person_details.start_date)
					 ,p_action_information15         => l_organization
					 ,p_action_information16         => p_time_period_id
					 ,p_action_information17         => l_job
					 ,p_action_information19         => l_position
					 ,p_action_information30         => l_pay_location
					 ,p_assignment_id                => p_assignment_id);


				 /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 7');*/
				 /* ADDITIONAL EMPLOYEE DETAILS */
				 pay_action_information_api.create_action_information (
					  p_action_information_id        => l_action_info_id
					 ,p_action_context_id            => p_archive_assact_id
					 ,p_action_context_type          => 'AAP'
					 ,p_object_version_number        => l_ovn
					 ,p_effective_date               => p_effective_date
					 ,p_source_id                    => NULL
					 ,p_source_text                  => NULL
					 ,p_action_information_category  => 'ADDL EMPLOYEE DETAILS'
					 ,p_action_information4          => l_formatted_value_ded -- for payroll register*/
					 ,p_action_information5          => rec_person_details.group_name
					 ,p_action_information6          => rec_person_details.alt_first
					 ,p_action_information7          => rec_person_details.alt_father
					 ,p_action_information8          => rec_person_details.alt_gfather
					 ,p_action_information9          => rec_person_details.alt_last
					 ,p_action_information10         => rec_person_details.first_name    -- for payroll register
					 ,p_action_information11         => rec_person_details.last_name     -- for payroll register
					 ,p_action_information12         => rec_person_details.father_name   -- for payroll register
					 ,p_action_information13         => l_formatted_value  -- for payroll register
					 ,p_action_information14         => l_employer_name
					 ,p_assignment_id                => p_assignment_id);

				/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 8');*/

				/* INSERT ADDRESS DETAILS */
			       IF rec_primary_address.AL1 IS NOT NULL THEN   /* CHECK IF EMPLOYEE HAS BEEN GIVEN A PRIMARY ADDRESS */
			       pay_action_information_api.create_action_information (
					  p_action_information_id        => l_action_info_id
					 ,p_action_context_id            => p_archive_assact_id
					 ,p_action_context_type          => 'AAP'
					 ,p_object_version_number        => l_ovn
					 ,p_effective_date               => p_effective_date
					 ,p_source_id                    => NULL
					 ,p_source_text                  => NULL
					 ,p_action_information_category  => 'ADDRESS DETAILS'
					 ,p_action_information1          => rec_primary_address.person_id
					 ,p_action_information5          => rec_primary_address.AL1
					 ,p_action_information6          => rec_primary_address.AL2
					 ,p_action_information7          => NULL
					 ,p_action_information8          => NULL
					 ,p_action_information9          => rec_primary_address.R1
					 ,p_action_information10         => rec_primary_address.R2
					 ,p_action_information11         => rec_primary_address.R3
					 ,p_action_information12         => rec_primary_address.postal_code
					 ,p_action_information13         => l_country
					 ,p_action_information14         => 'Employee Address'
					 ,p_assignment_id                => p_assignment_id);
			       ELSE
			       /* INSERT EMPLOYER ADDRESS AS EMPLOYEE'S PRIMARY ADDRESS */
			       pay_action_information_api.create_action_information (
					  p_action_information_id        => l_action_info_id
					 ,p_action_context_id            => p_archive_assact_id
					 ,p_action_context_type          => 'AAP'
					 ,p_object_version_number        => l_ovn
					 ,p_effective_date               => p_effective_date
					 ,p_source_id                    => NULL
					 ,p_source_text                  => NULL
					 ,p_action_information_category  => 'ADDRESS DETAILS'
					 ,p_action_information1          => rec_employer_address.person_id
					 ,p_action_information5          => NULL --rec_employer_address.AL1
					 ,p_action_information6          => NULL --rec_employer_address.AL2
					 ,p_action_information7          => NULL --rec_employer_address.AL3
					 ,p_action_information8          => NULL --l_emp_city
					 ,p_action_information9          => NULL --rec_employer_address.R1
					 ,p_action_information10         => NULL --rec_employer_address.R2
					 ,p_action_information11         => NULL --rec_employer_address.R3
					 ,p_action_information12         => NULL --rec_employer_address.postal_code
					 ,p_action_information13         => NULL --l_emp_country
					 ,p_action_information14         => 'Employee Address'
					 ,p_assignment_id                => p_assignment_id);
			       END IF;

			       /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 9');*/
			       /* INSERT EMPLOYER'S ADDRESS (ORGANIZATION ADDRESS)*/


			      BEGIN
			      l_org_exists := 0;
			       SELECT 1
			       INTO l_org_exists
			       FROM   pay_action_information
			       WHERE  action_context_id = p_payroll_action_id
			       AND    action_information1 = rec_person_details.org_id
			       AND    effective_date      = p_effective_date
			       AND    action_information_category = 'ADDRESS DETAILS';

			      EXCEPTION
				WHEN NO_DATA_FOUND THEN
				pay_action_information_api.create_action_information (
							  p_action_information_id        => l_action_info_id
							 ,p_action_context_id            => p_payroll_action_id
							 ,p_action_context_type          => 'PA'
							 ,p_object_version_number        => l_ovn
							 ,p_effective_date               => p_effective_date
							 ,p_source_id                    => NULL
							 ,p_source_text                  => NULL
							 ,p_action_information_category  => 'ADDRESS DETAILS'
							 ,p_action_information1          => rec_person_details.org_id
							 ,p_action_information5          => rec_org_address.AL1
							 ,p_action_information6          => rec_org_address.AL2
							 ,p_action_information7          => rec_org_address.AL3
							 ,p_action_information8          => NULL
							 ,p_action_information9          => rec_org_address.R1
							 ,p_action_information10         => rec_org_address.R2
							 ,p_action_information11         => rec_org_address.R3
							 ,p_action_information12         => rec_org_address.postal_code
							 ,p_action_information13         => l_org_country
							 ,p_action_information14         => 'Employer Address');

				WHEN OTHERS THEN
					NULL;
				END;




				/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 10');*/
			--

			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure ARCHIVE_EMPLOYEE_DETAILS',170);
			END IF;
			--
			    EXCEPTION WHEN OTHERS THEN
			    g_err_num := SQLCODE;

				/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_EMPLOYEE_DETAILS');*/
				IF g_debug THEN
				     hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_EMPLOYEE_DETAILS',180);
				END IF;

			END ARCHIVE_EMPLOYEE_DETAILS;

			/* EARNINGS REGION, DEDUCTIONS REGION */
			PROCEDURE ARCHIVE_ELEMENT_INFO(p_payroll_action_id IN NUMBER
						      ,p_effective_date    IN DATE
						      ,p_date_earned       IN DATE
						      ,p_pre_payact_id     IN NUMBER)
			IS

			/* Cursor to retrieve Earnings Element Information */
			CURSOR csr_ear_element_info IS
			SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
			      ,et.element_type_id element_type_id
			      ,iv.input_value_id input_value_id
			      ,iv.uom uom
			FROM   pay_element_types_f         et
			,      pay_element_types_f_tl      pettl
			,      pay_input_values_f          iv
			,      pay_element_classifications classification
			WHERE  et.element_type_id              = iv.element_type_id
			AND    et.element_type_id              = pettl.element_type_id
			AND    pettl.language                  = USERENV('LANG')
			AND    iv.name                         = 'Pay Value'
			AND    classification.classification_id   = et.classification_id
			AND    classification.classification_name       IN ('Earnings'
									   ,'Direct Payment'
									   ,'Absence')
			AND    p_date_earned       BETWEEN et.effective_start_date
						       AND et.effective_end_date
			AND    p_date_earned       BETWEEN iv.effective_start_date
						       AND iv.effective_end_date
			AND ((et.business_group_id IS NULL AND et.legislation_code = 'KW')
			OR  (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL));


			/* Cursor to retrieve Deduction Element Information */
			CURSOR csr_ded_element_info IS
			SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
			      ,et.element_type_id element_type_id
			      ,iv.input_value_id input_value_id
			      ,iv.uom uom
			FROM   pay_element_types_f         et
			,      pay_element_types_f_tl      pettl
			,      pay_input_values_f          iv
			,      pay_element_classifications classification
			WHERE  et.element_type_id              = iv.element_type_id
			AND    et.element_type_id              = pettl.element_type_id
			AND    pettl.language                  = USERENV('LANG')
			AND    iv.name                         = 'Pay Value'
			AND    classification.classification_id   = et.classification_id
			AND    classification.classification_name IN ('Involuntary Deductions'
								     ,'Pre Social Insurance Deductions'
								     ,'Voluntary Deductions'
								     ,'Social Insurance')
			AND    p_date_earned       BETWEEN et.effective_start_date
						       AND et.effective_end_date
			AND    p_date_earned       BETWEEN iv.effective_start_date
						       AND iv.effective_end_date
			AND ((et.business_group_id IS NULL AND et.legislation_code = 'KW')
			OR  (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL));

			l_action_info_id NUMBER;
			l_ovn            NUMBER;
			l_flag		 NUMBER := 0;

			BEGIN

			IF g_debug THEN
			     hr_utility.set_location(' Entering Procedure ARCHIVE_ELEMENT_INFO',210);
			END IF;

			    /* EARNINGS ELEMENT */

			 FOR rec_earnings IN csr_ear_element_info LOOP

			 BEGIN

			 SELECT 1 INTO l_flag
			 FROM   pay_action_information
			 WHERE  action_context_id = p_payroll_action_id
			 AND    action_information_category = 'EMEA ELEMENT DEFINITION'
			 AND    action_information2 = rec_earnings.element_type_id
			 AND    action_information3 = rec_earnings.input_value_id
			 AND    action_information5 = 'E';

			 EXCEPTION WHEN NO_DATA_FOUND THEN


			     pay_action_information_api.create_action_information (
						  p_action_information_id        => l_action_info_id
						 ,p_action_context_id            => p_payroll_action_id
						 ,p_action_context_type          => 'PA'
						 ,p_object_version_number        => l_ovn
						 ,p_effective_date               => p_effective_date
						 ,p_source_id                    => NULL
						 ,p_source_text                  => NULL
						 ,p_action_information_category  => 'EMEA ELEMENT DEFINITION'
						 ,p_action_information1          => p_pre_payact_id
						 ,p_action_information2          => rec_earnings.element_type_id
						 ,p_action_information3          => rec_earnings.input_value_id
						 ,p_action_information4          => rec_earnings.rep_name
						 ,p_action_information5          => 'E'
						 ,p_action_information6          => rec_earnings.uom
						 ,p_action_information7          => 'E');  --Earnings Element Context

			 WHEN OTHERS THEN
				NULL;

			 END;
			 END LOOP;

			    /* DEDUCTION ELEMENT */

			FOR rec_deduction IN csr_ded_element_info LOOP

			BEGIN

			SELECT 1 INTO l_flag
			FROM   pay_action_information
			WHERE  action_context_id = p_payroll_action_id
			AND    action_information_category = 'EMEA ELEMENT DEFINITION'
			AND    action_information2 = rec_deduction.element_type_id
			AND    action_information3 = rec_deduction.input_value_id
			AND    action_information5 = 'D';

			EXCEPTION WHEN NO_DATA_FOUND THEN
			     pay_action_information_api.create_action_information (
						  p_action_information_id        => l_action_info_id
						 ,p_action_context_id            => p_payroll_action_id
						 ,p_action_context_type          => 'PA'
						 ,p_object_version_number        => l_ovn
						 ,p_effective_date               => p_effective_date
						 ,p_source_id                    => NULL
						 ,p_source_text                  => NULL
						 ,p_action_information_category  => 'EMEA ELEMENT DEFINITION'
						 ,p_action_information1          => p_pre_payact_id
						 ,p_action_information2          => rec_deduction.element_type_id
						 ,p_action_information3          => rec_deduction.input_value_id
						 ,p_action_information4          => rec_deduction.rep_name
						 ,p_action_information5          => 'D'
						 ,p_action_information6          => rec_deduction.uom
						 ,p_action_information7          => 'D');   --Deduction Element Context
			 /*WHEN OTHERS THEN
				NULL;*/
			 END;
			 END LOOP;


			IF g_debug THEN
			     hr_utility.set_location(' Leaving Procedure ARCHIVE_ELEMENT_INFO',220);
			END IF;

			   EXCEPTION WHEN OTHERS THEN
			    g_err_num := SQLCODE;

			    /*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_ELEMENT_INFO');*/
			    IF g_debug THEN
				 hr_utility.set_location('ORA_ERR: ' || g_err_num || 'ARCHIVE_ELEMENT_INFO',230);
			    END IF;


			END ARCHIVE_ELEMENT_INFO;

			/* GET DEFINED BALANCE ID */
			FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2) RETURN NUMBER
			IS
			/* Cursor to retrieve Defined Balance Id */
			CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
			SELECT  u.creator_id
			FROM    ff_user_entities  u,
				ff_database_items d
			WHERE   d.user_name = p_user_name
			AND     u.user_entity_id = d.user_entity_id
			AND     (u.legislation_code = 'KW' )
			AND     (u.business_group_id IS NULL )
			AND     u.creator_type = 'B';

			l_defined_balance_id ff_user_entities.user_entity_id%TYPE;

			BEGIN
			IF g_debug THEN
				hr_utility.set_location(' Entering Function GET_DEFINED_BALANCE_ID',240);
			END IF;

			    OPEN csr_def_bal_id(p_user_name);
				FETCH csr_def_bal_id INTO l_defined_balance_id;
			    CLOSE csr_def_bal_id;
			    RETURN l_defined_balance_id;

			IF g_debug THEN
				hr_utility.set_location(' Leaving Function GET_DEFINED_BALANCE_ID',250);
			END IF;

			END GET_DEFINED_BALANCE_ID;

			/* PAYMENT INFORMATION REGION */
			PROCEDURE ARCHIVE_PAYMENT_INFO(p_archive_assact_id IN NUMBER,
						       p_prepay_assact_id  IN NUMBER,
						       p_assignment_id     IN NUMBER,
						       p_date_earned       IN DATE,
						       p_effective_date    IN DATE)
			IS

			/* Cursor to fetch ppm and opm ids to check which payment method to archive */
			CURSOR csr_chk(p_prepay_assact_id NUMBER) IS
			SELECT personal_payment_method_id ppm_id,
			       org_payment_method_id opm_id
			FROM   pay_pre_payments
			WHERE  assignment_action_id = p_prepay_assact_id;

			/* Cursor to check if bank details are attached with ppm */
			CURSOR csr_chk_bank(p_ppm_id NUMBER) IS
			SELECT ppm.external_account_id
			FROM   pay_personal_payment_methods_f ppm
			WHERE  ppm.personal_payment_method_id = p_ppm_id
			AND    p_date_earned BETWEEN ppm.effective_start_date
						 AND ppm.effective_end_date;

			/* Cursor to fetch id flex num for kw_bank_details */
			CURSOR csr_get_flexnum IS
			SELECT id_flex_num
			FROM FND_ID_FLEX_STRUCTURES_VL
			WHERE (ID_FLEX_STRUCTURE_CODE = 'KW_BANK_DETAILS')
			and (APPLICATION_ID=801)
			and (ID_FLEX_CODE='BANK');

			/* Cursor to retrieve Organization Payment Method Information */
			CURSOR csr_get_org_pay(p_prepay_assact_id NUMBER, opm_id NUMBER) IS
			SELECT pop.org_payment_method_id opm_id,
			       pop.org_payment_method_name,
			       ppttl.payment_type_name pay_type,
			       ppp.value value
			FROM   pay_org_payment_methods_f pop,
			       pay_assignment_actions paa,
			       pay_payment_types ppt,
			       pay_payment_types_tl ppttl,
			       pay_pre_payments ppp
			WHERE  paa.assignment_action_id = p_prepay_assact_id
			AND    ppt.payment_type_id = pop.payment_type_id
			AND    ppt.payment_type_id = ppttl.payment_type_id
			AND    ppttl.language      = userenv('LANG')
			AND    ppp.org_payment_method_id = pop.org_payment_method_id
			AND    pop.org_payment_method_id = opm_id
			AND    ppp.assignment_action_id = paa.assignment_action_id
			AND    p_date_earned BETWEEN pop.effective_start_date
						 AND pop.effective_end_date;

			/* Cursor to retrieve Personal Payment Method Info*/
			CURSOR csr_get_pers_pay(p_prepay_assact_id NUMBER, ppm_id NUMBER, p_flex_num NUMBER) IS
			SELECT pea.segment1 name_id,
			       pea.segment2 branch,
			       pea.segment3 account_number, /* for Bug No:6603767 */
			       pea.segment4 acct_num,
			       ppm.org_payment_method_id opm_id,
			       pop.external_account_id,
			       pop.org_payment_method_name,
			       ppm.personal_payment_method_id ppm_id,
			       ppttl.payment_type_name pay_type,
			       ppp.value value
			FROM   pay_external_accounts pea,
			       pay_org_payment_methods_f pop,
			       pay_personal_payment_methods_f ppm,
			       pay_assignment_actions paa,
			       pay_payment_types ppt,
			       pay_payment_types_tl ppttl,
			       pay_pre_payments ppp
			WHERE  pea.id_flex_num=p_flex_num
			AND    pea.external_account_id = NVL(ppm.external_account_id,pop.external_account_id)
			AND    paa.assignment_action_id = p_prepay_assact_id
			AND    paa.assignment_id = ppm.assignment_id
			AND    ppm.org_payment_method_id = pop.org_payment_method_id
			AND    ppm.personal_payment_method_id = ppm_id
			AND    ppt.payment_type_id = pop.payment_type_id
			AND    ppt.payment_type_id = ppttl.payment_type_id
			AND    ppttl.language      = userenv('LANG')
			AND    ppp.assignment_action_id = paa.assignment_action_id
			AND    ppp.personal_payment_method_id = ppm.personal_payment_method_id
			AND    p_date_earned BETWEEN pop.effective_start_date
						 AND pop.effective_end_date
			AND    p_date_earned BETWEEN ppm.effective_start_date
						 AND ppm.effective_end_date;


			l_bank_name VARCHAR2(50);
			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_org NUMBER;
			l_pers VARCHAR2(40) := NULL;
			l_ext_acct NUMBER;
			rec_chk csr_chk%ROWTYPE;
			l_pay_value VARCHAR2(50) := NULL;
			l_id_flex_num NUMBER;

			BEGIN

			IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_PAYMENT_INFO',260);
			END IF;
			fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 1');


			OPEN csr_chk(p_prepay_assact_id);
			LOOP
			FETCH csr_chk INTO rec_chk;
			EXIT WHEN csr_chk%NOTFOUND;


				IF rec_chk.ppm_id IS NOT NULL THEN

				OPEN csr_get_flexnum;
				  FETCH csr_get_flexnum INTO l_id_flex_num;
				CLOSE csr_get_flexnum;

				FOR rec_pers_pay IN csr_get_pers_pay(p_prepay_assact_id,rec_chk.ppm_id,l_id_flex_num) LOOP


				OPEN csr_chk_bank(rec_chk.ppm_id);
				  FETCH csr_chk_bank INTO l_ext_acct;
				CLOSE csr_chk_bank;

				l_pay_value := to_char (rec_pers_pay.value,g_format_mask);

				IF (l_ext_acct IS NOT NULL) THEN
				/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 2');*/

				l_bank_name := hr_general.decode_lookup('KW_BANKS',rec_pers_pay.name_id);

				pay_action_information_api.create_action_information (
					  p_action_information_id        => l_action_info_id
					 ,p_action_context_id            => p_archive_assact_id
					 ,p_action_context_type          => 'AAP'
					 ,p_object_version_number        => l_ovn
					 ,p_effective_date               => p_effective_date
					 ,p_source_id                    => NULL
					 ,p_source_text                  => NULL
					 ,p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION'
					 ,p_action_information1          => NULL
					 ,p_action_information2          => rec_pers_pay.ppm_id
					 ,p_action_information5          => l_bank_name
					 ,p_action_information6          => rec_pers_pay.branch
	/* for Bug No:6603767*/		 ,p_action_information7          => rec_pers_pay.account_number
					 ,p_action_information8          => rec_pers_pay.acct_num
					 ,p_action_information9          => NULL
					 ,p_action_information10         => NULL
					 ,p_action_information11         => NULL
					 ,p_action_information12         => NULL
					 ,p_action_information13         => NULL
					 ,p_action_information14         => NULL
					 ,p_action_information15         => NULL
					 ,p_action_information16         => fnd_number.number_to_canonical(rec_pers_pay.value) --l_pay_value
					 ,p_action_information17         => NULL
					 ,p_action_information18         => rec_pers_pay.pay_type
					 ,p_assignment_id                => p_assignment_id);

				ELSE

				/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 3');*/
				   pay_action_information_api.create_action_information (
					  p_action_information_id        => l_action_info_id
					 ,p_action_context_id            => p_archive_assact_id
					 ,p_action_context_type          => 'AAP'
					 ,p_object_version_number        => l_ovn
					 ,p_effective_date               => p_effective_date
					 ,p_source_id                    => NULL
					 ,p_source_text                  => NULL
					 ,p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION'
					 ,p_action_information1          => rec_pers_pay.opm_id
					 ,p_action_information2          => rec_pers_pay.ppm_id
					 ,p_action_information5          => NULL
					 ,p_action_information6          => NULL
					 ,p_action_information7          => NULL
					 ,p_action_information8          => NULL
					 ,p_action_information9          => NULL
					 ,p_action_information10         => NULL
					 ,p_action_information11         => NULL
					 ,p_action_information12         => NULL
					 ,p_action_information13         => NULL
					 ,p_action_information14         => NULL
					 ,p_action_information15         => NULL
					 ,p_action_information16         => fnd_number.number_to_canonical(rec_pers_pay.value) --l_pay_value
					 ,p_action_information17         => NULL
					 ,p_action_information18         => rec_pers_pay.pay_type
					 ,p_assignment_id                => p_assignment_id);

				END IF;

				END LOOP;
					/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 4');*/


			END IF;

			IF (rec_chk.opm_id IS NOT NULL AND rec_chk.ppm_id IS NULL) THEN

			/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 5');*/

				FOR rec_org_pay IN csr_get_org_pay(p_prepay_assact_id,rec_chk.opm_id) LOOP

				l_pay_value := to_char (rec_org_pay.value,g_format_mask);

					   pay_action_information_api.create_action_information (
						  p_action_information_id        => l_action_info_id
						 ,p_action_context_id            => p_archive_assact_id
						 ,p_action_context_type          => 'AAP'
						 ,p_object_version_number        => l_ovn
						 ,p_effective_date               => p_effective_date
						 ,p_source_id                    => NULL
						 ,p_source_text                  => NULL
						 ,p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION'
						 ,p_action_information1          => rec_org_pay.opm_id
						 ,p_action_information2          => NULL
						 ,p_action_information5          => NULL
						 ,p_action_information6          => NULL
						 ,p_action_information7          => NULL
						 ,p_action_information8          => NULL
						 ,p_action_information9          => NULL
						 ,p_action_information10         => NULL
						 ,p_action_information11         => NULL
						 ,p_action_information12         => NULL
						 ,p_action_information13         => NULL
						 ,p_action_information14         => NULL
						 ,p_action_information15         => NULL
						 ,p_action_information16         => fnd_number.number_to_canonical(rec_org_pay.value) --l_pay_value
						 ,p_action_information17         => NULL
						 ,p_action_information18         => rec_org_pay.pay_type
						 ,p_assignment_id                => p_assignment_id);

				END LOOP;
			END IF;

			END LOOP;
			CLOSE csr_chk;

			IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure ARCHIVE_PAYMENT_INFO',270);
			END IF;

			    EXCEPTION WHEN OTHERS THEN
			       g_err_num := SQLCODE;
				/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_PAYMENT_INFO');*/
				IF g_debug THEN
					hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_PAYMENT_INFO',280);
				END IF;

			END ARCHIVE_PAYMENT_INFO;


			/* ADDITIONAL ELEMENTS REGION */
			PROCEDURE ARCHIVE_ADD_ELEMENT(p_archive_assact_id     IN NUMBER,
						      p_assignment_action_id  IN NUMBER,
						      p_assignment_id         IN NUMBER,
						      p_payroll_action_id     IN NUMBER,
						      p_date_earned           IN DATE,
						      p_effective_date        IN DATE,
						      p_pre_payact_id         IN NUMBER,
						      p_archive_flag          IN VARCHAR2) IS

			/* Cursor to retrieve Additional Element Information */
			CURSOR csr_get_element(p_bus_grp_id NUMBER) IS
			SELECT hoi.org_information1 element_type_id
			      ,hoi.org_information2 input_value_id
			      ,hoi.org_information3 element_narrative
			      ,pec.classification_name
			      ,piv.uom
			      ,piv.name input_value
			FROM   hr_organization_information hoi
			      ,pay_element_classifications pec
			      ,pay_element_types_f  pet
			      ,pay_input_values_f piv
			WHERE  hoi.organization_id = p_bus_grp_id
			AND    hoi.org_information_context = 'KW_PAYSLIP_ELEMENTS'
			AND    hoi.org_information1 = pet.element_type_id
			AND    pec.classification_id = pet.classification_id
			AND    piv.input_value_id = hoi.org_information2
			AND    p_date_earned BETWEEN piv.effective_start_date
						 AND piv.effective_end_date;

			/* Cursor to retrieve run result value of Additional Elements */
			CURSOR csr_result_value(p_iv_id NUMBER
					       ,p_ele_type_id NUMBER
					       ,p_assignment_action_id NUMBER) IS
			SELECT rrv.result_value
			FROM   pay_run_result_values rrv
			      ,pay_run_results rr
			      ,pay_assignment_actions paa
			      ,pay_payroll_actions ppa
			WHERE  rrv.input_value_id = p_iv_id
			AND    rr.element_type_id = p_ele_type_id
			AND    rr.run_result_id = rrv.run_result_id
			AND    rr.assignment_action_id = paa.assignment_action_id
			AND    paa.assignment_action_id = p_assignment_action_id
			AND    ppa.payroll_action_id = paa.payroll_action_id
			AND    ppa.action_type IN ('Q','R')
			AND    rrv.result_value IS NOT NULL;

			rec_get_element csr_get_element%ROWTYPE;
			l_result_value pay_run_result_values.result_value%TYPE := 0;
			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_element_context VARCHAR2(10);
			l_index NUMBER := 0;
			l_formatted_value VARCHAR2(50) := NULL;
			l_flag  NUMBER := 0;

			BEGIN

			IF g_debug THEN
					hr_utility.set_location(' Entering Procedure ARCHIVE_ADD_ELEMENT',320);
			END IF;


			IF p_archive_flag = 'N' THEN

			---------------------------------------------------
			--Check if global table has already been populated
			---------------------------------------------------
			    IF g_element_table.count = 0 THEN

			    OPEN csr_get_element(g_business_group_id);

			    LOOP
			    FETCH csr_get_element INTO rec_get_element;
			    EXIT WHEN csr_get_element%NOTFOUND;

			    l_element_context := 'F'; --Additional Element Context

				SETUP_ELEMENT_DEFINITIONS(p_classification_name => rec_get_element.classification_name
							 ,p_element_name        => rec_get_element.element_narrative
							 ,p_element_type_id     => rec_get_element.element_type_id
							 ,p_element_type        => l_element_context
							 ,p_input_value_id      => rec_get_element.input_value_id
							 ,p_input_value         => rec_get_element.input_value
							 ,p_uom                 => rec_get_element.uom
							 ,p_archive_flag        => p_archive_flag);

			     END LOOP;
			     CLOSE csr_get_element;
			     END IF;


			  ELSIF p_archive_flag = 'Y' AND g_element_table.count > 0 THEN

			  FOR l_index IN g_element_table.first.. g_element_table.last LOOP
			  l_result_value := NULL;

			  BEGIN

                            OPEN csr_result_value(g_element_table(l_index).input_value_id
						 ,g_element_table(l_index).element_type_id
						 ,p_assignment_action_id);
                            LOOP
                              FETCH csr_result_value INTO l_result_value;
                              EXIT WHEN csr_result_value%NOTFOUND;
                              IF  l_result_value is not null THEN
                                pay_action_information_api.create_action_information (
                                                  p_action_information_id        => l_action_info_id
                                                 ,p_action_context_id            => p_archive_assact_id
                                                 ,p_action_context_type          => 'AAP'
                                                 ,p_object_version_number        => l_ovn
                                                 ,p_effective_date               => p_effective_date
                                                 ,p_source_id                    => NULL
                                                 ,p_source_text                  => NULL
                                                 ,p_action_information_category  => 'EMEA ELEMENT INFO'
                                                 ,p_action_information1          => g_element_table(l_index).element_type_id
                                                 ,p_action_information2          => g_element_table(l_index).input_value_id
                                                 ,p_action_information3          => g_element_table(l_index).element_type
                                                 ,p_action_information4          => l_result_value --l_formatted_value
                                                 ,p_action_information9          => g_element_table(l_index).input_value
                                                 ,p_assignment_id                => p_assignment_id);
                              END IF;
			    END LOOP;
                            CLOSE csr_result_value;

			    /*IF  l_result_value is not null THEN

				pay_action_information_api.create_action_information (
						  p_action_information_id        => l_action_info_id
						 ,p_action_context_id            => p_archive_assact_id
						 ,p_action_context_type          => 'AAP'
						 ,p_object_version_number        => l_ovn
						 ,p_effective_date               => p_effective_date
						 ,p_source_id                    => NULL
						 ,p_source_text                  => NULL
						 ,p_action_information_category  => 'EMEA ELEMENT INFO'
						 ,p_action_information1          => g_element_table(l_index).element_type_id
						 ,p_action_information2          => g_element_table(l_index).input_value_id
						 ,p_action_information3          => g_element_table(l_index).element_type
						 ,p_action_information4          => l_result_value --l_formatted_value
						 ,p_action_information9          => g_element_table(l_index).input_value
						 ,p_assignment_id                => p_assignment_id);
			    END IF;*/


			    EXCEPTION WHEN OTHERS THEN
			       g_err_num := SQLCODE;
			       /*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_ADD_ELEMENT');*/
				IF g_debug THEN
					hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_ADD_ELEMENT',330);
				END IF;

			      END;

			    END LOOP;

			    END IF;

			IF g_debug THEN
					hr_utility.set_location(' Leaving Procedure ARCHIVE_ADD_ELEMENT',340);
			END IF;

			END ARCHIVE_ADD_ELEMENT;

			/* OTHER BALANCES REGION */
			PROCEDURE ARCHIVE_OTH_BALANCE (p_archive_assact_id     IN NUMBER,
						       p_assignment_action_id  IN NUMBER,
						       p_assignment_id         IN NUMBER,
						       p_payroll_action_id     IN NUMBER,
						       p_record_count          IN NUMBER,
						       p_pre_payact_id         IN NUMBER,
						       p_effective_date        IN DATE,
						       p_date_earned           IN DATE,
						       p_archive_flag          IN VARCHAR2) IS

			/* Cursor to retrieve Other Balances Information */
			CURSOR csr_get_balance(p_bus_grp_id NUMBER) IS
			SELECT org_information1 balance_type_id
			      ,org_information2 balance_dim_id
			      ,org_information3 narrative
			FROM   hr_organization_information
			WHERE  organization_id = p_bus_grp_id
			AND    org_information_context = 'KW_PAYSLIP_BALANCES';

			/* Cursor to retrieve Tax Unit Id for setting context */
			CURSOR csr_tax_unit (p_run_assact_id NUMBER) IS
			SELECT paa.tax_unit_id
			FROM   pay_assignment_actions paa
			WHERE  paa.assignment_action_id = p_run_assact_id;

			/* Cursor to fetch defined balance id */
			CURSOR csr_def_balance(bal_type_id NUMBER, bal_dim_id NUMBER) IS
			SELECT defined_balance_id
			FROM   pay_defined_balances
			WHERE  balance_type_id = bal_type_id
			AND    balance_dimension_id = bal_dim_id;

			/* Cursor to fetch Unit of Measure */
			CURSOR csr_uom(bal_type_id NUMBER) IS
			SELECT balance_uom
			FROM   pay_balance_types
			WHERE  balance_type_id = bal_type_id;

			rec_get_balance csr_get_balance%ROWTYPE;
			l_balance_value NUMBER := 0;
			l_uom VARCHAR2(20) := NULL;
			l_action_info_id NUMBER;
			l_ovn NUMBER;
			l_index NUMBER;
			l_tu_id NUMBER;
			l_defined_balance_id NUMBER:=0;
			l_formatted_value VARCHAR2(50) := NULL;
			l_flag  NUMBER := 0;

			BEGIN

			IF g_debug THEN
					hr_utility.set_location(' Entering Procedure ARCHIVE_OTH_BALANCE',350);
			END IF;


			IF p_archive_flag = 'N' THEN

			---------------------------------------------------
			--Check if global table has already been populated
			---------------------------------------------------
			  IF g_user_balance_table.count = 0 THEN

			  OPEN csr_get_balance(g_business_group_id);

			  LOOP
			    FETCH csr_get_balance INTO rec_get_balance;
			    EXIT WHEN csr_get_balance%NOTFOUND;

				OPEN csr_def_balance(rec_get_balance.balance_type_id,rec_get_balance.balance_dim_id);
					FETCH csr_def_balance INTO l_defined_balance_id;
				CLOSE csr_def_balance;

				OPEN csr_uom(rec_get_balance.balance_type_id);
					FETCH csr_uom INTO l_uom;
				CLOSE csr_uom;

				PAY_KW_ARCHIVE.SETUP_BALANCE_DEFINITIONS(p_balance_name         => rec_get_balance.narrative
									,p_defined_balance_id   => l_defined_balance_id
									,p_balance_type_id      => rec_get_balance.balance_type_id
									,p_uom                  => l_uom);
			  END LOOP;
			  CLOSE csr_get_balance;
			  END IF;

			ELSIF p_archive_flag = 'Y' THEN

			OPEN csr_tax_unit(p_assignment_action_id);
				FETCH csr_tax_unit INTO l_tu_id;
			CLOSE csr_tax_unit;

			PAY_BALANCE_PKG.SET_CONTEXT('TAX_UNIT_ID',l_tu_id);
			PAY_BALANCE_PKG.SET_CONTEXT('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));

			    IF g_user_balance_table.count > 0 THEN

			    FOR l_index IN g_user_balance_table.first.. g_user_balance_table.last LOOP

			    l_balance_value := pay_balance_pkg.get_value(g_user_balance_table(l_index).defined_balance_id,p_assignment_action_id);

			    l_uom := hr_general.decode_lookup('UNITS',g_user_balance_table(l_index).uom);


			    IF l_balance_value > 0 THEN

			    pay_action_information_api.create_action_information (
						  p_action_information_id        => l_action_info_id
						 ,p_action_context_id            => p_archive_assact_id
						 ,p_action_context_type          => 'AAP'
						 ,p_object_version_number        => l_ovn
						 ,p_effective_date               => p_effective_date
						 ,p_source_id                    => NULL
						 ,p_source_text                  => NULL
						 ,p_action_information_category  => 'EMEA BALANCES'
						 ,p_action_information1          => g_user_balance_table(l_index).defined_balance_id
						 ,p_action_information2          => 'OBAL'
						 ,p_action_information4          => fnd_number.number_to_canonical(l_balance_value) --l_formatted_value
						 ,p_action_information5          => NULL
						 ,p_action_information6          => l_uom
						 ,p_assignment_id                => p_assignment_id);

			     END IF;

			     END LOOP;


			     END IF; /* For table count check */


			END IF;


			EXCEPTION WHEN OTHERS THEN
				     g_err_num := SQLCODE;

					/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_OTH_BALANCE'||SQLERRM);*/
					IF g_debug THEN
						hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_OTH_BALANCE',360);
					END IF;

			END ARCHIVE_OTH_BALANCE;

			/* ARCHIVE CODE */
			PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
					      ,p_effective_date    IN DATE)
			IS

			/* Cursor to retrieve Payroll and Prepayment related Ids for Archival */
			CURSOR csr_archive_ids (p_locking_action_id NUMBER) IS
			SELECT prepay_assact.assignment_action_id prepay_assact_id
			      ,prepay_assact.assignment_id        prepay_assgt_id
			      ,prepay_payact.payroll_action_id    prepay_payact_id
			      ,prepay_payact.effective_date       prepay_effective_date
			      ,run_assact.assignment_id           run_assgt_id
			      ,run_assact.assignment_action_id    run_assact_id
			      ,run_payact.payroll_action_id       run_payact_id
			      ,run_payact.payroll_id              payroll_id
			FROM   pay_action_interlocks  archive_intlck
			      ,pay_assignment_actions prepay_assact
			      ,pay_payroll_actions    prepay_payact
			      ,pay_action_interlocks  prepay_intlck
			      ,pay_assignment_actions run_assact
			      ,pay_payroll_actions    run_payact
			WHERE  archive_intlck.locking_action_id = p_locking_action_id
			AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
			AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
			AND    prepay_payact.action_type IN ('U','P')
			AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
			AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
			AND    run_payact.payroll_action_id = run_assact.payroll_action_id
			AND    run_payact.action_type IN ('Q', 'R')
			ORDER BY prepay_intlck.locking_action_id,prepay_intlck.locked_action_id desc;

			/* Cursor to retrieve time period information */
			CURSOR csr_period_end_date(p_assact_id NUMBER,p_pay_act_id NUMBER) IS
			SELECT ptp.end_date              end_date,
			       ptp.regular_payment_date  regular_payment_date,
			       ptp.time_period_id        time_period_id,
			       ppa.date_earned           date_earned,
			       ppa.effective_date        effective_date,
			       ptp.start_date		 start_date
			FROM   per_time_periods    ptp
			      ,pay_payroll_actions ppa
			      ,pay_assignment_actions paa
			WHERE  ptp.payroll_id             =ppa.payroll_id
			  AND  ppa.payroll_action_id      =paa.payroll_action_id
			  AND paa.assignment_action_id    =p_assact_id
			  AND ppa.payroll_action_id       =p_pay_act_id
			  AND ppa.date_earned BETWEEN ptp.start_date
						  AND ptp.end_date;

			/* Cursor to retrieve Archive Payroll Action Id */
			CURSOR csr_archive_payact(p_assignment_action_id NUMBER) IS
			SELECT payroll_action_id
			FROM   pay_assignment_actions
			WHERE  assignment_Action_id = p_assignment_action_id;


			l_archive_payact_id NUMBER;
			l_record_count  	NUMBER;
			l_actid			NUMBER;
			l_end_date 	per_time_periods.end_date%TYPE;
			l_pre_end_date  per_time_periods.end_date%TYPE;
			l_reg_payment_date 	per_time_periods.regular_payment_date%TYPE;
			l_pre_reg_payment_date  per_time_periods.regular_payment_date%TYPE;
			l_date_earned 	  pay_payroll_actions.date_earned%TYPE;
			l_pre_date_earned pay_payroll_actions.date_earned%TYPE;
			l_effective_date 	pay_payroll_actions.effective_date%TYPE;
			l_pre_effective_date 	pay_payroll_actions.effective_date%TYPE;
			l_run_payact_id NUMBER;
			l_action_context_id	NUMBER;
			g_archive_pact		NUMBER;
			p_assactid		NUMBER;
			l_time_period_id	per_time_periods.time_period_id%TYPE;
			l_pre_time_period_id	per_time_periods.time_period_id%TYPE;
			l_start_date		per_time_periods.start_date%TYPE;
			l_pre_start_date	per_time_periods.start_date%TYPE;
			l_fnd_session NUMBER := 0;
			l_prev_prepay NUMBER := 0;

			BEGIN

			IF g_debug THEN
					hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
			END IF;


			  OPEN csr_archive_payact(p_assignment_action_id);
			    FETCH csr_archive_payact INTO l_archive_payact_id;
			  CLOSE csr_archive_payact;

			  l_record_count := 0;
			  FOR rec_archive_ids IN csr_archive_ids(p_assignment_action_id) LOOP
			    OPEN csr_period_end_date(rec_archive_ids.run_assact_id,rec_archive_ids.run_payact_id);
				FETCH csr_period_end_date INTO l_end_date,l_reg_payment_date,l_time_period_id,l_date_earned,l_effective_date,l_start_date;
			    CLOSE csr_period_end_date;

			    OPEN csr_period_end_date(rec_archive_ids.prepay_assact_id,rec_archive_ids.prepay_payact_id);
				FETCH csr_period_end_date INTO l_pre_end_date,l_pre_reg_payment_date,l_pre_time_period_id,l_pre_date_earned,l_pre_effective_date,l_pre_start_date;
			    CLOSE csr_period_end_date;

			    /*fnd_file.put_line(fnd_file.log,'ARCHIVE_EMPLOYEE_DETAILS');*/

			    -------------------------------------------------------------
			    --Archive EMPLOYEE_DETAILS, PAYMENT_INFO and BALANCES
			    --for every prepayment assignment action id
			    -------------------------------------------------------------

			    IF (rec_archive_ids.prepay_assact_id <> l_prev_prepay) THEN

			    ARCHIVE_EMPLOYEE_DETAILS(p_archive_assact_id      => p_assignment_action_id
						    ,p_assignment_id          => rec_archive_ids.run_assgt_id
						    ,p_assignment_action_id   => rec_archive_ids.run_assact_id
						    ,p_payroll_action_id      => l_archive_payact_id
						    ,p_time_period_id         => l_time_period_id
						    ,p_date_earned            => l_date_earned --l_pre_date_earned
						    ,p_pay_date_earned        => l_date_earned
						    ,p_effective_date         => p_effective_date);


			   /*fnd_file.put_line(fnd_file.log,'ARCHIVE_PAYMENT_INFO');*/
			   ARCHIVE_PAYMENT_INFO(p_archive_assact_id => p_assignment_action_id,
						p_prepay_assact_id  => rec_archive_ids.prepay_assact_id,
						p_assignment_id     => rec_archive_ids.prepay_assgt_id,
						p_date_earned       => l_date_earned, --l_pre_date_earned,
						p_effective_date    => p_effective_date);

			   /*fnd_file.put_line(fnd_file.log,'ARCHIVE_OTH_BALANCE');*/
			   ARCHIVE_OTH_BALANCE(p_archive_assact_id     => p_assignment_action_id,
					       p_assignment_action_id  => rec_archive_ids.run_assact_id,
					       p_assignment_id         => rec_archive_ids.run_assgt_id,
					       p_payroll_action_id     => l_archive_payact_id,
					       p_record_count          => l_record_count,
					       p_pre_payact_id         => rec_archive_ids.prepay_payact_id,
					       p_effective_date        => p_effective_date,
					       p_date_earned           => l_date_earned,
					       p_archive_flag          => 'Y');

			   l_prev_prepay := rec_archive_ids.prepay_assact_id;

			   END IF;

			   /*fnd_file.put_line(fnd_file.log,'ARCHIVE_ADD_ELEMENT');*/
			   ARCHIVE_ADD_ELEMENT(p_archive_assact_id     => p_assignment_action_id,
					       p_assignment_action_id  => rec_archive_ids.run_assact_id,
					       p_assignment_id         => rec_archive_ids.run_assgt_id,
					       p_payroll_action_id     => l_archive_payact_id,
					       p_date_earned           => l_date_earned,
					       p_effective_date        => p_effective_date,
					       p_pre_payact_id         => rec_archive_ids.prepay_payact_id,
					       p_archive_flag          => 'Y');



			   /*fnd_file.put_line(fnd_file.log,'Assact id: '|| p_assignment_action_id);*/

			    l_record_count := l_record_count + 1;
			  END LOOP;

			IF g_debug THEN
					hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
			END IF;

			END ARCHIVE_CODE;
			END PAY_KW_ARCHIVE;

/
