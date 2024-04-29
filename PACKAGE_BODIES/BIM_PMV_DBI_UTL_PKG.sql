--------------------------------------------------------
--  DDL for Package Body BIM_PMV_DBI_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_PMV_DBI_UTL_PKG" AS
/*$Header: bimvutlb.pls 120.2.12010000.2 2008/10/08 05:04:03 annsrini ship $ */

PROCEDURE get_viewby_id (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                               l_viewby_id in OUT NOCOPY NUMBER)
                              IS
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
        IF( p_page_parameter_tbl(i).parameter_name= 'BIM_PARAMETER4') THEN
           l_viewby_id := p_page_parameter_tbl(i).parameter_value;
        END IF;
    END LOOP;
 END IF;
  COMMIT;
END get_viewby_id;

PROCEDURE get_bim_page_params (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                               l_as_of_date              OUT NOCOPY DATE,
                               l_period_type             in OUT NOCOPY VARCHAR2,
                               l_record_type_id          OUT NOCOPY NUMBER,
                               l_comp_type               OUT NOCOPY VARCHAR2,
                               l_country                 in OUT NOCOPY VARCHAR2,
			       l_view_by                 in OUT NOCOPY VARCHAR2,
			       l_cat_id                  in OUT NOCOPY VARCHAR2,
			       l_campaign_id             in OUT NOCOPY VARCHAR2,
                               l_currency                in OUT NOCOPY VARCHAR2 ,
			       l_col_id                  in OUT NOCOPY NUMBER,
			       l_area                    in OUT NOCOPY VARCHAR2,
                               l_media                   in OUT NOCOPY VARCHAR2,
			       l_report_name             in OUT NOCOPY VARCHAR2
                              )
			      IS

l_sql_errm VARCHAR2(32000);

BEGIN

  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

/*INSERT INTO bim_param_test values(p_page_parameter_tbl(i).parameter_name,
   p_page_parameter_tbl(i).parameter_value,
   p_page_parameter_tbl(i).parameter_id);*/

       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN
          l_as_of_date := trunc(sysdate);
       END IF;

       IF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
          l_comp_type := p_page_parameter_tbl(i).parameter_value;
       END IF;

        IF( p_page_parameter_tbl(i).parameter_name= 'VIEW_BY') THEN
           l_view_by := p_page_parameter_tbl(i).parameter_value;
	   if l_view_by is null then l_view_by := 'CAMPAIGN+CAMPAIGN';
	   end if;
        END IF;

	 IF ( p_page_parameter_tbl(i).parameter_name= 'ITEM+ENI_ITEM_VBH_CAT') THEN
	     l_cat_id := p_page_parameter_tbl(i).parameter_id;
         END IF;

	  IF ( p_page_parameter_tbl(i).parameter_name= 'CAMPAIGN+CAMPAIGN') THEN
	     l_campaign_id := p_page_parameter_tbl(i).parameter_id;
         END IF;
         IF ( p_page_parameter_tbl(i).parameter_name= 'CURRENCY+FII_CURRENCIES') THEN
	     l_currency := p_page_parameter_tbl(i).parameter_id;
         END IF;

	  IF( p_page_parameter_tbl(i).parameter_name= 'BIM_PARAMETER1') THEN
	   l_col_id := p_page_parameter_tbl(i).parameter_value;
	END IF;

	IF( p_page_parameter_tbl(i).parameter_name= 'BIM_PARAMETER2') THEN
	   l_report_name := p_page_parameter_tbl(i).parameter_value;
	END IF;

	 IF( p_page_parameter_tbl(i).parameter_name= 'MEDIA+MEDIA') THEN
	   l_media := p_page_parameter_tbl(i).parameter_id;
	END IF;

	 IF( p_page_parameter_tbl(i).parameter_name= 'GEOGRAPHY+AREA') THEN
	   l_area := p_page_parameter_tbl(i).parameter_id;
	   IF (l_area IS NULL)
   		THEN l_area := '-1';
   	   END IF;
	END IF;

	  IF p_page_parameter_tbl(i).parameter_name= 'GEOGRAPHY+COUNTRY' THEN
		l_country := p_page_parameter_tbl(i).parameter_id;
   		IF (l_country = '''ALL''')
   		THEN l_country := 'N';
   		END IF;

		IF (l_country IS NULL)
   		THEN l_country := 'N';
   		END IF;
         IF (instr(l_country,'''') >=0) THEN
            l_country := replace(l_country, '''','');
         END IF;
       END IF;

     END LOOP;
  END IF;

  IF l_comp_type IS NULL THEN l_comp_type := 'YEARLY'; END IF;

  IF l_period_type IS NULL THEN l_period_type := 'FII_TIME_WEEK'; END IF;

  IF l_country IS NULL THEN l_country := 'N'; END IF;

  -- Retrieve l_period_type info using CASE

  CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN l_record_type_id := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_record_type_id := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN l_record_type_id := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN l_record_type_id := 119;
    ELSE l_record_type_id := 11;
  END CASE;

/*INSERT INTO bim_param_test values('get_bim_page_params success',
         nvl(l_comp_type,'NULL'),nvl(l_period_type,'NULL'),
         DBMS_UTILITY.get_time,l_country,NULL,null);
COMMIT;
*/
EXCEPTION
WHEN OTHERS THEN
l_sql_errm := SQLERRM;
/*INSERT INTO bim_param_test values('get_bim_page_params excpetion',
         nvl(l_comp_type,'NULL'),nvl(l_period_type,'NULL'),
         DBMS_UTILITY.get_time,l_country,l_sql_errm,null);
COMMIT;
*/
END get_bim_page_params;

PROCEDURE get_bim_page_sgmt_params  (p_page_parameter_tbl      IN  BIS_PMV_PAGE_PARAMETER_TBL,
									p_as_of_date              OUT NOCOPY DATE,
									p_period_type             IN  OUT NOCOPY VARCHAR2,
									p_record_type_id          OUT NOCOPY NUMBER,
									p_view_by                 IN OUT NOCOPY VARCHAR2,
									p_cat_id                  IN OUT NOCOPY VARCHAR2,
									p_sgmt_id                 IN OUT NOCOPY VARCHAR2,
									p_currency                IN OUT NOCOPY VARCHAR2,
									p_url_metric			  IN OUT NOCOPY VARCHAR2,
									p_url_viewby			  IN OUT NOCOPY VARCHAR2,
									p_url_viewbyid			  IN OUT NOCOPY VARCHAR2
									)
is
BEGIN

	IF (p_page_parameter_tbl.count > 0) THEN
		FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last
		LOOP

			IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN

				p_period_type := p_page_parameter_tbl(i).parameter_value;

			END IF;

			IF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN

				p_as_of_date := trunc(sysdate);

			END IF;
			IF( p_page_parameter_tbl(i).parameter_name= 'VIEW_BY') THEN

				p_view_by := p_page_parameter_tbl(i).parameter_value;

				IF p_view_by IS NULL THEN

					p_view_by := 'TARGET SEGMENT+TARGET SEGMENT';

				END IF;

			END IF;

			IF ( p_page_parameter_tbl(i).parameter_name= 'ITEM+ENI_ITEM_VBH_CAT') THEN

				p_cat_id := p_page_parameter_tbl(i).parameter_id;

				/*IF p_cat_id = '''''' THEN
					p_cat_id := NULL;

				END IF;*/

			END IF;

			IF ( p_page_parameter_tbl(i).parameter_name= 'TARGET SEGMENT+TARGET SEGMENT') THEN

				p_sgmt_id := p_page_parameter_tbl(i).parameter_id;

				/*IF p_sgmt_id = '''''' THEN
					p_sgmt_id := NULL;
				END IF;*/

			END IF;
			IF ( p_page_parameter_tbl(i).parameter_name= 'CURRENCY+FII_CURRENCIES') THEN

				p_currency := p_page_parameter_tbl(i).parameter_id;

			END IF;

			IF p_page_parameter_tbl(i).parameter_name = 'BIM_PARAMETER1' THEN

				p_url_metric := p_page_parameter_tbl(i).parameter_value;

			END IF;

			IF p_page_parameter_tbl(i).parameter_name = 'BIM_PARAMETER3' THEN

				p_url_viewby := p_page_parameter_tbl(i).parameter_value;

			END IF;

			IF p_page_parameter_tbl(i).parameter_name = 'BIM_PARAMETER2' THEN

				p_url_viewbyid := p_page_parameter_tbl(i).parameter_value;

			END IF;

		END LOOP;
	END IF;

	IF p_period_type IS NULL THEN

		p_period_type := 'FII_TIME_WEEK';

	END IF;


  -- Retrieve p_period_type info using CASE

  CASE p_period_type
    WHEN 'FII_TIME_WEEK' THEN p_record_type_id := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN p_record_type_id := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN p_record_type_id := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN p_record_type_id := 119;
    ELSE p_record_type_id := 11;
  END CASE;
END;


FUNCTION Current_Period_Start_Date(	l_as_of_date 	DATE,
                                   	l_period_type 	VARCHAR2) RETURN DATE IS

  l_date date;

BEGIN

  CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN l_date := FII_TIME_API.Cwk_Start(l_as_of_date);
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_date := FII_TIME_API.Ent_Cper_Start(l_as_of_date);
    WHEN 'FII_TIME_ENT_QTR' THEN l_date := FII_TIME_API.Ent_Cqtr_Start(l_as_of_date);
    WHEN 'FII_TIME_ENT_YEAR' THEN l_date := FII_TIME_API.Ent_Cyr_Start(l_as_of_date);
    ELSE l_date := FII_TIME_API.Ent_Cqtr_Start(l_as_of_date);
  END CASE;

  RETURN l_date;
  END;

FUNCTION Previous_Period_Start_Date(l_as_of_date	DATE,
						l_period_type	VARCHAR2,
						l_comp_type	VARCHAR2) RETURN DATE IS
  l_prev_date date;
  l_date date;

BEGIN

  l_prev_date := Previous_Period_Asof_Date(l_as_of_date, l_period_type, l_comp_type);

  l_date := Current_Period_Start_Date(l_prev_date, l_period_type);

  RETURN l_date;

EXCEPTION
  WHEN OTHERS THEN
     RETURN BIS_COMMON_PARAMETERS.Get_Global_Start_Date;
END;


FUNCTION Current_Report_Start_Date(	l_as_of_date	DATE,
                             		l_period_type	VARCHAR2) RETURN DATE IS

  l_date		DATE;
  l_curr_year		NUMBER;
  l_curr_qtr		NUMBER;
  l_curr_period		NUMBER;
  l_week_start_date	DATE;

BEGIN

  IF(l_period_type = 'FII_TIME_ENT_YEAR' )
    THEN
      SELECT sequence
        INTO l_curr_year
        FROM fii_time_ent_year
       WHERE l_as_of_date BETWEEN start_date AND end_date;

      SELECT start_date
        INTO l_date
        FROM fii_time_ent_year
       WHERE sequence = l_curr_year - 3;

  END IF;

  IF(l_period_type = 'FII_TIME_ENT_QTR' )
    THEN
      SELECT sequence,
             ent_year_id
        INTO l_curr_qtr, l_curr_year
        FROM fii_time_ent_qtr
       WHERE l_as_of_date BETWEEN start_date AND end_date;

    IF(l_curr_qtr = 4)
      THEN l_date := FII_TIME_API.Ent_Cyr_Start(l_as_of_date);
      ELSE
        SELECT start_date
          INTO l_date
          FROM fii_time_ent_qtr
         WHERE sequence = l_curr_qtr + 1
           AND ent_year_id = l_curr_year - 1;
    END IF;
  END IF;

  IF(l_period_type = 'FII_TIME_ENT_PERIOD' )
  THEN
    SELECT p.sequence, q.ent_year_id
      INTO l_curr_period, l_curr_year
      FROM fii_time_ent_period p, fii_time_ent_qtr q
     WHERE p.ent_qtr_id=q.ent_qtr_id
       AND l_as_of_date BETWEEN p.start_date AND p.end_date;

    SELECT p.start_date
      INTO l_date
      FROM fii_time_ent_period p, fii_time_ent_qtr q
     WHERE p.ent_qtr_id = q.ent_qtr_id
       AND p.sequence = l_curr_period + 1
       AND q.ent_year_id = l_curr_year - 1;

/*INSERT INTO bim_param_test values('AOD:'||l_as_of_date,
   'currperiod:'||l_curr_period,
   'return date'||l_date,DBMS_UTILITY.get_time,NULL,NULL,null);
COMMIT;
*/  END IF;

  IF(l_period_type = 'FII_TIME_WEEK')
    THEN
      SELECT start_date
	INTO l_week_start_date
	FROM fii_time_week
       WHERE l_as_of_date BETWEEN start_date AND end_date;

      SELECT start_date
	INTO l_date
	FROM fii_time_week
       WHERE start_date = l_week_start_date - 7 * 12;

  END IF;

 RETURN l_date;

  EXCEPTION
   WHEN OTHERS
    THEN RETURN BIS_COMMON_PARAMETERS.Get_Global_Start_Date;

END;

FUNCTION Previous_Report_Start_Date(l_as_of_date	DATE,
                              	l_period_type	VARCHAR2,
						l_comp_type VARCHAR2) RETURN DATE IS

  l_prev_date date;
  l_date date;

BEGIN

  l_prev_date := Previous_Period_Asof_Date(l_as_of_date, l_period_type, l_comp_type);

  l_date := Current_Report_Start_Date(l_prev_date, l_period_type);

  RETURN l_date;

END;


FUNCTION Previous_Period_Asof_Date(	l_as_of_date	DATE,
                                   	l_period_type	VARCHAR2,
                                   	l_comp_type	VARCHAR2) RETURN DATE IS

  l_date date;

BEGIN

 IF (l_comp_type = 'YEARLY') THEN
   CASE l_period_type
       WHEN 'FII_TIME_WEEK' THEN
           l_date := FII_TIME_API.sd_lyswk(l_as_of_date);
       WHEN 'FII_TIME_ENT_PERIOD' THEN
           l_date := FII_TIME_API.ent_sd_lysper_end(l_as_of_date);
       WHEN 'FII_TIME_ENT_QTR' THEN
           l_date := FII_TIME_API.ent_sd_lysqtr_end(l_as_of_date);
       WHEN 'FII_TIME_ENT_YEAR' THEN
           l_date := FII_TIME_API.ent_sd_lyr_end(l_as_of_date);
       ELSE
           l_date := FII_TIME_API.ent_sd_lysqtr_end(l_as_of_date);
    END CASE;
 ELSIF (l_comp_type = 'SEQUENTIAL') THEN
    CASE l_period_type
       WHEN 'FII_TIME_WEEK' THEN
           l_date := FII_TIME_API.sd_pwk(l_as_of_date);
       WHEN 'FII_TIME_ENT_PERIOD' THEN
           l_date := FII_TIME_API.ent_sd_pper_end(l_as_of_date);
       WHEN 'FII_TIME_ENT_QTR' THEN
           l_date := FII_TIME_API.ent_sd_pqtr_end(l_as_of_date);
       WHEN 'FII_TIME_ENT_YEAR' THEN
           l_date := FII_TIME_API.ent_sd_lyr_end(l_as_of_date);
      ELSE
           l_date := FII_TIME_API.ent_sd_pqtr_end(l_as_of_date);
    END CASE;
 END IF;

  RETURN l_date;

EXCEPTION
  WHEN OTHERS
    THEN RETURN BIS_COMMON_PARAMETERS.Get_Global_Start_Date - 1; /* making sure it's < current_report_date */
END;

-- -------------------------------------------------------------------
-- Name: bil_pyr_end
-- Desc: Returns previous enterprise year end date.
-- Output: Previous Enterprise year end date.
-- --------------------------------------------------------------------
Function bil_pyr_end(as_of_date date, num_periods number) return DATE is
  l_date date;
begin
  select end_date
  into l_date
  from fii_time_ent_year
  where sequence =
  (select sequence - num_periods
   from fii_time_ent_year
   where as_of_date between start_date and end_date);

  return l_date;
end;


-- -------------------------------------------------------------------
-- Name: bil_pper_end
-- Desc: Returns previous enterprise period end date.
-- Output: Previous Enterprise Period end date
-- --------------------------------------------------------------------
Function bil_pper_end(as_of_date date) return DATE is -- will get lastDay of prior''s prior as-of-date period
  l_date        date;
  l_curr_period number;
  l_curr_year   number;
begin
 select p.sequence, q.ent_year_id
  into l_curr_period, l_curr_year
  from fii_time_ent_period p, fii_time_ent_qtr q
  where p.ent_qtr_id=q.ent_qtr_id
  and as_of_date between p.start_date and p.end_date;

    select p.end_date
    into l_date
    from fii_time_ent_period p, fii_time_ent_qtr q
    where p.ent_qtr_id=q.ent_qtr_id
    and p.sequence= l_curr_period
    and q.ent_year_id= l_curr_year-2;


  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: bil_pqtr_end
-- Desc: Returns previous enterprise quarter end date.
-- Output: Previous enterprise quarter end date.
-- --------------------------------------------------------------------
Function bil_pqtr_end(as_of_date date) return DATE is
  l_date      date;
  l_curr_qtr  number;
  l_curr_year number;
begin
  /*
  select sequence, ent_year_id
  into l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where as_of_date between start_date and end_date;

    select end_date
    into l_date
    from fii_time_ent_qtr
    where sequence=l_curr_qtr
    and ent_year_id=l_curr_year-2;
  */
       select qtr2.end_date
       into l_date
       from fii_time_ent_qtr qtr1, fii_time_ent_qtr qtr2
       where as_of_date between qtr1.start_date and qtr1.end_date
       and qtr2.sequence = qtr1.sequence and qtr2.ent_year_id=qtr1.ent_year_id-2;


  return l_date;
end;

PROCEDURE GET_TREND_PARAMS(  p_page_period_type  IN VARCHAR2,
                             p_comp_type         IN VARCHAR2,
                             p_curr_as_of_date   IN DATE,
                             p_table_name        OUT NOCOPY VARCHAR2,
                             p_column_name       OUT NOCOPY VARCHAR2,
                             p_curr_start_date   OUT NOCOPY DATE,
                             p_prev_start_date   OUT NOCOPY DATE,
                             p_prev_end_date     OUT NOCOPY DATE,
			     p_series_name       OUT NOCOPY VARCHAR2,
			     p_time_ids          OUT NOCOPY VARCHAR2
                             )
IS
BEGIN
CASE
  WHEN p_page_period_type = 'FII_TIME_ENT_YEAR' then
    p_table_name := 'fii_time_ent_year';
    p_column_name := 'ent_year_id';
    p_time_ids  := 'ent_year_id,ent_year_id';
--    p_curr_start_date := bil_pyr_end(p_curr_as_of_date, 4);
--    p_series_name := 'TO_CHAR(MOD(ent_year_id,100),''FM00'')';

WHEN p_page_period_type = 'FII_TIME_ENT_QTR' then
    p_table_name := 'fii_time_ent_qtr';
    p_column_name := 'ent_qtr_id';
    p_time_ids  := 'ent_year_id,ent_qtr_id';
--    p_curr_start_date := bil_pqtr_end(p_curr_as_of_date); --8 continuous quarters
--    p_series_name := 'FND_GLOBAL.LOCAL_CHR(81)||sequence||FND_GLOBAL.LOCAL_CHR(45)||TO_CHAR(MOD(ent_year_id,100),''FM00'')';
/*    IF p_comp_type = 'YEARLY' then
       p_curr_start_date := (fii_time_api.ent_lysqtr_end(p_curr_as_of_date)+1); -- lastDay+1 of prior's as-of-date period
       p_prev_start_date := (fii_time_api.ent_lysqtr_end(p_curr_start_date)+1); -- lastDay+1 of prior''s prior as-of-date period
    END IF;  */

WHEN p_page_period_type = 'FII_TIME_ENT_PERIOD' then
    p_table_name := 'fii_time_ent_period';
    p_column_name := 'ent_period_id';
    p_time_ids  := 'ent_year_id,ent_period_id';
    --l_curr_end_date := fii_time_api.ent_cper_end(p_curr_as_of_date); -- use &BIS_CURRENT_EFFECTIVE_END_DATE
--    p_curr_start_date := fii_time_api.ent_lysper_end(p_curr_as_of_date);
--    p_series_name := 'TO_CHAR(end_date,''Mon'')';

/*	IF p_comp_type = 'YEARLY' then
    p_curr_start_date := (fii_time_api.ent_lysper_end(p_curr_as_of_date)+1); --Last year same Enterprise period start date
    p_prev_start_date := (bil_pper_end(p_curr_as_of_date)+1); -- lastDay+1 of prior''s prior as-of-date period
    END IF;  */

    ELSE
 --WHEN p_page_period_type = 'FII_TIME_WEEK' then
    p_table_name := 'fii_time_week';
    p_column_name := 'week_id';
    p_time_ids  := 'week_id,week_id';
--    p_curr_start_date := (fii_time_api.cwk_end(p_curr_as_of_date) - 91);  -- use (as_of_date -13*7)
--    p_series_name := 'TO_CHAR(end_date,''DDMon'')';

/*    IF p_comp_type = 'YEARLY' then
     --p_curr_start_date := (fii_time_api.cwk_end(p_curr_as_of_date) - 91);
	  p_prev_start_date := (fii_time_api.lyswk_end(p_curr_as_of_date)-91);
    END IF;  */
 END CASE;

 /*  IF (p_comp_type = 'YEARLY') THEN
   CASE p_page_period_type
       WHEN 'FII_TIME_WEEK' THEN
           p_prev_end_date := FII_TIME_API.sd_lyswk(p_curr_as_of_date);
       WHEN 'FII_TIME_ENT_PERIOD' THEN
           p_prev_end_date := FII_TIME_API.ent_sd_lysper_end(p_curr_as_of_date);
       WHEN 'FII_TIME_ENT_QTR' THEN
           p_prev_end_date := FII_TIME_API.ent_sd_lysqtr_end(p_curr_as_of_date);
       WHEN 'FII_TIME_ENT_YEAR' THEN
           p_prev_end_date := FII_TIME_API.ent_sd_lyr_end(p_curr_as_of_date);
       ELSE
           p_prev_end_date := FII_TIME_API.ent_sd_lysqtr_end(p_curr_as_of_date);
    END CASE;
 ELSIF (p_comp_type = 'SEQUENTIAL') THEN
    CASE p_page_period_type
       WHEN 'FII_TIME_WEEK' THEN
           p_prev_end_date := FII_TIME_API.sd_pwk(p_curr_as_of_date);
       WHEN 'FII_TIME_ENT_PERIOD' THEN
           p_prev_end_date := FII_TIME_API.ent_sd_pper_end(p_curr_as_of_date);
       WHEN 'FII_TIME_ENT_QTR' THEN
           p_prev_end_date := FII_TIME_API.ent_sd_pqtr_end(p_curr_as_of_date);
       WHEN 'FII_TIME_ENT_YEAR' THEN
           p_prev_end_date := FII_TIME_API.ent_sd_lyr_end(p_curr_as_of_date);
       ELSE
           p_prev_end_date := FII_TIME_API.ent_sd_pqtr_end(p_curr_as_of_date);
    END CASE;
 END IF;  */

END GET_TREND_PARAMS;

FUNCTION GET_COLUMN_A(p_name IN VARCHAR2) RETURN VARCHAR2

IS
l_meaning Varchar2(50);
BEGIN
select al.meaning  into l_meaning
from bim_r_code_definitions bc ,
as_sales_lead_ranks_vl al
where bc.object_def = al.rank_id
and bc.object_type = 'RANK_DBI' and column_name = p_name;
Return l_meaning;
END ;



function get_rpl_label(p_name in varchar2,pld in varchar2) return varchar2

is
l_rev Varchar2(50);
l_period varchar2(50);
l_per_lead varchar2(50);
BEGIN

/* PLD */
l_per_lead:='';

    SELECT MEANING into l_rev
    FROM FND_LOOKUP_VALUES
    WHERE LOOKUP_TYPE = 'BIM_REVENUE'
    AND   lookup_code=fnd_profile.VALUE('BIM_REVENUE')
    AND   language = USERENV('LANG');


	IF (pld ='N' AND (p_name = 'PTD' OR p_name = 'TOTAL') ) THEN

	/* to get PTD revenue and Total revenue*/


   SELECT  MEANING into l_period
   FROM FND_LOOKUP_VALUES
   WHERE LOOKUP_TYPE = 'BIM_GEN_LOOKUP'
   AND  lookup_code=p_name
   AND   language = USERENV('LANG');

   return l_period||' '||l_rev;

   END IF;


   if pld ='PLD' AND p_name ='N' THEN

/* to get  <<revenue>> per lead  and Total <<revenue>> per lead */

   SELECT  MEANING into l_per_lead
   FROM FND_LOOKUP_VALUES
   WHERE LOOKUP_TYPE = 'BIM_GEN_LOOKUP'
   AND  lookup_code=pld
  AND   language = USERENV('LANG');

      return l_rev||' '||l_per_lead;

   END IF;


if pld ='PLD' AND (p_name = 'PTD' OR p_name = 'TOTAL') THEN

/* to get PTD <<revenue>> per lead  and Total <<revenue>> per lead */

  SELECT  MEANING into l_period
   FROM FND_LOOKUP_VALUES
   WHERE LOOKUP_TYPE = 'BIM_GEN_LOOKUP'
   AND    lookup_code=p_name
   AND   language = USERENV('LANG');



   SELECT  MEANING into l_per_lead
   FROM FND_LOOKUP_VALUES
   WHERE LOOKUP_TYPE = 'BIM_GEN_LOOKUP'
   AND    lookup_code=pld
   AND   language = USERENV('LANG');

      return l_period||' '||l_rev||' '||l_per_lead;

 END IF;

 if pld ='FORE' and p_name ='N' THEN

/* to get  <<revenue>>  Forecast */

   SELECT  MEANING into l_per_lead
   FROM FND_LOOKUP_VALUES
   WHERE LOOKUP_TYPE = 'BIM_GEN_LOOKUP'
   AND    lookup_code=pld
   AND   language = USERENV('LANG');

   return l_rev||' '||l_per_lead;

 END IF;

  if pld ='VAR' and p_name ='N' THEN

/* to get  <<revenue>>  variance */

   SELECT  MEANING into l_per_lead
   FROM FND_LOOKUP_VALUES
   WHERE LOOKUP_TYPE = 'BIM_GEN_LOOKUP'
   AND    lookup_code=pld
   AND   language = USERENV('LANG');

   return l_rev||' '||l_per_lead ;

 END IF;


end;




FUNCTION GET_LOOKUP_VALUE (code in  varchar2) return VARCHAR2 IS

l_meaning varchar2(100) ;

 CURSOR c_rid  (code varchar2)   IS
       SELECT MEANING
        FROM   fnd_lookup_values
	WHERE  lookup_type = 'BIM_GEN_LOOKUP'
	AND    lookup_code =code
	AND    language = USERENV('LANG');

BEGIN

 OPEN c_rid(code);
         FETCH c_rid   INTO l_meaning;
 CLOSE c_rid;
    return l_meaning;

END  GET_LOOKUP_VALUE;


FUNCTION GET_CONTEXT_VIEWBY (code in  varchar2) return VARCHAR2 IS

l_meaning varchar2(100) ;

 CURSOR c_rid  (code varchar2)   IS
       select a.name from bis_levels_tl a,bis_levels b
       where
       a.level_id = b.level_id
       and b.short_name =code
       and a.language=USERENV('LANG');

BEGIN

 OPEN c_rid(code);
         FETCH c_rid   INTO l_meaning;
 CLOSE c_rid;
    return l_meaning;

END  GET_CONTEXT_VIEWBY;



END  BIM_PMV_DBI_UTL_PKG;

/
