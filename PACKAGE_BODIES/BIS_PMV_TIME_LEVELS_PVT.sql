--------------------------------------------------------
--  DDL for Package Body BIS_PMV_TIME_LEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_TIME_LEVELS_PVT" AS
/* $Header: BISVTMLB.pls 120.3 2006/09/18 13:23:12 ashgarg noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.34=120.3):~PROD:~PATH:~FILE
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
--
--	ansingh			Apr 22, 2003	BugFix#2887200
--      nbarik                  Jul 16, 2003    Bug Fix#2999602
--      nkishore                Feb 12, 2004    Bug Fix#3432746
--      ugodavar                Oct 28, 2004    Bug.Fix#3921033

   -- Enter package declarations as shown below
PROCEDURE GET_PREVIOUS_TIME_LEVEL_VALUE
(p_DimensionLevel        in  VARCHAR2
,p_region_code           in  VARCHAR2
,p_responsibility_id     in  VARCHAR2
,p_asof_date             in  DATE
,p_time_comparison_type  in  VARCHAR2
,x_time_level_id         OUT NOCOPY VARCHAR2
,x_time_level_value      OUT NOCOPY VARCHAR2
,x_start_Date            OUT NOCOPY DATE
,x_end_date              OUT NOCOPY DATE
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
,p_use_current_mode      IN BOOLEAN DEFAULT FALSE --added for bug 4475937
)
IS
   l_Asof_date          DATE;
   l_mode               VARCHAR2(2000):= 'GET_PREVIOUS';
BEGIN

   l_asof_date := p_asof_date;
   /*IF (p_time_comparison_type = 'TIME_COMPARISON_TYPE+SEQUENTIAL') then
      l_Asof_Date := p_asof_Date;
   END IF;*/
   -- added for bug 4475937
   IF (p_time_comparison_Type = 'TIME_COMPARISON_TYPE+YEARLY' OR p_use_current_mode )then
      --l_asof_Date := add_months(l_asof_date, -12);
      l_mode      := 'GET_CURRENT';
   END IF;

   GET_TIME_LEVEL_INFO(p_dimensionlevel => p_DimensionLevel,
                      p_region_code    => p_region_code,
                      p_Responsibility_id => p_responsibility_id,
                      p_Asof_date      => l_asof_date,
                      p_mode           => l_mode,
                      x_time_level_id  => x_time_level_id,
                      x_time_level_value => x_time_level_Value,
                      x_Start_date       => x_start_date,
                      x_end_date         => x_end_date,
                      x_return_Status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data
                     );
END;
PROCEDURE GET_TIME_LEVEL_INFO
(p_DimensionLevel       IN    VARCHAR2
,p_region_code          IN    VARCHAR2
,p_responsibility_id    IN    VARCHAR2
,p_asof_date            IN    DATE
,p_mode                 IN    VARCHAR2
,x_time_level_id        OUT   NOCOPY VARCHAR2
,x_time_level_Value     OUT   NOCOPY VARCHAR2
,x_start_Date           OUT   NOCOPY DATE
,x_end_date             OUT   NOCOPY DATE
,x_return_Status        OUT   NOCOPY VARCHAR2
,x_msg_count            OUT   NOCOPY NUMBER
,x_msg_data             OUT   NOCOPY VARCHAR2
)
IS
   l_start_date date;
   tmp_start_date date;
   l_end_date   date;
   l_mode       varchar2(2000);
   l_start_date_function varchar2(2000);
   x_start_date_function varchar2(2000);
   -- P1 3502644 fix
   l_dynamic_sql varchar2(2000) ;
   -- ashgarg bug: 5347447
   l_sql  VARCHAR2(32676);
BEGIN
   --Bug Fix#3432746 Use Fii Apis for Rolling Time as well
   if (p_Dimensionlevel = 'TIME+FII_ROLLING_WEEK') then
      -- P1 3502644 fix
      -- x_start_date := fii_time_api.rwk_start(p_asof_date);
      -- ashgarg bug: 5347447
      l_sql := 'select id, value from fii_time_week_v where :1 between start_date and end_date';
      execute immediate l_sql INTO x_time_level_id, x_time_level_value using p_asof_date;

      l_dynamic_sql := 'BEGIN :1 := fii_time_api.rwk_start(:2); END;';
      EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_start_date, IN p_asof_date;

      --p_asof_date-6;
      x_end_date := p_asof_date;
      --x_time_level_id := sysdate;
      --x_time_level_value := sysdate;
      return;
   end if;
   if (p_dimensionlevel = 'TIME+FII_ROLLING_MONTH') then
      -- P1 3502644
      -- x_start_date := fii_time_api.rmth_start(p_asof_date);
      -- ashgarg bug: 5347447
      l_sql := 'select id, value from fii_time_month_v where :1 between start_date and end_date';
      execute immediate l_sql INTO x_time_level_id, x_time_level_value using p_asof_date;

      l_dynamic_sql := 'BEGIN :1 := fii_time_api.rmth_start(:2); END;';
      EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_start_date, IN p_asof_date;

      --add_months(p_asof_date,-1)+1;
      x_end_date := p_asof_date;
      --x_time_level_id := sysdate;
      --x_time_level_value := sysdate;
      return;
   end if;
   if (p_dimensionlevel = 'TIME+FII_ROLLING_QTR') then
      -- P1 3502644
      -- x_start_date := fii_time_api.rqtr_start(p_asof_Date);
      -- ashgarg bug: 5347447
      l_sql := 'select id, value from fii_time_qtr_v where :1 between start_date and end_date';
      execute immediate l_sql INTO x_time_level_id, x_time_level_value using p_asof_date;

      l_dynamic_sql := 'BEGIN :1 := fii_time_api.rqtr_start(:2); END;';
      EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_start_date, IN p_asof_date;


      --add_months(p_asof_Date,-3)+1;
      x_end_date := p_asof_date;
      --x_time_level_id := sysdate;
      --x_time_level_value := sysdate;
      return;
   end if;
   if (p_dimensionlevel = 'TIME+FII_ROLLING_YEAR') then
      -- P1 3502644
      -- x_start_Date := fii_time_api.ryr_start(p_asof_Date);
      -- ashgarg bug: 5347447
      l_sql := 'select id, value from fii_time_year_v where :1 between start_date and end_date';
      execute immediate l_sql INTO x_time_level_id, x_time_level_value using p_asof_date;


      l_dynamic_sql := 'BEGIN :1 := fii_time_api.ryr_start(:2); END;';
      EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_start_date, IN p_asof_date;

      --add_months(p_asof_Date,-12)+1;
      x_end_date := p_asof_date;
      --x_time_level_id := sysdate;
      --x_time_level_value := sysdate;
      return;
   end if;

 if (p_mode = 'GET_YEARLY') then
    l_mode := 'GET_CURRENT' ;
 else
   l_mode := p_mode;
 end if;

 BIS_PMV_PARAMETERS_PVT.GET_TIME_INFO(
 p_region_code            => p_region_Code
,p_responsibility_id      => p_responsibility_id
,p_parameter_name         => p_Dimensionlevel
,p_mode                   => l_mode
,p_date                   => p_asof_date
,x_time_description       => x_time_level_Value
,x_time_id                => x_time_level_id
,x_start_date             => x_start_date
,x_end_date               => x_end_date
,x_return_status          => x_return_status
,x_msg_count              => x_msg_count
,x_msg_data               => x_msg_data
);

END;
PROCEDURE GET_PREVIOUS_ASOF_DATE
(p_DimensionLevel        IN    VARCHAR2
,p_time_comparison_type  IN    VARCHAR2
,p_asof_date             IN    DATE
,x_prev_asof_Date        OUT   NOCOPY DATE
,x_Return_status         OUT   NOCOPY VARCHAR2
,x_msg_count             OUT   NOCOPY NUMBER
,x_msg_data              OUT   NOCOPY VARCHAR2
)
IS
  l_sql    varchar2(32000);
  l_temp    varchar2(3200);
   -- P1 3502644
   l_dynamic_sql varchar2(2000) ;
BEGIN
   /*IF (p_dimensionlevel = 'TIME+FII_ROLLING_MONTH' or
       p_dimensionlevel = 'TIME+FII_ROLLING_QTR' or
       p_dimensionlevel = 'TIME+FII_ROLLING_WEEK' or
       p_Dimensionlevel = 'TIME+FII_ROLLING_YEAR')
   THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_lyr_end(:2);  end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
         return;
   END IF;*/

   IF ( p_time_comparison_type IS NULL OR p_time_comparison_type = 'TIME_COMPARISON_TYPE+SEQUENTIAL') THEN
      IF (p_DimensionLevel = 'TIME+FII_TIME_WEEK') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.sd_pwk(:2); end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_ENT_PERIOD') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_pper_end(:2); end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_ENT_QTR') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_pqtr_end (:2); end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_ENT_YEAR') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_lyr_end(:2);  end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_DAY') THEN
         x_prev_asof_date := p_asof_date-1;
      END IF;
      --Bug Fix#3432746 Use Fii Apis for Rolling Time as well
      IF (p_DimensionLevel = 'TIME+FII_ROLLING_WEEK') THEN
         --x_prev_asof_date := p_asof_date-7;
         -- P1 3502644
         -- x_prev_asof_date := fii_time_api.rwk_start(p_asof_date)-1;
         l_dynamic_sql := 'BEGIN :1 := fii_time_api.rwk_start(:2); END;';
         EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_prev_asof_date, IN p_asof_date;
	 x_prev_asof_date := x_prev_asof_date-1 ;

      END IF;
      IF (p_DimensionLevel = 'TIME+FII_ROLLING_MONTH') THEN
         --x_prev_asof_Date := add_months(p_asof_date,-1);
         -- P1 3502644
         -- x_prev_asof_date := fii_time_api.rmth_start(p_asof_date)-1;
         l_dynamic_sql := 'BEGIN :1 := fii_time_api.rmth_start(:2); END;';
         EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_prev_asof_date, IN p_asof_date;
	 x_prev_asof_date := x_prev_asof_date-1 ;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_ROLLING_QTR') THEN
         -- x_prev_asof_date := add_months(p_asof_date,-3);
         -- P1 3502644
         -- x_prev_asof_date := fii_time_api.rqtr_start(p_asof_date)-1;
         l_dynamic_sql := 'BEGIN :1 := fii_time_api.rqtr_start(:2); END;';
         EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_prev_asof_date, IN p_asof_date;
	 x_prev_asof_date := x_prev_asof_date-1 ;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_ROLLING_YEAR') THEN
         -- x_prev_asof_date := add_months(p_asof_date,-12);
         -- P1 3502644
         -- x_prev_asof_date := fii_time_api.ryr_start(p_asof_date)-1;
         l_dynamic_sql := 'BEGIN :1 := fii_time_api.ryr_start(:2); END;';
         EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_prev_asof_date, IN p_asof_date;
	 x_prev_asof_date := x_prev_asof_date-1 ;
      END IF;
   ELSE
      IF (p_DimensionLevel = 'TIME+FII_TIME_WEEK') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.sd_lyswk(:2);  end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_ENT_PERIOD') THEN
          l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_lysper_end(:2); end;';
          execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_ENT_QTR') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_lysqtr_end(:2);  end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_DimensionLevel = 'TIME+FII_TIME_ENT_YEAR' OR p_dimensionlevel = 'TIME+FII_TIME_DAY') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_sd_lyr_end(:2);  end;';
         execute immediate l_sql USING OUT x_prev_asof_date , IN p_asof_date;
      END IF;
      IF (p_dimensionlevel = 'TIME+FII_ROLLING_WEEK' or
          p_dimensionlevel = 'TIME+FII_ROLLING_MONTH' or
          p_dimensionlevel = 'TIME+FII_ROLLING_QTR' or
          p_dimensionlevel = 'TIME+FII_ROLLING_YEAR') THEN
          x_prev_asof_date := add_months(p_asof_date,-12);
      END IF;
   END IF;
   IF (x_prev_asof_Date IS NULL or (length(x_prev_asof_date) = 0)) THEN
     GET_BIS_COMMON_START_DATE
    (x_prev_asof_Date       => x_prev_asof_date
    ,x_return_Status        => x_return_status
    ,x_msg_count            => x_msg_count
    ,x_msg_data             => x_msg_data );
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
      IF (x_prev_asof_Date IS NULL or (length(x_prev_asof_date) = 0)) THEN
         GET_BIS_COMMON_START_DATE
         (x_prev_asof_Date       => x_prev_asof_date
         ,x_return_Status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data );
       END IF;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END;
PROCEDURE GET_BIS_COMMON_START_DATE
(x_prev_asof_Date       OUT   NOCOPY DATE
,x_return_Status        OUT   NOCOPY VARCHAR2
,x_msg_count            OUT   NOCOPY NUMBER
,x_msg_data             OUT   NOCOPY VARCHAR2
)
IS
  l_sql  VARCHAr2(2000);
  --l_format VARCHAR2(20) := 'DD-MON-YYYY';
BEGIN
   l_sql := 'BEGIN :1 := bis_common_parameters.get_global_start_date-1; end;';
   execute immediate l_sql USING OUT x_prev_asof_date;
   --As of Date 3094234--Already returning date so no need to format
   --x_prev_asof_date := to_date(x_prev_asof_date, l_format);
EXCEPTION
  WHEN OTHERS THEN
       NULL;
END;
PROCEDURE GET_REPORT_START_DATE
(p_time_comparison_type IN  VARCHAR2
,p_asof_date            IN  DATE
,p_time_level           IN  VARCHAR2
,x_report_start_date    OUT NOCOPY DATE
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_sql    VARCHAR2(32767);
  l_curr_year number;
  l_curr_qtr  number;
  l_curr_period number;
  l_week_start_date date;

BEGIN
   IF (p_time_level = 'TIME+FII_TIME_ENT_YEAR') THEN
      l_sql := 'select sequence from fii_time_ent_year where :1 between start_date and end_date';
      execute immediate l_sql INTO l_curr_year using p_asof_date;
      l_sql := 'select min(start_date) from fii_time_ent_year where sequence >= :l_curr_year-3';
      execute immediate l_sql INTO x_report_start_date using l_curr_year;
  END IF;
  IF (p_time_level = 'TIME+FII_TIME_ENT_QTR') THEN
      l_sql := 'select sequence, ent_year_id from fii_time_ent_qtr where :p_asof_date between start_date and end_date';
      execute immediate l_sql INTO l_curr_qtr, l_curr_year using p_asof_Date;
      if (p_time_comparison_type = 'TIME_COMPARISON_TYPE+YEARLY') then
         l_sql := 'select start_date from (select start_Date from fii_time_ent_qtr where ((sequence >=:l_curr_qtr+1 and '||
                  ' ent_year_id = :l_curr_year-1) or (sequence>=1 and ent_year_id = :l_curr_year)) order by start_date) '||
                  ' where rownum <=1 ';
         execute immediate l_sql into x_report_start_date using l_curr_qtr, l_curr_year, l_curr_year ;
      else
         l_sql := 'select start_date from (select start_date from fii_time_ent_qtr where ((sequence >=:l_curr_qtr+1 and '||
                  ' ent_year_id = :l_curr_year-2) or (sequence>=1 and ent_year_id = :l_curr_year-1)) order by start_date) '||
                  ' where rownum <=1 ';
         execute immediate l_sql into x_report_start_date using l_curr_qtr, l_curr_year, l_curr_year;
     end if;
  END IF;
  IF (p_time_level = 'TIME+FII_TIME_ENT_PERIOD') THEN
      l_sql := 'select p.sequence,q.ent_year_id FROM fii_time_ent_period p , fii_time_ent_qtr q '||
               ' where p.ent_qtr_id=q.ent_qtr_id  and :p_asof_date between p.start_Date and p.end_date';
      execute immediate l_sql INTO l_curr_period, l_curr_year using p_asof_Date;
      l_sql := 'SELECT start_date FROM (select p.start_date from fii_time_ent_period p, '||
               ' fii_time_ent_qtr q where p.ent_qtr_id = q.ent_qtr_id and '||
               ' ((p.sequence >= :l_curr_period+1 and q.ent_year_id = :l_curr_year-1) or '||
               ' (p.sequence >= 1 and q.ent_year_id = :l_curr_year)) order by p.start_date) '||
               ' where rownum <= 1';
      execute immediate l_sql into x_report_start_date using l_curr_period, l_curr_year, l_curr_year;
  END IF;
  IF (p_time_level = 'TIME+FII_TIME_WEEK') THEN
     l_sql := 'select start_Date from fii_time_Week where :p_asof_date between start_date and end_date';
     execute immediate l_sql INTO l_week_start_date using p_asof_Date;
     l_sql := 'select min(start_date) from fii_time_Week where start_date >= :l_week_start_Date-7*12';
     execute immediate l_sql into x_report_Start_date using l_week_Start_date;
   END IF;
  IF (p_time_level = 'TIME+FII_TIME_DAY') THEN --Bug.Fix.3921033
    x_report_start_date := p_asof_Date - 6;
  END IF;
   IF (p_time_level = 'TIME+FII_ROLLING_WEEK' OR
       p_time_level = 'TIME+FII_ROLLING_MONTH' OR
       p_time_level = 'TIME+FII_ROLLING_QTR' OR
       p_time_level = 'TIME+FII_ROLLING_YEAR') then
       x_report_start_date := sysdate;
  END IF;
EXCEPTION
WHEN OTHERS THEN
     l_sql := 'BEGIN :1 := bis_common_parameters.get_global_start_date; END;';
     execute immediate l_sql USING OUT x_report_Start_date ;
END;


/*-----BugFix#2887200 -ansingh-------*/
PROCEDURE GET_TIME_PARAMETER_RECORD (
	p_TimeParamterName	IN VARCHAR2,
	p_DateParameter			IN DATE,
	x_parameterRecord   OUT NOCOPY BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
	x_return_Status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_Data          OUT NOCOPY VARCHAR2
) IS

	l_ParameterRecord						BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;

BEGIN

		l_ParameterRecord.dimension							:= NULL;
		l_ParameterRecord.default_flag					:= 'N';
		l_ParameterRecord.parameter_name				:= p_TimeParamterName;
		--l_ParameterRecord.parameter_description := to_char(p_DateParameter,'DD-MON-YYYY');
		--l_ParameterRecord.parameter_value				:= to_char(p_DateParameter,'DD-MON-YYYY');
                --As of Date 3094234--dd/mm/yyyy format
		l_ParameterRecord.parameter_description := to_char(p_DateParameter,'DD/MM/YYYY');
		l_ParameterRecord.parameter_value				:= to_char(p_DateParameter,'DD/MM/YYYY');
                --BugFix 3308824
		l_ParameterRecord.period_date					:= p_DateParameter;


		x_parameterRecord := l_ParameterRecord;

EXCEPTION
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.COUNT_AND_GET(p_count => x_msg_count, p_data => x_msg_data);
END;

/*-----BugFix#2887200 -ansingh-------*/
/*
nbarik - Bug Fix 2999602 Added x_prev_effective_start_date and x_prev_effective_end_date
*/
PROCEDURE GET_COMPUTED_DATES (
	p_region_code									 IN VARCHAR2,
	p_resp_id											 IN VARCHAR2,
	p_time_comparison_type         IN VARCHAR2,
	p_asof_date                    IN VARCHAR2,
	p_time_level                   IN VARCHAR2,
	x_prev_asof_Date               OUT NOCOPY DATE,
	x_curr_effective_start_date    OUT NOCOPY DATE,
	x_curr_effective_end_date      OUT NOCOPY DATE,
	x_curr_report_Start_date       OUT NOCOPY DATE,
	x_prev_report_Start_date       OUT NOCOPY DATE,
	x_time_level_id								 OUT NOCOPY VARCHAR2,
	x_time_level_value						 OUT NOCOPY VARCHAR2,
        x_prev_effective_start_date    OUT NOCOPY DATE,
        x_prev_effective_end_date      OUT NOCOPY DATE,
        x_prev_time_level_id           OUT NOCOPY VARCHAR2,
        x_prev_time_level_value        OUT NOCOPY VARCHAR2,
	x_return_status                OUT NOCOPY VARCHAR2,
	x_msg_count                    OUT NOCOPY NUMBER,
	x_msg_Data                     OUT NOCOPY VARCHAR2
	)
	IS
	  l_asof_date     						DATE;
	  l_time_level_id 						VARCHAR2(2000);
	  l_time_level_value 					VARCHAR2(2000);
	  l_current_report_start_date DATE;
	  l_prev_asof_Date 						DATE;
	  l_prev_report_Start_date 		DATE;
          l_date DATE;

	  l_Start_date   							DATE;
	  l_end_date     							DATE;
          l_prev_effective_start_date           DATE;
          l_prev_effective_end_date             DATE;
	  l_prev_time_level_id 			VARCHAR2(2000);
	  l_prev_time_level_value 		VARCHAR2(2000);
    l_use_current_mode BOOLEAN := FALSE;
		BEGIN
        if (p_asof_Date is not null) then
        l_asof_Date := to_Date(p_asof_Date,'DD/MM/YYYY');
        else
        l_asof_date := sysdate;
        end if;
        BIS_PMV_TIME_LEVELS_PVT.GET_TIME_LEVEL_INFO (
										p_dimensionlevel		=> p_Time_level,
                    p_region_code				=> p_region_code,
                    p_Responsibility_id => p_resp_id,
                    p_Asof_date					=> l_asof_date,
                    p_mode							=> 'GET_CURRENT',
                    x_time_level_id			=> l_time_level_id,
                    x_time_level_value	=> l_time_level_Value,
                    x_Start_date				=> l_start_date,
                    x_end_date					=> l_end_date,
                    x_return_Status			=> x_return_status,
                    x_msg_count					=> x_msg_count,
                    x_msg_data					=> x_msg_data
        );
        BIS_PMV_TIME_LEVELS_PVT.GET_PREVIOUS_ASOF_DATE (
        						p_DimensionLevel        =>   p_time_level,
                		p_time_comparison_type  =>   p_time_comparison_Type,
		                p_asof_date             =>   l_Asof_date,
		                x_prev_asof_Date        =>   l_prev_asof_Date,
		                x_Return_status         =>   x_return_Status,
		                x_msg_count             =>   x_msg_count,
		                x_msg_data              =>   x_msg_data
				);
        BIS_PMV_TIME_LEVELS_PVT.GET_REPORT_START_DATE (
        						p_time_comparison_type => p_time_comparison_type,
		                p_asof_date            => l_asof_date,
		                p_time_level           => p_time_level,
		                x_report_start_date    => l_current_report_start_date,
		                x_return_status        => x_return_status,
		                x_msg_count            => x_msg_count,
		                x_msg_data             => x_msg_data
				);
        BIS_PMV_TIME_LEVELS_PVT.GET_REPORT_START_DATE (
		        				p_time_comparison_type => p_time_comparison_type,
		                p_asof_date            => l_prev_asof_date,
		                p_time_level           => p_time_level,
		                x_report_start_date    => l_prev_report_start_date,
		                x_return_status        => x_return_status,
		                x_msg_count            => x_msg_count,
		                x_msg_data             => x_msg_data
       	);

        -- bug 3090746
        --IF (p_time_comparison_Type = 'TIME_COMPARISON_TYPE+YEARLY') then
            l_date := l_prev_asof_date; -- added for bug 4475937
            l_use_current_mode := TRUE;

       -- ELSE
       --     l_date := l_asof_date;
        --END IF;

        IF (p_time_level = 'TIME+FII_ROLLING_WEEK' or
            p_time_level = 'TIME+FII_ROLLING_MONTH' or
            p_time_level = 'TIME+FII_ROLLING_QTR' or
            p_time_level = 'TIME+FII_ROLLING_YEAR') then
            l_date := l_prev_asof_date;
            l_use_current_mode := FALSE;
        end if;

        BIS_PMV_TIME_LEVELS_PVT.GET_PREVIOUS_TIME_LEVEL_VALUE(
                                p_DimensionLevel       => p_Time_level
                               ,p_region_code          => p_region_code
                               ,p_responsibility_id    => p_resp_id
                               ,p_asof_date            => l_date
                               ,p_time_comparison_type => p_time_comparison_type
                               ,x_time_level_id        => l_prev_time_level_id
                               ,x_time_level_value     => l_prev_time_level_value
                               ,x_start_Date           => l_prev_effective_start_date
                               ,x_end_date             => l_prev_effective_end_date
                               ,x_return_status        => x_return_status
                               ,x_msg_count            => x_msg_count
                               ,x_msg_data             => x_msg_data
                               ,p_use_current_mode     => l_use_current_mode
                               );

        x_prev_asof_Date 						:= l_prev_asof_Date;
        x_curr_effective_start_date := l_Start_date;
        x_curr_effective_end_date   := l_end_date;
        x_curr_report_Start_date    := l_current_report_start_date;
        x_prev_report_Start_date 		:= l_prev_report_Start_date;

				x_time_level_id							:= l_time_level_id;
				x_time_level_value					:= l_time_level_value;
        x_prev_effective_start_date := l_prev_effective_start_date;
        x_prev_effective_end_date   := l_prev_effective_end_date;
        x_prev_time_level_id        := l_prev_time_level_id;
        x_prev_time_level_value     := l_prev_time_level_value;

END;



PROCEDURE GET_NESTED_PATTERN
(p_time_comparison_type IN VARCHAR2
,p_time_level           IN VARCHAR2
,x_nested_pattern       OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_Data             OUT NOCOPY VARCHAR2
)
IS
BEGIN
  if(p_time_level = 'FII_TIME_ENT_YEAR') then
    x_nested_pattern := 119;
  elsif(p_time_level = 'FII_TIME_ENT_QTR') then
    x_nested_pattern := 55;
  elsif(p_time_level = 'FII_TIME_ENT_PERIOD') then
    x_nested_pattern := 23;
  elsif(p_time_level = 'FII_TIME_WEEK') then
    x_nested_pattern := 11;
  elsif(p_time_level = 'FII_TIME_DAY') then
    x_nested_pattern := 1;
  else
    x_nested_pattern := 119;
  end if;
  x_return_Status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END;


--Combo Box Enh
PROCEDURE GET_POPLIST_DATES (
	p_asof_date                    IN DATE,
	p_rolling                      IN VARCHAR2 DEFAULT NULL,
	x_last_week	               OUT NOCOPY DATE,
	x_last_period		       OUT NOCOPY DATE,
	x_last_qtr		       OUT NOCOPY DATE,
	x_last_year		       OUT NOCOPY DATE,
	x_week			       OUT NOCOPY DATE,
        x_period		       OUT NOCOPY DATE,
        x_qtr			       OUT NOCOPY DATE,
        x_year			       OUT NOCOPY DATE,
	x_rolling_week	               OUT NOCOPY DATE,
	x_rolling_period	       OUT NOCOPY DATE,
	x_rolling_qtr		       OUT NOCOPY DATE,
	x_rolling_year		       OUT NOCOPY DATE,
	x_return_status                OUT NOCOPY VARCHAR2,
	x_msg_count                    OUT NOCOPY NUMBER,
	x_msg_Data                     OUT NOCOPY VARCHAR2
)
IS
l_asof_date DATE;
l_dynamic_sql varchar2(2000) ;
BEGIN

  IF (p_asof_date IS NOT NULL) THEN
    l_asof_date := p_asof_date;
  ELSE
    l_asof_date := sysdate;
  END IF;

  IF ( (p_rolling = 'Y') OR (p_rolling = 'C') ) THEN
    l_dynamic_sql := 'BEGIN :1 := fii_time_api.rwk_start(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_rolling_week, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.rmth_start(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_rolling_period, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.rqtr_start(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_rolling_qtr, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ryr_start(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_rolling_year, IN l_asof_date;
  END IF;

  IF ( (p_rolling = 'N') OR (p_rolling = 'C') ) THEN
    l_dynamic_sql := 'BEGIN :1 := fii_time_api.pwk_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_last_week, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_pper_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_last_period, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_pqtr_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_last_qtr, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_pyr_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_last_year, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.cwk_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_week, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_cper_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_period, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_cqtr_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_qtr, IN l_asof_date;

    l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_cyr_end(:2); END;';
    EXECUTE IMMEDIATE l_dynamic_sql USING OUT x_year, IN l_asof_date;
  END IF;
  x_return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END GET_POPLIST_DATES;

END BIS_PMV_TIME_LEVELS_PVT;

/
