--------------------------------------------------------
--  DDL for Package PAY_CN_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_EXT" AUTHID CURRENT_USER AS
/* $Header: pycnext.pkh 120.0.12010000.1 2008/07/27 22:21:00 appldev ship $ */

  g_package  VARCHAR2(100);


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CB_EXTRACT_PROCESS                                    --
  -- Type           : PROCEDURE                                             --
  -- Access         : Public                                                --
  -- Description    : Procedure for CB Extract                              --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :  p_phf_si_type         VARCHAR2                       --
  --                   p_legal_employer_id   NUMBER DEFAULT NULL            --
  --                   p_contribution_area   VARCHAR2                       --
  --                   p_contribution_year   VARCHAR2                       --
  --                   p_business_group_id   NUMBER                         --
  --           OUT  :  errbuf               VARCHAR2                        --
  --                   retcode              VARCHAR2                        --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this procedure                   --
  ----------------------------------------------------------------------------
 PROCEDURE cb_extract_process( errbuf               OUT  NOCOPY VARCHAR2
                             , retcode              OUT  NOCOPY VARCHAR2
                             , p_phf_si_type        IN   VARCHAR2
                             , p_legal_employer_id  IN   NUMBER
                             , p_contribution_area  IN   VARCHAR2
                             , p_contribution_year  IN   VARCHAR2
                             , p_business_group_id  IN   NUMBER
                             ) ;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CA_EXTRACT_PROCESS                                    --
  -- Type           : PROCEDURE                                             --
  -- Access         : Public                                                --
  -- Description    : Procedure for CA Extract                              --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_phf_si_type        VARCHAR2                         --
  --                  p_legal_employer_id  NUMBER                           --
  --                  p_contribution_area  VARCHAR2                         --
  --                  p_contribution_year  VARCHAR2                         --
  --                  p_business_group_id  NUMBER                           --
  --           OUT  : errbuf               VARCHAR2                         --
  --                  retcode              VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this procedure                   --
  ----------------------------------------------------------------------------
  PROCEDURE ca_extract_process( errbuf               OUT  NOCOPY VARCHAR2
                              , retcode              OUT  NOCOPY VARCHAR2
                              , p_phf_si_type        IN   VARCHAR2
                              , p_legal_employer_id  IN   NUMBER
                              , p_contribution_area  IN   VARCHAR2
                              , p_contribution_year  IN   VARCHAR2
                              , p_contribution_month IN   VARCHAR2
                              , p_business_group_id  IN   NUMBER
                              ) ;

 ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : EM_EXTRACT_PROCESS                                    --
  -- Type           : PROCEDURE                                             --
  -- Access         : Public                                                --
  -- Description    : Procedure for EM Extract                              --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :  p_phf_si_type          VARCHAR2                      --
  --                   p_legal_employer_id    NUMBER                        --
  --                   p_contribution_area    VARCHAR2                      --
  --                   p_contribution_year    VARCHAR2                      --
  --                   p_contribution_month   VARCHAR2                      --
  --                   p_business_group_id    NUMBER                        --
  --                   p_filling_date         VARCHAR2                      --
  --           OUT  :  errbuf                 VARCHAR2                      --
  --                   retcode                VARCHAR2                      --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this procedure                   --
  ----------------------------------------------------------------------------
  PROCEDURE em_extract_process( errbuf               OUT  NOCOPY VARCHAR2
                              , retcode              OUT  NOCOPY VARCHAR2
                              , p_phf_si_type        IN   VARCHAR2
                              , p_legal_employer_id  IN   NUMBER
                              , p_contribution_area  IN   VARCHAR2
                              , p_contribution_year  IN   VARCHAR2
                              , p_contribution_month IN   VARCHAR2
                              , p_business_group_id  IN   NUMBER
                              , p_filling_date       IN   VARCHAR2
                              ) ;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CB_CRITERIA_PROFILE                                   --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to select the assignments to be extracted    --
  --                  for CB Report                                         --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_date_earned        DATE                             --
  --            OUT : p_warning_message    VARCHAR2                         --
  --                  p_error_message      VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  FUNCTION cb_criteria_profile ( p_assignment_id      IN VARCHAR2
                               , p_business_group_id  IN NUMBER
                               , p_date_earned        IN DATE
                               , p_warning_message    OUT NOCOPY VARCHAR2
                               , p_error_message      OUT NOCOPY VARCHAR2
                               )
  RETURN VARCHAR2;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CA_CRITERIA_PROFILE                                   --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to select the assignments to be extracted    --
  --                  for CA Report                                         --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_date_earned        DATE                             --
  --            OUT:  p_warning_message    VARCHAR2                         --
  --                  p_error_message      VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  FUNCTION ca_criteria_profile ( p_assignment_id      IN VARCHAR2
                               , p_business_group_id  IN NUMBER
                               , p_date_earned        IN DATE
                               , p_warning_message    OUT NOCOPY VARCHAR2
                               , p_error_message      OUT NOCOPY VARCHAR2
                               )
  RETURN VARCHAR2;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : EM_CRITERIA_PROFILE                                   --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to select the assignments to be extracted    --
  --                  for EM Report                                         --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_date_earned        DATE                             --
  --            OUT:  p_warning_message    VARCHAR2                         --
  --                  p_error_message      VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  FUNCTION em_criteria_profile ( p_assignment_id      IN VARCHAR2
                               , p_business_group_id  IN NUMBER
                               , p_date_earned        IN DATE
                               , p_warning_message    OUT NOCOPY VARCHAR2
                               , p_error_message      OUT NOCOPY VARCHAR2
                               )
  RETURN VARCHAR2;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_EMPLOYER_INFO                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to get employer information based on the     --
  --                  info type                                             --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_info_type          VARCHAR2                         --
  --                  p_assignment_id      NUMBER                           --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   15-Sep-2004   snekkala  Added the parameter p_assignment_id      --
  ----------------------------------------------------------------------------
  FUNCTION  get_employer_info(p_assignment_id  IN NUMBER
                             ,p_info_type      IN VARCHAR2)
  RETURN VARCHAR2;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_EMPLOYEE_INFO                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to get Employee Details based on Info Type   --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_date_earned        DATE                             --
  --                  p_info_type          VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  FUNCTION  get_employee_info(p_assignment_id  IN NUMBER
                             ,p_date_earned    IN DATE
                             ,p_info_type      IN VARCHAR2)
  RETURN VARCHAR2;


   ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_BALANCE_VALUE                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to set the Balance value of a given Balance  --
  --                  and Balance Dimension                                 --
  --                  This function returns                                 --
  --                  o Previous month value if Info Type is PREV_MONTH     --
  --                  o Current month value if Info Type is CURR_MONTH      --
  --                  o Prev Years average value of the defined balance     --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_balance_name       VARCHAR2                         --
  --                  p_balance_dimension  VARCHAR2                         --
  --                  p_info_type          VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  FUNCTION  get_balance_value( p_assignment_id      IN NUMBER
                             , p_business_group_id  IN NUMBER
                             , p_balance_name       IN VARCHAR2
                             , p_balance_dimension  IN VARCHAR2
                             , p_info_type          IN VARCHAR2
			     )
  RETURN NUMBER;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_ELEMENT_ENTRY                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to check whether an assignment has element   --
  --                  entries for the given PHF/SI Type                     --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_effective_date      IN DATE                         --
  --                  p_phf_si_type         IN VARCHAR2                     --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   04-Feb-2004   bramajey  Removed parameters p_start_date and      --
  --                               p_end_date. Added new paramter           --
  --                               p_effective_date                         --
  ----------------------------------------------------------------------------
  FUNCTION  get_element_entry ( p_assignment_id       IN NUMBER
                              , p_business_group_id   IN NUMBER
			      , p_effective_date      IN DATE
			      , p_phf_si_type         IN VARCHAR2
                              )
  RETURN VARCHAR2;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_ASSIGNMENT_ACTION                                 --
  -- Type           : FUNCTION                                              --
  -- Access         : Private                                               --
  -- Description    : Function to check whether an assignment has assignment--
  --                  action id for the given period                        --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   03-Feb-2004   saikrish  Created this function (Bug# 3411273)     --
  ----------------------------------------------------------------------------
  FUNCTION  get_assignment_action ( p_assignment_id       IN NUMBER
                                  , p_business_group_id   IN NUMBER
				  , p_start_date          IN DATE
				  , p_end_date            IN DATE
                                  )
  RETURN VARCHAR2;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_OVERRIDE_SIC_CODE                                 --
  -- Type           : FUNCTION                                              --
  -- Access         : Privatre                                              --
  -- Description    : Function to check whether an assignment has Override  --
  --                  SIC code for the given PHF/SI Type                    --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_element_name      IN VARCHAR2                       --
  --                  p_assignment_id     IN NUMBER                         --
  --     	      p_date_earned       IN DATE                           --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   03-Feb-2004   saikrish  Created this function(Bug# 3411840)      --
  -- 1.1   05-Feb-2004   saikrish  Removed p_business_group_id              --
  ----------------------------------------------------------------------------
  FUNCTION  get_override_sic_code ( p_element_name      IN VARCHAR2
				  , p_assignment_id     IN NUMBER
				  , p_date_earned       IN DATE
				  )
  RETURN VARCHAR2;



END pay_cn_ext;

/
