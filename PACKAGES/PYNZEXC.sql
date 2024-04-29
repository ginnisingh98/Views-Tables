--------------------------------------------------------
--  DDL for Package PYNZEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYNZEXC" AUTHID CURRENT_USER as
/* $Header: pynzexc.pkh 115.1 2002/12/03 05:02:22 srrajago ship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 13-Aug-1999 sclarke          1.0                 Created
-- 03-Dec-2002 srrajago         1.1     2689221  Included 'nocopy' option for the 'out'
--                                               parameters of all the procedures,dbdrv
--                                               and checkfile commands.
-- -----------+---------------+--------+--------+-----------------------+
--
-------------------------------- asg_ptd_ec ---------------------------------
/*
 *  name
 *     asg_ptd_ec - assignment processing period to date expiry check.
 *  description
 *     expiry checking code for the following:
 *       nz assignment-level process period to date balance dimension
 *  notes
 *     the associtated dimension is expiry checked at assignment action level
 */
--
procedure asg_ptd_ec(   p_owner_payroll_action_id    in     number    -- run created balance.
                    ,   p_user_payroll_action_id     in     number    -- current run.
                    ,   p_owner_assignment_action_id in     number    -- assact created balance.
                    ,   p_user_assignment_action_id  in     number    -- current assact..
                    ,   p_owner_effective_date       in     date      -- eff date of balance.
                    ,   p_user_effective_date        in     date      -- eff date of current run.
                    ,   p_dimension_name             in     varchar2  -- balance dimension name.
                    ,   p_expiry_information         out nocopy number    -- dimension expired flag.
                    ) ;
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
end pynzexc;

 

/
