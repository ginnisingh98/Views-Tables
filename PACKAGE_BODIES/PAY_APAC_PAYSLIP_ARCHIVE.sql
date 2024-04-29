--------------------------------------------------------
--  DDL for Package Body PAY_APAC_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_APAC_PAYSLIP_ARCHIVE" AS
/* $Header: pyapacps.pkb 120.4.12010000.3 2009/03/13 07:30:27 mdubasi ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_apac_payslip_archive

    Description :This is a common package to archive the payroll
                 action level data for APAC countries SS payslip.
                 Different procedures defined are called by the
                 APAC countries legislative Payslip Data Archiver.




    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    22-Apr-2002 kaverma   115.0             Created.
    22-Apr-2002 kaverma	  115.1    2306309  Changes After code review comments
    23-Apr-2002 kaverma   115.2    2306309  Changes After code review comment
    24-Apr-2002 kaverma   115.4             Added p_archive parameter to get_eit_definitions
    02-May-2002 kaverma   115.5             Added procedure range_code
    27-Aug-2002 srrajago  115.6    2518997  Call to set the context for 'TAX UNIT ID' included in archive_user_balances.
    09-Sep-2002 apunekar  115.7             Call to set the context for 'SOURCE ID' included in archive_user_balances.
    22-Oct-2002 srrajago  115.8    2613475  'EMEA ELEMENT DEFINITION' and 'EMEA BALANCE DEFINITON' are now archived
                                            only once per archive run to improve performance. (In proc process_eit,
                                            cursor csr_payroll_info removed and values passed to parameters
                                            p_pre_payroll_action_id and p_pre_effective_date changed).
    03-Nov-2002 Ragovind  115.9    2689226  Added NOCOPY for function get_legislative_parameters.
    04-Nov-2003 Puchil    115.10   3228928  Added a new cursor csr_element_num_val to sum all the element values for
                                            numeric values and archive individual values for other types of input.
					    >Changed hr_utility.trace to execute conditionally.
    19-Apr-2004 bramajey  115.5   3578040  Renamed procedure range_code to
                                           archive_payroll_level_data
    04-May-2004 bramajey  115.6   3604206  Added code to convert numeric data to
                                           canonical using fnd_number.number_to_canonical while archiving.
                                           Reverted back changes done for 3578040
    29-Jun-2004 punmehta  115.7   3731940  Added source_action_id check
    02-Jul-2004 punmehta  115.8   3731940  Modified source_action_id check
    02-Jul-2004 punmehta  115.9   3731940  Modified for GSCC warnings
    12-Dec-2006 aaagarwa  115.10  5048802  Added deinitialization_code
    05-Oct-2007 jalin     115.11  6471802  Reset l_element_archived to N in the loop in archive_user_elements procedure
    11-Oct-2007 jalin     115.12  6486660  Added NOT null check for l_sum_value in archive_user_elements
    15-Oct-2007 jalin     115.13  6486660  Changed calling function pay_in_utils to hr_utility
    11-Mar-2009 mdubasi   115.21  8277653  Changed the cursor 'csr_payroll_msg'
    13-Mar-2009 mdubasi   115.21  8277653  Changed the cursor 'csr_payroll_msg'

*******************************************************************/

/*Global variable to enable trace conditionally*/
g_debug boolean;


/*********************************************************************
   Name      : get_eit_definitions
   Purpose   : Archives the EIT definition details for user configurable
               balances as well as user configurable elements.
               p_archive is flag for archival to happen.
  *********************************************************************/

PROCEDURE get_eit_definitions(p_payroll_action_id       IN  NUMBER,
          	    	      p_business_group_id       IN  NUMBER,
	   	              p_pre_payroll_action_id   IN  NUMBER,
	   	              p_pre_effective_date      IN  DATE,
	   	              p_archive                 IN  VARCHAR2)

IS


  -- Cursor to get the declared EIT definitions

  CURSOR csr_eit_values(p_business_group_id  NUMBER)
  IS
  SELECT org.org_information1,
         org.org_information2,
         org.org_information3,
         org.org_information4,
         org.org_information5,
         org.org_information6,
         org.org_information7
    FROM hr_organization_information_v org
   WHERE org.org_information_context = pay_apac_payslip_archive.g_bg_context
     AND org.organization_id         = p_business_group_id;


  -- Cursor to fetch the balance name delcared at EIT and definded balance id

  CURSOR csr_balance_name(p_balance_type_id      NUMBER,
                          p_balance_dimension_id NUMBER)
  IS
  SELECT nvl(pbttl.reporting_name,pbttl.balance_name),
         pbd.database_item_suffix,
         pdb.legislation_code,
         pdb.defined_balance_id
    FROM pay_balance_types_tl    pbttl,
         pay_balance_dimensions  pbd,
         pay_defined_balances    pdb
   WHERE pdb.balance_type_id        = pbttl.balance_type_id
     AND pdb.balance_dimension_id   = pbd.balance_dimension_id
     AND pbttl.balance_type_id      = p_balance_type_id
     AND pbd.balance_dimension_id   = p_balance_dimension_id
     AND pbttl.language             = userenv('LANG');



  -- Cursor to get the element name declared at EIT

  CURSOR csr_eit_element_name(p_element_type_id NUMBER,
                              p_effective_date  DATE)
  IS
  SELECT nvl(pettl.reporting_name,pettl.element_name)
    FROM pay_element_types_f_tl  pettl,
         pay_element_types_f     pet
   WHERE pet.element_type_id        = p_element_type_id
     AND pettl.element_type_id      = pet.element_type_id
     AND pettl.language             = userenv('LANG')
     AND p_effective_date BETWEEN pet.effective_start_date
                              AND pet.effective_end_date;


  -- Cursor to get the Input Value Name and Unit of Measure

  CURSOR csr_input_value_uom(p_input_value_id NUMBER,
                             p_effective_date DATE)
  IS
  SELECT piv.uom,
         pivtl.name
    FROM pay_input_values_f     piv,
         pay_input_values_f_tl  pivtl
   WHERE piv.input_value_id         = p_input_value_id
     AND pivtl.input_value_id       = piv.input_value_id
     AND pivtl.language             = userenv('LANG')
     AND p_effective_date BETWEEN piv.effective_start_date
                                AND piv.effective_end_date;


  l_action_info_id      NUMBER;
  l_index               NUMBER := 0;
  l_ovn                 NUMBER;
  l_uom                 pay_input_values_f.uom%TYPE;
  l_context   	        VARCHAR2(30);
  l_element_index       PLS_INTEGER :=0;
  l_balance_index       PLS_INTEGER :=0;
  l_element_type_id     NUMBER;
  l_element_name        pay_element_types_f.reporting_name%TYPE;
  l_input_value_id      NUMBER;
  l_element_narrative   VARCHAR2(150);
  l_input_value_name    pay_input_values_f.name%TYPE;


BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
     hr_utility.trace('Entering procedure get_eit_definitions');
  END IF;

  FOR csr_eit_rec IN csr_eit_values(p_business_group_id)

  LOOP

    l_context := csr_eit_rec.org_information1;

    IF g_debug THEN
       hr_utility.trace(' For context : l_context ........:'||l_context);
    END IF;

    IF (l_context = pay_apac_payslip_archive.g_balance_context) THEN

      l_balance_index := l_balance_index+1;

      g_user_balance_table(l_balance_index).balance_type_id      := csr_eit_rec.org_information4;
      g_user_balance_table(l_balance_index).balance_dimension_id := csr_eit_rec.org_information5;
      g_user_balance_table(l_balance_index).balance_narrative    := csr_eit_rec.org_information7;

      OPEN csr_balance_name(g_user_balance_table(l_balance_index).balance_type_id
	   		  ,g_user_balance_table(l_balance_index).balance_dimension_id);
      FETCH csr_balance_name
       INTO g_user_balance_table(l_balance_index).balance_name,
            g_user_balance_table(l_balance_index).database_item_suffix,
            g_user_balance_table(l_balance_index).legislation_code,
            g_user_balance_table(l_balance_index).defined_balance_id;

      CLOSE csr_balance_name;


      -- If user lefts the display name blank for balances then display name
      -- will be 'balance reporting name || 'dimension name'

      IF csr_eit_rec.org_information7 IS NULL THEN
         g_user_balance_table(l_balance_index).balance_narrative:= g_user_balance_table(l_balance_index).balance_name ||' '|| g_user_balance_table(l_balance_index).database_item_suffix;
      END IF;

      IF g_debug THEN
         hr_utility.trace('Archiving the user configured balances.......');
      END IF;

      IF p_archive = 'Y' THEN

        pay_action_information_api.create_action_information
            ( p_action_information_id        =>  l_action_info_id
	    , p_action_context_id            =>  p_payroll_action_id
	    , p_action_context_type          =>  'PA'
	    , p_object_version_number        =>  l_ovn
	    , p_effective_date               =>  p_pre_effective_date
	    , p_source_id                    =>  NULL
	    , p_source_text                  =>  NULL
	    , p_action_information_category  =>  'EMEA BALANCE DEFINITION'
            , p_action_information1          =>  p_pre_payroll_action_id
	    , p_action_information2          =>  g_user_balance_table(l_balance_index).defined_balance_id
	    , p_action_information4          =>  g_user_balance_table(l_balance_index).balance_narrative
	    );
      END IF;

    END IF;  -- l_context = pay_apac_payslip_archive.g_balance_context

    IF ( l_context = pay_apac_payslip_archive.g_element_context )  THEN

      l_element_type_id    := csr_eit_rec.org_information2;
      l_input_value_id     := csr_eit_rec.org_information3;
      l_element_narrative  := csr_eit_rec.org_information7;

      OPEN  csr_eit_element_name(csr_eit_rec.org_information2 , p_pre_effective_date);
      FETCH csr_eit_element_name INTO l_element_name;
      CLOSE csr_eit_element_name;


      OPEN  csr_input_value_uom(l_input_value_id , p_pre_effective_date);
      FETCH csr_input_value_uom INTO l_uom,l_input_value_name;
      CLOSE csr_input_value_uom;

      l_element_index := l_element_index + 1;

      IF g_debug THEN
         hr_utility.trace(' ......ELEMENT  :'||l_element_index);
      END IF;
      g_element_table(l_element_index).element_type_id   := l_element_type_id;
      g_element_table(l_element_index).input_value_id    := l_input_value_id;
      g_element_table(l_element_index).element_narrative := l_element_narrative;

      -- If user lefts the display name blank for elements then display name
      -- will be 'element reporting name' || 'input value name'

      IF csr_eit_rec.org_information7 IS NULL THEN
         g_element_table(l_element_index).element_narrative := l_element_name || ' ' || l_input_value_name;
      END IF;

      IF p_archive = 'Y' THEN

        pay_action_information_api.create_action_information
            ( p_action_information_id        =>  l_action_info_id
	    , p_action_context_id            =>  p_payroll_action_id
	    , p_action_context_type          =>  'PA'
	    , p_object_version_number        =>  l_ovn
	    , p_effective_date               =>  p_pre_effective_date
	    , p_source_id                    =>  NULL
	    , p_source_text                  =>  NULL
	    , p_action_information_category  =>  'EMEA ELEMENT DEFINITION'
	    , p_action_information1          =>  p_pre_payroll_action_id
	    , p_action_information2          =>  g_element_table(l_element_index).element_type_id
	    , p_action_information3          =>  g_element_table(l_element_index).input_value_id
	    , p_action_information4          =>  g_element_table(l_element_index).element_narrative
	    , p_action_information5          =>  'F'
	    , p_action_information6          =>  l_uom
	    );

      END IF;

    END IF; -- l_context = l_context = pay_apac_payslip_archive.g_element_context
  END LOOP;

  g_max_user_balance_index := l_balance_index;
  g_max_user_element_index := l_element_index;

  IF g_debug THEN
     hr_utility.trace('Leaving procedure get_eit_definition ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in get_eit_definitions');
    END IF;
    RAISE;

END get_eit_definitions;



/*********************************************************************
   Name      : archive_user_balances
   Purpose   : Archives the EIT values for the defined balances dimension
  *********************************************************************/

PROCEDURE archive_user_balances(p_arch_assignment_action_id IN NUMBER,
                                p_run_assignment_action_id  IN NUMBER,
                                p_pre_effective_date	    IN DATE)

IS

  l_action_info_id           NUMBER;
  l_balance_value            NUMBER;
  l_ovn                      NUMBER;
  l_tax_unit_id              pay_assignment_actions.tax_unit_id%type; /* Bug No : 2518997 */
  l_source  pay_run_result_values.result_value%type;

  /* Start of Bug No : 2518997 */

  CURSOR csr_tax_unit_id(p_run_assignment_action_id pay_assignment_actions.tax_unit_id%type)
      IS
  SELECT tax_unit_id
    FROM pay_assignment_actions
   WHERE assignment_action_id   =  p_run_assignment_action_id;

 /* End of Bug No : 2518997 */

/*Set context for source id*/

CURSOR csr_set_source_id(p_run_assignment_action_id pay_assignment_actions.tax_unit_id%type)
IS
select distinct CONTEXT.result_value
       from   pay_run_result_values CONTEXT
              ,pay_input_values_f    PIVF
	      ,pay_run_results RR
	      ,pay_payroll_actions PACT,
	       pay_assignment_actions paa
       where  CONTEXT.run_result_id = RR.run_result_id
       and    CONTEXT.input_value_id = PIVF.input_value_id
       and    PIVF.name = 'Source'
       and    paa.assignment_action_id= p_run_assignment_action_id
       and    paa.assignment_action_id=RR.assignment_action_id
       and    paa.payroll_action_id=pact.payroll_action_id
       and    PACT.effective_date between PIVF.effective_start_date and PIVF.effective_end_date;


 BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
     hr_utility.trace('Start of archive user balances');
  END IF;

  FOR l_index IN 1 .. pay_apac_payslip_archive.g_max_user_balance_index   LOOP

    /* Start of Bug No : 2518997 */

    OPEN  csr_tax_unit_id(p_run_assignment_action_id);
    FETCH csr_tax_unit_id INTO l_tax_unit_id;
    CLOSE csr_tax_unit_id;

    IF l_tax_unit_id IS NOT NULL THEN
       pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
    END IF;

   /* End of Bug No : 2518997 */

    pay_balance_pkg.set_context('SOURCE_ID',99);
    OPEN  csr_set_source_id(p_run_assignment_action_id);
    FETCH csr_set_source_id into l_source;
    CLOSE csr_set_source_id;

   /*Set context source id if exists*/
    if l_source is not null then
    pay_balance_pkg.set_context('SOURCE_ID',l_source);
    end if;

    l_balance_value := pay_balance_pkg.get_value (
                           p_defined_balance_id   => pay_apac_payslip_archive.g_user_balance_table(l_index).defined_balance_id
                          ,p_assignment_action_id => p_run_assignment_action_id
                                                 );
    -- Archive balance if non-zero

    IF l_balance_value <> 0  THEN

      pay_action_information_api.create_action_information
          ( p_action_information_id        =>  l_action_info_id
          , p_action_context_id            =>  p_arch_assignment_action_id
	  , p_action_context_type          =>  'AAP'
	  , p_object_version_number        =>  l_ovn
	  , p_effective_date               =>  p_pre_effective_date
	  , p_source_id                    =>  p_run_assignment_action_id
	  , p_source_text                  =>  NULL
	  , p_action_information_category  =>  'EMEA BALANCES'
	  , p_action_information1          =>  pay_apac_payslip_archive.g_user_balance_table(l_index).defined_balance_id
	  , p_action_information4          =>  fnd_number.number_to_canonical(l_balance_value)  -- Bug 3604206
	  );

    END IF;

  END LOOP;
  IF g_debug THEN
     hr_utility.trace(' End of archive user balances');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in archive user balances');
    END IF;
    RAISE;
END archive_user_balances;




/*********************************************************************
   Name      : archive_user_elements
   Purpose   : Archives the EIT values for input values defined in the
               EIT definition
  *********************************************************************/

PROCEDURE archive_user_elements(p_arch_assignment_action_id  IN NUMBER,
                                p_pre_assignment_action_id   IN NUMBER,
                                p_latest_run_assact_id       IN NUMBER,
                                p_pre_effective_date	     IN DATE)
IS


  -- Cursor to select all payroll runs under the prepayment

  CURSOR csr_all_runs_under_prepay(p_pre_assignment_action_id NUMBER)
  IS
  SELECT  pac.assignment_action_id
         ,pac.source_action_id
    FROM  pay_action_interlocks  pai
         ,pay_assignment_actions pac
	 ,pay_payroll_Actions ppa
   WHERE  pai.locking_action_id      = p_pre_assignment_action_id
     AND  pai.locked_action_id       = pac.assignment_action_id
     AND  ppa.payroll_action_id      = pac.payroll_action_id
     AND  (ppa.run_type_id IS NULL
            OR
	    (ppa.run_type_id IS not NULL
            and pac.source_action_id  IS NOT NULL)) --Bug:3731940 Because run results are not queried for master record
  ORDER BY pac.assignment_action_id DESC;



  -- Cursor to select all archived elements for category 'APAC ELEMENTS'

  CURSOR csr_archived_elements(p_arch_assignment_action_id NUMBER)
  IS
  SELECT action_information1
    FROM pay_action_information
   WHERE action_context_id           =  p_arch_assignment_action_id
     AND action_information_category = 'APAC ELEMENTS'
     AND action_context_type         = 'AAP';



  -- Cursor to get element name declared at EIT

  CURSOR csr_eit_element_name(p_element_type_id NUMBER,
                              p_effective_date  DATE)
  IS
  SELECT nvl(reporting_name,element_name)
    FROM pay_element_types_f
   WHERE element_type_id            = p_element_type_id
     AND p_effective_date BETWEEN effective_start_date
                              AND effective_end_date;



  -- Cursor to get Input Value name and unit of measure

  CURSOR csr_input_name(p_input_value_id NUMBER,
                        p_effective_date DATE)
  IS
  SELECT substr(uom,1,1) uom,
         name
    FROM pay_input_values_f
   WHERE input_value_id             = p_input_value_id
     AND p_effective_date BETWEEN effective_start_date
                              AND effective_end_date;


  -- Cursor to get element run result values

  CURSOR csr_element_values(p_assignment_action_id NUMBER,
                            p_element_type_id      NUMBER,
                            p_input_value_id       NUMBER)
  IS
  SELECT prv.result_value value
    FROM pay_run_result_values  prv,
         pay_run_results        prr
   WHERE prr.status IN ('P','PA')
     AND prv.run_result_id          = prr.run_result_id
     AND prr.assignment_action_id   = p_assignment_action_id
     AND prr.element_type_id        = p_element_type_id
     AND prv.input_value_id         = p_input_value_id
     AND prv.result_value IS NOT NULL;

  -- Cursor to get element run result values for numeric results

  CURSOR csr_element_num_val(p_assignment_action_id NUMBER,
                            p_element_type_id      NUMBER,
                            p_input_value_id       NUMBER)
  IS
  SELECT sum(fnd_number.canonical_to_number(prv.result_value)) value/*Bug 3228928*/
    FROM pay_run_result_values  prv,
         pay_run_results        prr
   WHERE prr.status IN ('P','PA')
     AND prv.run_result_id          = prr.run_result_id
     AND prr.assignment_action_id   = p_assignment_action_id
     AND prr.element_type_id        = p_element_type_id
     AND prv.input_value_id         = p_input_value_id
     AND prv.result_value IS NOT NULL;

  l_latest_assignment_action_id NUMBER;
  l_run_value    		NUMBER:=0;/*Bug 3228928*/
  l_sum_value    		NUMBER:=0;
  l_uom 	       		pay_input_values_f.uom%TYPE;
  l_action_info_id  	        NUMBER;
  l_ovn             	        NUMBER;
  l_element_name                pay_element_types_f.reporting_name%TYPE;
  l_input_name                  pay_input_values_f.name%TYPE;
  l_element_archived            VARCHAR2(1);

BEGIN
  g_debug := hr_utility.debug_enabled;
  l_element_archived := 'N';
  IF g_debug THEN
     hr_utility.trace(' Start of archive user elements');
  END IF;

  FOR l_index IN 1 .. g_max_user_element_index   LOOP

    OPEN  csr_eit_element_name(g_element_table(l_index).element_type_id,p_pre_effective_date);
    FETCH csr_eit_element_name INTO l_element_name;
    CLOSE csr_eit_element_name;

    OPEN  csr_input_name(g_element_table(l_index).input_value_id,p_pre_effective_date);
    FETCH csr_input_name INTO l_uom,l_input_name;
    CLOSE csr_input_name;


    -- Check if the element is already archived in 'APAC ELEMENTS'

    FOR  csr_rec in csr_archived_elements(p_arch_assignment_action_id)

    LOOP

      IF csr_rec.action_information1 = l_element_name AND l_input_name = 'Pay Value' THEN
         l_element_archived := 'Y';
         EXIT;

      END IF;

    END LOOP;

    -- No archival if Element is already archived in 'APAC ELEMENTS'

    IF l_element_archived = 'N' THEN

       IF g_debug THEN
          hr_utility.trace(' ...Unit Of Measure is ...:'||l_uom);
       END IF;

	 IF (l_uom ='M' OR l_uom='H' OR l_uom='I') THEN

            l_sum_value:=0;

      	    -- Sum all the run result values in case of multiple payrolls in prepayment

      	    FOR  rec_all_actions IN csr_all_runs_under_prepay(p_pre_assignment_action_id)
      	    LOOP

              l_run_value := 0;

      	      OPEN csr_element_num_val(rec_all_actions.assignment_action_id
	                              ,g_element_table(l_index).element_type_id
	                              ,g_element_table(l_index).input_value_id);

	      Fetch csr_element_num_val INTO  l_run_value;

	      CLOSE csr_element_num_val;

          if l_run_value is not null or l_run_value <> 0 then /* Bug 6486660 */
    	      l_sum_value:=l_sum_value + l_run_value;
          end if;

	    END LOOP;
	    /*Bug 3228928 - Archive the sum for numeric values */
	    IF l_sum_value <> 0 THEN

                pay_action_information_api.create_action_information
	        ( p_action_information_id        => l_action_info_id
		, p_action_context_id            => p_arch_assignment_action_id
		, p_action_context_type          => 'AAP'
		, p_object_version_number        => l_ovn
		, p_effective_date               => p_pre_effective_date
		, p_source_id                    => p_pre_assignment_action_id
		, p_source_text                  => NULL
		, p_action_information_category  => 'EMEA ELEMENT INFO'
		, p_action_information1          => g_element_table(l_index).element_type_id
		, p_action_information2          => g_element_table(l_index).input_value_id
		, p_action_information4          => fnd_number.number_to_canonical(l_sum_value) -- Bug 3604206
                );

	    END IF;

         ELSE
           /*Bug 3228928 - Archive all the input value for non numeric values */
	   FOR rec_element_value in csr_element_values
                                   (p_latest_run_assact_id
                                   ,g_element_table(l_index).element_type_id
                                   ,g_element_table(l_index).input_value_id)
           LOOP

                pay_action_information_api.create_action_information
	        ( p_action_information_id        => l_action_info_id
		, p_action_context_id            => p_arch_assignment_action_id
		, p_action_context_type          => 'AAP'
		, p_object_version_number        => l_ovn
		, p_effective_date               => p_pre_effective_date
		, p_source_id                    => p_pre_assignment_action_id
		, p_source_text                  => NULL
		, p_action_information_category  => 'EMEA ELEMENT INFO'
		, p_action_information1          => g_element_table(l_index).element_type_id
		, p_action_information2          => g_element_table(l_index).input_value_id
		, p_action_information4          => rec_element_value.value
                );

	   END LOOP;

	 END IF;

     END IF; -- If l_element_archived = 'N'

     l_element_archived := 'N'; /* Bug 6471802 */

  END LOOP;  -- End of 1.. max_user_elements Loop

  IF g_debug THEN
     hr_utility.trace(' End of archive user elements');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in archive user elements');
    END IF;
    RAISE;

END archive_user_elements;




/*******************************************************************************
   Name      : process_eit
   Purpose   : This procedure is called from both initialization_code and archive_payroll_level_data
               with different archive flag variable.
               From initiliazation_code it is called with p_archive='N' to populate the
               EIT's balances and elements into global table.
               From archive_payroll_level_data it is called with p_archive='Y' to actually archive
               the EIT's balances and elements.
               This procedure internally calls the common
               pay_apac_payslip_archive.get_eit_definitions to archive the EIT balances
               and elements.
********************************************************************************/


PROCEDURE process_eit(p_payroll_action_id IN NUMBER
                     ,p_archive           IN VARCHAR2)
IS

  l_payroll_id            NUMBER;
  l_consolidation_set_id  VARCHAR2(30);
  l_business_group_id     NUMBER;
  l_start_date            VARCHAR2(20);
  l_end_date              VARCHAR2(20);
  l_canonical_start_date  DATE;
  l_canonical_end_date    DATE;

BEGIN

  IF g_debug THEN
     hr_utility.trace('Start of process_eit');
  END IF;

  -- Get the legislative parameters of the archive request.

  pay_apac_payslip_archive.get_legislative_parameters
       (p_payroll_action_id,
        l_payroll_id,
        l_consolidation_set_id,
        l_business_group_id,
        l_start_date,
        l_end_date
        );

  l_canonical_start_date := TO_DATE(l_start_date,fnd_date.canonical_mask);
  l_canonical_end_date   := TO_DATE(l_end_date,fnd_date.canonical_mask);

  l_business_group_id    := to_number(l_business_group_id);

    pay_apac_payslip_archive.get_eit_definitions
        ( p_payroll_action_id     => p_payroll_action_id            -- archival payroll_action_id
        , p_business_group_id     => l_business_group_id            -- business group legislative parameter
        , p_pre_payroll_action_id => NULL /* Bug No : 2613475 */
        , p_pre_effective_date    => l_canonical_start_date /* Bug No : 2613475 */
        , p_archive               => p_archive
        );

  IF g_debug THEN
     hr_utility.trace('End of process_eit');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in process_eit');
    END IF;
    RAISE;
END process_eit;



-- Bug 3604206

/*********************************************************************
   Name      : range_code
   Purpose   : Calls the process_eit to archive the EIT details and
               also archives the payroll level data  -
               Messages and Employer address details.
  *********************************************************************/

PROCEDURE range_code(p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE)
IS

-- Cursor to get the pay advice message

  CURSOR csr_payroll_msg(p_payroll_id 	NUMBER,
                         p_start_date 	DATE,
                         p_end_date 	DATE)
  IS

SELECT  ppa.payroll_action_id   payroll_action_id
         , NULL    assignment_id
         ,ppa.effective_date      run_effective_date
         ,ppa.date_earned         date_earned
         ,ppa.pay_advice_message  payroll_message
    FROM  pay_payrolls_f	  pp,
          pay_payroll_actions     ppa
   WHERE  ppa.payroll_id           = p_payroll_id
     AND  ppa.effective_date BETWEEN p_start_date AND p_end_date
     AND  ppa.action_type          = 'R'
     AND  ppa.action_status        = 'C'
     AND  ppa.payroll_id           =  pp.payroll_id
     AND  NOT EXISTS (SELECT NULL
                        FROM pay_action_information pai
                       WHERE pai.action_context_id           = ppa.payroll_action_id
                         AND pai.action_context_type         = 'PA'
                         AND pai.action_information_category = 'EMPLOYEE OTHER INFORMATION')
   UNION
   SELECT  ppa.payroll_action_id   payroll_action_id
         ,paa.assignment_id    assignment_id
         ,ppa.effective_date      run_effective_date
         ,ppa.date_earned         date_earned
         ,ppa.pay_advice_message  payroll_message
    FROM  pay_payrolls_f	  pp,
          pay_payroll_actions     ppa,
          pay_assignment_actions paa
   WHERE  ppa.payroll_id           = p_payroll_id
     AND  ppa.effective_date BETWEEN p_start_date AND p_end_date
     AND  ppa.action_type          = 'Q'
     AND  ppa.action_status        = 'C'
     AND  ppa.payroll_id           =  pp.payroll_id
     AND  paa.payroll_action_id    =  ppa.payroll_action_id
     AND  NOT EXISTS (SELECT NULL
                        FROM pay_action_information pai
                       WHERE pai.action_context_id           = ppa.payroll_action_id
                         AND pai.action_context_type         = 'PA'
                         AND pai.action_information_category = 'EMPLOYEE OTHER INFORMATION');

  l_payroll_id            NUMBER;
  l_consolidation_set_id  VARCHAR2(30);
  l_business_group_id     NUMBER;
  l_start_date            VARCHAR2(20);
  l_end_date              VARCHAR2(20);
  l_canonical_start_date  DATE;
  l_canonical_end_date    DATE;
  l_action_info_id        NUMBER;
  l_ovn	 		  NUMBER;
  l_archive               VARCHAR2(1) ;


BEGIN
  g_debug := hr_utility.debug_enabled;
  l_archive := 'Y';
  IF g_debug THEN
     hr_utility.trace(' Start of APAC archive Range Code');
  END IF;

  -----------------------------------------------------------------------+
  -- Call to process_eit with p_archive parameter as 'Y' as this will
  -- archive the EIT details. Range_cursor is a non multi-threaded process
  -- so archival of EIT and payroll level data is done in this procedure.
  -----------------------------------------------------------------------+

  process_eit(p_payroll_action_id,l_archive);


  -- Get the legislative parameters of the archive request.

  get_legislative_parameters
       (p_payroll_action_id,
        l_payroll_id,
        l_consolidation_set_id,
        l_business_group_id,
        l_start_date,
        l_end_date
        );

  l_canonical_start_date := TO_DATE(l_start_date,fnd_date.canonical_mask);
  l_canonical_end_date   := TO_DATE(l_end_date,fnd_date.canonical_mask);

  l_business_group_id    := to_number(l_business_group_id);

  -- Call to Core package to archive Employer Address Details
  -- Needed for Person Information region to work on payslip.

  pay_emp_action_arch.arch_pay_action_level_data
       (p_payroll_action_id,
        l_payroll_id,
        l_canonical_end_date);

  IF g_debug THEN
     hr_utility.trace('Archiving the Payroll Messages.');
  END IF;

  FOR csr_msg_rec IN csr_payroll_msg(l_payroll_id
                        	    ,l_canonical_start_date
                                    ,l_canonical_end_date)
  LOOP

    IF csr_msg_rec.payroll_message IS NOT NULL THEN

       pay_action_information_api.create_action_information
           ( p_action_information_id        =>  l_action_info_id
   	   , p_action_context_id            =>  p_payroll_action_id
   	   , p_action_context_type          =>  'PA'
   	   , p_object_version_number        =>  l_ovn
   	   , p_effective_date               =>  csr_msg_rec.run_effective_date
   	   , p_source_id                    =>  NULL
   	   , p_source_text                  =>  NULL
   	   , p_action_information_category  =>  'EMPLOYEE OTHER INFORMATION'
   	   , p_action_information1          =>  l_business_group_id
   	   , p_action_information2          =>  'MESG'
   	   , p_action_information6          =>  csr_msg_rec.payroll_message
	   , p_assignment_id                =>  csr_msg_rec.assignment_id   );--Added for 8277653
    END IF;

  END LOOP;


  IF g_debug THEN
     hr_utility.trace('End of APAC archive Range Code');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in APAC archive Range Code');
    END IF;
    RAISE;

END range_code;





/*********************************************************************
   Name      : initialization_code
   Purpose   : Calls process_eit to set the globals.
  *********************************************************************/


PROCEDURE initialization_code(p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE)
IS

  l_archive        VARCHAR2(1);

BEGIN
  g_debug := hr_utility.debug_enabled;
  l_archive := 'N';
  IF g_debug THEN
     hr_utility.trace(' Start of APAC archive Initialization Code');
  END IF;

  -----------------------------------------------------------------------+
  -- Call to process_eit with p_archive parameter as 'N' as this will
  -- populate the EIT values in global tables. initialization_code  is a
  -- multi-threaded process. It is used to set the global contexts and variables.
  -----------------------------------------------------------------------+

  process_eit(p_payroll_action_id,l_archive);

  IF g_debug THEN
     hr_utility.trace('End of APAC Initliazation Code');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in APAC archive Initialization Code');
    END IF;
    RAISE;

END initialization_code;



/*********************************************************************
   Name      : get_legislative_parameters
   Purpose   : csrs the value of legislative parameters from the
               payroll run. For this to call, the legislative strings
               in the concurrent request parameters should be defined as below .

               PAYROLL        ---- Payroll Id
               CONSOLIDATION  ---- Consolidation Id
               BG_ID          ---- Business Group Id
               START_DATE     ---- Start Date
               END_DATE       ---- End Date

  *********************************************************************/

PROCEDURE get_legislative_parameters(p_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE,
                                     p_payroll_id	  OUT NOCOPY NUMBER,
                                     p_consolidation	  OUT NOCOPY NUMBER,
                                     p_business_group_id  OUT NOCOPY NUMBER,
                                     p_start_date	  OUT NOCOPY VARCHAR2,
				     p_end_date 	  OUT NOCOPY VARCHAR2)
IS


  -- Cursor to get legislative parameters from the archive request

  CURSOR csr_params(p_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
  IS
  SELECT pay_core_utils.get_parameter('PAYROLL',legislative_parameters)        payroll_id,
         pay_core_utils.get_parameter('CONSOLIDATION',legislative_parameters)  consolidation_set_id,
         pay_core_utils.get_parameter('BG_ID',legislative_parameters) 	       business_group_id,
         pay_core_utils.get_parameter('START_DATE',legislative_parameters)     start_date,
         pay_core_utils.get_parameter('END_DATE',legislative_parameters)       end_date
    FROM pay_payroll_actions ppa
   WHERE ppa.payroll_action_id  =  p_payroll_action_id;

BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
     hr_utility.trace('Start of get_legislative_parameters Procedure');
  END IF;

  OPEN csr_params(p_payroll_action_id);
  FETCH  csr_params INTO p_payroll_id
                        ,p_consolidation
                        ,p_business_group_id
                        ,p_start_date
                        ,p_end_date;
  CLOSE csr_params;

  IF g_debug THEN
     hr_utility.trace('End of get_legislative_parameters Procedure');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
       hr_utility.trace('Error occured in get_legislative_parameters');
    END IF;
    RAISE;

END get_legislative_parameters;  /* End of get_legislative_parameters */

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : DEINITIALIZATION_CODE                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to archive the PA level data if quick     --
  --                  archive has been run.                               --
  --                  called are                                          --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id          NUMBER                 --
  --            OUT : N/A                                                 --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 06-Dec-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE deinitialization_code (p_payroll_action_id IN NUMBER)
  IS
    CURSOR check_pa_data_existence
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_context_id = p_payroll_action_id
          AND action_context_type = 'PA'
          AND action_information_category IN('EMEA BALANCE DEFINITION'
                                            ,'EMEA ELEMENT DEFINITION'
                                            ,'EMPLOYEE OTHER INFORMATION'
                                            ,'ADDRESS DETAILS'
                                            );

    l_procedure                       VARCHAR2(100);
    l_count                           NUMBER;

   BEGIN
    l_procedure := 'pay_apac_payslip_archive.deinitialization_code';

    IF g_debug THEN
      hr_utility.set_location(l_procedure, 10);
    END IF;
    l_count := -1;

    OPEN  check_pa_data_existence;
    FETCH check_pa_data_existence INTO l_count;
    CLOSE check_pa_data_existence;

    IF (g_debug)
    THEN
          hr_utility.trace('p_payroll_action_id:'||p_payroll_action_id);
          hr_utility.trace('l_count:'||l_count);
    END IF;

    IF (l_count = -1)
    THEN
          pay_apac_payslip_archive.range_code(p_payroll_action_id => p_payroll_action_id);
          IF g_debug THEN
            hr_utility.set_location(l_procedure, 20);
          END IF;
    END IF;

    IF g_debug THEN
      hr_utility.set_location(l_procedure, 30);
    END IF;

   END deinitialization_code;

BEGIN

 g_max_user_element_index  := 0;
 g_max_user_balance_index  := 0;

 g_balance_context := 'BALANCE';
 g_element_context := 'ELEMENT';
 g_bg_context := 'Business Group:Payslip Info';

END pay_apac_payslip_archive;  /* End Of the Package Body  */

/
