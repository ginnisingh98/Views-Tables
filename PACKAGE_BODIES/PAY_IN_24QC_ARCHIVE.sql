--------------------------------------------------------
--  DDL for Package Body PAY_IN_24QC_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_24QC_ARCHIVE" AS
/* $Header: pyin24qc.pkb 120.11.12010000.6 2009/11/09 07:05:25 mdubasi ship $ */

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : TRACE_PL_SQL_TABLE_DATA                             --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure is used to display PL/SQL table      --
  --                  data depending on value of BOOLEAN g_debug          --
  -- Parameters     :                                                     --
  --             IN : N/A                                                 --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE trace_pl_sql_table_data
  IS
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
  BEGIN

      g_debug     := hr_utility.debug_enabled;
      l_procedure := g_package || '.trace_pl_sql_table_data ';
      pay_in_utils.set_location(g_debug,'Entering: '|| l_procedure,10);

      pay_in_utils.set_location(g_debug,'************************************************************ ',3);
      pay_in_utils.set_location(g_debug,'Displaying Data for Salary Records ',2);
      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON Starts........ ',3);
      pay_in_utils.set_location(g_debug,'Number of assignment actions deleted : '|| g_count_sal_delete ,4);
      FOR i IN 1..g_count_sal_delete -1
      LOOP
         pay_in_utils.trace('Last Action Context ID is : ', g_sal_data_rec_del(i).last_action_context_id );
         pay_in_utils.trace('Assignment ID is          : ', g_sal_data_rec_del(i).assignment_id          );
         pay_in_utils.trace('Source ID is       : ', g_sal_data_rec_del(i).source_id       );
         pay_in_utils.trace('Salary Mode is          : ', g_sal_data_rec_del(i).salary_mode          );
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON for deletion Ends........ ',5);
      pay_in_utils.set_location(g_debug,'========================================== ',6);

      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON for Addition Starts........ ',7);
      pay_in_utils.trace('Number of assignment actions added : ', g_count_sal_addition );
      FOR i IN 1..g_count_sal_addition -1
      LOOP
         pay_in_utils.trace('Last Action Context ID is : ', g_sal_data_rec_add(i).last_action_context_id );
         pay_in_utils.trace('Assignment ID is          : ', g_sal_data_rec_add(i).assignment_id          );
         pay_in_utils.trace('Source ID is       : ', g_sal_data_rec_add(i).source_id       );
         pay_in_utils.trace('Salary Mode is          : ', g_sal_data_rec_add(i).salary_mode          );
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON for addition Ends........ ',9);

      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON for addition Ends........ ',5);
      pay_in_utils.set_location(g_debug,'========================================== ',6);

      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON for Updation Starts........ ',7);
      pay_in_utils.trace('Number of assignment actions updated : ', g_count_sal_update );
      FOR i IN 1..g_count_sal_update -1
      LOOP
         pay_in_utils.trace('Last Action Context ID is : ', g_sal_data_rec_upd(i).last_action_context_id );
         pay_in_utils.trace('Assignment ID is          : ', g_sal_data_rec_upd(i).assignment_id          );
         pay_in_utils.trace('Source ID is       : ', g_sal_data_rec_upd(i).source_id       );
         pay_in_utils.trace('Salary Mode is          : ', g_sal_data_rec_upd(i).salary_mode          );
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_PERSON for updation Ends........ ',9);
      pay_in_utils.set_location(g_debug,'Data for Salary Records Ends ',2);
      pay_in_utils.set_location(g_debug,'************************************************************ ',3);


      pay_in_utils.set_location(g_debug,'************************************************************ ',3);
      pay_in_utils.set_location(g_debug,'Displaying Data for Deductee Records ',2);
      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE Starts........ ',3);
      pay_in_utils.set_location(g_debug,'Number of element entries deleted : '|| g_count_ee_delete ,4);
      FOR i IN 1..g_count_ee_delete -1
      LOOP
         pay_in_utils.trace('Last Action Context ID is : ', g_ee_data_rec_del(i).last_action_context_id );
         pay_in_utils.trace('Assignment ID is          : ', g_ee_data_rec_del(i).assignment_id          );
         pay_in_utils.trace('Element Entry ID is       : ', g_ee_data_rec_del(i).element_entry_id       );
         pay_in_utils.trace('Deductee Mode is          : ', g_ee_data_rec_del(i).deductee_mode          );
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE for deletion Ends........ ',5);
      pay_in_utils.set_location(g_debug,'========================================== ',6);

      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE for Addition Starts........ ',7);
      pay_in_utils.trace('Number of element entries added : ', g_count_ee_addition );
      FOR i IN 1..g_count_ee_addition -1
      LOOP
         pay_in_utils.trace('Last Action Context ID is : ', g_ee_data_rec_add(i).last_action_context_id );
         pay_in_utils.trace('Assignment ID is          : ', g_ee_data_rec_add(i).assignment_id          );
         pay_in_utils.trace('Element Entry ID is       : ', g_ee_data_rec_add(i).element_entry_id       );
         pay_in_utils.trace('Deductee Mode is          : ', g_ee_data_rec_add(i).deductee_mode          );
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE for addition Ends........ ',9);

      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE for addition Ends........ ',5);
      pay_in_utils.set_location(g_debug,'========================================== ',6);

      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE for Updation Starts........ ',7);
      pay_in_utils.trace('Number of element entries updated : ', g_count_ee_update );
      FOR i IN 1..g_count_ee_update -1
      LOOP
         pay_in_utils.trace('Last Action Context ID is : ', g_ee_data_rec_upd(i).last_action_context_id );
         pay_in_utils.trace('Assignment ID is          : ', g_ee_data_rec_upd(i).assignment_id          );
         pay_in_utils.trace('Element Entry ID is       : ', g_ee_data_rec_upd(i).element_entry_id       );
         pay_in_utils.trace('Deductee Mode is          : ', g_ee_data_rec_upd(i).deductee_mode          );
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_DEDUCTEE for updation Ends........ ',9);
      pay_in_utils.set_location(g_debug,'Data for Deductee Records Ends ',2);
      pay_in_utils.set_location(g_debug,'************************************************************ ',3);

      pay_in_utils.set_location(g_debug,'************************************************************ ',3);
      pay_in_utils.set_location(g_debug,'Displaying Data for Organization ',2);
      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.set_location(g_debug,'IN_24QC_ORG Starts........ ',3);
      pay_in_utils.trace('Value of g_count_org is : ', g_count_org);
      FOR i IN 1..g_count_org -1
      LOOP
         pay_in_utils.trace('Gre ID is                  : ', g_org_data(i).gre_id                );
         pay_in_utils.trace('Last Action Context ID is  : ', g_org_data(i).last_action_context_id);
      END LOOP;
      pay_in_utils.set_location(g_debug,'IN_24QC_ORG Ends........ ',3);
      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.set_location(g_debug,'************************************************************ ',3);

      pay_in_utils.set_location(g_debug,'************************************************************ ',3);
      pay_in_utils.set_location(g_debug,'IN_24QC_CHALLAN Starts............ ',3);
      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.trace('Number of added challans  is : ', g_count_challan_add);
      FOR i IN 1..g_count_challan_add - 1
      LOOP
         pay_in_utils.trace('Transfer Voucher Number is :' , g_challan_data_add(i).transfer_voucher_number);
         pay_in_utils.trace('Transfer Voucher Date is   :' , g_challan_data_add(i).transfer_voucher_date  );
         pay_in_utils.trace('Amount is                  :' , g_challan_data_add(i).amount                 );
         pay_in_utils.trace('Surcharge is               :' , g_challan_data_add(i).surcharge              );
         pay_in_utils.trace('Education Cess is          :' , g_challan_data_add(i).education_cess         );
         pay_in_utils.trace('Interest is                :' , g_challan_data_add(i).interest               );
         pay_in_utils.trace('Other is                   :' , g_challan_data_add(i).other                  );
         pay_in_utils.trace('Bank Branch Code is        :' , g_challan_data_add(i).bank_branch_code       );
         pay_in_utils.trace('Cheque DD Number           :' , g_challan_data_add(i).cheque_dd_num          );
         pay_in_utils.trace('Org Information ID is      :' , g_challan_data_add(i).org_information_id     );
         pay_in_utils.trace('Mode is                    :' , g_challan_data_add(i).modes                  );
         END LOOP;

      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.trace('Number of updated challans  is : ', g_count_challan_upd);
      FOR i IN 1..g_count_challan_upd - 1
      LOOP
         pay_in_utils.trace('Transfer Voucher Number is :' , g_challan_data_upd(i).transfer_voucher_number);
         pay_in_utils.trace('Transfer Voucher Date is   :' , g_challan_data_upd(i).transfer_voucher_date  );
         pay_in_utils.trace('Amount is                  :' , g_challan_data_upd(i).amount                 );
         pay_in_utils.trace('Surcharge is               :' , g_challan_data_upd(i).surcharge              );
         pay_in_utils.trace('Education Cess is          :' , g_challan_data_upd(i).education_cess         );
         pay_in_utils.trace('Interest is                :' , g_challan_data_upd(i).interest               );
         pay_in_utils.trace('Other is                   :' , g_challan_data_upd(i).other                  );
         pay_in_utils.trace('Bank Branch Code is        :' , g_challan_data_upd(i).bank_branch_code       );
         pay_in_utils.trace('Cheque DD Number           :' , g_challan_data_upd(i).cheque_dd_num          );
         pay_in_utils.trace('Org Information ID is      :' , g_challan_data_upd(i).org_information_id     );
         pay_in_utils.trace('Mode is                    :' , g_challan_data_upd(i).modes                  );
         END LOOP;

      pay_in_utils.set_location(g_debug,'========================================== ',3);
      pay_in_utils.trace('Number of no change challans  is : ', g_count_challan_noc);
      FOR i IN 1..g_count_challan_noc - 1
      LOOP
         pay_in_utils.trace('Transfer Voucher Number is :' , g_challan_data_noc(i).transfer_voucher_number);
         pay_in_utils.trace('Transfer Voucher Date is   :' , g_challan_data_noc(i).transfer_voucher_date  );
         pay_in_utils.trace('Amount is                  :' , g_challan_data_noc(i).amount                 );
         pay_in_utils.trace('Surcharge is               :' , g_challan_data_noc(i).surcharge              );
         pay_in_utils.trace('Education Cess is          :' , g_challan_data_noc(i).education_cess         );
         pay_in_utils.trace('Interest is                :' , g_challan_data_noc(i).interest               );
         pay_in_utils.trace('Other is                   :' , g_challan_data_noc(i).other                  );
         pay_in_utils.trace('Bank Branch Code is        :' , g_challan_data_noc(i).bank_branch_code       );
         pay_in_utils.trace('Cheque DD Number           :' , g_challan_data_noc(i).cheque_dd_num          );
         pay_in_utils.trace('Org Information ID is      :' , g_challan_data_noc(i).org_information_id     );
         pay_in_utils.trace('Mode is                    :' , g_challan_data_noc(i).modes                  );
         END LOOP;
      pay_in_utils.set_location(g_debug,'Leaving :'|| g_package || '.trace_pl_sql_table_data ',1);


  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END trace_pl_sql_table_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : REMOVE_CURR_FORMAT                                  --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    : This function is used to remove currency formatting --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_value                                             --
  --            OUT : VARCHAR2                                            --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  FUNCTION remove_curr_format (p_value    IN VARCHAR2)
  RETURN VARCHAR2 IS
     l_return_value VARCHAR2(240);
     l_procedure    VARCHAR2(100);
     l_message      VARCHAR2(250);
  BEGIN

    l_procedure := g_package||'.remove_curr_format';
    pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

    IF g_debug THEN
       pay_in_utils.trace('p_value',p_value);
    END IF;

    l_return_value := REPLACE(REPLACE(NVL(p_value,'0'), ',', ''), '+', '');
    pay_in_utils.set_location(g_debug,'Leaving : '|| l_procedure, 30);

    RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END remove_curr_format;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CHECK_ARCHIVAL_STATUS                               --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    : This function determines the presence of current    --
  --                  data in archival table for the current payroll act id-
  -- Parameters     :                                                     --
  --             IN : p_source_id          NUMBER                         --
  --                  p_act_inf_category   VARCHAR2                       --
  --                  p_act_information1   VARCHAR2                       --
  --                  p_mode               VARCHAR2                       --
  --            OUT : NUMBER                                              --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-20066     aaagarwa   Initial Version                      --
  -- 115.1 07-Feb-2007      rpalli     Added check for IN_24QC_PERSON       --
  --------------------------------------------------------------------------
  FUNCTION check_archival_status(p_source_id         IN  NUMBER   DEFAULT NULL
                                ,p_act_inf_category  IN  VARCHAR2
                                ,p_act_information1  IN  VARCHAR2 DEFAULT NULL
                                ,p_mode              IN  VARCHAR2 DEFAULT NULL
                                 )
  RETURN NUMBER
  IS

    CURSOR c_chk_person_data
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_information_category = 'IN_24QC_PERSON'
          AND action_context_type         = 'AAP'
          AND source_id                   = p_source_id
          AND action_information10        = p_mode
          AND action_context_id IN
                                (SELECT assignment_action_id
                                   FROM pay_assignment_actions
                                  WHERE payroll_action_id  = g_payroll_action_id
                                );


    CURSOR c_chk_ded_data
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_information_category = 'IN_24QC_DEDUCTEE'
          AND action_context_type         = 'AAP'
          AND source_id                   = p_source_id
          AND action_information15        = p_mode
          AND action_context_id IN
                                (SELECT assignment_action_id
                                   FROM pay_assignment_actions
                                  WHERE payroll_action_id  = g_payroll_action_id
                                );

    CURSOR c_chk_org_data
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_information_category = 'IN_24QC_ORG'
          AND action_context_type         = 'PA'
          AND action_context_id           = g_payroll_action_id
          AND action_information1         = g_gre_id;

    CURSOR c_chk_challan_data
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_information_category = 'IN_24QC_CHALLAN'
          AND action_context_type         = 'PA'
          AND action_context_id           = g_payroll_action_id
          AND action_information1         = p_act_information1
          AND action_information3         = g_gre_id;

  l_flag        NUMBER := 0;
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
  BEGIN
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'.check_archival_status';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     IF (p_act_inf_category = 'IN_24QC_DEDUCTEE')
     THEN
        OPEN  c_chk_ded_data;
        FETCH c_chk_ded_data INTO l_flag;
        CLOSE c_chk_ded_data;
     ELSIF (p_act_inf_category = 'IN_24QC_ORG')
     THEN
        OPEN  c_chk_org_data;
        FETCH c_chk_org_data INTO l_flag;
        CLOSE c_chk_org_data;
     ELSIF (p_act_inf_category = 'IN_24QC_PERSON')
     THEN
        OPEN  c_chk_person_data;
        FETCH c_chk_person_data INTO l_flag;
        CLOSE c_chk_person_data;
     ELSE
        OPEN  c_chk_challan_data;
        FETCH c_chk_challan_data INTO l_flag;
        CLOSE c_chk_challan_data;
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving : '|| g_package||'.check_archival_status',2);

     RETURN l_flag;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
END check_archival_status;

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
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------

  PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                           p_token_name        IN  VARCHAR2,
                           p_token_value       OUT NOCOPY VARCHAR2
                           )
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
    l_procedure   VARCHAR2(100);
    l_message     VARCHAR2(250);

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure  := g_package||'.get_parameters';

    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN csr_parameter_info(p_payroll_action_id,
                            p_token_name);
    FETCH csr_parameter_info INTO l_token_value,l_bg_id;
    CLOSE csr_parameter_info;

    p_token_value := TRIM(l_token_value);

    IF (p_token_name = 'BG_ID') THEN
        p_token_value := l_bg_id;
    END IF;

    IF (p_token_value IS NULL) THEN
         p_token_value := '%';
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,20);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END get_parameters;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : INITIALIZATION_CODE                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to set global contexts.      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  -- 115.1 07-Feb-2007    rpalli    Added code to initialize some dates   --
  --------------------------------------------------------------------------
  --
  PROCEDURE initialization_code (p_payroll_action_id  IN NUMBER)
  IS
  --
  CURSOR csr_arch_ref_no(p_payroll_action_id NUMBER)
  IS
   SELECT 1
    FROM pay_action_information pai
        ,pay_payroll_actions    ppa
   WHERE pai.action_information_category = 'IN_24QC_ORG'
     AND pai.action_context_type         = 'PA'
     AND pai.action_information1         = g_gre_id
     AND pai.action_information3         = g_year||g_quarter
     AND pai.action_information30        = g_24qc_reference
     AND pai.action_context_id           = ppa.payroll_action_id
     AND ppa.action_type                 = 'X'
     AND ppa.action_status               = 'C'
     AND ppa.payroll_action_id  <> p_payroll_action_id;

  CURSOR c_prev_stmt_details(p_tan_number      VARCHAR2
                            ,p_last_act_cxt_id NUMBER
                               )
     IS
       SELECT DECODE(action_information_category,'IN_24Q_ORG',action_information21,action_information7)   deductor_type
         FROM pay_action_information
        WHERE action_information_category IN ('IN_24Q_ORG','IN_24QC_ORG')
          AND action_context_id   = p_last_act_cxt_id
          AND action_context_type = 'PA'
          AND action_information1 = g_gre_id
          AND action_information2 = p_tan_number
          AND action_information3 = g_year||g_quarter
        ORDER BY action_context_id DESC;

    l_procedure                   VARCHAR2(100);
    l_assess_yr_start        DATE;
    l_end_date               DATE;
    i                        NUMBER;
    l_token_name             pay_in_utils.char_tab_type;
    l_token_value            pay_in_utils.char_tab_type;
    l_arch_ref_no_check      NUMBER;
    E_NON_UNIQUE_ARCH_REF_NO EXCEPTION;
    E_EMPLR_CLASS_VALIDATE EXCEPTION;
    l_deductor_type            hr_organization_information.org_information3%TYPE;
    l_tan_number               hr_organization_information.org_information3%TYPE;
    l_previous_deductor_type   hr_organization_information.org_information3%TYPE;
  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  := g_package || '.initialization_code';

    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    g_payroll_action_id  := p_payroll_action_id;
    get_parameters(p_payroll_action_id,'YR' ,g_year);
    get_parameters(p_payroll_action_id,'GRE',g_gre_id);
    get_parameters(p_payroll_action_id,'QR' ,g_quarter);
    get_parameters(p_payroll_action_id,'CT' ,g_correction_mode);
    get_parameters(p_payroll_action_id,'AR' ,g_24qc_reference);
    get_parameters(p_payroll_action_id,'EC' ,g_24qc_empr_change);
    get_parameters(p_payroll_action_id,'RC' ,g_24qc_rep_adr_chg);
    get_parameters(p_payroll_action_id,'RN' ,g_cancel_ref_number);
    get_parameters(p_payroll_action_id,'RFD',g_regular_file_date);

    IF g_regular_file_date < TO_DATE('01-10-09','DD-MM-YY')
    THEN
    g_old_format := 'Y';
    ELSE
    g_old_format := 'N';
    END IF;

    i := TO_NUMBER(SUBSTR(g_quarter,2,1)) - 1;
    l_assess_yr_start := fnd_date.string_to_date(('01/04/'|| SUBSTR(g_year,1,4)),'DD/MM/YYYY');
    l_end_date   := fnd_date.string_to_date(('31/03/'|| SUBSTR(g_year,6)),'DD/MM/YYYY');

    g_qr_start_date  := ADD_MONTHS(l_assess_yr_start,(i*3)-12);
    g_end_date       := ADD_MONTHS(g_qr_start_date,3) -1;

    pay_in_utils.set_location(g_debug,'Finding Globals : '||l_procedure,20);

    g_qr_end_date := ADD_MONTHS(g_qr_start_date,3) - 1;

    g_tax_year := TO_CHAR(TO_NUMBER(SUBSTR(g_year,1,4))-1)||'-'|| SUBSTR(g_year,1,4);

    g_fin_start_date := ADD_MONTHS(l_assess_yr_start,-12);
    g_fin_end_date   := ADD_MONTHS(l_end_date,-12);

    IF g_quarter ='Q4' THEN
      g_start_date := ADD_MONTHS(l_assess_yr_start,-12);
    ELSE
      g_start_date := g_qr_start_date;
    END IF;

    l_arch_ref_no_check := 0;
    OPEN csr_arch_ref_no(p_payroll_action_id);
    FETCH csr_arch_ref_no INTO l_arch_ref_no_check;
    CLOSE csr_arch_ref_no;

    IF l_arch_ref_no_check = 1 THEN
       l_token_name(1)  := 'NUMBER_CATEGORY';
       l_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','ARCH_REF_NUM');--'Archive Reference Number';
       RAISE E_NON_UNIQUE_ARCH_REF_NO;
    END IF;

    SELECT  hoi.org_information1 ,hoi.org_information6 into l_tan_number,l_deductor_type
      FROM hr_organization_information hoi
          ,hr_organization_units       hou
     WHERE hoi.organization_id         = g_gre_id
       AND hoi.org_information_context = 'PER_IN_INCOME_TAX_DF'
       AND hou.organization_id         = hoi.organization_id
       AND hou.business_group_id       = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
       AND g_qr_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

      FOR i IN 1.. g_count_org - 1
        LOOP
                IF (g_org_data(i).gre_id = g_gre_id)
                THEN
                       pay_in_utils.set_location(g_debug,'Fetching previous statement details ',3);
                       pay_in_utils.set_location(g_debug,'Last Payroll Action Id   : ' || g_org_data(i).last_action_context_id,6);
                       OPEN  c_prev_stmt_details(l_tan_number,g_org_data(i).last_action_context_id);
                       FETCH c_prev_stmt_details INTO l_previous_deductor_type;
                       CLOSE c_prev_stmt_details;
                END IF;
       END LOOP;
           pay_in_utils.set_location(g_debug,'Old Deductor Type is    : ' || l_previous_deductor_type,9);
           pay_in_utils.set_location(g_debug,'New Deductor Type is    : ' || l_deductor_type,9);

           IF (l_previous_deductor_type IN ('A','S') and l_deductor_type NOT IN ('A','S'))
           THEN
            l_token_name(1)  := 'EMPLR_TYPE';
            l_token_value(1) := 'Government';
            RAISE E_EMPLR_CLASS_VALIDATE;
           ELSIF (l_previous_deductor_type NOT IN ('A','S') and l_deductor_type IN ('A','S'))
           THEN
            l_token_name(1)  := 'EMPLR_TYPE';
            l_token_value(1) := 'Non-Government';
            RAISE E_EMPLR_CLASS_VALIDATE;
           END IF;

    pay_in_utils.set_location(g_debug,'Global1: '||g_year||' '||' '||g_quarter||' '||g_gre_id,30);
    pay_in_utils.set_location(g_debug,'Global2: '||g_end_date||g_qr_start_date||g_qr_end_date,40);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);

  --
  EXCEPTION
    WHEN E_NON_UNIQUE_ARCH_REF_NO THEN
      pay_in_utils.raise_message(800, 'PER_IN_NON_UNIQUE_VALUE', l_token_name, l_token_value);
      fnd_file.put_line(fnd_file.log,'Archive Reference Number '|| g_24qc_reference || 'is non-unique.');
      RAISE;
    WHEN E_EMPLR_CLASS_VALIDATE THEN
      pay_in_utils.raise_message(800,'PER_IN_24Q_EMPLR_VALIDATE', l_token_name, l_token_value);
      fnd_file.put_line(fnd_file.log,'Employer Classification '|| l_deductor_type || 'should be changed.');
      RAISE;
    WHEN OTHERS THEN
      RAISE;
  END initialization_code;

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_END_DATE                                 --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    : This function determines the least of asg terminat- --
  --                  -ion date and quarter end date.                     --
  -- Parameters     :                                                     --
  --             IN : p_assignment_id NUMBER                              --
  --            OUT : DATE                                                --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION assignment_end_date(p_assignment_id IN  NUMBER
                              )
  RETURN DATE
  IS
    CURSOR c_termination_check
    IS
    SELECT NVL(pos.actual_termination_date,(fnd_date.string_to_date('31-12-4712','DD-MM-YYYY')))
      FROM   per_all_assignments_f  asg
            ,per_periods_of_service pos
     WHERE asg.person_id         = pos.person_id
       AND asg.assignment_id     = p_assignment_id
       AND asg.business_group_id = pos.business_group_id
       AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
       AND NVL(pos.actual_termination_date,(TO_DATE('31-12-4712','DD-MM-YYYY')))
             BETWEEN asg.effective_start_date AND asg.effective_end_date
     ORDER BY 1 DESC;

    l_date      DATE;
    l_procedure VARCHAR2(250);
    l_message   VARCHAR2(250);
  BEGIN
    g_debug     := hr_utility.debug_enabled;
    l_procedure := g_package ||'.assignment_end_date';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    OPEN  c_termination_check;
    FETCH c_termination_check INTO l_date;
    CLOSE c_termination_check;
    pay_in_utils.set_location(g_debug,'Date Found is: '|| l_date,2);
    pay_in_utils.set_location(g_debug,'Leaving :'||g_package||'.assignment_end_date',3);
    RETURN LEAST(l_date,g_qr_end_date);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
END assignment_end_date;

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
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE range_code(p_payroll_action_id   IN  NUMBER
                      ,p_sql                 OUT NOCOPY VARCHAR2
                      )
  IS
  --
    l_procedure  VARCHAR2(100);
    l_message    VARCHAR2(250);
  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  := g_package || '.range_code';

    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    -- Call core package to return SQL string to SELECT a range
    -- of assignments eligible for archival
    --
    pay_core_payslip_utils.range_cursor(p_payroll_action_id
                                       ,p_sql);

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,20);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  --
  END range_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : UPDATE_CHALLANS                                     --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    : This function returns the last statement detail     --
  -- Parameters     :                                                     --
  --             IN : p_challan_number   VARCHAR2                         --
  --                                                                      --
  --            OUT : VARCHAR2                                            --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  FUNCTION update_challans(p_challan_number    IN VARCHAR2)
  RETURN VARCHAR2
  IS
    CURSOR c_24q_ee_sum(p_challan_number       VARCHAR2
                       ,p_24q_pay_action_id   NUMBER
                       )
    IS
        SELECT SUM(NVL(pai.action_information9,0)) amount_deposited
          FROM pay_action_information  pai
              ,pay_assignment_actions  paa
         WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
           AND paa.assignment_action_id        = pai.action_context_id
           AND pai.action_information1         = p_challan_number
           AND paa.payroll_action_id           = p_24q_pay_action_id;

      l_action_info_id    NUMBER;
      l_ovn               NUMBER;
      l_last_sum          VARCHAR2(2500);
      l_procedure         VARCHAR2(250);
      l_message           VARCHAR2(250);
  BEGIN
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'.update_challans';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     pay_in_utils.set_location(g_debug,'g_24q_payroll_act_id  ' || g_24q_payroll_act_id ,1);
     pay_in_utils.set_location(g_debug,'g_24qc_payroll_act_id ' || g_24qc_payroll_act_id,1);

     l_last_sum := NULL;
     pay_in_utils.set_location(g_debug,'Starting updation of action_information19 for Challans ' ,1);
     IF (g_24qc_payroll_act_id IS NOT NULL)
     THEN
            pay_in_utils.set_location(g_debug,'Using 24Q Correction Data',2);
            l_last_sum := pay_in_24qc_er_returns.get_24qc_tax_values(p_challan_number
                                                                    ,g_gre_id
                                                                    ,g_24qc_payroll_act_id
                                                                    );
            l_last_sum := SUBSTR(l_last_sum,1,INSTR(l_last_sum,'^')-1);
      END IF;

      IF(TO_NUMBER(NVL(l_last_sum,0)) = 0)
      THEN
            pay_in_utils.set_location(g_debug,'Using 24Q Data',3);
            OPEN  c_24q_ee_sum(p_challan_number,g_24q_payroll_act_id);
            FETCH c_24q_ee_sum INTO l_last_sum;
            CLOSE c_24q_ee_sum;
            l_last_sum := pay_in_24q_er_returns.get_format_value(l_last_sum);
     END IF;

     pay_in_utils.set_location(g_debug,'Leaving: '|| g_package||'.update_challans',1);
     RETURN l_last_sum;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END update_challans;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CHECK_EE_IN_QC                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This determines cyclic change in Challan Number in  --
  --                  an element entry                                    --
  -- Parameters     :                                                     --
  --             IN : p_element_entry_id                                  --
  --            OUT : VARCHAR2                                            --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION check_ee_in_qc(p_element_entry_id IN NUMBER)
  RETURN VARCHAR2
  IS
  CURSOR check_ee
  IS
   SELECT pai.action_information1
         ,MAX(pai.action_context_id)
     FROM pay_action_information pai
         ,pay_action_interlocks locks
         ,pay_assignment_actions paa
         ,pay_assignment_actions paa_24qc
    WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
      AND locks.locking_action_id         = pai.action_context_id
      AND locks.locked_action_id          = paa.assignment_action_id
      AND paa.payroll_action_id           = g_24q_payroll_act_id
      AND paa.assignment_id               = pai.assignment_id
      AND pai.action_information2         = g_year||g_quarter
      AND paa_24qc.assignment_id          = pai.assignment_id
      AND paa_24qc.assignment_action_id   = pai.action_context_id
      AND pai.action_information15        = 'A'
      AND pai.source_id                   = p_element_entry_id
      AND paa_24qc.payroll_action_id IN(
                                        SELECT org_information3
                                          FROM hr_organization_information
                                         WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                           AND organization_id  = g_gre_id
                                           AND org_information1 = g_year
                                           AND org_information2 = g_quarter
                                           AND org_information5 = 'A'
                                           AND org_information6 = 'C'
                                        )
      GROUP BY pai.action_information1;

  l_challan_number         VARCHAR2(250);
  l_action_info_id         NUMBER;
  l_procedure              VARCHAR2(250);
  l_message                VARCHAR2(250);

  BEGIN
    l_procedure  :=  g_package || '.check_ee_in_qc';
    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    OPEN  check_ee;
    FETCH check_ee INTO l_challan_number,l_action_info_id;
    CLOSE check_ee;

    l_challan_number := NVL(l_challan_number,pay_in_utils.get_ee_value(p_element_entry_id,'Challan or Voucher Number'));

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,20);
    RETURN l_challan_number;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END check_ee_in_qc;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GENERATE_EMPLOYEE_DATA                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure populates global tables used in      --
  --                  deductee detail record                              --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE generate_employee_data(p_payroll_action_id   IN NUMBER
                                  )
  IS

    CURSOR c_delete_mode_entries(p_payroll_action_id        NUMBER)
    IS
       SELECT pai.source_id           element_entry_id
             ,pai.assignment_id       assignment_id
             ,pai.action_context_id   last_action_context_id
         FROM pay_action_information pai
             ,pay_assignment_actions paa
        WHERE pai.action_information_category LIKE 'IN_24Q%_DEDUCTEE'
          AND pai.action_context_id = paa.assignment_action_id
          AND(
                paa.payroll_action_id IN (
                                           SELECT org_information3
                                             FROM hr_organization_information
                                            WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                              AND organization_id  = g_gre_id
                                              AND org_information1 = g_year
                                              AND org_information2 = g_quarter
                                              AND org_information5 = 'A'
                                          )
             )
          AND pai.action_information3 = g_gre_id
          AND (
                pai.source_id NOT IN
                       (SELECT entry.element_entry_id
                          FROM pay_element_entries_f entry
                              ,pay_element_types_f   types
                         WHERE entry.assignment_id = pai.assignment_id
                           AND entry.element_type_id = types.element_type_id
                           AND types.element_name = 'Income Tax Challan Information'
                           AND types.legislation_code = 'IN'
                           AND entry.effective_start_date BETWEEN g_qr_start_date
                           AND g_qr_end_date
                        )
               OR
               pai.action_information1 <> pay_in_utils.get_ee_value(pai.source_id,'Challan or Voucher Number')
             )
         AND (
                pai.source_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions masters
                        WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
                          AND pai.action_information15        = 'D'
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND masters.assignment_id            = pai.assignment_id
                          AND masters.assignment_action_id     = pai.action_context_id
                          AND masters.payroll_action_id IN(
                                                           SELECT org_information3
                                                             FROM hr_organization_information
                                                            WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                              AND organization_id  = g_gre_id
                                                              AND org_information1 = g_year
                                                              AND org_information2 = g_quarter
                                                              AND org_information5 = 'A'
                                                              AND org_information6 = 'C'
                                                     )
                      )
              OR
              pay_in_utils.get_ee_value(pai.source_id,'Challan or Voucher Number') NOT IN
              (
                      (SELECT pai.action_information1
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions masters
                        WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
                          AND pai.action_information15        = 'A'
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND masters.assignment_id            = pai.assignment_id
                          AND masters.assignment_action_id     = pai.action_context_id
                          AND masters.payroll_action_id IN(
                                                            SELECT org_information3
                                                              FROM hr_organization_information
                                                             WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                               AND organization_id  = g_gre_id
                                                               AND org_information1 = g_year
                                                               AND org_information2 = g_quarter
                                                               AND org_information5 = 'A'
                                                               AND org_information6 = 'C'
                                                     )
                      )
              )
           )
           ORDER BY 3 DESC;

    CURSOR c_addition_mode_entries(p_payroll_action_id        NUMBER)
    IS
      SELECT entry.element_entry_id  element_entry_id
            ,entry.assignment_id     assignment_id
            ,NULL                    last_action_context_id
            ,pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number')
        FROM pay_element_entries_f entry
            ,pay_element_types_f   types
       WHERE entry.element_type_id = types.element_type_id
         AND types.element_name    = 'Income Tax Challan Information'
         AND types.legislation_code = 'IN'
         AND entry.effective_start_date BETWEEN g_qr_start_date AND g_qr_end_date
         AND (
                entry.element_entry_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_assignment_actions paa
                        WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
                          AND pai.action_context_id   = paa.assignment_action_id
                          AND paa.payroll_action_id   = p_payroll_action_id
                      )
              OR
              pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number') NOT IN
                      (SELECT pai.action_information1
                         FROM pay_action_information pai
                             ,pay_assignment_actions paa
                        WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
                          AND pai.action_context_id   = paa.assignment_action_id
                          AND paa.payroll_action_id   = p_payroll_action_id
                          AND pai.source_id           = entry.element_entry_id
                      )
             )
         AND (
                 entry.element_entry_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions paa_24qc
                        WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND pai.action_information2         = g_year||g_quarter
                          AND paa_24qc.assignment_id          = pai.assignment_id
                          AND paa_24qc.assignment_action_id   = pai.action_context_id
                          AND paa_24qc.payroll_action_id IN(
                                                      SELECT org_information3
                                                        FROM hr_organization_information
                                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                         AND organization_id  = g_gre_id
                                                         AND org_information1 = g_year
                                                         AND org_information2 = g_quarter
                                                         AND org_information5 = 'A'
                                                         AND org_information6 = 'C'
                                                     )
                      )
              OR
              pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number') NOT IN
              (
                      (SELECT pai.action_information1
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions paa_24qc
                        WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND pai.action_information2         = g_year||g_quarter
                          AND paa_24qc.assignment_id          = pai.assignment_id
                          AND paa_24qc.assignment_action_id   = pai.action_context_id
                          AND pai.source_id                   = entry.element_entry_id
                          AND paa_24qc.payroll_action_id IN(
                                                      SELECT org_information3
                                                        FROM hr_organization_information
                                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                         AND organization_id  = g_gre_id
                                                         AND org_information1 = g_year
                                                         AND org_information2 = g_quarter
                                                         AND org_information5 = 'A'
                                                         AND org_information6 = 'C'
                                                     )
                      )
              )
            )
         AND pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number') IN
             	    (SELECT bank.org_information4||' - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                           FROM hr_organization_units hou
                                                               ,hr_organization_information hoi
                                                               ,hr_organization_information bank
                                                          WHERE hoi.organization_id   = hou.organization_id
                                                            AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                                            AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                            AND hoi.org_information1 = g_tax_year
                                                            AND bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                                                            and bank.organization_id = hoi.organization_id
                                                            AND hoi.org_information5 = bank.org_information_id
                                                            AND hoi.org_information13 = g_quarter
                                                            AND hoi.organization_id = g_gre_id
                                                         UNION
                                                        SELECT 'BOOK - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                          FROM hr_organization_units hou
                                                              ,hr_organization_information hoi
                                                         WHERE hoi.organization_id   = hou.organization_id
                                                           AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                                           AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                           AND hoi.org_information1 = g_tax_year
                                                           AND hoi.org_information13 = g_quarter
                                                           AND hoi.org_information5 IS NULL
                                                           AND hoi.organization_id = g_gre_id
			                                 )
         AND (
                (
                    g_correction_mode IN ('%','C3')
                    AND
                    pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number') IN
                    (
                                       SELECT action_information1
                                         FROM pay_action_information
                                        WHERE action_information_category IN('IN_24QC_CHALLAN','IN_24Q_CHALLAN')
                                          AND (
                                                action_information15 = p_payroll_action_id
                                                AND action_information_category = 'IN_24QC_CHALLAN'
                                                AND action_information2 = g_year||g_quarter
                                                AND action_information15 IN
                                                                           (
                                                                            (SELECT bank.org_information4||' - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                           FROM hr_organization_units hou
                                                               ,hr_organization_information hoi
                                                               ,hr_organization_information bank
                                                          WHERE hoi.organization_id   = hou.organization_id
                                                            AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                                            AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                            AND hoi.org_information1 = g_tax_year
                                                            AND bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                                                            and bank.organization_id = hoi.organization_id
                                                            AND hoi.org_information5 = bank.org_information_id
                                                            AND hoi.org_information13 = g_quarter
                                                            AND hoi.organization_id = g_gre_id
                                                         UNION
                                                        SELECT 'BOOK - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                          FROM hr_organization_units hou
                                                              ,hr_organization_information hoi
                                                         WHERE hoi.organization_id   = hou.organization_id
                                                           AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                                           AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                           AND hoi.org_information1 = g_tax_year
                                                           AND hoi.org_information13 = g_quarter
                                                           AND hoi.org_information5 IS NULL
                                                           AND hoi.organization_id = g_gre_id
			                                 )
                                                                           )
                                                )
                                                OR
                                                (
                                                action_information_category = 'IN_24Q_CHALLAN'
                                                AND action_context_id   = p_payroll_action_id
                                                )
                    )
                )
                OR
                (g_correction_mode IN ('%','C9')
                AND
                pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number') NOT IN
                       (
                                       SELECT action_information1
                                         FROM pay_action_information
                                        WHERE action_information_category IN('IN_24QC_CHALLAN','IN_24Q_CHALLAN')
                                          AND (
                                                action_information15 = p_payroll_action_id
                                                AND action_information_category = 'IN_24QC_CHALLAN'
                                                AND action_information2 = g_year||g_quarter
                                                AND action_information15 IN
						(SELECT bank.org_information4||' - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                           FROM hr_organization_units hou
                                                               ,hr_organization_information hoi
                                                               ,hr_organization_information bank
                                                          WHERE hoi.organization_id   = hou.organization_id
                                                            AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                                            AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                            AND hoi.org_information1 = g_tax_year
                                                            AND bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                                                            and bank.organization_id = hoi.organization_id
                                                            AND hoi.org_information5 = bank.org_information_id
                                                            AND hoi.org_information13 = g_quarter
                                                            AND hoi.organization_id = g_gre_id
                                                         UNION
                                                        SELECT 'BOOK - '||hoi.org_information3 ||' - ' ||to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-Mon-RRRR') org_information3
                                                          FROM hr_organization_units hou
                                                              ,hr_organization_information hoi
                                                         WHERE hoi.organization_id   = hou.organization_id
                                                           AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                                           AND hoi.org_information_context = 'PER_IN_IT_CHALLAN_INFO'
                                                           AND hoi.org_information1 = g_tax_year
                                                           AND hoi.org_information13 = g_quarter
                                                           AND hoi.org_information5 IS NULL
                                                           AND hoi.organization_id = g_gre_id
			                                 )
                                                )
                                                OR
                                                (
                                                action_information_category = 'IN_24Q_CHALLAN'
                                                AND action_context_id   = p_payroll_action_id
                                                )
                        )
                )
              )
              ORDER BY 4;

    CURSOR c_update_mode_entries(p_payroll_action_id        NUMBER
                                )
    IS
       SELECT pai.source_id     element_entry_id
             ,pai.assignment_id assignment_id
             ,pai.action_context_id   last_action_context_id
             ,pep.effective_end_date
         FROM pay_action_information pai
             ,pay_assignment_actions  paa
             ,per_people_f            pep
             ,per_assignments_f       asg
        WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
          AND pai.action_context_id = paa.assignment_action_id
          AND pai.action_information3 = g_gre_id
          AND paa.payroll_action_id = p_payroll_action_id
          AND asg.assignment_id     = pai.assignment_id
          AND asg.person_id         = pep.person_id
          AND asg.business_group_id = pep.business_group_id
          AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          AND (
                (
                  (NVL(pai.action_information13,'0') <> (SELECT  NVL(paei.aei_information2,'0')
                                                           FROM  per_assignment_extra_info paei
                                                                ,per_assignments_f paa
                                                          WHERE  paei.information_type = 'PER_IN_TAX_EXEMPTION_DF'
                                                            AND  paei.aei_information_category = 'PER_IN_TAX_EXEMPTION_DF'
                                                            AND  paei.assignment_id = paa.assignment_id
                                                            AND  paa.assignment_id  = asg.assignment_id
                                                            AND  paei.aei_information1 = g_tax_year
                                                            AND  assignment_end_date(asg.assignment_id) BETWEEN paa.effective_start_date AND paa.effective_end_date
                                                            AND  ROWNUM = 1)
                 )
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information6))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Income Tax Deducted'))))
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information7))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Surcharge Deducted'))))
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information8))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Education Cess Deducted'))))
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information5))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Taxable Income'))))
               OR
                  (pai.action_information4  <> pay_in_utils.get_ee_value(pai.source_id,'Payment Date'))
               OR
                  (pai.action_information12 <> hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title))
               OR
                  (NVL(pai.action_information11,'0') <> NVL(pep.per_information14,'0'))
               OR(
                     (
                           g_correction_mode IN ('C5','%')
                       AND (pai.action_information10 NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND (pai.action_information10 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                     )
                     OR
                     (
                       g_correction_mode NOT IN ('C5')
                       AND (pai.action_information10 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))IN('APPLIEDFOR','PANNOTAVBL'))
                     )
                )
               )
              AND pay_in_utils.get_ee_value(pai.source_id,'Challan or Voucher Number') = pai.action_information1
             )
          AND   assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
          AND   assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
          ORDER BY 4 DESC;

    CURSOR c_check_entries_in_24q_correct(p_24q_arc_action_context_id NUMBER
                                         ,p_assignment_id             NUMBER
                                         ,p_element_entry_id          NUMBER
                                         ,p_mode                      VARCHAR2
                                         )
    IS
       SELECT pai_locking.action_context_id  last_action_context_id
         FROM pay_action_information pai_locking
             ,pay_action_interlocks locks
             ,pay_assignment_actions paa
        WHERE pai_locking.action_information_category = 'IN_24QC_DEDUCTEE'
          AND pai_locking.action_information3  = g_gre_id
          AND pai_locking.action_information15 = p_mode
          AND pai_locking.action_context_id    = paa.assignment_action_id
          AND paa.payroll_action_id IN
                                    (
                                      SELECT org_information3
                                        FROM hr_organization_information
                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                         AND organization_id  = g_gre_id
                                         AND org_information1 = g_year
                                         AND org_information2 = g_quarter
                                         AND org_information5 = 'A'
                                         AND org_information6 = 'C'
                                    )
          AND locks.locking_action_id          = pai_locking.action_context_id
          AND locks.locked_action_id           = p_24q_arc_action_context_id
          AND pai_locking.assignment_id        = p_assignment_id
          AND pai_locking.source_id            = p_element_entry_id
        ORDER BY pai_locking.action_context_id DESC;

    CURSOR c_24qc_upd_mode_entries(p_assignment_action_id        NUMBER
                                  ,p_element_entry_id            NUMBER
                                  )
    IS
       SELECT pai.action_context_id
         FROM pay_action_information pai
             ,per_people_f           pep
             ,per_assignments_f      asg
             ,pay_assignment_actions paa
        WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
          AND paa.assignment_action_id = pai.action_context_id
          AND pai.source_id     = p_element_entry_id
          AND paa.payroll_action_id IN
                           (
                             SELECT org_information3
                               FROM hr_organization_information
                              WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                AND organization_id  = g_gre_id
                                AND org_information1 = g_year
                                AND org_information2 = g_quarter
                                AND org_information5 = 'A'
                                AND org_information6 = 'C'
                          )
          AND pai.action_information3 = g_gre_id
          AND pai.action_context_id = p_assignment_action_id
          AND asg.assignment_id     = pai.assignment_id
          AND asg.person_id         = pep.person_id
          AND asg.business_group_id = pep.business_group_id
          AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          AND (
                  (NVL(pai.action_information18,'0') <> (SELECT  NVL(paei.aei_information2,'0')
                                                           FROM  per_assignment_extra_info paei
                                                                ,per_assignments_f paa
                                                          WHERE  paei.information_type = 'PER_IN_TAX_EXEMPTION_DF'
                                                            AND  paei.aei_information_category = 'PER_IN_TAX_EXEMPTION_DF'
                                                            AND  paei.assignment_id = paa.assignment_id
                                                            AND  paa.assignment_id = asg.assignment_id
                                                            AND  paei.aei_information1 = g_tax_year
                                                            AND  assignment_end_date(asg.assignment_id) BETWEEN paa.effective_start_date AND paa.effective_end_date
                                                            AND  ROWNUM = 1)
                 )
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information6))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Income Tax Deducted'))))
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information7))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Surcharge Deducted'))))
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information8))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Education Cess Deducted'))))
               OR
                  (TO_NUMBER(remove_curr_format(pai.action_information5))  <> TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Taxable Income'))))
               OR
                  (pai.action_information4  <> pay_in_utils.get_ee_value(pai.source_id,'Payment Date'))
               OR
                  (pai.action_information10 <> hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title))
               OR(--Checking PAN Number
                    (
                           g_correction_mode IN ('C5','%')
                       AND (pai.action_information9 NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND (pai.action_information9 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                     )
                     OR
                     (
                       g_correction_mode NOT IN ('C5')
                       AND (pai.action_information9 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))IN('APPLIEDFOR','PANNOTAVBL'))
                     )
                )
              OR -- Checking PAN reference Number
                  (NVL(pai.action_information11,'0') <> NVL(pep.per_information14,'0'))
              )
          AND  assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
          AND  assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
          AND NOT EXISTS
          (
       SELECT 1
         FROM pay_action_information pai
             ,per_people_f           pep
             ,per_assignments_f      asg
        WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
          AND pai.source_id            = p_element_entry_id
          AND pai.action_information3  = g_gre_id
          AND pai.action_context_id    = p_assignment_action_id
          AND asg.assignment_id        = pai.assignment_id
          AND asg.person_id            = pep.person_id
          AND asg.business_group_id    = pep.business_group_id
          AND asg.business_group_id    = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          AND (
                  (NVL(pai.action_information18,'0') = (SELECT  NVL(paei.aei_information2,'0')
                                                           FROM  per_assignment_extra_info paei
                                                                ,per_assignments_f paa
                                                          WHERE  paei.information_type = 'PER_IN_TAX_EXEMPTION_DF'
                                                            AND  paei.aei_information_category = 'PER_IN_TAX_EXEMPTION_DF'
                                                            AND  paei.assignment_id = paa.assignment_id
                                                            AND  paa.assignment_id = asg.assignment_id
                                                            AND  paei.aei_information1 = g_tax_year
                                                            AND  assignment_end_date(asg.assignment_id) BETWEEN paa.effective_start_date AND paa.effective_end_date
                                                            AND  ROWNUM = 1)
                 )
               AND
                  (TO_NUMBER(remove_curr_format(pai.action_information6))  = TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Income Tax Deducted'))))
               AND
                  (TO_NUMBER(remove_curr_format(pai.action_information7))  = TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Surcharge Deducted'))))
               AND
                  (TO_NUMBER(remove_curr_format(pai.action_information8))  = TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Education Cess Deducted'))))
               AND
                  (TO_NUMBER(remove_curr_format(pai.action_information5))  = TO_NUMBER(remove_curr_format(pay_in_utils.get_ee_value(pai.source_id,'Taxable Income'))))
               AND
                  (pai.action_information4  = pay_in_utils.get_ee_value(pai.source_id,'Payment Date'))
               AND
                  (pai.action_information10 = hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title))
               AND(--Checking PAN Number
                     (
                           g_correction_mode IN ('C5','%')
                       AND (pai.action_information9 NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND (pai.action_information9 = (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                     )
                     OR
                     (
                       g_correction_mode NOT IN ('C5')
                       AND (pai.action_information9 = (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))IN('APPLIEDFOR','PANNOTAVBL'))
                     )
                )
              AND -- Checking PAN reference Number
                  (NVL(pai.action_information11,'0') = NVL(pep.per_information14,'0'))
              )
          AND  assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
          AND  assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
         );

    CURSOR c_form_24qc_locking_id(p_mode           VARCHAR2
                                 ,p_flag           NUMBER
                                 )
    IS
      SELECT MAX(pai.action_context_id) last_action_context_id
            ,pai.source_id              element_entry_id
            ,pai.assignment_id          assignment_id
        FROM pay_action_information pai
            ,pay_assignment_actions paa
       WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
         AND pai.action_information3         = g_gre_id
         AND pai.action_information2         = g_year||g_quarter
         AND pai.action_information15        = p_mode
         AND pai.action_context_id           = paa.assignment_action_id
         AND paa.payroll_action_id IN
                              (
                                SELECT org_information3
                                  FROM hr_organization_information
                                 WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                   AND organization_id  = g_gre_id
                                   AND org_information1 = g_year
                                   AND org_information2 = g_quarter
                                   AND org_information5 = 'A'
                                   AND org_information6 = 'C'
                              )
        AND (
                p_flag = 1
                OR
                (
                 pai.source_id NOT IN(
                                SELECT pai.source_id
                                  FROM pay_action_information pai
                                      ,pay_assignment_actions paa
                                 WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
                                   AND pai.action_information3         = g_gre_id
                                   AND pai.action_information2         = g_year||g_quarter
                                   AND pai.action_information15        = 'D'
                                   AND pai.action_context_id           = paa.assignment_action_id
                                   AND paa.payroll_action_id IN
                                                        (
                                                              SELECT org_information3
                                                                FROM hr_organization_information
                                                               WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                                 AND organization_id  = g_gre_id
                                                                 AND org_information1 = g_year
                                                                 AND org_information2 = g_quarter
                                                                 AND org_information5 = 'A'
                                                                 AND org_information6 = 'C'
                                                        )
                                   )
                AND pai.source_id IN
                                     (SELECT entry.element_entry_id
                                        FROM pay_element_entries_f entry
                                            ,pay_element_types_f   types
                                       WHERE entry.assignment_id = pai.assignment_id
                                         AND entry.element_type_id = types.element_type_id
                                         AND types.element_name = 'Income Tax Challan Information'
                                         AND types.legislation_code = 'IN'
                                         AND entry.effective_start_date BETWEEN g_qr_start_date
                                         AND g_qr_end_date
                                        )
                )
            )
        GROUP BY pai.source_id,pai.assignment_id;

    CURSOR c_live_ee
    IS
      SELECT entry.element_entry_id  element_entry_id
            ,entry.assignment_id     assignment_id
            ,pay_in_utils.get_ee_value(entry.element_entry_id,'Challan or Voucher Number') challan
        FROM pay_element_entries_f      entry
            ,pay_element_types_f        types
       WHERE entry.element_type_id   = types.element_type_id
         AND types.element_name      = 'Income Tax Challan Information'
         AND types.legislation_code  = 'IN'
         AND entry.effective_start_date BETWEEN g_qr_start_date AND g_qr_end_date;

    CURSOR c_bg_check(p_assignment_id   NUMBER)
    IS
      SELECT 1
        FROM per_assignments_f
       WHERE business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND assignment_id     = p_assignment_id;

    l_procedure                 VARCHAR2(100);
    l_action_id                 NUMBER;
    l_dummy                     NUMBER;
    l_flag                      BOOLEAN;
    l_last_action_context_id    NUMBER;
    i                           NUMBER;
    l_message                   VARCHAR2(250);
    l_bg_check                  NUMBER;

  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || '.generate_employee_data';

    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

   --The below process finds those Challan Element Entries which have MODE as Deletion(D)
    pay_in_utils.set_location(g_debug,'Finding element entries deleted since last statement ',2);
   FOR c_rec IN c_delete_mode_entries(p_payroll_action_id)
   LOOP
          l_bg_check := 0;
          OPEN  c_bg_check(c_rec.assignment_id);
          FETCH c_bg_check INTO l_bg_check;
          CLOSE c_bg_check;

          IF (l_bg_check = 1)
          THEN
               g_ee_data_rec_del(g_count_ee_delete).last_action_context_id := c_rec.last_action_context_id;
               g_ee_data_rec_del(g_count_ee_delete).assignment_id          := c_rec.assignment_id;
               g_ee_data_rec_del(g_count_ee_delete).element_entry_id       := c_rec.element_entry_id;
               g_ee_data_rec_del(g_count_ee_delete).deductee_mode          := 'D';
               g_count_ee_delete := g_count_ee_delete + 1;
          END IF;
   END LOOP;

    pay_in_utils.set_location(g_debug,'Finding element entries added since last statement ',3);
--The below process finds those Challan Element Entries which have MODE as Addition(A)
    FOR c_rec IN c_addition_mode_entries(p_payroll_action_id)
    LOOP
          l_bg_check := 0;
          OPEN  c_bg_check(c_rec.assignment_id);
          FETCH c_bg_check INTO l_bg_check;
          CLOSE c_bg_check;

          IF (l_bg_check = 1)
          THEN
               g_ee_data_rec_add(g_count_ee_addition).last_action_context_id := c_rec.last_action_context_id;
               g_ee_data_rec_add(g_count_ee_addition).assignment_id          := c_rec.assignment_id;
               g_ee_data_rec_add(g_count_ee_addition).element_entry_id       := c_rec.element_entry_id;
               g_ee_data_rec_add(g_count_ee_addition).deductee_mode          := 'A';
               g_count_ee_addition := g_count_ee_addition + 1;
          END IF;
    END LOOP;
--The below cursor finds those Challan Element Entries that have cyclic challan number change
    FOR c_rec IN c_live_ee
    LOOP
       l_bg_check := 0;
       OPEN  c_bg_check(c_rec.assignment_id);
       FETCH c_bg_check INTO l_bg_check;
       CLOSE c_bg_check;

       IF (l_bg_check = 1)
       THEN
            IF (c_rec.challan <> check_ee_in_qc(c_rec.element_entry_id))
            THEN
                pay_in_utils.set_location(g_debug,'Live Challan Value is: '|| c_rec.challan,1);
                pay_in_utils.set_location(g_debug,'Old Challan Value is: '|| check_ee_in_qc(c_rec.element_entry_id),2);
                g_ee_data_rec_add(g_count_ee_addition).last_action_context_id := NULL;
                g_ee_data_rec_add(g_count_ee_addition).assignment_id          := c_rec.assignment_id;
                g_ee_data_rec_add(g_count_ee_addition).element_entry_id       := c_rec.element_entry_id;
                g_ee_data_rec_add(g_count_ee_addition).deductee_mode          := 'A';
                g_count_ee_addition := g_count_ee_addition + 1;
            END IF;
       END IF;
    END LOOP;
--The below process finds those Challan Element Entries which have MODE as Updation(U)
-- This code checks U from Form 24Q Archival to Live Data
    pay_in_utils.set_location(g_debug,'Finding element entries updated since last statement ',4);
    pay_in_utils.set_location(g_debug,'Finding diff between live data and 24Q Archival ', 1);

    l_flag := TRUE;
    FOR csr_rec IN c_update_mode_entries(p_payroll_action_id)
    LOOP
        pay_in_utils.set_location(g_debug,'Diff between live data and 24Q Archival found', 1);
        pay_in_utils.set_location(g_debug,'p_payroll_action_id is '|| p_payroll_action_id,2);
        pay_in_utils.set_location(g_debug,'Finding diff between live data and 24Q Correction Archival ', 1);
        pay_in_utils.set_location(g_debug,'csr_rec.last_action_context_id '|| csr_rec.last_action_context_id,2);
        pay_in_utils.set_location(g_debug,'csr_rec.assignment_id          '|| csr_rec.assignment_id         ,2);
        pay_in_utils.set_location(g_debug,'csr_rec.element_entry_id       '|| csr_rec.element_entry_id      ,2);

        l_flag := TRUE;

        FOR c_rec IN c_check_entries_in_24q_correct(csr_rec.last_action_context_id
                                                   ,csr_rec.assignment_id
                                                   ,csr_rec.element_entry_id
                                                   ,'U'
                                                   )
        LOOP
           IF ((c_rec.last_action_context_id IS NOT NULL)AND l_flag)
           THEN
                  l_last_action_context_id := c_rec.last_action_context_id;
                  pay_in_utils.set_location(g_debug,'Record was reported in 24Q Correction',11);
                  pay_in_utils.set_location(g_debug,'with action context id as ' || l_last_action_context_id,1);
                  l_flag := FALSE;
           END IF;
        END LOOP;

        pay_in_utils.set_location(g_debug,'Mid way in finding updated element entries ', 5);
        IF (l_last_action_context_id IS NULL)
        THEN
           pay_in_utils.set_location(g_debug,'Record was not reported in 24Q Correction',1);
           pay_in_utils.set_location(g_debug,'Hence storing earlier values based on 24Q',1);
           g_ee_data_rec_upd(g_count_ee_update).last_action_context_id := csr_rec.last_action_context_id;
           g_ee_data_rec_upd(g_count_ee_update).assignment_id          := csr_rec.assignment_id;
           g_ee_data_rec_upd(g_count_ee_update).element_entry_id       := csr_rec.element_entry_id;
           g_ee_data_rec_upd(g_count_ee_update).deductee_mode          := 'U';
           g_count_ee_update := g_count_ee_update + 1;
        ELSE --Present then need to check the present values with the archived values under Form 24QCorrection
                l_dummy := NULL;
                pay_in_utils.set_location(g_debug,'Record was reported in 24Q Correction',1);
                pay_in_utils.set_location(g_debug,'Need to compare the value from 24Q Correction now',1);
                OPEN  c_24qc_upd_mode_entries(l_last_action_context_id,csr_rec.element_entry_id);
                FETCH c_24qc_upd_mode_entries INTO l_dummy;
                CLOSE c_24qc_upd_mode_entries;

                IF (l_dummy IS NOT NULL) THEN
                     pay_in_utils.set_location(g_debug,'Difference from 24Q Correction Data',1);
                     pay_in_utils.set_location(g_debug,'l_dummy is '|| l_dummy,1);
                     pay_in_utils.set_location(g_debug,'csr_rec.element_entry_id'|| csr_rec.element_entry_id,2);
                     g_ee_data_rec_upd(g_count_ee_update).last_action_context_id := l_dummy;
                     g_ee_data_rec_upd(g_count_ee_update).assignment_id          := csr_rec.assignment_id;
                     g_ee_data_rec_upd(g_count_ee_update).element_entry_id       := csr_rec.element_entry_id;
                     g_ee_data_rec_upd(g_count_ee_update).deductee_mode          := 'U';
                     g_count_ee_update := g_count_ee_update + 1;
                     pay_in_utils.set_location(g_debug,'Stored data as 24Q Correction Data',1);
                END IF;
        END IF;
    END LOOP;
        pay_in_utils.set_location(g_debug,'Additional Checking on updated element entries ', 6);
--Similarly need to repeat the above structure for the case when data after submission to authorities
--was updated, form 24qc generated again updated to original form and 24qc again generated
--The following code checks U for Data under Form 24Q Correction.

-- This cursor finds all those Form 24Q Corrections that are locking Form 24Q
    pay_in_utils.set_location(g_debug,'Now checking those element entries that have same data in live and 24QC ', 7);
    FOR c_rec IN c_form_24qc_locking_id('U',1)
    LOOP

       l_flag  := TRUE;
       l_dummy := NULL;

       pay_in_utils.set_location(g_debug,'Checking 24qc+ and Live Here',1);
       pay_in_utils.set_location(g_debug,'c_rec.last_action_context_id' || c_rec.last_action_context_id,1);
       pay_in_utils.set_location(g_debug,'c_rec.element_entry_id' || c_rec.element_entry_id,2);

       OPEN  c_24qc_upd_mode_entries(c_rec.last_action_context_id,c_rec.element_entry_id);
       FETCH c_24qc_upd_mode_entries INTO l_dummy;
       CLOSE c_24qc_upd_mode_entries;

       IF (l_dummy IS NOT NULL)
       THEN
            pay_in_utils.set_location(g_debug,'Diff found with the Live Data',3);
            FOR i IN 1.. g_count_ee_update - 1
            LOOP
               IF (
                  (g_ee_data_rec_upd(i).last_action_context_id = c_rec.last_action_context_id)
                  AND
                  (g_ee_data_rec_upd(i).assignment_id          = c_rec.assignment_id)
                  AND
                  (g_ee_data_rec_upd(i).element_entry_id       = c_rec.element_entry_id)
                  AND
                  (g_ee_data_rec_upd(i).deductee_mode          = 'U')
                  )
               THEN
                    l_flag := FALSE;
               END IF;
            END LOOP;
       ELSE
            pay_in_utils.set_location(g_debug,'No Diff found with the Live Data',3);
           l_flag  := FALSE;
       END IF;

       IF (l_flag)
       THEN
               g_ee_data_rec_upd(g_count_ee_update).last_action_context_id := c_rec.last_action_context_id;
               g_ee_data_rec_upd(g_count_ee_update).assignment_id          := c_rec.assignment_id;
               g_ee_data_rec_upd(g_count_ee_update).element_entry_id       := c_rec.element_entry_id;
               g_ee_data_rec_upd(g_count_ee_update).deductee_mode          := 'U';
               g_count_ee_update := g_count_ee_update + 1;
       END IF;

    END LOOP;
    --Now Searching for those updated element entries that were created after
    --form 24Q Correction generation
    pay_in_utils.set_location(g_debug,'Now Searching for those updated element entries that were 24QC+',1);
    FOR c_rec IN c_form_24qc_locking_id('A',2)
    LOOP
       l_dummy := NULL;
       pay_in_utils.set_location(g_debug,'c_rec.last_action_context_id '|| c_rec.last_action_context_id,1);
       pay_in_utils.set_location(g_debug,'c_rec.assignment_id          '|| c_rec.assignment_id         ,1);
       pay_in_utils.set_location(g_debug,'c_rec.element_entry_id       '|| c_rec.element_entry_id      ,1);

       OPEN  c_24qc_upd_mode_entries(c_rec.last_action_context_id,c_rec.element_entry_id);
       FETCH c_24qc_upd_mode_entries INTO l_dummy;
       CLOSE c_24qc_upd_mode_entries;
       pay_in_utils.set_location(g_debug,'l_dummy is '|| l_dummy,2);
       IF (l_dummy IS NOT NULL)
       THEN
               g_ee_data_rec_upd(g_count_ee_update).last_action_context_id := c_rec.last_action_context_id;
               g_ee_data_rec_upd(g_count_ee_update).assignment_id          := c_rec.assignment_id;
               g_ee_data_rec_upd(g_count_ee_update).element_entry_id       := c_rec.element_entry_id;
               g_ee_data_rec_upd(g_count_ee_update).deductee_mode          := 'U';
               g_count_ee_update := g_count_ee_update + 1;
       END IF;
    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END generate_employee_data;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_FORMAT_VALUE                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns value with precision          --
--                  of two decimal place                                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_value              VARCHAR2                       --
--------------------------------------------------------------------------
FUNCTION get_format_value(p_value IN VARCHAR2)
RETURN VARCHAR2 IS

l_value      VARCHAR2(20);
l_procedure  VARCHAR2(100);

BEGIN
 g_debug          := hr_utility.debug_enabled;
 l_procedure := g_package ||'.get_format_value';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
 IF g_debug THEN
   pay_in_utils.trace('p_value',p_value);
 END IF;

 IF(NVL(p_value,0)=0) THEN
       RETURN '0.00';
 END IF;

l_value := (p_value*100);

l_value := SUBSTR(l_value,1,length(l_value)-2)||'.'||SUBSTR(l_value,length(l_value)-1,length(l_value));


IF g_debug THEN
     pay_in_utils.trace('l_value',l_value);
END IF;

pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

RETURN l_value;

END get_format_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_24Q_VALUES                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the values corresponding to   --
--                  the F16 Balances                                    --
-- Parameters     :                                                     --
--             IN : p_category          VARCHAR2                        --
--                  p_component_name    VARCHAR2                        --
--                  p_context_id        NUMBER                          --
--                  p_source_id         NUMBER                          --
--                  p_segment_num       NUMBER                          --
--------------------------------------------------------------------------
FUNCTION get_24Q_values (p_category       IN VARCHAR2
                        ,p_component_name IN VARCHAR2
                        ,p_context_id     IN NUMBER
                        ,p_source_id      IN NUMBER
                        ,p_segment_num    IN NUMBER )
RETURN VARCHAR2 IS

CURSOR c_form24Q_values IS
  SELECT  NVL(action_information2,0)
    FROM  pay_action_information
   WHERE  action_information_category = p_category
     AND  action_information1 = p_component_name
     AND  action_context_id = p_context_id
     AND  source_id = p_source_id;

l_value1 VARCHAR2(20);
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'.get_24Q_values';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_category',p_category);
        pay_in_utils.trace('p_component_name',p_component_name);
        pay_in_utils.trace('p_context_id',TO_CHAR(p_context_id));
        pay_in_utils.trace('p_source_id',TO_CHAR(p_source_id));
        pay_in_utils.trace('p_segment_num',TO_CHAR(p_segment_num));
        pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN c_form24Q_values;
  FETCH c_form24Q_values INTO l_value1;
  IF c_form24Q_values%NOTFOUND THEN
    CLOSE c_form24Q_values;
    RETURN '0.00';
  END IF;
  CLOSE c_form24Q_values;

  pay_in_utils.set_location(g_debug,'l_value1 = : '||l_value1,15);

  l_value1 := get_format_value(l_value1);

  pay_in_utils.set_location(g_debug,'l_value1 = : '||l_value1,20);

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,40);

  IF(p_segment_num=1) THEN
       RETURN l_value1;
  END IF;

END get_24Q_values;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GENERATE_SALARY_DATA                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure populates global tables used in      --
  --                  salary detail record                                --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 07-Feb-2007    rpalli    5754018 : 24QC Quarter4 Stat Update   --
  --------------------------------------------------------------------------
 PROCEDURE generate_salary_data(p_payroll_action_id   IN NUMBER
                               ,p_start_person        IN NUMBER
                               ,p_end_person          IN NUMBER)
  IS

    CURSOR c_delete_mode_entries(p_payroll_action_id        NUMBER)
    IS
       SELECT pai.source_id           source_id
             ,pai.assignment_id       assignment_id
             ,pai.action_context_id   last_action_context_id
         FROM pay_action_information pai
             ,pay_assignment_actions paa
        WHERE pai.action_information_category LIKE 'IN_24Q%_PERSON'
          AND fnd_number.canonical_to_number(pai.action_information1)
              BETWEEN p_start_person AND p_end_person
          AND pai.action_context_id = paa.assignment_action_id
          AND
           ( pai.action_information_category = 'IN_24Q_PERSON'
             OR
             (pai.action_information_category = 'IN_24QC_PERSON' AND pai.action_information10 IN ('A'))
            )
          AND(
                paa.payroll_action_id IN (
                                           SELECT org_information3
                                             FROM hr_organization_information
                                            WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                              AND organization_id  = g_gre_id
                                              AND org_information1 = g_year
                                              AND org_information2 = g_quarter
                                              AND org_information5 = 'A'
                                          )
             )
          AND pai.action_information3 = g_gre_id
          AND (
              pai.source_id  NOT IN
             (
             SELECT
                 paa.assignment_action_id run_asg_action_id
             FROM pay_assignment_actions paa
                 ,pay_payroll_actions ppa
                 ,per_assignments_f paf
             WHERE paf.assignment_id = paa.assignment_id
             AND paa.assignment_id = pai.assignment_id
             AND paa.tax_unit_id  = pai.action_information3
             AND paa.payroll_action_id = ppa.payroll_action_id
             AND ppa.action_type IN('R','Q','I','B')
             AND ppa.payroll_id    = paf.payroll_id
             AND ppa.action_status ='C'
             AND ppa.effective_date between g_start_date and g_end_date
             AND paa.source_action_id IS NULL
             AND (1 = DECODE(ppa.action_type,'I',1,0)
             OR EXISTS (SELECT ''
                        FROM pay_action_interlocks intk,
                             pay_assignment_actions paa1,
                             pay_payroll_actions ppa1
                        WHERE intk.locked_action_id = paa.assignment_Action_id
                        AND intk.locking_action_id =  paa1.assignment_action_id
                        AND paa1.payroll_action_id =ppa1.payroll_action_id
                        AND ppa1.action_type in('P','U')
                        AND ppa.action_type in('R','Q','B')
                        AND ppa1.action_status ='C'
                        AND ppa1.effective_date BETWEEN g_start_date and g_end_date
                        AND ROWNUM =1 ))
                      )
             )
         AND (
                pai.source_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions masters
                        WHERE pai.action_information_category = 'IN_24QC_PERSON'
                          AND pai.action_information10        IN  ('D')
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND masters.assignment_id            = pai.assignment_id
                          AND masters.assignment_action_id     = pai.action_context_id
                          AND masters.payroll_action_id IN(
                                                           SELECT org_information3
                                                             FROM hr_organization_information
                                                            WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                              AND organization_id  = g_gre_id
                                                              AND org_information1 = g_year
                                                              AND org_information2 = g_quarter
                                                              AND org_information5 = 'A'
                                                              AND org_information6 = 'C'
                                                     )
                      )
           )
           ORDER BY 2 DESC;

    CURSOR c_addition_mode_entries(p_payroll_action_id        NUMBER)
    IS
    SELECT a.source_id,a.assignment_id,a.last_action_context_id
     FROM
           (SELECT
              FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) source_id
              ,paf.assignment_id       assignment_id
              ,NULL    last_action_context_id
             FROM pay_assignment_actions paa
                 ,pay_payroll_actions ppa
                 ,per_assignments_f paf
             WHERE paf.person_id BETWEEN p_start_person AND p_end_person
             AND paf.assignment_id = paa.assignment_id
             AND paa.tax_unit_id  = g_gre_id
             AND paa.payroll_action_id = ppa.payroll_action_id
             AND ppa.action_type IN('R','Q','I','B')
             AND ppa.payroll_id    = paf.payroll_id
             AND ppa.action_status ='C'
             AND ppa.effective_date between g_start_date and g_end_date
             AND paa.source_action_id IS NULL
             AND (1 = DECODE(ppa.action_type,'I',1,0)
              OR EXISTS (SELECT ''
                        FROM pay_action_interlocks intk,
                             pay_assignment_actions paa1,
                             pay_payroll_actions ppa1
                        WHERE intk.locked_action_id = paa.assignment_Action_id
                        AND intk.locking_action_id =  paa1.assignment_action_id
                        AND paa1.payroll_action_id =ppa1.payroll_action_id
                        AND ppa1.action_type in('P','U')
                        AND ppa.action_type in('R','Q','B')
                        AND ppa1.action_status ='C'
                        AND ppa1.effective_date BETWEEN g_start_date and g_end_date
                        AND ROWNUM =1 ))
                       GROUP BY paf.assignment_id) a
           WHERE (
                  a.source_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_assignment_actions paa
                        WHERE pai.action_information_category = 'IN_24Q_PERSON'
                          AND pai.action_context_id   = paa.assignment_action_id
                          AND paa.payroll_action_id   = p_payroll_action_id
                      )
                )
           AND (
                 a.source_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions paa_24qc
                        WHERE pai.action_information_category = 'IN_24QC_PERSON'
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND pai.action_information2         = g_year||g_quarter
                          AND paa_24qc.assignment_id          = pai.assignment_id
                          AND paa_24qc.assignment_action_id   = pai.action_context_id
                          AND paa_24qc.payroll_action_id IN(
                                                      SELECT org_information3
                                                        FROM hr_organization_information
                                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                         AND organization_id  = g_gre_id
                                                         AND org_information1 = g_year
                                                         AND org_information2 = g_quarter
                                                         AND org_information5 = 'A'
                                                         AND org_information6 = 'C'
                                                     )
                      )
                )
           AND (
                 a.source_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_action_interlocks locks
                             ,pay_assignment_actions paa
                             ,pay_assignment_actions paa_24qc
                        WHERE pai.action_information_category = 'IN_24QC_PERSON'
                          AND locks.locking_action_id         = pai.action_context_id
                          AND locks.locked_action_id          = paa.assignment_action_id
                          AND paa.payroll_action_id           = p_payroll_action_id
                          AND paa.assignment_id               = pai.assignment_id
                          AND pai.action_information2         = g_year||g_quarter
                          AND paa_24qc.assignment_id          = pai.assignment_id
                          AND paa_24qc.assignment_action_id   = pai.action_context_id
                          AND paa_24qc.payroll_action_id IN(
                                                      SELECT org_information3
                                                        FROM hr_organization_information
                                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                         AND organization_id  = g_gre_id
                                                         AND org_information1 = g_year
                                                         AND org_information2 = g_quarter
                                                         AND org_information5 = 'A'
                                                         AND org_information6 = 'C'
                                                     )
                      )
                )
           AND (
                 a.source_id NOT IN
                      (SELECT pai.source_id
                         FROM pay_action_information pai
                             ,pay_assignment_actions paa_24qc
                        WHERE pai.action_information_category = 'IN_24QC_PERSON'
                          AND pai.action_information3         = g_gre_id
                          AND pai.action_information2         = g_year||g_quarter
                          AND paa_24qc.assignment_id          = pai.assignment_id
                          AND paa_24qc.assignment_action_id   = pai.action_context_id
                          AND paa_24qc.payroll_action_id IN(
                                                      SELECT org_information3
                                                        FROM hr_organization_information
                                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                         AND organization_id  = g_gre_id
                                                         AND org_information1 = g_year
                                                         AND org_information2 = g_quarter
                                                         AND org_information5 = 'A'
                                                         AND org_information6 = 'C'
                                                     )
                      )
                )
            ORDER BY 2 DESC;


   CURSOR c_update_mode_entries(p_payroll_action_id        NUMBER
                                )
    IS
       SELECT DISTINCT
              pai.source_id     source_id
             ,pai.assignment_id assignment_id
             ,pai.action_context_id   last_action_context_id
             ,pep.effective_end_date
         FROM pay_action_information pai
             ,pay_assignment_actions  paa
             ,per_people_f            pep
             ,per_assignments_f       asg
        WHERE pai.action_information_category = 'IN_24Q_PERSON'
          AND fnd_number.canonical_to_number(pai.action_information1)
              BETWEEN p_start_person AND p_end_person
          AND pai.action_context_id = paa.assignment_action_id
          AND pai.action_information3 = g_gre_id
          AND paa.payroll_action_id = p_payroll_action_id
          AND asg.assignment_id     = pai.assignment_id
          AND asg.person_id         = pep.person_id
          AND asg.business_group_id = pep.business_group_id
          AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          AND pai.source_id  IN
             (
             SELECT
                 paa.assignment_action_id run_asg_action_id
             FROM pay_assignment_actions paa
                 ,pay_payroll_actions ppa
                 ,per_assignments_f paf
             WHERE paf.person_id BETWEEN p_start_person AND p_end_person
             AND paf.assignment_id = paa.assignment_id
             AND paa.assignment_id = pai.assignment_id
             AND paa.tax_unit_id  = pai.action_information3
             AND paa.payroll_action_id = ppa.payroll_action_id
             AND ppa.action_type IN('R','Q','I','B')
             AND ppa.payroll_id    = paf.payroll_id
             AND ppa.action_status ='C'
             AND ppa.effective_date between g_start_date and g_end_date
             AND paa.source_action_id IS NULL
             AND (1 = DECODE(ppa.action_type,'I',1,0)
             OR EXISTS (SELECT ''
                        FROM pay_action_interlocks intk,
                             pay_assignment_actions paa1,
                             pay_payroll_actions ppa1
                        WHERE intk.locked_action_id = paa.assignment_Action_id
                        AND intk.locking_action_id =  paa1.assignment_action_id
                        AND paa1.payroll_action_id =ppa1.payroll_action_id
                        AND ppa1.action_type in('P','U')
                        AND ppa.action_type in('R','Q','B')
                        AND ppa1.action_status ='C'
                        AND ppa1.effective_date BETWEEN g_start_date and g_end_date
                        AND ROWNUM =1 ))
               )
           AND (
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Salary Under Section 17',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Salary Under Section 17','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Profit in lieu of Salary',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Profit in lieu of Salary','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Value of Perquisites',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Value of Perquisites','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Gross Salary less Allowances',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Gross Salary less Allowances','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Allowances Exempt',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Allowances Exempt','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Deductions under Sec 16',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Deductions under Sec 16','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Income Chargeable Under head Salaries',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Income Chargeable Under head Salaries','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Other Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Other Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Gross Total Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Gross Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Total Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Tax on Total Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Tax on Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Marginal Relief',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Marginal Relief','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Total Tax payable',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Tax payable','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Relief under Sec 89',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Relief under Sec 89','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Employment Tax',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Employment Tax','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Entertainment Allowance',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Entertainment Allowance','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Surcharge',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Surcharge','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Education Cess',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Education Cess','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 TDS',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 TDS','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_SALARY','F16 Total Chapter VI A Deductions',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Chapter VI A Deductions','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24Q_VIA','80CCE',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Deductions Sec 80CCE','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                  (pai.action_information6 <> hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title))
               OR -- Checking PAN reference Number
                   (NVL(pai.action_information5,'0') <> NVL(pep.per_information14,'0'))
               OR ( --Checking PAN Number
                     (
                       g_correction_mode IN ('C5','%')
                       AND (pai.action_information4 NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND (pai.action_information4 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                     )
                     OR
                     (
                       g_correction_mode NOT IN ('C5')
                       AND (pai.action_information4 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))IN('APPLIEDFOR','PANNOTAVBL'))
                     )
                 )
              )
          AND   assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
          AND   assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
          ORDER BY 2,4 DESC;


    CURSOR c_check_entries_in_24q_correct(p_24q_arc_action_context_id NUMBER
                                         ,p_assignment_id             NUMBER
                                         ,p_source_id                 NUMBER
                                         )
    IS
       SELECT pai_locking.action_context_id  last_action_context_id
         FROM pay_action_information pai_locking
             ,pay_action_interlocks locks
             ,pay_assignment_actions paa
        WHERE pai_locking.action_information_category = 'IN_24QC_PERSON'
          AND fnd_number.canonical_to_number(pai_locking.action_information1)
              BETWEEN p_start_person AND p_end_person
          AND pai_locking.action_information3  = g_gre_id
          AND pai_locking.action_context_id    = paa.assignment_action_id
          AND paa.payroll_action_id IN
                                    (
                                      SELECT org_information3
                                        FROM hr_organization_information
                                       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                         AND organization_id  = g_gre_id
                                         AND org_information1 = g_year
                                         AND org_information2 = g_quarter
                                         AND org_information5 = 'A'
                                         AND org_information6 = 'C'
                                    )
          AND locks.locking_action_id          = pai_locking.action_context_id
          AND locks.locked_action_id           = p_24q_arc_action_context_id
          AND pai_locking.assignment_id        = p_assignment_id
          AND pai_locking.source_id            = p_source_id
        ORDER BY pai_locking.action_context_id DESC;

    CURSOR c_24qc_upd_mode_entries(p_assignment_action_id        NUMBER
                                  ,p_source_id                   NUMBER
                                  )
    IS
       SELECT pai.action_context_id
         FROM pay_action_information pai
             ,per_people_f           pep
             ,per_assignments_f      asg
             ,pay_assignment_actions paa
        WHERE pai.action_information_category = 'IN_24QC_PERSON'
          AND fnd_number.canonical_to_number(pai.action_information1)
              BETWEEN p_start_person AND p_end_person
          AND paa.assignment_action_id = pai.action_context_id
          AND pai.source_id     = p_source_id
          AND paa.payroll_action_id IN
                           (
                             SELECT org_information3
                               FROM hr_organization_information
                              WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                AND organization_id  = g_gre_id
                                AND org_information1 = g_year
                                AND org_information2 = g_quarter
                                AND org_information5 = 'A'
                                AND org_information6 = 'C'
                          )
          AND pai.action_information3 = g_gre_id
          AND pai.action_context_id = p_assignment_action_id
          AND asg.assignment_id     = pai.assignment_id
          AND asg.person_id         = pep.person_id
          AND asg.business_group_id = pep.business_group_id
          AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          AND pai.source_id  IN
             (
             SELECT
                 paa.assignment_action_id run_asg_action_id
             FROM pay_assignment_actions paa
                 ,pay_payroll_actions ppa
                 ,per_assignments_f paf
             WHERE paf.person_id BETWEEN p_start_person AND p_end_person
             AND paf.assignment_id = paa.assignment_id
             AND paa.assignment_id = pai.assignment_id
             AND paa.tax_unit_id  = pai.action_information3
             AND paa.payroll_action_id = ppa.payroll_action_id
             AND ppa.action_type IN('R','Q','I','B')
             AND ppa.payroll_id    = paf.payroll_id
             AND ppa.action_status ='C'
             AND ppa.effective_date between g_start_date and g_end_date
             AND paa.source_action_id IS NULL
             AND (1 = DECODE(ppa.action_type,'I',1,0)
                  OR EXISTS (SELECT ''
                             FROM pay_action_interlocks intk,
                                  pay_assignment_actions paa1,
                                  pay_payroll_actions ppa1
                             WHERE intk.locked_action_id = paa.assignment_Action_id
                             AND intk.locking_action_id =  paa1.assignment_action_id
                             AND paa1.payroll_action_id =ppa1.payroll_action_id
                             AND ppa1.action_type in('P','U')
                             AND ppa.action_type in('R','Q','B')
                             AND ppa1.action_status ='C'
                             AND ppa1.effective_date BETWEEN g_start_date and g_end_date
                             AND ROWNUM =1 ))
                )
          AND (
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Salary Under Section 17',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Salary Under Section 17','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Profit in lieu of Salary',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Profit in lieu of Salary','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Value of Perquisites',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Value of Perquisites','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Gross Salary less Allowances',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Gross Salary less Allowances','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Allowances Exempt',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Allowances Exempt','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Deductions under Sec 16',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Deductions under Sec 16','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Income Chargeable Under head Salaries',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Income Chargeable Under head Salaries','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Other Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Other Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Gross Total Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Gross Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Total Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Tax on Total Income',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Tax on Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Marginal Relief',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Marginal Relief','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Total Tax payable',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Tax payable','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Relief under Sec 89',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Relief under Sec 89','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Employment Tax',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Employment Tax','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Entertainment Allowance',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Entertainment Allowance','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Surcharge',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Surcharge','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Education Cess',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Education Cess','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 TDS',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 TDS','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Total Chapter VI A Deductions',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Chapter VI A Deductions','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_VIA','80CCE',pai.action_context_id,pai.source_id,1)))
                   <> FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Deductions Sec 80CCE','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               OR
                  (pai.action_information6 <> hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title))
               OR
                   (NVL(pai.action_information5,'0') <> NVL(pep.per_information14,'0'))
               OR(
                     (
                       g_correction_mode IN ('C5','%')
                       AND (pai.action_information4 NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND (pai.action_information4 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                     )
                     OR
                     (
                       g_correction_mode NOT IN ('C5')
                       AND (pai.action_information4 <> (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))IN('APPLIEDFOR','PANNOTAVBL'))
                     )
                 )
              )
          AND  assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
          AND  assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
          AND NOT EXISTS
          (
       SELECT 1
         FROM pay_action_information pai
             ,per_people_f           pep
             ,per_assignments_f      asg
        WHERE pai.action_information_category = 'IN_24QC_PERSON'
          AND fnd_number.canonical_to_number(pai.action_information1)
              BETWEEN p_start_person AND p_end_person
          AND pai.source_id            = p_source_id
          AND pai.action_information3  = g_gre_id
          AND pai.action_context_id    = p_assignment_action_id
          AND asg.assignment_id        = pai.assignment_id
          AND asg.person_id            = pep.person_id
          AND asg.business_group_id    = pep.business_group_id
          AND asg.business_group_id    = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          AND (
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Salary Under Section 17',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Salary Under Section 17','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Profit in lieu of Salary',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Profit in lieu of Salary','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Value of Perquisites',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Value of Perquisites','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Gross Salary less Allowances',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Gross Salary less Allowances','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Allowances Exempt',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Allowances Exempt','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Deductions under Sec 16',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Deductions under Sec 16','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Income Chargeable Under head Salaries',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Income Chargeable Under head Salaries','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Other Income',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Other Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Gross Total Income',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Gross Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Total Income',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Tax on Total Income',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Tax on Total Income','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Marginal Relief',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Marginal Relief','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Total Tax payable',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Tax payable','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Relief under Sec 89',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Relief under Sec 89','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Employment Tax',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Employment Tax','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Entertainment Allowance',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Entertainment Allowance','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Surcharge',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Surcharge','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Education Cess',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Education Cess','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 TDS',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 TDS','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_SALARY','F16 Total Chapter VI A Deductions',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Total Chapter VI A Deductions','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                 (FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values('IN_24QC_VIA','80CCE',pai.action_context_id,pai.source_id,1)))
                   = FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(pay_in_tax_utils.get_balance_value(pai.source_id,'F16 Deductions Sec 80CCE','_ASG_LE_PTD','TAX_UNIT_ID',g_gre_id))))
               AND
                  (pai.action_information6 = hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title))
               AND(--Checking PAN Number
                     (
                       g_correction_mode IN ('C5','%')
                       AND (pai.action_information4 NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))NOT IN('APPLIEDFOR','PANNOTAVBL'))
                       AND (pai.action_information4 = (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                     )
                     OR
                     (
                       g_correction_mode NOT IN ('C5')
                       AND (pai.action_information4 = (DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4)))
                       AND ((DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4))IN('APPLIEDFOR','PANNOTAVBL'))
                     )
                )
              AND -- Checking PAN reference Number
                  (NVL(pai.action_information5,'0') = NVL(pep.per_information14,'0'))
              )
          AND  assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
          AND  assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
         );

   CURSOR c_form_24qc_locking_id(p_mode           VARCHAR2
                                ,p_flag           NUMBER
                                 )
    IS
      SELECT MAX(pai.action_context_id) last_action_context_id
            ,pai.source_id              source_id
            ,pai.assignment_id          assignment_id
        FROM pay_action_information pai
            ,pay_assignment_actions paa
       WHERE pai.action_information_category = 'IN_24QC_PERSON'
         AND fnd_number.canonical_to_number(pai.action_information1)
              BETWEEN p_start_person AND p_end_person
         AND pai.action_information3         = g_gre_id
         AND pai.action_information2         = g_year||g_quarter
         AND
          (    ((p_flag = 1) AND (pai.action_information10 IN ('A','NA')))
            OR ((p_flag = 2) AND (pai.action_information10 = p_mode))
          )
         AND pai.action_context_id           = paa.assignment_action_id
         AND paa.payroll_action_id IN
                              (
                                SELECT org_information3
                                  FROM hr_organization_information
                                 WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                   AND organization_id  = g_gre_id
                                   AND org_information1 = g_year
                                   AND org_information2 = g_quarter
                                   AND org_information5 = 'A'
                                   AND org_information6 = 'C'
                              )
        AND (
                p_flag = 1
                OR
                (
                 pai.source_id NOT IN(
                                SELECT pai.source_id
                                  FROM pay_action_information pai
                                      ,pay_assignment_actions paa
                                 WHERE pai.action_information_category = 'IN_24QC_PERSON'
                                   AND fnd_number.canonical_to_number(pai.action_information1)
                                       BETWEEN p_start_person AND p_end_person
                                   AND pai.action_information3         = g_gre_id
                                   AND pai.action_information2         = g_year||g_quarter
                                   AND pai.action_information10        = 'D'
                                   AND pai.action_context_id           = paa.assignment_action_id
                                   AND paa.payroll_action_id IN
                                                        (
                                                              SELECT org_information3
                                                                FROM hr_organization_information
                                                               WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                                 AND organization_id  = g_gre_id
                                                                 AND org_information1 = g_year
                                                                 AND org_information2 = g_quarter
                                                                 AND org_information5 = 'A'
                                                                 AND org_information6 = 'C'
                                                        )
                                   )
                   AND pai.source_id IN
                            (SELECT a.source_id
                             FROM
                                 (SELECT
                                    FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) source_id
                                    ,paf.assignment_id       assignment_id
                                    ,NULL    last_action_context_id
                                   FROM pay_assignment_actions paa
                                       ,pay_payroll_actions ppa
                                       ,per_assignments_f paf
                                   WHERE paf.person_id BETWEEN p_start_person AND p_end_person
                                   AND paf.assignment_id = paa.assignment_id
                                   AND paa.tax_unit_id  = g_gre_id
                                   AND paa.payroll_action_id = ppa.payroll_action_id
                                   AND ppa.action_type IN('R','Q','I','B')
                                   AND ppa.payroll_id    = paf.payroll_id
                                   AND ppa.action_status ='C'
                                   AND ppa.effective_date between g_start_date and g_end_date
                                   AND paa.source_action_id IS NULL
                                   AND (1 = DECODE(ppa.action_type,'I',1,0)
                                    OR EXISTS (SELECT ''
                                              FROM pay_action_interlocks intk,
                                                   pay_assignment_actions paa1,
                                                   pay_payroll_actions ppa1
                                              WHERE intk.locked_action_id = paa.assignment_Action_id
                                              AND intk.locking_action_id =  paa1.assignment_action_id
                                              AND paa1.payroll_action_id =ppa1.payroll_action_id
                                              AND ppa1.action_type in('P','U')
                                              AND ppa.action_type in('R','Q','B')
                                              AND ppa1.action_status ='C'
                                              AND ppa1.effective_date BETWEEN g_start_date and g_end_date
                                              AND ROWNUM =1 ))
                                             GROUP BY paf.assignment_id) a
                                                 WHERE
                                       a.assignment_id  = pai.assignment_id)
                 )
            )
        GROUP BY pai.assignment_id,pai.source_id;

    CURSOR c_bg_check(p_assignment_id   NUMBER)
    IS
      SELECT 1
        FROM per_assignments_f
       WHERE business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND assignment_id     = p_assignment_id;

    l_procedure                 VARCHAR2(100);
    l_action_id                 NUMBER;
    l_dummy                     NUMBER;
    l_flag                      BOOLEAN;
    l_last_action_context_id    NUMBER;
    i                           NUMBER;
    l_message                   VARCHAR2(250);
    l_bg_check                  NUMBER;

  --
  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || '.generate_salary_data';

    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    pay_in_utils.trace('p_start_person in  generate_salary_data-> ',p_start_person);
    pay_in_utils.trace('p_end_person in  generate_salary_data-> ',p_end_person);


   --The below process finds those Assignment Actions which have MODE as Deletion(D)
    pay_in_utils.set_location(g_debug,'Finding Assignment Actions deleted since last statement ',2);
   FOR c_rec IN c_delete_mode_entries(p_payroll_action_id)
   LOOP
          l_bg_check := 0;
          OPEN  c_bg_check(c_rec.assignment_id);
          FETCH c_bg_check INTO l_bg_check;
          CLOSE c_bg_check;

          IF (l_bg_check = 1)
          THEN
               g_sal_data_rec_del(g_count_sal_delete).source_id              := c_rec.source_id;
               g_sal_data_rec_del(g_count_sal_delete).last_action_context_id := c_rec.last_action_context_id;
               g_sal_data_rec_del(g_count_sal_delete).assignment_id          := c_rec.assignment_id;
               g_sal_data_rec_del(g_count_sal_delete).salary_mode            := 'D';
               g_count_sal_delete := g_count_sal_delete + 1;
          END IF;
   END LOOP;

    pay_in_utils.set_location(g_debug,'Finding Assignment Actions added since last statement ',3);

--The below process finds those Assignment Actions which have MODE as Addition(A)
    FOR c_rec IN c_addition_mode_entries(p_payroll_action_id)
    LOOP
          l_bg_check := 0;
          OPEN  c_bg_check(c_rec.assignment_id);
          FETCH c_bg_check INTO l_bg_check;
          CLOSE c_bg_check;

          IF (l_bg_check = 1)
          THEN
               g_sal_data_rec_add(g_count_sal_addition).source_id              := c_rec.source_id;
               g_sal_data_rec_add(g_count_sal_addition).last_action_context_id := c_rec.last_action_context_id;
               g_sal_data_rec_add(g_count_sal_addition).assignment_id          := c_rec.assignment_id;
               g_sal_data_rec_add(g_count_sal_addition).salary_mode            := 'A';
               g_count_sal_addition := g_count_sal_addition + 1;
          END IF;
    END LOOP;
  --

--The below process finds those Assignment Actions which have been updated
-- This code checks A from Form 24Q Archival to Live Data
    pay_in_utils.set_location(g_debug,'Finding Assignment Actions updated since last statement ',4);
    pay_in_utils.set_location(g_debug,'Finding diff between live data and 24Q Archival ', 1);

    l_flag := TRUE;
    FOR csr_rec IN c_update_mode_entries(p_payroll_action_id)
    LOOP
        pay_in_utils.set_location(g_debug,'Diff between live data and 24Q Archival found', 1);
        pay_in_utils.set_location(g_debug,'p_payroll_action_id is '|| p_payroll_action_id,1);
        pay_in_utils.set_location(g_debug,'csr_rec.last_action_context_id '|| csr_rec.last_action_context_id,1);
        pay_in_utils.set_location(g_debug,'csr_rec.assignment_id          '|| csr_rec.assignment_id         ,1);
        pay_in_utils.set_location(g_debug,'csr_rec.source_id              '|| csr_rec.source_id      ,1);

        pay_in_utils.set_location(g_debug,'Finding diff between live data and 24Q Correction Archival ', 1);

        l_flag := TRUE;
        l_last_action_context_id := NULL;

        FOR c_rec IN c_check_entries_in_24q_correct(csr_rec.last_action_context_id
                                                   ,csr_rec.assignment_id
                                                   ,csr_rec.source_id
                                                   )
        LOOP
           IF ((c_rec.last_action_context_id IS NOT NULL) AND l_flag)
           THEN
                  l_last_action_context_id := c_rec.last_action_context_id;
                  pay_in_utils.set_location(g_debug,'Record was reported in 24Q Correction',2);
                  pay_in_utils.set_location(g_debug,'with action context id as ' || l_last_action_context_id,2);
                  l_flag := FALSE;
           END IF;
        END LOOP;

        pay_in_utils.set_location(g_debug,'Mid way in finding updated assignment actions', 3);
        pay_in_utils.trace('l_last_action_context_id after  c_check_entries_in_24q_correct is -> ',l_last_action_context_id);

        IF (l_last_action_context_id IS NULL)
        THEN
           pay_in_utils.set_location(g_debug,'Record was not reported in 24Q Correction',4);
           pay_in_utils.set_location(g_debug,'Hence storing earlier values based on 24Q',4);
           g_sal_data_rec_upd(g_count_sal_update).last_action_context_id := csr_rec.last_action_context_id;
           g_sal_data_rec_upd(g_count_sal_update).assignment_id          := csr_rec.assignment_id;
           g_sal_data_rec_upd(g_count_sal_update).source_id              := csr_rec.source_id;
           g_sal_data_rec_upd(g_count_sal_update).salary_mode            := 'U';
           g_count_sal_update := g_count_sal_update + 1;

        ELSE --Present then need to check the present values with the archived values under Form 24QCorrection
                l_dummy := NULL;
                pay_in_utils.set_location(g_debug,'Record was reported in 24Q Correction',5);
                pay_in_utils.set_location(g_debug,'Need to compare the value from 24Q Correction now',5);
                OPEN  c_24qc_upd_mode_entries(l_last_action_context_id,csr_rec.source_id);
                FETCH c_24qc_upd_mode_entries INTO l_dummy;
                CLOSE c_24qc_upd_mode_entries;

                IF (l_dummy IS NOT NULL) THEN
                     pay_in_utils.set_location(g_debug,'Difference from 24Q Correction Data',6);
                     pay_in_utils.set_location(g_debug,'l_dummy is '|| l_dummy,6);
                     pay_in_utils.set_location(g_debug,'csr_rec.source_id'|| csr_rec.source_id,6);
                     g_sal_data_rec_upd(g_count_sal_update).last_action_context_id := l_dummy;
                     g_sal_data_rec_upd(g_count_sal_update).assignment_id          := csr_rec.assignment_id;
                     g_sal_data_rec_upd(g_count_sal_update).source_id              := csr_rec.source_id;
                     g_sal_data_rec_upd(g_count_sal_update).salary_mode            := 'U';
                     g_count_sal_update := g_count_sal_update + 1;

                     pay_in_utils.set_location(g_debug,'Stored data as 24Q Correction Data',6);
                END IF;
        END IF;
    END LOOP;


        pay_in_utils.set_location(g_debug,'Additional Checking on updated assignment actions ', 7);
--Similarly need to repeat the above structure for the case when data after submission to authorities
--was updated, form 24qc generated again updated to original form and 24qc again generated
--The following code checks U for Data under Form 24Q Correction.

-- This cursor finds all those Form 24Q Corrections that are locking Form 24Q
    pay_in_utils.set_location(g_debug,'Now checking those assignment actions that have same data in live and 24QC ', 7);
    FOR c_rec IN c_form_24qc_locking_id('A',1)
    LOOP

       l_flag  := TRUE;
       l_dummy := NULL;

       pay_in_utils.set_location(g_debug,'Checking 24qc+ and Live Here',7);
       pay_in_utils.set_location(g_debug,'c_rec.last_action_context_id' || c_rec.last_action_context_id,7);
       pay_in_utils.set_location(g_debug,'c_rec.source_id' || c_rec.source_id,7);

       OPEN  c_24qc_upd_mode_entries(c_rec.last_action_context_id,c_rec.source_id);
       FETCH c_24qc_upd_mode_entries INTO l_dummy;
       CLOSE c_24qc_upd_mode_entries;

       pay_in_utils.trace('l_dummy in c_form_24qc_locking_id 1',l_dummy);

       IF (l_dummy IS NOT NULL)
       THEN
            pay_in_utils.set_location(g_debug,'Diff found with the Live Data',7);
            FOR i IN 1.. g_count_sal_update - 1
            LOOP
               IF (
                  (g_sal_data_rec_upd(i).last_action_context_id = c_rec.last_action_context_id)
                  AND
                  (g_sal_data_rec_upd(i).assignment_id          = c_rec.assignment_id)
                  AND
                  (g_sal_data_rec_upd(i).source_id       = c_rec.source_id)
                  AND
                  (g_sal_data_rec_upd(i).salary_mode          = 'U')
                  )
               THEN
                    l_flag := FALSE;
               END IF;
            END LOOP;
       ELSE
            pay_in_utils.set_location(g_debug,'No Diff found with the Live Data',7);
           l_flag  := FALSE;
       END IF;

       IF (l_flag)
       THEN
               g_sal_data_rec_upd(g_count_sal_update).last_action_context_id := c_rec.last_action_context_id;
               g_sal_data_rec_upd(g_count_sal_update).assignment_id          := c_rec.assignment_id;
               g_sal_data_rec_upd(g_count_sal_update).source_id              := c_rec.source_id;
               g_sal_data_rec_upd(g_count_sal_update).salary_mode            := 'U';
               g_count_sal_update := g_count_sal_update + 1;

       END IF;

    END LOOP;
    --Now Searching for those updated assignment actions that were created after
    --form 24Q Correction generation
    pay_in_utils.set_location(g_debug,'Now Searching for those updated assignment actions that were 24QC+',8);
    FOR c_rec IN c_form_24qc_locking_id('A',2)
    LOOP
       l_dummy := NULL;
       pay_in_utils.set_location(g_debug,'c_rec.last_action_context_id '|| c_rec.last_action_context_id,8);
       pay_in_utils.set_location(g_debug,'c_rec.assignment_id          '|| c_rec.assignment_id         ,8);
       pay_in_utils.set_location(g_debug,'c_rec.source_id       '|| c_rec.source_id      ,8);

       OPEN  c_24qc_upd_mode_entries(c_rec.last_action_context_id,c_rec.source_id);
       FETCH c_24qc_upd_mode_entries INTO l_dummy;
       CLOSE c_24qc_upd_mode_entries;
       pay_in_utils.set_location(g_debug,'l_dummy is '|| l_dummy,8);
       IF (l_dummy IS NOT NULL)
       THEN
               g_sal_data_rec_upd(g_count_sal_update).last_action_context_id := c_rec.last_action_context_id;
               g_sal_data_rec_upd(g_count_sal_update).assignment_id          := c_rec.assignment_id;
               g_sal_data_rec_upd(g_count_sal_update).source_id              := c_rec.source_id;
               g_sal_data_rec_upd(g_count_sal_update).salary_mode            := 'U';
               g_count_sal_update := g_count_sal_update + 1;

       END IF;
    END LOOP;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,120);
  --

  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END generate_salary_data;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_ORG_DETAILS                                     --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns the live value for an org    --
  -- Parameters     :                                                     --
  --             IN : p_gre_id   NUMBER                                   --
  --            OUT :                                                     --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  -- 115.1 25-Sep-2007    rsaharay  Modified c_pos,c_rep_address          --
  --------------------------------------------------------------------------
  PROCEDURE get_org_details(p_gre_id                IN NUMBER
                           ,p_tan_number           OUT NOCOPY VARCHAR2
                           ,p_deductor_type        OUT NOCOPY VARCHAR2
                           ,p_branch_or_division   OUT NOCOPY VARCHAR2
                           ,p_org_location         OUT NOCOPY NUMBER
                           ,p_pan_number           OUT NOCOPY VARCHAR2
                           ,p_legal_name           OUT NOCOPY VARCHAR2
                           ,p_rep_name             OUT NOCOPY VARCHAR2
                           ,p_rep_position         OUT NOCOPY VARCHAR2
                           ,p_rep_location         OUT NOCOPY NUMBER
                           ,p_rep_email_id         OUT NOCOPY VARCHAR2
                           ,p_rep_work_phone       OUT NOCOPY VARCHAR2
                           ,p_rep_std_code         OUT NOCOPY VARCHAR2
			   ,p_state                OUT NOCOPY VARCHAR2
	                   ,p_pao_code             OUT NOCOPY VARCHAR2
	                   ,p_ddo_code             OUT NOCOPY VARCHAR2
                   	   ,p_ministry_name        OUT NOCOPY VARCHAR2
                           ,p_other_ministry_name  OUT NOCOPY VARCHAR2
                           ,p_pao_reg_code         OUT NOCOPY NUMBER
                   	   ,p_ddo_reg_code         OUT NOCOPY VARCHAR2
                           )
  IS
    CURSOR c_org_inc_tax_df_details
    IS
    SELECT hoi.org_information1        tan
          ,hoi.org_information3        emplr_type
          ,hoi.org_information6        emplr_type_24Q
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
      FROM hr_organization_information hoi
          ,hr_organization_units       hou
     WHERE hoi.organization_id         = p_gre_id
       AND hoi.org_information_context = 'PER_IN_INCOME_TAX_DF'
       AND hou.organization_id         = hoi.organization_id
       AND hou.business_group_id       = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
       AND g_qr_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

    CURSOR c_reg_org_details(p_reg_org_id        NUMBER)
    IS
    SELECT hoi.org_information3        pan
          ,hoi.org_information4        legal_name
      FROM hr_organization_information  hoi
          ,hr_organization_units        hou
     WHERE hoi.organization_id = p_reg_org_id
       AND hoi.org_information_context = 'PER_IN_COMPANY_DF'
       AND hou.organization_id = hoi.organization_id
       AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
       AND g_qr_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

   CURSOR c_pos(p_person_id        NUMBER)
   IS
   SELECT nvl(pos.name,job.name) name
   FROM   per_positions     pos
         ,per_assignments_f asg
         ,per_jobs          job
   WHERE  asg.position_id=pos.position_id(+)
   AND    asg.job_id=job.job_id(+)
   AND    asg.person_id = p_person_id
   AND    asg.primary_flag = 'Y'
   AND    asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
   AND    g_qr_end_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
   AND    g_qr_end_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
   AND    g_qr_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


   CURSOR c_rep_address(p_person_id         NUMBER)
   IS
   SELECT hou.location_id rep_location
     FROM per_assignments_f   asg
         ,hr_organization_units hou
    WHERE asg.person_id = p_person_id
      AND asg.primary_flag = 'Y'
      AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
      AND hou.organization_id = asg.organization_id
      AND hou.business_group_id = asg.business_group_id
      AND g_qr_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND g_qr_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

   CURSOR c_representative_id
   IS
   SELECT pep.person_id
         ,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) rep_name
         ,pep.email_address        email_id
     FROM hr_organization_information   hoi
         ,hr_organization_units         hou
         ,per_people_f              pep
    WHERE hoi.org_information_context = 'PER_IN_INCOME_TAX_REP_DF'
      AND hoi.organization_id = p_gre_id
      AND hou.organization_id = hoi.organization_id
      AND hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
      AND pep.person_id = hoi.org_information1
      AND pep.business_group_id = hou.business_group_id
      AND g_qr_end_date BETWEEN pep.effective_start_date AND pep.effective_end_date
      AND g_qr_end_date BETWEEN fnd_date.canonical_to_date(hoi.org_information2)
      AND NVL(fnd_date.canonical_to_date(hoi.org_information3),TO_DATE('31-12-4712','DD-MM-YYYY'))
      AND g_qr_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));

   CURSOR c_rep_phone(p_person_id         NUMBER)
   IS
   SELECT phone_number rep_phone_no
         ,SUBSTR(phone_number
         ,INSTR(phone_number,'-',1,1) + 1
         ,INSTR(phone_number,'-',1,2) - INSTR(phone_number,'-',1,1) -1
         )STD_CODE
     FROM per_phones
    WHERE parent_id = p_person_id
      AND phone_type =  'W1'
      AND g_qr_end_date BETWEEN date_from AND NVL(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));


   l_reg_org_id          hr_organization_information.org_information4%TYPE;
   l_rep_person_id       per_all_people_f.person_id%TYPE;
   l_emplr_type          hr_organization_information.org_information3%TYPE;
   l_emplr_type_24Q      hr_organization_information.org_information6%TYPE;
   l_procedure           VARCHAR2(250);
   l_message             VARCHAR2(250);
  BEGIN
    g_debug     := hr_utility.debug_enabled;
    l_procedure := g_package ||'.get_org_details';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    pay_in_utils.set_location(g_debug,'Fetching Live Details ',2);
    OPEN  c_org_inc_tax_df_details;
    FETCH c_org_inc_tax_df_details INTO p_tan_number,l_emplr_type,l_emplr_type_24Q,l_reg_org_id,p_branch_or_division,p_org_location
     ,p_state,p_pao_code,p_ddo_code,p_ministry_name,p_other_ministry_name,p_pao_reg_code,p_ddo_reg_code;
    CLOSE c_org_inc_tax_df_details;

    IF g_old_format = 'Y' THEN
    p_deductor_type := l_emplr_type;
    ELSE
    p_deductor_type := l_emplr_type_24Q;
    END IF;

    pay_in_utils.set_location(g_debug,'p_tan_number              : '|| p_tan_number        ,1);
    pay_in_utils.set_location(g_debug,'p_org_location            : '|| p_org_location      ,1);
    pay_in_utils.set_location(g_debug,'p_branch_or_division      : '|| p_branch_or_division,1);
    pay_in_utils.set_location(g_debug,'p_deductor_type           : '|| p_deductor_type     ,1);
    pay_in_utils.set_location(g_debug,'l_reg_org_id              : '|| l_reg_org_id        ,1);
    pay_in_utils.set_location(g_debug,'p_state                   : '|| p_state             ,1);
    pay_in_utils.set_location(g_debug,'p_pao_code                : '|| p_pao_code          ,1);
    pay_in_utils.set_location(g_debug,'p_ddo_code                : '|| p_ddo_code          ,1);
    pay_in_utils.set_location(g_debug,'p_ministry_name           : '|| p_ministry_name     ,1);
    pay_in_utils.set_location(g_debug,'p_other_ministry_name     : '|| p_other_ministry_name ,1);
    pay_in_utils.set_location(g_debug,'p_pao_reg_code            : '|| p_pao_reg_code        ,1);
    pay_in_utils.set_location(g_debug,'p_ddo_reg_code            : '|| p_ddo_reg_code        ,1);

    OPEN  c_reg_org_details(l_reg_org_id);
    FETCH c_reg_org_details INTO p_pan_number,p_legal_name;
    CLOSE c_reg_org_details;

    pay_in_utils.set_location(g_debug,'p_pan_number           : '|| p_pan_number     ,2);
    pay_in_utils.set_location(g_debug,'p_legal_name           : '|| p_legal_name     ,2);

    OPEN  c_representative_id;
    FETCH c_representative_id INTO l_rep_person_id,p_rep_name,p_rep_email_id;
    CLOSE c_representative_id;

    pay_in_utils.set_location(g_debug,'l_rep_person_id           : '|| l_rep_person_id      ,2);
    pay_in_utils.set_location(g_debug,'p_rep_name                : '|| p_rep_name           ,2);
    pay_in_utils.set_location(g_debug,'p_rep_email_id            : '|| p_rep_email_id       ,2);

    OPEN  c_pos(l_rep_person_id);
    FETCH c_pos INTO p_rep_position;
    CLOSE c_pos;

    pay_in_utils.set_location(g_debug,'p_rep_position            : '|| p_rep_position       ,2);

    OPEN  c_rep_address(l_rep_person_id);
    FETCH c_rep_address INTO p_rep_location;
    CLOSE c_rep_address;

    pay_in_utils.set_location(g_debug,'p_rep_location            : '|| p_rep_location       ,2);

    OPEN  c_rep_phone(l_rep_person_id);
    FETCH c_rep_phone INTO p_rep_work_phone,p_rep_std_code;
    CLOSE c_rep_phone;

    pay_in_utils.set_location(g_debug,'p_rep_work_phone           : '|| p_rep_work_phone      ,2);
    pay_in_utils.set_location(g_debug,'p_rep_std_code             : '|| p_rep_std_code           ,2);

    pay_in_utils.set_location(g_debug,'Leaving: '|| g_package||'.get_org_details ',1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END get_org_details;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GENERATE_ORGANIZATION_DATA                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure populates global tables used in      --
  --                  organization detail record                          --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE generate_organization_data(p_payroll_action_id   IN NUMBER
                                      ,p_gre_id              IN NUMBER
                                      )
  IS
  -- The below cursor finds the Form 24Q Correction locking the Form 24Q Archival
  -- for a particulatr GRE as passed in the p_payroll_action_id
    CURSOR c_locking_24qc_pa_data
    IS
       SELECT DISTINCT pai.action_context_id locking_id
             ,pai.action_information1        gre_id
         FROM pay_action_information pai
        WHERE pai.action_context_type = 'PA'
          AND pai.action_information_category = 'IN_24QC_ORG'
          AND pai.action_information1  = p_gre_id
          AND pai.action_information3 = g_year||g_quarter
          AND pai.source_id = p_payroll_action_id
          AND pai.action_context_id IN
                           (
                             SELECT org_information3
                               FROM hr_organization_information
                              WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                AND organization_id  = g_gre_id
                                AND org_information1 = g_year
                                AND org_information2 = g_quarter
                                AND org_information5 = 'A'
                                AND org_information6 = 'C'
                          )
        ORDER BY pai.action_context_id DESC;

  -- This cursor fetches the GREs that were reported in Form 24Q Archival
    CURSOR c_chk_organization
    IS
       SELECT action_information1 gre_id
         FROM pay_action_information
        WHERE action_information_category = 'IN_24Q_ORG'
          AND action_context_type = 'PA'
          AND action_information1 = p_gre_id
          AND action_information3 = g_year||g_quarter
          AND action_context_id   = p_payroll_action_id;

  -- After fetching the above values, need to take a diff of their archived data
  -- and live data. Also, diff of live and 24Q Correction data.
  -- For doing so first find the live data values.

   CURSOR c_diff_with_24q_data(p_gre_id             NUMBER
                               ,p_tan_number         VARCHAR2
                               ,p_deductor_type      VARCHAR2
                               ,p_branch_or_division VARCHAR2
                               ,p_org_location       NUMBER
                               ,p_pan_number         VARCHAR2
                               ,p_legal_name         VARCHAR2
                               ,p_rep_name           VARCHAR2
                               ,p_rep_position       VARCHAR2
                               ,p_rep_location       NUMBER
                               ,p_rep_email_id       VARCHAR2
                               ,p_rep_work_phone     VARCHAR2
                               ,p_rep_std_code       VARCHAR2
                               ,p_act_inf_category   VARCHAR2
                               ,p_action_context_id  NUMBER
                               )
    IS
       SELECT pai.action_context_id     last_action_context_id
         FROM pay_action_information pai
        WHERE pai.action_information_category = p_act_inf_category
          AND pai.action_context_type   = 'PA'
          AND pai.action_context_id     = p_action_context_id
          AND pai.action_information1   = p_gre_id
          AND pai.action_information2   = p_tan_number
          AND pai.action_information3   = g_year||g_quarter
          AND(
               (pai.action_information4  <> p_pan_number)
              OR
               (pai.action_information5  <> p_legal_name)
              OR
               (pai.action_information6  <> p_org_location)
              OR
               (pai.action_information7  <> p_deductor_type)
              OR
               (pai.action_information8  <> p_branch_or_division)
              OR
               (pai.action_information9  <> p_rep_name)
              OR
               (pai.action_information10 <> p_rep_email_id)
              OR
               (pai.action_information11 <> p_rep_position)
              OR
               (pai.action_information12 <> p_rep_location)
              OR
               (pai.action_information13 <> p_rep_work_phone)
              OR
               (SUBSTR(pai.action_information13
                      ,INSTR(pai.action_information13,'-',1,1) + 1
                      ,INSTR(pai.action_information13,'-',1,2) - INSTR(pai.action_information13,'-',1,1) -1
                      )                  <> p_rep_std_code
               )
              OR
               (DECODE(p_act_inf_category,'IN_24Q_ORG',p_rep_std_code,pai.action_information14) <> p_rep_std_code)
              );

CURSOR c_diff_with_24q_data_new(p_gre_id             NUMBER
                               ,p_tan_number         VARCHAR2
                               ,p_deductor_type      VARCHAR2
                               ,p_branch_or_division VARCHAR2
                               ,p_org_location       NUMBER
                               ,p_pan_number         VARCHAR2
                               ,p_legal_name         VARCHAR2
                               ,p_rep_name           VARCHAR2
                               ,p_rep_position       VARCHAR2
                               ,p_rep_location       NUMBER
                               ,p_rep_email_id       VARCHAR2
                               ,p_rep_work_phone     VARCHAR2
                               ,p_rep_std_code       VARCHAR2
                               ,p_act_inf_category   VARCHAR2
                               ,p_action_context_id  NUMBER
			       ,p_state              VARCHAR2
                               ,p_pao_code           VARCHAR2
                               ,p_ddo_code           VARCHAR2
                               ,p_ministry_name      VARCHAR2
                               ,p_other_ministry_name VARCHAR2
                               ,p_pao_reg_code        NUMBER
                               ,p_ddo_reg_code        VARCHAR2
                               )
    IS
       SELECT pai.action_context_id     last_action_context_id
         FROM pay_action_information pai
        WHERE pai.action_information_category = p_act_inf_category
          AND pai.action_context_type   = 'PA'
          AND pai.action_context_id     = p_action_context_id
          AND pai.action_information1   = p_gre_id
          AND pai.action_information2   = p_tan_number
          AND pai.action_information3   = g_year||g_quarter
          AND(
               (pai.action_information4  <> p_pan_number)
              OR
               (pai.action_information5  <> p_legal_name)
              OR
               (pai.action_information6  <> p_org_location)
              OR
               (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information21,pai.action_information7) <> p_deductor_type)
              OR
               (pai.action_information8  <> p_branch_or_division)
              OR
               (pai.action_information9  <> p_rep_name)
              OR
               (pai.action_information10 <> p_rep_email_id)
              OR
               (pai.action_information11 <> p_rep_position)
              OR
               (pai.action_information12 <> p_rep_location)
              OR
               (pai.action_information13 <> p_rep_work_phone)
	      OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information14,pai.action_information20) <> p_state)
              OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information15,pai.action_information21) <> p_pao_code)
              OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information16,pai.action_information22) <> p_ddo_code)
              OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information17,pai.action_information23) <> p_ministry_name)
              OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information18,pai.action_information24) <> p_other_ministry_name)
              OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information19,pai.action_information27) <> p_pao_reg_code)
              OR
              (DECODE(p_act_inf_category,'IN_24Q_ORG',pai.action_information20,pai.action_information28) <> p_ddo_reg_code)
              OR
               (SUBSTR(pai.action_information13
                      ,INSTR(pai.action_information13,'-',1,1) + 1
                      ,INSTR(pai.action_information13,'-',1,2) - INSTR(pai.action_information13,'-',1,1) -1
                      )                  <> p_rep_std_code
               )
              OR
               (DECODE(p_act_inf_category,'IN_24Q_ORG',p_rep_std_code,pai.action_information14) <> p_rep_std_code)
              );
--
       l_last_action_context_id   NUMBER;
       l_dummy                    NUMBER;
       l_flag                     BOOLEAN;
       l_tan_number               hr_organization_information.org_information1%TYPE;
       l_deductor_type            hr_organization_information.org_information3%TYPE;
       l_branch_or_division       hr_organization_information.org_information7%TYPE;
       l_org_location             hr_organization_units.location_id%TYPE;
       l_pan_number               hr_organization_information.org_information3%TYPE;
       l_legal_name               hr_organization_information.org_information4%TYPE;
       l_state                    hr_organization_information.org_information9%TYPE;
       l_pao_code                 hr_organization_information.org_information10%TYPE;
       l_ddo_code                 hr_organization_information.org_information11%TYPE;
       l_ministry_name            hr_organization_information.org_information12%TYPE;
       l_other_ministry_name      hr_organization_information.org_information13%TYPE;
       l_pao_reg_code             hr_organization_information.org_information14%TYPE;
       l_ddo_reg_code             hr_organization_information.org_information15%TYPE;
       l_rep_name                 per_all_people_f.full_name%TYPE;
       l_rep_position             per_all_positions.name%TYPE;
       l_rep_location             hr_organization_units.location_id%TYPE;
       l_rep_email_id             per_all_people_f.email_address%TYPE;
       l_rep_work_phone           per_phones.phone_number%TYPE;
       l_rep_std_code             per_phones.phone_number%TYPE;
       l_procedure                VARCHAR2(250);
       l_message                  VARCHAR2(250);
  BEGIN
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'.generate_organization_data';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     FOR c_rec IN c_chk_organization
     LOOP
        pay_in_utils.set_location(g_debug,'Organization ID in Form 24Q Archival is '||c_rec.gre_id,2);
        pay_in_utils.set_location(g_debug,'Fetching Live GRE Details',2);
        get_org_details(c_rec.gre_id,
                        l_tan_number,
                        l_deductor_type,
                        l_branch_or_division,
                        l_org_location,
                        l_pan_number,
                        l_legal_name,
                        l_rep_name,
                        l_rep_position,
                        l_rep_location,
                        l_rep_email_id,
                        l_rep_work_phone,
                        l_rep_std_code,
			l_state,
                        l_pao_code,
                        l_ddo_code,
                        l_ministry_name,
                        l_other_ministry_name,
                        l_pao_reg_code,
                        l_ddo_reg_code
                       );

        pay_in_utils.set_location(g_debug,'Fetched Live GRE Details ',3);
        pay_in_utils.set_location(g_debug,'Checking Diff with 24Q Archived Data',4);

	IF g_old_format = 'Y' THEN
                OPEN  c_diff_with_24q_data(c_rec.gre_id,
                                   l_tan_number,
                                   l_deductor_type,
                                   l_branch_or_division,
                                   l_org_location,
                                   l_pan_number,
                                   l_legal_name,
                                   l_rep_name,
                                   l_rep_position,
                                   l_rep_location,
                                   l_rep_email_id,
                                   l_rep_work_phone,
                                   l_rep_std_code,
                                   'IN_24Q_ORG',
                                   p_payroll_action_id
                                  );
               FETCH c_diff_with_24q_data INTO l_last_action_context_id;
               CLOSE c_diff_with_24q_data;
        ELSE
              OPEN  c_diff_with_24q_data_new(c_rec.gre_id,
                                   l_tan_number,
                                   l_deductor_type,
                                   l_branch_or_division,
                                   l_org_location,
                                   l_pan_number,
                                   l_legal_name,
                                   l_rep_name,
                                   l_rep_position,
                                   l_rep_location,
                                   l_rep_email_id,
                                   l_rep_work_phone,
                                   l_rep_std_code,
                                   'IN_24Q_ORG',
                                   p_payroll_action_id,
				   l_state,
                                   l_pao_code,
                                   l_ddo_code,
                                   l_ministry_name,
                                   l_other_ministry_name,
                                   l_pao_reg_code,
                                   l_ddo_reg_code
                                  );
            FETCH c_diff_with_24q_data_new INTO l_last_action_context_id;
            CLOSE c_diff_with_24q_data_new;
	END IF;

        pay_in_utils.set_location(g_debug,'Last Action Context ID in 24Q is :'|| l_last_action_context_id,5);
        IF (l_last_action_context_id IS NOT NULL)
        THEN
        -- This means that there is a diff from archived and present data.
        -- So need to check whether this diff was reported in any of the
        -- Form 24Q Corrections or not. For this find the Form 24Q Corrections
        -- on top of Form 24Q Archival and check if any of them has data as per
        -- present live data. If they too dont have any record, then need to
        -- insert this org data in a PL/SQL table.
           pay_in_utils.set_location(g_debug,'Diff with live and and 24Q Data found..',2);
              l_flag := TRUE;

              FOR csr_rec IN c_locking_24qc_pa_data
              LOOP
                     pay_in_utils.set_location(g_debug,'Checking Diff in 24Q Correction Data',6);

	       IF g_old_format = 'Y' THEN
                     OPEN  c_diff_with_24q_data(c_rec.gre_id,
                                                l_tan_number,
                                                l_deductor_type,
                                                l_branch_or_division,
                                                l_org_location,
                                                l_pan_number,
                                                l_legal_name,
                                                l_rep_name,
                                                l_rep_position,
                                                l_rep_location,
                                                l_rep_email_id,
                                                l_rep_work_phone,
                                                l_rep_std_code,
                                                'IN_24QC_ORG',
                                                csr_rec.locking_id
                                                );
                      FETCH c_diff_with_24q_data INTO l_dummy;
                      CLOSE c_diff_with_24q_data;
                ELSE
                     OPEN  c_diff_with_24q_data_new(c_rec.gre_id,
                                                l_tan_number,
                                                l_deductor_type,
                                                l_branch_or_division,
                                                l_org_location,
                                                l_pan_number,
                                                l_legal_name,
                                                l_rep_name,
                                                l_rep_position,
                                                l_rep_location,
                                                l_rep_email_id,
                                                l_rep_work_phone,
                                                l_rep_std_code,
                                                'IN_24QC_ORG',
                                                csr_rec.locking_id,
						l_state,
                                                l_pao_code,
                                                l_ddo_code,
                                                l_ministry_name,
                                                l_other_ministry_name,
                                                l_pao_reg_code,
                                                l_ddo_reg_code
                                                );
                     FETCH c_diff_with_24q_data_new INTO l_dummy;
                     CLOSE c_diff_with_24q_data_new;
                  END IF;
                     IF ((l_dummy IS NULL)AND (l_flag))
                     THEN
                            pay_in_utils.set_location(g_debug,'Diff in 24Q Correction Data Found',6);
                           l_flag := FALSE;
                     END IF;
              END LOOP;

              IF (l_flag)
              THEN
                    g_org_data(g_count_org).gre_id                  := c_rec.gre_id;
                    g_org_data(g_count_org).last_action_context_id  := p_payroll_action_id;
                    g_count_org := g_count_org + 1;
              END IF;
        END IF;
     END LOOP;

     --The above logic found all those values of GRE that had a change from
     --24Q Archival to present state without getting reported in 24QC.
     --The following code finds those GREs that have undergone a change from
     --the last correction statement.
     FOR c_record IN c_locking_24qc_pa_data
     LOOP
        get_org_details(c_record.gre_id,
                        l_tan_number,
                        l_deductor_type,
                        l_branch_or_division,
                        l_org_location,
                        l_pan_number,
                        l_legal_name,
                        l_rep_name,
                        l_rep_position,
                        l_rep_location,
                        l_rep_email_id,
                        l_rep_work_phone,
                        l_rep_std_code,
			l_state,
                        l_pao_code,
                        l_ddo_code,
                        l_ministry_name,
                        l_other_ministry_name,
                        l_pao_reg_code,
                        l_ddo_reg_code
                       );
     IF g_old_format = 'Y' THEN
         OPEN  c_diff_with_24q_data(c_record.gre_id,
                                  l_tan_number,
                                  l_deductor_type,
                                  l_branch_or_division,
                                  l_org_location,
                                  l_pan_number,
                                  l_legal_name,
                                  l_rep_name,
                                  l_rep_position,
                                  l_rep_location,
                                  l_rep_email_id,
                                  l_rep_work_phone,
                                  l_rep_std_code,
                                  'IN_24QC_ORG',
                                  c_record.locking_id
                                  );
          FETCH c_diff_with_24q_data INTO l_dummy;
          CLOSE c_diff_with_24q_data;
       ELSE
          OPEN  c_diff_with_24q_data_new(c_record.gre_id,
                                  l_tan_number,
                                  l_deductor_type,
                                  l_branch_or_division,
                                  l_org_location,
                                  l_pan_number,
                                  l_legal_name,
                                  l_rep_name,
                                  l_rep_position,
                                  l_rep_location,
                                  l_rep_email_id,
                                  l_rep_work_phone,
                                  l_rep_std_code,
                                  'IN_24QC_ORG',
                                  c_record.locking_id,
				  l_state,
                                  l_pao_code,
                                  l_ddo_code,
                                  l_ministry_name,
                                  l_other_ministry_name,
                                  l_pao_reg_code,
                                  l_ddo_reg_code
                                  );
           FETCH c_diff_with_24q_data_new INTO l_dummy;
           CLOSE c_diff_with_24q_data_new;
       END IF;
        l_flag := TRUE;

        IF (l_dummy IS NOT NULL)
        THEN
        -- Then this means that there is a difference from this corrections
        -- statement to the present live data, hence need to store this GRE
        -- and last action context id, but need to check that this correction
        -- might have been superceded by another correction. So check in global
        -- PL/SQL table, if this GRE ID exists then dont insert a new record.
                FOR i IN 1..g_count_org - 1
                LOOP
                   IF ((g_org_data(i).gre_id = c_record.gre_id)AND(l_flag)AND(g_org_data(i).last_action_context_id < l_dummy))
                   THEN
                        l_flag := FALSE;
                        g_org_data(i).last_action_context_id := l_dummy;
                   END IF;
                END LOOP;

                IF (l_flag)
                THEN
                    g_org_data(g_count_org).gre_id                  := c_record.gre_id;
                    g_org_data(g_count_org).last_action_context_id  := l_dummy;
                    g_count_org := g_count_org + 1;
                END IF;
        END IF;
     END LOOP;
     pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.generate_organization_data ',5);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END generate_organization_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GENERATE_CHALLAN_DATA                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure populates PL/SQL table for challans  --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE generate_challan_data(p_payroll_action_id     IN NUMBER
                                 ,p_gre_id                IN NUMBER
                                 )
  IS
    CURSOR c_challan_live_data_master(p_tax_year       VARCHAR2
                                     ,p_challan_number VARCHAR2
                                     ,p_org_info_id    NUMBER
                                     )
    IS
      SELECT hoi.org_information3           challan_number,
             hoi.org_information2           transfer_voucher_date,
             hoi.org_information4           amount,
             hoi.org_information7           surcharge,
             hoi.org_information8           education_cess,
             hoi.org_information10          other,
             hoi.org_information9           interest,
             (SELECT hoi_bank.org_information4
               FROM hr_organization_information hoi_bank
              WHERE hoi_bank.organization_id = p_gre_id
                AND hoi_bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                AND hoi_bank.org_information_id = hoi.org_information5
             )                              bank_branch_code,
             hoi.org_information11          cheque_dd_num,
             hoi.org_information_id         org_information_id
        FROM hr_organization_information hoi
       WHERE hoi.org_information_id IN
       (
            SELECT hoi.org_information_id
              FROM hr_organization_information hoi
                  ,hr_organization_units hou
             WHERE hoi.organization_id     = p_gre_id
               AND  hoi.organization_id    = hou.organization_id
               AND  hou.business_group_id  = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
               AND org_information_context = 'PER_IN_IT_CHALLAN_INFO'
       )
         AND hoi.org_information13 = g_quarter
         AND hoi.org_information1  = p_tax_year
         AND(
	     hoi.org_information3 LIKE p_challan_number
             OR
             hoi.org_information_id  = p_org_info_id
            );

  --The below cursor gives the value of Challan Details as in the live Data.
  -- This cursor can return all the values as well as specific also based on
  -- p_challan_number and p_org_info_id
    CURSOR c_challan_live_data(p_tax_year       VARCHAR2
                              ,p_challan_number VARCHAR2
                              ,p_org_info_id    NUMBER
                              )
    IS
      SELECT hoi.org_information3           challan_number,
             hoi.org_information2           transfer_voucher_date,
             hoi.org_information4           amount,
             hoi.org_information7           surcharge,
             hoi.org_information8           education_cess,
             hoi.org_information10          other,
             hoi.org_information9           interest,
             (SELECT hoi_bank.org_information4
               FROM hr_organization_information hoi_bank
              WHERE hoi_bank.organization_id = p_gre_id
                AND hoi_bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                AND hoi_bank.org_information_id = hoi.org_information5
             )                              bank_branch_code,
             hoi.org_information11          cheque_dd_num,
             hoi.org_information_id         org_information_id
        FROM hr_organization_information hoi
       WHERE hoi.org_information_id IN
       (
            SELECT hoi.org_information_id
              FROM hr_organization_information hoi
                  ,hr_organization_units hou
             WHERE hoi.organization_id     = p_gre_id
               AND  hoi.organization_id    = hou.organization_id
               AND  hou.business_group_id  = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
               AND org_information_context = 'PER_IN_IT_CHALLAN_INFO'
       )
         AND hoi.org_information13 = g_quarter
         AND hoi.org_information1  = p_tax_year
         AND(
             hoi.org_information3 LIKE SUBSTR(p_challan_number ,INSTR (p_challan_number, ' -',1,1)+3,(INSTR (p_challan_number, ' -',1,2)-(INSTR (p_challan_number, ' -',1,1)+3)))
             OR
             hoi.org_information_id  = p_org_info_id
            );

    CURSOR c_challan_24q_data_master(p_act_info_category     VARCHAR2
                                    ,p_voucher_number        VARCHAR2
                                    ,p_org_information_id    NUMBER
                                     )
    IS
      SELECT action_information_id,
             action_information1     transfer_voucher_number,
             action_information4     bank_branch_code,
             action_information5     transfer_voucher_date,
             action_information6     amount,
             action_information7     surcharge,
             action_information8     cess,
             action_information9     interest,
             action_information10    other,
             action_information11    cheque_dd_num,
             source_id               org_information_id
        FROM pay_action_information
       WHERE action_information2         = g_year||g_quarter
         AND action_information3         = p_gre_id
         AND action_information_category = p_act_info_category
         AND action_context_id IN
                               (
                                 SELECT org_information3
                                   FROM hr_organization_information
                                  WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                    AND organization_id  = g_gre_id
                                    AND org_information1 = g_year
                                    AND org_information2 = g_quarter
                                    AND org_information5 = 'A'
                              )
         AND DECODE(p_act_info_category
                   ,'IN_24Q_CHALLAN'
                   ,action_context_id
                   ,p_payroll_action_id
                   )                    = p_payroll_action_id
         AND (
              action_information1 LIKE p_voucher_number
             OR
              source_id         =  p_org_information_id
             )
         AND DECODE(p_act_info_category
                   ,'IN_24QC_CHALLAN'
                   ,action_information15
                   ,p_payroll_action_id
                   ) = p_payroll_action_id
      ORDER BY action_information_id DESC;

    -- The below cursor fetches data both from Form 24Q Archival
    -- and Form 24Q Corrections. This cursor can retrun data specific to
    -- challan number or org_information_id
    CURSOR c_challan_24q_data(p_act_info_category     VARCHAR2
                             ,p_voucher_number        VARCHAR2
                             ,p_org_information_id    NUMBER
                             )
    IS
      SELECT action_information_id,
             action_information1     transfer_voucher_number,
             action_information4     bank_branch_code,
             action_information5     transfer_voucher_date,
             action_information6     amount,
             action_information7     surcharge,
             action_information8     cess,
             action_information9     interest,
             action_information10    other,
             action_information11    cheque_dd_num,
             source_id               org_information_id
        FROM pay_action_information
       WHERE action_information2         = g_year||g_quarter
         AND action_information3         = p_gre_id
         AND action_information_category = p_act_info_category
         AND action_context_id IN
                               (
                                 SELECT org_information3
                                   FROM hr_organization_information
                                  WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                    AND organization_id  = g_gre_id
                                    AND org_information1 = g_year
                                    AND org_information2 = g_quarter
                                    AND org_information5 = 'A'
                              )
         AND DECODE(p_act_info_category
                   ,'IN_24Q_CHALLAN'
                   ,action_context_id
                   ,p_payroll_action_id
                   )                    = p_payroll_action_id
         AND (
              action_information1 LIKE p_voucher_number
             OR
              source_id         =  p_org_information_id
             )
         AND DECODE(p_act_info_category
                   ,'IN_24QC_CHALLAN'
                   ,action_information15
                   ,p_payroll_action_id
                   ) = p_payroll_action_id
      ORDER BY action_information_id DESC;

    l_transfer_voucher_number     hr_organization_information.org_information3%TYPE;
    l_transfer_voucher_date       hr_organization_information.org_information2%TYPE;
    l_amount                      hr_organization_information.org_information4%TYPE;
    l_surcharge                   hr_organization_information.org_information7%TYPE;
    l_education_cess              hr_organization_information.org_information8%TYPE;
    l_interest                    hr_organization_information.org_information9%TYPE;
    l_others                      hr_organization_information.org_information10%TYPE;
    l_bank_branch_code            hr_organization_information.org_information4%TYPE;
    l_cheque_dd_num               hr_organization_information.org_information11%TYPE;
    l_org_information_id          NUMBER;
    l_action_information_id       NUMBER;

    l_transfer_voucher_number_1   hr_organization_information.org_information3%TYPE;
    l_transfer_voucher_date_1     hr_organization_information.org_information2%TYPE;
    l_amount_1                    hr_organization_information.org_information4%TYPE;
    l_surcharge_1                 hr_organization_information.org_information7%TYPE;
    l_education_cess_1            hr_organization_information.org_information8%TYPE;
    l_interest_1                  hr_organization_information.org_information9%TYPE;
    l_others_1                    hr_organization_information.org_information10%TYPE;
    l_bank_branch_code_1          hr_organization_information.org_information4%TYPE;
    l_cheque_dd_num_1             hr_organization_information.org_information11%TYPE;
    l_org_information_id_1        NUMBER;
    l_dummy_boolean               BOOLEAN;
    l_dummy                       hr_organization_information.org_information3%TYPE;
    l_procedure                   VARCHAR2(250);
    l_message                     VARCHAR2(250);
  BEGIN
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'.generate_challan_data';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    -- First Search for those challans that have been added since Form 24Q
    -- Last generation but were not reported in Form 24Q Correction.
    -- For this check existence of Live Challan Number in 24Q Archival.
    -- If its not there, then check its existence in Form 24Q Corrections
    -- done on its top. If its not even there, then this shows addition of
    -- challans.

    FOR c_rec IN c_challan_live_data_master(g_tax_year,'%',NULL)
    LOOP
       pay_in_utils.set_location(g_debug,'Fetching Live Data ', 2);
       -- For the fetched live data checking its presence in 24Q Archived Data
       l_dummy_boolean  := TRUE;
       l_dummy          := NULL;


       FOR csr_record IN c_challan_24q_data('IN_24Q_CHALLAN',NVL(c_rec.bank_branch_code,'BOOK')||' - '||c_rec.challan_number||' - '||to_char(fnd_date.canonical_to_date(c_rec.transfer_voucher_date),'DD-Mon-RRRR') ,NULL)
       LOOP

                IF (l_dummy_boolean)
                THEN
                   pay_in_utils.set_location(g_debug,'Checking 24Q Archived Data',3);
                   l_dummy := csr_record.transfer_voucher_number;
                   l_dummy_boolean  := FALSE;
                END IF;
       END LOOP;


       IF (l_dummy IS NULL)
       THEN
        -- This means that the present challan data was not reported in
        -- Form 24Q Archival. However this challan number might have been updated
        -- to a different challan number. So check in Form 24Q Archived Data for the
        -- presence of this record's org_information_id
           pay_in_utils.set_location(g_debug,'Again opened',1);
           l_dummy_boolean  := TRUE;
           FOR csr_record IN c_challan_24q_data('IN_24Q_CHALLAN',NULL,c_rec.org_information_id)
           LOOP
                 IF (l_dummy_boolean)
                THEN
                        l_dummy := csr_record.transfer_voucher_number;
                        l_dummy_boolean  := FALSE;
                END IF;
              pay_in_utils.set_location(g_debug,'Again opened',2);
           END LOOP;

           IF (l_dummy IS NULL)
           THEN
                -- This means that in 24Q Archival this record was never present. So,
                -- need to check in Form 24Q Correction, firstly on the basis of
                -- Challan Number and then on basis of org_information_id
                pay_in_utils.set_location(g_debug,'Again opened',3);
                l_dummy_boolean  := TRUE;
                FOR csr_record IN c_challan_24q_data('IN_24QC_CHALLAN',NVL(c_rec.bank_branch_code,'BOOK')||' - '||c_rec.challan_number||' - '||to_char(fnd_date.canonical_to_date(c_rec.transfer_voucher_date),'DD-Mon-RRRR') ,NULL)
                LOOP
                IF (l_dummy_boolean)
                THEN
                        l_dummy := csr_record.transfer_voucher_number;
                        pay_in_utils.set_location(g_debug,'Again opened',4);
                        l_dummy_boolean  := FALSE;
                END IF;
                END LOOP;

                  pay_in_utils.set_location(g_debug,'Again opened',5);
                  IF (l_dummy IS NULL)
                  THEN
                        -- This means that in Form 24QC no record with c_rec.challan_number
                        -- was reported. However this may happen that challan number was
                        -- updated and hence got reported in Form 24Q Correction. So,
                        -- checking in correction data again using org_information_id.
                         pay_in_utils.set_location(g_debug,'Again opened',6);
                         l_dummy_boolean  := TRUE;
                        FOR csr_record IN c_challan_24q_data('IN_24QC_CHALLAN',NULL,c_rec.org_information_id)
                        LOOP
                             IF (l_dummy_boolean)
                             THEN
                                  l_dummy := csr_record.transfer_voucher_number;
                                  pay_in_utils.set_location(g_debug,'Again opened',7);
                                  l_dummy_boolean  := FALSE;
                             END IF;
                        END LOOP;

                        pay_in_utils.set_location(g_debug,'Again opened',8);
                        IF (l_dummy IS NULL)
                        THEN
                           --This means that in Form 24Q Correction, this record was never
                           -- present. So need to insert this record data in PL/SQL table.
                           g_challan_data_add(g_count_challan_add).transfer_voucher_number := NVL(c_rec.bank_branch_code,'BOOK')||' - '||c_rec.challan_number||' - '||to_char(fnd_date.canonical_to_date(c_rec.transfer_voucher_date),'DD-Mon-RRRR') ;
                           g_challan_data_add(g_count_challan_add).transfer_voucher_date   := c_rec.transfer_voucher_date;
                           g_challan_data_add(g_count_challan_add).amount                  := c_rec.amount;
                           g_challan_data_add(g_count_challan_add).surcharge               := c_rec.surcharge;
                           g_challan_data_add(g_count_challan_add).education_cess          := c_rec.education_cess;
                           g_challan_data_add(g_count_challan_add).interest                := c_rec.interest;
                           g_challan_data_add(g_count_challan_add).other                   := c_rec.other;
                           g_challan_data_add(g_count_challan_add).bank_branch_code        := c_rec.bank_branch_code;
                           g_challan_data_add(g_count_challan_add).cheque_dd_num           := c_rec.cheque_dd_num;
                           g_challan_data_add(g_count_challan_add).org_information_id      := c_rec.org_information_id;
                           g_challan_data_add(g_count_challan_add).modes                   := 'A';
                           g_count_challan_add := g_count_challan_add + 1;
                           pay_in_utils.set_location(g_debug,'Again opened',9);
                        END IF;
                  END IF;
           END IF;
       END IF;
    END LOOP;

       pay_in_utils.set_location(g_debug,'Starting Search for Updated Challans',1);
    -- Lastly search for those challans that have been updated since Form 24Q
    -- last generation but were not reported in Form 24Q Correction.
    FOR c_rec IN c_challan_24q_data_master('IN_24Q_CHALLAN','%',NULL)
    LOOP
       pay_in_utils.set_location(g_debug,'Fetching 24Q Data ' ,1);
       -- Now, on the basis of org_information_id check if there is any change
       -- in challan details in the live data.

       OPEN  c_challan_live_data(g_tax_year,NULL,c_rec.org_information_id);
       FETCH c_challan_live_data INTO l_transfer_voucher_number,
                                      l_transfer_voucher_date,
                                      l_amount,
                                      l_surcharge,
                                      l_education_cess,
                                      l_others,
                                      l_interest,
                                      l_bank_branch_code,
                                      l_cheque_dd_num,
                                      l_org_information_id;
       CLOSE c_challan_live_data;
       pay_in_utils.set_location(g_debug,'Fetching Live Data ' ,2);


       IF (--24Q Archival Data Here                 Live Data Here
           (c_rec.transfer_voucher_number <> NVL(l_bank_branch_code,'BOOK')||' - '||l_transfer_voucher_number||' - '||to_char(fnd_date.canonical_to_date(l_transfer_voucher_date),'DD-Mon-RRRR') ) OR
           (c_rec.bank_branch_code        <> l_bank_branch_code)        OR
           (c_rec.transfer_voucher_date   <> l_transfer_voucher_date)   OR
           (c_rec.amount                  <> l_amount)                  OR
           (c_rec.surcharge               <> l_surcharge)               OR
           (c_rec.cess                    <> l_education_cess)          OR
           (c_rec.interest                <> l_interest)                OR
           (c_rec.other                   <> l_others)                  OR
           (c_rec.cheque_dd_num           <> l_cheque_dd_num)
         )
      THEN
      -- This means that there are certain records that have same org_information_id
      -- as in Live Data and in Form 24Q but have undergone a change in their data
      -- Now, need to check whether these changes were reported in Form 24Q Correction
      -- or not.
                pay_in_utils.set_location(g_debug,'Inside Check 1' ,1);
                l_action_information_id  := NULL;
                OPEN  c_challan_24q_data('IN_24QC_CHALLAN',NULL,c_rec.org_information_id);
                FETCH c_challan_24q_data INTO l_action_information_id,
                                              l_transfer_voucher_number_1,
                                              l_bank_branch_code_1,
                                              l_transfer_voucher_date_1,
                                              l_amount_1,
                                              l_surcharge_1,
                                              l_education_cess_1,
                                              l_interest_1,
                                              l_others_1,
                                              l_cheque_dd_num_1,
                                              l_org_information_id_1;
                CLOSE c_challan_24q_data;
                -- What may happen is that the values were reported in Form 24Q Correction
                -- but they might have still undergone another change. So need to check
                -- whether any change was reported in Form 24Q Correction or not.
                -- If yes(24QC), then are the values diff. If yes then store in PL/SQL on basis of 24QC, else reject
                -- If not, then store in PL/SQL on the basis of 24Q Archival
                IF (l_action_information_id IS NOT NULL)
                THEN
                    IF (-- Live Data here             --24Q Correction Data here
                        (NVL(l_bank_branch_code,'BOOK')||' - '||l_transfer_voucher_number||' - '||to_char(fnd_date.canonical_to_date(l_transfer_voucher_date),'DD-Mon-RRRR')  <> l_transfer_voucher_number_1) OR
                        (l_bank_branch_code        <> l_bank_branch_code_1)        OR
                        (l_transfer_voucher_date   <> l_transfer_voucher_date_1)   OR
                        (l_amount                  <> l_amount_1)                  OR
                        (l_surcharge               <> l_surcharge_1)               OR
                        (l_education_cess          <> l_education_cess_1)          OR
                        (l_interest                <> l_interest_1)                OR
                        (l_others                  <> l_others_1)                  OR
                        (l_cheque_dd_num           <> l_cheque_dd_num_1)           OR
                        (l_org_information_id      <> l_org_information_id_1)
                      )
                   THEN
                           pay_in_utils.set_location(g_debug,'Inside Check 2' ,2);
                          --This means that in Form 24Q Correction, this record was present and now it has
                          -- been further modified. So need to insert this record data in PL/SQL table.
                          g_challan_data_upd(g_count_challan_upd).transfer_voucher_number := l_transfer_voucher_number_1;
                          g_challan_data_upd(g_count_challan_upd).transfer_voucher_date   := l_transfer_voucher_date_1;
                          g_challan_data_upd(g_count_challan_upd).amount                  := l_amount_1;
                          g_challan_data_upd(g_count_challan_upd).surcharge               := l_surcharge_1;
                          g_challan_data_upd(g_count_challan_upd).education_cess          := l_education_cess_1;
                          g_challan_data_upd(g_count_challan_upd).interest                := l_interest_1;
                          g_challan_data_upd(g_count_challan_upd).other                   := l_others_1;
                          g_challan_data_upd(g_count_challan_upd).bank_branch_code        := l_bank_branch_code_1;
                          g_challan_data_upd(g_count_challan_upd).cheque_dd_num           := l_cheque_dd_num_1;
                          g_challan_data_upd(g_count_challan_upd).org_information_id      := l_org_information_id_1;
                          g_challan_data_upd(g_count_challan_upd).modes                   := 'U';
                          g_count_challan_upd := g_count_challan_upd + 1;
                   END IF;
              ELSE
                          pay_in_utils.set_location(g_debug,'Inside Check 3' ,3);
                          --This means that in Form 24Q Correction, this record was  never present.
                          --So need to insert this record data in PL/SQL table on basis of form 24q archival
                          g_challan_data_upd(g_count_challan_upd).transfer_voucher_number := c_rec.transfer_voucher_number;
                          g_challan_data_upd(g_count_challan_upd).transfer_voucher_date   := c_rec.transfer_voucher_date;
                          g_challan_data_upd(g_count_challan_upd).amount                  := c_rec.amount;
                          g_challan_data_upd(g_count_challan_upd).surcharge               := c_rec.surcharge;
                          g_challan_data_upd(g_count_challan_upd).education_cess          := c_rec.cess;
                          g_challan_data_upd(g_count_challan_upd).interest                := c_rec.interest;
                          g_challan_data_upd(g_count_challan_upd).other                   := c_rec.other;
                          g_challan_data_upd(g_count_challan_upd).bank_branch_code        := c_rec.bank_branch_code;
                          g_challan_data_upd(g_count_challan_upd).cheque_dd_num           := c_rec.cheque_dd_num;
                          g_challan_data_upd(g_count_challan_upd).org_information_id      := c_rec.org_information_id;
                          g_challan_data_upd(g_count_challan_upd).modes                   := 'U';
                          g_count_challan_upd := g_count_challan_upd + 1;
              END IF;
      ELSE
         pay_in_utils.set_location(g_debug,'Inside Check 4' ,4);
      -- This means that the archived data and Live Data is identical. But there is a possibility that
      -- data was updated and reported in Form 24Q Correction and later again restored back to the data
      -- as in Form 24Q Archival. So need to check whether for c_rec.org_information_id any record is
      -- present in Form 24Q Correction or not. If its present, then check its status with Live Data.
      -- If there is a diff then mark that record, else reject it.


                OPEN  c_challan_24q_data('IN_24QC_CHALLAN',NULL,c_rec.org_information_id);
                FETCH c_challan_24q_data INTO l_action_information_id,
                                              l_transfer_voucher_number_1,
                                              l_bank_branch_code_1,
                                              l_transfer_voucher_date_1,
                                              l_amount_1,
                                              l_surcharge_1,
                                              l_education_cess_1,
                                              l_interest_1,
                                              l_others_1,
                                              l_cheque_dd_num_1,
                                              l_org_information_id_1;
                CLOSE c_challan_24q_data;


                IF (l_action_information_id IS NOT NULL)
                THEN
                -- This means that there is a reporting of this data in 24Q Correction. Now, need
                -- to check the diff of the two records. If diff exists then store this record
                -- on the basis of 24Q Correction else reject it.
                      IF (--Live Data                     24Q Correction Data
                          (NVL(l_bank_branch_code,'BOOK')||' - '||l_transfer_voucher_number||' - '||to_char(fnd_date.canonical_to_date(l_transfer_voucher_date),'DD-Mon-RRRR')  <> l_transfer_voucher_number_1) OR
                          (l_bank_branch_code        <> l_bank_branch_code_1)        OR
                          (l_transfer_voucher_date   <> l_transfer_voucher_date_1)   OR
                          (l_amount                  <> l_amount_1)                  OR
                          (l_surcharge               <> l_surcharge_1)               OR
                          (l_education_cess          <> l_education_cess_1)          OR
                          (l_interest                <> l_interest_1)                OR
                          (l_others                  <> l_others_1)                  OR
                          (l_cheque_dd_num           <> l_cheque_dd_num_1)           OR
                          (l_org_information_id      <> l_org_information_id_1)
                        )
                      THEN
                             pay_in_utils.set_location(g_debug,'Inside Check 5' ,5);
                            --This means that in Form 24Q Correction, this record was never
                            -- updated. So need to insert this record data in PL/SQL table.
                            g_challan_data_upd(g_count_challan_upd).transfer_voucher_number := l_transfer_voucher_number_1;
                            g_challan_data_upd(g_count_challan_upd).transfer_voucher_date   := l_transfer_voucher_date_1;
                            g_challan_data_upd(g_count_challan_upd).amount                  := l_amount_1;
                            g_challan_data_upd(g_count_challan_upd).surcharge               := l_surcharge_1;
                            g_challan_data_upd(g_count_challan_upd).education_cess          := l_education_cess_1;
                            g_challan_data_upd(g_count_challan_upd).interest                := l_interest_1;
                            g_challan_data_upd(g_count_challan_upd).other                   := l_others_1;
                            g_challan_data_upd(g_count_challan_upd).bank_branch_code        := l_bank_branch_code_1;
                            g_challan_data_upd(g_count_challan_upd).cheque_dd_num           := l_cheque_dd_num_1;
                            g_challan_data_upd(g_count_challan_upd).org_information_id      := l_org_information_id_1;
                            g_challan_data_upd(g_count_challan_upd).modes                   := 'U';
                            g_count_challan_upd := g_count_challan_upd + 1;
                      END IF;
               END IF;
      END IF;
    END LOOP;
       pay_in_utils.set_location(g_debug,'New Search Criteria Starting........' ,1);
    -- The above updation case handles only those cases when record was only updated
    -- and never re - created with the same Challan Number.
    FOR c_rec IN c_challan_24q_data_master('IN_24Q_CHALLAN','%',NULL)
    LOOP
       -- Now, on the basis of challan number check if there is any change
       -- in challan details in the live data.
       OPEN  c_challan_live_data(g_tax_year,c_rec.transfer_voucher_number,NULL);
       FETCH c_challan_live_data INTO l_transfer_voucher_number,
                                      l_transfer_voucher_date,
                                      l_amount,
                                      l_surcharge,
                                      l_education_cess,
                                      l_others,
                                      l_interest,
                                      l_bank_branch_code,
                                      l_cheque_dd_num,
                                      l_org_information_id;
       CLOSE c_challan_live_data;

       IF (c_rec.org_information_id <> l_org_information_id)
       THEN
       -- This means that there is a record which was deleted and recreated
       -- with the same challan number. Now, if rest of the details are same
       -- then no need to mark this record else mark it.
               IF (
                   (c_rec.bank_branch_code        <> l_bank_branch_code)        OR
                   (c_rec.transfer_voucher_date   <> l_transfer_voucher_date)   OR
                   (c_rec.amount                  <> l_amount)                  OR
                   (c_rec.surcharge               <> l_surcharge)               OR
                   (c_rec.cess                    <> l_education_cess)          OR
                   (c_rec.interest                <> l_interest)                OR
                   (c_rec.other                   <> l_others)                  OR
                   (c_rec.cheque_dd_num           <> l_cheque_dd_num)
                 )
              THEN
              -- This means that this record has same challan number and different
              -- details in terms of org_information_id and other details.
              -- So check as to whether this diff was reported in Form 24Q Correction
              -- or not.
                      OPEN  c_challan_24q_data('IN_24QC_CHALLAN',c_rec.transfer_voucher_number,NULL);
                      FETCH c_challan_24q_data INTO l_action_information_id,
                                                    l_transfer_voucher_number_1,
                                                    l_bank_branch_code_1,
                                                    l_transfer_voucher_date_1,
                                                    l_amount_1,
                                                    l_surcharge_1,
                                                    l_education_cess_1,
                                                    l_interest_1,
                                                    l_others_1,
                                                    l_cheque_dd_num_1,
                                                    l_org_information_id_1;
                      CLOSE c_challan_24q_data;
                      IF (l_action_information_id IS NOT NULL)
                      THEN
                      -- This means that record was present in Form 24Q Correction. If there is a diff in
                      -- data then store in PL/SQL table based on 24Q Correction, else reject it.
                             IF (--Live Data                   24Q Correction Data
                                 (l_bank_branch_code        <> l_bank_branch_code_1)        OR
                                 (l_transfer_voucher_date   <> l_transfer_voucher_date_1)   OR
                                 (l_amount                  <> l_amount_1)                  OR
                                 (l_surcharge               <> l_surcharge_1)               OR
                                 (l_education_cess          <> l_education_cess_1)          OR
                                 (l_interest                <> l_interest_1)                OR
                                 (l_others                  <> l_others_1)                  OR
                                 (l_cheque_dd_num           <> l_cheque_dd_num_1)
                               )
                            THEN
                                 -- This means that in Form 24Q Correction, this record was present and at present
                                 -- the data has undergone a change since then. So need to store this change based
                                 -- on 24Q Correction.
                                  g_challan_data_upd(g_count_challan_upd).transfer_voucher_number := l_transfer_voucher_number_1;
                                  g_challan_data_upd(g_count_challan_upd).transfer_voucher_date   := l_transfer_voucher_date_1;
                                  g_challan_data_upd(g_count_challan_upd).amount                  := l_amount_1;
                                  g_challan_data_upd(g_count_challan_upd).surcharge               := l_surcharge_1;
                                  g_challan_data_upd(g_count_challan_upd).education_cess          := l_education_cess_1;
                                  g_challan_data_upd(g_count_challan_upd).interest                := l_others_1;
                                  g_challan_data_upd(g_count_challan_upd).other                   := l_interest_1;
                                  g_challan_data_upd(g_count_challan_upd).bank_branch_code        := l_bank_branch_code_1;
                                  g_challan_data_upd(g_count_challan_upd).cheque_dd_num           := l_cheque_dd_num_1;
                                  g_challan_data_upd(g_count_challan_upd).org_information_id      := l_org_information_id_1;
                                  g_challan_data_upd(g_count_challan_upd).modes                   := 'U';
                                  g_count_challan_upd := g_count_challan_upd + 1;
                            ELSE
                                  --This means that in Form 24Q Correction, this record was never
                                  -- updated. So need to insert this record data in PL/SQL table based on 24Q Archival
                                  g_challan_data_upd(g_count_challan_upd).transfer_voucher_number := c_rec.transfer_voucher_number;
                                  g_challan_data_upd(g_count_challan_upd).transfer_voucher_date   := c_rec.transfer_voucher_date;
                                  g_challan_data_upd(g_count_challan_upd).amount                  := c_rec.amount;
                                  g_challan_data_upd(g_count_challan_upd).surcharge               := c_rec.surcharge;
                                  g_challan_data_upd(g_count_challan_upd).education_cess          := c_rec.cess;
                                  g_challan_data_upd(g_count_challan_upd).interest                := c_rec.interest;
                                  g_challan_data_upd(g_count_challan_upd).other                   := c_rec.other;
                                  g_challan_data_upd(g_count_challan_upd).bank_branch_code        := c_rec.bank_branch_code;
                                  g_challan_data_upd(g_count_challan_upd).cheque_dd_num           := c_rec.cheque_dd_num;
                                  g_challan_data_upd(g_count_challan_upd).org_information_id      := c_rec.org_information_id;
                                  g_challan_data_upd(g_count_challan_upd).modes                   := 'U';
                                  g_count_challan_upd := g_count_challan_upd + 1;
                            END IF;
                     END IF;
               END IF;
      END IF;
    END LOOP;
    pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.generate_challan_data', 1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END generate_challan_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_ELEMENT_ENTRY_VALUES                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    :                                                     --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_element_entry_id     NUMBER                       --
  --                : p_action_context_id    NUMBER                       --
  --                : p_assignment_id        NUMBER                       --
  --            OUT : p_ee_live_rec          t_screen_entry_value_rec     --
  --                  p_ee_24qc_rec          t_screen_entry_value_rec     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE get_element_entry_values
    (
      p_element_entry_id   IN  NUMBER  DEFAULT NULL
     ,p_action_context_id  IN  NUMBER  DEFAULT NULL
     ,p_assignment_id      IN  NUMBER
     ,p_ee_live_rec        OUT NOCOPY  t_screen_entry_value_rec
     ,p_ee_24qc_rec        OUT NOCOPY  t_screen_entry_value_rec
     ,p_person_live_data   OUT NOCOPY  t_person_data_rec
     ,p_person_24q_data    OUT NOCOPY  t_person_data_rec
    )
  IS
    CURSOR c_get_ee_from_live_data
    IS
       SELECT pay_in_utils.get_ee_value(p_element_entry_id,'Challan or Voucher Number')  Challan_or_Voucher_Number,
              pay_in_utils.get_ee_value(p_element_entry_id,'Payment Date')               Payment_Date,
              pay_in_utils.get_ee_value(p_element_entry_id,'Taxable Income')             Taxable_Income,
              pay_in_utils.get_ee_value(p_element_entry_id,'Income Tax Deducted')        Income_Tax_Deducted,
              pay_in_utils.get_ee_value(p_element_entry_id,'Surcharge Deducted')         Surcharge_Deducted,
              pay_in_utils.get_ee_value(p_element_entry_id,'Education Cess Deducted')    Education_Cess_Deducted,
              pay_in_utils.get_ee_value(p_element_entry_id,'Amount Deposited')           Amount_Deposited
         FROM dual;

    CURSOR c_get_ee_from_24q_data
    IS
       SELECT action_information1        Challan_or_Voucher_Number,
              action_information4        Payment_Date,
              action_information5        Taxable_Income,
              action_information6        Income_Tax_Deducted,
              action_information7        Surcharge_Deducted,
              action_information8        Education_Cess_Deducted,
              DECODE(action_information_category,'IN_24Q_DEDUCTEE'
                    ,action_information9,'IN_24QC_DEDUCTEE'
                    ,action_information16) Amount_Deposited
             ,action_information_id
         FROM pay_action_information pai
        WHERE pai.action_context_id           = p_action_context_id
          AND pai.action_information_category IN ('IN_24Q_DEDUCTEE','IN_24QC_DEDUCTEE')
          AND pai.assignment_id               = p_assignment_id
          AND pai.source_id                   = p_element_entry_id
          AND pai.action_information3         = g_gre_id
        ORDER BY action_information_id DESC;

    CURSOR c_get_person_data_from_24q
    IS
       SELECT action_information1   person_id
             ,action_information4   pan_number
             ,action_information5   pan_ref_number
             ,action_information6   full_name
             ,action_information_id
         FROM pay_action_information
        WHERE action_context_id           =     p_action_context_id
          AND action_context_type         =     'AAP'
          AND action_information_category =     'IN_24Q_PERSON'
          AND assignment_id               =     p_assignment_id
          AND action_information2         =     g_year||g_quarter
          AND action_information3         =     g_gre_id
         ORDER BY action_information_id DESC;

    CURSOR c_get_tax_rate_from_24q
    IS
       SELECT action_information13  tax_rate
         FROM pay_action_information
        WHERE action_context_id           =     p_action_context_id
          AND action_context_type         =     'AAP'
          AND action_information_category =     'IN_24Q_DEDUCTEE'
          AND assignment_id               =     p_assignment_id
          AND source_id                   =     p_element_entry_id
          AND action_information3         =     g_gre_id;

    CURSOR c_get_person_data_from_24qc
    IS
       SELECT action_information12  person_id
             ,action_information9   pan_number
             ,action_information11  pan_ref_number
             ,action_information18  tax_rate
             ,action_information10  full_name
             ,action_information_id
         FROM pay_action_information
        WHERE action_context_id           =     p_action_context_id
          AND action_context_type         =     'AAP'
          AND action_information_category =     'IN_24QC_DEDUCTEE'
          AND assignment_id               =     p_assignment_id
          AND action_information2         =     g_year||g_quarter
          AND action_information3         =     g_gre_id
        ORDER BY action_information_id DESC;

    CURSOR c_get_live_person_data
    IS
       SELECT asg.person_id         person_id
             ,DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4) pan
             ,pep.per_information14 pan_ref_number
             ,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) full_name
             ,pep.effective_end_date
       FROM   per_assignments_f  asg
             ,per_people_f       pep
       WHERE  asg.assignment_id     = p_assignment_id
         AND  pep.person_id         = asg.person_id
         AND  pep.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND  asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND  assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
         AND  assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date
        ORDER BY 5 DESC;

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
          AND  assignment_end_date(paa.assignment_id) BETWEEN paa.effective_start_date AND paa.effective_end_date
          AND  ROWNUM = 1;


       l_person_id             per_all_people_f.person_id%TYPE;
       l_pan_number            per_all_people_f.per_information14%TYPE;
       l_pan_ref_number        per_all_people_f.per_information14%TYPE;
       l_full_name             per_all_people_f.full_name%TYPE;
       l_tax_rate              per_assignment_extra_info.aei_information2 %TYPE;
       l_end_date              DATE;
       l_old_tax_rate          per_assignment_extra_info.aei_information2 %TYPE;
       l_action_information_id NUMBER;
       l_procedure             VARCHAR2(250);
       l_message               VARCHAR2(250);
  BEGIN
        g_debug     := hr_utility.debug_enabled;
        l_procedure := g_package ||'.get_element_entry_values';
        pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
        pay_in_utils.set_location(g_debug,'Fetching Live Data ' ,2);
        OPEN  c_get_ee_from_live_data;
        FETCH c_get_ee_from_live_data INTO p_ee_live_rec.challan_number,
                                           p_ee_live_rec.payment_date,
                                           p_ee_live_rec.taxable_income,
                                           p_ee_live_rec.income_tax,
                                           p_ee_live_rec.surcharge,
                                           p_ee_live_rec.education_cess,
                                           p_ee_live_rec.amount_deposited;
        CLOSE c_get_ee_from_live_data;

        pay_in_utils.set_location(g_debug,'Fetched Live Data ' ,2);
        pay_in_utils.set_location(g_debug,'Fetching 24Q Archival Data ' ,2);

        pay_in_utils.set_location(g_debug,'p_element_entry_id   '|| p_element_entry_id  ,2);
        pay_in_utils.set_location(g_debug,'p_action_context_id  '|| p_action_context_id ,2);
        pay_in_utils.set_location(g_debug,'p_assignment_id      '|| p_assignment_id     ,2);

        OPEN  c_get_ee_from_24q_data;
        FETCH c_get_ee_from_24q_data INTO  p_ee_24qc_rec.challan_number,
                                           p_ee_24qc_rec.payment_date,
                                           p_ee_24qc_rec.taxable_income,
                                           p_ee_24qc_rec.income_tax,
                                           p_ee_24qc_rec.surcharge,
                                           p_ee_24qc_rec.education_cess,
                                           p_ee_24qc_rec.amount_deposited,
                                           l_action_information_id;
        CLOSE c_get_ee_from_24q_data;
        pay_in_utils.set_location(g_debug,'Fetched 24Q Archival Data ' ,2);

        pay_in_utils.set_location(g_debug,'Searching in 24Q Correction ' ,2);
        OPEN  c_get_person_data_from_24qc;
        FETCH c_get_person_data_from_24qc INTO l_person_id,l_pan_number,l_pan_ref_number,l_old_tax_rate,p_person_24q_data.full_name,l_action_information_id;
        CLOSE c_get_person_data_from_24qc;
        pay_in_utils.set_location(g_debug,'Found person id in 24Q Correction: '|| l_person_id ,2);

        IF (l_person_id IS NULL)
        THEN
               pay_in_utils.set_location(g_debug,'Person ID is NULL' ,2);
               pay_in_utils.set_location(g_debug,'Hence Searching in 24Q Archival ' ,2);
               OPEN  c_get_person_data_from_24q;
               FETCH c_get_person_data_from_24q INTO l_person_id,l_pan_number,l_pan_ref_number,p_person_24q_data.full_name,l_action_information_id;
               CLOSE c_get_person_data_from_24q;

               OPEN  c_get_tax_rate_from_24q;
               FETCH c_get_tax_rate_from_24q INTO l_old_tax_rate;
               CLOSE c_get_tax_rate_from_24q;
               pay_in_utils.set_location(g_debug,'Old Tax Rate was '|| l_old_tax_rate,2);
        END IF;

        p_person_24q_data.person_id      := l_person_id;
        p_person_24q_data.pan_number     := l_pan_number;
        p_person_24q_data.pan_ref_number := l_pan_ref_number;
        p_person_24q_data.tax_rate       := l_old_tax_rate;

        pay_in_utils.set_location(g_debug,'Fetching Person Data from Live Data' ,2);
        OPEN c_get_live_person_data;
        FETCH c_get_live_person_data INTO p_person_live_data.person_id
                                         ,p_person_live_data.pan_number
                                         ,p_person_live_data.pan_ref_number
                                         ,p_person_live_data.full_name
                                         ,l_end_date;
        CLOSE c_get_live_person_data;
        pay_in_utils.set_location(g_debug,'Fetched Person Data from Live Data' ,2);

        OPEN  c_aei_tax_rate(p_person_live_data.person_id);
        FETCH c_aei_tax_rate INTO p_person_live_data.tax_rate;
        CLOSE c_aei_tax_rate;

        p_ee_24qc_rec.taxable_income   := TO_NUMBER(remove_curr_format(p_ee_24qc_rec.taxable_income));
        p_ee_24qc_rec.income_tax       := TO_NUMBER(remove_curr_format(p_ee_24qc_rec.income_tax));
        p_ee_24qc_rec.surcharge        := TO_NUMBER(remove_curr_format(p_ee_24qc_rec.surcharge));
        p_ee_24qc_rec.education_cess   := TO_NUMBER(remove_curr_format(p_ee_24qc_rec.education_cess));
        p_ee_24qc_rec.amount_deposited := TO_NUMBER(remove_curr_format(p_ee_24qc_rec.amount_deposited));


        p_ee_live_rec.taxable_income   := TO_NUMBER(remove_curr_format(p_ee_live_rec.taxable_income));
        p_ee_live_rec.income_tax       := TO_NUMBER(remove_curr_format(p_ee_live_rec.income_tax));
        p_ee_live_rec.surcharge        := TO_NUMBER(remove_curr_format(p_ee_live_rec.surcharge));
        p_ee_live_rec.education_cess   := TO_NUMBER(remove_curr_format(p_ee_live_rec.education_cess));
        p_ee_live_rec.amount_deposited := TO_NUMBER(remove_curr_format(p_ee_live_rec.amount_deposited));

        pay_in_utils.set_location(g_debug,'Leaving : '|| g_package||'.get_element_entry_values ', 1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END get_element_entry_values;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_LIVE_BALANCES                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    :                                                     --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_run_asg_action_id    NUMBER                       --
  --                  p_gre_id               NUMBER                       --
  --            OUT : p_balances             t_balance_value_tab          --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 07-Feb-2007    rpalli    5754018 : 24QC Quarter4 Stat Update   --
  --------------------------------------------------------------------------
  PROCEDURE get_live_balances(p_run_asg_action_id     IN  NUMBER
                              ,p_gre_id               IN  NUMBER
                              ,p_balances             OUT NOCOPY t_balance_value_tab)
  IS

    CURSOR c_f16_le_balances
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
                              ,'F16 Total Income'
                              ,'F16 Tax on Total Income'
                              ,'F16 Marginal Relief'
                              ,'F16 Total Tax payable'
                              ,'F16 Relief under Sec 89'
                              ,'F16 Employment Tax'
                              ,'F16 Entertainment Allowance'
                              ,'F16 Surcharge'
                              ,'F16 Education Cess'
                              ,'F16 Sec and HE Cess'
                              ,'F16 TDS'
                             --Chapter VIA Balances
                              ,'F16 Total Chapter VI A Deductions'
                              ,'F16 Deductions Sec 80CCE'
                              )
       AND pbd.dimension_name   ='_ASG_LE_PTD'
       AND pbt.legislation_code = 'IN'
       AND pbd.legislation_code = 'IN'
       AND pdb.legislation_code = 'IN'
       AND pbt.balance_type_id = pdb.balance_type_id
       AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

    g_bal_name_tab       t_bal_name_tab;
    g_context_table      pay_balance_pkg.t_context_tab;
    g_balance_value_tab  pay_balance_pkg.t_balance_value_tab;
    g_result_table       pay_balance_pkg.t_detailed_bal_out_tab;

    l_balance_value       NUMBER;
    i                     NUMBER;
    j                     NUMBER;

    l_proc                VARCHAR2(100);
    l_message             VARCHAR2(255);

    l_tot_via_qa         NUMBER;
    l_q4_80cce_total     NUMBER;
    l_q4_others_total    NUMBER;
    l_cess		 NUMBER;

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_proc  := g_package||'.get_live_balances';

    pay_in_utils.set_location(g_debug,'Entering : '||l_proc,10);

    if g_debug then
      pay_in_utils.trace('******************************','********************');
      pay_in_utils.trace('p_run_asg_action_id             : ',p_run_asg_action_id);
      pay_in_utils.trace('p_gre_id                        : ',p_gre_id);
      pay_in_utils.trace('******************************','********************');
   end if;

    i := 1;
    g_bal_name_tab.DELETE;
    g_balance_value_tab.DELETE;
    g_result_table.DELETE;
    g_context_table.DELETE;
    g_context_table(1).tax_unit_id := p_gre_id;

    --Step 1: Chapter VIA Balances - Initialise variables
    l_tot_via_qa := 0;
    l_q4_80cce_total := 0;
    l_q4_others_total := 0;

    l_cess:=0;

    --Step 2: Get F16 balances

    FOR c_rec IN c_f16_le_balances
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


    FOR i IN 1..g_balance_value_tab.COUNT
    LOOP
      IF (g_result_table(i).balance_value <> 0)
      THEN
        IF (g_bal_name_tab(i).balance_name ='F16 Total Chapter VI A Deductions')
          THEN
            l_tot_via_qa := g_result_table(i).balance_value ;
        ELSIF (g_bal_name_tab(i).balance_name  = 'F16 Deductions Sec 80CCE')
          THEN
            l_q4_80cce_total := g_result_table(i).balance_value ;
        ELSIF (g_bal_name_tab(i).balance_name  = 'F16 Education Cess' OR g_bal_name_tab(i).balance_name  = 'F16 Sec and HE Cess')
          THEN
            l_cess := l_cess + g_result_table(i).balance_value ;
        END IF;

          if g_debug then
              pay_in_utils.trace('balance_name             : ',g_bal_name_tab(i).balance_name);
              pay_in_utils.trace('balance_value            : ',g_result_table(i).balance_value);
          end if;
      END IF;
    END LOOP;

    l_q4_others_total := l_tot_via_qa - l_q4_80cce_total;

    i:= g_balance_value_tab.COUNT + 1;
    g_bal_name_tab(i).balance_name  := '80CCE';
    g_result_table(i).balance_value := l_q4_80cce_total;

    i:= i + 1;
    g_bal_name_tab(i).balance_name  := 'Others';
    g_result_table(i).balance_value := l_q4_others_total;

    FOR r IN 1..g_bal_name_tab.COUNT
    LOOP
      IF g_bal_name_tab(r).balance_name='F16 Education Cess' THEN
        p_balances(r).balance_name  := g_bal_name_tab(r).balance_name;
        p_balances(r).balance_value := l_cess;
      ELSE
        p_balances(r).balance_name  := g_bal_name_tab(r).balance_name;
        p_balances(r).balance_value := g_result_table(r).balance_value;
      END IF ;
    END LOOP;

    --Step 3:Delete all PL/SQL tables
    g_bal_name_tab.DELETE;
    g_context_table.DELETE;
    g_balance_value_tab.DELETE;
    g_result_table.DELETE;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_proc,30);

  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_proc, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_proc, 150);
  END get_live_balances;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_BALANCE_VALUES                                  --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    :                                                     --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_source_id            NUMBER                       --
  --                : p_action_context_id    NUMBER                       --
  --                : p_assignment_id        NUMBER                       --
  --                : p_24qa_pay_act_id      NUMBER                       --
  --                : p_mode                 VARCHAR2                     --
  --            OUT : p_ba_live_rec          t_balance_value_rec          --
  --                  p_ba_24qc_rec          t_balance_value_rec          --
  --                : p_gre_count            NUMBER                       --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 07-Feb-2007    rpalli    5754018 : 24QC Quarter4 Stat Update   --
  --------------------------------------------------------------------------
  PROCEDURE get_balance_values
    (
      p_source_id          IN  NUMBER  DEFAULT NULL
     ,p_action_context_id  IN  NUMBER  DEFAULT NULL
     ,p_assignment_id      IN  NUMBER
     ,p_24qa_pay_act_id    IN  NUMBER
     ,p_mode               IN  VARCHAR2
     ,p_ba_live_rec        OUT NOCOPY  t_balance_value_tab
     ,p_ba_24qc_rec        OUT NOCOPY  t_balance_value_tab
     ,p_person_live_data   OUT NOCOPY  t_person_data_sal_rec
     ,p_person_24q_data    OUT NOCOPY  t_person_data_sal_rec
     ,p_gre_count          OUT NOCOPY  NUMBER
    )
  IS

    CURSOR c_get_bal_24q(p_action_context_id NUMBER, p_24q_source_id NUMBER, p_category VARCHAR2, p_balance_name VARCHAR2)
    IS
       SELECT DISTINCT
       FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values(p_category,p_balance_name,pai.action_context_id,pai.source_id,1)))
         FROM pay_action_information pai
        WHERE pai.action_context_id           = p_action_context_id
          AND pai.action_information_category = p_category
          AND pai.source_id                   = p_24q_source_id;

    CURSOR c_get_person_data_from_24q
    IS
       SELECT DISTINCT
              pai.action_information1   person_id
             ,pai.action_information4   pan_number
             ,pai.action_information5   pan_ref_number
             ,pai.action_information6   full_name
             ,fnd_date.canonical_to_date(pai.action_information9)   start_date
             ,fnd_date.canonical_to_date(pai.action_information10)  end_date
             ,pai.source_id
          FROM pay_action_information pai
              ,pay_assignment_actions paa
         WHERE pai.action_information_category IN('IN_24Q_PERSON')
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.assignment_id               = p_assignment_id
           AND (
                  (pai.source_id  = p_source_id AND p_mode NOT IN ('A'))
               OR (p_mode IN ('A'))
               )
           AND pai.action_context_id           = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
         ORDER BY pai.source_id DESC;

    CURSOR c_get_person_data_from_24qc
    IS
       SELECT DISTINCT
              pai.action_information1   person_id
             ,pai.action_information4   pan_number
             ,pai.action_information5   pan_ref_number
             ,pai.action_information6   full_name
             ,fnd_date.canonical_to_date(pai.action_information8)   start_date
             ,fnd_date.canonical_to_date(pai.action_information9)  end_date
             ,pai.source_id
         FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
              ,pay_assignment_actions paa_master
         WHERE pai.action_information_category = 'IN_24QC_PERSON'
           AND pai.assignment_id               = p_assignment_id
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information10        = 'NA'
           AND (
                  (pai.source_id  = p_source_id AND p_mode NOT IN ('A'))
               OR (p_mode IN ('A'))
               )
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa_master.assignment_action_id = pai.action_context_id
           AND paa_master.payroll_action_id IN(
                                                  SELECT org_information3
                                                    FROM hr_organization_information
                                                   WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                     AND organization_id         = g_gre_id
                                                     AND org_information1        = g_year
                                                     AND org_information2        = g_quarter
                                                     AND org_information5        = 'A'
                                                     AND org_information6        = 'C'
                                                 )
                                     ORDER BY pai.source_id DESC;

    CURSOR c_get_live_person_data
    IS
       SELECT asg.person_id         person_id
             ,DECODE(pep.per_information4,NULL,DECODE(pep.per_information5,'Yes','APPLIEDFOR','PANNOTAVBL'),pep.per_information4) pan
             ,pep.per_information14 pan_ref_number
             ,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title) full_name
       FROM   per_assignments_f  asg
             ,per_people_f       pep
       WHERE  asg.assignment_id     = p_assignment_id
         AND  pep.person_id         = asg.person_id
         AND  pep.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND  asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND  assignment_end_date(asg.assignment_id) BETWEEN asg.effective_start_date AND asg.effective_end_date
         AND  assignment_end_date(asg.assignment_id) BETWEEN pep.effective_start_date AND pep.effective_end_date;

  CURSOR c_24qc_source_id(p_action_context_id     NUMBER,
                          p_assignment_id         NUMBER
                         )
      IS
        SELECT pai.action_context_id, pai.source_id
          FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
              ,pay_assignment_actions paa_master
         WHERE pai.action_information_category = 'IN_24QC_PERSON'
           AND pai.assignment_id               = p_assignment_id
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information10        = 'A'
           AND (
                  (pai.source_id  = p_source_id AND p_mode NOT IN ('A'))
               OR (p_mode IN ('A'))
               )
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa_master.assignment_action_id = pai.action_context_id
           AND paa_master.payroll_action_id IN(
                                                  SELECT org_information3
                                                    FROM hr_organization_information
                                                   WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                     AND organization_id         = g_gre_id
                                                     AND org_information1        = g_year
                                                     AND org_information2        = g_quarter
                                                     AND org_information5        = 'A'
                                                     AND org_information6        = 'C'
                                                 )
                                                 ORDER BY pai.source_id DESC;


  CURSOR c_24qa_source_id(p_action_context_id     NUMBER,
                          p_assignment_id         NUMBER
                         )
  IS
       SELECT DISTINCT pai.action_context_id, pai.source_id
          FROM pay_action_information pai
              ,pay_assignment_actions paa
         WHERE pai.action_information_category IN('IN_24Q_PERSON')
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.assignment_id               = p_assignment_id
           AND (
                  (pai.source_id  = p_source_id AND p_mode NOT IN ('A'))
               OR (p_mode IN ('A'))
               )
           AND pai.action_context_id           = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           ORDER BY pai.source_id DESC;

    CURSOR c_gre_records(p_assignment_id NUMBER)
    IS
    SELECT  GREATEST(asg.effective_start_date,g_fin_start_date) start_date
           ,LEAST(asg.effective_end_date,g_fin_end_date)        end_date
           ,scl.segment1
      FROM  per_assignments_f  asg
           ,hr_soft_coding_keyflex scl
           ,pay_assignment_actions paa
     WHERE  asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
       AND  paa.assignment_action_id = p_action_context_id
       AND  asg.assignment_id = paa.assignment_id
       AND  paa.assignment_id = p_assignment_id
       AND  scl.segment1 LIKE g_gre_id
       AND  ( asg.effective_start_date BETWEEN g_fin_start_date  AND g_end_date
          OR  g_fin_start_date BETWEEN asg.effective_start_date  AND asg.effective_end_date
              )
       AND  asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
    ORDER BY 1 ;

    CURSOR get_eoy_archival_details(p_start_date        DATE
                                   ,p_end_date         DATE
                                   ,p_tax_unit_id      NUMBER
                                   ,p_assignment_id    NUMBER
                                   )
    IS
    SELECT FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) run_asg_action_id
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


    CURSOR get_assignment_pact_id
    IS
    SELECT paa.assignment_id
          ,paa.payroll_action_id
          ,paf.person_id
      FROM pay_assignment_actions  paa
          ,per_all_assignments_f paf
     WHERE paa.assignment_action_id = p_action_context_id
       AND paa.assignment_id = paf.assignment_id
       AND ROWNUM =1;

    CURSOR c_termination_check(p_assignment_id NUMBER)
    IS
    SELECT NVL(pos.actual_termination_date,(fnd_date.string_to_date('31-12-4712','DD-MM-YYYY')))
      FROM   per_all_assignments_f  asg
            ,per_periods_of_service pos
     WHERE asg.person_id         = pos.person_id
       AND asg.assignment_id     = p_assignment_id
       AND asg.business_group_id = pos.business_group_id
       AND asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
       AND NVL(pos.actual_termination_date,(to_date('31-12-4712','DD-MM-YYYY')))
             BETWEEN asg.effective_start_date AND asg.effective_end_date
     ORDER BY 1 DESC;


       l_per_id                per_all_people_f.person_id%TYPE;
       l_person_id             per_all_people_f.person_id%TYPE;
       l_pan_number            per_all_people_f.per_information14%TYPE;
       l_pan_ref_number        per_all_people_f.per_information14%TYPE;
       l_full_name             per_all_people_f.full_name%TYPE;

       l_procedure             VARCHAR2(250);
       l_message               VARCHAR2(250);

       l_source_id             NUMBER;
       l_24qa_source_id        NUMBER;
       l_arc_pay_action_id               NUMBER;

       l_run_asg_action_id               NUMBER;

       i                     NUMBER;
       j                     NUMBER;
       l_count               NUMBER;
       l_balance_value       NUMBER;

       l_assignment_id       NUMBER;
       l_action_context_id   NUMBER;
       l_actual_term_date    DATE;
       l_effective_start_date DATE;
       l_effective_end_date   DATE;

       l_last_run_ind                    BOOLEAN;

       l_sal_category               VARCHAR2(250);
       l_via_category               VARCHAR2(250);

       t_balance_name t_bal_name_tab;

  BEGIN

        g_debug     := hr_utility.debug_enabled;
        l_procedure := g_package ||'.get_balance_values';
        pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
        pay_in_utils.set_location(g_debug,'Fetching Live Data ' ,2);

    --
      l_count := 1;
      i := 1;
      j := 1;
      g_asg_tab.DELETE;

      t_balance_name(1).balance_name  :=          'F16 Salary Under Section 17';
      t_balance_name(2).balance_name  :=          'F16 Profit in lieu of Salary';
      t_balance_name(3).balance_name  :=          'F16 Value of Perquisites';
      t_balance_name(4).balance_name  :=          'F16 Gross Salary less Allowances';
      t_balance_name(5).balance_name  :=          'F16 Allowances Exempt';
      t_balance_name(6).balance_name  :=          'F16 Deductions under Sec 16';
      t_balance_name(7).balance_name  :=          'F16 Income Chargeable Under head Salaries';
      t_balance_name(8).balance_name  :=          'F16 Other Income';
      t_balance_name(9).balance_name  :=          'F16 Gross Total Income';
      t_balance_name(10).balance_name :=          'F16 Total Income';
      t_balance_name(11).balance_name :=          'F16 Tax on Total Income';
      t_balance_name(12).balance_name :=          'F16 Marginal Relief';
      t_balance_name(13).balance_name :=          'F16 Total Tax payable';
      t_balance_name(14).balance_name :=          'F16 Relief under Sec 89';
      t_balance_name(15).balance_name :=          'F16 Employment Tax';
      t_balance_name(16).balance_name :=          'F16 Entertainment Allowance';
      t_balance_name(17).balance_name :=          'F16 Surcharge';
      t_balance_name(18).balance_name :=          'F16 Education Cess';
      t_balance_name(19).balance_name :=          'F16 TDS';
        --Chapter VIA Balances
      t_balance_name(20).balance_name :=          'F16 Total Chapter VI A Deductions';
      t_balance_name(21).balance_name :=          'F16 Deductions Sec 80CCE';
        --Chapter VIA Balances - Archive
      t_balance_name(22).balance_name :=          '80CCE';
      t_balance_name(23).balance_name :=          'Others';

    --
    OPEN  get_assignment_pact_id;
    FETCH get_assignment_pact_id INTO l_assignment_id ,l_arc_pay_action_id,l_per_id;
    CLOSE get_assignment_pact_id;

    OPEN  c_termination_check(l_assignment_id);
    FETCH c_termination_check INTO l_actual_term_date;
    CLOSE c_termination_check;

    if g_debug then
       pay_in_utils.trace('l_assignment_id          : ',l_assignment_id);
       pay_in_utils.trace('l_arc_pay_action_id      : ',l_arc_pay_action_id);
       pay_in_utils.trace('l_per_id                 : ',l_per_id);
       pay_in_utils.trace('l_actual_term_date       : ',l_actual_term_date);
    end if;

 -- Get all records from financial year start till current quarter end to find out
 -- previous GRE assignment_action_id and remaining pay periods
    pay_in_utils.set_location(g_debug,'Entering : '||l_assignment_id,12);
    FOR c_rec IN c_gre_records(l_assignment_id)
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

    p_gre_count := l_count;

/* g_asg_tab.start/end date will contain the actual start/end of asg in a GRE or the the financial year  .
   We need to change it to quarter date*/

    FOR i IN 1..l_count-1
    LOOP
       --Get Live Balances only if it is a candidate for reporting in the specified quarter
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

            pay_in_utils.trace('l_run_asg_action_id in LOOP: ', l_run_asg_action_id );

         IF l_run_asg_action_id IS NOT NULL THEN

           -- Get Person start date and end date
           IF g_asg_tab(i).start_date > LEAST(g_asg_tab(i).end_date,l_actual_term_date) THEN
             l_effective_end_date := g_end_date;
           ELSE
             l_effective_end_date := LEAST(g_end_date,g_asg_tab(i).end_date,l_actual_term_date);
           END IF;

           IF g_quarter = 'Q4' THEN
             l_effective_start_date := g_asg_tab(i).start_date;
           ELSE
             l_effective_start_date := GREATEST(g_qr_start_date,g_asg_tab(i).start_date);
           END IF;

            pay_in_utils.set_location(g_debug,'Fetching Live Balances Data  ' ,2);
            pay_in_utils.set_location(g_debug,'p_mode in Live Balances Data : '||p_mode ,2);
            pay_in_utils.set_location(g_debug,'p_source_id in Live Balances Data : '||p_source_id ,2);
            pay_in_utils.set_location(g_debug,'l_run_asg_action_id in Live Balances Data : '||l_run_asg_action_id ,2);

            IF (p_source_id = l_run_asg_action_id)
            THEN

              get_live_balances(p_run_asg_action_id     => l_run_asg_action_id
                               ,p_gre_id                => g_asg_tab(i).gre_id
                               ,p_balances              => p_ba_live_rec
                               );
              pay_in_utils.set_location(g_debug,'Fetched Live Balances Data ' ,2);
              EXIT;
            END IF;
            pay_in_utils.set_location(g_debug,'Fetching Live Balances Data  ' ,3);

            IF ((p_mode = 'D') AND (p_source_id < l_run_asg_action_id))
            THEN

              get_live_balances(p_run_asg_action_id     => l_run_asg_action_id
                               ,p_gre_id                => g_asg_tab(i).gre_id
                               ,p_balances              => p_ba_live_rec
                               );
              pay_in_utils.set_location(g_debug,'Fetched Live Balances Data ' ,3);
              EXIT;
            END IF;

         END IF; -- Run Assact is NOT NULL
      END IF; -- End of Get Live Balances
    END LOOP;

            pay_in_utils.set_location(g_debug,'Fetching 24Q Archival Balances Data ' ,3);

            pay_in_utils.set_location(g_debug,'Searching in 24Q Correction ' ,3);
            pay_in_utils.set_location(g_debug,'Fetching 24Q Archival Source ID ' ,3);

            pay_in_utils.set_location(g_debug,'p_action_context_id  : '|| p_action_context_id ,3);
            pay_in_utils.set_location(g_debug,'p_assignment_id      : '|| p_assignment_id     ,3);
            pay_in_utils.set_location(g_debug,'p_source_id          : '|| p_source_id     ,3);

            OPEN  c_24qc_source_id(p_action_context_id,p_assignment_id);
            FETCH c_24qc_source_id INTO l_action_context_id,l_24qa_source_id;
             l_sal_category := 'IN_24QC_SALARY';
             l_via_category := 'IN_24QC_VIA';
             pay_in_utils.set_location(g_debug,'l_24qa_source_id in c_24qc_source_id : '|| l_24qa_source_id ,3);
            CLOSE c_24qc_source_id;

            IF (l_24qa_source_id IS NULL)
            THEN
               pay_in_utils.set_location(g_debug,'Source ID is NULL' ,4);
               pay_in_utils.set_location(g_debug,'Hence Searching in 24Q Archival ' ,4);
               OPEN  c_24qa_source_id(p_action_context_id,p_assignment_id);
               FETCH c_24qa_source_id INTO l_action_context_id,l_24qa_source_id;
                l_sal_category := 'IN_24Q_SALARY';
                l_via_category := 'IN_24Q_VIA';
                pay_in_utils.trace('l_24qa_source_id in c_24qa_source_id : ', l_24qa_source_id );
               CLOSE c_24qa_source_id;
            END IF;

            pay_in_utils.trace('l_24qa_source_id  : ', l_24qa_source_id );
            pay_in_utils.trace('l_sal_category  : ', l_sal_category );
            pay_in_utils.trace('l_via_category  : ', l_via_category );

            IF (l_24qa_source_id IS NOT NULL) THEN
               FOR j IN 1..t_balance_name.COUNT
               LOOP
                IF (t_balance_name(j).balance_name IN ('80CCE','Others'))
                THEN
                       OPEN  c_get_bal_24q(l_action_context_id,l_24qa_source_id,l_via_category,t_balance_name(j).balance_name);
                       FETCH c_get_bal_24q INTO l_balance_value;
                       CLOSE c_get_bal_24q;
                 ELSE
                       OPEN  c_get_bal_24q(l_action_context_id,l_24qa_source_id,l_sal_category,t_balance_name(j).balance_name);
                       FETCH c_get_bal_24q INTO l_balance_value;
                       CLOSE c_get_bal_24q;
                 END IF;
                 p_ba_24qc_rec(j).balance_name  := t_balance_name(j).balance_name;
                 p_ba_24qc_rec(j).balance_value := l_balance_value;
               END LOOP;
            END IF;

            pay_in_utils.set_location(g_debug,'Fetched 24Q Archival Balances Data ' ,4);

            pay_in_utils.set_location(g_debug,'Searching person data in 24Q Correction ' ,5);
            OPEN  c_get_person_data_from_24qc;
            FETCH c_get_person_data_from_24qc INTO l_person_id,l_pan_number,l_pan_ref_number,p_person_24q_data.full_name,
                    p_person_24q_data.start_date,p_person_24q_data.end_date,l_source_id;
            pay_in_utils.set_location(g_debug,'Value of person id found in 24Q Correction: '|| l_person_id ,5);
            CLOSE c_get_person_data_from_24qc;


            IF (l_person_id IS NULL)
            THEN
                   pay_in_utils.set_location(g_debug,'Person ID is NULL' ,5);
                   pay_in_utils.set_location(g_debug,'Hence Searching in 24Q Archival ' ,5);
                   OPEN  c_get_person_data_from_24q;
                   FETCH c_get_person_data_from_24q INTO l_person_id,l_pan_number,l_pan_ref_number,p_person_24q_data.full_name,
                            p_person_24q_data.start_date,p_person_24q_data.end_date,l_source_id;
                   CLOSE c_get_person_data_from_24q;
            pay_in_utils.set_location(g_debug,'Value of person id found in 24Q Archival: '|| l_person_id ,5);
            END IF;

            p_person_24q_data.person_id      := l_person_id;
            p_person_24q_data.pan_number     := l_pan_number;
            p_person_24q_data.pan_ref_number := l_pan_ref_number;

            pay_in_utils.set_location(g_debug,'Fetched Person Data from 24Q Archival Data' ,5);

            pay_in_utils.set_location(g_debug,'Fetching Person Data from Live Data' ,6);
            OPEN c_get_live_person_data;
            FETCH c_get_live_person_data INTO p_person_live_data.person_id
                                             ,p_person_live_data.pan_number
                                             ,p_person_live_data.pan_ref_number
                                             ,p_person_live_data.full_name;
            CLOSE c_get_live_person_data;

            p_person_live_data.start_date   := l_effective_start_date;
            p_person_live_data.end_date     := l_effective_end_date;

            pay_in_utils.set_location(g_debug,'Fetched Person Data from Live Data' ,6);

            pay_in_utils.set_location(g_debug,'---------------------------------------------' ,7);
            pay_in_utils.set_location(g_debug,'Removing format for Live Balances Data' ,7);
            FOR i IN 1..p_ba_live_rec.COUNT
            LOOP
              p_ba_live_rec(i).balance_value  := FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(p_ba_live_rec(i).balance_value));
            END LOOP;

            pay_in_utils.set_location(g_debug,'---------------------------------------------' ,7);

            pay_in_utils.set_location(g_debug,'---------------------------------------------' ,8);
            pay_in_utils.set_location(g_debug,'Removing format for 24Q Archive Balances Data' ,8);
            FOR i IN 1..p_ba_24qc_rec.COUNT
            LOOP
              p_ba_24qc_rec(i).balance_value  := FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(p_ba_24qc_rec(i).balance_value));
            END LOOP;
            pay_in_utils.set_location(g_debug,'---------------------------------------------' ,8);

    pay_in_utils.set_location(g_debug,'Leaving : '|| l_procedure, 120);

  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END get_balance_values;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CHECK_C5_CHANGE_ONLY                                --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    :                                                     --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_element_entry_id     NUMBER                       --
  --                : p_action_context_id    NUMBER                       --
  --                : p_assignment_id        NUMBER                       --
  --            OUT : p_flag                 BOOLEAN                      --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION check_c5_change_only
    (
      p_element_entry_id   IN  NUMBER
     ,p_action_context_id  IN  NUMBER
     ,p_assignment_id      IN  NUMBER
    )
  RETURN BOOLEAN
  IS
     t_ee_live_rec         t_screen_entry_value_rec;
     t_ee_24qc_rec         t_screen_entry_value_rec;
     t_person_live_data    t_person_data_rec;
     t_person_24q_data     t_person_data_rec;
     l_procedure           VARCHAR2(250);
     l_message             VARCHAR2(250);
  BEGIN
      g_debug     := hr_utility.debug_enabled;
      l_procedure := g_package ||'.check_c5_change_only';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      pay_in_utils.set_location(g_debug,'Fetching Live Data',2);
      get_element_entry_values
      (
        p_element_entry_id
       ,p_action_context_id
       ,p_assignment_id
       ,t_ee_live_rec
       ,t_ee_24qc_rec
       ,t_person_live_data
       ,t_person_24q_data
      );
      pay_in_utils.set_location(g_debug,'Fetched Live Data',3);
      pay_in_utils.set_location(g_debug,'Comparing Data',4);

      IF(t_ee_live_rec.challan_number <> t_ee_24qc_rec.challan_number)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.challan_number'|| t_ee_live_rec.challan_number,1);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.challan_number'|| t_ee_24qc_rec.challan_number,1);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 1',1);
           RETURN FALSE;
      END IF;

      IF(t_ee_live_rec.payment_date <> t_ee_24qc_rec.payment_date)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.payment_date'|| t_ee_live_rec.payment_date,2);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.payment_date'|| t_ee_24qc_rec.payment_date,2);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 2',2);
           RETURN FALSE;
      END IF;

      IF(t_ee_live_rec.amount_deposited <> t_ee_24qc_rec.amount_deposited)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.amount_deposited'|| t_ee_live_rec.amount_deposited,3);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.amount_deposited'|| t_ee_24qc_rec.amount_deposited,3);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 3',3);
           RETURN FALSE;
      END IF;

      IF(t_ee_live_rec.surcharge <> t_ee_24qc_rec.surcharge)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.surcharge'|| t_ee_live_rec.surcharge,4);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.surcharge'|| t_ee_24qc_rec.surcharge,4);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 4',4);
           RETURN FALSE;
      END IF;

      IF(t_ee_live_rec.education_cess <> t_ee_24qc_rec.education_cess)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.education_cess'|| t_ee_live_rec.education_cess,5);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.education_cess'|| t_ee_24qc_rec.education_cess,5);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 5',5);
           RETURN FALSE;
      END IF;

      IF(t_ee_live_rec.income_tax <> t_ee_24qc_rec.income_tax)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.income_tax'|| t_ee_live_rec.income_tax,6);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.income_tax'|| t_ee_24qc_rec.income_tax,6);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 6',6);
           RETURN FALSE;
      END IF;

      IF(t_ee_live_rec.taxable_income <> t_ee_24qc_rec.taxable_income)
      THEN
           pay_in_utils.set_location(g_debug,'t_ee_live_rec.taxable_income'|| t_ee_live_rec.taxable_income,7);
           pay_in_utils.set_location(g_debug,'t_ee_24qc_rec.taxable_income'|| t_ee_24qc_rec.taxable_income,7);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 7',7);
           RETURN FALSE;
      END IF;

      IF(t_person_live_data.full_name <> t_person_24q_data.full_name)
      THEN
           pay_in_utils.set_location(g_debug,'t_person_live_data.full_name'|| t_person_live_data.full_name,8);
           pay_in_utils.set_location(g_debug,'t_person_24q_data.full_name'|| t_person_24q_data.full_name,8);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 8',8);
           RETURN FALSE;
      END IF;

      IF(NVL(t_person_live_data.tax_rate,'NA') <> NVL(t_person_24q_data.tax_rate,'NA'))
      THEN
           pay_in_utils.set_location(g_debug,'t_person_live_data.tax_rate'|| t_person_live_data.tax_rate,9);
           pay_in_utils.set_location(g_debug,'t_person_24q_data.tax_rate'|| t_person_24q_data.tax_rate,9);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 9',9);
           RETURN FALSE;
      END IF;

      IF(NVL(t_person_live_data.pan_ref_number,'NA') <> NVL(t_person_24q_data.pan_ref_number,'NA'))
      THEN
           pay_in_utils.set_location(g_debug,'t_person_live_data.pan_ref_number'|| t_person_live_data.pan_ref_number,10);
           pay_in_utils.set_location(g_debug,'t_person_24q_data.pan_ref_number'|| t_person_24q_data.pan_ref_number,10);
           pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only Diff 10',10);
           RETURN FALSE;
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.check_c5_change_only No Diff',11);
      RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END check_c5_change_only;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_SALARY_DATA                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure to archive the salary data.               --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 07-Feb-2007    rpalli    5754018 : 24QC Quarter4 Stat Update   --
  --------------------------------------------------------------------------
  PROCEDURE archive_salary_data(p_payroll_action_id   NUMBER
                               ,p_24qa_pay_act_id     NUMBER
                               )
  IS

  CURSOR c_salary_number_24q(p_person_id      VARCHAR2
                            ,p_source_id      NUMBER
                             )
  IS
        SELECT MAX(FND_NUMBER.CANONICAL_TO_NUMBER(action_information11))
          FROM pay_action_information pai
              ,pay_assignment_actions paa
         WHERE pai.action_information_category = 'IN_24Q_PERSON'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information1         = p_person_id
           AND pai.source_id                   = p_source_id
           AND pai.action_context_id           = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa.payroll_action_id IN(
                                        SELECT org_information3
                                          FROM hr_organization_information
                                         WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                           AND organization_id         = g_gre_id
                                           AND org_information1        = g_year
                                           AND org_information2        = g_quarter
                                           AND org_information5        = 'A'
                                           AND org_information6        = 'O'
                                       );

  CURSOR c_salary_number_24qc(p_person_id      VARCHAR2
                             ,p_source_id      NUMBER
                              )
      IS
       SELECT MAX(FND_NUMBER.CANONICAL_TO_NUMBER(action_information12))
          FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
              ,pay_assignment_actions paa_master
         WHERE pai.action_information_category = 'IN_24QC_PERSON'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information1         = p_person_id
           AND pai.source_id                   = p_source_id
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa_master.assignment_action_id = pai.action_context_id
           AND paa_master.payroll_action_id IN(
                                                  SELECT org_information3
                                                    FROM hr_organization_information
                                                   WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                     AND organization_id         = g_gre_id
                                                     AND org_information1        = g_year
                                                     AND org_information2        = g_quarter
                                                     AND org_information5        = 'A'
                                                     AND org_information6        = 'C'
                                                 );

  CURSOR c_max_salary_number_24q
  IS
        SELECT MAX(FND_NUMBER.CANONICAL_TO_NUMBER(action_information11))
          FROM pay_action_information pai
              ,pay_assignment_actions paa
         WHERE pai.action_information_category = 'IN_24Q_PERSON'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_context_id           = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa.payroll_action_id IN(
                                        SELECT org_information3
                                          FROM hr_organization_information
                                         WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                           AND organization_id         = g_gre_id
                                           AND org_information1        = g_year
                                           AND org_information2        = g_quarter
                                           AND org_information5        = 'A'
                                           AND org_information6        = 'O'
                                       );


  CURSOR c_max_salary_number_24qc
      IS
       SELECT MAX(FND_NUMBER.CANONICAL_TO_NUMBER(action_information12))
          FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
              ,pay_assignment_actions paa_master
         WHERE pai.action_information_category = 'IN_24QC_PERSON'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa_master.assignment_action_id = pai.action_context_id
           AND paa_master.payroll_action_id IN(
                                                  SELECT org_information3
                                                    FROM hr_organization_information
                                                   WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                     AND organization_id         = g_gre_id
                                                     AND org_information1        = g_year
                                                     AND org_information2        = g_quarter
                                                     AND org_information5        = 'A'
                                                     AND org_information6        = 'C'
                                                 );


  CURSOR c_asg_act_id(p_payroll_action_id     NUMBER,
                      p_assignment_id         NUMBER
                     )
  IS
     SELECT assignment_action_id
       FROM pay_assignment_actions
      WHERE payroll_action_id = p_payroll_action_id
        AND assignment_id     = p_assignment_id;

  CURSOR c_max_pact(p_assignment_id NUMBER)
  IS
      SELECT
              FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) source_id
              ,paf.assignment_id       assignment_id
             FROM pay_assignment_actions paa
                 ,pay_payroll_actions ppa
                 ,per_assignments_f paf
             WHERE paf.assignment_id = paa.assignment_id
             AND paf.assignment_id =p_assignment_id
             AND paa.tax_unit_id  = g_gre_id
             AND paa.payroll_action_id = ppa.payroll_action_id
             AND ppa.action_type IN('R','Q','I','B')
             AND ppa.payroll_id    = paf.payroll_id
             AND ppa.action_status ='C'
             AND ppa.effective_date between g_start_date and g_end_date
             AND paa.source_action_id IS NULL
             AND (1 = DECODE(ppa.action_type,'I',1,0)
              OR EXISTS (SELECT ''
                        FROM pay_action_interlocks intk,
                             pay_assignment_actions paa1,
                             pay_payroll_actions ppa1
                        WHERE intk.locked_action_id = paa.assignment_Action_id
                        AND intk.locking_action_id =  paa1.assignment_action_id
                        AND paa1.payroll_action_id =ppa1.payroll_action_id
                        AND ppa1.action_type in('P','U')
                        AND ppa.action_type in('R','Q','B')
                        AND ppa1.action_status ='C'
                        AND ppa1.effective_date between g_start_date and g_end_date
                        AND ROWNUM =1 ))
                GROUP BY paf.assignment_id;

  CURSOR c_prev_max_pact(p_assignment_id NUMBER, p_max_asact_id NUMBER)
  IS
      SELECT
              FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) source_id
              ,paf.assignment_id       assignment_id
             FROM pay_assignment_actions paa
                 ,pay_payroll_actions ppa
                 ,per_assignments_f paf
             WHERE paf.assignment_id = paa.assignment_id
             AND paf.assignment_id =p_assignment_id
             AND paa.tax_unit_id  = g_gre_id
             AND paa.payroll_action_id = ppa.payroll_action_id
             AND paa.assignment_action_id < p_max_asact_id
             AND ppa.action_type IN('R','Q','I','B')
             AND ppa.payroll_id    = paf.payroll_id
             AND ppa.action_status ='C'
             AND ppa.effective_date between g_start_date and g_end_date
             AND paa.source_action_id IS NULL
             AND (1 = DECODE(ppa.action_type,'I',1,0)
              OR EXISTS (SELECT ''
                        FROM pay_action_interlocks intk,
                             pay_assignment_actions paa1,
                             pay_payroll_actions ppa1
                        WHERE intk.locked_action_id = paa.assignment_Action_id
                        AND intk.locking_action_id =  paa1.assignment_action_id
                        AND paa1.payroll_action_id =ppa1.payroll_action_id
                        AND ppa1.action_type in('P','U')
                        AND ppa.action_type in('R','Q','B')
                        AND ppa1.action_status ='C'
                        AND ppa1.effective_date between g_start_date and g_end_date
                        AND ROWNUM =1 ))
                GROUP BY paf.assignment_id;

  CURSOR c_24qc_source_id(p_action_context_id     NUMBER,
                          p_assignment_id         NUMBER
                         )
      IS
        SELECT DISTINCT pai.source_id,pai.action_context_id
          FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
              ,pay_assignment_actions paa_master
         WHERE pai.action_information_category = 'IN_24QC_PERSON'
           AND pai.assignment_id               = p_assignment_id
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information10        = 'A'
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa_master.assignment_action_id = pai.action_context_id
           AND paa_master.payroll_action_id IN(
                                                  SELECT org_information3
                                                    FROM hr_organization_information
                                                   WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                     AND organization_id         = g_gre_id
                                                     AND org_information1        = g_year
                                                     AND org_information2        = g_quarter
                                                     AND org_information5        = 'A'
                                                     AND org_information6        = 'C'
                                                 )
                                                 ORDER BY pai.source_id DESC;

  CURSOR c_24qa_source_id(p_action_context_id     NUMBER,
                          p_assignment_id         NUMBER
                         )
  IS
       SELECT DISTINCT pai.source_id,pai.action_context_id
          FROM pay_action_information pai
         WHERE pai.action_information_category IN('IN_24Q_PERSON')
           AND pai.action_information3         = g_gre_id
           AND pai.assignment_id               = p_assignment_id
           AND pai.action_context_id           = p_action_context_id
           ORDER BY pai.source_id DESC;

  CURSOR c_get_bal_24q(p_action_context_id NUMBER, p_24q_source_id NUMBER, p_category VARCHAR2, p_balance_name VARCHAR2)
  IS
       SELECT DISTINCT
       FND_NUMBER.CANONICAL_TO_NUMBER(remove_curr_format(get_24Q_values(p_category,p_balance_name,pai.action_context_id,pai.source_id,1)))
         FROM pay_action_information pai
        WHERE pai.action_context_id           = p_action_context_id
          AND pai.action_information_category = p_category
          AND pai.source_id                   = p_24q_source_id;

    tab_24q_ba_data  t_balance_value_tab;
    tab_liv_ba_data  t_balance_value_tab;

    tab_24q_pe_data  t_person_data_sal_rec;
    tab_liv_pe_data  t_person_data_sal_rec;

    l_action_information_category pay_action_information.action_information_category%TYPE;
    l_arch_asg_action_id          NUMBER;
    l_24qa_asg_action_id          NUMBER;
    l_24qa_source_id              NUMBER;
    l_prev_asg_action_id          NUMBER;
    l_prev_category               VARCHAR2(250);

    l_action_info_id              NUMBER;
    l_ovn                         NUMBER;
    j                             NUMBER;
    k                             NUMBER;
    l                             NUMBER;
    s                             NUMBER;
    l_dummy                       NUMBER  := -1;
    l_flag                        NUMBER  := -1;
    l_flag1                       NUMBER  := -1;
    l_flag2                       NUMBER  := -1;

    l_procedure                   VARCHAR2(250);
    l_message                     VARCHAR2(250);
    l_balance_value       NUMBER;

    l_c5_change_only              BOOLEAN;
    l_prev_c5                     BOOLEAN;
    l_c5_tot_income_flag          BOOLEAN;

    l_max_pact                NUMBER;
    l_prev_max_pact           NUMBER;
    l_count_delete            NUMBER;
    l_gre_count              NUMBER;
    l_assignment_id           NUMBER;
    l_future_pay              BOOLEAN;
    l_prev_pay                BOOLEAN;

  BEGIN

      g_debug     := hr_utility.debug_enabled;
      l_procedure := g_package ||'.archive_salary_data';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      pay_in_utils.set_location(g_debug,'Fetching Salary Data ', 1);

      s := 1;
      l_24qa_source_id := NULL;
      l_24qa_asg_action_id := NULL;
      IF (g_correction_mode IN('C4','C5','%'))
      THEN
             pay_in_utils.set_location(g_debug,'Value of g_count_sal_delete : '|| g_count_sal_delete, 1);
             FOR i IN 1..g_count_sal_delete - 1
             LOOP

                pay_in_utils.set_location(g_debug,'Checking archived presence of this deleted assignment action',1);
                l_flag := -1;
                l_flag1 := -1;
                l_flag2 := -1;
                l_gre_count := 0;

                l_flag  := check_archival_status(g_sal_data_rec_del(i).source_id,'IN_24QC_PERSON',NULL,'D');
                l_flag1 := check_archival_status(g_sal_data_rec_del(i).source_id,'IN_24QC_PERSON',NULL,'NA');

                pay_in_utils.trace('l_flag in g_count_sal_delete ',l_flag);
                pay_in_utils.trace('l_flag1 in g_count_sal_delete ',l_flag1);

                IF ((l_flag = 0) AND (l_flag1 = 0))
                THEN
                      pay_in_utils.set_location(g_debug,'Deleted Salary Detail Record Not Archived. Hence doing '||g_sal_data_rec_del(i).source_id,1);

                       get_balance_values
                        (
                          g_sal_data_rec_del(i).source_id
                         ,g_sal_data_rec_del(i).last_action_context_id
                         ,g_sal_data_rec_del(i).assignment_id
                         ,p_24qa_pay_act_id
                         ,'D'
                         ,tab_liv_ba_data
                         ,tab_24q_ba_data
                         ,tab_liv_pe_data
                         ,tab_24q_pe_data
                         ,l_gre_count
                        );

                --      if g_correction_mode = 'C5' and tab_24q_pe_data.pan_number IS VALID and
                --       tab_liv_pe_data.pan_number is also valid and not equal 2 each other
                --       then not only arhcive this assignment data, but also last organization PA data

                         pay_in_utils.trace('Delete Source ID            : ', g_sal_data_rec_del(i).source_id );
                         pay_in_utils.trace('tab_liv_pe_data.pan_number  : ', tab_liv_pe_data.pan_number );
                         pay_in_utils.trace('tab_24q_pe_data.pan_number  : ', tab_24q_pe_data.pan_number );

                         IF ((g_correction_mode IN('C4','C5','%'))
                              AND(tab_24q_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                              AND(tab_liv_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                              AND(tab_24q_pe_data.pan_number <> tab_liv_pe_data.pan_number)
                            )
                         THEN
                                 l_action_information_category := 'C4:C5';
                         ELSE
                                 l_action_information_category := 'C4';
                         END IF;

                         OPEN  c_asg_act_id(p_payroll_action_id,g_sal_data_rec_del(i).assignment_id);
                         FETCH c_asg_act_id INTO l_arch_asg_action_id;
                         CLOSE c_asg_act_id;

                         OPEN c_asg_act_id(p_24qa_pay_act_id,g_sal_data_rec_del(i).assignment_id);
                         FETCH c_asg_act_id INTO l_24qa_asg_action_id;
                         CLOSE c_asg_act_id;

                         OPEN  c_salary_number_24qc(tab_liv_pe_data.person_id,g_sal_data_rec_del(i).source_id);
                         FETCH c_salary_number_24qc INTO k;
                         CLOSE c_salary_number_24qc;

                         OPEN  c_salary_number_24q(tab_liv_pe_data.person_id,g_sal_data_rec_del(i).source_id);
                         FETCH c_salary_number_24q INTO j;
                         CLOSE c_salary_number_24q;

                          pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                          pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);

                       l_c5_change_only := TRUE;
                       pay_in_utils.trace('Count of live balances  : ', tab_liv_ba_data.COUNT );
                       pay_in_utils.trace('Count of 24q balances   : ', tab_24q_ba_data.COUNT );

                        FOR j IN 1..tab_liv_ba_data.COUNT
                        LOOP
                         FOR k IN 1..tab_24q_ba_data.COUNT
                         LOOP
                           IF (tab_liv_ba_data(j).balance_name = tab_24q_ba_data(k).balance_name)
                           THEN

                               IF ((tab_liv_ba_data(j).balance_value <> 0) AND
                                   (tab_liv_ba_data(j).balance_value <> tab_24q_ba_data(k).balance_value) AND
                                   (tab_liv_ba_data(j).balance_name NOT IN ('F16 Deductions Sec 80CCE'))
                                  )
                               THEN
                                   l_c5_change_only := FALSE;
                               END IF;

                           END IF;
                          END LOOP;
                        END LOOP;

                        IF (tab_liv_ba_data.COUNT = 0)
                        THEN
                           l_c5_change_only := FALSE;
                           tab_liv_pe_data.start_date := tab_24q_pe_data.start_date;
                           tab_liv_pe_data.end_date   := tab_24q_pe_data.end_date;
                        END IF;


                       IF (INSTR(l_action_information_category,'C4')<> 0) AND (g_correction_mode IN ('%','C4'))
                           AND ((l_c5_change_only = FALSE)) AND (g_quarter IN ('Q4') AND (l_flag = 0))
                       THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     g_sal_data_rec_del(i).source_id
                                             ,p_assignment_id                  =>     g_sal_data_rec_del(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'D'
                                             ,p_action_information11           =>     'C4'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );


                                         FOR l IN 1..tab_24q_ba_data.COUNT
                                         LOOP

                                            IF ((tab_24q_ba_data(l).balance_name IN ('F16 Gross Total Income')) AND
                                                (tab_24q_ba_data(l).balance_value <> 0)
                                               )
                                             THEN

                                              pay_action_information_api.create_action_information
                                                            (p_action_context_id              =>     l_arch_asg_action_id
                                                            ,p_action_context_type            =>     'AAP'
                                                            ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                            ,p_source_id                      =>     g_sal_data_rec_del(i).source_id
                                                            ,p_action_information1            =>     'Prev F16 Gross Total Income'
                                                            ,p_action_information2            =>     tab_24q_ba_data(l).balance_value
                                                            ,p_action_information_id          =>     l_action_info_id
                                                            ,p_object_version_number          =>     l_ovn
                                                            );
                                               END IF;
                                         END LOOP;

                              OPEN c_asg_act_id(p_24qa_pay_act_id,g_sal_data_rec_del(i).assignment_id);
                              FETCH c_asg_act_id INTO l_24qa_asg_action_id;
                              CLOSE c_asg_act_id;


                              OPEN  c_24qa_source_id(l_24qa_asg_action_id,g_sal_data_rec_del(i).assignment_id);
                              FETCH c_24qa_source_id INTO l_24qa_source_id,l_24qa_asg_action_id;
                              CLOSE c_24qa_source_id;

                              OPEN  c_get_bal_24q(l_24qa_asg_action_id,l_24qa_source_id,'IN_24Q_SALARY','F16 Gross Total Income');
                              FETCH c_get_bal_24q INTO l_balance_value;
                              CLOSE c_get_bal_24q;

                              IF ((l_24qa_source_id IS NOT NULL) AND (l_balance_value <> 0)) THEN
                                pay_action_information_api.create_action_information
                                              (p_action_context_id              =>     l_arch_asg_action_id
                                              ,p_action_context_type            =>     'AAP'
                                              ,p_action_information_category    =>     'IN_24QC_SALARY'
                                              ,p_source_id                      =>     g_sal_data_rec_del(i).source_id
                                              ,p_action_information1            =>     'Form24Q F16 Gross Total Income'
                                              ,p_action_information2            =>     l_balance_value
                                              ,p_action_information_id          =>     l_action_info_id
                                              ,p_object_version_number          =>     l_ovn
                                              );
                              END IF;

                       END IF;
                 END IF;

                        l_prev_pay := FALSE;
                        IF (l_c5_change_only=FALSE)
                        THEN
                              OPEN  c_max_pact(g_sal_data_rec_del(i).assignment_id);
                              FETCH c_max_pact INTO l_max_pact,l_assignment_id;
                              CLOSE c_max_pact;
                            IF (g_sal_data_rec_del(i).source_id < l_max_pact) AND (l_max_pact IS NOT NULL)
                            THEN
                              l_prev_pay := TRUE;
                            END IF;
                        END IF;

                       OPEN  c_max_salary_number_24qc;
                        FETCH c_max_salary_number_24qc INTO k;
                       CLOSE c_max_salary_number_24qc;

                       OPEN  c_max_salary_number_24q;
                        FETCH c_max_salary_number_24q INTO j;
                       CLOSE c_max_salary_number_24q;

                       pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                       pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);

                       l_flag2 := check_archival_status(l_max_pact,'IN_24QC_PERSON',NULL,'A');

                       IF (INSTR(l_action_information_category,'C4')<> 0) AND (g_correction_mode IN ('%','C4'))
                            AND ((l_c5_change_only=FALSE)) AND (l_prev_pay) AND (g_quarter IN ('Q4') AND (l_flag2=0))
                       THEN

                        pay_in_utils.trace('Delete Source ID :   ', g_sal_data_rec_del(i).source_id );
                        pay_in_utils.trace('l_max_pact       :   ', l_max_pact );

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     l_max_pact
                                             ,p_assignment_id                  =>     g_sal_data_rec_del(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'A'
                                             ,p_action_information11           =>     'C4'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0)) + s
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                           FOR l IN 1..tab_liv_ba_data.COUNT
                           LOOP

                               IF ((tab_liv_ba_data(l).balance_value <> 0) AND
                                   (tab_liv_ba_data(l).balance_name IN ('80CCE','Others'))
                                  )
                               THEN
                                          pay_action_information_api.create_action_information
                                                        (p_action_context_id              =>     l_arch_asg_action_id
                                                        ,p_action_context_type            =>     'AAP'
                                                        ,p_action_information_category    =>     'IN_24QC_VIA'
                                                        ,p_source_id                      =>     l_max_pact
                                                        ,p_action_information1            =>     tab_liv_ba_data(l).balance_name
                                                        ,p_action_information2            =>     tab_liv_ba_data(l).balance_value
                                                        ,p_action_information3            =>     0
                                                        ,p_action_information_id          =>     l_action_info_id
                                                        ,p_object_version_number          =>     l_ovn
                                                        );
                                ELSIF ((tab_liv_ba_data(l).balance_value <> 0) AND
                                       (tab_liv_ba_data(l).balance_name NOT IN ('F16 Deductions Sec 80CCE'))
                                      )
                                THEN
                                          pay_action_information_api.create_action_information
                                                        (p_action_context_id              =>     l_arch_asg_action_id
                                                        ,p_action_context_type            =>     'AAP'
                                                        ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                        ,p_source_id                      =>     l_max_pact
                                                        ,p_action_information1            =>     tab_liv_ba_data(l).balance_name
                                                        ,p_action_information2            =>     tab_liv_ba_data(l).balance_value
                                                        ,p_action_information_id          =>     l_action_info_id
                                                        ,p_object_version_number          =>     l_ovn
                                                        );
                                END IF;
                          END LOOP;
                       s := s + 1;
                       END IF;

                          OPEN  c_salary_number_24qc(tab_liv_pe_data.person_id,g_sal_data_rec_del(i).source_id);
                          FETCH c_salary_number_24qc INTO k;
                          CLOSE c_salary_number_24qc;

                          OPEN  c_salary_number_24q(tab_liv_pe_data.person_id,g_sal_data_rec_del(i).source_id);
                          FETCH c_salary_number_24q INTO j;
                          CLOSE c_salary_number_24q;

                          pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                          pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);


                          IF (INSTR(l_action_information_category,'C5')<> 0) AND (g_correction_mode IN ('%','C5') AND (l_prev_pay) AND (l_flag1=0))
                          THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     l_max_pact
                                             ,p_assignment_id                  =>     g_sal_data_rec_del(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'NA'
                                             ,p_action_information11           =>     'C5'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                                 FOR l IN 1..tab_24q_ba_data.COUNT
                                 LOOP

                                    IF ((tab_24q_ba_data(l).balance_name IN ('F16 Gross Total Income')) AND
                                        (tab_24q_ba_data(l).balance_value <> 0)
                                       )
                                    THEN

                                     pay_action_information_api.create_action_information
                                                   (p_action_context_id              =>     l_arch_asg_action_id
                                                   ,p_action_context_type            =>     'AAP'
                                                   ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                   ,p_source_id                      =>     l_max_pact
                                                   ,p_action_information1            =>     'Prev F16 Gross Total Income'
                                                   ,p_action_information2            =>     tab_24q_ba_data(l).balance_value
                                                   ,p_action_information_id          =>     l_action_info_id
                                                   ,p_object_version_number          =>     l_ovn
                                                   );
                                      END IF;
                                 END LOOP;

                        END IF;

             END LOOP;
         END IF;


      IF (s = 1) THEN
        s := 1;
      END IF;
      l_24qa_source_id := NULL;
      l_24qa_asg_action_id := NULL;
      l_prev_asg_action_id := NULL;
      l_prev_category := NULL;
      IF (g_correction_mode IN('C4','C5','%'))
      THEN
             pay_in_utils.set_location(g_debug,'Value of g_count_sal_addition : '|| g_count_sal_addition, 1);
             FOR i IN 1..g_count_sal_addition - 1
             LOOP

                OPEN c_asg_act_id(p_24qa_pay_act_id,g_sal_data_rec_add(i).assignment_id);
                FETCH c_asg_act_id INTO l_24qa_asg_action_id;
                CLOSE c_asg_act_id;

                OPEN  c_24qc_source_id(l_24qa_asg_action_id,g_sal_data_rec_add(i).assignment_id);
                FETCH c_24qc_source_id INTO l_24qa_source_id,l_24qa_asg_action_id;
                 pay_in_utils.set_location(g_debug,'Found source id in 24Q Correction: '|| l_24qa_source_id ,2);
                CLOSE c_24qc_source_id;

                IF (l_24qa_source_id IS NOT NULL)
                THEN
                 l_prev_asg_action_id := l_24qa_asg_action_id;
                 l_prev_category := 'IN_24QC_SALARY';
                END IF;

                IF (l_24qa_source_id IS NULL)
                THEN
                   pay_in_utils.set_location(g_debug,'Source ID is NULL' ,2);
                   pay_in_utils.set_location(g_debug,'Hence Searching in 24Q Archival ' ,2);
                   OPEN  c_24qa_source_id(l_24qa_asg_action_id,g_sal_data_rec_add(i).assignment_id);
                   FETCH c_24qa_source_id INTO l_24qa_source_id,l_24qa_asg_action_id;
                   CLOSE c_24qa_source_id;
                l_prev_asg_action_id := l_24qa_asg_action_id;
                l_prev_category := 'IN_24Q_SALARY';
                END IF;

                pay_in_utils.trace('l_24qa_source_id in g_count_sal_addition ',l_24qa_source_id);

                pay_in_utils.set_location(g_debug,'Checking archived presence of this added assignment action',1);
                l_flag := -1;
                l_flag1 := -1;
                l_flag2 := -1;
                l_gre_count := 0;
                l_prev_c5 := TRUE;

                pay_in_utils.trace('l_24qa_source_id in g_count_sal_addition ',l_24qa_source_id);

                l_flag := check_archival_status(g_sal_data_rec_add(i).source_id,'IN_24QC_PERSON',NULL,'A');
                l_flag1 := check_archival_status(g_sal_data_rec_add(i).source_id,'IN_24QC_PERSON',NULL,'NA');

                pay_in_utils.trace('l_flag in g_count_sal_addition  :',l_flag);
                pay_in_utils.trace('l_flag1 in g_count_sal_addition :',l_flag1);

                IF ((l_flag = 0) AND (l_flag1 = 0))
                THEN
                     pay_in_utils.set_location(g_debug,'Added Salary Detail Not Archived. Hence doing.. '||g_sal_data_rec_add(i).source_id,1);

                    pay_in_utils.set_location(g_debug,'Fetching balance data  ', 1);
                    pay_in_utils.set_location(g_debug,'For Assignment Action ID :  '|| g_sal_data_rec_add(i).source_id,1);
                    pay_in_utils.set_location(g_debug,'Calling....get_balance_values ',1);
                    pay_in_utils.set_location(g_debug,'Assignment Action id is ' || g_sal_data_rec_add(i).last_action_context_id ,2);
                    pay_in_utils.set_location(g_debug,'Assignment id is ' || g_sal_data_rec_add(i).assignment_id,3);


                     IF (l_24qa_asg_action_id IS NULL) THEN
                           l_24qa_asg_action_id := g_sal_data_rec_add(i).source_id;
                     END IF;

                       get_balance_values
                        (
                          g_sal_data_rec_add(i).source_id
                         ,l_24qa_asg_action_id
                         ,g_sal_data_rec_add(i).assignment_id
                         ,p_24qa_pay_act_id
                         ,'A'
                         ,tab_liv_ba_data
                         ,tab_24q_ba_data
                         ,tab_liv_pe_data
                         ,tab_24q_pe_data
                         ,l_gre_count
                        );

                      pay_in_utils.set_location(g_debug,'Called....get_balance_values ',1);
                      pay_in_utils.set_location(g_debug,'Fetched balance data  ', 1);

                      pay_in_utils.trace('tab_liv_pe_data.pan_number  : ', tab_liv_pe_data.pan_number );
                      pay_in_utils.trace('tab_24q_pe_data.pan_number  : ', tab_24q_pe_data.pan_number );


                      IF ((g_correction_mode IN('C4','C5','%'))
                            AND(tab_24q_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                            AND(tab_liv_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                            AND(tab_24q_pe_data.pan_number <> tab_liv_pe_data.pan_number)
                          )
                      THEN
                               l_action_information_category := 'C4:C5';
                      ELSE
                               l_action_information_category := 'C4';
                      END IF;

                      OPEN c_asg_act_id(p_payroll_action_id,g_sal_data_rec_add(i).assignment_id);
                      FETCH c_asg_act_id INTO l_arch_asg_action_id;
                      CLOSE c_asg_act_id;

                      j := -1;
                      k := -1;

                      OPEN  c_salary_number_24qc(tab_liv_pe_data.person_id,l_24qa_source_id);
                      FETCH c_salary_number_24qc INTO k;
                      CLOSE c_salary_number_24qc;

                      OPEN  c_salary_number_24q(tab_liv_pe_data.person_id,l_24qa_source_id);
                      FETCH c_salary_number_24q INTO j;
                      CLOSE c_salary_number_24q;

                      pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                      pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);

                       l_c5_change_only := TRUE;
                       pay_in_utils.trace('Count of live balances  : ', tab_liv_ba_data.COUNT );
                       pay_in_utils.trace('Count of 24q balances   : ', tab_24q_ba_data.COUNT );

                       FOR j IN 1..tab_liv_ba_data.COUNT
                       LOOP
                         FOR k IN 1..tab_24q_ba_data.COUNT
                         LOOP
                           IF (tab_liv_ba_data(j).balance_name = tab_24q_ba_data(k).balance_name)
                           THEN

                               IF ((tab_liv_ba_data(j).balance_value <> 0) AND
                                   (tab_liv_ba_data(j).balance_value <> tab_24q_ba_data(k).balance_value) AND
                                   (tab_liv_ba_data(j).balance_name NOT IN ('F16 Deductions Sec 80CCE'))
                                  )
                               THEN
                                   l_c5_change_only := FALSE;
                               END IF;

                           END IF;
                          END LOOP;
                        END LOOP;

                        IF (tab_24q_ba_data.COUNT = 0)
                        THEN
                           l_c5_change_only := FALSE;
                           l_prev_c5 := FALSE;
                        END IF;

                        pay_in_utils.trace('Addition Source ID : ', g_sal_data_rec_add(i).source_id );
                        pay_in_utils.trace('Addition Assignment ID :  ', g_sal_data_rec_add(i).assignment_id );

                        IF (INSTR(l_action_information_category,'C5')<> 0) AND (g_correction_mode IN ('%','C5') AND (l_flag1=0) AND (l_prev_c5))
                        THEN
                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     g_sal_data_rec_add(i).source_id
                                             ,p_assignment_id                  =>     g_sal_data_rec_add(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'NA'
                                             ,p_action_information11           =>     'C5'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                                       FOR l IN 1..tab_24q_ba_data.COUNT
                                       LOOP

                                           IF ((tab_24q_ba_data(l).balance_name IN ('F16 Gross Total Income')) AND
                                               (tab_24q_ba_data(l).balance_value <> 0)
                                              )
                                           THEN

                                            pay_action_information_api.create_action_information
                                                          (p_action_context_id              =>     l_arch_asg_action_id
                                                          ,p_action_context_type            =>     'AAP'
                                                          ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                          ,p_source_id                      =>     g_sal_data_rec_add(i).source_id
                                                          ,p_action_information1            =>     'Prev F16 Gross Total Income'
                                                          ,p_action_information2            =>     tab_24q_ba_data(l).balance_value
                                                          ,p_action_information_id          =>     l_action_info_id
                                                          ,p_object_version_number          =>     l_ovn
                                                          );
                                             END IF;
                                        END LOOP;

                        END IF;


                        OPEN  c_max_salary_number_24qc;
                        FETCH c_max_salary_number_24qc INTO k;
                        CLOSE c_max_salary_number_24qc;

                        OPEN  c_max_salary_number_24q;
                        FETCH c_max_salary_number_24q INTO j;
                        CLOSE c_max_salary_number_24q;

                        pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                        pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);


                       IF (INSTR(l_action_information_category,'C4')<> 0) AND (g_correction_mode IN ('%','C4'))
                            AND ((l_c5_change_only=FALSE)) AND (g_quarter IN ('Q4') AND (l_flag=0))
                       THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     g_sal_data_rec_add(i).source_id
                                             ,p_assignment_id                  =>     g_sal_data_rec_add(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'A'
                                             ,p_action_information11           =>     'C4'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0)) + s
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                                 FOR l IN 1..tab_liv_ba_data.COUNT
                                 LOOP

                                     IF ((tab_liv_ba_data(l).balance_value <> 0) AND
                                         (tab_liv_ba_data(l).balance_name IN ('80CCE','Others'))
                                        )
                                     THEN
                                                pay_action_information_api.create_action_information
                                                              (p_action_context_id              =>     l_arch_asg_action_id
                                                              ,p_action_context_type            =>     'AAP'
                                                              ,p_action_information_category    =>     'IN_24QC_VIA'
                                                              ,p_source_id                      =>     g_sal_data_rec_add(i).source_id
                                                              ,p_action_information1            =>     tab_liv_ba_data(l).balance_name
                                                              ,p_action_information2            =>     tab_liv_ba_data(l).balance_value
                                                              ,p_action_information3            =>     0
                                                              ,p_action_information_id          =>     l_action_info_id
                                                              ,p_object_version_number          =>     l_ovn
                                                              );
                                      ELSIF ((tab_liv_ba_data(l).balance_value <> 0) AND
                                             (tab_liv_ba_data(l).balance_name NOT IN ('F16 Deductions Sec 80CCE'))
                                            )
                                      THEN
                                                pay_action_information_api.create_action_information
                                                              (p_action_context_id              =>     l_arch_asg_action_id
                                                              ,p_action_context_type            =>     'AAP'
                                                              ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                              ,p_source_id                      =>     g_sal_data_rec_add(i).source_id
                                                              ,p_action_information1            =>     tab_liv_ba_data(l).balance_name
                                                              ,p_action_information2            =>     tab_liv_ba_data(l).balance_value
                                                              ,p_action_information_id          =>     l_action_info_id
                                                              ,p_object_version_number          =>     l_ovn
                                                              );
                                      END IF;
                                END LOOP;
                       s := s + 1;
                       END IF;
                END IF;



                      l_future_pay := FALSE;
                      l_prev_max_pact := NULL;
                      l_count_delete := 0;

                      IF (l_c5_change_only)
                      THEN
                      NULL;
                      ELSE
                          OPEN  c_prev_max_pact(g_sal_data_rec_add(i).assignment_id,g_sal_data_rec_add(i).source_id);
                          FETCH c_prev_max_pact INTO l_prev_max_pact,l_assignment_id;
                          CLOSE c_prev_max_pact;
                        IF (l_prev_max_pact IS NOT NULL)
                        THEN
                               FOR p IN 1..g_count_sal_delete - 1
                               LOOP
                                 IF (g_sal_data_rec_add(i).assignment_id = g_sal_data_rec_del(p).assignment_id)
                                 THEN
                                  l_count_delete := l_count_delete + 1;
                                 END IF;
                               END LOOP;
                               IF (l_count_delete = 0) THEN
                                  l_future_pay := TRUE;
                               END IF;
                        END IF;
                      END IF;



                      OPEN  c_salary_number_24qc(tab_liv_pe_data.person_id,l_prev_max_pact);
                      FETCH c_salary_number_24qc INTO k;
                      CLOSE c_salary_number_24qc;

                      OPEN  c_salary_number_24q(tab_liv_pe_data.person_id,l_prev_max_pact);
                      FETCH c_salary_number_24q INTO j;
                      CLOSE c_salary_number_24q;

                      pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                      pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);

                       l_flag2 := check_archival_status(l_prev_max_pact,'IN_24QC_PERSON',NULL,'D');

                       IF (INSTR(l_action_information_category,'C4')<> 0) AND (g_correction_mode IN ('%','C4'))
                            AND ((l_c5_change_only=FALSE)) AND (l_future_pay=TRUE) AND ((j>0) OR (j IS NULL)) AND (g_quarter IN ('Q4') AND (l_flag2=0))
                       THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     l_prev_max_pact
                                             ,p_assignment_id                  =>     g_sal_data_rec_add(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'D'
                                             ,p_action_information11           =>     'C4'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );


                                             OPEN  c_get_bal_24q(l_prev_asg_action_id,l_prev_max_pact,l_prev_category,'F16 Gross Total Income');
                                             FETCH c_get_bal_24q INTO l_balance_value;
                                             CLOSE c_get_bal_24q;

                                             pay_in_utils.trace('l_balance_value : ',l_balance_value);

                                             IF ((l_prev_asg_action_id IS NOT NULL) AND (l_balance_value <> 0))
                                             THEN

                                                   pay_action_information_api.create_action_information
                                                                 (p_action_context_id              =>     l_arch_asg_action_id
                                                                 ,p_action_context_type            =>     'AAP'
                                                                 ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                                 ,p_source_id                      =>     l_prev_max_pact
                                                                 ,p_action_information1            =>     'Prev F16 Gross Total Income'
                                                                 ,p_action_information2            =>     l_balance_value--tab_24q_ba_data(l).balance_value
                                                                 ,p_action_information_id          =>     l_action_info_id
                                                                 ,p_object_version_number          =>     l_ovn
                                                                 );
                                             END IF;


                                                OPEN c_asg_act_id(p_24qa_pay_act_id,g_sal_data_rec_add(i).assignment_id);
                                                FETCH c_asg_act_id INTO l_24qa_asg_action_id;
                                                CLOSE c_asg_act_id;

                                                OPEN  c_24qa_source_id(l_24qa_asg_action_id,g_sal_data_rec_add(i).assignment_id);
                                                FETCH c_24qa_source_id INTO l_24qa_source_id,l_24qa_asg_action_id;
                                                CLOSE c_24qa_source_id;

                                                OPEN  c_get_bal_24q(l_24qa_asg_action_id,l_24qa_source_id,'IN_24Q_SALARY','F16 Gross Total Income');
                                                FETCH c_get_bal_24q INTO l_balance_value;
                                                CLOSE c_get_bal_24q;

                                           IF ((l_24qa_source_id IS NOT NULL) AND (l_balance_value <> 0))
                                           THEN
                                                   pay_action_information_api.create_action_information
                                                                 (p_action_context_id              =>     l_arch_asg_action_id
                                                                 ,p_action_context_type            =>     'AAP'
                                                                 ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                                 ,p_source_id                      =>     l_prev_max_pact
                                                                 ,p_action_information1            =>     'Form24Q F16 Gross Total Income'
                                                                 ,p_action_information2            =>     l_balance_value
                                                                 ,p_action_information_id          =>     l_action_info_id
                                                                 ,p_object_version_number          =>     l_ovn
                                                                 );
                                           END IF;

                       END IF;
             END LOOP;
      END IF;


      IF (s = 1) THEN
        s := 1;
      END IF;
      l_24qa_source_id := NULL;
      l_24qa_asg_action_id := NULL;
      IF (g_correction_mode IN('C4','C5','%'))
      THEN
        pay_in_utils.set_location(g_debug,'Value of g_count_sal_update : '|| g_count_sal_update, 1);

      FOR i IN 1..g_count_sal_update - 1
      LOOP
         pay_in_utils.set_location(g_debug,'Checking archived presence of this updated assignment action',1);
         l_flag  := -1;
         l_flag1 := -1;
         l_flag2 := -1;
         l_gre_count := 0;
         l_c5_tot_income_flag := FALSE;

         l_flag  := check_archival_status(g_sal_data_rec_upd(i).source_id,'IN_24QC_PERSON',NULL,'A');
         l_flag1 := check_archival_status(g_sal_data_rec_upd(i).source_id,'IN_24QC_PERSON',NULL,'NA');
         l_flag2 := check_archival_status(g_sal_data_rec_upd(i).source_id,'IN_24QC_PERSON',NULL,'D');

          pay_in_utils.trace('l_flag in g_count_sal_update   : ', l_flag );
          pay_in_utils.trace('l_flag1 in g_count_sal_update  : ', l_flag1 );
          pay_in_utils.trace('l_flag2 in g_count_sal_update  : ', l_flag2 );


         IF ((l_flag = 0) AND (l_flag1 = 0) )
         THEN
              pay_in_utils.set_location(g_debug,'Updated Asg Action Not Archived. hence doing '||g_sal_data_rec_upd(i).source_id,1);

               pay_in_utils.set_location(g_debug,'Fetching balances...',2);

                       get_balance_values
                        (
                          g_sal_data_rec_upd(i).source_id
                         ,g_sal_data_rec_upd(i).last_action_context_id
                         ,g_sal_data_rec_upd(i).assignment_id
                         ,p_24qa_pay_act_id
                         ,'U'
                         ,tab_liv_ba_data
                         ,tab_24q_ba_data
                         ,tab_liv_pe_data
                         ,tab_24q_pe_data
                         ,l_gre_count
                        );


                pay_in_utils.set_location(g_debug,'Fetched balances...',2);
                pay_in_utils.set_location(g_debug,'Fetching Archival Assignment Action ID...',2);
                pay_in_utils.set_location(g_debug,'Asg ID' ||   g_sal_data_rec_upd(i).assignment_id ,2);
                pay_in_utils.set_location(g_debug,'Payroll Action id is ' || p_payroll_action_id ,2);

                OPEN c_asg_act_id(p_payroll_action_id,g_sal_data_rec_upd(i).assignment_id);
                FETCH c_asg_act_id INTO l_arch_asg_action_id;
                CLOSE c_asg_act_id;

                 pay_in_utils.set_location(g_debug,'Archival Assignment Action ID is :'|| l_arch_asg_action_id ,2);

                --      if g_correction_mode = 'C5' and tab_24q_pe_data.pan_number IS VALID and
                --       tab_liv_pe_data.pan_number is also valid and not equal 2 each other
                --       then not only arhcive this assignment data, but also last organization PA data

                         pay_in_utils.trace('tab_liv_pe_data.pan_number  : ', tab_liv_pe_data.pan_number );
                         pay_in_utils.trace('tab_24q_pe_data.pan_number  : ', tab_24q_pe_data.pan_number );

                         IF ((g_correction_mode IN('C4','C5','%'))
                              AND(tab_24q_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                              AND(tab_liv_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                              AND(tab_24q_pe_data.pan_number <> tab_liv_pe_data.pan_number)
                            )
                         THEN
                                 l_action_information_category := 'C4:C5';
                         ELSE
                                 l_action_information_category := 'C4';
                         END IF;

                          OPEN  c_salary_number_24qc(tab_liv_pe_data.person_id,g_sal_data_rec_upd(i).source_id);
                          FETCH c_salary_number_24qc INTO k;
                          CLOSE c_salary_number_24qc;

                          OPEN  c_salary_number_24q(tab_liv_pe_data.person_id,g_sal_data_rec_upd(i).source_id);
                          FETCH c_salary_number_24q INTO j;
                          CLOSE c_salary_number_24q;

                          pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                          pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);

                    l_c5_change_only := TRUE;
                    pay_in_utils.trace('Count of live balances  : ', tab_liv_ba_data.COUNT );
                    pay_in_utils.trace('Count of 24q balances   : ', tab_24q_ba_data.COUNT );

                    FOR j IN 1..tab_liv_ba_data.COUNT
                    LOOP
                       FOR k IN 1..tab_24q_ba_data.COUNT
                       LOOP

                          IF (tab_liv_ba_data(j).balance_name = tab_24q_ba_data(k).balance_name)
                            THEN
                                IF ((tab_liv_ba_data(j).balance_value <> 0) AND
                                    (tab_liv_ba_data(j).balance_value <> tab_24q_ba_data(k).balance_value) AND
                                    (tab_liv_ba_data(j).balance_name NOT IN ('F16 Deductions Sec 80CCE'))
                                    )
                                THEN
                                  l_c5_change_only := FALSE;
                                 END IF;
                            END IF;

                     END LOOP;
                    END LOOP;

                     l_future_pay := TRUE;

                     OPEN  c_max_pact(g_sal_data_rec_upd(i).assignment_id);
                       FETCH c_max_pact INTO l_max_pact,l_assignment_id;
                     CLOSE c_max_pact;

                     IF ((g_sal_data_rec_upd(i).source_id < l_max_pact) AND (l_gre_count <= 2))
                     THEN
                       l_future_pay := FALSE;
                     END IF;

                         pay_in_utils.trace('Update Source_id :',g_sal_data_rec_upd(i).source_id);
                         pay_in_utils.trace('l_max_pact ',l_max_pact);
                         pay_in_utils.trace('l_gre_count in g_count_sal_update: ',l_gre_count);

                          IF (INSTR(l_action_information_category,'C5')<> 0) AND (g_correction_mode IN ('%','C5') AND (l_flag1=0) AND (l_future_pay=TRUE))
                          THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                             ,p_assignment_id                  =>     g_sal_data_rec_upd(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'NA'
                                             ,p_action_information11           =>     'C5'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                                              FOR l IN 1..tab_24q_ba_data.COUNT
                                              LOOP

                                                  IF ((tab_24q_ba_data(l).balance_name IN ('F16 Gross Total Income')) AND
                                                      (tab_24q_ba_data(l).balance_value <> 0)
                                                     )
                                                  THEN

                                                   pay_action_information_api.create_action_information
                                                                 (p_action_context_id              =>     l_arch_asg_action_id
                                                                 ,p_action_context_type            =>     'AAP'
                                                                 ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                                 ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                                                 ,p_action_information1            =>     'Prev F16 Gross Total Income'
                                                                 ,p_action_information2            =>     tab_24q_ba_data(l).balance_value
                                                                 ,p_action_information_id          =>     l_action_info_id
                                                                 ,p_object_version_number          =>     l_ovn
                                                                 );
                                                    l_c5_tot_income_flag := TRUE;
                                                    END IF;
                                               END LOOP;

                       END IF;

                       IF (INSTR(l_action_information_category,'C4')<> 0) AND (g_correction_mode IN ('%','C4'))
                            AND (l_c5_change_only=FALSE) AND (g_quarter IN ('Q4') AND (l_flag2 = 0))
                       THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                             ,p_assignment_id                  =>     g_sal_data_rec_upd(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'D'
                                             ,p_action_information11           =>     'C4'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                                       IF (l_c5_tot_income_flag=FALSE)
                                       THEN
                                              FOR l IN 1..tab_24q_ba_data.COUNT
                                              LOOP

                                                  IF ((tab_24q_ba_data(l).balance_name IN ('F16 Gross Total Income')) AND
                                                      (tab_24q_ba_data(l).balance_value <> 0)
                                                     )
                                                  THEN

                                                   pay_action_information_api.create_action_information
                                                                 (p_action_context_id              =>     l_arch_asg_action_id
                                                                 ,p_action_context_type            =>     'AAP'
                                                                 ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                                 ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                                                 ,p_action_information1            =>     'Prev F16 Gross Total Income'
                                                                 ,p_action_information2            =>     tab_24q_ba_data(l).balance_value
                                                                 ,p_action_information_id          =>     l_action_info_id
                                                                 ,p_object_version_number          =>     l_ovn
                                                                 );
                                                    END IF;
                                               END LOOP;
                                          END IF;


                                                OPEN c_asg_act_id(p_24qa_pay_act_id,g_sal_data_rec_upd(i).assignment_id);
                                                FETCH c_asg_act_id INTO l_24qa_asg_action_id;
                                                CLOSE c_asg_act_id;

                                                OPEN  c_24qa_source_id(l_24qa_asg_action_id,g_sal_data_rec_upd(i).assignment_id);
                                                FETCH c_24qa_source_id INTO l_24qa_source_id,l_24qa_asg_action_id;
                                                CLOSE c_24qa_source_id;

                                                OPEN  c_get_bal_24q(l_24qa_asg_action_id,l_24qa_source_id,'IN_24Q_SALARY','F16 Gross Total Income');
                                                FETCH c_get_bal_24q INTO l_balance_value;
                                                CLOSE c_get_bal_24q;

                                                IF ((l_24qa_source_id IS NOT NULL) AND (l_balance_value <> 0)) THEN
                                                   pay_action_information_api.create_action_information
                                                                 (p_action_context_id              =>     l_arch_asg_action_id
                                                                 ,p_action_context_type            =>     'AAP'
                                                                 ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                                 ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                                                 ,p_action_information1            =>     'Form24Q F16 Gross Total Income'
                                                                 ,p_action_information2            =>     l_balance_value
                                                                 ,p_action_information_id          =>     l_action_info_id
                                                                 ,p_object_version_number          =>     l_ovn
                                                                 );
                                                END IF;

                       END IF;

                       j := -1;
                       k := -1;

                       OPEN  c_max_salary_number_24qc;
                        FETCH c_max_salary_number_24qc INTO k;
                       CLOSE c_max_salary_number_24qc;

                       OPEN  c_max_salary_number_24q;
                        FETCH c_max_salary_number_24q INTO j;
                       CLOSE c_max_salary_number_24q;

                       pay_in_utils.set_location(g_debug,'Previous Salary Detail Record Number was:' || j, 3);
                       pay_in_utils.set_location(g_debug,'New Salary Detail Record Number is:' || k,4);

                       IF (INSTR(l_action_information_category,'C4')<> 0)AND(g_correction_mode IN ('%','C4'))
                            AND (l_c5_change_only=FALSE) AND (g_quarter IN ('Q4') AND (l_flag = 0))
                       THEN

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_PERSON'
                                             ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                             ,p_assignment_id                  =>     g_sal_data_rec_upd(i).assignment_id
                                             ,p_action_information1            =>     tab_liv_pe_data.person_id
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information5            =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information6            =>     tab_liv_pe_data.full_name
                                             ,p_action_information7            =>     pay_in_24q_er_returns.get_emp_category(tab_liv_pe_data.person_id)
                                             ,p_action_information8            =>     fnd_date.date_to_canonical(tab_liv_pe_data.start_date)
                                             ,p_action_information9            =>     fnd_date.date_to_canonical(tab_liv_pe_data.end_date)
                                             ,p_action_information10           =>     'A'
                                             ,p_action_information11           =>     'C4'
                                             ,p_action_information12           =>     GREATEST(NVL(j,0),NVL(k,0)) + s
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );

                           FOR l IN 1..tab_liv_ba_data.COUNT
                           LOOP

                               IF ((tab_liv_ba_data(l).balance_value <> 0) AND
                                   (tab_liv_ba_data(l).balance_name IN ('80CCE','Others'))
                                  )
                               THEN
                                          pay_action_information_api.create_action_information
                                                        (p_action_context_id              =>     l_arch_asg_action_id
                                                        ,p_action_context_type            =>     'AAP'
                                                        ,p_action_information_category    =>     'IN_24QC_VIA'
                                                        ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                                        ,p_action_information1            =>     tab_liv_ba_data(l).balance_name
                                                        ,p_action_information2            =>     tab_liv_ba_data(l).balance_value
                                                        ,p_action_information3            =>     0
                                                        ,p_action_information_id          =>     l_action_info_id
                                                        ,p_object_version_number          =>     l_ovn
                                                        );
                                ELSIF ((tab_liv_ba_data(l).balance_value <> 0) AND
                                       (tab_liv_ba_data(l).balance_name NOT IN ('F16 Deductions Sec 80CCE'))
                                      )
                                THEN
                                          pay_action_information_api.create_action_information
                                                        (p_action_context_id              =>     l_arch_asg_action_id
                                                        ,p_action_context_type            =>     'AAP'
                                                        ,p_action_information_category    =>     'IN_24QC_SALARY'
                                                        ,p_source_id                      =>     g_sal_data_rec_upd(i).source_id
                                                        ,p_action_information1            =>     tab_liv_ba_data(l).balance_name
                                                        ,p_action_information2            =>     tab_liv_ba_data(l).balance_value
                                                        ,p_action_information_id          =>     l_action_info_id
                                                        ,p_object_version_number          =>     l_ovn
                                                        );
                                END IF;
                          END LOOP;
                   s := s + 1;
                       END IF;
        END IF;
      END LOOP;

    END IF;


  pay_in_utils.set_location(g_debug,'Leaving '|| l_procedure, 5);

  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END archive_salary_data;



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_DEDUCTEE_DATA                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure to actually archive the data.             --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE archive_deductee_data(p_payroll_action_id   NUMBER
                                 ,p_24qa_pay_act_id     NUMBER
                                 )
  IS
  CURSOR c_c5_correction_type_details(p_last_arc_asg_action_id  NUMBER)
  IS
    SELECT pai.action_information_category
          ,pai.action_context_id
      FROM pay_action_information pai
          ,pay_assignment_actions paa
     WHERE paa.assignment_action_id = p_last_arc_asg_action_id
       AND pai.action_context_id    = paa.payroll_action_id
       AND pai.action_context_type  = 'PA'
     ORDER BY pai.action_context_id DESC;

  CURSOR c_deductee_number_24q(p_challan_number      VARCHAR2
                              ,p_element_entry_id    NUMBER
                              )
  IS
        SELECT action_information25
          FROM pay_action_information pai
              ,pay_assignment_actions paa
         WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information1         = p_challan_number
           AND pai.action_context_id           = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND pai.source_id                   = p_element_entry_id;

  CURSOR c_deductee_number_24qc(p_challan_number      VARCHAR2
                               ,p_element_entry_id    NUMBER
                               )
      IS
        SELECT action_information25
          FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
         WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information1         = p_challan_number
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND pai.source_id                   = p_element_entry_id;


  CURSOR c_max_challan_number_24qc(p_challan_number      VARCHAR2)
      IS
        SELECT MAX(TO_NUMBER(action_information25))
          FROM pay_action_information pai
              ,pay_assignment_actions paa
              ,pay_action_interlocks  locks
              ,pay_assignment_actions paa_master
         WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information2         = g_year||g_quarter
           AND pai.action_information1         = p_challan_number
           AND locks.locking_action_id         = pai.action_context_id
           AND locks.locked_action_id          = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa_master.assignment_action_id = pai.action_context_id
           AND paa_master.payroll_action_id IN(
                                                  SELECT org_information3
                                                    FROM hr_organization_information
                                                   WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                     AND organization_id         = g_gre_id
                                                     AND org_information1        = g_year
                                                     AND org_information2        = g_quarter
                                                     AND org_information5        = 'A'
                                                     AND org_information6        = 'C'
                                                 );

  CURSOR c_max_challan_number_24q(p_challan_number      VARCHAR2)
      IS
        SELECT MAX(TO_NUMBER(action_information25))
          FROM pay_action_information pai
              ,pay_assignment_actions paa
         WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
           AND pai.action_information3         = g_gre_id
           AND pai.action_information1         = p_challan_number
           AND pai.action_context_id           = paa.assignment_action_id
           AND paa.payroll_action_id           = p_24qa_pay_act_id
           AND paa.payroll_action_id IN(
                                        SELECT org_information3
                                          FROM hr_organization_information
                                         WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                           AND organization_id         = g_gre_id
                                           AND org_information1        = g_year
                                           AND org_information2        = g_quarter
                                           AND org_information5        = 'A'
                                           AND org_information6        = 'O'
                                       );

  CURSOR c_asg_act_id(p_assignment_id         NUMBER)
  IS
     SELECT assignment_action_id
       FROM pay_assignment_actions
      WHERE payroll_action_id = p_payroll_action_id
        AND assignment_id     = p_assignment_id;

    tab_24q_ee_data  t_screen_entry_value_rec;
    tab_liv_ee_data  t_screen_entry_value_rec;
    tab_24q_pe_data  t_person_data_rec;
    tab_liv_pe_data  t_person_data_rec;

    l_action_information_category pay_action_information.action_information_category%TYPE;
    l_action_context_id           NUMBER;
    l_deductee_detail             NUMBER;
    l_arch_asg_action_id          NUMBER;
    l_action_info_id              NUMBER;
    l_ovn                         NUMBER;
    j                             NUMBER;
    k                             NUMBER;
    s                             NUMBER;
    l_dummy                       NUMBER  := -1;
    l_flag                        NUMBER  := -1;
    l_c5_change                   BOOLEAN;
    l_category                    pay_action_information.action_information_category%TYPE;
    l_procedure                   VARCHAR2(250);
    l_message                     VARCHAR2(250);
  BEGIN
      g_debug     := hr_utility.debug_enabled;
      l_procedure := g_package ||'.archive_deductee_data';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      pay_in_utils.set_location(g_debug,'Fetching Deductee Data ', 1);
      pay_in_utils.set_location(g_debug,'Value of g_count_ee_delete : '|| g_count_ee_delete, 1);
      IF (g_correction_mode <> 'C9')
      THEN
             FOR i IN 1..g_count_ee_delete - 1
             LOOP

                pay_in_utils.set_location(g_debug,'Checking archived presence of this deleted ee',1);
                l_flag := -1;

                l_flag := check_archival_status(g_ee_data_rec_del(i).element_entry_id,'IN_24QC_DEDUCTEE',NULL,'D');
                IF (l_flag = 0)
                THEN
                      pay_in_utils.set_location(g_debug,'Deleted EE Not Archived. hence doing '||g_ee_data_rec_del(i).element_entry_id,1);

                       get_element_entry_values
                        (
                          g_ee_data_rec_del(i).element_entry_id
                         ,g_ee_data_rec_del(i).last_action_context_id
                         ,g_ee_data_rec_del(i).assignment_id
                         ,tab_liv_ee_data
                         ,tab_24q_ee_data
                         ,tab_liv_pe_data
                         ,tab_24q_pe_data
                        );

                --      if g_correction_mode = 'C5' and tab_24q_pe_data.pan_number IS VALID and
                --       tab_liv_pe_data.pan_number is also valid and not equal 2 each other
                --       then not only arhcive this assignment data, but also last organization PA data

                         IF ((g_correction_mode IN('C3','C5','%'))
                              AND(tab_24q_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                              AND(tab_liv_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                              AND(tab_24q_pe_data.pan_number <> tab_liv_pe_data.pan_number)
                            )
                         THEN
                                 l_action_information_category := 'C3:C5';
                                 l_action_context_id           := -1;
                         ELSE
                                 l_action_information_category := 'C3';
                                 l_action_context_id           := -1;
                         END IF;

                         OPEN  c_asg_act_id(g_ee_data_rec_del(i).assignment_id);
                         FETCH c_asg_act_id INTO l_arch_asg_action_id;
                         CLOSE c_asg_act_id;

                          OPEN  c_deductee_number_24qc(tab_24q_ee_data.challan_number,g_ee_data_rec_del(i).element_entry_id);
                          FETCH c_deductee_number_24qc INTO k;
                          CLOSE c_deductee_number_24qc;

                          OPEN  c_deductee_number_24q(tab_24q_ee_data.challan_number,g_ee_data_rec_del(i).element_entry_id);
                          FETCH c_deductee_number_24q INTO j;
                          CLOSE c_deductee_number_24q;

                          pay_in_utils.set_location(g_debug,'Previous Challan Deductee Record Number was:' || j, 3);
                          pay_in_utils.set_location(g_debug,'New Challan Deductee Record Number is:' || k,4);

                          IF (INSTR(l_action_information_category,'C5')<> 0)AND(g_correction_mode IN ('%','C5'))
                          THEN
                                l_category := SUBSTR(l_action_information_category
                                                    ,1
                                                    ,INSTR(l_action_information_category,'G')
                                                    );
                                l_category := l_category || 'C5';

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_DEDUCTEE'
                                             ,p_source_id                      =>     g_ee_data_rec_del(i).element_entry_id
                                             ,p_assignment_id                  =>     g_ee_data_rec_del(i).assignment_id
                                             ,p_action_information1            =>     tab_24q_ee_data.challan_number
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_24q_ee_data.payment_date
                                             ,p_action_information5            =>     tab_24q_ee_data.taxable_income
                                             ,p_action_information6            =>     tab_24q_ee_data.income_tax
                                             ,p_action_information7            =>     tab_24q_ee_data.surcharge
                                             ,p_action_information8            =>     tab_24q_ee_data.education_cess
                                             ,p_action_information9            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information10           =>     tab_liv_pe_data.full_name
                                             ,p_action_information11           =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information12           =>     tab_liv_pe_data.person_id
                                             ,p_action_information13           =>     tab_24q_pe_data.pan_number
                                             ,p_action_information14           =>     tab_24q_pe_data.pan_ref_number
                                             ,p_action_information15           =>     'D'
                                             ,p_action_information16           =>     tab_24q_ee_data.amount_deposited
                                             ,p_action_information17           =>     NVL(tab_24q_ee_data.income_tax,0) + NVL(tab_24q_ee_data.surcharge,0) + NVL(tab_24q_ee_data.education_cess,0)
                                             ,p_action_information18           =>     tab_liv_pe_data.tax_rate
                                             ,p_action_information19           =>     l_category
                                             ,p_action_information20           =>     l_action_context_id
                                             ,p_action_information21           =>     tab_24q_ee_data.income_tax
                                             ,p_action_information22           =>     tab_24q_ee_data.surcharge
                                             ,p_action_information23           =>     tab_24q_ee_data.education_cess
                                             ,p_action_information24           =>     tab_24q_ee_data.amount_deposited
                                             ,p_action_information25           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );
                       END IF;

                       IF (INSTR(l_action_information_category,'C3')<> 0)AND(g_correction_mode IN ('%','C3'))
                       THEN
                                l_category := SUBSTR(l_action_information_category
                                                    ,1
                                                    ,INSTR(l_action_information_category,'G')
                                                    );
                                l_category := l_category || 'C3';

                                pay_action_information_api.create_action_information
                                             (p_action_context_id              =>     l_arch_asg_action_id
                                             ,p_action_context_type            =>     'AAP'
                                             ,p_action_information_category    =>     'IN_24QC_DEDUCTEE'
                                             ,p_source_id                      =>     g_ee_data_rec_del(i).element_entry_id
                                             ,p_assignment_id                  =>     g_ee_data_rec_del(i).assignment_id
                                             ,p_action_information1            =>     tab_24q_ee_data.challan_number
                                             ,p_action_information2            =>     g_year||g_quarter
                                             ,p_action_information3            =>     g_gre_id
                                             ,p_action_information4            =>     tab_24q_ee_data.payment_date
                                             ,p_action_information5            =>     tab_24q_ee_data.taxable_income
                                             ,p_action_information6            =>     tab_24q_ee_data.income_tax
                                             ,p_action_information7            =>     tab_24q_ee_data.surcharge
                                             ,p_action_information8            =>     tab_24q_ee_data.education_cess
                                             ,p_action_information9            =>     tab_liv_pe_data.pan_number
                                             ,p_action_information10           =>     tab_liv_pe_data.full_name
                                             ,p_action_information11           =>     tab_liv_pe_data.pan_ref_number
                                             ,p_action_information12           =>     tab_liv_pe_data.person_id
                                             ,p_action_information13           =>     tab_24q_pe_data.pan_number
                                             ,p_action_information14           =>     tab_24q_pe_data.pan_ref_number
                                             ,p_action_information15           =>     'D'
                                             ,p_action_information16           =>     tab_24q_ee_data.amount_deposited
                                             ,p_action_information17           =>     NVL(tab_24q_ee_data.income_tax,0) + NVL(tab_24q_ee_data.surcharge,0) + NVL(tab_24q_ee_data.education_cess,0)
                                             ,p_action_information18           =>     tab_liv_pe_data.tax_rate
                                             ,p_action_information19           =>     l_category
                                             ,p_action_information20           =>     l_action_context_id
                                             ,p_action_information21           =>     tab_24q_ee_data.income_tax
                                             ,p_action_information22           =>     tab_24q_ee_data.surcharge
                                             ,p_action_information23           =>     tab_24q_ee_data.education_cess
                                             ,p_action_information24           =>     tab_24q_ee_data.amount_deposited
                                             ,p_action_information25           =>     GREATEST(NVL(j,0),NVL(k,0))
                                             ,p_action_information_id          =>     l_action_info_id
                                             ,p_object_version_number          =>     l_ovn
                                             );
                       END IF;
                 END IF;
             END LOOP;
         END IF;
      IF (g_correction_mode <> 'C5')
      THEN
             pay_in_utils.set_location(g_debug,'Value of g_count_ee_addition : '|| g_count_ee_addition, 1);
             FOR i IN 1..g_count_ee_addition - 1
             LOOP

                pay_in_utils.set_location(g_debug,'Checking archived presence of this added ee',1);
                l_flag := -1;

                l_flag := check_archival_status(g_ee_data_rec_add(i).element_entry_id,'IN_24QC_DEDUCTEE',NULL,'A');
                IF (l_flag = 0)
                THEN
                     pay_in_utils.set_location(g_debug,'Added EE Not Archived. hence doing '||g_ee_data_rec_add(i).element_entry_id,1);

                    IF (l_dummy <> pay_in_utils.get_ee_value(g_ee_data_rec_add(i).element_entry_id,'Challan or Voucher Number'))
                    THEN
                           s := 1;
                           l_dummy := pay_in_utils.get_ee_value(g_ee_data_rec_add(i).element_entry_id,'Challan or Voucher Number');
                    END IF;

                    pay_in_utils.set_location(g_debug,'Fetching element entry data  ', 1);
                    pay_in_utils.set_location(g_debug,'For Element Entry ID :  '|| g_ee_data_rec_add(i).element_entry_id,1);
                    pay_in_utils.set_location(g_debug,'Calling....get_element_entry_values ',1);
                    pay_in_utils.set_location(g_debug,'Assignment Action id is ' || g_ee_data_rec_add(i).last_action_context_id ,2);
                    pay_in_utils.set_location(g_debug,'Assignment id is ' || g_ee_data_rec_add(i).assignment_id,3);
                    get_element_entry_values
                     (
                       g_ee_data_rec_add(i).element_entry_id
                      ,g_ee_data_rec_add(i).last_action_context_id
                      ,g_ee_data_rec_add(i).assignment_id
                      ,tab_liv_ee_data
                      ,tab_24q_ee_data
                      ,tab_liv_pe_data
                      ,tab_24q_pe_data
                     );
                    pay_in_utils.set_location(g_debug,'Called....get_element_entry_values ',1);
                    pay_in_utils.set_location(g_debug,'Fetched element entry data  ', 1);

                    OPEN c_asg_act_id(g_ee_data_rec_add(i).assignment_id);
                    FETCH c_asg_act_id INTO l_arch_asg_action_id;
                    CLOSE c_asg_act_id;

                      j := -1;
                      k := -1;
                      pay_in_utils.set_location(g_debug,'Value of p_24qa_pay_act_id is ' || p_24qa_pay_act_id ,1);
                      pay_in_utils.set_location(g_debug,'Checking Challan Deductee Number in 24Q for ' || tab_liv_ee_data.challan_number,1);
                      OPEN  c_max_challan_number_24q(tab_liv_ee_data.challan_number);
                      FETCH c_max_challan_number_24q INTO k;
                      CLOSE c_max_challan_number_24q;
                      pay_in_utils.set_location(g_debug,'Number found is ' || k, 2);
                      pay_in_utils.set_location(g_debug,'Checking Challan Deductee Number in 24QC for ' || tab_liv_ee_data.challan_number,1);
                      OPEN  c_max_challan_number_24qc(tab_liv_ee_data.challan_number);
                      FETCH c_max_challan_number_24qc INTO j;
                      CLOSE c_max_challan_number_24qc;
                      pay_in_utils.set_location(g_debug,'Number found is ' || j, 2);

                      pay_action_information_api.create_action_information
                                  (p_action_context_id              =>     l_arch_asg_action_id
                                  ,p_action_context_type            =>     'AAP'
                                  ,p_action_information_category    =>     'IN_24QC_DEDUCTEE'
                                  ,p_source_id                      =>     g_ee_data_rec_add(i).element_entry_id
                                  ,p_assignment_id                  =>     g_ee_data_rec_add(i).assignment_id
                                  ,p_action_information1            =>     tab_liv_ee_data.challan_number
                                  ,p_action_information2            =>     g_year||g_quarter
                                  ,p_action_information3            =>     g_gre_id
                                  ,p_action_information4            =>     tab_liv_ee_data.payment_date
                                  ,p_action_information5            =>     tab_liv_ee_data.taxable_income
                                  ,p_action_information6            =>     tab_liv_ee_data.income_tax
                                  ,p_action_information7            =>     tab_liv_ee_data.surcharge
                                  ,p_action_information8            =>     tab_liv_ee_data.education_cess
                                  ,p_action_information9            =>     tab_liv_pe_data.pan_number
                                  ,p_action_information10           =>     tab_liv_pe_data.full_name
                                  ,p_action_information11           =>     tab_liv_pe_data.pan_ref_number
                                  ,p_action_information12           =>     tab_liv_pe_data.person_id
                                  ,p_action_information13           =>     NULL
                                  ,p_action_information14           =>     NULL
                                  ,p_action_information15           =>     'A'
                                  ,p_action_information16           =>     tab_liv_ee_data.amount_deposited
                                  ,p_action_information17           =>     NULL
                                  ,p_action_information18           =>     tab_liv_pe_data.tax_rate
                                  ,p_action_information19           =>     NULL
                                  ,p_action_information20           =>     NULL
                                  ,p_action_information21           =>     tab_24q_ee_data.income_tax
                                  ,p_action_information22           =>     tab_24q_ee_data.surcharge
                                  ,p_action_information23           =>     tab_24q_ee_data.education_cess
                                  ,p_action_information24           =>     tab_24q_ee_data.amount_deposited
                                  ,p_action_information25           =>     GREATEST(NVL(j,0),NVL(k,0))+ s
                                  ,p_action_information_id          =>     l_action_info_id
                                  ,p_object_version_number          =>     l_ovn
                                  );
                       s := s + 1;
                END IF;
             END LOOP;
      END IF;
      pay_in_utils.set_location(g_debug,'Value of g_count_ee_update : '|| g_count_ee_update, 1);
      FOR i IN 1..g_count_ee_update - 1
      LOOP
         pay_in_utils.set_location(g_debug,'Checking archived presence of this updated ee',1);
         l_flag := -1;

         l_flag := check_archival_status(g_ee_data_rec_upd(i).element_entry_id,'IN_24QC_DEDUCTEE',NULL,'U');
         IF (l_flag = 0)
         THEN
              pay_in_utils.set_location(g_debug,'Updated EE Not Archived. hence doing '||g_ee_data_rec_upd(i).element_entry_id,1);

               pay_in_utils.set_location(g_debug,'Fetching element entries...',2);
               get_element_entry_values
                (
                  g_ee_data_rec_upd(i).element_entry_id
                 ,g_ee_data_rec_upd(i).last_action_context_id
                 ,g_ee_data_rec_upd(i).assignment_id
                 ,tab_liv_ee_data
                 ,tab_24q_ee_data
                 ,tab_liv_pe_data
                 ,tab_24q_pe_data
                );

                pay_in_utils.set_location(g_debug,'Fetched element entries...',2);
                pay_in_utils.set_location(g_debug,'Fetching Archival Assignment Action ID...',2);
                pay_in_utils.set_location(g_debug,'Asg ID' ||   g_ee_data_rec_upd(i).assignment_id ,1);
                pay_in_utils.set_location(g_debug,'Payroll Action id is ' || p_payroll_action_id ,1);

                OPEN c_asg_act_id(g_ee_data_rec_upd(i).assignment_id);
                FETCH c_asg_act_id INTO l_arch_asg_action_id;
                CLOSE c_asg_act_id;

                 pay_in_utils.set_location(g_debug,'Archival Assignment Action ID is :'|| l_arch_asg_action_id ,2);

                 OPEN  c_deductee_number_24qc(tab_24q_ee_data.challan_number,g_ee_data_rec_upd(i).element_entry_id);
                 FETCH c_deductee_number_24qc INTO k;
                 CLOSE c_deductee_number_24qc;

                 OPEN  c_deductee_number_24q(tab_24q_ee_data.challan_number,g_ee_data_rec_upd(i).element_entry_id);
                 FETCH c_deductee_number_24q INTO j;
                 CLOSE c_deductee_number_24q;

                 pay_in_utils.set_location(g_debug,'Previous Challan Deductee Record Number was:' || j, 3);

                 pay_in_utils.set_location(g_debug,'New Challan Deductee Record Number is:' || k,4);
--      if g_correction_mode = 'C5' and tab_24q_pe_data.pan_number IS VALID and
--       tab_liv_pe_data.pan_number is also valid and not equal 2 each other
--       then not only arhcive this assignment data, but also last organization PA data

              IF ((g_correction_mode IN('C3','C5','%'))
                   AND(tab_24q_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                   AND(tab_liv_pe_data.pan_number NOT IN ('APPLIEDFOR','PANNOTAVBL'))
                   AND(tab_24q_pe_data.pan_number <> tab_liv_pe_data.pan_number)
                 )
              THEN
                      OPEN  c_c5_correction_type_details(g_ee_data_rec_upd(i).last_action_context_id);
                      FETCH c_c5_correction_type_details INTO l_action_information_category,l_action_context_id;
                      CLOSE c_c5_correction_type_details;

                      pay_in_utils.set_location(g_debug,'C5 Change Found!!!',1);
                      pay_in_utils.set_location(g_debug,'Checking C5 Change only',2);
                      pay_in_utils.set_location(g_debug,'EE ID '|| g_ee_data_rec_upd(i).element_entry_id,1);
                      pay_in_utils.set_location(g_debug,'Asg id '|| g_ee_data_rec_upd(i).assignment_id,2);
                      pay_in_utils.set_location(g_debug,'Act cntxt id '|| g_ee_data_rec_upd(i).last_action_context_id,3);

                      l_c5_change := check_c5_change_only(g_ee_data_rec_upd(i).element_entry_id
                                                         ,g_ee_data_rec_upd(i).last_action_context_id
                                                         ,g_ee_data_rec_upd(i).assignment_id
                                                         );
                     IF (l_c5_change)
                     THEN
                        IF (g_correction_mode IN ('%','C5'))
                        THEN
                             pay_in_utils.set_location(g_debug,'Only C5 Change!!!',3);
                             l_action_information_category := l_action_information_category || ':C5';
                        END IF;
                     ELSIF g_correction_mode = '%'
                     THEN
                        pay_in_utils.set_location(g_debug,'C3 and C5 Change is there!',4);
                        l_action_information_category := l_action_information_category || ':C3:C5';
                     ELSIF g_correction_mode = 'C5'
                     THEN
                        l_action_information_category := l_action_information_category || ':C5';
                     ELSE
                        l_action_information_category := l_action_information_category || ':C3';
                     END IF;
              ELSE
                      l_action_information_category := 'C3';
                      l_action_context_id           := NULL;
              END IF;

              pay_in_utils.set_location(g_debug,'l_action_information_category is '|| l_action_information_category,1);

              IF (INSTR(l_action_information_category,'C5')<> 0)AND(g_correction_mode IN ('%','C5'))
              THEN
                   pay_in_utils.set_location(g_debug,'Archiving C5 data for this deductee',1);
                   l_category := SUBSTR(l_action_information_category
                                       ,1
                                       ,INSTR(l_action_information_category,'G')
                                       );
                   l_category := l_category || 'C5';

                   pay_action_information_api.create_action_information
                               (p_action_context_id              =>     l_arch_asg_action_id
                               ,p_action_context_type            =>     'AAP'
                               ,p_action_information_category    =>     'IN_24QC_DEDUCTEE'
                               ,p_source_id                      =>     g_ee_data_rec_upd(i).element_entry_id
                               ,p_assignment_id                  =>     g_ee_data_rec_upd(i).assignment_id
                               ,p_action_information1            =>     tab_24q_ee_data.challan_number
                               ,p_action_information2            =>     g_year||g_quarter
                               ,p_action_information3            =>     g_gre_id
                               ,p_action_information4            =>     tab_24q_ee_data.payment_date
                               ,p_action_information5            =>     tab_24q_ee_data.taxable_income
                               ,p_action_information6            =>     tab_24q_ee_data.income_tax
                               ,p_action_information7            =>     tab_24q_ee_data.surcharge
                               ,p_action_information8            =>     tab_24q_ee_data.education_cess
                               ,p_action_information9            =>     tab_liv_pe_data.pan_number
                               ,p_action_information10           =>     tab_liv_pe_data.full_name
                               ,p_action_information11           =>     tab_liv_pe_data.pan_ref_number
                               ,p_action_information12           =>     tab_liv_pe_data.person_id
                               ,p_action_information13           =>     tab_24q_pe_data.pan_number
                               ,p_action_information14           =>     tab_24q_pe_data.pan_ref_number
                               ,p_action_information15           =>     'U'
                               ,p_action_information16           =>     tab_24q_ee_data.amount_deposited
                               ,p_action_information17           =>     NVL(tab_24q_ee_data.income_tax,0) + NVL(tab_24q_ee_data.surcharge,0) + NVL(tab_24q_ee_data.education_cess,0)
                               ,p_action_information18           =>     tab_liv_pe_data.tax_rate
                               ,p_action_information19           =>     l_category
                               ,p_action_information20           =>     l_action_context_id
                               ,p_action_information21           =>     tab_24q_ee_data.income_tax
                               ,p_action_information22           =>     tab_24q_ee_data.surcharge
                               ,p_action_information23           =>     tab_24q_ee_data.education_cess
                               ,p_action_information24           =>     tab_24q_ee_data.amount_deposited
                               ,p_action_information25           =>     GREATEST(NVL(j,0),NVL(k,0))
                               ,p_action_information_id          =>     l_action_info_id
                               ,p_object_version_number          =>     l_ovn
                               );
              END IF;

              IF (INSTR(l_action_information_category,'C3')<> 0)AND(g_correction_mode IN ('%','C3'))
              THEN
                   pay_in_utils.set_location(g_debug,'Archiving C3 data for this deductee',1);
                   l_category := SUBSTR(l_action_information_category
                                       ,1
                                       ,INSTR(l_action_information_category,'G')
                                       );
                   l_category := l_category || 'C3';

                   pay_action_information_api.create_action_information
                                (p_action_context_id              =>     l_arch_asg_action_id
                                ,p_action_context_type            =>     'AAP'
                                ,p_action_information_category    =>     'IN_24QC_DEDUCTEE'
                                ,p_source_id                      =>     g_ee_data_rec_upd(i).element_entry_id
                                ,p_assignment_id                  =>     g_ee_data_rec_upd(i).assignment_id
                                ,p_action_information1            =>     tab_liv_ee_data.challan_number
                                ,p_action_information2            =>     g_year||g_quarter
                                ,p_action_information3            =>     g_gre_id
                                ,p_action_information4            =>     tab_liv_ee_data.payment_date
                                ,p_action_information5            =>     tab_liv_ee_data.taxable_income
                                ,p_action_information6            =>     tab_liv_ee_data.income_tax
                                ,p_action_information7            =>     tab_liv_ee_data.surcharge
                                ,p_action_information8            =>     tab_liv_ee_data.education_cess
                                ,p_action_information9            =>     tab_liv_pe_data.pan_number
                                ,p_action_information10           =>     tab_liv_pe_data.full_name
                                ,p_action_information11           =>     tab_liv_pe_data.pan_ref_number
                                ,p_action_information12           =>     tab_liv_pe_data.person_id
                                ,p_action_information13           =>     tab_24q_pe_data.pan_number
                                ,p_action_information14           =>     tab_24q_pe_data.pan_ref_number
                                ,p_action_information15           =>     'U'
                                ,p_action_information16           =>     tab_liv_ee_data.amount_deposited
                                ,p_action_information17           =>     NVL(tab_24q_ee_data.income_tax,0) + NVL(tab_24q_ee_data.surcharge,0) + NVL(tab_24q_ee_data.education_cess,0)
                                ,p_action_information18           =>     tab_liv_pe_data.tax_rate
                                ,p_action_information19           =>     l_category
                                ,p_action_information20           =>     l_action_context_id
                                ,p_action_information21           =>     tab_24q_ee_data.income_tax
                                ,p_action_information22           =>     tab_24q_ee_data.surcharge
                                ,p_action_information23           =>     tab_24q_ee_data.education_cess
                                ,p_action_information24           =>     tab_24q_ee_data.amount_deposited
                                ,p_action_information25           =>     GREATEST(NVL(j,0),NVL(k,0))
                                ,p_action_information_id          =>     l_action_info_id
                                ,p_object_version_number          =>     l_ovn
                                );
              END IF;
        END IF;
      END LOOP;
      pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.archive_deductee_data ', 5);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END archive_deductee_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_NO_CHANGE_CHALLAN                           --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure to actually archive the data.             --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE archive_no_change_challan(p_24qc_pay_act_id         NUMBER
                                     ,p_24qa_pay_act_id         NUMBER
                                     )
  IS
    CURSOR c_latest_correction_details(p_transfer_voucher_number VARCHAR2)
    IS
       SELECT  action_information13
              ,action_information14
              ,action_information17
              ,action_information25
              ,action_information_id
          FROM pay_action_information
         WHERE action_context_type         = 'PA'
           AND action_information_category = 'IN_24QC_CHALLAN'
           AND action_information15        = p_24qa_pay_act_id
           AND NVL(action_information4,'BOOK')||' - '||action_information1||' - '||to_char(fnd_date.canonical_to_date(action_information5),'DD-Mon-RRRR')         = p_transfer_voucher_number
           AND action_context_id IN(
                                    SELECT org_information3
                                      FROM hr_organization_information
                                     WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                       AND organization_id         = g_gre_id
                                       AND org_information1        = g_year
                                       AND org_information2        = g_quarter
                                       AND org_information5        = 'A'
                                       AND org_information6        = 'C'
                                   )
         ORDER BY action_information_id DESC;

    CURSOR c_24q_details(p_transfer_voucher_number VARCHAR2)
    IS
        SELECT action_information4      bank_code
              ,action_information5      payment_date
              , NVL(action_information6,0)
              + NVL(action_information7,0)
              + NVL(action_information8,0)
              + NVL(action_information9,0)
              + NVL(action_information10,0)
              ,action_information25
          FROM pay_action_information pai
         WHERE pai.action_context_type         = 'PA'
           AND pai.action_information_category = 'IN_24Q_CHALLAN'
           AND pai.action_context_id           = p_24qa_pay_act_id
           AND NVL(action_information4,'BOOK')||' - '||action_information1||' - '||to_char(fnd_date.canonical_to_date(action_information5),'DD-Mon-RRRR')         = p_transfer_voucher_number
         ORDER BY action_information_id DESC;

    CURSOR c_populate_no_change_data
    IS
      SELECT hoi.org_information3           challan_number,
             hoi.org_information2           transfer_voucher_date,
             hoi.org_information4           amount,
             hoi.org_information7           surcharge,
             hoi.org_information8           education_cess,
             hoi.org_information10          other,
             hoi.org_information9           interest,
             (SELECT hoi_bank.org_information4
               FROM hr_organization_information hoi_bank
              WHERE hoi_bank.organization_id = g_gre_id
                AND hoi_bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                AND hoi_bank.org_information_id = hoi.org_information5
             )                              bank_branch_code,
             hoi.org_information11          cheque_dd_num,
             hoi.org_information12          book_entry,
             hoi.org_information_id         org_information_id
        FROM hr_organization_information hoi
       WHERE hoi.org_information_id IN
       (
            SELECT hoi.org_information_id
              FROM hr_organization_information hoi
                  ,hr_organization_units hou
             WHERE hoi.organization_id     = g_gre_id
               AND  hoi.organization_id    = hou.organization_id
               AND  hou.business_group_id  = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
               AND org_information_context = 'PER_IN_IT_CHALLAN_INFO'
       )
         AND hoi.org_information13 = g_quarter
         AND hoi.org_information1  = g_tax_year;

        l_flag                           BOOLEAN;
        l_action_information_id          NUMBER;
        l_pre_bank_branch_code           VARCHAR2(150);
        l_pre_transfer_voucher_date      VARCHAR2(150);
        l_previous_total_amount          NUMBER;
        l_challan_deductee_no            NUMBER;
        l_action_info_id                 NUMBER;
        l_ovn                            NUMBER;
        l_flag_number                    NUMBER := -1;
        l_procedure                      VARCHAR2(250);
        l_message                        VARCHAR2(250);
    BEGIN
       g_debug     := hr_utility.debug_enabled;
       l_procedure := g_package ||'.archive_no_change_challan';
       pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
       FOR c_rec IN c_populate_no_change_data
       LOOP
          l_flag := TRUE;

         pay_in_utils.set_location(g_debug,'Checking in Added Challans ', 1);
          -- Checking in Added Challans
          FOR i IN 1..g_count_challan_add - 1
          LOOP
             IF( (g_challan_data_add(i).transfer_voucher_number = NVL(c_rec.bank_branch_code,'BOOK')||' - '||c_rec.challan_number||' - '||to_char(fnd_date.canonical_to_date(c_rec.transfer_voucher_date),'DD-Mon-RRRR') )
                OR
                 (g_challan_data_add(i).org_information_id      = c_rec.org_information_id)
               )
             THEN
                  l_flag := FALSE;
             END IF;
          END LOOP;

          pay_in_utils.set_location(g_debug,'Checking in Updated Challans ', 1);
          FOR i IN 1..g_count_challan_upd - 1
          LOOP
             IF ((g_challan_data_upd(i).transfer_voucher_number = NVL(c_rec.bank_branch_code,'BOOK')||' - '||c_rec.challan_number||' - '||to_char(fnd_date.canonical_to_date(c_rec.transfer_voucher_date),'DD-Mon-RRRR') )
             OR
                 (g_challan_data_upd(i).org_information_id      = c_rec.org_information_id)
                )
             THEN
                  l_flag := FALSE;
             END IF;
          END LOOP;
          --Insert Record in PL/SQL Table for no change Challans
          IF (l_flag)
          THEN
                g_challan_data_noc(g_count_challan_noc).transfer_voucher_number := NVL(c_rec.bank_branch_code,'BOOK')||' - '||c_rec.challan_number||' - '||to_char(fnd_date.canonical_to_date(c_rec.transfer_voucher_date),'DD-Mon-RRRR') ;
                g_challan_data_noc(g_count_challan_noc).transfer_voucher_date   := c_rec.transfer_voucher_date;
                g_challan_data_noc(g_count_challan_noc).amount                  := c_rec.amount;
                g_challan_data_noc(g_count_challan_noc).surcharge               := c_rec.surcharge;
                g_challan_data_noc(g_count_challan_noc).education_cess          := c_rec.education_cess;
                g_challan_data_noc(g_count_challan_noc).interest                := c_rec.interest;
                g_challan_data_noc(g_count_challan_noc).other                   := c_rec.other;
                g_challan_data_noc(g_count_challan_noc).bank_branch_code        := c_rec.bank_branch_code;
                g_challan_data_noc(g_count_challan_noc).cheque_dd_num           := c_rec.cheque_dd_num;
                g_challan_data_noc(g_count_challan_noc).org_information_id      := c_rec.org_information_id;
                g_challan_data_noc(g_count_challan_noc).modes                   := 'NC';
                g_challan_data_noc(g_count_challan_noc).book_entry              := c_rec.book_entry;
                g_count_challan_noc := g_count_challan_noc + 1;
          END IF;
       END LOOP;

       FOR i IN 1..g_count_challan_noc - 1
       LOOP
         pay_in_utils.set_location(g_debug,'Checking Challan no change status',1);
         l_flag_number := -1;
         l_flag_number := check_archival_status(NULL,'IN_24QC_CHALLAN',g_challan_data_noc(i).transfer_voucher_number,NULL);
         IF (l_flag_number = 0 AND g_correction_mode <> 'C5')
         THEN
                      pay_in_utils.set_location(g_debug,'Fetching details from 24Q Correction Archival',2);
                      pay_in_utils.set_location(g_debug,'Fetching details from 24Q Correction Archival for g_challan_data_noc(i).transfer_voucher_number' || g_challan_data_noc(i).transfer_voucher_number,2);
                      OPEN  c_latest_correction_details(g_challan_data_noc(i).transfer_voucher_number);
                      FETCH c_latest_correction_details INTO  l_pre_bank_branch_code
                                                             ,l_pre_transfer_voucher_date
                                                             ,l_previous_total_amount
                                                             ,l_challan_deductee_no
                                                             ,l_action_information_id;
                      CLOSE c_latest_correction_details;
                      pay_in_utils.set_location(g_debug,'Fetched details from 24Q Correction Archival',2);
                      pay_in_utils.set_location(g_debug,'l_pre_bank_branch_code      '|| l_pre_bank_branch_code      ,3);
                      pay_in_utils.set_location(g_debug,'l_pre_transfer_voucher_date '|| l_pre_transfer_voucher_date ,3);
                      pay_in_utils.set_location(g_debug,'l_previous_total_amount     '|| l_previous_total_amount     ,3);
                      pay_in_utils.set_location(g_debug,'l_challan_deductee_no       '|| l_challan_deductee_no       ,3);
                      pay_in_utils.set_location(g_debug,'l_action_information_id     '|| l_action_information_id     ,3);


                      IF (l_action_information_id IS NULL)
                      THEN
                                pay_in_utils.set_location(g_debug,'Fetching details from 24Q Archival',2);
                                pay_in_utils.set_location(g_debug,'Fetching details from 24Q Correction Archival for g_challan_data_noc(i).transfer_voucher_number' || g_challan_data_noc(i).transfer_voucher_number,2);
                                OPEN  c_24q_details(g_challan_data_noc(i).transfer_voucher_number);
                                FETCH c_24q_details INTO l_pre_bank_branch_code
                                                        ,l_pre_transfer_voucher_date
                                                        ,l_previous_total_amount
                                                        ,l_challan_deductee_no;
                                CLOSE c_24q_details;
                                pay_in_utils.set_location(g_debug,'Fetched details from 24Q Correction Archival',2);
                                pay_in_utils.set_location(g_debug,'l_pre_bank_branch_code      '|| l_pre_bank_branch_code      ,3);
                                pay_in_utils.set_location(g_debug,'l_pre_transfer_voucher_date '|| l_pre_transfer_voucher_date ,3);
                                pay_in_utils.set_location(g_debug,'l_previous_total_amount     '|| l_previous_total_amount     ,3);
                                pay_in_utils.set_location(g_debug,'l_challan_deductee_no       '|| l_challan_deductee_no       ,3);
                                pay_in_utils.set_location(g_debug,'l_action_information_id     '|| l_action_information_id     ,3);
                      END IF;
                      -- Now Archive these details
                         pay_action_information_api.create_action_information
                                    (p_action_context_id              =>     p_24qc_pay_act_id
                                    ,p_action_context_type            =>     'PA'
                                    ,p_action_information_category    =>     'IN_24QC_CHALLAN'
                                    ,p_source_id                      =>     g_challan_data_noc(i).org_information_id
                                    ,p_action_information1            =>     g_challan_data_noc(i).transfer_voucher_number
                                    ,p_action_information2            =>     g_year||g_quarter
                                    ,p_action_information3            =>     g_gre_id
                                    ,p_action_information4            =>     g_challan_data_noc(i).bank_branch_code
                                    ,p_action_information5            =>     g_challan_data_noc(i).transfer_voucher_date
                                    ,p_action_information6            =>     g_challan_data_noc(i).amount
                                    ,p_action_information7            =>     g_challan_data_noc(i).surcharge
                                    ,p_action_information8            =>     g_challan_data_noc(i).education_cess
                                    ,p_action_information9            =>     g_challan_data_noc(i).interest
                                    ,p_action_information10           =>     g_challan_data_noc(i).other
                                    ,p_action_information11           =>     g_challan_data_noc(i).cheque_dd_num
                                    ,p_action_information12           =>     g_challan_data_noc(i).transfer_voucher_number
                                    ,p_action_information13           =>     l_pre_bank_branch_code
                                    ,p_action_information14           =>     l_pre_transfer_voucher_date
                                    ,p_action_information15           =>     p_24qa_pay_act_id
                                    ,p_action_information16           =>     g_challan_data_noc(i).book_entry
                                    ,p_action_information17           =>     l_previous_total_amount
                                    ,p_action_information18           =>     'NC'
                                    ,p_action_information19           =>     update_challans(g_challan_data_noc(i).transfer_voucher_number)
                                    ,p_action_information25           =>     l_challan_deductee_no
                                    ,p_action_information_id          =>     l_action_info_id
                                    ,p_object_version_number          =>     l_ovn
                                    );
          END IF;
       END LOOP;
       pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.archive_no_change_challan ', 5);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
    END archive_no_change_challan;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CHALLAN_DATA                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to actually archive the data.             --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
PROCEDURE archive_challan_data(p_24qc_pay_act_id   NUMBER
                                ,p_24qa_pay_act_id   NUMBER
                                )
  IS
    CURSOR c_challan_live_data(p_challan_number         VARCHAR2
                              ,p_org_information_id     VARCHAR2
                              )
    IS
      SELECT hoi.org_information3           challan_number,
             hoi.org_information2           transfer_voucher_date,
             hoi.org_information4           amount,
             hoi.org_information7           surcharge,
             hoi.org_information8           education_cess,
             hoi.org_information10          other,
             hoi.org_information9           interest,
             (SELECT hoi_bank.org_information4
               FROM hr_organization_information hoi_bank
              WHERE hoi_bank.organization_id = g_gre_id
                AND hoi_bank.org_information_context = 'PER_IN_CHALLAN_BANK'
                AND hoi_bank.org_information_id = hoi.org_information5
             )                              bank_branch_code,
             hoi.org_information11          cheque_dd_num,
             hoi.org_information12          book_entry,
             hoi.org_information_id         org_information_id
        FROM hr_organization_information hoi
       WHERE hoi.org_information_id IN
       (
            SELECT hoi.org_information_id
              FROM hr_organization_information hoi
                  ,hr_organization_units hou
             WHERE hoi.organization_id     = g_gre_id
               AND  hoi.organization_id    = hou.organization_id
               AND  hou.business_group_id  = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
               AND org_information_context = 'PER_IN_IT_CHALLAN_INFO'
       )
         AND hoi.org_information13 = g_quarter
         AND hoi.org_information1  = g_tax_year
         AND (
               (hoi.org_information3   = SUBSTR(p_challan_number ,INSTR (p_challan_number, ' -',1,1)+3,(INSTR (p_challan_number, ' -',1,2)-(INSTR (p_challan_number, ' -',1,1)+3))))
             OR
               (hoi.org_information_id = p_org_information_id)
             );

    l_transfer_voucher_number     hr_organization_information.org_information3%TYPE;
    l_transfer_voucher_date       hr_organization_information.org_information2%TYPE;
    l_amount                      hr_organization_information.org_information4%TYPE;
    l_surcharge                   hr_organization_information.org_information7%TYPE;
    l_education_cess              hr_organization_information.org_information8%TYPE;
    l_others                      hr_organization_information.org_information10%TYPE;
    l_interest                    hr_organization_information.org_information9%TYPE;
    l_bank_branch_code            hr_organization_information.org_information4%TYPE;
    l_cheque_dd_num               hr_organization_information.org_information11%TYPE;
    l_book_entry                  hr_organization_information.org_information12%TYPE;
    l_org_information_id          NUMBER;
    l_previous_total_amount       NUMBER;
    l_challan_record_number       NUMBER;
    l_action_info_id              NUMBER;
    l_ovn                         NUMBER;
    j                             NUMBER;
    k                             NUMBER;
    l_flag                        NUMBER := -1;
    l_procedure                   VARCHAR2(250);
    l_message                     VARCHAR2(250);
   BEGIN
        g_debug     := hr_utility.debug_enabled;
        l_procedure := g_package ||'.archive_challan_data';
        pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
        pay_in_utils.set_location(g_debug,'Fetching Challan Data ', 1);
        BEGIN
             SELECT MAX(TO_NUMBER(action_information25))
               INTO j
               FROM pay_action_information
              WHERE action_information_category = 'IN_24Q_CHALLAN'
                AND action_information3         = g_gre_id
                AND action_information2         = g_year||g_quarter
                AND action_context_id           = p_24qa_pay_act_id
                AND action_context_id           IN(
                                                   SELECT org_information3
                                                     FROM hr_organization_information
                                                    WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                      AND organization_id  = g_gre_id
                                                      AND org_information1 = g_year
                                                      AND org_information2 = g_quarter
                                                      AND org_information5 = 'A'
                                                      AND org_information6 = 'O'
                                                    );

             pay_in_utils.set_location(g_debug,'Addition:Value of j is : '|| j ,1);
             SELECT MAX(TO_NUMBER(action_information25))
               INTO k
               FROM pay_action_information
              WHERE action_information_category = 'IN_24QC_CHALLAN'
                AND action_information3         = g_gre_id
                AND action_information2         = g_year||g_quarter
                AND action_information15        = p_24qa_pay_act_id
                AND action_context_id           IN(
                                                   SELECT org_information3
                                                     FROM hr_organization_information
                                                    WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                      AND organization_id  = g_gre_id
                                                      AND org_information1 = g_year
                                                      AND org_information2 = g_quarter
                                                      AND org_information5 = 'A'
                                                      AND org_information6 = 'C'
                                                    );
           EXCEPTION
                WHEN OTHERS THEN
                        NULL;
           END;

           pay_in_utils.set_location(g_debug,'Value of k is : '|| k ,1);
           l_challan_record_number := GREATEST(NVL(j,0),NVL(k,0));

          pay_in_utils.set_location(g_debug,'Value of l_challan_record_number is : '|| l_challan_record_number ,1);

   --if C9 only new Challans would (addition/Insert) be archived
    IF (g_correction_mode IN ('C9','%'))
    THEN
      FOR i IN 1.. g_count_challan_add - 1
        LOOP
             pay_in_utils.set_location(g_debug,'Checking archived presence of this added challan',1);
             l_flag := -1;

             l_flag := check_archival_status(NULL,'IN_24QC_CHALLAN',g_challan_data_add(i).transfer_voucher_number,NULL);
             IF (l_flag = 0)
             THEN
                      pay_in_utils.set_location(g_debug,'Archiving added challan ' || g_challan_data_add(i).transfer_voucher_number,1);
                      pay_in_utils.set_location(g_debug,'Fetching Live Data ' ,1);
                      OPEN  c_challan_live_data(g_challan_data_add(i).transfer_voucher_number,g_challan_data_add(i).org_information_id);
                      FETCH c_challan_live_data INTO l_transfer_voucher_number,
                                                     l_transfer_voucher_date,
                                                     l_amount,
                                                     l_surcharge,
                                                     l_education_cess,
                                                     l_others,
                                                     l_interest,
                                                     l_bank_branch_code,
                                                     l_cheque_dd_num,
                                                     l_book_entry,
                                                     l_org_information_id;
                      CLOSE c_challan_live_data;
                      pay_in_utils.set_location(g_debug,'Fetched Live Data ' ,1);

                      pay_in_utils.set_location(g_debug,'Archiving Data ' ,1);
                      pay_action_information_api.create_action_information
                                 (p_action_context_id              =>     p_24qc_pay_act_id
                                 ,p_action_context_type            =>     'PA'
                                 ,p_action_information_category    =>     'IN_24QC_CHALLAN'
                                 ,p_source_id                      =>     g_challan_data_add(i).org_information_id
                                 ,p_action_information1            =>     g_challan_data_add(i).transfer_voucher_number
                                 ,p_action_information2            =>     g_year||g_quarter
                                 ,p_action_information3            =>     g_gre_id
                                 ,p_action_information4            =>     g_challan_data_add(i).bank_branch_code
                                 ,p_action_information5            =>     g_challan_data_add(i).transfer_voucher_date
                                 ,p_action_information6            =>     NVL(g_challan_data_add(i).amount,0)
                                 ,p_action_information7            =>     NVL(g_challan_data_add(i).surcharge,0)
                                 ,p_action_information8            =>     NVL(g_challan_data_add(i).education_cess,0)
                                 ,p_action_information9            =>     NVL(g_challan_data_add(i).interest,0)
                                 ,p_action_information10           =>     NVL(g_challan_data_add(i).other,0)
                                 ,p_action_information11           =>     g_challan_data_add(i).cheque_dd_num
                                 ,p_action_information12           =>     NULL
                                 ,p_action_information13           =>     NULL
                                 ,p_action_information14           =>     NULL
                                 ,p_action_information15           =>     p_24qa_pay_act_id
                                 ,p_action_information16           =>     l_book_entry
                                 ,p_action_information17           =>     NULL
                                 ,p_action_information18           =>     'A'
                                 ,p_action_information19           =>     update_challans(g_challan_data_add(i).transfer_voucher_number)
                                 ,p_action_information25           =>     l_challan_record_number + i
                                 ,p_action_information_id          =>     l_action_info_id
                                 ,p_object_version_number          =>     l_ovn
                                 );
           END IF;
        END LOOP;
   END IF;

   pay_in_utils.set_location(g_debug,'Fetching Updated Challan Data ' ,1);
 --C2,C3 then archive only updated Challans
 --Later need to archive all those challans that have undergone no change under C3
    IF (g_correction_mode IN ('C2','C3','%'))
    THEN
      FOR i IN 1.. g_count_challan_upd - 1
        LOOP
             pay_in_utils.set_location(g_debug,'Checking archived presence of this updated challan',1);
             l_flag := -1;

             l_flag := check_archival_status(NULL,'IN_24QC_CHALLAN',g_challan_data_upd(i).transfer_voucher_number,NULL);
             IF (l_flag = 0)
             THEN

                        j := -1;
                        k := -1;
                        BEGIN
                              SELECT DISTINCT action_information25
                                INTO j
                                FROM pay_action_information
                               WHERE action_information_category = 'IN_24Q_CHALLAN'
                                 AND action_information3         = g_gre_id
                                 AND action_information2         = g_year||g_quarter
                                 AND action_context_id           = p_24qa_pay_act_id
                                 AND(action_information1         = g_challan_data_upd(i).transfer_voucher_number
                                    OR
                                     source_id                   = g_challan_data_upd(i).org_information_id
                                    )
                                 AND p_24qa_pay_act_id IN(
                                                         SELECT org_information3
                                                           FROM hr_organization_information
                                                          WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                            AND organization_id  = g_gre_id
                                                            AND org_information1 = g_year
                                                            AND org_information2 = g_quarter
                                                            AND org_information5 = 'A'
                                                            AND org_information6 = 'O'
                                                          );
                          EXCEPTION
                                   WHEN OTHERS THEN
                                           NULL;
                          END;
                          pay_in_utils.set_location(g_debug,'Updation:Value of j is : '|| j ,1);

                        BEGIN
                            SELECT DISTINCT action_information25
                              INTO k
                              FROM pay_action_information
                             WHERE action_information_category = 'IN_24QC_CHALLAN'
                               AND action_information3         = g_gre_id
                               AND action_information2         = g_year||g_quarter
                               AND action_context_id           = p_24qa_pay_act_id
                               AND(action_information1         = g_challan_data_upd(i).transfer_voucher_number
                                  OR
                                   source_id                   = g_challan_data_upd(i).org_information_id
                                  )
                              AND action_information15 IN(
                                                       SELECT org_information3
                                                         FROM hr_organization_information
                                                        WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                                          AND organization_id  = g_gre_id
                                                          AND org_information1 = g_year
                                                          AND org_information2 = g_quarter
                                                          AND org_information5 = 'A'
                                                          AND org_information6 = 'C'
                                                        );
                         EXCEPTION
                             WHEN OTHERS THEN
                                   NULL;
                         END;
                           pay_in_utils.set_location(g_debug,'Value of k is : '|| k ,1);

                        l_challan_record_number := GREATEST(j,k);

                        pay_in_utils.set_location(g_debug,'Value of l_challan_record_number is : '|| l_challan_record_number ,1);

                        OPEN  c_challan_live_data(g_challan_data_upd(i).transfer_voucher_number,g_challan_data_upd(i).org_information_id);
                        FETCH c_challan_live_data INTO l_transfer_voucher_number,
                                                       l_transfer_voucher_date,
                                                       l_amount,
                                                       l_surcharge,
                                                       l_education_cess,
                                                       l_others,
                                                       l_interest,
                                                       l_bank_branch_code,
                                                       l_cheque_dd_num,
                                                       l_book_entry,
                                                       l_org_information_id;
                        CLOSE c_challan_live_data;

                        l_previous_total_amount  := NVL(g_challan_data_upd(i).amount,0)
                                                  + NVL(g_challan_data_upd(i).surcharge,0)
                                                  + NVL(g_challan_data_upd(i).education_cess,0)
                                                  + NVL(g_challan_data_upd(i).interest,0)
                                                  + NVL(g_challan_data_upd(i).other,0);

                        pay_action_information_api.create_action_information
                                   (p_action_context_id              =>     p_24qc_pay_act_id
                                   ,p_action_context_type            =>     'PA'
                                   ,p_action_information_category    =>     'IN_24QC_CHALLAN'
                                   ,p_source_id                      =>     l_org_information_id
                                   ,p_action_information1            =>     NVL(l_bank_branch_code,'BOOK')||' - '||l_transfer_voucher_number||' - '||to_char(fnd_date.canonical_to_date(l_transfer_voucher_date),'DD-Mon-RRRR')
                                   ,p_action_information2            =>     g_year||g_quarter
                                   ,p_action_information3            =>     g_gre_id
                                   ,p_action_information4            =>     l_bank_branch_code
                                   ,p_action_information5            =>     l_transfer_voucher_date
                                   ,p_action_information6            =>     l_amount
                                   ,p_action_information7            =>     l_surcharge
                                   ,p_action_information8            =>     l_education_cess
                                   ,p_action_information9            =>     l_interest
                                   ,p_action_information10           =>     l_others
                                   ,p_action_information11           =>     l_cheque_dd_num
                                   ,p_action_information12           =>     g_challan_data_upd(i).transfer_voucher_number
                                   ,p_action_information13           =>     g_challan_data_upd(i).bank_branch_code
                                   ,p_action_information14           =>     g_challan_data_upd(i).transfer_voucher_date
                                   ,p_action_information15           =>     p_24qa_pay_act_id
                                   ,p_action_information16           =>     l_book_entry
                                   ,p_action_information17           =>     l_previous_total_amount
                                   ,p_action_information18           =>     'U'
                                   ,p_action_information19           =>     update_challans(g_challan_data_upd(i).transfer_voucher_number)
                                   ,p_action_information25           =>     l_challan_record_number
                                   ,p_action_information_id          =>     l_action_info_id
                                   ,p_object_version_number          =>     l_ovn
                                   );
             END IF;
        END LOOP;
    END IF;
    IF (g_correction_mode IN ('C3','C5','%'))
    THEN
        pay_in_utils.set_location(g_debug,'Starting Archival of no change challans ',1);
        archive_no_change_challan(p_24qc_pay_act_id,p_24qa_pay_act_id);
    END IF;
    pay_in_utils.set_location(g_debug,'Leaving '|| g_package||'.archive_challan_data ',1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
   END archive_challan_data;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CANCELLATION_DATA                           --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure to actually archive the data.             --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE archive_cancellation_data(p_payroll_action_id       NUMBER)
  IS
    CURSOR c_get_act_ctxt_id
    IS
       SELECT org_information3
         FROM hr_organization_information
        WHERE org_information_context  = 'PER_IN_FORM24Q_RECEIPT_DF'
          AND organization_id          = g_gre_id
          AND org_information1         = g_year
          AND org_information4         = g_cancel_ref_number;

    CURSOR c_get_last_stmt_details(p_action_context_id  NUMBER)
    IS
       SELECT action_information2
             ,action_information5
             ,action_information7
             ,DECODE(action_information_category,'IN_24Q_ORG',action_information21,action_information7)
         FROM pay_action_information
        WHERE action_context_id = p_action_context_id
          AND action_information_category LIKE 'IN_24Q%ORG'
          AND action_context_type = 'PA';

    l_action_context_id          NUMBER;
    l_tan_number                 VARCHAR2(250);
    l_legal_name                 VARCHAR2(250);
    l_deductor_type              VARCHAR2(250);
    l_emplr_type                 VARCHAR2(250);
    l_emplr_type_24Q             VARCHAR2(250);
    l_action_info_id             NUMBER;
    l_ovn                        NUMBER;
    l_procedure                  VARCHAR2(250);
    l_message                    VARCHAR2(250);
  BEGIN
        g_debug     := hr_utility.debug_enabled;
        l_procedure := g_package ||'.archive_cancellation_data';
        pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
        pay_in_utils.set_location(g_debug,'In this procedure archive only Name ',2);
        pay_in_utils.set_location(g_debug,'and Deductor type and that too as per ',3);
        pay_in_utils.set_location(g_debug,'the receipt number passed in concurrent ',4);
        pay_in_utils.set_location(g_debug,'Program parameters ',5);
        pay_in_utils.set_location(g_debug,'Fetching Action Context ID ',5);

        OPEN  c_get_act_ctxt_id;
        FETCH c_get_act_ctxt_id INTO l_action_context_id;
        CLOSE c_get_act_ctxt_id;

        OPEN  c_get_last_stmt_details(l_action_context_id);
        FETCH c_get_last_stmt_details INTO l_tan_number
                                          ,l_legal_name
                                          ,l_emplr_type
                                          ,l_emplr_type_24Q;
        CLOSE c_get_last_stmt_details;

        IF g_old_format = 'Y' THEN
        l_deductor_type := l_emplr_type;
        ELSE
        l_deductor_type := l_emplr_type_24Q;
        END IF;

        pay_in_utils.set_location(g_debug,'Action Context ID is: ' || l_action_context_id, 6);
        pay_in_utils.set_location(g_debug,'TAN Number is       : ' || l_tan_number,7);
        pay_in_utils.set_location(g_debug,'Legal Name is       : ' || l_legal_name,8);
        pay_in_utils.set_location(g_debug,'Deductor Type is    : ' || l_deductor_type,9);

        pay_in_utils.set_location(g_debug,'Archiving Data ', 9);

        pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_payroll_action_id
                  ,p_action_context_type            =>     'PA'
                  ,p_action_information_category    =>     'IN_24QC_ORG'
                  ,p_source_id                      =>     l_action_context_id
                  ,p_action_information1            =>     g_gre_id
                  ,p_action_information2            =>     l_tan_number
                  ,p_action_information3            =>     g_year||g_quarter
                  ,p_action_information4            =>     NULL
                  ,p_action_information5            =>     l_legal_name
                  ,p_action_information6            =>     NULL
                  ,p_action_information7            =>     l_deductor_type
                  ,p_action_information8            =>     NULL
                  ,p_action_information9            =>     NULL
                  ,p_action_information10           =>     NULL
                  ,p_action_information11           =>     NULL
                  ,p_action_information12           =>     NULL
                  ,p_action_information13           =>     NULL
                  ,p_action_information14           =>     NULL
                  ,p_action_information15           =>     NULL
                  ,p_action_information16           =>     NULL
                  ,p_action_information17           =>     NULL
                  ,p_action_information18           =>     NULL
                  ,p_action_information19           =>     NULL
                  ,p_action_information30           =>     g_24qc_reference
                  ,p_action_information25           =>     NULL
                  ,p_action_information26           =>     NULL
                  ,p_action_information29           =>     'Y'
		  ,p_action_information20           =>     NULL
                  ,p_action_information21           =>     NULL
                  ,p_action_information22           =>     NULL
                  ,p_action_information23           =>     NULL
                  ,p_action_information24           =>     NULL
                  ,p_action_information27           =>     NULL
                  ,p_action_information28           =>     NULL
                  ,p_action_information_id          =>     l_action_info_id
                  ,p_object_version_number          =>     l_ovn
                  );

        pay_in_utils.set_location(g_debug,'Leaving: '|| g_package||'.archive_cancellation_data', 1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END archive_cancellation_data;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ORGANIZATION_DATA                           --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : Procedure to actually archive the data.             --
  -- Parameters     :                                                     --
  --             IN :                                                     --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE archive_organization_data(p_24qc_pay_act_id   NUMBER
                                     ,p_24qa_pay_act_id   NUMBER
                                     )
  IS
     CURSOR c_prev_stmt_details(p_tan_number      VARCHAR2
                               ,p_last_act_cxt_id NUMBER
                               )
     IS
       SELECT action_information5    legal_name
             ,action_information7    emplr_type
             ,DECODE(action_information_category,'IN_24Q_ORG',action_information21,action_information7) emplr_type_24Q
             ,1                      BUI
             ,action_context_id
         FROM pay_action_information
        WHERE action_information_category IN ('IN_24Q_ORG','IN_24QC_ORG')
          AND action_context_id   = p_last_act_cxt_id
          AND action_context_type = 'PA'
          AND action_information1 = g_gre_id
          AND action_information2 = p_tan_number
          AND action_information3 = g_year||g_quarter
        ORDER BY action_context_id DESC;

     CURSOR c_24qa_nil_challan_indicator(p_tan_number      VARCHAR2)
     IS
        SELECT action_information26
         FROM pay_action_information
        WHERE action_information_category = 'IN_24Q_ORG'
          AND action_context_id   = p_24qa_pay_act_id
          AND action_context_type = 'PA'
          AND action_information1 = g_gre_id
          AND action_information2 = p_tan_number
          AND action_information3 = g_year||g_quarter
        ORDER BY action_context_id DESC;

       l_tan_number               hr_organization_information.org_information1%TYPE;
       l_deductor_type            hr_organization_information.org_information3%TYPE;
       l_branch_or_division       hr_organization_information.org_information7%TYPE;
       l_org_location             hr_organization_units.location_id%TYPE;
       l_pan_number               hr_organization_information.org_information3%TYPE;
       l_legal_name               hr_organization_information.org_information4%TYPE;
       l_state                    hr_organization_information.org_information9%TYPE;
       l_pao_code                 hr_organization_information.org_information10%TYPE;
       l_ddo_code                 hr_organization_information.org_information11%TYPE;
       l_ministry_name            hr_organization_information.org_information12%TYPE;
       l_other_ministry_name      hr_organization_information.org_information13%TYPE;
       l_pao_reg_code             hr_organization_information.org_information14%TYPE;
       l_ddo_reg_code             hr_organization_information.org_information15%TYPE;
       l_rep_name                 per_all_people_f.full_name%TYPE;
       l_rep_position             per_all_positions.name%TYPE;
       l_rep_location             hr_organization_units.location_id%TYPE;
       l_rep_email_id             per_all_people_f.email_address%TYPE;
       l_rep_work_phone           per_phones.phone_number%TYPE;
       l_rep_std_code             per_phones.phone_number%TYPE;

       l_action_info_id           NUMBER;
       l_ovn                      NUMBER;
       l_new_nil_challan          VARCHAR2(1);
       l_old_nil_challan          VARCHAR2(1);
       l_previous_org_legal_name  hr_organization_information.org_information4%TYPE;
       l_previous_deductor_type   hr_organization_information.org_information3%TYPE;
       l_previous_emplr_type      hr_organization_information.org_information3%TYPE;
       l_previous_emplr_type_24Q  hr_organization_information.org_information6%TYPE;
       l_batch_upd_indicator      NUMBER;
       i                          NUMBER;
       l_dummy                    NUMBER;
       l_flag                     NUMBER := -1;
       l_procedure                VARCHAR2(250);
       l_message                  VARCHAR2(250);
  BEGIN
        g_debug     := hr_utility.debug_enabled;
        l_procedure := g_package ||'.archive_organization_data';
        pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
        pay_in_utils.set_location(g_debug,'Fetching Organization Data ', 1);
        get_org_details(g_gre_id,
                        l_tan_number,
                        l_deductor_type,
                        l_branch_or_division,
                        l_org_location,
                        l_pan_number,
                        l_legal_name,
                        l_rep_name,
                        l_rep_position,
                        l_rep_location,
                        l_rep_email_id,
                        l_rep_work_phone,
                        l_rep_std_code,
			l_state,
                        l_pao_code,
                        l_ddo_code,
                        l_ministry_name,
                        l_other_ministry_name,
                        l_pao_reg_code,
                        l_ddo_reg_code
                       );

        pay_in_utils.set_location(g_debug,'Received Organization Data ', 1);

        l_previous_org_legal_name := NULL;
        l_previous_deductor_type  := NULL;
        l_batch_upd_indicator     := 0;

        IF (g_count_org = 1)
        THEN
                pay_in_utils.set_location(g_debug,'Archiving ORG data',1);
                SELECT DECODE(DECODE(g_24qc_empr_change,'N',DECODE(g_24qc_rep_adr_chg,'Y','Y','N'),'Y'),'Y',1,0)
                  INTO l_batch_upd_indicator
                  FROM dual;

                pay_in_utils.set_location(g_debug,'Checking Last NIL Challan Indicator details ',6);
                OPEN  c_24qa_nil_challan_indicator(l_tan_number);
                FETCH c_24qa_nil_challan_indicator INTO l_old_nil_challan;
                CLOSE c_24qa_nil_challan_indicator;

                IF ((g_count_challan_add > 1) OR (g_count_challan_upd > 1) OR (g_count_challan_noc > 1))
                THEN
                         l_new_nil_challan := 'N';
                ELSE
                         l_new_nil_challan := 'Y';
                END IF;

                pay_action_information_api.create_action_information
                          (p_action_context_id              =>     p_24qc_pay_act_id
                          ,p_action_context_type            =>     'PA'
                          ,p_action_information_category    =>     'IN_24QC_ORG'
                          ,p_source_id                      =>     p_24qa_pay_act_id
                          ,p_action_information1            =>     g_gre_id
                          ,p_action_information2            =>     l_tan_number
                          ,p_action_information3            =>     g_year||g_quarter
                          ,p_action_information4            =>     l_pan_number
                          ,p_action_information5            =>     l_legal_name
                          ,p_action_information6            =>     l_org_location
                          ,p_action_information7            =>     l_deductor_type
                          ,p_action_information8            =>     l_branch_or_division
                          ,p_action_information9            =>     l_rep_name
                          ,p_action_information10           =>     l_rep_email_id
                          ,p_action_information11           =>     l_rep_position
                          ,p_action_information12           =>     l_rep_location
                          ,p_action_information13           =>     l_rep_work_phone
                          ,p_action_information14           =>     l_rep_std_code
                          ,p_action_information15           =>     l_batch_upd_indicator
                          ,p_action_information16           =>     l_legal_name
                          ,p_action_information17           =>     l_deductor_type
                          ,p_action_information18           =>     g_24qc_empr_change
                          ,p_action_information19           =>     g_24qc_rep_adr_chg
                          ,p_action_information30           =>     g_24qc_reference
                          ,p_action_information25           =>     l_old_nil_challan
                          ,p_action_information26           =>     l_new_nil_challan
			  ,p_action_information20           =>     l_state
			  ,p_action_information21           =>     l_pao_code
                          ,p_action_information22           =>     l_ddo_code
                          ,p_action_information23           =>     l_ministry_name
                          ,p_action_information24           =>     l_other_ministry_name
                          ,p_action_information27           =>     l_pao_reg_code
                          ,p_action_information28           =>     l_ddo_reg_code
                          ,p_action_information_id          =>     l_action_info_id
                          ,p_object_version_number          =>     l_ovn
                          );
                       pay_in_utils.set_location(g_debug,'Leaving archive_organization_data NC',9);

                       RETURN;
        END IF;

        pay_in_utils.set_location(g_debug,'Value of g_count_org is '|| g_count_org ,2);

        FOR i IN 1.. g_count_org - 1
        LOOP
                IF (g_org_data(i).gre_id = g_gre_id)
                THEN
                       pay_in_utils.set_location(g_debug,'Fetching previous statement details ',3);
                       OPEN  c_prev_stmt_details(l_tan_number,g_org_data(i).last_action_context_id);
                       FETCH c_prev_stmt_details INTO l_previous_org_legal_name
                                                     ,l_previous_emplr_type
                                                     ,l_previous_emplr_type_24Q
                                                     ,l_batch_upd_indicator
                                                     ,l_dummy;
                       CLOSE c_prev_stmt_details;
		       IF g_old_format = 'Y'
                       THEN
                       l_previous_deductor_type := l_previous_emplr_type;
                       ELSE
                       l_previous_deductor_type := l_previous_emplr_type_24Q;
                       END IF;
                       pay_in_utils.set_location(g_debug,'Fetched previous statement details ',3);

                       pay_in_utils.set_location(g_debug,'Checking New NIL Challan Indicator details ',4);
                       IF ((g_count_challan_add > 1) OR (g_count_challan_upd > 1) OR (g_count_challan_noc > 1))
                       THEN
                                l_new_nil_challan := 'N';
                       ELSE
                                l_new_nil_challan := 'Y';
                       END IF;
                       pay_in_utils.set_location(g_debug,'New NIL Challan Indicator is '|| l_new_nil_challan,5);
                END IF;
        END LOOP;

        pay_in_utils.set_location(g_debug,'Checking Last NIL Challan Indicator details ',6);
        OPEN  c_24qa_nil_challan_indicator(l_tan_number);
        FETCH c_24qa_nil_challan_indicator INTO l_old_nil_challan;
        CLOSE c_24qa_nil_challan_indicator;

        pay_in_utils.set_location(g_debug,'Archiving Data ',7);
        pay_in_utils.set_location(g_debug,'Address Change is '|| g_24qc_empr_change , 2);

        pay_action_information_api.create_action_information
                  (p_action_context_id              =>     p_24qc_pay_act_id
                  ,p_action_context_type            =>     'PA'
                  ,p_action_information_category    =>     'IN_24QC_ORG'
                  ,p_source_id                      =>     p_24qa_pay_act_id
                  ,p_action_information1            =>     g_gre_id
                  ,p_action_information2            =>     l_tan_number
                  ,p_action_information3            =>     g_year||g_quarter
                  ,p_action_information4            =>     l_pan_number
                  ,p_action_information5            =>     l_legal_name
                  ,p_action_information6            =>     l_org_location
                  ,p_action_information7            =>     l_deductor_type
                  ,p_action_information8            =>     l_branch_or_division
                  ,p_action_information9            =>     l_rep_name
                  ,p_action_information10           =>     l_rep_email_id
                  ,p_action_information11           =>     l_rep_position
                  ,p_action_information12           =>     l_rep_location
                  ,p_action_information13           =>     l_rep_work_phone
                  ,p_action_information14           =>     l_rep_std_code
                  ,p_action_information15           =>     l_batch_upd_indicator
                  ,p_action_information16           =>     l_previous_org_legal_name
                  ,p_action_information17           =>     l_previous_deductor_type
                  ,p_action_information18           =>     g_24qc_empr_change
                  ,p_action_information19           =>     g_24qc_rep_adr_chg
                  ,p_action_information30           =>     g_24qc_reference
                  ,p_action_information25           =>     l_old_nil_challan
                  ,p_action_information26           =>     l_new_nil_challan
	          ,p_action_information20           =>     l_state
	          ,p_action_information21           =>     l_pao_code
                  ,p_action_information22           =>     l_ddo_code
                  ,p_action_information23           =>     l_ministry_name
                  ,p_action_information24           =>     l_other_ministry_name
                  ,p_action_information27           =>     l_pao_reg_code
                  ,p_action_information28           =>     l_ddo_reg_code
                  ,p_action_information_id          =>     l_action_info_id
                  ,p_object_version_number          =>     l_ovn
                  );
        pay_in_utils.set_location(g_debug,'Leaving:'|| g_package||'.archive_organization_data',1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END archive_organization_data;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CHECK_GRE                                           --
  -- Type           : FUNCTION                                           --
  -- Access         : Private                                             --
  -- Description    :                                                     --
  -- Parameters     :                                                     --
  --             IN : p_assignment_act_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 02-May-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION check_gre(p_assignment_act_id   IN NUMBER)
  RETURN BOOLEAN
  IS
    CURSOR c_24q_per_check
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_information_category = 'IN_24Q_PERSON'
          AND action_context_id = p_assignment_act_id
          AND action_information3 = g_gre_id;

    CURSOR c_24qc_ded_check
    IS
       SELECT 1
         FROM pay_action_information
        WHERE action_information_category = 'IN_24QC_DEDUCTEE'
          AND action_context_id = p_assignment_act_id
          AND action_information3 = g_gre_id;

    l_flag                NUMBER;
    l_procedure           VARCHAR2(250);
    l_message             VARCHAR2(250);
  BEGIN
    l_procedure  :=  g_package || '.check_gre';
    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);
    pay_in_utils.set_location(g_debug,'Checking Asg Action ID: '|| p_assignment_act_id,20);

    l_flag := -1;

    OPEN  c_24q_per_check;
    FETCH c_24q_per_check INTO l_flag;
    CLOSE c_24q_per_check;

    pay_in_utils.set_location(g_debug,'Value of l_flag:'|| l_flag,25);

    IF (l_flag = -1)
    THEN
        pay_in_utils.set_location(g_debug,'Checking in 24Q Correction',30);
        OPEN  c_24qc_ded_check;
        FETCH c_24qc_ded_check INTO l_flag;
        CLOSE c_24qc_ded_check;
        pay_in_utils.set_location(g_debug,'Value of l_flag:'|| l_flag,40);
    END IF;

    IF (l_flag = 1)
    THEN
        RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END check_gre;
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GENERATE_LOCKING                                    --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure locks the assignments                --
  -- Parameters     :                                                     --
  --             IN : p_lcking_pay_act_id    NUMBER                       --
  --                : p_locked_pay_act_id_q  NUMBER                       --
  --                : p_locked_pay_act_id_qc NUMBER                       --
  --                : p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE generate_locking(p_locking_pay_act_id   IN NUMBER
                            ,p_locked_pay_act_id_q  IN NUMBER
                            ,p_locked_pay_act_id_qc IN NUMBER
                            ,p_chunk                IN NUMBER
                            )
  IS
    CURSOR c_assignment_action_id(p_payroll_action_id   NUMBER)
    IS
       SELECT assignment_action_id
             ,assignment_id
         FROM pay_assignment_actions
        WHERE payroll_action_id = p_payroll_action_id;

    CURSOR c_chk_asg_action(p_assignment_id     NUMBER
                           ,p_payroll_action_id NUMBER
                           )
    IS
       SELECT assignment_action_id
         FROM pay_assignment_actions paa
             ,pay_action_interlocks  pai
        WHERE paa.assignment_id        = p_assignment_id
          AND paa.assignment_action_id = pai.locking_action_id
          AND paa.payroll_action_id    = p_payroll_action_id;

    CURSOR c_check_action(p_locking_act_id     NUMBER
                         ,p_locked_act_id      NUMBER
                         )
    IS
       SELECT 1
         FROM pay_action_interlocks  pai
        WHERE pai.locking_action_id   = p_locking_act_id
          AND pai.locked_action_id    = p_locked_act_id;

    CURSOR c_select_prev_24qc
    IS
       SELECT MAX(org_information3)
         FROM hr_organization_information
        WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
          AND organization_id  = g_gre_id
          AND org_information1 = g_year
          AND org_information2 = g_quarter
          AND org_information5 = 'A'
          AND org_information6 = 'C'
          AND org_information3 <> p_locked_pay_act_id_qc;

    l_action_id           NUMBER;
    l_procedure           VARCHAR2(250);
    l_message             VARCHAR2(250);
    l_flag                NUMBER;
    l_24qc_prv_pay_act_id NUMBER;
    --
  BEGIN
    l_procedure  :=  g_package || '.generate_locking';
    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    FOR c_rec IN c_assignment_action_id(p_locked_pay_act_id_q)
    LOOP
       IF (check_gre(c_rec.assignment_action_id))
       THEN
           l_action_id := NULL;
           OPEN  c_chk_asg_action(c_rec.assignment_id,p_locking_pay_act_id);
           FETCH c_chk_asg_action INTO l_action_id;
           CLOSE c_chk_asg_action;
           IF (l_action_id IS NULL)
           THEN
                   SELECT pay_assignment_actions_s.NEXTVAL
                     INTO l_action_id
                     FROM dual;

                   pay_in_utils.set_location(g_debug,'Value of l_action_id is        '|| l_action_id, 11);
                   pay_in_utils.set_location(g_debug,'Value of l_locked_action_id is '|| c_rec.assignment_action_id, 12);
                   pay_in_utils.set_location(g_debug,'Value of assignment_id is      '|| c_rec.assignment_id, 13);

                   pay_in_utils.set_location(g_debug,'Inserting Assignment Actions ', 14);
                   hr_nonrun_asact.insact(lockingactid => l_action_id
                                         ,assignid     => c_rec.assignment_id
                                         ,pactid       => p_locking_pay_act_id
                                         ,chunk        => p_chunk
                                         );
                   pay_in_utils.set_location(g_debug,'Enforcing Locking ', 15);
                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                         ,lockedactid  => c_rec.assignment_action_id
                                         );
                   pay_in_utils.set_location(g_debug,'Locking enforced', 16);
           END IF;
      END IF;
    END LOOP;

    pay_in_utils.set_location(g_debug,'Now starting locking Latest 24Q Correction Assignments', 16);
    FOR c_rec IN c_assignment_action_id(p_locked_pay_act_id_qc)
    LOOP
       IF (check_gre(c_rec.assignment_action_id))
       THEN
           l_action_id := NULL;
           OPEN  c_chk_asg_action(c_rec.assignment_id,p_locking_pay_act_id);
           FETCH c_chk_asg_action INTO l_action_id;
           CLOSE c_chk_asg_action;
           pay_in_utils.set_location(g_debug,'Value of l_action_id is        '|| l_action_id, 11);

           IF (l_action_id IS NULL)
           THEN
               SELECT pay_assignment_actions_s.NEXTVAL
                 INTO l_action_id
                 FROM dual;

                pay_in_utils.set_location(g_debug,'Inserting Assignment Actions as it was null', 14);
                hr_nonrun_asact.insact(lockingactid => l_action_id
                                      ,assignid     => c_rec.assignment_id
                                      ,pactid       => p_locking_pay_act_id
                                      ,chunk        => p_chunk
                                      );
           END IF;

           pay_in_utils.set_location(g_debug,'Value of l_locked_action_id is '|| c_rec.assignment_action_id, 12);
           pay_in_utils.set_location(g_debug,'Value of assignment_id is      '|| c_rec.assignment_id, 13);

           l_flag := NULL;
           OPEN  c_check_action(l_action_id,c_rec.assignment_action_id);
           FETCH c_check_action INTO l_flag;
           CLOSE c_check_action;

           IF (l_flag IS NULL)
           THEN
                pay_in_utils.set_location(g_debug,'Enforcing Locking ', 15);
                hr_nonrun_asact.insint(lockingactid => l_action_id
                                      ,lockedactid  => c_rec.assignment_action_id
                                      );
                pay_in_utils.set_location(g_debug,'Locking enforced', 16);
           END IF;
       END IF;
    END LOOP;

    OPEN  c_select_prev_24qc;
    FETCH c_select_prev_24qc INTO l_24qc_prv_pay_act_id;
    CLOSE c_select_prev_24qc;

    pay_in_utils.set_location(g_debug,'Payroll Action ID of previous 24Q Correction archival is '||l_24qc_prv_pay_act_id,1);

    IF (l_24qc_prv_pay_act_id IS NOT NULL)
    THEN
        pay_in_utils.set_location(g_debug,'Now starting locking Previous 24Q Correction Assignments', 16);
        FOR c_rec IN c_assignment_action_id(l_24qc_prv_pay_act_id)
        LOOP
          IF (check_gre(c_rec.assignment_action_id))
          THEN
               l_action_id := NULL;
               OPEN  c_chk_asg_action(c_rec.assignment_id,p_locking_pay_act_id);
               FETCH c_chk_asg_action INTO l_action_id;
               CLOSE c_chk_asg_action;
               pay_in_utils.set_location(g_debug,'Value of l_action_id is        '|| l_action_id, 11);

               IF (l_action_id IS NULL)
               THEN
                   SELECT pay_assignment_actions_s.NEXTVAL
                     INTO l_action_id
                     FROM dual;

                    pay_in_utils.set_location(g_debug,'Inserting Assignment Actions as it was null', 14);
                    hr_nonrun_asact.insact(lockingactid => l_action_id
                                          ,assignid     => c_rec.assignment_id
                                          ,pactid       => p_locking_pay_act_id
                                          ,chunk        => p_chunk
                                          );
               END IF;

               pay_in_utils.set_location(g_debug,'Value of l_locked_action_id is '|| c_rec.assignment_action_id, 12);
               pay_in_utils.set_location(g_debug,'Value of assignment_id is      '|| c_rec.assignment_id, 13);

               l_flag := NULL;
               OPEN  c_check_action(l_action_id,c_rec.assignment_action_id);
               FETCH c_check_action INTO l_flag;
               CLOSE c_check_action;

               IF (l_flag IS NULL)
               THEN
                    pay_in_utils.set_location(g_debug,'Enforcing Locking ', 15);
                    hr_nonrun_asact.insint(lockingactid => l_action_id
                                          ,lockedactid  => c_rec.assignment_action_id
                                          );
                    pay_in_utils.set_location(g_debug,'Locking enforced', 16);
                 END IF;
          END IF;
        END LOOP;
    END IF;
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,10);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
END generate_locking;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_C5_DATA_ONLY                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    :                                                     --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id      NUMBER                     --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    abhjain    Initial Version                      --
  --------------------------------------------------------------------------
PROCEDURE archive_c5_data_only(p_payroll_action_id      NUMBER)
IS
  CURSOR c_select_deductee
  IS
     SELECT DISTINCT pai.action_information1 challan
       FROM pay_action_information pai
           ,pay_assignment_actions paa
      WHERE pai.action_information_category = 'IN_24QC_DEDUCTEE'
        AND paa.assignment_action_id        = pai.action_context_id
        AND paa.payroll_action_id           = p_payroll_action_id
        AND pai.action_information19        IS NOT NULL
        AND pai.action_information20        IS NOT NULL;

  CURSOR c_challan_sequence(p_challan_number   VARCHAR2)
  IS
     SELECT pai.action_information25 challan_seq
       FROM pay_action_information pai
      WHERE pai.action_information_category IN ('IN_24QC_CHALLAN','IN_24Q_CHALLAN')
        AND pai.action_information1         = p_challan_number
        AND pai.action_context_id IN
                                   (
                                    SELECT org_information3
                                      FROM hr_organization_information
                                     WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
                                       AND organization_id  = g_gre_id
                                       AND org_information1 = g_year
                                       AND org_information2 = g_quarter
                                       AND org_information5 = 'A'
                                )
        AND ROWNUM                          = 1;

  CURSOR c_prev_stmt_details(p_last_act_cxt_id NUMBER
                            )
  IS
    SELECT action_information2    tan_number
          ,action_information5    legal_name
          ,action_information7    emplr_type
          ,DECODE(action_information_category,'IN_24Q_ORG',action_information21,action_information7) emplr_type_24Q
      FROM pay_action_information
     WHERE action_information_category IN ('IN_24Q_ORG','IN_24QC_ORG')
       AND action_context_id   = p_last_act_cxt_id
       AND action_context_type = 'PA'
       AND action_information1 = g_gre_id
       AND action_information3 = g_year||g_quarter
     ORDER BY action_context_id DESC;

  l_challan_deductee_no      VARCHAR2(250);
  l_tan_number               hr_organization_information.org_information1%TYPE;
  l_deductor_type            hr_organization_information.org_information3%TYPE;
  l_emplr_type                 hr_organization_information.org_information3%TYPE;
  l_emplr_type_24Q             hr_organization_information.org_information6%TYPE;
  l_branch_or_division       hr_organization_information.org_information7%TYPE;
  l_org_location             hr_organization_units.location_id%TYPE;
  l_pan_number               hr_organization_information.org_information3%TYPE;
  l_legal_name               hr_organization_information.org_information4%TYPE;
  l_state                    hr_organization_information.org_information9%TYPE;
  l_pao_code                 hr_organization_information.org_information10%TYPE;
  l_ddo_code                 hr_organization_information.org_information11%TYPE;
  l_ministry_name            hr_organization_information.org_information12%TYPE;
  l_other_ministry_name      hr_organization_information.org_information13%TYPE;
  l_pao_reg_code             hr_organization_information.org_information14%TYPE;
  l_ddo_reg_code             hr_organization_information.org_information15%TYPE;
  l_rep_name                 per_all_people_f.full_name%TYPE;
  l_rep_position             per_all_positions.name%TYPE;
  l_rep_location             hr_organization_units.location_id%TYPE;
  l_rep_email_id             per_all_people_f.email_address%TYPE;
  l_rep_work_phone           per_phones.phone_number%TYPE;
  l_rep_std_code             per_phones.phone_number%TYPE;
  l_flag_number              NUMBER := -1;
  l_action_info_id           NUMBER;
  l_ovn                      NUMBER;

  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'.archive_c5_data_only';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   pay_in_utils.set_location(g_debug,'Checking Challan Data', 1);
   FOR c_rec IN c_select_deductee
   LOOP
        OPEN  c_challan_sequence(c_rec.challan);
        FETCH c_challan_sequence INTO l_challan_deductee_no;
        CLOSE c_challan_sequence;

         pay_in_utils.set_location(g_debug,'Challan No is :'|| c_rec.challan, 1);
         pay_in_utils.set_location(g_debug,'Challan Seq No is :'|| l_challan_deductee_no, 1);
         pay_in_utils.set_location(g_debug,'Checking Challan Data in updated Data', 1);
         pay_in_utils.set_location(g_debug,'Value of g_count_challan_upd C5 is '|| g_count_challan_upd,2);

        FOR i IN 1..g_count_challan_upd - 1
        LOOP
                pay_in_utils.set_location(g_debug,'Found Challan in updated Data', 1);
                l_flag_number := -1;
                l_flag_number := check_archival_status(NULL,'IN_24QC_CHALLAN',g_challan_data_upd(i).transfer_voucher_number,NULL);
                IF((g_challan_data_upd(i).transfer_voucher_number = c_rec.challan)AND(l_flag_number = 0))
                THEN
                         pay_action_information_api.create_action_information
                                    (p_action_context_id              =>     p_payroll_action_id
                                    ,p_action_context_type            =>     'PA'
                                    ,p_action_information_category    =>     'IN_24QC_CHALLAN'
                                    ,p_source_id                      =>     g_challan_data_upd(i).org_information_id
                                    ,p_action_information1            =>     g_challan_data_upd(i).transfer_voucher_number
                                    ,p_action_information2            =>     g_year||g_quarter
                                    ,p_action_information3            =>     g_gre_id
                                    ,p_action_information5            =>     g_challan_data_upd(i).transfer_voucher_date
                                    ,p_action_information17           =>     g_challan_data_upd(i).amount
                                                                           + g_challan_data_upd(i).surcharge
                                                                           + g_challan_data_upd(i).education_cess
                                                                           + g_challan_data_upd(i).interest
                                                                           + g_challan_data_upd(i).other
                                    ,p_action_information18           =>     'NC'
                                    ,p_action_information19           =>     update_challans(g_challan_data_upd(i).transfer_voucher_number)
                                    ,p_action_information25           =>     l_challan_deductee_no
                                    ,p_action_information29           =>     'C5'
                                    ,p_action_information_id          =>     l_action_info_id
                                    ,p_object_version_number          =>     l_ovn
                                    );
                END IF;
        END LOOP;

        pay_in_utils.set_location(g_debug,'Checking Challan Data in No Change Data', 1);
         pay_in_utils.set_location(g_debug,'Value of g_count_challan_noc C5 is '|| g_count_challan_noc,2);
        FOR i IN 1..g_count_challan_noc - 1
        LOOP
                pay_in_utils.set_location(g_debug,'Found Challan in no change Data', 1);
                l_flag_number := -1;
                l_flag_number := check_archival_status(NULL,'IN_24QC_CHALLAN',g_challan_data_noc(i).transfer_voucher_number,NULL);
                IF((g_challan_data_noc(i).transfer_voucher_number = c_rec.challan)AND(l_flag_number =0))
                THEN
                         pay_action_information_api.create_action_information
                                    (p_action_context_id              =>     p_payroll_action_id
                                    ,p_action_context_type            =>     'PA'
                                    ,p_action_information_category    =>     'IN_24QC_CHALLAN'
                                    ,p_source_id                      =>     g_challan_data_noc(i).org_information_id
                                    ,p_action_information1            =>     g_challan_data_noc(i).transfer_voucher_number
                                    ,p_action_information2            =>     g_year||g_quarter
                                    ,p_action_information3            =>     g_gre_id
                                    ,p_action_information5            =>     g_challan_data_noc(i).transfer_voucher_date
                                    ,p_action_information17           =>     g_challan_data_noc(i).amount
                                                                           + g_challan_data_noc(i).surcharge
                                                                           + g_challan_data_noc(i).education_cess
                                                                           + g_challan_data_noc(i).interest
                                                                           + g_challan_data_noc(i).other
                                    ,p_action_information18           =>     'NC'
                                    ,p_action_information19           =>     update_challans(g_challan_data_noc(i).transfer_voucher_number)
                                    ,p_action_information25           =>     l_challan_deductee_no
                                    ,p_action_information29           =>     'C5'
                                    ,p_action_information_id          =>     l_action_info_id
                                    ,p_object_version_number          =>     l_ovn
                                    );
                END IF;
        END LOOP;
   END LOOP;

   pay_in_utils.set_location(g_debug,'Checking Organization Data', 1);
   l_flag_number := -1;
   l_flag_number := check_archival_status(NULL,'IN_24QC_ORG',NULL,NULL);
   IF (l_flag_number <> 0)
   THEN
          RETURN;
   END IF;
   pay_in_utils.set_location(g_debug,'Value of g_count_org is ' || g_count_org,2);

   IF (g_count_org = 1)
   THEN
        pay_in_utils.set_location(g_debug,'Fetching Live Organization Data ', 1);
        get_org_details(g_gre_id,
                        l_tan_number,
                        l_deductor_type,
                        l_branch_or_division,
                        l_org_location,
                        l_pan_number,
                        l_legal_name,
                        l_rep_name,
                        l_rep_position,
                        l_rep_location,
                        l_rep_email_id,
                        l_rep_work_phone,
                        l_rep_std_code,
			l_state,
                        l_pao_code,
                        l_ddo_code,
                        l_ministry_name,
                        l_other_ministry_name,
                        l_pao_reg_code,
                        l_ddo_reg_code
                       );
   ELSE
         FOR c_rec IN c_prev_stmt_details(g_org_data(1).last_action_context_id)
         LOOP
                 l_tan_number     :=  c_rec.tan_number;
                 l_legal_name     :=  c_rec.legal_name;
                 l_emplr_type     :=  c_rec.emplr_type;
                 l_emplr_type_24Q :=  c_rec.emplr_type_24Q;
         END LOOP;
	 IF g_old_format = 'Y' THEN
         l_deductor_type := l_emplr_type;
         ELSE
         l_deductor_type := l_emplr_type_24Q;
         END IF;
   END IF;

  pay_in_utils.set_location(g_debug,'Archiving Org Data for C5 ', 9);
  pay_in_utils.set_location(g_debug,'p_payroll_action_id is '|| p_payroll_action_id, 10);
  l_action_info_id := NULL;
  l_ovn            := NULL;

  pay_action_information_api.create_action_information
            (p_action_context_id              =>     p_payroll_action_id
            ,p_action_context_type            =>     'PA'
            ,p_action_information_category    =>     'IN_24QC_ORG'
            ,p_action_information1            =>     g_gre_id
            ,p_action_information2            =>     l_tan_number
            ,p_action_information3            =>     g_year||g_quarter
            ,p_action_information4            =>     NULL
            ,p_action_information5            =>     l_legal_name
            ,p_action_information6            =>     NULL
            ,p_action_information7           =>     l_deductor_type
            ,p_action_information15           =>     '0'
            ,p_action_information29           =>     'C5'
            ,p_action_information30           =>     g_24qc_reference
            ,p_action_information_id          =>     l_action_info_id
            ,p_object_version_number          =>     l_ovn
            );

   pay_in_utils.set_location(g_debug,'Archived Org Data for C5 ', 9);
   pay_in_utils.set_location(g_debug,'Leaving: '|| g_package||'.archive_c5_data_only', 1);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
END archive_c5_data_only;

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
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  -- 115.1 07-Feb-2007    rpalli    5754018 : 24QC Quarter4 Stat Update   --
  --------------------------------------------------------------------------
  --
  PROCEDURE assignment_action_code(p_payroll_action_id   IN NUMBER
                                  ,p_start_person        IN NUMBER
                                  ,p_end_person          IN NUMBER
                                  ,p_chunk               IN NUMBER
                                  )
  IS
    CURSOR c_pay_act_id_last_24Q
    IS
      SELECT org_information3 -- payroll action id of this quarter Form 24Q A/C Archival
            ,org_information6 -- Archival Type (Original or Correction Statement)
        FROM hr_organization_information
       WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
         AND organization_id  = g_gre_id
         AND org_information1 = g_year
         AND org_information2 = g_quarter
         AND org_information5 = 'A'
       ORDER BY org_information3 DESC;

    CURSOR c_chk_action_lock(p_locking_action_id NUMBER
                            ,p_locked_action_id NUMBER
                           )
    IS
      SELECT 1
        FROM pay_action_interlocks
       WHERE locking_action_id = p_locking_action_id
         AND locked_action_id  = p_locked_action_id;

    CURSOR c_chk_asg_action(p_assignment_id     NUMBER
                           ,p_payroll_act_id    NUMBER
                           )
    IS
      SELECT assignment_action_id
        FROM pay_assignment_actions
       WHERE payroll_action_id = p_payroll_act_id
         AND assignment_id     = p_assignment_id;

    CURSOR c_max_24qc_locking_24q(p_24qc_arc_asg_act_id      NUMBER)
    IS
      SELECT max(locking_action_id)
       FROM pay_action_interlocks
      WHERE locked_action_id = p_24qc_arc_asg_act_id
      ORDER BY locking_action_id DESC;

    CURSOR c_select_prev_24qc(p_locked_pay_act_id_qc  NUMBER)
    IS
       SELECT MAX(org_information3)
         FROM hr_organization_information
        WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
          AND organization_id  = g_gre_id
          AND org_information1 = g_year
          AND org_information2 = g_quarter
          AND org_information5 = 'A'
          AND org_information6 = 'C'
          AND org_information3 <> p_locked_pay_act_id_qc;

    CURSOR c_source_id(p_pay_act_id_last_24Q     NUMBER)
    IS
       SELECT source_id
         FROM pay_action_information
        WHERE action_context_id           = p_pay_act_id_last_24Q
          AND action_information_category = 'IN_24QC_ORG'
          AND action_context_type         = 'PA'
          AND action_information3         = g_year||g_quarter;

    CURSOR c_act_category(p_pay_act_id_last_24Q     NUMBER)
    IS
      SELECT DECODE(pai.action_information_category,'IN_24Q_ORG',1,2)
       FROM pay_action_information pai
      WHERE pai.action_information_category IN ('IN_24QC_ORG','IN_24Q_ORG')
        AND pai.action_context_id           = p_pay_act_id_last_24Q
        AND pai.action_context_type         = 'PA'
        AND pai.action_information3         = g_year||g_quarter
        AND pai.action_information1         = g_gre_id;

    l_max_24qc_locking_24q      NUMBER;
    l_procedure                 VARCHAR2(100);
    l_message                   VARCHAR2(250);
    l_action_id                 NUMBER;
    l_pay_act_id_last_24Q       NUMBER;
    l_dummy                     NUMBER;
    l_24q_asg_action_id         NUMBER;
    l_24q_locked_pay_id         NUMBER;
    l_24qc_locked_pay_id        NUMBER;
    l_flag                      BOOLEAN;
    l_flag_number               NUMBER := -1;
    l_last_24qc_pay_act_id      NUMBER;

    l_lock_exists               NUMBER;

  --
  BEGIN
  --

    l_procedure  :=  g_package || '.assignment_action_code';
    g_debug :=  hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    pay_in_utils.set_location(g_debug,'Archival for C4,C5 Modes Starts : '||l_procedure,12);

 --C4,C5 Salary Data Archival Starts
    IF (g_sal_action)
    THEN
           pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,15);

           initialization_code(p_payroll_action_id);

           l_flag  := TRUE;
           --Fetch last Form 24Q archival Payroll action id
            FOR c_rec IN c_pay_act_id_last_24Q
            LOOP
               pay_in_utils.set_location(g_debug,'ASSIGNMENT_ACTION_CODE : In c_pay_act_id_last_24Q ', 1);
               pay_in_utils.set_location(g_debug,'In c_rec.org_information6 : ' || c_rec.org_information6, 1);
               pay_in_utils.set_location(g_debug,'In c_rec.org_information3 : ' || c_rec.org_information3, 1);
               IF (l_flag)
               THEN
                     IF (c_rec.org_information6 = 'O')
                     THEN
                             l_pay_act_id_last_24Q := c_rec.org_information3;
                             pay_in_utils.set_location(g_debug,'In l_pay_act_id_last_24Q : ' || l_pay_act_id_last_24Q, 1);
                     ELSE
                             l_pay_act_id_last_24Q := c_rec.org_information3;
                             pay_in_utils.set_location(g_debug,'In l_pay_act_id_last_24Q : ' || l_pay_act_id_last_24Q, 1);
                     END IF;
                     l_flag := FALSE;
               END IF;
            END LOOP;
            pay_in_utils.set_location(g_debug,' Archival Action with which we need comparison is '|| l_pay_act_id_last_24Q,1);

           IF (l_pay_act_id_last_24Q IS NOT NULL)
           THEN
                 OPEN c_act_category(l_pay_act_id_last_24Q);
                 FETCH c_act_category INTO l_dummy;
                 CLOSE c_act_category;
           END IF;
            pay_in_utils.set_location(g_debug,' l_dummy is : '|| l_dummy, 3);

             IF (l_dummy = 1)
             THEN
             -- This means that l_pay_act_id_last_24Q corresponds to 24Q Archival only.
                l_24q_locked_pay_id  := l_pay_act_id_last_24Q;
                l_24qc_locked_pay_id := NULL;
             ELSIF(l_dummy = 2)
             THEN
             -- This means that l_pay_act_id_last_24Q corresponds to 24QC Archival.
                 OPEN c_source_id(l_pay_act_id_last_24Q);
                 FETCH c_source_id INTO l_24q_locked_pay_id;
                 CLOSE c_source_id;

                l_24qc_locked_pay_id := l_pay_act_id_last_24Q;
             END IF;
            pay_in_utils.set_location(g_debug,' l_24q_locked_pay_id  is '|| l_24q_locked_pay_id  ,4);
            pay_in_utils.set_location(g_debug,' l_24qc_locked_pay_id is '|| l_24qc_locked_pay_id ,5);

           g_payroll_action_id   := p_payroll_action_id;
           g_24q_payroll_act_id  := l_24q_locked_pay_id;
           g_24qc_payroll_act_id := l_24qc_locked_pay_id;

           OPEN  c_select_prev_24qc(g_24qc_payroll_act_id);
           FETCH c_select_prev_24qc INTO l_last_24qc_pay_act_id;
           CLOSE c_select_prev_24qc;

           pay_in_utils.set_location(g_debug,'Payroll Action ID of previous 24Q Correction is '|| l_last_24qc_pay_act_id,2);

           IF ((l_pay_act_id_last_24Q IS NULL)AND(g_correction_mode <> 'Y'))
           THEN
                RETURN;
           END IF;

           IF (g_correction_mode <> 'Y')
           THEN
               pay_in_utils.set_location(g_debug,'Calling : generate_employee_data '|| l_procedure,10);
               pay_in_utils.set_location(g_debug,'l_24q_locked_pay_id is ' || l_24q_locked_pay_id ,11);
               generate_employee_data(l_24q_locked_pay_id);

               pay_in_utils.set_location(g_debug,'Calling : generate_salary_data '|| l_procedure,20);
               pay_in_utils.set_location(g_debug,'l_24q_locked_pay_id is ' || l_24q_locked_pay_id ,21);
               generate_salary_data(l_24q_locked_pay_id, p_start_person, p_end_person);

               pay_in_utils.set_location(g_debug,'Calling : generate_challan_data '|| l_procedure,30);
               generate_challan_data(l_24q_locked_pay_id,g_gre_id);

               pay_in_utils.set_location(g_debug,'Calling : generate_organization_data '|| l_procedure,20);
               generate_organization_data(l_24q_locked_pay_id,g_gre_id);
           ELSE
               pay_in_utils.set_location(g_debug,'Calling : archive_cancellation_data '|| l_procedure,20);
               pay_in_utils.set_location(g_debug,'Checking Org archival status',1);
               l_flag_number := -1;
               l_flag_number := check_archival_status(NULL,'IN_24QC_ORG',NULL,NULL);
               IF (l_flag_number = 0)
               THEN
                       archive_cancellation_data(p_payroll_action_id);
               END IF;
               g_sal_action := FALSE;
               generate_locking(p_payroll_action_id,l_24q_locked_pay_id,l_24qc_locked_pay_id,p_chunk);
               RETURN;
           END IF;

           pay_in_utils.set_location(g_debug,'Inserting assignment action ids for Salary Records',30);

           pay_in_utils.set_location(g_debug,'Inserting Asg Action ID for Deleted Assignment Actions ' ,35);

           pay_in_utils.set_location(g_debug,'Value of g_count_sal_delete is '|| g_count_sal_delete, 39);
           IF ((g_count_sal_delete > 1) AND (g_correction_mode <> 'Y'))
           THEN
                   FOR i IN 1..g_count_sal_delete - 1
                   LOOP
                      l_24q_asg_action_id := NULL;
                      l_dummy             := NULL;
                      pay_in_utils.set_location(g_debug,'Checking for Assignment '|| g_sal_data_rec_del(i).assignment_id,1);
                      pay_in_utils.set_location(g_debug,'Payroll Action id is ' || p_payroll_action_id,2);
                      OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,p_payroll_action_id);
                      FETCH c_chk_asg_action INTO l_dummy;
                      CLOSE c_chk_asg_action;


                      pay_in_utils.trace('l_dummy in g_count_sal_delete ',l_dummy);

                       IF (l_dummy IS NULL)
                       THEN
                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO l_action_id
                             FROM dual;

                           pay_in_utils.set_location(g_debug,'Value of l_action_id is '|| l_action_id, 61);
                           pay_in_utils.set_location(g_debug,'Inserting Assignment action id ',61);

                            hr_nonrun_asact.insact(lockingactid => l_action_id
                                                  ,assignid     => g_sal_data_rec_del(i).assignment_id
                                                  ,pactid       => p_payroll_action_id
                                                  ,chunk        => p_chunk
                                                  );

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);

                           OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;

                       IF (l_dummy IS NOT NULL)
                       THEN

                           pay_in_utils.set_location(g_debug,'Value of l_dummy is '|| l_dummy, 61);

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;

                           OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;
                           OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;
                           OPEN  c_chk_asg_action(g_sal_data_rec_del(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;

                  END LOOP;
           END IF;


           pay_in_utils.set_location(g_debug,'Inserting Asg Action ID for Added Assignment Actions ' ,60);
           pay_in_utils.set_location(g_debug,'Value of g_count_sal_addition is '|| g_count_sal_addition, 61);
           IF ((g_count_sal_addition > 1) AND (g_correction_mode <> 'Y'))
           THEN
                  FOR i IN 1..g_count_sal_addition - 1
                  LOOP
                      l_24q_asg_action_id := NULL;
                      l_dummy             := NULL;
                      pay_in_utils.set_location(g_debug,'Checking for Assignment '|| g_sal_data_rec_add(i).assignment_id,1);
                      pay_in_utils.set_location(g_debug,'Payroll Action id is ' || p_payroll_action_id,2);

                      OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,p_payroll_action_id);
                      FETCH c_chk_asg_action INTO l_dummy;
                      CLOSE c_chk_asg_action;

                      pay_in_utils.trace('l_dummy in g_count_sal_addition ',l_dummy);

                       IF (l_dummy IS NULL)
                       THEN
                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO l_action_id
                             FROM dual;

                           pay_in_utils.set_location(g_debug,'Value of l_action_id is '|| l_action_id, 61);
                           pay_in_utils.set_location(g_debug,'Inserting Assignment action id ',61);

                            hr_nonrun_asact.insact(lockingactid => l_action_id
                                                  ,assignid     => g_sal_data_rec_add(i).assignment_id
                                                  ,pactid       => p_payroll_action_id
                                                  ,chunk        => p_chunk
                                                  );

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);

                           OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                       END IF;

                       IF (l_dummy IS NOT NULL)
                       THEN

                           pay_in_utils.set_location(g_debug,'Value of l_dummy is '|| l_dummy, 61);

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;

                           OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;
                           OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;
                           OPEN  c_chk_asg_action(g_sal_data_rec_add(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;

                  END LOOP;
           END IF;


           pay_in_utils.set_location(g_debug,'Inserting Asg Action ID for Updated Assignment Actions ' ,70);
           pay_in_utils.set_location(g_debug,'Value of g_count_sal_update is '|| g_count_sal_update, 71);
           IF ((g_count_sal_update > 1) AND (g_correction_mode <> 'Y'))
           THEN
                  FOR i IN 1..g_count_sal_update - 1
                  LOOP
                      l_24q_asg_action_id := NULL;
                      l_dummy             := NULL;

                      pay_in_utils.set_location(g_debug,'Checking for Assignment '|| g_sal_data_rec_upd(i).assignment_id,1);
                      pay_in_utils.set_location(g_debug,'Payroll Action id is ' || p_payroll_action_id,2);
                      OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,p_payroll_action_id);
                      FETCH c_chk_asg_action INTO l_dummy;
                      CLOSE c_chk_asg_action;


                      pay_in_utils.trace('l_dummy in g_count_sal_update ',l_dummy);

                       IF (l_dummy IS NULL)
                       THEN
                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO l_action_id
                             FROM dual;

                           pay_in_utils.set_location(g_debug,'Value of l_action_id is '|| l_action_id, 61);
                           pay_in_utils.set_location(g_debug,'Inserting Assignment action id ',61);

                            hr_nonrun_asact.insact(lockingactid => l_action_id
                                                  ,assignid     => g_sal_data_rec_upd(i).assignment_id
                                                  ,pactid       => p_payroll_action_id
                                                  ,chunk        => p_chunk
                                                  );

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);

                           OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;

                       IF (l_dummy IS NOT NULL)
                       THEN

                           pay_in_utils.set_location(g_debug,'Value of l_dummy is '|| l_dummy, 61);

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;

                           OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;
                           OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           l_lock_exists := 0;
                           OPEN  c_chk_asg_action(g_sal_data_rec_upd(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           OPEN  c_chk_action_lock(l_dummy,l_24q_asg_action_id);
                           FETCH c_chk_action_lock INTO l_lock_exists;
                           CLOSE c_chk_action_lock;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF ((l_24q_asg_action_id IS NOT NULL) AND (l_lock_exists=0))
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_dummy
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;

                  END LOOP;
           END IF;

           pay_in_utils.set_location(g_debug,'Asg Action ID Insertion Over for Salary Records ', 80);

           pay_in_utils.set_location(g_debug,'Archiving PL/SQL Data for Salary Records: archive_code ',90);

          --For C4,C5 only salary data should be Archived
           IF (g_correction_mode IN('C4','C5','%'))
           THEN
                   archive_salary_data(g_payroll_action_id,l_24q_locked_pay_id);
           END IF;

 END IF;
 --C4,C5 Salary Data Archival Ends
  pay_in_utils.set_location(g_debug,'Archival for C4,C5 Modes Ends : '||l_procedure,100);


    IF (g_action)
    THEN
           pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,110);

           pay_in_utils.set_location(g_debug,'Inserting assignment action id in pay_assignment_actions ',40);
           pay_in_utils.set_location(g_debug,'Inserting Asg Action ID for Deleted Element Entries ' ,50);

           pay_in_utils.set_location(g_debug,'Value of g_count_ee_delete is '|| g_count_ee_delete, 51);
           IF ((g_count_ee_delete > 1)AND (g_correction_mode <> 'Y'))
           THEN
                   FOR i IN 1..g_count_ee_delete - 1
                   LOOP
                      l_24q_asg_action_id := NULL;
                      l_dummy             := NULL;
                      OPEN  c_chk_asg_action(g_ee_data_rec_del(i).assignment_id,p_payroll_action_id);
                      FETCH c_chk_asg_action INTO l_dummy;
                      CLOSE c_chk_asg_action;

                       IF (l_dummy IS NULL)
                       THEN
                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO l_action_id
                             FROM dual;

                           pay_in_utils.set_location(g_debug,'Value of l_action_id is '|| l_action_id, 61);
                           pay_in_utils.set_location(g_debug,'Inserting Assignment action id ',61);

                            hr_nonrun_asact.insact(lockingactid => l_action_id
                                                  ,assignid     => g_ee_data_rec_del(i).assignment_id
                                                  ,pactid       => p_payroll_action_id
                                                  ,chunk        => p_chunk
                                                  );

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);

                           OPEN  c_chk_asg_action(g_ee_data_rec_del(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_ee_data_rec_del(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_ee_data_rec_del(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;
                  END LOOP;
           END IF;

           pay_in_utils.set_location(g_debug,'Inserting Asg Action ID for Added Element Entries ' ,60);
           pay_in_utils.set_location(g_debug,'Value of g_count_ee_addition is '|| g_count_ee_addition, 61);
           IF ((g_count_ee_addition > 1)AND(g_correction_mode <> 'Y'))
           THEN
                  FOR i IN 1..g_count_ee_addition - 1
                  LOOP
                      l_24q_asg_action_id := NULL;
                      l_dummy             := NULL;
                      OPEN  c_chk_asg_action(g_ee_data_rec_add(i).assignment_id,p_payroll_action_id);
                      FETCH c_chk_asg_action INTO l_dummy;
                      CLOSE c_chk_asg_action;

                      pay_in_utils.set_location(g_debug,'Value of l_dummy is '|| l_dummy, 61);
                       IF (l_dummy IS NULL)
                       THEN
                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO l_action_id
                             FROM dual;

                           pay_in_utils.set_location(g_debug,'Value of l_action_id is '|| l_action_id, 61);
                           pay_in_utils.set_location(g_debug,'Inserting Assignment action id ',61);

                            hr_nonrun_asact.insact(lockingactid => l_action_id
                                                  ,assignid     => g_ee_data_rec_add(i).assignment_id
                                                  ,pactid       => p_payroll_action_id
                                                  ,chunk        => p_chunk
                                                  );

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);

                           OPEN  c_chk_asg_action(g_ee_data_rec_add(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_ee_data_rec_add(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_ee_data_rec_add(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                       END IF;
                  END LOOP;
           END IF;

           pay_in_utils.set_location(g_debug,'Inserting Asg Action ID for Updated Element Entries ' ,70);
           pay_in_utils.set_location(g_debug,'Value of g_count_ee_update is '|| g_count_ee_update, 71);
           IF ((g_count_ee_update > 1)AND(g_correction_mode <> 'Y'))
           THEN
                  FOR i IN 1..g_count_ee_update - 1
                  LOOP
                      l_24q_asg_action_id := NULL;
                      l_dummy             := NULL;

                      pay_in_utils.set_location(g_debug,'Checking for Assignment '|| g_ee_data_rec_upd(i).assignment_id,1);
                      pay_in_utils.set_location(g_debug,'Payroll Action id is ' || p_payroll_action_id,2);
                      OPEN  c_chk_asg_action(g_ee_data_rec_upd(i).assignment_id,p_payroll_action_id);
                      FETCH c_chk_asg_action INTO l_dummy;
                      CLOSE c_chk_asg_action;

                      pay_in_utils.set_location(g_debug,'Value of dummy is ' || l_dummy ,3);
                       IF (l_dummy IS NULL)
                       THEN
                           SELECT pay_assignment_actions_s.NEXTVAL
                             INTO l_action_id
                             FROM dual;

                           pay_in_utils.set_location(g_debug,'Value of l_action_id is '|| l_action_id, 61);
                           pay_in_utils.set_location(g_debug,'Inserting Assignment action id ',61);

                            hr_nonrun_asact.insact(lockingactid => l_action_id
                                                  ,assignid     => g_ee_data_rec_upd(i).assignment_id
                                                  ,pactid       => p_payroll_action_id
                                                  ,chunk        => p_chunk
                                                  );

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Archival', 61);

                           OPEN  c_chk_asg_action(g_ee_data_rec_upd(i).assignment_id,l_24q_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                           pay_in_utils.set_location(g_debug,'Enforcing Locking on 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_ee_data_rec_upd(i).assignment_id,l_24qc_locked_pay_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;

                           pay_in_utils.set_location(g_debug,'Enforcing Locking on Previous 24Q Correction', 61);
                           l_24q_asg_action_id := NULL;
                           OPEN  c_chk_asg_action(g_ee_data_rec_upd(i).assignment_id,l_last_24qc_pay_act_id);
                           FETCH c_chk_asg_action INTO l_24q_asg_action_id;
                           CLOSE c_chk_asg_action;

                           pay_in_utils.trace('Value of l_locked_action_id for Previous 24Q Correction is ',l_24q_asg_action_id);

                           IF (l_24q_asg_action_id IS NOT NULL)
                           THEN
                                   hr_nonrun_asact.insint(lockingactid => l_action_id
                                                         ,lockedactid  => l_24q_asg_action_id
                                                         );
                           END IF;
                       END IF;
                  END LOOP;
           END IF;

           pay_in_utils.set_location(g_debug,'Asg Action ID Insertion Over ', 80);
           pay_in_utils.set_location(g_debug,'Archiving PL/SQL Data : archive_code ',90);

           --C2,C3 then archive only updated Challans, if C9 then only added challans
           IF (g_correction_mode NOT IN ('Y','C1'))
           THEN
                   archive_challan_data(g_payroll_action_id,l_24q_locked_pay_id);
           END IF;

           IF (g_correction_mode NOT IN ('C5','Y')) THEN
                pay_in_utils.set_location(g_debug,'Checking Org archival status',1);
                l_flag_number := -1;
                l_flag_number := check_archival_status(NULL,'IN_24QC_ORG',NULL,NULL);
                IF (l_flag_number = 0)
                THEN
                   archive_organization_data(g_payroll_action_id,l_24q_locked_pay_id);
                END IF;
           END IF;

            --For C3,C5,C9 only deductee data should be archived
           IF (g_correction_mode IN('C3','C5','C9','%'))
           THEN
                   archive_deductee_data(g_payroll_action_id,l_24q_locked_pay_id);
           END IF;

           pay_in_utils.set_location(g_debug,'Generating Locking...',1);
           --Inserting Assignment Actions and Locking if no deductee records exist for this archival.
           IF ((g_count_ee_delete = 1) AND (g_count_ee_addition = 1) AND (g_count_ee_update = 1))
           THEN
                        pay_in_utils.set_location(g_debug,'Generating Locking...',2);
                        pay_in_utils.set_location(g_debug,'p_payroll_action_id ' || p_payroll_action_id ,1);
                        pay_in_utils.set_location(g_debug,'l_24q_locked_pay_id ' || l_24q_locked_pay_id ,1);
                        pay_in_utils.set_location(g_debug,'l_24qc_locked_pay_id' || l_24qc_locked_pay_id,1);
                        generate_locking(p_payroll_action_id,l_24q_locked_pay_id,l_24qc_locked_pay_id,p_chunk);
           END IF;

           g_action := FALSE;

           IF (g_correction_mode =  'C5')
           THEN
              archive_c5_data_only(p_payroll_action_id);
           END IF;

           IF (g_debug)
           THEN
                trace_pl_sql_table_data();
           END IF;

    END IF;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,100);

  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END assignment_action_code;

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
  -- 115.0 13-Mar-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE archive_code (p_assignment_action_id  IN NUMBER
                         ,p_effective_date        IN DATE
                         )
  IS
  BEGIN
        NULL;
  END archive_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : DEINITIALIZATION_CODE                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    :                                                     --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id          NUMBER                 --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    abhjain    Initial Version                      --
  -- 115.1 07-Feb-2007    rpalli     5754018 :24QC Quarter4 Stat Update   --
  --------------------------------------------------------------------------
  PROCEDURE deinitialization_code (p_payroll_action_id IN NUMBER)
  IS
   CURSOR cur_org_recs(p_payroll_action_id NUMBER)
   IS
   SELECT DECODE(action_information15, 1, 'C1')
         ,action_information_id
         ,object_version_number
         ,action_information29
     FROM pay_action_information
    WHERE action_information1 = g_gre_id
      AND action_information3 = g_year||g_quarter
      AND action_context_type = 'PA'
      AND action_information_category = 'IN_24QC_ORG'
      AND action_context_id = p_payroll_action_id;

   CURSOR cur_challan_recs(p_payroll_action_id NUMBER)
    IS
    SELECT action_information1 challan
        ,DECODE(action_information18, 'U', 'C2', 'A', 'C9', 'NC', null) correction_type
        ,action_information_id
        ,object_version_number
    FROM pay_action_information
   WHERE action_information3 = g_gre_id
     AND action_information2 = g_year||g_quarter
     AND action_context_type = 'PA'
     AND action_information_category = 'IN_24QC_CHALLAN'
     AND action_context_id = p_payroll_action_id;

   CURSOR cur_deductee_recs(p_payroll_action_id NUMBER
                           ,p_challan_number    VARCHAR2)
    IS
    SELECT 'C3' correction_type
      FROM pay_action_information pai
     WHERE pai.action_context_id IN (SELECT assignment_action_id
                                       FROM pay_assignment_actions
                                      WHERE payroll_action_id = p_payroll_action_id
                                        AND assignment_id     = pai.assignment_id
                                    )
     AND action_context_type = 'AAP'
     AND action_information_category = 'IN_24QC_DEDUCTEE'
     AND action_information3 = g_gre_id
     AND action_information2 = g_year||g_quarter
     AND action_information15 IN ('U', 'A', 'D')
     AND (
            (    action_information19 IS NULL
             AND action_information20 IS NULL
            )
            OR
            (    (INSTR(action_information19,'C3') <> 0)
            )
         )
     AND action_information1 = p_challan_number;

   CURSOR cur_c5_deductee_recs(p_payroll_action_id NUMBER
                           ,p_challan_number    VARCHAR2)
    IS
    SELECT 'C5' correction_type
      FROM pay_action_information pai
     WHERE pai.action_context_id IN ( SELECT assignment_action_id
                                        FROM pay_assignment_actions
                                       WHERE payroll_action_id = p_payroll_action_id
                                         AND assignment_id     = pai.assignment_id
                                    )
     AND action_context_type = 'AAP'
     AND action_information_category = 'IN_24QC_DEDUCTEE'
     AND action_information3 = g_gre_id
     AND action_information2 = g_year||g_quarter
     AND INSTR(action_information19,'C5') <> 0
     AND action_information20 IS NOT NULL
     AND action_information1 = p_challan_number;

   CURSOR cur_c5_salary_recs(p_payroll_action_id NUMBER
                           ,p_person_id    NUMBER)
    IS
    SELECT 'C5' correction_type
      FROM pay_action_information pai
     WHERE pai.action_context_id IN ( SELECT assignment_action_id
                                        FROM pay_assignment_actions
                                       WHERE payroll_action_id = p_payroll_action_id
                                         AND assignment_id     = pai.assignment_id
                                    )
     AND action_context_type = 'AAP'
     AND action_information_category = 'IN_24QC_PERSON'
     AND action_information3 = g_gre_id
     AND action_information2 = g_year||g_quarter
     AND INSTR(action_information11,'C5') <> 0
     AND action_information1 = p_person_id;

   CURSOR cur_c4_salary_recs(p_payroll_action_id NUMBER
                           ,p_person_id    NUMBER)
    IS
    SELECT 'C4' correction_type
      FROM pay_action_information pai
     WHERE pai.action_context_id IN ( SELECT assignment_action_id
                                        FROM pay_assignment_actions
                                       WHERE payroll_action_id = p_payroll_action_id
                                         AND assignment_id     = pai.assignment_id
                                    )
     AND action_context_type = 'AAP'
     AND action_information_category = 'IN_24QC_PERSON'
     AND action_information3 = g_gre_id
     AND action_information2 = g_year||g_quarter
     AND INSTR(action_information11,'C4') <> 0
     AND action_information1 = p_person_id;

 CURSOR cur_salary_update_recs
  IS
SELECT DISTINCT action_information3          gre_id
  FROM pay_action_information
 WHERE action_information_category = 'IN_24QC_PERSON'
   AND action_context_type         = 'AAP'
   AND action_information10        = 'A'
   AND action_information11        = 'C4'
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id)
   ORDER BY action_information3;


 CURSOR cur_person_update_recs( p_gre_id VARCHAR2)
  IS
SELECT DISTINCT action_information1 person_id
     , source_id
     , action_information_id
     , object_version_number
  FROM pay_action_information
 WHERE action_information_category = 'IN_24QC_PERSON'
   AND action_context_type         = 'AAP'
   AND action_information3 = fnd_number.canonical_to_number(p_gre_id)
   AND action_information10 = 'A'
   AND action_information11 = 'C4'
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id)
   ORDER BY  LENGTH(action_information1)
            ,action_information1
            ,source_id;

 CURSOR cur_min_salary_record( p_gre_id VARCHAR2)
  IS
SELECT MIN(fnd_number.canonical_to_number(action_information12)) min_salary_rec
  FROM pay_action_information
 WHERE action_information_category = 'IN_24QC_PERSON'
   AND action_context_type         = 'AAP'
   AND action_information3 = fnd_number.canonical_to_number(p_gre_id)
   AND action_information10 = 'A'
   AND action_information11 = 'C4'
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id);


CURSOR cur_salary_recs(p_payroll_action_id NUMBER)
  IS
SELECT DISTINCT action_information1 person_id
  FROM pay_action_information pai
 WHERE action_information_category = 'IN_24QC_PERSON'
   AND action_context_type         = 'AAP'
   AND action_context_id IN (SELECT assignment_action_id
                               FROM pay_assignment_actions
                              WHERE payroll_action_id = p_payroll_action_id
                                AND assignment_id     = pai.assignment_id)
   AND action_information3 = g_gre_id
   AND action_information2 = g_year||g_quarter;

    CURSOR c_24q_ee_sum(p_challan_number       VARCHAR2
                        ,p_24q_pay_action_id   NUMBER
                       )
    IS
        SELECT SUM(NVL(pai.action_information9,0)) amount_deposited
          FROM pay_action_information  pai
              ,pay_assignment_actions  paa
         WHERE pai.action_information_category = 'IN_24Q_DEDUCTEE'
           AND paa.assignment_action_id        = pai.action_context_id
           AND pai.action_information1         = p_challan_number
           AND paa.payroll_action_id           = p_24q_pay_action_id;

     TYPE t_challan_data IS RECORD
       ( challan_no            hr_organization_information.org_information1%TYPE
        ,correction_type       VARCHAR2(100)
        ,action_information_id NUMBER
        ,object_version_number NUMBER
       );

      TYPE t_challan_data_tab IS TABLE OF t_challan_data
      INDEX BY binary_integer;
      t_challan_nos t_challan_data_tab;

      l_index             NUMBER ;
      l_correction_type   VARCHAR2(100);
      org_correction_type VARCHAR2(100);
      l_org_update_string VARCHAR(2400);
      l_action_info_id    NUMBER;
      l_ovn               NUMBER;
      l_y_flag            VARCHAR2(10);
      l_last_sum          VARCHAR2(250);
      l_procedure         VARCHAR2(100);
      l_message           VARCHAR2(300);
  BEGIN

     l_procedure := g_package ||'.deinitialization_code';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     IF (g_correction_mode =  'C5')
     THEN
        RETURN;
     END IF;

    OPEN  cur_org_recs(p_payroll_action_id);
    FETCH cur_org_recs INTO org_correction_type, l_action_info_id, l_ovn, l_y_flag;
    CLOSE cur_org_recs;

    IF (l_y_flag IS NOT NULL)
    THEN
       RETURN;
    END IF;

    pay_in_utils.set_location(g_debug,'Checking in Challans...',2);
    FOR i IN  cur_challan_recs(p_payroll_action_id) LOOP
      l_index                                      := nvl(l_index, 0) + 1;
      t_challan_nos(l_index).challan_no            := i.challan;
      t_challan_nos(l_index).correction_type       := i.correction_type;
      t_challan_nos(l_index).action_information_id := i.action_information_id;
      t_challan_nos(l_index).object_version_number := i.object_version_number;

      l_correction_type := null;

      OPEN  cur_deductee_recs(p_payroll_action_id, t_challan_nos(l_index).challan_no);
      FETCH cur_deductee_recs INTO l_correction_type;
      CLOSE cur_deductee_recs;

      IF nvl(t_challan_nos(l_index).correction_type, 'C2') = 'C2'  AND l_correction_type = 'C3' THEN
         t_challan_nos(l_index).correction_type := 'C3';
      END IF;

      OPEN  cur_c5_deductee_recs(p_payroll_action_id, t_challan_nos(l_index).challan_no);
      FETCH cur_c5_deductee_recs INTO l_correction_type;
      CLOSE cur_c5_deductee_recs;

      IF NVL(t_challan_nos(l_index).correction_type, '%') <> 'C9' AND l_correction_type = 'C5' THEN
         IF t_challan_nos(l_index).correction_type IS NULL THEN
            t_challan_nos(l_index).correction_type := 'C5';
         ELSE
            t_challan_nos(l_index).correction_type := t_challan_nos(l_index).correction_type||':C5';
         END IF;
      END IF;

      pay_in_utils.set_location(g_debug,'Updating API called for Challan ', 3);
      pay_action_information_api.update_action_information
                (p_validate                       =>  FALSE
                ,p_action_information_id          =>  t_challan_nos(l_index).action_information_id
                ,p_object_version_number          =>  t_challan_nos(l_index).object_version_number
                ,p_action_information29           =>  t_challan_nos(l_index).correction_type
                );
      pay_in_utils.set_location(g_debug,'Updating API successful for Challan ', 3);
      l_org_update_string := NVL(l_org_update_string, '1') ||':'||t_challan_nos(l_index).correction_type;

    END LOOP;

    pay_in_utils.set_location(g_debug,'Checked Challans...',2);


    pay_in_utils.set_location(g_debug,'Updating SD Record Number for A mode in Salary Records : ',3);

    l_index := 0;
    FOR c_salary_rec IN cur_salary_update_recs
    LOOP
      OPEN cur_min_salary_record(c_salary_rec.gre_id);
      FETCH cur_min_salary_record INTO l_index;
      CLOSE cur_min_salary_record;
    pay_in_utils.set_location(g_debug,'l_index...',1);
    pay_in_utils.set_location(g_debug,'c_salary_rec.gre_id...',c_salary_rec.gre_id);

      FOR cur_rec IN cur_person_update_recs(c_salary_rec.gre_id)
      LOOP
               pay_action_information_api.update_action_information
                (p_validate                       => FALSE
                ,p_action_information_id          => cur_rec.action_information_id
                ,p_object_version_number          => cur_rec.object_version_number
                ,p_action_information12           => l_index
                );
               l_index := l_index + 1;
    pay_in_utils.set_location(g_debug,'l_index...',2);
    pay_in_utils.set_location(g_debug,'l_index...',2);
      END LOOP;
    END LOOP;

    pay_in_utils.set_location(g_debug,'Updated SD Record Number for A mode in Salary Records : ',3);

    pay_in_utils.set_location(g_debug,'Checking in Salary Records...',3);

    FOR i IN cur_salary_recs(p_payroll_action_id) LOOP

      OPEN  cur_c5_salary_recs(p_payroll_action_id, i.person_id);
      FETCH cur_c5_salary_recs INTO l_correction_type;
      CLOSE cur_c5_salary_recs;

      IF l_correction_type = 'C5' THEN
       l_org_update_string := NVL(l_org_update_string, '1') ||':'||l_correction_type;
      END IF;

      OPEN  cur_c4_salary_recs(p_payroll_action_id, i.person_id);
      FETCH cur_c4_salary_recs INTO l_correction_type;
      CLOSE cur_c4_salary_recs;

      IF l_correction_type = 'C4' THEN
       l_org_update_string := NVL(l_org_update_string, '1') ||':'||l_correction_type;
      END IF;

    END LOOP;

    pay_in_utils.set_location(g_debug,'Checked Salary Records...',3);

    IF INSTR(l_org_update_string, 'C2') <> 0 THEN
       IF org_correction_type is null or org_correction_type = 'C1' THEN
          org_correction_type := 'C2';
       ELSE
          org_correction_type := org_correction_type || ':C2';
       END IF;
    END IF;
    IF INSTR(l_org_update_string, 'C3') <> 0 THEN
       IF org_correction_type IS NULL OR org_correction_type = 'C1' THEN
          org_correction_type := 'C3';
       ELSE
          org_correction_type := org_correction_type || ':C3';
       END IF;
    END IF;
    IF INSTR(l_org_update_string, 'C4') <> 0 THEN
       IF org_correction_type IS NULL THEN
          org_correction_type := 'C4';
       ELSE
          org_correction_type := org_correction_type || ':C4';
       END IF;
    END IF;
    IF INSTR(l_org_update_string, 'C5') <> 0 THEN
       IF org_correction_type IS NULL THEN
          org_correction_type := 'C5';
       ELSE
          org_correction_type := org_correction_type || ':C5';
       END IF;
    END IF;
    IF INSTR(l_org_update_string, 'C9') <> 0 THEN
       IF org_correction_type IS NULL THEN
          org_correction_type := 'C9';
       ELSE
          org_correction_type := org_correction_type || ':C9';
       END IF;
    END IF;


     pay_in_utils.set_location(g_debug,'Updating API called for Org ', 3);
     pay_action_information_api.update_action_information
               (p_validate                       =>  FALSE
               ,p_action_information_id          =>  l_action_info_id
               ,p_object_version_number          =>  l_ovn
               ,p_action_information29           =>  org_correction_type
               );
     pay_in_utils.set_location(g_debug,'Updating API successful for Org ', 3);
     pay_in_utils.set_location(g_debug,'Leaving: '|| g_package||'.deinitialization_code',1);

  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
  END deinitialization_code;


END pay_in_24qc_archive;

/
