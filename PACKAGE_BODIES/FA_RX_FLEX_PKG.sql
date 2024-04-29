--------------------------------------------------------
--  DDL for Package Body FA_RX_FLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_FLEX_PKG" as
/* $Header: FARXFLXB.pls 120.7.12010000.5 2009/07/19 11:56:22 glchen ship $ */

---------------------------------------------
-- Some global types, constants and cursors
---------------------------------------------
type seg_array is table of FND_FLEX_VALUES.PARENT_FLEX_VALUE_LOW%type index by binary_integer;
NEWLINE CONSTANT varchar2(3) := '';


--
-- The following cursor is used extensively and is the main logic of
-- most of the procedures provided by this package.
-- Givent the key flexfield and  qualifier/segment number,
-- this cursor will return the segment number(s), column name(s)
-- and the flex value set(s) for all of the segments that
-- match the criteria for this key flexfield
--
cursor cflex(p_application_id in varchar2,
		p_id_flex_code in varchar2,
		p_id_flex_num in number,
		p_qualifier in varchar2,
		p_segnum in number) is
	select s.segment_num, s.application_column_name, s.flex_value_set_id
	from 	fnd_id_flex_segments s
	where	s.application_id = p_application_id
	and	s.id_flex_code = p_id_flex_code
	and	s.id_flex_num = p_id_flex_num
	and	s.enabled_flag = 'Y'
	and	p_qualifier = 'ALL'
	and	p_segnum is null
	union all
	select s.segment_num, s.application_column_name, s.flex_value_set_id
	from 	fnd_id_flex_segments s,
		fnd_segment_attribute_values sav,
		fnd_segment_attribute_types sat
	where	s.application_id = p_application_id
	and	s.id_flex_code = p_id_flex_code
	and	s.id_flex_num = p_id_flex_num
	and	s.enabled_flag = 'Y'
	and	s.application_column_name = sav.application_column_name
	and	sav.application_id = p_application_id
	and	sav.id_flex_code = p_id_flex_code
	and	sav.id_flex_num = p_id_flex_num
	and	sav.attribute_value = 'Y'
	and	sav.segment_attribute_type = sat.segment_attribute_type
	and	sat.application_id = p_application_id
	and	sat.id_flex_code = p_id_flex_code
	and	sat.unique_flag = 'Y'
	and	sat.segment_attribute_type = p_qualifier
	and	p_qualifier <> 'ALL'
	and	p_segnum is null
	union all
	select s.segment_num, s.application_column_name, s.flex_value_set_id
	from 	fnd_id_flex_segments s
	where	s.application_id = p_application_id
	and	s.id_flex_code = p_id_flex_code
	and	s.id_flex_num = p_id_flex_num
	and	s.enabled_flag = 'Y'
	and	s.segment_num = p_segnum
	and	p_qualifier is null
	order by 1;

cursor par_seg( p_application_id in number,
		p_id_flex_code in varchar2,
		p_id_flex_num in number,
		p_value_set_id in number)
Is
select  c.segment_num parent_seg_num
from	FND_FLEX_VALUE_SETS a, FND_ID_FLEX_SEGMENTS b, FND_ID_FLEX_SEGMENTS c
where	b.APPLICATION_ID = p_application_id
and	b.ID_FLEX_CODE = p_id_flex_code
and	b.ID_FLEX_NUM = p_id_flex_num
and	(b.FLEX_VALUE_SET_ID = a.FLEX_VALUE_SET_ID)
and	b.APPLICATION_ID = c.APPLICATION_ID
and	b.ID_FLEX_CODE = c.ID_FLEX_CODE
and	b.ID_FLEX_NUM = c.ID_FLEX_NUM
and	(a.PARENT_FLEX_VALUE_SET_ID = c.FLEX_VALUE_SET_ID)
and	a.FLEX_VALUE_SET_ID = p_value_set_id;

------------------------------------
-- Private Functions/Procedures
------------------------------------

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

-------------------------------------------------------------------------
--
-- PRIVATE FUNCTION Get_Parent_Value
--
-- Parameters
--		p_seg_array		Segment Array
--		p_application_id	Application id
--		p_id_flex_code		flex code
--		p_id_flex_num		Flex num default null
--		p_child_value_set_id	value set id , whose parent value value is to be found out.
--
-- Returns
--   the parent segment value
-- Description
--   This function returns the parent segments value for a depenant value set.
--   takes in application id,
--
--
-- Modification History
--  RRAVUNNY    Created Bug#2991482
--
-------------------------------------------------------------------------
Function Get_Parent_Value(	p_seg_array in seg_array,
				p_application_id in number,
				p_id_flex_code in varchar2,
				p_id_flex_num in number default NULL,
				p_child_value_set_id in number
			) return varchar2
Is
	Lvr_Parent_Value	FND_FLEX_VALUES.PARENT_FLEX_VALUE_LOW%type	Default Null;
	Lnu_array_counter	Number		Default Null;
	err_num			Number;
	Lnu_cache_index		Number		Default Null;
Begin
--*	dbms_output.put_line('Get_Parent_Value +');
--*	dbms_output.put_line(p_application_id||' - '||p_id_flex_code||' - '||p_id_flex_num||' - '||p_child_value_set_id);
	--* Check if the fa_rx_flex_parent_seg_t cache exists
	Lnu_cache_index := fa_rx_flex_par_seg_t.FIRST;
--*	dbms_output.put_line('for first , Lnu_cache_index = '||Lnu_cache_index||' total = '||fa_rx_flex_par_seg_t.count);
	WHILE Lnu_cache_index IS NOT NULL
	LOOP
--*		dbms_output.put_line('record content fa_rx_flex_parent_seg_t('||Lnu_cache_index||')');
--*		dbms_output.put_line('fa_rx_flex_parent_seg_t(Lnu_cache_index).fap_application_id = '||fa_rx_flex_par_seg_t(Lnu_cache_index).fap_application_id);
--*		dbms_output.put_line('fa_rx_flex_parent_seg_t(Lnu_cache_index).fap_id_flex_code = '||fa_rx_flex_par_seg_t(Lnu_cache_index).fap_id_flex_code);
--*		dbms_output.put_line('fa_rx_flex_parent_seg_t(Lnu_cache_index).fap_id_flex_num = '||fa_rx_flex_par_seg_t(Lnu_cache_index).fap_id_flex_num);
--*		dbms_output.put_line('fa_rx_flex_parent_seg_t(Lnu_cache_index).fap_flex_value_set_id = '||fa_rx_flex_par_seg_t(Lnu_cache_index).fap_flex_value_set_id);
--*		dbms_output.put_line('fa_rx_flex_parent_seg_t(Lnu_cache_index).fap_parent_segment_num = '||fa_rx_flex_par_seg_t(Lnu_cache_index).fap_parent_segment_num);
		--* Check if the record exists in cache.
		If (	fa_rx_flex_par_seg_t(Lnu_cache_index).fap_application_id = p_application_id and
			fa_rx_flex_par_seg_t(Lnu_cache_index).fap_id_flex_code = p_id_flex_code and
			fa_rx_flex_par_seg_t(Lnu_cache_index).fap_id_flex_num = p_id_flex_num and
			fa_rx_flex_par_seg_t(Lnu_cache_index).fap_flex_value_set_id = p_child_value_set_id
		    )
		Then
--*			dbms_output.put_line('present in cache');
			Lnu_array_counter := fa_rx_flex_par_seg_t(Lnu_cache_index).fap_parent_segment_num;
--*			dbms_output.put_line('Lnu_array_counter = '||Lnu_array_counter);
			Exit;
		End If;

		Lnu_cache_index := fa_rx_flex_par_seg_t.NEXT(Lnu_cache_index);
	END LOOP;

	If p_seg_array.FIRST Is Null Then
--*		dbms_output.put_line('Get_Parent_Value return' ||Lvr_Parent_Value);
--*		dbms_output.put_line('Get_Parent_Value -');
		Return(Lvr_Parent_Value);
	End If;

	--* Not present in cache
	Lnu_cache_index := Nvl(fa_rx_flex_par_seg_t.count,0) + 1;
--*	dbms_output.put_line('Lnu_cache_index = '||Lnu_cache_index);
	fa_rx_flex_par_seg_t(Lnu_cache_index).fap_application_id := p_application_id;
	fa_rx_flex_par_seg_t(Lnu_cache_index).fap_id_flex_code := p_id_flex_code;
	fa_rx_flex_par_seg_t(Lnu_cache_index).fap_id_flex_num := p_id_flex_num ;
	fa_rx_flex_par_seg_t(Lnu_cache_index).fap_flex_value_set_id := p_child_value_set_id ;

	If Lnu_array_counter Is Null Then
--*		dbms_output.put_line('Get_Parent_Value Lnu_array_counter is null');
		If par_seg%IsOpen Then
			Close par_seg;
		End If;
		Open par_seg(p_application_id,p_id_flex_code,p_id_flex_num,p_child_value_set_id);
		Fetch par_seg into Lnu_array_counter;
		Close par_seg;
--*		dbms_output.put_line('Get_Parent_Value copy into cache Lnu_array_counter = '||Lnu_array_counter);
		fa_rx_flex_par_seg_t(Lnu_cache_index).fap_parent_segment_num := Lnu_array_counter;
--*		dbms_output.put_line('216');
--*		dbms_output.put_line('218');
	End If;

	If Lnu_array_counter Is Not Null Then
		Lvr_Parent_Value := p_seg_array(Lnu_array_counter);
	End If;

--*	dbms_output.put_line('Get_Parent_Value return' ||Lvr_Parent_Value);
--*	dbms_output.put_line('Get_Parent_Value -');
	Return(Lvr_Parent_Value);
Exception
	When Others Then
		err_num := sqlcode;
		dbms_output.put_line('Get_Parent_Value exception '||err_num);
		dbms_output.put_line('Get_Parent_Value -');
		Return(Lvr_Parent_Value);
End Get_Parent_Value;
-------------------------------------------------------------------------
--
-- PRIVATE PROCEDURE separate_segments
--
-- Parameters
--		p_seg_array		Segment Array
--		p_values		Concatenated Segments
--		p_sep			Segment Delimiter
--
-- Description
--   This function takes the concatenated segments and splits them
--   up into individual segments (using the segment delimiter) and
--   places them into the segment array.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------

procedure separate_segments(
	p_seg_array in out nocopy seg_array,
	p_values in varchar2,
	p_sep in varchar2)
is
  i number;
  next_sep number;
  l_values varchar2(600);
begin
  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.separate_segments('||p_values||')+');
  END IF;

  l_values := p_values;
  i := 1;
  while (l_values is not null) loop
	next_sep := instr(l_values, p_sep);
	if next_sep = 0 then
	  p_seg_array(i) := l_values;
	  l_values := null;
	else
	  p_seg_array(i) := substr(l_values, 1, next_sep-1);
	  l_values := substr(l_values, next_sep+1);
	end if;

	i := i+1;
  end loop;

  fa_rx_util_pkg.debug('fa_rx_flex_pkg.separate_segments('||to_char(i-1)||')-');
end separate_segments;


-------------------------------------------------------------------------
--
-- PRIVATE FUNCTION get_id_flex_num
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--
-- Returns NUMBER
--   Returns the actual id_flex_num to be used
--
-- Description
--   This function takes the p_id_flex_num as input and returns
--   the actual id_flex_num to be used. If p_id_flex_num is not NULL,
--   it returns p_id_flex_num. If it is NULL, it returns the one structure
--   number that exists for this key flexfield. If there are more than
--   one, then this function will raise an exception.
--   This is to support key flexfield structures like the item flexfield
--   which uses a dataset.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------
function get_id_flex_num(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number) return number
is
  l_id_flex_num number;
begin
  if p_id_flex_num is not null then
    return p_id_flex_num;
  end if;

  select id_flex_num into l_id_flex_num
  from fnd_id_flex_structures
  where application_id = p_application_id
  and   id_flex_code = p_id_flex_code;

  return l_id_flex_num;
exception
when too_many_rows then
  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('get_id_flex_num: ' || 'EXCEPTION ==> Too many structures for APP_ID='||to_char(p_application_id)||', ID_FLEX_CODE='||p_id_flex_code);
  END IF;
  raise;
end get_id_flex_num;


-------------------------------------------------------------------------
--
-- PRIVATE FUNCTION get_segment_delimiter
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--
-- Returns VARCHAR2
--   Returns the segment delimiter for the given key flexfield
--
-- Description
--   This function takes the concatenated segments and splits them
--   up into individual segments (using the segment delimiter) and
--   places them into the segment array.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------
function get_segment_delimiter(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number) return varchar2
is
  sep fnd_id_flex_structures.concatenated_segment_delimiter%type;
begin
  select concatenated_segment_delimiter into sep
  from fnd_id_flex_structures
  where	application_id = p_application_id
  and	id_flex_code = p_id_flex_code
  and	id_flex_num = p_id_flex_num;

  return sep;

exception
when no_data_found then
  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('get_segment_delimiter: ' || 'EXCEPTION ==> Unable to find segment delimiter!');
  END IF;
  raise;
end get_segment_delimiter;



------------------------------------
-- Public Functions/Procedures
------------------------------------

-------------------------------------------------------------------------
--
-- FUNCTION flex_sql
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--		p_table_alias		Table Alias
--		p_mode			Output mode
--		p_qualifier		Flexfield qualifier or segment number
--		p_function		Operator
--		p_operand1,2		Operands
--
-- Returns VARCHAR2
--   Returns the required SQL clause
--
-- Description
--   This function mimics the functionality of the userexit FLEXSQL.
--   Given the parameters, this function is equivalent to:
--	FND FLEXSQL
--		CODE=":p_id_flex_code"
--		APPL_SHORT_NAME="Short name from :p_application_id"
--		OUTPUT=":This is the return value"
--		MODE=":p_mode"
--		DISPLAY=":p_qualifier"
--		NUM=":p_id_flex_num"
--		TABLEALIAS=":p_table_alias"
--		OPERATOR=":p_function"
--		OPERAND1=":p_operand1"
--		OPERAND2=":p_operand2"
--
-- Restrictions
--   No support for SHOWDEPSEG parameter
--   No support for MULTINUM parameter
--   p_qualifier must be 'ALL' or a valid qualifier name or segment number.
--   p_function does not support "QBE".
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------
function flex_sql(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number default null,
	p_table_alias in varchar2,
	p_mode in varchar2,
	p_qualifier in varchar2,
	p_function in varchar2 default null,
	p_operand1 in varchar2 default null,
	p_operand2 in varchar2 default null)
return varchar2
is
  segnum   fnd_id_flex_segments.segment_num%type;
  colname  fnd_id_flex_segments.application_column_name%type;
  seg_value_set_id fnd_flex_value_sets.flex_value_set_id%type;

  sep fnd_id_flex_structures.concatenated_segment_delimiter%type;
  op1 seg_array;
  op2 seg_array;

  i number;

  table_alias varchar2(40);
  buffer varchar2(2000);

  l_qualifier	fnd_segment_attribute_types.segment_attribute_type%type;
  l_segnum	fnd_id_flex_segments.segment_num%type;
  l_id_flex_num number;
begin
  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.flex_sql()+');
  END IF;

  --
  -- Check the validity of some of the parameters
  --
  if 	p_mode not in ('SELECT', 'WHERE', 'HAVING', 'ORDER BY', 'GROUP BY') or
	p_function not in ('=', '<', '>', '<=', '>=', '!=', 'BETWEEN') then
		raise invalid_argument;
  end if;

  l_id_flex_num := get_id_flex_num(p_application_id, p_id_flex_code, p_id_flex_num);

  -- Delimiter
  sep := get_segment_delimiter(
		p_application_id,
		p_id_flex_code,
		l_id_flex_num);

  -- Actual table alias used in SQL statement
  if p_table_alias is null then table_alias := null;
  else table_alias := p_table_alias ||'.';
  end if;


  --
  -- Initialize the op1 and op2 seg_arrays
  --
  if p_function in ('=', '<', '>', '<=', '>=', '!=') then
    if p_qualifier = 'ALL' then
	separate_segments(op1, p_operand1, sep);
    else
	op1(1) := p_operand1;
    end if;
  elsif p_function in ('BETWEEN') then
    if p_qualifier = 'ALL' then
	separate_segments(op1, p_operand1, sep);
	separate_segments(op2, p_operand2, sep);
    else
	op1(1) := p_operand1;
	op2(1) := p_operand2;
    end if;
  end if;


  --
  -- Finally ready for to compile
  --
  if cflex%isopen then close cflex;
  end if;
  begin
    l_segnum := to_number(p_qualifier);
    l_qualifier := null;
  exception
  when VALUE_ERROR then
    l_segnum := null;
    l_qualifier := p_qualifier;
  end;
  open cflex(p_application_id,
		p_id_flex_code,
		l_id_flex_num,
		l_qualifier,
		l_segnum);
  i := 1;
  loop
	--
	-- For each row fetched by cflex
	-- build up the SQL clause
	fetch cflex into segnum, colname, seg_value_set_id;
	exit when cflex%notfound;

	if p_mode in ('SELECT', 'GROUP BY') then
	  if buffer is not null then buffer := buffer || '||''' ||sep|| '''||';
	  end if;
	  buffer := buffer||table_alias||colname;
	elsif p_mode = 'ORDER BY' then
	  if buffer is not null then buffer := buffer || ',';
	  end if;
	  buffer := buffer||table_alias||colname;
	elsif p_mode in ('WHERE', 'HAVING') then
	  if buffer is not null then buffer := buffer || ' and ';
	  end if;
	  buffer := buffer||table_alias||colname;

	  if p_function in ('=', '<', '>', '<=', '>=', '!=') then
	    buffer := buffer || p_function || '''' || op1(i) || '''';
	  elsif p_function in ('BETWEEN') then
	    buffer := buffer || ' BETWEEN '''|| op1(i) || ''' AND '''|| op2(i) ||'''';
	  end if;
	end if;
    	i := i + 1;
  end loop;
  close cflex;

  if buffer is null then
	--
	-- If the buffer is null then that means
	-- that cflex cursor returned no rows.
	-- One of the arguments MUST be incorrect
	-- Output the parameters and raise error
	--
	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('Error in fa_rx_flex_pkg.flex_sql()');
		fa_rx_util_pkg.debug('flex_sql: ' || 'Application ID = '||to_char(p_application_id));
		fa_rx_util_pkg.debug('flex_sql: ' || 'ID Flex Code   = '||p_id_flex_code);
		fa_rx_util_pkg.debug('flex_sql: ' || 'ID Flex Num    = '||to_char(l_id_flex_num));
		fa_rx_util_pkg.debug('flex_sql: ' || 'Qualifier      = '||p_qualifier);
		fa_rx_util_pkg.debug('flex_sql: ' || '  **** No rows returned ****  ');
		fa_rx_util_pkg.debug('fa_rx_flex_pkg.flex_sql(EXCEPTION)-');
	END IF;
	raise invalid_argument;
  end if;

  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.flex_sql('||buffer||')-');
  END IF;
  return buffer;

exception
when others then
  if cflex%isopen then
	close cflex;
  end if;

  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('Exception in fa_rx_flex_pkg.flex_sql()');
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Application ID = '||to_char(p_application_id));
  	fa_rx_util_pkg.debug('flex_sql: ' || 'ID Flex Code   = '||p_id_flex_code);
  	fa_rx_util_pkg.debug('flex_sql: ' || 'ID Flex Num    = '||to_char(l_id_flex_num));
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Table Alias    = '||p_table_alias);
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Mode           = '||p_mode);
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Qualifier      = '||p_qualifier);
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Function       = '||p_function);
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Operand 1      = '||p_operand1);
  	fa_rx_util_pkg.debug('flex_sql: ' || 'Operand 2      = '||p_operand2);
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.flex_sql(EXCEPTION)-');
  END IF;
  raise;
end flex_sql;



-------------------------------------------------------------------------
--
-- FUNCTION get_value
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--		p_qualifier		Flexfield qualifier or segment number
--		p_ccid			Code combination ID
--
-- Returns VARCHAR2
--   Returns the concatenated segment values of the key flexfield
--
-- Description
--   There is no equivalent for this function. This function takes
--   the code combination id for the key flexfield and returns the
--   actual segment values. This function can be used within
--   the after fetch triggers for RXi reports to retrieve the value.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.

--  Bug2951118 LGANDHI 25-MAY-2003 Modified to including Cacheing routine.
--
-------------------------------------------------------------------------
function get_value(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number default NULL,
	p_qualifier in varchar2,
	p_ccid in number) return varchar2
is
  sqlstmt varchar2(2000);

  l_table_name varchar2(30);
  l_unique_id_column_name varchar2(30);
  l_sep fnd_id_flex_structures.concatenated_segment_delimiter%type;
  c integer;
  rows integer;
  segnum   fnd_id_flex_segments.segment_num%type;
  colname  fnd_id_flex_segments.application_column_name%type;
  seg_value_set_id fnd_flex_value_sets.flex_value_set_id%type;
  buffer varchar2(2000);

  l_qualifier	fnd_segment_attribute_types.segment_attribute_type%type;
  l_segnum	fnd_id_flex_segments.segment_num%type;
  l_id_flex_num number;
  l_counter     number := 0;
begin
  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.get_value()+');
  END IF;

  IF(p_application_id IS NOT NULL AND p_id_flex_code IS NOT NULL AND p_id_flex_num
          IS NOT NULL AND p_qualifier IS NOT NULL AND 	p_ccid IS NOT NULL ) THEN

LOOP

	IF (fa_rx_flex_val_t.EXISTS(l_counter))   THEN


	  IF((fa_rx_flex_val_t(l_counter).application_id =  p_application_id)
              AND (fa_rx_flex_val_t(l_counter).id_flex_code = p_id_flex_code)
	      AND (fa_rx_flex_val_t(l_counter).id_flex_num =  p_id_flex_num)
              AND (fa_rx_flex_val_t(l_counter).qualifier =  p_qualifier)
              AND (fa_rx_flex_val_t(l_counter).ccid =  p_ccid))
          THEN


		RETURN fa_rx_flex_val_t(l_counter).buffer;

          ELSE

		l_counter:=l_counter + 1;

	  END IF;


	END IF;


EXIT WHEN  (NOT fa_rx_flex_val_t.EXISTS(l_counter));

END LOOP;

END IF;


  l_id_flex_num := get_id_flex_num(p_application_id, p_id_flex_code, p_id_flex_num);

  --
  -- Get the code combination table and the
  -- Primary key for that table
  --
  select application_table_name , unique_id_column_name
  into  l_table_name, l_unique_id_column_name
  from  fnd_id_flexs
  where application_id = p_application_id
  and   id_flex_code = p_id_flex_code;

  -- Get the segment delimiter
  l_sep := get_segment_delimiter(
		p_application_id,
		p_id_flex_code,
		l_id_flex_num);


  --
  -- We are going to build the select statment which
  -- is going to get us the value we want.
  --

  --
  -- First build the select statment
  --
  sqlstmt := null;
  if cflex%isopen then close cflex;
  end if;
  begin
    l_segnum := to_number(p_qualifier);
    l_qualifier := null;
  exception
  when VALUE_ERROR then
    l_segnum := null;
    l_qualifier := p_qualifier;
  end;
  open cflex(p_application_id,
		p_id_flex_code,
		l_id_flex_num,
		l_qualifier,
		l_segnum);

  loop
	--
	-- For each row, get the column name of the
	-- code combinations table which has the segment value.
	--
	fetch cflex into segnum, colname, seg_value_set_id;
	exit when cflex%notfound;

	if sqlstmt is not null then
	  sqlstmt := sqlstmt || '||''' || l_sep || '''||' ||colname;
	else
	  sqlstmt := colname;
	end if;
  end loop;
  if sqlstmt is null then
	--
	-- If the sqlstmt is null then that means
	-- that cflex cursor returned no rows.
	-- One of the arguments MUST be incorrect
	-- Output the parameters and raise error
	--
	fa_rx_util_pkg.log('Error in fa_rx_flex_pkg.get_value()');
	fa_rx_util_pkg.log('Application ID = '||to_char(p_application_id));
	fa_rx_util_pkg.log('ID Flex Code   = '||p_id_flex_code);
	fa_rx_util_pkg.log('ID Flex Num    = '||to_char(l_id_flex_num));
	fa_rx_util_pkg.log('Qualifier      = '||p_qualifier);
	fa_rx_util_pkg.log('  **** No rows returned ****  ');

	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('fa_rx_flex_pkg.get_value(EXCEPTION)-');
	END IF;
	raise invalid_argument;
  end if;

  sqlstmt := 'SELECT '||sqlstmt||' FROM '||l_table_name||' WHERE '||l_unique_id_column_name||' = :ccid';
  close cflex;
  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('get_value: ' || 'Executing SELECT...');
  	fa_rx_util_pkg.debug('get_value: ' || sqlstmt);
  END IF;

  --
  -- We have the SELECT statement.
  -- Now execute it.
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, sqlstmt, dbms_sql.native);
  dbms_sql.bind_variable(c, 'ccid', p_ccid);
  dbms_sql.define_column(c, 1, buffer, 2000);
  rows := dbms_sql.execute(c);
  rows := dbms_sql.fetch_rows(c);
  if rows <= 0 then
	IF (g_print_debug) THEN
		fa_rx_util_pkg.debug('Invalid CCID in fa_rx_flex_pkg.get_value()');
		fa_rx_util_pkg.debug('get_value: ' || 'CCID = '||to_char(p_ccid));
		fa_rx_util_pkg.debug('fa_rx_flex_pkg.get_value(NO_DATA_FOUND)-');
	END IF;
	raise no_data_found;
  end if;
  dbms_sql.column_value(c, 1, buffer);
  dbms_sql.close_cursor(c);

  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.get_value('||buffer||')-');
  END IF;


	IF (p_application_id IS NOT NULL AND p_id_flex_code IS NOT NULL AND p_id_flex_num
	 IS NOT NULL AND p_qualifier IS NOT NULL AND p_ccid IS NOT NULL ) THEN


	      fa_rx_flex_val_t(l_counter).application_id :=  p_application_id ;
              fa_rx_flex_val_t(l_counter).id_flex_code   := p_id_flex_code ;
	      fa_rx_flex_val_t(l_counter).id_flex_num    :=  p_id_flex_num ;
              fa_rx_flex_val_t(l_counter).qualifier      :=  p_qualifier;
              fa_rx_flex_val_t(l_counter).ccid           :=  p_ccid;
	      fa_rx_flex_val_t(l_counter).buffer	 :=  buffer;


		RETURN	fa_rx_flex_val_t(l_counter).buffer;

	 ELSE

		 RETURN	buffer ;

	END IF;




exception
when others then
  if cflex%isopen then
	close cflex;
  end if;
  if dbms_sql.is_open(c) then
	dbms_sql.close_cursor(c);
  end if;

  fa_rx_util_pkg.log('Exception in fa_rx_flex_pkg.get_value()');
  fa_rx_util_pkg.log('Application_ID = ' || to_char(p_Application_ID));
  fa_rx_util_pkg.log('ID Flex Code   = ' || p_ID_Flex_Code);
  fa_rx_util_pkg.log('ID Flex Num    = ' || to_char(l_id_flex_num));
  fa_rx_util_pkg.log('Qualifier      = ' || p_qualifier);
  fa_rx_util_pkg.log('CCID           = ' || to_char(p_ccid));

  IF (g_print_debug) THEN
  	fa_rx_util_pkg.debug('fa_rx_flex_pkg.get_value(EXCEPTION)-');
  END IF;
  raise;
end get_value;



-------------------------------------------------------------------------
--
-- FUNCTION get_description
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--		p_qualifier		Flexfield qualifier or segment number
--		p_data			Flexfield Segments
--
-- Returns VARCHAR2
--   Returns the concatenated description of the key flexfield
--
-- Description
--   This function mimics the functionality of the userexit FLEXIDVAL.
--   Given the parameters, this function is equivalent to:
--	FND FLEXIDVAL
--		CODE=":p_id_flex_code"
--		APPL_SHORT_NAME="Short name from :p_application_id"
--		DATA=":p_data"
--		NUM=":p_id_flex_num"
--		DISPLAY=":p_qualifier"
--		IDISPLAY=":p_qualifier"
--		DESCRIPTION=":This is the return value"
--
-- Restrictions
--   No support for SHOWDEPSEG parameter
--   No support for VALUE, APROMPT, LPROMPT, PADDED_VALUE, SECURITY parameter
--   p_qualifier must be 'ALL' or a valid qualifier name or segment number.
--   DISPLAY and IDISPLAY are always the same p_qualifier value.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
--  Bug2948619 LGANDHI 25-MAY-2003 Modified to including Cacheing routine.
--  Bug2991482 RRAVUNNY Modified the function to accomodate the parent value for
--   dependant value sets.

-------------------------------------------------------------------------
function get_description(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number default NULL,
	p_qualifier in varchar2,
	p_data in varchar2) return varchar2
is
  segments seg_array;
  err_num number;
  sep fnd_id_flex_structures.concatenated_segment_delimiter%type;

  segnum   fnd_id_flex_segments.segment_num%type;
  colname  fnd_id_flex_segments.application_column_name%type;
  seg_value_set_id fnd_flex_value_sets.flex_value_set_id%type;

  seg_value varchar2(50);
  seg_desc fnd_flex_values_vl.description%type;
  concatenated_description varchar2(2000);
  seg_parent_value FND_FLEX_VALUES.PARENT_FLEX_VALUE_LOW%type;
  i number;

  l_qualifier	fnd_segment_attribute_types.segment_attribute_type%type;
  l_segnum	fnd_id_flex_segments.segment_num%type;
  l_id_flex_num number;
  l_counter     number := 0;
  found         boolean;
begin

--  Bug2948619 LGANDHI 25-MAY-2003 Modified to including Cacheing routine.

IF (p_application_id IS NOT NULL  AND p_id_flex_code IS NOT NULL AND p_id_flex_num IS NOT NULL
          AND 	p_qualifier IS NOT NULL AND p_data IS NOT NULL )  THEN


LOOP

IF (fa_rx_flex_desc_t.EXISTS(l_counter))   THEN
	IF (   (fa_rx_flex_desc_t(l_counter).application_id =  p_application_id)
              AND (fa_rx_flex_desc_t(l_counter).id_flex_code=p_id_flex_code)
	      AND (fa_rx_flex_desc_t(l_counter).id_flex_num =  p_id_flex_num)
              AND (fa_rx_flex_desc_t(l_counter).qualifier =  p_qualifier)
              AND (fa_rx_flex_desc_t(l_counter).data =  p_data)   )
        THEN
		RETURN fa_rx_flex_desc_t(l_counter).concatenated_description;
        ELSE
		l_counter := l_counter + 1;
	END IF;
END IF;

EXIT WHEN  (NOT fa_rx_flex_desc_t.EXISTS(l_counter));

END LOOP;

END IF;



l_id_flex_num := get_id_flex_num(p_application_id, p_id_flex_code, p_id_flex_num);
  -- Get segment delimiter
  sep := get_segment_delimiter(
		p_application_id,
		p_id_flex_code,
		l_id_flex_num);


  -- Separate out the data
  if p_qualifier = 'ALL' then
	separate_segments(segments, p_data, sep);
  else
	segments(1) := p_data;
  end if;

  i := 1;
  if cflex%isopen then close cflex;
  end if;
  begin
    l_segnum := to_number(p_qualifier);
    l_qualifier := null;
  exception
   when others then
	err_num := sqlcode;
	seg_desc := null;
	l_segnum := null;
	l_qualifier := p_qualifier;
  end;

  open cflex(p_application_id,
		p_id_flex_code,
		l_id_flex_num,
		l_qualifier,
		l_segnum);
  loop
	--
	-- For each row, get its meaning
	--

	fetch cflex into segnum, colname, seg_value_set_id;
	exit when cflex%notfound;
	seg_parent_value := Null;
	if p_qualifier = 'ALL' then
		seg_parent_value := Get_Parent_Value(segments,
				p_application_id ,
				p_id_flex_code   ,
				l_id_flex_num    ,
				seg_value_set_id);
	End If;
	seg_value := segments(i);
	begin
		seg_desc := fa_rx_shared_pkg.get_flex_val_meaning(seg_value_set_id, null, seg_value,seg_parent_value);
		dbms_output.put_line('seg_parent_value = '||seg_parent_value||' , seg_desc = '||seg_desc);
	exception
		when no_data_found then
			seg_desc := null;
		when value_error then
			seg_desc := null;
		when others then
			err_num := sqlcode;
			seg_desc := null;
	end;

	if concatenated_description is not null then
	  concatenated_description := concatenated_description || sep;
	end if;
	concatenated_description := concatenated_description ||seg_desc;

	i := i + 1;
  end loop;
  close cflex;

  if concatenated_description is null then
	--
	-- If the concatenated_description is null then that means
	-- that cflex cursor returned no rows.
	-- One of the arguments MUST be incorrect
	-- Output the parameters and raise error
	--
	raise invalid_argument;
  end if;



	IF (p_application_id IS NOT NULL  AND p_id_flex_code IS NOT NULL AND p_id_flex_num  IS NOT NULL
          AND 	p_qualifier IS NOT NULL AND p_data IS NOT NULL )  THEN

		fa_rx_flex_desc_t(l_counter).application_id := p_application_id;
		fa_rx_flex_desc_t(l_counter).id_flex_code   :=  p_id_flex_code;
		fa_rx_flex_desc_t(l_counter).id_flex_num    :=  p_id_flex_num;
		fa_rx_flex_desc_t(l_counter).qualifier      :=  p_qualifier;
		fa_rx_flex_desc_t(l_counter).data           :=  p_data;
		fa_rx_flex_desc_t(l_counter).concatenated_description :=concatenated_description;

		RETURN	fa_rx_flex_desc_t(l_counter).concatenated_description ;

	 ELSE
		 RETURN	concatenated_description ;

	END IF;

exception
when no_data_found then
	if cflex%isopen then
		close cflex;
	end if;

	raise;

when others then
	if cflex%isopen then
		close cflex;
	end if;

	raise;

end get_description;


end fa_rx_flex_pkg;

/
