--------------------------------------------------------
--  DDL for Package PAY_IN_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_SOE" AUTHID CURRENT_USER AS
/* $Header: pyinsoe.pkh 120.0.12010000.5 2010/02/19 05:36:06 mdubasi ship $ */

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_TEMPLATE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure gets the payslip template code set at--
  --                  organization level.If no template is set default    --
  --                  template code is returned                           --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id    NUMBER                       --
  --            OUT : p_template             VARCHAR2                     --
  --------------------------------------------------------------------------
  --

  PROCEDURE get_template (
                          p_business_group_id    IN  NUMBER
                         ,p_template             OUT NOCOPY VARCHAR2
                         );

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : FETCH_XML                                           --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns the next CLOB available in   --
  --                  global CLOB array                                   --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : N/A                                                 --
  --            OUT : p_clob                 CLOB                         --
  --------------------------------------------------------------------------
  --
  PROCEDURE fetch_xml (
                       p_clob    OUT NOCOPY CLOB
                      );
  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EMP_ADDRESS                                     --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function returns Emp Address                   --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_person_id           NUMBER                        --
  --             IN : p_date                DATE                          --
  --------------------------------------------------------------------------
  --
  FUNCTION get_emp_address(p_person_id     NUMBER
                           ,p_date          DATE   )
  RETURN VARCHAR2;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EMP_EMAIL                                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function returns Employee Email ID             --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assign_action_id           NUMBER                 --
  --------------------------------------------------------------------------
  --
  FUNCTION get_emp_email(p_assign_action_id NUMBER)
  RETURN VARCHAR2 ;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : SUBMIT_REQ_XML_BURST                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                             --
  -- Description    : This function submits the CP XDOBURSTREP to burst   --
  --                  XML                                                 --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_request_id          NUMBER                        --
  --------------------------------------------------------------------------
  --
  PROCEDURE submit_req_xml_burst(p_request_id IN NUMBER);

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : LOAD_XML                                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure makes a list of XMLs in a global     --
  --                  CLOB array                                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id     NUMBER                      --
  --                  p_start_date            VARCHAR2                    --
  --                  p_end_date              VARCHAR2                    --
  --                  p_payroll_id            NUMBER                      --
  --                  p_consolidation_set_id  NUMBER                      --
  --                  p_assignment_set_id     NUMBER                      --
  --                  p_employee_number       NUMBER                      --
  --                  p_sort_order1           VARCHAR2                    --
  --                  p_sort_order2           VARCHAR2                    --
  --                  p_sort_order3           VARCHAR2                    --
  --                  p_sort_order4           VARCHAR2                    --
  --            OUT : p_clob_cnt              NUMBER                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE load_xml (
                      p_business_group_id    IN NUMBER
                     ,p_start_date           IN VARCHAR2
                     ,p_end_date             IN VARCHAR2
                     ,p_payroll_id           IN NUMBER   DEFAULT NULL
                     ,p_consolidation_set_id IN NUMBER   DEFAULT NULL
                     ,p_assignment_set_id    IN NUMBER   DEFAULT NULL
                     ,p_employee_number      IN NUMBER   DEFAULT NULL
                     ,p_sort_order1          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order2          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order3          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order4          IN VARCHAR2 DEFAULT NULL
                     ,p_clob_cnt             OUT NOCOPY NUMBER
                     );

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : LOAD_XML_BURST                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure makes a list of XMLs in a global     --
  --                  CLOB for xml burst                                  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id     NUMBER                      --
  --                  p_start_date            VARCHAR2                    --
  --                  p_end_date              VARCHAR2                    --
  --                  p_payroll_id            NUMBER                      --
  --                  p_consolidation_set_id  NUMBER                      --
  --                  p_assignment_set_id     NUMBER                      --
  --                  p_employee_number       NUMBER                      --
  --                  p_sort_order1           VARCHAR2                    --
  --                  p_sort_order2           VARCHAR2                    --
  --                  p_sort_order3           VARCHAR2                    --
  --                  p_sort_order4           VARCHAR2                    --
  --            OUT : p_xml                   CLOB                        --
  --------------------------------------------------------------------------

PROCEDURE load_xml_burst (
                      p_business_group_id    IN NUMBER
                     ,p_start_date           IN VARCHAR2
                     ,p_end_date             IN VARCHAR2
                     ,p_payroll_id           IN NUMBER   DEFAULT NULL
                     ,p_consolidation_set_id IN NUMBER   DEFAULT NULL
                     ,p_assignment_set_id    IN NUMBER   DEFAULT NULL
                     ,p_employee_number      IN NUMBER   DEFAULT NULL
                     ,p_sort_order1          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order2          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order3          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order4          IN VARCHAR2 DEFAULT NULL
                     ,p_xml                  OUT NOCOPY CLOB
                     );
  --
END pay_in_soe;

/
