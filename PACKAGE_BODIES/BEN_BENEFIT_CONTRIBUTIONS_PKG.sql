--------------------------------------------------------
--  DDL for Package Body BEN_BENEFIT_CONTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFIT_CONTRIBUTIONS_PKG" as
/* $Header: pybco.pkb 115.0 99/07/17 05:45:27 porting ship $ */
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
	p_delete_mode	varchar2	default 'DELETE',
	p_session_date	date		default trunc(sysdate),
					--
	-- Name of parent entity from which a deletion has been made
	p_parent_name	varchar2
					--
				) is
					--
cursor csr_orphaned_rows is
					--
	/*	Returns the set of rows whose foreign key references
		the deleted record. The decode determines which
		foreign key is used, thus the cursor applies to any
		parent entity.						*/
					--
	select	*
	from	ben_benefit_contributions_f
	where	p_parent_id	= decode (p_parent_name,
				'PAY_ELEMENT_TYPES_F', element_type_id,
				'PER_BUSINESS_GROUPS', business_group_id,
				'PER_COBRA_COVERAGE_BENEFITS_F',coverage_type)
	for update;
					--
begin
					--
<<REMOVE_ORPHANED_ROWS>>
for fetched_benefit_contribution in csr_orphaned_rows loop
					--
  -- For ZAP deletions, all child records must be deleted
  -- For date effective deletions, all children who start after the date
  -- of effective deletion must be deleted
					--
  if p_delete_mode = 'ZAP'
    or (p_delete_mode = 'DELETE'
	and p_session_date < fetched_benefit_contribution.effective_start_date )
  then
					--
    delete from ben_benefit_contributions_f
    where current of csr_orphaned_rows;
					--
  -- For date effective deletions, the current children of the now closed parent
  -- must have their end dates updated to match that of the parent
					--
  elsif (p_delete_mode = 'DELETE'
  and p_session_date between fetched_benefit_contribution.effective_start_date
                         and fetched_benefit_contribution.effective_end_date)
  then
					--
    update ben_benefit_contributions_f
    set effective_end_date = p_session_date
    where current of csr_orphaned_rows;
					--
  end if;
					--
end loop remove_orphaned_rows;
					--
end parent_deleted;
--------------------------------------------------------------------------------
end BEN_BENEFIT_CONTRIBUTIONS_PKG;

/
