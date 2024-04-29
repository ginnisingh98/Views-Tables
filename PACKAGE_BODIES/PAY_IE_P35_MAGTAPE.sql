--------------------------------------------------------
--  DDL for Package Body PAY_IE_P35_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_P35_MAGTAPE" AS
/* $Header: pyiep35m.pkb 120.10.12010000.3 2009/05/26 05:17:11 knadhan ship $ */
--
-- Constants
--
   l_package                  CONSTANT VARCHAR2 (31) := 'pay_ie_p35_magtape.';
--------------------------------------------------------------------------------+

   FUNCTION get_parameter (
      p_payroll_action_id   IN   NUMBER,
      p_token_name          IN   VARCHAR2
   )
      RETURN VARCHAR2
   AS
      CURSOR csr_parameter_info (p_pact_id NUMBER, p_token CHAR)
      IS
         SELECT SUBSTR (
                   legislative_parameters,
                     INSTR (legislative_parameters, p_token)
                   + (  LENGTH (p_token)
                      + 1
                     ),
                     INSTR (
                        legislative_parameters,
                        ' ',
                        INSTR (legislative_parameters, p_token)
                     )
                   - (  INSTR (legislative_parameters, p_token)
                      + LENGTH (p_token)
                     )
                ),
                business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_pact_id;

      l_business_group_id   NUMBER;
      l_token_value         VARCHAR2 (50);
   BEGIN
      hr_utility.set_location (   'p_token_name = '
                               || p_token_name, 20);
      OPEN csr_parameter_info (p_payroll_action_id, p_token_name);
      FETCH csr_parameter_info INTO l_token_value, l_business_group_id;
      CLOSE csr_parameter_info;

      IF p_token_name = 'BG_ID'
      THEN
         l_token_value := TO_CHAR (l_business_group_id);
      ELSE
         l_token_value := TRIM (l_token_value);
      END IF;

      RETURN l_token_value;
   END get_parameter;

   --------------------------------------------------------------------------------+
 -- Range cursor returns the ids of the assignments to be archived
 --------------------------------------------------------------------------------+
   PROCEDURE range_code (p_payroll_action_id   IN              NUMBER,
				 p_sqlstr              OUT NOCOPY      VARCHAR2
				)
   IS
      l_proc_name                VARCHAR2 (100) :=    l_package|| 'range_code';
      l_dummy                    NUMBER;
      p35_error                  EXCEPTION;
      l_payroll_action_message   VARCHAR2 (255);
      l_out_var                  VARCHAR2 (30);
      l_start_date               DATE;
      l_end_date                 DATE;
      l_bg_id                    NUMBER;

	CURSOR csr_p35_process
      IS
         SELECT NVL (MIN (ppa.payroll_action_id), 0)
           FROM pay_payroll_actions ppa
          WHERE ppa.report_type = 'IEP35'
            AND ppa.action_status = 'C'
            AND TO_DATE (
                   pay_ie_p35.get_parameter (
                      ppa.payroll_action_id,
                      'END_DATE'
                   ),
                   'YYYY/MM/DD'
                ) BETWEEN l_start_date AND l_end_date
            AND ppa.business_group_id = l_bg_id;

     BEGIN
   --hr_utility.trace_on(null,'MAGTRC');
      l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> p_payroll_action_id,
               p_token_name=> 'END_DATE'
            );
      l_end_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> p_payroll_action_id,
               p_token_name=> 'START_DATE'
            );
      l_start_date := TO_DATE (l_out_var, 'YYYY/MM/DD');
      l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> p_payroll_action_id,
               p_token_name=> 'BG_ID'
            );
      l_bg_id := TO_NUMBER (l_out_var);

      -- Check to make sure there is a p35 process run
      -- existing for business group, otherwise fail
      OPEN csr_p35_process;
      FETCH csr_p35_process INTO l_dummy;

      IF l_dummy = 0
      THEN
         CLOSE csr_p35_process;
         RAISE p35_error;
      END IF;

      CLOSE csr_p35_process;
      --
  -- Changed the cursor to reduce the cost (5042843)
      p_sqlstr :=
            ' SELECT distinct asg.person_id
              FROM per_periods_of_service pos,
                   per_assignments_f      asg,
                   pay_payroll_actions    ppa
             WHERE ppa.payroll_action_id = :payroll_action_id
               AND pos.person_id         = asg.person_id
               AND pos.period_of_service_id = asg.period_of_service_id
               AND pos.business_group_id = ppa.business_group_id
               AND asg.business_group_id = ppa.business_group_id
             ORDER BY asg.person_id';
      /* Added code for BUG 2987230 */
      hr_utility.set_location (l_proc_name, 20);

   EXCEPTION
      WHEN OTHERS
      THEN
         -- Write to the conc logfile, and try to archive err msg.
         l_payroll_action_message :=
               SUBSTR (
                  'P35 Report Process Failed: No P35 Process exist for the Business group in the reporting year.',
                  1,
                  240
               );
         fnd_file.put_line (fnd_file.LOG, l_payroll_action_message);
         p_sqlstr :=
               'select 1 from dual where to_char(:payroll_action_id) = dummy';
   END range_code;


--------------------------------------------------------------------------------+
-- Creates assignment action id for all the valid person id's in
-- the range selected by the Range code.
--------------------------------------------------------------------------------+
   PROCEDURE action_creation (
      pactid      IN   NUMBER,
      stperson    IN   NUMBER,
      endperson   IN   NUMBER,
      CHUNK       IN   NUMBER
   )
   IS
      l_proc_name                      VARCHAR2 (100) := l_package || 'assignment_action_code';
      l_actid                          NUMBER;
      l_out_var                        VARCHAR2 (30);
      l_start_date                     DATE;
      l_end_date                       DATE;
      l_bg_id                          NUMBER;
      l_segment4                       hr_soft_coding_keyflex.segment4%TYPE;
      l_assignment_set_id	         hr_assignment_sets.assignment_set_id%TYPE;
      l_payroll_id		         pay_all_payrolls_f.payroll_id%TYPE;
      l_set_flag				   hr_assignment_set_amendments.include_or_exclude%TYPE ;

CURSOR csr_get_flag_from_set
IS
	SELECT DISTINCT hasa.include_or_exclude FROM hr_assignment_set_amendments hasa, hr_assignment_sets has
	WHERE hasa.assignment_set_id = has.assignment_set_id
	AND has.business_group_id = l_bg_id
	AND has.assignment_set_id = l_assignment_set_id;


      CURSOR csr_locked_asgs
      IS
         SELECT DISTINCT paa.assignment_id,paa.assignment_action_id,paa.payroll_action_id
             FROM pay_assignment_actions   paa,
                  pay_payroll_actions      ppa,
                  pay_action_information   pai,
			per_assignments_f    paaf,
			pay_all_payrolls_f           ppf,
			hr_soft_coding_keyflex   flex
            WHERE paa.payroll_action_id = ppa.payroll_action_id
              AND paa.action_status = 'C'
              AND ppa.action_type ='X'
              AND ppa.business_group_id = l_bg_id
		  AND paa.source_action_id IS NULL
		  AND pai.action_context_id = paa.assignment_action_id
	        AND pai.action_information_category = 'IE P35 DETAIL'
	        AND ppa.report_type = 'IEP35'
	        AND paa.assignment_id = pai.assignment_id
	        AND paaf.assignment_id = paa.assignment_id
              --AND paaf.primary_flag = 'Y'
              AND paaf.business_group_id = ppa.business_group_id
	        AND paaf.payroll_id = ppf.payroll_id
      	  AND ppf.effective_start_date <= l_end_date
              AND ppf.effective_end_date >= l_start_date
	        AND flex.soft_coding_keyflex_id = ppf.soft_coding_keyflex_id
	        AND flex.segment4 = l_segment4
	        AND paaf.person_id BETWEEN stperson AND endperson
              AND paaf.effective_start_date <= l_end_date
              AND paaf.effective_end_date >= l_start_date
	        AND TO_DATE (
                                  pay_ie_p35.get_parameter (
                                     ppa.payroll_action_id,
                                     'END_DATE'
                                  ),
                                  'YYYY/MM/DD'
                               ) BETWEEN l_start_date AND l_end_date
	        AND (ppf.payroll_id in (select b.payroll_id FROM per_assignments_f a,per_assignments_f b
					  where a.payroll_id = l_payroll_id
					  and a.person_id = b.person_id
					  and a.person_id = paaf.person_id
					  --bug 6642916
					  and a.effective_start_date<= l_end_date
					   and a.effective_end_date>= l_start_date)
					 OR l_payroll_id IS NULL)
		  --AND (ppf.payroll_id =l_payroll_id or l_payroll_id is null)
              --AND PAY_IE_P35.check_assignment_in_set(paa.assignment_id,l_assignment_set_id,l_bg_id)=1;
	        AND ((l_assignment_set_id IS NOT NULL
	        AND (l_set_flag ='I' AND EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
							 --,  pay_payrolls_f pay
							 --,  hr_soft_coding_keyflex hflex
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = l_bg_id
					  AND   has.assignment_set_id = l_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id)
					  --AND   paf.payroll_id        = pay.payroll_id
					  --AND   pay.soft_coding_keyflex_id = hflex.soft_coding_keyflex_id
					  --AND   hflex.segment4 = l_segment4)
		  OR l_set_flag = 'E' AND NOT EXISTS(SELECT 1
						    FROM  hr_assignment_set_amendments hasa
							 ,  hr_assignment_sets has
							 ,  per_assignments_f paf
						--	 ,  pay_payrolls_f pay
						--	 ,  hr_soft_coding_keyflex hflex
					  WHERE has.assignment_set_id = hasa.assignment_set_id
					  AND   has.business_group_id = l_bg_id
					  AND   has.assignment_set_id = l_assignment_set_id
					  AND   hasa.assignment_id    = paf.assignment_id
					  AND   paf.person_id         = paaf.person_id
					  --AND   paf.payroll_id        = pay.payroll_id
					  --AND   pay.soft_coding_keyflex_id = hflex.soft_coding_keyflex_id
					  --AND   hflex.segment4 = l_segment4
					  )))
	       OR l_assignment_set_id IS NULL)
	       AND NOT EXISTS (
			SELECT 1
			  FROM pay_assignment_actions paa_p35,
				 pay_payroll_actions ppa_p35,
				 per_assignments_f paaf_p35,
				 pay_all_payrolls_f ppf_p35,
				hr_soft_coding_keyflex flex_p35,
				pay_action_interlocks plock
			 WHERE ppa_p35.report_type = 'IEP35MAG'
			   AND paa_p35.action_status = 'C'
			   AND TO_DATE (
				    pay_ie_p35.get_parameter (
					 ppa_p35.payroll_action_id,
					 'END_DATE'
				    ),
				    'YYYY/MM/DD'
				 ) BETWEEN l_start_date AND l_end_date
			   AND ppa_p35.payroll_action_id = paa_p35.payroll_action_id
			   --AND paa_p35.assignment_id = asg.assignment_id
			   AND paa_p35.assignment_id = paaf_p35.assignment_id
			   AND paaf_p35.person_id = paaf.person_id
			   AND paa_p35.assignment_action_id = plock.locking_action_id
			   AND plock.locked_action_id IN (SELECT assignment_action_id FROM pay_assignment_actions
			                                  WHERE assignment_id=paaf.assignment_id)
			   AND paaf_p35.payroll_id = ppf_p35.payroll_id
			   AND ppf_p35.soft_coding_keyflex_id = flex_p35.soft_coding_keyflex_id
			   AND flex_p35.segment4 = l_segment4);




   BEGIN

	hr_utility.set_location ('pactid passed to action creation::'||      pactid     ||'::' ,910);
	hr_utility.set_location ('stperson passed to action creation::'||stperson , 920);
	hr_utility.set_location ('endperson passed to action creation::'||endperson,930);
	hr_utility.set_location ('CHUNK passed to action creation::'||CHUNK ,940);
      hr_utility.set_location (l_proc_name, 10);

     --  l_end_date := pay_ie_p35.get_end_date;


      l_out_var :=
            pay_ie_p35.get_parameter (
               p_payroll_action_id=> pactid,
               p_token_name=> 'END_DATE'
            );
      l_end_date := TO_DATE (l_out_var, 'YYYY/MM/DD');                                     --4641756

      l_start_date := pay_ie_p35.get_start_date;

      l_out_var := pay_ie_p35.get_parameter (
                      p_payroll_action_id=> pactid,
                      p_token_name=> 'BG_ID'
                   );

      l_bg_id := TO_NUMBER (l_out_var);

      hr_utility.set_location (   'Start date -'
                               || TO_CHAR (l_start_date), 11);
      hr_utility.set_location (   'End  date  -'
                               || TO_CHAR (l_end_date), 12);
      hr_utility.set_location (   'Bus Group id  -'
                               || TO_CHAR (l_bg_id), 13);


      --
      l_segment4 := pay_ie_p35.get_parameter( p_payroll_action_id=> pactid,
                                              p_token_name=> 'EMP_NO');
      l_out_var := pay_ie_p35.get_parameter (
                      p_payroll_action_id=> pactid,
                      p_token_name=> 'ASSIGNMENT_SET_ID'
                   );
      l_assignment_set_id := to_number(l_out_var);
      --bug 6642916
       l_out_var := pay_ie_p35.get_parameter (
			    p_payroll_action_id=> pactid,
			    p_token_name=> 'PAYROLL'
			 );
	l_payroll_id := to_number(l_out_var);

OPEN csr_get_flag_from_set;
      FETCH csr_get_flag_from_set into l_set_flag;
      CLOSE csr_get_flag_from_set;

 FOR c_rec in csr_locked_asgs
 LOOP
	hr_utility.set_location ('Selected assignment ::'||  c_rec.assignment_id || ' ::and  action ::passed to action creation::'||
				c_rec.assignment_action_id||'::',960);
	hr_utility.set_location ('Selected payroll_action::'||c_rec.payroll_action_id ,960);

	 SELECT pay_assignment_actions_s.NEXTVAL
           INTO l_actid
           FROM DUAL;

         -- insert into pay_assignment_actions.
         hr_nonrun_asact.insact (
            l_actid,
            c_rec.assignment_id,
            pactid,
            CHUNK,
            NULL
         );

	hr_utility.set_location ('Created aact::'||l_actid ||' for assignment::'|| c_rec.assignment_id ||':: and aact::'||
				c_rec.assignment_action_id||'::',970);

         hr_nonrun_asact.insint ( l_actid,c_rec.assignment_action_id);
	 --Fnd_file.put_line(FND_FILE.LOG,'Locked Assignment Action ID'||c_rec.assignment_action_id );
	 hr_utility.set_location ('Locked Assignment Action ID::'||c_rec.assignment_action_id ||' :: using aact::'||l_actid,980);
	l_arc_payroll_action_id := c_rec.payroll_action_id;

END LOOP;
--Fnd_file.put_line(FND_FILE.LOG,l_arc_payroll_action_id );

   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_location ('Error in assignment action code ', 100);
         RAISE;
END action_creation;

--
   FUNCTION get_start_date
      RETURN DATE
   AS
      l_start_date   DATE;
   BEGIN
      SELECT fnd_date.canonical_to_date (
                   SUBSTR (fpov.profile_option_value, 1, 4)
                || '01/01 00:00:00'
             )
        INTO l_start_date
        FROM fnd_profile_option_values fpov, fnd_profile_options fpo
       WHERE fpo.profile_option_id = fpov.profile_option_id
         AND fpo.application_id = fpov.application_id
         AND fpo.profile_option_name = 'PAY_IE_P35_REPORTING_YEAR'
         AND fpov.level_id = 10001
         AND fpov.level_value = 0;

      RETURN l_start_date;
   END get_start_date;


--
   FUNCTION get_end_date
      RETURN DATE
   AS
      l_end_date   DATE;
   BEGIN
      SELECT fnd_date.canonical_to_date (
                   SUBSTR (fpov.profile_option_value, 1, 4)
                || '12/31 23:59:59'
             )
        INTO l_end_date
        FROM fnd_profile_option_values fpov, fnd_profile_options fpo
       WHERE fpo.profile_option_id = fpov.profile_option_id
         AND fpo.application_id = fpov.application_id
         AND fpo.profile_option_name = 'PAY_IE_P35_REPORTING_YEAR'
         AND fpov.level_id = 10001
         AND fpov.level_value = 0;

      RETURN l_end_date;
   END get_end_date;

/* Function for getting Pension Details */
FUNCTION get_pension_details(emp_rbs			IN OUT NOCOPY NUMBER,
				     emp_rbs_bal			IN OUT NOCOPY NUMBER,
				     empr_rbs			IN OUT NOCOPY NUMBER,
				     empr_rbs_bal			IN OUT NOCOPY NUMBER,
				     emp_prsa			IN OUT NOCOPY NUMBER,
				     emp_prsa_bal			IN OUT NOCOPY NUMBER,
				     empr_prsa			IN OUT NOCOPY NUMBER,
				     empr_prsa_bal		IN OUT NOCOPY NUMBER,
				     emp_rac			IN OUT NOCOPY NUMBER,
				     emp_rac_bal			IN OUT NOCOPY NUMBER,
				     p_payroll_action_id	NUMBER,
				     p_taxable_benefits		IN OUT NOCOPY NUMBER) RETURN NUMBER IS
cursor get_pension_details is
select count(decode(pact.action_information2,0,null,null,null,1)) EMP_RBS,
       sum(to_number(pact.action_information2))*100 EMP_RBS_BAL,
       count(decode(pact.action_information3,0,null,null,null,1)) EMPR_RBS,
	 sum(to_number(pact.action_information3))*100 EMPR_RBS_BAL,
       count(decode(pact.action_information4,0,null,null,null,1)) EMP_PRSA,
	 sum(to_number(pact.action_information4))*100 EMP_PRSA_BAL,
       count(decode(pact.action_information5,0,null,null,null,1)) EMPR_PRSA,
	 sum(to_number(pact.action_information5))*100 EMPR_PRSA_BAL,
       count(decode(pact.action_information6,0,null,null,null,1)) EMP_RAC,
	 sum(to_number(pact.action_information6))*100 EMP_RAC_BAL,
	 sum(to_number(pact.action_information1))*100 TAXABLEBENEFITS

FROM   pay_assignment_actions  paa
      ,pay_action_information  pact
	,pay_action_interlocks   pai
  WHERE paa.payroll_action_id        = p_payroll_action_id
  AND   paa.source_action_id         IS NULL
  AND   pai.locking_action_id        = paa.assignment_action_id
  AND   pact.action_context_id       = pai.locked_action_id
  --AND   pact.action_context_id       = paa.assignment_action_id
  AND   pact.action_information_category  = 'IE P35 ADDITIONAL DETAILS'
  AND   pact.action_context_type           = 'AAP';
BEGIN
OPEN get_pension_details;
FETCH get_pension_details INTO emp_rbs,
					 emp_rbs_bal,
					 empr_rbs,
					 empr_rbs_bal,
					 emp_prsa,
					 emp_prsa_bal,
					 empr_prsa,
					 empr_prsa_bal,
					 emp_rac,
					 emp_rac_bal,
					 p_taxable_benefits


					;
CLOSE get_pension_details;
RETURN 1;
END get_pension_details;

FUNCTION get_car_park_details(     emp_parking			IN OUT NOCOPY NUMBER, /* knadhan */
				     emp_parking_bal		 IN OUT NOCOPY NUMBER,
				     p_payroll_action_id      NUMBER,
				     empr_income_band IN OUT NOCOPY NUMBER
				     ) RETURN NUMBER IS
cursor get_car_park_details is
select 	 count(decode(pact.action_information23,0,null,null,null,1)) EMP_PARKING,  /* knadhan */
	 sum(to_number(pact.action_information23))*100 EMP_PARKING_BAL ,
        nvl((sum(to_number(pact.action_information19))*100),0) empr_income_band  /* sum of first band, second band and third band values */
FROM   pay_assignment_actions  paa
      ,pay_action_information  pact
	,pay_action_interlocks   pai
  WHERE paa.payroll_action_id        = p_payroll_action_id
  AND   paa.source_action_id         IS NULL
  AND   pai.locking_action_id        = paa.assignment_action_id
  AND   pact.action_context_id       = pai.locked_action_id
  --AND   pact.action_context_id       = paa.assignment_action_id
  AND   pact.action_information_category  = 'IE P35 ADDITIONAL DETAILS'
  AND   pact.action_context_type           = 'AAP';
BEGIN
OPEN get_car_park_details;
FETCH get_car_park_details INTO  emp_parking, /* knadhan */
					 emp_parking_bal,
					 empr_income_band
					 ;
CLOSE get_car_park_details;
RETURN 1;
END get_car_park_details;

FUNCTION raise_warning(l_flag	varchar2) return number is
l_status BOOLEAN;
BEGIN
IF l_flag = 'Y' THEN
	l_status := FND_CONCURRENT.SET_COMPLETION_STATUS
		 (
		  status => 'WARNING',
		  message => 'PRSI Insurable Weeks exceed max limit. Please Check the Log File for more details'
		 );
END IF;
return 1;
END raise_warning;

-- For bug 6275544
FUNCTION test_XML(P_STRING VARCHAR2) RETURN VARCHAR2 AS
l_string varchar2(300);
begin
l_string := p_string;

--
--Bug 6707467: call this code only for UTF8 characterset where special chars are supported at DB level
--Whenever a built in function like INSTR is called, the string is converted into the DB character set.
--In envs where special characters are not supported, Instr will treat 'a' and accented 'a' as the same and hence
--return > 0
--
--IF 'a' <> COMPOSE('a'|| UNISTR('\0301')) THEN
     IF Instr ('a', COMPOSE('a'|| UNISTR('\0301')) ) = 0 THEN

	l_string := replace(l_string,COMPOSE ('A'|| UNISTR('\0301')),'&#193;');

	l_string := replace(l_string,COMPOSE ('E'|| UNISTR('\0301')),'&#201;');

	l_string := replace(l_string,COMPOSE ('I'|| UNISTR('\0301')),'&#205;');

	l_string := replace(l_string,COMPOSE ('O'|| UNISTR('\0301')),'&#211;');

	l_string := replace(l_string,COMPOSE ('U'|| UNISTR('\0301')),'&#218;');

	l_string := replace(l_string,COMPOSE ('a'|| UNISTR('\0301')),'&#225;');
	l_string := replace(l_string,COMPOSE ('e'|| UNISTR('\0301')),'&#233;');

	l_string := replace(l_string,COMPOSE ('i'|| UNISTR('\0301')),'&#237;');

	l_string := replace(l_string,COMPOSE ('o'|| UNISTR('\0301')),'&#243;');

	l_string := replace(l_string,COMPOSE ('u'|| UNISTR('\0301')),'&#250;');
END IF;

RETURN l_string;
END ;

 END pay_ie_p35_magtape;

/
