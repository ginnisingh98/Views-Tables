--------------------------------------------------------
--  DDL for Package PER_IN_ENTRY_VALUE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_ENTRY_VALUE_LEG_HOOK" AUTHID CURRENT_USER as
/* $Header: peinlhee.pkh 120.2 2007/10/25 05:54:59 sivanara ship $ */
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-04  lnagaraj 3839878  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE check_entry_value(p_effective_date IN DATE
                           ,p_element_entry_id IN NUMBER
			   ,p_effective_start_date IN DATE
			   ,p_effective_end_date IN DATE
			   );
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE_DEL                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for IN localization  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   23-Oct-07  sivanara 6469684  Created this procedure            --
--------------------------------------------------------------------------

 PROCEDURE check_entry_value_del(p_effective_date       IN DATE
                                ,p_element_entry_id     IN NUMBER
		                ,p_effective_start_date IN DATE
		                ,p_effective_end_date   IN DATE
			        ,p_assignment_id_o      IN NUMBER
				,p_element_type_id_o    IN NUMBER
		               );
END per_in_entry_value_leg_hook;

/
