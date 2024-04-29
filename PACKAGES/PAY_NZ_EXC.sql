--------------------------------------------------------
--  DDL for Package PAY_NZ_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_EXC" AUTHID CURRENT_USER as
/* $Header: pynzexc.pkh 120.2.12010000.1 2008/07/27 23:17:06 appldev ship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 13-Aug-1999 sclarke          1.0                 Created
-- 03-Dec-2002 srrajago         1.1     2689221  Included 'nocopy' option for the 'out'
--                                               parameters of all the procedures,dbdrv
--                                               and checkfile commands.
-- 22-Jul-2003 puchil           1.2     3004603  Added overloaded function to populate
--                                               latest balances for balance adjustment
--                                               correctly
-- 05-Aug-2003 puchil           1.3     3062941  Changed the package name from pynzexc
--                                               to pay_nz_exc
-- 10-Aug-2004 sshankar         1.4     3181581  Removed function ASG_PTD_EC, expiry
--                                               checking code for _ASG_PTD.
-- 16-Nov-2004 snekkala         1.5     3828575  Added Start Date Code Procedures
-- 23-Nov-2004 snekkala         1.6     3828575  Modified as per review comments
-- 12-Apr-2007 dduvvuri         1.7     5846247  Added procedure start_code_11mths_prev
--                                               for KiwiSaver Stat Requirement for NZ
--                                               from 1st July 2007
-- 27-Apr-2007 dduvvuri         1.8     5846247  Changed Tab characters to spaces.
-- -----------+---------------+--------+--------+-----------------------+
--
-------------------------------- asg_span_ec -----------------------------------------
/*
 *
 *  name
 *     asg_span_ec - assignment processing span to date expiry check.
 *  description
 *     expiry checking code for the following:
 *          nz assignment-level process year to date balance dimension
 *          nz assignment-level process fiscal year to date balance dimension
 *          nz assignment-level process fiscal quarter to date balance dimension
 *          nz assignment-level process holiday year to date balance dimension
 *  notes
 *     the associated dimension is expiry checked at assignment action level
 */
--
procedure asg_span_ec   (   p_owner_payroll_action_id    in     number    -- run created balance.
                        ,   p_user_payroll_action_id     in     number    -- current run.
                        ,   p_owner_assignment_action_id in     number    -- assact created balance.
                        ,   p_user_assignment_action_id  in     number    -- current assact.
                        ,   p_owner_effective_date       in     date      -- eff date of balance.
                        ,   p_user_effective_date        in     date      -- eff date of current run.
                        ,   p_dimension_name             in     varchar2  -- balance dimension name.
                        ,   p_expiry_information         out nocopy number    -- dimension expired flag.
                        ) ;
--
---------------------------- Overloaded asg_span_ec ------------------------------------
/*
 *
 *  name
 *     asg_span_ec - assignment processing span to date expiry check.
 *  description
 *     Overloaded expiry checking code for the following:
 *          nz assignment-level process year to date balance dimension
 *          nz assignment-level process fiscal year to date balance dimension
 *          nz assignment-level process fiscal quarter to date balance dimension
 *          nz assignment-level process holiday year to date balance dimension
 *  notes
 *     the associated dimension is expiry checked at assignment action level
 */
--
procedure asg_span_ec   (   p_owner_payroll_action_id    in     number    -- run created balance.
                        ,   p_user_payroll_action_id     in     number    -- current run.
                        ,   p_owner_assignment_action_id in     number    -- assact created balance.
                        ,   p_user_assignment_action_id  in     number    -- current assact.
                        ,   p_owner_effective_date       in     date      -- eff date of balance.
                        ,   p_user_effective_date        in     date      -- eff date of current run.
                        ,   p_dimension_name             in     varchar2  -- balance dimension name.
                        ,   p_expiry_information         out nocopy date  -- dimension expired flag.
                        ) ;
--
PROCEDURE start_code_4week( p_effective_date  IN         DATE
                          , p_start_date      OUT NOCOPY DATE
                          , p_payroll_id      IN         NUMBER
                          , p_bus_grp         IN         NUMBER
                          , p_asg_action      IN         NUMBER
                          );


PROCEDURE start_code_4weeks_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                );

PROCEDURE start_code_hol_ytd( p_effective_date  IN         DATE
                            , p_start_date      OUT NOCOPY DATE
                            , p_payroll_id      IN         NUMBER
                            , p_bus_grp         IN         NUMBER
                            , p_asg_action      IN         NUMBER
                            );

PROCEDURE start_code_12mths_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                );
/* Changes for Bug 5846247 start*/
PROCEDURE start_code_11mths_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                );
end pay_nz_exc;
/* Changes for Bug 5846247 end*/


/
