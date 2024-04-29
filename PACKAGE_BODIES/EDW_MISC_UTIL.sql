--------------------------------------------------------
--  DDL for Package Body EDW_MISC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MISC_UTIL" AS
/* $Header: EDWMISCB.pls 115.7 2002/12/05 22:16:07 arsantha ship $ */

Procedure globalNamesOff IS
l_cid number;
l_dummy number;
BEGIN

        l_cid := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_cid,  ' ALTER SESSION SET global_names = false', DBMS_SQL.NATIVE);
        l_dummy := DBMS_SQL.EXECUTE(l_cid);
        DBMS_SQL.CLOSE_CURSOR(l_cid);


END;

FUNCTION formatNumber(p_input in number, sep in varchar2) return varchar2 is

hours number := 0;
minutes number := 0;
seconds number := 0;
l_ret varchar2(200) ;
l_input number := 0;
begin

if (p_input is null) then /* in cases where end date is null, due to error etc */
	return '00'||sep||'00'||sep||'00';
end if;

l_input := ceil(p_input);

if (l_input > 3600 ) then -- more than an hour
	hours := (l_input - mod(l_input, 3600)) /3600;
	l_input := l_input - hours * 3600;
	l_ret := hours;
else
	l_ret := l_ret||'00';
end if;

l_ret := l_ret ||sep;


if (l_input > 60) then -- more than one min
	minutes := (l_input - mod (l_input, 60)) / 60;
	l_input := l_input - minutes * 60;
	if (minutes > 10) then
        	l_ret := l_ret || minutes;
	else
        	l_ret := l_ret ||'0'||to_char(minutes, '' );
	end if;

else
	l_ret:= l_ret ||'00';
end if;


l_ret := l_ret ||sep;

seconds := l_input;


if (seconds > 10) then
        l_ret := l_ret || seconds;
else
        l_ret := l_ret ||'0'||seconds;
end if;

return l_ret;
end;

function get_item_default(l_db_link varchar2) return varchar2 is
l_stmt 		varchar2(1000);
result		varchar2(60);
Type CurTyp is Ref Cursor;
cv 		CurTyp;
begin

   edw_misc_util.globalnamesoff;
   l_stmt:='select mts.category_set_name from mtl_category_sets@'||l_db_link
      ||' mts, mtl_default_category_sets@'||l_db_link ||' mtd '||
	'where mts.category_set_id=mtd.category_set_id
	and mtd.functional_area_id=2
	and mts.control_level=1';

    open cv for l_stmt;
    fetch cv into result;
    close cv;
    return result;

end get_item_default;

function get_itemorg_default(l_db_link varchar2) return varchar2 is
l_stmt 		varchar2(1000);
result		varchar2(60);
Type CurTyp is Ref Cursor;
cv 		CurTyp;
begin

   edw_misc_util.globalnamesoff;
   l_stmt:='select mts.category_set_name from mtl_category_sets@'||l_db_link
      ||' mts, mtl_default_category_sets@'||l_db_link ||' mtd '||
	'where  mts.category_set_id=mtd.category_set_id
	and mtd.functional_area_id=1';
    open cv for l_stmt;
    fetch cv into result;
    close cv;
    return result;

end get_itemorg_default;


end edw_misc_util;

/
