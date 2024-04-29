--------------------------------------------------------
--  DDL for Package Body PAY_BACKPAY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BACKPAY_RULES_PKG" AS
/* $Header: pybkr01t.pkb 115.0 99/07/17 05:45:41 porting ship $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
-- Standard Insert procedure
--
procedure insert_row(
	p_row_id		IN OUT varchar2,
	p_defined_balance_id	number,
	p_input_value_id	number,
	p_backpay_set_id	number) is
cursor c1 is
	select	rowid
	from	pay_backpay_rules
	where	backpay_set_id		= P_BACKPAY_SET_ID
	and	defined_balance_id	= P_DEFINED_BALANCE_ID
	and	input_value_id		= P_INPUT_VALUE_ID;
begin
   	begin
     		insert into pay_backpay_rules(
			defined_balance_id,
			input_value_id,
			backpay_set_id)
		values	(p_defined_balance_id,
			p_input_value_id,
			p_backpay_set_id);
   	end;
--
   open c1;
   fetch c1 into P_ROW_ID;
   close c1;
--
end insert_row;
-----------------------------------------------------------------------------
--
-- Standard delete procedure
--
procedure delete_row(p_row_id	varchar2) is
begin
 	delete	from pay_backpay_rules
	where	rowid	= chartorowid(P_ROW_ID);
end delete_row;
-----------------------------------------------------------------------------
--
-- Standard lock procedure
--
procedure lock_row(
	p_row_id		varchar2,
	p_defined_balance_id	number,
	p_input_value_id	number,
	p_backpay_set_id	number) is
--
	cursor CUR is
		select	*
		from	pay_backpay_rules
		where	rowid	= chartorowid(P_ROW_ID)
		FOR	UPDATE OF BACKPAY_SET_ID NOWAIT;
--
	rule_rec	CUR%rowtype;
--
begin
--
   	open CUR;
--
   	fetch CUR into RULE_REC;
--
   	close CUR;
--
if 	((rule_rec.defined_balance_id = p_defined_balance_id)
	or (rule_rec.defined_balance_id is null
	and (p_defined_balance_id is null)))
and	((rule_rec.input_value_id = p_input_value_id)
	or (rule_rec.input_value_id is null
	and (p_input_value_id is null)))
and	((rule_rec.backpay_set_id = p_backpay_set_id)
	or (rule_rec.backpay_set_id is null
	and (p_backpay_set_id is null))) then
		return;		-- Row successfully locked, no changes.
end if;
--
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	app_exception.raise_exception;
--
end lock_row;
-----------------------------------------------------------------------------
--
-- Standard update procedure
--
-- NB Current business rules dictate that updates are not permitted in
-- PAYWSDBS but this is included here for completeness and possible future
-- changes to this rule.
--
procedure update_row(
	p_row_id		varchar2,
	p_defined_balance_id	number,
	p_input_value_id	number,
	p_backpay_set_id	number) is
begin
   	update	pay_backpay_rules
	set	defined_balance_id	= P_DEFINED_BALANCE_ID,
		input_value_id		= P_INPUT_VALUE_ID,
		backpay_set_id		= P_BACKPAY_SET_ID
  	where 	rowid 			= chartorowid(P_ROW_ID);
--
end update_row;
-----------------------------------------------------------------------------
procedure std_insert_checks(
	p_backpay_set_id	number,
	p_balance_type_id	number,
	p_input_value_id	number) is
	l_null			varchar2(1);
begin
--
-- Cannot have duplicate rows.
--
	begin
		select	null
		into	l_null
		from	sys.dual
		where	not exists (
			select	null
			from	pay_backpay_rules br,
				pay_defined_balances db
			where	br.backpay_set_id	= P_BACKPAY_SET_ID
			and	br.defined_balance_id	= db.defined_balance_id
			and	db.balance_type_id	= P_BALANCE_TYPE_ID
			and	br.input_value_id	= P_INPUT_VALUE_ID);
	exception
		when NO_DATA_FOUND then
			fnd_message.set_name('PAY', 'HR_7036_BACK_RULE_DUP');
			fnd_message.raise_error;
	end;
--
end std_insert_checks;
-----------------------------------------------------------------------------
procedure chk_overlap_bal_feeds(
	p_backpay_set_id 	number) is
	l_null		varchar2(1);
begin
--
-- Commit rule to db then perform this check.
-- Check to see if there are any input values feeding this balance and balances
-- fed by this input value. Then check to see if there are now duplicates of
-- this causing backpay to process a change more than once. The insert should
-- thus be disallowed if this is the case.
--
-- We have basically:
--				*
--		BAL1		-> IV1		->	BAL2
--	    _/					\
--	IV2 _					 --> 	BAL5
--	     \			*		/
--		BAL3		-> IV3		->	BAL4
--		(:BT_ID)	  (:IV_ID)
--
-- BAL3 is the balance type of the rule we are inserting (:BT_ID) and IV3 is the
-- input value of this rule.
-- We have IV2 feeding BAL3 and IV3 feeding BAL4.
-- The arrows with *'s indicate backpay rules for the current set.
-- By inserting our new backpay rule (BAL3 -> IV3) we have effectively added 2
-- new "indirect feeds" of IV2 -> BAL4 and IV2 -> BAL5. The former adds a new
-- "feed" to backpay and thus is no problem however the latter is a duplicate of
-- the other backpay rule in this set. The BAL5 balance would therefore be
-- incremented twice given just one input value. The new backpay rule is therefore
-- disallowed.
--
	begin
		select	null
		into	l_null
		from	sys.dual
		where 	not exists (
			select	bf1.input_value_id, bf2.balance_type_id
			from	pay_backpay_rules br,
				pay_defined_balances db,
				pay_balance_feeds bf1,
				pay_balance_feeds bf2
			where	bf1.balance_type_id	= db.balance_type_id
			and	db.defined_balance_id	= br.defined_balance_id
			and	br.input_value_id	= bf2.input_value_id
			and	br.backpay_set_id	= P_BACKPAY_SET_ID
			group 	by bf1.input_value_id, bf2.balance_type_id
			having	count(0) > 1);
	exception
		when NO_DATA_FOUND then
			fnd_message.set_name('PAY', 'HR_7037_BACK_RULES_DUP_BAL');
			fnd_message.raise_error;
	end;
--
end chk_overlap_bal_feeds;
-----------------------------------------------------------------------------
END PAY_BACKPAY_RULES_PKG;

/
