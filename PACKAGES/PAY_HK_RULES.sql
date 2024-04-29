--------------------------------------------------------
--  DDL for Package PAY_HK_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_RULES" AUTHID CURRENT_USER as
/* $Header: pyhkrule.pkh 115.2 2002/12/03 07:16:32 srrajago ship $ */
/*
   Copyright (c) Oracle Corporation 2000. All rights reserved
--
   Name        : pay_hk_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   08-NOV-2000  jbailie     115.0  Created.
   02-DEC-2002  srrajago    115.1  Included 'nocopy' option to the 'out' parameter of the procedure get_source_context,
                                   dbdrv and checkfile commands.
   03-DEC-2002  srrajago    115.2  Included 'nocopy' option to the 'in out ' parameter which was missed out in the
                                   earlier version.
*/
   procedure get_source_context(p_asg_act_id number,
                                p_ee_id number,
                                p_source_id in out nocopy number);
end pay_hk_rules;

 

/
