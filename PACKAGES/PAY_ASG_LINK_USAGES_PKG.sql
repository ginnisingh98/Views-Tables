--------------------------------------------------------
--  DDL for Package PAY_ASG_LINK_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASG_LINK_USAGES_PKG" AUTHID CURRENT_USER as
/* $Header: pyalu.pkh 120.0.12000000.2 2007/02/28 10:44:26 swinton ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		                                 |
|			   Redwood Shores, California, USA		                                   |
|			        All rights reserved.			                                       |
+==============================================================================+

Name
	Assignment Link Usages Table Handler
Purpose
	To handle DML on the Assignment Link Usages table
History
	16-MAR-1994	N Simpson	Created
  40.2  04-OCT-1994     R Fine          Renamed package to start with PAY_
 115.1  05-SEP-2006     T Habara        Added create_alu_asg.
 115.2  23-FEB-2007     S Winton        Added rebuild_alus.
 115.3  28-FEB-2007     S Winton        Doing checkin to propagate changes onto
                                        R12 mainline and branch.
*/
--------------------------------------------------------------------------------
--
-- Global types
--
type t_pg_link_rec is record
  (people_group_id      number
  ,element_link_id      number
  ,effective_start_date date
  ,effective_end_date   date
  );
--
type t_pg_link_tab is table of t_pg_link_rec
  index by binary_integer;

--------------------------------------------------------------------------------
procedure INSERT_ALU (
--
--******************************************************************************
--* Inserts Assignment Link Usages for a new element link.		       *
--******************************************************************************
--
	p_business_group_id     number,
	p_people_group_id       number,
	p_element_link_id       number,
	p_effective_start_date  date,
	p_effective_end_date    date);
--------------------------------------------------------------------------------
procedure CASCADE_LINK_DELETION (
--
--******************************************************************************
--* Deletes ALUs for a deleted link.					       *
--******************************************************************************
--
	p_element_link_id	number,
	p_business_group_id	number,
	p_people_group_id	number,
	p_delete_mode		varchar2,
	p_effective_start_date	date,
	p_effective_end_date	date,
	p_validation_start_date	date,
	p_validation_end_date	date	);
--------------------------------------------------------------------------------
procedure create_alu_asg
--
--******************************************************************************
--* Creates ALUs for an assignment with the specified element links.           *
--******************************************************************************
--
  (p_assignment_id        in number
  ,p_pg_link_tab          in t_pg_link_tab
  );
--------------------------------------------------------------------------------
procedure rebuild_alus
--
--******************************************************************************
--*  Name      : rebuild_alus                                                  *
--*  Purpose   : This procedure rebuilds all ALUs for a given assignment id    *
--*              and is used by the Generic Upgrade Mechanism.                 *
--******************************************************************************
--
  (p_assignment_id in number);
--------------------------------------------------------------------------------

end PAY_ASG_LINK_USAGES_PKG;

 

/
