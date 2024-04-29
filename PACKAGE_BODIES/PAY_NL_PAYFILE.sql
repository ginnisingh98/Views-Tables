--------------------------------------------------------
--  DDL for Package Body PAY_NL_PAYFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_PAYFILE" as
/* $Header: pynleftp.pkb 120.3.12010000.2 2009/07/29 12:15:55 namgoyal ship $ */
g_package                  varchar2(33) := '  PAY_NL_PAYFILE.';
-- Global Variables
hr_formula_error  EXCEPTION;
g_payee_details_formula_exists  BOOLEAN := TRUE;
g_payee_details_formula_cached  BOOLEAN := FALSE;
g_payee_details_formula_id      ff_formulas_f.formula_id%TYPE;
g_payee_details_formula_name    ff_formulas_f.formula_name%TYPE;
g_trans_desc_formula_exists  BOOLEAN := TRUE;
g_trans_desc_formula_cached  BOOLEAN := FALSE;
g_trans_desc_formula_id      ff_formulas_f.formula_id%TYPE;
g_trans_desc_formula_name    ff_formulas_f.formula_name%TYPE;
------------------------------------------------------------------------------
-- Global Variables for over riding Oraganization Name
------------------------------------------------------------------------------
g_org_details_formula_exists  BOOLEAN := TRUE;
g_org_details_formula_cached  BOOLEAN := FALSE;
g_org_details_formula_id      ff_formulas_f.formula_id%TYPE;
g_org_details_formula_name    ff_formulas_f.formula_name%TYPE;
-----------------------------------------------------------------------------


FUNCTION  get_payee_details(p_assignment_id              IN NUMBER
                           ,p_business_group_id          IN NUMBER
			   ,p_per_pay_method_id 	 IN NUMBER
                           ,p_date_earned                IN DATE
                           ,p_payee_address             OUT NOCOPY VARCHAR2
                           ) RETURN VARCHAR2 IS
--
  CURSOR csr_get_payee_type_id IS
  SELECT payee_type,payee_id
  FROM   pay_personal_payment_methods_f ppm
  WHERE  ppm.assignment_id              = p_assignment_id
  AND    ppm.personal_payment_method_id = p_per_pay_method_id
  AND    p_date_earned    BETWEEN ppm.effective_start_date
                                        AND     ppm.effective_end_date
  AND    ppm.business_group_id          = p_business_group_id
  AND    ppm.payee_id is NOT NULL;
--
cursor csr_org_count (p_org_id pay_personal_payment_methods_f.payee_id%TYPE) is
select count(*) from
hr_All_organization_units  hou,
hr_organization_information hoi
where hou.organization_id = p_org_id
and   hoi.organization_id = hou.organization_id
and    hoi.org_information_context = 'CLASS'
and    hoi.org_information1 = 'NL_PAYEE_OVERRIDE'
and   hoi.org_information2='Y';
--
  l_payee_type  pay_personal_payment_methods_f.payee_type%TYPE;
  l_payee_id    pay_personal_payment_methods_f.payee_id%TYPE;
  l_payee_name VARCHAR(35);
  l_org_count NUMBER;
--
  l_inputs  ff_exec.inputs_t;
  l_outputs ff_exec.outputs_t;
  p_formula_exists  BOOLEAN := TRUE;
  p_formula_cached  BOOLEAN := FALSE;
  p_formula_id      ff_formulas_f.formula_id%TYPE;
  p_formula_name    ff_formulas_f.formula_name%TYPE;
--
BEGIN
--
-- To be removed.
 -- hr_utility.trace_on(null,'EFT');
-- hr_utility.set_location('--In Get Payee Details ',10);
  g_payee_details_formula_name := 'NL_PAYEE_REPORTING_NAME';
  g_org_details_formula_name := 'NL_ORG_PAYEE_REPORTING_NAME';
  l_payee_name := ' ';
  OPEN csr_get_payee_type_id;
    FETCH csr_get_payee_type_id INTO l_payee_type,l_payee_id;
IF csr_get_payee_type_id%FOUND THEN
       --
/* A check is made to see whether thsi organization having the Dutch
   Payee Override Classification or not */
  IF l_payee_type = 'O'  THEN
	OPEN csr_org_count(l_payee_id);
	 FETCH csr_org_count  INTO l_org_count;
	 IF l_org_count >0 THEN
	      --
	     IF g_org_details_formula_exists = TRUE THEN
		IF g_org_details_formula_cached = FALSE THEN
		    cache_formula('NL_ORG_PAYEE_REPORTING_NAME',p_business_group_id,p_date_earned,p_formula_id,p_formula_exists,p_formula_cached);
		    g_org_details_formula_exists:=p_formula_exists;
		    g_org_details_formula_cached:=p_formula_cached;
		    g_org_details_formula_id:=p_formula_id;
		    END IF;
		--
		  IF g_org_details_formula_exists  THEN
		    --
		    l_inputs(1).name  := 'ASSIGNMENT_ID';
		    l_inputs(1).value := p_assignment_id;
		    l_inputs(2).name  := 'ORGANIZATION_ID';
		    l_inputs(2).value := l_payee_id;
		    l_inputs(3).name  := 'DATE_EARNED';
		    l_inputs(3).value := fnd_date.date_to_canonical(p_date_earned);
		    l_inputs(4).name  := 'BUSINESS_GROUP_ID';
		    l_inputs(4).value := p_business_group_id;
		  --
		    l_outputs(1).name := 'REPORTING_NAME';
		  --
		    run_formula(p_formula_id       => g_org_details_formula_id,
			            p_effective_date   => p_date_earned,
			            p_formula_name     => g_org_details_formula_name,
                        p_inputs           => l_inputs,
			            p_outputs          => l_outputs);
		  --
		    l_payee_name := substr(l_outputs(1).value,1,32);
		    p_payee_address := nvl(substr(get_payee_address(l_payee_id
                                                 , l_payee_type
                                                 , p_date_earned),1,35),' ');
		    RETURN l_payee_name;
		        CLOSE csr_org_count;
		  END IF;

	     END IF;
	 END IF;


       -- Get PAYE Name
       --
		l_payee_name:=substr(pay_org_payment_methods_pkg.payee_type(
                                              l_payee_type
                                             ,l_payee_id
                                             ,p_date_earned),1,35);       --
       -- Get PAYE Address
       --

		 p_payee_address := nvl(substr(get_payee_address(l_payee_id
                                                 , l_payee_type
                                                 , p_date_earned),1,35),' ');
       hr_utility.set_location('--In Core PAYEE Return ',11);

     RETURN l_payee_name;
     CLOSE csr_org_count;
     CLOSE csr_get_payee_type_id;

ELSIF l_payee_type = 'P' OR  l_payee_type = 'p' THEN
	      --
	      IF g_payee_details_formula_exists = TRUE  THEN

	            hr_utility.set_location('-- In the formula if ',111);


		    IF g_payee_details_formula_cached = FALSE THEN
		    cache_formula('NL_PAYEE_REPORTING_NAME',p_business_group_id,p_date_earned,p_formula_id,p_formula_exists,p_formula_cached);
		    g_payee_details_formula_exists:=p_formula_exists;
		    g_payee_details_formula_cached:=p_formula_cached;
		    g_payee_details_formula_id:=p_formula_id;
		    END IF;
		--
		    IF g_payee_details_formula_exists  THEN
		    --
		    --
		    l_inputs(1).name  := 'ASSIGNMENT_ID';
		    l_inputs(1).value := p_assignment_id;
		    l_inputs(2).name  := 'PERSON_ID';
		    l_inputs(2).value := l_payee_id;
		    l_inputs(3).name  := 'DATE_EARNED';
		    l_inputs(3).value := fnd_date.date_to_canonical(p_date_earned);
		    l_inputs(4).name  := 'BUSINESS_GROUP_ID';
		    l_inputs(4).value := p_business_group_id;
		  --
		    l_outputs(1).name := 'REPORTING_NAME';
		  --
		    run_formula(p_formula_id       => g_payee_details_formula_id,
			            p_effective_date   => p_date_earned,
			            p_formula_name     => g_payee_details_formula_name,
                        	    p_inputs           => l_inputs,
			            p_outputs          => l_outputs);
		  --
		    l_payee_name := substr(l_outputs(1).value,1,32);
		     p_payee_address := nvl(substr(get_payee_address(l_payee_id
                                                 , l_payee_type
                                                 , p_date_earned),1,35),' ');
		    return l_payee_name;
		         CLOSE csr_get_payee_type_id;
		    END IF;
	      END IF;

	          -- Get PAYE Name
                -- hr_utility.set_location('--After the formula if ',115);

		l_payee_name:=substr(pay_org_payment_methods_pkg.payee_type(
                                              l_payee_type
                                             ,l_payee_id
                                             ,p_date_earned),1,35);

               -- hr_utility.set_location('--l_payee name '||l_payee_name ,117);

	      -- Get PAYE Address
	      --
	     -- hr_utility.set_location('--In Formula Return ',11);
             	     p_payee_address := nvl(substr(get_payee_address(l_payee_id
                                                 , l_payee_type
                                                 , p_date_earned),1,35),' ');
	                     -- hr_utility.set_location('--p_payee_address '||p_payee_address ,119);

	      RETURN l_payee_name;
	        CLOSE csr_get_payee_type_id;

     END IF;
    --
  ELSE

 	IF g_payee_details_formula_exists = TRUE  THEN


		    IF g_payee_details_formula_cached = FALSE THEN
		    cache_formula('NL_PAYEE_REPORTING_NAME',p_business_group_id,p_date_earned,p_formula_id,p_formula_exists,p_formula_cached);
		    g_payee_details_formula_exists:=p_formula_exists;
		    g_payee_details_formula_cached:=p_formula_cached;
		    g_payee_details_formula_id:=p_formula_id;
		    END IF;
		--
		    IF g_payee_details_formula_exists  THEN
		    --
		    --
		    l_inputs(1).name  := 'ASSIGNMENT_ID';
		    l_inputs(1).value := p_assignment_id;
		    l_inputs(2).name  := 'PERSON_ID';
		    l_inputs(2).value := l_payee_id;
		    l_inputs(3).name  := 'DATE_EARNED';
		    l_inputs(3).value := fnd_date.date_to_canonical(p_date_earned);
		    l_inputs(4).name  := 'BUSINESS_GROUP_ID';
		    l_inputs(4).value := p_business_group_id;
		  --
		    l_outputs(1).name := 'REPORTING_NAME';
		  --
		    run_formula(p_formula_id       => g_payee_details_formula_id,
			            p_effective_date   => p_date_earned,
			            p_formula_name     => g_payee_details_formula_name,
                        	    p_inputs           => l_inputs,
			            p_outputs          => l_outputs);
		  --
		    l_payee_name := substr(l_outputs(1).value,1,32);

		   SELECT person_id INTO l_payee_id
		      FROM   per_all_assignments_f paf
		      WHERE  paf.assignment_id = p_assignment_id
		      AND    p_date_earned BETWEEN paf.effective_start_date
				      AND     paf.effective_end_date;

  		   l_payee_type := 'P';

		     p_payee_address := nvl(substr(get_payee_address(l_payee_id
                                                 , l_payee_type
                                                 , p_date_earned),1,35),' ');


		    return l_payee_name;
		         CLOSE csr_get_payee_type_id;
		    END IF;
	      END IF;

      SELECT person_id INTO l_payee_id
	      FROM   per_all_assignments_f paf
	      WHERE  paf.assignment_id = p_assignment_id
	      AND    p_date_earned BETWEEN paf.effective_start_date
				      AND     paf.effective_end_date;

     l_payee_type := 'P';

     l_payee_name:= ' ';

		 l_payee_name:= nvl(l_payee_name,' ');

               -- hr_utility.set_location('--l_payee name '||l_payee_name ,117);

	      -- Get PAYE Address
	      --
	     -- hr_utility.set_location('--In Formula Return ',11);
             	     p_payee_address := nvl(substr(get_payee_address(l_payee_id
                                                 , l_payee_type
                                                 , p_date_earned),1,35),' ');

	     CLOSE csr_get_payee_type_id;
             return l_payee_name ;
  END IF;
--
END get_payee_details;

FUNCTION get_transaction_desc (p_assignment_id IN NUMBER
            		       ,p_date_earned IN DATE
            		       ,p_business_group_id IN NUMBER
	                       ,p_transaction_desc IN VARCHAR2
	                       ,p_prepayment_id IN VARCHAR2
		               ) RETURN VARCHAR2 IS
	l_transaction_desc varchar(131);
	l_inputs  ff_exec.inputs_t;
  	l_outputs ff_exec.outputs_t;
    p_formula_exists  BOOLEAN := TRUE;
    p_formula_cached  BOOLEAN := FALSE;
    p_formula_id      ff_formulas_f.formula_id%TYPE;
    p_formula_name    ff_formulas_f.formula_name%TYPE;
    BEGIN
    	g_trans_desc_formula_name := 'NL_TRANSACTION_DESCRIPTION';
        IF g_trans_desc_formula_exists = TRUE THEN
            IF g_trans_desc_formula_cached = FALSE THEN
		    cache_formula('NL_TRANSACTION_DESCRIPTION',p_business_group_id,p_date_earned,p_formula_id,p_formula_exists,p_formula_cached);
		    g_trans_desc_formula_exists:=p_formula_exists;
		    g_trans_desc_formula_cached:=p_formula_cached;
		    g_trans_desc_formula_id:=p_formula_id;
            END IF;
		--
            IF g_trans_desc_formula_exists = TRUE THEN
          --  hr_utility.trace('FORMULA EXISTS');
		  --
	    	  l_inputs(1).name  := 'ASSIGNMENT_ID';
	    	  l_inputs(1).value := p_assignment_id;
	    	  l_inputs(2).name  := 'DATE_EARNED';
	    	  l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
	    	  l_inputs(3).name  := 'BUSINESS_GROUP_ID';
	    	  l_inputs(3).value := p_business_group_id;
	    	  l_inputs(4).name  := 'PRE_PAYMENT_ID';
	    	  l_inputs(4).value := p_prepayment_id;
		  --
    		  l_outputs(1).name := 'TRANSACTION_DESCRIPTION';
		  --
	    	  run_formula(p_formula_id       => g_trans_desc_formula_id,
	           		      p_effective_date   => p_date_earned,
                          p_formula_name     => g_trans_desc_formula_name,
			              p_inputs           => l_inputs,
			              p_outputs          => l_outputs);
		  --
		      l_transaction_desc := substr(l_outputs(1).value,1,128);
        --  hr_utility.trace('p_transaction_desc'||p_transaction_desc);
      --    hr_utility.trace('l_transaction_desc'||l_transaction_desc);
	    ELSE
        --  hr_utility.trace('FORMULA DOESNT EXISTS');
		      l_transaction_desc := p_transaction_desc;
        --  hr_utility.trace('p_transaction_desc'||p_transaction_desc);
        --  hr_utility.trace('l_transaction_desc'||l_transaction_desc);
            END IF;
        ELSIF g_trans_desc_formula_exists = FALSE THEN
            l_transaction_desc := p_transaction_desc;
        END IF;
    RETURN l_transaction_desc;
END get_transaction_desc;
PROCEDURE cache_formula(p_formula_name           IN VARCHAR2
                        ,p_business_group_id     IN NUMBER
                        ,p_effective_date        IN DATE
                        ,p_formula_id		 IN OUT NOCOPY NUMBER
                        ,p_formula_exists	 IN OUT NOCOPY BOOLEAN
                        ,p_formula_cached	 IN OUT NOCOPY BOOLEAN
                        ) IS
--
  CURSOR c_compiled_formula_exist IS
  SELECT 'Y'
  FROM   ff_formulas_f ff
        ,ff_compiled_info_f ffci
  WHERE  ff.formula_id           = ffci.formula_id
  AND    ff.effective_start_date = ffci.effective_start_date
  AND    ff.effective_end_date   = ffci.effective_end_date
  AND    ff.formula_id           = p_formula_id
  AND    ff.business_group_id    = p_business_group_id
  AND    p_effective_date        BETWEEN ff.effective_start_date
                                 AND     ff.effective_end_date;
--
  CURSOR c_get_formula(p_formula_name ff_formulas_f.formula_name%TYPE
                                 ,p_effective_date DATE)  IS
  SELECT ff.formula_id
  FROM   ff_formulas_f ff
  WHERE  ff.formula_name         = p_formula_name
  AND    ff.business_group_id    = p_business_group_id
  AND    p_effective_date        BETWEEN ff.effective_start_date
                                 AND     ff.effective_end_date;
--
l_test VARCHAR2(1);
BEGIN
--
  IF p_formula_cached = FALSE THEN
  --
  --
    OPEN c_get_formula(p_formula_name,p_effective_date);
    FETCH c_get_formula INTO p_formula_id;
      IF c_get_formula%FOUND THEN
         OPEN c_compiled_formula_exist;
         FETCH c_compiled_formula_exist INTO l_test;
         IF  c_compiled_formula_exist%NOTFOUND THEN
           p_formula_cached := FALSE;
           p_formula_exists := FALSE;
           --
           fnd_message.set_name('PAY','FFX03A_FORMULA_NOT_FOUND');
           fnd_message.set_token('1', p_formula_name);
           fnd_message.raise_error;
         ELSE
           p_formula_cached := TRUE;
           p_formula_exists := TRUE;
         END IF;
      ELSE
        p_formula_cached := FALSE;
        p_formula_exists := FALSE;
      END IF;
    CLOSE c_get_formula;
  END IF;
--
END cache_formula;
PROCEDURE run_formula(p_formula_id      IN NUMBER
                     ,p_effective_date  IN DATE
                     ,p_formula_name    IN VARCHAR2
                     ,p_inputs          IN ff_exec.inputs_t
                     ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t) IS
l_inputs ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
BEGIN
  hr_utility.set_location('--In Formula ',20);
  --
  -- Initialize the formula
  --
  ff_exec.init_formula(p_formula_id, p_effective_date  , l_inputs, l_outputs);
  --
  -- Set up the input values
  --
  IF l_inputs.count > 0 and p_inputs.count > 0 THEN
    FOR i IN l_inputs.first..l_inputs.last LOOP
      FOR j IN p_inputs.first..p_inputs.last LOOP
        IF l_inputs(i).name = p_inputs(j).name THEN
           l_inputs(i).value := p_inputs(j).value;
           exit;
        END IF;
     END LOOP;
    END LOOP;
  END IF;
  --
  -- Run the formula
  --
  ff_exec.run_formula(l_inputs,l_outputs);
  --
  -- Populate the output table
  --
  IF l_outputs.count > 0 and p_inputs.count > 0 then
    FOR i IN l_outputs.first..l_outputs.last LOOP
        FOR j IN p_outputs.first..p_outputs.last LOOP
            IF l_outputs(i).name = p_outputs(j).name THEN
              p_outputs(j).value := l_outputs(i).value;
              exit;
            END IF;
        END LOOP;
    END LOOP;
  END IF;
  hr_utility.set_location('--Leaving Formula ',21);
  EXCEPTION
  WHEN hr_formula_error THEN
      fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
      fnd_message.set_token('1', p_formula_name);
      fnd_message.raise_error;
  WHEN OTHERS THEN
    raise;
--
END run_formula;
FUNCTION  get_payee_address(p_payee_id   IN NUMBER
                           ,p_payee_type IN VARCHAR2
                           ,p_effective_date IN DATE) RETURN VARCHAR2 AS
--
  CURSOR csr_get_per_address_style(p_payee_id NUMBER) IS		-- to get the address style
  SELECT substr(style,1,35) style
  FROM   per_addresses pas
  WHERE  pas.person_id    = p_payee_id
  AND    pas.primary_flag = 'Y'
  AND    p_effective_date BETWEEN pas.date_from
                          AND     nvl(pas.date_to,to_date('31/12/4712','DD/MM/YYYY'));
--
  CURSOR csr_get_per_address(p_payee_id NUMBER) IS		-- to get the city when address style is Netherlands
  SELECT substr(hr_general.decode_lookup('HR_NL_CITY',town_or_city),1,35) town_or_city
  FROM   per_addresses pas
  WHERE  pas.person_id    = p_payee_id
  AND    pas.primary_flag = 'Y'
  AND    p_effective_date BETWEEN pas.date_from
                          AND     nvl(pas.date_to,to_date('31/12/4712','DD/MM/YYYY'));
--
 CURSOR csr_get_per_address1(p_payee_id NUMBER) IS		-- to get the city when address style is Netherlands (International)
  SELECT substr(town_or_city,1,35) town_or_city
  FROM   per_addresses pas
  WHERE  pas.person_id    = p_payee_id
  AND    pas.primary_flag = 'Y'
  AND    p_effective_date BETWEEN pas.date_from
                          AND     nvl(pas.date_to,to_date('31/12/4712','DD/MM/YYYY'));
--
  CURSOR csr_get_org_address(p_payee_id NUMBER) IS
  SELECT substr(hr_general.decode_lookup('HR_NL_CITY',town_or_city),1,35) town_or_city
  FROM   hr_locations_all hla
 	      ,hr_all_organization_units hou
  WHERE  hou.organization_id = p_payee_id
  AND    hou.location_id     = hla.location_id;
--
  l_payee_address VARCHAR2(35);
  l_payee_address_style VARCHAR2(35);
--
BEGIN
hr_utility.set_location('--In Payee Address ',30);
--
  IF p_payee_type = 'P' THEN -- Person Address
     OPEN csr_get_per_address_style(p_payee_id);
     FETCH csr_get_per_address_style INTO l_payee_address_style;
     CLOSE csr_get_per_address_style;
     IF l_payee_address_style='NL' THEN
     	OPEN csr_get_per_address(p_payee_id);
    	FETCH csr_get_per_address INTO l_payee_address;
   	CLOSE csr_get_per_address;
     ELSIF l_payee_address_style='NL_GLB' THEN
     	OPEN csr_get_per_address1(p_payee_id);
    	FETCH csr_get_per_address1 INTO l_payee_address;
   	CLOSE csr_get_per_address1;
     END IF;
  ELSIF p_payee_type = 'O' THEN   -- Organization Address
     OPEN csr_get_org_address(p_payee_id);
     FETCH csr_get_org_address INTO l_payee_address;
     CLOSE csr_get_org_address;
  END IF;
--
  hr_utility.set_location('--Leaving Payee Address ',30);
  RETURN l_payee_address;
--
END  get_payee_address;

--Cash Management Reconciliation function
 FUNCTION f_get_payfile_recon_data (p_effective_date         IN DATE,
			            p_identifier_name        IN VARCHAR2,
                   		    p_payroll_action_id	     IN NUMBER,
				    p_payment_type_id	     IN NUMBER,
				    p_org_payment_method_id  IN NUMBER,
				    p_personal_payment_method_id   IN NUMBER,
				    p_assignment_action_id	   IN NUMBER,
				    p_pre_payment_id	           IN NUMBER,
				    p_delimiter_string   	   IN VARCHAR2)
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

   CURSOR c_get_acc_num
   IS
     Select ext.segment2 --Acc Num
     From pay_external_accounts ext,
	  pay_org_payment_methods_f org
     Where org.org_payment_method_id = p_org_payment_method_id
     and   p_effective_date between org.effective_start_date and org.effective_end_date
     and   org.external_account_id = ext.external_account_id;

   CURSOR c_get_cp_bat_desc
   IS
     Select pay_nl_general.get_parameter(legislative_parameters, 'BATCH_DESC')
     From pay_payroll_actions
     Where payroll_action_id = p_payroll_action_id;

   CURSOR c_get_org_bat_desc
   IS
     Select pmeth_information2
     From pay_org_payment_methods_f
     Where org_payment_method_id = p_org_payment_method_id
     and  p_effective_date between effective_start_date and effective_end_date;

   l_business_grp_id     NUMBER;
   l_usr_fnc_name        pay_user_column_instances_f.VALUE%TYPE:= NULL;
   l_return_value	 VARCHAR2(80) := NULL;
   l_trx_date            Date;
   l_bat_desc            VARCHAR2(100) := NULL;
   l_acc_num             VARCHAR2(30);

 BEGIN

   OPEN c_get_bus_grp;
   FETCH c_get_bus_grp INTO l_business_grp_id;
   CLOSE c_get_bus_grp;

   Select hruserdt.get_table_value(l_business_grp_id,
                                   'NL_EFT_RECONC_FUNC',
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
            OPEN c_get_acc_num;
	    FETCH c_get_acc_num INTO l_acc_num;
            CLOSE c_get_acc_num;

            IF (SUBSTR(l_acc_num,1,1) = 'P')
               OR (SUBSTR(l_acc_num,1,1) = 'p')
            THEN
                l_acc_num := SUBSTR(l_acc_num,2);
            END IF;

            OPEN c_get_cp_bat_desc;
	    FETCH c_get_cp_bat_desc INTO l_bat_desc;
            CLOSE c_get_cp_bat_desc;

            IF l_bat_desc IS NULL
            THEN
                 OPEN c_get_org_bat_desc;
	         FETCH c_get_org_bat_desc INTO l_bat_desc;
                 CLOSE c_get_org_bat_desc;
             END IF;

             IF l_bat_desc IS NULL
             THEN
                  l_return_value := l_acc_num;
             ELSE
                  l_return_value := l_acc_num||p_delimiter_string||l_bat_desc;
              END IF;

       END IF;
   END IF;

   RETURN l_return_value;

END f_get_payfile_recon_data;

END PAY_NL_PAYFILE;

/
