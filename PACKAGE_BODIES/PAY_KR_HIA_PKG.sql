--------------------------------------------------------
--  DDL for Package Body PAY_KR_HIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_HIA_PKG" as
/* $Header: pykrhia.pkb 120.3 2006/01/05 03:40:50 pdesu noship $ */
--
-- Constants
--
  l_package varchar2(31) := '  pay_kr_hia_pkg.';
  g_debug   boolean      := hr_utility.debug_enabled;
--
-- Global Variables
--
  TYPE t_pact IS RECORD(
        payroll_action_id        NUMBER,
        report_type              pay_payroll_actions.report_type%TYPE,
        report_qualifier         pay_payroll_actions.report_qualifier%TYPE,
        report_category          pay_payroll_actions.report_category%TYPE,
        business_group_id        NUMBER,
        effective_date           date,
        bp_hi_number             varchar2(250),  --3506171
        reported_date            date,
        year_start_date          date );

        g_pact                   t_pact;

        --
        --Bug 2931128 . This global value stores defined balance id
        --for defined balance HI_PREM_EE_WO_ADJ_ASG_MTD_MTH

        g_dbl_id_hi_prem         pay_defined_balances.defined_balance_id%type;

  --------------------------------------------------------------------------------+
  -- Range cursor returns the ids of the assignments to be archived
  --------------------------------------------------------------------------------+
  PROCEDURE range_code(
                       p_payroll_action_id IN  NUMBER,
                       p_sqlstr            OUT NOCOPY VARCHAR2)
  IS
    l_proc_name VARCHAR2(100) := l_package || 'range_code';
  BEGIN

    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;

    p_sqlstr :=
               'SELECT DISTINCT person_id
                FROM   per_people_f    ppf,
                       pay_payroll_actions ppa
                WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND  ppa.business_group_id = ppf.business_group_id
             ORDER BY  ppf.person_id';
    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;
  end range_code;

  --------------------------------------------------------------------------------
  -- Initialization Code
  --------------------------------------------------------------------------------
  procedure initialization_code(p_payroll_action_id in number)
  is

      l_proc_name VARCHAR2(100) := l_package || 'initialization_code';

  begin

    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;

    IF g_pact.payroll_Action_id is null then
	select ppa.payroll_action_id,
	       ppa.report_type,
	       ppa.report_qualifier,
	       ppa.report_category,
	       ppa.business_group_id,
	       ppa.effective_date,
	       pay_core_utils.get_parameter('BP_HI_NUMBER',ppa.legislative_parameters) bp_hi_number, --3506171
	       fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTED_DATE',ppa.legislative_parameters))      reported_date,
	       trunc(fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTED_DATE',ppa.legislative_parameters)),'YYYY') year_start_date
	 into  g_pact
	 from  pay_payroll_actions           ppa
	where  ppa.payroll_action_id = p_payroll_action_id;
    END IF;

    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in initialization code ',10);
      RAISE;
  end initialization_code;

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
    l_locking_action_id        NUMBER;
    CURSOR csr_asg     -- 3506171
    IS
    SELECT DISTINCT asg.assignment_id,
           asg.establishment_id
      FROM per_assignments_f            asg,
           pay_payroll_actions          xppa,
           hr_organization_units        hou1,
	   hr_organization_information  hoi1
     WHERE xppa.payroll_action_id       = p_payroll_action_id
       and hou1.business_group_id       = g_pact.business_group_id  --3506171
       and hoi1.organization_id         = hou1.organization_id
       and hoi1.org_information_context = 'KR_HI_INFORMATION'
       and hoi1.org_information1        = g_pact.bp_hi_number
       AND asg.business_group_id 		= g_pact.business_group_id
       AND asg.establishment_id         = hou1.organization_id
       AND asg.person_id BETWEEN p_start_person_id AND p_end_person_id
--     BUG  3453612
       AND xppa.effective_date between asg.effective_start_date and asg.effective_end_date
       AND NOT EXISTS (SELECT NULL
                         FROM pay_payroll_actions         ppa4,
                              pay_assignment_actions      paa4
                        WHERE paa4.assignment_id        = asg.assignment_id
                          AND paa4.source_action_id     IS NULL
                          AND ppa4.payroll_action_id    = paa4.payroll_action_id
                          AND ppa4.action_type          = 'X'
                          AND ppa4.report_type          = 'HIA'
                          AND ppa4.report_qualifier     = 'KR'
                          AND ppa4.report_category      = 'A'
                          AND trunc(ppa4.effective_date, 'YYYY') = trunc(xppa.effective_date, 'YYYY')
                    UNION ALL -- Bug : 4859742
                      (SELECT NULL
                         FROM per_people_extra_info       pei
                        WHERE pei.person_id             = asg.person_id
                          AND pei.pei_information6      = 'Y'
                          AND pei.information_type      = 'PER_KR_HEALTH_INSURANCE_INFO'))
       AND EXISTS     (SELECT NULL
                         FROM pay_payroll_actions       ppa,
                              pay_assignment_actions    paa
                        WHERE ppa.effective_date BETWEEN
                              trunc(fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTED_DATE',xppa.legislative_parameters)), 'YYYY')
                          AND fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTED_DATE',xppa.legislative_parameters))
                          AND ppa.action_type           in ('R','Q')
                          AND paa.action_status         = 'C'
                          AND paa.payroll_action_id     = ppa.payroll_action_id
                          AND paa.source_action_id      IS NULL
                          AND paa.assignment_id         = asg.assignment_id);
  BEGIN
    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;

    initialization_code(p_payroll_action_id);

    FOR l_asg IN csr_asg  -- 3506171
    LOOP
      SELECT pay_assignment_actions_s.nextval
        INTO l_locking_action_id
        FROM dual;
      hr_nonrun_asact.insact(lockingactid  => l_locking_action_id,
                             assignid      => l_asg.assignment_id,
                             pactid        => p_payroll_action_id,
                             chunk         => p_chunk_number,
                             greid         => l_asg.establishment_id,
                             prepayid      => null,
                             status        => 'U');
    END LOOP;

    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in assignment action code ',10);
      RAISE;
  END assignment_action_code;
  --------------------------------------------------------------------------------+
  -- Archives item
  --------------------------------------------------------------------------------+
  PROCEDURE archive_item
                        ( p_item     IN     ff_user_entities.user_entity_name%TYPE,
                          p_context1 IN     pay_assignment_actions.assignment_action_id%TYPE,
                          p_value    IN OUT NOCOPY ff_archive_items.value%TYPE)
  IS
    CURSOR csr_get_user_entity_id(c_user_entity_name IN VARCHAR2)
    IS
    SELECT fue.user_entity_id,
           dbi.data_type
      FROM ff_user_entities       fue,
           ff_database_items      dbi
     WHERE user_entity_name     = c_user_entity_name
       AND fue.user_entity_id   = dbi.user_entity_id;
    l_user_entity_id          ff_user_entities.user_entity_id%TYPE;
    l_archive_item_id         ff_archive_items.archive_item_id%TYPE;
    l_data_type               ff_database_items.data_type%TYPE;
    l_object_version_number   ff_archive_items.object_version_number%TYPE;
    l_some_warning            BOOLEAN;
  BEGIN
    if g_debug then
      hr_utility.set_location('Entering : archive_item',1);
    end if;

    OPEN csr_get_user_entity_id (p_item);
    FETCH csr_get_user_entity_id INTO l_user_entity_id,l_data_type;
    IF csr_get_user_entity_id%found THEN
      CLOSE csr_get_user_entity_id;
          ff_archive_api.create_archive_item
            (p_validate              => false                    -- boolean  in default
            ,p_archive_item_id       => l_archive_item_id        -- NUMBER   out
            ,p_user_entity_id        => l_user_entity_id         -- NUMBER   in
            ,p_archive_value         => p_value                  -- VARCHAR2 in
            ,p_archive_type          => 'AAP'                    -- VARCHAR2 in default
            ,p_action_id             => p_context1               -- NUMBER   in
            ,p_legislation_code      => 'KR'                     -- VARCHAR2 in
            ,p_object_version_number => l_object_version_number  -- NUMBER   out
            ,p_some_warning          => l_some_warning);         -- boolean  out
    ELSE
      CLOSE csr_get_user_entity_id;

      if g_debug then
        hr_utility.set_location('User entity not found :'||p_item,20);
      end if;

    END IF;

    if g_debug then
      hr_utility.set_location('Leaving : archive_item',1);
    end if;

  EXCEPTION
    WHEN OTHERS THEN
    IF csr_get_user_entity_id%isopen THEN
      CLOSE csr_get_user_entity_id;
      hr_utility.set_location('closing..',117);
    END IF;
    hr_utility.set_location('Error in archive_item',20);
    RAISE;
  END archive_item;

  --------------------------------------------------------------------------------+
  -- Archive code selects the items to be archived.
  --------------------------------------------------------------------------------+
  PROCEDURE archive_code(
                         p_assignment_action_id IN NUMBER,
                         p_effective_date       IN DATE)
  IS
    l_proc_name                VARCHAR2(100) := l_package || 'archive_code';
    l_assignment_id     NUMBER;
    l_payroll_id        NUMBER;
    l_establishment_id  number;  -- 3506171

    --Bug 2931128
    --
    l_arch_val          ff_archive_items.value%type;

    TYPE t_arch_rec IS RECORD(item   VARCHAR2(50)
                             ,value  VARCHAR2(1000));
    TYPE t_arch_tab IS TABLE OF t_arch_rec INDEX BY BINARY_INTEGER;
    l_arch_tab t_arch_tab;

    -- Bug 4199014
    type t_assact_tbl 	is table of number index by binary_integer ;
    type t_ppa_mth_tbl 	is table of number index by binary_integer ;
    l_assact_tbl		t_assact_tbl ;
    l_ppa_mth_tbl		t_ppa_mth_tbl ;
    l_no_mths_prem_paid		number ;
    l_last_month_found		number ;
    l_each_row			number ;
    -- End of 4199014

    CURSOR csr_get_context_values
    IS
    SELECT paa.assignment_id,
           pa.payroll_id,
           pa.establishment_id  -- 3506171
      FROM per_assignments_f      pa,
           pay_assignment_actions     paa
     WHERE paa.assignment_action_id = p_assignment_action_id
     AND pa.assignment_id           = paa.assignment_id
     AND g_pact.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date;

  --employee details cursor
    CURSOR csr_employee_details
    IS
    SELECT pp.last_name || pp.first_name                  employee_name,
           pp.national_identifier                         national_identifier,
           pei.pei_information1                           hi_number,
           nvl(pei.pei_information4,pei.pei_information2) qualified_date,
           hhoi.org_information1                          business_place_code,
           NULL                                           business_place_unit
     FROM  per_people_extra_info                          pei,
           per_people_f                                   pp,
           per_assignments_f                              pa,
           pay_assignment_actions                         paa,
           pay_payroll_actions                            ppa,
           hr_organization_information                    hhoi,
           per_periods_of_service                         pds
     WHERE ppa.payroll_action_id                        = g_pact.payroll_action_id
       AND paa.payroll_action_id                        = ppa.payroll_action_id
       AND pa.assignment_id                             = paa.assignment_id
       AND pp.person_id                                 = pa.person_id
       AND pei.person_id(+)                             = pp.person_id
       AND pei.information_type(+)                      = 'PER_KR_HEALTH_INSURANCE_INFO'
       AND paa.tax_unit_id                              = hhoi.organization_id
       AND hhoi.org_information_context                 = 'KR_HI_INFORMATION'
       AND pp.person_id                                 = pds.person_id
       AND NVL(pds.actual_termination_date,ppa.effective_date) BETWEEN pa.effective_start_date AND pa.effective_end_date
       AND ppa.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date
       AND pp.business_group_id                        = g_pact.business_group_id
       AND paa.assignment_action_id                    = p_assignment_action_id;
       --
       --Bug 2931128
       --
       cursor csr_get_dbl_id (p_balance_name  varchar2, p_dimension_name varchar2 )
           is
       select defined_balance_id
         from pay_balance_types      pbt ,
              pay_balance_dimensions pbd ,
              pay_defined_balances   pdb
         where pbt.balance_name         =p_balance_name
           and pbt.legislation_code     ='KR'
           and pbd.dimension_name       =p_dimension_name
           and pbd.legislation_code     ='KR'
           and pbt.balance_type_id      =pdb.balance_type_id
           and pbd.balance_dimension_id =pdb.balance_dimension_id ;

	/* Bug 4199014: Performance update - Removed check for balance value (call to PAY_BALANCE_PKG.GET_VALUE)
			from the WHERE clause. Changed the SELECT clause, added extra WHERE predicate
			(PAA.ACTION_STATUS).
	*/
        cursor csr_hi_no_of_mths_prem_paid(p_assact_id  pay_assignment_actions.assignment_action_id%type ,
                                           p_start_date date ,
                                           p_end_date   date )
            is
        select paa.assignment_action_id
	      ,to_number(to_char(ppa.effective_date,'MM') )
          from pay_assignment_actions    xpaa
              ,pay_payroll_actions       xppa
              ,pay_payroll_actions       ppa
              ,pay_assignment_actions    paa
              ,pay_run_types_f           prt
        where  xpaa.assignment_action_id    = p_assact_id
          and xppa.payroll_action_id        = xpaa.payroll_action_id
          and xpaa.assignment_id            = paa.assignment_id
          and ppa.payroll_action_id         = paa.payroll_action_id
	  and paa.action_status 	    = 'C' -- Bug 4199014
          and ppa.action_type           in ('B', 'I', 'V', 'R', 'Q')
          and prt.run_type_id               = paa.run_type_id
          and prt.run_type_name             = 'MTH'
          and ppa.effective_date       between prt.effective_start_date
                                           and prt.effective_end_date
          and prt.legislation_code          = 'KR'
          and ppa.effective_date       between p_start_date
                                           and p_end_date
          and xppa.business_group_id        = ppa.business_group_id
	order by 2 ; -- IMPORTANT: Logic below depends on this ORDER BY
	-- End of 4199014
	-- Bug 3438946
	Cursor csr_last_year_asg_action
	IS
	   SELECT paa.assignment_action_id
	     FROM pay_assignment_actions paa,
	          per_assignments_f pa,
	          pay_payroll_actions ppa
	    WHERE pa.assignment_id = l_assignment_id
	      AND paa.assignment_id = l_assignment_id
	      AND paa.assignment_id = pa.assignment_id
	      AND ppa.payroll_action_id = paa.payroll_action_id
	      AND ppa.effective_date between trunc(p_effective_date, 'YYYY') and (add_months(trunc(p_effective_date,'YYYY'),12)-1)
	      AND ppa.action_type in ('B', 'V', 'R', 'Q', 'I')
	      AND paa.action_status = 'C'
	      AND p_effective_date between pa.effective_start_date and pa.effective_end_date
	    ORDER BY paa.action_sequence desc;

       l_last_year_assignment_action	NUMBER(15);
       l_defined_balance_id		NUMBER(9);

  BEGIN
    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;
    --
    OPEN csr_get_context_values;
    FETCH csr_get_context_values INTO l_assignment_id,l_payroll_id,l_establishment_id; -- 3506171
    CLOSE csr_get_context_values;

    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;
    -- Bug 3438946
    open csr_last_year_asg_action;
    fetch csr_last_year_asg_action into l_last_year_assignment_action;
    close csr_last_year_asg_action;
    -- End of bug 3438946
    --
    pay_archive.g_context_values.name(1) := 'BUSINESS_GROUP_ID';
    pay_archive.g_context_values.value(1) := to_char(g_pact.business_group_id);
    pay_archive.g_context_values.name(2) := 'PAYROLL_ID';
    pay_archive.g_context_values.value(2) := to_char(l_payroll_id);
    pay_archive.g_context_values.name(3) := 'PAYROLL_ACTION_ID';
    pay_archive.g_context_values.value(3) := to_char(g_pact.payroll_action_id);
    pay_archive.g_context_values.name(4) := 'ASSIGNMENT_ID';
    pay_archive.g_context_values.value(4) := to_char(l_assignment_id);
    pay_archive.g_context_values.name(5) := 'ASSIGNMENT_ACTION_ID';
    -- Bug 3438946
    pay_archive.g_context_values.value(5) := to_char(l_last_year_assignment_action);
    --
    pay_archive.g_context_values.name(6) := 'DATE_EARNED';
    pay_archive.g_context_values.value(6) := fnd_date.date_to_canonical(g_pact.effective_date);
    pay_archive.g_context_values.name(7) := 'TAX_UNIT_ID';
    pay_archive.g_context_values.value(7) := to_char(l_establishment_id); -- 3506171
    pay_archive.g_context_values.sz := 7;

    if g_debug then
      hr_utility.set_location(l_proc_name, 30);
    end if;

    /* Start of Archiving Employee Details */
    -----------------------------------------+
    -- note : the fetch order FROM the cursor
    --        should be same as the order
    --        defined in the pl/sql table below
    -----------------------------------------+
    l_arch_tab.delete;
    l_arch_tab(1).item  := 'X_KR_HIA_EMPLOYEE_NAME';
    l_arch_tab(2).item  := 'X_KR_HIA_REGISTRATION_NUMBER';
    l_arch_tab(3).item  := 'X_KR_HIA_HI_NUMBER';
    l_arch_tab(4).item  := 'X_KR_HIA_QUALIFIED_DATE';
    l_arch_tab(5).item  := 'X_KR_HIA_BUSINESS_PLACE_CODE';
    l_arch_tab(6).item  := 'X_KR_HIA_BUSINESS_PLACE_UNIT';
    -- Bug 3438946
    l_arch_tab(8).item  := 'X_HI_PREM_EE_WO_ADJ';
    l_arch_tab(9).item  := 'X_EARNINGS_SUBJ_HI';
    l_arch_tab(10).item := 'X_HI_WORKING_MONTHS';
    --
    -- Bug 2931128
    --
    l_arch_tab(7).item := 'X_KR_HI_NUM_OF_MTHS_PREM_PAID';

    if g_dbl_id_hi_prem is null then
      open csr_get_dbl_id('HI_PREM_EE_WO_ADJ', '_ASG_MTD_MTH');
      fetch csr_get_dbl_id into g_dbl_id_hi_prem ;
      close csr_get_dbl_id;
    end if ;

    /* Bug 4199014: (Performance update)
    		    csr_hi_no_of_mths_prem_paid now gets only the
    		    assignment actions corresponding to a monthly
		    run. IT NO LONGER FILTERS THE DATA BASED ON THE
		    VALUE OF BALANCE HI_PREM_EE_WO_ADJ_ASG_MTD_MTH.
		    We place this check after the cursor's execution.
    */

    l_assact_tbl.delete ;
    l_ppa_mth_tbl.delete ;

    open csr_hi_no_of_mths_prem_paid(p_assignment_action_id ,
                                     g_pact.year_start_date ,
                                     g_pact.reported_date ) ;
    fetch csr_hi_no_of_mths_prem_paid bulk collect into l_assact_tbl, l_ppa_mth_tbl ;
    close csr_hi_no_of_mths_prem_paid;

    l_no_mths_prem_paid := 0 ;
    l_last_month_found := 0 ;

    -- This loop finds out DISTINCT months for which the balance was non-zero.
    -- The ORDER BY on month number (ASC) in cursor CSR_HI_NO_OF_MTHS_PREM_PAID is used in the loop.
    --
    l_each_row := l_assact_tbl.first ;
    loop
    	exit when l_each_row is null ;
    	if l_ppa_mth_tbl(l_each_row) = l_last_month_found then
		-- This month has already been included in l_no_mths_prem_paid; do nothing
		null ;
	elsif pay_balance_pkg.get_value(g_dbl_id_hi_prem, l_assact_tbl(l_each_row) ) > 0 then
		l_last_month_found := l_ppa_mth_tbl(l_each_row) ; -- Now this is the latest month accounted for
		l_no_mths_prem_paid := l_no_mths_prem_paid + 1 ;
	end if ;
	l_each_row := l_assact_tbl.next(l_each_row) ;
    end loop ;
    --
    l_arch_tab(7).value := l_no_mths_prem_paid ;
    -- End of 4199014
    --
    --End of changes for Bug 2931128
    --------------------------------------------------------------
    -- Bug 3438946
    open csr_get_dbl_id('HI_PREM_EE_WO_ADJ', '_ASG_YTD');
    fetch csr_get_dbl_id into l_defined_balance_id;
    if csr_get_dbl_id%notfound then
       raise no_data_found;
    end if;
    close csr_get_dbl_id;

    l_arch_tab(8).value := pay_balance_pkg.get_value(l_defined_balance_id, l_last_year_assignment_action);
    --
    open csr_get_dbl_id('EARNINGS_SUBJ_HI', '_ASG_YTD');
    fetch csr_get_dbl_id into l_defined_balance_id;
    if csr_get_dbl_id%notfound then
       raise no_data_found;
    end if;
    close csr_get_dbl_id;

    l_arch_tab(9).value := pay_balance_pkg.get_value(l_defined_balance_id, l_last_year_assignment_action);
    --
    l_arch_tab(10).value := pay_balance_pkg.run_db_item('HI_WORKING_MONTHS', null, 'KR');
    --
    --End of changes for Bug 3438946
    --------------------------------------------------------------
    if g_debug then
      hr_utility.set_location('Entering : Archiving emp Details ',1);
      hr_utility.set_location('Assignments action id is  '||p_assignment_action_id,2);
    end if;

    OPEN csr_employee_details ;
    LOOP
      FETCH csr_employee_details
       INTO l_arch_tab(1).value,
            l_arch_tab(2).value,
            l_arch_tab(3).value,
            l_arch_tab(4).value,
            l_arch_tab(5).value,
            l_arch_tab(6).value;
       EXIT WHEN csr_employee_details%NOTFOUND;

      if g_debug then
        hr_utility.set_location('Creating Archive Item ',3);
      end if;

      FOR i IN 1..l_arch_tab.count
      LOOP
        archive_item(p_item     => l_arch_tab(i).item
                    ,p_context1 => p_assignment_action_id
                    ,p_value    => l_arch_tab(i).value);
      END LOOP;
    END LOOP;
    CLOSE csr_employee_details;

    if g_debug then
      hr_utility.set_location('Exiting : Archiving emp Details ',200);
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in archiving emp details ',10);
      RAISE;
  /* End of Archiving Employee Details */
  END archive_code;
  --------------------------------------------------------------------------
  -- This Procedure Actually Calls the Health Insurance Adjustment Report.
  --------------------------------------------------------------------------
  FUNCTION SUBMIT_REPORT
  RETURN NUMBER
  IS
    l_count                NUMBER := 0;
    l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
    l_bp_hi_number         hr_organization_information.org_information1%type := NULL; --3506171
    l_reported_date        DATE := NULL;
    l_number_of_copies     NUMBER := 0;
    l_request_id           NUMBER := 0;
    l_print_return         BOOLEAN;
    l_report_short_name    varchar2(30);
    l_formula_id           number;
    l_error_text           varchar2(255);
    e_missing_formula      exception;
    e_submit_error         exception;
    -- Cursor to get the report print options.
    CURSOR csr_get_print_options(p_payroll_action_id NUMBER)
    IS
    SELECT printer,
           print_style,
           decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
      FROM pay_payroll_actions      pact,
           fnd_concurrent_requests  fcr
     WHERE fcr.request_id         = pact.request_id
       AND pact.payroll_action_id = p_payroll_action_id;
     rec_print_options  csr_get_print_options%ROWTYPE;
  BEGIN
    -- Get all of the parameters needed to submit the report. Parameters defined
    -- in the concurrent program definition are passed through here by the PAR
    -- process. End the loop by the exception clause because we don't know
    -- what order the parameters will be in.
    -- Default the parameters in case they are not found.

    if g_debug then
      hr_utility.set_location('Submit report called',1);
      hr_utility.set_location('payroll action id'||l_payroll_action_id,1);
    end if;

    BEGIN
      LOOP
      l_count := l_count + 1;
        IF pay_mag_tape.internal_prm_names(l_count) = 'TRANSFER_PAYROLL_ACTION_ID' THEN
          l_payroll_action_id   := to_number(pay_mag_tape.internal_prm_values(l_count));
        ELSIF pay_mag_tape.internal_prm_names(l_count) = 'REPORTED_DATE' THEN
          l_reported_date       := fnd_date.canonical_to_date(pay_mag_tape.internal_prm_values(l_count));
        ELSIF pay_mag_tape.internal_prm_names(l_count) = 'BP_HI_NUMBER' THEN  -- 3506171
          l_bp_hi_number        := pay_mag_tape.internal_prm_values(l_count);
        END IF;
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        hr_utility.set_location('No data found',1);
        NULL;
      WHEN VALUE_ERROR THEN
        hr_utility.set_location('Value error',1);
        NULL;
    END;
    -- Default the number of report copies to 0.
    l_number_of_copies := 0;
    -- Set up the printer options.
    OPEN  csr_get_print_options(l_payroll_action_id);
    FETCH csr_get_print_options INTO rec_print_options;
    CLOSE csr_get_print_options;

    if g_debug then
      hr_utility.set_location('fnd_request.set_print_options',1);
    end if;

    l_print_return := fnd_request.set_print_options
                   (printer        => rec_print_options.printer,
                    style          => rec_print_options.print_style,
                    copies         => l_number_of_copies,
                    save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                    print_together => 'N');
    l_report_short_name := 'PAYKRHCL';
    -- Submit the report
    BEGIN

      if g_debug then
        hr_utility.set_location('fnd_request.submit_request',1);
      end if;

      l_request_id := fnd_request.submit_request
                   (application => 'PAY',
                    program     => l_report_short_name,
                    argument1   => 'P_PAYROLL_ACTION_ID='||l_payroll_action_id,
                    argument2   => 'P_BP_HI_NUMBER='||l_bp_hi_number,   --3506171
                    argument3   => 'P_REPORTED_DATE='||l_reported_date);
      -- If an error submitting report then get message and put to log.

      if g_debug then
        hr_utility.set_location('l_request_id : '||l_request_id,1);
      end if;

      IF l_request_id = 0 THEN
        RAISE e_submit_error;
      END IF;
      RETURN l_request_id;
    EXCEPTION
      WHEN e_submit_error THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Could Not submit report');
        RETURN 0;
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, sqlerrm);
        RETURN 0;
      END;
  END SUBMIT_REPORT;


END pay_kr_hia_pkg;

/
