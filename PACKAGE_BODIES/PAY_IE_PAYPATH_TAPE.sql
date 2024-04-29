--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAYPATH_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAYPATH_TAPE" as
/* $Header: pyiepppk.pkb 120.1.12010000.2 2009/07/24 09:12:49 namgoyal ship $ */
--
-- Constants
--
  l_package varchar2(31) := 'pay_ie_paypath_tape.';
--
-- Global Variables
--
--------------------------------------------------------------------------------+
--
--------------------------------------------------------------------------------+
/*
PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT NOCOPY VARCHAR2) IS

CURSOR csr_parameter_info(p_pact_id NUMBER,
                          p_token   CHAR) IS
SELECT SUBSTR(legislative_parameters,
               INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                INSTR(legislative_parameters,' ',
                       INSTR(legislative_parameters,p_token))
                 - (INSTR(legislative_parameters,p_token)+LENGTH(p_token))),
       business_group_id
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_business_group_id               VARCHAR2(20);
l_token_value                     VARCHAR2(50);


BEGIN




  hr_utility.set_location('p_token_name = ' || p_token_name,20);

  OPEN csr_parameter_info(p_payroll_action_id,p_token_name);
  FETCH csr_parameter_info INTO l_token_value,l_business_group_id;
  CLOSE csr_parameter_info;

  p_token_value := trim(l_token_value);


  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || 'get_parameters',30);

END get_parameters;*/

--------------------------------------------------------------------------------+
 --Function get_paypathid is used to fetch Paypath ids for a Consolidation Set
--------------------------------------------------------------------------------+
 -- Bug No 3060464 Start
 /*FUNCTION get_paypathid return varchar2 as

     --Cursor to fetch  paypath ids for all payrolls within a consolidation set
     CURSOR CSR_PAYROLLS
     IS
     SELECT   count(distinct org_information8) paycount,
              org_information8
     FROM     pay_all_payrolls_f papf
        ,     hr_organization_information org
        ,     hr_soft_coding_keyflex sck
      WHERE
              papf.consolidation_set_id    =  pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_ID')
              and  to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'),'YYYY/MM/DD HH24:MI:SS')
              between papf.effective_start_date and papf.effective_end_date
      and     org.org_information_context  = 'IE_PAYPATH_INFORMATION'
      and     papf.SOFT_CODING_KEYFLEX_ID  =  sck.SOFT_CODING_KEYFLEX_ID
      and     org.ORG_INFORMATION_ID       =  to_number(sck.segment2)
      and     org.org_information8 is not null
      group by org_information8;


      --Cursor to fetch first paypath id defined at BG Level
      CURSOR CSR_BG_PAYPATH
      IS
      SELECT  org.org_information8
      FROM    hr_organization_information    org
         ,    pay_payroll_actions            ppa
      WHERE
              ppa.payroll_action_id        =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
      and     org.organization_id          =  ppa.business_group_id
      and     org.org_information_context  =  'IE_PAYPATH_INFORMATION'
      and     rownum=1;

      --Cursor to fetch paypath id for a specified payroll parameter
      CURSOR CSR_PAYROLL_PAYPATH
      IS
      SELECT  org.org_information8
      FROM    hr_organization_information org
      WHERE
              org.org_information_context  = 'IE_PAYPATH_INFORMATION'
              and org.ORG_INFORMATION_ID   =
                      (SELECT  to_number(segment2)
                       FROM
			        hr_soft_coding_keyflex sck
		       ,        pay_all_payrolls_f papf
		       ,        pay_payroll_actions ppa
                       WHERE
			        papf.SOFT_CODING_KEYFLEX_ID =  sck.SOFT_CODING_KEYFLEX_ID
		       and      papf.payroll_id             =  pay_magtape_generic.get_parameter_value('PAYROLL_ID')
		       and      papf.consolidation_set_id   =  pay_magtape_generic.get_parameter_value('CONSOLIDATION_SET_ID')
		       and      ppa.effective_date between papf.effective_start_date and papf.effective_end_date
		       and      ppa.payroll_action_id       =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
		       and      papf.payroll_id=ppa.payroll_id);

      l_paypath_ids     csr_payrolls%rowtype;
      l_bg_pathid       csr_bg_paypath%rowtype;
      l_payroll_pathid  csr_payroll_paypath%rowtype;
      cnt number :=0;
      e_submit_error exception;
      l_paypathid varchar2(150);

 BEGIN

 --Only consolidation set specified as parameter in IE PayPath Process
 IF  pay_magtape_generic.get_parameter_value('PAYROLL_ID') is null then

	BEGIN

        OPEN csr_payrolls;
	LOOP
   	FETCH csr_payrolls into l_paypath_ids;
   	EXIT when csr_payrolls%NOTFOUND;

	           l_paypathid:=l_paypath_ids.org_information8;
	           pay_ie_paypath_tape.g_pathid:=l_paypathid;
                   cnt:=cnt+1;

                   --PayPath process errors when a consolidation set has multiple payrolls, which in turn have multiple Paypath ID's
                   if cnt>=2 then
                        raise e_submit_error;
                   end if;
        END LOOP;

        --If no Paypath ids are specified at payroll level,Paypath id  defined at BG level is picked up.
	if cnt=0 then

	           OPEN  CSR_BG_PAYPATH;
	           FETCH CSR_BG_PAYPATH into l_bg_pathid;

	           --If no paypath ids defined at BG level and payroll level
	           IF CSR_BG_PAYPATH%NOTFOUND THEN

	 	    	l_paypathid:= ' ';
	 	    	pay_ie_paypath_tape.g_pathid:=l_paypathid;
	 	        return l_paypathid;
	 	   END IF;
		   CLOSE CSR_BG_PAYPATH;

		   pay_ie_paypath_tape.g_pathid:=l_bg_pathid.org_information8;
	 	   return l_bg_pathid.org_information8;
        end if;
        --If payrolls in the consolidation set all have the same paypath id, then that paypath id is picked up.
	return l_paypathid;
        EXCEPTION when e_submit_error then

                   l_paypathid:='Error';
                   pay_ie_paypath_tape.g_pathid:=l_paypathid;
	 	   return l_paypathid;
        END;
  ELSE
     --Payroll name as well as the consolidation set specified as parameter then ,select paypath id specified at the payroll level

                   OPEN   CSR_PAYROLL_PAYPATH;
                   FETCH  CSR_PAYROLL_PAYPATH into l_payroll_pathid;

                   --Bug No 3086034 Start
                   IF  CSR_PAYROLL_PAYPATH%NOTFOUND THEN

                        --Payroll name specified as a parameter but ,no paypath id defined for that payroll,hence it picks up
                        --paypath id defined at BG Level
                        OPEN  CSR_BG_PAYPATH;
                        FETCH CSR_BG_PAYPATH into l_bg_pathid;
                        CLOSE CSR_BG_PAYPATH;
                        pay_ie_paypath_tape.g_pathid:=l_bg_pathid.org_information8;
                        return  l_bg_pathid.org_information8;
                   END IF;
                    --Bug No 3086034 End
                   CLOSE  CSR_PAYROLL_PAYPATH;

		   pay_ie_paypath_tape.g_pathid:=l_payroll_pathid.org_information8;
		   return   l_payroll_pathid.org_information8;
  END IF;
END get_paypathid;
-- Bug No 3060464 End
*/
--------------------------------------------------------------------------------+
  -- Range cursor returns the ids of the assignments to be archived
  --------------------------------------------------------------------------------+
  PROCEDURE range_code(
                       p_payroll_action_id IN  NUMBER,
                       p_sqlstr            OUT NOCOPY VARCHAR2)
  IS
    l_proc_name VARCHAR2(100) := l_package || 'range_code';
  BEGIN
    hr_utility.set_location(l_proc_name, 10);
 -- Changed the cursor to reduce the cost (5042843)
    p_sqlstr := 'SELECT distinct asg.person_id
              FROM per_periods_of_service pos,
                   per_assignments_f      asg,
                   pay_payroll_actions    ppa
             WHERE ppa.payroll_action_id = :payroll_action_id
               AND pos.person_id         = asg.person_id
               AND pos.period_of_service_id = asg.period_of_service_id
               AND pos.business_group_id = ppa.business_group_id
               AND asg.business_group_id = ppa.business_group_id
             ORDER BY asg.person_id';
    hr_utility.set_location(l_proc_name, 20);
  END range_code;

  --------------------------------------------------------------------------------+
  -- Creates assignment action id for all the valid person id's in
  -- the range selected by the Range code.
  --------------------------------------------------------------------------------+
  PROCEDURE assignment_action_code(
                                   p_payroll_action_id  IN NUMBER,
                                   p_start_person_id    IN NUMBER,
                                   p_end_person_id      IN NUMBER,
                                   p_chunk_number       IN NUMBER)
  IS
    l_proc_name                VARCHAR2(100) := l_package || 'assignment_action_code';

-- Bug 3221451: Added hint ORDERED for the optimizer

   CURSOR csr_asg(p_payroll_action_id NUMBER,
		  p_start_person_id   NUMBER,
		  p_end_person_id     NUMBER,
		  p_payroll_id        NUMBER,
		  p_consolidation_id  NUMBER,
		  p_assignment_set_id   NUMBER,
		  p_person_id   NUMBER) IS
   SELECT act.assignment_action_id,
          act.assignment_id,
          ppp.pre_payment_id
   FROM   pay_assignment_actions act,
          per_all_assignments_f  asg,
          pay_payroll_actions    pa2,
          pay_payroll_actions    pa1,
          pay_pre_payments       ppp,
          pay_org_payment_methods_f OPM,
          pay_payment_types       PPT,
          per_all_people_f	  pap
   WHERE  pa1.payroll_action_id           = p_payroll_action_id
   AND    pa2.consolidation_set_id     	  = p_consolidation_id
   AND    pa2.payroll_id		  = NVL(p_payroll_id,pa2.payroll_id)
   AND    pa2.effective_date 		  <= pa1.effective_date
   AND    pa2.action_type    		  IN ('P','U') -- Prepayments or Quickpay Prepayments
   AND    act.payroll_action_id		  = pa2.payroll_action_id
   AND    act.action_status    		  = 'C'
   AND    asg.assignment_id    		  = act.assignment_id
   AND    pa1.business_group_id		  = asg.business_group_id
   AND    pa1.effective_date between  asg.effective_start_date and asg.effective_end_date
   AND    pa1.effective_date between  pap.effective_start_date and pap.effective_end_date
   AND    pap.person_id			  = asg.person_id
   AND    pap.person_id      between  p_start_person_id and p_end_person_id
   AND    ppp.assignment_action_id 	  = act.assignment_action_id
   AND    ppp.org_payment_method_id 	  = opm.org_payment_method_id
   AND    opm.payment_type_id	  	  = ppt.payment_type_id
   AND    ppt.territory_code	  	  = 'IE'
   AND    ppt.payment_type_name		  = 'PayPath'
   AND    pap.person_id 		  = NVL(p_person_id,pap.person_id)
   AND    (p_assignment_set_id IS NULL
   	            OR EXISTS (     SELECT ''
   	    	        	    FROM   hr_assignment_set_amendments hr_asg
   	    	        	    WHERE  hr_asg.assignment_set_id = p_assignment_set_id
   	    	        	    AND    hr_asg.assignment_id     = asg.assignment_id
           	                 ))
   AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa.payroll_action_id
                   AND    appa.action_type = 'X'
                   AND    appa.report_type = 'PayPath');


  l_payroll_id 		VARCHAR2(15):=NULL;
  l_consolidation_set 	VARCHAR2(15):=NULL;
  l_locking_action_id   VARCHAR2(15):=NULL;
  l_assignment_set_id   VARCHAR2(15):=NULL;
  l_person_id		VARCHAR2(15):=NULL;

  BEGIN

    --hr_utility.trace_on(NULL,'VV');
    hr_utility.set_location(l_proc_name, 10);

    pay_ie_archive_detail_pkg.get_parameters (
	        p_payroll_action_id => p_payroll_action_id
	      , p_token_name        => 'PAYROLL_ID'
	      , p_token_value       => l_payroll_id);

      pay_ie_archive_detail_pkg.get_parameters (
	        p_payroll_action_id => p_payroll_action_id
	      , p_token_name        => 'CONSOLIDATION_SET_ID'
	      , p_token_value       => l_consolidation_set);

      pay_ie_archive_detail_pkg.get_parameters (
                p_payroll_action_id => p_payroll_action_id
              , p_token_name        => 'ASSIGNMENT_SET_ID'
              , p_token_value       => l_assignment_set_id);

      pay_ie_archive_detail_pkg.get_parameters (
                p_payroll_action_id => p_payroll_action_id
              , p_token_name        => 'PERSON_ID'
              , p_token_value       => l_person_id);


    hr_utility.set_location(l_proc_name, 20);

    FOR rec_asg IN csr_asg(p_payroll_action_id
    			  ,p_start_person_id
    			  ,p_end_person_id
    			  ,l_payroll_id
    			  ,l_consolidation_set
    			  ,l_assignment_set_id
    			  ,l_person_id) LOOP

      SELECT pay_assignment_actions_s.nextval
      INTO   l_locking_action_id
      FROM   dual;


       hr_nonrun_asact.insact(lockingactid  => l_locking_action_id,
                              assignid      => rec_asg.assignment_id,
                              pactid        => p_payroll_action_id,
                              chunk         => p_chunk_number,
                              greid         => NULL,
                              prepayid      => rec_asg.pre_payment_id,
                              status        => 'U');


       --
       -- insert the lock on the run action.
       --

        hr_nonrun_asact.insint(l_locking_action_id
                        , rec_asg.assignment_action_id);
       --

    END LOOP;
    hr_utility.set_location(l_proc_name, 40);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in assignment action code ',100);
      RAISE;
  END assignment_action_code;


--Cash Management Reconciliation function
 FUNCTION f_get_paypath_recon_data (p_effective_date       IN DATE,
			            p_identifier_name       IN VARCHAR2,
                   		    p_payroll_action_id	IN NUMBER,
				    p_payment_type_id	IN NUMBER,
				    p_org_payment_method_id	IN NUMBER,
				    p_personal_payment_method_id	IN NUMBER,
				    p_assignment_action_id	IN NUMBER,
				    p_pre_payment_id	IN NUMBER,
				    p_delimiter_string   	IN VARCHAR2)
 RETURN VARCHAR2
 IS

   CURSOR c_get_bus_grp
   IS
     Select business_group_id
     From pay_payroll_actions
     Where payroll_action_id = p_payroll_action_id;

   CURSOR c_get_trx_date
   IS
     Select overriding_dd_date
     From pay_payroll_actions
     Where payroll_action_id = p_payroll_action_id;

   CURSOR c_get_conc_ident
   IS
     Select ext.segment1, --Sort Code
            ext.segment4 --Acc Num
     From pay_external_accounts ext,
	  pay_org_payment_methods_f org
     Where  org.org_payment_method_id = p_org_payment_method_id
       and  p_effective_date between org.effective_start_date and org.effective_end_date
       and  org.external_account_id = ext.external_account_id;

   l_business_grp_id     NUMBER;
   l_usr_fnc_name        VARCHAR2(5000):= NULL;
   l_return_value	 VARCHAR2(80) := NULL;
   l_trx_date            Date;
   l_sort_code           VARCHAR2(30);
   l_acc_num             VARCHAR2(30);

 BEGIN

   OPEN c_get_bus_grp;
   FETCH c_get_bus_grp INTO l_business_grp_id;
   CLOSE c_get_bus_grp;

   Select hruserdt.get_table_value(l_business_grp_id,
                                   'IE_EFT_RECONC_FUNC',
                                   'RECONCILIATION',
                                   'FUNCTION NAME',
                                    p_effective_date)
    Into l_usr_fnc_name
    From dual;

   IF l_usr_fnc_name IS NOT NULL
   THEN
	     EXECUTE IMMEDIATE 'select '||l_usr_fnc_name||'(:1,:2,:3,:4,:5,:6,:7,:8,:9) from dual'
	     INTO l_return_value
	     USING p_effective_date ,
             p_identifier_name,
	     p_payroll_action_id,
	     p_payment_type_id,
	     p_org_payment_method_id,
	     p_personal_payment_method_id,
	     p_assignment_action_id,
	     p_pre_payment_id,
	     p_delimiter_string ;
   ELSE
       IF UPPER(p_identifier_name) = 'TRANSACTION_DATE'
       THEN
	   OPEN c_get_trx_date;
	   FETCH c_get_trx_date INTO l_trx_date;
           CLOSE c_get_trx_date;

	   l_return_value := to_char(l_trx_date, 'yyyy/mm/dd');

       ELSIF UPPER(p_identifier_name) = 'TRANSACTION_GROUP'
       THEN
           l_return_value := p_payroll_action_id;

       ELSIF UPPER(p_identifier_name) = 'CONCATENATED_IDENTIFIERS'
       THEN
            OPEN c_get_conc_ident;
	    FETCH c_get_conc_ident INTO l_sort_code,l_acc_num;
            CLOSE c_get_conc_ident;

	    l_return_value := 'PAYPATH'||p_delimiter_string||l_sort_code||p_delimiter_string||l_acc_num;

       END IF;
   END IF;

   RETURN l_return_value;

END f_get_paypath_recon_data;


END pay_ie_paypath_tape;

/
