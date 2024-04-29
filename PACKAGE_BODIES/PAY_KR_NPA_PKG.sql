--------------------------------------------------------
--  DDL for Package Body PAY_KR_NPA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_NPA_PKG" as
/* $Header: pykrnpa.pkb 120.1 2005/12/29 22:05:23 ssutar noship $ */
--
-- Constants
--
  l_package varchar2(31) := '  pay_kr_npa_pkg.';
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
	-- Bug 3506172
        bp_np_number   	 	 hr_organization_information.org_information1%type);
	-- End of 3506172
        g_pact                   t_pact;
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
               'SELECT DISTINCT ppf.person_id
                FROM   pay_payroll_actions  ppa
                       ,per_people_f    ppf
                WHERE  ppa.payroll_action_id = :p_payroll_action_id
                  AND  ppa.business_group_id = ppf.business_group_id
             ORDER BY  ppf.person_id';

    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;
  END range_code;
  --------------------------------------------------------------------------------+
  -- Cache ARCHIVE payroll action parameters
  --------------------------------------------------------------------------------+
  PROCEDURE initialization_code(
                                p_payroll_action_id IN NUMBER)
  IS
    l_proc_name VARCHAR2(100) := l_package || 'initialization_code';
  BEGIN
    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;

    SELECT ppa.payroll_action_id,
           ppa.report_type,
           ppa.report_qualifier,
           ppa.report_category,
           ppa.business_group_id,
           ppa.effective_date,
           pay_core_utils.get_parameter('BP_NP_NUMBER',ppa.legislative_parameters) -- Bug 3506172
    INTO  g_pact
    FROM  pay_payroll_actions           ppa
    WHERE ppa.payroll_action_id = p_payroll_action_id;

    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in initialization code ',10);
      RAISE;
  END initialization_code;

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
    l_start_date DATE;
    l_end_date DATE;
    CURSOR csr_date IS
    SELECT to_date('01-11-'||to_char(to_number(to_char(fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTED_DATE',bppa.legislative_parameters)),'YYYY'))-1),'DD-MM-YYYY')
           ,fnd_date.canonical_to_date(pay_core_utils.get_parameter('REPORTED_DATE',bppa.legislative_parameters))
    FROM   pay_payroll_actions bppa
    WHERE  bppa.payroll_action_id = p_payroll_action_id;

    ------------------------------------------------------------------------------
    -- Cursor altered for fix 2928733
    -- Added distinct to the SELECT clause
    ------------------------------------------------------------------------------
    CURSOR csr_asg(p_bp_np_number hr_organization_information.org_information1%type
                   ,p_start_date in date
                   ,p_end_date in date)
    IS
    SELECT distinct ass.assignment_id
           ,ass.establishment_id
    FROM   pay_payroll_actions 		bppa
           ,per_assignments_f 		ass
	   ,hr_organization_information hoi
	   ,hr_organization_units	hou
    WHERE bppa.payroll_action_id = p_payroll_action_id
      AND ass.person_id BETWEEN p_start_person_id AND p_end_person_id
      -- Bug 3506172
      AND ass.establishment_id = hoi.organization_id
      AND hou.business_group_id = bppa.business_group_id
      AND hoi.organization_id = hou.organization_id
      AND hoi.org_information_context = 'KR_NP_INFORMATION'
      AND hoi.org_information1  = p_bp_np_number
      -- End of 3506172
-- 3453776 : This WHERE clause has been moved from the inner SELECT
      AND bppa.effective_date between ass.effective_start_date and ass.effective_end_date
--
      AND EXISTS    ( SELECT NULL
                        FROM pay_payroll_actions ppa
                             ,pay_assignment_actions paa
                       WHERE ppa.payroll_action_id = paa.payroll_action_id
                         AND paa.assignment_id = ass.assignment_id
                         AND ppa.effective_date BETWEEN p_start_date
                                                    AND p_end_date
                         AND ppa.action_type in ('R','Q')
                         AND ppa.action_status = 'C'
                    )
      AND NOT EXISTS( SELECT NULL
                        FROM pay_payroll_actions         ppa4
                             ,pay_assignment_actions     paa4
                        WHERE paa4.assignment_id        = ass.assignment_id
                          AND paa4.source_action_id     IS NULL
                          AND paa4.payroll_action_id    = ppa4.payroll_action_id
                          AND ppa4.action_type          = 'X'
                          AND ppa4.report_type          = 'NPA'
                          AND ppa4.report_qualifier     = 'KR'
                          AND ppa4.report_category      = 'A'
                          AND trunc(ppa4.effective_date,'YYYY') = trunc(bppa.effective_date,'YYYY')
                      UNION ALL                       -- 4660204
                      SELECT NULL
                        FROM per_people_extra_info       pei
                       WHERE pei.person_id             = ass.person_id
                         AND pei.information_type      = 'PER_KR_NATIONAL_PENSION_INFO'
                         AND pei.pei_information7      IN ('03')
                    );

  BEGIN
    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;

    initialization_code(p_payroll_action_id);

    OPEN  csr_date;
    FETCH csr_date INTO l_start_date,l_end_date;
    CLOSE csr_date;
    FOR l_asg IN csr_asg(g_pact.bp_np_number,l_start_date,l_end_date) -- Bug 3506172
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
    -- Bug 3506172
    l_est_id		NUMBER ;
    -- End of 3506172
    TYPE t_arch_rec IS RECORD(item   VARCHAR2(50)
                             ,value  VARCHAR2(1000));
    TYPE t_arch_tab IS TABLE OF t_arch_rec INDEX BY BINARY_INTEGER;
    l_arch_tab t_arch_tab;
    CURSOR csr_get_context_values
    IS
    SELECT paa.assignment_id,
           pa.payroll_id,
	   pa.establishment_id -- Bug 3506172
      FROM per_assignments_f          pa,
           pay_assignment_actions     paa
     WHERE paa.assignment_action_id = p_assignment_action_id
     AND pa.assignment_id           = paa.assignment_id
     AND g_pact.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date;

  --employee details cursor
    CURSOR csr_employee_details
    IS
    SELECT hoi.org_information1 business_place_code
           ,pp.national_identifier registration_code
           ,hoi.org_information2 branch_code
           ,hoi1.org_information14 computerization_code
      FROM pay_assignment_actions paa
           ,per_assignments_f ass
           ,per_people_f pp
           ,hr_organization_information hoi
           ,hr_organization_information hoi1
     WHERE paa.assignment_action_id = p_assignment_action_id
       AND paa.assignment_id = ass.assignment_id
       AND ass.person_id = pp.person_id
       AND ass.establishment_id = hoi.organization_id
       AND hoi.org_information_context = 'KR_NP_INFORMATION'
       AND ass.establishment_id = hoi1.organization_id
       AND hoi1.org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
       AND p_effective_date BETWEEN ass.effective_start_date AND ass.effective_end_date
       AND p_effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;

  BEGIN
    if g_debug then
      hr_utility.set_location(l_proc_name, 10);
    end if;

    OPEN csr_get_context_values;
    FETCH csr_get_context_values INTO l_assignment_id,l_payroll_id, l_est_id; -- Bug 3506172
    CLOSE csr_get_context_values;

    if g_debug then
      hr_utility.set_location(l_proc_name, 20);
    end if;

    pay_archive.g_context_values.name(1) := 'BUSINESS_GROUP_ID';
    pay_archive.g_context_values.value(1) := to_char(g_pact.business_group_id);
    pay_archive.g_context_values.name(2) := 'PAYROLL_ID';
    pay_archive.g_context_values.value(2) := to_char(l_payroll_id);
    pay_archive.g_context_values.name(3) := 'PAYROLL_ACTION_ID';
    pay_archive.g_context_values.value(3) := to_char(g_pact.payroll_action_id);
    pay_archive.g_context_values.name(4) := 'ASSIGNMENT_ID';
    pay_archive.g_context_values.value(4) := to_char(l_assignment_id);
    pay_archive.g_context_values.name(5) := 'ASSIGNMENT_ACTION_ID';
    pay_archive.g_context_values.value(5) := to_char(p_assignment_action_id);
    pay_archive.g_context_values.name(6) := 'DATE_EARNED';
    pay_archive.g_context_values.value(6) := fnd_date.date_to_canonical(g_pact.effective_date);
    pay_archive.g_context_values.name(7) := 'TAX_UNIT_ID';
    pay_archive.g_context_values.value(7) := to_char(l_est_id); -- Bug 3506172
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
    l_arch_tab(1).item := 'X_KR_NPA_BUSINESS_PLACE_CODE';
    l_arch_tab(2).item := 'X_KR_NPA_REGISTRATION_NUMBER';
    l_arch_tab(3).item := 'X_KR_NPA_BRANCH_CODE';
    l_arch_tab(4).item := 'X_KR_NPA_COMPUTERIZATION_CODE';

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
            l_arch_tab(4).value ;
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

  FUNCTION return_header(
                P_lookup_type IN VARCHAR2,
                p_lookup_code IN VARCHAR2 )
  RETURN VARCHAR2
  IS
    l_meaning VARCHAR2(80);
    no_lookup EXCEPTION;
    CURSOR csr_hr_lookups
    IS
      SELECT meaning
        FROM hr_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code;
  BEGIN
    OPEN csr_hr_lookups ;
    FETCH csr_hr_lookups INTO l_meaning;
    CLOSE csr_hr_lookups ;

    IF l_meaning IS NOT NULL THEN
       RETURN  l_meaning;
    ELSE
      RAISE no_lookup;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in return_header ',10);
      RAISE;
  END;

END pay_kr_npa_pkg;

/
