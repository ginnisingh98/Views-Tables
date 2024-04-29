--------------------------------------------------------
--  DDL for Package PER_IN_PERQUISITE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_PERQUISITE_PKG" AUTHID CURRENT_USER as
/* $Header: peinperq.pkh 120.0.12010000.1 2008/07/28 04:53:07 appldev ship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ELEMENT_ENTRY                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to Check element entry validation         --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --

--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   07-OCT-04  lnagaraj  Created this function                     --
--------------------------------------------------------------------------
PROCEDURE check_element_entry
             (p_effective_date          IN DATE
             ,p_element_entry_id        IN NUMBER
             ,p_effective_start_date    IN DATE
	     ,p_effective_end_date      IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     );

END per_in_perquisite_pkg;

/
