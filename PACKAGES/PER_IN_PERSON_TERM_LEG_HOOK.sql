--------------------------------------------------------
--  DDL for Package PER_IN_PERSON_TERM_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_PERSON_TERM_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhte.pkh 120.2.12000000.1 2007/01/21 23:29:55 appldev ship $ */
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : ACTUAL_TERMINATION_EMP                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
-- 1.1   11-Jul-06  rpalli   5242205  Restored orig proc spec           --
--------------------------------------------------------------------------
PROCEDURE actual_termination_emp
                      (p_effective_date          IN DATE
		      ,p_period_of_service_id    IN NUMBER
		      ,p_actual_termination_date IN DATE
		      ,p_business_group_id       IN NUMBER
		      ) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : FINAL_PROCESS_EMP                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   11-Jul-06  rpalli   5242205  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE final_process_emp
                      (p_period_of_service_id    IN NUMBER) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : REVERSE_TERMINATION_EMP                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE reverse_termination_emp
                      (p_effective_date          IN DATE
		      ,p_period_of_service_id    IN NUMBER
		      ,p_actual_termination_date IN DATE
		      ,p_business_group_id       IN NUMBER
		      )  ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : REVERSE_TERMINATION_EMP_INT                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Internal Procedure to be called for IN localization --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   30-Sep-04  sshankar 3801926  Created this procedure            --
--------------------------------------------------------------------------

PROCEDURE reverse_termination_emp_int
                      (p_effective_date          IN DATE
		      ,p_period_of_service_id    IN NUMBER
		      ,p_actual_termination_date IN DATE
		      ,p_business_group_id       IN NUMBER
		      ,p_calling_procedure       IN VARCHAR2
           	      ,p_message_name            OUT NOCOPY VARCHAR2
                      ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
                      ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
		      ) ;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : UPDATE_PDS_DETAILS                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_effective_date          DATE                      --
--                  p_leaving_reason          VARCHAR2                  --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   19-Nov-04  aaagarwa 3977410  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE update_pds_details
                      (p_period_of_service_id       IN NUMBER
                      ,p_effective_date             IN DATE
                      ,p_leaving_reason             IN VARCHAR2
                      );

END   per_in_person_term_leg_hook;

/
