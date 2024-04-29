--------------------------------------------------------
--  DDL for Package Body PAY_CA_RL1_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_RL1_MAG" AS
 /* $Header: pycarlmg.pkb 120.73.12010000.19 2009/12/28 10:00:44 sapalani ship $ */

   -- Name     : get_report_parameters

 -----------------------------------------------------------------------------
   --
   -- Purpose
   --   The procedure gets the 'parameter' for which the report is being
   --   run i.e., the period, state and business organization.
   --
   -- Arguments
   --	p_pactid		Payroll_action_id passed from pyugen process
   --   p_year_start		Start Date of the period for which the report
   --				has been requested
   --   p_year_end		End date of the period
   --   p_business_group_id	Business group for which the report is being run
   --   p_report_type		Type of report being run RL1
   --
   -- Notes
 ----------------------------------------------------------------------------


PROCEDURE get_report_parameters
	(	p_pactid    		IN NUMBER,
		p_year_start		IN OUT NOCOPY	DATE,
		p_year_end		IN OUT NOCOPY	DATE,
		p_report_type		IN OUT NOCOPY	VARCHAR2,
		p_business_group_id	IN OUT NOCOPY	NUMBER
	) IS
	BEGIN
		--hr_utility.trace_on('Y','RL1MAG');
		hr_utility.set_location('pay_ca_rl1_mag.get_report_parameters', 10);

		SELECT  ppa.start_date,
			ppa.effective_date,
		  	ppa.business_group_id,
		  	ppa.report_type
		  INTO  p_year_start,
	  		p_year_end,
			p_business_group_id,
			p_report_type
		  FROM  pay_payroll_actions ppa
	 	 WHERE  payroll_action_id = p_pactid;

		hr_utility.set_location('pay_ca_rl1_mag.get_report_parameters', 20);

END get_report_parameters;

FUNCTION convert_special_char( p_data varchar2)
RETURN varchar2 IS
   l_data VARCHAR2(2000);
   l_output varchar2(2000);
cursor c_uppercase(p_input_string varchar2) is
select
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(convert(p_input_string,'UTF8'),
           utl_raw.cast_to_varchar2(hextoraw('C380')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38A')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C387')),'C'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C389')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39C')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C399')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39B')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C394')),'O'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38F')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38E')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C388')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38B')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C382')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C592')),'OE'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C386')),'AE'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C3A9')),'e'
          )
from dual;

BEGIN
      l_data := trim(p_data);
      l_data := REPLACE(l_data, '&' , '&' || 'amp;');
      l_data := REPLACE(l_data, '<'     , '&' || 'lt;');
      l_data := REPLACE(l_data, '>'     , '&' || 'gt;');
      l_data := REPLACE(l_data, ''''    , '&' || 'apos;');
      l_data := REPLACE(l_data, '"'     , '&' || 'quot;');

      open c_uppercase(l_data);
      fetch c_uppercase into l_output;
      if c_uppercase%NOTFOUND then
          l_output := l_data;
      end if;
  close c_uppercase;

   RETURN l_output;
END;

PROCEDURE validate_transmitter_info(p_payroll_action_id IN NUMBER,
                                    p_bg_id             IN NUMBER,
                                    p_effective_date    IN DATE) IS
BEGIN

DECLARE

  CURSOR cur_arch_pactid(p_transmitter_org_id NUMBER) IS
  SELECT
    ppa.payroll_action_id
  FROM
    pay_payroll_actions ppa
  WHERE
    ppa.business_group_id = p_bg_id AND
    ppa.report_type = 'RL1' AND
    ppa.report_qualifier = 'CAEOYRL1' AND
    ppa.report_category = 'CAEOYRL1' AND
    ppa.effective_date = p_effective_date AND
    p_transmitter_org_id =
            pay_ca_rl1_mag.get_parameter('PRE_ORGANIZATION_ID',
                                         ppa.legislative_parameters);

  l_transmitter_number     VARCHAR2(30);
  l_transmitter_name       VARCHAR2(100);
  l_type_of_package        VARCHAR2(30);
  l_source_of_slips        VARCHAR2(30);
  dummy                    NUMBER;
  dummy1                   VARCHAR2(10);
  l_transmitter_org_id     NUMBER;
  l_arch_pactid            NUMBER;
  l_legislative_parameters pay_payroll_actions.legislative_parameters%TYPE;
  l_address_line1          hr_locations.address_line_1%TYPE;

  CURSOR cur_ppa IS
  SELECT
    ppa.legislative_parameters
  FROM
    pay_payroll_actions ppa
  WHERE
    ppa.payroll_action_id = p_payroll_action_id;

BEGIN

  OPEN cur_ppa;
  FETCH cur_ppa
  INTO  l_legislative_parameters;
  CLOSE cur_ppa;

  l_transmitter_org_id := pay_ca_rl1_mag.get_parameter('TRANSMITTER_PRE',
                                               l_legislative_parameters);

  hr_utility.trace('l_transmitter_org_id = ' || to_char(l_transmitter_org_id));
  hr_utility.trace('p_bg_id = ' || to_char(p_bg_id));
  hr_utility.trace('p_payroll_action_id = ' || to_char(p_payroll_action_id));
  hr_utility.trace('p_effective_date = ' || to_char(p_effective_date));

  OPEN cur_arch_pactid(l_transmitter_org_id);
  FETCH cur_arch_pactid
  INTO  l_arch_pactid;
  CLOSE cur_arch_pactid;

  l_transmitter_number := get_arch_val(l_arch_pactid,'CAEOY_RL1_TRANSMITTER_NUMBER');
  l_transmitter_name   := get_arch_val(l_arch_pactid,'CAEOY_RL1_TRANSMITTER_NAME');
  BEGIN

    hr_utility.trace('l_transmitter_number = ' || l_transmitter_number);
    SELECT substr(l_transmitter_number,1,2)
    INTO dummy1
    FROM dual;

    IF (dummy1 <> 'NP' OR
       length(l_transmitter_number) <> 8) THEN
      RAISE INVALID_NUMBER;
    END IF;

    SELECT to_number(substr(l_transmitter_number,3,6))
    INTO dummy
    FROM dual;

  EXCEPTION
   WHEN INVALID_NUMBER THEN
     hr_utility.set_message(800,'PAY_CA_RL1_INVALID_TRANSMITTER');
     hr_utility.set_message_token('PRE_NAME',l_transmitter_name);
     pay_core_utils.push_message(800,'PAY_CA_RL1_INVALID_TRANSMITTER','P');
     pay_core_utils.push_token('PRE_NAME',l_transmitter_name);
     hr_utility.raise_error;
  END;

  l_type_of_package :=  get_arch_val(l_arch_pactid,'CAEOY_RL1_TRANSMITTER_PACKAGE_TYPE');

  hr_utility.trace('l_type_of_package = ' || l_type_of_package);

  IF l_type_of_package IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_TYPE_OF_PKG','P');
     hr_utility.raise_error;
  END IF;

  l_source_of_slips := get_arch_val(l_arch_pactid,'CAEOY_RL1_SOURCE_OF_SLIPS');
  hr_utility.trace('l_source_of_slips = ' || l_source_of_slips);

  IF l_source_of_slips IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_RLSLIP_SRC','P');
     hr_utility.raise_error;
  END IF;

  l_address_line1 := get_arch_val(l_arch_pactid,'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE1');
  hr_utility.trace('l_address_line1 = ' || l_address_line1);

  IF l_address_line1 IS NULL THEN
     pay_core_utils.push_message(800,'PAY_CA_RL1_MISSING_TRNMTR_ADDR','P');
     hr_utility.raise_error;
  END IF;

END;

END validate_transmitter_info;


----------------------------------------------------------------------------
  --Name
  --  range_cursor
  --Purpose
  --  This procedure defines a SQL statement
  --  to fetch all the people to be included in the report. This SQL statement
  --  is  used to define the 'chunks' for multi-threaded operation
  --Arguments
  --  p_pactid			payroll action id for the report
  --  p_sqlstr			the SQL statement to fetch the people
------------------------------------------------------------------------------
PROCEDURE range_cursor (
	p_pactid	IN	   NUMBER,
	p_sqlstr	OUT NOCOPY VARCHAR2
)
IS
	p_year_start			DATE;
	p_year_end			DATE;
	p_business_group_id		NUMBER;
	p_report_type			VARCHAR2(30);

BEGIN
       -- hr_utility.trace_on(null,'PDF');
	hr_utility.set_location( 'pay_ca_rl1_mag.range_cursor', 10);

	get_report_parameters(
		p_pactid,
		p_year_start,
		p_year_end,
		p_report_type,
		p_business_group_id
	);

	hr_utility.set_location( 'pay_ca_rl1_mag.range_cursor', 20);


	p_sqlstr := 'select distinct to_number(fai1.value)
        from    ff_archive_items fai1,
    		ff_database_items fdi1,
    		ff_archive_items fai2,
    		ff_database_items fdi2,
    		pay_assignment_actions  paa,
    		pay_payroll_actions     ppa,
    		pay_payroll_actions     ppa1,
                hr_organization_information hoi
      	where  ppa1.payroll_action_id    = :payroll_action_id
      	and    ppa.business_group_id+0 = ppa1.business_group_id
      	and    ppa.effective_date = ppa1.effective_date
      	and    ppa.report_type = ''RL1''
      	and    ppa.payroll_action_id = paa.payroll_action_id
      	and    fdi2.user_name = ''CAEOY_TAXATION_YEAR''
      	and    fai2.user_entity_id = fdi2.user_entity_id
      	and    fai2.value = pay_ca_rl1_mag.get_parameter(''REPORTING_YEAR'',ppa1.legislative_parameters)
      	and    paa.payroll_action_id= fai2.context1
      	and    paa.action_status = ''C''
      	and    paa.assignment_action_id = fai1.context1
      	and    fai1.user_entity_id = fdi1.user_entity_id
      	and    fdi1.user_name = ''CAEOY_PERSON_ID''
        and    decode(hoi.org_information3, ''Y'', hoi.organization_id, hoi.org_information20) =
               pay_ca_rl1_mag.get_parameter(''TRANSMITTER_PRE'', ppa1.legislative_parameters )
        and    hoi.org_information_context =''Prov Reporting Est''
        and    hoi.organization_id = pay_ca_rl1_mag.get_parameter(''PRE_ORGANIZATION_ID'', ppa.legislative_parameters )
	order by to_number(fai1.value)'  ;

	hr_utility.set_location( 'pay_ca_rl1_mag.range_cursor',40);

END range_cursor;

  -------------------------------------------------------------------------------
  --Name
  --  create_assignment_act
  --Purpose
  --  Creates assignment actions for the payroll action associated with the
  --  report
  --Arguments
  --  p_pactid				payroll action for the report
  --  p_stperson			starting person id for the chunk
  --  p_endperson			last person id for the chunk
  --  p_chunk				size of the chunk
  --Note
  --  The procedure processes assignments in 'chunks' to facilitate
  --  multi-threaded operation. The chunk is defined by the size and the
  --  starting and ending person id. An interlock is also created against the
  --  pre-processor assignment action to prevent rolling back of the archiver.
  ------------------------------------------------------------------------------
PROCEDURE create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson     IN NUMBER,
	p_chunk 	IN NUMBER )
IS

	-- Cursor to retrieve all the assignments for all GRE's
	-- archived in a reporting year

	CURSOR c_all_asg IS
    	SELECT 	paf.person_id,
      	   	paf.assignment_id,
      	   	paa.tax_unit_id,
      	   	paf.effective_end_date,
      	   	paa.assignment_action_id,
                ppa.payroll_action_id      -- Added by ssmukher for Bug 3353115
    	FROM 	pay_payroll_actions ppa,
	        pay_assignment_actions paa,
	        per_all_assignments_f paf,
      		pay_payroll_actions ppa1,
                hr_organization_information hoi
	WHERE ppa1.payroll_action_id = p_pactid
	  AND ppa.report_type = 'RL1'
	  AND ppa.business_group_id+0 = ppa1.business_group_id
	  AND ppa.effective_date = ppa1.effective_date
	  AND paa.payroll_action_id = ppa.payroll_action_id
	  AND paa.action_status = 'C'
	  AND paf.assignment_id = paa.assignment_id
	  AND paf.person_id BETWEEN p_stperson AND p_endperson
--	  AND paf.assignment_type = 'E'
	  AND paf.effective_start_date <= ppa.effective_date
	  AND paf.effective_end_date >= ppa.start_date
          and decode(hoi.org_information3, 'Y', hoi.organization_id, hoi.org_information20) =
              substr(ppa1.legislative_parameters,
                     instr(ppa1.legislative_parameters,'TRANSMITTER_PRE=')+16)
          and hoi.org_information_context = 'Prov Reporting Est'
          and hoi.organization_id =
              substr(ppa.legislative_parameters,
                     instr(ppa.legislative_parameters,'PRE_ORGANIZATION_ID=')+20)
          and paf.effective_end_date = (select max(paf1.effective_end_date)
                                        from per_all_assignments_f paf1
                                        where paf1.assignment_id = paf.assignment_id
                                        and paf1.effective_start_date <= ppa1.effective_date);

	--local variables

	l_year_start DATE;
	l_year_end   DATE;
	l_effective_end_date	DATE;
	l_report_type		VARCHAR2(30);
	l_business_group_id	NUMBER;
	l_person_id		NUMBER;
	l_assignment_id		NUMBER;
	l_assignment_action_id	NUMBER;
	l_value		        NUMBER;
	l_tax_unit_id		NUMBER;
	lockingactid		NUMBER;

/* Added by ssmukher for Bug 3353115 */
        l_prev_payact           NUMBER;
        l_payroll_act           NUMBER;
        l_quebec_val            VARCHAR2(20);
        l_quebec_no             VARCHAR2(20);
        l_quebec_name           VARCHAR2(240);
        l_return                NUMBER;

BEGIN

--      hr_utility.trace_on('Y','RL1MAG');

        l_prev_payact := -1;
	hr_utility.set_location( 'pay_ca_rl1_mag.create_assignement_act',10);

	get_report_parameters(
		p_pactid,
		l_year_start,
		l_year_end,
		l_report_type,
		l_business_group_id
		);

        validate_transmitter_info(p_pactid,
                                  l_business_group_id,
                                  l_year_end);

	hr_utility.set_location( 'pay_ca_rl1_mag.create_assignement_act',20);

	--IF l_report_type = 'PYRL1MAG' THEN

		OPEN c_all_asg;
		LOOP
		   FETCH c_all_asg INTO l_person_id,
		 		        l_assignment_id,
		 	 	        l_tax_unit_id,
		 		        l_effective_end_date,
              			        l_assignment_action_id,
                                        l_payroll_act;

		   hr_utility.set_location('pay_ca_rl1_mag.create_assignement_act', 30);

		   EXIT WHEN c_all_asg%NOTFOUND;

                       /* Added by ssmukher for validating the
                          Quebec Identification Number */

                   if l_prev_payact <> l_payroll_act then
                        hr_utility.trace('The payroll action id '||l_payroll_act);

                        l_prev_payact := l_payroll_act;
                        l_quebec_val  := get_arch_val(l_payroll_act,'CAEOY_RL1_QUEBEC_BN');
                        l_quebec_name  := get_arch_val(l_payroll_act,'CAEOY_RL1_EMPLOYER_NAME');

                        hr_utility.trace('The Quebec Number is '||l_quebec_val);

                        l_quebec_no   := substr(l_quebec_val ,1,10);

                        hr_utility.trace('First 10 digits of the QIN: '||l_quebec_no);
			hr_utility.trace('l_quebec_name ='|| l_quebec_name);
                        l_return := validate_quebec_number(l_quebec_val,l_quebec_name);

                   end if ;

		--Create the assignment action for the record

		  hr_utility.trace('Assignment Fetched  - ');
		  hr_utility.trace('Assignment Id : '|| to_char(l_assignment_id));
		  hr_utility.trace('Person Id :  '|| to_char(l_person_id));
		  hr_utility.trace('tax unit id : '|| to_char(l_tax_unit_id));
		  hr_utility.trace('Effective End Date :  '|| to_char(l_effective_end_date));
		  hr_utility.set_location('pay_ca_rl1_mag.create_assignement_act', 40);

	            SELECT pay_assignment_actions_s.nextval
		    INTO lockingactid
		    FROM dual;

	            hr_utility.set_location('pay_ca_rl1_mag.create_assignement_act', 50);
		    hr_nonrun_asact.insact(lockingactid,
                                           l_assignment_id,
                                           p_pactid,
                                           p_chunk,
                                           l_tax_unit_id);


               /* Update the serial number column with the person id
                   */

               -- hr_utility.trace('updating asg. action');

               update pay_assignment_actions aa
                  set aa.serial_number = to_char(l_person_id)
                where  aa.assignment_action_id = lockingactid;

		    hr_utility.set_location('pay_ca_rl1_mag.create_assignement_act', 60);
       		    hr_nonrun_asact.insint(lockingactid, l_assignment_action_id);
		    hr_utility.set_location('pay_ca_rl1_mag.create_assignement_act', 70);
		    hr_utility.trace('Interlock Created  - ');
		    hr_utility.trace('Locking Action : '|| to_char(lockingactid));
		    hr_utility.trace('Locked Action :  '|| to_char(l_assignment_action_id));
		END LOOP;
		CLOSE c_all_asg;

	-- END IF;

END create_assignment_act;

function get_parameter(name in varchar2, parameter_list varchar2) return varchar2 is
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

/* Added by ssmukher for Bug 3353115 */
/* The check digit calculated by the method below
must be the same as the 10th digit of the
identification number or the number is invalid.

Example of the modulus 11 method:
The identification number is 2345678908.
Use the first nine digits to validate the identification number.
The tenth digit is the check digit (in this case 8).

Formula:
Beginning with the ninth digit (extreme right), multiply each digit by the
factor indicated.
The factors form a circular sequence of the values 2 through 7, beginning on
the right.
First nine digits of the identification number 2 3 4 5 6 7 8 9 0
Multiply each digit by the factor indicated. x 4 x 3 x 2 x 7 x 6 x 5 x 4 x 3
x 2
Results 8 9 8 35 36 35 32 27 0
Add the results
(8 + 9 + 8 + 35 + 36 + 35 + 32 + 27 + 0). = 190
Divide the result by 11 (190/11). = 17 remainder 3
If the remainder is 0, the check digit is 1. If the remainder is 1, the check
digit is 0.
For any other remainder obtained, the check digit is the difference between
11 and that remainder.
Subtract the remainder obtained from 11 (11 -  3) = 8
*/

FUNCTION validate_quebec_number (p_quebec_no IN VARCHAR2,p_qin_name varchar2)
RETURN NUMBER IS

l_quebec	 NUMBER;
l_rem		 NUMBER;
i		 NUMBER;
l_max		 NUMBER;
l_total		 NUMBER;
l_min		 NUMBER;
l_modulus	 NUMBER;
l_chk_digit	 NUMBER;
l_act_chk_number NUMBER;

BEGIN
     i        := 1;
     l_min    := 2;
     l_max    := 7;
     l_total  := 0;

     l_act_chk_number := to_number(substr(p_quebec_no,10,1));
     hr_utility.trace('here1');
     if TRANSLATE(p_quebec_no,'0123456789','9999999999') = '9999999999RS9999' then
        l_quebec := to_number(substr(p_quebec_no,1,9));
        loop
            if i > 9 then
               exit;
            end if;

	    if l_min > l_max then
	       l_min := 2;
	    end if;

	    l_rem    := mod(l_quebec,10);
	    l_total  := l_total + (l_min * l_rem);
            l_min    := l_min + 1;
	    l_quebec := ((l_quebec - l_rem)/10);
	    i        := i+ 1;

        end loop;

        l_modulus := mod(l_total, 11);
        if l_modulus = 0 then
           l_chk_digit := 1;
        elsif l_modulus = 1 then
           l_chk_digit := 0;
        else
           l_chk_digit := 11 - l_modulus;
        end if;

        if  l_chk_digit <> l_act_chk_number then
          hr_utility.set_message(801,'PAY_74156_INCORRECT_QIN_INFO');
          hr_utility.set_message_token('PRE_NAME',p_qin_name);
          pay_core_utils.push_message(801,'PAY_74156_INCORRECT_QIN_INFO','P');
          pay_core_utils.push_token('PRE_NAME',p_qin_name);
          hr_utility.raise_error;
        end if;
     else

          hr_utility.set_message(801,'PAY_74156_INCORRECT_QIN_INFO');
          hr_utility.set_message_token('PRE_NAME',p_qin_name);
          pay_core_utils.push_message(801,'PAY_74156_INCORRECT_QIN_INFO','P');
          pay_core_utils.push_token('PRE_NAME',p_qin_name);
          hr_utility.raise_error;

     end if;

     return l_chk_digit;

END;

FUNCTION get_arch_val(p_context_id IN NUMBER,
                      p_user_name  IN VARCHAR2)
RETURN varchar2 IS

cursor cur_archive (b_context_id NUMBER, b_user_name VARCHAR2) is
select fai.value
from   ff_archive_items fai,
       ff_database_items fdi
where  fai.user_entity_id = fdi.user_entity_id
and    fai.context1  = b_context_id
and    fdi.user_name = b_user_name;

l_return  VARCHAR2(240);

BEGIN
    open cur_archive(p_context_id,p_user_name);
    fetch cur_archive into l_return;
    close cur_archive;

    return (l_return);
END;

  PROCEDURE xml_transmitter_record IS
  BEGIN

  DECLARE

    l_final_xml CLOB;
    l_final_xml_string VARCHAR2(32000);
    l_is_temp_final_xml VARCHAR2(2);

    TYPE transmitter_info IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    tab_transmitter transmitter_info;

    lAnnee       NUMBER;
    lTypeEnvoi   NUMBER;
    lProvenance  NUMBER;
    lNo          NUMBER;
    lType        NUMBER;
    lNom1        NUMBER;
    lNom2        NUMBER;
    lLigne1      NUMBER;
    lLigne2      NUMBER;
    lVille       NUMBER;
    lProvince    NUMBER;
    lCodePostal  NUMBER;
    lNom         NUMBER;
    lIndRegional NUMBER;
    lTel         NUMBER;
    lPosteTel    NUMBER;
    lLangue      NUMBER;
    lANom        NUMBER;
    lAIndRegional NUMBER;
    lATel         NUMBER;
    lAPosteTel    NUMBER;
    lALangue      NUMBER;
    lNoConcepteur       NUMBER;

    EOL                 VARCHAR2(5);
    l_address_line      hr_locations.address_line_1%TYPE;
    l_contact           VARCHAR2(60);
    l_transmitter_name  VARCHAR2(100);
    l_context1          ff_archive_items.context1%TYPE;
    l_taxation_year     VARCHAR2(4);
    l_return            VARCHAR2(60);
    l_certification_no  VARCHAR2(30);
    l_VersionSchema     VARCHAR2(20);

  BEGIN

    hr_utility.trace('XML Transmitter');

    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lAnnee        := 1;
    lTypeEnvoi    := 2;
    lProvenance   := 3;
    lNo           := 4;
    lType         := 5;
    lNom1         := 6;
    lNom2         := 7;
    lLigne1       := 8;
    lLigne2       := 9;
    lVille        := 10;
    lProvince     := 11;
    lCodePostal   := 12;
    lNom          := 13;
    lIndRegional  := 14;
    lTel          := 15;
    lPosteTel     := 16;
    lLangue       := 17;
    lANom         := 18;
    lAIndRegional := 19;
    lATel         := 20;
    lAPosteTel    := 21;
    lALangue      := 22;
    lNoConcepteur := 23;

    l_taxation_year
        := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');
    l_context1
        := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');

    hr_utility.trace('XML Transmitter: l_taxation_year = ' || l_taxation_year);
    hr_utility.trace('XML Transmitter: l_context1 = ' || to_char(l_context1));


    -- Annee
    tab_transmitter(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' ||EOL;
    hr_utility.trace('tab_transmitter(lAnnee) = ' || tab_transmitter(lAnnee));

    -- TypeEnvoi
    tab_transmitter(lTypeEnvoi) := '<TypeEnvoi>' ||
         pay_ca_archive_utils.get_archive_value(l_context1,
               'CAEOY_RL1_TRANSMITTER_PACKAGE_TYPE') || '</TypeEnvoi>' || EOL;
    hr_utility.trace('tab_transmitter(lTypeEnvoi) = ' ||
                                           tab_transmitter(lTypeEnvoi));

    tab_transmitter(lProvenance) := '<Provenance>' ||
         pay_ca_archive_utils.get_archive_value(l_context1,
                    'CAEOY_RL1_SOURCE_OF_SLIPS') || '</Provenance>' || EOL;

    hr_utility.trace('tab_transmitter(lProvenance) = ' || tab_transmitter(lProvenance));

    tab_transmitter(lNo) := '<No>' ||
         pay_ca_archive_utils.get_archive_value(l_context1,
                    'CAEOY_RL1_TRANSMITTER_NUMBER') || '</No>' || EOL;

    hr_utility.trace('tab_transmitter(lNo) = ' || tab_transmitter(lNo));

    l_return := pay_ca_archive_utils.get_archive_value(l_context1,
                    'CAEOY_RL1_TRANSMITTER_TYPE');
    IF l_return IS NOT NULL THEN
      tab_transmitter(lType) := '<Type>' || l_return || '</Type>' || EOL;
    ELSE
      tab_transmitter(lType) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lType) = ' || tab_transmitter(lType));

    l_transmitter_name := pay_ca_archive_utils.get_archive_value(l_context1,
                                            'CAEOY_RL1_TRANSMITTER_NAME');

    tab_transmitter(lNom1) := '<Nom1>' ||
                    convert_special_char(substr(l_transmitter_name,1,30)) || '</Nom1>' || EOL;

    hr_utility.trace('tab_transmitter(lNom1) = ' || tab_transmitter(lNom1));

    l_return := substr(l_transmitter_name,31,30);
    IF l_return IS NOT NULL THEN
      tab_transmitter(lNom2) := '<Nom2>' || convert_special_char(l_return) || '</Nom2>' || EOL;
    ELSE
      tab_transmitter(lNom2) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lNom2) = ' || tab_transmitter(lNom2));

    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE1');

    tab_transmitter(lLigne1) := '<Ligne1>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ligne1>' || EOL;

    hr_utility.trace('tab_transmitter(lLigne1) = ' || tab_transmitter(lLigne1));

    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE2');

    IF l_address_line IS NOT NULL THEN
      tab_transmitter(lLigne2) := '<Ligne2>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ligne2>' || EOL;
    ELSE
      tab_transmitter(lLigne2) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lLigne2) = ' || tab_transmitter(lLigne2));

    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_TRANSMITTER_CITY');

    IF l_address_line IS NOT NULL THEN
      tab_transmitter(lVille) := '<Ville>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ville>' || EOL;
    ELSE
      tab_transmitter(lVille) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lVille) = ' || tab_transmitter(lVille));

    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_TRANSMITTER_PROVINCE');

    tab_transmitter(lProvince) := '<Province>' ||
                   SUBSTR(hr_general.decode_lookup(
                   'CA_PROVINCE',l_address_line),1,20) || '</Province>' || EOL;

    hr_utility.trace('tab_transmitter(lProvince) = ' || tab_transmitter(lProvince));

    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_TRANSMITTER_POSTAL_CODE');

    tab_transmitter(lCodePostal) := '<CodePostal>' ||
             substr(replace(l_address_line,' '),1,6) || '</CodePostal>' || EOL;

    hr_utility.trace('tab_transmitter(lCodePostal) = ' || tab_transmitter(lCodePostal));

    l_contact :=  pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_TECHNICAL_CONTACT_NAME');

    IF l_contact IS NOT NULL THEN
      tab_transmitter(lNom) := '<Nom>' ||
             substr(l_contact,1,30) || '</Nom>' || EOL;
    ELSE
      tab_transmitter(lNom) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lNom) = ' || tab_transmitter(lNom));

    l_contact := pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_TECHNICAL_CONTACT_AREA_CODE');

    IF l_contact IS NOT NULL THEN
      tab_transmitter(lIndRegional) := '<IndRegional>' ||
                                         l_contact || '</IndRegional>' || EOL;
    ELSE
      tab_transmitter(lIndRegional) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lIndRegional) = ' || tab_transmitter(lIndRegional));

    l_contact := pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_TECHNICAL_CONTACT_PHONE');
    IF l_contact IS NOT NULL THEN
      l_contact := substr(l_contact,1,3) || '-' || substr(l_contact,4,4);
      tab_transmitter(lTel) := '<Tel>' || l_contact || '</Tel>' || EOL;
    ELSE
      tab_transmitter(lTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lTel) = ' || tab_transmitter(lTel));

    l_contact := pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_TECHNICAL_CONTACT_EXTENSION');

    IF l_contact IS NOT NULL THEN
      tab_transmitter(lPosteTel) := '<PosteTel>' || l_contact ||
                                  '</PosteTel>' || EOL;
    ELSE
      tab_transmitter(lPosteTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lPosteTel) = ' ||
                            tab_transmitter(lPosteTel));

    l_contact :=  pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_TECHNICAL_CONTACT_LANGUAGE');

   IF l_contact IS NOT NULL THEN
    tab_transmitter(lLangue) := '<Langue>' ||l_contact || '</Langue>' || EOL;
   ELSE
     tab_transmitter(lLangue) := NULL;
   END IF;

   l_contact :=  pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_ACCOUNTING_CONTACT_NAME');

    IF l_contact IS NOT NULL THEN
      tab_transmitter(lANom) := '<Nom>' ||
             convert_special_char(substr(l_contact,1,30)) || '</Nom>' || EOL;
    ELSE
      tab_transmitter(lANom) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lANom) = ' || tab_transmitter(lANom));

    l_contact := pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_ACCOUNTING_CONTACT_AREA_CODE');

    IF l_contact IS NOT NULL THEN
      tab_transmitter(lAIndRegional) := '<IndRegional>' || l_contact ||
                                      '</IndRegional>' || EOL;
    ELSE
      tab_transmitter(lAIndRegional) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lAIndRegional) = ' || tab_transmitter(lAIndRegional));

    l_contact := pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_ACCOUNTING_CONTACT_PHONE');

    IF l_contact IS NOT NULL THEN
      l_contact := substr(l_contact,1,3) || '-' || substr(l_contact,4,4);
      tab_transmitter(lATel) := '<Tel>' || l_contact || '</Tel>' || EOL;
    ELSE
      tab_transmitter(lATel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lATel) = ' || tab_transmitter(lATel));

    l_contact :=  pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_ACCOUNTING_CONTACT_EXTENSION');

    IF l_contact IS NOT NULL THEN
      tab_transmitter(lAPosteTel) := '<PosteTel>' || l_contact ||
                                     '</PosteTel>' || EOL;
    ELSE
      tab_transmitter(lAPosteTel) := NULL;
    END IF;
    hr_utility.trace('tab_transmitter(lAPosteTel) = ' ||
                                      tab_transmitter(lAPosteTel));

    l_contact := pay_ca_archive_utils.get_archive_value(l_context1,
          'CAEOY_RL1_ACCOUNTING_CONTACT_LANGUAGE');
    IF l_contact IS NOT NULL THEN
      tab_transmitter(lALangue) := '<Langue>' || l_contact ||
                                   '</Langue>' || EOL;
    ELSE
      tab_transmitter(lALangue) := NULL;
    END IF;

    hr_utility.trace('tab_transmitter(lALangue) = ' || tab_transmitter(lALangue));

    -- For bug 6738509
    if(l_taxation_year = '2006') then
      l_certification_no := 'RQ-06-01-098';
    elsif(l_taxation_year = '2007') then
      l_certification_no := 'RQ-07-01-146';
    elsif(l_taxation_year = '2008') then
      l_certification_no := 'RQ-08-01-114';
    elsif(l_taxation_year = '2009') then
      l_certification_no := 'RQ-09-01-047'; -- Bug 9206928
    else
      l_certification_no := 'RQ-09-99-999'; --For Bug 9037784
    end if;
    -- End bug 6738509

    tab_transmitter(lNoConcepteur) :=
                     '<NoCertification>'|| convert_special_char(l_certification_no)
                                     ||'</NoCertification>'|| EOL;

    -- Bug 	7602718
    if(l_taxation_year = '2006') then
      l_VersionSchema := '2006.1.2';
    elsif(l_taxation_year = '2007') then
      l_VersionSchema := '2007.1.1';
    else
      l_VersionSchema := trim(l_taxation_year)||'.1';
    end if;
    -- End

    l_final_xml_string :=
                   '<Transmission VersionSchema="'||l_VersionSchema||'" ' ||
                   'pxmlns="http://www.mrq.gouv.qc.ca/T5">' || EOL ||
                   '<P>' || EOL ||
                   tab_transmitter(lAnnee) ||
                   tab_transmitter(lTypeEnvoi) ||
                   tab_transmitter(lProvenance) || '<Preparateur>' || EOL ||
                   tab_transmitter(lNo) ||
                   tab_transmitter(lType) ||
                   tab_transmitter(lNom1) ||
                   tab_transmitter(lNom2) || '<Adresse>' || EOL ||
                   tab_transmitter(lLigne1) ||
                   tab_transmitter(lLigne2) ||
                   tab_transmitter(lVille) ||
                   tab_transmitter(lProvince) ||
                   tab_transmitter(lCodePostal) || '</Adresse>' || EOL ||
                   '</Preparateur>' || EOL || '<Informatique>' || EOL ||
                   tab_transmitter(lNom) ||
                   tab_transmitter(lIndRegional) ||
                   tab_transmitter(lTel) ||
                   tab_transmitter(lPosteTel) ||
                   tab_transmitter(lLangue) || '</Informatique>' || EOL ||
                   '<Comptabilite>' || EOL ||
                   tab_transmitter(lANom) ||
                   tab_transmitter(lAIndRegional) ||
                   tab_transmitter(lATel) ||
                   tab_transmitter(lAPosteTel) ||
                   tab_transmitter(lALangue) || '</Comptabilite>' || EOL ||
                   tab_transmitter(lNoConcepteur) ||
                   '</P>' || EOL;

    hr_utility.trace('xml_transmitter l_final_xml_string = ' ||
                        l_final_xml_string);
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_transmitter_record;

  PROCEDURE end_of_file is
  BEGIN

  DECLARE

    l_final_xml CLOB;
    l_final_xml_string VARCHAR2(32000);
    l_is_temp_final_xml VARCHAR2(2);

  BEGIN

    l_final_xml_string := '</Transmission>';

    hr_utility.trace('end_of_file l_final_xml_string = '
                                                 || l_final_xml_string );
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;

  END;

  /***************************************************************/

  /*************************** *******************************/

  PROCEDURE xml_employee_record IS
  BEGIN

  DECLARE
    /****************************************************/
    l_payroll_actid         NUMBER;
    l_rep_type             VARCHAR2(30);
    l_business_group_id	   NUMBER;
    l_year_start           DATE;
    l_year_end             DATE;
    l_legislative_param    pay_payroll_actions.legislative_parameters%type;
    l_arch_asg_actid       NUMBER;
    l_arch_pay_actid       NUMBER;
   -- l_asg_id               NUMBER;
    l_emplyr_final1    VARCHAR2(5000);
    l_emplyr_final2    VARCHAR2(5000);
    l_emplyr_final3    VARCHAR2(5000);
    --l_boxo_amount_cnt    NUMBER :=0;
    --l_xml_boxo_amount    VARCHAR2(200);
    --l_flag_seeattch      BOOLEAN;
   -- l_footnote           VARCHAR2(500);
    l_footnote_boxo1      VARCHAR2(1000);
    l_footnote_boxo2      VARCHAR2(1000);
    l_footnote_boxo3      VARCHAR2(1000);
    l_person_id1           NUMBER;
    l_session_date        DATE;
    lForm_number          NUMBER;
    l_neg_bal_exists      BOOlEAN := FALSE;


 CURSOR c_get_payroll_asg_actid(p_assg_actid NUMBER) IS
   SELECT
         to_number(substr(paa.serial_number,3,14)) asgactid , --archiver assignment action id
         to_number(substr(paa.serial_number,17,14)) payactid, --archiver payroll action id
         paa.assignment_id asgid
   FROM
         pay_assignment_actions paa
   WHERE paa.assignment_action_id = p_assg_actid;

  cursor c_province( p_arch_asact_id number ) is
   select fai.value
   from ff_archive_items fai,
        ff_database_items fdi
   where  fai.user_entity_id  = fdi.user_entity_id
   and 	fdi.user_name = 'CAEOY_RL1_PROVINCE_OF_EMPLOYMENT'
   and fai.context1 =p_arch_asact_id;

    l_page_break        VARCHAR2(50);
    l_final_xml_string1 VARCHAR2(32000);
    l_final_xml_string2 VARCHAR2(32000);
    l_final_xml_string3 VARCHAR2(32000);
    k                   NUMBER;
    addr pay_ca_rl1_reg.primaryaddress;
    /********************** ************************/
    l_final_xml CLOB;
    l_final_xml_string VARCHAR2(32000);
    l_is_temp_final_xml VARCHAR2(2);

    CURSOR cur_parameters(p_mag_asg_action_id NUMBER) IS
    SELECT
      pai.locked_action_id,  -- Archiver asg_action_id
      paa.assignment_id,
      pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id),
         -- date_earned
      fai.value -- Jurisdiction
    FROM
      ff_archive_items fai,
      ff_database_items fdi,
      per_all_people_f ppf,
      per_all_assignments_f paf,
      pay_action_interlocks pai,
      pay_assignment_actions paa,
      pay_payroll_actions ppa,
      pay_assignment_actions paa_arch
    WHERE
      paa.assignment_action_id = p_mag_asg_action_id AND
      ppa.payroll_action_id = paa.payroll_action_id AND
      pai.locking_action_id = paa.assignment_action_id AND
      paf.assignment_id = paa.assignment_id AND
      ppf.person_id = paf.person_id AND
      pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
      between
        paf.effective_start_date and paf.effective_end_date AND
      pay_magtape_generic.date_earned(ppa.effective_date,paa.assignment_id)
      between
        ppf.effective_start_date and ppf.effective_end_date AND
      fai.context1 = pai.locked_action_id AND
      fdi.user_name = 'CAEOY_RL1_PROVINCE_OF_EMPLOYMENT' AND
      fai.user_entity_id = fdi.user_entity_id AND
      paa_arch.assignment_action_id = fai.context1 AND
    --paa_arch.payroll_action_id =
    -- to_number(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')) AND
      paa_arch.assignment_action_id = pai.locked_action_id
    ORDER BY
      ppf.last_name,ppf.first_name,ppf.middle_names;

    l_mag_asg_action_id   pay_assignment_actions.assignment_action_id%TYPE;
    l_arch_action_id      pay_assignment_actions.assignment_action_id%TYPE;
    l_asg_id              per_assignments_f.assignment_id%TYPE;
    l_date_earned         DATE;
    l_province            VARCHAR2(30);
    l_O_AutreRevenu       VARCHAR2(1000);

    TYPE employee_info IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

    tab_employee employee_info;
    tab_xml_employee   employee_info;  --

    lAnnee                   NUMBER;
    lNoReleve                NUMBER;
    lNAS                     NUMBER;
    --SIN1                     NUMBER;
    --SIN2                     NUMBER;
    --SIN3                     NUMBER;
    lNo                      NUMBER;
    lNomFamille              NUMBER;
    lPrenom                  NUMBER;
    lInitiale                NUMBER;
    lLigne1                  NUMBER;
    lLigne2                  NUMBER;
    lVille                   NUMBER;
    lProvince                NUMBER;
    lCodePostal              NUMBER;
    lA_RevenuEmploi          NUMBER;
    lB_CotisationRRQ         NUMBER;
    lC_CotisationAssEmploi   NUMBER;
    lD_CotisationRPA         NUMBER;
    lE_ImpotQue              NUMBER;
    lF_CotisationSyndicale   NUMBER;
    lG_SalaireAdmisRRQ        NUMBER;
    lV_NourritureLogement    NUMBER;
    lW_Vehicule              NUMBER;
    lJ_RegimeAssMaladie      NUMBER;
    lK_Voyage                NUMBER;
    lL_AutreAvantage         NUMBER;
    lM_Commission            NUMBER;
    lN_DonBienfaisance       NUMBER;
    lO_AutreRevenu           NUMBER;
    l_SourceCase             NUMBER;
    lP_RegimeAssInterEntr    NUMBER;
    lQ_SalaireDiffere        NUMBER;
    lR_RevenuIndien          NUMBER;
    lS_PourboireRecu         NUMBER;
    lT_PourboireAttribue     NUMBER;
    lU_RetraiteProgressive   NUMBER;
    l_ContisationRPC         NUMBER;
    lH_CotisationRQAP        NUMBER;
    lI_SalaireAdmisRQAP      NUMBER;

    l_person_id         per_people_f.person_id%TYPE;
    l_address_line1     per_addresses.address_line1%TYPE;
    l_address_line2     per_addresses.address_line2%TYPE;
    l_address_line3     per_addresses.address_line3%TYPE;
    l_combined_addr     VARCHAR2(500);
    l_city              per_addresses.town_or_city%TYPE;
    l_postal_code       per_addresses.postal_code%TYPE;
    l_country           VARCHAR2(60);
    l_emp_province      per_addresses.region_1%TYPE;
    EOL                 VARCHAR2(5);
    l_taxation_year     VARCHAR2(5);
    l_name              VARCHAR2(200);
    l_box               VARCHAR2(20);
    l_boxA              VARCHAR2(20);
    l_boxB              VARCHAR2(20);
    l_boxU              VARCHAR2(20);
    l_boxQ              VARCHAR2(20);
    l_return            VARCHAR2(30);
    l_status            VARCHAR2(10);
    l_addr_begin_tag    VARCHAR2(10);
    l_addr_end_tag      VARCHAR2(10);
    l_formatted_box     VARCHAR2(20);
    l_boxO              VARCHAR2(20);
    l_other_details     VARCHAR2(32000);
    l_authorization_code VARCHAR2(100);
    l_authorization_header VARCHAR2(100);
    l_year              VARCHAR2(5);
    l_print_instruction VARCHAR2(1);  --added for 5850067

    lBoxA_01            NUMBER;
    lBoxA_02            NUMBER;
    lBoxA_15            NUMBER;
    lBoxA_16            NUMBER;
    lBoxA_17            NUMBER;
    lBoxA_18            NUMBER;
    lBoxA_19            NUMBER;
    lBoxA_25            NUMBER;
    lBoxA_26            NUMBER;
    lBoxA_27            NUMBER;
    lBoxD_07            NUMBER;
    lBoxD_08            NUMBER;
    lBoxD_20            NUMBER;
    lBoxK_11            NUMBER;
    lBoxO_RA            NUMBER;
    lBoxO_RB            NUMBER;
    lBoxO_RC            NUMBER;
    lBoxO_RD            NUMBER;
    lBoxO_RE            NUMBER;
    lBoxO_RF            NUMBER;
    lBoxO_RG            NUMBER;
    lBoxO_RH            NUMBER;
    lBoxO_RI            NUMBER;
    lBoxO_RJ            NUMBER;
    lBoxO_RK            NUMBER;
    lBoxO_RL            NUMBER;
    lBoxO_RL22          NUMBER;
    lBoxO_RL28          NUMBER;
    lBoxO_RM            NUMBER;
    lBoxO_RN            NUMBER;
    lBoxO_RO            NUMBER;
    lBoxO_RP            NUMBER;
    lBoxO_RQ            NUMBER;
    lBoxO_RR            NUMBER;
    lBoxO_RS            NUMBER;
    lBoxO_RT            NUMBER;
    lBoxO_RU            NUMBER;
    lBoxO_RV            NUMBER;
    lBoxO_RW            NUMBER;
    lBoxO_RX            NUMBER;

    --Added for bug 9178892
    lBoxO_CA            NUMBER;
    lBoxO_CB            NUMBER;
    lBoxO_CC            NUMBER;
    --

    lBoxQ_24            NUMBER;
    lBoxR_14            NUMBER;
    lErrorDetails       NUMBER;
    lBoxA_29            NUMBER;
    lBoxA_30            NUMBER;
    lBoxO_RN_31         NUMBER;

  CURSOR cur_get_meaning(p_lookup_code VARCHAR2) IS
  SELECT
   meaning
  FROM
    hr_lookups
  WHERE
   lookup_type = 'PAY_CA_MAG_EXCEPTIONS' and
   lookup_code = p_lookup_code;

  /* Cursor for fetching authorisation code */
  CURSOR c_get_auth_code(p_reporting_year varchar2) IS
  SELECT meaning
  FROM hr_lookups
  WHERE trim(lookup_code) = p_reporting_year
        AND lookup_type = 'PAY_CA_RL1_PDF_AUTH'
        AND enabled_flag='Y';

  l_meaning    hr_lookups.meaning%TYPE;
  l_msg_code   VARCHAR2(30);
  l_all_box_0  BOOLEAN;
  l_format_mask  VARCHAR2(30);
  l_sequence_number  NUMBER(9);

  /* Moved this function to package pay_ca_eoy_rl1_archive

  FUNCTION getnext_seq_num (p_curr_seq IN NUMBER)
  RETURN NUMBER IS
    l_seq_number   number;
    l_check_number number;
  BEGIN

     l_check_number := mod(p_curr_seq,7);
     hr_utility.trace('l_check_number ='|| l_check_number);
     l_seq_number := (p_curr_seq * 10) + l_check_number;
     hr_utility.trace('l_seq_number ='|| l_seq_number);
     return l_seq_number;
  END; */


  BEGIN
  -- hr_utility.trace_on(null,'PDF');
   hr_utility.trace('inside xml_employee_record');
   /*******************************************************************************/
   --l_rep_type:=pay_magtape_generic.get_parameter_value('REPORT_TYPE'); --
   l_payroll_actid
        := to_number(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'));
    hr_utility.trace('l_payroll_actid='||l_payroll_actid);
   SELECT  ppa.report_type
    INTO l_rep_type
    from pay_payroll_actions ppa
    where payroll_action_id=l_payroll_actid;
     hr_utility.trace('report_type='||l_rep_type);
   /******************************* ************************************/


    hr_utility.trace('XML Employee');
    l_status := 'Success';
    l_all_box_0 := TRUE;
    l_format_mask := '99999999999999990.99';

    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lAnnee        := 1;
    lNoReleve     := 2;
    lNAS          := 3;
    lNo           := 4;
    lNomFamille   := 5;
    lPrenom       := 6;
    lInitiale     := 7;
    lLigne1       := 8;
    lLigne2       := 9;
    lVille        := 10;
    lProvince     := 11;
    lCodePostal   := 12;
    lA_RevenuEmploi  := 13;
    lB_CotisationRRQ := 14;
    lC_CotisationAssEmploi := 15;
    lD_CotisationRPA := 16;
    lE_ImpotQue := 17;
    lF_CotisationSyndicale := 18;
    lG_SalaireAdmisRRQ := 19;
    lV_NourritureLogement := 20;
    lW_Vehicule := 21;
    lJ_RegimeAssMaladie := 22;
    lK_Voyage := 23;
    lL_AutreAvantage := 24;
    lM_Commission := 25;
    lN_DonBienfaisance := 26;
    lO_AutreRevenu := 27;
    l_SourceCase  := 28;
    lP_RegimeAssInterEntr := 29;
    lQ_SalaireDiffere := 30;
    lR_RevenuIndien := 31;
    lS_PourboireRecu := 32;
    lT_PourboireAttribue := 33;
    lU_RetraiteProgressive := 34;
    l_ContisationRPC := 35;
    lH_CotisationRQAP:=92;
    lI_SalaireAdmisRQAP := 93;

    lBoxA_01 := 36;
    lBoxA_02 := 37;
    lBoxA_15 := 38;
    lBoxA_16 := 39;
    lBoxA_17 := 40;
    lBoxA_18 := 41;
    lBoxA_19 := 42;
    lBoxA_25 := 43;
    lBoxA_26 := 44;
    lBoxA_27 := 45;
    lBoxD_07 := 46;
    lBoxD_08 := 47;
    lBoxD_20 := 48;

    lBoxO_RA := 49;
    lBoxO_RB := 50;
    lBoxO_RC := 51;
    lBoxO_RD := 52;
    lBoxO_RE := 53;
    lBoxO_RF := 54;
    lBoxO_RG := 55;
    lBoxO_RH := 56;
    lBoxO_RI := 57;
    lBoxO_RJ := 58;
    lBoxO_RK := 59;
    lBoxO_RL := 60;
    lBoxO_RL22 := 61;
    lBoxO_RL28 := 62;
    lBoxO_RM := 63;
    lBoxO_RN := 64;
    lBoxO_RO := 65;
    lBoxO_RP := 66;
    lBoxO_RQ := 67;
    lBoxO_RR := 68;
    lBoxO_RS := 69;
    lBoxO_RT := 70;
    lBoxO_RU := 80;
    lBoxO_RV := 81;
    lBoxO_RW := 82;
    lBoxO_RX := 83;
    lBoxQ_24 := 84;
    lBoxR_14 := 85;
    lBoxK_11 := 86;
    lErrorDetails := 87;
    lBoxA_29 := 88;
    lBoxA_30 := 89;
    lBoxO_RN_31 := 90;
    lForm_number :=91; --
    --SIN1         :=93;
    --SIN2         :=94;
    --SIN3         :=95;

    --Added for bug 9178892
    lBoxO_CA := 94;
    lBoxO_CB := 95;
    lBoxO_CC := 96;
    --

    l_mag_asg_action_id := to_number(pay_magtape_generic.get_parameter_value
                                                 ('TRANSFER_ACT_ID'));

    hr_utility.trace('XML Employee: l_mag_asg_action_id = '
                                  || to_char(l_mag_asg_action_id));

/**********************************************************************/
    IF l_rep_type <> 'RL1PAPERPDF' THEN
        OPEN cur_parameters(l_mag_asg_action_id);
        FETCH cur_parameters
        INTO
           l_arch_action_id,
           l_asg_id,
           l_date_earned,
           l_province;
        CLOSE cur_parameters;
    ELSE
       open c_get_payroll_asg_actid(l_mag_asg_action_id);
       fetch c_get_payroll_asg_actid
       into  l_arch_action_id,
             l_arch_pay_actid,
             l_asg_id;
       close c_get_payroll_asg_actid;
--     l_arch_action_id := l_arch_asg_actid;

       open c_province(l_arch_action_id);
       fetch c_province into l_province;
       close c_province;
   END IF;
  /**************************************** ******************/

    hr_utility.trace('XML Employee: l_arch_action_id = '
                                  || to_char(l_arch_action_id));
    hr_utility.trace('XML Employee: l_asg_id = ' || to_char(l_asg_id));
    hr_utility.trace('XML Employee: l_date_earned = '
                                  || to_char(l_date_earned));
    hr_utility.trace('XML Employee: l_province = ' || l_province);

    l_taxation_year
        := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');

    l_authorization_header := 'No d''autorisation :';

    l_year := pay_ca_archive_utils.get_archive_value(l_arch_pay_actid, 'CAEOY_TAXATION_YEAR');

    /*if( l_year ='2006' ) then
        l_authorization_code := 'FS-06-01-103';
    elsif (l_year ='2007' ) then
        l_authorization_code := 'FS-07-01-107';  --Bug 6747916
    elsif (l_year ='2008' ) then
        l_authorization_code := 'FS-08-01-020';  --Bug 7503515
    end if; */

    open c_get_auth_code(l_year);
    fetch c_get_auth_code into l_authorization_code;
    close c_get_auth_code;

    --Annee
    tab_employee(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' || EOL;
    hr_utility.trace('tab_employee(lAnnee) = ' || tab_employee(lAnnee));
    --NoReleve
    l_return := pay_ca_archive_utils.get_archive_value(l_arch_action_id,
                        'CAEOY_RL1_SLIP_NUMBER');

    IF l_return IS NULL THEN
      l_status := 'Failed';
      tab_employee(lNoReleve) := NULL;
      tab_xml_employee(lNoReleve) := NULL; --
    ELSE
      tab_employee(lNoReleve) := '<NoReleve>' || l_return ||
                        '</NoReleve>' || EOL;
      tab_xml_employee(lNoReleve) := l_return; --
    END IF;
    hr_utility.trace('tab_employee(lNoReleve) = ' || tab_employee(lNoReleve));
    hr_utility.trace('tab_xml_employee(lNoReleve) = ' || tab_xml_employee(lNoReleve)); --

    -- NAS
    l_return :=  pay_ca_archive_utils.get_archive_value(l_arch_action_id,
                        'CAEOY_EMPLOYEE_SIN');

    IF l_return IS NOT NULL THEN
      tab_employee(lNAS) := '<NAS>' || l_return || '</NAS>' || EOL;
      tab_xml_employee(lNAS) := l_return; --

    ELSE
      l_Status   := 'Failed';
      l_msg_code := 'SIN';
      tab_employee(lNAS) := NULL;
      tab_xml_employee(lNAS) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lNAS) = ' || tab_employee(lNAS));
    hr_utility.trace('tab_xml_employee(lNAS) = ' || tab_xml_employee(lNAS));

    -- No
    l_return := pay_ca_archive_utils.get_archive_value(l_arch_action_id,
                        'CAEOY_EMPLOYEE_NUMBER');
    IF l_return IS NOT NULL THEN
      tab_employee(lNo) := '<No>' || convert_special_char(l_return) || '</No>' || EOL;
      tab_xml_employee(lNo) := convert_special_char(l_return); --
    ELSE
      tab_employee(lNo) := NULL;
      tab_xml_employee(lNo) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lNo) = ' || tab_employee(lNo));
    hr_utility.trace('tab_xml_employee(lNo) = ' || tab_xml_employee(lNo)); --

    -- NomFamille
    l_name := pay_ca_archive_utils.get_archive_value(l_arch_action_id,
                        'CAEOY_EMPLOYEE_LAST_NAME');
    tab_employee(lNomFamille) := '<NomFamille>' ||
                        convert_special_char(substr(l_name,1,30)) || '</NomFamille>' || EOL;
    tab_xml_employee(lNomFamille) := convert_special_char(substr(l_name,1,20)); --
    hr_utility.trace('tab_employee(lNomFamille) = ' || tab_employee(lNomFamille));
    hr_utility.trace('tab_xml_employee(lNomFamille) = ' || tab_xml_employee(lNomFamille));  --

    -- Prenom
    l_name := pay_ca_archive_utils.get_archive_value(l_arch_action_id,
                        'CAEOY_EMPLOYEE_FIRST_NAME');
    IF l_name is NOT NULL THEN
      tab_employee(lPrenom) := '<Prenom>' || convert_special_char(substr(l_name,1,30))
                                          || '</Prenom>' || EOL;
      tab_xml_employee(lPrenom) := convert_special_char(substr(l_name,1,20)) ; --

    ELSE
      l_status   := 'Failed';
      l_msg_code := 'MISSING_EMP_FIRST_NAME';
      tab_employee(lPrenom) := NULL;
      tab_xml_employee(lPrenom) := NULL ; --
    END IF;
    hr_utility.trace('tab_employee(lPrenom) = ' || tab_employee(lPrenom));
    hr_utility.trace('tab_xml_employee(lPrenom) = ' || tab_xml_employee(lPrenom)); --

    -- Initiale
    l_name := pay_ca_archive_utils.get_archive_value(l_arch_action_id,
                        'CAEOY_EMPLOYEE_INITIAL');
    IF l_name is NOT NULL THEN
      tab_employee(lInitiale) := '<Initiale>' || substr(l_name,1,1)
                                              || '</Initiale>' || EOL;
      tab_xml_employee(lInitiale) := substr(l_name,1,1); --

    ELSE
      tab_employee(lInitiale) := NULL;
      tab_xml_employee(lInitiale) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lInitiale) = ' || tab_employee(lInitiale));
    hr_utility.trace('tab_xml_employee(lInitiale) = ' || tab_xml_employee(lInitiale)); --

    l_person_id := to_number(pay_ca_archive_utils.get_archive_value(
                        l_arch_action_id,
                        'CAEOY_PERSON_ID'));
   /***************************************************************/
   if(l_rep_type='RL1PAPERPDF') then
      l_person_id1 := to_number(pay_ca_archive_utils.get_archive_value(
                     l_arch_action_id,
                     'CAEOY_PERSON_ID'));

      select trunc(sysdate) into l_session_date from dual;
      hr_utility.trace('l_person_id1 ='|| l_person_id1);
      hr_utility.trace('l_session_date ='|| l_session_date);
      addr := pay_ca_rl1_reg.get_primary_address(l_person_id1, l_session_date);
      tab_xml_employee(lLigne1) := convert_special_char(substr(addr.addr_line_1,1,40));
      tab_xml_employee(lLigne2) := convert_special_char(substr(addr.addr_line_2,1,40)||' '||substr(addr.addr_line_3,1,40));
      tab_xml_employee(lVille)   := convert_special_char(substr(addr.addr_line_4,1,40));
      tab_xml_employee(lForm_number) := pay_ca_archive_utils.get_archive_value(l_mag_asg_action_id, --l_arch_action_id,
                                      'CAEOY_RL1_PRE_PRINTED_FORM_NO');
      hr_utility.trace('tab_xml_employee(lForm_number) = ' || tab_xml_employee(lForm_number));


      tab_xml_employee(lAnnee) := pay_ca_archive_utils.get_archive_value(l_arch_pay_actid,
                                         'CAEOY_TAXATION_YEAR');
      hr_utility.trace('tab_xml_employee(lAnnee) = ' || tab_xml_employee(lAnnee)); --
   /***************************** *****************************/
   else /***if not paper report***/
    l_return := pay_ca_emp_address_dtls.get_emp_address(
                    l_person_id,
                    l_address_line1,
                    l_address_line2,
                    l_address_line3,
                    l_city,
                    l_postal_code,
                    l_country,
                    l_emp_province
                    );
    -- If Address line 1 is NULL or ' ' then the employee is missing
    -- address information - as line 1 is mandatory in the Address form.
    -- Need to check data by SS transaction /API.

      hr_utility.trace('l_person_id = ' || to_char(l_person_id));
      hr_utility.trace('l_address_line1 = ' || l_address_line1);
      hr_utility.trace('l_address_line2 = ' || l_address_line2);
      hr_utility.trace('l_postal_code = ' || l_postal_code);

    -- Address Line 1
    IF l_address_line1 IS NULL OR
       l_address_line1 = ' ' THEN

       l_status := 'Failed';
       l_msg_code := 'MISSING_EMP_ADDRESS';

       l_addr_begin_tag          := NULL;
       tab_employee(lLigne1)     := NULL;
       tab_employee(lLigne2)     := NULL;
       tab_employee(lVille)      := NULL;
       tab_employee(lProvince)   := NULL;
       tab_employee(lCodePostal) := NULL;
       tab_employee(lCodePostal) := NULL;
       l_addr_end_tag            := NULL;

    ELSE

      l_addr_begin_tag := '<Adresse>';

      tab_employee(lLigne1) := '<Ligne1>' ||
                  convert_special_char(substr(l_address_line1,1,30)) || '</Ligne1>' || EOL;
      hr_utility.trace('tab_employee(lLigne1) = ' || tab_employee(lLigne1));

      -- Address Line 2
      IF ((l_address_line2 IS NULL OR
           l_address_line2 <> ' ') OR
          (l_address_line3 IS NULL OR
           l_address_line3 <> ' ')) THEN
        l_combined_addr := rtrim(ltrim(l_address_line2)) || rtrim(ltrim(l_address_line3));
        tab_employee(lLigne2) := '<Ligne2>' ||
                  convert_special_char(substr(l_combined_addr,1,30)) || '</Ligne2>' || EOL;
      ELSE
        tab_employee(lLigne2) := NULL;
      END IF;
      hr_utility.trace('tab_employee(lLigne2) = ' || tab_employee(lLigne2));

      -- Ville (City)
      IF l_city IS NULL OR
         l_city <> ' ' THEN
        tab_employee(lVille) := '<Ville>' ||
                  substr(l_city,1,30) || '</Ville>' || EOL;
      ELSE
        tab_employee(lVille) := NULL;
      END IF;
      hr_utility.trace('tab_employee(lVille) = ' || tab_employee(lVille));

      -- Province
      IF l_emp_province IS NULL OR
         l_emp_province <> ' ' THEN
         IF l_country = 'CA' THEN
                 tab_employee(lProvince) := '<Province>' ||
                                            SUBSTR(hr_general.decode_lookup(
                                            'CA_PROVINCE',l_emp_province),1,20) || '</Province>' || EOL;
         ELSIF l_country = 'US' THEN
                 tab_employee(lProvince) := '<Province>' || l_emp_province || '</Province>' || EOL;
         ELSE
                 tab_employee(lProvince) := '<Province>' || l_country || '</Province>' || EOL;
         END IF;
      ELSE
        tab_employee(lProvince) := NULL;
      END IF;
      hr_utility.trace('tab_employee(lProvince) = ' || tab_employee(lProvince));

    -- Postal Code
    IF l_postal_code IS NULL OR
       l_postal_code <> ' ' THEN
      tab_employee(lCodePostal) := '<CodePostal>' ||
             substr(replace(l_postal_code,' '),1,6) || '</CodePostal>' || EOL;
    ELSE
      tab_employee(lCodePostal) := NULL;
    END IF;
    hr_utility.trace('tab_employee(lCodePostal) = ' || tab_employee(lCodePostal));
    l_addr_end_tag := '</Adresse>';

    END IF;

end if; /***************end of address******/ --
    -- Summ (Box A)

    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_GROSS_EARNINGS_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;
      tab_employee(lA_RevenuEmploi) := '<A_RevenuEmploi>' || l_formatted_box ||
                                     '</A_RevenuEmploi>' || EOL;
      tab_xml_employee(lA_RevenuEmploi) := l_formatted_box; --
      l_all_box_0 := FALSE;
      l_BoxA := l_formatted_box;
    ELSE
      tab_employee(lA_RevenuEmploi) := NULL;
      tab_xml_employee(lA_RevenuEmploi) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lA_RevenuEmploi) = ' || tab_employee(lA_RevenuEmploi));
    hr_utility.trace('tab_xml_employee(lA_RevenuEmploi) = ' || tab_xml_employee(lA_RevenuEmploi));

    -- Summ (Box B)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_QPP_EE_WITHHELD_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      l_BoxB := l_box;

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lB_CotisationRRQ) := '<B_CotisationRRQ>' || l_formatted_box
                                        || '</B_CotisationRRQ>' || EOL;
      tab_xml_employee(lB_CotisationRRQ) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE

      tab_employee(lB_CotisationRRQ) := NULL;
      tab_xml_employee(lB_CotisationRRQ) := NULL; --

    END IF;
    hr_utility.trace('tab_employee(lB_CotisationRRQ) = ' ||
                                   tab_employee(lB_CotisationRRQ));
    hr_utility.trace('tab_xml_employee(lB_CotisationRRQ) = ' ||
                                   tab_xml_employee(lB_CotisationRRQ)); --

    -- Summ (Box C)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_EI_EE_WITHHELD_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lC_CotisationAssEmploi) := '<C_CotisationAssEmploi>' ||
                         l_formatted_box || '</C_CotisationAssEmploi>' || EOL;
      tab_xml_employee(lC_CotisationAssEmploi) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lC_CotisationAssEmploi) := NULL;
      tab_xml_employee(lC_CotisationAssEmploi) := NULL; --
    END IF;

    hr_utility.trace('tab_employee(lC_CotisationAssEmploi) = ' ||
                         tab_employee(lC_CotisationAssEmploi));

    hr_utility.trace('tab_xml_employee(lC_CotisationAssEmploi) = ' ||
                         tab_xml_employee(lC_CotisationAssEmploi)); --
    -- Summ (Box D)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXD_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lD_CotisationRPA) := '<D_CotisationRPA>' ||
                         l_formatted_box || '</D_CotisationRPA>' || EOL;
      tab_xml_employee(lD_CotisationRPA) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lD_CotisationRPA) := NULL;
      tab_xml_employee(lD_CotisationRPA) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lD_CotisationRPA) = ' ||
                         tab_employee(lD_CotisationRPA));
    hr_utility.trace('tab_xml_employee(lD_CotisationRPA) = ' ||
                         tab_xml_employee(lD_CotisationRPA));


    -- (Box E)

    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_PROV_WITHHELD_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lE_ImpotQue) := '<E_ImpotQue>' ||
                         l_formatted_box || '</E_ImpotQue>' || EOL;
      tab_xml_employee(lE_ImpotQue) := l_formatted_box ; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lE_ImpotQue) := NULL ;
      tab_xml_employee(lE_ImpotQue) := NULL ; --
    END IF;

    hr_utility.trace('tab_employee(lE_ImpotQue) = ' ||
                         tab_employee(lE_ImpotQue));
    hr_utility.trace('tab_xml_employee(lE_ImpotQue) = ' ||
                         tab_xml_employee(lE_ImpotQue)); --

    -- (Box F)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXF_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lF_CotisationSyndicale) := '<F_CotisationSyndicale>' ||
                         l_formatted_box || '</F_CotisationSyndicale>' || EOL;
      tab_xml_employee(lF_CotisationSyndicale) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lF_CotisationSyndicale) := NULL;
      tab_xml_employee(lF_CotisationSyndicale) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lF_CotisationSyndicale) = ' ||
                         tab_employee(lF_CotisationSyndicale));

    hr_utility.trace('tab_xml_employee(lF_CotisationSyndicale) = ' ||
                         tab_xml_employee(lF_CotisationSyndicale));
    -- (Box Q)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXQ_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lQ_SalaireDiffere) := '<Q_SalaireDiffere>' ||
                         l_formatted_box || '</Q_SalaireDiffere>' || EOL;
      tab_xml_employee(lQ_SalaireDiffere) := l_formatted_box; --
      l_all_box_0 := FALSE;
      l_BoxQ := l_formatted_box;
    ELSE
      tab_employee(lQ_SalaireDiffere) := NULL;
      tab_xml_employee(lQ_SalaireDiffere) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lQ_SalaireDiffere) = ' ||
                         tab_employee(lQ_SalaireDiffere));

    hr_utility.trace('tab_xml_employee(lQ_SalaireDiffere) = ' ||
                         tab_xml_employee(lQ_SalaireDiffere));
    -- (Box U)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXU_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN

     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';

    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lU_RetraiteProgressive) := '<U_RetraiteProgressive>' ||
                         l_formatted_box || '</U_RetraiteProgressive>' || EOL;
      tab_xml_employee(lU_RetraiteProgressive) := l_formatted_box; --
      l_all_box_0 := FALSE;
      l_BoxU := l_formatted_box;
    ELSE
      tab_employee(lU_RetraiteProgressive) := NULL;
      tab_xml_employee(lU_RetraiteProgressive) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lU_RetraiteProgressive) = ' ||
                         tab_employee(lU_RetraiteProgressive));

    hr_utility.trace('tab_xml_employee(lU_RetraiteProgressive) = ' ||
                         tab_xml_employee(lU_RetraiteProgressive));
    -- (Box G)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_QPP_REDUCED_SUBJECT_PER_JD_YTD');

    hr_utility.trace('l_box = '  || l_box);
    hr_utility.trace('l_boxA = ' || l_BoxA);
    hr_utility.trace('l_boxQ = ' || l_BoxQ);
    hr_utility.trace('l_boxU = ' || l_boxU);

    IF l_rep_type <>'RL1PAPERPDF' THEN
    IF l_box IS NOT NULL THEN

      IF TO_NUMBER(l_box) > 9999999.99 THEN

        l_status := 'Failed';
        l_msg_code := 'AMT_GREATER_THAN_RANGE';

        SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
        INTO   l_formatted_box
        FROM   dual;

        tab_employee(lG_SalaireAdmisRRQ) :=  '<G_SalaireAdmisRRQ>' ||
                           l_formatted_box || '</G_SalaireAdmisRRQ>' || EOL;
	--tab_xml_employee(lG_SalaireAdmisRRQ) := l_formatted_box; --

      ELSIF to_number(l_box) = 0 THEN

        tab_employee(lG_SalaireAdmisRRQ) := '<G_SalaireAdmisRRQ>' ||
                                      '0.00</G_SalaireAdmisRRQ>' || EOL;
	--tab_xml_employee(lG_SalaireAdmisRRQ) := '0.00'; --

      ELSIF to_number(l_box) <> (NVL(to_number(l_BoxA),0) +
                                 NVL(to_number(l_BoxQ),0) +
                                 NVL(to_number(l_BoxU),0)) THEN

        SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
        INTO   l_formatted_box
        FROM   dual;

        tab_employee(lG_SalaireAdmisRRQ) :=  '<G_SalaireAdmisRRQ>' ||
                           l_formatted_box || '</G_SalaireAdmisRRQ>' || EOL;

        --tab_xml_employee(lG_SalaireAdmisRRQ) := l_formatted_box; --
	l_all_box_0 := FALSE;

      ELSIF to_number(l_box) = (NVL(to_number(l_BoxA),0) +
                                 NVL(to_number(l_BoxQ),0) +
                                 NVL(to_number(l_BoxU),0)) THEN

        tab_employee(lG_SalaireAdmisRRQ) := NULL;
	--tab_xml_employee(lG_SalaireAdmisRRQ) := NULL; --

      END IF;

    ELSE
      tab_employee(lG_SalaireAdmisRRQ) := NULL;
      --tab_xml_employee(lG_SalaireAdmisRRQ) := NULL; --
    END IF;
              hr_utility.trace('tab_employee(lG_SalaireAdmisRRQ) = ' ||
                         tab_employee(lG_SalaireAdmisRRQ));
    END IF;

    IF l_rep_type ='RL1PAPERPDF' THEN
      IF l_box IS NOT NULL THEN
        SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
        INTO   l_formatted_box
        FROM   dual;
        tab_xml_employee(lG_SalaireAdmisRRQ) := l_formatted_box;

        IF to_number(l_box)= NVL(to_number(l_BoxA),0) THEN
           tab_xml_employee(lG_SalaireAdmisRRQ) := NULL;
	      END IF;

        IF l_BoxA is NULL and to_number(l_box)=0 THEN
	         tab_xml_employee(lG_SalaireAdmisRRQ) := NULL;
	      END IF;

	      --Bug 7636603
	      IF to_number(l_box) = (NVL(to_number(l_BoxA),0) +
                               NVL(to_number(l_BoxQ),0) +
                               NVL(to_number(l_BoxU),0)) THEN
          tab_xml_employee(lG_SalaireAdmisRRQ) := NULL;
        END IF;

      ELSE
        tab_xml_employee(lG_SalaireAdmisRRQ) := NULL;
      END IF;

    hr_utility.trace('tab_xml_employee(lG_SalaireAdmisRRQ) = ' ||
                         tab_xml_employee(lG_SalaireAdmisRRQ));

    END IF;


    -- (Box V)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXV_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lV_NourritureLogement) := '<V_NourritureLogement>' ||
                         l_formatted_box || '</V_NourritureLogement>' || EOL;
      tab_xml_employee(lV_NourritureLogement) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lV_NourritureLogement) := NULL;
      tab_xml_employee(lV_NourritureLogement) := NULL; --
    END IF;

    hr_utility.trace('tab_employee(lV_NourritureLogement) = ' ||
                         tab_employee(lV_NourritureLogement));

    hr_utility.trace('tab_xml_employee(lV_NourritureLogement) = ' ||
                         tab_xml_employee(lV_NourritureLogement));
    -- (Box W)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXW_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lW_Vehicule) := '<W_Vehicule>' ||
                         l_formatted_box || '</W_Vehicule>' || EOL;
      tab_xml_employee(lW_Vehicule) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lW_Vehicule) := NULL;
      tab_xml_employee(lW_Vehicule) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lW_Vehicule) = ' ||
                         tab_employee(lW_Vehicule));

    hr_utility.trace('tab_xml_employee(lW_Vehicule) = ' ||
                         tab_xml_employee(lW_Vehicule));

    --(BOX H)
    l_box := pay_ca_archive_utils.get_archive_value(
             l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_PPIP_EE_WITHHELD_PER_JD_YTD');
    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lH_CotisationRQAP) := '<H_CotisationRQAP>' ||
                         l_formatted_box || '</H_CotisationRQAP>' || EOL;
      tab_xml_employee(lH_CotisationRQAP) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lH_CotisationRQAP) := NULL;
      tab_xml_employee(lH_CotisationRQAP) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lH_CotisationRQAP) = ' ||
                         tab_employee(lH_CotisationRQAP));

    hr_utility.trace('tab_xml_employee(lH_CotisationRQAP) = ' ||
                         tab_xml_employee(lH_CotisationRQAP));

    --(BOX I)
    l_box := pay_ca_archive_utils.get_archive_value(
             l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
--	commented for bug 6623199.
--                'CAEOY_PPIP_REDUCED_SUBJECT_PER_JD_YTD');
                'CAEOY_PPIP_EE_TAXABLE_PER_JD_YTD');
    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lI_SalaireAdmisRQAP) := '<I_SalaireAdmisRQAP>' ||
                         l_formatted_box || '</I_SalaireAdmisRQAP>' || EOL;
      tab_xml_employee(lI_SalaireAdmisRQAP) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lI_SalaireAdmisRQAP) := '<I_SalaireAdmisRQAP>' ||
                         '0.00' || '</I_SalaireAdmisRQAP>' || EOL;
      tab_xml_employee(lI_SalaireAdmisRQAP) := '0.00';--
    END IF;
    hr_utility.trace('tab_employee(lI_SalaireAdmisRQAP) = ' ||
                         tab_employee(lI_SalaireAdmisRQAP));

    hr_utility.trace('tab_xml_employee(lI_SalaireAdmisRQAP) = ' ||
                         tab_xml_employee(lI_SalaireAdmisRQAP));

    -- (Box J)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXJ_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lJ_RegimeAssMaladie) := '<J_RegimeAssMaladie>' ||
                         l_formatted_box || '</J_RegimeAssMaladie>' || EOL;
      tab_xml_employee(lJ_RegimeAssMaladie) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lJ_RegimeAssMaladie) := NULL;
      tab_xml_employee(lJ_RegimeAssMaladie) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lJ_RegimeAssMaladie) = ' ||
                         tab_employee(lJ_RegimeAssMaladie));

    hr_utility.trace('tab_xml_employee(lJ_RegimeAssMaladie) = ' ||
                         tab_xml_employee(lJ_RegimeAssMaladie));

    -- (Box K)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXK_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lK_Voyage) := '<K_Voyage>' ||
                         l_formatted_box || '</K_Voyage>' || EOL;
      tab_xml_employee(lK_Voyage) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lK_Voyage) := NULL;
      tab_xml_employee(lK_Voyage) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lK_Voyage) = ' ||
                         tab_employee(lK_Voyage));

    hr_utility.trace('tab_xml_employee(lK_Voyage) = ' ||
                         tab_xml_employee(lK_Voyage));
    -- (Box L)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXL_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lL_AutreAvantage) := '<L_AutreAvantage>' ||
                         l_formatted_box || '</L_AutreAvantage>' || EOL;
      tab_xml_employee(lL_AutreAvantage) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lL_AutreAvantage) := NULL;
      tab_xml_employee(lL_AutreAvantage) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lL_AutreAvantage) = ' ||
                         tab_employee(lL_AutreAvantage));

    hr_utility.trace('tab_xml_employee(lL_AutreAvantage) = ' ||
                         tab_xml_employee(lL_AutreAvantage));
    -- (Box M)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXM_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lM_Commission) := '<M_Commission>' ||
                         l_formatted_box || '</M_Commission>' || EOL;
      tab_xml_employee(lM_Commission) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lM_Commission) := NULL;
      tab_xml_employee(lM_Commission) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lM_Commission) = ' ||
                         tab_employee(lM_Commission));

    hr_utility.trace('tab_xml_employee(lM_Commission) = ' ||
                         tab_xml_employee(lM_Commission));
    -- (Box N)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXN_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lN_DonBienfaisance) := '<N_DonBienfaisance>' ||
                         l_formatted_box || '</N_DonBienfaisance>' || EOL;
      tab_xml_employee(lN_DonBienfaisance) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lN_DonBienfaisance) := NULL;
      tab_xml_employee(lN_DonBienfaisance) := NULL; --
    END IF;

    hr_utility.trace('tab_employee(lN_DonBienfaisance) = ' ||
                         tab_employee(lN_DonBienfaisance));

    hr_utility.trace('tab_xml_employee(lN_DonBienfaisance) = ' ||
                         tab_xml_employee(lN_DonBienfaisance));
    -- Summ (Box O)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      l_boxO := l_box;
      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lO_AutreRevenu) := '<MontantCaseO>' ||
                         l_formatted_box || '</MontantCaseO>' || EOL;
      tab_xml_employee(lO_AutreRevenu) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lO_AutreRevenu) := NULL;
      tab_xml_employee(lO_AutreRevenu) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lO_AutreRevenu) = ' ||
                         tab_employee(lO_AutreRevenu));

    hr_utility.trace('tab_xml_employee(lO_AutreRevenu) = ' ||
                         tab_xml_employee(lO_AutreRevenu));

    -- SourceCasem

    IF to_number(l_boxO) <> 0 THEN
      l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_CODE_PER_JD_YTD');
      tab_employee(l_SourceCase) := '<SourceCaseO>' ||
                         l_box || '</SourceCaseO>'  || EOL;
      tab_xml_employee(l_SourceCase) := l_box; --
    ELSE
      tab_employee(l_SourceCase) := NULL;
      tab_xml_employee(l_SourceCase) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(l_SourceCase) = ' ||
                         tab_employee(l_SourceCase));

    hr_utility.trace('tab_xml_employee(l_SourceCase) = ' ||
                         tab_xml_employee(l_SourceCase));
    -- (Box P)
    if tab_employee(lO_AutreRevenu) is not null
       and tab_employee(l_SourceCase)is not null then
       l_O_AutreRevenu := '<O_AutreRevenu>'||EOL
                          ||tab_employee(lO_AutreRevenu)||EOL
			  ||tab_employee(l_SourceCase)||EOL
			  ||'</O_AutreRevenu>'||EOL;
    else
       l_O_AutreRevenu := null;
    end if;
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXP_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lP_RegimeAssInterEntr) := '<P_RegimeAssInterEntr>' ||
                         l_formatted_box || '</P_RegimeAssInterEntr>' || EOL;
      tab_xml_employee(lP_RegimeAssInterEntr) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lP_RegimeAssInterEntr) := NULL;
      tab_xml_employee(lP_RegimeAssInterEntr) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lP_RegimeAssInterEntr) = ' ||
                         tab_employee(lP_RegimeAssInterEntr));

    hr_utility.trace('tab_xml_employee(lP_RegimeAssInterEntr) = ' ||
                         tab_xml_employee(lP_RegimeAssInterEntr));
    -- (Box R)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXR_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lR_RevenuIndien) := '<R_RevenuIndien>' ||
                         l_formatted_box || '</R_RevenuIndien>' || EOL;
      tab_xml_employee(lR_RevenuIndien) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lR_RevenuIndien) := NULL;
      tab_xml_employee(lR_RevenuIndien) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lR_RevenuIndien) = ' ||
                         tab_employee(lR_RevenuIndien));

    hr_utility.trace('tab_xml_employee(lR_RevenuIndien) = ' ||
                         tab_xml_employee(lR_RevenuIndien));
    -- (Box S)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXS_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lS_PourboireRecu) := '<S_PourboireRecu>' ||
                         l_formatted_box || '</S_PourboireRecu>' || EOL;
      tab_xml_employee(lS_PourboireRecu) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lS_PourboireRecu) := NULL;
      tab_xml_employee(lS_PourboireRecu) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lS_PourboireRecu) = ' ||
                         tab_employee(lS_PourboireRecu));

    hr_utility.trace('tab_xml_employee(lS_PourboireRecu) = ' ||
                         tab_xml_employee(lS_PourboireRecu));
    -- (Box T)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXT_PER_JD_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(lT_PourboireAttribue) := '<T_PourboireAttribue>' ||
                         l_formatted_box || '</T_PourboireAttribue>' || EOL;
      tab_xml_employee(lT_PourboireAttribue) := l_formatted_box; --
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(lT_PourboireAttribue) := NULL;
      tab_xml_employee(lT_PourboireAttribue) := NULL; --
    END IF;
    hr_utility.trace('tab_employee(lT_PourboireAttribue) = ' ||
                         tab_employee(lT_PourboireAttribue));
    hr_utility.trace('tab_xml_employee(lT_PourboireAttribue) = ' ||
                         tab_xml_employee(lT_PourboireAttribue));
    -- (Box ContisationRPC)
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                --l_province,
                --'JURISDICTION_CODE',
                'CAEOY_CPP_EE_WITHHELD_PER_YTD');

    IF TO_NUMBER(l_box) > 9999999.99 THEN
     l_status := 'Failed';
     l_msg_code := 'AMT_GREATER_THAN_RANGE';
    END IF;

    IF l_box IS NOT NULL AND
       to_number(l_box) <> 0 THEN

      SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
      INTO   l_formatted_box
      FROM   dual;

      tab_employee(l_ContisationRPC) := '<CotisationRPC>' ||
                         l_formatted_box || '</CotisationRPC>' || EOL;
      l_all_box_0 := FALSE;
    ELSE
      tab_employee(l_ContisationRPC) := NULL;
    END IF;
    hr_utility.trace('tab_employee(lR_ContisationRPC) = ' ||
                         tab_employee(l_ContisationRPC));

    -- Negative Balance Exists
    hr_utility.trace('finding if neg bal exists');
    l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_NEGATIVE_BALANCE_EXISTS');

    IF l_box = 'Y' THEN
      l_status := 'Failed';
      l_msg_code := 'NEG';
      l_neg_bal_exists := TRUE;
      hr_utility.trace('neg bal exists');
    END IF;

    IF l_all_box_0 THEN
      l_status := 'Failed';
      l_msg_code := 'ALL_BOXES_ZERO';
    END IF;

    IF l_status = 'Failed' and l_rep_type <>'RL1PAPERPDF' THEN

          -- Box A, 01
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_01_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_01) := '<BoxA_01>' ||
                         l_formatted_box || '</BoxA_01>' || EOL;
          ELSE
            tab_employee(lBoxA_01) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_01) = ' ||
                         tab_employee(lBoxA_01));

          -- Box A, 02
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_02_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_02) := '<BoxA_02>' ||
                         l_formatted_box || '</BoxA_02>' || EOL;
          ELSE
            tab_employee(lBoxA_02) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_02) = ' ||
                         tab_employee(lBoxA_02));

          -- Box A, 15
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_15_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_15) := '<BoxA_15>' ||
                         l_formatted_box || '</BoxA_15>' || EOL;
          ELSE
            tab_employee(lBoxA_15) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_15) = ' ||
                         tab_employee(lBoxA_15));

          -- Box A, 16
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_16_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_16) := '<BoxA_16>' ||
                         l_formatted_box || '</BoxA_16>' || EOL;
          ELSE
            tab_employee(lBoxA_16) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_16) = ' ||
                         tab_employee(lBoxA_16));

          -- Box A, 17
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_17_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_17) := '<BoxA_17>' ||
                         l_formatted_box || '</BoxA_17>' || EOL;
          ELSE
            tab_employee(lBoxA_17) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_17) = ' ||
                         tab_employee(lBoxA_17));

          -- Box A, 18
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_18_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_18) := '<BoxA_18>' ||
                         l_formatted_box || '</BoxA_18>' || EOL;
          ELSE
            tab_employee(lBoxA_18) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_18) = ' ||
                                                   tab_employee(lBoxA_18));

          -- Box A, 19
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_19_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_19) := '<BoxA_19>' ||
                         l_formatted_box || '</BoxA_19>' || EOL;
          ELSE
            tab_employee(lBoxA_19) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_19) = ' ||
                                                tab_employee(lBoxA_19));

          -- Box A, 25
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_25_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_25) := '<BoxA_25>' ||
                         l_formatted_box || '</BoxA_25>' || EOL;
          ELSE
            tab_employee(lBoxA_25) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_25) = ' ||
                                                tab_employee(lBoxA_25));

          -- Box A, 26
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_26_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_26) := '<BoxA_26>' ||
                         l_formatted_box || '</BoxA_26>' || EOL;
          ELSE
            tab_employee(lBoxA_26) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_26) = ' ||
                                                tab_employee(lBoxA_26));

          -- Box A, 27
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_27_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_27) := '<BoxA_27>' ||
                         l_formatted_box || '</BoxA_27>' || EOL;
          ELSE
            tab_employee(lBoxA_27) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_27) = ' ||
                                                tab_employee(lBoxA_27));

          -- Box A, 29
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_29_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_29) := '<BoxA_29>' ||
                         l_formatted_box || '</BoxA_29>' || EOL;
          ELSE
            tab_employee(lBoxA_29) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_27) = ' ||
                                                tab_employee(lBoxA_29));

          -- Box A, 30
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXA_30_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxA_30) := '<BoxA_30>' ||
                         l_formatted_box || '</BoxA_30>' || EOL;
          ELSE
            tab_employee(lBoxA_30) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxA_30) = ' ||
                                                tab_employee(lBoxA_30));

          -- Box D, 07
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXD_07_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxD_07) := '<BoxD_07>' ||
                         l_formatted_box || '</BoxD_07>' || EOL;
          ELSE
            tab_employee(lBoxD_07) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxD_07) = ' ||
                                                tab_employee(lBoxD_07));

          -- Box D, 08
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXD_08_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxD_08) := '<BoxD_08>' ||
                         l_formatted_box || '</BoxD_08>' || EOL;
          ELSE
            tab_employee(lBoxD_08) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxD_08) = ' ||
                                                tab_employee(lBoxD_08));

          -- Box D, 20
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXD_20_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxD_20) := '<BoxD_20>' ||
                         l_formatted_box || '</BoxD_20>' || EOL;
          ELSE
            tab_employee(lBoxD_20) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxD_20) = ' ||
                                                tab_employee(lBoxD_20));

          -- Box K, 11
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXK_11_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxK_11) := '<BoxK_11>' ||
                         l_formatted_box || '</BoxK_11>' || EOL;
          ELSE
            tab_employee(lBoxK_11) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxK_11) = ' ||
                                                tab_employee(lBoxK_11));

          -- Box O, RA
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RA_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RA) := '<BoxO_RA>' ||
                         l_formatted_box || '</BoxO_RA>' || EOL;
          ELSE
            tab_employee(lBoxO_RA) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RA) = ' ||
                                                tab_employee(lBoxO_RA));

          -- Box O, RB
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RB_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RB) := '<BoxO_RB>' ||
                         l_formatted_box || '</BoxO_RB>' || EOL;
          ELSE
            tab_employee(lBoxO_RB) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RB) = ' ||
                                                tab_employee(lBoxO_RB));

          -- Box O, RC
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXC_AMOUNT_RA_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RC) := '<BoxO_RC>' ||
                         l_formatted_box || '</BoxO_RC>' || EOL;
          ELSE
            tab_employee(lBoxO_RC) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RC) = ' ||
                                                tab_employee(lBoxO_RC));

          -- Box O, RD
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RD_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RD) := '<BoxO_RD>' ||
                         l_formatted_box || '</BoxO_RD>' || EOL;
          ELSE
            tab_employee(lBoxO_RD) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RD) = ' ||
                                                tab_employee(lBoxO_RD));

          -- Box O, RE
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RE_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RE) := '<BoxO_RE>' ||
                         l_formatted_box || '</BoxO_RE>' || EOL;
          ELSE
            tab_employee(lBoxO_RE) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RE) = ' ||
                                                tab_employee(lBoxO_RE));

          -- Box O, RF
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RF_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RF) := '<BoxO_RF>' ||
                         l_formatted_box || '</BoxO_RF>' || EOL;
          ELSE
            tab_employee(lBoxO_RF) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RF) = ' ||
                                                tab_employee(lBoxO_RF));

          -- Box O, RG
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RG_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RG) := '<BoxO_RG>' ||
                         l_formatted_box || '</BoxO_RG>' || EOL;
          ELSE
            tab_employee(lBoxO_RG) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RG) = ' ||
                                                tab_employee(lBoxO_RG));

          -- Box O, RH
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RH_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RH) := '<BoxO_RH>' ||
                         l_formatted_box || '</BoxO_RH>' || EOL;
          ELSE
            tab_employee(lBoxO_RH) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RH) = ' ||
                                                tab_employee(lBoxO_RH));

          -- Box O, RI
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RI_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RI) := '<BoxO_RI>' ||
                         l_formatted_box || '</BoxO_RI>' || EOL;
          ELSE
            tab_employee(lBoxO_RI) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RI) = ' ||
                                                tab_employee(lBoxO_RI));

          -- Box O, RJ
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RJ_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RJ) := '<BoxO_RJ>' ||
                         l_formatted_box || '</BoxO_RJ>' || EOL;
          ELSE
            tab_employee(lBoxO_RJ) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RJ) = ' ||
                                                tab_employee(lBoxO_RJ));

          -- Box O, RK
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RK_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RK) := '<BoxO_RK>' ||
                         l_formatted_box || '</BoxO_RK>' || EOL;
          ELSE
            tab_employee(lBoxO_RK) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RK) = ' ||
                                                tab_employee(lBoxO_RK));

          -- Box O, RL
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RL_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RL) := '<BoxO_RL>' ||
                         l_formatted_box || '</BoxO_RL>' || EOL;
          ELSE
            tab_employee(lBoxO_RL) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RL) = ' ||
                                                tab_employee(lBoxO_RL));

          -- Box O, RL(22)
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RL_22_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RL22) := '<BoxO_RL22>' ||
                         l_formatted_box || '</BoxO_RL22>' || EOL;
          ELSE
            tab_employee(lBoxO_RL22) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RL22) = ' ||
                                                tab_employee(lBoxO_RL22));

          -- Box O, RL(28)
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RL_28_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RL28) := '<BoxO_RL28>' ||
                         l_formatted_box || '</BoxO_RL28>' || EOL;
          ELSE
            tab_employee(lBoxO_RL28) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RL28) = ' ||
                                                tab_employee(lBoxO_RL28));

          -- Box O, RM
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RM_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RM) := '<BoxO_RM>' ||
                         l_formatted_box || '</BoxO_RM>' || EOL;
          ELSE
            tab_employee(lBoxO_RM) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RM) = ' ||
                                                tab_employee(lBoxO_RM));

          -- Box O, RN
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RN_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RN) := '<BoxO_RN>' ||
                         l_formatted_box || '</BoxO_RN>' || EOL;
          ELSE
            tab_employee(lBoxO_RN) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RN) = ' ||
                                                tab_employee(lBoxO_RN));

           hr_utility.trace('l_person_id = ' || to_char(l_person_id));

          -- Box O, RN 31
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RN_31_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RN_31) := '<BoxO_RN_31>' ||
                         l_formatted_box || '</BoxO_RN_31>' || EOL;
          ELSE
            tab_employee(lBoxO_RN_31) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RN_31) = ' ||
                                                tab_employee(lBoxO_RN_31));
          -- Box O, RO
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RO_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RO) := '<BoxO_RO>' ||
                         l_formatted_box || '</BoxO_RO>' || EOL;
          ELSE
            tab_employee(lBoxO_RO) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RO) = ' ||
                                                tab_employee(lBoxO_RO));

          -- Box O, RP
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RP_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RP) := '<BoxO_RP>' ||
                         l_formatted_box || '</BoxO_RP>' || EOL;
          ELSE
            tab_employee(lBoxO_RP) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RP) = ' ||
                                                tab_employee(lBoxO_RP));

          -- Box O, RQ
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RQ_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RQ) := '<BoxO_RQ>' ||
                         l_formatted_box || '</BoxO_RQ>' || EOL;
          ELSE
            tab_employee(lBoxO_RQ) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RQ) = ' ||
                                                tab_employee(lBoxO_RQ));

          -- Box O, RR
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RR_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RR) := '<BoxO_RR>' ||
                         l_formatted_box || '</BoxO_RR>' || EOL;
          ELSE
            tab_employee(lBoxO_RR) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RR) = ' ||
                                                tab_employee(lBoxO_RR));

          -- Box O, RS
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RS_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RS) := '<BoxO_RS>' ||
                         l_formatted_box || '</BoxO_RS>' || EOL;
          ELSE
            tab_employee(lBoxO_RS) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RS) = ' ||
                                                tab_employee(lBoxO_RS));

          -- Box O, RT
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RT) := '<BoxO_RT>' ||
                         l_formatted_box || '</BoxO_RT>' || EOL;
          ELSE
            tab_employee(lBoxO_RT) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RT) = ' ||
                                                tab_employee(lBoxO_RT));

          -- Box O, RU
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RU_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RU) := '<BoxO_RU>' ||
                         l_formatted_box || '</BoxO_RU>' || EOL;
          ELSE
            tab_employee(lBoxO_RU) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RU) = ' ||
                                                tab_employee(lBoxO_RU));

          -- Box O, RV
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RV_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RV) := '<BoxO_RV>' ||
                         l_formatted_box || '</BoxO_RV>' || EOL;
          ELSE
            tab_employee(lBoxO_RV) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RV) = ' ||
                                                tab_employee(lBoxO_RV));

          -- Box O, RW
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RW_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RW) := '<BoxO_RW>' ||
                         l_formatted_box || '</BoxO_RW>' || EOL;
          ELSE
            tab_employee(lBoxO_RW) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RW) = ' ||
                                                tab_employee(lBoxO_RW));

          -- Box O, RX  Bug 7557184
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_RX_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_RX) := '<BoxO_RX>' ||
                         l_formatted_box || '</BoxO_RX>' || EOL;
          ELSE
            tab_employee(lBoxO_RX) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_RX) = ' ||
                                                tab_employee(lBoxO_RX));

          -- Box O, CA  Bug 9178892
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_CA_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_CA) := '<BoxO_CA>' ||
                         l_formatted_box || '</BoxO_CA>' || EOL;
          ELSE
            tab_employee(lBoxO_CA) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_CA) = ' ||
                                                tab_employee(lBoxO_CA));

				 -- Box O, CB  Bug 9178892
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_CB_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_CB) := '<BoxO_CB>' ||
                         l_formatted_box || '</BoxO_CB>' || EOL;
          ELSE
            tab_employee(lBoxO_CB) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_CB) = ' ||
                                                tab_employee(lBoxO_CB));

				 -- Box O, CC  Bug 9178892
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXO_AMOUNT_CC_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxO_CC) := '<BoxO_CC>' ||
                         l_formatted_box || '</BoxO_CC>' || EOL;
          ELSE
            tab_employee(lBoxO_CC) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxO_CC) = ' ||
                                                tab_employee(lBoxO_CC));

          -- Box Q, 24
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXQ_24_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxQ_24) := '<BoxQ_24>' ||
                         l_formatted_box || '</BoxQ_24>' || EOL;
          ELSE
            tab_employee(lBoxQ_24) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxQ_24) = ' ||
                                                tab_employee(lBoxQ_24));

          -- Box R, 14
          l_box := pay_ca_archive_utils.get_archive_value(
                l_arch_action_id,
                l_province,
                'JURISDICTION_CODE',
                'CAEOY_RL1_BOXR_14_AMT_PER_JD_YTD');

          IF l_box IS NOT NULL AND
             to_number(l_box) <> 0 THEN

            SELECT ltrim(rtrim(to_char(to_number(l_box),l_format_mask)))
            INTO   l_formatted_box
            FROM   dual;

            tab_employee(lBoxR_14) := '<BoxR_14>' ||
                         l_formatted_box || '</BoxR_14>' || EOL;
          ELSE
            tab_employee(lBoxR_14) := NULL;
          END IF;
          hr_utility.trace('tab_employee(lBoxR_14) = ' ||
                                                tab_employee(lBoxR_14));
	  hr_utility.trace('l_msg_code ='|| l_msg_code);

          OPEN cur_get_meaning(l_msg_code);
          FETCH cur_get_meaning
          INTO  l_meaning;
          CLOSE cur_get_meaning;
           hr_utility.trace('l_meaning ='|| l_meaning);
          tab_employee(lErrorDetails) := '<ErrorDetails>' ||
                         l_meaning || '</ErrorDetails>' || EOL;

         l_other_details := tab_employee(lBoxA_01) ||
                         tab_employee(lBoxA_02) ||
                         tab_employee(lBoxA_15) ||
                         tab_employee(lBoxA_16) ||
                         tab_employee(lBoxA_17) ||
                         tab_employee(lBoxA_18) ||
                         tab_employee(lBoxA_19) ||
                         tab_employee(lBoxA_25) ||
                         tab_employee(lBoxA_26) ||
                         tab_employee(lBoxA_27) ||
                         tab_employee(lBoxA_29) ||
                         tab_employee(lBoxA_30) ||
                         tab_employee(lBoxD_07) ||
                         tab_employee(lBoxD_08) ||
                         tab_employee(lBoxD_20) ||
                         tab_employee(lBoxK_11) ||
                         tab_employee(lBoxO_RA) ||
                         tab_employee(lBoxO_RB) ||
                         tab_employee(lBoxO_RC) ||
                         tab_employee(lBoxO_RD) ||
                         tab_employee(lBoxO_RE) ||
                         tab_employee(lBoxO_RF) ||
                         tab_employee(lBoxO_RG) ||
                         tab_employee(lBoxO_RH) ||
                         tab_employee(lBoxO_RI) ||
                         tab_employee(lBoxO_RJ) ||
                         tab_employee(lBoxO_RK) ||
                         tab_employee(lBoxO_RL) ||
                         -- modification for bug 7604080 starts here.
                         tab_employee(lBoxO_RL22) ||
                         tab_employee(lBoxO_RL28) ||
                         -- modification for bug 7604080 ends here.
                         tab_employee(lBoxO_RM) ||
                         tab_employee(lBoxO_RN) ||
                         tab_employee(lBoxO_RN_31) ||
                         tab_employee(lBoxO_RO) ||
                         tab_employee(lBoxO_RP) ||
                         tab_employee(lBoxO_RQ) ||
                         tab_employee(lBoxO_RR) ||
                         tab_employee(lBoxO_RS) ||
                         tab_employee(lBoxO_RT) ||
                         tab_employee(lBoxO_RU) ||
                         tab_employee(lBoxO_RV) ||
                         tab_employee(lBoxO_RW) ||
                         tab_employee(lBoxO_RX) ||
                         --Added for bug 9178892
                         tab_employee(lBoxO_CA) ||
                         tab_employee(lBoxO_CB) ||
                         tab_employee(lBoxO_CC) ||
                         --
                         tab_employee(lBoxQ_24) ||
                         tab_employee(lBoxR_14) ||
                         tab_employee(lErrorDetails) ;
    END IF;
    hr_utility.trace('l_other_details ='||l_other_details);
    hr_utility.trace('tab_employee(lH_CotisationRQAP) = ' ||
                         tab_employee(lH_CotisationRQAP));
    hr_utility.trace('l_rep_type ='|| l_rep_type);
    --hr_utility.trace('l_neg_bal_exists ='|| l_neg_bal_exists);
   --

     if l_rep_type = 'RL1PAPERPDF'  then
       /********************************/
       if l_neg_bal_exists = TRUE then
            hr_utility.trace('inside if');
	    xml_footnote_boxo(l_arch_action_id
	                      ,l_asg_id
			      ,l_footnote_boxo1
			      ,l_footnote_boxo2
			      ,l_footnote_boxo3);
	    if tab_xml_employee(lNomFamille) is not null then
	        l_final_xml_string := '<NomFamille>'
		                      ||tab_xml_employee(lNomFamille)
				      ||'</NomFamille>'||EOL;
	    end if;
            if tab_xml_employee(lPrenom) is not null then
	       l_final_xml_string := l_final_xml_string||'<Prenom>'
	                             ||tab_xml_employee(lPrenom)
				     ||'</Prenom>'||EOL;
	    end if;
	    if tab_xml_employee(lInitiale) is not null then
	       l_final_xml_string := l_final_xml_string||'<Initiale>'
	                             ||tab_xml_employee(lInitiale)
				     ||'</Initiale>'||EOL;
	    end if;
            l_final_xml_string :=l_final_xml_string||'<Annee>'||tab_xml_employee(lAnnee)
	                         ||'</Annee>'||EOL;

            if tab_xml_employee(lNoReleve) is not null then
                    l_final_xml_string := l_final_xml_string
                                          ||'<NoReleve>'
					  ||tab_xml_employee(lNoReleve)
					  ||'</NoReleve>'||EOL;
            end if;
	    if tab_xml_employee(lLigne1) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<Ligne1>'
					||substr(tab_xml_employee(lLigne1),1,45)
					||'</Ligne1>'||EOL;
              end if;
              if tab_xml_employee(lLigne2) is not null then
                  l_final_xml_string := l_final_xml_string
                                       ||'<Ligne2>'
				       ||substr(tab_xml_employee(lLigne2),1,45)
				       ||'</Ligne2>'||EOL;
              end if;
              if tab_xml_employee(lVille) is not NULL then
                 l_final_xml_string := l_final_xml_string
                                       ||'<Ville>'
				       ||substr(tab_xml_employee(lVille),1,45)
				       ||'</Ville>'||EOL;
              end if;
             if tab_xml_employee(lNAS) is not null then
                    l_final_xml_string := l_final_xml_string
                                          ||'<NAS>'
					  ||tab_xml_employee(lNAS)
					  ||'</NAS>'||EOL;

              end if;
              l_final_xml_string := l_final_xml_string
                                    ||'<No>'||tab_xml_employee(lNo)
				    ||'</No>'||EOL;

              if tab_xml_employee(lA_RevenuEmploi) is not null then
                  l_final_xml_string := l_final_xml_string
                                       ||'<A_RevenuEmploi>'
				       ||tab_xml_employee(lA_RevenuEmploi)
				       ||'</A_RevenuEmploi>'||EOL;
              end if;
              if tab_xml_employee(lB_CotisationRRQ) is not null then
                  l_final_xml_string := l_final_xml_string
                                       ||'<B_CotisationRRQ>'
				       ||tab_xml_employee(lB_CotisationRRQ)
				       ||'</B_CotisationRRQ>'||EOL;
              end if;
              if tab_xml_employee(lC_CotisationAssEmploi) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<C_CotisationAssEmploi>'
					||tab_xml_employee(lC_CotisationAssEmploi)
					||'</C_CotisationAssEmploi>'||EOL;
              end if;
              if tab_xml_employee(lD_CotisationRPA) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<D_CotisationRPA>'
					||tab_xml_employee(lD_CotisationRPA)
					||'</D_CotisationRPA>'||EOL;
              end if;
              if tab_xml_employee(lE_ImpotQue) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<E_ImpotQue>'
					||tab_xml_employee(lE_ImpotQue)
					||'</E_ImpotQue>'||EOL;
              end if;
              if tab_xml_employee(lF_CotisationSyndicale) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<F_CotisationSyndicale>'
					||tab_xml_employee(lF_CotisationSyndicale)
					||'</F_CotisationSyndicale>'||EOL;
              end if;
              if tab_xml_employee(lG_SalaireAdmisRRQ) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<G_SalaireAdmisRRQ>'
					||tab_xml_employee(lG_SalaireAdmisRRQ)
					||'</G_SalaireAdmisRRQ>'||EOL;
              end if;

	      if tab_xml_employee(lH_CotisationRQAP) is not null then
	          l_final_xml_string := l_final_xml_string
                                        ||'<H_CotisationRQAP>'
					||tab_xml_employee(lH_CotisationRQAP)
					||'</H_CotisationRQAP>'||EOL;
              end if;

	      if tab_xml_employee(lI_SalaireAdmisRQAP) is not null then
	          l_final_xml_string := l_final_xml_string
                                        ||'<I_SalaireAdmisRQAP>'
					||tab_xml_employee(lI_SalaireAdmisRQAP)
					||'</I_SalaireAdmisRQAP>'||EOL;
              end if;

              if tab_xml_employee(lJ_RegimeAssMaladie) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<J_RegimeAssMaladie>'
					||tab_xml_employee(lJ_RegimeAssMaladie)
					||'</J_RegimeAssMaladie>'||EOL;
              end if;
              if tab_xml_employee(lK_Voyage) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<K_Voyage>'
					||tab_xml_employee(lK_Voyage)
					||'</K_Voyage>'||EOL;
              end if;
              if tab_xml_employee(lL_AutreAvantage) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<L_AutreAvantage>'
					||tab_xml_employee(lL_AutreAvantage)
					||'</L_AutreAvantage>'||EOL;
              end if;
              if tab_xml_employee(lM_Commission) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<M_Commission>'
					||tab_xml_employee(lM_Commission)
					||'</M_Commission>'||EOL;
              end if;
              if tab_xml_employee(lN_DonBienfaisance) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<N_DonBienfaisance>'
					||tab_xml_employee(lN_DonBienfaisance)
					||'</N_DonBienfaisance>'||EOL;
              end if;
              if tab_xml_employee(lO_AutreRevenu) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<O_AutreRevenu>'
					||tab_xml_employee(lO_AutreRevenu)
					||'</O_AutreRevenu>'||EOL;
              end if;
              if tab_xml_employee(lP_RegimeAssInterEntr) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<P_RegimeAssInterEntr>'
					||tab_xml_employee(lP_RegimeAssInterEntr)
					||'</P_RegimeAssInterEntr>'||EOL;
              end if;
              if tab_xml_employee(lQ_SalaireDiffere) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<Q_SalaireDiffere>'
					||tab_xml_employee(lQ_SalaireDiffere)
					||'</Q_SalaireDiffere>'||EOL;
              end if;
              if tab_xml_employee(lR_RevenuIndien) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<R_RevenuIndien>'
					||tab_xml_employee(lR_RevenuIndien)
					||'</R_RevenuIndien>'||EOL;
              end if;
              if tab_xml_employee(lS_PourboireRecu) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<S_PourboireRecu>'
					||tab_xml_employee(lS_PourboireRecu)
					||'</S_PourboireRecu>'||EOL;
              end if;
              if tab_xml_employee(lT_PourboireAttribue) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<T_PourboireAttribue>'
					||tab_xml_employee(lT_PourboireAttribue)
					||'</T_PourboireAttribue>'||EOL;
              end if;
              if tab_xml_employee(lU_RetraiteProgressive) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<U_RetraiteProgressive>'
					||tab_xml_employee(lU_RetraiteProgressive)
					||'</U_RetraiteProgressive>'||EOL;
              end if;

            if tab_xml_employee(lV_NourritureLogement) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<V_NourritureLogement>'
					||tab_xml_employee(lV_NourritureLogement)
					||'</V_NourritureLogement>'||EOL;
              end if;
              if tab_xml_employee(lW_Vehicule) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<W_Vehicule>'
					||tab_xml_employee(lW_Vehicule)
					||'</W_Vehicule>'||EOL;
              end if;
	      if tab_xml_employee(l_SourceCase) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<SourceCase>'
					||tab_xml_employee(l_SourceCase)
					||'</SourceCase>'||EOL;
              end if;
	     l_final_xml_string := '<FAILED_RL1_PDFASG>'
	                            ||l_final_xml_string
	                            ||l_footnote_boxo1
				    ||'<Errmsg>'
	                            ||'Negative Balance exists'
				    ||'</Errmsg>'||EOL
	                            ||'</FAILED_RL1_PDFASG>'||EOL;
	     pay_core_files.write_to_magtape_lob(l_final_xml_string);
      end if; /*if l_neg_balance_exists is TRUE*/
    /************/
       if l_neg_bal_exists = FALSE then
            hr_utility.trace('inside if');
	    xml_footnote_boxo(l_arch_action_id
	                      ,l_asg_id
			      ,l_footnote_boxo1
			      ,l_footnote_boxo2
			      ,l_footnote_boxo3);
            RL1XML_emplyer_data(l_mag_asg_action_id
	                        ,l_emplyr_final1
				,l_emplyr_final2
				,l_emplyr_final3);

	    hr_utility.trace('l_emplyr_final1='||l_emplyr_final1);
	    hr_utility.trace('l_emplyr_final2='||l_emplyr_final2);
	    hr_utility.trace('l_emplyr_final3='||l_emplyr_final3);
	    hr_utility.trace('l_footnote_boxo1 ='|| l_footnote_boxo1);
	    hr_utility.trace('l_footnote_boxo2 ='|| l_footnote_boxo2);
	    hr_utility.trace('l_footnote_boxo3 ='|| l_footnote_boxo3);
      tab_xml_employee(lNomFamille) := tab_xml_employee(lNomFamille)||','||tab_xml_employee(lPrenom)||' '||tab_xml_employee(lInitiale);

	    /*select pay_ca_rl1_pdf_seq_s.nextval into l_sequence_number from dual;
	    */

	    l_sequence_number := pay_ca_eoy_rl1_archive.gen_rl1_pdf_seq(l_arch_action_id --Bug 6768167
                                                                   ,l_year
                                                                   ,l_province
                                                                   ,'XMLPROC');
      --l_sequence_number1 := getnext_seq_num(l_sequence_number);

      /* added for 5850067*/
      l_print_instruction := pay_magtape_generic.get_parameter_value('print_instruction');

            for k in 1..3 loop
                l_final_xml_string :=
                '<Annee'||k||'>'||tab_xml_employee(lAnnee)||'</Annee'||k||'>'
		||'<Authorization_header'||K||'>'||l_authorization_header
		||'</Authorization_header'||K||'>'||EOL
		||'<Authorization_code'||K||'>'||l_authorization_code
		||'</Authorization_code'||K||'>'
		||'<Sequence_number'||K||'>'||l_sequence_number
		||'</Sequence_number'||K||'>'||EOL;
                if tab_xml_employee(lForm_number) is not null then
                    l_final_xml_string := l_final_xml_string
                                          ||'<Form_number'||k||'>'
					  ||tab_xml_employee(lForm_number)
					  ||'</Form_number'||k||'>'||EOL;
                end if;
                if tab_xml_employee(lNoReleve) is not null then
                    l_final_xml_string := l_final_xml_string
                                          ||'<NoReleve'||k||'>'||tab_xml_employee(lNoReleve)||'</NoReleve'||k||'>'||EOL;
                end if;
               if tab_xml_employee(lNAS) is not null then
                    /*l_final_xml_string := l_final_xml_string
                                          ||'<NAS'||k||'>'||tab_xml_employee(lNAS)||'</NAS'||k||'>'||EOL;*/
                   l_final_xml_string := l_final_xml_string
		                         ||'<SIN1'||k||'>'||substr(tab_xml_employee(lNAS),1,3)||'</SIN1'||k||'>'||EOL
					 ||'<SIN2'||k||'>'||substr(tab_xml_employee(lNAS),4,3)||'</SIN2'||k||'>'||EOL
					 ||'<SIN3'||k||'>'||substr(tab_xml_employee(lNAS),7,3)||'</SIN3'||k||'>'||EOL;
               end if;
               l_final_xml_string := l_final_xml_string
                                     ||'<No'||k||'>'||tab_xml_employee(lNo)||'</No'||k||'>'||EOL
		         	      ||'<NomFamille'||k||'>'||substr(tab_xml_employee(lNomFamille),1,45)
				      ||'</NomFamille'||k||'>'||EOL;

	      /***********************************************/
	       if tab_xml_employee(lLigne1) is not null
	           or tab_xml_employee(lLigne2) is not null
		   or tab_xml_employee(lVille) is not NULL then

		  l_final_xml_string := l_final_xml_string||'<Ligne1'||k||'>';
                  if tab_xml_employee(lLigne1) is not null then
		       l_final_xml_string := l_final_xml_string||substr(tab_xml_employee(lLigne1),1,45)||EOL;
		  end if;
		  if tab_xml_employee(lLigne2) is not null then
                       l_final_xml_string := l_final_xml_string||substr(tab_xml_employee(lLigne2),1,45)||EOL;
		  end if;
		  if tab_xml_employee(lVille) is not NULL then
                        l_final_xml_string := l_final_xml_string||substr(tab_xml_employee(lVille),1,45);
		  end if;
			l_final_xml_string := l_final_xml_string||'</Ligne1'||k||'>'||EOL;
              end if;
	      /************************************************/

	      /**************************************************
	       if tab_xml_employee(lLigne1) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<Ligne1'||k||'>'
					||substr(tab_xml_employee(lLigne1),1,45)
					||'</Ligne1'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lLigne2) is not null then
                  l_final_xml_string := l_final_xml_string
                                       ||'<Ligne2'||k||'>'
				       ||substr(tab_xml_employee(lLigne2),1,45)
				       ||'</Ligne2'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lVille) is not NULL then
                 l_final_xml_string := l_final_xml_string
                                       ||'<Ville'||k||'>'
				       ||substr(tab_xml_employee(lVille),1,45)
				       ||'</Ville'||k||'>'||EOL;
              end if;
	      *******************************************************/

              if tab_xml_employee(lA_RevenuEmploi) is not null then
                  l_final_xml_string := l_final_xml_string
                                       ||'<A_RevenuEmploi'||k||'>'
				       ||tab_xml_employee(lA_RevenuEmploi)
				       ||'</A_RevenuEmploi'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lB_CotisationRRQ) is not null then
                  l_final_xml_string := l_final_xml_string
                                       ||'<B_CotisationRRQ'||k||'>'
				       ||tab_xml_employee(lB_CotisationRRQ)
				       ||'</B_CotisationRRQ'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lC_CotisationAssEmploi) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<C_CotisationAssEmploi'||k||'>'
					||tab_xml_employee(lC_CotisationAssEmploi)
					||'</C_CotisationAssEmploi'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lD_CotisationRPA) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<D_CotisationRPA'||k||'>'
					||tab_xml_employee(lD_CotisationRPA)
					||'</D_CotisationRPA'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lE_ImpotQue) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<E_ImpotQue'||k||'>'
					||tab_xml_employee(lE_ImpotQue)
					||'</E_ImpotQue'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lF_CotisationSyndicale) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<F_CotisationSyndicale'||k||'>'
					||tab_xml_employee(lF_CotisationSyndicale)
					||'</F_CotisationSyndicale'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lG_SalaireAdmisRRQ) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<G_SalaireAdmisRRQ'||k||'>'
					||tab_xml_employee(lG_SalaireAdmisRRQ)
					||'</G_SalaireAdmisRRQ'||k||'>'||EOL;
              end if;

	      if tab_xml_employee(lH_CotisationRQAP) is not null then
	          l_final_xml_string := l_final_xml_string
                                        ||'<H_CotisationRQAP'||k||'>'
					||tab_xml_employee(lH_CotisationRQAP)
					||'</H_CotisationRQAP'||k||'>'||EOL;
              end if;

	      if tab_xml_employee(lI_SalaireAdmisRQAP) is not null then
	          l_final_xml_string := l_final_xml_string
                                        ||'<I_SalaireAdmisRQAP'||k||'>'
					||tab_xml_employee(lI_SalaireAdmisRQAP)
					||'</I_SalaireAdmisRQAP'||k||'>'||EOL;
              end if;

              if tab_xml_employee(lJ_RegimeAssMaladie) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<J_RegimeAssMaladie'||k||'>'
					||tab_xml_employee(lJ_RegimeAssMaladie)
					||'</J_RegimeAssMaladie'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lK_Voyage) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<K_Voyage'||k||'>'
					||tab_xml_employee(lK_Voyage)
					||'</K_Voyage'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lL_AutreAvantage) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<L_AutreAvantage'||k||'>'
					||tab_xml_employee(lL_AutreAvantage)
					||'</L_AutreAvantage'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lM_Commission) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<M_Commission'||k||'>'
					||tab_xml_employee(lM_Commission)
					||'</M_Commission'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lN_DonBienfaisance) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<N_DonBienfaisance'||k||'>'
					||tab_xml_employee(lN_DonBienfaisance)
					||'</N_DonBienfaisance'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lO_AutreRevenu) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<O_AutreRevenu'||k||'>'
					||tab_xml_employee(lO_AutreRevenu)
					||'</O_AutreRevenu'||k||'>'||EOL;
              end if;
              if tab_xml_employee(l_SourceCase) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<SourceCase'||k||'>'
					||tab_xml_employee(l_SourceCase)
					||'</SourceCase'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lP_RegimeAssInterEntr) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<P_RegimeAssInterEntr'||k||'>'
					||tab_xml_employee(lP_RegimeAssInterEntr)
					||'</P_RegimeAssInterEntr'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lQ_SalaireDiffere) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<Q_SalaireDiffere'||k||'>'
					||tab_xml_employee(lQ_SalaireDiffere)
					||'</Q_SalaireDiffere'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lR_RevenuIndien) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<R_RevenuIndien'||k||'>'
					||tab_xml_employee(lR_RevenuIndien)
					||'</R_RevenuIndien'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lS_PourboireRecu) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<S_PourboireRecu'
					||k||'>'||tab_xml_employee(lS_PourboireRecu)
					||'</S_PourboireRecu'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lT_PourboireAttribue) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<T_PourboireAttribue'||k||'>'
					||tab_xml_employee(lT_PourboireAttribue)
					||'</T_PourboireAttribue'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lU_RetraiteProgressive) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<U_RetraiteProgressive'||k||'>'
					||tab_xml_employee(lU_RetraiteProgressive)
					||'</U_RetraiteProgressive'||k||'>'||EOL;
              end if;

            if tab_xml_employee(lV_NourritureLogement) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<V_NourritureLogement'||k||'>'
					||tab_xml_employee(lV_NourritureLogement)
					||'</V_NourritureLogement'||k||'>'||EOL;
              end if;
              if tab_xml_employee(lW_Vehicule) is not null then
                  l_final_xml_string := l_final_xml_string
                                        ||'<W_Vehicule'||k||'>'
					||tab_xml_employee(lW_Vehicule)
					||'</W_Vehicule'||k||'>'||EOL;
              end if;


              if k=1 then
                l_final_xml_string1 := '<RL1_PDF_ASG>'||EOL
		                       ||'<Empdata>'||EOL
                                       ||l_emplyr_final1
                                       ||l_final_xml_string
                                       ||l_footnote_boxo1
                                       ||'</Empdata>'||EOL;
              end if;
              if k=2 then
                  l_final_xml_string2 := '<Empdata>'||EOL
                                        ||l_emplyr_final2
                                        ||l_final_xml_string
                      		        ||l_footnote_boxo2
         			        ||'</Empdata>'||EOL;
               end if;
              if k=3 then
                    l_final_xml_string3 := '<Empdata>'||EOL
                                           ||l_emplyr_final3
                                           ||l_final_xml_string
         			           ||l_footnote_boxo3
         			           ||'</Empdata>'||EOL
					               ||'<PRINT-INSTRUCTION>'||l_print_instruction||'</PRINT-INSTRUCTION>' --Added for 5850067
                         ||EOL||'</RL1_PDF_ASG>'||EOL;
               end if;
           end loop;
           hr_utility.trace('final l_final_xml_string1 ='|| l_final_xml_string1);
	   hr_utility.trace('final l_final_xml_string2 ='|| l_final_xml_string2);
	   hr_utility.trace('final l_final_xml_string3 ='|| l_final_xml_string3);
           pay_core_files.write_to_magtape_lob(l_final_xml_string1);
           pay_core_files.write_to_magtape_lob(l_final_xml_string2);
           pay_core_files.write_to_magtape_lob(l_final_xml_string3);
           --l_page_break :=' ';
           --l_page_break :='<page_break>'||l_page_break||'</page_break>';
          -- pay_core_files.write_to_magtape_lob(l_page_break);
      end if; /* end if of ifl_neg_balance_exists */
 else
     hr_utility.trace('tab_employee(lH_CotisationRQAP) = ' ||
                         tab_employee(lH_CotisationRQAP));
     l_final_xml_string :=
                           '<' || l_status || '>' || EOL ||
                           '<R>' || EOL ||
			  -- '<ok>ok</ok>'||EOL||
                           tab_employee(lAnnee) ||
                           tab_employee(lNoReleve)
			   ||'<Identification>'|| EOL
			   || '<Employe>' || EOL ||
                           tab_employee(lNAS) ||
                           tab_employee(lNo) ||
                           tab_employee(lNomFamille) ||
                           tab_employee(lPrenom) ||
                           tab_employee(lInitiale) || '</Employe>' || EOL
			   ||'</Identification>' || EOL
			   || l_addr_begin_tag || EOL ||
                           tab_employee(lLigne1) ||
                           tab_employee(lLigne2) ||
                           tab_employee(lVille) ||
                           tab_employee(lProvince) ||
                           tab_employee(lCodePostal) ||
                           l_addr_end_tag || EOL   ||
                           '<Montants>' || EOL ||
                         tab_employee(lA_RevenuEmploi) ||
                         tab_employee(lB_CotisationRRQ) ||
                         tab_employee(lC_CotisationAssEmploi) ||
                         tab_employee(lD_CotisationRPA) ||
                         tab_employee(lE_ImpotQue) ||
                         tab_employee(lF_CotisationSyndicale) ||
                         tab_employee(lG_SalaireAdmisRRQ) ||
			 tab_employee(lH_CotisationRQAP)||
			 tab_employee(lI_SalaireAdmisRQAP)||
                         tab_employee(lJ_RegimeAssMaladie) ||
                         tab_employee(lK_Voyage)  ||
                         tab_employee(lL_AutreAvantage)  ||
                         tab_employee(lM_Commission) ||
                         tab_employee(lN_DonBienfaisance) ||
			 l_O_AutreRevenu||
                         tab_employee(lP_RegimeAssInterEntr) ||
                         tab_employee(lQ_SalaireDiffere) ||
                         tab_employee(lR_RevenuIndien) ||
                         tab_employee(lS_PourboireRecu) ||
                         tab_employee(lT_PourboireAttribue) ||
                         tab_employee(lU_RetraiteProgressive) ||
			 tab_employee(lV_NourritureLogement)  ||
                         tab_employee(lW_Vehicule) ||
                         tab_employee(l_ContisationRPC) ||
                         l_other_details ||
                         '</Montants>' || EOL || '</R>' || EOL ||
                         '</' || l_status || '>' ;


    hr_utility.trace('rl1_xml_employee: l_final_xml_string = ' ||  l_final_xml_string);
    pay_core_files.write_to_magtape_lob(l_final_xml_string);
   end if;
   hr_utility.trace('end of xml_employee_record');

  END;
  END xml_employee_record;

  PROCEDURE xml_employer_start IS
  BEGIN

  DECLARE

    l_final_xml CLOB;
    l_final_xml_string VARCHAR2(32000);
    l_is_temp_final_xml VARCHAR2(2);

  BEGIN

    l_final_xml_string := '<Groupe01>';

    hr_utility.trace('rl1_xml_employee_start: l_final_xml_string = ' ||  l_final_xml_string);
    pay_core_files.write_to_magtape_lob(l_final_xml_string);


  END;
  END xml_employer_start;

  PROCEDURE xml_employer_record  IS
  BEGIN
    DECLARE

    l_final_xml CLOB;
    l_final_xml_string VARCHAR2(32000);
    l_is_temp_final_xml VARCHAR2(2);

    TYPE employer_info IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    tab_employer employer_info;

    lAnnee                   NUMBER;
    lNbReleves                NUMBER;
    lNoId                    NUMBER;
    lTypeDossier             NUMBER;
    lNoDossier               NUMBER;
    lNEQ                     NUMBER;
    lNom1                    NUMBER;
    lNom2                    NUMBER;
    lLigne1                  NUMBER;
    lLigne2                  NUMBER;
    lVille                   NUMBER;
    lProvince                NUMBER;
    lCodePostal              NUMBER;

    l_taxation_year         varchar2(4);
    l_context1              ff_archive_items.context1%TYPE;
    EOL                     varchar2(5);
    l_employer_name         varchar2(100);
    l_quebec_bn             varchar2(20);
    l_address_line          hr_locations.address_line_1%TYPE;
    l_address_begin_tag     varchar2(10);
    l_address_end_tag       varchar2(10);

  BEGIN

    hr_utility.trace('XML Employer');

    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lAnnee        := 1;
    lNbReleves    := 2;
    lNoId         := 3;
    lTypeDossier  := 4;
    lNoDossier    := 5;
    lNEQ          := 6;
    lNom1         := 7;
    lNom2         := 8;
    lLigne1       := 9;
    lLigne2       := 10;
    lVille        := 11;
    lProvince     := 12;
    lCodePostal   := 13;

    l_taxation_year
        := pay_magtape_generic.get_parameter_value('REPORTING_YEAR');
    l_context1 := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');

    hr_utility.trace ('l_cvontext1 ='||l_context1);

    tab_employer(lAnnee) := '<Annee>' || l_taxation_year || '</Annee>' || EOL;
    tab_employer(lNbReleves) := '<NbReleves>' || 'Running Total' || '</NbReleves>' || EOL;

    l_quebec_bn := pay_ca_archive_utils.get_archive_value
              (l_context1,'CAEOY_RL1_QUEBEC_BN');

    tab_employer(lNoId) := '<NoId>' || substr(l_quebec_bn,1,10) ||
                           '</NoId>' || EOL;
    tab_employer(lTypeDossier) := '<TypeDossier>' || 'RS' ||
                                  '</TypeDossier>' || EOL;
    tab_employer(lNoDossier) := '<NoDossier>' || substr(l_quebec_bn,13,4) ||
                                '</NoDossier>' || EOL;
    tab_employer(lNEQ) := '<NEQ>' || substr(l_quebec_bn,1,10) ||
                                '</NEQ>' || EOL;
    l_employer_name := pay_ca_archive_utils.get_archive_value(l_context1,
                                            'CAEOY_RL1_EMPLOYER_NAME');

    tab_employer(lNom1) := '<Nom1>' ||
                    convert_special_char(substr(l_employer_name,1,30)) || '</Nom1>' || EOL;
    hr_utility.trace('tab_employer(lAnnee) = ' || tab_employer(lAnnee));
    hr_utility.trace('tab_employer(lNbReleves) = ' || tab_employer(lNbReleves));
    hr_utility.trace('tab_employer(lNoId) = ' || tab_employer(lNoId));
    hr_utility.trace('tab_employer(lTypeDossier) = ' || tab_employer(lTypeDossier));
    hr_utility.trace('tab_employer(lNoDossier) = ' || tab_employer(lNoDossier));
    hr_utility.trace('tab_employer(lNEQ) = ' || tab_employer(lNEQ));
    hr_utility.trace('tab_employer(lNom1) = ' || tab_employer(lNom1));

    IF SUBSTR(l_employer_name,31,30) IS NOT NULL THEN
      tab_employer(lNom2) := '<Nom2>' ||
                    convert_special_char(substr(l_employer_name,31,30)) || '</Nom2>' || EOL;
    ELSE
      tab_employer(lNom2) := NULL;
    END IF;
    hr_utility.trace('tab_employer(lNom2) = ' || tab_employer(lNom2));

    -- Address Line 1

    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_ADDRESS_LINE1');

    IF l_address_line IS NULL THEN

      l_address_begin_tag       := '';
      tab_employer(lLigne1)     := NULL;
      tab_employer(lLigne2)     := NULL;
      tab_employer(lVille)      := NULL;
      tab_employer(lProvince)   := NULL;
      tab_employer(lCodePostal) := NULL;
      l_address_end_tag         := '';

    ELSE

      l_address_begin_tag       := '<Adresse>';

      tab_employer(lLigne1) := '<Ligne1>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ligne1>' || EOL;
      hr_utility.trace('tab_employer(lLigne1) = ' || tab_employer(lLigne1));


      -- Address Line 2

      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_ADDRESS_LINE2');

      IF l_address_line IS NOT NULL THEN
        tab_employer(lLigne2) := '<Ligne2>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ligne2>' || EOL;
      ELSE
        tab_employer(lLigne2) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lLigne2) = ' || tab_employer(lLigne2));

      -- Ville (City)

      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_CITY');
      IF l_address_line IS NOT NULL THEN
        tab_employer(lVille) := '<Ville>' ||
                  convert_special_char(substr(l_address_line,1,30)) || '</Ville>' || EOL;
      ELSE
        tab_employer(lVille) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lVille) = ' || tab_employer(lVille));

      -- Province

      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_PROVINCE');

      IF l_address_line IS NOT NULL THEN
        tab_employer(lProvince) := '<Province>' ||
                         SUBSTR(hr_general.decode_lookup( 'CA_PROVINCE',
                         l_address_line),1,20) || '</Province>' || EOL;
      ELSE
        tab_employer(lProvince) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lProvince) = ' || tab_employer(lProvince));

      -- Postal Code

      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_POSTAL_CODE');

      IF l_address_line IS NOT NULL THEN
        tab_employer(lCodePostal) := '<CodePostal>' ||
             substr(replace(l_address_line,' '),1,6) || '</CodePostal>' || EOL;
      ELSE
        tab_employer(lCodePostal) := NULL;
      END IF;
      hr_utility.trace('tab_employer(lCodePostal) = ' || tab_employer(lCodePostal));

      l_address_end_tag         := '</Adresse>';

    END IF;

    l_final_xml_string := '<T>' || EOL ||
                           tab_employer(lAnnee) ||
                           tab_employer(lNbReleves) || '<Employeur>' || EOL ||
                           tab_employer(lNoId) ||
                           tab_employer(lTypeDossier) ||
                           tab_employer(lNoDossier) ||
                           tab_employer(lNEQ) ||
                           tab_employer(lNom1) ||
                           tab_employer(lNom2) || l_address_begin_tag || EOL ||
                           tab_employer(lLigne1) ||
                           tab_employer(lLigne2) ||
                           tab_employer(lVille) ||
                           tab_employer(lProvince) ||
                           tab_employer(lCodePostal) ||
                           l_address_end_tag || EOL || '</Employeur>' || EOL ||
                           '</T>' || EOL ||
                           '</Groupe01>' || EOL;

    hr_utility.trace('rl1_xml_employer_start: l_final_xml_string = ' ||  l_final_xml_string);
    pay_core_files.write_to_magtape_lob(l_final_xml_string);
   END;
   END xml_employer_record;


/**********************************************************************************************************/
  PROCEDURE xml_report_end IS
  BEGIN

   DECLARE
     l_final_xml_string VARCHAR2(32000);

  BEGIN
    hr_utility.trace('report ends here..closing RL1PAPER tag');
    l_final_xml_string := '</RL1PAPER>';
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_report_end;

   PROCEDURE xml_rl1_report_start IS
  BEGIN

    DECLARE
     l_final_xml_string VARCHAR2(32000);

  BEGIN
    --hr_utility.trace_on(null,'SATI');
    hr_utility.trace('inside xml_rl1_report_start');
    l_final_xml_string := '<RL1PAPER>';
    pay_core_files.write_to_magtape_lob(l_final_xml_string);

  END;
  END xml_rl1_report_start;

PROCEDURE xml_footnote_boxo(p_arch_assact_id IN  NUMBER
                          ,p_assgn_id       IN  NUMBER
		          ,p_footnote_boxo1 OUT NOCOPY VARCHAR2
			  ,p_footnote_boxo2 OUT NOCOPY VARCHAR2
			  ,p_footnote_boxo3 OUT NOCOPY VARCHAR2
			  ) is

l_person_lang        VARCHAR2(10);
l_cpp_withheld    NUMBER;
l_footnote1        VARCHAR2(200);
l_footnote2        VARCHAR2(200);
l_footnote3        VARCHAR2(200);
l_count           NUMBER;
l_count_boxo      NUMBER;
l_boxo1            VARCHAR(400);
l_boxo2            VARCHAR(400);
l_boxo3            VARCHAR(400);
l_footnote_value   VARCHAR(30);

type t_footnote_record is  record ( code   varchar2(100)
                                        ,value   VARCHAR2(30));
type t_footnote_table is  table of t_footnote_record index by BINARY_INTEGER;

t_footnote   t_footnote_table;
type t_boxo_record is  record ( code   varchar2(100)
                                        ,value   NUMBER);
type t_boxo_table is  table of t_boxo_record index by BINARY_INTEGER;
t_boxo       t_boxo_table;
i            NUMBER :=0;
EOL varchar2(5);

cursor c_get_language(p_assgn_id number) is
     select decode(correspondence_language,NULL,'US',correspondence_language)
     from per_all_people_f
     where person_id = to_number(pay_ca_archive_utils.get_archive_value(
                        p_arch_assact_id,
                        'CAEOY_PERSON_ID'));
cursor cur_boxo is
SELECT 'BOXO-'||substr(fdi.user_name,23,2) DB_Name,to_number(fai.value) value
FROM  	ff_database_items fdi,
	ff_archive_items fai
WHERE	fai.user_entity_id = fdi.user_entity_id
AND	fai.context1 = p_arch_assact_id
-- Modified for Bug 9135372
--AND	fdi.user_name like 'CAEOY_RL1_BOXO_AMOUNT_R__PER_JD_YTD'
AND	fdi.user_name like 'CAEOY_RL1_BOXO_AMOUNT____PER_JD_YTD'
and             fai.value <> '0'
ORDER BY substr(fdi.user_name,5,4);

cursor cur_ftnt(p_cpp_withheld NUMBER
                ,p_person_lang VARCHAR2
		,p_arch_assactid NUMBER)is
select substr(ltrim(rtrim(code)),1,60) code,to_char(value,'999,999.99') value
from (

select pay_ca_rl1_reg.get_label(lookup_type,lookup_code,p_person_lang) code, p_cpp_withheld value
from    hr_lookups
where  lookup_type = 'PAY_CA_RL1_FOOTNOTES'
and      lookup_code = 'CPP'
and      p_cpp_withheld <> 0
union
select SUBSTR(fdi.user_name,11,4)||', '||pay_ca_rl1_reg.get_label(hl.lookup_type,hl.lookup_code,p_person_lang) code,
           to_number(fai.value) value
from     HR_LOOKUPS HL,
         ff_database_items fdi,
         ff_archive_items fai
where fai.user_entity_id=fdi.user_entity_id
and fai.context1= p_arch_assactid
and fdi.user_name like 'CAEOY_RL1_BOX%_AMT_PER_JD_YTD'
and fai.value <> '0'
and hl.lookup_type = 'PAY_CA_RL1_FOOTNOTES'
AND HL.LOOKUP_CODE = SUBSTR(replace(FDI.USER_NAME,'_AMT_PER_JD_YTD'),-2)
union all
select pay_ca_rl1_reg.get_label(hl.lookup_type,hl.lookup_code,p_person_lang) code,
to_number(pai.action_information5) value
from   pay_action_information pai
     , hr_lookups hl
where  pai.action_context_id = p_arch_assactid
and    hl.lookup_type              = 'PAY_CA_RL1_NONBOX_FOOTNOTES'
and    hl.lookup_code              = pai.action_information4
);

l_see_attached   Varchar2(100);

begin
     l_footnote1 :=NULL;
     l_footnote2 :=NULL;
     l_footnote3 :=NULL;
     l_boxo1     :=NULL;
     l_boxo2     :=NULL;
     l_boxo3     :=NULL;

  l_see_attached := hr_general.decode_lookup('PAY_CA_LABELS'
                                             ,'SEE_ATTACHED');
     hr_utility.trace('l_see_attached = '||l_see_attached);
     SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    from dual;
     l_cpp_withheld := pay_ca_archive_utils.get_archive_value(p_arch_assact_id
                                                              ,'CAEOY_CPP_EE_WITHHELD_PER_YTD');
     open c_get_language(p_assgn_id);
     fetch c_get_language into l_person_lang;
     close c_get_language;
     hr_utility.trace(' l_cpp_withheld ='|| l_cpp_withheld);
     hr_utility.trace(' l_person_lang ='|| l_person_lang);
     hr_utility.trace(' p_arch_assact_id ='|| p_arch_assact_id);
     for rec in cur_ftnt(l_cpp_withheld,l_person_lang,p_arch_assact_id)
     loop
         i:=i+1;
         t_footnote(i) := rec;
     end loop;
     i:=0;
     for rec in cur_boxo
     loop
         i:=i+1;
	 t_boxo(i)  :=rec;
     end loop;
     l_count_boxo:=t_boxo.count;
     l_count := t_footnote.count;
     hr_utility.trace(' l_count_boxo ='|| l_count_boxo);
     hr_utility.trace(' l_count ='|| l_count);
     if l_count > 1 then  --more than 1 footnote
        p_footnote_boxo1 :='<Seeattached1>'|| l_see_attached ||'</Seeattached1>';
        p_footnote_boxo2 :='<Seeattached2>'|| l_see_attached ||'</Seeattached2>';
        p_footnote_boxo3 :='<Seeattached3>'|| l_see_attached ||'</Seeattached3>';
     elsif l_count=1 and l_count_boxo > 1 then --accomodate 1 box o
        p_footnote_boxo1 :='<Seeattached1>'|| l_see_attached ||'</Seeattached1>';
        p_footnote_boxo2 :='<Seeattached2>'|| l_see_attached ||'</Seeattached2>';
        p_footnote_boxo3 :='<Seeattached3>'|| l_see_attached ||'</Seeattached3>';
     elsif l_count=1 and l_count_boxo<=1 then
       if(t_footnote(1).code = 'Volunteer-Allow not incl in A and L:$1,000' --Bug 6748011
          or
          t_footnote(1).code = 'Volunteer-Allow not incl. in A and L:$1,025' -- Bug 9135372
       ) then
            l_footnote_value := null;
       else
            l_footnote_value := t_footnote(1).value;
       end if;
         l_footnote1 :='<Footnote_Code1>'||t_footnote(1).code||'</Footnote_Code1>'||EOL
		       ||'<Footnote_value1>'|| l_footnote_value || '</Footnote_value1>'||EOL;
         l_footnote2 :='<Footnote_Code2>'||t_footnote(1).code||'</Footnote_Code2>'||EOL
		       ||'<Footnote_value2>'|| l_footnote_value || '</Footnote_value2>'||EOL;
         l_footnote3 :='<Footnote_Code3>'||t_footnote(1).code||'</Footnote_Code3>'||EOL
		       ||'<Footnote_value3>'|| l_footnote_value || '</Footnote_value3>'||EOL;
        hr_utility.trace(' l_footnote1 ='|| l_footnote1);
	hr_utility.trace(' l_footnote2 ='|| l_footnote2);
	hr_utility.trace(' l_footnote3 ='|| l_footnote3);
	if (l_count_boxo=1) then
	   l_boxo1  :='<Boxo_code_31>'||t_boxo(1).code||'</Boxo_code_31>'||EOL
		     ||'<Boxo_value_31>'||t_boxo(1).value||'</Boxo_value_31>'||EOL;
	   l_boxo2  :='<Boxo_code_32>'||t_boxo(1).code||'</Boxo_code_32>'||EOL
		     ||'<Boxo_value_32>'||t_boxo(1).value||'</Boxo_value_32>'||EOL;
	   l_boxo3  :='<Boxo_code_33>'||t_boxo(1).code||'</Boxo_code_33>'||EOL
		     ||'<Boxo_value_33>'||t_boxo(1).value||'</Boxo_value_33>'||EOL;

        end if;

        p_footnote_boxo1 :=l_footnote1||l_boxo1;
	p_footnote_boxo2 :=l_footnote2||l_boxo2;
	p_footnote_boxo3 :=l_footnote3||l_boxo3;
      elsif l_count = 0 and l_count_boxo < 4 then
        hr_utility.trace('boxo count less than 4');
        for k in 1.. l_count_boxo
	loop
	   l_boxo1  :=l_boxo1||'<Boxo_code_'||k||'1>'||t_boxo(k).code||'</Boxo_code_'||k||'1>'||EOL
		     ||'<Boxo_value_'||k||'1>'||t_boxo(k).value||'</Boxo_value_'||k||'1>'||EOL;
	   l_boxo2  :=l_boxo2||'<Boxo_code_'||k||'2>'||t_boxo(k).code||'</Boxo_code_'||k||'2>'||EOL
		     ||'<Boxo_value_'||k||'2>'||t_boxo(k).value||'</Boxo_value_'||k||'2>'||EOL;
	   l_boxo3  :=l_boxo3||'<Boxo_code_'||k||'3>'||t_boxo(k).code||'</Boxo_code_'||k||'3>'||EOL
		     ||'<Boxo_value_'||k||'3>'||t_boxo(k).value||'</Boxo_value_'||k||'3>'||EOL;

        end loop;
	hr_utility.trace(' l_boxo1 ='|| l_boxo1);
	hr_utility.trace(' l_boxo2 ='|| l_boxo2);
	hr_utility.trace(' l_boxo3 ='|| l_boxo3);

	p_footnote_boxo1 :=l_boxo1;
	p_footnote_boxo2 :=l_boxo2;
	p_footnote_boxo3 :=l_boxo3;

     elsif l_count_boxo > 3 then
        p_footnote_boxo1 :='<Seeattached1>'|| l_see_attached ||'</Seeattached1>';
        p_footnote_boxo2 :='<Seeattached2>'|| l_see_attached ||'</Seeattached2>';
        p_footnote_boxo3 :='<Seeattached3>'|| l_see_attached ||'</Seeattached3>';
     end if;

     hr_utility.trace(' p_footnote_boxo1 ='|| p_footnote_boxo1);
     hr_utility.trace(' p_footnote_boxo2 ='|| p_footnote_boxo2);
     hr_utility.trace(' p_footnote_boxo3 ='|| p_footnote_boxo3);

end xml_footnote_boxo;


 PROCEDURE RL1XML_emplyer_data(p_assact_id IN NUMBER
                              ,p_emplyr_final1 OUT  NOCOPY VARCHAR2
			      ,p_emplyr_final2 OUT  NOCOPY VARCHAR2
			      ,p_emplyr_final3 OUT  NOCOPY VARCHAR2
			      ) is

    CURSOR c_get_arch_pay_actid IS
    SELECT to_number(substr(paa.serial_number,17,14)) payactid --archiver payroll action id
    FROM pay_assignment_actions paa
    WHERE paa.assignment_action_id = p_assact_id;
    l_final_xml_string VARCHAR2(32000);
    l_index             NUMBER;
    l_address_line      hr_locations.address_line_1%TYPE;
    TYPE employer_info IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

    tab_employer employer_info;
    lNoId                    NUMBER;
    lNom1                    NUMBER;
    lLigne1                  NUMBER;
    lLigne2                  NUMBER;
    lVille                   NUMBER;
    lProvince                NUMBER;
    lCodePostal              NUMBER;
    lLigne3                  NUMBER;
    lCountry                 NUMBER;
    l_context1              ff_archive_items.context1%TYPE;
    EOL                     varchar2(5);
    l_employer_name         varchar2(100);
    l_quebec_bn             varchar2(20);

  BEGIN

    hr_utility.trace('XML Employer');

    SELECT
      fnd_global.local_chr(13) || fnd_global.local_chr(10)
    INTO EOL
    FROM dual;

    lNoId         := 1;
    lNom1         := 2;
    lLigne1       := 3;
    lLigne2       := 4;
    lVille        := 5;
    lProvince     := 6;
    lCodePostal   := 7;
    lLigne3       := 8;
    lCountry      := 9;

    open c_get_arch_pay_actid;
       fetch c_get_arch_pay_actid
       into  l_context1;
       close c_get_arch_pay_actid;
    hr_utility.trace ('l_cvontext1 ='||l_context1);

    l_quebec_bn := pay_ca_archive_utils.get_archive_value
              (l_context1,'CAEOY_RL1_QUEBEC_BN');
    tab_employer(lNoId) := substr(l_quebec_bn,1,10); -- employer id

    l_employer_name := pay_ca_archive_utils.get_archive_value(l_context1,
                                            'CAEOY_RL1_EMPLOYER_NAME');

    tab_employer(lNom1) := convert_special_char(l_employer_name);
    hr_utility.trace('tab_employer(lNoId) = ' || tab_employer(lNoId));
    hr_utility.trace('tab_employer(lNom1) = ' || tab_employer(lNom1));

    -- Address Line 1
    l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_ADDRESS_LINE1');
      tab_employer(lLigne1) := convert_special_char(substr(l_address_line,1,40));
      hr_utility.trace('tab_employer(lLigne1) = ' || tab_employer(lLigne1));

      -- Address Line 2
      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_ADDRESS_LINE2');
      tab_employer(lLigne2) := convert_special_char(substr(l_address_line,1,40));
      hr_utility.trace('tab_employer(lLigne2) = ' || tab_employer(lLigne2));

      -- Address Line 3
      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_ADDRESS_LINE3');
      tab_employer(lLigne3) := convert_special_char(substr(l_address_line,1,40));
      hr_utility.trace('tab_employer(lLigne3) = ' || tab_employer(lLigne3));

      if(tab_employer(lLigne2) is not null or tab_employer(lLigne3) is not null) then
      tab_employer(lLigne2) := tab_employer(lLigne2) ||' '|| tab_employer(lLigne3) ; /*******/
      end if;

      -- Ville (City)
      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_CITY');
      tab_employer(lVille) := convert_special_char(substr(l_address_line,1,30));
      hr_utility.trace('tab_employer(lVille) = ' || tab_employer(lVille));

      -- Province

      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_PROVINCE');

      tab_employer(lProvince) :=l_address_line;
      hr_utility.trace('tab_employer(lProvince) = ' || tab_employer(lProvince));

      --Country
      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_COUNTRY');
      tab_employer(lCountry) :=l_address_line;
      hr_utility.trace('tab_employer(lCountry) = ' || tab_employer(lCountry));

      -- Postal Code
      l_address_line := pay_ca_archive_utils.get_archive_value(l_context1,
                  'CAEOY_RL1_EMPLOYER_POSTAL_CODE');
      tab_employer(lCodePostal) :=substr(replace(l_address_line,' '),1,6);

      --final city
      tab_employer(lVille):=tab_employer(lVille)||' '||
                            tab_employer(lProvince)||' '||
                            tab_employer(lCountry) ||' '||
			    substr(tab_employer(lCodePostal),1,3)||' '||
                            substr(tab_employer(lCodePostal),4,3);

      hr_utility.trace('tab_employer(lCodePostal) = ' || tab_employer(lCodePostal));
    for l_index in 1..3 loop
    l_final_xml_string := '<Employer_name'||l_index||'>' ||substr(tab_employer(lNom1),1,40) || '</Employer_name'||l_index||'>' || EOL;

     /*********************************************/
     if tab_employer(lLigne1) is not null
     or tab_employer(lLigne2) is not null
     or tab_employer(lVille) is not null then

         l_final_xml_string := l_final_xml_string||'<emplr_Ligne1'||l_index||'>' ;


	 if tab_employer(lLigne1) is not null then
	     l_final_xml_string := l_final_xml_string||substr(tab_employer(lLigne1),1,40)||EOL;
	 end if;
	 if tab_employer(lLigne2) is not null then
	     l_final_xml_string := l_final_xml_string||substr(tab_employer(lLigne2),1,40)||EOL;
	 end if;
	 if tab_employer(lVille) is not null then
	     l_final_xml_string := l_final_xml_string||substr(tab_employer(lVille),1,40)||EOL;
	 end if;

	 l_final_xml_string := l_final_xml_string|| '</emplr_Ligne1'||l_index||'>' || EOL;
     end if;
     /********************************************/

    /*****************************************************
    if tab_employer(lLigne1) is not null then
       l_final_xml_string := l_final_xml_string
                           ||'<emplr_Ligne1'||l_index||'>' ||substr(tab_employer(lLigne1),1,40)  || '</emplr_Ligne1'||l_index||'>' || EOL;
    end if;
    if tab_employer(lLigne2) is not null then
       l_final_xml_string := l_final_xml_string
                           ||'<emplr_Ligne2'||l_index||'>' ||substr(tab_employer(lLigne2),1,40) || '</emplr_Ligne2'||l_index||'>' || EOL;
    end if;
    if tab_employer(lVille) is not null then
       l_final_xml_string := l_final_xml_string
                           ||'<emplr_Ville'||l_index||'>' ||substr(tab_employer(lVille),1,40) || '</emplr_Ville'||l_index||'>' || EOL;
    end if;
    ******************************************************/


    hr_utility.trace('rl1_xml_employer_start: l_final_xml_string = ' ||  l_final_xml_string);
    if l_index=1 then
        p_emplyr_final1 := l_final_xml_string;
    end if;
    if l_index=2 then
        p_emplyr_final2 := l_final_xml_string;
    end if;
    if l_index=3 then
        p_emplyr_final3 := l_final_xml_string;
    end if;
    end loop;

   END RL1XML_emplyer_data;

   PROCEDURE archive_ca_deinit (p_pactid IN NUMBER) IS

   CURSOR  c_get_report_type ( p_pactid number) IS
   SELECT  report_type
   FROM    pay_payroll_actions
   WHERE   payroll_action_id = p_pactid;

   l_report_type pay_payroll_actions.report_type%type;

   BEGIN

    open c_get_report_type(p_pactid);
    fetch c_get_report_type
    into  l_report_type;
    close c_get_report_type;

   IF l_report_type = 'RL1PAPERPDF' THEN
        pay_ca_payroll_utils.delete_actionid(p_pactid);
    END IF;

  END archive_ca_deinit;
/******************************************** *************************************************************/

END pay_ca_rl1_mag;

/
