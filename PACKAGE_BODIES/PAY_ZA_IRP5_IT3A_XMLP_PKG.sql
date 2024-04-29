--------------------------------------------------------
--  DDL for Package Body PAY_ZA_IRP5_IT3A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_IRP5_IT3A_XMLP_PKG" AS
--  /* $Header: pyzairp5.pkb 120.0.12010000.5 2010/03/23 12:38:41 parusia noship $ */
--
--

g_package   Constant varchar2(30) := 'PAY_ZA_IRP5_IT3A_XMLP_PKG.';
g_current_period  varchar2(2);
g_previous_period varchar2(2);
g_effective_date  date;

-- -----------------------------------------------------------------------------
-- Get Parameters
-- -----------------------------------------------------------------------------
Function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2 is

start_ptr number;
end_ptr   number;
token_val pay_payroll_actions.legislative_parameters%type;
par_value pay_payroll_actions.legislative_parameters%type;

begin
   token_val := name || '=';

   start_ptr := instr(parameter_list, token_val) + length(token_val);
   end_ptr   := instr(parameter_list, ' ', start_ptr);

   /* if there is no spaces, then use the length of the string */
   if end_ptr = 0 then
     end_ptr := length(parameter_list) + 1;
   end if;

   /* Did we find the token */
   if instr(parameter_list, token_val) = 0 then
     par_value := NULL;
   else
     par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
   end if;

   return par_value;
end get_parameter;


--------------------------------------------------------------------------------
-- set_periods procedure
-- This procedure sets the previous period to be considered while picking up the
-- existing certificate numbers. For eg, while creating February's certificate
-- we need to take the certificate number from the existing Aug's certificate,
-- if present.
-- -----------------------------------------------------------------------------
PROCEDURE set_periods (p_period varchar2,p_tax_year varchar2) IS
BEGIN
    g_current_period := p_period;
    IF g_current_period = '02' THEN
	   g_effective_date  := last_day(to_date('01-02-'||p_tax_year,'DD-MM-YYYY'));
   	   g_previous_period := '08' ;
    END IF;
    IF g_current_period = '08' THEN
   	   g_effective_date  := last_day(to_date('01-08-'||to_char(p_tax_year-1),'DD-MM-YYYY'));
       g_previous_period := null;
    END IF;
END set_periods;


-- -----------------------------------------------------------------------------
-- get_payroll_ref procedure
--
-- This period gets the Payroll IRP5 Number from the Statutory Information
-- of the assignment's payroll. Payroll IRP5 Number is an optional field,
-- if null, then '000000' will be used
-- Payroll IRP5 Number will indicate to the customers the payroll for which this
-- certificate is generated. This will form the digits 17-22 of the certificate
-- number
-- -----------------------------------------------------------------------------
FUNCTION get_payroll_ref (p_payroll_id varchar2) return varchar2 IS
   CURSOR get_payroll_ref IS
      SELECT lpad(segment8,6,'0')
      FROM hr_soft_coding_keyflex kff, pay_all_payrolls_f ppf
      WHERE ppf.soft_coding_keyflex_id = kff.soft_coding_keyflex_id
        AND ppf.payroll_id = p_payroll_id
    	AND g_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

l_payroll_ref varchar2(6);
BEGIN
    if p_payroll_id is not null then
       OPEN  get_payroll_ref;
       FETCH get_payroll_ref INTO l_payroll_ref;
       CLOSE get_payroll_ref;
    end if;

    IF l_payroll_ref IS NULL then
       l_payroll_ref := '000000';
    END if;

   RETURN l_payroll_ref;
END get_payroll_ref;


-- -----------------------------------------------------------------------------
-- get_prev_cert_num procedure
--
-- This function returns the active (not Old/Manual) certificate number
-- for the assignment generated for the given PAYE Ref Number, Year and Period
-- for the same certificate type (Main/Lumpsum-directive number)
--
-- This procedure is called twice -
-- 1) For the current period
-- 2) For the previous period
-- For eg, while generating Feb's certificate number, this procedure will be
-- called 1)to get any active certificate number for the assignment for Feb
-- 2) If no active cert found for Feb, then the procedure is called again
-- to get any active certificate number for the assignment for Aug
-- -----------------------------------------------------------------------------
FUNCTION get_prev_cert_num (p_archive_pact number, p_paye_ref varchar2, p_year varchar2,
                            p_assignment_id number, p_period varchar2,
                            p_cert_type varchar2, p_directive_num varchar2
			    ) return varchar2 is
CURSOR csr_prev_cert_num IS
select   pai_1.action_information1   cert_num
  from   pay_payroll_actions    ppa
       , pay_assignment_actions paa
       , pay_action_information pai_1
       , pay_action_information pai_2
       , hr_organization_information hoi
  where   ppa.business_group_id = P_BUSINESS_GROUP_ID
    and   ppa.action_type='X'
    and   ppa.report_type='ZA_TYE'
    and   ppa.action_status='C'
    and   get_parameter('TAX_YEAR', ppa.legislative_parameters) = p_year
    and   get_parameter('LEGAL_ENTITY', ppa.legislative_parameters)  = hoi.organization_id
    and   hoi.org_information_context = 'ZA_LEGAL_ENTITY'
    and   hoi.org_information3 =  p_paye_ref
    and   ppa.payroll_action_id <> p_archive_pact
    and   paa.payroll_action_id  = ppa.payroll_action_id
    and   paa.action_status      = 'C'
    and   paa.assignment_id      = p_assignment_id
    and   pai_1.action_context_type = 'AAP'
    and   pai_1.action_context_id = paa.assignment_action_id
    and   pai_1.action_information_category = 'ZATYE_EMPLOYEE_INFO'
    and   pai_2.action_context_type = 'AAP'
    and   pai_2.action_context_id = paa.assignment_action_id
    and   pai_2.action_information_category = 'ZATYE_EMPLOYEE_CONTACT_INFO'
    and   pai_1.action_information30 = pai_2.action_information30
    and   pai_1.action_information1   like p_paye_ref || p_year || p_period || '%'
    and   pai_2.action_information1   like p_paye_ref || p_year || p_period || '%'
    and   pai_1.action_information28  is NULL -- last active certificate number
    -- matching certificate type
    AND   ( (p_cert_type = 'MAIN' AND pai_2.action_information26 = 'MAIN')
            or
	          (p_cert_type = 'LMPSM' AND pai_2.action_information26 = 'LMPSM'  AND p_directive_num = pai_1.action_information18)
          )
    ;

l_new_cert_num    varchar2(30);
begin
   open  csr_prev_cert_num ;
   FETCH csr_prev_cert_num INTO l_new_cert_num;
   CLOSE csr_prev_cert_num;

   RETURN l_new_cert_num;
end get_prev_cert_num;


-- -----------------------------------------------------------------------------
-- get_new_serial_num function
--
-- This function is called when-
-- 1) The customer says Reissue cert number 'No', but no active certificate
--    could be found for current / previous period
-- 2) The customer says Reissue cert number 'Yes'
--
-- This function gets the max serial number (digits 23-30 of the certificate
-- number) existing for any assignment for given PAYE Ref Num, Year and Payroll
-- Ref, irrespective of the period (digits 15-16). Then adds 1 to it and return
-- as the new serial number to be used.
--
-- -----------------------------------------------------------------------------
FUNCTION get_new_serial_num(p_paye_ref varchar2, p_year varchar2, p_payroll_ref varchar2) return varchar2 is
cursor   csr_max_serial_num is
select   max(substr(pai.action_information1,23,8)) max_serial_num
  from   pay_payroll_actions    ppa
       , pay_assignment_actions paa
       , pay_action_information pai
       , hr_organization_information hoi
  where   ppa.business_group_id = P_BUSINESS_GROUP_ID
    and   ppa.action_type='X'
    and   ppa.report_type='ZA_TYE'
    and   ppa.action_status='C'
    and   get_parameter('TAX_YEAR', ppa.legislative_parameters) = p_year
    and   get_parameter('LEGAL_ENTITY', ppa.legislative_parameters)  = hoi.organization_id
    and   hoi.org_information_context = 'ZA_LEGAL_ENTITY'
    and   hoi.org_information3   =  p_paye_ref
    and   paa.payroll_action_id  = ppa.payroll_action_id
    and   paa.action_status      = 'C'
    and   pai.action_context_type= 'AAP'
    and   pai.action_context_id  = paa.assignment_action_id
    and   pai.action_information_category = 'ZATYE_EMPLOYEE_INFO'
    and   pai.action_information1 like p_paye_ref || p_year || '__' || p_payroll_ref || '%'
    and   ( pai.action_information28 is null or pai.action_information28 = 'O' ); -- do not consider M/OM

l_max_serial_num varchar2(8);
l_new_serial_num varchar2(8);
begin
   open  csr_max_serial_num;
   FETCH csr_max_serial_num INTO l_max_serial_num;
   CLOSE csr_max_serial_num;

   IF l_max_serial_num IS NOT null then
	If l_max_serial_num = '99999999' then
    	    l_new_serial_num := '00000001';
	else
	    l_new_serial_num := lpad(l_max_serial_num + 1,8,'0');
	END if;
   else
        l_new_serial_num := '00000001';
   END if;

   RETURN l_new_serial_num;
end get_new_serial_num;


-- -----------------------------------------------------------------------------
-- mark_all_prev_cert_old function
--
-- This function marks all the non-manual certificates of an assignment for the
-- given PAYE Ref Num and given period (expect those created with current payroll
-- action) as 'Old'.
-- -----------------------------------------------------------------------------
PROCEDURE mark_all_prev_cert_old(p_archive_pact number, p_assignment_id number, p_paye_ref varchar2, p_period varchar2) is

-- For the given assignment for this tax year + period, pick up the certificates
-- which are active (not yet marked 'Old')
-- This cursor should give the certificates created by a single assignment action
-- and hence this cursor should return only one row
cursor csr_all_prev_cert_for_asg is
select distinct paa.assignment_action_id  prev_assact
  from   pay_payroll_actions    ppa
       , pay_assignment_actions paa
       , pay_action_information pai_1
       , hr_organization_information hoi
  where   ppa.business_group_id = P_BUSINESS_GROUP_ID
    and   ppa.action_type='X'
    and   ppa.report_type='ZA_TYE'
    and   ppa.action_status='C'
    and   get_parameter('TAX_YEAR', ppa.legislative_parameters) = P_TAX_YEAR
    and   get_parameter('LEGAL_ENTITY', ppa.legislative_parameters)  = hoi.organization_id
    and   hoi.org_information_context = 'ZA_LEGAL_ENTITY'
    and   hoi.org_information3 =  p_paye_ref
    and   ppa.payroll_action_id <> p_archive_pact
    and   paa.payroll_action_id  = ppa.payroll_action_id
    and   paa.action_status      = 'C'
    and   paa.assignment_id      = p_assignment_id
    and   pai_1.action_context_type = 'AAP'
    and   pai_1.action_context_id = paa.assignment_action_id
    and   pai_1.action_information_category = 'ZATYE_EMPLOYEE_INFO'
    and   pai_1.action_information1   like p_paye_ref || P_TAX_YEAR || p_period || '%'
    and   pai_1.action_information28  is null; -- not 'O'/'M'/'OM'
begin
    for rec_prev_cert in csr_all_prev_cert_for_asg
    loop
           -- Mark all certificates created by this assignment action as 'Old'
           update pay_action_information
           set    action_information28 = 'O'
           where  action_context_type = 'AAP'
	         and    action_context_id = rec_prev_cert.prev_assact
           and    action_information28 is null;
    end loop;
END mark_all_prev_cert_old;


-- -----------------------------------------------------------------------------
-- Before Report Trigger
-- -----------------------------------------------------------------------------
FUNCTION BEFOREREPORT RETURN BOOLEAN IS

 cursor csr_paye_ref (p_legal_entity_id number) is
   select lpad(org_information3,10,'0')
   from hr_organization_information
   where organization_id = p_legal_entity_id
     and org_information_context = 'ZA_LEGAL_ENTITY';

 type t_csr_employee is ref cursor;
 csr_get_employee_info t_csr_employee;

 type emp_rec is record (assignment_id number,
                         p_archive_assacct number,
                         CERTIFICATE_NUMBER varchar2(30),
                         CERTIFICATE_TYPE varchar2(10),
                         DIRECTIVE_NUMBER1 varchar2(100),
		                 TEMP_CERTIFICATE_NUMBER varchar2(30));

 l_proc_name constant      varchar2(200) := g_package || 'BEFOREREPORT' ;
 l_paye_ref_num            varchar2(10);
 l_tax_year                varchar2(4);
 l_max_cert_num_reissue_no varchar2(30);
 l_max_cert_num_reissue_yes varchar2(30);
 l_new_cert_num            varchar2(30);
 l_cert_type               varchar2(10); -- MAIN/LMPSM
 l_archive_pact            number      :=P_PAYROLL_ACTION_ID ;
 l_sort_order              varchar2(1000);
 leg_param                 varchar2(1000);
 l_legal_entity_id         number;
 l_sql                     varchar2(4000);
 p_period                  varchar2(2) := '02';  -- Needs to be checked for mid tax year
 l_employee_info           emp_rec;
 l_payroll_id              number;
 l_payroll_ref             varchar2(6);
 l_prev_asg_id             number;
 l_asg_id                  number;
 l_directive_num           varchar2(100);
 l_last_cert_num           varchar2(30);
 l_new_serial_num          varchar2(8);
 l_effective_date          date;
BEGIN

  -- hr_utility.trace_on(null,'ZACERT');
   ----
   -- updating certificate numbers
   ----

   C_PAYROLL_ACTION_ID := 'and paa.payroll_action_id = '||P_PAYROLL_ACTION_ID;
   C_ACTION_CONTEXT_ID := 'and pai.action_context_id = '||P_PAYROLL_ACTION_ID;
   C_CERTIFICATE_TYPE  := ''''||P_CERTIFICATE_TYPE||'''';
   if  P_ASSIGNMENT_NO is not NULL then
       C_ASSIGNMENT_NO := ' and ass.assignment_id ='||P_ASSIGNMENT_NO;
   else
       C_ASSIGNMENT_NO := 'and ass.assignment_id = ass.assignment_id';
    end if;

  ---
  --  deciding sort order
  ---

  -- Append first sort order
   if p_sort_order1 = '1' then
      l_sort_order := l_sort_order || ' upper(org.name)';
   elsif p_sort_order1 = '2' then
      l_sort_order := l_sort_order || ' upper(pai.Action_Information5), upper(pai.Action_Information6)';
   elsif p_sort_order1 = '3' then
      l_sort_order := l_sort_order || ' lpad(pai.Action_Information13, 30, ''0'')';
   elsif p_sort_order1 = '4' then
      l_sort_order := l_sort_order || ' lpad(ass.assignment_number, 30, ''0'')';
   end if;

   -- Append second sort order
   if p_sort_order2 = '1' then
      l_sort_order := l_sort_order || ', upper(org.name)';
   elsif p_sort_order2 = '2' then
      l_sort_order := l_sort_order || ', upper(pai.Action_Information5), upper(pai.Action_Information6)';
   elsif p_sort_order2 = '3' then
      l_sort_order := l_sort_order || ', lpad(pai.Action_Information13, 30, ''0'')';
   elsif p_sort_order2 = '4' then
      l_sort_order := l_sort_order || ', lpad(ass.assignment_number, 30, ''0'')';
   end if;

   -- Append third sort order
   if p_sort_order3 = '1' then
      l_sort_order := l_sort_order || ', upper(org.name)';
   elsif p_sort_order3 = '2' then
      l_sort_order := l_sort_order || ', upper(pai.Action_Information5), upper(pai.Action_Information6)';
   elsif p_sort_order3 = '3' then
      l_sort_order := l_sort_order || ', lpad(pai.Action_Information13, 30, ''0'')';
   elsif p_sort_order3 = '4' then
      l_sort_order := l_sort_order || ', lpad(ass.assignment_number, 30, ''0'')';
   end if;

   -- Append fourth sort order
   if p_sort_order4 = '1' then
      l_sort_order := l_sort_order || ', upper(org.name)';
   elsif p_sort_order4 = '2' then
      l_sort_order := l_sort_order || ', upper(pai.Action_Information5), upper(pai.Action_Information6)';
   elsif p_sort_order4 = '3' then
      l_sort_order := l_sort_order || ', lpad(pai.Action_Information13, 30, ''0'')';
   elsif p_sort_order4 = '4' then
      l_sort_order := l_sort_order || ', lpad(ass.assignment_number, 30, ''0'')';
   end if;

   C_SORT_ORDER := l_sort_order || ', pai.action_information30 asc';

   l_sql := 'select  pai.assignment_id,
                     paa.assignment_action_id p_archive_assacct,
                     pai.action_information1  CERTIFICATE_NUMBER,
    	             pai.action_information2  CERTIFICATE_TYPE,
                     pai.action_information18 DIRECTIVE_NUMBER1,
		             pai.action_information30 TEMP_CERTIFICATE_NUMBER
             from pay_action_information pai,
	              pay_assignment_actions paa,
                  hr_all_organization_units org,
                  per_all_assignments_f ass,
                  pay_payroll_actions ppa
            where  pai.action_context_id = paa.assignment_action_id
               and paa.payroll_action_id = :1
               and pai.action_context_type = ''AAP''
               and pai.action_information_category = ''ZATYE_EMPLOYEE_INFO''
               and ( pai.action_information28 is null
                     or
                     pai.action_information28 not in (''M'',''OM'')
                   )
               and Action_Information2 = :2
               and paa.ASSIGNMENT_ID = ass.ASSIGNMENT_ID
               and paa.PAYROLL_ACTION_ID = ppa.PAYROLL_ACTION_ID
               and (select least(ppa.EFFECTIVE_DATE, (select max(effective_end_date)
                                                      from per_all_assignments_f paaf
                                                      where  paaf.assignment_id = ass.assignment_id))
                    from dual)
                               between ass.EFFECTIVE_START_DATE and ass.EFFECTIVE_END_DATE
               and ass.organization_id = org.organization_id (+)
               and paa.ASSIGNMENT_ID = NVL(:3, paa.ASSIGNMENT_ID) order by '|| C_SORT_ORDER;


   -- Retrieve legislative parameters from the archiver payroll action
   select legislative_parameters
   into   leg_param
   from   pay_payroll_actions
   where  payroll_action_id = l_archive_pact;

   l_legal_entity_id  := get_parameter('LEGAL_ENTITY', leg_param);
   l_tax_year         := lpad(get_parameter('TAX_YEAR',  leg_param),4,'0');

   open csr_paye_ref (l_legal_entity_id);
   fetch csr_paye_ref into l_paye_ref_num;
   close csr_paye_ref;

   set_periods (p_period, P_TAX_YEAR);

   hr_utility.set_location('P_DUMMY_RUN='||P_DUMMY_RUN,10);
   hr_utility.set_location('P_REISSUE_IRP5='||P_REISSUE_IRP5,10);
   hr_utility.set_location('l_paye_ref_num='||l_paye_ref_num,10);
   hr_utility.set_location('P_TAX_YEAR='||P_TAX_YEAR,10);
   hr_utility.set_location('P_BUSINESS_GROUP_ID='||P_BUSINESS_GROUP_ID,10);
   hr_utility.set_location('P_SORT_ORDER1='||P_SORT_ORDER1,10);
   hr_utility.set_location('P_PAYROLL_ACTION_ID='||P_PAYROLL_ACTION_ID,10);
   hr_utility.set_location('P_CERTIFICATE_TYPE='||P_CERTIFICATE_TYPE,10);
   hr_utility.set_location('P_ASSIGNMENT_NO='||P_ASSIGNMENT_NO,10);
   hr_utility.trace('SORT_ORDER='||C_SORT_ORDER);

   l_prev_asg_id := null;

  -- Fetch certificates
  open csr_get_employee_info for l_sql using P_PAYROLL_ACTION_ID, P_CERTIFICATE_TYPE, P_ASSIGNMENT_NO;
  loop

  fetch csr_get_employee_info into l_employee_info;
  exit when csr_get_employee_info%notfound;

  -- Certificate Number Generation

  --
  -- CERTIFICATE NUMBER FORMAT ---
  --
  -- PAYE Ref Num (digit 1-10  )
  -- YEAR         (digit 11-14 )
  -- PERIOD       (digit 15-16 )
  -- Payroll Ref  (digit 17-22 )
  -- Serial Number(digit 23-30 )
  --

  l_asg_id       := l_employee_info.assignment_id;
  hr_utility.trace('Assignment_id :'||l_asg_id);

  -- If we have moved to the next assignment, then call mark_all_prev_cert_old
  -- for the previous assignment to mark all previous (not generated by this
  -- payroll action) certificates of that assignment for the current period
  -- as 'Old'
  IF l_prev_asg_id IS NOT NULL AND l_prev_asg_id <> l_asg_id  THEN
     hr_utility.set_location(l_proc_name, 20);
     mark_all_prev_cert_old (l_archive_pact, l_prev_asg_id, l_paye_ref_num, g_current_period);
  END if;

  l_new_cert_num := null;
  if P_DUMMY_RUN = 'Y' then
       -- For dummy run, do not generate/return certificate number
      hr_utility.set_location(l_proc_name, 30);
      l_new_cert_num := NULL;
  else

      hr_utility.set_location(l_proc_name, 40);
     if l_employee_info.CERTIFICATE_NUMBER is not null then
        -- Certificate Number has already been generated for this certificate
        -- Return same certificate number
        hr_utility.set_location(l_proc_name, 50);
        l_new_cert_num := l_employee_info.CERTIFICATE_NUMBER;

     else
        -- Generate certificate number
        hr_utility.set_location(l_proc_name, 60);

        -- Get Payroll IRP5 Number for this assignment
        select least(g_effective_date,max(effective_end_date))
        into   l_effective_date
        from   per_all_assignments_f
        where  assignment_id = l_asg_id;

        select payroll_id
        into l_payroll_id
        from per_all_assignments_f
        where assignment_id = l_asg_id
          and l_effective_date between effective_start_date and effective_end_date ;

        l_payroll_ref := get_payroll_ref(l_payroll_id);
        hr_utility.trace('l_effective_date :'||l_effective_date);
        hr_utility.trace('l_payroll_id :'||l_payroll_id);
        hr_utility.trace('l_payroll_ref :'||l_payroll_ref);

        -- REISSUE means "Reissue new certificate numbers"
        -- If "No" then
        --   1) Get any active (not 'Old') certificate for the assignment for
        --      the CURRENT period with same cert type (Main/Lumpsum). If found,
        --      use the same certificate number.
        --   2) If no cert number found in Step1, then
        --      get any active (not 'Old') certificate for the assignment for
        --      the PREVIOUS period with same cert type (Main/Lumpsum). If found,
        --      use the same certificate number after replacing the period digits
        --      (digit 15-16).
        --   3) If no cert number found in Step1 and Step2, then
        --      get the max serial number(digits 23-30) used till date for the
        --      given PAYE Ref, year, and payroll ref, irrespective of the period.
        --      Add 1 to it, and use this new serial number to create new certificate
        --     number.
        -- If "Yes" then
        --     use the same mechanism as in Step 3 above to create new certificate
        --     number.
        if P_REISSUE_IRP5 = 'N' then

            hr_utility.set_location(l_proc_name, 70);
            -- Pick up certificate type (MAIN / LMPSM) of this current certificate
            select action_information26
            into l_cert_type
            from pay_action_information
            where action_context_type = 'AAP'
              and action_context_id   = l_employee_info.p_archive_assacct
              and action_information_category = 'ZATYE_EMPLOYEE_CONTACT_INFO'
              and action_information30 = l_employee_info.TEMP_CERTIFICATE_NUMBER;

            l_directive_num := l_employee_info.DIRECTIVE_NUMBER1;

            hr_utility.trace('l_cert_type :'||l_cert_type);
            hr_utility.trace('l_directive_num :'||l_directive_num);

            -- check for the active(non-old) certificate issued for this assignment in this period
	          l_last_cert_num := get_prev_cert_num (l_archive_pact, l_paye_ref_num, P_TAX_YEAR, l_asg_id, g_current_period, l_cert_type, l_directive_num);
   	        l_new_cert_num  := l_last_cert_num;

            -- if no certificate issued in this period
            if l_new_cert_num is null then
             hr_utility.set_location(l_proc_name, 80);
 	           if g_previous_period is not null then
                    -- check for the last(non-old) certificate issued for this assignment in previous period
                    -- and use the same certificate number (after replacing period_id)
                  hr_utility.set_location(l_proc_name, 90);
             	    l_last_cert_num := get_prev_cert_num (l_archive_pact, l_paye_ref_num, P_TAX_YEAR, l_asg_id, g_previous_period, l_cert_type, l_directive_num);
                  if l_last_cert_num is not null then
                      hr_utility.set_location(l_proc_name, 100);
       		            l_new_cert_num  := substr(l_last_cert_num, 1,14) || g_current_period || SUBSTR(l_last_cert_num,17,14);
                  end if;
    	       end if;
	        end if;

            -- if no certificate issued in current or previous period
            -- then issue a new certificate number
            hr_utility.set_location(l_proc_name, 110);
            if l_new_cert_num is null then
              hr_utility.set_location(l_proc_name, 120);
        		  l_new_serial_num := get_new_serial_num(l_paye_ref_num, P_TAX_YEAR, l_payroll_ref);
	           	l_new_cert_num   := l_paye_ref_num || P_TAX_YEAR || g_current_period || l_payroll_ref || l_new_serial_num;
    	    end if;

        else -- P_REISSUE_IRP5 = 'Y'
            -- issue a new certificate number
            hr_utility.set_location(l_proc_name, 130);
            hr_utility.trace('l_payroll_ref :'||l_payroll_ref);
            l_new_serial_num := get_new_serial_num(l_paye_ref_num, P_TAX_YEAR, l_payroll_ref);
      	    l_new_cert_num   := l_paye_ref_num || P_TAX_YEAR || g_current_period || l_payroll_ref || l_new_serial_num;
       end if;

       hr_utility.set_location(l_proc_name, 140);
        -- Update all archive records for this certificate with new certificate number
        update pay_action_information
        set action_information1 = l_new_cert_num
        where action_context_type = 'AAP'
          and action_context_id = l_employee_info.p_archive_assacct
          and action_information30 = l_employee_info.TEMP_CERTIFICATE_NUMBER;
     end if; -- closing if l_employee_info.CERTIFICATE_NUMBER is not null

     hr_utility.set_location(l_proc_name, 150);

  end if; -- closing if P_DUMMY_RUN = 'Y'
  l_prev_asg_id := l_asg_id ;
  hr_utility.set_location('Certificate Number : '||l_new_cert_num, 13);

  END LOOP;

  hr_utility.set_location(l_proc_name, 160);

  -- mark all previous certificates of the last assignment for current period as Old
  if P_DUMMY_RUN <> 'Y' then
     hr_utility.set_location(l_proc_name, 170);
     mark_all_prev_cert_old (l_archive_pact, l_asg_id, l_paye_ref_num, g_current_period);
  end if;


  if csr_get_employee_info%ISOPEN then
     close csr_get_employee_info;
  end if;

RETURN true;
END BEFOREREPORT;

-- -----------------------------------------------------------------------------
-- Get Time Stamp
-- This function will return seconds from start of year till current system time
-- -----------------------------------------------------------------------------

Function get_timestamp return number is
l_start_date  varchar2(10) ;
l_curr_date   varchar2(20) ;
l_no_days   varchar2(10);
l_no_hours varchar2(10);
l_no_min   varchar2(10);
l_no_sec   varchar2(10);
Begin

l_curr_date    := to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss');
-- start date should be start of the year of sysdate
l_start_date   := '01-01-'||substr(l_curr_date, 7, 4);

l_no_days := to_date(substr(l_curr_date, 1 , 10), 'dd-mm-yyyy') - to_date(l_start_date, 'dd-mm-yyyy')+1;
l_no_hours := substr(l_curr_date, 12, 2);
l_no_min := substr(l_curr_date, 15, 2);
l_no_sec := substr(l_curr_date, 18, 2);
 return (l_no_days*86400)+(l_no_min*3600)+(l_no_min*60)+ l_no_sec;
End;

END PAY_ZA_IRP5_IT3A_XMLP_PKG;

/
