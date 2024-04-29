--------------------------------------------------------
--  DDL for Package Body BIM_I_LEAD_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_I_LEAD_MGMT_PVT" AS
/* $Header: bimvldib.pls 120.2 2005/11/25 00:36:07 arvikuma noship $ */

   G_ORGANIZATION CONSTANT VARCHAR2(80) := 'ORGANIZATION';
   G_SALES_GROUP CONSTANT VARCHAR2(80) := 'JTF_ORG_SALES_GROUP';
   G_ORG_SG CONSTANT VARCHAR2(80) := G_ORGANIZATION||'+'||G_SALES_GROUP;
   G_TIME CONSTANT VARCHAR2(80) := 'TIME';
   G_PERIOD_TYPE CONSTANT varchar2(80) := 'PERIOD_TYPE';
   G_TIME_PERIOD CONSTANT varchar2(80) := G_TIME||'+'||G_PERIOD_TYPE;
   G_BIS_CURRENT_ASOF_DATE CONSTANT varchar2(80) := 'BIS_CURRENT_ASOF_DATE';
   G_BIS_PREVIOUS_ASOF_DATE CONSTANT VARCHAR2(80) := 'BIS_PREVIOUS_ASOF_DATE';
   G_AS_OF_DATE CONSTANT varchar2(80) := 'AS_OF_DATE';
   G_TIME_COMPARISON_TYPE CONSTANT varchar2(80) := 'TIME_COMPARISON_TYPE';
   --G_PROD_DIRECTLY_ASSIGNED varchar2(80) := ' - '||bim_pmv_dbi_utl_pkg.get_lookup_value('DASS');
   --G_UNASSIGNED varchar2(80) := bim_pmv_dbi_utl_pkg.get_lookup_value('UNA');
   --G_OTHERS varchar2(80) := bim_pmv_dbi_utl_pkg.get_lookup_value('OTH');
   G_START_DATE CONSTANT  DATE := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');
   Label1       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('LEAD_STATUS');
   Label2       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('LEAD_AGE');
   Label3       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('LEAD_END_DT');
   Label4       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('LEAD_CLOSURE');


   L_viewby_ls  CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('BIM_LEAD_SOURCE');
   L_viewby_c   CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('COUNTRY');
   L_viewby_lq  CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('BIM_LEAD_QUALITY');
   L_viewby_pc  CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('ENI_ITEM_VBH_CAT');
   L_viewby_sg  CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('JTF_ORG_SALES_GROUP');
   L_viewby_cc  CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('CUSTOMER CATEGORY');
   L_viewby_sc  CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('BIS_SALES_CHANNELS');


PROCEDURE test(parameter IN varchar2 ,
               value IN varchar2
               )
IS
BEGIN
   --INSERT INTO bim_param_test values(parameter,value);
   --COMMIT;
   NULL;
END;

--  **********************************************************************
--	PROCEDURE PARSE_SALES_GROUP_ID
--
--	Purpose: if a resource is selected, then PMV will pass a concatenated
-- resource_id.sales_group_id in the sales_group parameter.  Parsing it here
-- into two parameters.  Used by the get_page_params procedure, as well as
-- by top_open_oppties report directly.
--
--  **********************************************************************
PROCEDURE PARSE_SALES_GROUP_ID(
        p_salesgroup_id     IN OUT NOCOPY VARCHAR2,
        x_resource_id       OUT NOCOPY VARCHAR2
       ) IS

l_sg_id         VARCHAR2(20);
l_resource_id   VARCHAR2(20);
l_dot           NUMBER;

BEGIN

    l_dot:= INSTR(p_salesgroup_id, '.');
    IF(l_dot > 0) then
      l_sg_id := SUBSTR(p_salesgroup_id,l_dot + 1) ;
	  l_resource_id := SUBSTR(p_salesgroup_id,1,l_dot - 1);
    ELSE
      l_sg_id := p_salesgroup_id;
    END IF;

    p_salesgroup_id := REPLACE(l_sg_id,'''','');
    x_resource_id:= REPLACE(l_resource_id,'''','');

END PARSE_SALES_GROUP_ID;


--  **********************************************************************
--  PROCEDURE GetLabel
--  Procedure to enable change of  column Name's in Reports dynamically
--  **********************************************************************


FUNCTION GLbl( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL,colno in number )
  RETURN VARCHAR2	IS
  l_metric_def			VARCHAR2(5000);
  l_report_def                  VARCHAR2(5000);
  l_view_by                     varchar2(5000);


  BEGIN

  IF (p_page_parameter_tbl.count > 0) THEN
  FOR i IN p_page_parameter_tbl.FIRST..p_page_parameter_tbl.LAST
      LOOP


	 IF( p_page_parameter_tbl(i).parameter_name in ('BIM_PARAMETER1','BIM_PARAMETER5')) THEN
	   l_report_def := p_page_parameter_tbl(i).parameter_value;
         END IF;

	 IF( p_page_parameter_tbl(i).parameter_name in ('BIM_PARAMETER3','BIM_PARAMETER7')) THEN
	   l_metric_def := p_page_parameter_tbl(i).parameter_value;
         END IF;

	  IF( p_page_parameter_tbl(i).parameter_name= 'VIEW_BY') THEN
          l_view_by := p_page_parameter_tbl(i).parameter_value;
          if l_view_by is null then
            l_view_by := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
          end if;
        END IF;


      END LOOP;

END IF;

l_report_def := trim(l_report_def);
l_metric_def := trim(l_metric_def);

           --l_report_def='LEAD_ACTIVITY'
       if  l_report_def='A' then
	     if  l_metric_def in ('B','C2')  then
	        if  colno =1 then
	            return Label3 ;
	        elsif colno =2 then
	            return Label4;
	        end if;
             elsif  (l_metric_def='D' or l_metric_def='E') then
	         if  colno =1 then
	            return Label1 ;
	         elsif colno =2 then
	            return Label2;
	         end if;
             elsif  (l_metric_def='A') then
	         if  colno =1 then
		    return Label1 ;
                 end if;
	     end if;
	  --   l_report_def='LEAD_AGING'
	 elsif l_report_def='G' then
	     if  colno =1 then
	      return Label1 ;
	     else
	      return Label2;
	     end if;
	     --l_report_def='LEAD_QUALITY'
        elsif (l_report_def='Q' ) then
	    if  colno =1 then
	      return Label1 ;
	    end if;
	 end if;


   EXCEPTION
   WHEN OTHERS THEN
	RETURN NULL;
   END GLbl;

--  **********************************************************************
--  PROCEDURE GET_PAGE_PARAMS
--
--  **********************************************************************
PROCEDURE GET_PAGE_PARAMS (p_page_parameter_tbl     IN     BIS_PMV_PAGE_PARAMETER_TBL,
                          p_period_type             OUT NOCOPY VARCHAR2,
                          p_record_type             OUT NOCOPY VARCHAR2,
                          p_sg_id                   OUT NOCOPY VARCHAR2,
                          p_resource_id             OUT NOCOPY VARCHAR2,
                          p_comp_type               OUT NOCOPY VARCHAR2,
                          p_as_of_date              OUT NOCOPY DATE,
                          p_page_period_type        OUT NOCOPY VARCHAR2,
                          p_category_id             OUT NOCOPY VARCHAR2,
                          p_curr_page_time_id      OUT NOCOPY NUMBER,
                          p_prev_page_time_id      OUT NOCOPY NUMBER,
                          l_view_by                OUT NOCOPY VARCHAR2,
			  l_col_by                 OUT NOCOPY VARCHAR2,
			  l_report_name            OUT NOCOPY VARCHAR2,
			  l_view_id                OUT NOCOPY VARCHAR2,
			  l_close_rs               OUT NOCOPY VARCHAR2,
			  l_context                OUT NOCOPY VARCHAR2,
			  p_camp_id                OUT NOCOPY VARCHAR2)

        IS

  l_salesgroup_id          VARCHAR2(200);
  l_resource_id            VARCHAR2(20);


BEGIN

  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last
     LOOP

        IF( p_page_parameter_tbl(i).parameter_name in ('BIM_PARAMETER1','BIM_PARAMETER5')) THEN
	   l_report_name := p_page_parameter_tbl(i).parameter_value;
	END IF;

	IF( p_page_parameter_tbl(i).parameter_name in ('BIM_PARAMETER2','BIM_PARAMETER6')) THEN
	   l_view_id := p_page_parameter_tbl(i).parameter_value;
	   if p_page_parameter_tbl(i).PARAMETER_ID is null then
	      l_view_id :=null;
	   end if;
	END IF;

	IF( p_page_parameter_tbl(i).parameter_name in  ('BIM_PARAMETER3','BIM_PARAMETER7')) THEN
	   l_col_by := p_page_parameter_tbl(i).parameter_value;
	END IF;

       IF( p_page_parameter_tbl(i).parameter_name ='BIM_PARAMETER9') THEN

	   l_close_rs := p_page_parameter_tbl(i).parameter_value;

	END IF;

	IF( p_page_parameter_tbl(i).parameter_name ='BIM_PARAMETER4') THEN
	   l_context := p_page_parameter_tbl(i).parameter_value;
	END IF;

	IF p_page_parameter_tbl(i).parameter_name = 'CAMPAIGN+CAMPAIGN' THEN
          p_camp_id := p_page_parameter_tbl(i).parameter_id;
        END IF;

        IF p_page_parameter_tbl(i).parameter_name = G_PERIOD_TYPE THEN
          p_page_period_type := p_page_parameter_tbl(i).parameter_value;
        END IF;

        IF p_page_parameter_tbl(i).parameter_name= G_TIME_COMPARISON_TYPE THEN
            p_comp_type := p_page_parameter_tbl(i).parameter_value;
        END IF;

        IF p_page_parameter_tbl(i).parameter_name= G_AS_OF_DATE THEN
          --l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
          p_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
        END IF;

        IF p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT' THEN
          p_category_id := p_page_parameter_tbl(i).parameter_id;
        END IF;

        IF( p_page_parameter_tbl(i).parameter_name= 'VIEW_BY') THEN
          l_view_by := p_page_parameter_tbl(i).parameter_value;
          if l_view_by is null then
            l_view_by := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
          end if;
        END IF;

        IF( p_page_parameter_tbl(i).parameter_name= 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
                    l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;
                    PARSE_SALES_GROUP_ID(
                                         p_salesgroup_id =>l_salesgroup_id,
                                         x_resource_id   =>l_resource_id);

                     p_sg_id:= l_salesgroup_id;
                     p_resource_id:=l_resource_id;
        END IF;

/*Getting values for previous time id*/

     IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_PFROM' THEN

                    p_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
           END IF;

     IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_PFROM' THEN

                    p_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
           END IF;

           IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_PFROM' THEN

                    p_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
           END IF;

           IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_PFROM' THEN

           p_prev_page_time_id := p_page_parameter_tbl(i).parameter_id;
           END IF;


       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_WEEK_FROM' THEN
          p_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
          p_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
          p_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
          p_curr_page_time_id := p_page_parameter_tbl(i).parameter_id;
       END IF;

       /*test(p_page_parameter_tbl(i).parameter_name,
          p_page_parameter_tbl(i).parameter_id,
          p_page_parameter_tbl(i).parameter_value,
          NULL,p_page_parameter_tbl(i).DIMENSION,
          p_page_parameter_tbl(i).period_date);*/
     END LOOP;
  END IF;
  COMMIT;

  -- Retrieve Period_Type info using CASE

  CASE p_page_period_type
    WHEN 'FII_TIME_WEEK' THEN p_period_type := 16; p_record_type := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN p_period_type := 32; p_record_type := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN p_period_type := 64; p_record_type := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN p_period_type := 128; p_record_type := 119;
    ELSE p_period_type := 64; p_record_type := 55;
  END CASE;

  -- Derive fact.effective_time_id from AS_OF_DATE, time_comparison_type and time dimension tables
         /**********************************************************
         *SELECT WEEK_ID
         *FROM fii_time_week
         *WHERE to_date('14-JUL-2002','DD-MON-YYYY') >= start_date
         *AND   to_date('14-JUL-2002','DD-MON-YYYY') <= end_date
         *
         *SELECT MONTH_ID -- Get Month_id
         *FROM fii_time_month -- NEED TO GET THE RIGHT TABLE FROM period_type
         *WHERE to_date('14-JUL-2002','DD-MON-YYYY') >= start_date
         *AND   to_date('14-JUL-2002','DD-MON-YYYY') <= end_date
         *
         *SELECT QUARTER_ID -- GET quarter_id
         *FROM fii_time_qtr
         *WHERE to_date('14-JUL-2002','DD-MON-YYYY') >= start_date
         *AND   to_date('14-JUL-2002','DD-MON-YYYY') <= end_date
         *
         *SELECT YEAR_ID  -- GET year_id
         *FROM  fii_time_year
         *WHERE to_date('14-JUL-2002','DD-MON-YYYY') >= start_date
         *AND   to_date('14-JUL-2002','DD-MON-YYYY') <= end_date
         **********************************************************/
 -- get values for p_prev_page_time_id
 -- ER #2467584 for gettig previous time_id e.g. TIME+FII_TIME_ENT_PERIOD_PFROM and TIME+FII_TIME_ENT_PERIOD_PTO
/*          IF (p_comp_type = 'YEARLY') THEN
            CASE p_page_period_type
                WHEN 'FII_TIME_WEEK' THEN
                    l_prior_as_of_date := FII_TIME_API.sd_lyswk(l_as_of_date);
                WHEN 'FII_TIME_ENT_PERIOD' THEN
                    l_prior_as_of_date := FII_TIME_API.ent_sd_lysper_end(l_as_of_date);
                WHEN 'FII_TIME_ENT_QTR' THEN
                    l_prior_as_of_date := FII_TIME_API.ent_sd_lysqtr_end(l_as_of_date);
                WHEN 'FII_TIME_ENT_YEAR' THEN
                    l_prior_as_of_date := FII_TIME_API.ent_sd_lyr_end(l_as_of_date);
                ELSE
                    l_prior_as_of_date := FII_TIME_API.ent_sd_lysqtr_end(l_as_of_date);
             END CASE;
          ELSIF (p_comp_type = 'SEQUENTIAL') THEN
             CASE p_page_period_type
                WHEN 'FII_TIME_WEEK' THEN
                    l_prior_as_of_date := FII_TIME_API.sd_pwk(l_as_of_date);
                WHEN 'FII_TIME_ENT_PERIOD' THEN
                    l_prior_as_of_date := FII_TIME_API.ent_sd_pper_end(l_as_of_date);
                WHEN 'FII_TIME_ENT_QTR' THEN
                    l_prior_as_of_date := FII_TIME_API.ent_sd_pqtr_end(l_as_of_date);
                WHEN 'FII_TIME_ENT_YEAR' THEN
                    l_prior_as_of_date := FII_TIME_API.ent_sd_lyr_end(l_as_of_date);
                ELSE
                    l_prior_as_of_date := FII_TIME_API.ent_sd_pqtr_end(l_as_of_date);
             END CASE;
          END IF;

          p_prior_as_of_date := l_prior_as_of_date;
*/
/*  CASE p_page_period_type
    WHEN 'FII_TIME_WEEK' THEN
                         select WEEK_ID
                         into   p_prev_page_time_id
                         from   fii_time_week
                         where  l_prior_as_of_date BETWEEN start_date AND end_date;

    WHEN 'FII_TIME_ENT_PERIOD' THEN

                         select MONTH_ID
                         into   p_prev_page_time_id
                         from   fii_time_month
                         where  l_prior_as_of_date BETWEEN start_date AND end_date;

    WHEN 'FII_TIME_ENT_QTR' THEN
                         select QUARTER_ID
                         into   p_prev_page_time_id
                         from   fii_time_qtr
                         where  l_prior_as_of_date BETWEEN start_date AND end_date;

    WHEN 'FII_TIME_ENT_YEAR' THEN
                         select YEAR_ID
                         into   p_prev_page_time_id
                         from   fii_time_year
                         where  l_prior_as_of_date BETWEEN start_date AND end_date;

  END CASE;
*/
  --Retrieve sales_group_id from selected. No other logic required. Likely will be a VIEWBY
/*   p_sg_id := l_salesgroup_id;
   IF p_sg_id IS NULL THEN
      p_sg_id := '0';
   ELSE
      IF instr(p_sg_id,',') > 0 THEN
         p_sg_id := substr(p_sg_id,1,instr(p_sg_id,',')-1);
      END IF;
      IF instr(p_sg_id,'''') > 0 THEN
         p_sg_id := REPLACE(p_sg_id,'''','');
      END IF;
      IF p_sg_id = '' THEN
         p_sg_id := '0';
      END IF;
   END IF;
*/

END GET_PAGE_PARAMS;

--  **********************************************************************
--	PROCEDURE GET_CURRENCY
--
--  **********************************************************************
PROCEDURE GET_CURRENCY (p_page_parameter_tbl     IN     BIS_PMV_PAGE_PARAMETER_TBL,
    		          l_currency                OUT NOCOPY VARCHAR2)

			  IS
BEGIN

    --test('Start GET_PAGE_PARAMS');
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
     IF ( p_page_parameter_tbl(i).parameter_name= 'CURRENCY+FII_CURRENCIES') THEN
	     l_currency := p_page_parameter_tbl(i).parameter_id;
     END IF;
     END LOOP;
  END IF;


 END GET_CURRENCY;

-- -------------------------------------------------------------------
-- Name: bil_pyr_end
-- Desc: Returns previous enterprise year end date.
-- Output: Previous Enterprise year end date.
-- --------------------------------------------------------------------
Function bil_pyr_end(as_of_date date, num_periods number) return DATE is
  l_date date;
   CURSOR c_get_pyr_end_date(p_as_of_date date) is
  select end_date
  from fii_time_ent_year
  where sequence =
  (select sequence - num_periods
   from fii_time_ent_year
   where p_as_of_date between start_date and end_date);
begin
   OPEN c_get_pyr_end_date(as_of_date);
   FETCH c_get_pyr_end_date INTO l_date;
   CLOSE c_get_pyr_end_date;
  return l_date;
end;


-- -------------------------------------------------------------------
-- Name: bil_pper_end
-- Desc: Returns previous enterprise period end date.
-- Output: Previous Enterprise Period end date
-- --------------------------------------------------------------------
Function bil_pper_end(as_of_date date) return DATE is -- will get lastDay of prior''s prior as-of-date period
  l_date        date;
  CURSOR c_get_pper_end_date(p_as_of_date date) IS
    SELECT p2.end_date
    FROM fii_time_ent_period p1, fii_time_ent_period p2
    WHERE p1.sequence = p2.sequence
    AND p_as_of_date BETWEEN p1.start_date AND p1.end_date
    AND p2.ent_year_id = p1.ent_year_id -2;
BEGIN
   OPEN c_get_pper_end_date(as_of_date);
   FETCH c_get_pper_end_date INTO l_date;
   CLOSE c_get_pper_end_date;
  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: bil_pqtr_end
-- Desc: Returns previous enterprise quarter end date.
-- Output: Previous enterprise quarter end date.
-- --------------------------------------------------------------------
Function bil_pqtr_end(as_of_date date) return DATE is
  l_date      date;
  CURSOR c_get_pqtr_end_date(p_as_of_date date) is
       select qtr2.end_date
       from fii_time_ent_qtr qtr1, fii_time_ent_qtr qtr2
       where p_as_of_date between qtr1.start_date and qtr1.end_date
       and qtr2.sequence = qtr1.sequence and qtr2.ent_year_id=qtr1.ent_year_id-2;
begin
   OPEN c_get_pqtr_end_date(as_of_date);
   FETCH c_get_pqtr_end_date INTO l_date;
   CLOSE c_get_pqtr_end_date;
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
                             p_series_name       OUT NOCOPY VARCHAR2
                             )
IS
BEGIN
CASE
  WHEN p_page_period_type = 'FII_TIME_ENT_YEAR' then
    p_table_name := 'fii_time_ent_year_v';
--    p_column_name := 'ent_year_id, ent_year_id';
--    p_curr_start_date := bil_pyr_end(p_curr_as_of_date, 4);
--    p_series_name := 'TO_CHAR(MOD(ent_year_id,100),''FM00'')';

  WHEN p_page_period_type = 'FII_TIME_WEEK' then
    p_table_name := 'fii_time_week_v';
--    p_column_name := 'to_char(end_date,''RRRR'') ent_year_id, week_id';
--    p_curr_start_date := (fii_time_api.cwk_end(p_curr_as_of_date) - 91);  -- use (as_of_date -13*7)
--    p_series_name := 'TO_CHAR(end_date,''DDMon'')';

--	 IF p_comp_type = 'YEARLY' then
     --p_curr_start_date := (fii_time_api.cwk_end(p_curr_as_of_date) - 91);
--	  p_prev_start_date := (fii_time_api.lyswk_end(p_curr_as_of_date)-91);
--    END IF;
  WHEN p_page_period_type = 'FII_TIME_ENT_PERIOD' then
    p_table_name := 'fii_time_ent_period_v';
--    p_column_name := 'ent_year_id, ent_period_id';
    --l_curr_end_date := fii_time_api.ent_cper_end(p_curr_as_of_date); -- use &BIS_CURRENT_EFFECTIVE_END_DATE
--    p_curr_start_date := fii_time_api.ent_lysper_end(p_curr_as_of_date);
--    p_series_name := 'TO_CHAR(end_date,''Mon'')';

--	IF p_comp_type = 'YEARLY' then
--    p_curr_start_date := (p_curr_start_date+1); --Last year same Enterprise period start date
--    p_prev_start_date := (bil_pper_end(p_curr_as_of_date)+1); -- lastDay+1 of prior''s prior as-of-date period
--    END IF;

    ELSE
--  WHEN p_page_period_type = 'FII_TIME_ENT_QTR' then
    p_table_name := 'fii_time_ent_qtr_v';
--    p_column_name := 'ent_year_id, ent_qtr_id';
--    p_curr_start_date := bil_pqtr_end(p_curr_as_of_date); --8 continuous quarters
--    p_series_name := 'FND_GLOBAL.LOCAL_CHR(81)||sequence||FND_GLOBAL.LOCAL_CHR(45)||TO_CHAR(MOD(ent_year_id,100),''FM00'')';

--	IF p_comp_type = 'YEARLY' then
--    p_curr_start_date := (fii_time_api.ent_lysqtr_end(p_curr_as_of_date)+1); -- lastDay+1 of prior's as-of-date period
--	 p_prev_start_date := (fii_time_api.ent_lysqtr_end(p_curr_start_date)+1); -- lastDay+1 of prior''s prior as-of-date period
--	END IF;
 END CASE;
/*
 IF (p_comp_type = 'YEARLY') THEN
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
 END IF;
*/
END GET_TREND_PARAMS;

/***************************************************************/
/* Internal Function to Check if a given Node is a Leaf Node   */
/* or not.                                                     */
/***************************************************************/

FUNCTION GETLEAFNODE(l_Category_ID IN VARCHAR2)
         RETURN BOOLEAN
IS L_LEAF_node VARCHAR2(1);
BEGIN

  SELECT LEAF_NODE_FLAG INTO L_LEAF_NODE FROM ENI_ITEM_VBH_NODES_V
  WHERE PARENT_ID = replace(l_Category_ID,'''','')
  AND PARENT_ID = CHILD_ID;

  IF(l_leaf_node = 'Y') THEN
      return TRUE;
  ELSE
      return FALSE;
  END IF;

EXCEPTION
WHEN OTHERS THEN
 return FALSE;
END;


-- Start of comments
-- NAME
--    GET_KPI_SQL
--
-- PURPOSE
--    Returns the KPI bin query.
--
-- NOTES
--
-- HISTORY
-- 08/27/2002  dmvincen  created.
--
-- End of comments
PROCEDURE GET_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_query_rec bis_map_rec;
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_juldate  number := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(20000) := NULL;
      l_current_date date := NULL;
      l_previous_date date := NULL;
      l_current_date_str varchar2(80) := NULL;
      l_previous_date_str varchar2(80) := NULL;
      l_error_msg varchar2(4000) := NULL;
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by varchar2(4000);
      l_compare_date date := NULL;
      l_seq_date date := NULL;
      l_resource_id   VARCHAR2(20);
      l_hint varchar2(200);
      l_curr VARCHAR2(50);
      l_curr_suffix VARCHAR2(50);

      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);

-- -----------/* Declaration of local variables to form the final query */----------------------
l_qry VARCHAR2(10000);
l_qry1 VARCHAR2(1000);
l_qry2 VARCHAR2(100);
l_qry3 VARCHAR2(1000);
l_qry4 VARCHAR2(175);
l_qry4_res VARCHAR2(50);
l_qry5 VARCHAR2(80);
l_qry6 VARCHAR2(2000);
l_qry7 VARCHAR2(1000);
l_qry8 VARCHAR2(500);
l_qry9 VARCHAR2(1000);
l_qry10 VARCHAR2(1000);
l_qry10_res VARCHAR2(50);
l_qry11 VARCHAR2(100);
l_qry12 VARCHAR2(2000);
l_qry13 VARCHAR2(1000);
l_qry14 VARCHAR2(1500);
l_qry15 VARCHAR2(1500);
l_qry16 VARCHAR2(1000);
l_qry16_res VARCHAR2(200);
l_qry17 VARCHAR2(100);
l_camp_id VARCHAR2(100);
l_close_rs      VARCHAR2(500);
l_context       VARCHAR2(5000);

-- -----------/* End of Declaration of local variables to form the final query */ ----------------------
   BEGIN

      l_qry2 := ' ';
      l_qry4 := ' AND b.time_id=c.time_id AND b.period_type_id=c.period_type_id
                  AND b.resource_id = ' ;
      l_qry14:= ' ';
      l_qry8 := ' ';
      l_qry10 := 'AND c.calendar_id=-1
                  AND c.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1, &BIS_PREVIOUS_EFFECTIVE_START_DATE -1,&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
                  AND BITAND(c.record_type_id,1143)=c.record_type_id
                  AND b.time_id=c.time_id
                  AND b.period_type_id=c.period_type_id
                  AND b.resource_id = ';
      l_qry12 := ' /* Query for Opportunity Amount in KPI */
                  UNION ALL
                  SELECT /*+ leading(c) */
                   0 c_lds,
                   0 p_lds,
                   0 c_leads,
                   0 p_leads,
                   0 c_leads_a,
                   0 p_leads_a,
                   0 c_opps,
                   0 p_opps,
                   0 c_boa,
                   0 p_boa,
                   0 c_no_leads,
                   0 p_no_leads,
                   0 c_cost,
                   0 p_cost,
                   0 c_revenue,
                   0 p_revenue,
                   0 c_leads_open,
                   0 p_leads_open,
                   0 c_prior_open,
                   0 p_prior_open,
                   0 c_invoice_amt,
                   0 p_invoice_amt,
                   1 value,
                   SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.cnv_opty_amt else 0 end)  c_opp_amt_conv_leads,
                   SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE then b.cnv_opty_amt else 0 end) p_opp_amt_conv_leads
                  FROM FII_TIME_RPT_STRUCT c, ';
      l_qry16 := 'AND c.calendar_id=-1
                  AND c.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
                  AND BITAND(record_type_id,:l_record_type)=c.record_type_id
                  AND b.effective_time_id=c.time_id
                  AND b.effective_period_type_id=c.period_type_id  ';
      l_qry16_res := 'AND b.salesrep_id = ';

      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

      get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
		 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date      => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id       => l_curr_page_time_id,
		 p_prev_page_time_id       => l_prev_page_time_id,
		 l_view_by                 => l_view_by,
		 l_col_by                  => l_col_by,
		 l_report_name             => l_report_name,
		 l_view_id                 => l_view_id,
		 l_close_rs                => l_close_rs,
                 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );
      get_currency(p_page_parameter_tbl     =>p_page_parameter_tbl,
                 l_currency             => l_curr);

  IF (l_curr = '''FII_GLOBAL2''')
 THEN
 l_qry12 := ' /* Query for Opportunity Amount in KPI */
UNION ALL
SELECT /*+ leading(c) */
 0 c_lds,
 0 p_lds,
 0 c_leads,
 0 p_leads,
 0 c_leads_a,
 0 p_leads_a,
 0 c_opps,
 0 p_opps,
 0 c_boa,
 0 p_boa,
 0 c_no_leads,
 0 p_no_leads,
 0 c_cost,
 0 p_cost,
 0 c_revenue,
 0 p_revenue,
 0 c_leads_open,
 0 p_leads_open,
 0 c_prior_open,
 0 p_prior_open,
 0 c_invoice_amt,
 0 p_invoice_amt,
 1 value,
 SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.cnv_opty_amt_s else 0 end)  c_opp_amt_conv_leads,
 SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE then b.cnv_opty_amt_s else 0 end) p_opp_amt_conv_leads
FROM FII_TIME_RPT_STRUCT c, ';
  END IF;
--      l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
--      l_juldate := to_char(l_as_of_date, 'J');
--      l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';
--       test('GET_KPI_SQL as of dates are',l_current_asof_date,l_previous_asof_date);
--      SELECT current_date_id INTO l_current_date FROM BIS.BIS_SYSTEM_DATE;
/*      IF l_comp_type = 'YEARLY' THEN l_previous_date := add_months(l_current_date, -12);
      ELSIF l_period_type = 16 THEN l_previous_date := l_current_date - 7;
      ELSIF l_period_type = 32 THEN l_previous_date := add_months(l_current_date, -1);
      ELSIF l_period_type = 64 THEN l_previous_date := add_months(l_current_date, -3);
      ELSIF l_period_type = 128 THEN l_previous_date := add_months(l_current_date, -12);
      ELSE l_previous_date := add_months(l_current_date, -3);
      END IF;
      l_current_date_str := 'to_date('||to_char(l_current_date,'J')||',''J'')';
      l_previous_date_str := 'to_date('||to_char(l_previous_date,'J')||',''J'')';
       test('GET_KPI_SQL dates are',
       l_current_date_str,l_previous_date_str);
*/


 IF  (l_category_id is null) THEN
    l_hint := ' /*+ leading(c) */ ';


    l_qry1 := ' BIM_I_LD_GEN_SG_MV b ';
    l_qry3 := ' WHERE b.group_id=:l_group_id ';
    l_qry5 := ' AND b.update_period_type_id = -1 AND b.update_time_id = -1  ';
    l_qry7 := ' BIM_I_LD_GEN_SG_MV b  ';
    l_qry9 := ' WHERE b.group_id=:l_group_id ';
    l_qry11 := ' AND b.update_period_type_id = -1 AND b.update_time_id = -1  ';
    l_qry13 := ' BIL_BI_OPTY_G_MV b ';
    l_qry15 := ' WHERE b.parent_sales_group_id=:l_group_id ';
    l_qry17 := ' ) ) a';

    /* If Only Group is passed without Sales Rep */
    if (l_resource_id is null) THEN
          l_resource_id := '-1';
	  l_qry4_res :=':l_resource_id ';
	  l_qry10_res:=':l_resource_id ';
	  l_qry16_res := null;
    else
    /* If Only Sales Rep is Passed*/
	  l_qry4_res := ':l_resource_id ';
	  l_qry10_res :=':l_resource_id ';
	  l_qry16_res := l_qry16_res||' :l_resource_id';
    end if;
 ELSE
    l_hint := ' /*+ ORDERED */ ';
--    l_hint := ' /*+ leading(c) */ ';
    l_qry1 := ' BIM_I_LP_GEN_SG_MV b,
    ( select edh.child_id from eni_denorm_hierarchies edh, mtl_default_category_sets d
       where edh.object_type = ''CATEGORY_SET''
         AND edh.object_id = d.category_set_id   AND d.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ) edh ';
    l_qry3 := ' WHERE b.group_id=:l_group_id AND b.product_category_id = edh.child_id ';
    l_qry5 := ' AND b.update_period_type_id = -1 AND b.update_time_id = -1  ';
    l_qry7 := ' BIM_I_LP_GEN_SG_MV b,
    ( select edh.child_id from eni_denorm_hierarchies edh, mtl_default_category_sets d
       where edh.object_type = ''CATEGORY_SET''
         AND edh.object_id = d.category_set_id   AND d.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ) edh ';
    l_qry9 := ' WHERE b.group_id=:l_group_id AND b.product_category_id = edh.child_id  ';
    l_qry11 := ' AND b.update_period_type_id = -1 AND b.update_time_id = -1 ';
    l_qry13 := ' BIL_BI_OPTY_PG_MV b,
    ( select edh.child_id from eni_denorm_hierarchies edh, mtl_default_category_sets d
       where edh.object_type = ''CATEGORY_SET''
         AND edh.object_id = d.category_set_id   AND d.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ) edh ';
    l_qry15 := ' WHERE b.parent_sales_group_id=:l_group_id AND b.product_category_id = edh.child_id ';
    l_qry17 := ') ) a';

    /* If Only Group is passed without Sales Rep */
    if (l_resource_id is null) THEN
          l_resource_id := '-1';
 	  l_qry4_res := ':l_resource_id ';
	  l_qry10_res := ':l_resource_id ';
	  l_qry16_res := null;
    else
    /* If Only Sales Rep is Passed*/
	  l_qry4_res := ':l_resource_id ';
	  l_qry10_res :=':l_resource_id ';
	  l_qry16_res := l_qry16_res||':l_resource_id ';
    end if;
 END IF;

l_qry  :=
'SELECT
    c_leads BIM_MEASURE1,p_leads BIM_MEASURE2,
     c_leads BIM_GRAND_TOTAL1,p_leads BIM_CGRAND_TOTAL1,
    DECODE(c_leads,0,NULL,100*(c_leads_a/c_leads)) BIM_MEASURE3,
    DECODE(p_leads,0,NULL,100*(p_leads_a/p_leads)) BIM_MEASURE4,
    DECODE(c_leads,0,NULL,100*(c_leads_a/c_leads)) BIM_GRAND_TOTAL2,
    DECODE(p_leads,0,NULL,100*(p_leads_a/p_leads)) BIM_CGRAND_TOTAL2,
    0 BIM_MEASURE5, 0 BIM_MEASURE6,
    0 BIM_GRAND_TOTAL3, 0 BIM_CGRAND_TOTAL3,
    DECODE(c_no_leads,0,NULL,(c_boa/c_no_leads)) BIM_MEASURE7,
    DECODE(p_no_leads,0,NULL,(p_boa/p_no_leads)) BIM_MEASURE8,
    DECODE(c_no_leads,0,NULL,(c_boa/c_no_leads)) BIM_GRAND_TOTAL4,
    DECODE(p_no_leads,0,NULL,(p_boa/p_no_leads)) BIM_CGRAND_TOTAL4,
    DECODE((c_leads+c_prior_open),0,NULL,(c_opps*100/(c_prior_open+c_leads))) BIM_MEASURE9,
    DECODE((p_leads+p_prior_open),0,NULL,(p_opps*100/(p_prior_open+p_leads))) BIM_MEASURE10,
    DECODE((c_leads+c_prior_open),0,NULL,(c_opps*100/(c_prior_open+c_leads))) BIM_GRAND_TOTAL5,
    DECODE((p_leads+p_prior_open),0,NULL,(p_opps*100/(p_prior_open+p_leads))) BIM_CGRAND_TOTAL5,
    c_opps BIM_MEASURE11,p_opps BIM_MEASURE12,
    c_opps BIM_GRAND_TOTAL6,p_opps BIM_CGRAND_TOTAL6,
    c_boa BIM_MEASURE13,p_boa BIM_MEASURE14,
    c_boa BIM_GRAND_TOTAL7,p_boa BIM_CGRAND_TOTAL7,
    c_leads_open BIM_MEASURE15,p_leads_open BIM_MEASURE16,
    c_leads_open BIM_GRAND_TOTAL8,p_leads_open BIM_CGRAND_TOTAL8,
    c_invoice_amt BIM_MEASURE17,p_invoice_amt BIM_MEASURE18,
    c_invoice_amt BIM_GRAND_TOTAL9,p_invoice_amt BIM_CGRAND_TOTAL9,
    c_opp_amt_conv_leads BIM_MEASURE19,
    p_opp_amt_conv_leads BIM_MEASURE20,
    c_opp_amt_conv_leads BIM_GRAND_TOTAL10,
    p_opp_amt_conv_leads BIM_CGRAND_TOTAL10,
    c_leads_a BIM_MEASURE21,p_leads_a BIM_MEASURE22,
    c_leads_a BIM_GRAND_TOTAL11,p_leads_a BIM_CGRAND_TOTAL11
 FROM (
      SELECT
         sum(c_lds) c_lds, sum(p_lds) p_lds, sum(c_leads) c_leads, sum(p_leads) p_leads,
         sum(c_leads_a) c_leads_a, sum(p_leads_a) p_leads_a, sum(c_opps) c_opps, sum(p_opps) p_opps,
         sum(c_boa) c_boa, sum(p_boa) p_boa, sum(c_no_leads) c_no_leads, sum(p_no_leads) p_no_leads,
         0 c_cost, 0 p_cost, sum(c_revenue) c_revenue, sum(p_revenue) p_revenue,
         sum(c_leads_open) c_leads_open, sum(p_leads_open) p_leads_open,
         sum(c_prior_open) c_prior_open, sum(p_prior_open) p_prior_open,
         sum(c_invoice_amt) c_invoice_amt, sum(p_invoice_amt) p_invoice_amt, sum(value) value,
	 sum(c_opp_amt_conv_leads) c_opp_amt_conv_leads, sum(p_opp_amt_conv_leads) p_opp_amt_conv_leads
      FROM ( /* Query for Current and Previous */
           SELECT '||l_hint||'
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.leads else 0 end) c_lds,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.leads else 0 end) p_lds,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.leads else 0 end) c_leads,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.leads else 0 end) p_leads,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.rank_a else 0 end) c_leads_a,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE   then b.rank_a else 0 end) p_leads_a,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.leads_converted else 0 end) c_opps,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.leads_converted else 0 end) p_opps,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.orders_booked_amt else 0 end) c_boa,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.orders_booked_amt else 0 end) p_boa,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.leads_new else 0 end) c_no_leads,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.leads_new else 0 end) p_no_leads,
              0 c_cost,
              0 p_cost,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.orders_booked_amt*b.leads_new/DECODE(b.leads,0,1,b.leads) else 0 end) c_revenue,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.orders_booked_amt*b.leads_new/DECODE(b.leads,0,1,b.leads) else 0 end) p_revenue,
              0 c_leads_open,
              0 p_leads_open,
              0 c_prior_open,
              0 p_prior_open,
              SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE  then b.orders_invoiced_amt else 0 end) c_invoice_amt,
              SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE  then b.orders_invoiced_amt else 0 end) p_invoice_amt,
              1 value,
              0 c_opp_amt_conv_leads, 0 p_opp_amt_conv_leads
           FROM (
	        SELECT report_date,time_id,period_type_id
                FROM FII_TIME_RPT_STRUCT
                WHERE calendar_id=-1
                AND report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
                AND BITAND(record_type_id,:l_record_type)=record_type_id) c, ';

l_qry6 := ' /* Query for Prior Open */
UNION ALL
SELECT '||l_hint||'
 0 c_lds,
 0 p_lds,
 0 c_leads,
 0 p_leads,
 0 c_leads_a,
 0 p_leads_a,
 0 c_opps,
 0 p_opps,
 0 c_boa,
 0 p_boa,
 0 c_no_leads,
 0 p_no_leads,
 0 c_cost,
 0 p_cost,
 0 c_revenue,
 0 p_revenue,
 SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) c_leads_open,
 SUM(case when c.report_date=&BIS_PREVIOUS_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) p_leads_open,
 SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) c_prior_open,
 SUM(case when c.report_date=&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1 then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) p_prior_open,
 0 c_invoice_amt,
 0 p_invoice_amt,
 1 value,
 0 c_opp_amt_conv_leads,
 0 p_opp_amt_conv_leads
FROM FII_TIME_RPT_STRUCT c, ';

  l_query := l_qry||l_qry1||l_qry2||l_qry3||l_qry4||l_qry4_res||l_qry5||l_qry6||l_qry7||l_qry8||l_qry9||l_qry10||l_qry10_res||l_qry11||
            l_qry12||l_qry13||l_qry14||l_qry15||l_qry16||l_qry16_res||l_qry17;

  x_custom_sql := l_query;
  x_custom_output.EXTEND;

  /*l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_KEY;
  l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_CUSTOM_OUTPUT.COUNT) := l_custom_rec;
*/

  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_prev_time_id';
  l_custom_rec.attribute_value := l_prev_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;



   --test('GET_KPI_SQL','QUERY','',l_query);
   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
      --test('GET_KPI_SQL', 'EXCEPTION','test',l_error_msg);
   END;




PROCEDURE TEST_KPI_SQL
IS
   l_query_tbl bis_map_tbl := NULL;
   l_page_parameter_tbl BIS_PMV_PAGE_PARAMETER_TBL;
/* :=
      BIS_PMV_PAGE_PARAMETER_TBL(
BIS_PMV_PAGE_PARAMETER_REC('TIME_COMPARISON_TYPE','SEQUENTIAL','SEQUENTIAL','TIME_COMPARISON_TYPE',NULL),
BIS_PMV_PAGE_PARAMETER_REC('TIME+FII_TIME_WEEK_PTO','20020936','36 2002','TIME',to_date('9/8/2002','MM/DD/YYYY')),
BIS_PMV_PAGE_PARAMETER_REC('AS_OF_DATE','10/09/2002','10/09/2002',null,NULL),
BIS_PMV_PAGE_PARAMETER_REC('TIME+FII_TIME_WEEK_TO','20020937','37 2002','TIME',to_date('9/15/2002','MM/DD/YYYY')),
BIS_PMV_PAGE_PARAMETER_REC('PERIOD_TYPE','FII_TIME_WEEK','FII_TIME_WEEK','TIME',to_date('9/9/2002','MM/DD/YYYY')),
BIS_PMV_PAGE_PARAMETER_REC('TIME_COMPARISON_TYPE','SEQUENTIAL','SEQUENTIAL','TIME_COMPARISON_TYPE',null),
BIS_PMV_PAGE_PARAMETER_REC('ORDERBY','ORDERBY','BIM_MEASURE1',null,null),
BIS_PMV_PAGE_PARAMETER_REC('TIME+FII_TIME_WEEK_PFROM','20020936','36 2002','TIME',to_date('9/2/2002','MM/DD/YYYY')),
BIS_PMV_PAGE_PARAMETER_REC('ORGANIZATION+JTF_ORG_SALES_GROUP','''100000001'',''100000148'',''100000217''','-- LELLISON','ORGANIZATION',NULL)
      );*/
BEGIN
NULL;
   --GET_KPI_SQL(l_page_parameter_tbl,l_query_tbl);
END;

-- Start of comments
-- NAME
--    GET_LEAD_AGING_KPI_SQL

--
-- PURPOSE
--    Returns the Lead Aging KPI query.
--
-- NOTES
--
-- HISTORY
-- 08/27/2002  dmvincen  created.
--
-- End of comments


PROCEDURE GET_LEAD_AGE_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_previous_date_str varchar2(4000);
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(4000) := NULL;
      l_error_msg varchar2(4000) := NULL;
      l_previous_date DATE := NULL;
      l_bis_date CONSTANT DATE := trunc(sysdate);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_prev_page_time_id  NUMBER;
      l_view_by VARCHAR2(4000);
      l_resource_id VARCHAR2(20);
      l_camp_id VARCHAR2(100);
      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
      l_close_rs   VARCHAR2(500);
      l_context       VARCHAR2(5000);
   BEGIN
      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
      get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
		 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date        => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id        => l_curr_page_time_id,
		 p_prev_page_time_id        =>  l_prev_page_time_id,
		 l_view_by                 =>  l_view_by,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );
      /*IF l_comp_type = 'YEARLY' THEN l_previous_date_str := 'add_months(e.CURRENT_DATE_ID, -12)';
      ELSIF l_period_type = 16 THEN l_previous_date_str := 'e.CURRENT_DATE_ID - 7';
      ELSIF l_period_type = 32 THEN l_previous_date_str := 'add_months(e.CURRENT_DATE_ID, -1)';
      ELSIF l_period_type = 64 THEN l_previous_date_str := 'add_months(e.CURRENT_DATE_ID, -3)';
      ELSIF l_period_type = 128 THEN l_previous_date_str := 'add_months(e.CURRENT_DATE_ID, -12)';
      ELSE l_previous_date_str := 'add_months(l_current_date, -3)';
      END IF;
      */
    --  select current_date_id into l_bis_date from bis_system_date;

      IF l_comp_type = 'YEARLY' THEN l_previous_date := add_months(l_bis_date, -12);
      ELSIF l_period_type = 16 THEN l_previous_date := l_bis_date - 7;
      ELSIF l_period_type = 32 THEN l_previous_date := add_months(l_bis_date, -1);
      ELSIF l_period_type = 64 THEN l_previous_date := add_months(l_bis_date, -3);
      ELSIF l_period_type = 128 THEN l_previous_date := add_months(l_bis_date, -12);
      ELSE l_previous_date := add_months(l_bis_date, -3);
      END IF;
      if (l_category_id is null) THEN
       if (l_resource_id is null) THEN
   l_query :='SELECT c_lead_age BIM_MEASURE1,   p_lead_age BIM_MEASURE2,
   c_lead_age BIM_GRAND_TOTAL1,   p_lead_age BIM_CGRAND_TOTAL1,
       c_a_lead_age BIM_MEASURE3,  p_a_lead_age BIM_MEASURE4,
       c_a_lead_age BIM_GRAND_TOTAL2,  p_a_lead_age BIM_CGRAND_TOTAL2
 FROM(SELECT
               decode(sum(c_leads_open),0,NULL,sum(c_days)/sum(c_leads_open))c_lead_age,
               decode(sum(p_leads_open),0,NULL,sum(p_days)/sum(p_leads_open))p_lead_age,
               decode(sum(c_aleads_open),0,null,sum(c_adays)/sum(c_aleads_open))c_a_lead_age,
               decode(sum(p_aleads_open),0,null,sum(p_adays)/sum(p_aleads_open))p_a_lead_age
            FROM  bim_i_ld_age_sg_mv a
            WHERE a.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
            AND   a.resource_id = -1
       ) a';

       else
   l_query :='SELECT c_lead_age BIM_MEASURE1,   p_lead_age BIM_MEASURE2,
   c_lead_age BIM_GRAND_TOTAL1,   p_lead_age BIM_CGRAND_TOTAL1,
       c_a_lead_age BIM_MEASURE3,  p_a_lead_age BIM_MEASURE4,
       c_a_lead_age BIM_GRAND_TOTAL2,  p_a_lead_age BIM_CGRAND_TOTAL2
       FROM(SELECT
               decode(sum(c_leads_open),0,NULL,sum(c_days)/sum(c_leads_open))c_lead_age,
               decode(sum(p_leads_open),0,NULL,sum(p_days)/sum(p_leads_open))p_lead_age,
               decode(sum(c_aleads_open),0,null,sum(c_adays)/sum(c_aleads_open))c_a_lead_age,
               decode(sum(p_aleads_open),0,null,sum(p_adays)/sum(p_aleads_open))p_a_lead_age
            FROM  bim_i_ld_age_sg_mv a
            WHERE a.group_id = :l_group_id
            AND a.resource_id = :l_resource_id  ) a';
       end if;
     ELSE
       if (l_resource_id is null) THEN
l_query :='SELECT c_lead_age BIM_MEASURE1,   p_lead_age BIM_MEASURE2,
   c_lead_age BIM_GRAND_TOTAL1,   p_lead_age BIM_CGRAND_TOTAL1,
       c_a_lead_age BIM_MEASURE3,  p_a_lead_age BIM_MEASURE4,
       c_a_lead_age BIM_GRAND_TOTAL2,  p_a_lead_age BIM_CGRAND_TOTAL2
       FROM(SELECT
               decode(sum(c_leads_open),0,NULL,sum(c_days)/sum(c_leads_open))c_lead_age,
               decode(sum(p_leads_open),0,NULL,sum(p_days)/sum(p_leads_open))p_lead_age,
               decode(sum(c_aleads_open),0,null,sum(c_adays)/sum(c_aleads_open))c_a_lead_age,
               decode(sum(p_aleads_open),0,null,sum(p_adays)/sum(p_aleads_open))p_a_lead_age
            FROM  bim_i_lp_age_sg_mv a
            WHERE a.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
            AND a.product_category_id = &ITEM+ENI_ITEM_VBH_CAT
            AND   a.resource_id = -1
            AND   a.umark = 3
       ) a';
       else
l_query :='c_lead_age BIM_MEASURE1,   p_lead_age BIM_MEASURE2,
   c_lead_age BIM_GRAND_TOTAL1,   p_lead_age BIM_CGRAND_TOTAL1,
       c_a_lead_age BIM_MEASURE3,  p_a_lead_age BIM_MEASURE4,
       c_a_lead_age BIM_GRAND_TOTAL2,  p_a_lead_age BIM_CGRAND_TOTAL2
       FROM(SELECT
               decode(sum(c_leads_open),0,NULL,sum(c_days)/sum(c_leads_open))c_lead_age,
               decode(sum(p_leads_open),0,NULL,sum(p_days)/sum(p_leads_open))p_lead_age,
               decode(sum(c_aleads_open),0,null,sum(c_adays)/sum(c_aleads_open))c_a_lead_age,
               decode(sum(p_aleads_open),0,null,sum(p_adays)/sum(p_aleads_open))p_a_lead_age
            FROM  bim_i_lp_age_sg_mv a
            WHERE a.group_id = :l_group_id
            AND a.product_category_id = &ITEM+ENI_ITEM_VBH_CAT
            AND a.resource_id = :l_resource_id  AND   a.umark = 3 ) a';

      end if;
     END IF;

  x_custom_sql := l_query;
  x_custom_output.EXTEND;

  /*l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_KEY;
  l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_CUSTOM_OUTPUT.COUNT) := l_custom_rec;
*/

  l_custom_rec.attribute_name := ':l_previous_date';
  l_custom_rec.attribute_value := TO_CHAR(l_previous_date,'MM-DD-YYYY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;


   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
      --test('GET_LEAD_AGE_KPI_SQL', 'EXCEPTION','test',l_error_msg);
   END;

-- Start of comments
-- NAME
--    GET_LEAD_ACT_SQL
--
-- PURPOSE
--    Returns the Lead activity and conversion query.
--

PROCEDURE GET_LEAD_ACT_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(10000) := NULL;
      l_error_msg varchar2(4000);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_url_str VARCHAR2(1000);
      l_url_str1 VARCHAR2(1000);
      l_url_str2 VARCHAR2(1000);
      l_url_str3 VARCHAR2(1000);
      l_url_str4 VARCHAR2(1000);
      l_url_str5 VARCHAR2(1000);
      l_compare_date date := NULL;
      l_seq_date date := NULL;
      l_resource_id VARCHAR2(20);
/* First query */
l_col1_a   VARCHAR2(200) ;
l_col2_a   VARCHAR2(200) ;
l_col3_a   VARCHAR2(200) ;
l_tables_a VARCHAR2(500);
l_where_a  VARCHAR2(1000);

/* Second query */
l_col1_b   VARCHAR2(200) ;
l_col2_b   VARCHAR2(200) ;
l_col3_b   VARCHAR2(200) ;
l_tables_b VARCHAR2(500);
l_where_b  VARCHAR2(1000);

/* Third query */
l_col1_c   VARCHAR2(200) ;
l_col2_c   VARCHAR2(200) ;
l_col3_c   VARCHAR2(200) ;
l_tables_c VARCHAR2(500);
l_where_c  VARCHAR2(1000);

/* Fourth query */
l_col1_d   VARCHAR2(200) ;
l_col2_d   VARCHAR2(200) ;
l_col3_d   VARCHAR2(200) ;
l_tables_d VARCHAR2(500);
l_where_d  VARCHAR2(1000);
l_qry_sg   VARCHAR2(20000);
l_hint     VARCHAR2(100);

l_col_by  varchar2(5000);
l_report_name varchar2(5000);
l_view_id     varchar2(5000);
l_rpt_name  varchar2(2000);
l_Metric_a   varchar2(15);
l_Metric_b   varchar2(15);
l_Metric_c   varchar2(15);
l_Metric_d   varchar2(15);
l_Metric_e   varchar2(15);
l_camp_id  varchar2(100);
l_close_rs   VARCHAR2(500);
l_view_name  VARCHAR2(1000);
l_context       VARCHAR2(5000);
l_context_info      varchar2(1000);

BEGIN
   l_col3_a   := '0';
   l_col3_b   := '0';
   l_col3_c   := '0';
   l_col3_d   := '0';
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
              p_period_type             => l_period_type,
              p_record_type             => l_record_type,
              p_sg_id                   => l_org_sg,
              p_resource_id             => l_resource_id,
              p_comp_type               => l_comp_type,
              p_as_of_date              => l_as_of_date,
              --p_prior_as_of_date      => l_prior_as_of_date,
              p_page_period_type        => l_page_period_type,
              p_category_id             => l_category_id,
              p_curr_page_time_id       => l_curr_page_time_id,
              p_prev_page_time_id       => l_prev_page_time_id,
              l_view_by                 => l_view_by ,
	      l_col_by                  => l_col_by,
	      l_report_name             => l_report_name,
	      l_view_id                 => l_view_id,
	      l_close_rs                => l_close_rs,
	      l_context                 => l_context,
              p_camp_id                 => l_camp_id
                 );
   l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
   l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';

IF l_org_sg is null THEN
l_query := 'SELECT
NULL VIEWBY,
NULL VIEWBYID,
NULL BIM_MEASURE1,
NULL BIM_MEASURE2,
NULL BIM_MEASURE3,
NULL BIM_MEASURE4,
NULL BIM_MEASURE5,
NULL BIM_MEASURE6,
NULL BIM_MEASURE8,
NULL BIM_MEASURE7,
NULL BIM_MEASURE9,
NULL BIM_URL1,
NULL BIM_URL2,
NULL BIM_URL3,
NULL BIM_URL4,
NULL BIM_URL5,
NULL BIM_URL6,
NULL BIM_URL7,
NULL BIM_GRAND_TOTAL1,
NULL BIM_GRAND_TOTAL2,
NULL BIM_GRAND_TOTAL3,
NULL BIM_GRAND_TOTAL4,
NULL BIM_GRAND_TOTAL5,
NULL BIM_GRAND_TOTAL6,
NULL bim_GRAND_TOTAL7,
NULL bim_GRAND_TOTAL8,
NULL bim_GRAND_TOTAL9
FROM dual';

ELSE

if    l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'     then
  l_view_name:=L_viewby_sg;      -- 'Sales Group'
elsif l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'                then
  l_view_name:=L_viewby_pc ;     --'Product Category'
elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE'	 then
  l_view_name:=L_viewby_ls;      --'Lead Source'
elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY' then
  l_view_name:=L_viewby_lq;      --'Lead Quality'
elsif l_view_by = 'GEOGRAPHY+COUNTRY'			 then
  l_view_name:=L_viewby_c;       --'Country'
elsif l_view_by = 'SALES CHANNEL+SALES CHANNEL'	 then
  l_view_name:=L_viewby_sc;      --'Sales Channel'
elsif l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY'	 then
  l_view_name:=L_viewby_cc;      --'Customer Category'
end if;

   l_url_str:='pFunctionName=BIM_I_LEAD_LAC_SG_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';

-- "LEAD_ACTIVITY" report name is send as "A" to crunch URL string within 300 characters
--l_url_str1:='pFunctionName=BIM_I_LD_DETAIL_NP&pParamIds=Y&VIEW_BY='||l_view_by|| '&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER4='||l_view_name||' :'||'''||BIM_SALES_GROUP||''&BIM_PARAMETER1=A&BIM_PARAMETER3=';

   l_url_str1:='pFunctionName=BIM_I_LD_DETAIL_NP&pParamIds=Y&VIEW_BY='||l_view_by|| '&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=A&BIM_PARAMETER3=';
   l_url_str2:='pFunctionName=BIM_I_LD_DETAIL_CNV&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=A&BIM_PARAMETER3=';
   l_url_str3:='pFunctionName=BIM_I_LD_DETAIL_CF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=A&BIM_PARAMETER3=';
   l_url_str4:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=A&BIM_PARAMETER3=';
   l_url_str5:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=A&BIM_PARAMETER3=';

   l_rpt_name:='&BIM_PARAMETER2=';

   l_context_info:='&BIM_PARAMETER4='||l_view_name||' :''||BIM_SALES_GROUP||''''';


l_Metric_a   := 'A';
l_Metric_b   := 'B';
l_Metric_c   := 'C';
l_Metric_d   := 'D';
l_Metric_e   := 'E';

   IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN

      IF (l_category_id is null) THEN

         l_hint := ' /*+ leading(c) */ ';

         IF l_resource_id is null then
         /* First query */
            l_col1_a   := ' b.group_id ';
            l_col2_a   := ' b.group_id ';
            l_tables_a := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b ';
            l_where_a  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
          AND b.group_id=den.group_id
          AND den.immediate_parent_flag = ''Y''
          AND den.latest_relationship_flag = ''Y''
          AND b.time_id=c.time_id
          AND b.period_type_id=c.period_type_id
          AND b.update_time_id=-1
          AND b.update_period_type_id =-1
          AND b.resource_id = :l_resource_id ';

  /* Second query */
            l_col1_b   := ' b.resource_id ';
            l_col2_b   := ' b.resource_id||''.''||b.group_id ';
            l_col3_b   := '1';
            l_tables_b := ' BIM_I_LD_GEN_SG_MV b';
            l_where_b  := ' AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
          AND b.time_id=c.time_id
          AND b.period_type_id=c.period_type_id
          AND b.update_time_id=-1
          AND b.update_period_type_id =-1
          AND b.resource_id <> :l_resource_id ';

  /* Third query */
        l_col1_c   := ' b.group_id ';
        l_col2_c  := ' b.group_id ';
        l_tables_c := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b ';
        l_where_c  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND b.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
        AND b.time_id=c.time_id
        AND b.period_type_id=c.period_type_id
        AND b.update_time_id=-1
        AND b.update_period_type_id=-1
        AND b.resource_id = :l_resource_id ';

        /* Fourth query */
        l_col1_d   := ' b.resource_id ';
        l_col2_d   := ' b.resource_id||''.''||b.group_id ';
        l_col3_d   := '1';
        l_tables_d := ' BIM_I_LD_GEN_SG_MV b';
        l_where_d  := ' AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id <> :l_resource_id ';

         ELSE
          /* Second query */
        l_col1_b   := ' b.resource_id ';
        l_col2_b   := ' b.resource_id||''.''||b.group_id ';
        l_col3_b   := '1';
        l_tables_b := ' BIM_I_LD_GEN_SG_MV b';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         /* Fourth query */
        l_col1_d   := ' b.resource_id ';
        l_col2_d   := ' b.resource_id||''.''||b.group_id ';
        l_col3_d   := '1';
        l_tables_d := ' BIM_I_LD_GEN_SG_MV b';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         END IF;
      ELSE
         l_hint := ' /*+ ORDERED */ ';

      /* Category ID is not null */
         IF l_resource_id is null then

   /* First query */
        l_col1_a   := ' b.group_id ';
        l_col2_a   := ' b.group_id ';
        l_tables_a := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl';
        l_where_a  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND b.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
        AND b.time_id=c.time_id
        AND b.period_type_id=c.period_type_id
        AND b.update_time_id=-1
        AND b.update_period_type_id =-1
        AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

  /* Second query */
        l_col1_b   := ' b.resource_id ';
        l_col2_b   := ' b.resource_id||''.''||b.group_id ';
        l_col3_b   := '1';
        l_tables_b := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl';
        l_where_b  := ' AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id <> :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

  /* Third query */
        l_col1_c   := ' b.group_id ';
        l_col2_c  := '  b.group_id ';
        l_tables_c := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_c  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND b.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
        AND b.time_id=c.time_id
        AND b.period_type_id=c.period_type_id
        AND b.update_time_id=-1
        AND b.update_period_type_id=-1
        AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

        /* Fourth query */
        l_col1_d   := ' b.resource_id ';
        l_col2_d   := ' b.resource_id||''.''||b.group_id ';
        l_col3_d   := '1';
        l_tables_d := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_d  := ' AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id <> :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';
         ELSE
          /* Second query */
        l_col1_b   := ' b.resource_id ';
        l_col2_b   := ' b.resource_id||''.''||b.group_id ';
        l_col3_b   := '1';
        l_tables_b := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_b  := ' AND b.group_id =:l_group_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';
         /* Fourth query */
        l_col1_d   := ' b.resource_id ';
        l_col2_d   := ' b.resource_id||''.''||b.group_id ';
        l_col3_d   := '1';
        l_tables_d := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';
         END IF;
      END IF;
/* View by Category*/
   ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
      IF (l_category_id is null) THEN
         IF (l_resource_id is null) THEN
            l_query :=
' SELECT BIM_SALES_GROUP VIEWBY,
  VIEWBYID,
  prior_open BIM_MEASURE1,
  leads_new BIM_MEASURE2,
  leads_converted BIM_MEASURE3,
  leads_dead BIM_MEASURE4,
  curr_open BIM_MEASURE5,
  (curr_total-curr_leads_changed) BIM_MEASURE6,
  leads_closed BIM_MEASURE8,
  DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_MEASURE7,
  leads_converted BIM_MEASURE9,
  NULL BIM_URL1,
  DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
  decode(VIEWBYID,-1,null,decode(leads_new,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,-1,null,decode(leads_converted,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,-1,null,decode(leads_closed,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,-1,null,decode(curr_open,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,-1,null,decode((curr_total-curr_leads_changed),0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  SUM(prior_open) OVER() BIM_GRAND_TOTAL1,
  SUM(leads_new) OVER() BIM_GRAND_TOTAL2,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
  SUM(leads_dead) OVER() BIM_GRAND_TOTAL4,
  SUM(curr_open) OVER() BIM_GRAND_TOTAL5,
  SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL6,
  DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL7,
  SUM(leads_closed) OVER() BIM_GRAND_TOTAL8,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL9
  FROM
  (
  select BIM_SALES_GROUP,
  VIEWBYID,
  leaf_node_flag,
  sum(prior_open) prior_open,
  sum(curr_open) curr_open,
  sum(curr_total) curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead) leads_dead,
  sum(leads_closed) leads_closed,
  sum(curr_leads_changed) curr_leads_changed
  FROM
  (
  select /*+ ORDERED */
  p.value BIM_SALES_GROUP,
  p.parent_id VIEWBYID,
  p.leaf_node_flag leaf_node_flag,
  SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE <> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
  0 leads_converted,
  0 leads_new,
  0 leads_dead,
  0 leads_closed,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,
       ( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
           FROM eni_item_vbh_nodes_v e
          WHERE e.top_node_flag=''Y''
            AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
  WHERE
      b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND b.product_category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = d.category_set_id
  AND d.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = p.parent_id
  AND c.calendar_id=-1
  AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
  AND BITAND(c.record_type_id,1143)=c.record_type_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_period_type_id = -1
  AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
  GROUP BY p.value,p.parent_id,p.leaf_node_flag
  UNION ALL
  /*Others for sales group*/
  select /*+ ORDERED */
  p.value BIM_SALES_GROUP,
  p.parent_id VIEWBYID,
  p.leaf_node_flag leaf_node_flag,
  0 prior_open,
  0 curr_open,
  0 curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead)  leads_dead,
  sum(leads_closed) leads_closed,
  0  curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,
       ( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
           FROM eni_item_vbh_nodes_v e
          WHERE e.top_node_flag=''Y''
            AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
  WHERE
      b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND b.product_category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = d.category_set_id
  AND d.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = p.parent_id
  AND c.calendar_id=-1
  AND c.report_date = &BIS_CURRENT_ASOF_DATE
  AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_period_type_id = -1
  AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
  AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
  GROUP BY p.value,p.parent_id,p.leaf_node_flag
  )
  GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
  HAVING
  sum(prior_open) > 0
  OR sum(leads_new) > 0
  OR sum(leads_converted) > 0
  OR sum(leads_dead) > 0
  OR sum(curr_open) > 0
  OR sum(curr_total)-sum(curr_leads_changed) > 0
  OR sum(leads_closed) > 0
  ) &ORDER_BY_CLAUSE';

         ELSE
/* only sales rep is passed from page */
            l_query :=
 'SELECT BIM_SALES_GROUP VIEWBY,
  VIEWBYID,
  prior_open BIM_MEASURE1,
  leads_new BIM_MEASURE2,
  leads_converted BIM_MEASURE3,
  leads_dead BIM_MEASURE4,
  curr_open BIM_MEASURE5,
  (curr_total-curr_leads_changed) BIM_MEASURE6,
  leads_closed BIM_MEASURE8,
  DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_MEASURE7,
  leads_converted BIM_MEASURE9,
  NULL BIM_URL1,
  DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
  decode(VIEWBYID,-1,null,decode(leads_new,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,-1,null,decode(leads_converted,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,-1,null,decode(leads_closed,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,-1,null,decode(curr_open,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,-1,null,decode((curr_total-curr_leads_changed),0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  SUM(prior_open) OVER() BIM_GRAND_TOTAL1,
  SUM(leads_new) OVER() BIM_GRAND_TOTAL2,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
  SUM(leads_dead) OVER() BIM_GRAND_TOTAL4,
  SUM(curr_open) OVER() BIM_GRAND_TOTAL5,
  SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL6,
  DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL7,
  SUM(leads_closed) OVER() BIM_GRAND_TOTAL8,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL9
  FROM
  (
  select BIM_SALES_GROUP,
  VIEWBYID,
  leaf_node_flag,
  sum(prior_open) prior_open,
  sum(curr_open) curr_open,
  sum(curr_total) curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead) leads_dead,
  sum(leads_closed) leads_closed,
  sum(curr_leads_changed) curr_leads_changed
  FROM
  (
  select /*+ ORDERED */
  p.value BIM_SALES_GROUP,
  p.parent_id VIEWBYID,
  p.leaf_node_flag leaf_node_flag,
  SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
  0 leads_converted,
  0 leads_new,
  0 leads_dead,
  0 leads_closed,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,
       ( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
           FROM eni_item_vbh_nodes_v e
          WHERE e.top_node_flag=''Y''
            AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
  WHERE
      b.group_id =:l_group_id
  AND b.product_category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = d.category_set_id
  AND d.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = p.parent_id
  AND c.calendar_id=-1
  AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
  AND BITAND(c.record_type_id,1143)=c.record_type_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_period_type_id = -1
  AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
  GROUP BY p.value,p.parent_id,p.leaf_node_flag
  UNION ALL
  /*Others for sales group*/
  select /*+ ORDERED */
  p.value BIM_SALES_GROUP,
  p.parent_id VIEWBYID,
  p.leaf_node_flag leaf_node_flag,
  0 prior_open,
  0 curr_open,
  0 curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead)  leads_dead,
  sum(leads_closed) leads_closed,
  0  curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,
       ( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
           FROM eni_item_vbh_nodes_v e
          WHERE e.top_node_flag=''Y''
            AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
  WHERE
      b.group_id =:l_group_id
  AND b.product_category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = d.category_set_id
  AND d.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = p.parent_id
  AND c.calendar_id=-1
  AND c.report_date = &BIS_CURRENT_ASOF_DATE
  AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_period_type_id = -1
  AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
  AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
  GROUP BY p.value,p.parent_id,p.leaf_node_flag
  )
  GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
  HAVING
  sum(prior_open) > 0
  OR sum(leads_new) > 0
  OR sum(leads_converted) > 0
  OR sum(leads_dead) > 0
  OR sum(curr_open) > 0
  OR sum(curr_total)-sum(curr_leads_changed) > 0
  OR sum(leads_closed) > 0
  ) &ORDER_BY_CLAUSE';

         END IF;
      ELSE
/*Catgeory not equal to all*/
         IF (l_resource_id is null) THEN

            l_query :=
'SELECT BIM_SALES_GROUP VIEWBY,
VIEWBYID,
prior_open BIM_MEASURE1,
leads_new BIM_MEASURE2,
leads_converted BIM_MEASURE3,
leads_dead BIM_MEASURE4,
curr_open BIM_MEASURE5,
curr_total-curr_leads_changed BIM_MEASURE6,
leads_closed BIM_MEASURE8,
DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_MEASURE7,
leads_converted BIM_MEASURE9,
NULL BIM_URL1,
DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
CASE WHEN VIEWBYID = -1 THEN NULL WHEN dir_flag = 1 THEN NULL WHEN leads_new =0 THEN NULL
ELSE '||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL3,
CASE WHEN VIEWBYID = -1 THEN NULL WHEN dir_flag = 1 THEN NULL WHEN leads_converted = 0 THEN NULL ELSE
'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL4,
CASE WHEN VIEWBYID = -1 THEN NULL WHEN dir_flag = 1 THEN NULL WHEN leads_closed = 0 THEN NULL ELSE
'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL5,
CASE WHEN VIEWBYID = -1 THEN NULL WHEN dir_flag = 1 THEN NULL WHEN curr_open  = 0 THEN NULL ELSE
'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL6,
CASE WHEN VIEWBYID = -1 THEN NULL WHEN dir_flag = 1 THEN NULL WHEN (curr_total-curr_leads_changed)  = 0 THEN NULL ELSE
'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL7,
SUM(prior_open) OVER() BIM_GRAND_TOTAL1,SUM(leads_new) OVER() BIM_GRAND_TOTAL2,SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,SUM(leads_dead) OVER() BIM_GRAND_TOTAL4,
SUM(curr_open) OVER() BIM_GRAND_TOTAL5,SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL6,
DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL7,
SUM(leads_closed) OVER() BIM_GRAND_TOTAL8,
SUM(leads_converted) OVER() BIM_GRAND_TOTAL9
FROM
( select BIM_SALES_GROUP,VIEWBYID,leaf_node_flag,dir_flag,sum(prior_open) prior_open,sum(curr_open) curr_open,sum(curr_total) curr_total,
sum(leads_converted) leads_converted,sum(leads_new) leads_new,sum(leads_dead) leads_dead,sum(leads_closed) leads_closed,sum(curr_leads_changed) curr_leads_changed
FROM
(
/*********children of the selected category*********/
select /*+ ORDERED */
p.value BIM_SALES_GROUP,p.id VIEWBYID,p.leaf_node_flag leaf_node_flag,0 dir_flag,
SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
0 leads_converted,0 leads_new,0 leads_dead,0 leads_closed,SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id=&ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/*Others for sales group*/
select /*+ ORDERED */
p.value BIM_SALES_GROUP,p.id VIEWBYID,p.leaf_node_flag leaf_node_flag,0 dir_flag,0 prior_open,0 curr_open,0 curr_total,
sum(leads_converted) leads_converted,sum(leads_new) leads_new,sum(leads_dead)  leads_dead,sum(leads_closed) leads_closed,0  curr_leads_changed
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id=&ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/******Directly Assigned to Category*******/
select /*+ ORDERED */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,p.id VIEWBYID,''Y'' leaf_node_flag,1 dir_flag,
SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
0 leads_converted,0 leads_new,0 leads_dead,0 leads_closed,SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
    ,(SELECT e.id id,e.value value
        FROM eni_item_vbh_nodes_v e
       WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
         AND e.parent_id = e.child_id
         AND leaf_node_flag <> ''Y''
      ) p
WHERE
    b.group_id=&ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
and b.item_id = ''-1''
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id
UNION ALL
/*Others for sales group*/
select /*+ ORDERED */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,p.id VIEWBYID,''Y'' leaf_node_flag,1 dir_flag,
0 prior_open,0 curr_open,0 curr_total,sum(leads_converted) leads_converted,sum(leads_new) leads_new,sum(leads_dead)  leads_dead,sum(leads_closed) leads_closed,
0  curr_leads_changed
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,(SELECT e.id id,e.value value
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND e.parent_id = e.child_id
          AND leaf_node_flag <> ''Y''
       ) p
WHERE
    b.group_id=&ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
and b.item_id = ''-1''
AND b.resource_id = :l_resource_id
AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
GROUP BY p.value,p.id
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag,dir_flag
HAVING
sum(prior_open) > 0 OR sum(leads_new) > 0 OR sum(leads_converted) > 0 OR sum(leads_dead) > 0 OR sum(curr_open) > 0
OR sum(curr_total)-sum(curr_leads_changed) > 0 OR sum(leads_closed) > 0
) &ORDER_BY_CLAUSE';

         ELSE
/* Sales rep is passed from the page*/
            l_query :=
'SELECT BIM_SALES_GROUP VIEWBY,
    VIEWBYID,
    prior_open BIM_MEASURE1,leads_new BIM_MEASURE2,leads_converted BIM_MEASURE3,leads_dead BIM_MEASURE4,curr_open BIM_MEASURE5,
    curr_total-curr_leads_changed BIM_MEASURE6,leads_closed BIM_MEASURE8,DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_MEASURE7,
    leads_converted BIM_MEASURE9, NULL BIM_URL1,
    DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
    CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag=1 THEN NULL WHEN leads_new=0 THEN NULL ELSE '||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL3,
    CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag=1 THEN NULL WHEN leads_converted=0 THEN NULL ELSE '||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL4,
    CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag=1 THEN NULL WHEN leads_closed=0 THEN NULL ELSE '||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL5,
    CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag=1 THEN NULL WHEN curr_open= 0 THEN NULL ELSE'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL6,
    CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag=1 THEN NULL WHEN(curr_total-curr_leads_changed)= 0 THEN NULL
    ELSE '||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL7,
    SUM(prior_open) OVER() BIM_GRAND_TOTAL1,SUM(leads_new) OVER() BIM_GRAND_TOTAL2,SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
    SUM(leads_dead) OVER() BIM_GRAND_TOTAL4,SUM(curr_open) OVER() BIM_GRAND_TOTAL5,SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL6,
    DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL7,
    SUM(leads_closed) OVER() BIM_GRAND_TOTAL8,SUM(leads_converted) OVER() BIM_GRAND_TOTAL9
    FROM
    ( select BIM_SALES_GROUP,VIEWBYID,leaf_node_flag,dir_flag,sum(prior_open) prior_open,sum(curr_open) curr_open,sum(curr_total) curr_total,
    sum(leads_converted) leads_converted,sum(leads_new) leads_new,sum(leads_dead) leads_dead,sum(leads_closed) leads_closed,sum(curr_leads_changed) curr_leads_changed
    FROM
    ( select /*+ ORDERED */ p.value BIM_SALES_GROUP,p.id VIEWBYID,p.leaf_node_flag leaf_node_flag,0 dir_flag,
    SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
    SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
    SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
    0 leads_converted,0 leads_new,0 leads_dead,0 leads_closed,
    SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
    FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
         ,eni_denorm_hierarchies edh
         ,mtl_default_category_sets mdc
         ,(SELECT e.id,e.value,leaf_node_flag
             FROM eni_item_vbh_nodes_v e
            WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
          ) p
    WHERE
        b.group_id=:l_group_id
    AND b.product_category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdc.category_set_id
    AND mdc.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = p.id
    AND c.calendar_id=-1
    AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
    AND BITAND(c.record_type_id,1143)=c.record_type_id
    AND b.time_id=c.time_id
    AND b.period_type_id=c.period_type_id
    AND b.update_period_type_id = -1
    AND b.update_time_id = -1
    AND b.resource_id = :l_resource_id
    GROUP BY p.value,p.id,p.leaf_node_flag
    UNION ALL
    select /*+ ORDERED */ p.value BIM_SALES_GROUP,p.id VIEWBYID,p.leaf_node_flag leaf_node_flag,0 dir_flag,
    0 prior_open,0 curr_open,0 curr_total,sum(leads_converted) leads_converted,sum(leads_new) leads_new,
    sum(leads_dead)  leads_dead,sum(leads_closed) leads_closed,0  curr_leads_changed
    FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
         ,eni_denorm_hierarchies edh
   ,mtl_default_category_sets mdc
   ,(SELECT e.id,e.value,leaf_node_flag
       FROM eni_item_vbh_nodes_v e
      WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
        AND e.id = e.child_id
        AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
    ) p
    WHERE
        b.group_id=:l_group_id
    AND b.product_category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdc.category_set_id
    AND mdc.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = p.id
    AND c.calendar_id=-1
    AND c.report_date = &BIS_CURRENT_ASOF_DATE
    AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
    AND b.time_id=c.time_id
    AND b.period_type_id=c.period_type_id
    AND b.update_period_type_id = -1
    AND b.update_time_id = -1
    AND b.resource_id =:l_resource_id
    AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
    GROUP BY p.value,p.id,p.leaf_node_flag
    UNION ALL
    select /*+ ORDERED */
    bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
    p.id VIEWBYID,''Y'' leaf_node_flag,1     dir_flag,
    SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
    SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
    SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
    0 leads_converted,0 leads_new,0 leads_dead,0 leads_closed,SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
    FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
         ,(SELECT e.id id,e.value value
             FROM eni_item_vbh_nodes_v e
            WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
              AND e.parent_id = e.child_id
              AND leaf_node_flag <> ''Y''
          ) p
    WHERE
        b.group_id=:l_group_id
    AND p.id =  b.product_category_id
    AND c.calendar_id=-1
    AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
    AND BITAND(c.record_type_id,1143)=c.record_type_id
    AND b.time_id=c.time_id
    AND b.period_type_id=c.period_type_id
    AND b.update_period_type_id = -1
    AND b.update_time_id = -1
    and b.item_id = ''-1''
    AND b.resource_id =:l_resource_id
    GROUP BY p.value,p.id
    UNION ALL
    select /*+ ORDERED */
    bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
    p.id VIEWBYID,''Y'' leaf_node_flag,1     dir_flag,0 prior_open,0 curr_open,0 curr_total,
    sum(leads_converted) leads_converted,sum(leads_new) leads_new,sum(leads_dead)  leads_dead,
    sum(leads_closed) leads_closed,0  curr_leads_changed
    FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b
         ,(SELECT e.id id,e.value value
             FROM eni_item_vbh_nodes_v e
            WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
              AND e.parent_id = e.child_id
              AND leaf_node_flag <> ''Y''
          ) p
    WHERE
        b.group_id=:l_group_id
    AND p.id =  b.product_category_id
    AND c.calendar_id=-1
    AND c.report_date = &BIS_CURRENT_ASOF_DATE
    AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
    AND b.time_id=c.time_id
    AND b.period_type_id=c.period_type_id
    AND b.update_period_type_id = -1
    AND b.update_time_id = -1
    and b.item_id = ''-1''
    AND b.resource_id = :l_resource_id
    AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
    GROUP BY p.value,p.id
    )
    GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag,dir_flag
    HAVING  sum(prior_open) > 0 OR sum(leads_new) > 0 OR sum(leads_converted) > 0
    OR sum(leads_dead) > 0 OR sum(curr_open) > 0 OR sum(curr_total)-sum(curr_leads_changed) > 0 OR sum(leads_closed) > 0
    ) &ORDER_BY_CLAUSE';
    END IF;
      END IF;  /********Category All or non-all*************/

/* View by Lead Source*/
   ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN
      IF (l_category_id is null) THEN

   l_hint := ' /*+ leading(c) */ ';

   IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_a   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_a := ' BIM_I_LD_SRC_MV b,as_lookups d ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                  AND b.lead_Source =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id ';
        /* Third query */
        l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_c  :=  ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_c := ' BIM_I_LD_SRC_MV b , as_lookups d ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id= -1
                        AND b.update_period_type_id= -1
                        AND b.resource_id = :l_resource_id ';

         ELSE

          /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_b := ' BIM_I_LD_SRC_MV b,as_lookups d ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         /* Fourth query */
        l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_d   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_d := ' BIM_I_LD_SRC_MV b,as_lookups d ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id  ';
         END IF;
      ELSE
         l_hint := ' /*+ ORDERED */ ';

         IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_a   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_a := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
      AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
      AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
        /* Third query */
        l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_c  := '  decode(d.meaning,null,null,b.lead_source) ';
        l_tables_c := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_b := ' BIM_I_LP_SRC_MV b,as_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         /* Fourth query */
        l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_d   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_d := ' BIM_I_LP_SRC_MV b,as_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         END IF;
      END IF;
/* View by Lead Quality*/
   ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY') THEN
      IF (l_category_id is null) THEN
         l_hint := ' /*+ leading(c) */ ';

         IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_a   := ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_a := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id ';
        /* Third query */
        l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_c  :=  ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_c := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_b := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         /* Fourth query */
        l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_d   := ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_d := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         END IF;
      ELSE
         l_hint := ' /*+ ORDERED */ ';

         IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_a   := ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_a := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
        /* Third query */
        l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_c  := '  decode(d.meaning,null,null,b.lead_rank_id )';
        l_tables_c := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_b := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         /* Fourth query */
        l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_d   := ' decode(d.meaning,null,null,b.lead_rank_id ) ';
        l_tables_d := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.rank_id (+)= b.lead_rank_id
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         END IF;
      END IF;
/* View by Country*/
   ELSIF (l_view_by = 'GEOGRAPHY+COUNTRY') THEN
      IF (l_category_id is null) THEN
         l_hint := ' /*+ leading(c) */ ';

         IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_a   := ' decode(d.name,null,null,b.lead_country) ';
        l_tables_a := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id =:l_resource_id ';
        /* Third query */
        l_col1_c   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_c  :=  ' decode(d.name,null,null,b.lead_country) ';
        l_tables_c := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id ';
          ELSE
          /* Second query */
        l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_b   := '  decode(d.name,null,null,b.lead_country) ';
        l_tables_b := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         /* Fourth query */
        l_col1_d   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_d   := '  decode(d.name,null,null,b.lead_country) ';
        l_tables_d := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
          END IF;
      ELSE
         l_hint := ' /*+ ORDERED */ ';

   IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_a   := ' decode(d.name,null,null,b.lead_country) ';
        l_tables_a := ' BIM_I_LP_REGN_MV b,bis_countries_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
        /* Third query */
        l_col1_c   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_c  := '   decode(d.name,null,null,b.lead_country) ';
        l_tables_c := ' BIM_I_LP_REGN_MV b,bis_countries_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_b   := ' decode(d.name,null,null,b.lead_country) ';
        l_tables_b := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         /* Fourth query */
        l_col1_d   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_d   := ' decode(d.name,null,null,b.lead_country) ';
        l_tables_d := ' BIM_I_LP_REGN_MV b,bis_countries_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.country_code(+) = b.lead_country
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         END IF;
      END IF;
/* View by Sales Channel*/
   ELSIF (l_view_by = 'SALES CHANNEL+SALES CHANNEL') THEN
      IF (l_category_id is null) THEN
         l_hint := ' /*+ leading(c) */ ';

         IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_a   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_a := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SALES_CHANNEL''
                  AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id ';
        /* Third query */
        l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_c  :=  ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_c := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SALES_CHANNEL''
                  AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
          ELSE
          /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_b := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
        l_where_b  := ' AND b.group_id =:l_group_id
                        AND d.lookup_type(+) = ''SALES_CHANNEL''
                        AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id';
         /* Fourth query */
        l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_d   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_d := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.lookup_type(+) = ''SALES_CHANNEL''
                        AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         END IF;
      ELSE
         l_hint := ' /*+ ORDERED */ ';

   IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_a   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_a := ' BIM_I_LP_CHNL_MV b,so_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SALES_CHANNEL''
                        AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
      AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
        /* Third query */
        l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_c  := '  decode(d.meaning,null,null,b.channel_code) ';
        l_tables_c := ' BIM_I_LP_CHNL_MV b,so_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.lookup_type(+) = ''SALES_CHANNEL''
                  AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_b := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.lookup_type(+) = ''SALES_CHANNEL''
                        AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         /* Fourth query */
        l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_d   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_d := ' BIM_I_LP_CHNL_MV b,so_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
        l_where_d  := 'AND b.group_id=:l_group_id
                        AND d.lookup_type(+) = ''SALES_CHANNEL''
                  AND b.channel_code =d.lookup_code(+)
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         END IF;
      END IF;
/* View by Customer category*/
   ELSIF (l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN
      IF (l_category_id is null) THEN
         l_hint := ' /*+ leading(c) */ ';

          IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_a   := '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_a := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id ';
        /* Third query */
        l_col1_c   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_c  :=  '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_c := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_b   := '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_b := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
        l_where_b  := 'AND b.group_id = :l_group_id
                        AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id  ';
         /* Fourth query */
        l_col1_d   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_d   := '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_d := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id ';
         END IF;
      ELSE
         l_hint := ' /*+ ORDERED */ ';

   IF l_resource_id is null then
         /* First query */
        l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_a   := '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_a := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
        l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
      AND b.update_time_id=-1
                        AND b.update_period_type_id =-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
        /* Third query */
        l_col1_c   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_c  :=  '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_c := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
        l_where_c  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                  AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id = :l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         ELSE
          /* Second query */
        l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_b   := '  decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_b := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
        l_where_b  := ' AND b.group_id = :l_group_id
                        AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         /* Fourth query */
        l_col1_d   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_d   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_d := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
        l_where_d  := ' AND b.group_id=:l_group_id
                        AND d.customer_category_code (+) = b.cust_category
                        AND b.time_id=c.time_id
                        AND b.period_type_id=c.period_type_id
                        AND b.update_time_id=-1
                        AND b.update_period_type_id=-1
                        AND b.resource_id =:l_resource_id
                        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
      AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
         END IF;
      END IF;
   END IF; /*********Category or Sales Group*********/

-- ===================== Query Formation =============================
/* This is the dynamic query to be used with variables replaced*/
   IF (l_view_by <> 'ITEM+ENI_ITEM_VBH_CAT')  THEN
    /* This query is formed for sales group view by only */
      IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
          l_qry_sg :=
  ' UNION ALL
    SELECT  a.source_name BIM_SALES_GROUP,VIEWBYID,is_resource,prior_open,curr_open,curr_total,
     leads_converted,leads_new,leads_dead,leads_closed,curr_leads_changed  from  (
  /*Prior Open and Current Open for reps*/
  SELECT '||l_hint||' '||l_col1_b||' resource_id,
  '||l_col2_b||' VIEWBYID,
  '||l_col3_b||' is_resource,
  SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
  0 leads_converted,
  0 leads_new,
  0 leads_dead,
  0 leads_closed,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c,  '|| l_tables_b|| '
  WHERE c.calendar_id=-1
  AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
  AND BITAND(c.record_type_id,1143)=c.record_type_id
  '||l_where_b||'
  GROUP BY '||l_col1_b||','||l_col2_b||','||l_col3_b||'
  UNION ALL
  /*Others for reps*/
  SELECT '||l_hint||' '||l_col1_d||' BIM_SALES_GROUP,
         '||l_col2_d||' VIEWBYID,
         '||l_col3_d||' is_resource,
  0 prior_open,
  0 curr_open,
  0 curr_total,
  sum(b.leads_converted) leads_converted,
  sum(b.leads_new) leads_new,
  sum(b.leads_dead)  leads_dead,
  sum(b.leads_closed) leads_closed,
  0  curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c, '|| l_tables_d|| '
  WHERE c.calendar_id=-1
  AND c.report_date = &BIS_CURRENT_ASOF_DATE
  AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
  AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
  '||l_where_d||'
  GROUP BY'||l_col1_d||','||l_col2_d||','||l_col3_d ||'
  ) q ,JTF_RS_RESOURCE_EXTNS_VL a where q.resource_id=a.resource_id ';

 END IF;

      IF l_resource_id is null THEN

  /* This query needs to be executed in case if Sales Rep is not passed */
  l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
  VIEWBYID,
  prior_open BIM_MEASURE1,
  leads_new BIM_MEASURE2,
  leads_converted BIM_MEASURE3,
  leads_dead BIM_MEASURE4,
  curr_open BIM_MEASURE5,
  (curr_total-curr_leads_changed) BIM_MEASURE6,
  leads_closed BIM_MEASURE8,
  DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_MEASURE7,
  leads_converted BIM_MEASURE9,
  DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_URL1,
  NULL BIM_URL2,
  decode(VIEWBYID,null,null,decode(leads_new,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,null,null,decode(leads_converted,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,null,null,decode(leads_closed,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,null,null,decode(curr_open,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,null,null,decode((curr_total-curr_leads_changed),0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  SUM(prior_open) OVER() BIM_GRAND_TOTAL1,
  SUM(leads_new) OVER() BIM_GRAND_TOTAL2,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
  SUM(leads_dead) OVER() BIM_GRAND_TOTAL4,
  SUM(curr_open) OVER() BIM_GRAND_TOTAL5,
  SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL6,
  DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL7,
  SUM(leads_closed) OVER() BIM_GRAND_TOTAL8,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL9
  FROM
  (
  select BIM_SALES_GROUP,
  VIEWBYID,
  is_resource,
  sum(prior_open) prior_open,
  sum(curr_open) curr_open,
  sum(curr_total) curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead) leads_dead,
  sum(leads_closed) leads_closed,
  sum(curr_leads_changed) curr_leads_changed
  FROM
  ( ';

   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
    l_query :=l_query ||' SELECT  d.group_name BIM_SALES_GROUP,VIEWBYID,is_resource,prior_open,curr_open,curr_total,
    leads_converted,leads_new,leads_dead,leads_closed,curr_leads_changed  from  ( ';
   end if;

  l_query :=l_query ||' select '||l_hint||'
  '||l_col1_a||' BIM_SALES_GROUP,
  to_char( '||l_col2_a||' ) VIEWBYID,
  '||l_col3_a||' is_resource,
  SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE -1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
  0 leads_converted,
  0 leads_new,
  0 leads_dead,
  0 leads_closed,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c,'|| l_tables_a|| '
  WHERE c.calendar_id=-1
  AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
  AND BITAND(c.record_type_id,1143)=c.record_type_id
  '||l_where_a||'
  GROUP BY '||l_col1_a||','||l_col2_a||','||l_col3_a||'
  UNION ALL
  /*Others for sales group*/
  select '||l_hint||'
  '||l_col1_c||' BIM_SALES_GROUP,
  to_char(   '||l_col2_c||' ) VIEWBYID,
  '||l_col3_c||' is_resource,
  0 prior_open,
  0 curr_open,
  0 curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead)  leads_dead,
  sum(leads_closed) leads_closed,
  0  curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c,'|| l_tables_c|| '
  WHERE c.calendar_id=-1
  AND c.report_date = &BIS_CURRENT_ASOF_DATE
  AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
  AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
  '||l_where_c||'
  GROUP BY '||l_col1_c||','||l_col2_c||','||l_col3_c;

  IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
    l_query :=l_query ||' )q ,jtf_rs_groups_tl d
    where q.BIM_SALES_GROUP=d.group_id AND d.language=USERENV(''LANG'')'||l_qry_sg ;
  end if;

  l_query :=l_query ||'  )
  GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
  HAVING
  sum(prior_open) > 0
  OR sum(leads_new) > 0
  OR sum(leads_converted) > 0
  OR sum(leads_dead) > 0
  OR sum(curr_open) > 0
  OR sum(curr_total)-sum(curr_leads_changed) > 0
  OR sum(leads_closed) > 0
  )
  &ORDER_BY_CLAUSE';

      ELSE
         l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
  VIEWBYID,
  prior_open BIM_MEASURE1,
  leads_new BIM_MEASURE2,
  leads_converted BIM_MEASURE3,
  leads_dead BIM_MEASURE4,
  curr_open BIM_MEASURE5,
  (curr_total-curr_leads_changed) BIM_MEASURE6,
  leads_closed BIM_MEASURE8,
  leads_converted BIM_MEASURE9,
  DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_URL1,
  NULL BIM_URL2,
  decode(VIEWBYID,null,null,decode(leads_new,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,null,null,decode(leads_converted,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,null,null,decode(leads_closed,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,null,null,decode(curr_open,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,null,null,decode((curr_total-curr_leads_changed),0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_MEASURE7,
  SUM(prior_open) OVER() BIM_GRAND_TOTAL1,
  SUM(leads_new) OVER() BIM_GRAND_TOTAL2,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
  SUM(leads_dead) OVER() BIM_GRAND_TOTAL4,
  SUM(curr_open) OVER() BIM_GRAND_TOTAL5,
  SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL6,
  DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL7,
  SUM(leads_closed) OVER() BIM_GRAND_TOTAL8,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL9
  FROM
  (
  select ';
  IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
    l_query :=l_query||'a.source_name BIM_SALES_GROUP,';
  else
    l_query :=l_query||'BIM_SALES_GROUP,';
  end if;
  l_query :=l_query||'VIEWBYID,
  is_resource,
  sum(prior_open) prior_open,
  sum(curr_open) curr_open,
  sum(curr_total) curr_total,
  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,
  sum(leads_dead) leads_dead,
  sum(leads_closed) leads_closed,
  sum(curr_leads_changed) curr_leads_changed
  FROM
  (     /*Prior Open and Current Open for reps*/
  SELECT '||l_hint||' '||l_col1_b||' BIM_SALES_GROUP,
  to_char( '||l_col2_b||' ) VIEWBYID,
  '||l_col3_b||' is_resource,
  b.resource_id resource_id,
  SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,
  0 leads_converted,
  0 leads_new,
  0 leads_dead,
  0 leads_closed,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c,  '|| l_tables_b|| '
  WHERE c.calendar_id=-1
  AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
  AND BITAND(c.record_type_id,1143)=c.record_type_id
  '||l_where_b||'
  GROUP BY '||l_col1_b||','||l_col2_b||','||l_col3_b||' ,b.resource_id
  UNION ALL
  /*Others for reps*/
  SELECT '||l_hint||' '||l_col1_d||' BIM_SALES_GROUP,
         to_char( '||l_col2_d||' ) VIEWBYID,
         '||l_col3_d||' is_resource,
   b.resource_id resource_id,
  0 prior_open,
  0 curr_open,
  0 curr_total,
  sum(b.leads_converted) leads_converted,
  sum(b.leads_new) leads_new,
  sum(b.leads_dead)  leads_dead,
  sum(b.leads_closed) leads_closed,
  0  curr_leads_changed
  FROM FII_TIME_RPT_STRUCT c, '|| l_tables_d|| '
  WHERE c.calendar_id=-1
  AND c.report_date = &BIS_CURRENT_ASOF_DATE
  AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
  AND ( leads_converted <> 0 or leads_new <> 0 or leads_dead <> 0 or leads_closed <> 0 )
  '||l_where_d||'
  GROUP BY'||l_col1_d||','||l_col2_d||','||l_col3_d||',b.resource_id
  ) q,JTF_RS_RESOURCE_EXTNS_VL a where
  q.resource_id=a.resource_id
  GROUP BY ';
  IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
    l_query :=l_query||'a.source_name ,';
  else
    l_query :=l_query||'BIM_SALES_GROUP,';
  end if;
 l_query :=l_query||'VIEWBYID,is_resource
  HAVING
  sum(prior_open) > 0
  OR sum(leads_new) > 0
  OR sum(leads_converted) > 0
  OR sum(leads_dead) > 0
  OR sum(curr_open) > 0
  OR sum(curr_total)-sum(curr_leads_changed) > 0
  OR sum(leads_closed) > 0
  )
  &ORDER_BY_CLAUSE';
      END IF;
   END IF;

   END IF;

   /* Earlier l_resource_id was hardcoded to -1 ,to enable binding below code was added */

   IF l_resource_id is null then
      l_resource_id:= -1;
   END IF;



  x_custom_sql := l_query;

  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_seq_date';
  l_custom_rec.attribute_value := to_char(l_seq_date,'DD-MON-YY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;


  l_custom_rec.attribute_name := ':g_start_date';
  l_custom_rec.attribute_value := TO_CHAR(G_START_DATE,'MM-DD-YYYY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;


   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
   END;



PROCEDURE GET_LEAD_CONV_P_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_error_msg varchar2(4000);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_resource_id VARCHAR2(20);
      l_query VARCHAR2(20000);
      l_url_str   VARCHAR2(1000);
      l_curr VARCHAR2(50);
      l_curr_suffix VARCHAR2(50);

      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
/* Local varaibles to be initiated accordingly*/

/* First query */
l_col1_a   VARCHAR2(200) ;
l_col2_a   VARCHAR2(200) ;
l_col3_a   VARCHAR2(200) ;
l_tables_a VARCHAR2(500);
l_where_a  VARCHAR2(1000);

/* Second query */
l_col1_b   VARCHAR2(200) ;
l_col2_b   VARCHAR2(200) ;
l_col3_b   VARCHAR2(200) ;
l_tables_b VARCHAR2(500);
l_where_b  VARCHAR2(1000);

/* Third query */
l_col1_c   VARCHAR2(200) ;
l_col2_c   VARCHAR2(200) ;
l_col3_c   VARCHAR2(200) ;
l_tables_c VARCHAR2(500);
l_where_c  VARCHAR2(1000);

/* Fourth query */
l_col1_d   VARCHAR2(200) ;
l_col2_d   VARCHAR2(200) ;
l_col3_d   VARCHAR2(200) ;
l_tables_d VARCHAR2(500);
l_where_d  VARCHAR2(1000);

/* Fifth query */
l_col1_e   VARCHAR2(200) ;
l_col2_e   VARCHAR2(200) ;
l_col3_e   VARCHAR2(200) ;
l_tables_e VARCHAR2(500);
l_where_e  VARCHAR2(1000);

/* Sixth query */
l_col1_f   VARCHAR2(200) ;
l_col2_f   VARCHAR2(200) ;
l_col3_f   VARCHAR2(200) ;
l_tables_f VARCHAR2(500);
l_where_f  VARCHAR2(1000);

l_sg_table VARCHAR2(500);
l_sg_and   VARCHAR2(500);
l_hint     VARCHAR2(100);
l_camp_id VARCHAR2(100);
l_close_rs   VARCHAR2(500);
l_context       VARCHAR2(5000);

  /* Start of the PL/SQL Block */

   BEGIN
   l_col3_a   := '0';
   l_col3_b   := '0';
   l_col3_c   := '0';
   l_col3_e   := '0';
   l_col3_f   := '0';
      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

      get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
		 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date        => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id        => l_curr_page_time_id,
		 p_prev_page_time_id        => l_prev_page_time_id,
		 l_view_by                 =>  l_view_by,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );
      get_currency(p_page_parameter_tbl     =>p_page_parameter_tbl,
                 l_currency             => l_curr);
IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;

      l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
      l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';

      l_url_str:='pFunctionName=BIM_I_LEAD_CONVERSION_P_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';

IF l_org_sg is null THEN
   l_query := 'SELECT
NULL VIEWBY,
NULL VIEWBYID,
NULL BIM_MEASURE1,
NULL BIM_MEASURE2,
NULL BIM_MEASURE3,
NULL BIM_MEASURE4,
NULL BIM_MEASURE5,
NULL BIM_MEASURE6,
NULL BIM_MEASURE8,
NULL BIM_MEASURE7,
NULL BIM_MEASURE9,
NULL BIM_URL1,
NULL BIM_URL2,
NULL BIM_URL3,
NULL BIM_URL4,
NULL BIM_URL5,
NULL BIM_URL6,
NULL BIM_URL7,
NULL BIM_GRAND_TOTAL1,
NULL BIM_GRAND_TOTAL2,
NULL BIM_GRAND_TOTAL3,
NULL BIM_GRAND_TOTAL4,
NULL BIM_GRAND_TOTAL5,
NULL BIM_GRAND_TOTAL6,
NULL bim_GRAND_TOTAL7,
NULL bim_GRAND_TOTAL8,
NULL bim_GRAND_TOTAL9
FROM dual ';

x_custom_sql := l_query;

ELSE

/* View By Sales Group */

      IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
         if (l_category_id is null) then
            l_sg_table := ' bil_bi_opty_g_mv b ';
            l_sg_and   := NULL;
	    l_hint := ' /*+ leading(c) */ ';
   /* Start assigning the local variables to be substituted in the query */
            IF l_resource_id is null then

	/* First query */
	l_col1_a   := ' b.group_id ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_a  := '
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
	l_col1_b   := ' d.group_name ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LD_GEN_SG_MV b,jtf_rs_groups_tl d ';
	l_where_b  := ' AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Third query */
	l_col1_c   := ' b.resource_id ';
	l_col2_c   := ' b.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_c  := '
	AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id <> :l_resource_id ';

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id <> :l_resource_id ';

	/* Fifth query */
	l_col1_e   := ' b.group_id ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_e  := '
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Sixth query */
	l_col1_f   := ' b.resource_id ';
	l_col2_f   := ' b.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_f  := '
	AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id <> :l_resource_id ';
            ELSE
	/* Third query */
	l_col1_c   := ' b.resource_id ';
	l_col2_c   := ' b.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_c  := '
	AND b.group_id = :l_group_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Sixth query */
	l_col1_f   := ' b.resource_id ';
	l_col2_f   := ' b.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_f  := '
	AND b.group_id = :l_group_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

         END IF;

      ELSE
         l_sg_table := ' bil_bi_opty_pg_mv b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
         l_sg_and   := ' and b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';
         --l_hint := ' /*+ ORDERED */ ';
         l_hint := ' /*+ leading(c) */ ';

         IF l_resource_id is null then
	/* First query */
	l_col1_a   := ' b.group_id ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_a  := '
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
	l_col1_b   := ' d.group_name ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LP_GEN_SG_MV b,jtf_rs_groups_tl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_b  := ' AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

	/* Third query */
	l_col1_c   := ' b.resource_id ';
	l_col2_c   := ' b.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_c  := '
	AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id <> :l_resource_id ';

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id <> :l_resource_id  ';

	/* Fifth query */
	l_col1_e   := ' b.group_id ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_e  := '
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

	/* Sixth query */
	l_col1_f   := ' b.resource_id ';
	l_col2_f   := ' b.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := '
	AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id <> :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

         ELSE

	/* Third query */
	l_col1_c   := ' b.resource_id ';
	l_col2_c   := ' b.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_c  := '
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;


	/* Sixth query */
	l_col1_f   := ' b.resource_id ';
	l_col2_f   := ' b.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := '
	AND b.group_id = :l_group_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

         END IF;
      end if;

/* View by Category*/

   ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN

      IF (l_category_id is null) THEN
         /* If Only group is selected and rep is not selected */
         IF (l_resource_id is null) THEN

            l_query :=
'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       oppt_amt BIM_ATTRIBUTE1,
       decode(prev_oppt_amt,0,NULL,((oppt_amt - prev_oppt_amt)/prev_oppt_amt)*100) BIM_ATTRIBUTE2,
       leads_converted BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       NULL BIM_ATTRIBUTE13,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
       oppt_amt BIM_ATTRIBUTE16,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE17,
       SUM(oppt_amt) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_oppt_amt) over(),0,NULL,(sum(oppt_amt - prev_oppt_amt) over()/sum(prev_oppt_amt) over())*100) BIM_GRAND_TOTAL2,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL5
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(oppt_amt) oppt_amt,
sum(prev_oppt_amt) prev_oppt_amt,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted
FROM
(
SELECT /*+ leading(c) */
	p.value BIM_SALES_GROUP,
	p.parent_id VIEWBYID,
	p.leaf_node_flag leaf_node_flag,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
          FROM eni_item_vbh_nodes_v e
         WHERE e.top_node_flag=''Y''
           AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
WHERE b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id =:l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
	p.value BIM_SALES_GROUP,
	p.parent_id VIEWBYID,
	p.leaf_node_flag leaf_node_flag,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
	0 leads_converted,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
          FROM eni_item_vbh_nodes_v e
         WHERE e.top_node_flag=''Y''
           AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
WHERE b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id =:l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
HAVING sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
UNION ALL/* For Opportunities from Sales MVs*/
SELECT /*+ leading(c) */ p.value BIM_SALES_GROUP,p.parent_id VIEWBYID,p.leaf_node_flag leaf_node_flag,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,
0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c, bil_bi_opty_pg_mv f
     ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
          FROM eni_item_vbh_nodes_v e
         WHERE e.top_node_flag=''Y''
           AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
WHERE f.effective_time_id=c.time_id
AND f.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND f.effective_period_type_id=c.period_type_id
--AND f.salesrep_id is null
AND f.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(oppt_amt) > 0
OR sum(prev_oppt_amt) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
)';
         ELSE
            /* If Only rep is selected */
            l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       oppt_amt BIM_ATTRIBUTE1,
       decode(prev_oppt_amt,0,NULL,((oppt_amt - prev_oppt_amt)/prev_oppt_amt)*100) BIM_ATTRIBUTE2,
       leads_converted BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       NULL BIM_ATTRIBUTE13,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
       oppt_amt BIM_ATTRIBUTE16,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE17,
       SUM(oppt_amt) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_oppt_amt) over(),0,NULL,(sum(oppt_amt - prev_oppt_amt) over()/sum(prev_oppt_amt) over())*100) BIM_GRAND_TOTAL2,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL5
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(oppt_amt) oppt_amt,
sum(prev_oppt_amt) prev_oppt_amt,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted
FROM
(
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
          FROM eni_item_vbh_nodes_v e
         WHERE e.top_node_flag=''Y''
           AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
WHERE b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
	p.value BIM_SALES_GROUP,
        p.parent_id VIEWBYID,
        p.leaf_node_flag leaf_node_flag,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
	0 leads_converted,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b
     ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
          FROM eni_item_vbh_nodes_v e
         WHERE e.top_node_flag=''Y''
           AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
WHERE b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
HAVING sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
UNION ALL /* For Oppt from Sales MV*/
SELECT /*+ leading(c) */
p.value BIM_SALES_GROUP,
p.parent_id VIEWBYID,
p.leaf_node_flag leaf_node_flag,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,
0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c, bil_bi_opty_pg_mv f
     , ( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
           FROM eni_item_vbh_nodes_v e
          WHERE e.top_node_flag=''Y''
            AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
WHERE f.effective_time_id=c.time_id
AND f.parent_sales_group_id = :l_group_id
AND f.effective_period_type_id=c.period_type_id
AND f.salesrep_id = :l_resource_id
AND f.product_category_id=edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
GROUP BY  p.value,p.parent_id,p.leaf_node_flag
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(oppt_amt) > 0
OR sum(prev_oppt_amt) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
)';
         END IF;
      ELSE
/*Catgeory not equal to all*/

      /* If Only group is selected and rep is not selected */
         IF (l_resource_id is null) THEN

            l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       oppt_amt BIM_ATTRIBUTE1,
       decode(prev_oppt_amt,0,NULL,((oppt_amt - prev_oppt_amt)/prev_oppt_amt)*100) BIM_ATTRIBUTE2,
       leads_converted BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       NULL BIM_ATTRIBUTE13,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
       oppt_amt BIM_ATTRIBUTE16,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE17,
       SUM(oppt_amt) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_oppt_amt) over(),0,NULL,(sum(oppt_amt - prev_oppt_amt) over()/sum(prev_oppt_amt) over())*100) BIM_GRAND_TOTAL2,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL5
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(oppt_amt) oppt_amt,
sum(prev_oppt_amt) prev_oppt_amt,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted
FROM
(
/*********children of the selected category*********/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
        p.value BIM_SALES_GROUP,
        p.id VIEWBYID,
        p.leaf_node_flag leaf_node_flag,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
	0 leads_converted,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
HAVING sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
UNION ALL
/******Directly Assigned to Category*******/
SELECT /*+ leading(c) */
       bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y'' leaf_node_flag,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,(SELECT e.id id,e.value value
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND e.parent_id = e.child_id
          AND leaf_node_flag <> ''Y''
       ) p
WHERE b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id =:l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
UNION ALL
select /*+ leading(c) */
       bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
        p.id VIEWBYID,
         ''Y''  leaf_node_flag,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
	0 leads_converted,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,(SELECT e.id id,e.value value
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND e.parent_id = e.child_id
          AND leaf_node_flag <> ''Y''
       ) p
WHERE b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id =:l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
HAVING sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
UNION ALL /* For Oppt from Sales MV*/
SELECT /*+ leading(c) */
p.value BIM_SALES_GROUP,
p.id VIEWBYID,
p.leaf_node_flag leaf_node_flag,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,
0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c, bil_bi_opty_pg_mv f
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE f.effective_time_id=c.time_id
AND f.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND f.effective_period_type_id=c.period_type_id
AND f.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
GROUP BY  p.value,p.id,p.leaf_node_flag
UNION ALL/******Directly Assigned to Category*******/
SELECT /*+ leading(c) */
 bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
 p.id VIEWBYID,
 ''Y''  leaf_node_flag,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,
0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c, bil_bi_opty_pg_mv f
     , (SELECT e.id id,e.value value
          FROM eni_item_vbh_nodes_v e
         WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
           AND e.parent_id = e.child_id
           AND leaf_node_flag <> ''Y''
     ) p
WHERE f.effective_time_id=c.time_id
AND f.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND f.effective_period_type_id=c.period_type_id
--AND f.salesrep_id is null
AND f.product_category_id=p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
GROUP BY p.value,p.id
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(oppt_amt) > 0
OR sum(prev_oppt_amt) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
)';

         ELSE
         /* If Only rep is selected */
            l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       oppt_amt BIM_ATTRIBUTE1,
       decode(prev_oppt_amt,0,NULL,((oppt_amt - prev_oppt_amt)/prev_oppt_amt)*100) BIM_ATTRIBUTE2,
       leads_converted BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       NULL BIM_ATTRIBUTE13,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
       oppt_amt BIM_ATTRIBUTE16,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE17,
       SUM(oppt_amt) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_oppt_amt) over(),0,NULL,(sum(oppt_amt - prev_oppt_amt) over()/sum(prev_oppt_amt) over())*100) BIM_GRAND_TOTAL2,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL5
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(oppt_amt) oppt_amt,
sum(prev_oppt_amt) prev_oppt_amt,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted
FROM
(
/*********children of the selected category*********/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
select  /*+ leading(c) */
        p.value BIM_SALES_GROUP,
        p.id VIEWBYID,
        p.leaf_node_flag leaf_node_flag,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
	0 leads_converted,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(SELECT e.id,e.value,leaf_node_flag
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
HAVING sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/******Directly Assigned to Category*******/
SELECT /*+ leading(c) */
       bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y'' leaf_node_flag,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,(SELECT e.id id,e.value value
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND e.parent_id = e.child_id
          AND leaf_node_flag <> ''Y''
       ) p
WHERE b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
UNION ALL
select  /*+ leading(c) */
       bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
        p.id VIEWBYID,
        ''Y'' leaf_node_flag,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
	0 leads_converted,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b
     ,(SELECT e.id id,e.value value
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND e.parent_id = e.child_id
          AND leaf_node_flag <> ''Y''
       ) p
WHERE b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
HAVING sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
UNION ALL /*********children of the selected category*********/
SELECT /*+ leading(c) */
 p.value BIM_SALES_GROUP,
 p.id VIEWBYID,
 p.leaf_node_flag leaf_node_flag,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,
0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c, bil_bi_opty_pg_mv f
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets mdc
     ,(select e.id,e.value,leaf_node_flag
         from eni_item_vbh_nodes_v e
        where e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
          AND e.id = e.child_id
          AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE f.effective_time_id=c.time_id
AND f.parent_sales_group_id = :l_group_id
AND f.effective_period_type_id=c.period_type_id
AND f.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id AND f.salesrep_id = :l_resource_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL /******Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
p.id VIEWBYID,
''Y'' leaf_node_flag,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0))  prev_oppt_amt,
0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c, bil_bi_opty_pg_mv f
     ,(SELECT e.id id,e.value value
         FROM eni_item_vbh_nodes_v e
        WHERE e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND e.parent_id = e.child_id
          AND leaf_node_flag <> ''Y''
       ) p
WHERE f.effective_time_id=c.time_id
AND f.parent_sales_group_id = :l_group_id
AND f.effective_period_type_id=c.period_type_id
AND f.product_category_id=p.id
AND f.salesrep_id = :l_resource_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
GROUP BY p.value,p.id
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(oppt_amt) > 0
OR sum(prev_oppt_amt) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
)';
         END IF;
      END IF;  /********All or non-all*************/

   END IF; /*********Category or Sales Group*********/

-- ===================== Query Formation =============================
/* This is the dynamic query to be used with variables replaced*/
   IF (l_view_by <> 'ITEM+ENI_ITEM_VBH_CAT')  THEN
      IF l_resource_id is null THEN
/* This query needs to be executed in case if Sales Rep is not passed */
         l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       oppt_amt BIM_ATTRIBUTE1,
       decode(prev_oppt_amt,0,NULL,((oppt_amt - prev_oppt_amt)/prev_oppt_amt)*100) BIM_ATTRIBUTE2,
       leads_converted BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE13,
       NULL BIM_ATTRIBUTE15,
       oppt_amt BIM_ATTRIBUTE16,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE17,
       SUM(oppt_amt) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_oppt_amt) over(),0,NULL,(sum(oppt_amt - prev_oppt_amt) over()/sum(prev_oppt_amt) over())*100) BIM_GRAND_TOTAL2,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL5
FROM
(
SELECT
BIM_SALES_GROUP,
VIEWBYID,
is_resource,
sum(oppt_amt) oppt_amt,
sum(prev_oppt_amt) prev_oppt_amt,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted
FROM
(

select  d.group_name BIM_SALES_GROUP,VIEWBYID,is_resource,oppt_amt,prev_oppt_amt,
        leads_new,leads_converted, conversion_time,prev_open,prev_lead_converted
     from   (

SELECT '||l_hint||'
       '||l_col1_a||' group_id,
       to_char( '||l_col2_a||' ) VIEWBYID,
       '||l_col3_a||' is_resource,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c , jtf_rs_groups_denorm den, '|| l_tables_a|| '
WHERE den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
       and den.group_id=b.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_a||'
GROUP BY '||l_col1_a||','||l_col2_a||','||l_col3_a||'
/*prior open*/
UNION ALL
select '||l_hint||'
       '||l_col1_e||' group_id,
       to_char( '||l_col2_e||' ) VIEWBYID,
       '||l_col3_e||' is_resource,
        0 oppt_amt,
        0 prev_oppt_amt,
        0 leads_new,
        0 leads_converted,
        0 conversion_time,
        sum(b.leads - (leads_closed+leads_dead+leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, jtf_rs_groups_denorm den, '|| l_tables_e|| '
WHERE den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
       and den.group_id=b.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_e||'
GROUP BY '||l_col1_e||','||l_col2_e||','||l_col3_e||'
HAVING sum(b.leads-(leads_closed+leads_dead+leads_converted)) <> 0
UNION ALL/* For Oppurtunity Info from Sales MVs*/

SELECT /*+ leading(c) */ b.sales_group_id group_id ,to_char(b.sales_group_id),0,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c , '||l_sg_table||'
WHERE c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.effective_time_id =c.time_id
AND b.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.effective_period_type_id=c.period_type_id
AND b.salesrep_id is null
 '||l_sg_and||'
GROUP BY b.sales_group_id,b.sales_group_id,0
----
) q, jtf_rs_groups_tl d where
 q.group_id=d.group_id
AND d.language=USERENV(''LANG'')
---------------------------------------------------------------
UNION ALL
-----------------------------------------------------------------
/* Leads Converted for reps*/

select  d.source_name BIM_SALES_GROUP,VIEWBYID,is_resource,oppt_amt,prev_oppt_amt,
        leads_new,leads_converted, conversion_time,prev_open,prev_lead_converted
        from (
 SELECT '||l_hint||'
       '||l_col1_c||' resource_id,
       to_char( '||l_col2_c||' ) VIEWBYID,
       '||l_col3_c||' is_resource,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c , '|| l_tables_C|| '
WHERE c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_c||'
GROUP BY '||l_col1_c||','||l_col2_c||','||l_col3_c||'
UNION ALL
/* prior Open for reps*/
SELECT '||l_hint||'
       '||l_col1_f||' resource_id,
       to_char( '||l_col2_f||' ) VIEWBYID,
       '||l_col3_f||' is_resource,
        0 oppt_amt,
        0 prev_oppt_amt,
	0 leads_new,
        0 leads_converted,
        0 conversion_time,
        sum(b.leads - (leads_closed+leads_dead+leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c , '|| l_tables_f|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_f||'
GROUP BY '||l_col1_f||','||l_col2_f||','||l_col3_f||'
HAVING sum(b.leads-(leads_closed+leads_dead+leads_converted)) <> 0
UNION ALL/* For Reps*/
SELECT /*+ leading(c) */ b.salesrep_id resource_id,to_char(b.salesrep_id||''.''||b.sales_group_id),1,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c , '||l_sg_table||'
WHERE c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.effective_time_id=c.time_id
AND b.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.effective_period_type_id=c.period_type_id
AND b.salesrep_id is not null '||l_sg_and||'
GROUP BY b.salesrep_id,b.salesrep_id||''.''||b.sales_group_id,1
----
) q, JTF_RS_RESOURCE_EXTNS_VL d where
q.resource_id=d.resource_id

)
GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open) > 0
OR sum(oppt_amt) > 0
OR sum(prev_oppt_amt) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
 ) ';

ELSE
/* This query needs to be executed in case if Sales Rep is passed */

l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       oppt_amt BIM_ATTRIBUTE1,
       decode(prev_oppt_amt,0,NULL,((oppt_amt - prev_oppt_amt)/prev_oppt_amt)*100) BIM_ATTRIBUTE2,
       leads_converted BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE13,
       NULL BIM_ATTRIBUTE15,
       oppt_amt BIM_ATTRIBUTE16,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE17,
       SUM(oppt_amt) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_oppt_amt) over(),0,NULL,(sum(oppt_amt - prev_oppt_amt) over()/sum(prev_oppt_amt) over())*100) BIM_GRAND_TOTAL2,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL5
FROM
(
SELECT
d.source_name BIM_SALES_GROUP,
VIEWBYID,
is_resource,
sum(oppt_amt) oppt_amt,
sum(prev_oppt_amt) prev_oppt_amt,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted
FROM
(
/* Leads Converted for reps*/

 SELECT '||l_hint||'
       '||l_col1_c||' resource_id,
       to_char( '||l_col2_c||' ) VIEWBYID,
       '||l_col3_c||' is_resource,
       0 oppt_amt,
       0 prev_oppt_amt,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted
FROM FII_TIME_RPT_STRUCT c, '|| l_tables_c|| '
WHERE c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_c||'
GROUP BY '||l_col1_c||','||l_col2_c||','||l_col3_c||'
/* Previous */
UNION ALL
/* prior Open for reps*/
SELECT '||l_hint||'
       '||l_col1_f||' resource_id,
       to_char( '||l_col2_f||' ) VIEWBYID,
       '||l_col3_f||' is_resource,
        0 oppt_amt,
        0 prev_oppt_amt,
        0 leads_new,
        0 leads_converted,
        0 conversion_time,
        sum(b.leads - (leads_closed+leads_dead+leads_converted)) prev_open,
	0 prev_lead_converted
FROM FII_TIME_RPT_STRUCT c ,  '|| l_tables_f|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_f||'
GROUP BY '||l_col1_f||','||l_col2_f||','||l_col3_f||'
having sum(b.leads - (leads_closed+leads_dead+leads_converted)) <> 0
       or sum(leads_converted) <> 0
UNION ALL /* For Oppurtunity Info from Sales MVs*/
/* For Reps*/
SELECT /*+ leading(c) */ b.salesrep_id resource_id,to_char(b.salesrep_id||''.''||b.sales_group_id),1,
sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) oppt_amt,
sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,cnv_opty_amt'||l_curr_suffix||',0)) prev_oppt_amt,0,0,0,0,0
FROM FII_TIME_RPT_STRUCT c ,  '||l_sg_table||'
WHERE b.effective_time_id=c.time_id
AND b.parent_sales_group_id = :l_group_id
AND b.effective_period_type_id=c.period_type_id
AND b.salesrep_id is not null
AND b.salesrep_id = :l_resource_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id '||l_sg_and||'
GROUP BY b.salesrep_id,b.salesrep_id||''.''||b.sales_group_id,1
)q,
JTF_RS_RESOURCE_EXTNS_VL d where
q.resource_id=d.resource_id
GROUP BY d.source_name,VIEWBYID,is_resource
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open) > 0
OR sum(oppt_amt) > 0
OR sum(prev_oppt_amt) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
 ) ';

END IF;
END IF;


 /* Earlier l_resource_id was hardcoded to -1 ,to enable binding below code was added */

   IF l_resource_id is null then
      l_resource_id:= -1;
   END IF;


-- ========================================================================
  x_custom_sql := l_query||'&ORDER_BY_CLAUSE';
  END IF;


  /*l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_KEY;
  l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_CUSTOM_OUTPUT.COUNT) := l_custom_rec;
*/

  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


    EXCEPTION
   WHEN others THEN

      l_error_msg := SQLERRM;

  END;

PROCEDURE GET_LEAD_CONV_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_error_msg varchar2(4000);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_resource_id VARCHAR2(20);
      l_query VARCHAR2(20000);
      l_url_str VARCHAR2(1000);

      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
/* Local varaibles to be initiated accordingly*/

/* First query */
l_col1_a   VARCHAR2(200) ;
l_col2_a   VARCHAR2(200) ;
l_col3_a   VARCHAR2(200) ;
l_tables_a VARCHAR2(500);
l_where_a  VARCHAR2(1000);

/* Second query */
l_col1_b   VARCHAR2(200) ;
l_col2_b   VARCHAR2(200) ;
l_col3_b   VARCHAR2(200) ;
l_tables_b VARCHAR2(500);
l_where_b  VARCHAR2(1000);

/* Third query */
l_col1_c   VARCHAR2(200) ;
l_col2_c   VARCHAR2(200) ;
l_col3_c   VARCHAR2(200) ;
l_tables_c VARCHAR2(500);
l_where_c  VARCHAR2(1000);

/* Fourth query */
l_col1_d   VARCHAR2(200) ;
l_col2_d   VARCHAR2(200) ;
l_col3_d   VARCHAR2(200) ;
l_tables_d VARCHAR2(500);
l_where_d  VARCHAR2(1000);

/* Fifth query */
l_col1_e   VARCHAR2(200) ;
l_col2_e   VARCHAR2(200) ;
l_col3_e   VARCHAR2(200) ;
l_tables_e VARCHAR2(500);
l_where_e  VARCHAR2(1000);

/* Sixth query */
l_col1_f   VARCHAR2(200) ;
l_col2_f   VARCHAR2(200) ;
l_col3_f   VARCHAR2(200) ;
l_tables_f VARCHAR2(500);
l_where_f  VARCHAR2(1000);

/* Seventh query */
l_col1_g   VARCHAR2(200) ;
l_col2_g   VARCHAR2(200) ;
l_col3_g   VARCHAR2(200) ;
l_tables_g VARCHAR2(500);
l_where_g  VARCHAR2(1000);

/* Second query */
l_col1_h   VARCHAR2(200) ;
l_col2_h   VARCHAR2(200) ;
l_col3_h   VARCHAR2(200) ;
l_tables_h VARCHAR2(500);
l_where_h  VARCHAR2(1000);

l_qry_sg VARCHAR2(20000);
l_camp_id VARCHAR2(100);
l_close_rs   VARCHAR2(500);
l_context       VARCHAR2(5000);

  /* Start of the PL/SQL Block */

   BEGIN
   l_col3_a   := '0';
   l_col3_b   := '0';
   l_col3_c   := '0';
   l_col3_e   := '0';
   l_col3_f   := '0';
   l_col3_g   := '0';
   l_col3_h   := '0';
      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

      get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
		 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date        => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id        => l_curr_page_time_id,
		 p_prev_page_time_id        => l_prev_page_time_id,
		 l_view_by                 =>  l_view_by,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );
      l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
      l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';

l_url_str:='pFunctionName=BIM_I_LEAD_CONVERSION_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';

IF l_org_sg is null THEN
  l_query := 'SELECT
NULL VIEWBY,
NULL VIEWBYID,
NULL BIM_MEASURE1,
NULL BIM_MEASURE2,
NULL BIM_MEASURE3,
NULL BIM_MEASURE4,
NULL BIM_MEASURE5,
NULL BIM_MEASURE6,
NULL BIM_MEASURE8,
NULL BIM_MEASURE7,
NULL BIM_MEASURE9,
NULL BIM_URL1,
NULL BIM_URL2,
NULL BIM_URL3,
NULL BIM_URL4,
NULL BIM_URL5,
NULL BIM_URL6,
NULL BIM_URL7,
NULL BIM_GRAND_TOTAL1,
NULL BIM_GRAND_TOTAL2,
NULL BIM_GRAND_TOTAL3,
NULL BIM_GRAND_TOTAL4,
NULL BIM_GRAND_TOTAL5,
NULL BIM_GRAND_TOTAL6,
NULL bim_GRAND_TOTAL7,
NULL bim_GRAND_TOTAL8,
NULL bim_GRAND_TOTAL9
FROM dual ';
  x_custom_sql := l_query;
ELSE

/* View By Sales Group */

IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
if (l_category_id is null)
then
   /* Start assigning the local variables to be substituted in the query */
   IF l_resource_id is null then

	/* First query */
	l_col1_a   := ' d.group_name ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b,jtf_rs_groups_tl d ';
	l_where_a  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
	l_col1_b   := ' d.group_name ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b,jtf_rs_groups_tl d ';
	l_where_b  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Third query */
	l_col1_c   := ' a.source_name ';
	l_col2_c   := ' a.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id <> :l_resource_id ';

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id <> :l_resource_id ';

	/* Fifth query */
	l_col1_e   := ' d.group_name ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b,jtf_rs_groups_tl d ';
	l_where_e  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Sixth query */
	l_col1_f   := ' a.source_name ';
	l_col2_f   := ' a.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id <> :l_resource_id ';
	/* Seventh query */
	l_col1_g   := ' a.source_name ';
	l_col2_g   := ' a.resource_id||''.''||b.group_id ';
	l_col3_g   := '1';
	l_tables_g := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id <> :l_resource_id ';
	/* eighth query */
	l_col1_h   := ' d.group_name ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b,jtf_rs_groups_tl d ';
	l_where_h  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';
    ELSE
	/* Third query */
	l_col1_c   := ' a.source_name ';
	l_col2_c   := ' a.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Sixth query */
	l_col1_f   := ' a.source_name ';
	l_col2_f   := ' a.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Seventh query */
	l_col1_g   := ' a.source_name ';
	l_col2_g   := ' a.resource_id||''.''||b.group_id ';
	l_col3_g   := '1';
	l_tables_g := ' BIM_I_LD_GEN_SG_MV b ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;


    END IF;

else
   IF l_resource_id is null then
	/* First query */
	l_col1_a   := ' d.group_name ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b,jtf_rs_groups_tl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_a  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
	l_col1_b   := ' d.group_name ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b,jtf_rs_groups_tl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_b  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Third query */
	l_col1_c   := ' a.source_name ';
	l_col2_c   := ' a.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id <> :l_resource_id ';

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id <> :l_resource_id ';

	/* Fifth query */
	l_col1_e   := ' d.group_name ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b,jtf_rs_groups_tl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_e  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Sixth query */
	l_col1_f   := ' a.source_name ';
	l_col2_f   := ' a.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id <> :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* seventh query */
	l_col1_g   := ' a.source_name ';
	l_col2_g   := ' a.resource_id||''.''||b.group_id ';
	l_col3_g   := '1';
	l_tables_g := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id <> :l_resource_id ';

	/* Eight query */
	l_col1_h   := ' d.group_name ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b,jtf_rs_groups_tl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_h  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
	AND b.group_id=d.group_id
	AND d.language=USERENV(''LANG'')
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id =:l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';


    ELSE

	/* Third query */
	l_col1_c   := ' a.source_name ';
	l_col2_c   := ' a.resource_id||''.''||b.group_id ';
	l_col3_c   := '1';
	l_tables_c := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
	l_col1_d   := ' a.source_name ';
	l_col2_d   := ' a.resource_id||''.''||b.group_id ';
	l_col3_d   := '1';
	l_tables_d := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';


	/* Sixth query */
	l_col1_f   := ' a.source_name ';
	l_col2_f   := ' a.resource_id||''.''||b.group_id ';
	l_col3_f   := '1';
	l_tables_f := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
	/* seventh query */
	l_col1_g   := ' a.source_name ';
	l_col2_g   := ' a.resource_id||''.''||b.group_id ';
	l_col3_g   := '1';
	l_tables_g := ' BIM_I_LP_GEN_SG_MV b , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

    END IF;
end if;

/* View by Category*/

ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN

if (l_category_id is null) THEN
  /* If Only group is selected and rep is not selected */
  if (l_resource_id is null) THEN

l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       leads_converted BIM_ATTRIBUTE1,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE2,
       DECODE(leads_new,0,NULL,(leads_new_conv/leads_new)*100) BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       leads_new_conv BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(prev_new_lead_converted,0,NULL,((leads_new_conv - prev_new_lead_converted)/prev_new_lead_converted)*100) BIM_ATTRIBUTE7,
       NULL BIM_ATTRIBUTE12,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE13,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_open+leads_new) over(),0,NULL,(sum(leads_converted) over()/sum(prev_open+leads_new) over())*100) BIM_GRAND_TOTAL2,
       DECODE(sum(leads_new) over(),0,NULL,(sum(leads_new_conv) over()/sum(leads_new) over())*100) BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       sum(leads_new_conv) over() BIM_GRAND_TOTAL5,
       DECODE(sum(prev_lead_converted) over(),0,NULL,(( sum(leads_converted - prev_lead_converted) over() )/sum(prev_lead_converted) over())*100) BIM_GRAND_TOTAL6,
       DECODE(sum(prev_new_lead_converted) over(),0,NULL,((sum(leads_new_conv - prev_new_lead_converted) over())/sum(prev_new_lead_converted) over())*100) BIM_GRAND_TOTAL7
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(leads_new_conv) leads_new_conv,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted,
sum(prev_new_lead_converted) prev_new_lead_converted
FROM
(
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
/*current leads new conv for groups*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date =&BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
/*previous leads new conv for groups*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date =&BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_prev_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id =:l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
	p.value BIM_SALES_GROUP,
	p.parent_id VIEWBYID,
	p.leaf_node_flag leaf_node_flag,
	0 leads_new,
	0 leads_converted,
	0 leads_new_conv,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c,  BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND (b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.parent_id,p.leaf_node_flag
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(leads_new_conv) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
OR sum(prev_new_lead_converted) > 0
)';
 else
  /* If Only rep is selected */
l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       leads_converted BIM_ATTRIBUTE1,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE2,
       DECODE(leads_new,0,NULL,(leads_new_conv/leads_new)*100) BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       leads_new_conv BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(prev_new_lead_converted,0,NULL,((leads_new_conv - prev_new_lead_converted)/prev_new_lead_converted)*100) BIM_ATTRIBUTE7,
       NULL BIM_ATTRIBUTE12,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE13,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_open+leads_new) over(),0,NULL,(sum(leads_converted) over()/sum(prev_open+leads_new) over())*100) BIM_GRAND_TOTAL2,
       DECODE(sum(leads_new) over(),0,NULL,(sum(leads_new_conv) over()/sum(leads_new) over())*100) BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       sum(leads_new_conv) over() BIM_GRAND_TOTAL5,
       DECODE(sum(prev_lead_converted) over(),0,NULL,(( sum(leads_converted - prev_lead_converted) over() )/sum(prev_lead_converted) over())*100) BIM_GRAND_TOTAL6,
       DECODE(sum(prev_new_lead_converted) over(),0,NULL,((sum(leads_new_conv - prev_new_lead_converted) over())/sum(prev_new_lead_converted) over())*100) BIM_GRAND_TOTAL7
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(leads_new_conv) leads_new_conv,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted,
sum(prev_new_lead_converted) prev_new_lead_converted
FROM
(
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
/*current leads new conv for groups*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date =&BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
/*current leads new conv for groups*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.parent_id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date =&BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_prev_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
	p.value BIM_SALES_GROUP,
        p.parent_id VIEWBYID,
        p.leaf_node_flag leaf_node_flag,
	0 leads_new,
	0 leads_converted,
	0 leads_new_conv,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
        ,eni_denorm_hierarchies edh
        ,mtl_default_category_sets d
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND (b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.parent_id,p.leaf_node_flag
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(leads_new_conv) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
OR sum(prev_new_lead_converted) > 0
)';
 end if;
ELSE

/*Catgeory not equal to all*/

  /* If Only group is selected and rep is not selected */
  if (l_resource_id is null) THEN

l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       leads_converted BIM_ATTRIBUTE1,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE2,
       DECODE(leads_new,0,NULL,(leads_new_conv/leads_new)*100) BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       leads_new_conv BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(prev_new_lead_converted,0,NULL,((leads_new_conv - prev_new_lead_converted)/prev_new_lead_converted)*100) BIM_ATTRIBUTE7,
       NULL BIM_ATTRIBUTE12,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE13,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_open+leads_new) over(),0,NULL,(sum(leads_converted) over()/sum(prev_open+leads_new) over())*100) BIM_GRAND_TOTAL2,
       DECODE(sum(leads_new) over(),0,NULL,(sum(leads_new_conv) over()/sum(leads_new) over())*100) BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       sum(leads_new_conv) over() BIM_GRAND_TOTAL5,
       DECODE(sum(prev_lead_converted) over(),0,NULL,(( sum(leads_converted - prev_lead_converted) over() )/sum(prev_lead_converted) over())*100) BIM_GRAND_TOTAL6,
       DECODE(sum(prev_new_lead_converted) over(),0,NULL,((sum(leads_new_conv - prev_new_lead_converted) over())/sum(prev_new_lead_converted) over())*100) BIM_GRAND_TOTAL7
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(leads_new_conv) leads_new_conv,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted,
sum(prev_new_lead_converted) prev_new_lead_converted
FROM
(
/*********children of the selected category*********/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/*leads new conv*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date =&BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id =:l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date =&BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_prev_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
	p.value BIM_SALES_GROUP,
        p.id VIEWBYID,
        p.leaf_node_flag leaf_node_flag,
	0 leads_new,
	0 leads_converted,
	0 leads_new_conv,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND (b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/******Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y'' leaf_node_flag,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
UNION ALL
/******Leads New Conv Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y''  leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date =&BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY  p.value,p.id
UNION ALL
/******Leads New Conv Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y''  leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date =&BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_prev_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY  p.value,p.id
UNION ALL
select /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
        p.id VIEWBYID,
        ''Y''  leaf_node_flag,
	0 leads_new,
	0 leads_converted,
	0 leads_new_conv,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
AND (b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.id
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(leads_new_conv) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
OR sum(prev_new_lead_converted) > 0
)';

 else
  /* If Only rep is selected */
l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       leads_converted BIM_ATTRIBUTE1,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE2,
       DECODE(leads_new,0,NULL,(leads_new_conv/leads_new)*100) BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       leads_new_conv BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(prev_new_lead_converted,0,NULL,((leads_new_conv - prev_new_lead_converted)/prev_new_lead_converted)*100) BIM_ATTRIBUTE7,
       NULL BIM_ATTRIBUTE12,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE13,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(prev_open+leads_new) over(),0,NULL,(sum(leads_converted) over()/sum(prev_open+leads_new) over())*100) BIM_GRAND_TOTAL2,
       DECODE(sum(leads_new) over(),0,NULL,(sum(leads_new_conv) over()/sum(leads_new) over())*100) BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       sum(leads_new_conv) over() BIM_GRAND_TOTAL5,
       DECODE(sum(prev_lead_converted) over(),0,NULL,(( sum(leads_converted - prev_lead_converted) over() )/sum(prev_lead_converted) over())*100) BIM_GRAND_TOTAL6,
       DECODE(sum(prev_new_lead_converted) over(),0,NULL,((sum(leads_new_conv - prev_new_lead_converted) over())/sum(prev_new_lead_converted) over())*100) BIM_GRAND_TOTAL7
FROM (
SELECT
BIM_SALES_GROUP,
VIEWBYID,
leaf_node_flag,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(leads_new_conv) leads_new_conv,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted,
sum(prev_new_lead_converted) prev_new_lead_converted
FROM
(
/*********children of the selected category*********/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/*leads new conv*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/*previous leads new conv*/
SELECT /*+ leading(c) */
       p.value BIM_SALES_GROUP,
       p.id VIEWBYID,
       p.leaf_node_flag leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_prev_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
	p.value BIM_SALES_GROUP,
        p.id VIEWBYID,
        p.leaf_node_flag leaf_node_flag,
	0 leads_new,
	0 leads_converted,
	0 leads_new_conv,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND (b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
/******Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y'' leaf_node_flag,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY  p.value,p.id
UNION ALL
/******Leads New Conv Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y'' leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY  p.value,p.id
UNION ALL
/******Leads New Conv Directly Assigned to Category*******/
SELECT /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
       p.id VIEWBYID,
       ''Y'' leaf_node_flag,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date =&BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.update_time_id=c.time_id
AND b.update_period_type_id=c.period_type_id
and b.time_id = :l_prev_time_id
and b.period_type_id = :l_period_type_id
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY  p.value,p.id
UNION ALL
select /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
        p.id VIEWBYID,
        ''Y''  leaf_node_flag,
	0 leads_new,
	0 leads_converted,
	0 leads_new_conv,
	0 conversion_time,
	sum(b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c, BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
AND (b.leads-(b.leads_closed+b.leads_dead+b.leads_converted)) <> 0
GROUP BY p.value,p.id
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,leaf_node_flag
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(leads_new_conv) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
OR sum(prev_new_lead_converted) > 0
)';
end if;
end if;  /********All or non-all*************/


/* View by Lead Source*/

ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN
if (l_category_id is null) THEN
   IF l_resource_id is null then

	/* First query */
      	l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LD_SRC_MV b,as_lookups d ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.lead_Source =d.lookup_code(+)
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
      	l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LD_SRC_MV b,as_lookups d ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.lead_Source =d.lookup_code(+)
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id =:l_resource_id ';

       /* eighth query */
      	l_col1_h   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LD_SRC_MV b,as_lookups d ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.lead_Source =d.lookup_code(+)
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LD_SRC_MV b,as_lookups d ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+)= ''SOURCE_SYSTEM''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

    ELSE
	/* Third query */
      	l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LD_SRC_MV b , as_lookups d ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
        AND d.lookup_code(+) = b.lead_source
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LD_SRC_MV b , as_lookups d ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND d.lookup_code(+) = b.lead_source
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Seventh query */
      	l_col1_g   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LD_SRC_MV b , as_lookups d ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND d.lookup_code(+) = b.lead_source
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Sixth query */
      	l_col1_f   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LD_SRC_MV b , as_lookups d ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.lead_source = d.lookup_code(+)
        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

    END IF;


else

   IF l_resource_id is null then
	/* First query */
      	l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LP_SRC_MV b,as_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
      	l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

	/* Third query */
      	l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
        AND b.lead_source=d.lookup_code(+)
        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Seventh query */
      	l_col1_g   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.lead_source=d.lookup_code(+)
	AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Sixth query */
      	l_col1_f   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LP_SRC_MV b,as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.lead_source=d.lookup_code(+)
        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    END IF;

end if;

/* View by Lead Quality*/

ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY') THEN

if (l_category_id is null) THEN
   IF l_resource_id is null then

	/* First query */
      	l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
      	l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LD_QUAL_MV b,as_sales_lead_ranks_vl d ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

    ELSE
	/* Third query */
      	l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LD_QUAL_MV b , as_sales_lead_ranks_vl d ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LD_QUAL_MV b , as_sales_lead_ranks_vl d ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* seventh query */
      	l_col1_g   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LD_QUAL_MV b , as_sales_lead_ranks_vl d ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Sixth query */
      	l_col1_f   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LD_QUAL_MV b , as_sales_lead_ranks_vl d ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

    END IF;


else

   IF l_resource_id is null then
	/* First query */
      	l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
      	l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';


	/* Eighth query */
      	l_col1_h   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

	/* Third query */
      	l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* seventh query */
      	l_col1_g   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.rank_id (+) = b.lead_rank_id
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Sixth query */
      	l_col1_f   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LP_QUAL_MV b,as_sales_lead_ranks_vl d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.rank_id (+) = b.lead_rank_id
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    END IF;

end if;

/* View by Sales Channel*/

ELSIF (l_view_by = 'SALES CHANNEL+SALES CHANNEL') THEN

if (l_category_id is null) THEN
   IF l_resource_id is null then

	/* First query */
      	l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.channel_code =d.lookup_code(+)
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
      	l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.channel_code =d.lookup_code(+)
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.channel_code =d.lookup_code(+)
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+)= ''SALES_CHANNEL''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

    ELSE
	/* Third query */
      	l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LD_CHNL_MV b , so_lookups d ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND d.lookup_type(+) = ''SALES_CHANNEL''
        AND d.lookup_code(+) = b.channel_code
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LD_CHNL_MV b , so_lookups d ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND d.lookup_code(+) = b.channel_code
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Seventh query */
      	l_col1_g   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LD_CHNL_MV b , so_lookups d ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND d.lookup_code(+) = b.channel_code
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Sixth query */
      	l_col1_f   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LD_CHNL_MV b , so_lookups d ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.channel_code = d.lookup_code(+)
        AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

    END IF;


else

   IF l_resource_id is null then
	/* First query */
      	l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
      	l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LP_CHNL_MV b,so_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
      	l_col1_h   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LP_CHNL_MV b,so_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl   ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id =:l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

	/* Third query */
      	l_col1_c   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
        AND b.channel_code=d.lookup_code(+)
        AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

        /* Seventh query */
      	l_col1_g   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND b.channel_code=d.lookup_code(+)
	AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Sixth query */
      	l_col1_f   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LP_CHNL_MV b,so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.channel_code=d.lookup_code(+)
        AND d.lookup_type(+) = ''SALES_CHANNEL''
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    END IF;

end if;

/* View by Country*/

ELSIF (l_view_by = 'GEOGRAPHY+COUNTRY') THEN

if (l_category_id is null) THEN
   IF l_resource_id is null then

	/* First query */
      	l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
      	l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

    ELSE
	/* Third query */
      	l_col1_c   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LD_REGN_MV b , bis_countries_v d ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LD_REGN_MV b , bis_countries_v d ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Seventh query */
      	l_col1_g   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LD_REGN_MV b , bis_countries_v d ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;

	/* Sixth query */
      	l_col1_f   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LD_REGN_MV b , bis_countries_v d ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

    END IF;


else

   IF l_resource_id is null then
	/* First query */
      	l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
      	l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

	/* Third query */
      	l_col1_c   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Seventh query */
      	l_col1_g   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.country_code (+) = b.lead_country
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Sixth query */
      	l_col1_f   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.country_code (+) = b.lead_country
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    END IF;

end if;

/* View by Customer Category */

ELSIF (l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN

if (l_category_id is null) THEN
   IF l_resource_id is null then

	/* First query */
      	l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

	/* Second query */
      	l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ';

    ELSE
	/* Third query */
      	l_col1_c   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LD_CCAT_MV b , bic_cust_category_v d ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LD_CCAT_MV b , bic_cust_category_v d ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;



	/* Seventh query */
      	l_col1_g   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LD_CCAT_MV b , bic_cust_category_v d ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ' ;



	/* Sixth query */
      	l_col1_f   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LD_CCAT_MV b , bic_cust_category_v d ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
	AND b.update_time_id= -1
	AND b.update_period_type_id= -1
	AND b.resource_id = :l_resource_id ' ;

    END IF;


else

   IF l_resource_id is null then
	/* First query */
      	l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_a   := ' b.group_id ';
	l_tables_a := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code(+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Second query */
      	l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_b   := ' b.group_id ';
	l_tables_b := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_b  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Eighth query */
      	l_col1_h   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_h   := ' b.group_id ';
	l_tables_h := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_h  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

	/* Fifth query */
      	l_col1_e   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_e   := ' b.group_id ';
	l_tables_e := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_e  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

	/* Third query */
      	l_col1_c   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_c   := ' b.group_id ';
	l_tables_c := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_c  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id ' ;

	/* Fourth query */
      	l_col1_d   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_d   := ' b.group_id ';
	l_tables_d := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_d  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';

	/* Seventh query */
      	l_col1_g   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_g   := ' b.group_id ';
	l_tables_g := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_g  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
	AND d.customer_category_code (+) = b.cust_category
	AND b.update_time_id=c.time_id
	AND b.update_period_type_id=c.period_type_id
	and b.time_id = :l_prev_time_id
	and b.period_type_id = :l_period_type_id
	AND b.resource_id = :l_resource_id ';


	/* Sixth query */
      	l_col1_f   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
	l_col2_f   := ' b.group_id ';
	l_tables_f := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
	l_where_f  := ' AND a.resource_id=b.resource_id
	AND b.group_id = :l_group_id
	AND d.customer_category_code (+) = b.cust_category
	AND b.time_id=c.time_id
	AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
	AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
	AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';

    END IF;

end if;

end if; /*********Category or Sales Group*********/

-- ===================== Query Formation =============================
/* This is the dynamic query to be used with variables replaced*/
IF (l_view_by <> 'ITEM+ENI_ITEM_VBH_CAT')  THEN
 IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
      l_qry_sg :=
	'UNION ALL
	/* Leads Converted for reps*/
	 SELECT /*+ leading(c) */
	       '||l_col1_c||' BIM_SALES_GROUP,
	       to_char ( '||l_col2_c||' ) VIEWBYID,
	       '||l_col3_c||' is_resource,
	       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
	       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
	       0 leads_new_conv,
	       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
	       0 prev_open,
	       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
	       0 prev_new_lead_converted
	FROM FII_TIME_RPT_STRUCT c ,JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_C|| '
	WHERE c.calendar_id=-1
	AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
	'||l_where_c||'
	GROUP BY '||l_col1_c||','||l_col2_c||','||l_col3_c||'
	UNION ALL
	/* Leads New Converted for reps*/
	 SELECT /*+ leading(c) */
	       '||l_col1_d||' BIM_SALES_GROUP,
	       to_char ( '||l_col2_d||' ) VIEWBYID,
	       '||l_col3_d||' is_resource,
		0 leads_new,
		0 leads_converted,
		sum(leads_new_conv) leads_new_conv,
		0 conversion_time,
		0 prev_open,
		0 prev_lead_converted,
		0 prev_new_lead_converted
	FROM FII_TIME_RPT_STRUCT c ,JTF_RS_RESOURCE_EXTNS_VL a,  '|| l_tables_d|| '
	WHERE c.calendar_id=-1
	AND c.report_date = &BIS_CURRENT_ASOF_DATE
	AND BITAND(c.record_type_id,1143)=c.record_type_id
	'||l_where_d||'
	GROUP BY '||l_col1_d||','||l_col2_d||','||l_col3_d||'
	UNION ALL
	/* Leads New Converted for reps*/
	 SELECT /*+ leading(c) */
	       '||l_col1_g||' BIM_SALES_GROUP,
	       to_char ( '||l_col2_g||' ) VIEWBYID,
	       '||l_col3_g||' is_resource,
		0 leads_new,
		0 leads_converted,
		0 leads_new_conv,
		0 conversion_time,
		0 prev_open,
		0 prev_lead_converted,
		sum(leads_new_conv) prev_new_lead_converted
	FROM FII_TIME_RPT_STRUCT c ,JTF_RS_RESOURCE_EXTNS_VL a,  '|| l_tables_g|| '
	WHERE c.calendar_id=-1
	AND c.report_date = &BIS_PREVIOUS_ASOF_DATE
	AND BITAND(c.record_type_id,1143)=c.record_type_id
	'||l_where_g||'
	GROUP BY '||l_col1_g||','||l_col2_g||','||l_col3_g||'
	UNION ALL
	/* prior Open for reps*/
	SELECT /*+ leading(c) */
	       '||l_col1_f||' BIM_SALES_GROUP,
	       to_char ( '||l_col2_f||' ) VIEWBYID,
	       '||l_col3_f||' is_resource,
		0 leads_new,
		0 leads_converted,
		0 leads_new_conv,
		0 conversion_time,
		sum(b.leads - (leads_closed+leads_dead+leads_converted)) prev_open,
		0 prev_lead_converted,
		0 prev_new_lead_converted
	FROM FII_TIME_RPT_STRUCT c ,JTF_RS_RESOURCE_EXTNS_VL a,  '|| l_tables_f|| '
	WHERE c.calendar_id=-1
	AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND BITAND(c.record_type_id,1143)=c.record_type_id
	AND (b.leads-(leads_closed+leads_dead+leads_converted)) <> 0
        '||l_where_f||'
	GROUP BY '||l_col1_f||','||l_col2_f||','||l_col3_f;
 ELSE
     l_qry_sg := NULL;
 END IF;

IF l_resource_id is null THEN
/* This query needs to be executed in case if Sales Rep is not passed */
l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       leads_converted BIM_ATTRIBUTE1,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE2,
       DECODE(leads_new,0,NULL,(leads_new_conv/leads_new)*100) BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       leads_new_conv BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(prev_new_lead_converted,0,NULL,((leads_new_conv - prev_new_lead_converted)/prev_new_lead_converted)*100) BIM_ATTRIBUTE7,
       DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_ATTRIBUTE12,
       NULL BIM_ATTRIBUTE13,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL2,
       DECODE(sum(leads_new) over(),0,NULL,(sum(leads_new_conv) over()/sum(leads_new) over())*100) BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       sum(leads_new_conv) over() BIM_GRAND_TOTAL5,
       DECODE(sum(prev_lead_converted) over(),0,NULL,(( sum(leads_converted - prev_lead_converted) over() )/sum(prev_lead_converted) over())*100) BIM_GRAND_TOTAL6,
       DECODE(sum(prev_new_lead_converted) over(),0,NULL,((sum(leads_new_conv - prev_new_lead_converted) over())/sum(prev_new_lead_converted) over())*100) BIM_GRAND_TOTAL7
FROM
(
SELECT
BIM_SALES_GROUP,
VIEWBYID,
is_resource,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(leads_new_conv) leads_new_conv,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted,
sum(prev_new_lead_converted) prev_new_lead_converted
FROM
(
SELECT /*+ leading(c) */
       '||l_col1_a||' BIM_SALES_GROUP,
       to_char ( '||l_col2_a||' ) VIEWBYID,
       '||l_col3_a||' is_resource,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM  FII_TIME_RPT_STRUCT c , '|| l_tables_a|| '
WHERE c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_a||'
GROUP BY '||l_col1_a||','||l_col2_a||','||l_col3_a||'
/*Leads New Converted for groups*/
UNION ALL
SELECT /*+ leading(c) */
       '||l_col1_b||' BIM_SALES_GROUP,
       to_char ( '||l_col2_b||' ) VIEWBYID,
       '||l_col3_b||' is_resource,
       0 leads_new,
       0 leads_converted,
       sum(leads_new_conv) leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c , '|| l_tables_b|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_b||'
GROUP BY '||l_col1_b||','||l_col2_b||','||l_col3_b||'
/*Leads New Converted for groups*/
UNION ALL
SELECT /*+ leading(c) */
       '||l_col1_h||' BIM_SALES_GROUP,
       to_char ( '||l_col2_h||' ) VIEWBYID,
       '||l_col3_h||' is_resource,
       0 leads_new,
       0 leads_converted,
       0 leads_new_conv,
       0 conversion_time,
       0 prev_open,
       0 prev_lead_converted,
       sum(leads_new_conv)  prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c , '|| l_tables_h|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_h||'
GROUP BY '||l_col1_h||','||l_col2_h||','||l_col3_h||'
/*prior open*/
UNION ALL
select /*+ leading(c) */
       '||l_col1_e||' BIM_SALES_GROUP,
       to_char ( '||l_col2_e||' ) VIEWBYID,
       '||l_col3_e||' is_resource,
        0 leads_new,
        0 leads_converted,
        0 leads_new_conv,
        0 conversion_time,
        sum(b.leads - (leads_closed+leads_dead+leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c,  '|| l_tables_e|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
AND (b.leads-(leads_closed+leads_dead+leads_converted)) <> 0
'||l_where_e||'
GROUP BY '||l_col1_e||','||l_col2_e||','||l_col3_e||l_qry_sg||'
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(leads_new_conv) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
OR sum(prev_new_lead_converted) > 0
 ) ';

ELSE
/* This query needs to be executed in case if Sales Rep is passed */

l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       leads_converted BIM_ATTRIBUTE1,
       DECODE((prev_open+leads_new),0,NULL,(leads_converted/(prev_open+leads_new))*100) BIM_ATTRIBUTE2,
       DECODE(leads_new,0,NULL,(leads_new_conv/leads_new)*100) BIM_ATTRIBUTE3,
       DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE4,
       leads_new_conv BIM_ATTRIBUTE5,
       DECODE(prev_lead_converted,0,NULL,((leads_converted - prev_lead_converted)/prev_lead_converted)*100) BIM_ATTRIBUTE6,
       DECODE(prev_new_lead_converted,0,NULL,((leads_new_conv - prev_new_lead_converted)/prev_new_lead_converted)*100) BIM_ATTRIBUTE7,
       DECODE('||''''||l_view_by||''''||' , ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_ATTRIBUTE12,
       NULL BIM_ATTRIBUTE13,
       SUM(leads_converted) OVER() BIM_GRAND_TOTAL1,
       DECODE(sum(open_new) over(),0,NULL,(sum(leads_converted) over()/sum(open_new) over())*100) BIM_GRAND_TOTAL2,
       DECODE(sum(leads_new) over(),0,NULL,(sum(leads_new_conv) over()/sum(leads_new) over())*100) BIM_GRAND_TOTAL3,
       DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL4,
       sum(leads_new_conv) over() BIM_GRAND_TOTAL5,
       DECODE(sum(prev_lead_converted) over(),0,NULL,(( sum(leads_converted - prev_lead_converted) over() )/sum(prev_lead_converted) over())*100) BIM_GRAND_TOTAL6,
       DECODE(sum(prev_new_lead_converted) over(),0,NULL,((sum(leads_new_conv - prev_new_lead_converted) over())/sum(prev_new_lead_converted) over())*100) BIM_GRAND_TOTAL7
FROM
(
SELECT
BIM_SALES_GROUP,
VIEWBYID,
is_resource,
sum(leads_new) leads_new,
sum(leads_converted) leads_converted,
sum(leads_new_conv) leads_new_conv,
sum(prev_open+leads_new) open_new,
sum(conversion_time) conversion_time,
sum(prev_open) prev_open,
sum(prev_lead_converted) prev_lead_converted,
sum(prev_new_lead_converted) prev_new_lead_converted
FROM
(
/* Leads Converted for reps*/
 SELECT /*+ leading(c) */
       '||l_col1_c||' BIM_SALES_GROUP,
       to_char ( '||l_col2_c||' ) VIEWBYID,
       '||l_col3_c||' is_resource,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_new,0)) leads_new,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,leads_converted,0)) leads_converted,
       0 leads_new_conv,
       sum(decode(c.report_date,&BIS_CURRENT_ASOF_DATE,conversion_time,0)) conversion_time,
       0 prev_open,
       sum(decode(c.report_date,&BIS_PREVIOUS_ASOF_DATE,leads_converted,0)) prev_lead_converted,
       0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c , JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_c|| '
WHERE c.calendar_id=-1
AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_c||'
GROUP BY '||l_col1_c||','||l_col2_c||','||l_col3_c||'
UNION ALL
/* Leads New Converted for reps*/
 SELECT /*+ leading(c) */
       '||l_col1_d||' BIM_SALES_GROUP,
       to_char ( '||l_col2_d||' ) VIEWBYID,
       '||l_col3_d||' is_resource,
        0 leads_new,
        0 leads_converted,
        sum(leads_new_conv) leads_new_conv,
        0 conversion_time,
        0 prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c , JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_d|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_d||'
GROUP BY '||l_col1_d||','||l_col2_d||','||l_col3_d||'
UNION ALL
/* Leads New Converted for reps*/
 SELECT /*+ leading(c) */
       '||l_col1_g||' BIM_SALES_GROUP,
       to_char ( '||l_col2_g||' ) VIEWBYID,
       '||l_col3_g||' is_resource,
        0 leads_new,
        0 leads_converted,
        0 leads_new_conv,
        0 conversion_time,
        0 prev_open,
	0 prev_lead_converted,
	sum(leads_new_conv) prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c , JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_g|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_PREVIOUS_ASOF_DATE
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_g||'
GROUP BY '||l_col1_g||','||l_col2_g||','||l_col3_g||'
UNION ALL
/* prior Open for reps*/
SELECT /*+ leading(c) */
       '||l_col1_f||' BIM_SALES_GROUP,
       to_char ( '||l_col2_f||' ) VIEWBYID,
       '||l_col3_f||' is_resource,
        0 leads_new,
        0 leads_converted,
        0 leads_new_conv,
        0 conversion_time,
        sum(b.leads - (leads_closed+leads_dead+leads_converted)) prev_open,
	0 prev_lead_converted,
	0 prev_new_lead_converted
FROM FII_TIME_RPT_STRUCT c , JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_f|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
AND BITAND(c.record_type_id,1143)=c.record_type_id
'||l_where_f||'
GROUP BY '||l_col1_f||','||l_col2_f||','||l_col3_f||'
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
HAVING
sum(leads_converted) > 0
OR sum(leads_new) > 0
OR sum(prev_open)> 0
OR sum(leads_new_conv) > 0
OR sum(conversion_time) > 0
OR sum(prev_lead_converted) > 0
OR sum(prev_new_lead_converted) > 0
 ) ';

END IF;
END IF;



 /* Earlier l_resource_id was hardcoded to -1 ,to enable binding below code was added */

   IF l_resource_id is null then
      l_resource_id:= -1;
   END IF;



-- ========================================================================
  x_custom_sql := l_query||'&ORDER_BY_CLAUSE';

  END IF;

  /*l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_KEY;
  l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_CUSTOM_OUTPUT.COUNT) := l_custom_rec;
*/

  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_prev_time_id';
  l_custom_rec.attribute_value := l_prev_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

   --test('GET_LEAD_ACT_SQL','QUERY','',l_query);

   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
      --test('GET_LEAD_ACT_SQL', 'EXCEPTION','test',l_error_msg);
   END;

-- Start of comments
-- NAME
--    GET_LEAD_AGING_QU_SQL
--
-- PURPOSE
--    Returns the Lead Aging by Quality query.
--
-- NOTES
--
-- HISTORY
-- 08/27/2002  dmvincen  created.
--
-- End of comments
PROCEDURE GET_LEAD_AGING_QU_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(4000) := NULL;
      l_error_msg varchar2(4000) := NULL;
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_resource_id VARCHAR2(20);
      l_camp_id VARCHAR2(100);
      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
      l_close_rs   VARCHAR2(500);
      l_context       VARCHAR2(5000);
   BEGIN

      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
		 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date        => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id        => l_curr_page_time_id,
		 p_prev_page_time_id        => l_prev_page_time_id,
		 l_view_by                 =>  l_view_by,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );

if (l_category_id is null)
then
      l_query := 'SELECT quality BIM_QUALITY,
age_3_below BIM_MEASURE1,
age_3_to_7 BIM_MEASURE2,
age_8_to_14 BIM_MEASURE3,
age_15_to_21 BIM_MEASURE4,
age_22_to_28 BIM_MEASURE5,
age_29_to_35 BIM_MEASURE6,
age_36_to_42 BIM_MEASURE7,
age_42_to_above BIM_MEASURE8,
(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
age_36_to_42+age_42_to_above) BIM_MEASURE9,
SUM(age_3_below) over() BIM_GRAND_TOTAL1,
SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
FROM(select quality,age_3_below,age_3_to_7,age_8_to_14,age_15_to_21,
age_22_to_28,age_29_to_35,age_36_to_42,age_42_to_above
from(select decode(b.rank_code,''Z'',''Other'',a.meaning) quality,b.age_3_below,b.age_3_to_7,b.age_8_to_14,
b.age_15_to_21,b.age_22_to_28,b.age_29_to_35,b.age_36_to_42,
b.age_42_to_above
FROM BIM_I_LD_AGE_QU_MV b,
     AS_SALES_LEAD_RANKS_TL a
WHERE b.group_id IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.rank_id(+) = b.rank_id
AND a.language(+)=USERENV(''LANG'')
order by rank_code
)
)
WHERE age_3_below > 0
AND age_3_to_7 > 0
AND age_8_to_14 > 0
AND age_15_to_21 > 0
AND age_22_to_28 > 0
AND age_29_to_35 > 0
AND age_36_to_42 > 0
AND age_42_to_above > 0
&ORDER_BY_CLAUSE
';
else
l_query := 'SELECT quality BIM_QUALITY,
age_3_below BIM_MEASURE1,
age_3_to_7 BIM_MEASURE2,
age_8_to_14 BIM_MEASURE3,
age_15_to_21 BIM_MEASURE4,
age_22_to_28 BIM_MEASURE5,
age_29_to_35 BIM_MEASURE6,
age_36_to_42 BIM_MEASURE7,
age_42_to_above BIM_MEASURE8,
(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
age_36_to_42+age_42_to_above) BIM_MEASURE9,
SUM(age_3_below) over() BIM_GRAND_TOTAL1,
SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
FROM(select quality,age_3_below,age_3_to_7,age_8_to_14,age_15_to_21,
age_22_to_28,age_29_to_35,age_36_to_42,age_42_to_above
from(select decode(b.rank_code,''Z'',''Other'',a.meaning) quality,b.age_3_below,b.age_3_to_7,b.age_8_to_14,
b.age_15_to_21,b.age_22_to_28,b.age_29_to_35,b.age_36_to_42,
b.age_42_to_above
FROM BIM_I_LP_AGE_QU_MV b,
     AS_SALES_LEAD_RANKS_TL a
WHERE b.group_id IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.rank_id(+) = b.rank_id
AND a.language(+)=USERENV(''LANG'')
AND b.product_category_id = &ITEM+ENI_ITEM_VBH_CAT
AND b.umark = 1
order by rank_code
)
)
WHERE age_3_below > 0
AND age_3_to_7 > 0
AND age_8_to_14 > 0
AND age_15_to_21 > 0
AND age_22_to_28 > 0
AND age_29_to_35 > 0
AND age_36_to_42 > 0
AND age_42_to_above > 0
&ORDER_BY_CLAUSE';
END IF;
  x_custom_sql := l_query;
  x_custom_output.EXTEND;


   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
      --test('GET_LEAD_AGING_QU_SQL', 'EXCEPTION','test',l_error_msg);
 END;

-- Start of comments
-- NAME
--    GET_LEAD_QUALITY_SQL
--
-- PURPOSE
--    Returns the Lead Quality query.
--
--
-- End of comments

PROCEDURE GET_LEAD_QUALITY_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(10000) := NULL;
      l_error_msg varchar2(4000);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_url_str VARCHAR2(1000);
      l_url_str1 VARCHAR2(1000);
      l_url_str2 VARCHAR2(1000);
      l_url_str3 VARCHAR2(1000);
      l_url_str4 VARCHAR2(1000);
      l_url_str5 VARCHAR2(1000);
      l_resource_id VARCHAR2(20);
      l_view_name  VARCHAR2(1000);



l_Metric_a   varchar2(15);
l_Metric_b   varchar2(15);
l_Metric_c   varchar2(15);
l_Metric_d   varchar2(15);
l_Metric_e   varchar2(15);

/* First query */
l_col1_a   VARCHAR2(200) ;
l_col2_a   VARCHAR2(200) ;
l_col3_a   VARCHAR2(200) ;
l_tables_a VARCHAR2(500);
l_where_a  VARCHAR2(1000);

/* Second query */
l_col1_b   VARCHAR2(200) ;
l_col2_b   VARCHAR2(200) ;
l_col3_b   VARCHAR2(200) ;
l_tables_b VARCHAR2(500);
l_where_b  VARCHAR2(1000);

l_col_by  varchar2(5000);
l_report_name varchar2(5000);
l_view_id     varchar2(5000);
l_rpt_name varchar2(5000);
l_camp_id  varchar2(100);
l_close_rs   VARCHAR2(500);
l_context       VARCHAR2(5000);
l_context_info      varchar2(1000);
l_qry_sg VARCHAR2(20000);

   BEGIN
   l_col3_a   := '0';
   l_col3_b   := '0';
      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

      get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
                 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
                 p_curr_page_time_id        => l_curr_page_time_id,
                 p_prev_page_time_id        => l_prev_page_time_id,
                 l_view_by                 =>  l_view_by	  ,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );

 IF l_org_sg is null THEN

   l_query := 'SELECT
NULL VIEWBY,
NULL VIEWBYID,
NULL BIM_MEASURE1,
NULL BIM_MEASURE2,
NULL BIM_MEASURE3,
NULL BIM_MEASURE4,
NULL BIM_MEASURE5,
NULL BIM_MEASURE6,
NULL BIM_MEASURE8,
NULL BIM_MEASURE7,
NULL BIM_MEASURE9,
NULL BIM_URL1,
NULL BIM_URL2,
NULL BIM_URL3,
NULL BIM_URL4,
NULL BIM_URL5,
NULL BIM_URL6,
NULL BIM_URL7,
NULL BIM_GRAND_TOTAL1,
NULL BIM_GRAND_TOTAL2,
NULL BIM_GRAND_TOTAL3,
NULL BIM_GRAND_TOTAL4,
NULL BIM_GRAND_TOTAL5,
NULL BIM_GRAND_TOTAL6,
NULL bim_GRAND_TOTAL7,
NULL bim_GRAND_TOTAL8,
NULL bim_GRAND_TOTAL9
FROM dual';

ELSE


 if    l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'     then
  l_view_name:=L_viewby_sg;      -- 'Sales Group'
elsif l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'                then
  l_view_name:=L_viewby_pc ;     --'Product Category'
elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE'	 then
  l_view_name:=L_viewby_ls;      --'Lead Source'
elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY' then
  l_view_name:=L_viewby_lq;      --'Lead Quality'
elsif l_view_by = 'GEOGRAPHY+COUNTRY'			 then
  l_view_name:=L_viewby_c;       --'Country'
elsif l_view_by = 'SALES CHANNEL+SALES CHANNEL'	 then
  l_view_name:=L_viewby_sc;      --'Sales Channel'
elsif l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY'	 then
  l_view_name:=L_viewby_cc;      --'Customer Category'
end if;

      l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
      l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';

   l_url_str:='pFunctionName=BIM_I_LEAD_QUALITY_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';

-- "LEAD_QUALITY" report name is send as "Q" to crunch URL string within 300 characters

   l_url_str1:='pFunctionName=BIM_I_LD_DETAIL_F&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=Q&BIM_PARAMETER3=';
   l_url_str2:='pFunctionName=BIM_I_LD_DETAIL_F&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=Q&BIM_PARAMETER3=';
   l_url_str3:='pFunctionName=BIM_I_LD_DETAIL_F&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=Q&BIM_PARAMETER3=';
   l_url_str4:='pFunctionName=BIM_I_LD_DETAIL_F&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=Q&BIM_PARAMETER3=';
   l_url_str5:='pFunctionName=BIM_I_LD_DETAIL_F&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=Q&BIM_PARAMETER3=';


   l_rpt_name:='&BIM_PARAMETER2=';
   l_context_info:='&BIM_PARAMETER4='||l_view_name||' :''||BIM_SALES_GROUP||''''';
   l_Metric_a   := 'A';
   l_Metric_b   := 'B';
   l_Metric_c   := 'C';
   l_Metric_d   := 'D';
   l_Metric_e   := 'E';

 --test('category_id',l_category_id );
  IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
if (l_category_id is null)
then
   /* Start assigning the local variables to be substituted in the query */
   IF l_resource_id is null then

  /* First query */
  l_col1_a   := ' d.group_name ';
  l_col2_a   := ' b.group_id ';
  l_tables_a := ' jtf_rs_groups_denorm den,BIM_I_LD_GEN_SG_MV b,jtf_rs_groups_tl d ';
  l_where_a  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
  AND b.group_id=d.group_id
  AND d.language=USERENV(''LANG'')
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ';

  /* Second query */
  l_col1_b   := ' a.source_name ';
  l_col2_b   := ' a.resource_id||''.''||b.group_id ';
  l_col3_b   := '1';
  l_tables_b := ' BIM_I_LD_GEN_SG_MV b ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id <> :l_resource_id';

    ELSE

  /* Second query */
  l_col1_b   := ' a.source_name ';
  l_col2_b   := ' a.resource_id||''.''||b.group_id ';
  l_col3_b   := '1';
  l_tables_b := ' BIM_I_LD_GEN_SG_MV b ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id = :l_group_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ' ;

    END IF;

else

   IF l_resource_id is null then
  /* First query */
  l_col1_a   := ' d.group_name ';
  l_col2_a   := ' b.group_id ';
  l_tables_a := ' jtf_rs_groups_denorm den,BIM_I_LP_GEN_SG_MV b,jtf_rs_groups_tl d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_a  := ' AND den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
  AND b.group_id=d.group_id
  AND d.language=USERENV(''LANG'')
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT ';

  /* Second query */
  l_col1_b   := ' a.source_name ';
  l_col2_b   := ' a.resource_id||''.''||b.group_id ';
  l_col3_b   := '1';
  l_tables_b := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id in(&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id <> :l_resource_id ';

    ELSE

  /* Second query */
  l_col1_b   := ' a.source_name ';
  l_col2_b   := ' a.resource_id||''.''||b.group_id ';
  l_col3_b   := '1';
  l_tables_b := ' BIM_I_LP_GEN_SG_MV b, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id = :l_group_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =   &ITEM+ENI_ITEM_VBH_CAT
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id   ' ;

    END IF;

end if;

/* View by Category*/
ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
if (l_category_id is null) then
 /* If Sales Rep is not selected */
 IF (l_resource_id is null) THEN
l_query := '
SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       RANK_A BIM_ATTRIBUTE1,
       RANK_B BIM_ATTRIBUTE2,
       RANK_C BIM_ATTRIBUTE3,
       RANK_D BIM_ATTRIBUTE4,
       RANK_Z BIM_ATTRIBUTE5,
       RANK_TOTAL BIM_ATTRIBUTE6,
       decode(SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER(),0,0,((RANK_TOTAL * 100)/ SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER())) BIM_ATTRIBUTE7,
       LEADS_QUALIFIED BIM_ATTRIBUTE8,
       RANK_A BIM_ATTRIBUTE9,
       LEADS_QUALIFIED BIM_ATTRIBUTE13,
       NULL BIM_ATTRIBUTE14,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
       (RANK_TOTAL - (RANK_A + RANK_B)) BIM_ATTRIBUTE16,
       decode(VIEWBYID,-1,null,decode(RANK_A,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
       decode(VIEWBYID,-1,null,decode(RANK_B,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
       decode(VIEWBYID,-1,null,decode(RANK_C,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
       decode(VIEWBYID,-1,null,decode(RANK_D,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
       decode(VIEWBYID,-1,null,decode(RANK_Z,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL1,
       SUM(RANK_B) OVER() BIM_GRAND_TOTAL2,
       SUM(RANK_C) OVER() BIM_GRAND_TOTAL3,
       SUM(RANK_D) OVER() BIM_GRAND_TOTAL4,
       SUM(RANK_Z) OVER() BIM_GRAND_TOTAL5,
       SUM(RANK_TOTAL) OVER() BIM_GRAND_TOTAL6,
       decode(SUM(RANK_TOTAL) OVER(),0,0,(SUM(RANK_TOTAL) OVER()) * 100/(SUM(RANK_TOTAL) OVER())) BIM_GRAND_TOTAL7,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL8,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL9,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL10
FROM
(
/*Others for sales group*/
select /*+ leading(c) */
p.value BIM_SALES_GROUP,
p.parent_id VIEWBYID,
p.leaf_node_flag leaf_node_flag,
sum(rank_a) rank_a,
sum(rank_b) rank_b,
sum(rank_c) rank_c,
sum(rank_d) rank_d,
sum(rank_z) rank_z,
sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d
    , BIM_I_LP_GEN_SG_MV b
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id =:l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
HAVING SUM(RANK_A) > 0
OR SUM(RANK_B) > 0
OR SUM(RANK_C) > 0
OR SUM(RANK_D) > 0
OR SUM(RANK_Z) > 0
) &ORDER_BY_CLAUSE';
ELSE
 /* If Sales Rep is selected */
l_query := '
SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       RANK_A BIM_ATTRIBUTE1,
       RANK_B BIM_ATTRIBUTE2,
       RANK_C BIM_ATTRIBUTE3,
       RANK_D BIM_ATTRIBUTE4,
       RANK_Z BIM_ATTRIBUTE5,
       RANK_TOTAL BIM_ATTRIBUTE6,
       decode(SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER(),0,0,((RANK_TOTAL * 100)/ SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER())) BIM_ATTRIBUTE7,
       LEADS_QUALIFIED BIM_ATTRIBUTE8,
       RANK_A BIM_ATTRIBUTE9,
       LEADS_QUALIFIED BIM_ATTRIBUTE13,
       NULL BIM_ATTRIBUTE14,
       DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
       (RANK_TOTAL - (RANK_A + RANK_B)) BIM_ATTRIBUTE16,
  decode(VIEWBYID,-1,null,decode(RANK_A,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,-1,null,decode(RANK_B,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,-1,null,decode(RANK_C,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,-1,null,decode(RANK_D,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,-1,null,decode(RANK_Z,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL1,
       SUM(RANK_B) OVER() BIM_GRAND_TOTAL2,
       SUM(RANK_C) OVER() BIM_GRAND_TOTAL3,
       SUM(RANK_D) OVER() BIM_GRAND_TOTAL4,
       SUM(RANK_Z) OVER() BIM_GRAND_TOTAL5,
       SUM(RANK_TOTAL) OVER() BIM_GRAND_TOTAL6,
       decode(SUM(RANK_TOTAL) OVER(),0,0,(SUM(RANK_TOTAL) OVER()) * 100/(SUM(RANK_TOTAL) OVER())) BIM_GRAND_TOTAL7,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL8,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL9,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL10
FROM
(
/*Others for sales group*/
select /*+ leading(c) */
p.value BIM_SALES_GROUP,
p.parent_id VIEWBYID,
p.leaf_node_flag leaf_node_flag,
sum(rank_a) rank_a,
sum(rank_b) rank_b,
sum(rank_c) rank_c,
sum(rank_d) rank_d,
sum(rank_z) rank_z,
sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p
     ,eni_denorm_hierarchies edh
     ,mtl_default_category_sets d, BIM_I_LP_GEN_SG_MV b
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = d.category_set_id
AND d.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
HAVING SUM(RANK_A) > 0
OR SUM(RANK_B) > 0
OR SUM(RANK_C) > 0
OR SUM(RANK_D) > 0
OR SUM(RANK_Z) > 0
) &ORDER_BY_CLAUSE';
END IF;
else

/*Catgeory not equal to all*/

 /* If Sales Rep is not selected */
 IF (l_resource_id is null) THEN
l_query := '
SELECT BIM_SALES_GROUP VIEWBY,
 VIEWBYID,
 RANK_A BIM_ATTRIBUTE1,
 RANK_B BIM_ATTRIBUTE2,
 RANK_C BIM_ATTRIBUTE3,
 RANK_D BIM_ATTRIBUTE4,
 RANK_Z BIM_ATTRIBUTE5,
 RANK_TOTAL BIM_ATTRIBUTE6,
 decode(SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER(),0,0,((RANK_TOTAL * 100)/ SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER())) BIM_ATTRIBUTE7,
 LEADS_QUALIFIED BIM_ATTRIBUTE8,
 RANK_A BIM_ATTRIBUTE9,
 LEADS_QUALIFIED BIM_ATTRIBUTE13,
 NULL BIM_ATTRIBUTE14,
 DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
 (RANK_TOTAL - (RANK_A + RANK_B)) BIM_ATTRIBUTE16,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_A = 0 THEN NULL ELSE '||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL1,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_B = 0 THEN NULL ELSE '||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL2,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_C = 0 THEN NULL ELSE '||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL3,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_D = 0 THEN NULL ELSE '||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL4,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_Z = 0 THEN NULL ELSE '||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL5,
 SUM(RANK_A) OVER() BIM_GRAND_TOTAL1,SUM(RANK_B) OVER() BIM_GRAND_TOTAL2,SUM(RANK_C) OVER() BIM_GRAND_TOTAL3,SUM(RANK_D) OVER() BIM_GRAND_TOTAL4,
 SUM(RANK_Z) OVER() BIM_GRAND_TOTAL5,SUM(RANK_TOTAL) OVER() BIM_GRAND_TOTAL6,
 decode(SUM(RANK_TOTAL) OVER(),0,0,(SUM(RANK_TOTAL) OVER()) * 100/(SUM(RANK_TOTAL) OVER())) BIM_GRAND_TOTAL7,
 SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL8,SUM(RANK_A) OVER() BIM_GRAND_TOTAL9,SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL10
FROM
(
select /*+ leading(c) */
p.value BIM_SALES_GROUP,
p.id VIEWBYID,p.leaf_node_flag leaf_node_flag,
0 dir_flag,sum(rank_a) rank_a,sum(rank_b) rank_b,
sum(rank_c) rank_c,sum(rank_d) rank_d,sum(rank_z) rank_z,
sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.resource_id = :l_resource_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
p.id VIEWBYID,
''Y'' leaf_node_flag,
1 dir_flag,
sum(rank_a) rank_a,
sum(rank_b) rank_b,
sum(rank_c) rank_c,
sum(rank_d) rank_d,
sum(rank_z) rank_z,
sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
) WHERE RANK_A > 0 OR RANK_B > 0 OR RANK_C > 0 OR RANK_D > 0 OR RANK_Z > 0 &ORDER_BY_CLAUSE';

ELSE
 /* If Sales Rep is selected */

 l_query := '
SELECT BIM_SALES_GROUP VIEWBY,
 VIEWBYID,RANK_A BIM_ATTRIBUTE1,RANK_B BIM_ATTRIBUTE2,RANK_C BIM_ATTRIBUTE3,
 RANK_D BIM_ATTRIBUTE4,RANK_Z BIM_ATTRIBUTE5,RANK_TOTAL BIM_ATTRIBUTE6,
 decode(SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER(),0,0,((RANK_TOTAL * 100)/ SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER())) BIM_ATTRIBUTE7,
 LEADS_QUALIFIED BIM_ATTRIBUTE8,RANK_A BIM_ATTRIBUTE9,LEADS_QUALIFIED BIM_ATTRIBUTE13,NULL BIM_ATTRIBUTE14,
 DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_ATTRIBUTE15,
 (RANK_TOTAL - (RANK_A + RANK_B)) BIM_ATTRIBUTE16,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_A = 0 THEN NULL ELSE '||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL1,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_B = 0 THEN NULL ELSE '||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL2,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_C = 0 THEN NULL ELSE'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'  END  BIM_URL3,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_D = 0 THEN NULL ELSE '||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL4,
 CASE WHEN VIEWBYID = -1 THEN null WHEN dir_flag = 1 THEN null WHEN RANK_Z = 0 THEN NULL ELSE '||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL5,
 SUM(RANK_A) OVER() BIM_GRAND_TOTAL1,
 SUM(RANK_B) OVER() BIM_GRAND_TOTAL2,
 SUM(RANK_C) OVER() BIM_GRAND_TOTAL3,
 SUM(RANK_D) OVER() BIM_GRAND_TOTAL4,
 SUM(RANK_Z) OVER() BIM_GRAND_TOTAL5,
 SUM(RANK_TOTAL) OVER() BIM_GRAND_TOTAL6,
 decode(SUM(RANK_TOTAL) OVER(),0,0,(SUM(RANK_TOTAL) OVER()) * 100/(SUM(RANK_TOTAL) OVER())) BIM_GRAND_TOTAL7,
 SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL8,
 SUM(RANK_A) OVER() BIM_GRAND_TOTAL9,
 SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL10
FROM
(
select /*+ leading(c) */
p.value BIM_SALES_GROUP,p.id VIEWBYID,
p.leaf_node_flag leaf_node_flag,0 dir_flag,sum(rank_a) rank_a,sum(rank_b) rank_b,sum(rank_c) rank_c,
sum(rank_d) rank_d,sum(rank_z) rank_z,sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,leaf_node_flag
              from eni_item_vbh_nodes_v e
              where
              e.parent_id =&ITEM+ENI_ITEM_VBH_CAT
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
    b.group_id = :l_group_id
AND b.product_category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.resource_id = :l_resource_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
GROUP BY p.value,p.id,p.leaf_node_flag
UNION ALL
select /*+ leading(c) */
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
p.id VIEWBYID,''Y'' leaf_node_flag,1 dir_flag,sum(rank_a) rank_a,sum(rank_b) rank_b,
sum(rank_c) rank_c,sum(rank_d) rank_d,sum(rank_z) rank_z,sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c,BIM_I_LP_GEN_SG_MV b ,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p
WHERE
    b.group_id = :l_group_id
AND p.id =  b.product_category_id
AND c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
AND b.time_id=c.time_id
AND b.period_type_id=c.period_type_id
AND b.update_period_type_id = -1
AND b.update_time_id = -1
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
GROUP BY p.value,p.id
) WHERE RANK_A > 0 OR RANK_B > 0 OR RANK_C > 0 OR RANK_D > 0 OR RANK_Z > 0 &ORDER_BY_CLAUSE';
END IF;
END IF;

/*View by Source*/

ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN

if (l_category_id is null)
then
   /* Start assigning the local variables to be substituted in the query */
   IF l_resource_id is null then

  /* First query */
  l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_a   := ' decode(d.meaning,null,null,b.lead_source) ';
  l_tables_a := ' BIM_I_LD_SRC_MV b,as_lookups d ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND b.lead_source = d.lookup_code(+)
  AND d.lookup_type (+) = ''SOURCE_SYSTEM''
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ';

    ELSE

  /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_b   := ' decode(d.meaning,null,null,b.lead_source) ';
  l_tables_b := ' BIM_I_LD_SRC_MV b, as_lookups d ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.lead_source = d.lookup_code(+)
  AND d.lookup_type (+) = ''SOURCE_SYSTEM''
  AND b.group_id = :l_group_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id  ' ;

    END IF;

else

   IF l_resource_id is null then
  /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_a   := ' decode(d.meaning,null,null,b.lead_source) ';
  l_tables_a := ' BIM_I_LP_SRC_MV b,as_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND b.lead_source = d.lookup_code(+)
  AND d.lookup_type (+) = ''SOURCE_SYSTEM''
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

  /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_b   := ' decode(d.meaning,null,null,b.lead_source) ';
  l_tables_b := ' BIM_I_LP_SRC_MV b, as_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id = :l_group_id
  AND b.lead_source = d.lookup_code(+)
  AND d.lookup_type (+) = ''SOURCE_SYSTEM''
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
  AND b.resource_id = :l_resource_id
        AND b.update_time_id = -1
  AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
    END IF;

end if;

/*View by Sales Channel */

ELSIF (l_view_by = 'SALES CHANNEL+SALES CHANNEL') THEN

if (l_category_id is null)
then
   /* Start assigning the local variables to be substituted in the query */
   IF l_resource_id is null then

  /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_a   := ' decode(d.meaning,null,null,b.channel_code) ';
  l_tables_a := ' BIM_I_LD_CHNL_MV b,so_lookups d ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND b.channel_code = d.lookup_code(+)
  AND d.lookup_type (+) = ''SALES_CHANNEL''
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ';

    ELSE

  /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_b   := ' decode(d.meaning,null,null,b.channel_code) ';
  l_tables_b := ' BIM_I_LD_CHNL_MV b, so_lookups d ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.channel_code = d.lookup_code(+)
  AND d.lookup_type (+) = ''SALES_CHANNEL''
  AND b.group_id = :l_group_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ';

    END IF;

else

   IF l_resource_id is null then
  /* First query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_a   := ' decode(d.meaning,null,null,b.channel_code) ';
  l_tables_a := ' BIM_I_LP_CHNL_MV b,so_lookups d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND b.channel_code = d.lookup_code(+)
  AND d.lookup_type (+) = ''SALES_CHANNEL''
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';

    ELSE

  /* Second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
  l_col2_b   := ' decode(d.meaning,null,null,b.channel_code) ';
  l_tables_b := ' BIM_I_LP_CHNL_MV b, so_lookups d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id = :l_group_id
  AND b.channel_code = d.lookup_code(+)
  AND d.lookup_type (+) = ''SALES_CHANNEL''
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
  AND b.resource_id = :l_resource_id
        AND b.update_time_id = -1
  AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
    END IF;

end if;

/*View by Customer Category */

ELSIF (l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN

if (l_category_id is null)
then
   /* Start assigning the local variables to be substituted in the query */
   IF l_resource_id is null then

  /* First query */
        l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
  l_col2_a   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
  l_tables_a := ' BIM_I_LD_CCAT_MV b,bic_cust_category_v d ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND d.customer_category_code (+) = b.cust_category
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ';
    ELSE
  /* Second query */
        l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
  l_col2_b   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
  l_tables_b := ' BIM_I_LD_CCAT_MV b, bic_cust_category_v d ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND d.customer_category_code (+) = b.cust_category
  AND b.group_id = :l_group_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id  ' ;

    END IF;

else

   IF l_resource_id is null then
  /* First query */
        l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
  l_col2_a   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
  l_tables_a := ' BIM_I_LP_CCAT_MV b,bic_cust_category_v d, eni_denorm_hierarchies edh,mtl_default_category_sets mtl  ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND d.customer_category_code (+) = b.cust_category
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
    ELSE

  /* Second query */
        l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
  l_col2_b   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
  l_tables_b := ' BIM_I_LP_CCAT_MV b, bic_cust_category_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id = :l_group_id
  AND d.customer_category_code (+) = b.cust_category
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
  AND b.resource_id = :l_resource_id
        AND b.update_time_id = -1
  AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
    END IF;

end if;

/*View by Country */

ELSIF (l_view_by = 'GEOGRAPHY+COUNTRY') THEN

if (l_category_id is null)
then
   /* Start assigning the local variables to be substituted in the query */
   IF l_resource_id is null then

  /* First query */
        l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
  l_col2_a   := ' decode(d.name,null,null,b.lead_country) ';
  l_tables_a := ' BIM_I_LD_REGN_MV b,bis_countries_v d ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND d.country_code (+) = b.lead_country
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id ';
    ELSE
  /* Second query */
        l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
  l_col2_b   := ' decode(d.name,null,null,b.lead_country) ';
  l_tables_b := ' BIM_I_LD_REGN_MV b, bis_countries_v d ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND d.country_code (+) = b.lead_country
  AND b.group_id = :l_group_id
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
  AND b.update_time_id= -1
  AND b.update_period_type_id= -1
  AND b.resource_id = :l_resource_id  ' ;

    END IF;

else

   IF l_resource_id is null then
  /* First query */
        l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
  l_col2_a   := ' decode(d.name,null,null,b.lead_country) ';
  l_tables_a := ' BIM_I_LP_REGN_MV b,bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_a  := ' AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
  AND d.country_code (+) = b.lead_country
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
        AND b.update_time_id = -1
  AND b.resource_id = :l_resource_id
        AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
  AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
    ELSE
  /* Second query */
        l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
  l_col2_b   := ' decode(d.name,null,null,b.lead_country) ';
  l_tables_b := ' BIM_I_LP_REGN_MV b, bis_countries_v d , eni_denorm_hierarchies edh,mtl_default_category_sets mtl ';
  l_where_b  := ' AND a.resource_id=b.resource_id
  AND b.group_id = :l_group_id
        AND d.country_code (+) = b.lead_country
  AND b.time_id=c.time_id
  AND b.period_type_id=c.period_type_id
        AND b.update_period_type_id = -1
  AND b.resource_id = :l_resource_id
        AND b.update_time_id = -1
  AND b.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id
        AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y'' AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT ';
    END IF;

end if;

end if;

-- ===================== Query Formation =============================
/* This is the dynamic query to be used with variables replaced*/
IF (l_view_by <> 'ITEM+ENI_ITEM_VBH_CAT')  THEN
  IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP')  THEN
  l_qry_sg :=
  'UNION ALL /*for reps*/
   SELECT /*+ leading(c) */
         '||l_col1_b||' BIM_SALES_GROUP,
         to_char( '||l_col2_b||' ) VIEWBYID,
         '||l_col3_b||' is_resource,
         sum(rank_a) rank_a,
         sum(rank_b) rank_b,
         sum(rank_c) rank_c,
         sum(rank_d) rank_d,
         sum(rank_z) rank_z,
         sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
         sum(leads_qualified) leads_qualified
  FROM FII_TIME_RPT_STRUCT c , JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_b|| '
  WHERE c.calendar_id=-1
  AND c.report_date = &BIS_CURRENT_ASOF_DATE
  AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
  '||l_where_b||'
  GROUP BY '||l_col1_b||','||l_col2_b||','||l_col3_b;
  ELSE
    l_qry_sg :=  NULL;
  END IF;

IF l_resource_id is null THEN
/* This query needs to be executed in case if Sales Rep is not passed */

l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       RANK_A BIM_ATTRIBUTE1,
       RANK_B BIM_ATTRIBUTE2,
       RANK_C BIM_ATTRIBUTE3,
       RANK_D BIM_ATTRIBUTE4,
       RANK_Z BIM_ATTRIBUTE5,
       RANK_TOTAL BIM_ATTRIBUTE6,
       decode(SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER(),0,0,((RANK_TOTAL * 100)/ SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER())) BIM_ATTRIBUTE7,
       LEADS_QUALIFIED BIM_ATTRIBUTE8,
       RANK_A BIM_ATTRIBUTE9,
       LEADS_QUALIFIED BIM_ATTRIBUTE13,
       DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_ATTRIBUTE14,
       NULL BIM_ATTRIBUTE15,
       (RANK_TOTAL - (RANK_A + RANK_B)) BIM_ATTRIBUTE16,
  decode(VIEWBYID,null,null,decode(RANK_A,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,null,null,decode(RANK_B,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,null,null,decode(RANK_C,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,null,null,decode(RANK_D,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,null,null,decode(RANK_Z,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL1,
       SUM(RANK_B) OVER() BIM_GRAND_TOTAL2,
       SUM(RANK_C) OVER() BIM_GRAND_TOTAL3,
       SUM(RANK_D) OVER() BIM_GRAND_TOTAL4,
       SUM(RANK_Z) OVER() BIM_GRAND_TOTAL5,
       SUM(RANK_TOTAL) OVER() BIM_GRAND_TOTAL6,
       decode(SUM(RANK_TOTAL) OVER(),0,0,(SUM(RANK_TOTAL) OVER()) * 100/(SUM(RANK_TOTAL) OVER())) BIM_GRAND_TOTAL7,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL8,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL9,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL10
FROM
  (
  SELECT BIM_SALES_GROUP,
  VIEWBYID,
  is_resource,
  sum(rank_a) rank_a,
  sum(rank_b) rank_b,
  sum(rank_c) rank_c,
  sum(rank_d) rank_d,
  sum(rank_z) rank_z,
  sum(rank_total) rank_total,
  sum(leads_qualified) leads_qualified
  FROM
(
/*For sales group*/
select /*+ leading(c) */
       '||l_col1_a||' BIM_SALES_GROUP,
       to_char( '||l_col2_a||' ) VIEWBYID,
       '||l_col3_a||' is_resource,
       sum(rank_a) rank_a,
       sum(rank_b) rank_b,
       sum(rank_c) rank_c,
       sum(rank_d) rank_d,
       sum(rank_z) rank_z,
       sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
       sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c , '|| l_tables_a|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_a||'
GROUP BY '||l_col1_a||','||l_col2_a||','||l_col3_a||l_qry_sg||'
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
HAVING SUM(RANK_A) > 0
OR SUM(RANK_B) > 0
OR SUM(RANK_C) > 0
OR SUM(RANK_D) > 0
OR SUM(RANK_Z) > 0
)
&ORDER_BY_CLAUSE';
ELSE
/* This query needs to be executed in case if Sales Rep is passed */
l_query := 'SELECT BIM_SALES_GROUP VIEWBY,
       VIEWBYID,
       RANK_A BIM_ATTRIBUTE1,
       RANK_B BIM_ATTRIBUTE2,
       RANK_C BIM_ATTRIBUTE3,
       RANK_D BIM_ATTRIBUTE4,
       RANK_Z BIM_ATTRIBUTE5,
       RANK_TOTAL BIM_ATTRIBUTE6,
       decode(SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER(),0,0,((RANK_TOTAL * 100)/ SUM(RANK_A + RANK_B + RANK_C + RANK_D + RANK_Z) OVER())) BIM_ATTRIBUTE7,
       LEADS_QUALIFIED BIM_ATTRIBUTE8,
       RANK_A BIM_ATTRIBUTE9,
       LEADS_QUALIFIED BIM_ATTRIBUTE13,
       DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_ATTRIBUTE14,
       NULL BIM_ATTRIBUTE15,
       (RANK_TOTAL - (RANK_A + RANK_B)) BIM_ATTRIBUTE16,
  decode(VIEWBYID,null,null,decode(RANK_A,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,null,null,decode(RANK_B,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,null,null,decode(RANK_C,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,null,null,decode(RANK_D,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,null,null,decode(RANK_Z,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL1,
       SUM(RANK_B) OVER() BIM_GRAND_TOTAL2,
       SUM(RANK_C) OVER() BIM_GRAND_TOTAL3,
       SUM(RANK_D) OVER() BIM_GRAND_TOTAL4,
       SUM(RANK_Z) OVER() BIM_GRAND_TOTAL5,
       SUM(RANK_TOTAL) OVER() BIM_GRAND_TOTAL6,
       decode(SUM(RANK_TOTAL) OVER(),0,0,(SUM(RANK_TOTAL) OVER()) * 100/(SUM(RANK_TOTAL) OVER())) BIM_GRAND_TOTAL7,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL8,
       SUM(RANK_A) OVER() BIM_GRAND_TOTAL9,
       SUM(LEADS_QUALIFIED) OVER() BIM_GRAND_TOTAL10
FROM
(
  SELECT BIM_SALES_GROUP,
  VIEWBYID,
  is_resource,
  sum(rank_a) rank_a,
  sum(rank_b) rank_b,
  sum(rank_c) rank_c,
  sum(rank_d) rank_d,
  sum(rank_z) rank_z,
  sum(rank_total) rank_total,
  sum(leads_qualified) leads_qualified
  FROM
(
/*For reps*/
 SELECT /*+ leading(c) */
       '||l_col1_b||' BIM_SALES_GROUP,
       to_char('||l_col2_b||' ) VIEWBYID,
       '||l_col3_b||' is_resource,
       sum(rank_a) rank_a,
       sum(rank_b) rank_b,
       sum(rank_c) rank_c,
       sum(rank_d) rank_d,
       sum(rank_z) rank_z,
       sum(rank_a + rank_b + rank_c + rank_d + rank_z) rank_total,
       sum(leads_qualified) leads_qualified
FROM FII_TIME_RPT_STRUCT c ,JTF_RS_RESOURCE_EXTNS_VL a, '|| l_tables_b|| '
WHERE c.calendar_id=-1
AND c.report_date = &BIS_CURRENT_ASOF_DATE
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id
'||l_where_b||'
GROUP BY '||l_col1_b||','||l_col2_b||','||l_col3_b||'
)
GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
HAVING SUM(RANK_A) > 0
OR SUM(RANK_B) > 0
OR SUM(RANK_C) > 0
OR SUM(RANK_D) > 0
OR SUM(RANK_Z) > 0
)
&ORDER_BY_CLAUSE';
END IF;
END IF;

END IF;
-- ========================================================================

 /* Earlier l_resource_id was hardcoded to -1 ,to enable binding below code was added */

   IF l_resource_id is null then
      l_resource_id:= -1;
   END IF;

  x_custom_sql := l_query;

  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name      := ':l_group_id';
  l_custom_rec.attribute_value     := l_org_sg;
  l_custom_rec.attribute_type      := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

   --test('GET_LEAD_QUALITY_SQL','QUERY','',l_query);

   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
      --test('GET_LEAD_ACT_SQL', 'EXCEPTION','test',l_error_msg);
   END;


-- Start of comments
-- NAME
--    GET_LEAD_AGING_SG_SQL
--
-- PURPOSE
--    Returns the Lead Aging by Sales Group query.
--
-- NOTES
--
-- HISTORY
-- 08/27/2002  dmvincen  created.
--
-- End of comments


PROCEDURE GET_LEAD_AGING_SG_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(15000) := NULL;
      l_error_msg varchar2(4000) := NULL;
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_resource_id VARCHAR2(20);
      l_url_str VARCHAR2(1000);

      l_url_str1 VARCHAR2(1000);
      l_url_str2 VARCHAR2(1000);
      l_url_str3 VARCHAR2(1000);
      l_url_str4 VARCHAR2(1000);
      l_url_str5 VARCHAR2(1000);
      l_url_str6 VARCHAR2(1000);
      l_url_str7 VARCHAR2(1000);
      l_url_str8 VARCHAR2(1000);

       /* First query */
      l_col1_a   VARCHAR2(200) ;
      l_col2_a   VARCHAR2(200) ;
      l_col3_a   VARCHAR2(200) ;
      l_tables_a VARCHAR2(500);
      l_where_a  VARCHAR2(1000);

      /* Second query */
      l_col1_b   VARCHAR2(200) ;
      l_col2_b   VARCHAR2(200) ;
      l_col3_b   VARCHAR2(200) ;
      l_tables_b VARCHAR2(500);
      l_where_b  VARCHAR2(1000);

      l_qry_sg VARCHAR2(20000);

      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);


      l_rpt_name  varchar2(2000);
      l_Metric_a   varchar2(15);
      l_Metric_b   varchar2(15);
      l_Metric_c   varchar2(15);
      l_Metric_d   varchar2(15);
      l_Metric_e   varchar2(15);
      l_Metric_f   varchar2(15);
      l_Metric_g  varchar2(15);
      l_Metric_h   varchar2(15);
      l_camp_id  varchar2(100);
      l_close_rs   VARCHAR2(500);
      l_view_name  VARCHAR2(1000);
      l_context       VARCHAR2(5000);
      l_context_info      varchar2(1000);

   BEGIN

   l_col3_a   := '0';
   l_col3_b   := '0';
      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
                 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
                 p_curr_page_time_id        => l_curr_page_time_id,
                 p_prev_page_time_id        => l_prev_page_time_id,
                 l_view_by                 =>  l_view_by	  ,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );

 IF l_org_sg is null THEN

 l_query := 'SELECT
     NULL VIEWBY,
     NULL VIEWBYID,
     NULL BIM_MEASURE1,
     NULL BIM_MEASURE2,
     NULL BIM_MEASURE3,
     NULL BIM_MEASURE4,
     NULL BIM_MEASURE5,
     NULL BIM_MEASURE6,
     NULL BIM_MEASURE8,
     NULL BIM_MEASURE7,
     NULL BIM_MEASURE9,
     NULL BIM_URL1,
     NULL BIM_URL2,
     NULL BIM_URL3,
     NULL BIM_URL4,
     NULL BIM_URL5,
     NULL BIM_URL6,
     NULL BIM_URL7,
     NULL BIM_GRAND_TOTAL1,
     NULL BIM_GRAND_TOTAL2,
     NULL BIM_GRAND_TOTAL3,
     NULL BIM_GRAND_TOTAL4,
     NULL BIM_GRAND_TOTAL5,
     NULL BIM_GRAND_TOTAL6,
     NULL bim_GRAND_TOTAL7,
     NULL bim_GRAND_TOTAL8,
     NULL bim_GRAND_TOTAL9
   FROM dual';

 ELSE

 if    l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'     then
  l_view_name:=L_viewby_sg;      -- 'Sales Group'
elsif l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'                then
  l_view_name:=L_viewby_pc ;     --'Product Category'
elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE'	 then
  l_view_name:=L_viewby_ls;      --'Lead Source'
elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY' then
  l_view_name:=L_viewby_lq;      --'Lead Quality'
elsif l_view_by = 'GEOGRAPHY+COUNTRY'			 then
  l_view_name:=L_viewby_c;       --'Country'
elsif l_view_by = 'SALES CHANNEL+SALES CHANNEL'	 then
  l_view_name:=L_viewby_sc;      --'Sales Channel'
elsif l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY'	 then
  l_view_name:=L_viewby_cc;      --'Customer Category'
end if;

l_url_str:='pFunctionName=BIM_I_LEAD_AGE_SG_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';

-- "LEAD_AGING" report name is send as "G" to crunch URL string within 300 characters


l_url_str1:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str2:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str3:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str4:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str5:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str6:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str7:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';
l_url_str8:='pFunctionName=BIM_I_LD_DETAIL_AF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=G&BIM_PARAMETER3=';

l_rpt_name:='&BIM_PARAMETER2=';
l_context_info:='&BIM_PARAMETER4='||l_view_name||' :''||BIM_SALES_GROUP||''''';

l_Metric_a   := 'A';
l_Metric_b   := 'B';
l_Metric_c   := 'C';
l_Metric_d   := 'D';
l_Metric_e   := 'E';
l_Metric_f   := 'F';
l_Metric_g   := 'G';
l_Metric_h   := 'H';

  IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
     if (l_category_id is null) then
         if l_resource_id is null then
      /* first query */
            l_col1_a   := ' a.source_name ';
            l_col2_a   := ' a.resource_id||''.''||b.group_id ';
            l_col3_a   := '1';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b ';
            l_where_a  := ' a.resource_id=b.resource_id
            AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                AND b.dim_id=''ALL''
            AND b.resource_id <> :l_resource_id ';
        /* second query */
        l_col1_b   := ' d.group_name ';
        l_col2_b   := ' b.group_id ';
        l_tables_b := ' jtf_rs_groups_denorm den,BIM_I_LD_AGE_SG_MV b,jtf_rs_groups_tl d ';
        l_where_b  := ' den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
        AND b.group_id=d.group_id
        AND d.language=USERENV(''LANG'')
        AND b.dim_id=''ALL''
        AND b.resource_id = :l_resource_id ';
        else
       /* first query */
            l_col1_a   := ' a.source_name ';
            l_col2_a   := ' a.resource_id||''.''||b.group_id ';
            l_col3_a   := '1';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b ';
            l_where_a  := ' a.resource_id=b.resource_id
            AND b.group_id = :l_group_id
                AND b.dim_id=''ALL''
            AND b.resource_id =:l_resource_id ' ;
      end if;
    else
     if l_resource_id is null then
    /* first query */
          l_col1_a   := ' a.source_name ';
          l_col2_a   := ' a.resource_id||''.''||b.group_id ';
          l_col3_a   := '1';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b ';
          l_where_a  := '  a.resource_id=b.resource_id
          AND b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                AND b.dim_id=''ALL''
          AND b.resource_id <> :l_resource_id
                AND b.umark=1
                AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';

  /* second query */
      l_col1_b   := ' d.group_name ';
      l_col2_b   := ' b.group_id ';
      l_tables_b := ' jtf_rs_groups_denorm den,BIM_I_LP_AGE_SG_MV b,jtf_rs_groups_tl d ';
      l_where_b  := ' den.parent_group_id in (&ORGANIZATION+JTF_ORG_SALES_GROUP)
        AND d.group_id=den.group_id
        AND den.immediate_parent_flag = ''Y''
        AND den.latest_relationship_flag = ''Y''
        AND b.group_id=d.group_id
        AND d.language=USERENV(''LANG'')
        AND b.resource_id =:l_resource_id
        AND b.dim_id=''ALL''
        AND b.umark=1
        AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';
      else

     /* first query */
          l_col1_a   := ' a.source_name ';
          l_col2_a   := ' a.resource_id||''.''||b.group_id ';
          l_col3_a   := '1';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b ';
          l_where_a  := '  a.resource_id=b.resource_id
          AND b.group_id = :l_group_id
                AND b.dim_id=''ALL''
                AND b.umark=1
                AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT
          AND b.resource_id = :l_resource_id ';
    end if;
   end if;
ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
/*view by Category*/
if (l_category_id is null) then
if l_resource_id is null then
    l_query :=
     'SELECT BIM_SALES_GROUP VIEWBY, VIEWBYID,
    age_3_below BIM_MEASURE1, age_3_to_7 BIM_MEASURE2,
    age_8_to_14 BIM_MEASURE3, age_15_to_21 BIM_MEASURE4,
    age_22_to_28 BIM_MEASURE5, age_29_to_35 BIM_MEASURE6,
    age_36_to_42 BIM_MEASURE7, age_42_to_above BIM_MEASURE8,
    (age_3_below + age_3_to_7 + age_8_to_14 + age_15_to_21 +
    age_22_to_28 + age_29_to_35 + age_36_to_42 + age_42_to_above)  BIM_MEASURE9,
    NULL BIM_MEASURE10,
    DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_MEASURE11,
  decode(VIEWBYID,-1,null,decode(age_3_below,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,-1,null,decode(age_3_to_7,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,-1,null,decode(age_8_to_14,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,-1,null,decode(age_15_to_21,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,-1,null,decode(age_22_to_28,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,-1,null,decode(age_29_to_35,0,NULL,'||''''||l_url_str6||''''||'||'||''''||l_Metric_f||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,-1,null,decode(age_36_to_42,0,NULL,'||''''||l_url_str7||''''||'||'||''''||l_Metric_g||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  decode(VIEWBYID,-1,null,decode(age_42_to_above,0,NULL,'||''''||l_url_str8||''''||'||'||''''||l_Metric_h||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL8,
    SUM(age_3_below) over() BIM_GRAND_TOTAL1,
    SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
    SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
    SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
    SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
    SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
    SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
    SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
    SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
    age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
    FROM (
    SELECT e.value BIM_SALES_GROUP,b.product_category_id VIEWBYID,e.leaf_node_flag leaf_node_flag,
    sum(age_3_below) age_3_below, sum(age_3_to_7) age_3_to_7, sum(age_8_to_14) age_8_to_14,
    sum(age_15_to_21) age_15_to_21, sum(age_22_to_28) age_22_to_28, sum(age_29_to_35) age_29_to_35,
    sum(age_36_to_42) age_36_to_42, sum(age_42_to_above) age_42_to_above,
    1 row_order
    FROM BIM_I_LP_AGE_SG_MV  b,ENI_ITEM_VBH_NODES_V e
    WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
    AND e.parent_id = b.product_category_id
    AND e.parent_id = e.child_id
    AND e.top_node_flag = ''Y''
    AND b.resource_id = :l_resource_id
    AND b.dim_id=''ALL''
    AND b.umark = 1
    GROUP BY e.value,b.product_category_id,e.leaf_node_flag
    HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
    ) &ORDER_BY_CLAUSE';
  else
  l_query :=
     'SELECT BIM_SALES_GROUP VIEWBY,VIEWBYID,
    age_3_below BIM_MEASURE1, age_3_to_7 BIM_MEASURE2,
    age_8_to_14 BIM_MEASURE3, age_15_to_21 BIM_MEASURE4,
    age_22_to_28 BIM_MEASURE5, age_29_to_35 BIM_MEASURE6,
    age_36_to_42 BIM_MEASURE7, age_42_to_above BIM_MEASURE8,
    (age_3_below + age_3_to_7 + age_8_to_14 + age_15_to_21 +
    age_22_to_28 + age_29_to_35 + age_36_to_42 + age_42_to_above)  BIM_MEASURE9,
    NULL BIM_MEASURE10,
    DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_MEASURE11,
  decode(VIEWBYID,-1,null,decode(age_3_below,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,-1,null,decode(age_3_to_7,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,-1,null,decode(age_8_to_14,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,-1,null,decode(age_15_to_21,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,-1,null,decode(age_22_to_28,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,-1,null,decode(age_29_to_35,0,NULL,'||''''||l_url_str6||''''||'||'||''''||l_Metric_f||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,-1,null,decode(age_36_to_42,0,NULL,'||''''||l_url_str7||''''||'||'||''''||l_Metric_g||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  decode(VIEWBYID,-1,null,decode(age_42_to_above,0,NULL,'||''''||l_url_str8||''''||'||'||''''||l_Metric_h||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL8,
    SUM(age_3_below) over() BIM_GRAND_TOTAL1,
    SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
    SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
    SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
    SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
    SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
    SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
    SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
    SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
    age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
    FROM (
    SELECT e.value BIM_SALES_GROUP,b.product_category_id VIEWBYID,e.leaf_node_flag leaf_node_flag,
    sum(age_3_below) age_3_below, sum(age_3_to_7) age_3_to_7, sum(age_8_to_14) age_8_to_14,
    sum(age_15_to_21) age_15_to_21, sum(age_22_to_28) age_22_to_28, sum(age_29_to_35) age_29_to_35,
    sum(age_36_to_42) age_36_to_42, sum(age_42_to_above) age_42_to_above,
    1 row_order
    FROM BIM_I_LP_AGE_SG_MV  b,ENI_ITEM_VBH_NODES_V e
    WHERE
     b.group_id = :l_group_id
    AND e.parent_id = b.product_category_id
    AND e.parent_id = e.child_id
    AND e.top_node_flag = ''Y''
    AND b.resource_id =:l_resource_id
    AND b.dim_id=''ALL''
    AND b.umark = 1
    GROUP BY e.value,b.product_category_id,e.leaf_node_flag
    HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
    ) &ORDER_BY_CLAUSE';
 end if;
else
/*Catgeory not equal to all*/
/*sales group is selected from the page*/
if l_resource_id is null then
    l_query :=
     'SELECT BIM_SALES_GROUP VIEWBY,VIEWBYID,
    age_3_below BIM_MEASURE1, age_3_to_7 BIM_MEASURE2,
    age_8_to_14 BIM_MEASURE3, age_15_to_21 BIM_MEASURE4,
    age_22_to_28 BIM_MEASURE5, age_29_to_35 BIM_MEASURE6,
    age_36_to_42 BIM_MEASURE7, age_42_to_above BIM_MEASURE8,
    (age_3_below + age_3_to_7 + age_8_to_14 + age_15_to_21 +
    age_22_to_28 + age_29_to_35 + age_36_to_42 + age_42_to_above)  BIM_MEASURE9,
    NULL BIM_MEASURE10,
    DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_MEASURE11,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_3_below = 0 THEN NULL ELSE '||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END   BIM_URL1,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_3_to_7 = 0 THEN NULL ELSE '||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'  END BIM_URL2,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_8_to_14 = 0 THEN NULL ELSE '||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL3,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_15_to_21 = 0 THEN NULL ELSE '||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL4,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_22_to_28 = 0 THEN NULL ELSE '||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL5,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_29_to_35 = 0 THEN NULL ELSE '||''''||l_url_str6||''''||'||'||''''||l_Metric_f||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL6,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_36_to_42 = 0 THEN NULL ELSE '||''''||l_url_str7||''''||'||'||''''||l_Metric_g||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL7,
    CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_42_to_above = 0 THEN NULL ELSE '||''''||l_url_str8||''''||'||'||''''||l_Metric_h||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL8,
    SUM(age_3_below) over() BIM_GRAND_TOTAL1,
    SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
    SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
    SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
    SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
    SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
    SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
    SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
    SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
    age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
    FROM (
    SELECT e.value BIM_SALES_GROUP,b.product_category_id VIEWBYID,e.leaf_node_flag leaf_node_flag,0 dir_flag,
    sum(age_3_below) age_3_below, sum(age_3_to_7) age_3_to_7, sum(age_8_to_14) age_8_to_14,
    sum(age_15_to_21) age_15_to_21, sum(age_22_to_28) age_22_to_28, sum(age_29_to_35) age_29_to_35,
    sum(age_36_to_42) age_36_to_42, sum(age_42_to_above) age_42_to_above,
    1 row_order
    FROM BIM_I_LP_AGE_SG_MV  b,ENI_ITEM_VBH_NODES_V e
    WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
    AND e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
    AND e.id =  b.product_category_id
    AND e.id = e.child_id
    AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
    AND b.resource_id = :l_resource_id
    AND b.dim_id=''ALL''
    AND b.umark = 1
    GROUP BY e.value,b.product_category_id,e.leaf_node_flag
    HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
    UNION ALL
    SELECT bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
    b.product_category_id VIEWBYID,e.leaf_node_flag leaf_node_flag,1 dir_flag,
    sum(age_3_below) age_3_below, sum(age_3_to_7) age_3_to_7, sum(age_8_to_14) age_8_to_14,
    sum(age_15_to_21) age_15_to_21, sum(age_22_to_28) age_22_to_28, sum(age_29_to_35) age_29_to_35,
    sum(age_36_to_42) age_36_to_42, sum(age_42_to_above) age_42_to_above,
    1 row_order
    FROM BIM_I_LP_AGE_SG_MV  b,ENI_ITEM_VBH_NODES_V e
    WHERE
    b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
    AND e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
    AND e.parent_id =  e.child_id
    AND e.parent_id =  b.product_category_id
    AND e.leaf_node_flag <> ''Y''
    AND b.resource_id = :l_resource_id
    AND b.item_id = ''-1''
    AND b.dim_id=''ALL''
    AND b.umark = 2
    GROUP BY e.value,b.product_category_id,e.leaf_node_flag
    HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
    ) &ORDER_BY_CLAUSE';
else
/*sales rep is selected from the page*/
l_query :=
 'SELECT BIM_SALES_GROUP VIEWBY,VIEWBYID,
age_3_below BIM_MEASURE1, age_3_to_7 BIM_MEASURE2,
age_8_to_14 BIM_MEASURE3, age_15_to_21 BIM_MEASURE4,
age_22_to_28 BIM_MEASURE5, age_29_to_35 BIM_MEASURE6,
age_36_to_42 BIM_MEASURE7, age_42_to_above BIM_MEASURE8,
(age_3_below + age_3_to_7 + age_8_to_14 + age_15_to_21 +
age_22_to_28 + age_29_to_35 + age_36_to_42 + age_42_to_above)  BIM_MEASURE9,
NULL BIM_MEASURE10,
DECODE(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) BIM_MEASURE11,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_3_below = 0 THEN NULL ELSE '||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL1,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_3_to_7 = 0 THEN NULL ELSE '||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END BIM_URL2,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_8_to_14 = 0 THEN NULL ELSE '||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL3,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_15_to_21 = 0 THEN NULL ELSE '||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL4,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_22_to_28 = 0 THEN NULL ELSE '||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL5,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_29_to_35 = 0 THEN NULL ELSE '||''''||l_url_str6||''''||'||'||''''||l_Metric_f||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL6,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_36_to_42 = 0 THEN NULL ELSE '||''''||l_url_str7||''''||'||'||''''||l_Metric_g||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL7,
CASE WHEN VIEWBYID = -1 THEN null WHEN DIR_FLAG=1 THEN NULL WHEN age_42_to_above = 0 THEN NULL ELSE '||''''||l_url_str8||''''||'||'||''''||l_Metric_h||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||' END  BIM_URL8,
SUM(age_3_below) over() BIM_GRAND_TOTAL1,
SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
FROM (
/*********children of the selected category*********/
SELECT e.value BIM_SALES_GROUP,b.product_category_id VIEWBYID,e.leaf_node_flag leaf_node_flag,0 dir_flag,
sum(age_3_below) age_3_below, sum(age_3_to_7) age_3_to_7, sum(age_8_to_14) age_8_to_14,
sum(age_15_to_21) age_15_to_21, sum(age_22_to_28) age_22_to_28, sum(age_29_to_35) age_29_to_35,
sum(age_36_to_42) age_36_to_42, sum(age_42_to_above) age_42_to_above,
1 row_order
FROM BIM_I_LP_AGE_SG_MV  b,ENI_ITEM_VBH_NODES_V e
WHERE
b.group_id = :l_group_id
AND e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
AND e.id =  b.product_category_id
AND e.id = e.child_id
AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
AND b.resource_id = :l_resource_id
AND b.dim_id=''ALL''
AND b.umark = 1
GROUP BY e.value,b.product_category_id,e.leaf_node_flag
HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
UNION ALL
SELECT bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' BIM_SALES_GROUP,
b.product_category_id VIEWBYID,e.leaf_node_flag leaf_node_flag,1 dir_flag,
sum(age_3_below) age_3_below, sum(age_3_to_7) age_3_to_7, sum(age_8_to_14) age_8_to_14,
sum(age_15_to_21) age_15_to_21, sum(age_22_to_28) age_22_to_28, sum(age_29_to_35) age_29_to_35,
sum(age_36_to_42) age_36_to_42, sum(age_42_to_above) age_42_to_above,
1 row_order
FROM BIM_I_LP_AGE_SG_MV  b,ENI_ITEM_VBH_NODES_V e
WHERE
b.group_id = :l_group_id
AND e.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
AND e.parent_id =  e.child_id
AND e.parent_id =  b.product_category_id
AND e.leaf_node_flag <> ''Y''
AND b.resource_id = :l_resource_id
AND b.item_id = ''-1''
AND b.dim_id=''ALL''
AND b.umark = 2
GROUP BY e.value,b.product_category_id,e.leaf_node_flag
HAVING
SUM(age_3_below) > 0
OR SUM(age_3_to_7) > 0
OR SUM(age_8_to_14) > 0
OR SUM(age_15_to_21) > 0
OR SUM(age_22_to_28) > 0
OR SUM(age_29_to_35) > 0
OR SUM(age_36_to_42) > 0
OR SUM(age_42_to_above) > 0
) &ORDER_BY_CLAUSE';
end if;
end if;
 /* VIEW BY IS CHANNEL */
 ELSIF (l_view_by = 'SALES CHANNEL+SALES CHANNEL') THEN
     if (l_category_id is null) then
         if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.channel_code) ';
        l_tables_b := ' BIM_I_LD_AGE_SG_MV b,so_lookups d ';
        l_where_b  := '  b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                        AND b.dim_id=''CHANNEL''
                        AND d.lookup_type(+) = ''SALES_CHANNEL''
                        AND d.lookup_code(+) = b.channel_code
                        AND b.resource_id =:l_resource_id ';
        else
       /* first query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
            l_col2_a   := ' decode(d.meaning,null,null,b.channel_code) ';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b,so_lookups d ';
            l_where_a  := ' a.resource_id=b.resource_id
                           AND b.group_id = :l_group_id
                           AND b.dim_id=''CHANNEL''
                           AND d.lookup_type(+) = ''SALES_CHANNEL''
                           AND d.lookup_code(+) = b.channel_code
                           AND b.resource_id =:l_resource_id ' ;
      end if;
    else
     if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
      l_col2_b   := ' decode(d.meaning,null,null,b.channel_code) ';
      l_tables_b := ' BIM_I_LP_AGE_SG_MV b,so_lookups d ';
      l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                      AND b.dim_id=''CHANNEL''
                      AND d.lookup_type(+) = ''SALES_CHANNEL''
                      AND d.lookup_code(+) = b.channel_code
                      AND b.resource_id = :l_resource_id
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';
      else
     /* first query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
          l_col2_a   := ' decode(d.meaning,null,null,b.channel_code) ';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b,so_lookups d ';
          l_where_a  := '  a.resource_id=b.resource_id
                      AND b.group_id = :l_group_id
                      AND b.dim_id=''CHANNEL''
                      AND d.lookup_type(+) = ''SALES_CHANNEL''
                      AND d.lookup_code(+) = b.channel_code
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND b.resource_id = :l_resource_id ';
    end if;
   end if;
   /* VIEW BY IS COUNTRY */
 ELSIF (l_view_by = 'GEOGRAPHY+COUNTRY') THEN
   if (l_category_id is null) then
         if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
        l_col2_b   := ' decode(d.name,null,null,b.lead_country) ';
        l_tables_b := ' BIM_I_LD_AGE_SG_MV b,bis_countries_v d ';
        l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                        AND b.dim_id=''COUNTRY''
                        AND d.country_code(+) = b.lead_country
                        AND b.resource_id = :l_resource_id ';
        else
       /* first query */
        l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
            l_col2_a   := ' decode(d.name,null,null,b.lead_country) ';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b,bis_countries_v d ';
            l_where_a  := ' a.resource_id=b.resource_id
                           AND b.group_id = :l_group_id
                           AND b.dim_id=''COUNTRY''
                           AND d.country_code(+) = b.lead_country
                           AND b.resource_id =:l_resource_id ';
      end if;
    else
     if l_resource_id is null then
      /* second query */
        l_col1_b   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
      l_col2_b   := ' decode(d.name,null,null,b.lead_country) ';
      l_tables_b := ' BIM_I_LP_AGE_SG_MV b,bis_countries_v d  ';
      l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                      AND b.dim_id=''COUNTRY''
                      AND d.country_code(+) = b.lead_country
                      AND b.resource_id = :l_resource_id
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';
      else
     /* first query */
        l_col1_a   := ' decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name)  ';
          l_col2_a   := ' decode(d.name,null,null,b.lead_country) ';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b,bis_countries_v d ';
          l_where_a  := '  a.resource_id=b.resource_id
                      AND b.group_id = :l_group_id
                        AND b.dim_id=''COUNTRY''
                        AND d.country_code(+) = b.lead_country
                        AND b.umark=1
                        AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT
                        AND b.resource_id = :l_resource_id ';
    end if;
   end if;
  /* View by Lead Quality*/
ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY') THEN
 if (l_category_id is null) then
         if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.lead_rank_id) ';
        l_tables_b := ' BIM_I_LD_AGE_SG_MV b,as_sales_lead_ranks_vl d';
        l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                        AND b.dim_id=''QUALITY''
                        AND d.rank_id (+)= b.lead_rank_id
                        AND b.resource_id = :l_resource_id ';
        else
       /* first query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
            l_col2_a   := ' decode(d.meaning,null,null,b.lead_rank_id) ';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b,as_sales_lead_ranks_vl d';
            l_where_a  := ' a.resource_id=b.resource_id
                           AND b.group_id = :l_group_id
                           AND b.dim_id=''QUALITY''
                           AND d.rank_id (+)= b.lead_rank_id
                           AND b.resource_id = :l_resource_id ';
      end if;
    else
     if l_resource_id is null then
       /* second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
      l_col2_b   := ' decode(d.meaning,null,null,b.lead_rank_id) ';
      l_tables_b := ' BIM_I_LP_AGE_SG_MV b,as_sales_lead_ranks_vl d ';
      l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                      AND b.dim_id=''QUALITY''
                      AND d.rank_id (+)= b.lead_rank_id
                      AND b.resource_id = :l_resource_id
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';
      else
     /* first query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'OTH'||''''||')'||',d.meaning)  ';
          l_col2_a   := ' decode(d.meaning,null,null,b.lead_rank_id) ';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b,as_sales_lead_ranks_vl d ';
          l_where_a  := '  a.resource_id=b.resource_id
                      AND b.group_id = :l_group_id
                      AND b.dim_id=''QUALITY''
                      AND d.rank_id (+)= b.lead_rank_id
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND b.resource_id =:l_resource_id ';
     end if;
   end if;
/* View by Lead Source*/
ELSIF (l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN
if (l_category_id is null) then
         if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
        l_col2_b   := ' decode(d.meaning,null,null,b.lead_source) ';
        l_tables_b := ' BIM_I_LD_AGE_SG_MV b,as_lookups d';
        l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                        AND b.dim_id=''SOURCE''
                        AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                        AND d.lookup_code(+) = b.lead_source
                        AND b.resource_id = :l_resource_id ';
        else
       /* first query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
            l_col2_a   := ' decode(d.meaning,null,null,b.lead_source) ';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b,as_lookups d';
            l_where_a  := ' a.resource_id=b.resource_id
                           AND b.group_id = :l_group_id
                           AND b.dim_id=''SOURCE''
                           AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                           AND d.lookup_code(+) = b.lead_source
                           AND b.resource_id =:l_resource_id ';
      end if;
    else
     if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
      l_col2_b   := ' decode(d.meaning,null,null,b.lead_source) ';
      l_tables_b := ' BIM_I_LP_AGE_SG_MV b,as_lookups d';
      l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                      AND b.dim_id=''SOURCE''
                      AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                      AND d.lookup_code(+) = b.lead_source
                      AND b.resource_id = :l_resource_id
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';
      else
     /* first query */
        l_col1_a   := ' decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning)  ';
          l_col2_a   := ' decode(d.meaning,null,null,b.lead_source) ';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b,as_lookups d ';
          l_where_a  := '  a.resource_id=b.resource_id
                      AND b.group_id = :l_group_id
                      AND b.dim_id=''SOURCE''
                      AND d.lookup_type(+) = ''SOURCE_SYSTEM''
                      AND d.lookup_code(+) = b.lead_source
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND b.resource_id = :l_resource_id ';
     end if;
   end if;
   /* View by is customer category*/
   ELSIF (l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN
if (l_category_id is null) then
         if l_resource_id is null then
        /* second query */
        l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
        l_col2_b   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
        l_tables_b := ' BIM_I_LD_AGE_SG_MV b,bic_cust_category_v d';
        l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                        AND b.dim_id=''CUSTCAT''
                        AND d.customer_category_code (+) = b.cust_category
                        AND b.resource_id = :l_resource_id ';
        else
       /* first query */
        l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
            l_col2_a   := 'decode(d.customer_category_name,null,null,b.cust_category) ';
            l_tables_a := ' BIM_I_LD_AGE_SG_MV b,bic_cust_category_v d';
            l_where_a  := ' a.resource_id=b.resource_id
                           AND b.group_id = :l_group_id
                           AND b.dim_id=''CUSTCAT''
                           AND d.customer_category_code (+) = b.cust_category
                           AND b.resource_id =:l_resource_id ';
      end if;
    else
     if l_resource_id is null then
      /* second query */
        l_col1_b   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
      l_col2_b   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
      l_tables_b := ' BIM_I_LP_AGE_SG_MV b,bic_cust_category_v d';
      l_where_b  := ' b.group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
                      AND b.dim_id=''CUSTCAT''
                      AND d.customer_category_code (+) = b.cust_category
                      AND b.resource_id = :l_resource_id
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT';
      else
     /* first query */
        l_col1_a   := ' decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name)  ';
          l_col2_a   := ' decode(d.customer_category_name,null,null,b.cust_category) ';
          l_tables_a := ' BIM_I_LP_AGE_SG_MV b,bic_cust_category_v d';
          l_where_a  := '  a.resource_id=b.resource_id
                      AND b.group_id = :l_group_id
                      AND b.dim_id=''CUSTCAT''
                      AND d.customer_category_code (+) = b.cust_category
                      AND b.umark=1
                      AND b.product_category_id =  &ITEM+ENI_ITEM_VBH_CAT
                      AND b.resource_id = :l_resource_id ';
     end if;
   end if;
END IF;
-- ===================== Query Formation =============================
/* This is the dynamic query to be used with variables replaced*/
IF (l_view_by <> 'ITEM+ENI_ITEM_VBH_CAT')  THEN
  IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
     l_qry_sg :=
    ' UNION ALL
    SELECT '||l_col1_a||' BIM_SALES_GROUP,
            to_char( '||l_col2_a||' ) VIEWBYID,
            '||l_col3_a||' is_resource,
    sum(age_3_below) age_3_below ,
    SUM(age_3_to_7) age_3_to_7, SUM(age_8_to_14) age_8_to_14,
    SUM(age_15_to_21) age_15_to_21 , SUM(age_22_to_28) age_22_to_28, SUM(age_29_to_35) age_29_to_35, SUM(age_36_to_42) age_36_to_42 ,
    SUM(age_42_to_above) age_42_to_above ,
    1 row_order
    FROM JTF_RS_RESOURCE_EXTNS_VL a,'|| l_tables_a|| '
    WHERE '||l_where_a||'
    GROUP BY '||l_col1_a||','||l_col2_a||','||l_col3_a;
  ELSE
     l_qry_sg := NULL;
  END IF;

  IF l_resource_id is null THEN
    l_query := ' SELECT bim_sales_group VIEWBY, VIEWBYID,
    age_3_below BIM_MEASURE1, age_3_to_7 BIM_MEASURE2,
    age_8_to_14 BIM_MEASURE3, age_15_to_21 BIM_MEASURE4,
    age_22_to_28 BIM_MEASURE5, age_29_to_35 BIM_MEASURE6,
    age_36_to_42 BIM_MEASURE7, age_42_to_above BIM_MEASURE8,
    (age_3_below + age_3_to_7 + age_8_to_14 + age_15_to_21 +
    age_22_to_28 + age_29_to_35 + age_36_to_42 + age_42_to_above)  BIM_MEASURE9,
    DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_MEASURE10,
    NULL BIM_MEASURE11,
   decode(VIEWBYID,null,null,decode(age_3_below,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,null,null,decode(age_3_to_7,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,null,null,decode(age_8_to_14,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,null,null,decode(age_15_to_21,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,null,null,decode(age_22_to_28,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,null,null,decode(age_29_to_35,0,NULL,'||''''||l_url_str6||''''||'||'||''''||l_Metric_f||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,null,null,decode(age_36_to_42,0,NULL,'||''''||l_url_str7||''''||'||'||''''||l_Metric_g||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  decode(VIEWBYID,null,null,decode(age_42_to_above,0,NULL,'||''''||l_url_str8||''''||'||'||''''||l_Metric_h||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL8,
    SUM(age_3_below) over() BIM_GRAND_TOTAL1,
    SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
    SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
    SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
    SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
    SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
    SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
    SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
    SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
    age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
    FROM (
    SELECT BIM_SALES_GROUP,VIEWBYID, is_resource,
    sum(age_3_below) age_3_below ,
    SUM(age_3_to_7) age_3_to_7,
    SUM(age_8_to_14) age_8_to_14,
    SUM(age_15_to_21) age_15_to_21 ,
    SUM(age_22_to_28) age_22_to_28,
    SUM(age_29_to_35) age_29_to_35,
    SUM(age_36_to_42) age_36_to_42 ,
    SUM(age_42_to_above) age_42_to_above
    FROM
    (
    SELECT  '||l_col1_b||' BIM_SALES_GROUP,
            to_char( '||l_col2_b||' ) VIEWBYID,
            '||l_col3_b||' is_resource,
    sum(age_3_below) age_3_below ,
    SUM(age_3_to_7) age_3_to_7, SUM(age_8_to_14) age_8_to_14,
    SUM(age_15_to_21) age_15_to_21 , SUM(age_22_to_28) age_22_to_28, SUM(age_29_to_35) age_29_to_35, SUM(age_36_to_42) age_36_to_42 ,
    SUM(age_42_to_above) age_42_to_above ,
    2 row_order
    FROM  '|| l_tables_b|| '
    WHERE '||l_where_b||'
    GROUP BY '||l_col1_b||','||l_col2_b||','||l_col3_b||l_qry_sg||'
    )
    GROUP BY BIM_SALES_GROUP,VIEWBYID,is_resource
    HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
    ) &ORDER_BY_CLAUSE';
  ELSE
    l_query := ' SELECT bim_sales_group VIEWBY,
    VIEWBYID,
    age_3_below BIM_MEASURE1, age_3_to_7 BIM_MEASURE2,
    age_8_to_14 BIM_MEASURE3, age_15_to_21 BIM_MEASURE4,
    age_22_to_28 BIM_MEASURE5, age_29_to_35 BIM_MEASURE6,
    age_36_to_42 BIM_MEASURE7, age_42_to_above BIM_MEASURE8,
    (age_3_below + age_3_to_7 + age_8_to_14 + age_15_to_21 +
    age_22_to_28 + age_29_to_35 + age_36_to_42 + age_42_to_above)  BIM_MEASURE9,
    DECODE('||''''||l_view_by||''''||', ''ORGANIZATION+JTF_ORG_SALES_GROUP'',DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ,NULL) BIM_MEASURE10,
    NULL BIM_MEASURE11,
    decode(VIEWBYID,null,null,decode(age_3_below,0,NULL,'||''''||l_url_str1||''''||'||'||''''||l_Metric_a||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL1,
  decode(VIEWBYID,null,null,decode(age_3_to_7,0,NULL,'||''''||l_url_str2||''''||'||'||''''||l_Metric_b||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL2,
  decode(VIEWBYID,null,null,decode(age_8_to_14,0,NULL,'||''''||l_url_str3||''''||'||'||''''||l_Metric_c||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL3,
  decode(VIEWBYID,null,null,decode(age_15_to_21,0,NULL,'||''''||l_url_str4||''''||'||'||''''||l_Metric_d||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL4,
  decode(VIEWBYID,null,null,decode(age_22_to_28,0,NULL,'||''''||l_url_str5||''''||'||'||''''||l_Metric_e||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL5,
  decode(VIEWBYID,null,null,decode(age_29_to_35,0,NULL,'||''''||l_url_str6||''''||'||'||''''||l_Metric_f||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL6,
  decode(VIEWBYID,null,null,decode(age_36_to_42,0,NULL,'||''''||l_url_str7||''''||'||'||''''||l_Metric_g||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL7,
  decode(VIEWBYID,null,null,decode(age_42_to_above,0,NULL,'||''''||l_url_str8||''''||'||'||''''||l_Metric_h||''''||'||'||''''||l_rpt_name||''''||'||VIEWBYID'||'||'||''''||l_context_info||'))  BIM_URL8,
    SUM(age_3_below) over() BIM_GRAND_TOTAL1,
    SUM(age_3_to_7) over() BIM_GRAND_TOTAL2,
    SUM(age_8_to_14) over() BIM_GRAND_TOTAL3,
    SUM(age_15_to_21) over() BIM_GRAND_TOTAL4,
    SUM(age_22_to_28) over() BIM_GRAND_TOTAL5,
    SUM(age_29_to_35) over() BIM_GRAND_TOTAL6,
    SUM(age_36_to_42) over() BIM_GRAND_TOTAL7,
    SUM(age_42_to_above) over() BIM_GRAND_TOTAL8,
    SUM(age_3_below+age_3_to_7+age_8_to_14+age_15_to_21+age_22_to_28+age_29_to_35+
    age_36_to_42+age_42_to_above) over() BIM_GRAND_TOTAL9
    FROM (
    SELECT '||l_col1_a||' BIM_SALES_GROUP,
            to_char( '||l_col2_a||' ) VIEWBYID,
            '||l_col3_a||' is_resource,
    sum(age_3_below) age_3_below ,
    SUM(age_3_to_7) age_3_to_7, SUM(age_8_to_14) age_8_to_14,
    SUM(age_15_to_21) age_15_to_21 , SUM(age_22_to_28) age_22_to_28, SUM(age_29_to_35) age_29_to_35, SUM(age_36_to_42) age_36_to_42 ,
    SUM(age_42_to_above) age_42_to_above ,
    1 row_order
    FROM JTF_RS_RESOURCE_EXTNS_VL a,'|| l_tables_a|| '
    WHERE '||l_where_a||'
    GROUP BY '||l_col1_a||','||l_col2_a||','||l_col3_a||'
    HAVING
    SUM(age_3_below) > 0
    OR SUM(age_3_to_7) > 0
    OR SUM(age_8_to_14) > 0
    OR SUM(age_15_to_21) > 0
    OR SUM(age_22_to_28) > 0
    OR SUM(age_29_to_35) > 0
    OR SUM(age_36_to_42) > 0
    OR SUM(age_42_to_above) > 0
  ) &ORDER_BY_CLAUSE';
  END IF;
 END IF;

 END IF;

 /* Earlier l_resource_id was hardcoded to -1 ,to enable binding below code was added */

   IF l_resource_id is null then
      l_resource_id:= -1;
   END IF;


  x_custom_sql := l_query;
--  x_custom_output.EXTEND;

  /*l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_KEY;
  l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_CUSTOM_OUTPUT.COUNT) := l_custom_rec;
*/

  l_custom_rec.attribute_name      := ':l_group_id';
  l_custom_rec.attribute_value     := l_org_sg;
  l_custom_rec.attribute_type      := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

   --test('GET_LEAD_AGING_SG_SQL','QUERY','',l_query);

   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
     -- test('GET_LEAD_AGING_SG_SQL', 'EXCEPTION','test',l_error_msg);
   END;



-- Start of comments
-- NAME
--    GET_LEAD_OPP_CHART_SQL
--
-- PURPOSE
--    Returns the Leads and Opportunities chart query.
--
-- NOTES
--
-- HISTORY
-- 08/27/2002  dmvincen  created.
--
-- End of comments

PROCEDURE GET_LEAD_OPP_CHART_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_row_count varchar2(80) := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_table_name varchar2(80) := NULL;
      l_column_name varchar2(80) := NULL;
      l_curr_start_date date := NULL;
      l_prev_start_date date := NULL;
      l_prev_end_date date := NULL;
      l_query varchar2(32767);
      l_error varchar2(4000);
      l_series_name varchar2(4000);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_resource_id VARCHAR2(20);
      l_curr VARCHAR2(50);
      l_curr_suffix VARCHAR2(50);
      l_camp_id VARCHAR2(100);
      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
      l_close_rs   VARCHAR2(500);
      l_context       VARCHAR2(5000);

   BEGIN

      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

 get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
                 p_resource_id              => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date        => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id        => l_curr_page_time_id,
		 p_prev_page_time_id        => l_prev_page_time_id,
		 l_view_by                 =>  l_view_by,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
                 p_camp_id                 => l_camp_id
                 );

      GET_TREND_PARAMS( p_page_period_type  => l_page_period_type,
                       p_comp_type         => l_comp_type,
                       p_curr_as_of_date   => l_as_of_date,
                       p_table_name        => l_table_name,
                       p_column_name       => l_column_name,
                       p_curr_start_date   => l_curr_start_date,
                       p_prev_start_date   => l_prev_start_date,
                       p_prev_end_date     => l_prev_end_date,
                       p_series_name       => l_series_name
                       );
       get_currency(p_page_parameter_tbl     =>p_page_parameter_tbl,
                 l_currency             => l_curr);
 IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;

       l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
      l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';

IF l_org_sg is null THEN
l_query:= 'SELECT
NULL VIEWBY,
NULL VIEWBYID,
NULL BIM_MEASURE1,
NULL BIM_MEASURE2,
NULL BIM_MEASURE3,
NULL BIM_MEASURE4,
NULL BIM_MEASURE5,
NULL BIM_MEASURE6,
NULL BIM_MEASURE8,
NULL BIM_MEASURE7,
NULL BIM_MEASURE9,
NULL BIM_URL1,
NULL BIM_URL2,
NULL BIM_URL3,
NULL BIM_URL4,
NULL BIM_URL5,
NULL BIM_URL6,
NULL BIM_URL7,
NULL BIM_GRAND_TOTAL1,
NULL BIM_GRAND_TOTAL2,
NULL BIM_GRAND_TOTAL3,
NULL BIM_GRAND_TOTAL4,
NULL BIM_GRAND_TOTAL5,
NULL BIM_GRAND_TOTAL6,
NULL bim_GRAND_TOTAL7,
NULL bim_GRAND_TOTAL8,
NULL bim_GRAND_TOTAL9
FROM dual';

ELSE

      IF l_period_type = 16 THEN l_row_count := 13;
      ELSIF l_period_type = 32 THEN l_row_count := 12;
      ELSIF l_period_type = 64 THEN
         IF l_comp_type = 'SEQUENTIAL'
         THEN l_row_count := 8;
         ELSE l_row_count := 4;
         END IF;
      ELSIF l_period_type = 128 THEN l_row_count := 4;
      END IF;
IF (l_category_id is null) THEN
   IF l_comp_type = 'SEQUENTIAL' OR l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
     IF l_resource_id is null THEN
		   l_query:= '
select name VIEWBY,null BIM_MEASURE2,nvl(sum(leads),0) BIM_MEASURE3,nvl(sum(opportunities),0) BIM_MEASURE4,NULL BIM_MEASURE5,NULL BIM_MEASURE6
FROM ( /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(fi) */ leads, 0 opportunities, start_date, end_date, name
FROM BIM_I_LD_GEN_SG_MV a,
(SELECT *
FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count -1) fi
WHERE a.group_id(+) IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.time_id(+) = fi.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
AND a.resource_id(+) = :l_resource_id
UNION ALL /*Opportunity*/
SELECT /*+ leading(fi) */ 0 leads, cnv_opty_amt'||l_curr_suffix||' opportunities, start_date, end_date, name
FROM BIL_BI_OPTY_G_MV a,
(SELECT *
FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count -1) fi
WHERE a.effective_time_id(+) = fi.time_id
AND a.parent_sales_group_id(+) = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.effective_period_type_id(+) = :l_period_type
)
group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id, start_date, end_date, value name, trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
and end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc
) fi,
(SELECT /*+ leading(c) */ SUM(a.leads) leads, 0 opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
BIM_I_LD_GEN_SG_MV a
WHERE a.group_id IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
AND a.resource_id =:l_resource_id
GROUP BY report_date) a
where a.report_date(+) = fi.report_date
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id, start_date, end_date, value name,trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
and end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc
) fi,
(SELECT /*+ leading(c) */ 0 leads, SUM(a.cnv_opty_amt'||l_curr_suffix||') opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
BIL_BI_OPTY_G_MV a
WHERE a.effective_time_id = c.time_id
AND a.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) a
where a.report_date(+) = fi.report_date
)
group by start_date, end_date, name
order by start_date asc
)
group by name,start_date
order by start_date';
    ELSE
		   l_query:= '
SELECT NAME VIEWBY,null bim_measure2, nvl(sum(leads), 0) bim_measure3, nvl(sum(opportunities), 0) bim_measure4, NULL bim_measure5, NULL bim_measure6
FROM (
/*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
FROM (SELECT /*+ leading(fi) */ leads, 0 opportunities, start_date, end_date, name
FROM bim_i_ld_gen_sg_mv a,
(SELECT *
FROM (SELECT ID time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count - 1) fi
WHERE a.group_id(+) IN (:l_group_id)
AND a.time_id(+) = fi.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) = -1
AND a.update_period_type_id(+) = -1
AND a.resource_id(+) = :l_resource_id
UNION ALL
/*Opportunity*/
SELECT /*+ leading(fi) */ 0 leads, cnv_opty_amt'||l_curr_suffix||' opportunities, start_date, end_date, name
FROM bil_bi_opty_g_mv a,
(SELECT *
FROM (SELECT ID time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count - 1) fi
WHERE a.effective_time_id(+) = fi.time_id
AND a.parent_sales_group_id(+) = :l_group_id
AND a.effective_period_type_id(+) = :l_period_type
AND a.salesrep_id(+) = :l_resource_id
)
GROUP BY start_date, end_date, name
UNION ALL
/*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
FROM (SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT ID time_id, start_date, end_date, value name, trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi,
(SELECT /*+ leading(c) */ sum(a.leads) leads, 0 opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM fii_time_rpt_struct
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id, :l_record_type) = record_type_id) c,
bim_i_ld_gen_sg_mv a
WHERE a.group_id IN (:l_group_id)
AND a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id = -1
AND a.update_period_type_id = -1
AND a.resource_id = :l_resource_id
GROUP BY report_date ) a
WHERE a.report_date(+) = fi.report_date
UNION ALL
/*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT ID time_id, start_date, end_date, value name, trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM  '||l_table_name||' a
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi,
(SELECT  /*+ leading(c) */ 0 leads, sum(a.cnv_opty_amt'||l_curr_suffix||') opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM fii_time_rpt_struct
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND (record_type_id, :l_record_type) = record_type_id) c,
bil_bi_opty_g_mv a
WHERE a.effective_time_id = c.time_id
AND a.parent_sales_group_id = :l_group_id
AND a.effective_period_type_id = c.period_type_id
AND a.salesrep_id = :l_resource_id
GROUP BY report_date ) a
WHERE a.report_date(+) = fi.report_date
)
GROUP BY start_date, end_date, name
ORDER BY start_date asc
)
GROUP BY name, start_date
ORDER BY start_date';
   END IF;
  ELSE
-- Year by Year
   IF l_resource_id is null THEN
		   l_query:= 'SELECT a.name VIEWBY,null bim_measure2, nvl(sum(a.leads), 0) bim_measure3, nvl(sum(a.opportunities), 0) bim_measure4, nvl(sum(b.leads), 0) bim_measure5, nvl(sum(b.opportunities), 0) bim_measure6
FROM (
/*start of sub table for current values*/
SELECT leads, opportunities, start_date, end_date, name, rownum sequence
FROM ( /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
FROM (SELECT /*+ leading(t) */ leads, 0 opportunities, start_date, end_date, name
FROM bim_i_ld_gen_sg_mv a,
(SELECT *
FROM (SELECT   ID time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) t
WHERE rownum <= :l_row_count - 1) t
WHERE a.group_id(+) IN (&ORGANIZATION+JTF_ORG_SALES_GROUP)
AND a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) = -1
AND a.update_period_type_id(+) = -1
AND a.resource_id(+) = :l_resource_id
UNION ALL
/*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, cnv_opty_amt'||l_curr_suffix||' opportunities, start_date, end_date, name
FROM bil_bi_opty_g_mv a,
(SELECT *
FROM (SELECT   ID time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) t
WHERE rownum <= :l_row_count - 1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.parent_sales_group_id(+) = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.effective_period_type_id(+) = :l_period_type
)
GROUP BY start_date, end_date, name
UNION ALL
/*Leads*/
SELECT   sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
FROM (SELECT /*+ leading(c) */ leads, opportunities, start_date, end_date, name
FROM (SELECT ID time_id, start_date, end_date, value name, trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) t,
(SELECT sum(a.leads) leads, 0 opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM fii_time_rpt_struct
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND (record_type_id, :l_record_type) = record_type_id) c,
bim_i_ld_gen_sg_mv a
WHERE a.group_id IN (&ORGANIZATION+JTF_ORG_SALES_GROUP)
AND a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id = -1
AND a.update_period_type_id = -1
AND a.resource_id = :l_resource_id
GROUP BY report_date
) a
WHERE a.report_date(+) = t.report_date
UNION ALL
/*Opportunity*/
SELECT /*+ leading(c) */ leads, opportunities, start_date, end_date, name
FROM (SELECT ID time_id, start_date, end_date, value name, trunc (&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) t,
(SELECT   0 leads, sum(cnv_opty_amt'||l_curr_suffix||') opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM fii_time_rpt_struct
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND (record_type_id, :l_record_type) = record_type_id) c,
bil_bi_opty_g_mv a
WHERE a.effective_time_id = c.time_id
AND a.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) a
WHERE a.report_date(+) = t.report_date
)
GROUP BY start_date, end_date, name
ORDER BY start_date
)
) a,
(SELECT leads, opportunities, start_date, end_date, name, rownum sequence
FROM ( /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
FROM (SELECT /*+ leading(t) */ leads, 0 opportunities, start_date, end_date, name
FROM bim_i_ld_gen_sg_mv a,
(SELECT *
FROM (SELECT ID time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc) t
WHERE ROWNUM <= :l_row_count - 1) t
WHERE a.group_id(+) IN (&ORGANIZATION+JTF_ORG_SALES_GROUP)
AND a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) = -1
AND a.update_period_type_id(+) = -1
AND a.resource_id(+) = :l_resource_id
UNION ALL
/*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, cnv_opty_amt'||l_curr_suffix||' opportunities, start_date, end_date, name
FROM bil_bi_opty_g_mv a,
(SELECT *
FROM (SELECT ID time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE ROWNUM <= :l_row_count - 1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.parent_sales_group_id(+) = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.effective_period_type_id(+) = :l_period_type
)
GROUP BY start_date, end_date, name
UNION ALL
/*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
FROM (SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT *
FROM (SELECT ID time_id, start_date, end_date, VALUE name, trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc) t
WHERE ROWNUM <= 1) t,
(SELECT /*+ leading(c) */sum(nvl(a.leads, 0)) leads, 0 opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM fii_time_rpt_struct
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND (record_type_id, :l_record_type) = record_type_id) c,
bim_i_ld_gen_sg_mv a
WHERE a.group_id IN (&ORGANIZATION+JTF_ORG_SALES_GROUP)
AND a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id = -1
AND a.update_period_type_id = -1
AND a.resource_id = :l_resource_id
GROUP BY report_date) b
WHERE t.report_date = b.report_date(+)
UNION ALL
/*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT *
FROM (SELECT ID time_id, start_date, end_date, VALUE name, trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc) t
WHERE ROWNUM <= 1) t,
(SELECT /*+ leading(c) */ 0 leads, sum(nvl(a.cnv_opty_amt'||l_curr_suffix||', 0)) opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM fii_time_rpt_struct
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND (record_type_id, :l_record_type) = record_type_id) c,
bil_bi_opty_g_mv a
WHERE a.effective_time_id = c.time_id
AND a.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) b
WHERE t.report_date = b.report_date(+)
)
GROUP BY start_date, end_date, name
ORDER BY start_date
)
) b
WHERE a.sequence = b.sequence
GROUP BY a.name, b.start_date
ORDER BY b.start_date';
  ELSE
l_query:= 'SELECT a.name VIEWBY,null BIM_MEASURE2,NVL(sum(a.leads),0) BIM_MEASURE3,NVL(sum(a.opportunities),0) BIM_MEASURE4,NVL(sum(b.leads),0) BIM_MEASURE5,NVL(sum(b.opportunities),0) BIM_MEASURE6
FROM (
/*start of sub table for current values*/
SELECT leads, opportunities, start_date, end_date, name, rownum sequence
FROM (
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from ( /* Leads*/
SELECT /*+ leading(t) */ leads, 0 opportunities, start_date, end_date, name
FROM BIM_I_LD_GEN_SG_MV a,
(SELECT * FROM (select id time_id, start_date, end_date, value name
FROM '||l_table_name||' WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE rownum <= :l_row_count -1) t
WHERE a.group_id(+) IN ( :l_group_id )
AND a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
AND a.resource_id(+) = :l_resource_id
UNION ALL /*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, cnv_opty_amt'||l_curr_suffix||' opportunities, start_date, end_date, name
FROM BIL_BI_OPTY_G_MV a,
(SELECT * FROM (select id time_id, start_date, end_date, value name
FROM '||l_table_name||' WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE rownum <= :l_row_count -1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.parent_sales_group_id(+) = :l_group_id
AND a.effective_period_type_id(+) = :l_period_type
AND a.salesrep_id(+) = :l_resource_id
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id,start_date,end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||' WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t,
(SELECT /*+ leading(c) */ SUM(a.leads) leads, 0 opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id) c,
BIM_I_LD_GEN_SG_MV a
WHERE a.group_id IN (:l_group_id)
AND a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
AND a.resource_id = :l_resource_id
GROUP BY report_date ) a
WHERE a.report_date(+) = t.report_date
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id,start_date,end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||' WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC ) t,
(SELECT /*+ leading(c) */ 0 leads, SUM(cnv_opty_amt'||l_curr_suffix||') opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id) c,
BIL_BI_OPTY_G_MV a
WHERE a.effective_time_id = c.time_id
AND a.parent_sales_group_id = :l_group_id
AND a.effective_period_type_id = c.period_type_id
AND a.salesrep_id = :l_resource_id
GROUP BY report_date ) a
WHERE a.report_date(+) = t.report_date
) group by start_date, end_date, name
ORDER BY start_date )
) a
,(SELECT leads, opportunities, start_date, end_date, name, rownum sequence
FROM (
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (/*Leads*/
SELECT /*+ leading(t) */ leads, 0 opportunities, start_date, end_date, name
FROM BIM_I_LD_GEN_SG_MV a,
(SELECT * FROM (SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||' WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC
) t where rownum <= :l_row_count -1 ) t
WHERE a.group_id(+) IN (:l_group_id)
AND a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
AND a.resource_id(+) = :l_resource_id
UNION ALL /*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, cnv_opty_amt'||l_curr_suffix||' opportunities, start_date, end_date, name
FROM BIL_BI_OPTY_G_MV a,
(SELECT * FROM (SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||' WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC
) t where rownum <= :l_row_count -1 ) t
WHERE a.effective_time_id(+) = t.time_id
AND a.parent_sales_group_id(+) = :l_group_id
AND a.effective_period_type_id(+) = :l_period_type
AND a.salesrep_id(+) = :l_resource_id
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT * FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||' WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc
) t WHERE rownum <= 1) t,
(SELECT /*+ leading(c) */ SUM(NVL(a.leads,0)) leads, 0 opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id) c,
BIM_I_LD_GEN_SG_MV a
WHERE a.group_id IN ( :l_group_id )
AND a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
AND a.resource_id = :l_resource_id
GROUP BY report_date
) b WHERE t.report_date = b.report_date(+)
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT * FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||' WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc
) t WHERE rownum <= 1) t,
(SELECT /*+ leading(c) */ 0 leads, SUM(NVL(a.cnv_opty_amt'||l_curr_suffix||',0)) opportunities, report_date
FROM (SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id) c,
BIL_BI_OPTY_G_MV a
WHERE a.effective_time_id = c.time_id
AND a.parent_sales_group_id = :l_group_id
AND a.effective_period_type_id = c.period_type_id
AND a.salesrep_id = :l_resource_id
GROUP BY report_date
) b WHERE t.report_date = b.report_date(+)
) group by start_date, end_date, name
ORDER BY start_date)) b
WHERE a.sequence = b.sequence
group by a.name,b.start_date
ORDER BY b.START_DATE';
     END IF;
  END IF;
ELSE
   IF l_comp_type = 'SEQUENTIAL' OR l_page_period_type = 'FII_TIME_ENT_YEAR' THEN
    IF l_resource_id is null THEN
l_query:= 'select name VIEWBY,null BIM_MEASURE2,NVL(sum(leads),0) BIM_MEASURE3,NVL(sum(opportunities),0) BIM_MEASURE4,NULL BIM_MEASURE5,NULL BIM_MEASURE6
FROM ( /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(fi) */ leads, 0 opportunities, start_date, end_date, name
FROM (
SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a , eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id(+) IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id(+) = :l_resource_id
) a,
(SELECT * FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count -1) fi
WHERE a.time_id(+) = fi.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
UNION ALL /*Opportunity*/
SELECT /*+ leading(fi) */ 0 leads, cnv_opty_amt opportunities, start_date, end_date, name
from (
select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id(+) = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
) a,
(SELECT * FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count -1) fi
WHERE a.effective_time_id(+) = fi.time_id
AND a.effective_period_type_id(+) = :l_period_type
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
and end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc
) fi,
(SELECT /*+ leading(c) */ SUM(a.leads) leads, 0 opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
( SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id = :l_resource_id
) a
WHERE a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
GROUP BY report_date) a
where a.report_date(+) = fi.report_date
UNION ALL /*Opportunities*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
and end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc
) fi,
(SELECT /*+ leading(c) */ 0 leads, SUM(a.cnv_opty_amt) opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
(select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV  a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
where a.parent_sales_group_id =  &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
) a
WHERE a.effective_time_id = c.time_id
AND  a.effective_period_type_id = c.period_type_id
GROUP BY report_date) a
where a.report_date(+) = fi.report_date
) group by start_date, end_date, name
order by start_date asc)
group by name,start_date
order by start_date';
     ELSE
l_query:= 'select name VIEWBY,null BIM_MEASURE2,NVL(sum(leads),0) BIM_MEASURE3,NVL(sum(opportunities),0) BIM_MEASURE4,NULL BIM_MEASURE5,NULL BIM_MEASURE6
FROM (
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(fi) */ leads, 0 opportunities, start_date, end_date, name
FROM (
SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id(+) IN ( :l_group_id )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id(+) =:l_resource_id
) a,
(SELECT * FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count -1) fi
WHERE  a.time_id(+) = fi.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
UNION ALL /*Opportunity*/
SELECT /*+ leading(fi) */ 0 leads, cnv_opty_amt opportunities, start_date, end_date, name
from (
select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id(+) = :l_group_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.salesrep_id(+) = :l_resource_id
) a,
(SELECT * FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc) fi
WHERE rownum <= :l_row_count -1) fi
WHERE a.effective_time_id(+) = fi.time_id
AND  a.effective_period_type_id(+) = :l_period_type
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
and end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc
) fi,
(SELECT /*+ leading(c) */ SUM(a.leads) leads, 0 opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
( SELECT leads, time_id, period_type_id,update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id IN ( :l_group_id )
AND a.resource_id = :l_resource_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
) a
WHERE a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
GROUP BY report_date) a
where a.report_date(+) = fi.report_date
UNION ALL /*Opportunities*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
and end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date desc
) fi,
(SELECT /*+ leading(c) */ 0 leads, SUM(a.cnv_opty_amt) opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
(select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id = :l_group_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
AND a.salesrep_id = :l_resource_id
) a
WHERE a.effective_time_id = c.time_id
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) a
where a.report_date(+) = fi.report_date
) group by start_date, end_date, name
order by start_date asc)
group by name,start_date
order by start_date';
   END IF;
ELSE
-- Year by Year
 IF l_resource_id is null THEN
		   l_query:= 'SELECT a.name VIEWBY,null BIM_MEASURE2,NVL(sum(a.leads),0) BIM_MEASURE3,NVL(sum(a.opportunities),0) BIM_MEASURE4,NVL(sum(b.leads),0) BIM_MEASURE5,NVL(sum(b.opportunities),0) BIM_MEASURE6
FROM (
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name, rownum sequence
FROM (
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(t) */ sum(leads) leads, 0 opportunities, start_date, end_date, name
FROM (
SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id(+) IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id(+) = :l_resource_id
) a,
(SELECT * FROM (select id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE rownum <= :l_row_count -1) t
WHERE a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
group by name,start_date, end_date
UNION ALL /*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, sum(cnv_opty_amt) opportunities, start_date, end_date, name
FROM (
select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id(+) = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id =  &ITEM+ENI_ITEM_VBH_CAT
) a,
(SELECT * FROM (select id time_id, start_date, end_date, value name
FROM '||l_table_name||' WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE rownum <= :l_row_count -1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.effective_period_type_id(+) = :l_period_type
group by name,start_date, end_date
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id,start_date,end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC
) t,
(SELECT /*+ leading(c) */ SUM(a.leads) leads, 0 opportunities, report_date
FROM (
SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
( SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id IN (&ORGANIZATION+JTF_ORG_SALES_GROUP)
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id = :l_resource_id
) a
WHERE  a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
GROUP BY report_date) a
WHERE a.report_date(+) = t.report_date
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id,start_date,end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC
) t,
(SELECT /*+ leading(c) */ 0 leads, SUM(cnv_opty_amt) opportunities, report_date
FROM (
SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
(select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
) a
WHERE a.effective_time_id = c.time_id
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) a
WHERE a.report_date(+) = t.report_date
) group by start_date, end_date, name
ORDER BY start_date)
group by start_date, end_date, name, rownum ) a
/*end of table that fetches current values named as a*/
,(SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name, rownum sequence
FROM ( /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(t) */ sum(leads) leads, 0 opportunities, start_date, end_date, name
FROM (
SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id(+) IN (&ORGANIZATION+JTF_ORG_SALES_GROUP)
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id(+) = :l_resource_id
) a,
(SELECT * FROM
(SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC) t
where rownum <= :l_row_count -1) t
WHERE a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
group by name,start_date, end_date
UNION ALL /*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, sum(cnv_opty_amt) opportunities, start_date, end_date, name
from (
select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id(+) = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.product_category_id= edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
) a,
(SELECT * FROM
(SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC) t
where rownum <= :l_row_count -1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.effective_period_type_id(+) = :l_period_type
group by name,start_date, end_date
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT * FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc
) t WHERE rownum <= 1) t,
(SELECT /*+ leading(c) */ SUM(NVL(a.leads,0)) leads, 0 opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
( SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id IN ( &ORGANIZATION+JTF_ORG_SALES_GROUP )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id = :l_resource_id
) a
WHERE a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
GROUP BY report_date) b
WHERE t.report_date = b.report_date(+)
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT * FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc
) t WHERE rownum <= 1) t,
(SELECT /*+ leading(c) */ 0 leads, SUM(NVL(a.cnv_opty_amt,0)) opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id) c,
(select cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
) a
WHERE a.effective_time_id = c.time_id
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) b
WHERE t.report_date = b.report_date(+)
) group by start_date, end_date, name
ORDER BY start_date)
group by start_date, end_date, name, rownum) b
WHERE a.sequence = b.sequence(+)
group by a.name,b.start_date
order by b.start_date';
  ELSE
l_query:= 'SELECT a.name VIEWBY,null BIM_MEASURE2,NVL(sum(a.leads),0) BIM_MEASURE3,NVL(sum(a.opportunities),0) BIM_MEASURE4,NVL(sum(b.leads),0) BIM_MEASURE5,NVL(sum(b.opportunities),0) BIM_MEASURE6
FROM (
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name, rownum sequence
FROM ( /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(t) */ sum(leads) leads, 0 opportunities, start_date, end_date, name
FROM (
SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id(+) IN ( :l_group_id )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id(+) = :l_resource_id
) a,
(SELECT * FROM (
select id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE rownum <= :l_row_count -1) t
WHERE a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
group by name,start_date, end_date
UNION ALL /*Opportunities*/
SELECT /*+ leading(t) */ 0 leads, sum(cnv_opty_amt) opportunities, start_date, end_date, name
FROM (
select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id(+) = :l_group_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.salesrep_id(+) = :l_resource_id
) a,
(SELECT * FROM (
select id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC) t
WHERE rownum <= :l_row_count -1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.effective_period_type_id(+) = :l_period_type
group by name,start_date, end_date
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id,start_date,end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC
) t,
(SELECT /*+ leading(c) */ SUM(a.leads) leads, 0 opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
( SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id IN (:l_group_id)
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id =:l_resource_id
) a
WHERE a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
GROUP BY report_date) a
WHERE a.report_date(+) = t.report_date
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT id time_id,start_date,end_date, value name,
trunc(&BIS_CURRENT_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_CURRENT_ASOF_DATE)
AND end_date >= trunc(&BIS_CURRENT_ASOF_DATE)
ORDER BY start_date DESC
) t,
(SELECT /*+ leading(c) */ 0 leads, SUM(cnv_opty_amt) opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_CURRENT_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
(select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id = :l_group_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.salesrep_id = :l_resource_id
) a
WHERE a.effective_time_id = c.time_id
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) a
WHERE a.report_date(+) = t.report_date
)group by start_date, end_date, name
ORDER BY start_date)
group by start_date, end_date, name, rownum ) a
/*end of table that fetches current values named as a*/
,(SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name, rownum sequence
FROM (/*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT /*+ leading(t) */ sum(leads) leads, 0 opportunities, start_date, end_date, name
FROM (
SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id(+) IN (:l_group_id)
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id(+) =:l_resource_id
) a,
(SELECT * FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC
) t where rownum <= :l_row_count -1) t
WHERE a.time_id(+) = t.time_id
AND a.period_type_id(+) = :l_period_type
AND a.update_time_id(+) =-1
AND a.update_period_type_id(+) =-1
group by name,start_date, end_date
UNION ALL /*Opportunity*/
SELECT /*+ leading(t) */ 0 leads, sum(cnv_opty_amt) opportunities, start_date, end_date, name
from (
select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id(+) = :l_group_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.salesrep_id(+) = :l_resource_id
) a,
(SELECT * FROM (
SELECT id time_id, start_date, end_date, value name
FROM '||l_table_name||'
WHERE end_date < trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date DESC
) t where rownum <= :l_row_count -1) t
WHERE a.effective_time_id(+) = t.time_id
AND a.effective_period_type_id(+) = :l_period_type
group by name,start_date, end_date
) group by start_date, end_date, name
UNION ALL /*Leads*/
SELECT sum(leads) leads, sum(opportunities) opportunities, start_date, end_date, name
from (
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT * FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc
) t WHERE rownum <= 1
) t,
(SELECT /*+ leading(c) */ SUM(NVL(a.leads,0)) leads, 0 opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
( SELECT leads, time_id, period_type_id, update_time_id,update_period_type_id
FROM BIM_I_LP_GEN_SG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.group_id IN ( :l_group_id )
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.resource_id = :l_resource_id
) a
WHERE a.time_id = c.time_id
AND a.period_type_id = c.period_type_id
AND a.update_time_id =-1
AND a.update_period_type_id =-1
GROUP BY report_date
) b WHERE t.report_date = b.report_date(+)
UNION ALL /*Opportunity*/
SELECT leads, opportunities, start_date, end_date, name
FROM (SELECT * FROM (SELECT id time_id, start_date, end_date, value name,
trunc(&BIS_PREVIOUS_ASOF_DATE) report_date
FROM '||l_table_name||'
WHERE start_date <= trunc(&BIS_PREVIOUS_ASOF_DATE)
AND end_date >= trunc(&BIS_PREVIOUS_ASOF_DATE)
ORDER BY start_date desc
) t WHERE rownum <= 1
) t,
(SELECT /*+ leading(c) */ 0 leads, SUM(NVL(a.cnv_opty_amt,0)) opportunities, report_date
FROM
(SELECT report_date, time_id, period_type_id
FROM FII_TIME_RPT_STRUCT
WHERE calendar_id = -1
AND report_date = trunc(&BIS_PREVIOUS_ASOF_DATE)
AND BITAND(record_type_id,:l_record_type) = record_type_id
) c,
(select cnv_opty_amt'||l_curr_suffix||' cnv_opty_amt, effective_time_id, effective_period_type_id
FROM BIL_BI_OPTY_PG_MV a, eni_denorm_hierarchies edh,mtl_default_category_sets mtl
WHERE a.parent_sales_group_id =  :l_group_id
AND a.product_category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mtl.category_set_id   AND mtl.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = &ITEM+ENI_ITEM_VBH_CAT
AND a.salesrep_id = :l_resource_id
) a
WHERE a.effective_time_id = c.time_id
AND a.effective_period_type_id = c.period_type_id
GROUP BY report_date) b
WHERE t.report_date = b.report_date(+)
) group by start_date, end_date, name
ORDER BY start_date)
group by start_date, end_date, name, rownum) b
WHERE a.sequence = b.sequence(+)
group by a.name,b.start_date
order by b.start_date';
  END IF;
END IF;
   END IF;

   END IF;


 /* Earlier l_resource_id was hardcoded to -1 ,to enable binding below code was added */

   IF l_resource_id is null then
      l_resource_id:= -1;
   END IF;



  x_custom_sql := l_query;
  x_custom_output.EXTEND;

  /*l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_KEY;
  l_custom_rec.attribute_value := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_CUSTOM_OUTPUT.COUNT) := l_custom_rec;
*/

  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_row_count';
  l_custom_rec.attribute_value := l_row_count;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

    l_custom_rec.attribute_name      := ':l_group_id';
  l_custom_rec.attribute_value     := l_org_sg;
  l_custom_rec.attribute_type      := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

  -- test('GET_LEAD_OPP_CHART_SQL','QUERY','',l_query);
EXCEPTION
WHEN others THEN
   l_error := SQLERRM;
   --test('GET_LEAD_OPP_CHART_SQL','EXCEPTION',l_error);
END;

PROCEDURE GET_LEAD_CAMP_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
      l_current_asof_date varchar2(80)  := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80)        := NULL;
      l_period_type varchar2(80)        := NULL;
      l_record_type varchar2(80)        := NULL;
      l_org_sg varchar2(80)             := NULL;
      l_comp_type varchar2(100)         := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(10000) := NULL;
      l_error_msg varchar2(4000);
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
      l_view_by VARCHAR2(4000);
      l_url_str VARCHAR2(1000) := null;
      l_url_sg VARCHAR2(500) := null;
      l_url_camp VARCHAR2(500) := null;
      l_compare_date date := NULL;
      l_seq_date date := NULL;
      l_resource_id  VARCHAR2(20);
      l_top_sql      varchar2(20000);
      l_filter_sql   varchar2(2000);
      l_from         varchar2(2000);
      l_where        varchar2(2000);
      l_select_grp   varchar2(20000);
      l_select_srep  varchar2(20000);
      l_comm_col1    varchar2(20000);
      l_comm_col2    varchar2(20000);
      l_grp_name0    varchar2(2000);
      l_grp_join0    varchar2(2000);
      l_srep_name1   varchar2(2000);
      l_srep_join1   varchar2(2000);
      l_srep_col_i   varchar2(2000);
      l_denorm       varchar2(2000);
      l_where_grp    varchar2(200);
      l_where_res    varchar2(2000);
      l_camp_id  varchar2(100);
      l_camp     varchar2(100);
      l_object_type  varchar2(30);
      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
      l_close_rs   VARCHAR2(500);
      l_context       VARCHAR2(5000);

BEGIN
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

   l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
              p_period_type             => l_period_type,
              p_record_type             => l_record_type,
              p_sg_id                   => l_org_sg,
	      p_resource_id             => l_resource_id,
              p_comp_type               => l_comp_type,
              p_as_of_date              => l_as_of_date,
              --p_prior_as_of_date      => l_prior_as_of_date,
	      p_page_period_type        => l_page_period_type,
              p_category_id             => l_category_id,
	      p_curr_page_time_id       => l_curr_page_time_id,
	      p_prev_page_time_id       =>  l_prev_page_time_id,
	      l_view_by                 =>  l_view_by,
	      l_col_by                  =>  l_col_by,
	      l_report_name             =>  l_report_name,
	      l_view_id                 =>  l_view_id,
	      l_close_rs                => l_close_rs,
	      l_context                 => l_context,
              p_camp_id                 => l_camp_id
              );

   l_current_asof_date := 'to_date('||to_char(l_as_of_date, 'J')||',''J'')';
   l_previous_asof_date := 'to_date('||to_char(l_prior_as_of_date, 'J')||',''J'')';

 l_url_str:='pFunctionName=BIM_I_LD_CAMP_SG_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';



  IF l_view_by  = 'CAMPAIGN+CAMPAIGN'  THEN
       l_object_type := ' ,object_type ';
  end if;

  if L_VIEW_BY = 'ORGANIZATION+JTF_ORG_SALES_GROUP' then
    l_url_sg   := ' DECODE(is_resource,1,NULL,'||''''||l_url_str||''''||' ) ';
    l_url_camp := ' null ';
  else
    l_url_sg   := ' null ';
  l_url_camp :=' DECODE(nvl(object_type,'||''''||'EONE'||''''||'),'||''''||'EONE'||''''||',NULL,'||''''||l_url_str||''''||' ) ';
  end if;

  l_top_sql := 'SELECT  viewby, VIEWBYID ,leads_new BIM_ATTRIBUTE3,curr_open BIM_ATTRIBUTE2,rank_a BIM_ATTRIBUTE4,
  (curr_total-curr_leads_changed) BIM_ATTRIBUTE6, DECODE(curr_open,0,0,((curr_total-curr_leads_changed)/curr_open)*100) BIM_ATTRIBUTE7,
  leads_dead BIM_ATTRIBUTE9,leads_closed BIM_ATTRIBUTE10,
  leads_converted BIM_ATTRIBUTE12,
  DECODE((prior_open+leads_new),0,NULL,(leads_converted/(prior_open+leads_new))*100) BIM_ATTRIBUTE13,DECODE(leads_converted,0,NULL,conversion_time/leads_converted) BIM_ATTRIBUTE14,'
  || l_url_sg ||' BIM_URL1,'||l_url_camp||' BIM_URL2,
  SUM(leads_new) OVER() BIM_GRAND_TOTAL2, SUM(curr_open) OVER() BIM_GRAND_TOTAL1,SUM(rank_a) OVER() BIM_GRAND_TOTAL3,
  SUM(curr_total-curr_leads_changed) OVER() BIM_GRAND_TOTAL4,
  DECODE(SUM(curr_open) OVER(),0,0,(SUM(curr_total-curr_leads_changed) OVER()/SUM(curr_open) OVER())*100) BIM_GRAND_TOTAL5,
  SUM(leads_closed) OVER() BIM_GRAND_TOTAL7,  SUM(leads_dead) OVER() BIM_GRAND_TOTAL6,
  SUM(leads_converted) OVER() BIM_GRAND_TOTAL8, ((SUM(leads_converted) OVER())*100)/(sum(NVL(prior_open,0)+NVL(leads_new,0)) OVER()) BIM_GRAND_TOTAL9,
  DECODE(sum(leads_converted) over(),0,NULL,sum(conversion_time) over()/sum(leads_converted) over()) BIM_GRAND_TOTAL10
  FROM ( select viewby, viewbyid'||l_object_type||' ,is_resource,
  sum(prior_open) prior_open,  sum(curr_open) curr_open,
  sum(curr_total) curr_total,  sum(leads_converted) leads_converted,
  sum(leads_new) leads_new,sum(rank_a) rank_a, sum(leads_dead) leads_dead,
  sum(leads_closed) leads_closed,  sum(curr_leads_changed) curr_leads_changed,
  sum(conversion_time) conversion_time  FROM (';

 l_filter_sql:= ' GROUP BY viewby,viewbyid'||l_object_type||',is_resource
  having
  sum(prior_open) > 0
  or sum(leads_new) > 0
  or sum(rank_a) > 0
  or sum(leads_converted) > 0
  or sum(leads_dead) > 0
  or sum(curr_open) > 0
  or sum(curr_total)-sum(curr_leads_changed) > 0
  or sum(leads_closed) > 0
  ) &ORDER_BY_CLAUSE';

  l_from := ' FROM fii_time_rpt_struct c,bim_ld_camp_sg_mv b ';

  if l_camp_id is not null then
     if l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' then
         l_camp := ' AND source_code_id = '||l_camp_id ;
    else
         l_camp := ' AND immediate_parent_id  = '||l_camp_id ;
   end if;
  else
     l_camp := ' AND immediate_parent_id  is null ';
  end if;

  l_where :=' WHERE b.time_id=c.time_id AND b.period_type_id=c.period_type_id  AND c.calendar_id=-1 '||l_camp;

  l_comm_col1 := ' SUM(case when c.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1  and &BIS_CURRENT_EFFECTIVE_START_DATE<> :g_start_date then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) prior_open,
	   SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads-(b.leads_closed+b.leads_dead+b.leads_converted) else 0 end) curr_open,
  SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads else 0 end) curr_total,0 leads_converted,0 leads_new,0 rank_a,0 leads_dead,0 leads_closed,
SUM(case when c.report_date=&BIS_CURRENT_ASOF_DATE then b.leads_changed else 0 end) curr_leads_changed, 0 conversion_time ';

  l_comm_col2:= '  0 prior_open,0 curr_open,0 curr_total,sum(leads_converted) leads_converted,sum(leads_new) leads_new,sum(rank_a) rank_a,
sum(leads_dead)  leads_dead, sum(leads_closed) leads_closed,0 curr_leads_changed,sum(conversion_time) conversion_time ';


  IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
		l_grp_name0  := ' d.group_name VIEWBY,to_char(VIEWBYID) viewbyid ';
		l_grp_join0  := ' jtf_rs_groups_tl d where q.viewbyid=d.group_id AND d.language=USERENV(''LANG'') ';

 		l_srep_name1 := ' a.source_name viewby,VIEWBYID ';
		l_srep_join1 := ' JTF_RS_RESOURCE_EXTNS_VL a where q.resource_id=a.resource_id )';

 		l_srep_col_i := ' b.resource_id ,b.resource_id ||''.''|| b.group_id ';
		l_denorm     := ' ,jtf_rs_groups_denorm den';
		l_where_grp:=' AND den.parent_group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP AND b.group_id=den.group_id AND den.immediate_parent_flag = ''Y'' AND den.latest_relationship_flag = ''Y''';

 ELSIF l_view_by  = 'CAMPAIGN+CAMPAIGN' THEN
		l_grp_name0  := ' campname.name VIEWBY,VIEWBYID viewbyid ';
		l_grp_join0  := ' bim_i_obj_name_mv campname WHERE campname.source_code_id = q.viewbyid AND campname.language=USERENV(''LANG'') ';
 		l_srep_name1 := ' campname.name viewby,VIEWBYID ';
		l_srep_join1 := ' bim_i_obj_name_mv campname WHERE campname.source_code_id = q.viewbyid AND campname.language=USERENV(''LANG''))';
 		l_srep_col_i := ' b.source_code_id ';
		l_where_grp:=' AND group_id = &ORGANIZATION+JTF_ORG_SALES_GROUP ';
 END IF;
  l_select_grp := ' SELECT '||l_grp_name0||',is_resource,prior_open,curr_open,curr_total,leads_converted,leads_new,rank_a,leads_dead,
leads_closed,curr_leads_changed,conversion_time  from  ( Select b.group_id VIEWBYID,0 is_resource,'||l_comm_col1||l_from||l_denorm ||l_where||l_where_grp||
' AND BITAND(c.record_type_id,1143)=c.record_type_id AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1) and resource_id = :l_resource_id GROUP BY  b.group_id UNION ALL
Select b.group_id VIEWBYID,0 is_resource,'||l_comm_col2||l_from||l_denorm||l_where||l_where_grp||' AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id AND c.report_date = &BIS_CURRENT_ASOF_DATE
and resource_id = :l_resource_id GROUP BY  b.group_id) q, '||l_grp_join0;

 IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
 if l_resource_id is null  then
	l_where_res := ' AND b.resource_id <> :l_resource_id ';
 else
	l_where_res := ' AND b.resource_id  = :l_resource_id ';

 end if;
 ELSE
 	l_where_res := ' AND b.resource_id  = :l_resource_id ';
END IF;
 l_select_srep:= ' SELECT '||l_srep_name1||l_object_type||',is_resource,prior_open,curr_open,curr_total,leads_converted,leads_new,rank_a,leads_dead,
leads_closed,curr_leads_changed,conversion_time from ( select '||l_srep_col_i||' VIEWBYID,1 is_resource,'||l_comm_col1||l_from||l_where||'
AND BITAND(c.record_type_id,1143)=c.record_type_id AND c.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)'||l_where_res||'
and b.group_id=:l_group_id  GROUP BY '||l_srep_col_i||' union all  select '||l_srep_col_i||'  VIEWBYID, 1 is_resource,'||l_comm_col2||l_from||l_where||'
AND BITAND(c.record_type_id,:l_record_type)=c.record_type_id AND c.report_date =&BIS_CURRENT_ASOF_DATE' ||l_where_res||' and b.group_id=:l_group_id  GROUP BY  '||l_srep_col_i||' ) q ,'||l_srep_join1;

if l_resource_id is null AND l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' then
l_query:=l_top_sql||l_select_grp||' UNION ALL '||l_select_srep||l_filter_sql;

else
l_query:=l_top_sql||l_select_srep||l_filter_sql;
end if;

if l_resource_id is null then
l_resource_id:=-1;
end if;




  x_custom_sql := l_query;


  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_time_id';
  l_custom_rec.attribute_value := l_curr_page_time_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type';
  l_custom_rec.attribute_value := l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_seq_date';
  l_custom_rec.attribute_value := to_char(l_seq_date,'DD-MON-YY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

 l_custom_rec.attribute_name := ':g_start_date';
  l_custom_rec.attribute_value := TO_CHAR(G_START_DATE,'MM-DD-YYYY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;

   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
   END GET_LEAD_CAMP_SQL;

--- commented the code having outer join ,below is the other version using MV..

/*
 PROCEDURE GET_LEAD_DETAIL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS



      l_view_by varchar2(4000);
      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
      l_qry	varchar2(15000);
      l_cls_resn_qry varchar2(15000);
      l_from    varchar2(15000);
      l_frm    varchar2(15000);
      l_frm_c  varchar2(15000);
      l_whr    varchar2(15000);
      l_whr_c    varchar2(15000);
      l_where   varchar2(15000);
      l_view_col varchar2(15000);
      l_group_by varchar2(15000);
      l_grp_c     varchar2(15000);
      l_camp_id  varchar2(100);


      l_query_rec bis_map_rec;
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--    l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_juldate  number := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(20000) := NULL;
      l_current_date date := NULL;
      l_previous_date date := NULL;
      l_current_date_str varchar2(80) := NULL;
      l_previous_date_str varchar2(80) := NULL;
      l_error_msg varchar2(4000) := NULL;
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
       l_compare_date date := NULL;
      l_seq_date date := NULL;
      l_resource_id   VARCHAR2(20);
      l_hint varchar2(200);
      l_curr VARCHAR2(50);
      l_curr_suffix VARCHAR2(50);
      l_last_refresh  VARCHAR2(23);

      l_url_str VARCHAR2(1000);
      l_lead_url_str VARCHAR2(2000);

      l_age_frm NUMBER;
      l_age_to  NUMBER;
      l_rank  varchar2(1);
      l_close_rs   VARCHAR2(500);
      l_context     VARCHAR2(5000);
      l_outer_query VARCHAR2(10000);



     CURSOR c_last_refresh(mv_name varchar2)
      IS
       select to_char(LAST_REFRESH_DATE,'DD/MM/YYYY') FROM BIS_OBJ_PROPERTIES WHERE OBJECT_NAME = mv_name
       AND OBJECT_TYPE='MV';


   BEGIN

      x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
      l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;



      get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
                 p_period_type             => l_period_type,
                 p_record_type             => l_record_type,
                 p_sg_id                   => l_org_sg,
		 p_resource_id             => l_resource_id,
                 p_comp_type               => l_comp_type,
                 p_as_of_date              => l_as_of_date,
                 --p_prior_as_of_date        => l_prior_as_of_date,
		 p_page_period_type        => l_page_period_type,
                 p_category_id             => l_category_id,
		 p_curr_page_time_id        => l_curr_page_time_id,
		 p_prev_page_time_id        => l_prev_page_time_id,
		 l_view_by                 =>  l_view_by,
		 l_col_by                  =>  l_col_by,
		 l_report_name             =>  l_report_name,
		 l_view_id                 =>  l_view_id,
		 l_close_rs                => l_close_rs,
		 l_context                 => l_context,
		 p_camp_id                 => l_camp_id
                 );

      get_currency(p_page_parameter_tbl     =>p_page_parameter_tbl,
                 l_currency             => l_curr);

l_view_id:=trim(l_view_id);
l_context:=trim(l_context);


l_lead_url_str:='pFunctionName=ASN_LEADDETPG&ASNReqFrmLeadId=';
l_url_str:='pFunctionName=BIM_I_LD_DETAIL_CAF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_report_name||'&BIM_PARAMETER6='||l_view_id||'&BIM_ATTRIBUTE11='||l_context||'&BIM_PARAMETER7=C2&BIM_PARAMETER9=';


--************  Query for Group Selection  ************
  if   l_resource_id  is null then
    l_from :=' from BIM_I_LD_HEADER_MV a,JTF_RS_GROUPS_DENORM GDN ';
    l_where := ' WHERE   gdn.group_id =  a.group_id
                and gdn.parent_group_id=:l_group_id  AND     gdn.latest_relationship_flag = ''Y'' ';

  else
    l_from :=' from BIM_I_LD_HEADER_MV a,JTF_RS_GROUP_MEMBERS gdn  ';
     l_where :=' WHERE gdn.group_id=:l_group_id and delete_flag=''N''
                 and    gdn.group_id =  a.group_id
		 and a.resource_id=:l_resource_id and a.resource_id=gdn .resource_id';
  end if;




--************  Query for Product category  Selection  ************
  if l_category_id <> 'All'  then
    if   l_resource_id  is null then
      l_from :='  from BIM_I_LP_ITEM_MV a,JTF_RS_GROUPS_DENORM GDN,eni_denorm_hierarchies edh ';
    else
      l_from :='  from BIM_I_LP_ITEM_MV a,JTF_RS_GROUP_MEMBERS gdn,eni_denorm_hierarchies edh ';
    end if;

    l_where := l_where||'  AND edh.parent_id =:l_category_id and a.product_category_id=edh.child_id';

    --    l_report_name ='LEAD_AGING'     l_report_name ='LEAD_ACTIVITY'
     if ((l_report_name ='G') or (l_report_name ='A' and l_col_by in ('D','E')))    then
      open c_last_refresh('BIM_I_LP_AGE_SG_MV');
      fetch c_last_refresh into l_last_refresh ;
      close c_last_refresh;
     end if;


  else
      --    l_report_name ='LEAD_AGING'     l_report_name ='LEAD_ACTIVITY'

     if ((l_report_name ='G') or (l_report_name ='A' and l_col_by in ('D','E')))  then
       open c_last_refresh('BIM_I_LD_AGE_SG_MV');
       fetch c_last_refresh into l_last_refresh ;
       close c_last_refresh;
     end if;



  end if;


--***********  Formation of Select Clause  ************

  l_qry:= ' select to_char(A.lead_id)         BIM_ATTRIBUTE1,
                   a.lead_name                BIM_ATTRIBUTE2,
		   a.customer_id             customer_id,
	           a.cust_category           cust_category,
   	           a.source_code_id          source_code_id,
	           a.lead_rank_id            lead_rank_id,
	           a.channel_code            channel_code,
		   to_char(a.LEAD_CREATION_DATE)  BIM_ATTRIBUTE8
		  , '||''''||l_lead_url_str||''''||'||A.lead_id  BIM_URL1 ';

--l_report_name ='LEAD_ACTIVITY'

 if l_report_name ='A' then
   if     l_col_by ='A' then ---New for Period
    l_qry:=  l_qry||',a.lead_status  lead_status
                     ,5 BIM_ATTRIBUTE10';

   elsif  l_col_by = 'B' then ---Converted
    l_qry:=  l_qry||',a.LEAD_CONVERTED_DATE BIM_ATTRIBUTE9
		    ,a.lead_converted_date-a.lead_creation_date BIM_ATTRIBUTE10 ';

  elsif  l_col_by = 'C2' then ---Closed without Conversion (Second Intermediate Report)
    l_qry:=  l_qry||',a.LEAD_closed_DATE BIM_ATTRIBUTE9
		    ,a.lead_closed_date-a.lead_creation_date BIM_ATTRIBUTE10 ';

   elsif  l_col_by ='C' then ---Closed without Conversion (First Intermediate Report)
    l_cls_resn_qry:=  ' select cls.MEANING,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',cls.MEANING) BIM_ATTRIBUTE1
                       ,count(a.lead_id) BIM_ATTRIBUTE2,avg(a.lead_closed_date-lead_creation_date) BIM_ATTRIBUTE3,
			'||''''||l_url_str||'''||a.close_reason||''&BIM_PARAMETER8=''||decode(cls.MEANING,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',cls.MEANING) BIM_URL1
--    '||''''||l_url_str||''''||''||'||decode(cls.MEANING,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',cls.MEANING)'||'||'||''''||'&BIM_PARAMETER9=''||a.close_reason   BIM_URL1
		       ,SUM(count(a.lead_id)) OVER() BIM_GRAND_TOTAL1, sum(avg(a.lead_closed_date-lead_creation_date)*count(a.lead_id)) OVER()/SUM(count(a.lead_id)) OVER() BIM_GRAND_TOTAL2';

   elsif  l_col_by ='D' then ---Current Open
    l_qry:=  l_qry||',a.lead_status  lead_status
		    ,:l_last_ref_date -lead_creation_date BIM_ATTRIBUTE10 ';

   elsif  l_col_by ='E' then ---Current Open with no Activity
    l_qry:=  l_qry||',a.lead_status  lead_status
		    ,:l_last_ref_date -lead_creation_date BIM_ATTRIBUTE10 ';
   end if;
   --l_report_name ='LEAD_AGING'
 elsif l_report_name ='G'   then
     l_qry:=  l_qry||',a.lead_status  lead_status
		    ,:l_last_ref_date-lead_creation_date BIM_ATTRIBUTE10 ';
--l_report_name ='LEAD_QUALITY'
 elsif l_report_name ='Q' then
     l_qry:=  l_qry||',a.lead_status  lead_status
     ,5 BIM_ATTRIBUTE10';
 end if;


 --l_frm := ' ,as_statuses_tl w ,as_statuses_b w1 ,hz_parties  hz,bim_i_obj_name_mv  d,as_sales_lead_ranks_vl r,bic_cust_category_v  c,so_lookups s ';



-- l_whr := '
--and w.status_code=w1.status_code
--and w.language=userenv(''LANG'')
--and w1.lead_flag=''Y''
--and w1.status_code(+)=a.lead_status
--and hz.party_id (+) =a.customer_id
--and d.source_code_id  = nvl(a.source_code_id,-1)
--AND d.language  = userenv(''LANG'')
--and r.rank_id  (+) = a.lead_rank_id
--AND c.customer_category_code (+) = a.cust_category
--and s.lookup_type(+) = ''SALES_CHANNEL''
--and s.lookup_code(+) = a.CHANNEL_CODE';

--l_report_name ='LEAD_ACTIVITY'

if l_report_name ='A' and  l_col_by in ('C','C2') then ---Closed without Conversion
 l_frm_c :=' ,as_lookups cls ';
 l_whr_c :=' and cls.LOOKUP_CODE(+)=a.close_reason
              and cls.LOOKUP_TYPE (+)=''CLOSE_REASON''  ';
 l_grp_c := ' group by
 decode(cls.MEANING,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',cls.MEANING),a.close_reason ';
end if;







--************  Query for Metric Selection  ***********
--l_report_name ='LEAD_ACTIVITY'
if l_report_name ='A' then
 if     l_col_by='A' then  --***New for period  ***
    l_where := l_where||'
    and     trunc(a.lead_creation_date) between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE  ';

 elsif  l_col_by='B' then  --**Converted**
    l_where := l_where||'
    and trunc(a.lead_converted_date) between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';


 elsif  l_col_by = 'C' then  --***Closed without Conversion Ist Intermediate *++++++**
    l_where := l_where||'
    and     trunc(a.lead_closed_date) between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
    and     a.lead_converted_date IS   NULL ';

 elsif  l_col_by = 'C2' then  --***Closed without Conversion IInd Intermediate *++++++*
    l_where := l_where||'
    and     trunc(a.lead_closed_date) between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
    and     a.lead_converted_date IS   NULL ';

    if l_close_rs = 'All' then  ---Need to log a bug on PMF,when it is null its returning 'All' by default
      l_where := l_where||' and     a.close_reason  is null';
     else
      l_where := l_where||' and     a.close_reason  = :l_close_rs';
    end if;



 elsif  l_col_by='D' then  --***Current Open  ****
    l_where := l_where||'
    and trunc(a.lead_creation_date) between :g_start_date  and  &BIS_CURRENT_ASOF_DATE
    and lead_converted_date IS NULL
    and lead_closed_date IS NULL
    and lead_dead_date IS NULL';

 elsif  l_col_by='E' then  --***Current Open with no Activity  ****
     l_where := l_where||'
     and  trunc(a.lead_creation_date) between :g_start_date and &BIS_CURRENT_ASOF_DATE
     and lead_converted_date IS NULL and lead_closed_date IS NULL
     and lead_dead_date IS NULL AND ((lead_touched_date NOT BETWEEN :g_start_date and &BIS_CURRENT_ASOF_DATE ) OR (lead_touched_date is null))  ';
 end if;

--l_report_name ='LEAD_QUALITY'
elsif  l_report_name ='Q' then

 l_from := l_from||' ,BIM_R_CODE_DEFINITIONS BCD ';
 l_where:= l_where||' and trunc(a.lead_creation_date) between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
                     and a.lead_rank_id =  BCD.OBJECT_DEF AND BCD.object_type = ''RANK_DBI''
		      and  BCD.column_name=:l_rank';



 if     l_col_by='A' then
  l_rank :='A';
 elsif  l_col_by='B' then
  l_rank :='B';
 elsif  l_col_by='C' then
  l_rank :='C';
 elsif  l_col_by='D' then
  l_rank :='D';
 elsif  l_col_by='E' then
  l_rank :='Z';
 end  if;


--l_report_name ='LEAD_AGING'
elsif  l_report_name ='G' then
l_where:= l_where||' and lead_converted_date IS NULL and lead_closed_date IS NULL
and lead_dead_date IS NULL  and lead_creation_date >= :l_last_ref_date -365 ';

if     l_col_by='A' then
  l_age_frm:=0;
  l_age_to :=2;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between   :l_age_frm and :l_age_to ';
 elsif  l_col_by='B' then
  l_age_frm:=3;
  l_age_to :=7;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='C' then
  l_age_frm:=8;
  l_age_to :=14;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='D' then
  l_age_frm:=15;
  l_age_to :=21;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='E' then
  l_age_frm:=22;
  l_age_to :=28;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='F' then
  l_age_frm:=29;
  l_age_to :=35;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between   :l_age_frm and :l_age_to ';
 elsif  l_col_by='G' then
  l_age_frm:=36;
  l_age_to :=42;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='H' then
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date > 42';
 end  if;


end if;


--************  Query for View By Selection  ***********

if l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE' then
   l_view_col:='lead_source';
 elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY'  THEN
   l_view_col:='lead_rank_id';
 elsif l_view_by = 'GEOGRAPHY+COUNTRY' THEN
    l_view_col:='lead_country';
 elsif l_view_by = 'SALES CHANNEL+SALES CHANNEL' THEN
    l_view_col:='channel_code';
 elsif l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY' THEN
  l_view_col:='cust_category';
 end if;

if   not (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' or l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  if l_view_id is null then
     l_where := l_where||' and '||l_view_col||' is null ';
   else
     l_where := l_where||' and '||l_view_col||' = :l_view_id' ;
  end if;
end if;

  l_group_by := ' group by  a.lead_id,a.LEAD_STATUS,to_char(a.LEAD_CREATION_DATE)) ';





--************* Query Formation *****************

l_outer_query := ' SELECT BIM_ATTRIBUTE1,BIM_ATTRIBUTE2,
                 (SELECT party_name FROM hz_parties WHERE party_id = INNER.customer_id) BIM_ATTRIBUTE3,
		 (SELECT customer_category_name from bic_cust_category_v c where c.customer_category_code = inner.cust_category   )  BIM_ATTRIBUTE4,
		 (SELECT name  FROM bim_i_obj_name_mv WHERE source_code_id  = INNER.source_code_id AND language  = userenv(''LANG''))    BIM_ATTRIBUTE5,
		 (SELECT r.meaning FROM as_sales_lead_ranks_vl r WHERE  r.rank_id = inner.lead_rank_id )    BIM_ATTRIBUTE6,
		 (SELECT s.meaning  FROM so_lookups s  WHERE s.lookup_type(+) = ''SALES_CHANNEL'' and s.lookup_code = inner.CHANNEL_CODE ) BIM_ATTRIBUTE7,
		 BIM_ATTRIBUTE8,BIM_URL1, ';
if l_report_name = 'A' then
   if l_col_by in ('A','D','E') then
      l_outer_query:= l_outer_query|| '(SELECT W.MEANING FROM as_statuses_tl w ,as_statuses_b w1 WHERE w.status_code=w1.status_code and w.language=userenv(''LANG'') and w1.lead_flag=''Y'' and w1.status_code=inner.lead_status) BIM_ATTRIBUTE9,
                                       BIM_ATTRIBUTE10 from ( ';
   else
     l_outer_query:= l_outer_query||' BIM_ATTRIBUTE9,BIM_ATTRIBUTE10 from ( ';
   end if;
elsif l_report_name in ('G','Q') then
  l_outer_query:= l_outer_query|| '((SELECT W.MEANING FROM as_statuses_tl w ,as_statuses_b w1 WHERE w.status_code=w1.status_code and w.language=userenv(''LANG'') and w1.lead_flag=''Y'' and w1.status_code=inner.lead_status) BIM_ATTRIBUTE9,
                  BIM_ATTRIBUTE10 from ( ';
else
l_outer_query:= l_outer_query||' BIM_ATTRIBUTE9,BIM_ATTRIBUTE10 from ( ';
end if;


  --l_report_name ='LEAD_ACTIVITY'

  if l_report_name ='A' and  l_col_by ='C' then ---Closed without Conversion (Ist intermediate Report)
   l_query:=l_cls_resn_qry||l_from||l_frm_c||l_where||l_whr_c||l_grp_c;
   --l_report_name ='LEAD_ACTIVITY'
  elsif l_report_name ='A' and  l_col_by ='C2' then ---Closed without Conversion (IInd intermediate Report)
    l_query:=l_outer_query||l_qry||l_from||l_frm_c||l_where||l_whr_c||' ) INNER ';
  else
    l_query:= l_outer_query||l_qry||l_from||l_where||' ) INNER ';
  end if;






  x_custom_sql := l_query;
  x_custom_output.EXTEND;



  l_custom_rec.attribute_name := ':l_category_id';
  l_custom_rec.attribute_value := l_category_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;


  l_custom_rec.attribute_name := ':g_start_date';
  l_custom_rec.attribute_value := TO_CHAR(G_START_DATE,'MM-DD-YYYY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_last_ref_date';
   l_custom_rec.attribute_value := l_last_refresh;
 -- l_custom_rec.attribute_value :=l_last_refresh;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.date_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_age_frm';
  l_custom_rec.attribute_value := l_age_frm;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_age_to';
  l_custom_rec.attribute_value := l_age_to;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_rank';
  l_custom_rec.attribute_value := l_rank;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_close_rs';
  l_custom_rec.attribute_value := l_close_rs;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_view_id';
  l_custom_rec.attribute_value := ''''||l_view_id||'''';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(10) := l_custom_rec;
   --test('GET_LEAD_DETAIL_SQL','QUERY','',l_query);
   EXCEPTION
   WHEN others THEN

      l_error_msg := SQLERRM;
      --test('GET_LEAD_DETAIL_SQL', 'EXCEPTION','test',l_error_msg);

   END;


*/




-- Procedure to get lead attributes from mview


PROCEDURE GET_LEAD_DETAIL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS



      l_view_by varchar2(4000);
      l_col_by  varchar2(5000);
      l_report_name varchar2(5000);
      l_view_id     varchar2(5000);
      l_qry	varchar2(15000);
      l_cls_resn_qry varchar2(15000);
      l_from    varchar2(15000);
      l_frm    varchar2(15000);
      l_frm_c  varchar2(15000);
      l_whr    varchar2(15000);
      l_whr_c    varchar2(15000);
      l_where   varchar2(15000);
      l_view_col varchar2(15000);
      l_group_by varchar2(15000);
      l_grp_c     varchar2(15000);
      l_camp_id  varchar2(100);


      l_query_rec bis_map_rec;
      l_current_asof_date varchar2(80) := null;
      l_previous_asof_date varchar2(80) := null;
      l_time_period varchar2(80) := NULL;
      l_period_type varchar2(80) := NULL;
      l_record_type varchar2(80) := NULL;
      l_org_sg varchar2(80) := NULL;
      l_comp_type varchar2(80) := NULL;
--      l_curr_page_time_id        NUMBER := NULL;
      l_prev_page_time_id       NUMBER := NULL;
      l_as_of_date              DATE := NULL;
      l_prior_as_of_date        DATE := NULL;
      l_juldate  number := NULL;
      l_page_period_type varchar2(80) := NULL;
      l_query varchar2(20000) := NULL;
      l_current_date date := NULL;
      l_previous_date date := NULL;
      l_current_date_str varchar2(80) := NULL;
      l_previous_date_str varchar2(80) := NULL;
      l_error_msg varchar2(4000) := NULL;
      l_custom_rec BIS_QUERY_ATTRIBUTES;
      l_category_id  VARCHAR2(10) := NULL;
      l_curr_page_time_id  NUMBER ;
       l_compare_date date := NULL;
      l_seq_date date := NULL;
      l_resource_id   VARCHAR2(20);
      l_hint varchar2(200);
      l_curr VARCHAR2(50);
      l_curr_suffix VARCHAR2(50);
      l_last_refresh  VARCHAR2(23);

      l_url_str VARCHAR2(1000);
      l_lead_url_str VARCHAR2(2000);

      l_age_frm NUMBER;
      l_age_to  NUMBER;
      l_rank  varchar2(1);
      l_close_rs   VARCHAR2(500);
      l_context     VARCHAR2(5000);
      l_outer_query VARCHAR2(1000);



     CURSOR c_last_refresh(mv_name varchar2)
      IS
       select to_char(LAST_REFRESH_DATE,'DD/MM/YYYY') FROM BIS_OBJ_PROPERTIES WHERE OBJECT_NAME = mv_name
       AND OBJECT_TYPE='MV';


   BEGIN

		x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
		l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

      	get_page_params (p_page_parameter_tbl     =>p_page_parameter_tbl,
						p_period_type             => l_period_type,
						p_record_type             => l_record_type,
						p_sg_id                   => l_org_sg,
						p_resource_id             => l_resource_id,
						p_comp_type               => l_comp_type,
						p_as_of_date              => l_as_of_date,
						--p_prior_as_of_date        => l_prior_as_of_date,
						p_page_period_type        => l_page_period_type,
						p_category_id             => l_category_id,
						p_curr_page_time_id        => l_curr_page_time_id,
						p_prev_page_time_id        => l_prev_page_time_id,
						l_view_by                 =>  l_view_by,
						l_col_by                  =>  l_col_by,
						l_report_name             =>  l_report_name,
						l_view_id                 =>  l_view_id,
						l_close_rs                => l_close_rs,
						l_context                 => l_context,
						p_camp_id                 => l_camp_id
						);

	get_currency(p_page_parameter_tbl     =>p_page_parameter_tbl,
	l_currency             => l_curr);

	l_view_id:=trim(l_view_id);
	l_context:=trim(l_context);


	l_lead_url_str:='pFunctionName=ASN_LEADDETPG&ASNReqFrmLeadId=';
	--l_url_str:='pFunctionName=BIM_I_LD_DETAIL_CAF&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_report_name||'&BIM_PARAMETER6='||l_view_id||'&BIM_ATTRIBUTE11='||l_context||
	--'&BIM_PARAMETER7=C2&BIM_DIM8='||l_org_sg||'&ENI_ITEM_VBH_CAT='||replace(l_category_id,'''',null)||'&BIM_PARAMETER9=';

	l_url_str:='pFunctionName=BIM_I_LD_DETAIL_CAF&pParamIds=Y&VIEW_BY='||l_view_by||'&BIM_PARAMETER5='||l_report_name||'&BIM_PARAMETER6='||l_view_id||'&BIM_ATTRIBUTE11='||l_context||
	'&BIM_PARAMETER7=C2&BIM_DIM8='||l_org_sg||'&ENI_ITEM_VBH_CAT='||replace(l_category_id,'''',null)||'&BIM_PARAMETER9=';



 --************  Query for Group Selection  ***********
  if   l_resource_id  is null then
    l_from :=' from BIM_I_LD_HEADER_MV a,JTF_RS_GROUPS_DENORM GDN ';
    l_where := ' WHERE   gdn.group_id =  a.group_id
                and gdn.parent_group_id=:l_group_id  AND     gdn.latest_relationship_flag = ''Y'' ';

  else
    l_from :=' from BIM_I_LD_HEADER_MV a,JTF_RS_GROUP_MEMBERS gdn  ';
     l_where :=' WHERE gdn.group_id=:l_group_id and delete_flag=''N''
                 and    gdn.group_id =  a.group_id
		 and a.resource_id=:l_resource_id and a.resource_id=gdn .resource_id';
  end if;




--************  Query for Product category  Selection  ************
  if l_category_id <> 'All'  then
    if   l_resource_id  is null then
      l_from :='  from BIM_I_LP_ITEM_MV a,JTF_RS_GROUPS_DENORM GDN,eni_denorm_hierarchies edh ';
    else
      l_from :='  from BIM_I_LP_ITEM_MV a,JTF_RS_GROUP_MEMBERS gdn,eni_denorm_hierarchies edh ';
    end if;

    l_where := l_where||'  AND edh.parent_id =:l_category_id and a.product_category_id=edh.child_id';

    --    l_report_name ='LEAD_AGING'     l_report_name ='LEAD_ACTIVITY'
     if ((l_report_name ='G') or (l_report_name ='A' and l_col_by in ('D','E')))    then
      open c_last_refresh('BIM_I_LP_AGE_SG_MV');
      fetch c_last_refresh into l_last_refresh ;
      close c_last_refresh;
     end if;


  else
      --    l_report_name ='LEAD_AGING'     l_report_name ='LEAD_ACTIVITY'

     if ((l_report_name ='G') or (l_report_name ='A' and l_col_by in ('D','E')))  then
       open c_last_refresh('BIM_I_LD_AGE_SG_MV');
       fetch c_last_refresh into l_last_refresh ;
       close c_last_refresh;
     end if;



  end if;


 --************  Formation of Select Clause  ***********

l_qry:= ' select   A.lead_id     BIM_ATTRIBUTE1,
                   a.lead_name    BIM_ATTRIBUTE2,
		   a.customer_id customer_id,
	           a.cust_category  cust_category,
   	           a.source_code_id  source_code_id,
	           a.lead_rank_id lead_rank_id,
	           a.channel_code channel_code,
		   a.LEAD_CREATION_DATE  BIM_ATTRIBUTE8
		  , '||''''||l_lead_url_str||''''||'||A.lead_id  BIM_URL1 ';

--l_report_name ='LEAD_ACTIVITY'

 if l_report_name ='A' then
   if     l_col_by ='A' then ---New for Period
    l_qry:=  l_qry||',a.lead_status  lead_status
                     ,5 BIM_ATTRIBUTE10';

   elsif  l_col_by = 'B' then ---Converted
    l_qry:=  l_qry||',a.LEAD_CONVERTED_DATE BIM_ATTRIBUTE9
		    ,a.lead_converted_date-a.lead_creation_date BIM_ATTRIBUTE10 ';

  elsif  l_col_by = 'C2' then ---Closed without Conversion (Second Intermediate Report)
    l_qry:=  l_qry||',a.LEAD_closed_DATE BIM_ATTRIBUTE9
		    ,a.lead_closed_date-a.lead_creation_date BIM_ATTRIBUTE10 ';

   elsif  l_col_by ='C' then ---Closed without Conversion (First Intermediate Report)
    l_cls_resn_qry:=  ' select cls.value BIM_ATTRIBUTE1
                       ,count(a.lead_id) BIM_ATTRIBUTE2,avg(a.lead_closed_date-lead_creation_date) BIM_ATTRIBUTE3,
		       decode(a.close_reason,null,null,'||''''||l_url_str||'''||a.close_reason||''&BIM_PARAMETER8=''||cls.value) BIM_URL1
		  --    '||''''||l_url_str||''''||''||'||decode(cls.MEANING,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',cls.MEANING)'||'||'||''''||'&BIM_PARAMETER9=''||a.close_reason   BIM_URL1
		       ,SUM(count(a.lead_id)) OVER() BIM_GRAND_TOTAL1, sum(avg(a.lead_closed_date-lead_creation_date)*count(a.lead_id)) OVER()/SUM(count(a.lead_id)) OVER() BIM_GRAND_TOTAL2';

   elsif  l_col_by ='D' then ---Current Open
    l_qry:=  l_qry||',a.lead_status  lead_status
		    ,:l_last_ref_date -lead_creation_date BIM_ATTRIBUTE10 ';

   elsif  l_col_by ='E' then ---Current Open with no Activity
    l_qry:=  l_qry||',a.lead_status  lead_status
		    ,:l_last_ref_date -lead_creation_date BIM_ATTRIBUTE10 ';

   end if;
   --l_report_name ='LEAD_AGING'
 elsif l_report_name ='G'   then
     l_qry:=  l_qry||',a.lead_status  lead_status
		    ,:l_last_ref_date-lead_creation_date BIM_ATTRIBUTE10 ';
--l_report_name ='LEAD_QUALITY'
 elsif l_report_name ='Q' then
     l_qry:=  l_qry||',a.lead_status  lead_status
     ,5 BIM_ATTRIBUTE10';
 end if;


 --l_frm := ' ,BIM_I_ATTR_NAME_MV w ,HZ_PARTIES  hz,bim_i_obj_name_mv  d,BIM_I_ATTR_NAME_MV r,BIM_I_ATTR_NAME_MV c,BIM_I_ATTR_NAME_MV s ';



--l_whr := ' and w.UMARK=''STATUS''
--and w.ID =nvl(a.lead_status,-999)
--and w.LANGUAGE=userenv(''LANG'')

--and hz.party_id (+) =a.customer_id

--and d.source_code_id  = nvl(a.source_code_id,-1)
--AND d.language  = userenv(''LANG'')

--and r.UMARK=''RANK''
--and r.id   = nvl(a.lead_rank_id,-999)
--and r.LANGUAGE=userenv(''LANG'')

--and c.UMARK=''CCUST''
--AND c.id = nvl(a.cust_category ,-999)
--and c.LANGUAGE=userenv(''LANG'')

--and s.UMARK = ''CHANNEL''
--and s.id = nvl(a.CHANNEL_CODE,-999)
--and s.LANGUAGE=userenv(''LANG'')';


--l_report_name ='LEAD_ACTIVITY'

if l_report_name ='A' and  l_col_by in ('C','C2') then ---Closed without Conversion
 l_frm_c :=' ,bim_i_attr_name_mv cls ';
 l_whr_c :=' and cls.UMARK=''CRES''
             and cls.id=nvl(a.close_reason,-999)
              and cls.LANGUAGE=userenv(''LANG'')  ';
 l_grp_c := ' group by cls.value,a.close_reason ';
end if;







 --************  Query for Metric Selection  ***********
--l_report_name ='LEAD_ACTIVITY'
if l_report_name ='A' then

 if     l_col_by='A' then  --***New for period  ****
    l_where := l_where||'
    and a.lead_creation_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE  ';

 elsif  l_col_by='B' then  --**Converted**
    l_where := l_where||'
    and a.lead_converted_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';


 elsif  l_col_by = 'C' then  --***Closed without Conversion Ist Intermediate *++++++**
    l_where := l_where||'
    and  a.lead_closed_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
    and  a.lead_converted_date IS   NULL ';

 elsif  l_col_by = 'C2' then  --***Closed without Conversion IInd Intermediate *++++++**
    l_where := l_where||'
    and     a.lead_closed_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
    and     a.lead_converted_date IS   NULL ';

    if l_close_rs = 'All' then  ---Need to log a bug on PMF,when it is null its returning 'All' by default
      l_where := l_where||' and     a.close_reason  is null';
     else
      l_where := l_where||' and     a.close_reason  = :l_close_rs';
    end if;



 elsif  l_col_by='D' then --***Current Open  ****
    l_where := l_where||'
    and a.lead_creation_date between :g_start_date  and  &BIS_CURRENT_ASOF_DATE
    and lead_converted_date IS NULL
    and lead_closed_date IS NULL
    and lead_dead_date IS NULL';

 elsif  l_col_by='E' then  --***Current Open with no Activity  ****
     l_where := l_where||'
     and  a.lead_creation_date between :g_start_date and &BIS_CURRENT_ASOF_DATE
     and lead_converted_date IS NULL and lead_closed_date IS NULL
     and lead_dead_date IS NULL AND ((lead_touched_date NOT BETWEEN :g_start_date and &BIS_CURRENT_ASOF_DATE ) OR (lead_touched_date is null)) ';
 end if;
--l_report_name ='LEAD_QUALITY'
elsif  l_report_name ='Q' then

if  l_col_by <> 'E' then
 l_from := l_from||' ,BIM_R_CODE_DEFINITIONS BCD ';


 l_where:= l_where||' and a.lead_creation_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
                     and a.lead_rank_id =  BCD.OBJECT_DEF AND BCD.object_type = ''RANK_DBI''
		      and  BCD.column_name=:l_rank';
else
 l_where:= l_where||' and a.lead_creation_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
                     and NVL(a.lead_rank_id,-999) not in ( SELECT OBJECT_DEF FROM BIM_R_CODE_DEFINITIONS WHERE object_type = ''RANK_DBI'' AND column_name IN (''A'',''B'',''C'',''D''))';
end if;


 if     l_col_by='A' then
  l_rank :='A';
 elsif  l_col_by='B' then
  l_rank :='B';
 elsif  l_col_by='C' then
  l_rank :='C';
 elsif  l_col_by='D' then
  l_rank :='D';
 elsif  l_col_by='E' then
  l_rank :='Z';
 end  if;


--l_report_name ='LEAD_AGING'
elsif  l_report_name ='G' then
l_where:= l_where||' and lead_converted_date IS NULL and lead_closed_date IS NULL
and lead_dead_date IS NULL  and lead_creation_date >= :l_last_ref_date -365 ';

if     l_col_by='A' then
  l_age_frm:=0;
  l_age_to :=2;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between   :l_age_frm and :l_age_to ';
 elsif  l_col_by='B' then
  l_age_frm:=3;
  l_age_to :=7;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='C' then
  l_age_frm:=8;
  l_age_to :=14;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='D' then
  l_age_frm:=15;
  l_age_to :=21;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='E' then
  l_age_frm:=22;
  l_age_to :=28;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='F' then
  l_age_frm:=29;
  l_age_to :=35;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between   :l_age_frm and :l_age_to ';
 elsif  l_col_by='G' then
  l_age_frm:=36;
  l_age_to :=42;
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date between  :l_age_frm and :l_age_to ';
 elsif  l_col_by='H' then
  l_where:= l_where||' and   :l_last_ref_date - a.lead_creation_date > 42';
 end  if;


end if;

 --************  Query for View By Selection  ***********

if l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE' then
   l_view_col:='lead_source';
 elsif l_view_by = 'BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY'  THEN
   l_view_col:='lead_rank_id';
 elsif l_view_by = 'GEOGRAPHY+COUNTRY' THEN
    l_view_col:='lead_country';
 elsif l_view_by = 'SALES CHANNEL+SALES CHANNEL' THEN
    l_view_col:='channel_code';
 elsif l_view_by = 'CUSTOMER CATEGORY+CUSTOMER CATEGORY' THEN
  l_view_col:='cust_category';
 end if;

if   not (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' or l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  if l_view_id is null then
     l_where := l_where||' and '||l_view_col||' is null ';
   else
     l_where := l_where||' and '||l_view_col||' = :l_view_id' ;
  end if;
end if;

  l_group_by := ' group by  a.lead_id,a.LEAD_STATUS,a.LEAD_CREATION_DATE) ';






--************* Query Formation *****************

l_outer_query := ' SELECT BIM_ATTRIBUTE1,BIM_ATTRIBUTE2,
                 (SELECT party_name FROM hz_parties WHERE party_id = INNER.customer_id) BIM_ATTRIBUTE3,
		 (SELECT value FROM bim_i_attr_name_mv WHERE UMARK=''CCUST'' AND id = INNER.cust_category and LANGUAGE=userenv(''LANG''))  BIM_ATTRIBUTE4,
		 (SELECT name  FROM bim_i_obj_name_mv WHERE source_code_id  = INNER.source_code_id AND language  = userenv(''LANG''))    BIM_ATTRIBUTE5,
		 (SELECT value FROM bim_i_attr_name_mv WHERE UMARK=''RANK'' AND id = INNER.lead_rank_id and LANGUAGE=userenv(''LANG''))    BIM_ATTRIBUTE6,
		 (SELECT value FROM bim_i_attr_name_mv WHERE UMARK=''CHANNEL'' AND id = INNER.CHANNEL_CODE and LANGUAGE=userenv(''LANG'')) BIM_ATTRIBUTE7,
		 BIM_ATTRIBUTE8,BIM_URL1, ';
if l_report_name = 'A' then
   if l_col_by in ('A','D','E') then
      l_outer_query:= l_outer_query|| '(SELECT value FROM bim_i_attr_name_mv WHERE UMARK=''STATUS'' AND id = lead_status and LANGUAGE=userenv(''LANG'')) BIM_ATTRIBUTE9,BIM_ATTRIBUTE10 from ( ';
   else
     l_outer_query:= l_outer_query||' BIM_ATTRIBUTE9,BIM_ATTRIBUTE10 from ( ';
   end if;
elsif l_report_name in ('G','Q') then
  l_outer_query:= l_outer_query|| '(SELECT value FROM bim_i_attr_name_mv WHERE UMARK=''STATUS'' AND id = lead_status and LANGUAGE=userenv(''LANG'')) BIM_ATTRIBUTE9,BIM_ATTRIBUTE10 from ( ';
else
l_outer_query:= l_outer_query||' BIM_ATTRIBUTE9,BIM_ATTRIBUTE10 from ( ';
end if;

  --l_report_name ='LEAD_ACTIVITY'

  if l_report_name ='A' and  l_col_by ='C' then ---Closed without Conversion (Ist intermediate Report)
   l_query:=l_cls_resn_qry||l_from||l_frm_c||l_where||l_whr_c||l_grp_c;
   --l_report_name ='LEAD_ACTIVITY'
  elsif l_report_name ='A' and  l_col_by ='C2' then ---Closed without Conversion (IInd intermediate Report)
   l_query:=l_outer_query||l_qry||l_from||l_frm_c||l_where||l_whr_c||' ) INNER ';
  else
   l_query:= l_outer_query||l_qry||l_from||l_where||' ) INNER ';
  end if;


  x_custom_sql := l_query||'&ORDER_BY_CLAUSE';
  x_custom_output.EXTEND;



  l_custom_rec.attribute_name := ':l_category_id';
  l_custom_rec.attribute_value := l_category_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_group_id';
  l_custom_rec.attribute_value := l_org_sg;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := l_resource_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;


  l_custom_rec.attribute_name := ':g_start_date';
  l_custom_rec.attribute_value := TO_CHAR(G_START_DATE,'MM-DD-YYYY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_last_ref_date';
   l_custom_rec.attribute_value := l_last_refresh;
 -- l_custom_rec.attribute_value :=l_last_refresh;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.date_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_age_frm';
  l_custom_rec.attribute_value := l_age_frm;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_age_to';
  l_custom_rec.attribute_value := l_age_to;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_rank';
  l_custom_rec.attribute_value := l_rank;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_close_rs';
  l_custom_rec.attribute_value := l_close_rs;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_view_id';
  l_custom_rec.attribute_value := ''''||l_view_id||'''';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(10) := l_custom_rec;



   --test('GET_LEAD_DETAIL_SQL','QUERY','',l_query);
   EXCEPTION
   WHEN others THEN
      l_error_msg := SQLERRM;
      --test('GET_LEAD_DETAIL_SQL', 'EXCEPTION','test',l_error_msg);
   END;


FUNCTION get_dummy_sql
 RETURN varchar2 IS
BEGIN
   RETURN 'select 1 BIM_MEASURE1 from dual where 1=2';
END;

FUNCTION get_params_new RETURN varchar2 IS

 l_sg_id	VARCHAR2(100);
 period_id NUMBER;
 BEGIN

   l_sg_id := GET_SALES_GROUP_ID;
   period_id := -1;

 return '&AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
'&BIM_DIM6='||'TIME_COMPARISON_TYPE+YEARLY'||
'&BIM_DIM3_FROM='||period_id||'&BIM_DIM3_TO='||period_id||
'&BIM_DIM8='||l_sg_id||'&BIM_DIM9=FII_GLOBAL1&ENI_ITEM_VBH_CAT=All';

 END get_params_new;

 FUNCTION get_params RETURN varchar2 IS
   l_sg_id   VARCHAR2(100);
   period_id NUMBER;
 BEGIN
   l_sg_id := GET_SALES_GROUP_ID;
   period_id := -1;

 return '&AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
'&BIM_DIM6='||'TIME_COMPARISON_TYPE+YEARLY'||
'&BIM_DIM3_FROM='||period_id||'&BIM_DIM3_TO='||period_id||
'&JTF_ORG_SALES_GROUP='||l_sg_id||'&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP' ;

 END get_params;


-- Start of comments
-- NAME
--    GET_LEAD_AGING_SG_SQL
--
-- PURPOSE
--    Returns the default sales group id.
--
-- NOTES
--
-- HISTORY
-- 08/27/2002  dmvincen  created.
--
-- End of comments
   FUNCTION GET_SALES_GROUP_ID RETURN VARCHAR2 IS
   BEGIN
      RETURN JTF_RS_DBI_CONC_PUB.GET_SG_ID();
   END GET_SALES_GROUP_ID;

   PROCEDURE RESET_ATTRIBUTES
   IS
   BEGIN
      UPDATE BIS_USER_ATTRIBUTES
      SET SESSION_VALUE = '''100000148''', SESSION_DESCRIPTION = '* LELLISON'
      WHERE function_name = 'BIM_I_LEAD_MGMT_PARAM_PORTLET'
      AND attribute_name ='ORGANIZATION+JTF_ORG_SALES_GROUP';

   END RESET_ATTRIBUTES;
/*
begin
   BIM_I_LEAD_MGMT_PVT.RESET_ATTRIBUTES;

*/
END;

/
