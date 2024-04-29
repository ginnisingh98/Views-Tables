--------------------------------------------------------
--  DDL for Package Body PAYRPENP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAYRPENP" AS
/* $Header: payrpenp.pkb 120.1 2006/01/04 00:44:40 pgongada noship $ */
/* +======================================================================+
   |                Copyright (c) 1998 Oracle Corporation                 |
   |                   Redwood Shores, California, USA                    |
   |                        All rights reserved.                          |
   +======================================================================+

    File Name   : payrpenp.pkb

    Description : This package used for Employee Not Processes.

    Change History
    --------------

    Ver    Date        Bug      Author    Description
    ------ ----------- -------  --------  ---------------------------
    115.2  04-JAN-2001          ahanda    Added Header Info.
    115.3  21-JAN-2004 3372714  saurgupt  Modify definition of cursor
                                          missing_assignment_action to
                                          reduce the cost of query.
    115.4  04-JAN-2006 4771529  pgongada  Changed the size of the local
					  variables to corresponding
					  columns of the tables.
*/

--
--
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_gre_name                                                          --
-- Purpose                                                                 --
--   This function returns the name of the government reporting entity     --
--   associated with the soft_coding_keyflex_id.  If this is null, the     --
--   function returns ' ', avoiding the need for an outer join to handle   --
--   non-US business groups.                                               --
-----------------------------------------------------------------------------

FUNCTION get_gre_name( p_soft_coding_keyflex_id   IN NUMBER )
RETURN VARCHAR2 IS

cursor c_get_gre_name is
select tax.name
from
hr_soft_coding_keyflex      flx,
hr_organization_units       tax,
hr_organization_information inf
where
tax.organization_id                 = inf.organization_id
and inf.org_information_context||'' = 'CLASS'
and inf.org_information1            = 'HR_LEGAL'
and flx.soft_coding_keyflex_id      = p_soft_coding_keyflex_id
and tax.organization_id             = flx.segment1;

l_gre_name          hr_organization_units.name%TYPE;

BEGIN

open  c_get_gre_name;
fetch c_get_gre_name into l_gre_name;
close c_get_gre_name;

IF l_gre_name IS NULL THEN

 RETURN ' ';

END IF;

RETURN l_gre_name;

END get_gre_name;

-----------------------------------------------------------------------------
-- Name                                                                    --
--  get_gre_id                                                             --
-- Purpose                                                                 --
--  This function returns the id of the government reporting entity        --
--  associated with the soft_coding_keyflex_id.  If this is null, the      --
--  function returns NULL, avoiding the need for an outer join to handle   --
--  non-US business groups.                                                --
--                                                                         --
-----------------------------------------------------------------------------

FUNCTION get_gre_id( p_soft_coding_keyflex_id   IN NUMBER )
RETURN NUMBER IS

cursor c_get_gre_id is
select tax.organization_id
from
hr_soft_coding_keyflex      flx,
hr_organization_units       tax,
hr_organization_information inf
where
tax.organization_id                 = inf.organization_id
and inf.org_information_context||'' = 'CLASS'
and inf.org_information1            = 'HR_LEGAL'
and flx.soft_coding_keyflex_id      = p_soft_coding_keyflex_id
and tax.organization_id             = flx.segment1;

l_gre_id       hr_organization_units.organization_id%TYPE;

BEGIN

open  c_get_gre_id;
fetch c_get_gre_id into l_gre_id;
close c_get_gre_id;

IF l_gre_id IS NULL THEN

 RETURN NULL;

END IF;

RETURN l_gre_id;

END get_gre_id;

-----------------------------------------------------------------------------
-- Name                                                                    --
--  get_location_code                                                      --
-- Purpose                                                                 --
--  This function returns the location code associated with the            --
--  location_id.  If this is null, the function returns ' ', avoiding      --
--  the need for an outer join to handle non-US business groups in which   --
--  the location is not a mandatory field.                                 --
--                                                                         --
-----------------------------------------------------------------------------

FUNCTION get_location_code( p_location_id   IN NUMBER )
RETURN VARCHAR2 IS

cursor c_get_location_code is
select loc.location_code
from hr_locations loc
where loc.location_id = p_location_id;

l_location_code  hr_locations.location_code%TYPE;

BEGIN

open  c_get_location_code;
fetch c_get_location_code into l_location_code;
close c_get_location_code;

IF l_location_code IS NULL THEN

 RETURN NULL;

END IF;

RETURN l_location_code;

END get_location_code;

-----------------------------------------------------------------------------
-- Name                                                                    --
--  missing_assignment_action                                              --
-- Purpose                                                                 --
--  This function identifies those assignments which do not have           --
--  completed assignment actions in a given payroll period.                --
--                                                                         --
-----------------------------------------------------------------------------

FUNCTION missing_assignment_action( p_assignment_id  IN NUMBER,
                                   p_time_period_id IN NUMBER )
RETURN VARCHAR2 IS

l_assignment_action_id    pay_assignment_actions.assignment_action_id%TYPE;

CURSOR c_get_assignment_action_id IS
select assignment_action_id           -- Bug 3372714: Single query is broken into two queries to reduce the cost.
  from pay_assignment_actions act
 where act.assignment_id = p_assignment_id
   and act.action_status in ('C', 'S')
   and exists
       (select 'x'
          from per_time_periods ptp  ,
               pay_payroll_actions pct
         where ptp.time_period_id      = p_time_period_id
           and ptp.time_period_id      = pct.time_period_id
           and pct.effective_date between ptp.start_date and ptp.end_Date
           and act.payroll_action_id  = pct.payroll_action_id
        );

BEGIN

open  c_get_assignment_action_id;
fetch c_get_assignment_action_id into l_assignment_action_id;
close c_get_assignment_action_id;

IF l_assignment_action_id IS NULL THEN

 RETURN 'Y';

END IF;

RETURN 'N';

END missing_assignment_action;

END PAYRPENP;

/
