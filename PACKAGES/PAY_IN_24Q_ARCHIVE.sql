--------------------------------------------------------
--  DDL for Package PAY_IN_24Q_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_24Q_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyin24qa.pkh 120.3.12010000.1 2008/07/27 22:52:12 appldev ship $ */
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

  TYPE t_input_value_rec IS RECORD
        (input_value_id pay_input_values_f.input_value_id%TYPE);

  TYPE t_input_table_type IS TABLE OF  t_input_value_rec
    INDEX BY binary_integer;

  g_input_table_rec t_input_table_type;

  g_package              CONSTANT VARCHAR2(100) := 'pay_in_24q_archive';
  g_debug                BOOLEAN;

  g_tax_year             VARCHAR2(20);
  g_year                 VARCHAR2(20);
  g_gre_id               VARCHAR2(20);
  g_quarter              VARCHAR2(2);
  g_archive_ref_no       VARCHAR2(50);
  g_bg_id                NUMBER;
  g_start_date           DATE;
  g_fin_start_date       DATE;
  g_fin_end_date         DATE;
  g_qr_start_date        DATE;
  g_end_date             DATE;

  g_payroll_action_id    NUMBER;
  g_session_date         DATE;
  g_chln_element_id      NUMBER;
  g_index                NUMBER;

  g_asg_tab              t_asg_tab;

  -------------------------------------------------------------------------
  -- These are PUBLIC procedures that are required by the Archive process.
  -- There names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------------

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
  --

  PROCEDURE range_code
    (
      p_payroll_action_id    IN  NUMBER
     ,p_sql                  OUT NOCOPY VARCHAR2
    );
  --

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
  --------------------------------------------------------------------------
  --
  PROCEDURE initialization_code
    (
      p_payroll_action_id    IN  NUMBER
    );
  --

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
  --

  PROCEDURE assignment_action_code
    (
      p_payroll_action_id    IN  NUMBER
     ,p_start_person         IN  NUMBER
     ,p_end_person           IN  NUMBER
     ,p_chunk                IN  NUMBER
    );
  --

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
  --

  PROCEDURE archive_code
    (
      p_assignment_action_id IN  NUMBER
     ,p_effective_date       IN  DATE
    );

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : DEINITIALIZATION_CODE                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to call the internal procedures to        --
  --                  actually archive the data.                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id       NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --------------------------------------------------------------------------
PROCEDURE deinitialization_code
   (
    p_payroll_action_id IN number
   );


END pay_in_24q_archive;

/
