--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_CONC_PKG" AS
/* $Header: pykrycon.pkb 120.2.12000000.1 2007/01/17 22:19:49 appldev noship $ */
-----------
  PROCEDURE SUBMIT_YEA (ERRBUF                  OUT   NOCOPY	VARCHAR2,
			RETCODE                 OUT   NOCOPY	VARCHAR2,
                        P_yea_Type                    		VARCHAR2,
                        P_effective_date              		VARCHAR2,
                        P_business_group_id           		per_all_people_f.business_group_id%type,
                        P_payroll_id                  		pay_payroll_actions.payroll_id%type,
			P_action_parameter_group_id             pay_action_parameter_groups.action_parameter_group_id%type,
			P_consolidation_set_id        		pay_consolidation_sets.consolidation_set_id%type,
                        P_assignment_set_id           		hr_assignment_sets.assignment_set_id%type,
                        P_element_type_iD             		pay_element_types.element_type_id%type,
                        P_run_type_iD                 		pay_run_types.run_type_id%type
                      )
  IS
    l_bal_req_id          NUMBER;
    l_arc_req_id          NUMBER;
    l_bal_adj_action_id   pay_payroll_actions.payroll_action_id%type;
    l_effective_date      DATE   ;
    l_message             VARCHAR2(2000);
    l_phase               VARCHAR2(100);
    l_status              VARCHAR2(100);
    l_dev_status          VARCHAR2(100);
    l_dev_phase           VARCHAR2(100);
    l_action_completed    BOOLEAN;

    CURSOR csr_bal_adj_action_id
    IS
       SELECT payroll_action_id
         FROM pay_payroll_actions
        WHERE request_id           = l_bal_req_id
          AND payroll_id           = p_payroll_id
          AND consolidation_set_id = p_consolidation_set_id
          AND effective_date       = l_effective_date;
  BEGIN

    l_bal_req_id          := 0;
    l_arc_req_id          := 0;
    l_dev_status          := 'X';
    l_dev_phase           := 'X';
    l_effective_date := fnd_date.canonical_to_date(p_effective_date);

    l_bal_req_id := FND_REQUEST.SUBMIT_REQUEST (
						 APPLICATION          =>   'PAY'
						,PROGRAM              =>   'PYKRYEB'
						,DESCRIPTION          =>   'KR Year End Balance Adjustment'
						,ARGUMENT1            =>   'BAL_ADJUST'
						,ARGUMENT2            =>   p_payroll_id
						,ARGUMENT3            =>   p_consolidation_set_id
						,ARGUMENT4            =>   p_effective_date
						,ARGUMENT5            =>   p_assignment_set_id
						,ARGUMENT6            =>   p_element_type_id
						,ARGUMENT7            =>   p_run_type_id
--	Bug No: 3561068
						,ARGUMENT8            =>   null                 -- bal_adj_cost_flag
						,ARGUMENT9            =>   null                 -- cost_allocation_keyflex_id
						,ARGUMENT10           =>   'REPORT_TYPE=YEA'
						,ARGUMENT11           =>   'REPORT_QUALIFIER=KR'
						,ARGUMENT12           =>   'REPORT_CATEGORY='||p_yea_type
						);
--

    IF (l_bal_req_id = 0) THEN
        RETCODE := 2;
	FND_MESSAGE.RETRIEVE(ERRBUF);
    ELSE
       COMMIT;
       WHILE (l_dev_phase <> 'COMPLETE')
       LOOP
          l_action_completed := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                            request_id 	=>	l_bal_req_id
					   ,interval 	=>	15
					   ,max_wait 	=>	60
					   ,phase 	=>	l_phase
					   ,status 	=>	l_status
					   ,dev_phase 	=>	l_dev_phase
					   ,dev_status 	=>	l_dev_status
					   ,message 	=>	l_message);
        END LOOP;

        IF l_dev_phase = 'COMPLETE' AND l_dev_status = 'NORMAL' THEN

           OPEN csr_bal_adj_action_id;
           FETCH csr_bal_adj_action_id INTO l_bal_adj_action_id;
           CLOSE csr_bal_adj_action_id;

           l_arc_req_id := FND_REQUEST.SUBMIT_REQUEST (
						 APPLICATION          =>   'PAY'
						,PROGRAM              =>   'PYKRYEA'
						,DESCRIPTION          =>   'KR Year End Adjustment Archive'
						,ARGUMENT1            =>   'ARCHIVE'
						,ARGUMENT2            =>   'YEA'
						,ARGUMENT3            =>   'KR'
						,ARGUMENT4            =>   p_effective_date
						,ARGUMENT5            =>   p_effective_date
						,ARGUMENT6            =>   p_yea_type
						,ARGUMENT7            =>   p_business_group_id
						,ARGUMENT8            =>   null
						,ARGUMENT9            =>   null
						,ARGUMENT10           =>   P_action_parameter_group_id
						,ARGUMENT11           =>   'PAYROLL_ID='||to_char(p_payroll_id)
						,ARGUMENT12           =>   'BAL_ADJ_ACTION_ID='||to_char(l_bal_adj_action_id)
						,ARGUMENT13           =>   'CONSOLIDATION_SET_ID='||to_char(p_consolidation_set_id)
                                                ,ARGUMENT14           =>   'ARCHIVE_TYPE=AAP'   -- Bug 5225198
						);

           IF (l_arc_req_id = 0) THEN
              RETCODE := 2;
              FND_MESSAGE.RETRIEVE(ERRBUF);
           ELSE
	      COMMIT;
	      --
              l_dev_phase        := 'X';
              l_action_completed := null;
              l_dev_status       := null;
              l_phase            := null;
              l_status           := null;
              l_message          := null;
              --
              WHILE (l_dev_phase <> 'COMPLETE')
              LOOP
                 l_action_completed := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                            request_id 	=>	l_arc_req_id
					   ,interval 	=>	15
					   ,max_wait 	=>	60
					   ,phase 	=>	l_phase
					   ,status 	=>	l_status
					   ,dev_phase 	=>	l_dev_phase
					   ,dev_status 	=>	l_dev_status
					   ,message 	=>	l_message);
               END LOOP;

           END IF;
       ELSE
         RETCODE := 2;
         FND_MESSAGE.RETRIEVE(ERRBUF);
       END IF;
    END IF;

  END SUBMIT_YEA;

END PAY_KR_YEA_CONC_PKG;

/
