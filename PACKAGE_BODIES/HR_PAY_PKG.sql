--------------------------------------------------------
--  DDL for Package Body HR_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAY_PKG" as
/* $Header: hrpay.pkb 120.0 2005/05/29 01:49:02 appldev noship $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
	HR Libraries server-side agent
Purpose
	Agent handles all server-side traffic to and from forms libraries. This
	is particularly necessary because we wish to avoid the situation where
	a form and its libraries both refer to the same server-side package.
	Forms/libraries appears to be unable to cope with this situation in
	circumstances which we cannot yet define.
History
	21 Apr 95	N Simpson	Created
	19 Aug 97	Sxshah	        Banner now on eack line.
Change List:
======================================================================
Version  Date         Author    Bug No.  Description of Change
-------  -----------  --------  -------  -----------------------------
115.1    25-JUL-2000  JBailie            Added use of tax_unit_id and
                                         parameters to pybaluex.pkh 115.2
======================================================================
*/
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_always_get_db_item   in boolean
) return number is
--
l_tax_unit_id   number;
--
begin
--
select paa.tax_unit_id
into l_tax_unit_id
from pay_assignment_actions paa
where paa.assignment_action_id = p_assignment_action_id;
--
return (pay_balance_pkg.get_value (
		p_defined_balance_id,
		p_assignment_action_id,
		l_tax_unit_id,
                null, -- jurisdiction
                null, -- source_id
                null, -- tax_group
                null  -- date_earned
       ));
--
end get_value;
--
end	hr_pay_pkg;

/
