--------------------------------------------------------
--  DDL for Package Body PAY_IN_24Q_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_24Q_ARCHIVE" AS
/* $Header: pyin24qa.pkb 120.18.12010000.7 2010/01/06 10:36:27 mdubasi ship $ */

   TYPE t_person_data_rec IS RECORD
     ( person_id per_all_people_f.person_id%TYPE
      ,pan_number per_all_people_f.per_information14%TYPE
      ,pan_ref_number per_all_people_f.per_information14%TYPE
      ,full_name per_all_people_f.full_name%TYPE
      ,tax_rate  per_assignment_extra_info.aei_information2 %TYPE
      ,position per_all_positions.name%TYPE);

    TYPE t_person_data_tab_type IS TABLE OF  t_person_data_rec
      INDEX BY binary_integer;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETERS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure determines the globals applicable    --
  --                  through out the tenure of the process               --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id  NUMBER                         --
  --                  p_token_name         VARCHAR2                       --
  --            OUT : p_token_value        VARCHAR2                       --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 5-Jan-2006     lnagaraj   Initial Version                      --
  --------------------------------------------------------------------------

  PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                           p_token_name        IN  VARCHAR2,
                           p_token_value       OUT  NOCOPY VARCHAR2)
  IS

    CURSOR csr_parameter_info(p_pact_id NUMBER,
                              p_token   CHAR) IS
    SELECT SUBSTR(legislative_parameters,
                   INSTR(legislative_parameters,p_token)+(LENGTH(p_token)+1),
                    INSTR(legislative_parameters,' ',
                           INSTR(legislative_parameters,p_token))
                     - (INSTR(legislative_parameters,p_token)+LENGTH(p_token)))
           ,business_group_id
      FROM  pay_payroll_actions
     WHERE  payroll_action_id = p_pact_id;

    l_token_value VARCHAR2(150);
    l_bg_id       NUMBER;
    l_proc        VARCHAR2(100);
    l_message     VARCHAR2(255);

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'get_parameters';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_payroll_action_id            : ',p_payroll_action_id);
      pay_in_utils.trace('p_token_name                   : ',p_token_name);
      pay_in_utils.trace('******************************','********************');
    end if;

    OPEN csr_parameter_info(p_payroll_action_id,
                            p_token_name);
    FETCH csr_parameter_info INTO l_token_value,l_bg_id;
    CLOSE csr_parameter_info;

    if g_debug then
      pay_in_utils.trace('l_token_value            : ',l_token_value);
      pay_in_utils.trace('l_bg_id                  : ',l_bg_id);
    end if;

    p_token_value := TRIM(l_token_value);

    if g_debug then
      pay_in_utils.trace('p_token_value before            : ',p_token_value);
    end if;

    IF (p_token_name = 'BG_ID') THEN
        p_token_value := l_bg_id;
    END IF;

    IF (p_token_value IS NULL) THEN
         p_token_value := '%';
    END IF;

    if g_debug then
      pay_in_utils.trace('p_token_value after             : ',p_token_value);
    end if;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,20);

  END get_parameters;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : INITIALIZATION_CODE                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to set global contexts.      --
  --                    Store 1.Challan Element type id                   --
  --                          2.Challan input value id in a PL/SQL table  --
  --                          3.legislative parameters                    --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj  Initial Version                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE initialization_code (p_payroll_action_id  IN NUMBER)
  IS
  --
    l_proc  VARCHAR2(100) ;
    l_message     VARCHAR2(255);
    l_assess_yr_start DATE;
    l_end_date DATE;
    i NUMBER;
    l_arch_ref_no_check NUMBER;
    E_NON_UNIQUE_ARCH_REF_NO EXCEPTION;

   CURSOR csr_challan_input_id
       IS
   SELECT pet.element_type_id element_type_id
         ,piv.input_value_id input_value_id
         ,piv.display_sequence indx
     FROM pay_element_types_f pet
         ,pay_input_values_f piv
    WHERE pet.element_name ='Income Tax Challan Information'
      AND pet.legislation_code='IN'
      AND pet.element_type_id = piv.element_type_id
      AND piv.name in('Challan or Voucher Number',
                      'Payment Date',
                      'Taxable Income',
                      'Income Tax Deducted',
                      'Surcharge Deducted',
                      'Education Cess Deducted',
                      'Amount Deposited')
      AND g_session_date BETWEEN pet.effective_start_date AND pet.effective_end_date
      AND g_session_date BETWEEN piv.effective_start_date AND piv.effective_end_date;
  --
   CURSOR csr_arch_ref_no(p_payroll_action_id NUMBER
                         ,p_bg_id             NUMBER)
       IS
   SELECT 1
    FROM pay_action_information pai
        ,pay_payroll_actions ppa
        ,hr_organization_units hou
   WHERE pai.action_information_category = 'IN_24Q_ORG'
     AND pai.action_context_type         = 'PA'
     AND pai.action_information1 like g_gre_id
     AND pai.action_information3 = g_year||g_quarter
     AND pai.action_information30 = g_archive_ref_no
     AND pai.action_context_id = ppa.payroll_action_id
     AND ppa.action_type = 'X'
     AND ppa.action_status = 'C'
     AND ppa.payroll_action_id <> p_payroll_action_id
     AND hou.organization_id = pai.action_information1
     AND hou.business_group_id = p_bg_id;

    l_token_name    pay_in_utils.char_tab_type;
    l_token_value   pay_in_utils.char_tab_type;

  BEGIN
  --

    g_debug :=  hr_utility.debug_enabled;
    l_proc  :=  g_package || 'initialization_code';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

   if g_debug then
     pay_in_utils.trace('******************************','********************');
     pay_in_utils.trace('p_payroll_action_id            : ',p_payroll_action_id);
     pay_in_utils.trace('******************************','********************');
   end if;

    get_parameters(p_payroll_action_id,'YR',g_year);
    get_parameters(p_payroll_action_id,'GRE',g_gre_id);
    get_parameters(p_payroll_action_id,'QR',g_quarter);
    get_parameters(p_payroll_action_id,'RN',g_archive_ref_no);
    get_parameters(p_payroll_action_id,'BG_ID',g_bg_id);

    if g_debug then
      pay_in_utils.trace('g_year               : ',g_year);
      pay_in_utils.trace('g_gre_id             : ',g_gre_id);
      pay_in_utils.trace('g_quarter            : ',g_quarter);
      pay_in_utils.trace('g_bg_id              : ',g_bg_id);
    end if;

    l_arch_ref_no_check := 0;
    OPEN csr_arch_ref_no(p_payroll_action_id
                        ,g_bg_id);
    FETCH csr_arch_ref_no INTO l_arch_ref_no_check;
    CLOSE csr_arch_ref_no;
    IF l_arch_ref_no_check = 1 THEN
       l_token_name(1) := 'NUMBER_CATEGORY';
       l_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','ARCH_REF_NUM');--'Archive Reference Number';
       RAISE E_NON_UNIQUE_ARCH_REF_NO;
    END IF;

    SELECT TRUNC(effective_date)
    INTO   g_session_date
    FROM   fnd_sessions
    WHERE  session_id = USERENV('sessionid');

    if g_debug then
      pay_in_utils.trace('g_session_date               : ',g_session_date);
    end if;

    i := TO_NUMBER(SUBSTR(g_quarter,2,1)) - 1;
    l_assess_yr_start := fnd_date.string_to_date(('01/04/'|| SUBSTR(g_year,1,4)),'DD/MM/YYYY');
    g_tax_year := TO_CHAR((TO_NUMBER(SUBSTR(g_year,1,4)) - 1)||'-'||SUBSTR(g_year,1,4));
    l_end_date   := fnd_date.string_to_date(('31/03/'|| SUBSTR(g_year,6)),'DD/MM/YYYY');

    if g_debug then
      pay_in_utils.trace('i                        : ',i);
      pay_in_utils.trace('l_assess_yr_start        : ',l_assess_yr_start);
      pay_in_utils.trace('g_tax_year               : ',g_tax_year);
      pay_in_utils.trace('l_end_date               : ',l_end_date);
    end if;

    g_fin_start_date := ADD_MONTHS(l_assess_yr_start,-12);
    g_fin_end_date   := ADD_MONTHS(l_end_date,-12);
    g_qr_start_date  := ADD_MONTHS(l_assess_yr_start,(i*3)-12);
    g_end_date       := ADD_MONTHS(g_qr_start_date,3) -1;
    g_payroll_action_id := p_payroll_action_id;

    if g_debug then
      pay_in_utils.trace('g_fin_start_date         : ',g_fin_start_date);
      pay_in_utils.trace('g_fin_end_date           : ',g_fin_end_date);
      pay_in_utils.trace('g_qr_start_date          : ',g_qr_start_date);
      pay_in_utils.trace('g_end_date               : ',g_end_date);
      pay_in_utils.trace('g_payroll_action_id      : ',g_payroll_action_id);
    end if;

    pay_in_utils.set_location(g_debug,'Finding Globals : '||l_proc,20);

    IF g_quarter ='Q4' THEN
      g_start_date := ADD_MONTHS(l_assess_yr_start,-12);
    ELSE
      g_start_date := g_qr_start_date;
    END IF;

    if g_debug then
      pay_in_utils.trace('g_start_date         : ',g_start_date);
    end if;

    FOR crec in csr_challan_input_id LOOP
      g_input_table_rec(crec.indx).input_value_id := crec.input_value_id;
      g_chln_element_id := crec.element_type_id;
    END LOOP;

    pay_in_utils.set_location(g_debug,'Global1: '||g_year||' '||g_bg_id||' '||g_quarter||' '||g_gre_id,30);
    pay_in_utils.set_location(g_debug,'Global2: '||g_start_date||g_end_date||g_qr_start_date,40);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,50);

  --
  EXCEPTION
    WHEN E_NON_UNIQUE_ARCH_REF_NO THEN
      pay_in_utils.raise_message(800, 'PER_IN_NON_UNIQUE_VALUE', l_token_name, l_token_value);
      fnd_file.put_line(fnd_file.log,'Archive Reference Number '|| g_archive_ref_no || 'is non-unique.');
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,60);
      RAISE;
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,70);
      pay_in_utils.trace(l_message,l_proc);
      RAISE;
  END initialization_code;

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : RANGE_CODE                                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns a sql string to select a     --
  --                  range of assignments eligible for archival.         --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : p_sql                  VARCHAR2                     --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj  Initial Version                       --
  --------------------------------------------------------------------------
  --

  PROCEDURE range_code(p_payroll_action_id   IN  NUMBER
                      ,p_sql                 OUT NOCOPY VARCHAR2)
  IS
  --
    l_proc  VARCHAR2(100);
    l_message     VARCHAR2(255);
  --
  BEGIN
  --

    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package || 'range_code';

    hr_utility.set_location('Entering : '||l_proc,10);

    -- Call core package to return SQL string to SELECT a range
    -- of assignments eligible for archival
    --
    pay_core_payslip_utils.range_cursor(p_payroll_action_id
                                       ,p_sql);

    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,20);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,30);
      pay_in_utils.trace(l_message,l_proc);
      RAISE;
  --
  END range_code;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_ACTION_CODE                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure further restricts the assignment_id's--
  --                  returned by range_code.                             --
  --                  It selects assignments that have prepayments/balance--
  --                  initialization in the specified duration OR those   --
  --                  that have Challan information entries               --
  --                  of challans in the specified quarter                --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --                  p_start_person         NUMBER                       --
  --                  p_end_person           NUMBER                       --
  --                  p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj  Initial Version                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE assignment_action_code(p_payroll_action_id   IN NUMBER
                                  ,p_start_person        IN NUMBER
                                  ,p_end_person          IN NUMBER
                                  ,p_chunk               IN NUMBER
                                  )
  IS
    CURSOR c_process_assignments
    IS
      SELECT  paf.assignment_id assignment_id
        FROM per_assignments_f paf
            ,pay_payroll_actions ppa
            ,pay_assignment_actions paa
       WHERE paf.business_group_id = g_bg_id
         AND paf.person_id BETWEEN p_start_person AND p_end_person
         AND p_payroll_action_id IS NOT NULL
         AND paa.tax_unit_id LIKE  g_gre_id
         AND paa.assignment_id =paf.assignment_id
         AND ppa.action_type IN('P','U','I')
         AND paa.payroll_action_id = ppa.payroll_action_id
         AND ppa.action_status = 'C'
         AND ppa.effective_date BETWEEN  g_start_date and g_end_date
         AND paf.effective_start_date <= g_end_date
         AND paf.effective_end_date >= g_start_date
         AND ppa.business_group_id =g_bg_id
      UNION
      SELECT paf1.assignment_id
        FROM pay_element_entries_f pee
            ,per_assignments_f paf1
       WHERE paf1.business_group_id = g_bg_id
         AND paf1.person_id BETWEEN p_start_person AND p_end_person
         AND pee.element_type_id = g_chln_element_id
         AND p_payroll_action_id IS NOT NULL
         AND paf1.effective_start_date <= g_fin_end_date
         AND paf1.effective_end_date >= g_fin_start_date
         AND pee.effective_start_date <= g_fin_end_date
         AND pee.effective_end_date >= g_fin_start_date
         AND pee.assignment_id = paf1.assignment_id
         AND EXISTS (SELECT ''
                       FROM pay_element_entry_values_f peev
                       WHERE peev.input_value_id = g_input_table_rec(1).input_value_id
                         AND peev.element_entry_id = pee.element_entry_id
			 AND peev.effective_start_date <= g_fin_end_date
                         AND peev.effective_end_date >= g_fin_start_date
                         AND peev.screen_entry_value in (SELECT bank.org_information4||' - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                           FROM hr_organization_units hou
                                                               ,hr_organization_information hoi
                                                               ,hr_organization_information bank
                                                          WHERE hoi.organization_id   = hou.organization_id
                                                            AND hou.business_group_id = g_bg_id
                                                            AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                            AND hoi.org_information1 = g_tax_year
                                                            AND bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                                                            and bank.organization_id = hoi.organization_id
                                                            AND hoi.org_information5 = bank.org_information_id
                                                            AND hoi.org_information13 = g_quarter
                                                            AND hoi.organization_id LIKE g_gre_id
                                                         UNION
                                                        SELECT 'BOOK - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                          FROM hr_organization_units hou
                                                              ,hr_organization_information hoi
                                                         WHERE hoi.organization_id   = hou.organization_id
                                                           AND hou.business_group_id = g_bg_id
                                                           AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                           AND hoi.org_information1 = g_tax_year
                                                           AND hoi.org_information13 = g_quarter
                                                           AND hoi.org_information5 IS NULL
                                                           AND hoi.organization_id LIKE g_gre_id
			                                 )
                         AND ROWNUM =1);

    l_proc                 VARCHAR2(100);
    l_message              VARCHAR2(255);
    l_action_id                 NUMBER;
  --
  BEGIN
  --

    g_debug := hr_utility.debug_enabled;
    l_proc  :=  g_package || 'assignment_action_code';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_payroll_action_id            : ',p_payroll_action_id);
  pay_in_utils.trace('p_start_person                 : ',p_start_person);
  pay_in_utils.trace('p_end_person                   : ',p_end_person);
  pay_in_utils.trace('p_chunk                        : ',p_chunk);
  pay_in_utils.trace('******************************','********************');
end if;

if g_debug then
  pay_in_utils.trace('g_fin_start_date            : ',g_fin_start_date);
end if;

    -- need to initialise the global contexts again
    IF g_fin_start_date IS  NULL THEN
      initialization_code (p_payroll_action_id);
    END IF;

    FOR csr_rec IN c_process_assignments
    LOOP
      SELECT pay_assignment_actions_s.NEXTVAL
        INTO l_action_id
        FROM dual;

      if g_debug then
        pay_in_utils.trace('l_action_id                 : ',l_action_id);
        pay_in_utils.trace('csr_rec.assignment_id       : ',csr_rec.assignment_id);
      end if;

      hr_nonrun_asact.insact(lockingactid => l_action_id
                            ,assignid     => csr_rec.assignment_id
                            ,pactid       => p_payroll_action_id
                            ,chunk        => p_chunk
                            );

    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,30);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,40);
      pay_in_utils.trace(l_message,l_proc);
      RAISE;
  END assignment_action_code;

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CHALLAN_DATA                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure archives organization level challan  --
  --                  data belonging to a GRE in a quarter at PA level    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE archive_challan_data(p_arc_pay_action_id     IN  NUMBER
                                ,p_gre_id                IN  NUMBER
                             )
   IS
  CURSOR csr_challans_in_guarter
  IS
  SELECT hoi_challan.org_information2  Payment_date
        ,hoi_challan.org_information5  Bank
        ,hoi_challan.org_information3  challan_number
        ,hoi_challan.org_information4  tax
        ,hoi_challan.org_information6  remarks
        ,hoi_challan.org_information7  surcharge
        ,hoi_challan.org_information8  cess
        ,hoi_challan.org_information9  interest
        ,hoi_challan.org_information10 others
        ,hoi_challan.org_information11 dd_cheq_num
        ,hoi_challan.org_information12 book_entry
        ,hoi_challan.org_information_id org_info_id
    FROM hr_organization_information hoi_challan
   WHERE hoi_challan.organization_id = p_gre_id
     AND hoi_challan.org_information_context ='PER_IN_IT_CHALLAN_INFO'
     AND hoi_challan.org_information1 = g_tax_year
     AND hoi_challan.org_information13 = g_quarter
     AND fnd_date.canonical_to_date(hoi_challan.org_information2) <= fnd_date.CHARDATE_TO_DATE(SYSDATE)
   ORDER BY fnd_date.canonical_to_date(hoi_challan.org_information2);

 CURSOR csr_challan_bank(p_bank_code VARCHAR2)
  IS
  SELECT hoi_bank.org_information4     Bank
    FROM hr_organization_information hoi_bank
   WHERE hoi_bank.organization_id = p_gre_id
     AND hoi_bank.org_information_context = 'PER_IN_CHALLAN_BANK'
     AND hoi_bank.org_information_id = p_bank_code;

      TYPE t_challan_entry_asg_rec IS RECORD
      (Payment_date hr_organization_information.org_information2%TYPE,
       Bank         hr_organization_information.org_information4%TYPE,
       challan_number pay_element_entry_values_f.screen_entry_value%TYPE,
       tax          hr_organization_information.org_information4%TYPE,
       remarks      hr_organization_information.org_information4%TYPE,
       surcharge    hr_organization_information.org_information4%TYPE,
       cess         hr_organization_information.org_information4%TYPE,
       interest     hr_organization_information.org_information4%TYPE,
       others       hr_organization_information.org_information4%TYPE,
       dd_cheq_num  hr_organization_information.org_information4%TYPE,
       book_entry   hr_organization_information.org_information4%TYPE,
       org_info_id  hr_organization_information.org_information_id%TYPE
     );
    --

     TYPE t_challan_entry_asg_tab_type IS TABLE OF  t_challan_entry_asg_rec
       INDEX BY binary_integer;

     t_challan_entry_asg_tab t_challan_entry_asg_tab_type;

     l_action_info_id NUMBER;
     l_ovn            NUMBER;
     p_cnt            NUMBER;
     l_bank_code      hr_organization_information.org_information4%TYPE;
     l_proc           VARCHAR2(100);
     l_message        VARCHAR2(255);
  BEGIN

    g_debug := hr_utility.debug_enabled;
    l_proc  :=  g_package || 'archive_challan_data';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
       pay_in_utils.trace('******************************','********************');
       pay_in_utils.trace('p_arc_pay_action_id            : ',p_arc_pay_action_id);
       pay_in_utils.trace('p_gre_id                       : ',p_gre_id);
       pay_in_utils.trace('******************************','********************');
    end if;

    t_challan_entry_asg_tab.DELETE;

    OPEN csr_challans_in_guarter ;
    FETCH csr_challans_in_guarter BULK COLLECT INTO t_challan_entry_asg_tab;
    CLOSE csr_challans_in_guarter;

    p_cnt := t_challan_entry_asg_tab.COUNT;

    if g_debug then
      pay_in_utils.trace('p_cnt            : ',p_cnt);
    end if;

    IF p_cnt >0 then
      FOR i IN t_challan_entry_asg_tab.FIRST .. t_challan_entry_asg_tab.LAST LOOP
        l_bank_code := NULL;
        IF t_challan_entry_asg_tab.EXISTS(i) THEN
           IF t_challan_entry_asg_tab(i).Bank IS NOT NULL THEN
             OPEN csr_challan_bank(t_challan_entry_asg_tab(i).Bank);
             FETCH csr_challan_bank INTO l_bank_code ;
             CLOSE csr_challan_bank;
           END IF;

           if g_debug then
             pay_in_utils.trace('challan_number                   : ',t_challan_entry_asg_tab(i).challan_number);
             pay_in_utils.trace('g_year                           : ',g_year);
             pay_in_utils.trace('g_quarter                        : ',g_quarter);
             pay_in_utils.trace('l_bank_code                      : ',l_bank_code);
             pay_in_utils.trace('Payment_date                     : ',t_challan_entry_asg_tab(i).Payment_date);
             pay_in_utils.trace('tax                              : ',t_challan_entry_asg_tab(i).tax);
             pay_in_utils.trace('surcharge                        : ',t_challan_entry_asg_tab(i).surcharge);
             pay_in_utils.trace('interest                         : ',t_challan_entry_asg_tab(i).interest);
             pay_in_utils.trace('others                           : ',t_challan_entry_asg_tab(i).others);
             pay_in_utils.trace('dd_cheq_num                      : ',t_challan_entry_asg_tab(i).dd_cheq_num);
             pay_in_utils.trace('book_entry                       : ',t_challan_entry_asg_tab(i).book_entry);
             pay_in_utils.trace('remarks                          : ',t_challan_entry_asg_tab(i).remarks);
           end if;

           IF (NVL(t_challan_entry_asg_tab(i).tax,0)<>0 OR
               NVL(t_challan_entry_asg_tab(i).surcharge,0)<>0 OR
               NVL(t_challan_entry_asg_tab(i).cess,0)<>0 OR
               NVL(t_challan_entry_asg_tab(i).interest,0)<>0 OR
               NVL(t_challan_entry_asg_tab(i).others,0)<>0 ) THEN
                 pay_action_information_api.create_action_information
                (p_action_context_id              =>     p_arc_pay_action_id
                ,p_action_context_type            =>     'PA'
                ,p_action_information_category    =>     'IN_24Q_CHALLAN'
                ,p_source_id                      =>     t_challan_entry_asg_tab(i).org_info_id
                ,p_action_information1            =>     NVL(l_bank_code,'BOOK')||' - '||t_challan_entry_asg_tab(i).challan_number ||' - '||to_char(fnd_date.canonical_to_date(t_challan_entry_asg_tab(i).Payment_date),'DD-Mon-YYYY')
                ,p_action_information2            =>     g_year||g_quarter
                ,p_action_information3            =>     p_gre_id
                ,p_action_information4            =>     l_bank_code
                ,p_action_information5            =>     t_challan_entry_asg_tab(i).Payment_date
                ,p_action_information6            =>     nvl(t_challan_entry_asg_tab(i).tax,0)
                ,p_action_information7            =>     nvl(t_challan_entry_asg_tab(i).surcharge,0)
                ,p_action_information8            =>     nvl(t_challan_entry_asg_tab(i).cess,0)
                ,p_action_information9            =>     nvl(t_challan_entry_asg_tab(i).interest,0)
                ,p_action_information10           =>     nvl(t_challan_entry_asg_tab(i).others,0)
                ,p_action_information11           =>     t_challan_entry_asg_tab(i).dd_cheq_num
                ,p_action_information12           =>     t_challan_entry_asg_tab(i).book_entry
                ,p_action_information13           =>     t_challan_entry_asg_tab(i).remarks
                ,p_action_information25           =>     i
                ,p_action_information_id          =>     l_action_info_id
                ,p_object_version_number          =>     l_ovn
                );

          END IF;
        END IF;

      END LOOP;
    END IF;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,20);
  --
  END archive_challan_data;

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ORG_DATA                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to archive the Org/Representative         --
  --                  data at PA level as on the quarter end date         --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_date         DATE                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj  Initial Version                       --
  -- 115.1 25-Sep-2007    rsaharay  Modified cursors c_pos,c_rep_address  --
  -- 115.2 23-Sep-2009    mdubasi   Modified cursor c_org_inc_tax_df_details
  --------------------------------------------------------------------------
   PROCEDURE archive_org_data(p_arc_pay_action_id     IN  NUMBER
                             ,p_gre_id                IN  NUMBER
                             ,p_effective_date          IN  DATE
                             )
   IS

   CURSOR c_org_inc_tax_df_details
   IS
   SELECT  hoi.org_information1        tan
          ,hoi.org_information3        er_class
	  ,hoi.org_information6        er_24q_class
          ,hoi.org_information4        reg_org_id
          ,hoi.org_information7        division
          ,hou.location_id             location_id
	  ,hoi.org_information9        state
          ,hoi.org_information10       pao_code
          ,hoi.org_information11       ddo_code
          ,hoi.org_information12       ministry_name
          ,hoi.org_information13       other_ministry_name
          ,hoi.org_information14       pao_reg_code
          ,hoi.org_information15       ddo_reg_code
   FROM    hr_organization_information hoi
          ,hr_organization_units       hou
   WHERE hoi.organization_id = p_gre_id
   AND hoi.org_information_context = 'PER_IN_INCOME_TAX_DF'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND p_effective_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

   CURSOR c_reg_org_details(p_reg_org_id        NUMBER)
   IS
   SELECT hoi.org_information3        pan
         ,hoi.org_information4        legal_name
   FROM  hr_organization_information  hoi
        ,hr_organization_units        hou
   WHERE hoi.organization_id = p_reg_org_id
   AND   hoi.org_information_context = 'PER_IN_COMPANY_DF'
   AND   hou.organization_id = hoi.organization_id
   AND   hou.business_group_id = g_bg_id
   AND   p_effective_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR c_pos(p_person_id                  NUMBER)
  IS
  SELECT nvl(pos.name,job.name) name
  FROM   per_positions     pos
        ,per_assignments_f asg
	,per_jobs          job
  WHERE  asg.position_id=pos.position_id(+)
  AND    asg.job_id=job.job_id(+)
  AND    asg.person_id = p_person_id
  AND    asg.primary_flag = 'Y'
  AND    asg.business_group_id = g_bg_id
  AND    p_effective_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


  CURSOR c_representative_id
  IS
  SELECT hoi.org_information1     person_id
        ,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) rep_name
        ,pep.email_address        email_id
  FROM   hr_organization_information   hoi
        ,hr_organization_units         hou
        ,per_people_f              pep
  WHERE  hoi.org_information_context = 'PER_IN_INCOME_TAX_REP_DF'
  AND    hoi.organization_id = p_gre_id
  AND    hou.organization_id = hoi.organization_id
  AND    hou.business_group_id = g_bg_id
  AND    pep.person_id = hoi.org_information1
  AND    pep.business_group_id = hou.business_group_id
  AND    p_effective_date BETWEEN pep.effective_start_date AND pep.effective_end_date
  AND    p_effective_date BETWEEN fnd_date.canonical_to_date(hoi.org_information2)
  AND    NVL(fnd_date.canonical_to_date(hoi.org_information3),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    p_effective_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR c_rep_address(p_person_id         NUMBER)
  IS
  SELECT hou.location_id rep_location
  FROM   per_assignments_f   asg
        ,hr_organization_units hou
  WHERE asg.person_id = p_person_id
  AND   asg.primary_flag = 'Y'
  AND   asg.business_group_id = g_bg_id
  AND   hou.organization_id = asg.organization_id
  AND   hou.business_group_id = asg.business_group_id
  AND   p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
  AND   p_effective_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR c_rep_phone(p_person_id         NUMBER)
  IS
  SELECT phone_number rep_phone_no
  FROM   per_phones
  WHERE  parent_id = p_person_id
  AND    phone_type =  'W1'
  AND    p_effective_date BETWEEN date_from AND NVL(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR csr_challan_recs
  IS
  SELECT COUNT(*)
  FROM   pay_action_information
  WHERE  action_information_category = 'IN_24Q_CHALLAN'
  AND    action_context_type         = 'PA'
  AND    action_context_id = p_arc_pay_action_id
  AND    action_information3 = p_gre_id
  AND    action_information2 = g_year||g_quarter;

  l_tan                 hr_organization_information.org_information1%TYPE;
  l_er_class            hr_organization_information.org_information3%TYPE;
  l_er_24q_class        hr_organization_information.org_information6%TYPE;
  l_reg_org_id          hr_organization_information.org_information4%TYPE;
  l_division            hr_organization_information.org_information7%TYPE;
  l_location_id         hr_organization_units.location_id%TYPE;
  l_pan                 hr_organization_information.org_information3%TYPE;
  l_legal_name          hr_organization_information.org_information4%TYPE;
  l_state               hr_organization_information.org_information9%TYPE;
  l_pao_code            hr_organization_information.org_information10%TYPE;
  l_ddo_code            hr_organization_information.org_information11%TYPE;
  l_ministry_name       hr_organization_information.org_information12%TYPE;
  l_other_ministry_name hr_organization_information.org_information13%TYPE;
  l_pao_reg_code        hr_organization_information.org_information14%TYPE;
  l_ddo_reg_code        hr_organization_information.org_information15%TYPE;
  l_rep_person_id       per_all_people_f.person_id%TYPE;
  l_rep_name            per_all_people_f.full_name%TYPE;
  l_position            per_all_positions.name%TYPE;
  l_rep_location        hr_organization_units.location_id%TYPE;
  l_rep_phone_no        per_phones.phone_number%TYPE;
  l_rep_email_id        per_all_people_f.email_address%TYPE;
  l_action_info_id      NUMBER;
  l_ovn                 NUMBER;
  l_challan_count       NUMBER;
  l_nil_challan         VARCHAR2(1);
  l_proc                VARCHAR2(100);
  l_message             VARCHAR2(255);

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc  :=  g_package || 'archive_org_data';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_arc_pay_action_id             : ',p_arc_pay_action_id);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('p_effective_date                : ',p_effective_date);
      pay_in_utils.trace('******************************','********************');
    end if;

    OPEN  c_org_inc_tax_df_details;
    FETCH c_org_inc_tax_df_details INTO l_tan
                                       ,l_er_class
				       ,l_er_24q_class
				       ,l_reg_org_id
				       ,l_division
				       ,l_location_id
				       ,l_state
				       ,l_pao_code
				       ,l_ddo_code
				       ,l_ministry_name
				       ,l_other_ministry_name
				       ,l_pao_reg_code
				       ,l_ddo_reg_code ;
    CLOSE c_org_inc_tax_df_details;

    OPEN  c_reg_org_details(l_reg_org_id);
    FETCH c_reg_org_details INTO l_pan,l_legal_name;
    CLOSE c_reg_org_details;

    OPEN  c_representative_id;
    FETCH c_representative_id INTO l_rep_person_id,l_rep_name,l_rep_email_id;
    CLOSE c_representative_id;

    OPEN  c_pos(l_rep_person_id);
    FETCH c_pos INTO l_position;
    CLOSE c_pos;

    OPEN  c_rep_address(l_rep_person_id);
    FETCH c_rep_address INTO l_rep_location;
    CLOSE c_rep_address;

    OPEN  c_rep_phone(l_rep_person_id);
    FETCH c_rep_phone INTO l_rep_phone_no;
    CLOSE c_rep_phone;

    OPEN  csr_challan_recs;
    FETCH csr_challan_recs INTO l_challan_count;
      IF l_challan_count <> 0 THEN
         l_nil_challan := 'N';
      ELSE
         l_nil_challan := 'Y';
      END IF;
    CLOSE csr_challan_recs;

    if g_debug then
      pay_in_utils.trace('l_tan                           : ',l_tan);
      pay_in_utils.trace('g_year                          : ',g_year);
      pay_in_utils.trace('g_quarter                       : ',g_quarter);
      pay_in_utils.trace('l_reg_org_id                    : ',l_reg_org_id);
      pay_in_utils.trace('l_division                      : ',l_division);
      pay_in_utils.trace('l_location_id                   : ',l_location_id);
      pay_in_utils.trace('l_pan                           : ',l_pan);
      pay_in_utils.trace('l_legal_name                    : ',l_legal_name);
      pay_in_utils.trace('l_rep_person_id                 : ',l_rep_person_id);
      pay_in_utils.trace('l_rep_name                      : ',l_rep_name);
      pay_in_utils.trace('l_rep_email_id                  : ',l_rep_email_id);
      pay_in_utils.trace('l_position                      : ',l_position);
      pay_in_utils.trace('l_rep_location                  : ',l_rep_location);
      pay_in_utils.trace('l_rep_phone_no                  : ',l_rep_phone_no);
      pay_in_utils.trace('l_state                         : ',l_state);
      pay_in_utils.trace('l_pao_code                      : ',l_pao_code);
      pay_in_utils.trace('l_ddo_code                      : ',l_ddo_code);
      pay_in_utils.trace('l_ministry_name                 : ',l_ministry_name);
      pay_in_utils.trace('l_other_ministry_name           : ',l_other_ministry_name);
      pay_in_utils.trace('l_pao_reg_code                  : ',l_pao_reg_code);
      pay_in_utils.trace('l_ddo_reg_code                  : ',l_ddo_reg_code);
    end if;

    pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_24Q_ORG'
              ,p_action_information1            =>     p_gre_id
              ,p_action_information2            =>     l_tan
              ,p_action_information3            =>     g_year||g_quarter
              ,p_action_information4            =>     l_pan
              ,p_action_information5            =>     l_legal_name
              ,p_action_information6            =>     l_location_id
              ,p_action_information7            =>     l_er_class
              ,p_action_information21           =>     l_er_24q_class
              ,p_action_information8            =>     l_division
              ,p_action_information9            =>     l_rep_name
              ,p_action_information10           =>     l_rep_email_id
              ,p_action_information11           =>     l_position
              ,p_action_information12           =>     l_rep_location
              ,p_action_information13           =>     l_rep_phone_no
	      ,p_action_information14           =>     l_state
              ,p_action_information15           =>     l_pao_code
              ,p_action_information16           =>     l_ddo_code
              ,p_action_information17           =>     l_ministry_name
              ,p_action_information18           =>     l_other_ministry_name
              ,p_action_information19           =>     l_pao_reg_code
              ,p_action_information20           =>     l_ddo_reg_code
              ,p_action_information30           =>     g_archive_ref_no
              ,p_action_information26           =>     l_nil_challan
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );

       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 20);

   END archive_org_data;

 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : ARCHIVE_PERSON_DATA                                 --
 -- Type           : PROCEDURE                                           --
 -- Access         : Public                                              --
 -- Description    : This procedure archives the person data             --
 -- Parameters     :                                                     --
 --             IN : p_run_asg_action_id    NUMBER                       --
 --                  p_arc_asg_action_id    NUMBER                       --
 --                  p_assignment_id        NUMBER                       --
 --                  p_gre_id               NUMBER                       --
 --                  p_effective_start_date DATE                         --
 --                  p_effective_end_date   DATE                         --
 --                  p_effective_date       DATE                         --
 --                  p_termination_date     DATE                         --
 --            OUT : N/A                                                 --
 --                                                                      --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid    Description                           --
 --------------------------------------------------------------------------
 -- 115.0 05-Jan-2006    lnagaraaj   Initial Version                     --
 -- 115.1 25-Sep-2007    rsaharay    Modified cursors c_pos              --
 --------------------------------------------------------------------------
 --
  PROCEDURE archive_person_data(p_run_asg_action_id     IN NUMBER
                               ,p_arc_asg_action_id     IN NUMBER
                               ,p_assignment_id         IN NUMBER
                               ,p_gre_id                IN NUMBER
                               ,p_effective_start_date  IN DATE
                               ,p_effective_end_date    IN DATE
                               ,p_effective_date        IN DATE
                               ,p_termination_date      IN DATE
                               ,p_person_table          IN OUT NOCOPY t_person_data_tab_type
                               )
  IS

    CURSOR c_emp_no
    IS
    SELECT asg.person_id         person_id
          ,DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4) pan
          ,pep.per_information14 pan_ref_num
          ,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) name
    FROM   per_assignments_f  asg
          ,per_people_f       pep
    WHERE  asg.assignment_id = p_assignment_id
      AND  pep.person_id  = asg.person_id
      AND  pep.business_group_id = g_bg_id
      AND  asg.business_group_id = g_bg_id
      AND  p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND  p_effective_date BETWEEN pep.effective_start_date AND pep.effective_end_date ;

    CURSOR c_pos
    IS
    SELECT nvl(pos.name,job.name) name
    FROM   per_all_positions pos
          ,per_assignments_f asg
    	  ,per_jobs          job
    WHERE  asg.position_id=pos.position_id(+)
    AND    asg.job_id=job.job_id(+)
    AND    asg.assignment_id = p_assignment_id
    AND    asg.business_group_id = g_bg_id
    AND    p_effective_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
    AND    p_effective_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
    AND    p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


    CURSOR c_aei_tax_rate(p_person_id  NUMBER)
    IS
    SELECT  paei.aei_information2
      FROM  per_assignment_extra_info paei
           ,per_assignments_f paa
     WHERE  paei.information_type = 'PER_IN_TAX_EXEMPTION_DF'
       AND  paei.aei_information_category = 'PER_IN_TAX_EXEMPTION_DF'
       AND  paei.assignment_id = paa.assignment_id
       AND  paa.person_id = p_person_id
       AND  paei.aei_information1 = g_tax_year
       AND  p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
       AND  ROWNUM = 1;

    CURSOR csr_payroll_id(p_assignment_id NUMBER,p_date DATE)
     IS
     SELECT paf.payroll_id
      FROM per_all_assignments_f paf
     WHERE paf.assignment_id =p_assignment_id
       AND p_date BETWEEN paf.effective_start_date AND paf.effective_end_date;

    l_person_id                per_all_people_f.person_id%TYPE;
    l_pan                      per_all_people_f.per_information4%TYPE;
    l_pan_ref_num              per_all_people_f.per_information14%TYPE;
    l_name                     per_all_people_f.full_name%TYPE;
    l_pos                      per_all_positions.name%TYPE;
    l_tax_rate                 per_assignment_extra_info.aei_information2%TYPE;
    l_action_info_id           NUMBER;
    l_ovn                      NUMBER;
    flag                       BOOLEAN;
    l_full_name                per_all_people_f.full_name%TYPE;

    l_effective_start_date     DATE;
    l_effective_end_date       DATE;
    l_payroll_id               NUMBER;
    l_total_pay_period         NUMBER;
    l_current_pay_period       NUMBER;

    l_proc                     VARCHAR2(100);
    l_message                  VARCHAR2(255);


  BEGIN

    g_debug := hr_utility.debug_enabled;
    l_proc  :=  g_package || 'archive_person_data';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_run_asg_action_id             : ',p_run_asg_action_id);
      pay_in_utils.trace('p_arc_asg_action_id             : ',p_arc_asg_action_id);
      pay_in_utils.trace('p_assignment_id                 : ',p_assignment_id);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('p_effective_start_date          : ',p_effective_start_date);
      pay_in_utils.trace('p_effective_end_date            : ',p_effective_end_date);
      pay_in_utils.trace('p_effective_date                : ',p_effective_date);
      pay_in_utils.trace('p_termination_date              : ',p_termination_date);
      pay_in_utils.trace('******************************','********************');
   end if;

   IF p_person_table.EXISTS(1) THEN
     NULL;
   ELSE
   --
    OPEN  c_emp_no;
    FETCH c_emp_no INTO l_person_id,l_pan,l_pan_ref_num,l_name;
    CLOSE c_emp_no;


    OPEN  c_pos;
    FETCH c_pos INTO l_pos;
    CLOSE c_pos;

    OPEN  c_aei_tax_rate(l_person_id);
    FETCH c_aei_tax_rate INTO l_tax_rate;
    CLOSE c_aei_tax_rate;

        p_person_table(1).person_id       := l_person_id;
        p_person_table(1).pan_number      := l_pan;
        p_person_table(1).pan_ref_number  := l_pan_ref_num;
        p_person_table(1).full_name       := l_name;
        p_person_table(1).tax_rate        := l_tax_rate;
        p_person_table(1).position        := l_pos;
   --
   END IF;

    IF p_effective_start_date > LEAST(p_effective_end_date,p_termination_date) THEN
      l_effective_end_date := g_end_date;
    ELSE
      l_effective_end_date := LEAST(g_end_date,p_effective_end_date,p_termination_date);
    END IF;

    IF g_quarter = 'Q4' THEN
      l_effective_start_date := p_effective_start_date;
    ELSE
      l_effective_start_date := GREATEST(g_qr_start_date,p_effective_start_date);
    END IF;

    if g_debug then
      pay_in_utils.trace('person_id                        : ',p_person_table(1).person_id);
      pay_in_utils.trace('g_year                           : ',g_year);
      pay_in_utils.trace('g_quarter                        : ',g_quarter);
      pay_in_utils.trace('pan_number                       : ',p_person_table(1).pan_number);
      pay_in_utils.trace('pan_ref_number                   : ',p_person_table(1).pan_ref_number);
      pay_in_utils.trace('full_name                        : ',p_person_table(1).full_name);
      pay_in_utils.trace('tax_rate                         : ',p_person_table(1).tax_rate);
      pay_in_utils.trace('position                         : ',p_person_table(1).position);
      pay_in_utils.trace('l_effective_start_date           : ',l_effective_start_date);
      pay_in_utils.trace('l_effective_end_date             : ',l_effective_end_date);
    end if;

    pay_action_information_api.create_action_information
                 (p_action_context_id              =>     p_arc_asg_action_id
                 ,p_action_context_type            =>     'AAP'
                 ,p_action_information_category    =>     'IN_24Q_PERSON'
                 ,p_source_id                      =>     p_run_asg_action_id
                 ,p_assignment_id                  =>     p_assignment_id
                 ,p_action_information1            =>     p_person_table(1).person_id
                 ,p_action_information2            =>     g_year||g_quarter
                 ,p_action_information3            =>     p_gre_id
                 ,p_action_information4            =>     p_person_table(1).pan_number
                 ,p_action_information5            =>     p_person_table(1).pan_ref_number
                 ,p_action_information6            =>     p_person_table(1).full_name
                 ,p_action_information7            =>     p_person_table(1).tax_rate
                 ,p_action_information8            =>     p_person_table(1).position
                 ,p_action_information9            =>     fnd_date.date_to_canonical(l_effective_start_date)
                 ,p_action_information10           =>     fnd_date.date_to_canonical(l_effective_end_date)
                 ,p_action_information_id          =>     l_action_info_id
                 ,p_object_version_number          =>     l_ovn
                 );

pay_in_utils.set_location(g_debug,'Leaving: '||l_proc,20);

  END archive_person_data;

  --------------------------------------------------------------------------
   --                                                                      --
  -- Name           : ARCHIVE_VIA_DETAILS                                 --
   -- Type           : PROCEDURE                                           --
   -- Access         : Public                                              --
   -- Description    : This procedure archives the Chapter VI A related    --
   --                  details under 3 heads - 80G, 80GG and 80OTHERS      --
   -- Parameters     :                                                     --
   --             IN : p_run_asg_action_id    NUMBER                       --
   --                  p_arc_pay_action_id    NUMBER                       --
   --                  p_gre_id               NUMBER                       --
   --                  p_assignment_id        NUMBER                       --
   --            OUT : N/A                                                 --
   --                                                                      --
   -- Change History :                                                     --
   --------------------------------------------------------------------------
   -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
    -- 115.0 05-Jan-2006    lnagaraj  Initial Version                      --
    -- 115.1 26-Jun-2006    aaagarwa  Modifed c_defined_balance_id         --
   --------------------------------------------------------------------------
  PROCEDURE archive_via_details(p_run_asg_action_id     IN  NUMBER
                               ,p_arc_asg_action_id     IN  NUMBER
                               ,p_gre_id                IN  NUMBER
                               ,p_assignment_id         IN  NUMBER
                               )
  IS

    CURSOR c_defined_balance_id
    IS
    SELECT pdb.defined_balance_id balance_id
          ,pbt.balance_name       balance_name
    FROM   pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
    WHERE  pbt.balance_name IN('F16 Deductions Sec 80E'
                              ,'F16 Deductions Sec 80U'
                              ,'Gross Chapter VIA Deductions'
                              ,'Deferred Annuity'
                              ,'Senior Citizens Savings Scheme'
                              ,'Pension Fund'
                              ,'F16 Employee PF Contribution'
                              ,'F16 Total Chapter VI A Deductions'
                              ,'Deductions under Section 80CCE'
                              ,'F16 Deductions Sec 80GG'
                              ,'F16 Deductions Sec 80G'
                              ,'F16 Deductions Sec 80CCE'
                              ,'F16 ER Pension Contribution'
                               )
    AND pbd.dimension_name='_ASG_LE_PTD'
    AND pbt.legislation_code = 'IN'
    AND pbd.legislation_code = 'IN'
    AND pdb.legislation_code = 'IN'
    AND pbt.balance_type_id = pdb.balance_type_id
    AND pbd.balance_dimension_id  = pdb.balance_dimension_id
    ORDER BY pbt.balance_name;

    g_bal_name_tab        t_bal_name_tab;
    g_balance_value_tab   pay_balance_pkg.t_balance_value_tab;
    g_context_table       pay_balance_pkg.t_context_tab;
    g_result_table        pay_balance_pkg.t_detailed_bal_out_tab;
    g_balance_value_tab1  pay_balance_pkg.t_balance_value_tab;
    g_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;

    i                    NUMBER;
    l_action_info_id     NUMBER;
    l_ovn                NUMBER;
    l_80g_gross          NUMBER;
    l_via_gross          NUMBER;
    l_tot_via_qa         NUMBER;
    l_80gg_qa_gross      NUMBER;
    l_80g_qa             NUMBER;
    l_via_others_gross   NUMBER;
    l_via_others_qa      NUMBER;
    l_80cce_others       NUMBER;
    l_q4_80cce_total     NUMBER;
    l_q4_others_total    NUMBER;
    l_proc               VARCHAR2(100);
    l_message            VARCHAR2(255);

  BEGIN
  -- STEP 0 :Initialise variables
    i := 1;
    l_80g_gross := 0;
    l_via_gross  := 0;
    l_tot_via_qa := 0;
    l_80gg_qa_gross := 0;
    l_80g_qa := 0 ;
    l_via_others_gross := 0;
    l_via_others_qa := 0;
    l_80cce_others := 0;
    l_q4_80cce_total := 0;
    l_q4_others_total := 0;
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'archive_via_details';
    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_run_asg_action_id             : ',p_run_asg_action_id);
      pay_in_utils.trace('p_arc_asg_action_id             : ',p_arc_asg_action_id);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('p_assignment_id                 : ',p_assignment_id);
      pay_in_utils.trace('******************************','********************');
    end if;


  -- STEP 1 : Gross Amount determination for 80G
    g_balance_value_tab1.DELETE;
    g_context_table.DELETE;
    g_result_table1.DELETE;

    g_context_table(1).source_text2  := 'Donations';           -- 80G
    g_context_table(1).tax_unit_id   := p_gre_id;

    g_balance_value_tab1(1).defined_balance_id :=
    pay_in_tax_utils.get_defined_balance('Gross Chapter VIA Deductions','_ASG_LE_COMP_PTD');

    pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                             ,p_defined_balance_lst   =>         g_balance_value_tab1
                             ,p_context_lst           =>         g_context_table
                             ,p_output_table          =>         g_result_table1
                             );
    l_80g_gross := g_result_table1(1).balance_value;
    pay_in_utils.set_location(g_debug,'80G Gross : '||l_80g_gross,20);

  -- STEP 2 : Get Qualifying Amt of Deferred Annuity,Senior Citizens Savings Scheme, Pension Fund and LIC
    g_balance_value_tab1.DELETE;
    g_context_table.DELETE;
    g_result_table1.DELETE;

    g_balance_value_tab1(1).defined_balance_id :=   pay_in_tax_utils.get_defined_balance
                                                   ('Deductions under Section 80CCE','_ASG_LE_COMP_PTD');
    g_context_table(1).source_text2  := 'Deferred Annuity';
    g_context_table(1).tax_unit_id   := p_gre_id;
    g_context_table(2).source_text2  := 'Pension Fund 80CCC';
    g_context_table(2).tax_unit_id   := p_gre_id;
    g_context_table(3).source_text2  := 'Life Insurance Premium';
    g_context_table(3).tax_unit_id   := p_gre_id;
    g_context_table(4).source_text2  := 'Senior Citizens Savings Scheme';
    g_context_table(4).tax_unit_id   := p_gre_id;


    pay_balance_pkg.get_value(p_assignment_action_id  =>         p_run_asg_action_id
                             ,p_defined_balance_lst   =>         g_balance_value_tab1
                             ,p_context_lst           =>         g_context_table
                             ,p_output_table          =>         g_result_table1
                             );
    FOR i IN 1..4 LOOP
      l_80cce_others := l_80cce_others + g_result_table1(i).balance_value;
    END LOOP;
    pay_in_utils.set_location(g_debug,'Qualifying Amount of three 80CCE components: '||l_80cce_others,20);

  -- STEP 3: Qualifying amt of 80GG ,80G, Total Qualifying Chapter VIA,Gross Amt of ALL chapter VIA Components
    g_context_table.DELETE;
    g_result_table.DELETE;
    g_balance_value_tab.DELETE;
    g_bal_name_tab.DELETE;
    g_context_table(1).tax_unit_id := p_gre_id;

    FOR c_rec IN c_defined_balance_id
    LOOP
      g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name            := c_rec.balance_name;
      i := i + 1;
    END LOOP;

    pay_balance_pkg.get_value(p_assignment_action_id  =>     p_run_asg_action_id
                             ,p_defined_balance_lst   =>     g_balance_value_tab
                             ,p_context_lst           =>     g_context_table
                             ,p_output_table          =>     g_result_table
                            );
    pay_in_utils.set_location(g_debug,'ASSACT:  '||p_run_asg_action_id,30);

    FOR i IN 1..g_balance_value_tab.COUNT
    LOOP
      pay_in_utils.set_location(g_debug,'Balance Name: '|| g_bal_name_tab(i).balance_name,32);
      pay_in_utils.set_location(g_debug,'Balance Value: '|| g_result_table(i).balance_value,34);
        IF (g_result_table(i).balance_value <> 0)
        THEN
          IF (g_bal_name_tab(i).balance_name IN('F16 Deductions Sec 80E'
                                               ,'F16 Deductions Sec 80U'
                                               ,'Gross Chapter VIA Deductions'
                                               ,'Deferred Annuity'
                                               ,'Senior Citizens Savings Scheme'
                                               ,'Pension Fund'
                                               ,'F16 Employee PF Contribution'
                                               ,'Deductions under Section 80CCE'
                                               ,'F16 ER Pension Contribution'
                                                )
             )
          THEN
            l_via_gross := l_via_gross + g_result_table(i).balance_value ;
          ELSIF (g_bal_name_tab(i).balance_name ='F16 Total Chapter VI A Deductions')
          THEN
            l_tot_via_qa := g_result_table(i).balance_value ;
          ELSIF (g_bal_name_tab(i).balance_name  = 'F16 Deductions Sec 80GG')
          THEN
            l_80gg_qa_gross := g_result_table(i).balance_value ;
          ELSIF (g_bal_name_tab(i).balance_name  = 'F16 Deductions Sec 80CCE')
          THEN
            l_q4_80cce_total := g_result_table(i).balance_value ;
          ELSE
            l_80g_qa  := g_result_table(i).balance_value ;
          END IF;

        END IF;
    END LOOP;

    l_via_others_gross := l_via_gross - l_80g_gross -l_80cce_others;
    l_via_others_qa    := l_tot_via_qa - (l_80g_qa + l_80gg_qa_gross);

    l_q4_others_total := l_tot_via_qa - l_q4_80cce_total;

    pay_in_utils.set_location(g_debug,'Gross Amt 80G: '||l_80g_gross,30);
    pay_in_utils.set_location(g_debug,'Qual Amt 80G: '||l_80g_qa,40);
    pay_in_utils.set_location(g_debug,'Both Amts 80GG: '||l_80gg_qa_gross,50);
    pay_in_utils.set_location(g_debug,'Gross Amt Others: '||l_via_others_gross,60);
    pay_in_utils.set_location(g_debug,'Qual Amt Others: '|| l_via_others_qa,70);
    pay_in_utils.set_location(g_debug,'Amount 80CCE: '|| l_q4_80cce_total,80);
    pay_in_utils.set_location(g_debug,'Amount Others: '|| l_q4_others_total,90);
    pay_in_utils.set_location(g_debug,'l_80cce_others: '|| l_80cce_others,100);
    pay_in_utils.set_location(g_debug,'l_q4_others_total '|| l_q4_others_total,100);
  -- STEP 4: Archive values

    IF (g_quarter = 'Q4') THEN
        IF (l_q4_80cce_total <> 0) THEN
             pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_arc_asg_action_id
                  ,p_action_context_type            =>     'AAP'
                  ,p_action_information_category    =>     'IN_24Q_VIA'
                  ,p_source_id                      =>     p_run_asg_action_id
                  ,p_action_information1            =>     '80CCE'
                  ,p_action_information2            =>     fnd_number.number_to_canonical(l_q4_80cce_total)
                  ,p_action_information3            =>     fnd_number.number_to_canonical(0)
                  ,p_action_information_id          =>     l_action_info_id
                  ,p_object_version_number          =>     l_ovn
                  );
        END IF;

        IF (l_q4_others_total <> 0) THEN
             pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_arc_asg_action_id
                  ,p_action_context_type            =>     'AAP'
                  ,p_action_information_category    =>     'IN_24Q_VIA'
                  ,p_source_id                      =>     p_run_asg_action_id
                  ,p_action_information1            =>     'Others'
                  ,p_action_information2            =>     fnd_number.number_to_canonical(l_q4_others_total)
                  ,p_action_information3            =>     fnd_number.number_to_canonical(0)
                  ,p_action_information_id          =>     l_action_info_id
                  ,p_object_version_number          =>     l_ovn
                  );
       END IF;
    ELSE
       IF (l_80g_gross <>0 OR l_80g_qa <> 0) THEN
            pay_action_information_api.create_action_information
                 (p_action_context_id              =>     p_arc_asg_action_id
                 ,p_action_context_type            =>     'AAP'
                 ,p_action_information_category    =>     'IN_24Q_VIA'
                 ,p_source_id                      =>     p_run_asg_action_id
                 ,p_action_information1            =>     '80G'
                 ,p_action_information2            =>     fnd_number.number_to_canonical(l_80g_qa)
                 ,p_action_information3            =>     fnd_number.number_to_canonical(l_80g_gross)
                 ,p_action_information_id          =>     l_action_info_id
                 ,p_object_version_number          =>     l_ovn
                 );
       END IF;

       IF (l_80gg_qa_gross <> 0) THEN
            pay_action_information_api.create_action_information
                 (p_action_context_id              =>     p_arc_asg_action_id
                 ,p_action_context_type            =>     'AAP'
                 ,p_action_information_category    =>     'IN_24Q_VIA'
                 ,p_source_id                      =>     p_run_asg_action_id
                 ,p_action_information1            =>     '80GG'
                 ,p_action_information2            =>     fnd_number.number_to_canonical(l_80gg_qa_gross)
                 ,p_action_information3            =>     fnd_number.number_to_canonical(l_80gg_qa_gross)
                 ,p_action_information_id          =>     l_action_info_id
                 ,p_object_version_number          =>     l_ovn
                 );
       END IF;

       IF (l_via_others_gross <>0 OR l_via_others_qa <> 0) THEN
            pay_action_information_api.create_action_information
                 (p_action_context_id              =>     p_arc_asg_action_id
                 ,p_action_context_type            =>     'AAP'
                 ,p_action_information_category    =>     'IN_24Q_VIA'
                 ,p_source_id                      =>     p_run_asg_action_id
                 ,p_action_information1            =>     '80OTHERS'
                 ,p_action_information2            =>     fnd_number.number_to_canonical(l_via_others_qa)
                 ,p_action_information3            =>     fnd_number.number_to_canonical(l_via_others_gross)
                 ,p_action_information_id          =>     l_action_info_id
                 ,p_object_version_number          =>     l_ovn
                 );
       END IF;
    END IF;
  -- STEP 5: Delete PL/SQL Tables
    g_bal_name_tab.DELETE;
    g_balance_value_tab.DELETE;
    g_balance_value_tab1.DELETE;
    g_result_table.DELETE;
    g_context_table.DELETE;
    g_result_table1.DELETE;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_proc,80);
  END archive_via_details;


 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : ARCHIVE_ASG_SALARY                                  --
 -- Type           : PROCEDURE                                           --
 -- Access         : Public                                              --
 -- Description    : This procedure archives the various salary components-
 -- Parameters     :                                                     --
 --             IN : p_run_asg_action_id    NUMBER                       --
 --                  p_arc_asg_action_id    NUMBER                       --
 --                  p_balance_periods      NUMBER                       --
 --                  p_gre_id               NUMBER                       --
 --                  pre_gre_asg_act_id     NUMBER                       --
 --            OUT : N/A                                                 --
 --                                                                      --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid    Description                           --
 --------------------------------------------------------------------------
 -- 115.0 05-Jan-2006    lnagaraj   Initial Version                      --
 -- 115.1 26-Jun-2006    aaagarwa   Modifed c_f16_sal_balances           --
 --------------------------------------------------------------------------
  PROCEDURE archive_asg_salary(p_run_asg_action_id     IN  NUMBER
                              ,p_arc_asg_action_id     IN  NUMBER
                              ,p_balance_periods       IN  NUMBER
                              ,p_gre_id                IN  NUMBER
                              ,pre_gre_asg_act_id      IN  NUMBER DEFAULT NULL)
  IS

    CURSOR c_f16_sal_balances
    IS
    SELECT pdb.defined_balance_id balance_id
          ,pbt.balance_name       balance_name
      FROM pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
     WHERE pbt.balance_name IN('F16 Salary Under Section 17'
                              ,'F16 Profit in lieu of Salary'
                              ,'F16 Value of Perquisites'
                              ,'F16 Gross Salary less Allowances'
                              ,'F16 Allowances Exempt'
                              ,'F16 Deductions under Sec 16'
                              ,'F16 Income Chargeable Under head Salaries'
                              ,'F16 Other Income'
                              ,'F16 Gross Total Income'
                              ,'F16 Total Chapter VI A Deductions'
                              ,'F16 Total Income'
                              ,'F16 Tax on Total Income'
                              ,'F16 Marginal Relief'
                              ,'F16 Total Tax payable'
                              ,'F16 Relief under Sec 89'
                              ,'F16 Employment Tax'
                              ,'F16 Entertainment Allowance'
                              ,'Allowances Standard Value'
                              ,'F16 Surcharge'
                              ,'F16 Education Cess'
                              ,'F16 Sec and HE Cess'
                              ,'F16 TDS'
                              )
       AND pbd.dimension_name   ='_ASG_LE_PTD'
       AND pbt.legislation_code = 'IN'
       AND pbd.legislation_code = 'IN'
       AND pdb.legislation_code = 'IN'
       AND pbt.balance_type_id = pdb.balance_type_id
       AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

    CURSOR c_er_excess_pf_balances
    IS
    SELECT pdb.defined_balance_id balance_id
          ,pbt.balance_name       balance_name
      FROM pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
     WHERE pbt.balance_name IN( 'Excess Interest Amount'
                               ,'Excess PF Amount'
                               ,'Allowance Amount'
                               )
       AND pbd.dimension_name='_ASG_YTD'
       AND pbt.legislation_code = 'IN'
       AND pbd.legislation_code = 'IN'
       AND pbt.balance_type_id = pdb.balance_type_id
       AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

    g_bal_name_tab       t_bal_name_tab;
    g_context_table      pay_balance_pkg.t_context_tab;
    g_balance_value_tab  pay_balance_pkg.t_balance_value_tab;
    g_result_table       pay_balance_pkg.t_detailed_bal_out_tab;
    g_balance_value_tab1 pay_balance_pkg.t_balance_value_tab;
    g_balance_value_tab2 pay_balance_pkg.t_balance_value_tab;

    l_allow_proj_value    NUMBER;
    l_balance_value       NUMBER;
    l_action_info_id      NUMBER;
    l_ovn                 NUMBER;
    l_in_tax_ded          NUMBER :=0;
    i                     NUMBER;
    l_total_cess          NUMBER ;

    l_proc                VARCHAR2(100);
    l_message             VARCHAR2(255);


  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'archive_asg_salary';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_run_asg_action_id             : ',p_run_asg_action_id);
      pay_in_utils.trace('p_arc_asg_action_id             : ',p_arc_asg_action_id);
      pay_in_utils.trace('p_balance_periods               : ',p_balance_periods);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('pre_gre_asg_act_id              : ',pre_gre_asg_act_id);
      pay_in_utils.trace('******************************','********************');
   end if;

    i := 1;
    g_bal_name_tab.DELETE;
    g_balance_value_tab.DELETE;
    g_result_table.DELETE;
    g_context_table.DELETE;
    g_context_table(1).tax_unit_id := p_gre_id;
    l_total_cess:=0;

    --Step 1: Archive F16 balances,also get Projected Allowance Amount
    pay_in_utils.set_location(g_debug,'PERIODS '||p_balance_periods,10);

    FOR c_rec IN c_f16_sal_balances
    LOOP
      g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name            := c_rec.balance_name;
      i := i + 1;
    END LOOP;

    pay_balance_pkg.get_value(p_assignment_action_id  =>     p_run_asg_action_id
                             ,p_defined_balance_lst   =>     g_balance_value_tab
                             ,p_context_lst           =>     g_context_table
                             ,p_output_table          =>     g_result_table
                             );

    l_allow_proj_value :=0;

    FOR i IN 1..g_balance_value_tab.COUNT
    LOOP
       IF g_result_table(i).balance_value <> 0 AND(g_bal_name_tab(i).balance_name='F16 Education Cess' OR g_bal_name_tab(i).balance_name='F16 Sec and HE Cess' ) THEN
          l_total_cess:= l_total_cess + g_result_table(i).balance_value;
      END IF ;
      IF (g_result_table(i).balance_value <> 0)
      THEN
        IF g_bal_name_tab(i).balance_name = 'Allowances Standard Value' THEN
          l_allow_proj_value := g_result_table(i).balance_value * p_balance_periods;
          if g_debug then
              pay_in_utils.trace('l_allow_proj_value             : ',l_allow_proj_value);
          end if;
        ELSIF  g_bal_name_tab(i).balance_name <> 'F16 Education Cess' THEN
          if g_debug then
              pay_in_utils.trace('balance_name             : ',g_bal_name_tab(i).balance_name);
              pay_in_utils.trace('balance_value            : ',g_result_table(i).balance_value);
          end if;
          pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_24Q_SALARY'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     g_bal_name_tab(i).balance_name
             ,p_action_information2            =>     fnd_number.number_to_canonical(g_result_table(i).balance_value)
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
         END IF;
      END IF;
    END LOOP;
       IF l_total_cess <> 0 THEN
        pay_action_information_api.create_action_information
                         (p_action_context_id              =>     p_arc_asg_action_id
                         ,p_action_context_type            =>     'AAP'
                         ,p_action_information_category    =>     'IN_24Q_SALARY'
                         ,p_source_id                      =>     p_run_asg_action_id
                         ,p_action_information1            =>     'F16 Education Cess'
                         ,p_action_information2            =>     fnd_number.number_to_canonical(l_total_cess)
                         ,p_action_information_id          =>     l_action_info_id
                         ,p_object_version_number          =>     l_ovn
                         );
      END IF;

    --Step 2: Get balances for Employer excess PF as total value -previous LE value
    g_bal_name_tab.DELETE;
    g_context_table.DELETE;
    g_balance_value_tab1.DELETE;
    g_balance_value_tab2.DELETE;
    g_result_table.DELETE;
    i := 1;
    l_total_cess:=0;
    FOR c_rec IN c_er_excess_pf_balances
    LOOP
      g_balance_value_tab1(i).defined_balance_id := c_rec.balance_id;
      g_balance_value_tab2(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name             := c_rec.balance_name;
       i := i + 1;
    END LOOP;

    pay_balance_pkg.get_value(p_run_asg_action_id,g_balance_value_tab1);

    IF pre_gre_asg_act_id IS NOT NULL THEN
      pay_balance_pkg.get_value(pre_gre_asg_act_id,g_balance_value_tab2);
    END IF;

    --Step 3:Archive values
    FOR i IN 1..g_balance_value_tab1.COUNT
    LOOP
      IF g_bal_name_tab(i).balance_name = 'Allowance Amount' THEN
        g_balance_value_tab1(i).balance_value := g_balance_value_tab1(i).balance_value + l_allow_proj_value;
      END IF;

      IF pre_gre_asg_act_id IS NOT NULL THEN
        l_balance_value := g_balance_value_tab1(i).balance_value - g_balance_value_tab2(i).balance_value;
      ELSE
        l_balance_value := g_balance_value_tab1(i).balance_value;
      END IF;

      if g_debug then
         pay_in_utils.trace('balance_name               : ',g_bal_name_tab(i).balance_name);
         pay_in_utils.trace('l_balance_value            : ',l_balance_value);
      end if;



      IF (l_balance_value <> 0)
      THEN
         pay_action_information_api.create_action_information
             (p_action_context_id              =>     p_arc_asg_action_id
             ,p_action_context_type            =>     'AAP'
             ,p_action_information_category    =>     'IN_24Q_SALARY'
             ,p_source_id                      =>     p_run_asg_action_id
             ,p_action_information1            =>     g_bal_name_tab(i).balance_name
             ,p_action_information2            =>     fnd_number.number_to_canonical(l_balance_value)
             ,p_action_information_id          =>     l_action_info_id
             ,p_object_version_number          =>     l_ovn
             );
      END IF;
    END LOOP;


    -- Step 4:Delete all PL/SQL tables
    g_bal_name_tab.DELETE;
    g_context_table.DELETE;
    g_balance_value_tab.DELETE;
    g_result_table.DELETE;
    g_balance_value_tab1.DELETE;
    g_balance_value_tab2.DELETE;


    pay_in_utils.set_location(g_debug,'Leaving: '||l_proc,30);

  END archive_asg_salary;

 --------------------------------------------------------------------------
 --                                                                      --
 -- Name           : balance_difference                                  --
 -- Type           : PROCEDURE                                           --
 -- Access         : Private                                              --
 -- Description    : This procedure is used to find the difference in    --
 --                  values of 2 PL/SQL tables                           --
 -- Parameters     :                                                     --
 --      IN : g_result_table1    pay_balance_pkg.t_detailed_bal_out_tab  --
 --           g_result_table2    pay_balance_pkg.t_detailed_bal_out_tab  --
 --      IN/OUT : g_result_table                                         --
 --                                                                      --
 -- Change History :                                                     --
 --------------------------------------------------------------------------
 -- Rev#  Date           Userid    Description                           --
 --------------------------------------------------------------------------
 -- 115.0 05-Jan-2006    lnagaraj   Initial Version                      --
 --------------------------------------------------------------------------
  PROCEDURE balance_difference(g_result_table1            IN pay_balance_pkg.t_detailed_bal_out_tab
                              ,g_result_table2            IN pay_balance_pkg.t_detailed_bal_out_tab
                              ,g_result_table  IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                               )
  IS
  l_proc                VARCHAR2(100);
  l_message             VARCHAR2(255);

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'balance_difference';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

     FOR i IN 1..GREATEST(g_result_table1.COUNT,g_result_table2.COUNT)
     LOOP
        g_result_table(i).balance_value := g_result_table1(i).balance_value
                                         - g_result_table2(i).balance_value;
     END LOOP;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,20);

  END;

--------------------------------------------------------------------------
  --                                                                      --
  -- Name           : get_balances                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Given a list of balances, current LE/Previous LE    --
  --                  assignment action id, this procedure finds the      --
  --                  balance values                                      --
  -- Parameters     :                                                     --
  --      IN :    p_run_asg_action_id  NUMBER                             --
  --              pre_gre_asg_act_id   NUMBER                             --
  --              p_balance_name       VARCHAR2                           --
  --              p_balance_dimension  VARCHAR2                           --
  --      IN/OUT :g_context_table      pay_balance_pkg.t_context_tab      --
  --              g_balance_value_tab  pay_balance_pkg.t_balance_value_tab--
--                g_result_table pay_balance_pkg.t_detailed_bal_out_tab   --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE get_balances(p_run_asg_action_id  IN  NUMBER
                        ,pre_gre_asg_act_id   IN  NUMBER DEFAULT NULL
                        ,p_balance_name       IN  VARCHAR2 DEFAULT NULL
                        ,p_balance_dimension  IN  VARCHAR2 DEFAULT NULL
                        ,g_context_table      IN OUT NOCOPY pay_balance_pkg.t_context_tab
                        ,g_balance_value_tab  IN OUT NOCOPY pay_balance_pkg.t_balance_value_tab
                        ,g_result_table       IN OUT NOCOPY pay_balance_pkg.t_detailed_bal_out_tab
                        )
  IS

    l_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;
    l_result_table2       pay_balance_pkg.t_detailed_bal_out_tab;
    l_proc                VARCHAR2(100);
    l_message             VARCHAR2(255);

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'get_balances';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

     if g_debug then
       pay_in_utils.trace('******************************','********************');
       pay_in_utils.trace('p_run_asg_action_id             : ',p_run_asg_action_id);
       pay_in_utils.trace('pre_gre_asg_act_id              : ',pre_gre_asg_act_id);
       pay_in_utils.trace('p_balance_name                  : ',p_balance_name);
       pay_in_utils.trace('p_balance_dimension             : ',p_balance_dimension);
       pay_in_utils.trace('******************************','********************');
    end if;

    IF p_balance_name IS NOT NULL THEN
      g_balance_value_tab(1).defined_balance_id :=
                          pay_in_tax_utils.get_defined_balance(p_balance_name,p_balance_dimension);
    END IF;

    pay_balance_pkg.get_value(p_assignment_action_id  =>     p_run_asg_action_id
                             ,p_defined_balance_lst   =>     g_balance_value_tab
                             ,p_context_lst           =>     g_context_table
                             ,p_output_table          =>     l_result_table1
                             );

    IF pre_gre_asg_act_id IS NOT NULL
    THEN
       pay_balance_pkg.get_value(p_assignment_action_id  =>     pre_gre_asg_act_id
                                ,p_defined_balance_lst   =>     g_balance_value_tab
                                ,p_context_lst           =>     g_context_table
                                ,p_output_table          =>     l_result_table2
                                );
    ELSE
      g_result_table := l_result_table1;
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,20);
      RETURN;
    END IF;

    balance_difference(l_result_table1,l_result_table2,g_result_table);

    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,30);

END get_balances;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PERQUISITES                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the perqusite balance       --
  -- Parameters     :                                                     --
  --             IN : p_run_asg_action_id    NUMBER                       --
   --                 p_arc_pay_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  pre_gre_asg_act_id     NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj   Initial Version                      --
  --------------------------------------------------------------------------

  PROCEDURE archive_perquisites(p_run_asg_action_id     IN  NUMBER
                               ,p_arc_asg_action_id     IN  NUMBER
                               ,p_gre_id                IN  NUMBER
                               ,pre_gre_asg_act_id      IN  NUMBER DEFAULT NULL
                                )
  IS
    CURSOR c_defined_balance_id
    IS
    SELECT pdb.defined_balance_id balance_id
          ,DECODE(pbt.balance_name,'Monthly Furniture Cost',1,
                                   'Furniture Perquisite',2,
                                   'Taxable Perquisites',3) indx
          ,pbt.balance_name balance_name
      FROM pay_balance_types pbt
           ,pay_balance_dimensions pbd
           ,pay_defined_balances pdb
     WHERE pbt.balance_name IN('Monthly Furniture Cost'
                              ,'Furniture Perquisite'
                              ,'Taxable Perquisites'
                              )
       AND pbd.dimension_name='_ASG_YTD'
       AND pbt.legislation_code = 'IN'
       AND pbd.legislation_code = 'IN'
       AND pbt.balance_type_id = pdb.balance_type_id
       AND pbd.balance_dimension_id  = pdb.balance_dimension_id;


    CURSOR c_proj_defined_balance_id
    IS
    SELECT pdb.defined_balance_id balance_id
          ,DECODE(pbt.balance_name,'Projected Furniture Cost',1,
                                   'Projected Furniture Perquisite',2,
                                   'Taxable Perquisites for Projection',3)  indx
      FROM pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
     WHERE pbt.balance_name IN('Projected Furniture Cost'
                              ,'Projected Furniture Perquisite'
                              ,'Taxable Perquisites for Projection'
                               )
       AND pbd.dimension_name='_ASG_PTD'
       AND pbt.legislation_code = 'IN'
       AND pbd.legislation_code = 'IN'
       AND pbt.balance_type_id = pdb.balance_type_id
       AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

    g_balance_value_tab   pay_balance_pkg.t_balance_value_tab;
    g_balance_value_tab1  pay_balance_pkg.t_balance_value_tab;
    g_balance_value_tab2  pay_balance_pkg.t_balance_value_tab;
    g_bal_name_tab        t_bal_name_tab;
    g_context_table       pay_balance_pkg.t_context_tab;
    g_result_table        pay_balance_pkg.t_detailed_bal_out_tab;
    g_result_table1       pay_balance_pkg.t_detailed_bal_out_tab;
    g_result_table2       pay_balance_pkg.t_detailed_bal_out_tab;

    l_balance_value             NUMBER;
    l_defined_balance_id        NUMBER;
    l_total_value               NUMBER;
    l_prev_gre_value            NUMBER;
    l_action_info_id            NUMBER;
    l_ovn                       NUMBER;

    l_ser_gas_edu_med_perq      NUMBER;
    l_ser_gas_edu_med_proj_perq NUMBER;
    l_travel_perq               NUMBER;
    l_travel_proj_perq          NUMBER;
    l_others_proj               NUMBER;
    i                           NUMBER;
    l_others                    NUMBER;


    l_proc                      VARCHAR2(100);
    l_message                   VARCHAR2(255);

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc := 'pay_in_24q_archive.archive_perquisites';

    --- Step 1: Company Accommodation :Cost and Rent of Furniture
      pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

   if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_run_asg_action_id             : ',p_run_asg_action_id);
      pay_in_utils.trace('p_arc_asg_action_id             : ',p_arc_asg_action_id);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('pre_gre_asg_act_id              : ',pre_gre_asg_act_id);
      pay_in_utils.trace('******************************','********************');
    end if;

    l_defined_balance_id :=pay_in_tax_utils.get_defined_balance('Cost and Rent of Furniture','_ASG_YTD');

    l_total_value := pay_balance_pkg.get_value(p_assignment_action_id => p_run_asg_action_id,
                                               p_defined_balance_id   => l_defined_balance_id);

    if g_debug then
      pay_in_utils.trace('l_total_value              : ',l_total_value);
    end if;

    IF pre_gre_asg_act_id IS NOT NULL THEN
      l_prev_gre_value := pay_balance_pkg.get_value(p_assignment_action_id => pre_gre_asg_act_id,
                                                    p_defined_balance_id   => l_defined_balance_id);
      if g_debug then
        pay_in_utils.trace('l_prev_gre_value              : ',l_prev_gre_value);
      end if;

      l_balance_value := l_total_value - l_prev_gre_value;
    ELSE
      l_balance_value := l_total_value;
    END IF;

   if g_debug then
     pay_in_utils.trace('l_balance_value              : ',l_balance_value);
   end if;

    IF (l_balance_value <> 0)
    THEN
      pay_action_information_api.create_action_information
                    (p_action_context_id              =>     p_arc_asg_action_id
                    ,p_action_context_type            =>     'AAP'
                    ,p_action_information_category    =>    'IN_24Q_PERQ'
                    ,p_source_id                      =>     p_run_asg_action_id
                    ,p_action_information1            =>     'Cost and Rent of Furniture'
                    ,p_action_information2            =>     fnd_number.number_to_canonical(l_balance_value)
                    ,p_action_information_id          =>     l_action_info_id
                    ,p_object_version_number          =>     l_ovn
                    );
    END IF;


    -- Step 2: Company Accommodation :Employee Contribution
    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,20);
    g_context_table.DELETE;
    g_balance_value_tab1.DELETE;
    g_result_table1.DELETE;
    g_context_table(1).source_text2  := 'Company Accommodation';


    get_balances(p_run_asg_action_id   => p_run_asg_action_id
                ,pre_gre_asg_act_id    => pre_gre_asg_act_id
                ,p_balance_name        => 'Perquisite Employee Contribution'
                ,p_balance_dimension   => '_ASG_COMP_YTD'
                ,g_context_table       => g_context_table
                ,g_balance_value_tab   => g_balance_value_tab1
                ,g_result_table        => g_result_table1
                );
    l_defined_balance_id :=pay_in_tax_utils.get_defined_balance('Projected Employee Contribution for Company Accommodation','_ASG_PTD');
    l_balance_value := pay_balance_pkg.get_value(p_assignment_action_id => p_run_asg_action_id,
                                                 p_defined_balance_id   => l_defined_balance_id);


   if g_debug then
     pay_in_utils.trace('balance_value                : ',g_result_table1(1).balance_value);
     pay_in_utils.trace('l_balance_value              : ',l_balance_value);
   end if;

    IF (g_result_table1(1).balance_value <>0 OR l_balance_value <>0 ) THEN
           pay_action_information_api.create_action_information
                   (p_action_context_id              =>     p_arc_asg_action_id
                   ,p_action_context_type            =>     'AAP'
                   ,p_action_information_category    =>    'IN_24Q_PERQ'
                   ,p_source_id                      =>     p_run_asg_action_id
                   ,p_action_information1            =>     'Employee Contribution for Company Accommodation'
                   ,p_action_information2            =>     fnd_number.number_to_canonical(g_result_table1(1).balance_value)
                   ,p_action_information3            =>     fnd_number.number_to_canonical(l_balance_value)
                   ,p_action_information_id          =>     l_action_info_id
                   ,p_object_version_number          =>     l_ovn
                   );
    END IF;

    --Step 3: Furniture Perquiste and  taxable perquisite - Actual
    g_balance_value_tab1.DELETE;
    g_balance_value_tab2.DELETE;
    g_bal_name_tab.DELETE;

    g_result_table1.DELETE;
    g_result_table2.DELETE;

    FOR c_rec IN c_defined_balance_id
    LOOP
      i :=c_rec.indx;
      g_balance_value_tab1(i).defined_balance_id := c_rec.balance_id;
      g_balance_value_tab2(i).defined_balance_id := c_rec.balance_id;
      g_bal_name_tab(i).balance_name := c_rec.balance_name;
    END LOOP;

    pay_balance_pkg.get_value(p_assignment_action_id  => p_run_asg_action_id,
                              p_defined_balance_lst   => g_balance_value_tab1);

    IF pre_gre_asg_act_id IS NOT NULL THEN
      pay_balance_pkg.get_value(p_assignment_action_id  => pre_gre_asg_act_id,
                                p_defined_balance_lst   => g_balance_value_tab2);
      FOR i in 1..3
      LOOP
        g_balance_value_tab1(i).balance_value :=  g_balance_value_tab1(i).balance_value -  g_balance_value_tab2(i).balance_value;
      END LOOP;
    END IF;

    --Step 4: Furniture Perquiste and  taxable perquiste - Projected
     g_balance_value_tab.DELETE;
    FOR c_rec IN c_proj_defined_balance_id
    LOOP
      i :=c_rec.indx;
      g_balance_value_tab(i).defined_balance_id := c_rec.balance_id;
    END LOOP;

    pay_balance_pkg.get_value(p_assignment_action_id => p_run_asg_action_id,
                              p_defined_balance_lst   => g_balance_value_tab);


    if g_debug then
      pay_in_utils.trace('balance_name                 : ',g_bal_name_tab(i).balance_name);
      pay_in_utils.trace('tabl_balance_value           : ',g_balance_value_tab1(i).balance_value);
      pay_in_utils.trace('tab_balance_value            : ',g_balance_value_tab(i).balance_value);
    end if;

    FOR i IN 1..2
    LOOP
      IF ((   g_balance_value_tab1(i).balance_value <> 0)
           OR(g_balance_value_tab(i).balance_value <> 0)
         )
      THEN
        pay_action_information_api.create_action_information
                   (p_action_context_id              =>     p_arc_asg_action_id
                   ,p_action_context_type            =>     'AAP'
                   ,p_action_information_category    =>    'IN_24Q_PERQ'
                   ,p_source_id                      =>     p_run_asg_action_id
                   ,p_action_information1            =>     g_bal_name_tab(i).balance_name
                   ,p_action_information2            =>     fnd_number.number_to_canonical(g_balance_value_tab1(i).balance_value)
                   ,p_action_information3            =>     fnd_number.number_to_canonical(g_balance_value_tab(i).balance_value)
                   ,p_action_information_id          =>     l_action_info_id
                   ,p_object_version_number          =>     l_ovn
                   );
      END IF;
    END LOOP;

    l_others := g_balance_value_tab1(3).balance_value ;
    l_others_proj := g_balance_value_tab(3).balance_value ;

    pay_in_utils.set_location(g_debug,'Furniture and Total Perquisites '||l_proc,40);

   -- Step 5 - Get individual perquisite values
    g_balance_value_tab.DELETE;
    g_context_table.DELETE;
    g_result_table1.delete;
    g_result_table2.DELETE;

    g_context_table(1).source_text2  := 'Company Accommodation';
    g_context_table(2).source_text2  := 'Motor Car Perquisite';
    g_context_table(3).source_text2  := 'Leave Travel Concession';
    g_context_table(4).source_text2  := 'Free Transport';
    g_context_table(5).source_text2  := 'Travel / Tour / Accommodation';
    g_context_table(6).source_text2  := 'Domestic Servant'; --
    g_context_table(7).source_text2  := 'Gas / Water / Electricity'; --
    g_context_table(8).source_text2  := 'Free Education';--
    g_context_table(9).source_text2  := 'Medical';--

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,50);

    get_balances(p_run_asg_action_id   => p_run_asg_action_id
                ,pre_gre_asg_act_id    => pre_gre_asg_act_id
                ,p_balance_name        => 'Taxable Perquisites'
                ,p_balance_dimension   => '_ASG_COMP_YTD'
                ,g_context_table       => g_context_table
                ,g_balance_value_tab   => g_balance_value_tab
                ,g_result_table        => g_result_table1
                );
    get_balances(p_run_asg_action_id   => p_run_asg_action_id
                ,pre_gre_asg_act_id    => NULL
                ,p_balance_name        => 'Taxable Perquisites for Projection'
                ,p_balance_dimension   => '_ASG_COMP_PTD'
                ,g_context_table      => g_context_table
                ,g_balance_value_tab  => g_balance_value_tab
                ,g_result_table        => g_result_table2
                );

    l_travel_perq := 0;
    l_travel_proj_perq := 0;

    l_ser_gas_edu_med_perq := 0;
    l_ser_gas_edu_med_proj_perq := 0;

    FOR i IN 3..5 LOOP
      l_travel_perq := l_travel_perq + g_result_table1(i).balance_value ;
      l_travel_proj_perq := l_travel_proj_perq + g_result_table2(i).balance_value ;
    END LOOP ;

    pay_in_utils.set_location(g_debug,l_proc,55);
    g_context_table(3).source_text2 :=  'Leave Travel Concession';
    g_result_table1(3).balance_value := l_travel_perq;
    g_result_table2(3).balance_value := l_travel_proj_perq;

 -- Step 6: Grp under company acco., LTC, Domestic and Personal Services Perquisite and remaining perq.
    FOR i in 6..9 LOOP
      l_ser_gas_edu_med_perq := l_ser_gas_edu_med_perq + g_result_table1(i).balance_value ;
      l_ser_gas_edu_med_proj_perq := l_ser_gas_edu_med_proj_perq + g_result_table2(i).balance_value ;
    END LOOP;

    pay_in_utils.set_location(g_debug,l_proc,60);
    g_context_table(4).source_text2 :=  'Domestic and Personal Services Perquisite';
    g_result_table1(4).balance_value := l_ser_gas_edu_med_perq;
    g_result_table2(4).balance_value := l_ser_gas_edu_med_proj_perq;

    FOR i in 1..4 LOOP
      l_others := l_others - g_result_table1(i).balance_value ;
      l_others_proj := l_others_proj - g_result_table2(i).balance_value ;
    END LOOP;

    pay_in_utils.set_location(g_debug,l_proc,70);

    g_context_table(5).source_text2 :=  'Other Perquisites';
    g_result_table1(5).balance_value := l_others;
    g_result_table2(5).balance_value := l_others_proj;

    pay_in_utils.set_location(g_debug,l_proc,80);

   if g_debug then
      pay_in_utils.trace('source_text2                   : ',g_context_table(i).source_text2);
      pay_in_utils.trace('tablel_balance_value           : ',g_result_table1(i).balance_value);
      pay_in_utils.trace('table2_balance_value           : ',g_result_table2(i).balance_value);
   end if;

    FOR i IN 1..5
    LOOP
        IF ((g_result_table1(i).balance_value <> 0)
            OR(g_result_table2(i).balance_value <> 0)
           )
        THEN
          pay_action_information_api.create_action_information
                   (p_action_context_id              =>     p_arc_asg_action_id
                   ,p_action_context_type            =>     'AAP'
                   ,p_action_information_category    =>    'IN_24Q_PERQ'
                   ,p_source_id                      =>     p_run_asg_action_id
                   ,p_action_information1            =>     g_context_table(i).source_text2
                   ,p_action_information2            =>     fnd_number.number_to_canonical(g_result_table1(i).balance_value)
                   ,p_action_information3            =>     fnd_number.number_to_canonical(g_result_table2(i).balance_value)
                   ,p_action_information_id          =>     l_action_info_id
                   ,p_object_version_number          =>     l_ovn
                   );
        END IF;
    END LOOP;

  -- Step 7 - Delete PL/SQL Tables
    pay_in_utils.set_location(g_debug,'Deleting PL/SQL tables in : '||l_proc,90);
    g_balance_value_tab.DELETE;
    g_balance_value_tab1.DELETE;
    g_balance_value_tab2.DELETE;
    g_bal_name_tab.DELETE;
    g_context_table.DELETE;
    g_result_table.DELETE;
    g_result_table1.DELETE;
    g_result_table2.DELETE;

  END archive_perquisites;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : archive_challan_asg                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the challan details for     --
  --                  each assignment giving the tax,surcharge and cess   --
  --                  details                                             --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id    NUMBER                       --
  --                  p_person_id            NUMBER                       --
    --                p_assignment_id        NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --                  p_effective_date       DATE                          --
  --         IN/ OUT : p_person_table        t_person_data_tab_type       --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj   Initial Version                      --
  -- 115.1 25-Sep-2007    rsaharay   Modified cursors c_pos               --
  --------------------------------------------------------------------------
  PROCEDURE archive_challan_asg(p_arc_asg_action_id   IN NUMBER
                               ,p_person_id           IN NUMBER
                               ,p_assignment_id       IN NUMBER
                               ,p_gre_id              IN NUMBER
                               ,p_effective_date      IN DATE
                               ,p_person_table        IN OUT NOCOPY t_person_data_tab_type
                               )
  IS
    CURSOR csr_challan_asg
    IS
    SELECT pee.element_entry_id
      FROM pay_element_entries_f pee
     WHERE pee.element_type_id = g_chln_element_id
       AND pee.effective_start_date <= g_fin_end_date
       AND pee.effective_end_date >= g_fin_start_date
       AND pee.assignment_id = p_assignment_id
       AND EXISTS (SELECT ''
                     FROM pay_element_entry_values_f peev
                         ,hr_organization_information hoi
                    WHERE peev.input_value_id = g_input_table_rec(1).input_value_id
                      AND peev.element_entry_id = pee.element_entry_id
                      AND peev.screen_entry_value LIKE '% - '|| hoi.org_information3|| ' - %'||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR')
                      AND hoi.organization_id = p_gre_id
                      AND hoi.org_information1 = g_tax_year
                      AND hoi.org_information13 = g_quarter
                      AND hoi.org_information_context ='PER_IN_IT_CHALLAN_INFO'
                      AND peev.effective_start_date <= g_fin_end_date
                      AND peev.effective_end_date >= g_fin_start_date
                      AND ROWNUM =1);

    CURSOR csr_person_data (p_person_id NUMBER)
    IS
    SELECT asg.person_id         person_id
          ,DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4) pan
          ,pep.per_information14 pan_ref_num
          ,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) name
    FROM   per_assignments_f  asg
          ,per_people_f       pep
    WHERE  asg.assignment_id = p_assignment_id
      AND  pep.person_id  = asg.person_id
      AND  pep.business_group_id = g_bg_id
      AND  asg.business_group_id = g_bg_id
      AND  p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND  p_effective_date BETWEEN pep.effective_start_date AND pep.effective_end_date ;

    CURSOR c_pos
    IS
    SELECT nvl(pos.name,job.name) name
    FROM   per_all_positions pos
          ,per_assignments_f asg
	  ,per_jobs          job
    WHERE  asg.position_id=pos.position_id(+)
    AND    asg.job_id=job.job_id(+)
    AND    asg.assignment_id = p_assignment_id
    AND    asg.business_group_id = g_bg_id
    AND    p_effective_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
    AND    p_effective_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
    AND    p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


    CURSOR c_aei_tax_rate(p_person_id  NUMBER)
    IS
    SELECT  paei.aei_information2
      FROM  per_assignment_extra_info paei
           ,per_assignments_f paa
     WHERE  paei.information_type = 'PER_IN_TAX_EXEMPTION_DF'
       AND  paei.aei_information_category = 'PER_IN_TAX_EXEMPTION_DF'
       AND  paei.assignment_id = paa.assignment_id
       AND  paa.person_id = p_person_id
       AND  paei.aei_information1 = g_tax_year
       AND  p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
       AND  ROWNUM = 1;



    CURSOR csr_get_element_entry_value(p_element_entry_id NUMBER)
    IS
    SELECT peev.screen_entry_value entry_value
          ,piv.display_sequence    indx
      FROM pay_element_entry_values_f peev
          ,pay_input_values_f piv
     WHERE peev.element_entry_id = p_element_entry_id
       AND peev.input_value_id IN(g_input_table_rec(1).input_value_id
                                 ,g_input_table_rec(2).input_value_id
                                 ,g_input_table_rec(3).input_value_id
                                 ,g_input_table_rec(4).input_value_id
                                 ,g_input_table_rec(5).input_value_id
                                 ,g_input_table_rec(6).input_value_id
                                 ,g_input_table_rec(7).input_value_id)
       AND peev.input_value_id = piv.input_value_id
       AND g_fin_end_date BETWEEN piv.effective_start_date AND piv.effective_end_date;



    t_person_tab t_person_data_tab_type;

   TYPE t_challan_entry_asg_rec IS RECORD
      (element_entry_id pay_element_entries_f.element_entry_id%TYPE);

    TYPE t_challan_entry_asg_tab_type is table of  t_challan_entry_asg_rec index by binary_integer;
    t_challan_entry_asg_tab t_challan_entry_asg_tab_type;

     TYPE t_entry_values_rec IS RECORD
      (screen_entry_value pay_element_entry_values_f.screen_entry_value%TYPE);

    TYPE t_entry_values_tab_type is table of  t_entry_values_rec index by binary_integer;
    t_entry_values_tab t_entry_values_tab_type;

    l_action_info_id NUMBER;
    l_ovn            NUMBER;
    l_cnt            NUMBER;
    i                NUMBER;
    l_person_id      NUMBER;
    l_full_name      per_all_people_f.full_name%TYPE;

    l_pan            per_all_people_f.per_information14%TYPE;
    l_pan_ref_num    per_all_people_f.per_information14%TYPE;
    l_tax_rate       per_assignment_extra_info.aei_information2 %TYPE;
    l_pos            per_all_positions.name%TYPE;
    l_proc           VARCHAR2(100);
    l_message        VARCHAR2(255);


  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc := g_package||'archive_challan_asg';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_arc_asg_action_id             : ',p_arc_asg_action_id);
      pay_in_utils.trace('p_person_id                     : ',p_person_id);
      pay_in_utils.trace('p_assignment_id                 : ',p_assignment_id);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('p_effective_date                : ',p_effective_date);
      pay_in_utils.trace('******************************','********************');
    end if;

    t_challan_entry_asg_tab.DELETE;

    -- Gets element entries for this assignment for all challans in this GRE in the given assessment year-quarter


    OPEN csr_challan_asg;
    FETCH csr_challan_asg BULK COLLECT INTO t_challan_entry_asg_tab;
    CLOSE csr_challan_asg;

    l_cnt := t_challan_entry_asg_tab.COUNT;

    IF l_cnt >0 THEN
      IF p_person_table.EXISTS(1) THEN
       NULL;
      ELSE
        OPEN csr_person_data(p_person_id);
        FETCH csr_person_data INTO l_person_id,l_pan, l_pan_ref_num, l_full_name;
        CLOSE csr_person_data;

        OPEN  c_pos;
        FETCH c_pos INTO l_pos;
        CLOSE c_pos;

        OPEN c_aei_tax_rate(l_person_id);
        FETCH c_aei_tax_rate INTO l_tax_rate;
        CLOSE c_aei_tax_rate;

        p_person_table(1).person_id       := l_person_id;
        p_person_table(1).pan_number      := l_pan;
        p_person_table(1).pan_ref_number  := l_pan_ref_num;
        p_person_table(1).full_name       := l_full_name;
        p_person_table(1).tax_rate        := l_tax_rate;
        p_person_table(1).position        := l_pos;
       END IF;


    --
      FOR i in t_challan_entry_asg_tab.FIRST .. t_challan_entry_asg_tab.LAST
      LOOP
        IF t_challan_entry_asg_tab.EXISTS(i) THEN
          FOR j in csr_get_element_entry_value(t_challan_entry_asg_tab(i).element_entry_id) LOOP
            t_entry_values_tab(j.indx).screen_entry_value := j.entry_value;
          END LOOP;

         if g_debug then
           pay_in_utils.trace('element_entry_id               : ',t_challan_entry_asg_tab(i).element_entry_id);
           pay_in_utils.trace('screen_entry_value1            : ',t_entry_values_tab(1).screen_entry_value);
           pay_in_utils.trace('person_id                      : ',p_person_table(1).person_id);
           pay_in_utils.trace('screen_entry_value2            : ',t_entry_values_tab(2).screen_entry_value);
           pay_in_utils.trace('screen_entry_value3            : ',t_entry_values_tab(3).screen_entry_value);
           pay_in_utils.trace('screen_entry_value4            : ',t_entry_values_tab(4).screen_entry_value);
           pay_in_utils.trace('screen_entry_value5            : ',t_entry_values_tab(5).screen_entry_value);
           pay_in_utils.trace('screen_entry_value6            : ',t_entry_values_tab(6).screen_entry_value);
           pay_in_utils.trace('screen_entry_value7            : ',t_entry_values_tab(7).screen_entry_value);
           pay_in_utils.trace('screen_entry_value1            : ',t_entry_values_tab(1).screen_entry_value);
           pay_in_utils.trace('pan_number                     : ',p_person_table(1).pan_number);
           pay_in_utils.trace('pan_ref_number                 : ',p_person_table(1).pan_ref_number);
           pay_in_utils.trace('full_name                      : ',p_person_table(1).full_name);
           pay_in_utils.trace('tax_rate                       : ',p_person_table(1).tax_rate);
         end if;

          pay_action_information_api.create_action_information
                   (p_action_context_id              =>     p_arc_asg_action_id
                   ,p_action_context_type            =>     'AAP'
                   ,p_action_information_category    =>     'IN_24Q_DEDUCTEE'
                   ,p_assignment_id                  =>     p_assignment_id
                   ,p_source_id                      =>     t_challan_entry_asg_tab(i).element_entry_id
                   ,p_action_information1            =>     t_entry_values_tab(1).screen_entry_value
                   ,p_action_information2            =>     p_person_table(1).person_id
                   ,p_action_information3            =>     p_gre_id
                   ,p_action_information4            =>     t_entry_values_tab(2).screen_entry_value
                   ,p_action_information5            =>     t_entry_values_tab(3).screen_entry_value
                   ,p_action_information6            =>     t_entry_values_tab(4).screen_entry_value
                   ,p_action_information7            =>     t_entry_values_tab(5).screen_entry_value
                   ,p_action_information8            =>     t_entry_values_tab(6).screen_entry_value
                   ,p_action_information9            =>     t_entry_values_tab(7).screen_entry_value
                   ,p_action_information10           =>     p_person_table(1).pan_number
                   ,p_action_information11           =>     p_person_table(1).pan_ref_number
                   ,p_action_information12           =>     p_person_table(1).full_name
                   ,p_action_information13           =>     p_person_table(1).tax_rate
                   ,p_action_information_id          =>     l_action_info_id
                   ,p_object_version_number          =>     l_ovn
                   );
        END IF;

      END LOOP;
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,20);

  END archive_challan_asg;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CODE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to call the internal procedures to        --
  --                  actually archive the data.                          --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id       NUMBER                 --
  --                  p_effective_date             DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Jan-2006    lnagaraj   Initial Version                      --
  -- 115.1 26-Jun-2006    aaagarwa   Modifed get_eoy_archival_details     --
  --------------------------------------------------------------------------
  PROCEDURE archive_code ( p_assignment_action_id  IN NUMBER
                          ,p_effective_date        IN DATE
                         )
  IS
    CURSOR get_assignment_pact_id
    IS
    SELECT paa.assignment_id
          ,paa.payroll_action_id
          ,paf.person_id
      FROM pay_assignment_actions  paa
          ,per_all_assignments_f paf
     WHERE paa.assignment_action_id = p_assignment_action_id
       AND paa.assignment_id = paf.assignment_id
       AND ROWNUM =1;

     CURSOR c_get_distinct_gre(p_assignment_id NUMBER)
    IS
     SELECT DISTINCT(hscl.segment1) gre
      FROM per_all_assignments_f paf
          ,hr_soft_coding_keyflex hscl
     WHERE hscl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
       AND paf.assignment_id =paf.assignment_id
       AND paf.assignment_id = p_assignment_id
        AND  ( paf.effective_start_date BETWEEN g_fin_start_date  AND g_end_date
          OR  g_fin_start_date BETWEEN paf.effective_start_date  AND paf.effective_end_date
              )
       AND hscl.segment1 LIKE g_gre_id;

    CURSOR c_gre_records
    IS
    SELECT  GREATEST(asg.effective_start_date,g_fin_start_date) start_date
           ,LEAST(asg.effective_end_date,g_fin_end_date)        end_date
           ,scl.segment1
      FROM  per_assignments_f  asg
           ,hr_soft_coding_keyflex scl
           ,pay_assignment_actions paa
     WHERE  asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
       AND  paa.assignment_action_id = p_assignment_action_id
       AND  asg.assignment_id = paa.assignment_id
       AND  scl.segment1 LIKE g_gre_id
       AND  ( asg.effective_start_date BETWEEN g_fin_start_date  AND g_end_date
          OR  g_fin_start_date BETWEEN asg.effective_start_date  AND asg.effective_end_date
              )
       AND  asg.business_group_id = g_bg_id
    ORDER BY 1 ;

    CURSOR csr_payroll_id(p_assignment_id NUMBER,p_date DATE)
    IS
    SELECT paf.payroll_id
      FROM per_all_assignments_f paf
     WHERE paf.assignment_id =p_assignment_id
       AND p_date BETWEEN paf.effective_start_date AND paf.effective_end_date;

    CURSOR get_eoy_archival_details(p_start_date        DATE
                                   ,p_end_date         DATE
                                   ,p_tax_unit_id      NUMBER
                                   ,p_assignment_id    NUMBER
                                   )
    IS
    SELECT TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) run_asg_action_id
      FROM pay_assignment_actions paa
          ,pay_payroll_actions ppa
          ,per_assignments_f paf
     WHERE paf.assignment_id = paa.assignment_id
       AND paf.assignment_id = p_assignment_id
       AND paa.tax_unit_id  = p_tax_unit_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND ppa.action_type IN('R','Q','I','B')
       AND ppa.payroll_id    = paf.payroll_id
       AND ppa.action_status ='C'
       AND ppa.effective_date between p_start_date and p_end_date
       AND paa.source_action_id IS NULL
       AND (1 = DECODE(ppa.action_type,'I',1,0)
            OR EXISTS (SELECT ''
                     FROM pay_action_interlocks intk,
                          pay_assignment_actions paa1,
                          pay_payroll_actions ppa1
                    WHERE intk.locked_action_id = paa.assignment_Action_id
                      AND intk.locking_action_id =  paa1.assignment_action_id
                      AND paa1.payroll_action_id =ppa1.payroll_action_id
                      AND paa1.assignment_id = p_assignment_id
                      AND ppa1.action_type in('P','U')
                      AND ppa.action_type in('R','Q','B')
                      AND ppa1.action_status ='C'
                      AND ppa1.effective_date BETWEEN p_start_date and p_end_date
                      AND ROWNUM =1 ));

    CURSOR c_get_date_earned(l_run_assact NUMBER)
    IS
    SELECT ppa.date_earned run_date
          ,ppa.payroll_id
      FROM pay_payroll_actions ppa,
           pay_assignment_actions paa
     WHERE paa.payroll_action_id = ppa.payroll_action_id
       AND paa.assignment_action_id = l_run_assact;

    CURSOR c_pay_action_level_check(p_payroll_action_id    NUMBER
                                   ,p_gre_id               NUMBER)
    IS
    SELECT 1
      FROM  pay_action_information pai,
            pay_assignment_actions paa
     WHERE  pai.action_information_category = 'IN_24Q_ORG'
       AND  pai.action_context_type         = 'PA'
       AND  pai.action_context_id           = p_payroll_action_id
       AND  pai.action_information1         = p_gre_id
       AND ROWNUM =1;

    CURSOR c_termination_check(p_assignment_id NUMBER)
    IS
    SELECT NVL(pos.actual_termination_date,(fnd_date.string_to_date('31-12-4712','DD-MM-YYYY')))
      FROM   per_all_assignments_f  asg
            ,per_periods_of_service pos
     WHERE asg.person_id         = pos.person_id
       AND asg.assignment_id     = p_assignment_id
       AND asg.business_group_id = pos.business_group_id
       AND asg.business_group_id = g_bg_id
       AND NVL(pos.actual_termination_date,(to_date('31-12-4712','DD-MM-YYYY')))
             BETWEEN asg.effective_start_date AND asg.effective_end_date
     ORDER BY 1 DESC;


    l_proc VARCHAR2(100);
    l_message     VARCHAR2(255);
    l_assignment_id                   NUMBER;
    l_run_asg_action_id               NUMBER;
    l_person_id                       NUMBER;
    l_run_pay_action_id               NUMBER;
    l_run_effective_date              DATE;
    l_run_date_earned                 VARCHAR2(30);
    l_pre_asg_action_id               NUMBER;
    l_source_id                       NUMBER;
    l_arc_pay_action_id               NUMBER;
    l_check                           NUMBER;
    l_previous_gre_asg_action_id      NUMBER;
    l_count                           NUMBER;
    l_periods                         NUMBER;
    l_payroll_id                      NUMBER;
    l_total_pay_period                NUMBER;
    l_current_pay_period              NUMBER;
    p_rem_pay_period                  NUMBER;
    p_arc_asg_action_id               NUMBER;
    l_actual_term_date                DATE;
    p_person_data                     t_person_data_tab_type;


  BEGIN


    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'archive_code';
    pay_in_utils.set_location(g_debug,'Entering : '||l_proc||p_assignment_action_id,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_assignment_action_id          : ',p_assignment_action_id);
      pay_in_utils.trace('p_effective_date                : ',p_effective_date);
      pay_in_utils.trace('******************************','********************');
    end if;

    --
      l_count := 1;
      g_asg_tab.DELETE;
      p_person_data.DELETE;
    --
    OPEN  get_assignment_pact_id;
    FETCH get_assignment_pact_id INTO l_assignment_id ,l_arc_pay_action_id,l_person_id;
    CLOSE get_assignment_pact_id;

    OPEN  c_termination_check(l_assignment_id);
    FETCH c_termination_check INTO l_actual_term_date;
    CLOSE c_termination_check;

    if g_debug then
       pay_in_utils.trace('l_assignment_id          : ',l_assignment_id);
       pay_in_utils.trace('l_arc_pay_action_id      : ',l_arc_pay_action_id);
       pay_in_utils.trace('l_person_id              : ',l_person_id);
       pay_in_utils.trace('l_actual_term_date       : ',l_actual_term_date);
    end if;

    pay_in_utils.set_location(g_debug,'Entering : '||l_assignment_id,11);
    FOR c_gre_rec IN  c_get_distinct_gre(l_assignment_id)
    LOOP
       if g_debug then
         pay_in_utils.trace('c_gre_rec.gre            : ',c_gre_rec.gre);
         pay_in_utils.trace('g_session_date           : ',g_session_date);
        end if;

      archive_challan_asg(  p_arc_asg_action_id  => p_assignment_action_id
                           ,p_person_id          => l_person_id
                           ,p_assignment_id      => l_assignment_id
                           ,p_gre_id             => c_gre_rec.gre
                           ,p_effective_date     => LEAST(g_session_date,l_actual_term_date)
                           ,p_person_table       => p_person_data
                           );
    END LOOP;

 -- Get all records from financial year start till current quarter end to find out
 -- previous GRE assignment_action_id and remaining pay periods
    pay_in_utils.set_location(g_debug,'Entering : '||l_assignment_id,12);
    FOR c_rec IN c_gre_records
    LOOP
        IF ((l_count <>1)
              AND
            (g_asg_tab(l_count-1).gre_id =  c_rec.segment1)
             AND
            (g_asg_tab(l_count-1).end_date + 1 = c_rec.start_date)
          )
        THEN
           g_asg_tab(l_count-1).end_date     := c_rec.end_date;
           l_count := l_count -1;
        ELSE
           g_asg_tab(l_count).gre_id       := c_rec.segment1;
           g_asg_tab(l_count).start_date   := c_rec.start_date;
           g_asg_tab(l_count).end_date     := c_rec.end_date;
        END IF;
        l_count := l_count + 1;
    END LOOP;

    pay_in_utils.set_location(g_debug,'l_count : '||l_count,20);

/* g_asg_tab.start/end date will contain the actual start/end of asg in a GRE or the the financial year  .
   We need to change it to quarter date*/

    FOR i IN 1..l_count-1
    LOOP
    --Archive only if it is a candidate for reporting in the specified quarter
      IF (g_start_date <=  g_asg_tab(i).end_date AND
          g_end_date   >=  g_asg_tab(i).start_date) THEN
         pay_in_utils.set_location(g_debug,'l_assignment_id : '||l_assignment_id||' ' ||g_asg_tab(i).start_date||' ' ||g_asg_tab(i).end_date||' ' ||g_asg_tab(i).gre_id,30);

        -- Get assignment action id corresponding to the maximum action sequence record
         OPEN  get_eoy_archival_details(GREATEST(g_asg_tab(i).start_date,g_start_date)
                                       ,LEAST(g_asg_tab(i).end_date,g_end_date)
                                       ,g_asg_tab(i).gre_id
                                       ,l_assignment_id
                                       );
         FETCH get_eoy_archival_details INTO l_run_asg_action_id;
         CLOSE get_eoy_archival_details;

         IF l_run_asg_action_id IS NOT NULL THEN
           OPEN c_get_date_earned(l_run_asg_action_id);
           FETCH c_get_date_earned INTO l_run_date_earned,l_payroll_id;
           CLOSE c_get_date_earned;

           -- Get remaining pay periods
           OPEN csr_payroll_id(l_assignment_id,l_run_date_earned);
           FETCH csr_payroll_id INTO l_payroll_id;
           CLOSE csr_payroll_id;

           l_total_pay_period   := pay_in_tax_utils.get_period_number(l_payroll_id,LEAST(l_actual_term_date,g_asg_tab(i).end_date));
           l_current_pay_period := pay_in_tax_utils.get_period_number(l_payroll_id,l_run_date_earned);
           p_rem_pay_period     := GREATEST((l_total_pay_period - l_current_pay_period),0);

           -- Get Previous GRE's max assignment action id
           l_previous_gre_asg_action_id := NULL;
           IF (i > 1)
           THEN
             FOR c_rec IN get_eoy_archival_details(g_asg_tab(i-1).start_date,g_asg_tab(i-1).end_date,g_asg_tab(i-1).gre_id,l_assignment_id)
             LOOP
              l_previous_gre_asg_action_id := c_rec.run_asg_action_id;
             EXIT;
             END LOOP;
           END IF;

           -- Person Data as on actual termination date/session date
           -- Find p_person_data in archive_challan_asg
           -- archive_person_data uses p_person_data if available,else it would fetch the values .
           archive_person_data(p_run_asg_action_id    => l_run_asg_action_id
                              ,p_arc_asg_action_id    => p_assignment_action_id
                              ,p_assignment_id        => l_assignment_id
                              ,p_gre_id               => g_asg_tab(i).gre_id
                              ,p_effective_start_date => g_asg_tab(i).start_date
                              ,p_effective_end_date   => g_asg_tab(i).end_date
                              ,p_effective_date       => LEAST(l_actual_term_date,g_session_date)
                              ,p_termination_date     => l_actual_term_date
                              ,p_person_table         => p_person_data);

           archive_via_details(p_run_asg_action_id     => l_run_asg_action_id
                              ,p_arc_asg_action_id     => p_assignment_action_id
                              ,p_gre_id                => g_asg_tab(i).gre_id
                              ,p_assignment_id         => l_assignment_id
                              );

           archive_asg_salary(p_run_asg_action_id     => l_run_asg_action_id
                             ,p_arc_asg_action_id     => p_assignment_action_id
                             ,p_balance_periods       => p_rem_pay_period
                             ,p_gre_id                => g_asg_tab(i).gre_id
                             ,pre_gre_asg_act_id      => l_previous_gre_asg_action_id
                             );

           archive_perquisites(p_run_asg_action_id     => l_run_asg_action_id
                              ,p_arc_asg_action_id     => p_assignment_action_id
                              ,p_gre_id                => g_asg_tab(i).gre_id
                              ,pre_gre_asg_act_id      => l_previous_gre_asg_action_id
                              );

           OPEN  c_pay_action_level_check(l_arc_pay_action_id,g_asg_tab(i).gre_id);
           FETCH c_pay_action_level_check INTO l_check;
           CLOSE c_pay_action_level_check;

           IF l_check IS NULL
           THEN
               archive_challan_data(p_arc_pay_action_id      => l_arc_pay_action_id
                                   ,p_gre_id                 => g_asg_tab(i).gre_id
                                    );

               archive_org_data(p_arc_pay_action_id      => l_arc_pay_action_id
                               ,p_gre_id                 => g_asg_tab(i).gre_id
                               ,p_effective_date         => g_session_date
                               );

           END IF;
         END IF; -- RUN Assact is not null
      END IF; -- End of Archive
    END LOOP;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,40);

  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 50);
       pay_in_utils.trace(l_message,l_proc);
       RAISE;
  END archive_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : DEINITIALIZATION_CODE                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to update the sorting index  --
  --                  for deductee records                                --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 05-Mar-2006    abhjain   Initial Version                       --
  -- 115.1 07-Feb-2007    rpalli    Modified to archive salary details    --
  --                                seq number                            --
  --------------------------------------------------------------------------
PROCEDURE deinitialization_code (p_payroll_action_id IN NUMBER)
IS

l_index NUMBER;
l_proc  VARCHAR2(100) ;
l_message     VARCHAR2(255);

 CURSOR cur_challan_recs
  IS
SELECT DISTINCT action_information1 challan_no
      ,action_information3          gre_id
  FROM pay_action_information
 WHERE action_information_category = 'IN_24Q_DEDUCTEE'
   AND action_context_type         = 'AAP'
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id)
   ORDER BY action_information3;


 CURSOR cur_deductee_recs(p_challan VARCHAR2, p_gre_id VARCHAR2)
  IS
SELECT DISTINCT action_information2
     , action_information4
     , action_information_id
     , object_version_number
  FROM pay_action_information
 WHERE action_information_category = 'IN_24Q_DEDUCTEE'
   AND action_context_type         = 'AAP'
   AND action_information3 = p_gre_id
   AND action_information1 = p_challan
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id)
   ORDER BY action_information2
          , action_information4;


 CURSOR cur_salary_recs
  IS
SELECT DISTINCT action_information3          gre_id
  FROM pay_action_information
 WHERE action_information_category = 'IN_24Q_PERSON'
   AND action_context_type         = 'AAP'
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id)
   ORDER BY action_information3;


 CURSOR cur_person_recs( p_gre_id VARCHAR2)
  IS
SELECT DISTINCT action_information1 person_id
     , source_id
     , action_information_id
     , object_version_number
  FROM pay_action_information
 WHERE action_information_category = 'IN_24Q_PERSON'
   AND action_context_type         = 'AAP'
   AND action_information3 = p_gre_id
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id)
   ORDER BY  LENGTH(action_information1)
            ,action_information1
            ,source_id;

BEGIN

  g_debug :=  hr_utility.debug_enabled;
  l_proc  :=  g_package || 'deinitialization_code';

  pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

  FOR c_challan_rec IN cur_challan_recs
  LOOP
    l_index := 0;
    FOR cur_rec IN cur_deductee_recs(c_challan_rec.challan_no ,c_challan_rec.gre_id)
    LOOP
             l_index := l_index + 1;
             pay_action_information_api.update_action_information
              (p_validate                       => FALSE
              ,p_action_information_id          => cur_rec.action_information_id
              ,p_object_version_number          => cur_rec.object_version_number
              ,p_action_information25           => l_index
              );
          END LOOP;
  END LOOP;

  pay_in_utils.set_location(g_debug,'Entering : '||l_proc,20);

  FOR c_salary_rec IN cur_salary_recs
  LOOP
    l_index := 0;
    FOR cur_rec IN cur_person_recs(c_salary_rec.gre_id)
    LOOP
             l_index := l_index + 1;
             pay_action_information_api.update_action_information
              (p_validate                       => FALSE
              ,p_action_information_id          => cur_rec.action_information_id
              ,p_object_version_number          => cur_rec.object_version_number
              ,p_action_information11           => l_index
              );
          END LOOP;
  END LOOP;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,50);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc,70);
      pay_in_utils.trace(l_message,l_proc);
      RAISE;
END deinitialization_code;

  END pay_in_24q_archive;

/
