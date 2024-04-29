--------------------------------------------------------
--  DDL for Package Body OKS_PROFILES_VISIBLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PROFILES_VISIBLE" AS
/* $Header: OKSSETPB.pls 115.4 2002/05/24 10:36:20 pkm ship        $ */

FUNCTION profile_visible_value( p_application_id number,
                                p_profile_option_id number,
                                p_level_id number,
                                p_level_value number,
                                p_lvl_val_appl_id number default NULL)  return varchar2 is

CURSOR get_sql IS
select  replace(substr(upper(fpovl.sql_validation),instr(upper(fpovl.sql_validation),'SELECT',1,1)-1,
              instr(upper(fpovl.sql_validation),'COLUMN',1,1) -
              instr(upper(fpovl.sql_validation),'SELECT',1,1)),'\','') SQL_VALID,
        fpov.profile_option_value PROF_VAL
from 	fnd_profile_options_vl fpovl,
	    fnd_profile_option_values fpov
where	fpovl.profile_option_id = p_profile_option_id
and     fpov.profile_option_id = fpovl.profile_option_id
and	    fpov.level_id = p_level_id
and     fpov.application_id = p_application_id
and     fpov.level_value   = p_level_value
and     nvl(fpov.level_value_application_id,-99) = nvl(nvl(p_lvl_val_appl_id,fpov.level_value_application_id),-99)
--and     fpovl.application_id = 515
order by fpovl.profile_option_id,fpov.level_id,fpov.level_value;


v_sql_valid	          varchar2(4000);
v_whr_loc	          number;
v_sel_loc	          number;
v_from_loc	          number;
v_into_loc	          number;
v_col_loc	          number;
v_visoval_loc	      number;
v_profoval_loc	      number;
v_visoval	          varchar2(1000);
v_profoval	          varchar2(240) :='NO_VAL';
v_profoval_num        number;
v_where_ins	          varchar2(2000);
v_where_ins_into      varchar2(2000);
i                     number := 1;

BEGIN

FOR sql_rec IN get_sql
LOOP
    v_profoval := sql_rec.prof_val;
    v_sql_valid := sql_rec.sql_valid;

if v_profoval is not null and v_sql_valid is not null then
    select instr(v_sql_valid,'INTO') into v_into_loc from dual;
    select instr(v_sql_valid,':VISIBLE_OPTION_VALUE') into v_visoval_loc from dual;
    select instr(v_sql_valid,':PROFILE_OPTION_VALUE') into v_profoval_loc from dual;
    select instr(v_sql_valid,'WHERE',-1,1) into v_whr_loc from dual;
    select instr(v_sql_valid,'FROM',1,1) into v_from_loc from dual;
--select instr(v_sql_valid,'COLUMN') into v_col_loc from dual;
--v_sql_valid := replace(v_sql_valid,substr(v_sql_valid,v_col_loc-1),'');
if v_profoval_loc < v_visoval_loc then

	v_where_ins := replace(v_sql_valid,'WHERE','WHERE '||
		substr(v_sql_valid,8,instr(v_sql_valid,',',1,1)-1-7)||' = '||''''||v_profoval||''''||' and');
	v_where_ins := substr(v_sql_valid,1,v_whr_loc-1)||'WHERE '||
		substr(v_sql_valid,8,instr(v_sql_valid,',',1,1)-1-7)||' = '||''''||v_profoval||''''||' and'||
		substr(v_sql_valid,v_whr_loc+5,length(v_sql_valid));

else

	v_where_ins := replace(v_sql_valid,'WHERE','WHERE '||
		substr(v_sql_valid,instr(v_sql_valid,',',1,1)+1,v_into_loc-1-instr(v_sql_valid,',',1,1))||' = '||''''||v_profoval||''''||' and');
end if;

v_where_ins_into := substr(v_where_ins,v_into_loc,v_from_loc-v_into_loc);
v_where_ins := replace(v_where_ins,substr(v_where_ins,v_into_loc,v_from_loc-v_into_loc),'');
v_where_ins := substr(v_where_ins,2,instr(v_where_ins,'"',-1,1)-2);


begin
if v_profoval_loc < v_visoval_loc then
execute immediate v_where_ins into v_profoval,v_visoval;
 null;
else
execute immediate v_where_ins into v_visoval,v_profoval;
null;
end if;
exception
when others then null;
end;


end if;

i := i +1 ;
END LOOP;

if v_visoval is not null then
    return v_visoval;
else
    return v_profoval;
end if;

v_sql_valid	:=null;
v_whr_loc	:=null;
v_sel_loc	:=null;
v_from_loc	:=null;
v_into_loc	:=null;
v_col_loc	:=null;
v_visoval_loc	:=null;
v_profoval_loc	:=null;
v_visoval	:=null;
v_profoval	:=null;
v_profoval_num  :=null;
v_where_ins	:=null;
v_where_ins_into :=null;

EXCEPTION
when others then return v_profoval;
end;


END OKS_PROFILES_VISIBLE;

/
