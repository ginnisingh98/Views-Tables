--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_SETUP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_SETUP_UTIL_PKG" AS
/* $Header: ISCPSFUB.pls 120.1 2006/07/31 23:42:26 scheung noship $ */

function  is_plan_name_exists		(p_plan_name		in	varchar2) return varchar2 is
	l_dblink			varchar2(1000);
	l_stmt				varchar2(1000);
	l_cursor_id			number;
	l_dummy				number;
	l_result			varchar2(1);

begin

	 l_dblink := fnd_profile.value('ISC_DBI_PLANNING_INSTANCE');

	 if (l_dblink is null or l_dblink = '') then

	    select decode(ltrim(a2m_dblink, ' '), NULL, NULL, '@'||a2m_dblink)
	    into l_dblink
	    from mrp_ap_apps_instances_all;

	elsif (l_dblink = '@') then

	    l_dblink := NULL;

        end if;

	l_stmt := 'select ''Y'' from msc_plans'||l_dblink||' msc where :plan_name in msc.compile_designator '||
		  'and curr_plan_type <> 4';
	l_cursor_id := dbms_sql.open_cursor;
	dbms_sql.parse(l_cursor_id,l_stmt,dbms_sql.native);
	dbms_sql.bind_variable(l_cursor_id, ':plan_name', p_plan_name);
	dbms_sql.define_column(l_cursor_id, 1, l_result, 1);
	l_dummy := dbms_sql.execute(l_cursor_id);
	l_dummy := dbms_sql.fetch_rows(l_cursor_id);
	dbms_sql.column_value(l_cursor_id, 1, l_result);
	dbms_sql.close_cursor(l_cursor_id);

	if (l_result = 'Y') then
		return 'Y';
	else
		return 'N';
	end if;

	exception
	when others then
		dbms_sql.close_cursor(l_cursor_id);
		raise;

end;


function  get_next_collection_date	(p_frequency		in	varchar2,
					 p_days_offset		in	number,
					 p_reference_date	in	date) return date is
	l_cursor_id			number;
	l_dummy				number;
	l_stmt				varchar2(10000);
	l_table_name			varchar2(1000);
	l_col_name			varchar2(100);
	l_result			date;
	l_days_offset			number;

begin
	if (p_frequency = 'ONCE') then
		return trunc(sysdate)+p_days_offset-1;
	elsif (p_frequency = 'WEEKLY')
		then l_table_name := 'FII_TIME_WEEK';
	elsif (p_frequency = 'MONTHLY')
		then l_table_name := 'FII_TIME_ENT_PERIOD';
	elsif (p_frequency = 'QUARTERLY')
		then l_table_name := 'FII_TIME_ENT_QTR';
	else -- (p_frequency = 'YEARLY')
		     l_table_name := 'FII_TIME_ENT_YEAR';
	end if;

	if (p_days_offset > 0) then
		l_days_offset := p_days_offset - 1;
		l_col_name := 'start_date';
	else -- p_days_offset < 0
		l_days_offset := p_days_offset + 1;
		l_col_name := 'end_date';
	end if;

	if (l_days_offset >= 0) then
	  l_stmt := 'select min(f.'||l_col_name||')+'||l_days_offset||' from '||
		    l_table_name||' f where f.'||l_col_name||' >= trunc(:reference_date)-'||l_days_offset;
	else
  	  l_stmt := 'select min(f.'||l_col_name||')'||l_days_offset||' from '||
		    l_table_name||' f where f.'||l_col_name||' >= trunc(:reference_date)+'||abs(l_days_offset);
	end if;


	l_cursor_id := dbms_sql.open_cursor;
	dbms_sql.parse(l_cursor_id,l_stmt,dbms_sql.native);
	dbms_sql.bind_variable(l_cursor_id, ':reference_date', p_reference_date);
	dbms_sql.define_column(l_cursor_id, 1, l_result);
	l_dummy := dbms_sql.execute(l_cursor_id);
	l_dummy := dbms_sql.fetch_rows(l_cursor_id);
	dbms_sql.column_value(l_cursor_id, 1, l_result);
	dbms_sql.close_cursor(l_cursor_id);
	return l_result;

	exception
	when others then
		dbms_sql.close_cursor(l_cursor_id);
		raise;
end;


-- Called by Setup Form UI
function get_next_collection_date	(p_frequency		in	varchar2,
					 p_days_offset		in	number) return date is
begin
	return get_next_collection_date(p_frequency, p_days_offset, sysdate);
end;


-- Called by Collection Program
function  get_next_collection_date	(p_plan_name		in	varchar2) return date is
	l_next_collection_date		date;
begin
	 select get_next_collection_date(frequency, days_offset, sysdate+1)
	   into	l_next_collection_date
	   from	isc_dbi_plan_schedules
	  where	plan_name = p_plan_name;

	return l_next_collection_date;

	exception
	when others then
		raise;
end;

END ISC_DBI_PLAN_SETUP_UTIL_PKG;

/
