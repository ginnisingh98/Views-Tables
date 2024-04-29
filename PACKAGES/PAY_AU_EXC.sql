--------------------------------------------------------
--  DDL for Package PAY_AU_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_EXC" AUTHID CURRENT_USER as
/* $Header: pyauexch.pkh 120.1 2005/12/02 01:38:29 avenkatk noship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+--------------------------------------------------+
-- 13-Aug-1999 sgoggin          1.0               Created
-- 23-Jul-2002 Ragovind         1.1     2123970   Overloaded the Functions asg_ptd_ec, asg_span_ec
--                                                for Handling the Balance Adjustment Enhancement.
-- 03-Dec-2002 Ragovind         1.2     2689226   Added NOCOPY for functions pyauexc.asg_ptd_ec,
--                                                pyauexc.asg_span_ec.
-- 22-Mar-2004 jkarouza         1.0     3830198   Renamed file to pyauexch.pkh and package to
--                                                PAY_AU_EXC.
-- 30-Nov-2005 avenkatk         1.4     4351318   Introduced procedure fbt_ytd_start.
-- -----------+---------------+--------+--------+--------------------------------------------------+
--
-- FUNCTION DECLARATIONS

   FUNCTION next_period      (p_payroll_action_id in number, p_given_date in date ) RETURN date ;

   FUNCTION next_month       (p_given_date in date )   			            RETURN date ;

   FUNCTION next_quarter     (p_given_date in date)  			            RETURN date ;

   FUNCTION next_year        (p_given_date in date)                                 RETURN date ;

   FUNCTION next_fin_quarter (p_beg_of_the_year in date, p_given_date in date )     RETURN date;

   FUNCTION next_fin_year    (p_beg_of_the_year in date, p_given_date in date )     RETURN date ;

   FUNCTION next_fbt_quarter (p_given_date in date )                                RETURN date ;

   FUNCTION next_fbt_year    (p_given_date in date )                                RETURN date ;


-------------------------------- asg_ptd_ec ---------------------------------
/*
 *  name
 *     asg_ptd_ec - assignment processing period to date expiry check.
 *  description
 *     expiry checking code for the following:
 *       au assignment-level process period to date balance dimension
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
                    ,   p_expiry_information         out NOCOPY number    -- dimension expired flag.
                    ) ;
--
-------------------------------- asg_span_ec -----------------------------------------
/*
 *
 *  name
 *     asg_span_ec - assignment processing span to date expiry check.
 *  description
 *     expiry checking code for the following:
 *          au assignment-level process year to date balance dimension
 *          au assignment-level process fiscal year to date balance dimension
 *          au assignment-level process fiscal quarter to date balance dimension
 *          au assignment-level process FBT year to date balance dimension
 *          au assignment-level process Calendar year to date balance dimension
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
                        ,   p_expiry_information         out NOCOPY number    -- dimension expired flag.
                        ) ;
--

PROCEDURE asg_ptd_ec
	(   p_owner_payroll_action_id    in     number      -- run created balance.
	,   p_user_payroll_action_id     in     number      -- current run.
	,   p_owner_assignment_action_id in     number      -- assact created balance.
	,   p_user_assignment_action_id  in     number      -- current assact..
	,   p_owner_effective_date       in     date        -- eff date of balance.
	,   p_user_effective_date        in     date        -- eff date of current run.
	,   p_dimension_name             in     varchar2    -- balance dimension name.
	,   p_expiry_information         out NOCOPY  date        -- dimension expired flag.
	) ;
--
PROCEDURE asg_span_ec
	(   p_owner_payroll_action_id    in     number    -- run created balance.
	,   p_user_payroll_action_id     in     number    -- current run.
	,   p_owner_assignment_action_id in     number    -- assact created balance.
	,   p_user_assignment_action_id  in     number    -- current assact.
	,   p_owner_effective_date       in     date      -- eff date of balance.
	,   p_user_effective_date        in     date      -- eff date of current run.
	,   p_dimension_name             in     varchar2  -- balance dimension name.
	,   p_expiry_information         out NOCOPY   date      -- dimension expired date.
	) ;
--
/* Bug 4351318 - Introduced procedure for returning Start date for FBT year */
PROCEDURE fbt_ytd_start( p_effective_date  IN  DATE     ,
                         p_start_date      OUT NOCOPY DATE,
                         p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                         p_payroll_id      IN  NUMBER   DEFAULT NULL,
                         p_bus_grp         IN  NUMBER   DEFAULT NULL,
                         p_action_type     IN  VARCHAR2 DEFAULT NULL,
                         p_asg_action      IN  NUMBER   DEFAULT NULL);

end pay_au_exc;

 

/
