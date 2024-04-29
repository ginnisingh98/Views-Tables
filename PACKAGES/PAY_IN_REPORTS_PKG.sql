--------------------------------------------------------
--  DDL for Package PAY_IN_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_REPORTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyinprpt.pkh 120.2.12010000.3 2008/08/21 10:16:32 mdubasi ship $ */
--------------------------------------------------------------------------
--                                                                      --
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure calls procedure for PF Form3A or PF  --
--                    Form6A depending on the report type parameter     --
-- Parameters     :                                                     --
--             IN : p_contribution_period                VARCHAR2       --
--                    p_report_type                      VARCHAR 2      --
--                    p_pf_org_id                        VARCHAR2       --
--                    p_pf_number                        VARCHAR2       --
--                    p_template_appl                    VARCHAR2       --
--                    p_template_code                    VARCHAR2       --
--                    p_number_of_copies                 VARCHAR2       --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE init_code
          (p_pf_org_id            IN VARCHAR2  DEFAULT NULL
          ,p_pf_number            IN VARCHAR2  DEFAULT NULL
          ,p_pension_number       IN VARCHAR2  DEFAULT NULL
          ,p_contribution_period  IN VARCHAR2  DEFAULT NULL
          ,p_form_type            IN VARCHAR2
          ,p_employee_type        IN VARCHAR2  DEFAULT NULL
          ,p_esi_org_id           IN VARCHAR2  DEFAULT NULL
          ,p_esi_coverage         IN VARCHAR2  DEFAULT NULL
          ,p_sysdate              IN DATE      DEFAULT NULL
          ,p_template_name        IN VARCHAR2
          ,p_xml                  OUT NOCOPY CLOB
          ,p_pt_org_id            IN VARCHAR2  DEFAULT NULL
          ,p_frequency            IN VARCHAR2  DEFAULT NULL
          ,p_year                 IN VARCHAR2  DEFAULT NULL
          ,p_period               IN VARCHAR2  DEFAULT NULL
	  ,p_gre_org_id           IN VARCHAR2  DEFAULT NULL
	  ,p_assess_year          IN VARCHAR2  DEFAULT NULL
           );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : employee_type                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks whether the employee type of   --
--                  current assignment is same as in the Concurrent     --
--                  Program Parameter or not.                           --
-- Parameters     :                                                     --
--             IN : p_assignment_id                     NUMBER          --
--                  p_employee_type                     VARCHAR2        --
--                  p_effective_start_date              DATE            --
--                  p_effective_end_date                DATE            --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 21-Feb-2005    aaagawra   Initial Version                      --
--------------------------------------------------------------------------
FUNCTION employee_type(p_pf_number            VARCHAR2
                      ,p_employee_type        VARCHAR2
                      ,p_effective_start_date DATE
                      ,p_effective_end_date   DATE
                      ,p_cp_pf_org_id         VARCHAR2 DEFAULT NULL
                      ,p_pf_org_id            VARCHAR2 DEFAULT NULL
                      ,p_status               OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_disability_details                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This Function returns the PF wage ceiling limit     --
--		    depending on whether the disabled employee          --
--		    has met all the sucessfull criteria or not.         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                   VARCHAR2          --
--                  p_earn_date                       DATE              --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 13-AUG-2005    mdubasi   Initial Version                      --
--------------------------------------------------------------------------
FUNCTION get_disability_details(p_assignment_id NUMBER
                               ,p_earn_date DATE)
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM6A_XML                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for PF Form 6A      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                   VARCHAR2              --
--                  p_effective_start_date        DATE                  --
--                  p_effective_end_date          DATE                  --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE create_form6a_xml(p_pf_org_id        VARCHAR2
                 ,p_effective_start_date        DATE
                 ,p_effective_end_date          DATE
                 ,p_contribution_period         VARCHAR2);


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM3A_XML                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for PF Form3A       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                        VARCHAR2         --
--                    p_pf_number                      VARCHAR2         --
--                    p_effective_start_date           DATE             --
--                    p_effective_end_date             DATE             --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagawra   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE create_form3a_xml(p_pf_org_id            VARCHAR2
                           ,p_pf_number            VARCHAR2
                           ,p_contribution_period  VARCHAR2
                           ,p_employee_type        VARCHAR2
                           ,p_effective_start_date DATE
                           ,p_effective_end_date   DATE);




/*Bug 4132919. Added following  procedure for Pension Form 8 */
PROCEDURE create_form8_xml(p_pf_org_id            IN VARCHAR2
                          ,p_contribution_period  IN VARCHAR2
                          ,p_effective_start_date IN DATE
                          ,p_effective_end_date   IN DATE);


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM7_XML                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for Pension Form7   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                        VARCHAR2         --
--                  p_pension_number                   VARCHAR2         --
--                  p_employee_type                    VARCHAR2         --
--                  p_contribution_period              VARCHAR2         --
--                  p_effective_start_date             DATE             --
--                  p_effective_end_date               DATE             --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 08-Mar-2005    lnagaraj  Initial Version                       --
--------------------------------------------------------------------------

PROCEDURE create_form7_xml(p_pf_org_id              VARCHAR2
                          ,p_pension_number         VARCHAR2
                          ,p_employee_type          VARCHAR2
                          ,p_contribution_period    VARCHAR2
                          ,p_effective_start_date   DATE
                          ,p_effective_end_date     DATE);
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_ESI_XML                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for ESI Form 6      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_org_id                    VARCHAR2                --
--                  p_employee_type             VARCHAR2                --
--                  p_contribution_period       VARCHAR2                --
--                  p_esi_coverage              VARCHAR2                --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 10-Mar-2005    aaagarwa  Initial Version                       --
--------------------------------------------------------------------------
PROCEDURE create_esi_xml(p_esi_org_id       IN  VARCHAR2 DEFAULT NULL
                    ,p_contribution_period  IN  VARCHAR2
                    ,p_esi_coverage         IN  VARCHAR2 DEFAULT NULL
                    ,p_sysdate              IN  DATE     DEFAULT NULL
                    );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM27A_XML                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for Form 27A        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_gre_org_id                VARCHAR2                --
--                  p_assess_year               VARCHAR2                --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 27-Jul-2005    vgsriniv  Initial Version                       --
--------------------------------------------------------------------------
PROCEDURE create_form27A_xml(p_gre_org_id  IN VARCHAR2
                            ,p_assess_year IN VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LOCATION_DETAILS                                --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : This function gets the gre location details        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id         hr_locations.location_id      --
--                : p_concatenate         VARCHAR2                      --
--                  p_field               VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_location_details ( p_location_id  IN  VARCHAR2
                               ,p_field        IN   VARCHAR2     DEFAULT NULL)
RETURN VARCHAR2;

END pay_in_reports_pkg;

/
