--------------------------------------------------------
--  DDL for Package Body BIS_COMMON_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COMMON_PARAMETERS" AS
/* $Header: BISGPFVB.pls 120.0.12000000.2 2007/04/20 09:03:34 rkumar ship $  */
   version          CONSTANT CHAR (80)
            := '$Header: BISGPFVB.pls 120.0.12000000.2 2007/04/20 09:03:34 rkumar ship $';


FUNCTION get_value_at_site_level(pname IN VARCHAR2) RETURN VARCHAR2 IS
   CURSOR c_profile_info(pname VARCHAR2) IS
      select profile_option_id,	application_id
        from   fnd_profile_options
        where  profile_option_name = upper(pname)
        and    start_date_active  <= sysdate
        and    nvl(end_date_active, sysdate) >= sysdate;

   CURSOR c_profile_value(pid number, aid number, lid number, lval number) IS
      select profile_option_value
	from   fnd_profile_option_values
	where  profile_option_id = pid
	and    application_id    = aid
	and    level_id          = lid
	and    level_value       = lval;

   v_pid NUMBER;
   v_aid NUMBER;
   v_lid NUMBER;
   v_lval NUMBER;
   v_profile_val VARCHAR2(240);
BEGIN
   IF(pname IS NULL OR pname = '') THEN
      RETURN NULL;
   END IF;

   OPEN c_profile_info(pname);
   FETCH c_profile_info INTO v_pid, v_aid;
   IF (c_profile_info%NOTFOUND) THEN
      CLOSE c_profile_info;
      RETURN NULL;
   END IF;
   CLOSE c_profile_info;

   v_lid := 10001;
   v_lval := 0;
   OPEN c_profile_value(v_pid, v_aid, v_lid, v_lval);
   FETCH c_profile_value INTO v_profile_val;
   IF (c_profile_value%NOTFOUND) THEN
      CLOSE c_profile_value;
      RETURN NULL;
   END IF;
   CLOSE c_profile_value;

   RETURN v_profile_val;
END;



FUNCTION HIGH 	return number IS
BEGIN
    BIS_COLLECTION_UTILITIES.put_line('within HIGH');
	return  nvl(to_number(FND_PROFILE.VALUE('BIS_TXN_COMPLEXITY_HIGH'),'999999999999999.9999999999999'), 0.5);
END;

FUNCTION MEDIUM 	return number IS
BEGIN
    BIS_COLLECTION_UTILITIES.put_line('within MEDIUM');
	return  nvl(to_number(FND_PROFILE.VALUE('BIS_TXN_COMPLEXITY_MEDIUM'),'999999999999999.9999999999999'),1.0);
END;

FUNCTION LOW 	return number IS
BEGIN
    BIS_COLLECTION_UTILITIES.put_line('within LOW');
	return  nvl(to_number(FND_PROFILE.VALUE('BIS_TXN_COMPLEXITY_LOW'),'999999999999999.9999999999999'), 2.0);
END;



FUNCTION get_rate_type RETURN varchar2 is
 l_rate_type varchar2(30);
 begin
    ---l_rate_type:=fnd_profile.value('BIS_PRIMARY_RATE_TYPE');
    l_rate_type:=get_value_at_site_level('BIS_PRIMARY_RATE_TYPE');
    return l_rate_type;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
 end;


FUNCTION get_secondary_rate_type return varchar2  is
l_second_rate_type varchar2(30);
begin
    ---l_second_rate_type:=fnd_profile.value('BIS_SECONDARY_RATE_TYPE');
    l_second_rate_type:=get_value_at_site_level('BIS_SECONDARY_RATE_TYPE');
    return l_second_rate_type;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_currency_code  return varchar2 is
 l_currency_code varchar2(15);
begin
    --l_currency_code:=fnd_profile.value('BIS_PRIMARY_CURRENCY_CODE');
      l_currency_code:=get_value_at_site_level('BIS_PRIMARY_CURRENCY_CODE');
     return l_currency_code;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_secondary_currency_code  return varchar2 is
  l_second_curr_code varchar2(15);
begin
   --- l_second_curr_code:=fnd_profile.value('BIS_SECONDARY_CURRENCY_CODE');
   l_second_curr_code:=get_value_at_site_level('BIS_SECONDARY_CURRENCY_CODE');
    return l_second_curr_code;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;



function get_period_set_name return varchar2 is
  l_period_set_name varchar2(15);
begin
  --- l_period_set_name:=fnd_profile.value('BIS_ENTERPRISE_CALENDAR');
     l_period_set_name:=get_value_at_site_level('BIS_ENTERPRISE_CALENDAR');
   return l_period_set_name;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;



function get_START_DAY_OF_WEEK_ID  return varchar2 is
 l_start_dayofweek varchar2(30);
begin
     ---l_start_dayofweek:=fnd_profile.value('BIS_START_DAY_OF_WEEK');
     l_start_dayofweek:=get_value_at_site_level('BIS_START_DAY_OF_WEEK');
     return l_start_dayofweek;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_period_type  return varchar2 is
 l_period_type  varchar2(15);
begin
    ---l_period_type:=fnd_profile.value('BIS_PERIOD_TYPE');
    l_period_type:=get_value_at_site_level('BIS_PERIOD_TYPE');
    return l_period_type;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_workforce_mes_type_id  return varchar2 is
  l_workforce_mes_type_id varchar2(30);
 begin
  --  l_workforce_mes_type_id:=fnd_profile.value('BIS_WORKFORCE_MEASUREMENT_TYPE');
      l_workforce_mes_type_id:=get_value_at_site_level('BIS_WORKFORCE_MEASUREMENT_TYPE');
    return l_workforce_mes_type_id;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_auto_factor_mode  return varchar2 is
  l_get_auto_factor_mode varchar2(30);
 begin
    ---l_get_auto_factor_mode:=fnd_profile.value('BIS_AUTO_FACTOR');
     l_get_auto_factor_mode:=get_value_at_site_level('BIS_AUTO_FACTOR');
    return l_get_auto_factor_mode;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;



function get_ITM_HRCHY3_VBH_TOP_NODE   return varchar2 is
  l_ITM_HRCHY3_VBH_TOP_NODE  varchar2(150);
 begin
    ---l_ITM_HRCHY3_VBH_TOP_NODE:=fnd_profile.value('BIS_ITEM_HIERARCHY3_VBH_TOP_NODE');
    l_ITM_HRCHY3_VBH_TOP_NODE:=get_value_at_site_level('BIS_ITEM_HIERARCHY3_VBH_TOP_NODE');
    return l_ITM_HRCHY3_VBH_TOP_NODE;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
 end;


function get_GLOBAL_START_DATE   return date is
l_global_start_date varchar2(30);
 begin
    -- l_global_start_date:=fnd_profile.value('BIS_GLOBAL_START_DATE');
     l_global_start_date:=get_value_at_site_level('BIS_GLOBAL_START_DATE');
     return to_date(l_global_start_date, 'mm/dd/yyyy');
 exception
    when no_data_found then
        return null;
    when others then
        raise;
 end;

function get_implementation_type    return varchar2 is
l_implementation_type varchar2(30);
begin
  --- l_implementation_type:=fnd_profile.value('BIS_IMPLEMENTATION_TYPE');
   l_implementation_type:=get_value_at_site_level('BIS_IMPLEMENTATION_TYPE');
   return l_implementation_type;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;

function get_item_category_set_1     return varchar2 is
l_item_category_set varchar2(30);
begin
--l_item_category_set:=fnd_profile.value('BIS_ITEM_CATEGORY_SET_1');
l_item_category_set:=get_value_at_site_level('BIS_ITEM_CATEGORY_SET_1');
return l_item_category_set;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_item_category_set_2     return varchar2 is
l_item_category_set varchar2(30);
begin
--l_item_category_set:=fnd_profile.value('BIS_ITEM_CATEGORY_SET_2');
l_item_category_set:=get_value_at_site_level('BIS_ITEM_CATEGORY_SET_2');
return l_item_category_set;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_item_category_set_3     return varchar2 is
l_item_category_set varchar2(30);
begin
--l_item_category_set:=fnd_profile.value('BIS_ITEM_CATEGORY_SET_3');
l_item_category_set:=get_value_at_site_level('BIS_ITEM_CATEGORY_SET_3');
return l_item_category_set;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_item_org_catset_1      return varchar2 is
l_item_org_catset varchar2(30);
begin
--- l_item_org_catset:=fnd_profile.value('BIS_ITEM_ORG_CATEGORY_SET_1');
 l_item_org_catset:=get_value_at_site_level('BIS_ITEM_ORG_CATEGORY_SET_1');
 return l_item_org_catset;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;

function get_item_hierarchy3_type     return varchar2 is
l_item_hierarchy3_type varchar2(30);
begin
-- l_item_hierarchy3_type:=fnd_profile.value('BIS_ITEM_HIERARCHY3_TYPE');
 l_item_hierarchy3_type:=get_value_at_site_level('BIS_ITEM_HIERARCHY3_TYPE');
 return l_item_hierarchy3_type;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;

function get_master_instance     return varchar2 is
l_master_instance varchar2(30);
begin
-- l_master_instance:=fnd_profile.value('BIS_MASTER_INSTANCE');
l_master_instance:=get_value_at_site_level('BIS_MASTER_INSTANCE');
 return l_master_instance;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


--rkumar:bug5864925
FUNCTION remove_extra_spaces(INPUT IN  VARCHAR2) RETURN VARCHAR2 IS
        loop_length NUMBER;
        spaceflag NUMBER(1);
        tmp_char VARCHAR2(1);
        result_string VARCHAR2(4000);
BEGIN
        loop_length := LENGTH(INPUT);
        spaceflag := 0;
        FOR i IN 1 .. loop_length
        LOOP
          tmp_char := SUBSTR(INPUT,   i,   1);
          IF tmp_char = ' ' THEN
            IF spaceflag = 1 THEN
              NULL;
            ELSE
              spaceflag := 1;
              result_string := result_string || tmp_char;
            END IF;
          ELSE
            IF spaceflag = 1 THEN
              spaceflag := 0;
              result_string := result_string || tmp_char;
            ELSE
              result_string := result_string || tmp_char;
            END IF;
          END IF;
        END LOOP;

        RETURN result_string;
END;

function GET_DISPLAY_VALUE(NAME in varchar2) return varchar2 is
        l_temp VARCHAR2(4000);
        sqlvalidation VARCHAR2(4000);
        l_sql VARCHAR2(4000);
        l_val VARCHAR2(255);
        l_display_val VARCHAR2(255);
        l_start_index number;
        l_end_index number;
        l_into_index number;
        l_from_index number;
        l_where_index number;
        l_stmt varchar2(4000);
begin
	l_val := get_value_at_site_level(upper(name));

	if (l_val is null) or (l_val = '') then
	  return '';
	end if;

        --get sqlvalidation
        l_temp := 'select upper(sql_validation) from fnd_profile_options where profile_option_name = UPPER(:name)';
        execute immediate l_temp into sqlvalidation using name;

	--if there is no sql validation, display value is same as internal value.
        if (sqlvalidation is null) then
	  return l_val;
	end if;

        --get parsed sql l_sql
        l_start_index := instr(sqlvalidation, '"', 1, 1);
        l_end_index := instr(sqlvalidation, 'COLUMN=', 1, 1);
        l_temp := substr(sqlvalidation, l_start_index+1, l_end_index-l_start_index-1);

        -- now backtrack till we hit the first " from the reverse

         --l_end_index := l_end_index - instr(substr(l_temp, l_start_index, l_end_index), '"' -1,1);

        l_temp := substr(l_temp, 1, instr(l_temp,'"', -1,1)-1);
        --Bug#5864925 updated to suppport multiple spaces between into and :
        l_temp := remove_extra_spaces(l_temp);
        l_into_index := instr(l_temp, 'INTO :', 1, 1); --??? what if other words have 'into'?
        l_from_index := instr(l_temp, 'FROM', l_into_index, 1);
        l_sql := substr(l_temp, 1, l_into_index-1) || substr(l_temp, l_from_index, length(l_temp)-l_from_index+1);

        --get display value from l_sql
	l_stmt := 'SELECT LOOKUP_CODE, MEANING FROM (' || l_sql ||
		') WHERE LOOKUP_CODE = :val';

        -- REMOVE \" and contents between successive \" that is
	-- found in some EDW profiles : EDW_DEBUG and EDW_TRACE
        -- BUG 2516318
        LOOP
            l_start_index := 0;
            l_end_index := 0;
            L_START_INDEX := instr(l_stmt, '\"', 1, 1);
            L_END_INDEX := instr(l_stmt, '\"', 1, 2);
            EXIT WHEN l_start_index =0 OR l_end_index = 0;
            L_STMT := substr(l_stmt, 1, L_START_INDEX-1) || substr(l_stmt, l_end_index+2);
        END LOOP;
        execute immediate l_stmt into l_val, l_display_val using l_val;


        return l_display_val;
end get_display_value ;

  procedure get_global_parameters(
	 p_parameter_list	IN DBMS_SQL.VARCHAR2_TABLE,
	 p_attribute_values	OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE) IS
 l_count  number :=0 ;
 l_profile_name varchar2(100);

 BEGIN
null;

	IF (p_parameter_list.count = 0) THEN
		return;
	END IF;

	l_count := p_parameter_list.first;


	LOOP
		l_profile_name := p_parameter_list(l_count);
	  	IF (l_profile_name = 'EDW_DEBUG') THEN
		  l_profile_name := 'BIS_PMF_DEBUG';
	  	ELSIF (l_profile_name = 'EDW_TRACE') THEN
		  l_profile_name := 'BIS_SQL_TRACE';
	  	END IF;

	   p_attribute_values(l_count) := fnd_profile.value(l_profile_name);

	  EXIT WHEN l_count = p_parameter_list.last;
	  l_count := p_parameter_list.next(l_count);
	END LOOP;

	EXCEPTION WHEN OTHERS THEN
		p_attribute_values.delete;
		raise;

 END;

   FUNCTION check_global_parameters(
	p_parameter_list       IN DBMS_SQL.VARCHAR2_TABLE) return BOOLEAN IS
  l_count number := 0;
  l_profile_list varchar2(3000) := '';
  l_new_line  varchar2(10):='
';
  l_return_value boolean := true;
  l_profile_name varchar2(100);

  BEGIN

	l_return_value := true;
	l_profile_list := null;
	IF (p_parameter_list.count = 0) THEN
		return true;
	END IF;

	l_count := p_parameter_list.first;

	LOOP

	  l_profile_name := p_parameter_list(l_count);
	  IF (l_profile_name = 'EDW_DEBUG') THEN
		l_profile_name := 'BIS_PMF_DEBUG';
	  ELSIF (l_profile_name = 'EDW_TRACE') THEN
		l_profile_name := 'BIS_SQL_TRACE';
	  END IF;

	  IF (fnd_profile.value(l_profile_name) IS NULL) THEN

		l_profile_list := l_profile_list || l_profile_name;
		l_return_value := false;
	  END IF;

	  EXIT WHEN l_count = p_parameter_list.last;
	  l_count := p_parameter_list.next(l_count);


	END LOOP;

	IF (l_return_value) THEN
		null;
	ELSE
	fnd_message.set_name('BIS', 'BIS_DBI_PROFILE_NOT_SET');
        fnd_message.set_token('PROFILE', l_profile_list);

	bis_collection_utilities.log(fnd_message.get);
	END IF;

	return l_return_value;
  END;




FUNCTION get_batch_size(p_complexity_level IN NUMBER) RETURN NUMBER IS

l_batch_size number := 10000;

BEGIN
     BIS_COLLECTION_UTILITIES.put_line('within get_batch_size');
	IF (p_complexity_level > 0) THEN
		l_batch_size := nvl(FND_PROFILE.value('EDW_PUSH_SIZE'), 10000) * p_complexity_level;
        BIS_COLLECTION_UTILITIES.put_line('l_batch_size: '||l_batch_size);
	ELSE
		return 10000;
	END IF;

	IF (l_batch_size < 1000) THEN
		return 1000;
	ELSE
		return l_batch_size;
	END IF;

END;

FUNCTION get_degree_of_parallelism RETURN NUMBER IS
l_parallel number;
BEGIN

	l_parallel := null;
	l_parallel := floor(fnd_profile.value('EDW_PARALLEL_SRC')); -- gets value of profile option

	  /* Set by the customer, return this value */

	  IF (l_parallel IS NOT NULL and l_parallel > 0) THEN
 		return l_parallel;
	  END IF;

	  /* Not set by customer, so query v$parameters */

	  begin
     -------Changed to the following logic for bug 4007212.
     ----the logic was given by performance team
      select min(para.value) into  l_parallel
	  from v$parameter para
	  where para.name in ('cpu_count','parallel_max_servers');

      exception when no_data_found then
			l_parallel := 1;
	  end;

	  IF (l_parallel IS NULL) THEN
		l_parallel:=1;
	  END IF;

	  l_parallel := floor(l_parallel/2);
	  IF (l_parallel = 0) THEN
		l_parallel := 1;
	  END IF;

	  return l_parallel;

END;


function GET_PRIMARY_CURDIS_NAME return varchar2
is
  l_name VARCHAR2(300) := null;
begin
  --l_name := fnd_profile.value('BIS_PRIMARY_CURDISP_NAME'); -- gets value of profile option
  l_name:=get_value_at_site_level('BIS_PRIMARY_CURDISP_NAME');
  return l_name;
end;

function GET_SECONDARY_CURDIS_NAME return varchar2
is
  l_name VARCHAR2(300) := null;
begin
---  l_name := fnd_profile.value('BIS_SECONDARY_CURDISP_NAME'); -- gets value of profile option
  l_name:=get_value_at_site_level('BIS_SECONDARY_CURDISP_NAME');
  return l_name;
end;




FUNCTION get_current_date_id return DATE IS
l_date DATE := trunc(sysdate);
BEGIN

	BEGIN
	SELECT current_date_id into l_date FROM bis_system_date;
	return l_date;

	EXCEPTION when no_data_found THEN
		return null;
	END;

END;


FUNCTION get_annualized_rate_type return varchar2  is
l_annual_rate_type varchar2(30);
begin
   ---l_annual_rate_type:=fnd_profile.value('BIS_ANNUALIZED_RATE_TYPE');
    l_annual_rate_type:=get_value_at_site_level('BIS_ANNUALIZED_RATE_TYPE');
    return l_annual_rate_type;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;


function get_annualized_currency_code  return varchar2 is
  l_annual_curr_code varchar2(15);
begin
   --- l_annual_curr_code:=fnd_profile.value('BIS_ANNUALIZED_CURRENCY_CODE');
    l_annual_curr_code:=get_value_at_site_level('BIS_ANNUALIZED_CURRENCY_CODE');
    return l_annual_curr_code;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;

function GET_ANNUALIZED_CURDIS_NAME  return varchar2
is
  l__disp_name VARCHAR2(300);
begin
  ---l__disp_name := fnd_profile.value('BIS_ANNUALIZED_CURDISP_NAME'); -- gets value of profile option
   l__disp_name:=get_value_at_site_level('BIS_ANNUALIZED_CURDISP_NAME');
  return l__disp_name;
 exception
    when no_data_found then
        return null;
    when others then
        raise;
end;

-- get the profile option value at site level
-- although this profile option is enabled for site, application, responsibility, and user levels
FUNCTION get_low_percentage_range RETURN VARCHAR2
IS
   l_low_percentage_range VARCHAR2(300);
BEGIN
   l_low_percentage_range := get_value_at_site_level('BIS_PMV_CHANGE_LOW_RANGE'); -- gets value of profile option
   RETURN l_low_percentage_range;
EXCEPTION
   when no_data_found then
      return null;
   when others then
      raise;
END get_low_percentage_range;


-- get the profile option value at site level
-- although this profile option is enabled for site, application, responsibility, and user levels
FUNCTION get_high_percentage_range
  RETURN VARCHAR2
IS
   l_high_percentage_range VARCHAR2(300);
BEGIN
   l_high_percentage_range := get_value_at_site_level('BIS_PMV_CHANGE_HIGH_RANGE'); -- gets value of profile option
   RETURN l_high_percentage_range;
EXCEPTION
   when no_data_found then
      return null;
   when others then
      RAISE;
END get_high_percentage_range;


FUNCTION get_treasury_rate_type
  RETURN VARCHAR2
IS
   l_treasury_rate_type VARCHAR2(300);
BEGIN
  ---l_treasury_rate_type := fnd_profile.value('BIS_TREASURY_RATE_TYPE'); -- gets value of profile option
  l_treasury_rate_type:=get_value_at_site_level('BIS_TREASURY_RATE_TYPE');
  RETURN l_treasury_rate_type;
EXCEPTION
   when no_data_found then
      return null;
   when others then
      raise;
END get_treasury_rate_type;

FUNCTION GET_BIS_CUST_CLASS_TYPE
  RETURN VARCHAR2
IS
l_cust_class_type VARCHAR2(300);
BEGIN
--  l_cust_class_type := fnd_profile.value('BIS_CUST_CLASS_TYPE'); -- gets value of profile option
    l_cust_class_type:= get_value_at_site_level('BIS_CUST_CLASS_TYPE'); -- gets value of profile option
  RETURN l_cust_class_type;
EXCEPTION
   when no_data_found then
      return null;
   when others then
      raise;
END GET_BIS_CUST_CLASS_TYPE;

END bis_common_parameters;


/
