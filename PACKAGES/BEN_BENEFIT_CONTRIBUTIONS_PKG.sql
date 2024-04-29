--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_CONTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_CONTRIBUTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pybco.pkh 115.0 99/07/17 05:45:30 porting ship $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved			       |
+==============================================================================+

Name
	Benefit Contributions Table Handler
Purpose
	To interface with the Benefit Contributions entity and maintain its
	integrity
History
	27 Jan 94	N Simpson	Created
								*/
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
					--
--***************************************************************************
--* Handles the case when a referenced master entity has one of its records *
--* deleted or shut down						    *
--***************************************************************************
					--
-- Parameters are:
					--
	-- Identifier of parent record
	p_parent_id	number,
					--
	-- Date Track deletion mode
	p_delete_mode	varchar2	default 'DELETE',
					--
	-- Effective date
	p_session_date	date		default trunc(sysdate),
					--
	-- Name of parent entity from which a deletion has been made
	p_parent_name	varchar2
					--
				);
--------------------------------------------------------------------------------
end BEN_BENEFIT_CONTRIBUTIONS_PKG;

 

/
