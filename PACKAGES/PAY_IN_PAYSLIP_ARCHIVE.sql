--------------------------------------------------------
--  DDL for Package PAY_IN_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyinparc.pkh 120.0.12010000.2 2008/11/18 12:04:18 mdubasi ship $ */

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
  -- Description    : This procedure is used to set global contexts       --
  --                  Here It is used to archive the data at payroll      --
  --                  action level.                                       --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
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
  -- Description    : This procedure is actually used to archive data . It--
  --                  internally calls private procedures to archive      --
  --                  balances,employee details, employer details,        --
  --                  elements,absences and accruals etc.                 --
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
  --



 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_FORM_DATA                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the data required for form  --
  --                  3A and form 6A                                      --
  -- Parameters     :                                                     --
  --             IN :      p_assignment_action_id   NUMBER                --
  --                       p_payroll_action_id      NUMBER                --
  --                       p_run_payroll_action_id  NUMBER                --
  --                       p_archive_action_id      NUMBER                --
  --                       p_assignment_id          NUMBER                --
  --                       p_payroll_date           DATE                  --
  --                       p_prepayment_date        DATE                  --
  --                                                                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
  -- 115.1 01-Mar-2005    aaagawra   Changes done for incorporating PA data-
  -- 115.2 31-Mar-2005    lnagaraj   New parameter p_run_payroll_action_id
  --------------------------------------------------------------------------
PROCEDURE archive_form_data
    (
      p_assignment_action_id IN  NUMBER
     ,p_payroll_action_id    IN  NUMBER
     ,p_run_payroll_action_id IN NUMBER
     ,p_archive_action_id    IN  NUMBER
     ,p_assignment_id        IN  NUMBER
     ,p_payroll_date         IN  DATE
     ,p_prepayment_date      IN  DATE
    );

--------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_ESI_DATA                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure archives the data required for form 6--
  -- Parameters     :                                                     --
  --             IN :      p_assignment_action_id   NUMBER                --
  --                       p_payroll_action_id      NUMBER                --
  --                       p_archive_action_id      NUMBER                --
  --                       p_assignment_id          NUMBER                --
  --                       p_payroll_date           DATE                  --
  --                       p_prepayment_date        DATE                  --
  --                                                                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 07-Mar-2005    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE archive_esi_data
    (
      p_assignment_action_id IN  NUMBER
     ,p_payroll_action_id    IN  NUMBER
     ,p_archive_action_id    IN  NUMBER
     ,p_assignment_id        IN  NUMBER
     ,p_payroll_date         IN  DATE
     ,p_prepayment_date      IN  DATE
     );

  --
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETER                                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function returns payroll id of corresponding   --
  --                  payroll action id.                                  --
  -- Parameters     :                                                     --
  --             IN : p_name             VARCHAR2			  --
  --                  p_leg_parameters   VARCHAR2                         --
  --         Returns:                    VARCHAR2                         --
  --------------------------------------------------------------------------
  --

    FUNCTION get_parameter
     (
        p_name        IN VARCHAR2,
        p_leg_parameters IN VARCHAR2
     )  RETURN VARCHAR2;

END pay_in_payslip_archive;

/
