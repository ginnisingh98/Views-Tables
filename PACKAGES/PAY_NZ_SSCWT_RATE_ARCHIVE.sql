--------------------------------------------------------
--  DDL for Package PAY_NZ_SSCWT_RATE_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_SSCWT_RATE_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: paynzssc.pkh 120.0.12000000.1 2007/01/17 14:29:16 appldev noship $ */

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
  --                  Here it fetches and stores defined balnce ids,      --
  --                  element type ids and element input value ids.       --
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
  -- Description    : This procedure is actually used to archive data .   --
  --                  This procedure archives details of an employee's    --
  --                  SSCWT Rates. It archives details of all employees   --
  --                  selected by assignment_action_code                  --
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
  -- Name           : DEINITIALIZE_CODE                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to submit request for        --
  --                  SSCWT Report to run.                                --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --------------------------------------------------------------------------
  --
  PROCEDURE deinitialize_code
    (
      p_payroll_action_id    IN  NUMBER
    );
  --


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : PERIODS_IN_SPAN                                     --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function returns the number of periods for which    --
  --                  the payroll is run for a given assignment and given --
  --                  period.                                             --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_start_date           DATE                         --
  --                  p_start_date           DATE                         --
  --            p_assignment_id     per_assignments_f.assignment_id%TYPE  --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 22-JAN-2004    sshankar   Initial Version                      --
  --                                                                      --
  --------------------------------------------------------------------------
  --
  FUNCTION periods_in_span
         ( p_start_date IN DATE
         , p_end_date   IN DATE
         , p_assignment_id IN per_assignments_f.assignment_id%TYPE)
  RETURN NUMBER;
  --


END pay_nz_sscwt_rate_archive;

 

/
