--------------------------------------------------------
--  DDL for Package PAY_PAYWIEEH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYWIEEH_PKG" AUTHID CURRENT_USER as
/* $Header: paywieeh.pkh 115.0 99/07/17 05:40:05 porting ship $ */
--
--
--
--
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|                          Redwood Shores, California, USA		       |
|                               All rights reserved.			       |
+==============================================================================+
Name
	Element Entry History Form Package
Purpose
	To provide information required by the PAYWIEEH form
History
--
	25 Oct 94	N Simpson	Created
*/
--------------------------------------------------------------------------------
--
procedure GET_ENTRY_VALUE_DETAILS (
--
-- Returns the element entry values
-- for each element entry selected by a query in the form
--
p_element_entry_id	number,
p_element_link_id	number,
p_effective_date	date,
p_name1			in out varchar2,
p_name2			in out varchar2,
p_name3			in out varchar2,
p_name4			in out varchar2,
p_name5			in out varchar2,
p_name6			in out varchar2,
p_name7			in out varchar2,
p_name8			in out varchar2,
p_name9			in out varchar2,
p_name10		in out varchar2,
p_name11		in out varchar2,
p_name12		in out varchar2,
p_name13		in out varchar2,
p_name14		in out varchar2,
p_name15		in out varchar2,
p_uom1			in out varchar2,
p_uom2			in out varchar2,
p_uom3			in out varchar2,
p_uom4			in out varchar2,
p_uom5			in out varchar2,
p_uom6			in out varchar2,
p_uom7			in out varchar2,
p_uom8			in out varchar2,
p_uom9			in out varchar2,
p_uom10			in out varchar2,
p_uom11			in out varchar2,
p_uom12			in out varchar2,
p_uom13			in out varchar2,
p_uom14			in out varchar2,
p_uom15			in out varchar2,
p_screen_entry_value1	in out varchar2,
p_screen_entry_value2	in out varchar2,
p_screen_entry_value3	in out varchar2,
p_screen_entry_value4	in out varchar2,
p_screen_entry_value5	in out varchar2,
p_screen_entry_value6	in out varchar2,
p_screen_entry_value7	in out varchar2,
p_screen_entry_value8	in out varchar2,
p_screen_entry_value9	in out varchar2,
p_screen_entry_value10	in out varchar2,
p_screen_entry_value11	in out varchar2,
p_screen_entry_value12	in out varchar2,
p_screen_entry_value13	in out varchar2,
p_screen_entry_value14	in out varchar2,
p_screen_entry_value15	in out varchar2);
--------------------------------------------------------------------------------
procedure populate_context_items (
--
--******************************************************************************
-- Populate form initialisation information
--******************************************************************************
--
p_business_group_id		in number,	-- User's business group
p_cost_allocation_structure 	in out varchar2);-- Keyflex structure
--------------------------------------------------------------------------------
end PAY_PAYWIEEH_PKG;

 

/
