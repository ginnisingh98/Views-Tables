--------------------------------------------------------
--  DDL for Package PAY_IN_EOY_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_EOY_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pyineoyr.pkh 120.0.12010000.1 2008/07/27 22:53:03 appldev ship $ */

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_TEMPLATE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure gets the payslip template code       --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id    NUMBER                       --
  --            OUT : p_template             VARCHAR2                     --
  --------------------------------------------------------------------------
  --

  PROCEDURE get_template (p_business_group_id    IN  NUMBER
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
  PROCEDURE fetch_xml (p_clob    OUT NOCOPY CLOB);

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
  --                  p_assessment_year       VARCHAR2                    --
  --                  p_gre_organization      VARCHAR2                    --
  --                  p_employee_type         VARCHAR2                    --
  --                  p_employee_number       VARCHAR2                    --
  --            OUT : p_clob_cnt              NUMBER                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE load_xml (p_business_group_id  IN  NUMBER
                     ,p_assessment_year    IN  VARCHAR2
                     ,p_gre_organization   IN  VARCHAR2   DEFAULT NULL
                     ,p_employee_type      IN  VARCHAR2
                     ,p_employee_number    IN  VARCHAR2   DEFAULT NULL
                     ,p_clob_cnt           OUT NOCOPY     NUMBER
                     );

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_LOCATION_DETAILS                                --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function returns either the complete gre       --
  --                  location details or of a specified field based on   --
  --                  the parameters passed                               --
  -- Parameters     :                                                     --
  --             IN : p_location_id     NUMBER                            --
  --                  p_concatenate     VARCHAR2                          --
  --                  p_field           VARCHAR2                          --
  --         RETURN : VARCHAR2
  --------------------------------------------------------------------------
FUNCTION get_location_details ( p_location_id  IN   hr_locations.location_id%TYPE
                              , p_concatenate  IN   VARCHAR2     DEFAULT 'N'
                              , p_field        IN   VARCHAR2     DEFAULT NULL
                              )
RETURN VARCHAR2;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_ADDRESS_DETAILS                                 --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
   -- Description    : This function returns either the complete person   --
  --                  address details or of a specified field based on    --
  --                  the parameters passed                               --
  -- Parameters     :                                                     --
  --             IN : p_address_id     NUMBER                            --
  --                  p_concatenate     VARCHAR2                          --
  --                  p_field           VARCHAR2                          --
  --         RETURN : VARCHAR2
  --------------------------------------------------------------------------
FUNCTION get_address_details ( p_address_id   IN   per_addresses.address_id%TYPE
                             , p_concatenate  IN   VARCHAR2     DEFAULT 'N'
                             , p_field        IN   VARCHAR2     DEFAULT NULL
                       )
RETURN VARCHAR2;

END pay_in_eoy_reports;

/
