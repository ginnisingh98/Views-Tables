--------------------------------------------------------
--  DDL for Package Body PAY_JP_FORMULA_FUNCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_FORMULA_FUNCTION_PKG" AS
/* $Header: pyjpffuc.pkb 120.0.12010000.2 2009/02/09 05:50:38 keyazawa ship $ */
--
c_package  constant varchar2(30) := 'pay_jp_formula_function_pkg.';
g_debug    boolean := hr_utility.debug_enabled;
--
/* ------------------------------------------------------------------------------------ --
-- GET_TABLE_VALUE_WITH_DEFAULT
-- return the value of specified user defined table
-- if fetched return value is null,
--    if p_default_by_row is setted 'Y',
--       return the udt value by specifying row as p_default_value
--    if p_default_by_row is not setted or is setted 'Y' or else,
--       return the specified p_default_value directly.
-- USAGE: p_default_value     : Set return default value
--                              or column value to fetch udt value
--                                 when p_default_by_row is Y.
--        p_default_by_row : Set Y or N.
--                              If set Y, Use p_default_value as parameter to fetch return value
--                              If set N(null) or else, Use p_default_value as default return value.
-- ------------------------------------------------------------------------------------ */
FUNCTION get_table_value_with_default(
		p_business_group_id	IN NUMBER,
		p_table_name		IN VARCHAR2,
		p_column_name		IN VARCHAR2,
		p_row_value		IN VARCHAR2,
		p_effective_date	IN DATE DEFAULT NULL,
		p_default_value		IN VARCHAR2,
		p_default_by_row	IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2
IS
--
	l_effective_date	date;
	l_range_or_match	pay_user_tables.range_or_match%type;
	l_user_table_id		pay_user_tables.user_table_id%type;
	l_value			pay_user_column_instances_f.value%type;
	l_legislation_code	per_business_groups.legislation_code%type;
--
	cursor	csr_value_match
	is
	select	puci.value
	from	pay_user_column_instances_f	puci,
		pay_user_columns		puc,
		pay_user_rows_f			pur,
		pay_user_tables			put
	where	put.user_table_id = l_user_table_id
	and	pur.user_table_id = put.user_table_id
	and	l_effective_date
		between pur.effective_start_date and pur.effective_end_date
	and	nvl(pur.business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(pur.legislation_code, l_legislation_code) = l_legislation_code
	and	decode(put.user_key_units,
				'D', to_char(fnd_date.canonical_to_date(pur.row_low_range_or_name)),
				'N', pur.row_low_range_or_name,
				'T', pur.row_low_range_or_name,
				null)
		=
		decode(put.user_key_units,
				'D', to_char(fnd_date.canonical_to_date(p_row_value)),
				'N', p_row_value,
				'T', p_row_value,
				null)
	and	puc.user_table_id = put.user_table_id
	and	puc.user_column_name = p_column_name
	and	nvl(puc.business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(puc.legislation_code, l_legislation_code) = l_legislation_code
	and	puci.user_row_id = pur.user_row_id
	and	puci.user_column_id = puc.user_column_id
	and	l_effective_date
		between puci.effective_start_date and puci.effective_end_date;
--
	cursor	csr_value_range
	is
	select	puci.value
	from	pay_user_column_instances_f	puci,
		pay_user_columns		puc,
		pay_user_rows_f			pur,
		pay_user_tables			put
	where	put.user_table_id = l_user_table_id
	and	put.user_key_units = 'N'
	and	pur.user_table_id = put.user_table_id
	and	l_effective_date
		between pur.effective_start_date and pur.effective_end_date
	and	nvl(pur.business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(pur.legislation_code, l_legislation_code) = l_legislation_code
	and	fnd_number.canonical_to_number(p_row_value)
		between fnd_number.canonical_to_number(pur.row_low_range_or_name)
		and fnd_number.canonical_to_number(pur.row_high_range)
	and	puc.user_table_id = put.user_table_id
	and	puc.user_column_name = p_column_name
	and	nvl(puc.business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(puc.legislation_code, l_legislation_code) = l_legislation_code
	and	puci.user_row_id = pur.user_row_id
	and	puci.user_column_id = puc.user_column_id
	and	l_effective_date
		between puci.effective_start_date and puci.effective_end_date;
BEGIN
--
	/* Use either the supplied date, or the date from fnd_sessions */
    	if p_effective_date is null then
		select	effective_date
		into	l_effective_date
		from	fnd_sessions
		where	session_id = userenv('sessionid');
	else
		l_effective_date := p_effective_date;
	end if;
--
	/* Get the legislation code */
	select	legislation_code
	into	l_legislation_code
	from	per_business_groups
	where	business_group_id = p_business_group_id;
--
	/* Get the type of query to be performed, either range or match */
	select	range_or_match,
		user_table_id
	into	l_range_or_match,
		l_user_table_id
	from	pay_user_tables
	where	user_table_name = p_table_name
	and	nvl(business_group_id, p_business_group_id) = p_business_group_id
	and	nvl(legislation_code, l_legislation_code) = l_legislation_code;
--
	/* Get the value */
	/* + Matched */
	if l_range_or_match = 'M' then
		open csr_value_match;
		fetch csr_value_match into l_value;
		close csr_value_match;
	/* + Range */
	else
		open csr_value_range;
		fetch csr_value_range into l_value;
		close csr_value_range;
	end if;
--
	/* Get default value if the value is null */
	if l_value is null then
		if p_default_by_row = 'Y' then
			l_value := hruserdt.get_table_value(
						p_bus_group_id		=> p_business_group_id,
						p_table_name		=> p_table_name,
						p_col_name		=> p_column_name,
						p_row_value		=> p_default_value,
						p_effective_date	=> l_effective_date);
		else
			l_value := p_default_value;
		end if;
	end if;
--
RETURN l_value;
END get_table_value_with_default;
/* ------------------------------------------------------------------------------------ --
-- CHK_SMC
-- return the 'TRUE' or 'FALSE'
--   If a value which is confirmed is on UDT, returns 'TRUE'.  If a value is not on UDT,
--   returns 'FALSE'.
-- USAGE:
--   Name                           Reqd Type     Description
--   p_table_name                   Yes  VARCHAR2 UDT table name.
--   p_column_name                  Yes  VARCHAR2 UDT column name.
--   p_effective_date               Yes  DATE	  effective_date.
--   p_value                        Yes  VARCHAR2 value to be confirmed.
-- ------------------------------------------------------------------------------------ */
 FUNCTION chk_smc(
  p_table_name          IN      VARCHAR2,
  p_column_name         IN      VARCHAR2,
  p_effective_date	IN      DATE,
  p_value		IN      VARCHAR2) RETURN VARCHAR2
IS
--
	l_value_exists        VARCHAR2(1);
--
	CURSOR udt_value_exists IS
		select 	'Y'
		from	pay_user_column_instances_f i,
			pay_user_rows_f r,
			pay_user_columns c,
			pay_user_tables t
		where   t.legislation_code ='JP'
		and	t.business_group_id is null
		and	t.user_table_name = p_table_name
		and	c.legislation_code = 'JP'
		and	c.business_group_id is null
		and	c.user_table_id = t.user_table_id
		and	c.user_column_name = p_column_name
		and	r.user_table_id = t.user_table_id
		and	p_effective_date between r.effective_start_date and r.effective_end_date
		and	r.legislation_code = 'JP'
		and	r.business_group_id is null
		and	p_effective_date between i.effective_start_date and i.effective_end_date
		and	i.user_row_id = r.user_row_id
		and	i.user_column_id = c.user_column_id
		and	i.value = p_value
		;
BEGIN
	OPEN udt_value_exists;
	FETCH udt_value_exists INTO l_value_exists;
	--
	IF udt_value_exists%NOTFOUND THEN
	  --
	  return 'FALSE';
	  --
	ELSE
	  return 'TRUE';
	END IF;
	CLOSE udt_value_exists;
END chk_smc;
/* ------------------------------------------------------------------------------------ */
 FUNCTION get_jp_parameter(
  p_owner               IN      VARCHAR2,
  p_parameter_name      IN      VARCHAR2) RETURN VARCHAR2 IS
  --
  CURSOR cel_jp_parameter IS
   SELECT parameter_value FROM hr_jp_parameters
   WHERE owner = p_owner
   AND parameter_name = p_parameter_name;
  --
  l_parameter_value     hr_jp_parameters.parameter_value%TYPE;
  --
 BEGIN
  --
  OPEN cel_jp_parameter;
  FETCH cel_jp_parameter INTO l_parameter_value;
  --
  IF cel_jp_parameter%NOTFOUND THEN
   --
   l_parameter_value := NULL;
   --
  END IF;
  --
  CLOSE cel_jp_parameter;
  --
  RETURN l_parameter_value;
  --
 END get_jp_parameter;
 --
--
function get_global_value(
  p_business_group_id in number,
  p_global_name       in varchar2,
  p_effective_date    in date default null)
return varchar2
is
--
  l_proc varchar2(80) := c_package||'get_global_value';
--
  l_value ff_globals_f.global_value%type;
--
  l_skip boolean := false;
  l_effective_date date := p_effective_date;
  l_glb_tbl_cnt number;
--
  cursor csr_global_value
  is
  select global_value
  from   ff_globals_f
  where  global_name = p_global_name
  and    nvl(legislation_code,g_legislation_code) = g_legislation_code
  and    nvl(business_group_id,p_business_group_id) = p_business_group_id
  and    l_effective_date
         between effective_start_date and effective_end_date;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  -- normally not pass here.
  if l_effective_date is null then
  --
    if g_session_id is null
       or g_session_id <> userenv('sessionid') then
    --
      g_session_id := userenv('sessionid');
    --
      select effective_date
      into   g_effective_date
      from   fnd_sessions
      where  session_id = g_session_id;
    --
      l_effective_date := g_effective_date;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('l_effective_date : '||to_char(l_effective_date,'YYYY/MM/DD'));
  end if;
--
  if g_effective_date is not null
  and g_effective_date = l_effective_date then
  --
    <<loop_glb>>
    for i in 1..g_glb_tbl.count loop
    --
      -- no support for same global name between cust and prod.
      if g_glb_tbl(i).global_name = p_global_name then
      --
        l_value := g_glb_tbl(i).global_value;
        l_skip := true;
        exit loop_glb;
      --
      end if;
    --
    end loop loop_glb;
  --
    if g_debug then
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('l_value : '||l_value);
    end if;
  --
  else
  --
    g_glb_tbl.delete;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,30);
  end if;
--
  if not l_skip then
  --
    if g_business_group_id is null
       or g_business_group_id <> p_business_group_id then
    --
      g_glb_tbl.delete;
      g_business_group_id := p_business_group_id;
    --
      select legislation_code
      into   g_legislation_code
      from   per_business_groups_perf
      where  business_group_id = g_business_group_id;
    --
    end if;
  --
    open csr_global_value;
    fetch csr_global_value into l_value;
    --
    if csr_global_value%found then
    --
      g_effective_date := l_effective_date;
    --
      l_glb_tbl_cnt := g_glb_tbl.count + 1;
      g_glb_tbl(l_glb_tbl_cnt).global_name := p_global_name;
      g_glb_tbl(l_glb_tbl_cnt).global_value := l_value;
    --
    end if;
    --
    close csr_global_value;
  --
    if g_debug then
      hr_utility.set_location(l_proc,40);
      hr_utility.trace('g_glb_tbl.count                         : '||g_glb_tbl.count);
      hr_utility.trace('g_glb_tbl(g_glb_tbl.count).global_name  : '||g_glb_tbl(g_glb_tbl.count).global_name);
      hr_utility.trace('g_glb_tbl(g_glb_tbl.count).global_value : '||g_glb_tbl(g_glb_tbl.count).global_value);
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.trace('final l_value : '||l_value);
    hr_utility.set_location(l_proc,1000);
  end if;
--
return l_value;
end get_global_value;
--
END pay_jp_formula_function_pkg;

/
