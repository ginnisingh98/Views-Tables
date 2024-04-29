--------------------------------------------------------
--  DDL for Package Body OZF_COMMON_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_COMMON_PARAMETERS_PVT" AS
/* $Header: ozfvcomb.pls 115.1 2003/11/04 19:40:30 mkothari noship $  */
   VERSION  CONSTANT VARCHAR (80) := '$Header: ozfvcomb.pls 115.1 2003/11/04 19:40:30 mkothari noship $';


FUNCTION GET_PERIOD_SET_NAME RETURN VARCHAR2 IS
  l_period_set_name varchar2(15);
BEGIN
-- l_period_set_name:='Accounting';

   l_period_set_name:=fnd_profile.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   return l_period_set_name;
EXCEPTION
    when no_data_found then
        return null;
    when others then
        raise;
END;



FUNCTION GET_START_DAY_OF_WEEK_ID  RETURN VARCHAR2 IS
 l_start_dayofweek varchar2(30);
BEGIN
--     l_start_dayofweek:='2';

     l_start_dayofweek:=fnd_profile.value('OZF_TP_START_DAY_OF_WEEK');
     return l_start_dayofweek;
EXCEPTION
    when no_data_found then
        return null;
    when others then
        raise;
END;


FUNCTION GET_PERIOD_TYPE  RETURN VARCHAR2 IS
 l_period_type  varchar2(15);
BEGIN
--    l_period_type:='Month';
    l_period_type:=fnd_profile.value('OZF_TP_PERIOD_TYPE');
    return l_period_type;
EXCEPTION
    when no_data_found then
        return null;
    when others then
        raise;
END;


FUNCTION GET_GLOBAL_START_DATE   RETURN DATE IS
l_global_start_date varchar2(30);
BEGIN
     l_global_start_date:=fnd_profile.value('OZF_TP_GLOBAL_START_DATE');
     return to_date(l_global_start_date, 'mm/dd/yyyy');
EXCEPTION
    when no_data_found then
        return null;
    when others then
        raise;
END;


FUNCTION CHECK_GLOBAL_PARAMETERS(
  p_parameter_list       IN DBMS_SQL.VARCHAR2_TABLE)
  RETURN BOOLEAN IS

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
           fnd_message.set_name('OZF', 'OZF_TP_PROFILE_NOT_SET');
           fnd_message.set_token('PROFILE', l_profile_list);
	   OZF_TP_UTIL_PVT.put_line(fnd_message.get);
	END IF;

	return l_return_value;
END;



FUNCTION get_degree_of_parallelism RETURN NUMBER IS
l_parallel number;
BEGIN

	l_parallel := null;
        l_parallel := floor(fnd_profile.value('OZF_TP_PARALLEL_SRC'));


          /* If set by the customer, return this value */

	  IF (l_parallel IS NOT NULL and l_parallel > 0) THEN
 		return l_parallel;
	  END IF;


	  /* If Not set by customer, so query v$pq_sysstat */
	  BEGIN

	  SELECT value INTO l_parallel
	  FROM v$pq_sysstat WHERE trim(statistic) = 'Servers Idle';

	  EXCEPTION when no_data_found then
			l_parallel := 1;
	  END;

	  IF (l_parallel IS NULL) THEN
		l_parallel:=1;
	  END IF;

	  l_parallel := floor(l_parallel/2);
	  IF (l_parallel = 0) THEN
		l_parallel := 1;
	  END IF;

	  return l_parallel;

END;


END ozf_common_parameters_pvt;

/
