--------------------------------------------------------
--  DDL for Package PAY_IN_PF_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_PF_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyinmpfa.pkh 120.0.12010000.1 2008/07/27 22:53:41 appldev ship $ */

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
  --                                                                      --
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
  --                  returned by range_code.                             --
  --                  It filters the assignments selected by range_code   --
  --                  procedure.                                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --                  p_start_person         NUMBER                       --
  --                  p_end_person           NUMBER                       --
  --                  p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
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
  --                  actually archive the data. The procedures           --
  --                  called are                                          --
  --                    archive_pf_balances                               --
  --                    archive_pf_emp_dtls                               --
  --                    archive_pf_org_dtls                               --
  --                    archive_pf_challan_dtls                           --
  --                    archive_pf_7Q_dtls                                --
  --                    archive_pf_misc_dtls                              --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id       NUMBER                 --
  --                  p_effective_date             DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --------------------------------------------------------------------------
  --

  PROCEDURE archive_code
    (
      p_assignment_action_id IN  NUMBER
     ,p_effective_date       IN  DATE
    );
  --




END pay_in_pf_archive;

/
