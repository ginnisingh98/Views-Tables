--------------------------------------------------------
--  DDL for Package PAY_GB_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_RULES" AUTHID CURRENT_USER as
/*   $Header: pygbrule.pkh 120.0 2005/05/29 05:29:30 appldev noship $ */

-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+

---------------------------------------------------------------------------
-- Procedure:  get_source_text_context
-- Sets the default for Court Order Reference contexts.
---------------------------------------------------------------------------

   procedure get_source_text_context(p_asg_act_id number,
                                     p_ee_id number,
                                     p_source_text in out NOCOPY varchar2);
end PAY_GB_RULES;

 

/
