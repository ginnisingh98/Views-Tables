--------------------------------------------------------
--  DDL for Package Body PJI_PMV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_UTIL" AS
-- $Header: PJIRX04B.pls 120.10.12000000.4 2007/03/12 06:04:17 pschandr ship $

-- Variable added by pschandr
-- This label holds the language in which the labels in other global variables are populated
-- and translated labels to be displayed in pmv reports.
G_User_Lang             VARCHAR2(52):='US';

-- Variables Added by vmangulu
-- Following are the global variables used to cache the label codes
-- and translated labels to be displayed in pmv reports.
G_Measure_Short_Code	Measure_Label_Code_Tbl;
G_Measure_Label		Measure_Label_Tbl;

-- Following are global variables used to cache full/xtd translated
-- string for period types.
G_Year_Label	VARCHAR2(8):='YEAR';
G_Quarter_Label	VARCHAR2(8):='QTR';
G_Period_Label	VARCHAR2(8):='PERIOD';
G_Week_Label	VARCHAR2(8):='WEEK';

G_YTD_Label		VARCHAR2(8):='YTD';
G_QTD_Label		VARCHAR2(8):='QTD';
G_PTD_Label		VARCHAR2(8):='PTD';
G_WTD_Label		VARCHAR2(8):='WTD';

G_Prior_Label	VARCHAR2(80);
G_Budget_Label	VARCHAR2(80);

G_Labor_Units_LT    VARCHAR2(30):='PJI_REPORT_LABOR_UNITS';

G_Graph_Labels_LT 		VARCHAR2(30):='PJI_PMV_GRAPH_LABELS';
G_Budget_Label_LC 		VARCHAR2(30):='PJI_BUDGET_LABEL';
G_Prior_Budget_Label_LC		VARCHAR2(30):='PJI_PRIOR_LABEL';

G_FTE_Level		VARCHAR2(8);

FUNCTION Get_Labor_Unit RETURN VARCHAR2
IS
   l_labor_unit VARCHAR2(80);
BEGIN
   SELECT lkp.meaning
   INTO   l_labor_unit
   FROM   pji_lookups lkp,
          pji_system_settings setup
   WHERE  lkp.lookup_type = G_Labor_Units_LT
     AND  lkp.lookup_code = setup.report_labor_units;

   RETURN l_labor_unit;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 'Hours';
END Get_Labor_Unit;


/* ----------------------------------------------------------
   Function: get_projects
   This function concatenates all the projects of a
   person which are non-administrative and the forecast_item
   details have not been summarized, given a date.
   ----------------------------------------------------------*/
FUNCTION get_projects ( p_person_id    IN  NUMBER
                       ,p_exp_org_id   IN  NUMBER
                       ,p_date         IN  DATE)
  RETURN VARCHAR2
  IS
      l_projects   VARCHAR2(500) := '';

      CURSOR projects IS
         select distinct proj.name
         from  pa_projects_all           proj
              ,pa_forecast_items         fi
              ,pa_forecast_item_details  fid
         where fi.item_date                     = trunc(p_date)
           and proj.project_id                  = fi.project_id
           and fi.person_id                     = p_person_id
           and fi.expenditure_organization_id   = p_exp_org_id
           and fi.forecast_item_id              = fid.forecast_item_id
           and fid.pji_summarized_flag          is null
           and rownum                           = 1;

BEGIN

  OPEN projects;
  FETCH projects INTO l_projects;
  CLOSE projects;

  RETURN l_projects;

EXCEPTION
  WHEN OTHERS THEN
     RETURN null;
END get_projects;


/* ------------------------------------------------------
   Function: Get_Available_From
   This function returns the date that the person
   is available_from, given the from_date, the as_of_date,
   and the availability threshold.
   ------------------------------------------------------*/

FUNCTION Get_Available_From (p_person_id    IN  NUMBER
                            ,p_exp_org_id   IN  NUMBER
                            ,p_from_date    IN  NUMBER
                            ,p_as_of_date   IN  NUMBER
                            ,p_threshold    IN  NUMBER)
  RETURN VARCHAR2
  IS
     l_j_date       NUMBER;
     l_date         DATE;
     l_start_time   NUMBER;
     l_end_time     NUMBER;

BEGIN

  l_date       := to_date(p_from_date, 'J');

  -- subtract a year from the from_date value
  l_start_time := to_number(to_char(ADD_MONTHS(l_date,(-12)), 'J'));
  l_end_time   := p_as_of_date;

  -- depending on the availability threshold values, the following
  -- read the data using available_res_count_bkt#_s respectively
  -- get the max time when the resource is not available
  -- (where the available_res_count_bkt#_s will be zero)

  IF p_threshold = 1 THEN

         SELECT max(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt1_s = 0;

  ELSIF p_threshold = 2 THEN

         SELECT max(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt2_s = 0;

  ELSIF p_threshold = 3 THEN

         SELECT max(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt3_s = 0;

  ELSIF p_threshold = 4 THEN

         SELECT max(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt4_s = 0;

  ELSIF p_threshold = 5 THEN

         SELECT max(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt5_s = 0;

  END IF;

  -- if the value is equal to the start or end time, then the code
  -- could not find the available from date (cannot go beyond
  -- the time limit), return null
  IF l_j_date = l_start_time or l_j_date = l_end_time or l_j_date is null THEN
     RETURN NULL;

  ELSE
     -- return the date+1 because the next day, the resource
     -- is available
     RETURN to_char(to_date(l_j_date, 'J')+1);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN null;

  WHEN OTHERS THEN
     RETURN null;

END Get_Available_From;


/* ------------------------------------------------------
   Function: Get_Next_Asgmt_Date
   This function returns the date that the person has the
   next assignment, given the to_date, the as_of_date,
   and the availability threshold.
   ------------------------------------------------------*/
FUNCTION Get_Next_Asgmt_Date (p_person_id    IN  NUMBER
                             ,p_exp_org_id   IN  NUMBER
                             ,p_to_date      IN  NUMBER
                             ,p_as_of_date   IN  NUMBER
                             ,p_threshold    IN  NUMBER)
  RETURN VARCHAR2
  IS
     l_j_date       NUMBER;
     l_date         DATE;
     l_start_time   NUMBER;
     l_end_time     NUMBER;

BEGIN

  l_date       := to_date(p_to_date, 'J');
  l_start_time := p_as_of_date;

  -- add a year to the to_date value
  l_end_time   := to_number(to_char(ADD_MONTHS(l_date, 12), 'J'));

  -- depending on the availability threshold values, the following
  -- read the data using available_res_count_bkt#_s respectively
  -- get the min time when the resource is not available
  -- (where the available_res_count_bkt#_s will be zero)

  IF p_threshold = 1 THEN

         SELECT min(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt1_s = 0;

  ELSIF p_threshold = 2 THEN

         SELECT min(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt2_s = 0;

  ELSIF p_threshold = 3 THEN

         SELECT min(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt3_s = 0;

  ELSIF p_threshold = 4 THEN

         SELECT min(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt4_s = 0;

  ELSIF p_threshold = 5 THEN

         SELECT min(time_id)
         INTO   l_j_date
         FROM   pji_rm_res_f
         WHERE  person_id           = p_person_id
           and  expenditure_organization_id  = p_exp_org_id
           and  period_type_id      = 1
           and  time_id between l_start_time and l_end_time
           and  available_res_count_bkt5_s = 0;

  END IF;


  -- if the value is equal to the start or end time, then the code
  -- could not find the next assignment date (cannot go beyond
  -- the time limit), return null
  IF l_j_date = l_end_time or l_j_date = l_start_time or l_j_date is null THEN
     RETURN NULL;

  ELSE
     -- return the date found (because resource has assignment on that
     -- day as availability is zero)
     RETURN to_char(to_date(l_j_date, 'J'));
  END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN null;

  WHEN OTHERS THEN
     RETURN null;

END Get_Next_Asgmt_Date;

/* ------------------------------------------------------
   Function : GetTimeLevelLabel
   This function returns the concatenated attribute label
   name long. The function concatenates the label names with
   year/quarter/period or YTD/QTD/PTD. This function is called
   from the PMV report and relies on cached values of variables
   called in the package init section.
   ------------------------------------------------------*/
-- Function GetTimeLevelLabel Follows
  FUNCTION GetTimeLevelLabel( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL
                            , p_Label_Code            VARCHAR2    DEFAULT NULL
                            , p_Bit_Mode              VARCHAR2    DEFAULT '1')
  RETURN VARCHAR2	IS
	l_Time_Level_Value VARCHAR2(80);
	l_Time_Level VARCHAR2(8);
	l_Label VARCHAR2(80);
	l_Bit_Mode	NUMBER:=TO_NUMBER(p_Bit_Mode);
	l_FTE_Level VARCHAR2(8);
	l_User_Lang VARCHAR2(52);
	BEGIN
		--Bug 5598041: Invoke Init procedure if the labels are not populated in the correct language
		BEGIN
			SELECT userenv('LANG') INTO l_User_Lang FROM dual;
			IF G_User_Lang <> l_User_Lang THEN
				Init;
			END IF;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

		FOR i IN 1..p_page_parameter_tbl.COUNT
		LOOP
			IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
				l_Time_Level_Value:=p_page_parameter_tbl(i).parameter_value;
			END IF;
		END LOOP;
		/*
		** Determine the time level as full translated strings like
		** 'Year/Quarter/Period/Week' for forecast and budget measures.
		** For all the other cases consider the time level as to date
		** like 'YTD/QTD/PTD/WTD'.
		*/
		IF l_time_level_value IS NOT NULL THEN
		 	IF BITAND(l_Bit_Mode, 2) = 2 THEN
				CASE (l_time_level_value)
					WHEN 'FII_TIME_ENT_YEAR' THEN
						l_Time_Level:='_'||G_Year_Label;
					WHEN 'FII_TIME_ENT_QTR' THEN
						l_Time_Level:='_'||G_Quarter_Label;
					WHEN 'FII_TIME_ENT_PERIOD' THEN
						l_Time_Level:='_'||G_Period_Label;
					WHEN 'FII_TIME_CAL_YEAR' THEN
						l_Time_Level:='_'||G_Year_Label;
					WHEN 'FII_TIME_CAL_QTR' THEN
						l_Time_Level:='_'||G_Quarter_Label;
					WHEN 'FII_TIME_CAL_PERIOD' THEN
						l_Time_Level:='_'||G_Period_Label;
					WHEN 'PJI_TIME_PA_PERIOD' THEN
						l_Time_Level:='_'||G_Period_Label;
					WHEN 'FII_TIME_WEEK' THEN
						l_Time_Level:='_'||G_Week_Label;
				END CASE;
			ELSIF BITAND(l_Bit_Mode, 1) = 1 THEN
				CASE (l_time_level_value)
					WHEN 'FII_TIME_ENT_YEAR' THEN
						l_Time_Level:='_'||G_YTD_Label;
					WHEN 'FII_TIME_ENT_QTR' THEN
						l_Time_Level:='_'||G_QTD_Label;
					WHEN 'FII_TIME_ENT_PERIOD' THEN
						l_Time_Level:='_'||G_PTD_Label;
					WHEN 'FII_TIME_CAL_YEAR' THEN
						l_Time_Level:='_'||G_YTD_Label;
					WHEN 'FII_TIME_CAL_QTR' THEN
						l_Time_Level:='_'||G_QTD_Label;
					WHEN 'FII_TIME_CAL_PERIOD' THEN
						l_Time_Level:='_'||G_PTD_Label;
					WHEN 'PJI_TIME_PA_PERIOD' THEN
						l_Time_Level:='_'||G_PTD_Label;
					WHEN 'FII_TIME_WEEK' THEN
						l_Time_Level:='_'||G_WTD_Label;
				END CASE;
			ELSE
				l_Time_Level:='';
			END IF;
		END IF;

	 	IF BITAND(l_Bit_Mode, 4) = 4 THEN
			l_FTE_Level:='_'||G_FTE_Level;
		ELSE
			l_FTE_Level:='';
		END IF;

		--	return 'PJI_MSR_'||p_Label_Code||l_Time_Level||l_FTE_Level;

		/*
		** Lookup the translated value of the label code
		** in the cached global variable.
		*/
		IF p_Label_Code IS NOT NULL THEN
			FOR i in 1..G_Measure_Short_Code.LAST LOOP
				IF 'PJI_MSR_'||p_Label_Code||l_Time_Level||l_FTE_Level = G_Measure_Short_Code(i) THEN
					l_Label := G_Measure_Label(i);
				END IF;
			END LOOP;
		END IF;


		/*
		** Return the concatenated values of translated time level
		** and the translated label code.
		*/
  	RETURN l_Label;
	EXCEPTION
 		WHEN OTHERS THEN
			RETURN NULL;
	END GetTimeLevelLabel;
-- Function GetTimeLevelLabel ends here

/* ------------------------------------------------------
   Function : GetPriorLabel
   This function returns the concatenated attribute label
   name long. The function concatenates the label names with
   year/quarter/period or YTD/QTD/PTD. This function is called
   from the PMV report and relies on cached values of variables
   called in the package init section.
   ------------------------------------------------------*/
-- Function GetPriorLabel Follows
  FUNCTION GetPriorLabel( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL )
  RETURN VARCHAR2	IS
  l_Label			VARCHAR2(80);
  l_Time_Comparision	VARCHAR2(30);
  l_User_Lang VARCHAR2(52);
  BEGIN
	--Bug 5598041: Invoke Init procedure if labels are not populated in the correct language
	BEGIN
		SELECT userenv('LANG') INTO l_User_Lang FROM dual;
		IF G_User_Lang <> l_User_Lang THEN
			Init;
		END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	FOR i IN 1..p_page_parameter_tbl.COUNT
	LOOP
		IF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
			l_Time_Comparision:=p_page_parameter_tbl(i).parameter_value;
		END IF;
	END LOOP;

	IF l_Time_Comparision = 'BUDGET' THEN
		l_Label:=G_Budget_Label;
	ELSE
		l_Label:=G_Prior_Label;
	END IF;

	/*
	** Return the correct label back to report.
	*/
  	RETURN l_Label;
   EXCEPTION
   WHEN OTHERS THEN
	RETURN NULL;
   END GetPriorLabel;
-- Function GetPriorLabel ends here



/* ----------------------------------------------------------------------
   Function : RA2_RA5_URL
   This API is used to concatenate drill across URL link from RA2 to RA5
   report. It determines the from, to and current date values for RA5.
   ----------------------------------------------------------------------*/

FUNCTION RA2_RA5_URL  (p_date           IN NUMBER,
                       p_week           IN VARCHAR2,
                       p_organization   IN VARCHAR2,
                       p_operating_unit IN VARCHAR2,
                       p_threshold      IN NUMBER)

RETURN VARCHAR IS
   l_date         DATE;
   l_is_date      DATE;
   l_start_date   DATE;
   l_Url          VARCHAR2(400);
   l_value        VARCHAR2(100);

   CURSOR get_week(l_is_date IN DATE) IS
     SELECT value, start_date
     FROM fii_time_week_v
     WHERE l_is_date between start_date and end_date;

BEGIN

   l_date:= to_date(p_date, 'J');

   -- get the corresponding week start_date
   IF p_week = 'W0' THEN
      l_is_date  := l_date;
   ELSIF p_week = 'W1' THEN
      l_is_date  := l_date + 7;
   ELSIF p_week = 'W2' THEN
      l_is_date  := l_date + 14;
   ELSIF p_week = 'W3' THEN
      l_is_date  := l_date + 21;
   ELSIF p_week = 'W4' THEN
      l_is_date  := l_date + 28;
   END IF;

   OPEN get_week(l_is_date);
   FETCH get_week INTO l_value, l_start_date;
   CLOSE get_week;

  --Bug 5603228, 5603194 Add nls_date_language parameter to to_date function call
   l_Url :=   'AS_OF_DATE=' ||to_char(l_start_date,'DD/MM/YYYY')
            ||'&pFunctionName=PJI_REP_RA5'
            ||'&PJI_REP_DIM_18='||to_char(to_date(l_value,'DD/MM/YYYY', 'nls_date_language = AMERICAN'),'DD/MM/YYYY')
     	    ||'&PJI_REP_DIM_2='||p_organization
     	    ||'&PJI_REP_DIM_1='||p_operating_unit
            ||'&PJI_REP_DIM_28='||p_threshold
            ||'&pParamIds=Y';



RETURN l_URL;
END RA2_RA5_URL;


/* -------------------------------------------------------------------------------------------------
   Function : Drill_To_Proj_Perf_URL(PROJECT_ID, p_Currency_Record_Type, p_As_of_Date,p_Period_Type)
  ------------------------------------------------------------------------------------------------*/



FUNCTION Drill_To_Proj_Perf_URL( PROJECT_ID              IN NUMBER
                                ,p_Currency_Record_Type  IN NUMBER
                                ,p_As_Of_Date            IN NUMBER
                                ,p_Period_Type           IN VARCHAR2)
RETURN VARCHAR2 IS
  l_Url          VARCHAR2(1000);
BEGIN

   l_Url:=  'paFromPji=Y&pFunctionName=PJI_VIEW_PROJ_PERF'
          ||'&paProjectId='	       ||TO_CHAR(PROJECT_ID)
          ||'&paAsOfDate='	       ||TO_CHAR(p_As_Of_Date)
          ||'&paCurrencyRecordType='   ||TO_CHAR(p_Currency_Record_Type)
          ||'&paPeriodType='	 ||p_Period_Type
          ||'&paCstBudgetType='  ||PJI_UTILS.GET_SETUP_PARAMETER('COST_FP_TYPE_ID')
          ||'&paCstForecastType='||PJI_UTILS.GET_SETUP_PARAMETER('COST_FORECAST_FP_TYPE_ID')
          ||'&paRevBudgetType='  ||PJI_UTILS.GET_SETUP_PARAMETER('REVENUE_FP_TYPE_ID')
          ||'&paRevForecastType='||PJI_UTILS.GET_SETUP_PARAMETER('REVENUE_FORECAST_FP_TYPE_ID');


   -- dbms_output.put_line('URL = ' || l_Url);

RETURN l_Url;
END Drill_To_Proj_Perf_URL;



/* ----------------------------------------------------------------------
   Function : RA4_RA5_URL
   This API is used to concatenate drill across URL link from RA4 to RA5
   report.
   ----------------------------------------------------------------------*/

FUNCTION RA4_RA5_URL       (p_week           IN VARCHAR2,
                            p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN NUMBER,
                            p_period_type    IN VARCHAR2)

RETURN VARCHAR IS
   l_start_date   DATE;
   l_Url          VARCHAR2(1000);

BEGIN

IF p_period_type='FII_TIME_WEEK'
 THEN

   select start_date
   into l_start_date
   from fii_time_week_v
   where value = p_week;

  -- constructing the URL string
  --Bug 5603228, 5603194 Add nls_date_language parameter to to_date function call
   l_Url:=   'AS_OF_DATE='         ||to_char(l_start_date,'DD/MM/YYYY')
             ||'&pFunctionName=PJI_REP_RA5'
             ||'&PJI_REP_DIM_18='||to_char(to_date(p_week,'DD/MM/YYYY', 'nls_date_language = AMERICAN'),'DD/MM/YYYY')
	     ||'&PJI_REP_DIM_2='      ||p_organization
	     ||'&PJI_REP_DIM_28='     ||p_threshold
	     ||'&PJI_REP_DIM_1='      ||p_operating_unit
	     ||'&pParamIds=Y';

   -- dbms_output.put_line('URL = ' || l_Url);

ELSIF p_period_type='PJI_TIME_PA_PERIOD'
 THEN
     L_URL:= NULL;
END IF;

RETURN l_Url;
END RA4_RA5_URL;

/* ----------------------------------------------------
   Procedure : Redirect_RA2_RA5
   This API is used to drill across from RA2 to RA5
   report. It determines the from, to and current date
   values for RA5.
   ---------------------------------------------------- */

PROCEDURE Redirect_RA2_RA5 (p_date           IN VARCHAR2,
                            p_week           IN VARCHAR2,
                            p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN VARCHAR2
)
IS
   l_date         DATE;
   l_is_date      DATE;
   l_start_date   DATE;
   l_Url          VARCHAR2(400);
   l_value        VARCHAR2(100);

   -- modified to fix bug2505055 (due to fii bug)
   -- get value from date between start date and end date
   CURSOR get_week(l_is_date IN DATE) IS
     SELECT value, start_date
     FROM fii_time_week_v
     WHERE l_is_date between start_date and end_date;

BEGIN

   l_date := FND_DATE.CHARDATE_TO_DATE(p_date);

   -- get the week id and week start date of the p_date parameter
   /*
   select week_id, week_start_date
   into l_week_id, l_week_date
   from fii_time_day
   where report_date = l_date;  */

   -- get the corresponding week start_date
   IF p_week = 'W0' THEN
      l_is_date  := l_date;
   ELSIF p_week = 'W1' THEN
      l_is_date  := l_date + 7;
   ELSIF p_week = 'W2' THEN
      l_is_date  := l_date + 14;
   ELSIF p_week = 'W3' THEN
      l_is_date  := l_date + 21;
   ELSIF p_week = 'W4' THEN
      l_is_date  := l_date + 28;
   END IF;

   -- get the dates for the beginning of the week (for FROM)
   -- and the end of the week (for TO)
   OPEN get_week(l_is_date);
   FETCH get_week INTO l_value, l_start_date;
   CLOSE get_week;

   -- constructing the URL string
   l_Url := '&PJI_REP_DIM_18_FROM=' || l_value ||
            '&PJI_REP_DIM_18_TO=' || l_value ||
            '&AS_OF_DATE=' || l_start_date ||
   	    '&PJI_REP_DIM_2=' || p_organization ||
            '&PJI_REP_DIM_28=' || p_threshold ||
   	    '&PJI_REP_DIM_1=' || p_operating_unit;

   --dbms_output.put_line('URL = ' || l_Url);

   bisviewer_pub.showreport( pUrlString    => 'pRegionCode=PJI_REP_RA5' || l_Url
                            ,pFunctionName => 'PJI_REP_RA5'
                            ,pUserId       => icx_sec.getID(icx_sec.PV_WEB_USER_ID)
                            ,pSessionId    => icx_sec.getID(icx_sec.PV_SESSION_ID)
                            ,pRespId       => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

END Redirect_RA2_RA5;


/* ----------------------------------------------------
   Procedure : Redirect_RA1_RA4
   This API is used to drill across from RA1 to RA4
   report. It determines the as_of_date value for RA4.
   This is a link for the % Available column.
   ---------------------------------------------------- */
PROCEDURE Redirect_RA1_RA4 (p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN VARCHAR2,
                            p_period_type    IN VARCHAR2,
                            p_start_time     IN VARCHAR2
)
IS
   l_Url            VARCHAR2(2000);
   l_date           DATE;

BEGIN

   l_date := to_date(p_start_time, 'j');

   l_Url := '&AS_OF_DATE=' || l_date ||
            '&PJI_REP_DIM_2=' || p_organization ||
            '&PJI_REP_DIM_28=' || p_threshold ||
            '&PJI_PERIOD_TYPE=Enterprise Week&VIEW_BY=TIME+FII_TIME_WEEK';

   IF p_operating_unit is not null then
       l_Url := l_Url || '&PJI_REP_DIM_1=' || p_operating_unit;
   END IF;

   --dbms_output.put_line('URL = ' || l_Url);

   bisviewer_pub.showreport('pRegionCode=PJI_REP_RA4' || l_Url
                            ,pUserId       => icx_sec.getID(icx_sec.PV_WEB_USER_ID)
                            ,pSessionId    => icx_sec.getID(icx_sec.PV_SESSION_ID)
                            ,pRespId       => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID)
                            ,pFunctionName => 'PJI_REP_RA4'
                            );

END Redirect_RA1_RA4;


PROCEDURE Redirect_RA4_RA5 (p_week           IN VARCHAR2,
                            p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN VARCHAR2
)
IS
   l_start_date   DATE;
   l_Url          VARCHAR2(400);

BEGIN
   select start_date
   into l_start_date
   from fii_time_week_v
   where value = p_week;

   -- constructing the URL string
   l_Url := '&PJI_REP_DIM_18_FROM=' || p_week || '&PJI_REP_DIM_18_TO=' || p_week ||
            '&AS_OF_DATE=' || l_start_date || '&PJI_REP_DIM_2=' || p_organization ||
            '&PJI_REP_DIM_28=' || p_threshold || '&PJI_REP_DIM_1=' || p_operating_unit;


   --dbms_output.put_line('URL = ' || l_Url);

   bisviewer_pub.showreport( pUrlString    => 'pRegionCode=PJI_REP_RA5' || l_Url
                            ,pFunctionName => 'PJI_REP_RA5'
                            ,pUserId       => icx_sec.getID(icx_sec.PV_WEB_USER_ID)
                            ,pSessionId    => icx_sec.getID(icx_sec.PV_SESSION_ID)
                            ,pRespId       => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID));

END Redirect_RA4_RA5;


/* ----------------------------------------------------
   Procedure : Redirect_RA1_RA5
   This API is used to drill across from RA1 to RA5
   report. This is a link for the Available
   (Hours/Days/Week) column in RA1 report.
   ---------------------------------------------------- */
PROCEDURE Redirect_RA1_RA5 (p_organization   IN VARCHAR2,
                            p_operating_unit IN VARCHAR2,
                            p_threshold      IN VARCHAR2,
                            p_period_type    IN VARCHAR2,
                            p_start_time     IN VARCHAR2,
                            p_end_time       IN VARCHAR2
)
IS
   l_Url            VARCHAR2(400);
   l_date           DATE;
   l_from_date      DATE;
   l_to_date        DATE;
   l_as_of_date     DATE;
   l_val_from       VARCHAR2(100);
   l_val_to         VARCHAR2(100);
   l_period_url     VARCHAR2(100);

BEGIN

   l_from_date := to_date(p_start_time, 'j');
   l_to_date   := to_date(p_end_time, 'j');

   -- get the FROM and TO values for the Year using the dates passed
   IF p_period_type = 'FII_TIME_ENT_YEAR' THEN

        select name
        into l_val_from
        from fii_time_ent_year
        where start_date = l_from_date;

        select name
        into l_val_to
        from fii_time_ent_year
        where end_date = l_to_date;

        l_period_url := '&PJI_REP_DIM_11_FROM=' || l_val_from || '&PJI_REP_DIM_11_TO=' || l_val_to;

   -- get the FROM and TO values for the Quarter using the dates passed
   ELSIF p_period_type = 'FII_TIME_ENT_QTR' THEN

        select name
        into l_val_from
        from fii_time_ent_qtr
        where start_date = l_from_date;

        select name
        into l_val_to
        from fii_time_ent_qtr
        where end_date = l_to_date;

        l_period_url := '&PJI_REP_DIM_12_FROM=' || l_val_from || '&PJI_REP_DIM_12_TO=' || l_val_to;

   -- get the FROM and TO values for the Period using the dates passed
   ELSIF p_period_type = 'FII_TIME_ENT_PERIOD' THEN

        select name
        into l_val_from
        from fii_time_ent_period
        where start_date = l_from_date;

        select name
        into l_val_to
        from fii_time_ent_period
        where end_date = l_to_date;

        l_period_url := '&PJI_REP_DIM_13_FROM=' || l_val_from || '&PJI_REP_DIM_13_TO=' || l_val_to;

   -- get the FROM and TO values for the Week using the dates passed
   ELSIF p_period_type = 'FII_TIME_WEEK' THEN

        select name
        into l_val_from
        from fii_time_week
        where start_date = l_from_date;

        select name
        into l_val_to
        from fii_time_week
        where end_date = l_to_date;

        l_period_url := '&PJI_REP_DIM_18_FROM=' || l_val_from || '&PJI_REP_DIM_18_TO=' || l_val_to;

   -- get the FROM and TO values for the PA Period using the dates passed
   ELSIF p_period_type = 'PJI_TIME_PA_PERIOD' THEN

        select value
        into l_val_from
        from fii_time_cal_period_v
        where start_date = l_from_date;

        select value
        into l_val_to
        from fii_time_cal_period_v
        where end_date = l_to_date;

        l_period_url := '&PJI_REP_DIM_17_FROM=' || l_val_from || '&PJI_REP_DIM_17_TO=' || l_val_to;

   END IF;

   -- set the default current date for RA5 to sysdate
   l_date   := trunc(sysdate);

   -- then check whether this sysdate value is between l_from_date and l_to_date
   IF l_date >= l_from_date AND l_date <= l_to_date THEN
      l_as_of_date := l_date;

   ELSIF l_date < l_from_date THEN
      -- sysdate is less than p_from, so set the current date as the
      -- p_from date value
      l_as_of_date := l_from_date;

   ELSIF l_date > l_to_date THEN
      -- sysdate is greater than p_to, so set the current date as the
      -- p_to date value
      l_as_of_date := l_to_date;

   END IF;

   l_Url := '&AS_OF_DATE=' || l_as_of_date ||
            '&PJI_REP_DIM_2=' || p_organization ||
            '&PJI_REP_DIM_28='  || p_threshold ||
             l_period_url;

   IF p_operating_unit is not null then
       l_Url := l_Url || '&PJI_REP_DIM_1=' || p_operating_unit;
   END IF;

   --dbms_output.put_line('URL = ' || l_Url);

   bisviewer_pub.showreport('pRegionCode=PJI_REP_RA5' || l_Url
                            ,pUserId       => icx_sec.getID(icx_sec.PV_WEB_USER_ID)
                            ,pSessionId    => icx_sec.getID(icx_sec.PV_SESSION_ID)
                            ,pRespId       => icx_sec.getId(icx_sec.PV_RESPONSIBILITY_ID)
                            ,pFunctionName => 'PJI_REP_RA5'
                            );


END Redirect_RA1_RA5;

--Bug 4599990. This Procedure returns the details of the top organization in the PJI hierarchy over which the user
--has security permissions. The parameters are described below
--> x_top_org_id       : Id of the top org over which the user has security permissions. The id will be 0 if the
--                       user has permissions to see all the orgz
--> x_top_org_name     : Name of the top org.This will be populated only if x_insert_top_org is Y
--> x_user_assmt_flag  : If the top org is obtained from the security profile then the value will be 'N'
--                       If the top org is obtained from the user assignment then the value will be 'Y'
--> x_insert_top_org   : Flag indicating whether the user has permissions to the see the top org in the
--                       hierarchy
PROCEDURE get_top_org_details
(x_top_org_id           OUT  nocopy    per_security_profiles.organization_id%TYPE,
 x_top_org_name         OUT  nocopy    hr_all_organization_units_tl.name%TYPE,
 x_user_assmt_flag      OUT  nocopy   VARCHAR2,
 x_insert_top_org_flag  OUT  nocopy   VARCHAR2 )
IS
l_security_profile_id   per_security_profiles.security_profile_id%TYPE;
l_top_organization_id   per_security_profiles.organization_id%TYPE;
l_view_all_org_flag     per_security_profiles.view_all_organizations_flag%TYPE;
l_user_id               NUMBER;
BEGIN

    l_security_profile_id := fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL');
    l_user_id             := fnd_global.user_id;

    SELECT organization_id,
           view_all_organizations_flag ,
           include_top_organization_flag
    INTO   l_top_organization_id,
           l_view_all_org_flag,
           x_insert_top_org_flag
    FROM   per_security_profiles
    WHERE  security_profile_id=l_security_profile_id;

    x_user_assmt_flag := 'N';

    IF l_view_all_org_flag = 'Y' THEN

        l_top_organization_id :=0;

    ELSIF l_top_organization_id IS NULL THEN

        SELECT per.organization_id
        INTO   l_top_organization_id
        FROM   fnd_user fndu,
               per_all_assignments_f per
        WHERE  fndu.user_id=l_user_id
        AND    fndu.employee_id=per.person_id
        AND    per.primary_flag='Y'
        AND   (SYSDATE BETWEEN per.effective_start_Date AND NVL(per.effective_end_date, SYSDATE + 1));

        x_user_assmt_flag := 'Y';

    END IF;

    x_top_org_id := l_top_organization_id;

    IF x_insert_top_org_flag = 'Y' THEN

        SELECT name
        INTO   x_top_org_name
        FROM   hr_all_organization_units_tl
        WHERE  organization_id = x_top_org_id
        AND    language = USERENV('LANG');

    END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN

    x_top_org_id         :=-1;
    x_insert_top_org_flag:='N';

END get_top_org_details;


--Bug 4599990. Modified the code to handle the case where the security profile restricts the organizations
--to be displayed to that part of the hierarchy with organization selected in the user assignment as the top org
FUNCTION PJI_ORGANIZATION_LOV RETURN PJI_ORGANIZATION_LIST_TBL
IS
l_Organization_List     PJI_ORGANIZATION_LIST_TBL := PJI_ORGANIZATION_LIST_TBL();
l_Count					NUMBER;
--Bug 4599990.
l_top_organization_id   per_security_profiles.organization_id%TYPE;
l_user_id               NUMBER;
l_top_org_name          hr_all_organization_units_tl.name%TYPE;
l_user_assmt_flag       VARCHAR2(1);
l_insert_top_org_flag   VARCHAR2(1);

BEGIN
    --Important: Any change in logic made here should be updated in the function PJI_ORGANIZATION_EXISTS also
    --Bug 4599990.
    l_user_id := fnd_global.user_id;

    get_top_org_details(
    x_top_org_id          => l_top_organization_id,
    x_top_org_name        => l_top_org_name,
    x_user_assmt_flag     => l_user_assmt_flag,
    x_insert_top_org_flag => l_insert_top_org_flag);

    --Bug 4599990. View All Orgz
    IF l_top_organization_id = 0 THEN

        SELECT
        PJI_ORGANIZATION_LIST(
        orgd.organization_id_child
        , org.name
        , orgd.organization_id_parent)
        BULK COLLECT INTO l_Organization_List
        FROM
              per_org_structure_elements orgd
            , pji_system_settings pset
            , hr_all_organization_units_tl org
        WHERE 1=1
            AND orgd.org_structure_version_id = pset.org_structure_version_id
            AND orgd.organization_id_child = org.organization_id
            AND org.language = USERENV('LANG');
      	    l_Count:=l_Organization_List.COUNT;

    --Bug 4599990. The security restricts the view to only a part of hierarchy with l_top_organization_id
    --as the top org
    ELSIF l_user_assmt_flag = 'N' THEN

        SELECT
        PJI_ORGANIZATION_LIST(
        orgd.organization_id_child
        , org.name
        , orgd.organization_id_parent)
        BULK COLLECT INTO l_Organization_List
        FROM
              per_org_structure_elements orgd
            , pji_system_settings pset
            , per_organization_list sec
            , hr_all_organization_units_tl org
        WHERE 1=1
            AND orgd.org_structure_version_id = pset.org_structure_version_id
            AND orgd.organization_id_child = org.organization_id
            AND org.language = USERENV('LANG')
            AND orgd.organization_id_child = sec.organization_id
            AND sec.security_profile_id = fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL');
            l_Count:=l_Organization_List.COUNT;

    --Bug 4599990. The security restricts the view to only a part of hierarchy with organization on the user
    --assignment as the top org
    ELSIF  l_user_assmt_flag = 'Y' THEN

        SELECT
        PJI_ORGANIZATION_LIST(
        orgd.organization_id_child
        , org.name
        , orgd.organization_id_parent)
        BULK COLLECT INTO l_Organization_List
        FROM
              per_org_structure_elements orgd
            , pji_system_settings pset
            , hr_all_organization_units_tl org
        WHERE 1=1
            AND orgd.org_structure_version_id = pset.org_structure_version_id
            AND orgd.organization_id_child = org.organization_id
            AND org.language = USERENV('LANG')
            START WITH orgd.organization_id_parent=l_top_organization_id
            CONNECT BY PRIOR orgd.organization_id_child = orgd.organization_id_parent;
            l_Count:=l_Organization_List.COUNT;

    END IF;

    --Bug 4599990. Insert top org only when the security profile setting allows the user to see top org.
    IF l_insert_top_org_flag= 'Y' THEN

        --Bug 4599990.In case the user has permissions to see all the orgz then the top org has to be derived.
        IF l_top_organization_id=0 THEN

            FOR cur_Top_Organization_List IN (
                SELECT
                orgd.organization_id_child organization_id_child
                , org.name name
                , orgd.organization_id_parent organization_id_parent
                FROM
                    (select distinct organization_id_parent organization_id_child, NULL organization_id_parent from
                      per_org_structure_elements p
                    , pji_system_settings pset
                    where p.org_structure_version_id = pset.org_structure_version_id
                    and not exists
                    (select 1 from
                      per_org_structure_elements c
                      where c.organization_id_child = p.organization_id_parent
                      and   c.org_structure_version_id = p.org_structure_version_id)) orgd
                    , per_organization_list sec
                    , hr_all_organization_units_tl org
                    , per_security_profiles prof
                WHERE 1=1
                    AND orgd.organization_id_child = org.organization_id
                    AND org.language = USERENV('LANG')
                    AND orgd.organization_id_child = sec.organization_id (+)
                    AND sec.security_profile_id(+) = fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL')
                    AND fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL') IS NOT NULL
                AND prof.security_profile_id = fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL')
                AND ( prof.view_all_organizations_flag = 'Y'
                OR sec.organization_id IS NOT NULL))
            LOOP
                l_Count:=l_Count+1;
                l_Organization_List.EXTEND;
                l_Organization_List(l_Count):=PJI_ORGANIZATION_LIST(NULL,NULL,NULL);
                l_Organization_List(l_Count).ID:=cur_Top_Organization_List.organization_id_child;
                l_Organization_List(l_Count).VALUE:=cur_Top_Organization_List.name;
                l_Organization_List(l_Count).PARENT_ID:=NULL;
                NULL;
            END LOOP;

        --Bug 4599990. If the top org is already derived earlier then it can be used here.
        ELSE
            l_Count:=l_Count+1;
            l_Organization_List.EXTEND;
            l_Organization_List(l_Count):=PJI_ORGANIZATION_LIST(NULL,NULL,NULL);
            l_Organization_List(l_Count).ID:=l_top_organization_id;
            l_Organization_List(l_Count).VALUE:=l_top_org_name;
            l_Organization_List(l_Count).PARENT_ID:=NULL;

        END IF;

    END IF;--IF l_insert_top_org_flag= 'Y' THEN

    RETURN l_Organization_List;
EXCEPTION
	WHEN OTHERS THEN
		RETURN l_Organization_List;
END PJI_ORGANIZATION_LOV;

--This function takes org_id as input parameter and returns the same org_id if it is
--present in the list of PJI organizations. Otherwise it returns null
--This helps to check the access to Performance Reporting from Project List page
FUNCTION PJI_ORGANIZATION_EXISTS(p_org_id IN NUMBER) RETURN NUMBER
IS
l_top_organization_id   per_security_profiles.organization_id%TYPE;
l_org_id                        per_security_profiles.organization_id%TYPE;
l_top_org_name          hr_all_organization_units_tl.name%TYPE;
l_user_assmt_flag       VARCHAR2(1);
l_insert_top_org_flag   VARCHAR2(1);

BEGIN

    get_top_org_details(
    x_top_org_id          => l_top_organization_id,
    x_top_org_name        => l_top_org_name,
    x_user_assmt_flag     => l_user_assmt_flag,
    x_insert_top_org_flag => l_insert_top_org_flag);

    BEGIN
    IF l_top_organization_id = 0 THEN
        SELECT p_org_id INTO l_org_id FROM DUAL WHERE EXISTS
	(SELECT orgd.organization_id_child
        FROM
              per_org_structure_elements orgd
            , pji_system_settings pset
            , hr_all_organization_units org
        WHERE 1=1
            AND orgd.org_structure_version_id = pset.org_structure_version_id
            AND orgd.organization_id_child = org.organization_id
            AND org.organization_id = p_org_id);

	RETURN l_org_id;
    ELSIF l_user_assmt_flag = 'N' THEN

        SELECT p_org_id INTO l_org_id FROM DUAL WHERE EXISTS
	(SELECT orgd.organization_id_child
        FROM
              per_org_structure_elements orgd
            , pji_system_settings pset
            , per_organization_list sec
            , hr_all_organization_units org
        WHERE 1=1
            AND orgd.org_structure_version_id = pset.org_structure_version_id
            AND orgd.organization_id_child = org.organization_id
            AND org.organization_id = p_org_id
            AND orgd.organization_id_child = sec.organization_id
            AND sec.security_profile_id = fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL'));

	RETURN l_org_id;
    ELSIF  l_user_assmt_flag = 'Y' THEN

        SELECT p_org_id INTO l_org_id FROM DUAL WHERE EXISTS
	(SELECT orgd.organization_id_child
        FROM
              per_org_structure_elements orgd
            , pji_system_settings pset
            , hr_all_organization_units org
        WHERE 1=1
            AND orgd.org_structure_version_id = pset.org_structure_version_id
            AND orgd.organization_id_child = org.organization_id
	    AND orgd.organization_id_child = p_org_id
            START WITH orgd.organization_id_parent=l_top_organization_id
            CONNECT BY PRIOR orgd.organization_id_child = orgd.organization_id_parent);

	RETURN l_org_id;
    END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	      NULL;
    END;

    --Bug 4599990. Insert top org only when the security profile setting allows the user to see top org.
    IF l_insert_top_org_flag= 'Y' THEN

        --Bug 4599990.In case the user has permissions to see all the orgz then the top org has to be derived.
        IF l_top_organization_id=0 THEN

		SELECT p_org_id INTO l_org_id FROM DUAL WHERE EXISTS
		(SELECT orgd.organization_id_child
                FROM
                    (select distinct organization_id_parent organization_id_child, NULL organization_id_parent from
                      per_org_structure_elements p
                    , pji_system_settings pset
                    where p.org_structure_version_id = pset.org_structure_version_id
                    and not exists
                    (select 1 from
                      per_org_structure_elements c
                      where c.organization_id_child = p.organization_id_parent
                      and   c.org_structure_version_id = p.org_structure_version_id)) orgd
                    , per_organization_list sec
                    , hr_all_organization_units org
                    , per_security_profiles prof
                WHERE 1=1
                    AND orgd.organization_id_child = org.organization_id
                    AND orgd.organization_id_child = p_org_id
                    AND orgd.organization_id_child = sec.organization_id (+)
                    AND sec.security_profile_id(+) = fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL')
                    AND fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL') IS NOT NULL
                AND prof.security_profile_id = fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL')
                AND ( prof.view_all_organizations_flag = 'Y' OR sec.organization_id IS NOT NULL));

		RETURN l_org_id;

        ELSE
	    IF l_top_organization_id = p_org_id THEN
	    RETURN p_org_id;
	    END IF;

        END IF;

    END IF;--IF l_insert_top_org_flag= 'Y' THEN
RETURN l_org_id;
EXCEPTION
	WHEN OTHERS THEN
		RETURN NULL;
END PJI_ORGANIZATION_EXISTS;


FUNCTION GET_JOB_LEVEL ( p_person_id  NUMBER,
                         p_as_of_date DATE )
RETURN NUMBER
IS
  l_job_level NUMBER;
BEGIN

  BEGIN
    SELECT resource_job_level
    INTO   l_job_level
    FROM   pa_resources_denorm
    WHERE  person_id = p_person_id
    AND    p_as_of_date between resource_effective_start_date and resource_effective_end_date;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_job_level := null;
  END;
  RETURN l_job_level;

END;

/* ------------------------------------------------------
   Procedure : SEED_PJI_STATS
   -----------------------------------------------------*/

PROCEDURE SEED_PJI_STATS IS

BEGIN

    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_CLS_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_ITD_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_JB_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_ORG_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_JL_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_ORGZ_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_PRJ_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_TIME_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_TCMP_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_UC_DIM_TMP',10,10,10);
    FND_STATS.SET_TABLE_STATS('PJI','PJI_PMV_WT_DIM_TMP',10,10,10);

END SEED_PJI_STATS;


/* ------------------------------------------------------
   Procedure : Init
   This procedure is called only once when the package is
   instantiated. The procedure is used to populate the
   global variables and these variables are usable
   through out the session
   ------------------------------------------------------*/
-- Procedure Init starts here
PROCEDURE Init
	AS
	BEGIN
		--Bug 5598041: G_User_Lang will hold the language name in which the labels are being populated
		BEGIN
			SELECT userenv('LANG')
			INTO G_User_Lang
			FROM dual;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

		BEGIN
			SELECT lookup_code, meaning
			BULK COLLECT INTO G_Measure_Short_Code, G_Measure_Label
			FROM pji_lookups
			WHERE lookup_type LIKE 'PJI_PMV_MSR_LABELS';
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

		BEGIN
			SELECT setup.report_labor_units
			INTO G_FTE_Level
			FROM pji_system_settings setup;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

		BEGIN
			SELECT meaning INTO G_Budget_Label
			FROM pji_lookups
			WHERE lookup_type = G_Graph_Labels_LT
			AND lookup_code =   G_Budget_Label_LC ;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

		BEGIN
			SELECT meaning INTO G_Prior_Label
			FROM pji_lookups
			WHERE lookup_type = G_Graph_Labels_LT
			AND lookup_code =   G_Prior_Budget_Label_LC ;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

	END;
-- Procedure Init ends here

PROCEDURE hide_parameter (
                        p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                        hide    OUT NOCOPY VARCHAR2)
IS
BEGIN
	hide := 'N';
	--Hide the dimension level if the operating unit has the value All
	FOR i IN 1..p_page_parameter_tbl.count LOOP
		IF (p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS') THEN
			IF (p_page_parameter_tbl(i).parameter_value = 'All') THEN
				hide := 'Y';
			ELSE
				hide := 'N';
			END IF;
			EXIT;
		END IF;
	END LOOP;
END hide_parameter;

-- Initializing Procedure Init
BEGIN
 	Init;

END PJI_PMV_UTIL;

/
