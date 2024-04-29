--------------------------------------------------------
--  DDL for Package PAY_IN_24QC_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_24QC_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyin24qc.pkh 120.1.12010000.2 2009/11/04 05:45:25 mdubasi ship $ */

     TYPE t_org_data_rec  IS RECORD
     (gre_id                   NUMBER
     ,last_action_context_id   NUMBER
     );

    TYPE t_org_data_tab_type IS TABLE OF  t_org_data_rec
    INDEX BY binary_integer;

    TYPE t_element_entry_rec IS RECORD
     (assignment_id            NUMBER
     ,element_entry_id         NUMBER
     ,deductee_mode            VARCHAR2(5)
     ,last_action_context_id   NUMBER
     );

    TYPE t_element_entry_data_rec IS TABLE OF  t_element_entry_rec
    INDEX BY binary_integer;

    TYPE t_salary_rec IS RECORD
     (assignment_id            NUMBER
     ,source_id                NUMBER
     ,salary_mode              VARCHAR2(5)
     ,last_action_context_id   NUMBER
     );

    TYPE t_salary_data_rec IS TABLE OF  t_salary_rec
    INDEX BY binary_integer;

  TYPE t_asg_rec IS RECORD
         (gre_id       NUMBER
         ,start_date   DATE
         ,end_date     DATE
         );

  TYPE t_asg_tab IS TABLE OF t_asg_rec
    INDEX BY BINARY_INTEGER;

  TYPE t_bal_name_rec IS RECORD
   (
        balance_name VARCHAR2(240)
   );

  TYPE t_bal_name_tab IS TABLE OF t_bal_name_rec
    INDEX BY BINARY_INTEGER;

  g_asg_tab              t_asg_tab;
  g_fin_start_date       DATE;
  g_fin_end_date         DATE;

type t_balance_value_rec is record
(
balance_name VARCHAR2(240),
balance_value NUMBER
);

  TYPE t_balance_value_tab IS TABLE OF t_balance_value_rec
    INDEX BY BINARY_INTEGER;


   TYPE t_challan_entry_rec IS RECORD
     (transfer_voucher_number   VARCHAR2(240)
     ,transfer_voucher_date     VARCHAR2(240)
     ,amount                    VARCHAR2(240)
     ,surcharge                 VARCHAR2(240)
     ,education_cess            VARCHAR2(240)
     ,interest                  VARCHAR2(240)
     ,other                     VARCHAR2(240)
     ,bank_branch_code          VARCHAR2(240)
     ,cheque_dd_num             VARCHAR2(240)
     ,org_information_id        NUMBER
     ,modes                     VARCHAR2(5)
     ,book_entry                VARCHAR2(240)
     );

    TYPE t_challan_data_rec IS TABLE OF  t_challan_entry_rec
    INDEX BY binary_integer;

    TYPE t_screen_entry_value_rec IS RECORD
      (
       challan_number              VARCHAR2(240)
      ,payment_date                VARCHAR2(240)
      ,amount_deposited            VARCHAR2(240)
      ,surcharge                   VARCHAR2(240)
      ,education_cess              VARCHAR2(240)
      ,income_tax                  VARCHAR2(240)
      ,taxable_income              VARCHAR2(240)
      );

    TYPE t_screen_entry_table_data IS TABLE OF t_screen_entry_value_rec
    INDEX BY binary_integer;

    TYPE t_person_data_rec IS RECORD
      (person_id        per_all_people_f.person_id%TYPE
      ,pan_number       per_all_people_f.per_information14%TYPE
      ,pan_ref_number   per_all_people_f.per_information14%TYPE
      ,full_name        per_all_people_f.full_name%TYPE
      ,tax_rate         per_assignment_extra_info.aei_information2 %TYPE
      );

    TYPE t_person_record IS TABLE OF t_person_data_rec
    INDEX BY binary_integer;

    TYPE t_person_data_sal_rec IS RECORD
      (person_id        per_all_people_f.person_id%TYPE
      ,pan_number       per_all_people_f.per_information14%TYPE
      ,pan_ref_number   per_all_people_f.per_information14%TYPE
      ,full_name        per_all_people_f.full_name%TYPE
      ,start_date       DATE
      ,end_date         DATE
      );

    TYPE t_person_sal_record IS TABLE OF t_person_data_sal_rec
    INDEX BY binary_integer;

    g_ee_data_rec_del               t_element_entry_data_rec;
    g_ee_data_rec_add               t_element_entry_data_rec;
    g_ee_data_rec_upd               t_element_entry_data_rec;
    g_challan_data_add              t_challan_data_rec;
    g_challan_data_upd              t_challan_data_rec;
    g_challan_data_noc              t_challan_data_rec;
    g_org_data                      t_org_data_tab_type;

    g_payroll_action_id             NUMBER;
    g_24q_payroll_act_id            NUMBER;
    g_24qc_payroll_act_id           NUMBER;
    g_chln_element_id               NUMBER;
    g_count_ee_delete               NUMBER := 1;
    g_count_ee_addition             NUMBER := 1;
    g_count_ee_update               NUMBER := 1;
    g_count_challan_add             NUMBER := 1;
    g_count_challan_upd             NUMBER := 1;
    g_count_challan_noc             NUMBER := 1;
    g_count_org                     NUMBER := 1;

    g_qr_start_date                 DATE;
    g_start_date                    DATE;
    g_end_date                      DATE;
    g_qr_end_date                   DATE;
    g_session_date                  DATE;

    g_correction_mode               VARCHAR2(5);
    g_24qc_empr_change              VARCHAR2(5);
    g_24qc_rep_adr_chg              VARCHAR2(5);
    g_quarter                       VARCHAR2(5);
    g_tax_year                      VARCHAR2(20);
    g_year                          VARCHAR2(20);
    g_gre_id                        VARCHAR2(20);
    g_cancel_ref_number             VARCHAR2(250);
    g_24qc_reference                VARCHAR2(250);
    g_regular_file_date             VARCHAR2(15);
    g_old_format                    Varchar2(1);
    g_package                       CONSTANT VARCHAR2(100) := 'pay_in_24qc_archive';

     g_count_sal_delete               NUMBER := 1;
     g_count_sal_addition             NUMBER := 1;
     g_count_sal_update               NUMBER := 1;

    g_sal_data_rec_del               t_salary_data_rec;
    g_sal_data_rec_add               t_salary_data_rec;
    g_sal_data_rec_upd               t_salary_data_rec;


    g_debug                         BOOLEAN;
    g_action                        BOOLEAN := TRUE;
    g_sal_action                    BOOLEAN := TRUE;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CHECK_C5_CHANGE_ONLY                                --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function is used to determine C5 change        --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_element_entry_id                                  --
  --                : p_action_context_id                                 --
  --                : p_assignment_id                                     --
  --            OUT : BOOLEAN                                             --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 5-Jan-2006     aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  FUNCTION check_c5_change_only
    (
      p_element_entry_id   IN  NUMBER
     ,p_action_context_id  IN  NUMBER
     ,p_assignment_id      IN  NUMBER
    )
  RETURN BOOLEAN;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : REMOVE_CURR_FORMAT                                  --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
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
  -- 115.0 5-Jan-2006     aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  FUNCTION remove_curr_format(p_value IN VARCHAR2)
  RETURN VARCHAR2;

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
                        ,p_segment_num    IN NUMBER
                        )
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
  --------------------------------------------------------------------------
  PROCEDURE range_code
    (
      p_payroll_action_id    IN  NUMBER
     ,p_sql                  OUT NOCOPY VARCHAR2
    );

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
  --------------------------------------------------------------------------
  PROCEDURE initialization_code
    (
      p_payroll_action_id  IN  NUMBER
    );

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_ACTION_CODE                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure further restricts the assignment_id's--
  --                  returned by range_code                              --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --                  p_start_person         NUMBER                       --
  --                  p_end_person           NUMBER                       --
  --                  p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --------------------------------------------------------------------------
  PROCEDURE assignment_action_code
    (
      p_payroll_action_id    IN  NUMBER
     ,p_start_person         IN  NUMBER
     ,p_end_person           IN  NUMBER
     ,p_chunk                IN  NUMBER
    );

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_END_DATE                                 --
  -- Type           : FUNCTION                                            --
  -- Access         : Private                                             --
  -- Description    : This function returns the end date of an assignment --
  --                : subjected to Quarter end date                       --
  -- Parameters     :                                                     --
  --             IN : p_assignment_id NUMBER                              --
  --            OUT : p_end_date      DATE                                --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 13-Mar-2006    aaagarwa  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION assignment_end_date(p_assignment_id IN  NUMBER
                              )
  RETURN DATE;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CODE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to call the internal procedures to        --
  --                  actually archive the data.                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id    NUMBER                    --
  --                  p_effective_date          DATE                      --
  --            OUT : N/A                                                 --
  --------------------------------------------------------------------------
  PROCEDURE archive_code
    (
      p_assignment_action_id IN  NUMBER
     ,p_effective_date       IN  DATE
    );

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : DEINITIALIZATION_CODE                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    :                                                     --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id          NUMBER                 --
  --                                                                      --
  --            OUT : N/A                                                 --
  --------------------------------------------------------------------------
  PROCEDURE deinitialization_code(p_payroll_action_id IN NUMBER);

END pay_in_24qc_archive;

/
