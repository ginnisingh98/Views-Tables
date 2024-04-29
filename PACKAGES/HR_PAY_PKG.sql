--------------------------------------------------------
--  DDL for Package HR_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_PKG" AUTHID CURRENT_USER as
/* $Header: hrpay.pkh 120.0 2005/05/29 01:49:09 appldev noship $ */
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
	19 Aug 97	Sxshah	Banner now on eack line.
*/
function get_value
(
    p_defined_balance_id   in number,
    p_assignment_action_id in number,
    p_always_get_db_item   in boolean
) return number;
--
end	hr_pay_pkg;

 

/
