--------------------------------------------------------
--  DDL for Package Body BIX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_UTIL_PKG" AS
/*$Header: bixxutlb.pls 115.36 2003/07/31 21:09:56 djambula ship $*/

FUNCTION get_hrmiss_frmt(seconds IN NUMBER) RETURN VARCHAR2
IS
BEGIN

  IF (seconds IS NULL) THEN
    RETURN NULL;
  ELSIF (FLOOR(ROUND(seconds)/3600) > 99 ) THEN
  RETURN FLOOR(ROUND(seconds)/3600)|| ':' ||
         LPAD(FLOOR(MOD(ROUND(seconds),3600)/60),2,'0') || ':' ||
         LPAD(MOD(ROUND(seconds),60),2,'0');
  ELSE
    RETURN LPAD(FLOOR(ROUND(seconds)/3600),2,'0')|| ':' ||
	      LPAD(FLOOR(MOD(ROUND(seconds),3600)/60),2,'0') || ':' ||
		   LPAD(MOD(ROUND(seconds),60),2,'0');
  END IF;

END get_hrmiss_frmt;

FUNCTION get_hrmi_frmt(seconds IN NUMBER) RETURN VARCHAR2
IS
BEGIN

  IF (seconds IS NULL) THEN
    RETURN NULL;
  ELSE
    IF MOD(seconds,60) < 30 THEN
	  RETURN LPAD(FLOOR(seconds/3600),2,'0')|| ':' ||
				  LPAD(FLOOR(MOD(seconds,3600)/60),2,'0');
    ELSE
	  RETURN LPAD(FLOOR(seconds/3600),2,'0')|| ':' ||
				 LPAD(FLOOR(MOD(seconds,3600)/60)+1,2,'0');
    END IF;
  END IF;

END get_hrmi_frmt;

PROCEDURE get_time_range(p_time_id in number, p_from_date out nocopy date, p_to_date out nocopy date) IS

l_sysdate    DATE;

BEGIN

  SELECT sysdate
  INTO   l_sysdate
  FROM   dual;

  IF (p_time_id = 1) THEN
    p_from_date := trunc(l_sysdate,'IW');
    p_to_date   := l_sysdate;
  ELSIF (p_time_id = 2) THEN
    p_from_date := trunc(l_sysdate,'IW') - 7;
    p_to_date   := sysdate - 7;
  ELSIF (p_time_id = 3) THEN
    p_from_date := trunc(l_sysdate,'MM');
    p_to_date   := l_sysdate;
  ELSIF (p_time_id = 4) THEN
    p_from_date := to_date('01-' || to_char(trunc(l_sysdate,'MM') - 1,'mm-yyyy'),'dd-mm-yyyy');
    IF (to_char(last_day(p_from_date),'dd') >= to_char(l_sysdate,'dd')) THEN
	 p_to_date := to_date(to_char(l_sysdate,'dd') || '-' || to_char(p_from_date,'mm') || '-' ||
					 to_char(l_sysdate,'yyyy') , 'dd-mm-yyyy');
    ELSE
	 p_to_date := last_day(p_from_date);
    END IF;
  ELSIF (p_time_id = 5) THEN
    p_from_date := to_date('01/01/' || to_char(l_sysdate,'yyyy') , 'dd/mm/yyyy');
    p_to_date   := l_sysdate;
  ELSIF (p_time_id = 6) THEN
    p_from_date := to_date('01/01/' || to_char(to_number(to_char(l_sysdate,'yyyy')) - 1) , 'dd/mm/yyyy');
    p_to_date   := to_date(to_char(l_sysdate,'dd-mm-') ||
						to_char(to_number(to_char(l_sysdate,'yyyy')) - 1) , 'dd-mm-yyyy');
  END IF;

  p_to_date := to_date(to_char(p_to_date,'dd/mm/yyyy') || ' 23:59:59', 'dd/mm/yyyy hh24:mi:ss');

EXCEPTION
   WHEN OTHERS THEN
    RAISE;
END get_time_range;


 FUNCTION get_uwq_refresh_date
 (p_context in varchar2 )
 RETURN VARCHAR2 IS
    l_max_date  VARCHAR2(25);
    l_uwq_max_date DATE;
    l_collect_max_date DATE;

    l_date_format VARCHAR2(50);

BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;


  select max(day)
         into l_uwq_max_date
  from   bix_dm_uwq_agent_sum;

    SELECT MAX(collect_end_date) INTO l_collect_max_date
    FROM bix_dm_collect_log
    WHERE object_name = 'BIX_DM_UWQ_GROUP_SUM';


   IF ( (TRUNC(l_collect_max_date) - l_uwq_max_date ) > 0) THEN
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| ' 23:59:59';
   ELSIF( (TRUNC(l_collect_max_date) - l_uwq_max_date ) = 0) THEN
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| to_char(l_collect_max_date,' HH24:MI:SS');
   ELSE
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| ' 00:00:00';
   END IF;


  IF l_max_date IS NULL
  THEN
	RETURN NULL;
  ELSE
     RETURN l_max_date ;
  END IF;

 EXCEPTION
 WHEN OTHERS
 THEN
    RETURN NULL;
 END get_uwq_refresh_date;

 FUNCTION get_calls_refresh_date
 (p_context in varchar2 )
 RETURN VARCHAR2 IS
    l_max_date  VARCHAR2(25);
    l_date_format VARCHAR2(50);
 BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_agent_call_sum;
    RETURN l_max_date;
 EXCEPTION
 WHEN OTHERS
 THEN
    RETURN NULL;
 END get_calls_refresh_date;

FUNCTION bix_dm_get_footer(p_context in VARCHAR2 )
         RETURN VARCHAR2 IS
l_max_date VARCHAR2(20);
l_date_format VARCHAR2(50);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_agent_call_sum;
  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_FOOTER;

FUNCTION bix_real_get_footer(p_context in VARCHAR2 )
         RETURN VARCHAR2 IS
l_date_format VARCHAR2(50);
l_max_date VARCHAR2(20);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  l_max_date := to_char(sysdate, l_date_format);
  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_REAL_GET_FOOTER;

FUNCTION get_uwq_footer(p_context in VARCHAR2 )
         RETURN VARCHAR2 IS
    l_max_date  VARCHAR2(25);
    l_uwq_max_date DATE;
    l_collect_max_date DATE;

    l_date_format VARCHAR2(50);

BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;


  select max(day)
         into l_uwq_max_date
  from   bix_dm_uwq_agent_sum;

    SELECT MAX(collect_end_date) INTO l_collect_max_date
    FROM bix_dm_collect_log
    WHERE object_name = 'BIX_DM_UWQ_GROUP_SUM';


   IF ( (TRUNC(l_collect_max_date) - l_uwq_max_date ) > 0) THEN
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| ' 23:59:59';
   ELSIF( (TRUNC(l_collect_max_date) - l_uwq_max_date ) = 0) THEN
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| to_char(l_collect_max_date,' HH24:MI:SS');
   ELSE
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| ' 00:00:00';
   END IF;

  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END GET_UWQ_FOOTER;

FUNCTION get_uwq_duration_footer(p_context in VARCHAR2 )
         RETURN VARCHAR2 IS
    l_max_date  VARCHAR2(25);
    l_uwq_max_date DATE;
    l_collect_max_date DATE;

    l_date_format VARCHAR2(50);

BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;


  select max(day)
         into l_uwq_max_date
  from   bix_dm_uwq_agent_sum;

    SELECT MAX(collect_end_date) INTO l_collect_max_date
    FROM bix_dm_collect_log
    WHERE object_name = 'BIX_DM_UWQ_GROUP_SUM';


   IF ( (TRUNC(l_collect_max_date) - l_uwq_max_date ) > 0) THEN
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| ' 23:59:59';
   ELSIF( (TRUNC(l_collect_max_date) - l_uwq_max_date ) = 0) THEN
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| to_char(l_collect_max_date,' HH24:MI:SS');
   ELSE
	 l_max_date := to_char(l_uwq_max_date,l_date_format)|| ' 00:00:00';
   END IF;

  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '||
         l_max_date || ' '||
         FND_MESSAGE.GET_STRING('BIX','BIX_DM_DURATION_FORMAT');
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END GET_UWQ_DURATION_FOOTER;

FUNCTION get_realtime_footer(p_context in VARCHAR2 )
         RETURN VARCHAR2 IS
l_max_date VARCHAR2(20);
l_date_format VARCHAR2(50);
BEGIN
  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  IF(l_date_format IS NULL) THEN
  l_date_format := 'MM/DD/YYYY';
  END IF;
  l_date_format := l_date_format||' HH24:MI:SS';
  SELECT to_char(sysdate,l_date_format)
  INTO   l_max_date
  FROM   dual;
  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END GET_REALTIME_FOOTER;

procedure get_conversion_rate(p_from_currency   IN  VARCHAR2,
						p_to_currency     IN  VARCHAR2,
                              p_conversion_date IN  DATE,
                              p_conversion_type IN  VARCHAR2,
                              p_denom_rate      OUT nocopy NUMBER,
                              p_num_rate        OUT nocopy NUMBER,
                              p_status          OUT nocopy NUMBER) is
l_num_rate     number ;
l_denom_rate   number ;
l_conv_rate    number ;
l_max_rollback_days    number ;

BEGIN
	  IF p_from_currency = p_to_currency
	  THEN
            l_denom_rate := 1;
		  l_num_rate := 1;
    	  ELSE
          l_max_rollback_days := fnd_profile.value('BIX_DM_CURR_MAX_ROLL_DAYS');

          IF l_max_rollback_days is null
          THEN
             l_max_rollback_days := 0;
          END IF;

          gl_currency_api.get_closest_triangulation_rate( p_from_currency,
                  p_to_currency, p_conversion_date, p_conversion_type,
                  l_max_rollback_days, l_denom_rate,  l_num_rate, l_conv_rate );
	  END IF;
       p_num_rate := l_num_rate;
       p_denom_rate  := l_denom_rate;
       p_status      := 0;
EXCEPTION
       WHEN gl_currency_api.NO_RATE THEN
            p_status := -1;
            raise;
       WHEN gl_currency_api.INVALID_CURRENCY THEN
            p_status  := -2;
            raise;
       WHEN others THEN
            raise;
END get_conversion_rate;

FUNCTION  GET_PARAMETER_VALUE(p_param_str  in varchar2,
                              p_param_name in varchar2,
                              p_param_sep  in varchar2,
                              p_value_sep  in varchar2)
						RETURN VARCHAR2 IS
l_param_val  VARCHAR2(240);
BEGIN
  l_param_val := jtfb_dcf.get_parameter_value(p_param_str, p_param_name, p_param_sep, p_value_sep);

  IF (l_param_val = 'NOT_FOUND') THEN
    return NULL;
  ELSE
    return l_param_val;
  END IF;

END GET_PARAMETER_VALUE;

FUNCTION get_icx_session_id RETURN NUMBER IS
l_session_id NUMBER;
BEGIN
  SELECT icx_sec.g_session_id
  INTO   l_session_id
  FROM   dual;

  return l_session_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_icx_session_id;

FUNCTION get_null_lookup RETURN VARCHAR2 IS
  l_meaning VARCHAR2(80);
BEGIN
  l_meaning := NULL;

  SELECT meaning
  INTO   l_meaning
  FROM   fnd_lookups
  WHERE  lookup_type = 'BIX_DM_NULL_DESC'
  AND    lookup_code = 'NULL';

  return l_meaning;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return NULL;
  WHEN OTHERS THEN
    RAISE;
END get_null_lookup;

PROCEDURE get_prev_period(p_period_set_name IN VARCHAR2,
				      p_period_type     IN VARCHAR2,
				      p_date            IN DATE,
                          p_period_start_date OUT nocopy DATE,
                          p_period_end_date   OUT nocopy DATE) IS

l_curr_start_date DATE;
l_prev_end_date   DATE;
no_of_days        NUMBER;

BEGIN

  SELECT b.start_date,
         b.end_date,
         a.start_date
  INTO   p_period_start_date,
         l_prev_end_date,
         l_curr_start_date
  FROM   gl_periods a, gl_periods b
  WHERE  a.period_set_name = p_period_set_name
  AND    a.period_type = p_period_type
  AND    a.adjustment_period_flag = 'N'
  AND    trunc(p_date) between a.start_date and a.end_date
  AND    b.period_set_name = a.period_set_name
  AND    b.period_type = a.period_type
  AND    b.adjustment_period_flag = 'N'
  AND    (a.start_date - 1) between b.start_date and b.end_date;

  no_of_days := trunc(sysdate - l_curr_start_date);

  IF ((p_period_start_date + no_of_days) > l_prev_end_date) THEN
    p_period_end_date := l_prev_end_date;
  ELSE
    p_period_end_date := p_period_start_date + no_of_days;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     p_period_start_date := to_date('01/01/1900','dd/mm/yyyy');
     p_period_end_date := to_date('01/01/1900','dd/mm/yyyy');
   WHEN OTHERS THEN
    RAISE;
END get_prev_period;

PROCEDURE get_curr_period(p_period_set_name IN VARCHAR2,
				      p_period_type     IN VARCHAR2,
				      p_date            IN DATE,
                          p_period_start_date OUT nocopy DATE,
                          p_period_end_date   OUT nocopy DATE) IS

BEGIN

  SELECT start_date
  INTO   p_period_start_date
  FROM   gl_periods
  WHERE  period_set_name = p_period_set_name
  AND    period_type = p_period_type
  AND    adjustment_period_flag = 'N'
  AND    trunc(p_date) between start_date and end_date;

  SELECT sysdate
  INTO   p_period_end_date
  FROM   dual;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     p_period_start_date := to_date('01/01/1900','dd/mm/yyyy');
     p_period_end_date := to_date('01/01/1900','dd/mm/yyyy');
   WHEN OTHERS THEN
     RAISE;
END get_curr_period;


PROCEDURE get_time_period(p_period_ind   IN VARCHAR2,
					 p_start_date   IN VARCHAR2,
					 p_start_time   IN VARCHAR2,
					 p_end_date     IN VARCHAR2,
					 p_end_time     IN VARCHAR2,
					 p_start_period OUT nocopy VARCHAR2,
					 p_end_period   OUT nocopy VARCHAR2) IS
l_sysdate         DATE;
l_time_id         NUMBER;
l_start_date      DATE;
l_start_time      VARCHAR2(10);
l_end_date        DATE;
l_end_time        VARCHAR2(10);
l_nls_date_format VARCHAR2(50);
l_temp_date       DATE;
l_period_set_name VARCHAR2(20);

BEGIN

  IF (p_period_ind IS NULL) THEN
    return;
  END IF;

  SELECT sysdate
  INTO   l_sysdate
  FROM   dual;

  /*
  ** Commented out ; will be required once we start implementing "Save as default"
  IF (INSTR(p_period_ind,':') > 0) THEN
    l_time_id := SUBSTR(p_period_ind, 1, INSTR(p_period_ind, ':') - 1);
    l_nls_date_format := SUBSTR(p_period_ind, INSTR(p_period_ind, ':') + 1);
  else
    l_time_id := TO_NUMBER(p_period_ind);
    l_nls_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');
  end if;
  */

  l_nls_date_format  := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
  l_time_id := TO_NUMBER(p_period_ind);
  l_start_date := TO_DATE(p_start_date, l_nls_date_format);
  l_end_date := TO_DATE(p_end_date, l_nls_date_format);

  IF (p_start_time IS NOT NULL) THEN
    l_start_time := LPAD(p_start_time,2,'0');
  ELSE
    l_start_time := '00';
  END IF;

  IF (p_end_time IS NOT NULL) THEN
    l_end_time := LPAD(p_end_time,2,'0');
  ELSE
    l_end_time := '23';
  END IF;

  l_period_set_name := FND_PROFILE.VALUE('BIX_DM_REPORTING_CALENDAR');

  IF (l_time_id = 11) THEN
    /* Period Indicator = 11 indicates that user has selected today as reporting period */
    p_start_period := to_char(l_sysdate, 'dd/mm/yyyy') || ' 00:00:00';
    p_end_period := to_char(l_sysdate, 'dd/mm/yyyy') || ' 23:59:59';

  ELSIF (l_time_id = 12) THEN
    /* Period Indicator = 12 indicates that user has selected yesterday as reporting period */
    p_start_period := to_char(l_sysdate-1, 'dd/mm/yyyy') || ' 00:00:00';
    p_end_period := to_char(l_sysdate-1, 'dd/mm/yyyy') || ' 23:59:59';

  ELSIF (l_time_id = 13) THEN
    /* Period Indicator = 13 indicates that user has selected current week as reporting period */
    p_start_period := to_char(trunc(l_sysdate,'IW'),'dd/mm/yyyy') || ' 00:00:00';
    p_end_period := to_char(l_sysdate,'dd/mm/yyyy') || ' 23:59:59';

  ELSIF (l_time_id = 14) THEN
    /* Period Indicator = 14 indicates that user has selected previous week as reporting period */
    p_start_period := to_char(trunc(l_sysdate,'IW') - 7,'dd/mm/yyyy') || ' 00:00:00';
    p_end_period := to_char(l_sysdate - 7,'dd/mm/yyyy') || ' 23:59:59';

  ELSIF (l_time_id = 15) THEN
    /* Period indicator = 15 indicates user has selected current month as reporting period */
    get_curr_period(l_period_set_name, 'Month', l_sysdate, l_start_date, l_end_date);
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || '00:00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || '23:59:59';

  ELSIF (l_time_id = 16) THEN
    /* Period indicator = 16 indicates user has selected previous month as reporting period */
    get_prev_period(l_period_set_name, 'Month', l_sysdate, l_start_date, l_end_date);
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || '00:00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || '23:59:59';

  ELSIF (l_time_id = 17) THEN
    /* Period indicator = 17 indicates user has selected current quarter as reporting period */
    get_curr_period(l_period_set_name, 'Quarter', l_sysdate, l_start_date, l_end_date);
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || '00:00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || '23:59:59';

  ELSIF (l_time_id = 18) THEN
    /* Period indicator = 18 indicates user has selected previous quarter as reporting period */
    get_prev_period(l_period_set_name, 'Quarter', l_sysdate, l_start_date, l_end_date);
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || '00:00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || '23:59:59';

  ELSIF (l_time_id = 19) THEN
    /* Period indicator = 19 indicates user has selected current year as reporting period */
    get_curr_period(l_period_set_name, 'Year', l_sysdate, l_start_date, l_end_date);
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || '00:00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || '23:59:59';

  ELSIF (l_time_id = 20) THEN
    /* Period indicator = 20 indicates user has selected previous year as reporting period */
    get_prev_period(l_period_set_name, 'Year', l_sysdate, l_start_date, l_end_date);
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || '00:00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || '23:59:59';

  ELSIF (l_time_id = 21) THEN
    /* Period indicator = 21 indicates user has specified from date time and to date time */
    p_start_period := to_char(l_start_date,'dd/mm/yyyy ') || l_start_time || ':00:00';
    p_end_period := to_char(l_end_date,'dd/mm/yyyy ') || l_end_time || ':59:59';

  END IF;

EXCEPTION
   WHEN OTHERS THEN
    RAISE;
END get_time_period;

procedure get_conversion_rate(p_from_currency   IN  VARCHAR2,
						p_to_currency     IN  VARCHAR2,
                              p_conversion_type IN  VARCHAR2,
                              p_denom_rate      OUT nocopy NUMBER,
                              p_num_rate        OUT nocopy NUMBER,
                              p_status          OUT nocopy NUMBER) is
l_num_rate     number ;
l_denom_rate   number ;
l_conv_rate    number ;
l_max_rollback_days    number ;

BEGIN
	  IF p_from_currency = p_to_currency
	  THEN
            l_denom_rate := 1;
		  l_num_rate := 1;
    	  ELSE
          l_max_rollback_days := fnd_profile.value('BIX_DM_CURR_MAX_ROLL_DAYS');

          IF l_max_rollback_days is null
          THEN
             l_max_rollback_days := 0;
          END IF;

          gl_currency_api.get_closest_triangulation_rate( p_from_currency,
                  p_to_currency, sysdate, p_conversion_type,
                  l_max_rollback_days, l_denom_rate,  l_num_rate, l_conv_rate );
	  END IF;
       p_num_rate := l_num_rate;
       p_denom_rate  := l_denom_rate;
       p_status      := 0;
EXCEPTION
       WHEN gl_currency_api.NO_RATE THEN
            p_status := -1;
            raise;
       WHEN gl_currency_api.INVALID_CURRENCY THEN
            p_status  := -2;
            raise;
       WHEN others THEN
            raise;
END get_conversion_rate;

FUNCTION bix_dm_get_agent_footer(p_context in VARCHAR2 ) RETURN VARCHAR2 IS
  l_max_date VARCHAR2(20);
  l_date_format VARCHAR2(50);
BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  IF(l_date_format IS NULL) THEN
    l_date_format := 'MM/DD/YYYY';
  END IF;

  l_date_format := l_date_format||' HH24:MI:SS';

  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_agent_sum;

  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_AGENT_FOOTER;

FUNCTION bix_dm_get_call_footer(p_context in VARCHAR2 ) RETURN VARCHAR2 IS
  l_max_date VARCHAR2(20);
  l_date_format VARCHAR2(50);
BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  IF(l_date_format IS NULL) THEN
    l_date_format := 'MM/DD/YYYY';
  END IF;

  l_date_format := l_date_format||' HH24:MI:SS';

  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_call_sum;

  RETURN FND_MESSAGE.GET_STRING('BIX','BIX_DM_REFRESH_MSG') || ' '|| l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_CALL_FOOTER;

FUNCTION bix_dm_get_agent_refresh_date(p_context in VARCHAR2 ) RETURN VARCHAR2 IS
  l_max_date VARCHAR2(20);
  l_date_format VARCHAR2(50);
BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  IF(l_date_format IS NULL) THEN
    l_date_format := 'MM/DD/YYYY';
  END IF;

  l_date_format := l_date_format||' HH24:MI:SS';

  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_agent_sum;

  RETURN l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_AGENT_refresh_date;

FUNCTION bix_dm_get_call_refresh_date(p_context in VARCHAR2 ) RETURN VARCHAR2 IS
  l_max_date VARCHAR2(20);
  l_date_format VARCHAR2(50);
BEGIN

  l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  IF(l_date_format IS NULL) THEN
    l_date_format := 'MM/DD/YYYY';
  END IF;

  l_date_format := l_date_format||' HH24:MI:SS';

  SELECT to_char(MAX(period_start_date_time),l_date_format)
  INTO   l_max_date
  FROM   bix_dm_call_sum;

  RETURN l_max_date;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END BIX_DM_GET_CALL_refresh_date;

FUNCTION get_start_date ( p_end_date   in VARCHAR2,
                          p_period     in VARCHAR2,
					 p_date_format in VARCHAR2,
					 p_numperiods in NUMBER
                         )
RETURN VARCHAR2 IS

  l_max_date VARCHAR2(20);
  l_rpt_calendar VARCHAR2(50);
  l_ctl_date DATE;
  l_start_date DATE;
  l_period_type VARCHAR2(50);

BEGIN

/**
*** Note: to get the start date of the current period pass in a
*** p_numperiods of 0
**/

  l_rpt_calendar:= FND_PROFILE.VALUE('BIX_DM_REPORTING_CALENDAR');

  --IF upper(p_period) = 'DAY'
  IF p_period = '5'
  THEN
     l_period_type := 'DAY';
     SELECT to_date(p_end_date, p_date_format) - p_numperiods
     INTO   l_start_date
     from dual;
  --ELSIF upper(p_period) = 'WEEK'
  ELSIF p_period = '1'
  THEN
     l_period_type := 'WEEK';
     SELECT trunc(to_date(p_end_date,p_date_format),'IW') - (p_numperiods*7)
     INTO l_start_date
     FROM dual;
  ELSIF (   p_period = '2'
         OR p_period = '3'
         OR p_period = '4'
        )
  THEN
	l_ctl_date := to_date(p_end_date, p_date_format);

        IF p_period = '2'
        THEN
           l_period_type := 'MONTH';
        ELSIF p_period = '3'
        THEN
           l_period_type := 'QUARTER';
        ELSIF p_period = '4'
        THEN
           l_period_type := 'YEAR';
        END IF;

     BEGIN

	FOR i IN 1 ..p_numperiods+1
	LOOP

	   SELECT start_date
	   INTO l_start_date
	   FROM gl_periods
	   WHERE upper(period_set_name) = upper(l_rpt_calendar)
	   AND upper(period_type) = upper(l_period_type)
        AND    adjustment_period_flag = 'N'
	   AND l_ctl_date BETWEEN start_date and end_date;

           IF l_start_date IS NOT NULL
           THEN
              l_ctl_date := l_start_date-1;
           ELSE
              EXIT;
           END IF;


           END LOOP;

	   --
	   --If it is not able to find the 13th period for some reason
	   --
	EXCEPTION
	WHEN OTHERS
	THEN
        IF l_start_date IS NULL
        THEN
	      l_start_date := l_ctl_date+1;
        END IF;

     END;

   END IF;  --end if for checking the period

IF l_start_date IS NULL
THEN
   l_start_date := nvl(l_ctl_date+1,to_date(p_end_date, p_date_format));
END IF;

RETURN to_char(l_start_date, p_date_format);

EXCEPTION
WHEN OTHERS
THEN
   l_start_date := to_date(p_end_date, p_date_format);
   RETURN to_char(l_start_date, p_date_format);

END get_start_date;

FUNCTION get_group_by   ( p_end_date   in VARCHAR2,
                          p_period     in VARCHAR2,
			 p_date_format in VARCHAR2
                         )
RETURN VARCHAR2 IS

  l_rpt_calendar VARCHAR2(50);
  l_group_by VARCHAR2(50);

BEGIN

/**
*** Note: to get the start date of the current period pass in a
*** p_numperiods of 0
**/

  l_rpt_calendar:= FND_PROFILE.VALUE('BIX_DM_REPORTING_CALENDAR');

  IF upper(p_period) = 'DAY'
  THEN
	l_group_by := p_end_date;
  ELSIF upper(p_period) = 'WEEK'
  THEN
     SELECT 'Week of '
		   || to_char(trunc(to_date(p_end_date,p_date_format),'IW'),'DD-MON')
     INTO l_group_by
	FROM dual;
  ELSIF upper(p_period) = 'MONTH'
  THEN
     SELECT to_char(start_date,'MON') ||'-'|| period_year
     INTO l_group_by
     FROM gl_periods
     WHERE upper(period_set_name) = upper(l_rpt_calendar)
     AND upper(period_type) = upper(p_period)
     AND adjustment_period_flag = 'N'
     AND p_end_date BETWEEN start_date and end_date;
  ELSIF upper(p_period) = 'QUARTER'
  THEN
     SELECT period_year || '-Q' || period_num
     INTO l_group_by
     FROM gl_periods
     WHERE upper(period_set_name) = upper(l_rpt_calendar)
     AND upper(period_type) = upper(p_period)
     AND adjustment_period_flag = 'N'
     AND p_end_date BETWEEN start_date and end_date;
  END IF;

RETURN l_group_by;

EXCEPTION
WHEN OTHERS
THEN
   NULL;

END get_group_by;

END BIX_UTIL_PKG;

/
