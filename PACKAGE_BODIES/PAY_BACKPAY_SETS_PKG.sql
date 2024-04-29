--------------------------------------------------------
--  DDL for Package Body PAY_BACKPAY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BACKPAY_SETS_PKG" AS
/* $Header: pybks01t.pkb 115.1 99/07/17 05:45:47 porting ship  $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
procedure check_name_uniqueness(
	p_bus_grp_id	number,
	p_set_name	varchar2,
	p_set_id	number) is
	l_null		varchar2(1);
--
-- Check that backpay set name is unique within business group.
-- Error if it is not.
--
begin
	if p_set_id is not null then
--
-- Updating.
--
		begin
			select	null
			into	l_null
			from	sys.dual
			where	not exists (
				select 	null
				from	pay_backpay_sets s
				where	s.business_group_id + 0	= P_BUS_GRP_ID
				and	s.backpay_set_name	= P_SET_NAME
				and	s.backpay_set_id	<> P_SET_ID);
		exception
			when NO_DATA_FOUND then
				fnd_message.set_name('PAY',
					'PAY_7883_USER_TABLE_UNIQUE');
				fnd_message.raise_error;
		end;
	else
--
-- Inserting.
--
		begin
			select	null
			into	l_null
			from	sys.dual
			where	not exists (
				select 	null
				from	pay_backpay_sets s
				where	s.business_group_id + 0	= P_BUS_GRP_ID
				and	s.backpay_set_name	= P_SET_NAME);
		exception
			when NO_DATA_FOUND then
				fnd_message.set_name('PAY',
					'PAY_7883_USER_TABLE_UNIQUE');
				fnd_message.raise_error;
		end;
	end if;
--
end check_name_uniqueness;
-----------------------------------------------------------------------------
END PAY_BACKPAY_SETS_PKG;

/
