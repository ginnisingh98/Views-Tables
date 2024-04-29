--------------------------------------------------------
--  DDL for Package PAY_IE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_RULES" AUTHID CURRENT_USER as
/*   $Header: pyierule.pkh 120.0 2005/05/29 05:46:49 appldev noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_ie_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   07-MAR-2003  vmkhande    115.0  Created(template pyfrrule).
*/
   procedure get_source_text_context(p_asg_act_id number,
                                      p_ee_id number,
                                      p_source_text in out NOCOPY varchar2);
   PROCEDURE get_main_tax_unit_id
  				 (p_assignment_id                 IN         NUMBER
  				 ,p_effective_date                IN         DATE
  				 ,p_tax_unit_id                   OUT NOCOPY NUMBER
  				 );
END;

 

/
