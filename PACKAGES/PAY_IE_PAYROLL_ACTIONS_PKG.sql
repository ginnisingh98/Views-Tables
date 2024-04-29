--------------------------------------------------------
--  DDL for Package PAY_IE_PAYROLL_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYROLL_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyiesoe.pkh 120.0.12000000.1 2007/01/17 20:59:16 appldev noship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  SOE  package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  06 NOV 2001 kavenkat  N/A        Created
**  05 DEC 2001 gpadmasa  N/A        Added dbdrv Commands
**  10 JAN 2002 gpadmasa  N/A        Modified the Fetch_Action-Id Procedures
**				     to handle Iterative Engine Run Results.
**  12 DEC 2002 viviswan             nocopy changes done
-------------------------------------------------------------------------------
*/
procedure fetch_action_id(p_session_date             in     date,
			     p_payroll_exists           in out nocopy varchar2,
			     p_assignment_action_id     in out nocopy number,
			     p_run_assignment_action_id in out nocopy number,
			     p_paye_prsi_action_id      out nocopy number,
			     p_assignment_id            in     number,
			     p_payroll_action_id        in out nocopy number,
			     p_date_earned              in out nocopy varchar2);
procedure fetch_action_id (  p_assignment_action_id     in out nocopy number,
			     p_run_assignment_action_id in out nocopy number,
			     p_paye_prsi_action_id         out nocopy number,
			     p_assignment_id        	in out nocopy number
			  );
function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type;


END PAY_IE_PAYROLL_ACTIONS_PKG ;

 

/
