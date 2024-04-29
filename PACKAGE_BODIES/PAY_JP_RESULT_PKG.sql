--------------------------------------------------------
--  DDL for Package Body PAY_JP_RESULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_RESULT_PKG" AS
/* $Header: pyjprslt.pkb 120.3 2006/12/06 06:34:43 keyazawa noship $ */
--
-- Current ORACLE has so many bugs when using object.
-- Avoid using so many objects, or cause unexpected errors.
-- These problems will be fixed after 8.2.0.0.0.
--
-- This function returns result("Result Value" and "Balance Value") of "RUN".
-- Available action_type is as follows.
--   B : Balance Adjustment
--   F : Advance Pay(?)
--   I : Balance Initialization
--   Q : QuickPay Run
--   R : Run
--   V : Reversal
--   Z : Purge(?)
--
--
PROCEDURE result_values_internal(
	p_assignment_action_id	IN NUMBER,
	p_effective_date	IN DATE,
	p_result_values_by_iv	IN OUT NOCOPY result_values_by_iv_t)
IS
	--
	-- Bulk Result informations.
	--
	-- To execute bulk fetch, nested loop(or VARRAY) is mandatory.
	--
	TYPE result_values_t IS TABLE OF PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
	TYPE data_types_t IS TABLE OF VARCHAR2(30);
	/* BUG1899306: Modified not to use an object type. ***********
	l_input_value_ids	pay_jp_numbers_t;
	*********************************************************** */
	TYPE numbers_t IS TABLE OF NUMBER;
	l_input_value_ids	numbers_t;
	l_data_types		data_types_t;
	l_result_values		result_values_t;
	CURSOR csr_result_value IS
/* Removed the hint to fix Bug# 5464717. */
		select
			piv.input_value_id,
			decode(substrb(piv.uom,1,1),'M','N','N','N','I','N','H','N','D','D','T')	DATA_TYPE,
			decode(
				/* N(Number), T(Text), D(Date) */
				decode(substrb(piv.uom,1,1),'M','N','N','N','I','N','H','N','D','D','T'),
				'N',fnd_number.number_to_canonical(
					sum(
						decode(
							decode(substrb(piv.uom,1,1),'M','N','N','N','I','N','H','N','D','D','T'),
							/* BUG3038738: Modified not to return result value if uom is number type.  **
							** When UOM of that result_value is number type, and it exceeds 20 digits  **
							** after the decimal point, ORA-06502 error occurs in                      **
							** fnd_number.canonical_to_number() function. Because fnd_number uses a    **
							** canonical_mask with only 20 decimal places against result_value with up **
							** to 38 decimal places. Currently, result_value for number type from this **
							** cursor has not been used anywhere.                                      **
							'N',fnd_number.canonical_to_number(prrv.result_value),
							********************************************************************************* */
							'N',
                decode(substrb(piv.uom,1,1),'N',0,
                fnd_number.canonical_to_number(prrv.result_value)),
							NULL
						)
					)
				),
				min(distinct prrv.result_value))	RESULT_VALUE
		from
			pay_run_result_values prrv, -- Run result value
			pay_run_results       prr,  -- Run result
			pay_input_values_f    piv
		where	prr.assignment_action_id = p_assignment_action_id
		and	prr.status in ('P','PA')
		and	prrv.run_result_id = prr.run_result_id
		and	piv.input_value_id = prrv.input_value_id
		and	p_effective_date
			between piv.effective_start_date and piv.effective_end_date
		group by
			piv.input_value_id,
			decode(substrb(piv.uom,1,1),'M','N','N','N','I','N','H','N','D','D','T');
	--
	-- Other local variables.
	--
	l_result_values_by_iv	result_values_by_iv_t;
	l_input_value_id	NUMBER;
	l_data_type		hr_lookups.LOOKUP_CODE%TYPE;
	l_result_value		PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
BEGIN
	--
	-- Get all result values with bulk collect.
	--
	open csr_result_value;
	fetch csr_result_value bulk collect into l_input_value_ids,l_data_types,l_result_values;
	close csr_result_value;
	--
	-- Convert result values from nexted loop to index-by PL/SQL table.
	--
	for i in 1..l_input_value_ids.count loop
		l_input_value_id	:= l_input_value_ids(i);
		l_data_type		:= l_data_types(i);
		l_result_value		:= l_result_values(i);
		--
		-- Setup result_values indexed by input_value_id for current assignment_action_id.
		--
		l_result_values_by_iv(l_input_value_id).data_type	:= l_data_type;
		l_result_values_by_iv(l_input_value_id).result_value	:= l_result_value;
		--
		-- Unite result_values indexed by input_value_id of current assignment_action_id
		-- to the p_result_values_by_iv input variable.
		--
		if p_result_values_by_iv.exists(l_input_value_id) then
			if l_result_value is not NULL then
				if p_result_values_by_iv(l_input_value_id).result_value is NULL then
					p_result_values_by_iv(l_input_value_id).result_value := l_result_value;
				else
					if l_data_type = 'N' then
						p_result_values_by_iv(l_input_value_id).result_value
							:= fnd_number.number_to_canonical(
								  fnd_number.canonical_to_number(p_result_values_by_iv(l_input_value_id).result_value)
								+ fnd_number.canonical_to_number(l_result_value));
					else
						p_result_values_by_iv(l_input_value_id).result_value
							:= least(p_result_values_by_iv(l_input_value_id).result_value,l_result_value);
					end if;
				end if;
			end if;
		else
			p_result_values_by_iv(l_input_value_id).data_type	:= l_data_type;
			p_result_values_by_iv(l_input_value_id).result_value	:= l_result_value;
		end if;
	end loop;
END result_values_internal;
--
PROCEDURE balance_values_internal(
	p_result_values_by_iv	IN result_values_by_iv_t,
	p_balance_type_ids	IN balance_type_ids_t,
	p_feed_checking_date	IN DATE,
	p_balance_values_by_bal	IN OUT NOCOPY balance_values_by_bal_t)
IS
	--
	-- Bulk Feed informations.
	--
	/* BUG1899306: Modified not to use EXECUTE IMMEDIATE. ************************
	-- Bulk collect is applied to this function to raise performance.
	-- Remember that binding SQL in PL/SQL is very slow, that is, fetch is very slow.
	-- Additionally, when using bulk fetch with EXECUTE IMMEDIATE,
	-- output variables must be declared with "CREATE TYPE".
	--
	l_feed_bals		pay_jp_numbers_t;
	l_feed_ivs		pay_jp_numbers_t;
	l_feed_scales		pay_jp_numbers_t;
	*************************************************************************** */
	--
	-- BUG1899306
	--
	-- Since using object type is a violation of Apps standards, we cannot use
	-- EXECUTE IMMEDIATE. That's why fetching balance feed informations was modified
	-- to using DBMS_SQL package.
	--
	l_feed_bals		dbms_sql.Number_Table;
	l_feed_ivs		dbms_sql.Number_Table;
	l_feed_scales		dbms_sql.Number_Table;
	l_stmt_str		VARCHAR2(32767);
	l_cur_hdl		NUMBER;
	l_rows_processed	NUMBER;
	l_idx			NUMBER := 0;
	--
	-- Other local variables.
	--
	l_index			NUMBER;
	l_balance_type_id	NUMBER;
	l_concat_bal		VARCHAR2(32767);
	l_input_value_id	NUMBER;
	l_concat_iv		VARCHAR2(32767);
	l_result_value		PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
BEGIN
	--
	-- Setup balance values.
	--
	-- Initialize output variable "p_balance_values_by_bal".
	--
	if p_balance_type_ids is not NULL then
		l_index := p_balance_type_ids.first;
		while l_index is not NULL loop
			l_balance_type_id := p_balance_type_ids(l_index);
			if l_balance_type_id is not NULL then
				--
				-- If not instantiated, default as "0".
				--
				if not p_balance_values_by_bal.exists(l_balance_type_id) then
					p_balance_values_by_bal(l_balance_type_id) := 0;
				end if;
				--
				-- Construct balance_type_id list used by EXECUTE IMMEDIATE statement below.
				--
				if l_concat_bal is NULL then
					l_concat_bal := to_char(l_balance_type_id);
				else
					l_concat_bal := l_concat_bal || ',' || to_char(l_balance_type_id);
				end if;
			end if;
			l_index := p_balance_type_ids.next(l_index);
		end loop;
	end if;
	--
	-- Construct input_value_id lists used by EXECUTE IMMEDIATE statement below.
	--
	if l_concat_bal is not NULL then
		l_input_value_id	:= p_result_values_by_iv.first;
		while l_input_value_id is not NULL loop
			--
			-- Balance is available only for data_type = 'N'(UOM = M,N,I,etc...).
			--
			if p_result_values_by_iv(l_input_value_id).data_type = 'N' then
				if l_concat_iv is NULL then
					l_concat_iv := to_char(l_input_value_id);
				else
					l_concat_iv := l_concat_iv || ',' || to_char(l_input_value_id);
				end if;
			end if;
			l_input_value_id := p_result_values_by_iv.next(l_input_value_id);
		end loop;
	end if;
	--
	-- Setup balance values to output variable "p_balance_values_by_bal".
	-- When no balance required(p_concat_bal is NULL) or no results with data_type=Number(p_concat_iv is NULL),
	-- the following code is skipped.
	--
	if l_concat_iv is not NULL then
		--
		-- Bulk fetch minimum balance feed informations.
		--
		/* BUG1899306: modified not to use EXECUTE IMMEDIATE ***********************************
		execute immediate
			'BEGIN
				select	pbf.balance_type_id,
					pbf.input_value_id,
					pbf.scale
				bulk collect into
					:b_feed_bal,
					:b_feed_iv,
					:b_feed_scale
				from	pay_balance_feeds_f	pbf
				where	pbf.balance_type_id in (' || l_concat_bal || ')
				and	pbf.input_value_id in (' || l_concat_iv || ')
				and	:b_feed_cheking_date
					between pbf.effective_start_date and pbf.effective_end_date;
			END;'
		using	OUT l_feed_bals,
			OUT l_feed_ivs,
			OUT l_feed_scales,
			IN p_feed_checking_date;
		************************************************************************************ */
		--
		-- BUG1899306: Fetch balance feed informations using DBMS_SQL package.
		--
		l_stmt_str := '	select	pbf.balance_type_id,
					pbf.input_value_id,
					pbf.scale
				from	pay_balance_feeds_f	pbf
				where	pbf.balance_type_id in (' || l_concat_bal || ')
				and	pbf.input_value_id in (' || l_concat_iv || ')
				and	:b_feed_cheking_date
				between pbf.effective_start_date and pbf.effective_end_date';
		l_cur_hdl := dbms_sql.open_cursor;
		dbms_sql.parse(l_cur_hdl, l_stmt_str, DBMS_SQL.NATIVE);
		dbms_sql.bind_variable(l_cur_hdl, 'b_feed_cheking_date', p_feed_checking_date);
		dbms_sql.define_array(l_cur_hdl, 1, l_feed_bals, 10, l_idx);
		dbms_sql.define_array(l_cur_hdl, 2, l_feed_ivs, 10, l_idx);
		dbms_sql.define_array(l_cur_hdl, 3, l_feed_scales, 10, l_idx);
		l_rows_processed := dbms_sql.execute(l_cur_hdl);
		loop
			l_rows_processed := dbms_sql.fetch_rows(l_cur_hdl);
			dbms_sql.column_value(l_cur_hdl, 1, l_feed_bals);
			dbms_sql.column_value(l_cur_hdl, 2, l_feed_ivs);
			dbms_sql.column_value(l_cur_hdl, 3, l_feed_scales);
			exit when l_rows_processed <> 10;
		end loop;
		dbms_sql.close_cursor(l_cur_hdl);
		--
		-- l_feed_bals is not NULL even when no records fetched in above SQL statement.
		-- So not necessary to check l_feed_bals is NULL or not.
		--
		if l_feed_bals.count > 0 then
			for i in l_feed_bals.first..l_feed_bals.last loop
				--
				-- No need to check collection method "EXISTS".
				--
				l_result_value := p_result_values_by_iv(l_feed_ivs(i)).result_value;
				if l_result_value is not NULL and l_result_value <> 0 then
					p_balance_values_by_bal(l_feed_bals(i)) := p_balance_values_by_bal(l_feed_bals(i))
										 + fnd_number.canonical_to_number(l_result_value) * l_feed_scales(i);
				end if;
			end loop;
		end if;
	end if;
END balance_values_internal;
--
PROCEDURE run_internal(
	p_assignment_action_id	IN NUMBER,
	p_feed_checking_date	IN DATE,
	p_balance_type_ids	IN balance_type_ids_t,
	p_result_values_by_iv	IN OUT NOCOPY result_values_by_iv_t,
	p_balance_values_by_bal	IN OUT NOCOPY balance_values_by_bal_t)
IS
BEGIN
	result_values_internal(
		p_assignment_action_id	=> p_assignment_action_id,
		p_effective_date	=> p_feed_checking_date,
		p_result_values_by_iv	=> p_result_values_by_iv);
	balance_values_internal(
		p_result_values_by_iv	=> p_result_values_by_iv,
		p_balance_type_ids	=> p_balance_type_ids,
		p_feed_checking_date	=> p_feed_checking_date,
		p_balance_values_by_bal	=> p_balance_values_by_bal);
END run_internal;
--
-- Function result_value
--
FUNCTION result_value(
	p_result_values_by_iv	IN result_values_by_iv_t,
	p_input_value_id	IN NUMBER) RETURN VARCHAR2
IS
	l_result_value	PAY_RUN_RESULT_VALUES.RESULT_VALUE%TYPE;
BEGIN
	if p_input_value_id is not NULL then
		if p_result_values_by_iv.exists(p_input_value_id) then
			l_result_value := p_result_values_by_iv(p_input_value_id).result_value;
		end if;
	end if;
	--
	-- Return value.
	--
	return l_result_value;
END result_value;
--
-- Function balance_value
--
FUNCTION balance_value(
	p_balance_values_by_bal	IN balance_values_by_bal_t,
	p_balance_type_id	IN NUMBER) RETURN NUMBER
IS
	l_balance_value	NUMBER;
BEGIN
	if p_balance_type_id is not NULL then
		if p_balance_values_by_bal.exists(p_balance_type_id) then
			l_balance_value := p_balance_values_by_bal(p_balance_type_id);
		end if;
	end if;
	--
	-- Return value.
	--
	return l_balance_value;
END balance_value;
--
-- Procedure convert_to_table
--
PROCEDURE convert_to_table(
	p_balance_type_id1	IN NUMBER,
	p_balance_type_id2	IN NUMBER,
	p_balance_type_id3	IN NUMBER,
	p_balance_type_id4	IN NUMBER,
	p_balance_type_id5	IN NUMBER,
	p_balance_type_id6	IN NUMBER,
	p_balance_type_id7	IN NUMBER,
	p_balance_type_id8	IN NUMBER,
	p_balance_type_id9	IN NUMBER,
	p_balance_type_id10	IN NUMBER,
	p_balance_type_id11	IN NUMBER,
	p_balance_type_id12	IN NUMBER,
	p_balance_type_id13	IN NUMBER,
	p_balance_type_id14	IN NUMBER,
	p_balance_type_id15	IN NUMBER,
	p_balance_type_id16	IN NUMBER,
	p_balance_type_id17	IN NUMBER,
	p_balance_type_id18	IN NUMBER,
	p_balance_type_id19	IN NUMBER,
	p_balance_type_id20	IN NUMBER,
	p_balance_type_id21	IN NUMBER,
	p_balance_type_id22	IN NUMBER,
	p_balance_type_id23	IN NUMBER,
	p_balance_type_id24	IN NUMBER,
	p_balance_type_id25	IN NUMBER,
	p_balance_type_id26	IN NUMBER,
	p_balance_type_id27	IN NUMBER,
	p_balance_type_id28	IN NUMBER,
	p_balance_type_id29	IN NUMBER,
	p_balance_type_id30	IN NUMBER,
	p_balance_type_ids	OUT NOCOPY balance_type_ids_t)
IS
	PROCEDURE set_to_table(
		p_balance_type_id	IN NUMBER)
	IS
	BEGIN
		if p_balance_type_id is not NULL then
			if p_balance_type_ids is NULL then
				p_balance_type_ids := balance_type_ids_t();
			else
				p_balance_type_ids.extend;
				p_balance_type_ids(p_balance_type_ids.count) := p_balance_type_id;
			end if;
		end if;
	END set_to_table;
BEGIN
	set_to_table(p_balance_type_id1);
	set_to_table(p_balance_type_id1);
	set_to_table(p_balance_type_id2);
	set_to_table(p_balance_type_id3);
	set_to_table(p_balance_type_id4);
	set_to_table(p_balance_type_id5);
	set_to_table(p_balance_type_id6);
	set_to_table(p_balance_type_id7);
	set_to_table(p_balance_type_id8);
	set_to_table(p_balance_type_id9);
	set_to_table(p_balance_type_id10);
	set_to_table(p_balance_type_id11);
	set_to_table(p_balance_type_id12);
	set_to_table(p_balance_type_id13);
	set_to_table(p_balance_type_id14);
	set_to_table(p_balance_type_id15);
	set_to_table(p_balance_type_id16);
	set_to_table(p_balance_type_id17);
	set_to_table(p_balance_type_id18);
	set_to_table(p_balance_type_id19);
	set_to_table(p_balance_type_id20);
	set_to_table(p_balance_type_id21);
	set_to_table(p_balance_type_id22);
	set_to_table(p_balance_type_id23);
	set_to_table(p_balance_type_id24);
	set_to_table(p_balance_type_id25);
	set_to_table(p_balance_type_id26);
	set_to_table(p_balance_type_id27);
	set_to_table(p_balance_type_id28);
	set_to_table(p_balance_type_id29);
	set_to_table(p_balance_type_id30);
END convert_to_table;
/* BUG1899306: Obsoleted run and prepay functions *************************
--
-- Function run
--
FUNCTION run(
	p_assignment_action_id	IN NUMBER,
	p_input_value_id1	IN NUMBER DEFAULT NULL,
	p_input_value_id2	IN NUMBER DEFAULT NULL,
	p_input_value_id3	IN NUMBER DEFAULT NULL,
	p_input_value_id4	IN NUMBER DEFAULT NULL,
	p_input_value_id5	IN NUMBER DEFAULT NULL,
	p_input_value_id6	IN NUMBER DEFAULT NULL,
	p_input_value_id7	IN NUMBER DEFAULT NULL,
	p_input_value_id8	IN NUMBER DEFAULT NULL,
	p_input_value_id9	IN NUMBER DEFAULT NULL,
	p_input_value_id10	IN NUMBER DEFAULT NULL,
	p_input_value_id11	IN NUMBER DEFAULT NULL,
	p_input_value_id12	IN NUMBER DEFAULT NULL,
	p_input_value_id13	IN NUMBER DEFAULT NULL,
	p_input_value_id14	IN NUMBER DEFAULT NULL,
	p_input_value_id15	IN NUMBER DEFAULT NULL,
	p_input_value_id16	IN NUMBER DEFAULT NULL,
	p_input_value_id17	IN NUMBER DEFAULT NULL,
	p_input_value_id18	IN NUMBER DEFAULT NULL,
	p_input_value_id19	IN NUMBER DEFAULT NULL,
	p_input_value_id20	IN NUMBER DEFAULT NULL,
	p_input_value_id21	IN NUMBER DEFAULT NULL,
	p_input_value_id22	IN NUMBER DEFAULT NULL,
	p_input_value_id23	IN NUMBER DEFAULT NULL,
	p_input_value_id24	IN NUMBER DEFAULT NULL,
	p_input_value_id25	IN NUMBER DEFAULT NULL,
	p_input_value_id26	IN NUMBER DEFAULT NULL,
	p_input_value_id27	IN NUMBER DEFAULT NULL,
	p_input_value_id28	IN NUMBER DEFAULT NULL,
	p_input_value_id29	IN NUMBER DEFAULT NULL,
	p_input_value_id30	IN NUMBER DEFAULT NULL,
	p_input_value_id31	IN NUMBER DEFAULT NULL,
	p_input_value_id32	IN NUMBER DEFAULT NULL,
	p_input_value_id33	IN NUMBER DEFAULT NULL,
	p_input_value_id34	IN NUMBER DEFAULT NULL,
	p_input_value_id35	IN NUMBER DEFAULT NULL,
	p_input_value_id36	IN NUMBER DEFAULT NULL,
	p_input_value_id37	IN NUMBER DEFAULT NULL,
	p_input_value_id38	IN NUMBER DEFAULT NULL,
	p_input_value_id39	IN NUMBER DEFAULT NULL,
	p_input_value_id40	IN NUMBER DEFAULT NULL,
	p_input_value_id41	IN NUMBER DEFAULT NULL,
	p_input_value_id42	IN NUMBER DEFAULT NULL,
	p_input_value_id43	IN NUMBER DEFAULT NULL,
	p_input_value_id44	IN NUMBER DEFAULT NULL,
	p_input_value_id45	IN NUMBER DEFAULT NULL,
	p_input_value_id46	IN NUMBER DEFAULT NULL,
	p_input_value_id47	IN NUMBER DEFAULT NULL,
	p_input_value_id48	IN NUMBER DEFAULT NULL,
	p_input_value_id49	IN NUMBER DEFAULT NULL,
	p_input_value_id50	IN NUMBER DEFAULT NULL,
	p_input_value_id51	IN NUMBER DEFAULT NULL,
	p_input_value_id52	IN NUMBER DEFAULT NULL,
	p_input_value_id53	IN NUMBER DEFAULT NULL,
	p_input_value_id54	IN NUMBER DEFAULT NULL,
	p_input_value_id55	IN NUMBER DEFAULT NULL,
	p_input_value_id56	IN NUMBER DEFAULT NULL,
	p_input_value_id57	IN NUMBER DEFAULT NULL,
	p_input_value_id58	IN NUMBER DEFAULT NULL,
	p_input_value_id59	IN NUMBER DEFAULT NULL,
	p_input_value_id60	IN NUMBER DEFAULT NULL,
	p_input_value_id61	IN NUMBER DEFAULT NULL,
	p_input_value_id62	IN NUMBER DEFAULT NULL,
	p_input_value_id63	IN NUMBER DEFAULT NULL,
	p_input_value_id64	IN NUMBER DEFAULT NULL,
	p_input_value_id65	IN NUMBER DEFAULT NULL,
	p_input_value_id66	IN NUMBER DEFAULT NULL,
	p_input_value_id67	IN NUMBER DEFAULT NULL,
	p_input_value_id68	IN NUMBER DEFAULT NULL,
	p_input_value_id69	IN NUMBER DEFAULT NULL,
	p_input_value_id70	IN NUMBER DEFAULT NULL,
	p_input_value_id71	IN NUMBER DEFAULT NULL,
	p_input_value_id72	IN NUMBER DEFAULT NULL,
	p_input_value_id73	IN NUMBER DEFAULT NULL,
	p_input_value_id74	IN NUMBER DEFAULT NULL,
	p_input_value_id75	IN NUMBER DEFAULT NULL,
	p_input_value_id76	IN NUMBER DEFAULT NULL,
	p_input_value_id77	IN NUMBER DEFAULT NULL,
	p_input_value_id78	IN NUMBER DEFAULT NULL,
	p_input_value_id79	IN NUMBER DEFAULT NULL,
	p_input_value_id80	IN NUMBER DEFAULT NULL,
	p_input_value_id81	IN NUMBER DEFAULT NULL,
	p_input_value_id82	IN NUMBER DEFAULT NULL,
	p_input_value_id83	IN NUMBER DEFAULT NULL,
	p_input_value_id84	IN NUMBER DEFAULT NULL,
	p_input_value_id85	IN NUMBER DEFAULT NULL,
	p_input_value_id86	IN NUMBER DEFAULT NULL,
	p_input_value_id87	IN NUMBER DEFAULT NULL,
	p_input_value_id88	IN NUMBER DEFAULT NULL,
	p_input_value_id89	IN NUMBER DEFAULT NULL,
	p_input_value_id90	IN NUMBER DEFAULT NULL,
	p_input_value_id91	IN NUMBER DEFAULT NULL,
	p_input_value_id92	IN NUMBER DEFAULT NULL,
	p_input_value_id93	IN NUMBER DEFAULT NULL,
	p_input_value_id94	IN NUMBER DEFAULT NULL,
	p_input_value_id95	IN NUMBER DEFAULT NULL,
	p_input_value_id96	IN NUMBER DEFAULT NULL,
	p_input_value_id97	IN NUMBER DEFAULT NULL,
	p_input_value_id98	IN NUMBER DEFAULT NULL,
	p_input_value_id99	IN NUMBER DEFAULT NULL,
	p_input_value_id100	IN NUMBER DEFAULT NULL,
	p_balance_type_id1	IN NUMBER DEFAULT NULL,
	p_balance_type_id2	IN NUMBER DEFAULT NULL,
	p_balance_type_id3	IN NUMBER DEFAULT NULL,
	p_balance_type_id4	IN NUMBER DEFAULT NULL,
	p_balance_type_id5	IN NUMBER DEFAULT NULL,
	p_balance_type_id6	IN NUMBER DEFAULT NULL,
	p_balance_type_id7	IN NUMBER DEFAULT NULL,
	p_balance_type_id8	IN NUMBER DEFAULT NULL,
	p_balance_type_id9	IN NUMBER DEFAULT NULL,
	p_balance_type_id10	IN NUMBER DEFAULT NULL,
	p_balance_type_id11	IN NUMBER DEFAULT NULL,
	p_balance_type_id12	IN NUMBER DEFAULT NULL,
	p_balance_type_id13	IN NUMBER DEFAULT NULL,
	p_balance_type_id14	IN NUMBER DEFAULT NULL,
	p_balance_type_id15	IN NUMBER DEFAULT NULL,
	p_balance_type_id16	IN NUMBER DEFAULT NULL,
	p_balance_type_id17	IN NUMBER DEFAULT NULL,
	p_balance_type_id18	IN NUMBER DEFAULT NULL,
	p_balance_type_id19	IN NUMBER DEFAULT NULL,
	p_balance_type_id20	IN NUMBER DEFAULT NULL,
	p_balance_type_id21	IN NUMBER DEFAULT NULL,
	p_balance_type_id22	IN NUMBER DEFAULT NULL,
	p_balance_type_id23	IN NUMBER DEFAULT NULL,
	p_balance_type_id24	IN NUMBER DEFAULT NULL,
	p_balance_type_id25	IN NUMBER DEFAULT NULL,
	p_balance_type_id26	IN NUMBER DEFAULT NULL,
	p_balance_type_id27	IN NUMBER DEFAULT NULL,
	p_balance_type_id28	IN NUMBER DEFAULT NULL,
	p_balance_type_id29	IN NUMBER DEFAULT NULL,
	p_balance_type_id30	IN NUMBER DEFAULT NULL) RETURN pay_jp_result_run_t
IS
	--
	-- Payroll action information.
	--
	CURSOR csr_pact IS
		select	ppa.effective_date
		from	pay_payroll_actions	ppa,
			pay_assignment_actions	paa
		where	paa.assignment_action_id = p_assignment_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id;
	l_pact	csr_pact%ROWTYPE;
	--
	-- Other local variables.
	--
	l_balance_type_ids	balance_type_ids_t;
	l_result_values_by_iv	result_values_by_iv_t;
	l_balance_values_by_bal	balance_values_by_bal_t;
BEGIN
	--
	-- Get payroll action information.
	--
	open csr_pact;
	fetch csr_pact into l_pact;
	if csr_pact%FOUND then
		--
		-- Convert input parameters to VARRAY variable.
		--
		convert_to_table(
			p_balance_type_id1	=> p_balance_type_id1,
			p_balance_type_id2	=> p_balance_type_id2,
			p_balance_type_id3	=> p_balance_type_id3,
			p_balance_type_id4	=> p_balance_type_id4,
			p_balance_type_id5	=> p_balance_type_id5,
			p_balance_type_id6	=> p_balance_type_id6,
			p_balance_type_id7	=> p_balance_type_id7,
			p_balance_type_id8	=> p_balance_type_id8,
			p_balance_type_id9	=> p_balance_type_id9,
			p_balance_type_id10	=> p_balance_type_id10,
			p_balance_type_id11	=> p_balance_type_id11,
			p_balance_type_id12	=> p_balance_type_id12,
			p_balance_type_id13	=> p_balance_type_id13,
			p_balance_type_id14	=> p_balance_type_id14,
			p_balance_type_id15	=> p_balance_type_id15,
			p_balance_type_id16	=> p_balance_type_id16,
			p_balance_type_id17	=> p_balance_type_id17,
			p_balance_type_id18	=> p_balance_type_id18,
			p_balance_type_id19	=> p_balance_type_id19,
			p_balance_type_id20	=> p_balance_type_id20,
			p_balance_type_id21	=> p_balance_type_id21,
			p_balance_type_id22	=> p_balance_type_id22,
			p_balance_type_id23	=> p_balance_type_id23,
			p_balance_type_id24	=> p_balance_type_id24,
			p_balance_type_id25	=> p_balance_type_id25,
			p_balance_type_id26	=> p_balance_type_id26,
			p_balance_type_id27	=> p_balance_type_id27,
			p_balance_type_id28	=> p_balance_type_id28,
			p_balance_type_id29	=> p_balance_type_id29,
			p_balance_type_id30	=> p_balance_type_id30,
			p_balance_type_ids	=> l_balance_type_ids);
		--
		-- Get the following informations.
		--   1. All Result Values
		--   2. Balance Values specified by l_balance_type_ids.
		-- Balance value is returned as "0"(not "NULL" value) when no results for balance_type_id.
		--
		run_internal(
			p_assignment_action_id	=> p_assignment_action_id,
			p_feed_checking_date	=> l_pact.effective_date,
			p_balance_type_ids	=> l_balance_type_ids,
			p_result_values_by_iv	=> l_result_values_by_iv,
			p_balance_values_by_bal	=> l_balance_values_by_bal);
	end if;
	close csr_pact;
	--
	-- Return value.
	--
	return pay_jp_result_run_t(
		result_value(l_result_values_by_iv,p_input_value_id1),
		result_value(l_result_values_by_iv,p_input_value_id2),
		result_value(l_result_values_by_iv,p_input_value_id3),
		result_value(l_result_values_by_iv,p_input_value_id4),
		result_value(l_result_values_by_iv,p_input_value_id5),
		result_value(l_result_values_by_iv,p_input_value_id6),
		result_value(l_result_values_by_iv,p_input_value_id7),
		result_value(l_result_values_by_iv,p_input_value_id8),
		result_value(l_result_values_by_iv,p_input_value_id9),
		result_value(l_result_values_by_iv,p_input_value_id10),
		result_value(l_result_values_by_iv,p_input_value_id11),
		result_value(l_result_values_by_iv,p_input_value_id12),
		result_value(l_result_values_by_iv,p_input_value_id13),
		result_value(l_result_values_by_iv,p_input_value_id14),
		result_value(l_result_values_by_iv,p_input_value_id15),
		result_value(l_result_values_by_iv,p_input_value_id16),
		result_value(l_result_values_by_iv,p_input_value_id17),
		result_value(l_result_values_by_iv,p_input_value_id18),
		result_value(l_result_values_by_iv,p_input_value_id19),
		result_value(l_result_values_by_iv,p_input_value_id20),
		result_value(l_result_values_by_iv,p_input_value_id21),
		result_value(l_result_values_by_iv,p_input_value_id22),
		result_value(l_result_values_by_iv,p_input_value_id23),
		result_value(l_result_values_by_iv,p_input_value_id24),
		result_value(l_result_values_by_iv,p_input_value_id25),
		result_value(l_result_values_by_iv,p_input_value_id26),
		result_value(l_result_values_by_iv,p_input_value_id27),
		result_value(l_result_values_by_iv,p_input_value_id28),
		result_value(l_result_values_by_iv,p_input_value_id29),
		result_value(l_result_values_by_iv,p_input_value_id30),
		result_value(l_result_values_by_iv,p_input_value_id31),
		result_value(l_result_values_by_iv,p_input_value_id32),
		result_value(l_result_values_by_iv,p_input_value_id33),
		result_value(l_result_values_by_iv,p_input_value_id34),
		result_value(l_result_values_by_iv,p_input_value_id35),
		result_value(l_result_values_by_iv,p_input_value_id36),
		result_value(l_result_values_by_iv,p_input_value_id37),
		result_value(l_result_values_by_iv,p_input_value_id38),
		result_value(l_result_values_by_iv,p_input_value_id39),
		result_value(l_result_values_by_iv,p_input_value_id40),
		result_value(l_result_values_by_iv,p_input_value_id41),
		result_value(l_result_values_by_iv,p_input_value_id42),
		result_value(l_result_values_by_iv,p_input_value_id43),
		result_value(l_result_values_by_iv,p_input_value_id44),
		result_value(l_result_values_by_iv,p_input_value_id45),
		result_value(l_result_values_by_iv,p_input_value_id46),
		result_value(l_result_values_by_iv,p_input_value_id47),
		result_value(l_result_values_by_iv,p_input_value_id48),
		result_value(l_result_values_by_iv,p_input_value_id49),
		result_value(l_result_values_by_iv,p_input_value_id50),
		result_value(l_result_values_by_iv,p_input_value_id51),
		result_value(l_result_values_by_iv,p_input_value_id52),
		result_value(l_result_values_by_iv,p_input_value_id53),
		result_value(l_result_values_by_iv,p_input_value_id54),
		result_value(l_result_values_by_iv,p_input_value_id55),
		result_value(l_result_values_by_iv,p_input_value_id56),
		result_value(l_result_values_by_iv,p_input_value_id57),
		result_value(l_result_values_by_iv,p_input_value_id58),
		result_value(l_result_values_by_iv,p_input_value_id59),
		result_value(l_result_values_by_iv,p_input_value_id60),
		result_value(l_result_values_by_iv,p_input_value_id61),
		result_value(l_result_values_by_iv,p_input_value_id62),
		result_value(l_result_values_by_iv,p_input_value_id63),
		result_value(l_result_values_by_iv,p_input_value_id64),
		result_value(l_result_values_by_iv,p_input_value_id65),
		result_value(l_result_values_by_iv,p_input_value_id66),
		result_value(l_result_values_by_iv,p_input_value_id67),
		result_value(l_result_values_by_iv,p_input_value_id68),
		result_value(l_result_values_by_iv,p_input_value_id69),
		result_value(l_result_values_by_iv,p_input_value_id70),
		result_value(l_result_values_by_iv,p_input_value_id71),
		result_value(l_result_values_by_iv,p_input_value_id72),
		result_value(l_result_values_by_iv,p_input_value_id73),
		result_value(l_result_values_by_iv,p_input_value_id74),
		result_value(l_result_values_by_iv,p_input_value_id75),
		result_value(l_result_values_by_iv,p_input_value_id76),
		result_value(l_result_values_by_iv,p_input_value_id77),
		result_value(l_result_values_by_iv,p_input_value_id78),
		result_value(l_result_values_by_iv,p_input_value_id79),
		result_value(l_result_values_by_iv,p_input_value_id80),
		result_value(l_result_values_by_iv,p_input_value_id81),
		result_value(l_result_values_by_iv,p_input_value_id82),
		result_value(l_result_values_by_iv,p_input_value_id83),
		result_value(l_result_values_by_iv,p_input_value_id84),
		result_value(l_result_values_by_iv,p_input_value_id85),
		result_value(l_result_values_by_iv,p_input_value_id86),
		result_value(l_result_values_by_iv,p_input_value_id87),
		result_value(l_result_values_by_iv,p_input_value_id88),
		result_value(l_result_values_by_iv,p_input_value_id89),
		result_value(l_result_values_by_iv,p_input_value_id90),
		result_value(l_result_values_by_iv,p_input_value_id91),
		result_value(l_result_values_by_iv,p_input_value_id92),
		result_value(l_result_values_by_iv,p_input_value_id93),
		result_value(l_result_values_by_iv,p_input_value_id94),
		result_value(l_result_values_by_iv,p_input_value_id95),
		result_value(l_result_values_by_iv,p_input_value_id96),
		result_value(l_result_values_by_iv,p_input_value_id97),
		result_value(l_result_values_by_iv,p_input_value_id98),
		result_value(l_result_values_by_iv,p_input_value_id99),
		result_value(l_result_values_by_iv,p_input_value_id100),
		balance_value(l_balance_values_by_bal,p_balance_type_id1),
		balance_value(l_balance_values_by_bal,p_balance_type_id2),
		balance_value(l_balance_values_by_bal,p_balance_type_id3),
		balance_value(l_balance_values_by_bal,p_balance_type_id4),
		balance_value(l_balance_values_by_bal,p_balance_type_id5),
		balance_value(l_balance_values_by_bal,p_balance_type_id6),
		balance_value(l_balance_values_by_bal,p_balance_type_id7),
		balance_value(l_balance_values_by_bal,p_balance_type_id8),
		balance_value(l_balance_values_by_bal,p_balance_type_id9),
		balance_value(l_balance_values_by_bal,p_balance_type_id10),
		balance_value(l_balance_values_by_bal,p_balance_type_id11),
		balance_value(l_balance_values_by_bal,p_balance_type_id12),
		balance_value(l_balance_values_by_bal,p_balance_type_id13),
		balance_value(l_balance_values_by_bal,p_balance_type_id14),
		balance_value(l_balance_values_by_bal,p_balance_type_id15),
		balance_value(l_balance_values_by_bal,p_balance_type_id16),
		balance_value(l_balance_values_by_bal,p_balance_type_id17),
		balance_value(l_balance_values_by_bal,p_balance_type_id18),
		balance_value(l_balance_values_by_bal,p_balance_type_id19),
		balance_value(l_balance_values_by_bal,p_balance_type_id20),
		balance_value(l_balance_values_by_bal,p_balance_type_id21),
		balance_value(l_balance_values_by_bal,p_balance_type_id22),
		balance_value(l_balance_values_by_bal,p_balance_type_id23),
		balance_value(l_balance_values_by_bal,p_balance_type_id24),
		balance_value(l_balance_values_by_bal,p_balance_type_id25),
		balance_value(l_balance_values_by_bal,p_balance_type_id26),
		balance_value(l_balance_values_by_bal,p_balance_type_id27),
		balance_value(l_balance_values_by_bal,p_balance_type_id28),
		balance_value(l_balance_values_by_bal,p_balance_type_id29),
		balance_value(l_balance_values_by_bal,p_balance_type_id30));
END run;
--
FUNCTION prepay(
	p_assignment_action_id	IN NUMBER,
	p_input_value_id1	IN NUMBER DEFAULT NULL,
	p_input_value_id2	IN NUMBER DEFAULT NULL,
	p_input_value_id3	IN NUMBER DEFAULT NULL,
	p_input_value_id4	IN NUMBER DEFAULT NULL,
	p_input_value_id5	IN NUMBER DEFAULT NULL,
	p_input_value_id6	IN NUMBER DEFAULT NULL,
	p_input_value_id7	IN NUMBER DEFAULT NULL,
	p_input_value_id8	IN NUMBER DEFAULT NULL,
	p_input_value_id9	IN NUMBER DEFAULT NULL,
	p_input_value_id10	IN NUMBER DEFAULT NULL,
	p_input_value_id11	IN NUMBER DEFAULT NULL,
	p_input_value_id12	IN NUMBER DEFAULT NULL,
	p_input_value_id13	IN NUMBER DEFAULT NULL,
	p_input_value_id14	IN NUMBER DEFAULT NULL,
	p_input_value_id15	IN NUMBER DEFAULT NULL,
	p_input_value_id16	IN NUMBER DEFAULT NULL,
	p_input_value_id17	IN NUMBER DEFAULT NULL,
	p_input_value_id18	IN NUMBER DEFAULT NULL,
	p_input_value_id19	IN NUMBER DEFAULT NULL,
	p_input_value_id20	IN NUMBER DEFAULT NULL,
	p_input_value_id21	IN NUMBER DEFAULT NULL,
	p_input_value_id22	IN NUMBER DEFAULT NULL,
	p_input_value_id23	IN NUMBER DEFAULT NULL,
	p_input_value_id24	IN NUMBER DEFAULT NULL,
	p_input_value_id25	IN NUMBER DEFAULT NULL,
	p_input_value_id26	IN NUMBER DEFAULT NULL,
	p_input_value_id27	IN NUMBER DEFAULT NULL,
	p_input_value_id28	IN NUMBER DEFAULT NULL,
	p_input_value_id29	IN NUMBER DEFAULT NULL,
	p_input_value_id30	IN NUMBER DEFAULT NULL,
	p_input_value_id31	IN NUMBER DEFAULT NULL,
	p_input_value_id32	IN NUMBER DEFAULT NULL,
	p_input_value_id33	IN NUMBER DEFAULT NULL,
	p_input_value_id34	IN NUMBER DEFAULT NULL,
	p_input_value_id35	IN NUMBER DEFAULT NULL,
	p_input_value_id36	IN NUMBER DEFAULT NULL,
	p_input_value_id37	IN NUMBER DEFAULT NULL,
	p_input_value_id38	IN NUMBER DEFAULT NULL,
	p_input_value_id39	IN NUMBER DEFAULT NULL,
	p_input_value_id40	IN NUMBER DEFAULT NULL,
	p_input_value_id41	IN NUMBER DEFAULT NULL,
	p_input_value_id42	IN NUMBER DEFAULT NULL,
	p_input_value_id43	IN NUMBER DEFAULT NULL,
	p_input_value_id44	IN NUMBER DEFAULT NULL,
	p_input_value_id45	IN NUMBER DEFAULT NULL,
	p_input_value_id46	IN NUMBER DEFAULT NULL,
	p_input_value_id47	IN NUMBER DEFAULT NULL,
	p_input_value_id48	IN NUMBER DEFAULT NULL,
	p_input_value_id49	IN NUMBER DEFAULT NULL,
	p_input_value_id50	IN NUMBER DEFAULT NULL,
	p_input_value_id51	IN NUMBER DEFAULT NULL,
	p_input_value_id52	IN NUMBER DEFAULT NULL,
	p_input_value_id53	IN NUMBER DEFAULT NULL,
	p_input_value_id54	IN NUMBER DEFAULT NULL,
	p_input_value_id55	IN NUMBER DEFAULT NULL,
	p_input_value_id56	IN NUMBER DEFAULT NULL,
	p_input_value_id57	IN NUMBER DEFAULT NULL,
	p_input_value_id58	IN NUMBER DEFAULT NULL,
	p_input_value_id59	IN NUMBER DEFAULT NULL,
	p_input_value_id60	IN NUMBER DEFAULT NULL,
	p_input_value_id61	IN NUMBER DEFAULT NULL,
	p_input_value_id62	IN NUMBER DEFAULT NULL,
	p_input_value_id63	IN NUMBER DEFAULT NULL,
	p_input_value_id64	IN NUMBER DEFAULT NULL,
	p_input_value_id65	IN NUMBER DEFAULT NULL,
	p_input_value_id66	IN NUMBER DEFAULT NULL,
	p_input_value_id67	IN NUMBER DEFAULT NULL,
	p_input_value_id68	IN NUMBER DEFAULT NULL,
	p_input_value_id69	IN NUMBER DEFAULT NULL,
	p_input_value_id70	IN NUMBER DEFAULT NULL,
	p_input_value_id71	IN NUMBER DEFAULT NULL,
	p_input_value_id72	IN NUMBER DEFAULT NULL,
	p_input_value_id73	IN NUMBER DEFAULT NULL,
	p_input_value_id74	IN NUMBER DEFAULT NULL,
	p_input_value_id75	IN NUMBER DEFAULT NULL,
	p_input_value_id76	IN NUMBER DEFAULT NULL,
	p_input_value_id77	IN NUMBER DEFAULT NULL,
	p_input_value_id78	IN NUMBER DEFAULT NULL,
	p_input_value_id79	IN NUMBER DEFAULT NULL,
	p_input_value_id80	IN NUMBER DEFAULT NULL,
	p_input_value_id81	IN NUMBER DEFAULT NULL,
	p_input_value_id82	IN NUMBER DEFAULT NULL,
	p_input_value_id83	IN NUMBER DEFAULT NULL,
	p_input_value_id84	IN NUMBER DEFAULT NULL,
	p_input_value_id85	IN NUMBER DEFAULT NULL,
	p_input_value_id86	IN NUMBER DEFAULT NULL,
	p_input_value_id87	IN NUMBER DEFAULT NULL,
	p_input_value_id88	IN NUMBER DEFAULT NULL,
	p_input_value_id89	IN NUMBER DEFAULT NULL,
	p_input_value_id90	IN NUMBER DEFAULT NULL,
	p_input_value_id91	IN NUMBER DEFAULT NULL,
	p_input_value_id92	IN NUMBER DEFAULT NULL,
	p_input_value_id93	IN NUMBER DEFAULT NULL,
	p_input_value_id94	IN NUMBER DEFAULT NULL,
	p_input_value_id95	IN NUMBER DEFAULT NULL,
	p_input_value_id96	IN NUMBER DEFAULT NULL,
	p_input_value_id97	IN NUMBER DEFAULT NULL,
	p_input_value_id98	IN NUMBER DEFAULT NULL,
	p_input_value_id99	IN NUMBER DEFAULT NULL,
	p_input_value_id100	IN NUMBER DEFAULT NULL,
	p_balance_type_id1	IN NUMBER DEFAULT NULL,
	p_balance_type_id2	IN NUMBER DEFAULT NULL,
	p_balance_type_id3	IN NUMBER DEFAULT NULL,
	p_balance_type_id4	IN NUMBER DEFAULT NULL,
	p_balance_type_id5	IN NUMBER DEFAULT NULL,
	p_balance_type_id6	IN NUMBER DEFAULT NULL,
	p_balance_type_id7	IN NUMBER DEFAULT NULL,
	p_balance_type_id8	IN NUMBER DEFAULT NULL,
	p_balance_type_id9	IN NUMBER DEFAULT NULL,
	p_balance_type_id10	IN NUMBER DEFAULT NULL,
	p_balance_type_id11	IN NUMBER DEFAULT NULL,
	p_balance_type_id12	IN NUMBER DEFAULT NULL,
	p_balance_type_id13	IN NUMBER DEFAULT NULL,
	p_balance_type_id14	IN NUMBER DEFAULT NULL,
	p_balance_type_id15	IN NUMBER DEFAULT NULL,
	p_balance_type_id16	IN NUMBER DEFAULT NULL,
	p_balance_type_id17	IN NUMBER DEFAULT NULL,
	p_balance_type_id18	IN NUMBER DEFAULT NULL,
	p_balance_type_id19	IN NUMBER DEFAULT NULL,
	p_balance_type_id20	IN NUMBER DEFAULT NULL,
	p_balance_type_id21	IN NUMBER DEFAULT NULL,
	p_balance_type_id22	IN NUMBER DEFAULT NULL,
	p_balance_type_id23	IN NUMBER DEFAULT NULL,
	p_balance_type_id24	IN NUMBER DEFAULT NULL,
	p_balance_type_id25	IN NUMBER DEFAULT NULL,
	p_balance_type_id26	IN NUMBER DEFAULT NULL,
	p_balance_type_id27	IN NUMBER DEFAULT NULL,
	p_balance_type_id28	IN NUMBER DEFAULT NULL,
	p_balance_type_id29	IN NUMBER DEFAULT NULL,
	p_balance_type_id30	IN NUMBER DEFAULT NULL) RETURN pay_jp_result_prepay_t
IS
	l_balance_type_ids		balance_type_ids_t;
	l_result_values_by_iv		result_values_by_iv_t;
	l_balance_values_by_bal		balance_values_by_bal_t;
	--
	-- Cursor to fetch assigment actions locked by Pre-payments assact.
	--
	CURSOR csr_assact IS
		select	paa.assignment_action_id,
			ppa.effective_date
		from	pay_payroll_actions	ppa,	-- Run pact
			pay_assignment_actions	paa,	-- Run assact
			pay_action_interlocks	pai	-- Locked by Prepay assact
		where	pai.locking_action_id = p_assignment_action_id
		and	paa.assignment_action_id = pai.locked_action_id
		and	ppa.payroll_action_id = paa.payroll_action_id
		and	ppa.action_type <> 'V'
		and	not exists(
				select	NULL
				from	pay_payroll_actions	ppa2,	-- Reversal pact
					pay_assignment_actions	paa2,	-- Reversal assact
					pay_action_interlocks	pai2	-- Locked by Reversal assact
				where	pai2.locked_action_id = paa.assignment_action_id
				and	paa2.assignment_action_id = pai2.locking_action_id
				and	ppa2.payroll_action_id = paa2.payroll_action_id
				and	ppa2.action_type = 'V');
	--
	-- Cursor to fetch payment info.
	--
	CURSOR csr_payment IS
		select	ppp.value
		from	pay_pre_payments	ppp
		where	ppp.assignment_action_id = p_assignment_action_id
		order by ppp.pre_payment_id;
	l_payments		pay_jp_numbers_t;
	--
	-- Function payment
	--
	FUNCTION payment(p_index IN NUMBER) RETURN NUMBER
	IS
		l_payment	NUMBER;
	BEGIN
		--
		-- l_payments is not atomically NULL because of bulk fetch.
		-- Even if no records returned, l_payments is instantiated.
		--
		if l_payments.exists(p_index) then
			l_payment := l_payments(p_index);
		end if;
		--
		-- Return value.
		--
		return l_payment;
	END payment;
BEGIN
	--
	-- Convert input parameters to VARRAY variable.
	--
	convert_to_table(
		p_balance_type_id1	=> p_balance_type_id1,
		p_balance_type_id2	=> p_balance_type_id2,
		p_balance_type_id3	=> p_balance_type_id3,
		p_balance_type_id4	=> p_balance_type_id4,
		p_balance_type_id5	=> p_balance_type_id5,
		p_balance_type_id6	=> p_balance_type_id6,
		p_balance_type_id7	=> p_balance_type_id7,
		p_balance_type_id8	=> p_balance_type_id8,
		p_balance_type_id9	=> p_balance_type_id9,
		p_balance_type_id10	=> p_balance_type_id10,
		p_balance_type_id11	=> p_balance_type_id11,
		p_balance_type_id12	=> p_balance_type_id12,
		p_balance_type_id13	=> p_balance_type_id13,
		p_balance_type_id14	=> p_balance_type_id14,
		p_balance_type_id15	=> p_balance_type_id15,
		p_balance_type_id16	=> p_balance_type_id16,
		p_balance_type_id17	=> p_balance_type_id17,
		p_balance_type_id18	=> p_balance_type_id18,
		p_balance_type_id19	=> p_balance_type_id19,
		p_balance_type_id20	=> p_balance_type_id20,
		p_balance_type_id21	=> p_balance_type_id21,
		p_balance_type_id22	=> p_balance_type_id22,
		p_balance_type_id23	=> p_balance_type_id23,
		p_balance_type_id24	=> p_balance_type_id24,
		p_balance_type_id25	=> p_balance_type_id25,
		p_balance_type_id26	=> p_balance_type_id26,
		p_balance_type_id27	=> p_balance_type_id27,
		p_balance_type_id28	=> p_balance_type_id28,
		p_balance_type_id29	=> p_balance_type_id29,
		p_balance_type_id30	=> p_balance_type_id30,
		p_balance_type_ids	=> l_balance_type_ids);
	--
	-- Looped by assacts locked by Pre-payments assact.
	--
	for l_assact in csr_assact loop
		run_internal(
			p_assignment_action_id	=> l_assact.assignment_action_id,
			p_feed_checking_date	=> l_assact.effective_date,
			p_balance_type_ids	=> l_balance_type_ids,
			p_result_values_by_iv	=> l_result_values_by_iv,
			p_balance_values_by_bal	=> l_balance_values_by_bal);
	end loop;
	--
	-- Setup Payment information with BULK COLLECT.
	--
	open csr_payment;
	fetch csr_payment bulk collect into l_payments;
	close csr_payment;
	--
	-- Return value.
	--
	return pay_jp_result_prepay_t(
		result_value(l_result_values_by_iv,p_input_value_id1),
		result_value(l_result_values_by_iv,p_input_value_id2),
		result_value(l_result_values_by_iv,p_input_value_id3),
		result_value(l_result_values_by_iv,p_input_value_id4),
		result_value(l_result_values_by_iv,p_input_value_id5),
		result_value(l_result_values_by_iv,p_input_value_id6),
		result_value(l_result_values_by_iv,p_input_value_id7),
		result_value(l_result_values_by_iv,p_input_value_id8),
		result_value(l_result_values_by_iv,p_input_value_id9),
		result_value(l_result_values_by_iv,p_input_value_id10),
		result_value(l_result_values_by_iv,p_input_value_id11),
		result_value(l_result_values_by_iv,p_input_value_id12),
		result_value(l_result_values_by_iv,p_input_value_id13),
		result_value(l_result_values_by_iv,p_input_value_id14),
		result_value(l_result_values_by_iv,p_input_value_id15),
		result_value(l_result_values_by_iv,p_input_value_id16),
		result_value(l_result_values_by_iv,p_input_value_id17),
		result_value(l_result_values_by_iv,p_input_value_id18),
		result_value(l_result_values_by_iv,p_input_value_id19),
		result_value(l_result_values_by_iv,p_input_value_id20),
		result_value(l_result_values_by_iv,p_input_value_id21),
		result_value(l_result_values_by_iv,p_input_value_id22),
		result_value(l_result_values_by_iv,p_input_value_id23),
		result_value(l_result_values_by_iv,p_input_value_id24),
		result_value(l_result_values_by_iv,p_input_value_id25),
		result_value(l_result_values_by_iv,p_input_value_id26),
		result_value(l_result_values_by_iv,p_input_value_id27),
		result_value(l_result_values_by_iv,p_input_value_id28),
		result_value(l_result_values_by_iv,p_input_value_id29),
		result_value(l_result_values_by_iv,p_input_value_id30),
		result_value(l_result_values_by_iv,p_input_value_id31),
		result_value(l_result_values_by_iv,p_input_value_id32),
		result_value(l_result_values_by_iv,p_input_value_id33),
		result_value(l_result_values_by_iv,p_input_value_id34),
		result_value(l_result_values_by_iv,p_input_value_id35),
		result_value(l_result_values_by_iv,p_input_value_id36),
		result_value(l_result_values_by_iv,p_input_value_id37),
		result_value(l_result_values_by_iv,p_input_value_id38),
		result_value(l_result_values_by_iv,p_input_value_id39),
		result_value(l_result_values_by_iv,p_input_value_id40),
		result_value(l_result_values_by_iv,p_input_value_id41),
		result_value(l_result_values_by_iv,p_input_value_id42),
		result_value(l_result_values_by_iv,p_input_value_id43),
		result_value(l_result_values_by_iv,p_input_value_id44),
		result_value(l_result_values_by_iv,p_input_value_id45),
		result_value(l_result_values_by_iv,p_input_value_id46),
		result_value(l_result_values_by_iv,p_input_value_id47),
		result_value(l_result_values_by_iv,p_input_value_id48),
		result_value(l_result_values_by_iv,p_input_value_id49),
		result_value(l_result_values_by_iv,p_input_value_id50),
		result_value(l_result_values_by_iv,p_input_value_id51),
		result_value(l_result_values_by_iv,p_input_value_id52),
		result_value(l_result_values_by_iv,p_input_value_id53),
		result_value(l_result_values_by_iv,p_input_value_id54),
		result_value(l_result_values_by_iv,p_input_value_id55),
		result_value(l_result_values_by_iv,p_input_value_id56),
		result_value(l_result_values_by_iv,p_input_value_id57),
		result_value(l_result_values_by_iv,p_input_value_id58),
		result_value(l_result_values_by_iv,p_input_value_id59),
		result_value(l_result_values_by_iv,p_input_value_id60),
		result_value(l_result_values_by_iv,p_input_value_id61),
		result_value(l_result_values_by_iv,p_input_value_id62),
		result_value(l_result_values_by_iv,p_input_value_id63),
		result_value(l_result_values_by_iv,p_input_value_id64),
		result_value(l_result_values_by_iv,p_input_value_id65),
		result_value(l_result_values_by_iv,p_input_value_id66),
		result_value(l_result_values_by_iv,p_input_value_id67),
		result_value(l_result_values_by_iv,p_input_value_id68),
		result_value(l_result_values_by_iv,p_input_value_id69),
		result_value(l_result_values_by_iv,p_input_value_id70),
		result_value(l_result_values_by_iv,p_input_value_id71),
		result_value(l_result_values_by_iv,p_input_value_id72),
		result_value(l_result_values_by_iv,p_input_value_id73),
		result_value(l_result_values_by_iv,p_input_value_id74),
		result_value(l_result_values_by_iv,p_input_value_id75),
		result_value(l_result_values_by_iv,p_input_value_id76),
		result_value(l_result_values_by_iv,p_input_value_id77),
		result_value(l_result_values_by_iv,p_input_value_id78),
		result_value(l_result_values_by_iv,p_input_value_id79),
		result_value(l_result_values_by_iv,p_input_value_id80),
		result_value(l_result_values_by_iv,p_input_value_id81),
		result_value(l_result_values_by_iv,p_input_value_id82),
		result_value(l_result_values_by_iv,p_input_value_id83),
		result_value(l_result_values_by_iv,p_input_value_id84),
		result_value(l_result_values_by_iv,p_input_value_id85),
		result_value(l_result_values_by_iv,p_input_value_id86),
		result_value(l_result_values_by_iv,p_input_value_id87),
		result_value(l_result_values_by_iv,p_input_value_id88),
		result_value(l_result_values_by_iv,p_input_value_id89),
		result_value(l_result_values_by_iv,p_input_value_id90),
		result_value(l_result_values_by_iv,p_input_value_id91),
		result_value(l_result_values_by_iv,p_input_value_id92),
		result_value(l_result_values_by_iv,p_input_value_id93),
		result_value(l_result_values_by_iv,p_input_value_id94),
		result_value(l_result_values_by_iv,p_input_value_id95),
		result_value(l_result_values_by_iv,p_input_value_id96),
		result_value(l_result_values_by_iv,p_input_value_id97),
		result_value(l_result_values_by_iv,p_input_value_id98),
		result_value(l_result_values_by_iv,p_input_value_id99),
		result_value(l_result_values_by_iv,p_input_value_id100),
		balance_value(l_balance_values_by_bal,p_balance_type_id1),
		balance_value(l_balance_values_by_bal,p_balance_type_id2),
		balance_value(l_balance_values_by_bal,p_balance_type_id3),
		balance_value(l_balance_values_by_bal,p_balance_type_id4),
		balance_value(l_balance_values_by_bal,p_balance_type_id5),
		balance_value(l_balance_values_by_bal,p_balance_type_id6),
		balance_value(l_balance_values_by_bal,p_balance_type_id7),
		balance_value(l_balance_values_by_bal,p_balance_type_id8),
		balance_value(l_balance_values_by_bal,p_balance_type_id9),
		balance_value(l_balance_values_by_bal,p_balance_type_id10),
		balance_value(l_balance_values_by_bal,p_balance_type_id11),
		balance_value(l_balance_values_by_bal,p_balance_type_id12),
		balance_value(l_balance_values_by_bal,p_balance_type_id13),
		balance_value(l_balance_values_by_bal,p_balance_type_id14),
		balance_value(l_balance_values_by_bal,p_balance_type_id15),
		balance_value(l_balance_values_by_bal,p_balance_type_id16),
		balance_value(l_balance_values_by_bal,p_balance_type_id17),
		balance_value(l_balance_values_by_bal,p_balance_type_id18),
		balance_value(l_balance_values_by_bal,p_balance_type_id19),
		balance_value(l_balance_values_by_bal,p_balance_type_id20),
		balance_value(l_balance_values_by_bal,p_balance_type_id21),
		balance_value(l_balance_values_by_bal,p_balance_type_id22),
		balance_value(l_balance_values_by_bal,p_balance_type_id23),
		balance_value(l_balance_values_by_bal,p_balance_type_id24),
		balance_value(l_balance_values_by_bal,p_balance_type_id25),
		balance_value(l_balance_values_by_bal,p_balance_type_id26),
		balance_value(l_balance_values_by_bal,p_balance_type_id27),
		balance_value(l_balance_values_by_bal,p_balance_type_id28),
		balance_value(l_balance_values_by_bal,p_balance_type_id29),
		balance_value(l_balance_values_by_bal,p_balance_type_id30),
		payment(1),
		payment(2),
		payment(3),
		payment(4),
		payment(5));
END prepay;
************************************************************************ */
--
END pay_jp_result_pkg;

/
