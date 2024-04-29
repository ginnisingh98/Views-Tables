--------------------------------------------------------
--  DDL for Package Body PAY_JP_MAG_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_MAG_UTILITY_PKG" as
/* $Header: pyjpmagu.pkb 120.1 2005/06/13 19:55:28 ttagawa noship $ */
--
-- Constants
--
c_package		constant varchar2(31) := 'pay_jp_mag_utility_pkg.';
--
-- Global Variables
--
type t_formula_queue is table of number index by binary_integer;
g_formula_queue		t_formula_queue;
-- ----------------------------------------------------------------------------
-- |--------------------------< show_formula_queue >--------------------------|
-- ----------------------------------------------------------------------------
-- Show all formulas stacked in the formula queue.
-- This procedure is only for debug purpose.
--
procedure show_formula_queue
is
	l_proc	varchar2(61) := c_package || 'show_formula_queue';
	--
	l_index	number;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	l_index := g_formula_queue.first;
	while l_index is not null loop
		hr_utility.trace('formula : ' || to_char(l_index, 99) || ' : ' || to_char(g_formula_queue(l_index)));
		l_index := g_formula_queue.next(l_index);
	end loop;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end show_formula_queue;
-- ----------------------------------------------------------------------------
-- |---------------------------< enqueue_formula >----------------------------|
-- ----------------------------------------------------------------------------
-- Enqueue the formula into the formula queue
--
procedure enqueue_formula(p_formula_id in number)
is
	l_index		number;
	l_formula_id	number;
begin
	l_index := nvl(g_formula_queue.last, 0) + 1;
	g_formula_queue(l_index) := p_formula_id;
end enqueue_formula;
-- ----------------------------------------------------------------------------
-- |---------------------------< dequeue_formula >----------------------------|
-- ----------------------------------------------------------------------------
-- Dequeue the latest formula from the formula queue.
-- The dequeued formula is removed from the formula queue.
--
function dequeue_formula return number
is
	l_index		number;
	l_formula_id	number;
begin
	l_index := g_formula_queue.first;
	if l_index is not null then
		l_formula_id := g_formula_queue(l_index);
		g_formula_queue.delete(l_index);
	end if;
	--
	return l_formula_id;
end dequeue_formula;
-- ----------------------------------------------------------------------------
-- |----------------------------< show_contexts >-----------------------------|
-- ----------------------------------------------------------------------------
-- Show all contexts in pay_mag_tape.internal_cxt_names/values.
-- This procedure is only for debug purpose.
--
procedure show_contexts
is
	l_proc	varchar2(61) := c_package || 'show_contexts';
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	for i in 1..pay_mag_tape.internal_cxt_names.count loop
		hr_utility.trace('context : ' || to_char(i, 99) || ' : ' || rpad(pay_mag_tape.internal_cxt_names(i), 30, ' ') || ' : ' || pay_mag_tape.internal_cxt_values(i));
	end loop;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end show_contexts;
-- ----------------------------------------------------------------------------
-- |----------------------------< clear_contexts >----------------------------|
-- ----------------------------------------------------------------------------
-- Clear all contexts in pay_mag_tape.internal_cxt_names/values except for
-- the first entry "NO_OF_CONTEXTS".
--
procedure clear_contexts
is
	l_count	number := pay_mag_tape.internal_cxt_names.count;
begin
	for i in 2..l_count loop
		pay_mag_tape.internal_cxt_names.delete(i);
		pay_mag_tape.internal_cxt_values.delete(i);
	end loop;
	--
	pay_mag_tape.internal_cxt_values(1) := fnd_number.number_to_canonical(1);
end clear_contexts;
-- ----------------------------------------------------------------------------
-- |-----------------------------< set_context >------------------------------|
-- ----------------------------------------------------------------------------
-- Set context value to pay_mag_tape.internal_cxt_names/values.
-- All data types "NUMBER", "TEXT" and "DATE" are supported for contexts.
-- Need to convert to canonical format.
--
procedure set_context(
	p_context_name		in varchar2,
	p_context_value		in varchar2)
is
	l_found	boolean := false;
	l_count	number := pay_mag_tape.internal_cxt_names.count;
begin
	--
	-- If the context with specified name exists,
	-- override the context value with specified value.
	--
	for i in 1..l_count loop
		if pay_mag_tape.internal_cxt_names(i) = p_context_name then
			pay_mag_tape.internal_cxt_values(i) := p_context_value;
			l_found := true;
			exit;
		end if;
	end loop;
	--
	-- If the context with specified name does not exist,
	-- create new entry.
	--
	if not l_found then
		l_count := l_count + 1;
		pay_mag_tape.internal_cxt_values(1) := fnd_number.number_to_canonical(l_count);
		pay_mag_tape.internal_cxt_names(l_count) := p_context_name;
		pay_mag_tape.internal_cxt_values(l_count) := p_context_value;
	end if;
end set_context;
--
procedure set_context(
	p_context_name		in varchar2,
	p_context_value		in number)
is
begin
	set_context(
		p_context_name	=> p_context_name,
		p_context_value	=> fnd_number.number_to_canonical(p_context_value));
end set_context;
--
procedure set_context(
	p_context_name		in varchar2,
	p_context_value		in date)
is
begin
	set_context(
		p_context_name	=> p_context_name,
		p_context_value	=> fnd_date.date_to_canonical(p_context_value));
end set_context;
-- ----------------------------------------------------------------------------
-- |---------------------------< show_parameters >----------------------------|
-- ----------------------------------------------------------------------------
-- Show all parameters in pay_mag_tape.internal_prm_names/values.
-- This procedure is only for debug purpose.
--
procedure show_parameters
is
	l_proc	varchar2(61) := c_package || 'show_parameters';
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	for i in 1..pay_mag_tape.internal_prm_names.count loop
		hr_utility.trace('parameter : ' || to_char(i, 99) || ' : ' || rpad(pay_mag_tape.internal_prm_names(i), 60, ' ') || ' : "' || pay_mag_tape.internal_prm_values(i) || '"');
	end loop;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
end show_parameters;
-- ----------------------------------------------------------------------------
-- |----------------------------< get_parameter >-----------------------------|
-- ----------------------------------------------------------------------------
-- Derive the parameter value from pay_mag_tape.internal_prm_names/values.
--
function get_parameter(p_parameter_name in varchar2) return varchar2
is
	l_parameter_value	varchar2(81);
begin
	for i in 1..pay_mag_tape.internal_prm_names.count loop
		if pay_mag_tape.internal_prm_names(i) = p_parameter_name then
			l_parameter_value := pay_mag_tape.internal_prm_values(i);
			exit;
		end if;
	end loop;
	--
	return l_parameter_value;
end get_parameter;
-- ----------------------------------------------------------------------------
-- |----------------------------< set_parameter >-----------------------------|
-- ----------------------------------------------------------------------------
-- Set parameter value to pay_mag_tape.internal_prm_names/values.
-- Note supported parameter data type by PYUMAG is "TEXT" only.
-- Here passes parameters with canonical format.
--
procedure set_parameter(
	p_parameter_name	in varchar2,
	p_parameter_value	in varchar2,
	p_default_value		in varchar2 default ' ')
is
	l_found	boolean := false;
	l_count	number := pay_mag_tape.internal_prm_names.count;
begin
	--
	-- If the parameter with specified name exists,
	-- override the parameter value with specified value.
	--
	for i in 1..l_count loop
		if pay_mag_tape.internal_prm_names(i) = p_parameter_name then
			pay_mag_tape.internal_prm_values(i) := nvl(p_parameter_value, p_default_value);
			l_found := true;
			exit;
		end if;
	end loop;
	--
	-- If the parameter with specified name does not exist,
	-- create new entry.
	--
	if not l_found then
		l_count := l_count + 1;
		pay_mag_tape.internal_prm_values(1) := fnd_number.number_to_canonical(l_count);
		pay_mag_tape.internal_prm_names(l_count) := p_parameter_name;
		pay_mag_tape.internal_prm_values(l_count) := nvl(p_parameter_value, p_default_value);
	end if;
end set_parameter;
--
procedure set_parameter(
	p_parameter_name	in varchar2,
	p_parameter_value	in number,
	p_default_value		in number default 0)
is
begin
	set_parameter(
		p_parameter_name	=> p_parameter_name,
		p_parameter_value	=> fnd_number.number_to_canonical(p_parameter_value),
		p_default_value		=> fnd_number.number_to_canonical(p_default_value));
end set_parameter;
--
procedure set_parameter(
	p_parameter_name	in varchar2,
	p_parameter_value	in date,
	p_default_value		in date default trunc(sysdate))
is
begin
	set_parameter(
		p_parameter_name	=> p_parameter_name,
		p_parameter_value	=> fnd_date.date_to_canonical(p_parameter_value),
		p_default_value		=> fnd_date.date_to_canonical(p_default_value));
end set_parameter;
--
-- The following package initialization code is not necessary
-- when processed through PYUMAG or PYUGEN which populate the followings.
-- This is mainly for debugging purpose.
--
begin
	if not pay_mag_tape.internal_cxt_names.exists(1) then
		set_context('NO_OF_CONTEXTS', 1);
	end if;
	--
	if not pay_mag_tape.internal_prm_names.exists(1) then
		set_parameter('NO_OF_PARAMETERS', 2);
		set_parameter('NEW_FORMULA_ID', 0);
	end if;
end pay_jp_mag_utility_pkg;

/
