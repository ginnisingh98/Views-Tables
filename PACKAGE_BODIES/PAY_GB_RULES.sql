--------------------------------------------------------
--  DDL for Package Body PAY_GB_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_RULES" as
/*   $Header: pygbrule.pkb 120.0 2005/05/29 05:29:20 appldev noship $ */

-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
--
---------------------------------------------------------------------------
-- Procedure: get_source_text_context
-- This procedure sets default for Court Order contexts
---------------------------------------------------------------------------

   procedure get_source_text_context(p_asg_act_id number,
                                     p_ee_id number,
                                     p_source_text in out NOCOPY varchar2)
   is
   begin
           hr_utility.set_location('PAY_GB_RULES.get_source_text_context',1);
           p_source_text := 'Unknown';
           hr_utility.set_location('PAY_GB_RULES.get_source_text_context',3);
           hr_utility.set_location('PAY_GB_RULES.get_source_text_context='||
                               p_source_text,4);
   end get_source_text_context;

end PAY_GB_RULES;

/
