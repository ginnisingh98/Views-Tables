--------------------------------------------------------
--  DDL for Package Body IBE_BI_PMV_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_PMV_UTIL_PVT" AS
/* $Header: IBEVBIUTILB.pls 120.2 2005/09/16 05:46:07 appldev ship $ */

TYPE curr_code_type is table of varchar2(15) index by binary_integer;
TYPE curr_count_type is table of number index by binary_integer;

/** Global variable to cache currency code for each minisite **/
g_msite_curr_table curr_code_type;

/** Global variable to cache count of currency for each minisite **/
g_msite_curr_count_table curr_count_type;

g_userid number := -9999;

/** Global variable to cache currency count when 'ALL' minisite is selected **/
g_all_curr_count number := -9999;

/** Global variable to cache currency code when 'ALL' minisite is selected **/
g_all_curr_code varchar2(15);

/* APPS-IT performance Bug# 4435729. Initialise global currency, secondary currency and MO: Security Profile */

g_gp_currency    varchar2(30) := bis_common_parameters.get_currency_code;
g_gs_currency    varchar2(30) := bis_common_parameters.get_secondary_currency_code;
g_mo_sec_profile number       := fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL');

FUNCTION GET_CURR_CODE(id IN varchar2,p_MSITE_ID IN varchar2) return varchar2 is

   x_out_var varchar2(20);
   l_out_var varchar2(20);

   l_msite_id number;
   l_count number;
   BEGIN


   IF (id = 'FII_GLOBAL1') THEN
      x_out_var := id;
      return x_out_var;
   END if ;

   IF (id = 'FII_GLOBAL2') THEN
      x_out_var := id;
      return x_out_var;
   END if ;

     IF p_MSITE_ID = 'ALL' THEN

	   -- Check if currency count for ALL stores is cached or not
	   -- Since 'ALL' may mean different stores for different users, we are caching the count and currency code for a given user id
	   IF g_all_curr_count = -9999 or fnd_global.user_id <> g_userid THEN

		   g_userid := fnd_global.user_id;

		   SELECT COUNT(distinct f_curr.currency_code) new_count_number
		   INTO g_all_curr_count
		   FROM  ibe_bi_currency_v f_curr
		   WHERE not exists (select b.org_id
	                  from ibe_bi_msiteorg_mv b
	                  where b.msite_id = f_Curr.msite_id
	                  MINUS
        	          select a.organization_id
                	  from per_organization_list a
	                  where a.security_profile_id =
        	            g_mo_sec_profile);
	   END IF;

          IF g_all_curr_count > 1 THEN
             x_out_var := NULL;
          ELSE

	    -- Check if currency code for all is already in cache or not
	   -- Since 'ALL' may mean different stores for different users, we are caching the count and currency code for a given user id
	    IF g_all_curr_code IS NULL or fnd_global.user_id <> g_userid THEN
		   g_userid := fnd_global.user_id;
	            select distinct currency_code
		    into g_all_curr_code
	            FROM  ibe_bi_currency_v f_curr
	            WHERE currency_code <> g_gp_currency
 				and currency_code <> g_gs_currency
		      and not exists (select b.org_id
		                  from ibe_bi_msiteorg_mv b
		                  where b.msite_id = f_Curr.msite_id
	        	          MINUS
        	        	  select a.organization_id
	                	  from per_organization_list a
		                  where a.security_profile_id =
        		            g_mo_sec_profile);
	    END IF;
            x_out_var := g_all_curr_code;
         END IF;

     ELSE

	/** convert the varchar field to numeric **/
	l_msite_id := to_number(p_msite_id);

 	/** cache the currency count for a given msite_id **/
	IF g_msite_curr_count_table.EXISTS(l_msite_id)THEN
		l_count := g_msite_curr_count_table(l_msite_id);
	ELSE
		SELECT count(distinct currency_code) count_number
		INTO g_msite_curr_count_table(l_msite_id)
	   	FROM ibe_bi_currency_v
   		WHERE msite_id = l_msite_id;

		l_count := g_msite_curr_count_table(l_msite_id);
	END IF;

       	 IF l_count > 1 THEN
	         x_out_var := NULL;
         ELSE
	     /** cache the functional currency code for a given msite_id **/
	     IF g_msite_curr_table.EXISTS(l_msite_id) THEN
		  x_out_var := g_msite_curr_table(l_msite_id);
	     ELSE
	         select  currency_code
		 into g_msite_curr_table(l_msite_id)
        	 FROM ibe_bi_currency_v
	         WHERE msite_id = to_number(l_MSITE_ID)
                  and currency_code <> g_gp_currency
			   and currency_code <> g_gs_currency;
		  x_out_var := g_msite_curr_table(l_msite_id);

       	     END IF;

         END IF;

   END IF;

   RETURN (x_out_var);

   EXCEPTION WHEN OTHERS THEN
	   RETURN 'xxx';

END GET_CURR_CODE;

FUNCTION GET_RECORD_TYPE_ID(p_period_type IN VARCHAR2)
RETURN NUMBER IS
  l_record_type_id NUMBER;

BEGIN

  IF(p_period_type = 'FII_TIME_ENT_YEAR') THEN
    l_record_type_id := 119;
  ELSIF(p_period_type = 'FII_TIME_ENT_QTR') THEN
    l_record_type_id := 55;
  ELSIF(p_period_type = 'FII_TIME_ENT_PERIOD') THEN
    l_record_type_id := 23;
  ELSE
    l_record_type_id := 11;
  END IF;

  RETURN l_record_type_id;


END GET_RECORD_TYPE_ID;

-- Function to get the previous date.. required for calculating the % change

FUNCTION GET_PREV_DATE(p_asof_date IN DATE, p_period_type VARCHAR2, p_comparison_type VARCHAR2)
RETURN DATE IS
  l_prev_date DATE;
BEGIN

  -- If Sequential
 IF(p_comparison_type = 'SEQUENTIAL') THEN
    IF(p_period_type = 'FII_TIME_ENT_YEAR') THEN
      l_prev_date := FII_TIME_API.ent_sd_lyr_end(p_asof_date);
    ELSIF(p_period_type = 'FII_TIME_ENT_QTR') THEN
      l_prev_date := FII_TIME_API.ent_sd_pqtr_end(p_asof_date);
    ELSIF(p_period_type = 'FII_TIME_ENT_PERIOD') THEN
      l_prev_date := FII_TIME_API.ent_sd_pper_end(p_asof_date);
    ELSE

      l_prev_date := FII_TIME_API.sd_pwk(p_asof_date);
    END IF;
  ELSE -- comparison type Year by Year
    IF(p_period_type = 'FII_TIME_ENT_YEAR') THEN
      l_prev_date := FII_TIME_API.ent_sd_lyr_end(p_asof_date);
    ELSIF(p_period_type = 'FII_TIME_ENT_QTR') THEN
      l_prev_date := FII_TIME_API.ent_sd_lysqtr_end(p_asof_date);
    ELSIF(p_period_type = 'FII_TIME_ENT_PERIOD') THEN
      l_prev_date := FII_TIME_API.ent_sd_lysper_end(p_asof_date);
    ELSE
      l_prev_date := FII_TIME_API.sd_lyswk(p_asof_date);
    END IF;
  END IF;


  RETURN l_prev_date;

END GET_PREV_DATE;

PROCEDURE ENT_YR_SPAN(p_asof_date IN  Date,
                      x_timespan  OUT NOCOPY Number,
                      x_sequence  OUT NOCOPY Number)
  AS

  Cursor c_year(p_date Date)
  IS
  Select (end_date - p_date) timespan,
         sequence
    From  FII_TIME_ENT_YEAR
    Where  p_date BETWEEN start_date AND end_date;
Begin
  Open c_year(p_asof_date);
  Fetch c_year INTO x_timespan,x_sequence;
  Close c_year;

END ENT_YR_SPAN;

PROCEDURE ENT_QTR_SPAN(p_asof_date IN  DATE,
                       p_comparator IN  VARCHAR2,
                       x_cur_start OUT NOCOPY DATE,
                       x_prev_start OUT NOCOPY DATE,
                       x_mid_start OUT NOCOPY DATE,
                       x_cur_year  OUT NOCOPY NUMBER,
                       x_prev_year OUT NOCOPY NUMBER,
                       x_timespan  OUT NOCOPY NUMBER)
  AS
  Cursor c_qtr(p_date Date) IS
  SELECT end_date - p_date timespan,
    sequence,
    ent_year_id,
    start_date
    FROM  FII_TIME_ENT_qtr
    WHERE  p_date BETWEEN start_date AND end_date;

  Cursor c_min_date(p_sequence NUMBER,p_year_id  NUMBER)
  IS
    SELECT start_date
      FROM  FII_TIME_ENT_qtr
      WHERE  sequence = p_sequence
      AND  ent_year_id = p_year_id;

    l_timespan   NUMBER := 0;
    l_sequence   NUMBER := 0;
    l_year_id    NUMBER := 0;
    l_start_date DATE;
    l_prev_seq   NUMBER := 0;
    l_prev_yr    NUMBER := 0;
    l_prev_start DATE;
Begin
  OPEN c_qtr(p_asof_date);
  FETCH c_qtr INTO l_timespan,l_sequence,l_year_id,l_start_date;
  CLOSE c_qtr;

  If(l_sequence = 4)
  THEN
    l_prev_seq := 1;

    l_prev_yr  := l_year_id - 1;
  Elsif(l_sequence < 4)
  THEN
    l_prev_seq := l_sequence + 1;
    l_prev_yr  := l_year_id - 2;
  End If;

  Open c_min_date(l_prev_seq,l_prev_yr);
  FETCH c_min_date INTO l_prev_start;
  CLOSE c_min_date;

  x_cur_start := TO_DATE(TO_CHAR(l_start_date,'DD/MM/RRRR'),'DD/MM/RRRR');
  x_prev_start:= TO_DATE(TO_CHAR(l_prev_start,'DD/MM/YYYY'),'DD/MM/RRRR');

  x_cur_year  := l_year_id;
  x_prev_year := l_prev_yr;
  x_timespan  := l_timespan;

  If(p_comparator = 'YEARLY')
  THEN
    OPEN c_min_date(l_sequence,l_year_id-1);
    FETCH c_min_date INTO x_mid_start;
    CLOSE c_min_date;
  END IF;
END ENT_QTR_SPAN;

PROCEDURE ENT_PRD_SPAN(p_asof_date IN  DATE,

                       p_comparator IN  VARCHAR2,
                       x_cur_start OUT NOCOPY DATE,
                       x_prev_start OUT NOCOPY DATE,
                       x_mid_start OUT NOCOPY DATE,
                       x_cur_year  OUT NOCOPY NUMBER,
                       x_prev_year OUT NOCOPY NUMBER,
                       x_timespan  OUT NOCOPY NUMBER)
  As
  Cursor c_prd(p_date Date)
  IS
  SELECT end_date - p_date timespan,
    sequence,
    ent_year_id,

    start_date
    FROM  FII_TIME_ENT_period
    WHERE  p_date BETWEEN start_date AND end_date;

  Cursor c_min_date(p_sequence NUMBER,
    p_year_id  NUMBER)
  IS
  SELECT start_date
  FROM  FII_TIME_ENT_PERIOD
  WHERE  sequence = p_sequence
    AND  ent_year_id = p_year_id;

 l_timespan   NUMBER := 0;

 l_sequence   NUMBER := 0;
 l_year_id    NUMBER := 0;
 l_start_date DATE;
 l_prev_seq   NUMBER := 0;
 l_prev_yr    NUMBER := 0;
 l_prev_start DATE;
Begin
 OPEN c_prd(p_asof_date);
 FETCH c_prd INTO l_timespan,l_sequence,l_year_id,l_start_date;
 CLOSE c_prd;

 If(l_sequence = 12)
 Then

   l_prev_seq := 1;
   l_prev_yr  := l_year_id - 1;
 Elsif(l_sequence < 12)
 Then
   l_prev_seq := l_sequence + 1;
   l_prev_yr  := l_year_id - 2;
 End If;

 Open c_min_date(l_prev_seq,l_prev_yr);
 FETCH c_min_date INTO l_prev_start;
 CLOSE c_min_date;

 x_cur_start := l_start_date;

 x_prev_start:= l_prev_start;
 x_cur_year  := l_year_id;
 x_prev_year := l_prev_yr;
 x_timespan  := l_timespan;

 OPEN c_min_date(l_sequence,l_year_id-1);
 FETCH c_min_date INTO x_mid_start;
 CLOSE c_min_date;
END ENT_PRD_SPAN;

PROCEDURE WEEK_SPAN(p_asof_date IN  DATE,
                    p_comparator IN VARCHAR2,
                    x_cur_start OUT NOCOPY DATE,
                    x_prev_start OUT NOCOPY DATE,
                    x_pcur_start OUT NOCOPY DATE,
                    x_pprev_start OUT NOCOPY DATE,
                    x_timespan  OUT NOCOPY NUMBER)
AS
  Cursor c_week(p_date Date)
  IS
  select w.end_date - p_date timespan,
         w.start_date,
                 w.sequence,
                 p.year445_id
  from fii_time_week w, fii_time_p445 p

  where w.period445_id = p.period445_id
  and   p_date between w.start_date and w.end_date ;

  Cursor c_lyswk(p_sequence NUMBER,p_year NUMBER)
  IS
   SELECT w.start_date
     from fii_time_week w, fii_time_p445 p
    where w.period445_id = p.period445_id
      and w.sequence = p_sequence
      and p.year445_id = p_year-1;

  l_timespan   NUMBER := 0;
  l_cur_start  DATE ;

  l_prev_start DATE ;
  l_sequence   NUMBER;
  l_cur_year   NUMBER;
  l_pcur_start DATE;
Begin

  OPEN c_week(p_asof_date);
  FETCH c_week INTO l_timespan, l_cur_start,l_sequence,l_cur_year;
  CLOSE c_week;

  l_prev_start := l_cur_start - 84; --(12*7)

  -- set the out variables

  x_cur_start := l_cur_start;
  x_prev_start:= l_prev_start;
  x_timespan  := l_timespan;

  If(p_comparator = 'YEARLY')
  Then
   Open c_lyswk(p_sequence => l_sequence,p_year => l_cur_year);
   Fetch c_lyswk Into l_pcur_start;
   Close c_lyswk;

   x_pcur_start  := l_pcur_start;
   x_pprev_start := l_pcur_start-(12*7);
   End if;

END WEEK_SPAN;

END IBE_BI_PMV_UTIL_PVT;

/
